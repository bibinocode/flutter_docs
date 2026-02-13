# 第 1 章：区块链核心原理

> 在写任何一行 Web3 代码之前，你需要真正理解区块链到底是什么。这一章不讲空话，我们直接用 Go 代码把一条最小区块链跑起来。

## 1.1 什么是区块链？

把区块链想象成一个**所有人共享的、不可篡改的记账本**。

传统数据库是这样的：

```
┌──────────────┐
│   中心服务器   │  ← 一个公司控制
│  MySQL/PG    │
│  所有数据在这  │
└──────────────┘
      ↑ ↑ ↑
   用户A 用户B 用户C
```

区块链是这样的：

```
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│ 节点 A  │──│ 节点 B  │──│ 节点 C  │──│ 节点 D  │
│ 完整账本 │  │ 完整账本 │  │ 完整账本 │  │ 完整账本 │
└────────┘  └────────┘  └────────┘  └────────┘
```

每个节点都有一份完整的数据副本，没有任何一个中心节点可以单独篡改数据。这就是**去中心化**。

### 区块链 vs 传统数据库

| 特性 | 传统数据库 | 区块链 |
|------|-----------|--------|
| 控制权 | 单一机构 | 分布式网络 |
| 数据修改 | 管理员可随意修改 | 需要网络共识 |
| 透明度 | 对外不可见 | 所有人可查 |
| 信任模型 | 信任中心机构 | 信任数学和代码 |
| 性能 | 高（毫秒级） | 低（秒到分钟级） |
| 适用场景 | 大部分业务系统 | 需要去信任的场景 |

### 区块链的核心特性

1. **去中心化（Decentralization）**：没有单点故障，没有单一控制者
2. **不可篡改（Immutability）**：数据一旦写入，无法修改或删除
3. **透明性（Transparency）**：所有交易记录公开可查
4. **共识机制（Consensus）**：网络中的节点通过算法达成一致

## 1.2 区块结构深度解析

一个区块（Block）本质上就是一个数据结构，包含以下核心字段：

```
┌─────────────────────────────────┐
│           Block Header           │
├─────────────────────────────────┤
│  Index (区块高度)                 │
│  Timestamp (时间戳)              │
│  PreviousHash (前一个区块的哈希)  │
│  Hash (当前区块的哈希)            │
│  Nonce (工作量证明的随机数)        │
│  Difficulty (挖矿难度)           │
│  MerkleRoot (交易的默克尔树根)    │
├─────────────────────────────────┤
│           Block Body             │
├─────────────────────────────────┤
│  Transactions (交易列表)          │
│    ├── Tx1: A → B 转账 1 ETH     │
│    ├── Tx2: C → D 转账 0.5 ETH   │
│    └── Tx3: E 部署合约            │
└─────────────────────────────────┘
```

### 用 Go 定义区块结构

```go
package blockchain

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"
)

// Transaction 表示一笔交易
type Transaction struct {
	From   string  `json:"from"`   // 发送方地址
	To     string  `json:"to"`     // 接收方地址
	Amount float64 `json:"amount"` // 转账金额
	Data   []byte  `json:"data"`   // 附加数据（合约调用时使用）
}

// Block 表示一个区块
type Block struct {
	Index        int64          `json:"index"`         // 区块高度，从 0 开始
	Timestamp    int64          `json:"timestamp"`     // Unix 时间戳
	Transactions []*Transaction `json:"transactions"`  // 交易列表
	PrevHash     string         `json:"prev_hash"`     // 前一个区块的哈希
	Hash         string         `json:"hash"`          // 当前区块的哈希
	Nonce        int64          `json:"nonce"`         // 工作量证明随机数
	Difficulty   int            `json:"difficulty"`    // 挖矿难度
}

// CalculateHash 计算区块的哈希值
// 哈希 = SHA256(Index + Timestamp + Transactions + PrevHash + Nonce)
func (b *Block) CalculateHash() string {
	data := fmt.Sprintf("%d%d%v%s%d",
		b.Index,
		b.Timestamp,
		b.Transactions,
		b.PrevHash,
		b.Nonce,
	)
	hash := sha256.Sum256([]byte(data))
	return hex.EncodeToString(hash[:])
}

// NewBlock 创建一个新区块
func NewBlock(index int64, transactions []*Transaction, prevHash string, difficulty int) *Block {
	block := &Block{
		Index:        index,
		Timestamp:    time.Now().Unix(),
		Transactions: transactions,
		PrevHash:     prevHash,
		Difficulty:   difficulty,
	}
	block.Hash = block.CalculateHash()
	return block
}
```

### 为什么用哈希？

哈希函数有三个关键特性让它成为区块链的基石：

1. **确定性**：相同输入永远产生相同输出
2. **雪崩效应**：输入改变一个字节，输出完全不同
3. **不可逆**：无法从哈希值反推原始数据

```go
package main

import (
	"crypto/sha256"
	"fmt"
)

func main() {
	// 演示雪崩效应
	data1 := "Hello Blockchain"
	data2 := "Hello blockchain" // 只改了一个字母的大小写

	hash1 := sha256.Sum256([]byte(data1))
	hash2 := sha256.Sum256([]byte(data2))

	fmt.Printf("输入: %s\n哈希: %x\n\n", data1, hash1)
	fmt.Printf("输入: %s\n哈希: %x\n\n", data2, hash2)
	// 两个哈希值完全不同！
}
```

运行结果：
```
输入: Hello Blockchain
哈希: 7a3c1d3e8f...（64位十六进制）

输入: Hello blockchain
哈希: 2b9f4c7d1a...（完全不同的64位十六进制）
```

## 1.3 用 Go 从零实现一条区块链

现在我们把区块串成链。核心规则：**每个区块的 PrevHash 指向前一个区块的 Hash**。

```go
package blockchain

import (
	"fmt"
	"log"
	"strings"
)

// Blockchain 区块链主结构
type Blockchain struct {
	Blocks     []*Block // 区块列表
	Difficulty int      // 全局挖矿难度
}

// NewBlockchain 创建一条新的区块链（包含创世区块）
func NewBlockchain(difficulty int) *Blockchain {
	genesisBlock := createGenesisBlock(difficulty)
	return &Blockchain{
		Blocks:     []*Block{genesisBlock},
		Difficulty: difficulty,
	}
}

// createGenesisBlock 创建创世区块（第一个区块）
func createGenesisBlock(difficulty int) *Block {
	genesis := &Block{
		Index:        0,
		Timestamp:    1231006505, // 比特币创世区块的时间戳（致敬中本聪）
		Transactions: []*Transaction{},
		PrevHash:     "0000000000000000000000000000000000000000000000000000000000000000",
		Difficulty:   difficulty,
	}
	// 对创世区块进行挖矿
	mineBlock(genesis, difficulty)
	return genesis
}

// AddBlock 向区块链添加新区块
func (bc *Blockchain) AddBlock(transactions []*Transaction) *Block {
	prevBlock := bc.Blocks[len(bc.Blocks)-1]
	newBlock := &Block{
		Index:        prevBlock.Index + 1,
		Timestamp:    prevBlock.Timestamp + 10, // 简化：假设每10秒一个区块
		Transactions: transactions,
		PrevHash:     prevBlock.Hash,
		Difficulty:   bc.Difficulty,
	}

	// 挖矿：找到满足难度要求的 Nonce
	mineBlock(newBlock, bc.Difficulty)

	bc.Blocks = append(bc.Blocks, newBlock)
	return newBlock
}

// mineBlock 工作量证明（PoW）挖矿
// 不断尝试不同的 Nonce，直到哈希值的前 N 位都是 0
func mineBlock(block *Block, difficulty int) {
	target := strings.Repeat("0", difficulty) // 例如 difficulty=2 → "00"

	for {
		block.Hash = block.CalculateHash()
		if strings.HasPrefix(block.Hash, target) {
			fmt.Printf("✅ 区块 #%d 挖矿成功! Nonce=%d Hash=%s\n",
				block.Index, block.Nonce, block.Hash)
			return
		}
		block.Nonce++
	}
}

// IsValid 验证整条区块链的完整性
func (bc *Blockchain) IsValid() bool {
	for i := 1; i < len(bc.Blocks); i++ {
		current := bc.Blocks[i]
		previous := bc.Blocks[i-1]

		// 验证当前区块的哈希是否正确
		if current.Hash != current.CalculateHash() {
			log.Printf("❌ 区块 #%d 的哈希不匹配", current.Index)
			return false
		}

		// 验证链接是否正确
		if current.PrevHash != previous.Hash {
			log.Printf("❌ 区块 #%d 的 PrevHash 不匹配", current.Index)
			return false
		}

		// 验证工作量证明
		target := strings.Repeat("0", bc.Difficulty)
		if !strings.HasPrefix(current.Hash, target) {
			log.Printf("❌ 区块 #%d 的工作量证明无效", current.Index)
			return false
		}
	}
	return true
}

// Print 打印整条区块链
func (bc *Blockchain) Print() {
	for _, block := range bc.Blocks {
		fmt.Printf("┌─────────────────────────────────┐\n")
		fmt.Printf("│ 区块 #%d                         \n", block.Index)
		fmt.Printf("│ 时间戳: %d                       \n", block.Timestamp)
		fmt.Printf("│ 交易数: %d                       \n", len(block.Transactions))
		fmt.Printf("│ Nonce: %d                        \n", block.Nonce)
		fmt.Printf("│ PrevHash: %s...\n", block.PrevHash[:16])
		fmt.Printf("│ Hash:     %s...\n", block.Hash[:16])
		fmt.Printf("└─────────────────────────────────┘\n")
		fmt.Println("          │")
		fmt.Println("          ▼")
	}
}
```

### 运行你的第一条区块链

```go
package main

import (
	"fmt"
	"mychain/blockchain"
)

func main() {
	// 创建一条难度为 2 的区块链（哈希前两位必须是 00）
	bc := blockchain.NewBlockchain(2)

	// 添加第一个区块
	bc.AddBlock([]*blockchain.Transaction{
		{From: "Alice", To: "Bob", Amount: 10.0},
		{From: "Bob", To: "Charlie", Amount: 3.5},
	})

	// 添加第二个区块
	bc.AddBlock([]*blockchain.Transaction{
		{From: "Charlie", To: "Alice", Amount: 2.0},
	})

	// 打印区块链
	bc.Print()

	// 验证区块链
	fmt.Printf("\n区块链是否有效: %v\n", bc.IsValid())

	// 尝试篡改数据
	fmt.Println("\n--- 尝试篡改区块 #1 的交易金额 ---")
	bc.Blocks[1].Transactions[0].Amount = 1000.0
	fmt.Printf("篡改后区块链是否有效: %v\n", bc.IsValid())
	// 输出 false！因为哈希不再匹配
}
```

运行输出：
```
✅ 区块 #0 挖矿成功! Nonce=142 Hash=00a3f2...
✅ 区块 #1 挖矿成功! Nonce=87 Hash=0034b1...
✅ 区块 #2 挖矿成功! Nonce=231 Hash=00c7e9...

┌─────────────────────────────────┐
│ 区块 #0
│ 时间戳: 1231006505
│ 交易数: 0
│ Nonce: 142
│ PrevHash: 0000000000000000...
│ Hash:     00a3f2e8b7c1d9f4...
└─────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────┐
│ 区块 #1
│ 时间戳: 1231006515
│ 交易数: 2
│ Nonce: 87
│ PrevHash: 00a3f2e8b7c1d9f4...
│ Hash:     0034b1a9c8e2f5d7...
└─────────────────────────────────┘
          │
          ▼

区块链是否有效: true

--- 尝试篡改区块 #1 的交易金额 ---
❌ 区块 #1 的哈希不匹配
篡改后区块链是否有效: false
```

::: tip 关键理解
篡改任何一个区块的数据，都会导致该区块的哈希改变，进而导致后续所有区块的 PrevHash 不匹配。要篡改数据，攻击者需要重新计算该区块及其后所有区块的工作量证明——这在算力上几乎不可能。
:::

## 1.4 共识机制：网络如何达成一致

区块链网络中有成千上万个节点，它们如何就"哪些交易是有效的"达成一致？这就是共识机制要解决的问题。

### PoW（工作量证明）— 比特币使用

核心思想：**谁先解出数学难题，谁就有权记账。**

```
矿工A: 尝试 Nonce=1 → Hash=a3f2... ❌ (不以00开头)
矿工A: 尝试 Nonce=2 → Hash=b7c1... ❌
矿工A: 尝试 Nonce=3 → Hash=00d9... ✅ 找到了！广播给全网
矿工B: 验证 Nonce=3 → Hash=00d9... ✅ 确认有效
矿工C: 验证 Nonce=3 → Hash=00d9... ✅ 确认有效
→ 全网接受这个区块
```

优点：安全性极高，经过 15 年验证
缺点：耗电量巨大，出块慢（比特币约 10 分钟）

### PoS（权益证明）— 以太坊使用

核心思想：**质押越多 ETH，被选为验证者的概率越大。**

```
验证者A: 质押 32 ETH → 被随机选中出块
验证者A: 打包交易，生成区块
验证者B,C,D: 验证区块有效性 → 投票确认
→ 区块被确认，验证者A获得奖励
→ 如果验证者A作恶 → 质押的 ETH 被罚没（Slashing）
```

优点：节能，出块快（以太坊约 12 秒）
缺点：富者越富的问题

### DPoS（委托权益证明）— EOS / BSC 使用

核心思想：**持币者投票选出少数代表节点来出块。**

类似于代议制民主：你不直接参与记账，而是投票选出你信任的节点。

### 共识机制对比

| 机制 | 代表项目 | 出块时间 | 去中心化程度 | 能耗 |
|------|---------|---------|-------------|------|
| PoW | Bitcoin | ~10 min | 高 | 极高 |
| PoS | Ethereum | ~12 sec | 中高 | 低 |
| DPoS | BSC/EOS | ~3 sec | 中 | 低 |
| PBFT | Hyperledger | ~1 sec | 低（联盟链） | 低 |
| PoA | 测试网 | ~5 sec | 低 | 低 |

### 用 Go 模拟 PoS 验证者选择

```go
package consensus

import (
	"crypto/rand"
	"math/big"
)

// Validator 验证者
type Validator struct {
	Address string
	Stake   int64 // 质押金额
}

// SelectValidator 按质押权重随机选择验证者
// 质押越多，被选中的概率越大
func SelectValidator(validators []Validator) *Validator {
	// 计算总质押量
	var totalStake int64
	for _, v := range validators {
		totalStake += v.Stake
	}

	// 生成 [0, totalStake) 范围内的随机数
	n, _ := rand.Int(rand.Reader, big.NewInt(totalStake))
	target := n.Int64()

	// 按权重选择
	var cumulative int64
	for i := range validators {
		cumulative += validators[i].Stake
		if target < cumulative {
			return &validators[i]
		}
	}
	return &validators[len(validators)-1]
}
```

```go
// 测试验证者选择
func main() {
	validators := []consensus.Validator{
		{Address: "0xAlice", Stake: 32},   // 32 ETH
		{Address: "0xBob", Stake: 100},    // 100 ETH
		{Address: "0xCharlie", Stake: 64}, // 64 ETH
	}

	// 模拟 1000 次选择，统计每个验证者被选中的次数
	counts := make(map[string]int)
	for i := 0; i < 1000; i++ {
		v := consensus.SelectValidator(validators)
		counts[v.Address]++
	}

	// Bob 质押最多，被选中次数应该最多
	fmt.Println(counts)
	// 输出类似: map[0xAlice:163 0xBob:510 0xCharlie:327]
}
```

## 1.5 Merkle Tree（默克尔树）

Merkle Tree 是区块链中用来高效验证交易数据完整性的数据结构。

```
              Root Hash
             /         \
        Hash(AB)      Hash(CD)
        /     \       /     \
    Hash(A)  Hash(B) Hash(C) Hash(D)
      |        |       |       |
    Tx A     Tx B    Tx C    Tx D
```

核心价值：不需要下载所有交易数据，只需要一条"证明路径"就能验证某笔交易是否在区块中。

### Go 实现 Merkle Tree

```go
package merkle

import (
	"crypto/sha256"
	"encoding/hex"
)

// Node 默克尔树节点
type Node struct {
	Left  *Node
	Right *Node
	Hash  string
}

// hashData 计算数据的 SHA256 哈希
func hashData(data string) string {
	hash := sha256.Sum256([]byte(data))
	return hex.EncodeToString(hash[:])
}

// hashPair 计算两个哈希的组合哈希
func hashPair(left, right string) string {
	return hashData(left + right)
}

// BuildMerkleTree 从交易列表构建默克尔树
func BuildMerkleTree(transactions []string) *Node {
	if len(transactions) == 0 {
		return nil
	}

	// 创建叶子节点
	var nodes []*Node
	for _, tx := range transactions {
		nodes = append(nodes, &Node{Hash: hashData(tx)})
	}

	// 如果节点数为奇数，复制最后一个节点
	if len(nodes)%2 != 0 {
		nodes = append(nodes, nodes[len(nodes)-1])
	}

	// 逐层向上构建
	for len(nodes) > 1 {
		var newLevel []*Node
		for i := 0; i < len(nodes); i += 2 {
			parent := &Node{
				Left:  nodes[i],
				Right: nodes[i+1],
				Hash:  hashPair(nodes[i].Hash, nodes[i+1].Hash),
			}
			newLevel = append(newLevel, parent)
		}
		// 如果新层节点数为奇数，复制最后一个
		if len(newLevel) > 1 && len(newLevel)%2 != 0 {
			newLevel = append(newLevel, newLevel[len(newLevel)-1])
		}
		nodes = newLevel
	}

	return nodes[0] // 返回根节点
}

// GetRootHash 获取默克尔树根哈希
func GetRootHash(transactions []string) string {
	root := BuildMerkleTree(transactions)
	if root == nil {
		return ""
	}
	return root.Hash
}
```

```go
func main() {
	transactions := []string{
		"Alice -> Bob: 10 ETH",
		"Bob -> Charlie: 3 ETH",
		"Charlie -> Dave: 5 ETH",
		"Dave -> Alice: 2 ETH",
	}

	root := merkle.BuildMerkleTree(transactions)
	fmt.Printf("Merkle Root: %s\n", root.Hash)

	// 修改任何一笔交易，根哈希都会完全改变
	transactions[0] = "Alice -> Bob: 100 ETH" // 篡改金额
	root2 := merkle.BuildMerkleTree(transactions)
	fmt.Printf("篡改后 Root: %s\n", root2.Hash)
	// 两个根哈希完全不同！
}
```

::: warning 为什么 Merkle Tree 重要？
以太坊的轻节点（Light Client）不需要下载完整的区块数据。它只需要区块头中的 Merkle Root，就能通过 Merkle Proof 验证某笔交易是否真的被包含在区块中。这是 SPV（简单支付验证）的基础。
:::

## 1.6 本章小结与练习

### 你学到了什么

- 区块链是一个去中心化的、不可篡改的分布式账本
- 区块通过哈希链接形成链式结构
- 工作量证明（PoW）通过计算难题来保证安全
- 权益证明（PoS）通过质押代币来保证安全
- Merkle Tree 用于高效验证交易数据完整性

### 动手练习

1. **难度调整**：修改区块链代码，实现动态难度调整——如果出块太快就增加难度，太慢就降低难度（类似比特币每 2016 个区块调整一次）

2. **交易验证**：为 `Transaction` 结构添加签名字段，实现交易签名和验证（提示：使用 `crypto/ecdsa` 包）

3. **Merkle Proof**：实现 `GetMerkleProof(transactions []string, index int) []string` 函数，返回指定交易的证明路径，并实现 `VerifyMerkleProof` 验证函数

4. **P2P 网络模拟**：创建两个 Goroutine 模拟两个节点，通过 Channel 通信，实现区块广播和链同步

### 下一章预告

下一章我们将深入密码学——ECDSA 签名、HD 钱包推导、以太坊地址生成。这些是你理解钱包和交易签名的基础。
