# 第 10 章：Go 后端数据存储与高可用

> 上一章搭了 API 骨架和事件索引器，但数据都在内存里——重启就没了。这一章解决"数据往哪存、怎么存、怎么不丢"的问题：PostgreSQL 做持久化、Redis 做缓存和分布式锁、IPFS 做去中心化存储，最后搭建监控体系让你的服务在生产环境跑得稳。

## 10.1 为什么 Web3 后端的存储这么重要？

```
一个常见的误解：
"区块链本身就是数据库，为什么还需要 PostgreSQL？"

答案：链上数据的查询能力极其有限。

你能在链上做的查询：
✅ 查某个地址的 ETH 余额
✅ 查某笔交易的详情
✅ 查某个合约的某个 storage slot

你不能在链上做的查询：
❌ "过去 24 小时交易量最大的 10 个代币"
❌ "某个地址的所有 ERC-20 转账历史"
❌ "Uniswap 上 ETH/USDC 的 1 小时 K 线"
❌ "持有某个 NFT 的所有地址"
❌ "某个代币的持有者数量排行"

所以你需要：
┌──────────┐  事件索引   ┌──────────────┐  快速查询  ┌──────────┐
│ 区块链    │ ─────────→ │  PostgreSQL  │ ─────────→ │  前端     │
│ (数据源)  │            │  (结构化存储) │            │  (展示)   │
└──────────┘            └──────────────┘            └──────────┘
                               │
                        ┌──────┴──────┐
                        │   Redis     │
                        │  (热数据缓存) │
                        └─────────────┘
```

## 10.2 PostgreSQL + GORM：链上数据持久化

### 为什么选 PostgreSQL？

| 特性 | MySQL | PostgreSQL | MongoDB |
|------|-------|-----------|---------|
| JSON 查询 | 一般 | 原生支持 jsonb | 原生 |
| 大数支持 | BIGINT (8字节) | NUMERIC (任意精度) | NumberDecimal |
| 数组类型 | 不支持 | 原生支持 | 原生 |
| 全文搜索 | 插件 | 内置 | 内置 |
| 事务隔离 | MVCC | MVCC (更严格) | 4.0+ |
| 适合 Web3 | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

PostgreSQL 的 `NUMERIC` 类型可以精确存储以太坊的 256 位整数，`jsonb` 可以存储 NFT 元数据，这是选它的核心原因。

### 安装与配置

```bash
# macOS
brew install postgresql@16
brew services start postgresql@16

# 创建数据库
createdb dapp_dev

# 或者用 Docker（推荐）
docker run -d \
  --name postgres-web3 \
  -e POSTGRES_USER=dapp \
  -e POSTGRES_PASSWORD=dapp123 \
  -e POSTGRES_DB=dapp_dev \
  -p 5432:5432 \
  postgres:16-alpine
```

### GORM 基础配置

```bash
go get gorm.io/gorm
go get gorm.io/driver/postgres
```

```go
// internal/database/postgres.go
package database

import (
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// NewPostgresDB 创建 PostgreSQL 连接
func NewPostgresDB() (*gorm.DB, error) {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		getEnv("DB_HOST", "localhost"),
		getEnv("DB_PORT", "5432"),
		getEnv("DB_USER", "dapp"),
		getEnv("DB_PASSWORD", "dapp123"),
		getEnv("DB_NAME", "dapp_dev"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return nil, fmt.Errorf("连接数据库失败: %w", err)
	}

	// 连接池配置
	sqlDB, _ := db.DB()
	sqlDB.SetMaxOpenConns(50)              // 最大连接数
	sqlDB.SetMaxIdleConns(10)              // 最大空闲连接
	sqlDB.SetConnMaxLifetime(time.Hour)    // 连接最大存活时间
	sqlDB.SetConnMaxIdleTime(10 * time.Minute)

	log.Println("✅ PostgreSQL 连接成功")
	return db, nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
```

### 数据模型设计：Web3 场景

Web3 后端最常见的数据模型有这几类：区块数据、交易记录、代币信息、用户资产。下面是一个完整的 DEX 数据库 Schema 设计：

```go
// internal/model/models.go
package model

import (
	"time"

	"gorm.io/gorm"
)

// ========== 区块与交易 ==========

// Block 区块记录（索引器同步的区块）
type Block struct {
	gorm.Model
	ChainID     uint64 `gorm:"index;not null" json:"chain_id"`
	BlockNumber uint64 `gorm:"uniqueIndex:idx_chain_block;not null" json:"block_number"`
	BlockHash   string `gorm:"type:char(66);uniqueIndex" json:"block_hash"`
	ParentHash  string `gorm:"type:char(66)" json:"parent_hash"`
	Timestamp   uint64 `json:"timestamp"`
	GasUsed     uint64 `json:"gas_used"`
	GasLimit    uint64 `json:"gas_limit"`
	BaseFee     string `gorm:"type:numeric(78)" json:"base_fee"` // 用 NUMERIC 存大数
	TxCount     int    `json:"tx_count"`
}

// Transaction 交易记录
type Transaction struct {
	gorm.Model
	ChainID     uint64 `gorm:"index;not null" json:"chain_id"`
	TxHash      string `gorm:"type:char(66);uniqueIndex;not null" json:"tx_hash"`
	BlockNumber uint64 `gorm:"index" json:"block_number"`
	FromAddress string `gorm:"type:char(42);index" json:"from_address"`
	ToAddress   string `gorm:"type:char(42);index" json:"to_address"`
	Value       string `gorm:"type:numeric(78)" json:"value"`
	GasPrice    string `gorm:"type:numeric(78)" json:"gas_price"`
	GasUsed     uint64 `json:"gas_used"`
	Nonce       uint64 `json:"nonce"`
	Status      uint64 `json:"status"` // 0=失败, 1=成功
	InputData   []byte `gorm:"type:bytea" json:"-"`
	Timestamp   time.Time `gorm:"index" json:"timestamp"`
}

// ========== 代币与资产 ==========

// Token 代币信息
type Token struct {
	gorm.Model
	ChainID         uint64 `gorm:"uniqueIndex:idx_chain_token;not null" json:"chain_id"`
	ContractAddress string `gorm:"type:char(42);uniqueIndex:idx_chain_token;not null" json:"contract_address"`
	Name            string `gorm:"type:varchar(100)" json:"name"`
	Symbol          string `gorm:"type:varchar(20);index" json:"symbol"`
	Decimals        uint8  `json:"decimals"`
	TotalSupply     string `gorm:"type:numeric(78)" json:"total_supply"`
	LogoURL         string `gorm:"type:text" json:"logo_url"`
	IsVerified      bool   `gorm:"default:false" json:"is_verified"`
}

// TokenTransfer ERC-20 转账记录
type TokenTransfer struct {
	gorm.Model
	ChainID         uint64 `gorm:"index;not null" json:"chain_id"`
	ContractAddress string `gorm:"type:char(42);index" json:"contract_address"`
	TxHash          string `gorm:"type:char(66);index" json:"tx_hash"`
	BlockNumber     uint64 `gorm:"index" json:"block_number"`
	LogIndex        uint   `json:"log_index"`
	FromAddress     string `gorm:"type:char(42);index:idx_from_time" json:"from_address"`
	ToAddress       string `gorm:"type:char(42);index:idx_to_time" json:"to_address"`
	Value           string `gorm:"type:numeric(78)" json:"value"`
	Timestamp       time.Time `gorm:"index:idx_from_time;index:idx_to_time" json:"timestamp"`
}

// ========== DEX 交易数据 ==========

// SwapEvent DEX 交易事件
type SwapEvent struct {
	gorm.Model
	ChainID     uint64 `gorm:"index;not null" json:"chain_id"`
	PoolAddress string `gorm:"type:char(42);index" json:"pool_address"`
	TxHash      string `gorm:"type:char(66);index" json:"tx_hash"`
	BlockNumber uint64 `gorm:"index" json:"block_number"`
	Sender      string `gorm:"type:char(42)" json:"sender"`
	Recipient   string `gorm:"type:char(42)" json:"recipient"`
	Amount0In   string `gorm:"type:numeric(78)" json:"amount0_in"`
	Amount1In   string `gorm:"type:numeric(78)" json:"amount1_in"`
	Amount0Out  string `gorm:"type:numeric(78)" json:"amount0_out"`
	Amount1Out  string `gorm:"type:numeric(78)" json:"amount1_out"`
	Price       string `gorm:"type:numeric(38,18)" json:"price"`
	Timestamp   time.Time `gorm:"index" json:"timestamp"`
}

// LiquidityPool 流动性池
type LiquidityPool struct {
	gorm.Model
	ChainID      uint64 `gorm:"uniqueIndex:idx_chain_pool;not null" json:"chain_id"`
	PoolAddress  string `gorm:"type:char(42);uniqueIndex:idx_chain_pool;not null" json:"pool_address"`
	Token0       string `gorm:"type:char(42)" json:"token0"`
	Token1       string `gorm:"type:char(42)" json:"token1"`
	Fee          uint32 `json:"fee"`           // 手续费等级 (500, 3000, 10000)
	TickSpacing  int32  `json:"tick_spacing"`
	Liquidity    string `gorm:"type:numeric(78)" json:"liquidity"`
	SqrtPriceX96 string `gorm:"type:numeric(78)" json:"sqrt_price_x96"`
	Tick         int32  `json:"tick"`
	TVL          string `gorm:"type:numeric(38,2)" json:"tvl"` // 总锁仓价值 (USD)
}
```

### 数据库迁移

```go
// internal/database/migrate.go
package database

import (
	"log"

	"github.com/yourname/dapp-backend/internal/model"
	"gorm.io/gorm"
)

// AutoMigrate 自动迁移数据库表结构
func AutoMigrate(db *gorm.DB) error {
	log.Println("🔄 开始数据库迁移...")

	err := db.AutoMigrate(
		&model.Block{},
		&model.Transaction{},
		&model.Token{},
		&model.TokenTransfer{},
		&model.SwapEvent{},
		&model.LiquidityPool{},
	)
	if err != nil {
		return err
	}

	// 创建复合索引（GORM AutoMigrate 不支持的复杂索引）
	db.Exec(`
		CREATE INDEX IF NOT EXISTS idx_swap_pool_time 
		ON swap_events (pool_address, timestamp DESC);
	`)
	db.Exec(`
		CREATE INDEX IF NOT EXISTS idx_transfer_contract_time 
		ON token_transfers (contract_address, timestamp DESC);
	`)

	log.Println("✅ 数据库迁移完成")
	return nil
}
```

### Repository 层：数据访问

```go
// internal/repository/token_transfer_repo.go
package repository

import (
	"context"
	"time"

	"github.com/yourname/dapp-backend/internal/model"
	"gorm.io/gorm"
)

type TokenTransferRepo struct {
	db *gorm.DB
}

func NewTokenTransferRepo(db *gorm.DB) *TokenTransferRepo {
	return &TokenTransferRepo{db: db}
}

```go
// BatchCreate 批量插入转账记录（索引器用）
func (r *TokenTransferRepo) BatchCreate(ctx context.Context, transfers []model.TokenTransfer) error {
	// GORM 批量插入，每批 500 条
	return r.db.WithContext(ctx).CreateInBatches(transfers, 500).Error
}

// GetByAddress 查询某地址的转账记录（分页）
func (r *TokenTransferRepo) GetByAddress(
	ctx context.Context,
	address string,
	page, pageSize int,
) ([]model.TokenTransfer, int64, error) {
	var transfers []model.TokenTransfer
	var total int64

	query := r.db.WithContext(ctx).
		Where("from_address = ? OR to_address = ?", address, address)

	// 先查总数
	query.Model(&model.TokenTransfer{}).Count(&total)

	// 再查分页数据
	err := query.
		Order("timestamp DESC").
		Offset((page - 1) * pageSize).
		Limit(pageSize).
		Find(&transfers).Error

	return transfers, total, err
}

// GetByContract 查询某代币的转账记录
func (r *TokenTransferRepo) GetByContract(
	ctx context.Context,
	contractAddress string,
	since time.Time,
	limit int,
) ([]model.TokenTransfer, error) {
	var transfers []model.TokenTransfer
	err := r.db.WithContext(ctx).
		Where("contract_address = ? AND timestamp >= ?", contractAddress, since).
		Order("timestamp DESC").
		Limit(limit).
		Find(&transfers).Error
	return transfers, err
}

// GetTransferVolume 查询某代币在时间段内的转账总量
func (r *TokenTransferRepo) GetTransferVolume(
	ctx context.Context,
	contractAddress string,
	start, end time.Time,
) (string, error) {
	var result struct {
		TotalVolume string
	}
	err := r.db.WithContext(ctx).
		Model(&model.TokenTransfer{}).
		Select("COALESCE(SUM(value::numeric), 0) as total_volume").
		Where("contract_address = ? AND timestamp BETWEEN ? AND ?",
			contractAddress, start, end).
		Scan(&result).Error
	return result.TotalVolume, err
}
```

### DEX 交易数据 Repository

```go
// internal/repository/swap_repo.go
package repository

import (
	"context"
	"time"

	"github.com/yourname/dapp-backend/internal/model"
	"gorm.io/gorm"
)

type SwapRepo struct {
	db *gorm.DB
}

func NewSwapRepo(db *gorm.DB) *SwapRepo {
	return &SwapRepo{db: db}
}

// KlineData K 线数据结构
type KlineData struct {
	Timestamp time.Time `json:"timestamp"`
	Open      string    `json:"open"`
	High      string    `json:"high"`
	Low       string    `json:"low"`
	Close     string    `json:"close"`
	Volume    string    `json:"volume"`
}

// GetKlineData 生成 K 线数据
// interval: "1m", "5m", "1h", "1d"
func (r *SwapRepo) GetKlineData(
	ctx context.Context,
	poolAddress string,
	interval string,
	start, end time.Time,
) ([]KlineData, error) {
	// PostgreSQL 的 date_trunc + time_bucket 生成 K 线
	// 这里用 date_trunc 做简化版本
	var truncExpr string
	switch interval {
	case "1m":
		truncExpr = "minute"
	case "5m":
		// PostgreSQL 没有原生 5 分钟截断，用表达式
		truncExpr = "minute" // 简化处理
	case "1h":
		truncExpr = "hour"
	case "1d":
		truncExpr = "day"
	default:
		truncExpr = "hour"
	}

	var klines []KlineData
	err := r.db.WithContext(ctx).Raw(`
		SELECT 
			date_trunc(?, timestamp) as timestamp,
			(array_agg(price ORDER BY timestamp ASC))[1] as open,
			MAX(price::numeric)::text as high,
			MIN(price::numeric)::text as low,
			(array_agg(price ORDER BY timestamp DESC))[1] as close,
			SUM(ABS(amount0_in::numeric) + ABS(amount0_out::numeric))::text as volume
		FROM swap_events
		WHERE pool_address = ? 
			AND timestamp BETWEEN ? AND ?
			AND price IS NOT NULL
			AND price != ''
		GROUP BY date_trunc(?, timestamp)
		ORDER BY timestamp ASC
	`, truncExpr, poolAddress, start, end, truncExpr).
		Scan(&klines).Error

	return klines, err
}

// GetTopPools 获取交易量最大的池子
func (r *SwapRepo) GetTopPools(ctx context.Context, limit int) ([]model.LiquidityPool, error) {
	var pools []model.LiquidityPool
	err := r.db.WithContext(ctx).
		Order("tvl::numeric DESC").
		Limit(limit).
		Find(&pools).Error
	return pools, err
}
```

## 10.3 Redis 深度使用：缓存、锁、队列

Redis 在 Web3 后端的三大用途：
1. **热数据缓存**：代币价格、Gas 价格、区块高度
2. **分布式锁**：防止多个索引器重复处理同一区块
3. **消息队列**：链上事件的异步处理

### Redis 客户端封装

```go
// internal/cache/redis.go
package cache

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/go-redis/redis/v9"
)

type RedisCache struct {
	client *redis.Client
}

func NewRedisCache(addr, password string, db int) (*RedisCache, error) {
	client := redis.NewClient(&redis.Options{
		Addr:         addr,
		Password:     password,
		DB:           db,
		PoolSize:     50,
		MinIdleConns: 10,
		DialTimeout:  5 * time.Second,
		ReadTimeout:  3 * time.Second,
		WriteTimeout: 3 * time.Second,
	})

	// 测试连接
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("Redis 连接失败: %w", err)
	}

	return &RedisCache{client: client}, nil
}

// ========== 通用缓存操作 ==========

// Get 获取缓存（泛型版本）
func Get[T any](c *RedisCache, ctx context.Context, key string) (*T, error) {
	data, err := c.client.Get(ctx, key).Bytes()
	if err == redis.Nil {
		return nil, nil // 缓存未命中
	}
	if err != nil {
		return nil, err
	}

	var result T
	if err := json.Unmarshal(data, &result); err != nil {
		return nil, err
	}
	return &result, nil
}

// Set 设置缓存
func Set[T any](c *RedisCache, ctx context.Context, key string, value T, ttl time.Duration) error {
	data, err := json.Marshal(value)
	if err != nil {
		return err
	}
	return c.client.Set(ctx, key, data, ttl).Err()
}

// Delete 删除缓存
func (c *RedisCache) Delete(ctx context.Context, keys ...string) error {
	return c.client.Del(ctx, keys...).Err()
}
```

### 代币价格缓存（防穿透 + 防雪崩）

```go
// internal/cache/price_cache.go
package cache

import (
	"context"
	"fmt"
	"math/rand"
	"sync"
	"time"
)

type TokenPriceCache struct {
	redis      *RedisCache
	mu         sync.Mutex
	singleFlight map[string]chan struct{} // 防止缓存击穿
}

type CachedPrice struct {
	Symbol    string  `json:"symbol"`
	PriceUSD  float64 `json:"price_usd"`
	Change24h float64 `json:"change_24h"`
	UpdatedAt int64   `json:"updated_at"`
}

func NewTokenPriceCache(redis *RedisCache) *TokenPriceCache {
	return &TokenPriceCache{
		redis:        redis,
		singleFlight: make(map[string]chan struct{}),
	}
}

// GetPrice 获取价格（带三级防护）
// 1. 缓存穿透防护：空值缓存
// 2. 缓存击穿防护：singleflight 模式
// 3. 缓存雪崩防护：随机过期时间
func (c *TokenPriceCache) GetPrice(
	ctx context.Context,
	symbol string,
	fetchFn func(string) (*CachedPrice, error), // 缓存未命中时的获取函数
) (*CachedPrice, error) {
	key := fmt.Sprintf("price:%s", symbol)

	// 1. 尝试从缓存获取
	cached, err := Get[CachedPrice](c.redis, ctx, key)
	if err != nil {
		return nil, err
	}
	if cached != nil {
		// 检查是否是空值缓存（防穿透）
		if cached.PriceUSD == -1 {
			return nil, fmt.Errorf("代币 %s 不存在", symbol)
		}
		return cached, nil
	}

	// 2. 缓存未命中 → singleflight 防击穿
	c.mu.Lock()
	if ch, ok := c.singleFlight[symbol]; ok {
		c.mu.Unlock()
		// 已经有人在获取了，等待结果
		<-ch
		// 重新从缓存读取
		cached, _ = Get[CachedPrice](c.redis, ctx, key)
		if cached != nil {
			return cached, nil
		}
		return nil, fmt.Errorf("获取价格失败")
	}

	// 标记正在获取
	ch := make(chan struct{})
	c.singleFlight[symbol] = ch
	c.mu.Unlock()

	defer func() {
		close(ch)
		c.mu.Lock()
		delete(c.singleFlight, symbol)
		c.mu.Unlock()
	}()

	// 3. 从数据源获取
	price, err := fetchFn(symbol)
	if err != nil {
		// 缓存空值，防止穿透（短过期时间）
		emptyPrice := &CachedPrice{Symbol: symbol, PriceUSD: -1}
		Set(c.redis, ctx, key, emptyPrice, 30*time.Second)
		return nil, err
	}

	// 4. 写入缓存（随机过期时间防雪崩）
	// 基础 30 秒 + 随机 0-10 秒
	ttl := 30*time.Second + time.Duration(rand.Intn(10))*time.Second
	Set(c.redis, ctx, key, price, ttl)

	return price, nil
}
```

### 分布式锁：防止重复索引

当你有多个索引器实例时，需要确保同一个区块不会被重复处理：

```go
// internal/cache/distributed_lock.go
package cache

import (
	"context"
	"fmt"
	"time"

	"github.com/go-redis/redis/v9"
	"github.com/google/uuid"
)

type DistributedLock struct {
	client *redis.Client
	key    string
	value  string // 唯一标识，防止误释放
	ttl    time.Duration
}

// NewLock 创建分布式锁
func NewLock(client *redis.Client, resource string, ttl time.Duration) *DistributedLock {
	return &DistributedLock{
		client: client,
		key:    fmt.Sprintf("lock:%s", resource),
		value:  uuid.New().String(),
		ttl:    ttl,
	}
}

// Acquire 获取锁
func (l *DistributedLock) Acquire(ctx context.Context) (bool, error) {
	// SET key value NX EX ttl
	// NX = 只在 key 不存在时设置（原子操作）
	ok, err := l.client.SetNX(ctx, l.key, l.value, l.ttl).Result()
	return ok, err
}

// Release 释放锁（Lua 脚本保证原子性）
func (l *DistributedLock) Release(ctx context.Context) error {
	// 用 Lua 脚本确保只释放自己的锁
	script := redis.NewScript(`
		if redis.call("GET", KEYS[1]) == ARGV[1] then
			return redis.call("DEL", KEYS[1])
		else
			return 0
		end
	`)
	_, err := script.Run(ctx, l.client, []string{l.key}, l.value).Result()
	return err
}

// 使用示例：索引器获取区块处理锁
func processBlockWithLock(client *redis.Client, blockNum uint64) error {
	ctx := context.Background()
	lock := NewLock(client, fmt.Sprintf("block:%d", blockNum), 30*time.Second)

	acquired, err := lock.Acquire(ctx)
	if err != nil {
		return err
	}
	if !acquired {
		// 其他实例正在处理这个区块，跳过
		return nil
	}
	defer lock.Release(ctx)

	// 安全地处理区块...
	fmt.Printf("🔒 获取锁成功，处理区块 %d\n", blockNum)
	// processBlock(blockNum)
	return nil
}
```

## 10.4 IPFS 与去中心化存储

NFT 的图片和元数据不能存在中心化服务器上（服务器挂了 NFT 就变成空白了）。IPFS 是去中心化存储的标准方案。

### IPFS 工作原理

```
传统存储（基于位置寻址）：
  "给我 https://example.com/image.png 这个 URL 的文件"
  → 如果服务器挂了，文件就没了

IPFS 存储（基于内容寻址）：
  "给我哈希为 QmX...abc 的文件"
  → 只要网络中任何节点有这个文件，就能获取到
  → 文件内容决定哈希，内容不可篡改

上传流程：
  文件 → SHA-256 哈希 → CID (Content Identifier) → 分发到 IPFS 网络
  
  例如：
  image.png → QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG
  
  访问方式：
  https://ipfs.io/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG
  https://gateway.pinata.cloud/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG
```

### 用 Pinata 上传文件到 IPFS

Pinata 是最流行的 IPFS Pinning 服务，免费额度足够开发使用。

```bash
# 注册 Pinata 账号：https://app.pinata.cloud/
# 获取 API Key 和 Secret
```

```go
// internal/storage/ipfs.go
package storage

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

type IPFSClient struct {
	apiKey    string
	apiSecret string
	httpClient *http.Client
}

type PinataResponse struct {
	IpfsHash  string `json:"IpfsHash"`
	PinSize   int    `json:"PinSize"`
	Timestamp string `json:"Timestamp"`
}

func NewIPFSClient() *IPFSClient {
	return &IPFSClient{
		apiKey:    os.Getenv("PINATA_API_KEY"),
		apiSecret: os.Getenv("PINATA_API_SECRET"),
		httpClient: &http.Client{Timeout: 60 * time.Second},
	}
}

// UploadFile 上传文件到 IPFS
func (c *IPFSClient) UploadFile(filePath string) (*PinataResponse, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	// 构建 multipart form
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)
	part, err := writer.CreateFormFile("file", filepath.Base(filePath))
	if err != nil {
		return nil, err
	}
	io.Copy(part, file)
	writer.Close()

	// 发送请求
	req, _ := http.NewRequest("POST", "https://api.pinata.cloud/pinning/pinFileToIPFS", body)
	req.Header.Set("Content-Type", writer.FormDataContentType())
	req.Header.Set("pinata_api_key", c.apiKey)
	req.Header.Set("pinata_secret_api_key", c.apiSecret)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result PinataResponse
	json.NewDecoder(resp.Body).Decode(&result)
	return &result, nil
}

// UploadJSON 上传 JSON 元数据到 IPFS（NFT 元数据常用）
func (c *IPFSClient) UploadJSON(metadata interface{}) (*PinataResponse, error) {
	payload := map[string]interface{}{
		"pinataContent": metadata,
	}
	data, _ := json.Marshal(payload)

	req, _ := http.NewRequest("POST",
		"https://api.pinata.cloud/pinning/pinJSONToIPFS",
		bytes.NewReader(data))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("pinata_api_key", c.apiKey)
	req.Header.Set("pinata_secret_api_key", c.apiSecret)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result PinataResponse
	json.NewDecoder(resp.Body).Decode(&result)
	return &result, nil
}

// GetIPFSURL 获取 IPFS 网关 URL
func GetIPFSURL(cid string) string {
	return fmt.Sprintf("https://gateway.pinata.cloud/ipfs/%s", cid)
}
```

### NFT 元数据上传完整流程

```go
// internal/service/nft_metadata_service.go
package service

import (
	"fmt"
	"log"

	"github.com/yourname/dapp-backend/internal/storage"
)

type NFTMetadataService struct {
	ipfs *storage.IPFSClient
}

// NFTMetadata ERC-721 标准元数据格式
type NFTMetadata struct {
	Name        string          `json:"name"`
	Description string          `json:"description"`
	Image       string          `json:"image"`       // IPFS URI
	ExternalURL string          `json:"external_url"` 
	Attributes  []NFTAttribute  `json:"attributes"`
}

type NFTAttribute struct {
	TraitType string      `json:"trait_type"`
	Value     interface{} `json:"value"`
}

func NewNFTMetadataService(ipfs *storage.IPFSClient) *NFTMetadataService {
	return &NFTMetadataService{ipfs: ipfs}
}

// UploadNFT 完整的 NFT 上传流程：图片 → IPFS → 元数据 → IPFS
func (s *NFTMetadataService) UploadNFT(
	imagePath string,
	name, description string,
	attributes []NFTAttribute,
) (string, error) {
	// 第一步：上传图片到 IPFS
	log.Printf("📤 上传图片: %s", imagePath)
	imageResult, err := s.ipfs.UploadFile(imagePath)
	if err != nil {
		return "", fmt.Errorf("上传图片失败: %w", err)
	}
	imageURI := fmt.Sprintf("ipfs://%s", imageResult.IpfsHash)
	log.Printf("✅ 图片已上传: %s", imageURI)

	// 第二步：构建元数据
	metadata := NFTMetadata{
		Name:        name,
		Description: description,
		Image:       imageURI,
		ExternalURL: fmt.Sprintf("https://your-nft-site.com/nft/%s", imageResult.IpfsHash),
		Attributes:  attributes,
	}

	// 第三步：上传元数据到 IPFS
	log.Println("📤 上传元数据...")
	metaResult, err := s.ipfs.UploadJSON(metadata)
	if err != nil {
		return "", fmt.Errorf("上传元数据失败: %w", err)
	}

	tokenURI := fmt.Sprintf("ipfs://%s", metaResult.IpfsHash)
	log.Printf("✅ 元数据已上传: %s", tokenURI)
	log.Printf("🔗 网关访问: %s", storage.GetIPFSURL(metaResult.IpfsHash))

	// 这个 tokenURI 就是铸造 NFT 时传给合约的参数
	return tokenURI, nil
}

// 使用示例
func ExampleUploadNFT() {
	ipfs := storage.NewIPFSClient()
	svc := NewNFTMetadataService(ipfs)

	tokenURI, err := svc.UploadNFT(
		"./assets/cool-nft.png",
		"Cool NFT #1",
		"A very cool NFT from our collection",
		[]NFTAttribute{
			{TraitType: "Background", Value: "Blue"},
			{TraitType: "Eyes", Value: "Laser"},
			{TraitType: "Rarity", Value: 95},
			{TraitType: "Generation", Value: 1},
		},
	)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Token URI: %s\n", tokenURI)
	// 输出: Token URI: ipfs://QmXxx...
	// 这个 URI 传给 NFT 合约的 mint 函数
}
```

## 10.5 高可用与可观测性

生产环境的 DApp 后端不能"裸奔"。你需要知道：服务是否健康？请求延迟多少？哪里出了问题？

### Prometheus + Grafana 监控

```
监控架构：
┌──────────┐  /metrics  ┌──────────────┐  查询  ┌──────────┐
│ Go 服务   │ ─────────→ │  Prometheus  │ ←───── │ Grafana  │
│ (暴露指标) │            │  (采集存储)   │        │ (可视化)  │
└──────────┘            └──────────────┘        └──────────┘
```

```bash
# 安装 Prometheus 客户端
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp
```

```go
// internal/middleware/metrics.go
package middleware

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

var (
	// HTTP 请求总数
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "dapp_http_requests_total",
			Help: "HTTP 请求总数",
		},
		[]string{"method", "path", "status"},
	)

	// HTTP 请求延迟
	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "dapp_http_request_duration_seconds",
			Help:    "HTTP 请求延迟（秒）",
			Buckets: []float64{0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5},
		},
		[]string{"method", "path"},
	)

	// 区块链 RPC 调用延迟
	rpcCallDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "dapp_rpc_call_duration_seconds",
			Help:    "区块链 RPC 调用延迟（秒）",
			Buckets: []float64{0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10},
		},
		[]string{"method"},
	)

	// 索引器同步进度
	indexerBlockHeight = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "dapp_indexer_block_height",
			Help: "索引器当前同步到的区块高度",
		},
	)

	// 缓存命中率
	cacheHits = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "dapp_cache_hits_total",
			Help: "缓存命中次数",
		},
		[]string{"cache_name", "result"}, // result: hit / miss
	)
)

// PrometheusMiddleware Gin 中间件：记录请求指标
func PrometheusMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()

		c.Next()

		duration := time.Since(start).Seconds()
		status := strconv.Itoa(c.Writer.Status())

		httpRequestsTotal.WithLabelValues(c.Request.Method, c.FullPath(), status).Inc()
		httpRequestDuration.WithLabelValues(c.Request.Method, c.FullPath()).Observe(duration)
	}
}

// RecordRPCCall 记录 RPC 调用指标
func RecordRPCCall(method string, duration time.Duration) {
	rpcCallDuration.WithLabelValues(method).Observe(duration.Seconds())
}

// RecordCacheResult 记录缓存命中/未命中
func RecordCacheResult(cacheName string, hit bool) {
	result := "miss"
	if hit {
		result = "hit"
	}
	cacheHits.WithLabelValues(cacheName, result).Inc()
}

// UpdateIndexerHeight 更新索引器区块高度
func UpdateIndexerHeight(height uint64) {
	indexerBlockHeight.Set(float64(height))
}
```

### 健康检查与优雅关闭

```go
// internal/server/server.go
package server

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/yourname/dapp-backend/internal/middleware"
)

type Server struct {
	router *gin.Engine
	port   string
}

func NewServer(port string) *Server {
	r := gin.Default()

	// 全局中间件
	r.Use(middleware.CORS())
	r.Use(middleware.PrometheusMiddleware())

	// 健康检查端点
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "ok",
			"time":   time.Now().Unix(),
		})
	})

	// Prometheus 指标端点
	r.GET("/metrics", gin.WrapH(promhttp.Handler()))

	return &Server{router: r, port: port}
}

// Run 启动服务（支持优雅关闭）
func (s *Server) Run() {
	srv := &http.Server{
		Addr:    ":" + s.port,
		Handler: s.router,
	}

	// 在 goroutine 中启动服务
	go func() {
		log.Printf("🚀 服务启动: http://localhost:%s", s.port)
		log.Printf("📊 监控指标: http://localhost:%s/metrics", s.port)
		log.Printf("❤️ 健康检查: http://localhost:%s/health", s.port)
		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			log.Fatalf("服务异常: %v", err)
		}
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 收到关闭信号，开始优雅关闭...")

	// 给 30 秒时间处理剩余请求
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("强制关闭: %v", err)
	}

	log.Println("✅ 服务已安全关闭")
}
```

### Docker 部署配置

```dockerfile
# Dockerfile
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /dapp-backend ./cmd/server

# 运行阶段
FROM alpine:3.19
RUN apk --no-cache add ca-certificates tzdata
ENV TZ=Asia/Shanghai

COPY --from=builder /dapp-backend /dapp-backend

EXPOSE 8080
CMD ["/dapp-backend"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ETH_RPC_URL=wss://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=dapp
      - DB_PASSWORD=dapp123
      - DB_NAME=dapp_dev
      - REDIS_ADDR=redis:6379
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: dapp
      POSTGRES_PASSWORD: dapp123
      POSTGRES_DB: dapp_dev
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

volumes:
  pgdata:
```

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'dapp-backend'
    static_configs:
      - targets: ['api:8080']
```

## 10.6 本章小结与练习

### 你学到了什么

- PostgreSQL + GORM 做链上数据持久化，NUMERIC 类型存 256 位大数
- 完整的 DEX 数据库 Schema 设计（区块、交易、代币、Swap 事件、流动性池）
- Repository 模式：分页查询、K 线数据生成、交易量统计
- Redis 三级缓存防护：防穿透（空值缓存）、防击穿（singleflight）、防雪崩（随机 TTL）
- 分布式锁：Lua 脚本保证原子性，防止多实例重复处理
- IPFS 去中心化存储：Pinata API 上传文件和 JSON 元数据
- NFT 元数据完整上传流程：图片 → IPFS → 元数据 → IPFS → tokenURI
- Prometheus + Grafana 监控体系：HTTP 指标、RPC 延迟、缓存命中率、索引进度
- Docker Compose 一键部署：API + PostgreSQL + Redis + Prometheus + Grafana

### 动手练习

1. **完整数据库服务**：把第 9 章的索引器和本章的 Repository 连起来，实现：索引器监听 Transfer 事件 → 存入 PostgreSQL → API 查询转账历史

2. **K 线数据服务**：用 Uniswap V3 的 Swap 事件数据，生成 ETH/USDC 的 1 小时 K 线，提供 REST API 给前端

3. **NFT 铸造后端**：实现完整的 NFT 铸造流程：用户上传图片 → 后端存 IPFS → 返回 tokenURI → 前端调用合约 mint

4. **监控大盘**：用 Grafana 搭建一个 DApp 监控大盘，包含：QPS、延迟 P99、缓存命中率、索引器同步延迟

### 下一章预告

下一章进入 DeFi 协议开发——Uniswap V3/V4 的 AMM 数学原理和合约实现。这是 Web3 开发中最硬核也最有价值的技能，搞懂了你就能理解整个 DeFi 世界的运作逻辑。
