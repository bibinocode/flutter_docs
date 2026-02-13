# 第 9 章：Go 后端微服务架构

> DApp 不只是前端 + 合约。一个真正的 Web3 产品需要强大的后端：索引链上数据、聚合价格、管理订单、推送通知。这一章用 Gin 框架搭建完整的 DApp 后端。

## 9.1 为什么 DApp 需要后端？

很多新手以为 Web3 = 前端直接连区块链，不需要后端。错了。

```
"纯前端 DApp" 的问题：
❌ 每次打开页面都要从链上重新读取所有数据 → 慢
❌ 无法做复杂查询（如"过去24小时交易量最大的代币"）
❌ 无法推送实时通知
❌ 无法做链下计算（如最优交易路由）
❌ 无法存储用户偏好设置
❌ 前端直接调用 RPC 节点，容易被限流

实际的 DApp 架构：
┌──────────┐     REST/WS     ┌──────────────┐     RPC      ┌──────────┐
│  Flutter  │ ──────────────→ │  Go 后端服务   │ ──────────→ │ 区块链节点 │
│  前端     │ ←────────────── │  (Gin/gRPC)  │ ←────────── │ Ethereum │
└──────────┘                  └──────────────┘              └──────────┘
                                     │
                              ┌──────┴──────┐
                              │             │
                         ┌────┴────┐  ┌─────┴─────┐
                         │ Postgres │  │   Redis   │
                         │ 链上数据  │  │  价格缓存  │
                         └─────────┘  └───────────┘
```

## 9.2 用 Gin 搭建 RESTful API

### 项目初始化

```bash
mkdir dapp-backend && cd dapp-backend
go mod init github.com/yourname/dapp-backend

# 安装依赖
go get github.com/gin-gonic/gin
go get github.com/ethereum/go-ethereum
go get github.com/joho/godotenv
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get github.com/go-redis/redis/v9
go get go.uber.org/zap
```

### 项目结构

```
dapp-backend/
├── cmd/
│   └── server/
│       └── main.go              # 入口
├── internal/
│   ├── config/
│   │   └── config.go            # 配置管理
│   ├── handler/                  # HTTP 处理器
│   │   ├── token_handler.go
│   │   ├── price_handler.go
│   │   └── tx_handler.go
│   ├── service/                  # 业务逻辑
│   │   ├── token_service.go
│   │   ├── price_service.go
│   │   └── indexer_service.go
│   ├── repository/               # 数据访问
│   │   ├── token_repo.go
│   │   └── tx_repo.go
│   ├── blockchain/               # 链交互
│   │   ├── client.go
│   │   ├── erc20.go
│   │   └── events.go
│   ├── middleware/                # 中间件
│   │   ├── cors.go
│   │   ├── ratelimit.go
│   │   └── logger.go
│   └── model/                    # 数据模型
│       ├── token.go
│       └── transaction.go
├── .env
├── go.mod
└── Makefile
```

### 入口文件

```go
// cmd/server/main.go
package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/yourname/dapp-backend/internal/blockchain"
	"github.com/yourname/dapp-backend/internal/handler"
	"github.com/yourname/dapp-backend/internal/middleware"
	"github.com/yourname/dapp-backend/internal/service"
)

func main() {
	// 加载环境变量
	godotenv.Load()

	// 初始化区块链客户端
	ethClient, err := blockchain.NewClient(os.Getenv("ETH_RPC_URL"))
	if err != nil {
		log.Fatalf("连接区块链失败: %v", err)
	}
	defer ethClient.Close()

	// 初始化服务
	tokenSvc := service.NewTokenService(ethClient)
	priceSvc := service.NewPriceService()

	// 初始化 Gin
	r := gin.Default()

	// 中间件
	r.Use(middleware.CORS())
	r.Use(middleware.RateLimit(100)) // 每秒 100 请求
	r.Use(middleware.Logger())

	// 路由
	api := r.Group("/api/v1")
	{
		// 代币相关
		tokens := api.Group("/tokens")
		{
			h := handler.NewTokenHandler(tokenSvc)
			tokens.GET("/:address/info", h.GetTokenInfo)
			tokens.GET("/:address/balance/:wallet", h.GetBalance)
			tokens.GET("/:address/holders", h.GetTopHolders)
		}

		// 价格相关
		prices := api.Group("/prices")
		{
			h := handler.NewPriceHandler(priceSvc)
			prices.GET("/:symbol", h.GetPrice)
			prices.GET("/:symbol/history", h.GetPriceHistory)
		}

		// 交易相关
		txs := api.Group("/transactions")
		{
			h := handler.NewTxHandler(ethClient)
			txs.GET("/:hash", h.GetTransaction)
			txs.GET("/address/:address", h.GetTransactionsByAddress)
			txs.POST("/send", h.SendTransaction)
		}

		// 链信息
		api.GET("/chain/status", func(c *gin.Context) {
			blockNum, _ := ethClient.BlockNumber()
			gasPrice, _ := ethClient.GasPrice()
			c.JSON(200, gin.H{
				"block_number": blockNum,
				"gas_price":    gasPrice,
				"chain_id":     ethClient.ChainID(),
			})
		})
	}

	// 启动服务
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("🚀 服务启动在 http://localhost:%s", port)
	r.Run(":" + port)
}
```

### 代币信息 Handler

```go
// internal/handler/token_handler.go
package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/yourname/dapp-backend/internal/service"
)

type TokenHandler struct {
	svc *service.TokenService
}

func NewTokenHandler(svc *service.TokenService) *TokenHandler {
	return &TokenHandler{svc: svc}
}

// GetTokenInfo 获取代币基本信息
// GET /api/v1/tokens/:address/info
func (h *TokenHandler) GetTokenInfo(c *gin.Context) {
	address := c.Param("address")

	info, err := h.svc.GetTokenInfo(c.Request.Context(), address)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": info,
	})
}

// GetBalance 查询代币余额
// GET /api/v1/tokens/:address/balance/:wallet
func (h *TokenHandler) GetBalance(c *gin.Context) {
	tokenAddress := c.Param("address")
	walletAddress := c.Param("wallet")

	balance, err := h.svc.GetBalance(c.Request.Context(), tokenAddress, walletAddress)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"token":   tokenAddress,
			"wallet":  walletAddress,
			"balance": balance.String(),
			"formatted": balance.Formatted,
		},
	})
}
```

### 代币服务（业务逻辑层）

```go
// internal/service/token_service.go
package service

import (
	"context"
	"fmt"
	"math"
	"math/big"

	"github.com/yourname/dapp-backend/internal/blockchain"
)

type TokenInfo struct {
	Address     string `json:"address"`
	Name        string `json:"name"`
	Symbol      string `json:"symbol"`
	Decimals    uint8  `json:"decimals"`
	TotalSupply string `json:"total_supply"`
}

type TokenBalance struct {
	Raw       *big.Int `json:"raw"`
	Formatted string   `json:"formatted"`
}

func (b TokenBalance) String() string {
	return b.Raw.String()
}

type TokenService struct {
	client *blockchain.Client
}

func NewTokenService(client *blockchain.Client) *TokenService {
	return &TokenService{client: client}
}

// GetTokenInfo 获取代币信息
func (s *TokenService) GetTokenInfo(ctx context.Context, address string) (*TokenInfo, error) {
	erc20, err := blockchain.NewERC20(s.client, address)
	if err != nil {
		return nil, fmt.Errorf("创建 ERC20 实例失败: %w", err)
	}

	name, err := erc20.Name(ctx)
	if err != nil {
		return nil, fmt.Errorf("查询名称失败: %w", err)
	}

	symbol, err := erc20.Symbol(ctx)
	if err != nil {
		return nil, fmt.Errorf("查询符号失败: %w", err)
	}

	decimals, err := erc20.Decimals(ctx)
	if err != nil {
		return nil, fmt.Errorf("查询精度失败: %w", err)
	}

	totalSupply, err := erc20.TotalSupply(ctx)
	if err != nil {
		return nil, fmt.Errorf("查询总供应量失败: %w", err)
	}

	// 格式化总供应量
	formatted := formatTokenAmount(totalSupply, decimals)

	return &TokenInfo{
		Address:     address,
		Name:        name,
		Symbol:      symbol,
		Decimals:    decimals,
		TotalSupply: formatted,
	}, nil
}

// GetBalance 查询代币余额
func (s *TokenService) GetBalance(ctx context.Context, tokenAddr, walletAddr string) (*TokenBalance, error) {
	erc20, err := blockchain.NewERC20(s.client, tokenAddr)
	if err != nil {
		return nil, err
	}

	balance, err := erc20.BalanceOf(ctx, walletAddr)
	if err != nil {
		return nil, err
	}

	decimals, err := erc20.Decimals(ctx)
	if err != nil {
		return nil, err
	}

	return &TokenBalance{
		Raw:       balance,
		Formatted: formatTokenAmount(balance, decimals),
	}, nil
}

// formatTokenAmount 将原始金额格式化为可读字符串
func formatTokenAmount(amount *big.Int, decimals uint8) string {
	if amount == nil {
		return "0"
	}
	divisor := new(big.Float).SetFloat64(math.Pow10(int(decimals)))
	result := new(big.Float).Quo(new(big.Float).SetInt(amount), divisor)
	return result.Text('f', 4)
}
```

### 中间件

```go
// internal/middleware/cors.go
package middleware

import (
	"github.com/gin-gonic/gin"
)

// CORS 跨域中间件
func CORS() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
```

```go
// internal/middleware/ratelimit.go
package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// RateLimit 令牌桶限流
func RateLimit(maxPerSecond int) gin.HandlerFunc {
	type client struct {
		tokens    int
		lastReset time.Time
	}

	var mu sync.Mutex
	clients := make(map[string]*client)

	return func(c *gin.Context) {
		ip := c.ClientIP()

		mu.Lock()
		cl, exists := clients[ip]
		if !exists {
			cl = &client{tokens: maxPerSecond, lastReset: time.Now()}
			clients[ip] = cl
		}

		// 每秒重置令牌
		if time.Since(cl.lastReset) > time.Second {
			cl.tokens = maxPerSecond
			cl.lastReset = time.Now()
		}

		if cl.tokens <= 0 {
			mu.Unlock()
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error": "请求过于频繁，请稍后再试",
			})
			c.Abort()
			return
		}

		cl.tokens--
		mu.Unlock()

		c.Next()
	}
}
```

## 9.3 链上事件索引服务

这是 DApp 后端最核心的功能之一：监听链上事件，存入数据库，供前端快速查询。

```go
// internal/service/indexer_service.go
package service

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

// IndexerService 链上事件索引服务
type IndexerService struct {
	client       *ethclient.Client
	contracts    []common.Address // 要监听的合约地址
	startBlock   uint64           // 开始扫描的区块
	batchSize    uint64           // 每批扫描的区块数
}

// TransferEvent 解析后的 Transfer 事件
type TransferEvent struct {
	ContractAddress string    `json:"contract_address"`
	From            string    `json:"from"`
	To              string    `json:"to"`
	Value           *big.Int  `json:"value"`
	BlockNumber     uint64    `json:"block_number"`
	TxHash          string    `json:"tx_hash"`
	LogIndex        uint      `json:"log_index"`
	Timestamp       time.Time `json:"timestamp"`
}

func NewIndexerService(client *ethclient.Client, contracts []string, startBlock uint64) *IndexerService {
	var addrs []common.Address
	for _, addr := range contracts {
		addrs = append(addrs, common.HexToAddress(addr))
	}
	return &IndexerService{
		client:    client,
		contracts: addrs,
		startBlock: startBlock,
		batchSize: 1000,
	}
}

// Transfer 事件的 Topic
var transferTopic = common.HexToHash("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef")

// StartHistoricalSync 扫描历史事件（回填数据）
func (s *IndexerService) StartHistoricalSync(ctx context.Context, onEvent func(TransferEvent)) error {
	currentBlock, err := s.client.BlockNumber(ctx)
	if err != nil {
		return fmt.Errorf("获取当前区块失败: %w", err)
	}

	log.Printf("📊 开始历史同步: 从区块 %d 到 %d", s.startBlock, currentBlock)

	for from := s.startBlock; from <= currentBlock; from += s.batchSize {
		to := from + s.batchSize - 1
		if to > currentBlock {
			to = currentBlock
		}

		events, err := s.fetchEvents(ctx, from, to)
		if err != nil {
			log.Printf("⚠️ 扫描区块 %d-%d 失败: %v", from, to, err)
			continue
		}

		for _, event := range events {
			onEvent(event)
		}

		log.Printf("✅ 已同步区块 %d-%d, 事件数: %d", from, to, len(events))
	}

	return nil
}

// StartRealtimeSync 实时监听新事件
func (s *IndexerService) StartRealtimeSync(ctx context.Context, onEvent func(TransferEvent)) error {
	query := ethereum.FilterQuery{
		Addresses: s.contracts,
		Topics:    [][]common.Hash{{transferTopic}},
	}

	logsCh := make(chan types.Log, 100)
	sub, err := s.client.SubscribeFilterLogs(ctx, query, logsCh)
	if err != nil {
		return fmt.Errorf("订阅事件失败: %w", err)
	}

	log.Println("🔍 开始实时监听事件...")

	for {
		select {
		case err := <-sub.Err():
			log.Printf("⚠️ 订阅错误: %v, 5秒后重连...", err)
			time.Sleep(5 * time.Second)
			sub, err = s.client.SubscribeFilterLogs(ctx, query, logsCh)
			if err != nil {
				return err
			}

		case vLog := <-logsCh:
			event := s.parseTransferLog(vLog)
			onEvent(event)

		case <-ctx.Done():
			sub.Unsubscribe()
			return nil
		}
	}
}

// fetchEvents 批量获取事件
func (s *IndexerService) fetchEvents(ctx context.Context, fromBlock, toBlock uint64) ([]TransferEvent, error) {
	query := ethereum.FilterQuery{
		FromBlock: new(big.Int).SetUint64(fromBlock),
		ToBlock:   new(big.Int).SetUint64(toBlock),
		Addresses: s.contracts,
		Topics:    [][]common.Hash{{transferTopic}},
	}

	logs, err := s.client.FilterLogs(ctx, query)
	if err != nil {
		return nil, err
	}

	var events []TransferEvent
	for _, vLog := range logs {
		events = append(events, s.parseTransferLog(vLog))
	}
	return events, nil
}

// parseTransferLog 解析 Transfer 事件日志
func (s *IndexerService) parseTransferLog(vLog types.Log) TransferEvent {
	return TransferEvent{
		ContractAddress: vLog.Address.Hex(),
		From:            common.HexToAddress(vLog.Topics[1].Hex()).Hex(),
		To:              common.HexToAddress(vLog.Topics[2].Hex()).Hex(),
		Value:           new(big.Int).SetBytes(vLog.Data),
		BlockNumber:     vLog.BlockNumber,
		TxHash:          vLog.TxHash.Hex(),
		LogIndex:        vLog.Index,
	}
}
```

### 使用索引服务

```go
func main() {
	client, _ := ethclient.Dial("wss://eth-mainnet.g.alchemy.com/v2/YOUR_KEY")

	// 监听 USDT 和 USDC 的 Transfer 事件
	indexer := service.NewIndexerService(client, []string{
		"0xdAC17F958D2ee523a2206206994597C13D831ec7", // USDT
		"0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", // USDC
	}, 19000000) // 从区块 19000000 开始

	ctx := context.Background()

	// 事件处理回调
	handleEvent := func(event service.TransferEvent) {
		fmt.Printf("💸 %s Transfer: %s → %s, 金额: %s (区块 %d)\n",
			event.ContractAddress[:8],
			event.From[:8],
			event.To[:8],
			event.Value.String(),
			event.BlockNumber,
		)
		// 实际项目中：存入数据库
		// repo.SaveTransferEvent(event)
	}

	// 先同步历史数据
	go indexer.StartHistoricalSync(ctx, handleEvent)

	// 同时开始实时监听
	indexer.StartRealtimeSync(ctx, handleEvent)
}
```

## 9.4 价格缓存服务（Redis）

```go
// internal/service/price_service.go
package service

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/go-redis/redis/v9"
)

type PriceService struct {
	redis      *redis.Client
	httpClient *http.Client
}

type TokenPrice struct {
	Symbol    string    `json:"symbol"`
	PriceUSD  float64   `json:"price_usd"`
	Change24h float64   `json:"change_24h"`
	UpdatedAt time.Time `json:"updated_at"`
}

func NewPriceService() *PriceService {
	rdb := redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})
	return &PriceService{
		redis:      rdb,
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

// GetPrice 获取代币价格（优先从缓存读取）
func (s *PriceService) GetPrice(ctx context.Context, symbol string) (*TokenPrice, error) {
	cacheKey := fmt.Sprintf("price:%s", symbol)

	// 1. 尝试从 Redis 缓存读取
	cached, err := s.redis.Get(ctx, cacheKey).Result()
	if err == nil {
		var price TokenPrice
		json.Unmarshal([]byte(cached), &price)
		return &price, nil
	}

	// 2. 缓存未命中，从 CoinGecko API 获取
	price, err := s.fetchPriceFromAPI(symbol)
	if err != nil {
		return nil, err
	}

	// 3. 写入缓存（30秒过期）
	data, _ := json.Marshal(price)
	s.redis.Set(ctx, cacheKey, data, 30*time.Second)

	return price, nil
}

// fetchPriceFromAPI 从 CoinGecko 获取价格
func (s *PriceService) fetchPriceFromAPI(symbol string) (*TokenPrice, error) {
	// CoinGecko 免费 API
	url := fmt.Sprintf(
		"https://api.coingecko.com/api/v3/simple/price?ids=%s&vs_currencies=usd&include_24hr_change=true",
		symbol,
	)

	resp, err := s.httpClient.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	var result map[string]struct {
		USD       float64 `json:"usd"`
		Change24h float64 `json:"usd_24h_change"`
	}
	json.Unmarshal(body, &result)

	data, ok := result[symbol]
	if !ok {
		return nil, fmt.Errorf("未找到 %s 的价格数据", symbol)
	}

	return &TokenPrice{
		Symbol:    symbol,
		PriceUSD:  data.USD,
		Change24h: data.Change24h,
		UpdatedAt: time.Now(),
	}, nil
}
```

## 9.5 本章小结与练习

### 你学到了什么

- DApp 后端的必要性和架构设计
- Gin 框架搭建 RESTful API（路由、Handler、中间件）
- 链上事件索引服务（历史扫描 + 实时监听）
- Redis 价格缓存服务
- 分层架构：Handler → Service → Repository → Blockchain

### 动手练习

1. **完整 API 服务**：补全上面的代码，实现一个完整的 DApp 后端，支持：查询代币信息、查询余额、查询交易历史、获取价格

2. **WebSocket 推送**：添加 WebSocket 端点，当监听到大额 Transfer 事件时，实时推送给前端

3. **数据库持久化**：用 GORM + PostgreSQL 存储索引到的 Transfer 事件，支持按地址、时间范围查询

### 下一章预告

下一章进入 DeFi 协议开发——Uniswap V3/V4 的数学原理和合约实现，这是 Web3 开发的核心技能。
