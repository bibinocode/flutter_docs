# 第 5 章：Go-Ethereum 链上交互实战

> 这一章是 Go 后端开发的核心——用 go-ethereum 库与以太坊深度交互。读区块、发交易、调合约、听事件，全部用真实代码跑通。

## 5.1 ethclient 连接管理

### 基础连接

```go
package blockchain

import (
	"context"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/ethereum/go-ethereum/ethclient"
)

// Client 封装 ethclient，添加重连和多节点支持
type Client struct {
	client   *ethclient.Client
	rpcURL   string
	mu       sync.RWMutex
}

// NewClient 创建客户端
func NewClient(rpcURL string) (*Client, error) {
	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		return nil, fmt.Errorf("连接节点失败: %w", err)
	}

	// 验证连接
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	chainID, err := client.ChainID(ctx)
	if err != nil {
		return nil, fmt.Errorf("获取 Chain ID 失败: %w", err)
	}
	log.Printf("✅ 已连接到链 ID: %d", chainID)

	return &Client{
		client: client,
		rpcURL: rpcURL,
	}, nil
}

// GetClient 获取底层 ethclient（带读锁）
func (c *Client) GetClient() *ethclient.Client {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.client
}

// Reconnect 重连
func (c *Client) Reconnect() error {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.client != nil {
		c.client.Close()
	}

	client, err := ethclient.Dial(c.rpcURL)
	if err != nil {
		return err
	}
	c.client = client
	log.Println("🔄 重连成功")
	return nil
}

// Close 关闭连接
func (c *Client) Close() {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.client != nil {
		c.client.Close()
	}
}
```

### 多节点负载均衡

```go
package blockchain

import (
	"context"
	"sync/atomic"

	"github.com/ethereum/go-ethereum/ethclient"
)

// MultiClient 多节点客户端，轮询负载均衡
type MultiClient struct {
	clients []*ethclient.Client
	index   uint64
}

// NewMultiClient 创建多节点客户端
func NewMultiClient(rpcURLs []string) (*MultiClient, error) {
	var clients []*ethclient.Client
	for _, url := range rpcURLs {
		client, err := ethclient.Dial(url)
		if err != nil {
			log.Printf("⚠️ 连接 %s 失败: %v", url, err)
			continue
		}
		clients = append(clients, client)
	}

	if len(clients) == 0 {
		return nil, fmt.Errorf("所有节点连接失败")
	}

	return &MultiClient{clients: clients}, nil
}

// Next 轮询获取下一个客户端
func (mc *MultiClient) Next() *ethclient.Client {
	idx := atomic.AddUint64(&mc.index, 1)
	return mc.clients[idx%uint64(len(mc.clients))]
}
```

## 5.2 区块数据读取

```go
package main

import (
	"context"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	client, _ := ethclient.Dial("https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY")
	ctx := context.Background()

	// 获取最新区块
	block, err := client.BlockByNumber(ctx, nil) // nil = 最新区块
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("区块号: %d\n", block.Number().Uint64())
	fmt.Printf("时间戳: %d\n", block.Time())
	fmt.Printf("交易数: %d\n", len(block.Transactions()))
	fmt.Printf("Gas Used: %d\n", block.GasUsed())
	fmt.Printf("Gas Limit: %d\n", block.GasLimit())
	fmt.Printf("Base Fee: %s Gwei\n", weiToGwei(block.BaseFee()))
	fmt.Printf("区块哈希: %s\n", block.Hash().Hex())
	fmt.Printf("父区块哈希: %s\n", block.ParentHash().Hex())

	// 遍历区块中的交易
	for i, tx := range block.Transactions() {
		if i >= 5 { // 只打印前 5 笔
			break
		}

		// 获取发送方地址（需要从签名恢复）
		chainID, _ := client.ChainID(ctx)
		signer := types.LatestSignerForChainID(chainID)
		from, _ := types.Sender(signer, tx)

		fmt.Printf("\n--- 交易 #%d ---\n", i)
		fmt.Printf("  哈希: %s\n", tx.Hash().Hex())
		fmt.Printf("  From: %s\n", from.Hex())
		if tx.To() != nil {
			fmt.Printf("  To: %s\n", tx.To().Hex())
		} else {
			fmt.Printf("  To: 合约创建\n")
		}
		fmt.Printf("  Value: %s ETH\n", weiToEther(tx.Value()))
		fmt.Printf("  Gas: %d\n", tx.Gas())

		// 判断交易类型
		if len(tx.Data()) > 0 {
			fmt.Printf("  类型: 合约调用\n")
			if len(tx.Data()) >= 4 {
				fmt.Printf("  函数选择器: 0x%x\n", tx.Data()[:4])
			}
		} else {
			fmt.Printf("  类型: ETH 转账\n")
		}
	}
}

func weiToEther(wei *big.Int) string {
	f := new(big.Float).Quo(new(big.Float).SetInt(wei), big.NewFloat(1e18))
	return f.Text('f', 6)
}

func weiToGwei(wei *big.Int) string {
	f := new(big.Float).Quo(new(big.Float).SetInt(wei), big.NewFloat(1e9))
	return f.Text('f', 2)
}
```

## 5.3 发送交易

### ETH 转账

```go
package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

func sendETH(client *ethclient.Client, privateKeyHex string, to string, amountETH float64) (string, error) {
	ctx := context.Background()

	// 1. 解析私钥
	privateKey, err := crypto.HexToECDSA(privateKeyHex)
	if err != nil {
		return "", fmt.Errorf("解析私钥失败: %w", err)
	}

	// 2. 获取发送方地址
	publicKey := privateKey.Public().(*ecdsa.PublicKey)
	fromAddress := crypto.PubkeyToAddress(*publicKey)

	// 3. 获取 Nonce
	nonce, err := client.PendingNonceAt(ctx, fromAddress)
	if err != nil {
		return "", fmt.Errorf("获取 Nonce 失败: %w", err)
	}

	// 4. 构造交易参数
	toAddress := common.HexToAddress(to)
	value := etherToWei(amountETH)
	gasLimit := uint64(21000) // ETH 转账固定 21000 Gas

	// 5. 获取 Gas 价格（EIP-1559）
	tipCap, err := client.SuggestGasTipCap(ctx) // maxPriorityFeePerGas
	if err != nil {
		return "", fmt.Errorf("获取 Gas Tip 失败: %w", err)
	}

	header, err := client.HeaderByNumber(ctx, nil)
	if err != nil {
		return "", fmt.Errorf("获取区块头失败: %w", err)
	}
	baseFee := header.BaseFee

	// maxFeePerGas = 2 * baseFee + tipCap（留足余量）
	feeCap := new(big.Int).Add(
		new(big.Int).Mul(baseFee, big.NewInt(2)),
		tipCap,
	)

	// 6. 构造 EIP-1559 交易
	chainID, _ := client.ChainID(ctx)
	tx := types.NewTx(&types.DynamicFeeTx{
		ChainID:   chainID,
		Nonce:     nonce,
		GasTipCap: tipCap,
		GasFeeCap: feeCap,
		Gas:       gasLimit,
		To:        &toAddress,
		Value:     value,
	})

	// 7. 签名
	signedTx, err := types.SignTx(tx, types.LatestSignerForChainID(chainID), privateKey)
	if err != nil {
		return "", fmt.Errorf("签名失败: %w", err)
	}

	// 8. 发送
	err = client.SendTransaction(ctx, signedTx)
	if err != nil {
		return "", fmt.Errorf("发送失败: %w", err)
	}

	return signedTx.Hash().Hex(), nil
}

func etherToWei(eth float64) *big.Int {
	// 用字符串避免浮点精度问题
	weiFloat := new(big.Float).Mul(
		big.NewFloat(eth),
		big.NewFloat(1e18),
	)
	wei, _ := weiFloat.Int(nil)
	return wei
}
```

### 等待交易确认

```go
package blockchain

import (
	"context"
	"fmt"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

// WaitForTransaction 等待交易确认
func WaitForTransaction(client *ethclient.Client, txHash common.Hash, timeout time.Duration) (*types.Receipt, error) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			receipt, err := client.TransactionReceipt(ctx, txHash)
			if err != nil {
				continue // 交易还未被打包，继续等待
			}

			if receipt.Status == types.ReceiptStatusSuccessful {
				fmt.Printf("✅ 交易成功! 区块: %d, Gas: %d\n",
					receipt.BlockNumber.Uint64(), receipt.GasUsed)
			} else {
				fmt.Printf("❌ 交易失败! 区块: %d\n", receipt.BlockNumber.Uint64())
			}
			return receipt, nil

		case <-ctx.Done():
			return nil, fmt.Errorf("等待超时: %w", ctx.Err())
		}
	}
}
```

## 5.4 智能合约交互

### 使用 abigen 生成 Go 绑定

```bash
# 1. 获取合约 ABI（以 USDT 为例）
# 方法一：从 Etherscan 下载
# 方法二：从 Solidity 编译获取
solc --abi contracts/ERC20.sol -o build/

# 2. 用 abigen 生成 Go 代码
abigen --abi=build/ERC20.abi --pkg=erc20 --out=pkg/abi/erc20/erc20.go

# 如果有字节码，还可以生成部署方法
abigen --abi=build/ERC20.abi --bin=build/ERC20.bin --pkg=erc20 --out=pkg/abi/erc20/erc20.go
```

### 读取 ERC-20 代币信息

```go
package main

import (
	"context"
	"fmt"
	"log"
	"math"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
)

// ERC-20 ABI（简化版，只包含常用方法）
const erc20ABI = `[
	{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},
	{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},
	{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
	{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},
	{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},
	{"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"}
]`

func main() {
	client, _ := ethclient.Dial("https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY")
	ctx := context.Background()

	// USDT 合约地址
	usdtAddress := common.HexToAddress("0xdAC17F958D2ee523a2206206994597C13D831ec7")

	// 解析 ABI
	parsedABI, _ := abi.JSON(strings.NewReader(erc20ABI))

	// 查询代币名称
	nameData, _ := parsedABI.Pack("name")
	nameResult, _ := client.CallContract(ctx, ethereum.CallMsg{
		To:   &usdtAddress,
		Data: nameData,
	}, nil)
	var name string
	parsedABI.UnpackIntoInterface(&name, "name", nameResult)
	fmt.Printf("代币名称: %s\n", name)

	// 查询代币符号
	symbolData, _ := parsedABI.Pack("symbol")
	symbolResult, _ := client.CallContract(ctx, ethereum.CallMsg{
		To:   &usdtAddress,
		Data: symbolData,
	}, nil)
	var symbol string
	parsedABI.UnpackIntoInterface(&symbol, "symbol", symbolResult)
	fmt.Printf("代币符号: %s\n", symbol)

	// 查询精度
	decimalsData, _ := parsedABI.Pack("decimals")
	decimalsResult, _ := client.CallContract(ctx, ethereum.CallMsg{
		To:   &usdtAddress,
		Data: decimalsData,
	}, nil)
	var decimals uint8
	parsedABI.UnpackIntoInterface(&decimals, "decimals", decimalsResult)
	fmt.Printf("精度: %d\n", decimals)

	// 查询某个地址的 USDT 余额
	wallet := common.HexToAddress("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045") // Vitalik
	balanceData, _ := parsedABI.Pack("balanceOf", wallet)
	balanceResult, _ := client.CallContract(ctx, ethereum.CallMsg{
		To:   &usdtAddress,
		Data: balanceData,
	}, nil)
	var balance *big.Int
	parsedABI.UnpackIntoInterface(&balance, "balanceOf", balanceResult)

	// 转换为可读格式
	humanBalance := new(big.Float).Quo(
		new(big.Float).SetInt(balance),
		new(big.Float).SetFloat64(math.Pow10(int(decimals))),
	)
	fmt.Printf("Vitalik 的 USDT 余额: %s\n", humanBalance.Text('f', 2))
}
```

## 5.5 事件监听

### 监听 ERC-20 Transfer 事件

```go
package main

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

// Transfer 事件的 ABI
const transferEventABI = `[{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]`

func main() {
	// 使用 WebSocket 连接（事件订阅需要 WS）
	client, err := ethclient.Dial("wss://eth-mainnet.g.alchemy.com/v2/YOUR_KEY")
	if err != nil {
		log.Fatal(err)
	}

	// USDT 合约
	usdtAddress := common.HexToAddress("0xdAC17F958D2ee523a2206206994597C13D831ec7")

	// Transfer 事件的 Topic（Keccak256("Transfer(address,address,uint256)")）
	transferTopic := common.HexToHash("0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef")

	// 构造过滤器
	query := ethereum.FilterQuery{
		Addresses: []common.Address{usdtAddress},
		Topics:    [][]common.Hash{{transferTopic}},
	}

	// 订阅事件
	logsCh := make(chan types.Log)
	sub, err := client.SubscribeFilterLogs(context.Background(), query, logsCh)
	if err != nil {
		log.Fatal(err)
	}

	parsedABI, _ := abi.JSON(strings.NewReader(transferEventABI))

	fmt.Println("🔍 开始监听 USDT Transfer 事件...")

	for {
		select {
		case err := <-sub.Err():
			log.Fatal(err)

		case vLog := <-logsCh:
			// 解析事件数据
			from := common.HexToAddress(vLog.Topics[1].Hex())
			to := common.HexToAddress(vLog.Topics[2].Hex())

			// 解析非 indexed 参数（value）
			var transferEvent struct {
				Value *big.Int
			}
			parsedABI.UnpackIntoInterface(&transferEvent, "Transfer", vLog.Data)

			// USDT 精度是 6
			amount := new(big.Float).Quo(
				new(big.Float).SetInt(transferEvent.Value),
				big.NewFloat(1e6),
			)

			fmt.Printf("💸 USDT Transfer: %s → %s, 金额: %s USDT (区块: %d)\n",
				shortenAddress(from.Hex()),
				shortenAddress(to.Hex()),
				amount.Text('f', 2),
				vLog.BlockNumber,
			)
		}
	}
}

func shortenAddress(addr string) string {
	if len(addr) < 10 {
		return addr
	}
	return addr[:6] + "..." + addr[len(addr)-4:]
}
```

### 扫描历史事件

```go
// ScanHistoricalEvents 扫描历史事件（用于数据回填）
func ScanHistoricalEvents(client *ethclient.Client, contractAddr common.Address,
	fromBlock, toBlock uint64) ([]types.Log, error) {

	// 每次最多查询 2000 个区块（RPC 限制）
	const batchSize = 2000
	var allLogs []types.Log

	for start := fromBlock; start <= toBlock; start += batchSize {
		end := start + batchSize - 1
		if end > toBlock {
			end = toBlock
		}

		query := ethereum.FilterQuery{
			FromBlock: new(big.Int).SetUint64(start),
			ToBlock:   new(big.Int).SetUint64(end),
			Addresses: []common.Address{contractAddr},
		}

		logs, err := client.FilterLogs(context.Background(), query)
		if err != nil {
			return nil, fmt.Errorf("查询区块 %d-%d 失败: %w", start, end, err)
		}

		allLogs = append(allLogs, logs...)
		fmt.Printf("已扫描区块 %d-%d, 找到 %d 条事件\n", start, end, len(logs))
	}

	return allLogs, nil
}
```

## 5.6 本章小结与练习

### 你学到了什么

- ethclient 连接管理：单节点、多节点负载均衡、重连机制
- 区块数据读取：区块头、交易列表、交易回执
- 交易发送：EIP-1559 交易构造、签名、发送、等待确认
- 合约交互：ABI 编解码、只读调用、写入调用
- 事件监听：实时订阅和历史扫描

### 动手练习

1. **批量转账工具**：实现一个 Go 程序，从 CSV 文件读取转账列表（地址, 金额），批量发送 ETH 或 ERC-20 转账，支持 Nonce 管理和失败重试

2. **大额转账监控**：监听 USDT/USDC 的 Transfer 事件，当单笔转账超过 100 万美元时，打印告警信息

3. **Gas 追踪器**：实时监控以太坊的 Base Fee 变化，计算过去 100 个区块的平均 Gas Price，并预测下一个区块的 Base Fee

### 下一章预告

下一章进入 Solidity 智能合约开发——从 ERC-20 代币到可升级合约，用 Foundry 全流程实战。
