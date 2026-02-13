# 第 4 章：Go 语言核心精通

> Go 是 Web3 后端的首选语言——go-ethereum 本身就是用 Go 写的。这一章不是泛泛的 Go 教程，每个知识点都直接对接区块链开发场景。

## 4.1 Go 基础快速过关

### 变量与类型

```go
package main

import (
	"fmt"
	"math/big"
)

func main() {
	// 基本类型
	var name string = "Ethereum"
	chainID := 1          // 类型推断: int
	gasPrice := 30.5      // float64
	isMainnet := true     // bool

	// Web3 开发中最重要的类型：big.Int
	// 以太坊的数值都是 256 位整数，Go 的 int64 装不下
	balance := new(big.Int)
	balance.SetString("1000000000000000000", 10) // 1 ETH = 10^18 Wei

	// big.Int 运算
	gasUsed := big.NewInt(21000)
	gasPriceWei := big.NewInt(30000000000) // 30 Gwei
	txFee := new(big.Int).Mul(gasUsed, gasPriceWei)

	fmt.Printf("链: %s (ID: %d)\n", name, chainID)
	fmt.Printf("余额: %s Wei\n", balance.String())
	fmt.Printf("交易费: %s Wei\n", txFee.String())

	// 字节数组 — 处理哈希、地址、签名的基础
	hash := [32]byte{} // 固定长度 32 字节（256 位）
	address := [20]byte{} // 以太坊地址 20 字节（160 位）
	signature := make([]byte, 65) // 签名 65 字节（r:32 + s:32 + v:1）

	_ = hash
	_ = address
	_ = signature
	_ = gasPrice
	_ = isMainnet
}
```

::: tip big.Int 是你的好朋友
在 Web3 开发中，几乎所有数值都用 `big.Int`：余额、Gas、代币数量、价格等。永远不要用 `float64` 处理金融数据——浮点精度问题会让你丢钱。
:::

### 切片（Slice）— 处理交易列表

```go
package main

import "fmt"

// Transaction 简化的交易结构
type Transaction struct {
	Hash   string
	From   string
	To     string
	Value  string
}

func main() {
	// 创建交易列表
	txs := make([]Transaction, 0, 100) // 预分配容量，避免频繁扩容

	// 添加交易
	txs = append(txs, Transaction{
		Hash:  "0xabc...",
		From:  "0x71C7...",
		To:    "0x1f98...",
		Value: "1000000000000000000",
	})

	// 批量处理交易（模拟区块中的交易列表）
	block := generateMockTransactions(50)
	
	// 过滤：只保留转账金额 > 0 的交易
	var transfers []Transaction
	for _, tx := range block {
		if tx.Value != "0" {
			transfers = append(transfers, tx)
		}
	}
	fmt.Printf("区块中有 %d 笔转账交易\n", len(transfers))

	// 切片是引用类型！修改切片会影响底层数组
	slice1 := block[:10]
	slice2 := block[5:15]
	// slice1 和 slice2 共享底层数组的 [5:10] 部分
	// 在并发场景下要特别注意！
}

func generateMockTransactions(count int) []Transaction {
	txs := make([]Transaction, count)
	for i := range txs {
		txs[i] = Transaction{
			Hash:  fmt.Sprintf("0x%064d", i),
			From:  "0xSender",
			To:    "0xReceiver",
			Value: fmt.Sprintf("%d", i*1000000000000000000),
		}
	}
	return txs
}
```

### Map — 地址到余额的映射

```go
package main

import (
	"fmt"
	"math/big"
	"sync"
)

// BalanceTracker 余额追踪器
// 在区块链后端中，经常需要维护地址到余额的映射
type BalanceTracker struct {
	mu       sync.RWMutex
	balances map[string]*big.Int
}

func NewBalanceTracker() *BalanceTracker {
	return &BalanceTracker{
		balances: make(map[string]*big.Int),
	}
}

// GetBalance 查询余额（读锁）
func (bt *BalanceTracker) GetBalance(address string) *big.Int {
	bt.mu.RLock()
	defer bt.mu.RUnlock()

	if balance, ok := bt.balances[address]; ok {
		return new(big.Int).Set(balance) // 返回副本，防止外部修改
	}
	return big.NewInt(0)
}

// Transfer 转账（写锁）
func (bt *BalanceTracker) Transfer(from, to string, amount *big.Int) error {
	bt.mu.Lock()
	defer bt.mu.Unlock()

	// 检查余额
	fromBalance, ok := bt.balances[from]
	if !ok || fromBalance.Cmp(amount) < 0 {
		return fmt.Errorf("余额不足: %s 只有 %s", from, fromBalance)
	}

	// 扣减发送方
	bt.balances[from] = new(big.Int).Sub(fromBalance, amount)

	// 增加接收方
	if _, ok := bt.balances[to]; !ok {
		bt.balances[to] = big.NewInt(0)
	}
	bt.balances[to] = new(big.Int).Add(bt.balances[to], amount)

	return nil
}

func main() {
	tracker := NewBalanceTracker()

	// 初始化余额
	tracker.balances["Alice"] = big.NewInt(1000)
	tracker.balances["Bob"] = big.NewInt(500)

	// 转账
	err := tracker.Transfer("Alice", "Bob", big.NewInt(200))
	if err != nil {
		fmt.Println("转账失败:", err)
		return
	}

	fmt.Printf("Alice: %s\n", tracker.GetBalance("Alice")) // 800
	fmt.Printf("Bob: %s\n", tracker.GetBalance("Bob"))     // 700
}
```

### 结构体与接口 — 合约交互抽象

```go
package contracts

import (
	"context"
	"math/big"
)

// ERC20 接口 — 所有 ERC-20 代币都实现这个接口
type ERC20 interface {
	Name(ctx context.Context) (string, error)
	Symbol(ctx context.Context) (string, error)
	Decimals(ctx context.Context) (uint8, error)
	TotalSupply(ctx context.Context) (*big.Int, error)
	BalanceOf(ctx context.Context, account string) (*big.Int, error)
	Transfer(ctx context.Context, to string, amount *big.Int) (string, error) // 返回 tx hash
	Approve(ctx context.Context, spender string, amount *big.Int) (string, error)
	Allowance(ctx context.Context, owner, spender string) (*big.Int, error)
}

// DEX 接口 — 去中心化交易所的核心操作
type DEX interface {
	// 查询价格
	GetPrice(ctx context.Context, tokenIn, tokenOut string, amountIn *big.Int) (*big.Int, error)
	// 执行交易
	Swap(ctx context.Context, tokenIn, tokenOut string, amountIn, minAmountOut *big.Int) (string, error)
	// 添加流动性
	AddLiquidity(ctx context.Context, tokenA, tokenB string, amountA, amountB *big.Int) (string, error)
}

// ChainClient 链客户端接口 — 抽象不同链的交互
type ChainClient interface {
	ChainID() int64
	BlockNumber(ctx context.Context) (uint64, error)
	BalanceAt(ctx context.Context, address string) (*big.Int, error)
	SendTransaction(ctx context.Context, tx interface{}) (string, error)
}
```

::: tip 接口设计原则
Go 的接口是隐式实现的（不需要 `implements` 关键字）。在 Web3 开发中，善用接口可以：
1. 抽象不同链的交互（EVM 链 vs Solana）
2. 方便 Mock 测试（不需要真实连接链）
3. 支持多种合约标准（ERC-20 / ERC-721 / ERC-1155）
:::

### 错误处理 — Web3 场景

```go
package blockchain

import (
	"errors"
	"fmt"
)

// 自定义错误类型
var (
	ErrInsufficientBalance = errors.New("余额不足")
	ErrInvalidAddress      = errors.New("无效地址")
	ErrTransactionFailed   = errors.New("交易失败")
	ErrNonceTooLow         = errors.New("Nonce 过低")
	ErrGasTooLow           = errors.New("Gas 不足")
)

// TransactionError 带上下文的交易错误
type TransactionError struct {
	TxHash  string
	Code    int
	Message string
	Err     error
}

func (e *TransactionError) Error() string {
	return fmt.Sprintf("交易 %s 失败 (code=%d): %s", e.TxHash, e.Code, e.Message)
}

func (e *TransactionError) Unwrap() error {
	return e.Err
}

// 使用示例
func sendTransaction(to string, amount int64) error {
	// 模拟各种错误场景
	if to == "" {
		return fmt.Errorf("发送交易: %w", ErrInvalidAddress)
	}

	if amount > 1000 {
		return &TransactionError{
			TxHash:  "0xabc...",
			Code:    -32000,
			Message: "insufficient funds for gas * price + value",
			Err:     ErrInsufficientBalance,
		}
	}

	return nil
}

func main() {
	err := sendTransaction("", 100)
	if err != nil {
		// 用 errors.Is 检查错误链
		if errors.Is(err, ErrInvalidAddress) {
			fmt.Println("地址无效，请检查输入")
		}
	}

	err = sendTransaction("0x123", 2000)
	if err != nil {
		// 用 errors.As 提取具体错误类型
		var txErr *TransactionError
		if errors.As(err, &txErr) {
			fmt.Printf("交易哈希: %s\n", txErr.TxHash)
			fmt.Printf("错误码: %d\n", txErr.Code)
		}
	}
}
```

## 4.2 Go 并发编程 — 区块链场景实战

并发是 Go 的杀手锏，也是区块链后端开发的核心能力。

### Goroutine + Channel 基础

```go
package main

import (
	"fmt"
	"time"
)

// 模拟：同时监听多个链的新区块
func main() {
	// 为每条链启动一个 Goroutine
	chains := []string{"Ethereum", "BSC", "Polygon", "Arbitrum"}

	// 用 Channel 收集所有链的新区块通知
	blockCh := make(chan string, 100) // 带缓冲的 Channel

	for _, chain := range chains {
		go monitorBlocks(chain, blockCh) // 启动 Goroutine
	}

	// 主 Goroutine 统一处理所有链的区块
	for block := range blockCh {
		fmt.Println(block)
	}
}

func monitorBlocks(chain string, ch chan<- string) {
	blockNum := 0
	for {
		blockNum++
		ch <- fmt.Sprintf("[%s] 新区块 #%d", chain, blockNum)

		// 不同链的出块速度不同
		switch chain {
		case "Ethereum":
			time.Sleep(12 * time.Second)
		case "BSC":
			time.Sleep(3 * time.Second)
		case "Polygon":
			time.Sleep(2 * time.Second)
		case "Arbitrum":
			time.Sleep(250 * time.Millisecond)
		}
	}
}
```

### Select 多路复用 — 同时处理多种事件

```go
package main

import (
	"context"
	"fmt"
	"time"
)

// EventType 事件类型
type EventType string

const (
	EventSwap      EventType = "Swap"
	EventTransfer  EventType = "Transfer"
	EventApproval  EventType = "Approval"
)

// ChainEvent 链上事件
type ChainEvent struct {
	Type      EventType
	Contract  string
	BlockNum  uint64
	Data      map[string]interface{}
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// 三个独立的事件源
	swapCh := make(chan ChainEvent, 50)
	transferCh := make(chan ChainEvent, 50)
	errCh := make(chan error, 10)

	// 启动事件监听
	go listenSwapEvents(swapCh)
	go listenTransferEvents(transferCh)

	// Select 多路复用：同时处理多种事件
	for {
		select {
		case swap := <-swapCh:
			fmt.Printf("🔄 Swap 事件: 区块 #%d, 合约 %s\n", swap.BlockNum, swap.Contract)
			// 处理 Swap 事件：更新价格、K线数据等

		case transfer := <-transferCh:
			fmt.Printf("💸 Transfer 事件: 区块 #%d\n", transfer.BlockNum)
			// 处理 Transfer 事件：更新余额等

		case err := <-errCh:
			fmt.Printf("❌ 错误: %v\n", err)
			// 处理错误：重连、告警等

		case <-ctx.Done():
			fmt.Println("⏰ 超时退出")
			return
		}
	}
}
```

### Worker Pool — 高并发交易处理

```go
package worker

import (
	"context"
	"fmt"
	"sync"
)

// Task 任务
type Task struct {
	ID   int
	Data interface{}
}

// Result 结果
type Result struct {
	TaskID int
	Output interface{}
	Err    error
}

// Pool Worker 池
type Pool struct {
	workerCount int
	taskCh      chan Task
	resultCh    chan Result
	wg          sync.WaitGroup
}

// NewPool 创建 Worker 池
func NewPool(workerCount, taskBuffer int) *Pool {
	return &Pool{
		workerCount: workerCount,
		taskCh:      make(chan Task, taskBuffer),
		resultCh:    make(chan Result, taskBuffer),
	}
}

// Start 启动所有 Worker
func (p *Pool) Start(ctx context.Context, handler func(Task) Result) {
	for i := 0; i < p.workerCount; i++ {
		p.wg.Add(1)
		go func(workerID int) {
			defer p.wg.Done()
			for {
				select {
				case task, ok := <-p.taskCh:
					if !ok {
						return // Channel 关闭，退出
					}
					result := handler(task)
					p.resultCh <- result
				case <-ctx.Done():
					return
				}
			}
		}(i)
	}
}

// Submit 提交任务
func (p *Pool) Submit(task Task) {
	p.taskCh <- task
}

// Close 关闭池
func (p *Pool) Close() {
	close(p.taskCh)
	p.wg.Wait()
	close(p.resultCh)
}

// Results 获取结果 Channel
func (p *Pool) Results() <-chan Result {
	return p.resultCh
}
```

使用 Worker Pool 批量处理交易：

```go
func main() {
	ctx := context.Background()
	pool := worker.NewPool(10, 100) // 10 个 Worker，缓冲 100 个任务

	// 定义处理函数：解析交易
	handler := func(task worker.Task) worker.Result {
		txHash := task.Data.(string)
		// 模拟解析交易（实际中会调用链上 RPC）
		return worker.Result{
			TaskID: task.ID,
			Output: fmt.Sprintf("已解析交易 %s", txHash),
		}
	}

	pool.Start(ctx, handler)

	// 提交 1000 笔交易解析任务
	go func() {
		for i := 0; i < 1000; i++ {
			pool.Submit(worker.Task{
				ID:   i,
				Data: fmt.Sprintf("0x%064d", i),
			})
		}
		pool.Close()
	}()

	// 收集结果
	count := 0
	for result := range pool.Results() {
		count++
		if count%100 == 0 {
			fmt.Printf("已处理 %d 笔交易\n", count)
		}
		_ = result
	}
	fmt.Printf("✅ 共处理 %d 笔交易\n", count)
}
```

### Context — 超时控制与取消传播

```go
package main

import (
	"context"
	"fmt"
	"time"
)

// 模拟：查询链上数据，带超时控制
func queryBlockchainData(ctx context.Context, query string) (string, error) {
	// 创建子 Context，设置 5 秒超时
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	resultCh := make(chan string, 1)
	errCh := make(chan error, 1)

	go func() {
		// 模拟 RPC 调用
		time.Sleep(3 * time.Second) // 假设需要 3 秒
		resultCh <- fmt.Sprintf("查询结果: %s", query)
	}()

	select {
	case result := <-resultCh:
		return result, nil
	case err := <-errCh:
		return "", err
	case <-ctx.Done():
		return "", fmt.Errorf("查询超时: %w", ctx.Err())
	}
}

// 实际场景：批量查询多个地址的余额，任何一个超时就取消全部
func batchQueryBalances(addresses []string) {
	// 父 Context 设置总超时 10 秒
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	for _, addr := range addresses {
		result, err := queryBlockchainData(ctx, "balance:"+addr)
		if err != nil {
			fmt.Printf("❌ %s: %v\n", addr, err)
			return // 一个失败就取消后续查询
		}
		fmt.Printf("✅ %s\n", result)
	}
}
```

## 4.3 Go 工程化实践

### 项目结构（区块链后端）

```
web3-backend/
├── cmd/                          # 服务入口
│   ├── api/                      # API 服务
│   │   └── main.go
│   ├── indexer/                   # 链上事件索引服务
│   │   └── main.go
│   └── bot/                      # 清算/套利机器人
│       └── main.go
├── internal/                     # 内部包（不对外暴露）
│   ├── blockchain/               # 链交互层
│   │   ├── client.go             # 链客户端
│   │   ├── contract.go           # 合约交互
│   │   └── event.go              # 事件监听
│   ├── service/                  # 业务逻辑层
│   │   ├── swap.go               # Swap 业务
│   │   ├── liquidity.go          # 流动性业务
│   │   └── price.go              # 价格服务
│   ├── repository/               # 数据访问层
│   │   ├── postgres/             # PostgreSQL 实现
│   │   └── redis/                # Redis 实现
│   └── middleware/               # HTTP 中间件
│       ├── auth.go
│       ├── ratelimit.go
│       └── cors.go
├── pkg/                          # 公共包（可对外暴露）
│   ├── abi/                      # ABI 绑定代码
│   ├── math/                     # 数学工具（大数运算）
│   └── crypto/                   # 密码学工具
├── api/                          # API 定义
│   └── proto/                    # protobuf 文件
├── configs/                      # 配置文件
├── deployments/                  # 部署配置
│   ├── docker/
│   └── k8s/
├── go.mod
├── go.sum
└── Makefile
```

### 单元测试 — 表驱动测试

```go
package math

import (
	"math/big"
	"testing"
)

// WeiToEther 将 Wei 转换为 Ether
func WeiToEther(wei *big.Int) *big.Float {
	return new(big.Float).Quo(
		new(big.Float).SetInt(wei),
		new(big.Float).SetFloat64(1e18),
	)
}

// 表驱动测试
func TestWeiToEther(t *testing.T) {
	tests := []struct {
		name     string
		wei      string
		expected string
	}{
		{
			name:     "1 ETH",
			wei:      "1000000000000000000",
			expected: "1",
		},
		{
			name:     "0.5 ETH",
			wei:      "500000000000000000",
			expected: "0.5",
		},
		{
			name:     "0 ETH",
			wei:      "0",
			expected: "0",
		},
		{
			name:     "很小的金额",
			wei:      "1",
			expected: "1e-18",
		},
		{
			name:     "很大的金额",
			wei:      "1000000000000000000000000", // 1,000,000 ETH
			expected: "1e+06",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			wei := new(big.Int)
			wei.SetString(tt.wei, 10)

			result := WeiToEther(wei)
			// 比较浮点数需要一定的精度容忍
			expected := new(big.Float)
			expected.SetString(tt.expected)

			if result.Cmp(expected) != 0 {
				t.Errorf("WeiToEther(%s) = %s, 期望 %s", tt.wei, result.Text('g', 10), tt.expected)
			}
		})
	}
}
```

## 4.4 本章小结与练习

### 你学到了什么

- Go 基础类型在 Web3 场景中的应用（big.Int、字节数组）
- 接口设计：抽象合约交互和链客户端
- 并发编程：Goroutine、Channel、Select、Worker Pool
- Context 超时控制与取消传播
- 工程化项目结构和表驱动测试

### 动手练习

1. **并发余额查询器**：实现一个工具，输入 100 个以太坊地址，用 Worker Pool 并发查询所有地址的 ETH 余额，限制最大并发数为 10，总超时 30 秒

2. **链上事件聚合器**：实现一个程序，同时监听 3 个不同合约的 Transfer 事件，用 Select 聚合所有事件，按时间排序输出

3. **交易重试器**：实现一个带指数退避的交易发送器——如果交易发送失败（如 Nonce 冲突），自动重试，最多重试 5 次，每次等待时间翻倍

### 下一章预告

下一章我们用 go-ethereum 的 ethclient 深度交互以太坊——读取区块数据、发送交易、调用合约、监听事件。
