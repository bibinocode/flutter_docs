# 第 3 章：以太坊架构与多链生态

> 理解以太坊的内部运作机制，是写出安全高效的 DApp 的前提。这一章我们拆解 EVM、账户模型、交易生命周期，并搭建完整的开发环境。

## 3.1 以太坊虚拟机（EVM）

EVM 是以太坊的核心执行引擎。所有智能合约最终都编译成 EVM 字节码在这台"世界计算机"上运行。

### EVM 是一台栈机器

```
┌─────────────────────────────────────┐
│              EVM 执行环境             │
├─────────────────────────────────────┤
│  Stack (栈)     ← 最多 1024 层       │
│  ┌───┐                              │
│  │ 3 │ ← 栈顶                       │
│  │ 5 │                              │
│  │ 2 │                              │
│  └───┘                              │
│                                     │
│  Memory (内存)  ← 临时存储，调用结束清空 │
│  [0x00]: 0xff...                    │
│  [0x20]: 0x00...                    │
│                                     │
│  Storage (存储) ← 永久存储，写入成本高  │
│  slot[0]: 0x123...                  │
│  slot[1]: 0x456...                  │
│                                     │
│  Program Counter ← 当前执行位置       │
│  Gas Counter     ← 剩余 Gas          │
└─────────────────────────────────────┘
```

### 常见 Opcode 与 Gas 消耗

| Opcode | 功能 | Gas 消耗 | 说明 |
|--------|------|---------|------|
| ADD | 加法 | 3 | 栈顶两个数相加 |
| MUL | 乘法 | 5 | 栈顶两个数相乘 |
| SLOAD | 读 Storage | 2100 | 从永久存储读取（冷访问） |
| SSTORE | 写 Storage | 20000 | 写入永久存储（从0到非0） |
| MLOAD | 读 Memory | 3 | 从内存读取 |
| MSTORE | 写 Memory | 3 | 写入内存 |
| CALL | 调用合约 | 2600+ | 调用外部合约 |
| CREATE | 创建合约 | 32000 | 部署新合约 |

::: tip Gas 优化的关键
Storage 操作（SLOAD/SSTORE）是最贵的。一次 SSTORE 的 Gas 消耗是 ADD 的 6666 倍。这就是为什么合约优化的核心是减少 Storage 读写。
:::

## 3.2 以太坊账户模型

以太坊有两种账户：

### EOA（外部拥有账户）— 你的钱包

```
┌──────────────────────┐
│  EOA Account          │
├──────────────────────┤
│  Address: 0x71C7...  │
│  Balance: 1.5 ETH    │
│  Nonce: 42           │  ← 已发送的交易数量
│  (没有代码)           │
└──────────────────────┘
```

- 由私钥控制
- 可以发起交易
- 没有代码

### Contract Account（合约账户）— 智能合约

```
┌──────────────────────┐
│  Contract Account     │
├──────────────────────┤
│  Address: 0x1f9840.. │
│  Balance: 1000 ETH   │
│  Nonce: 1            │  ← 创建的合约数量
│  Code: 0x6080604...  │  ← EVM 字节码
│  Storage:            │  ← 合约状态数据
│    slot[0]: owner    │
│    slot[1]: totalSupply │
└──────────────────────┘
```

- 由代码控制（没有私钥）
- 不能主动发起交易，只能被调用
- 有代码和存储

### State Trie（状态树）

以太坊用 Modified Merkle Patricia Trie 存储所有账户状态：

```
                    State Root (在区块头中)
                   /          \
              [0x7...]      [0x1...]
              /    \         /    \
         [0x71C7..]  ...  [0x1f98..]  ...
            │                  │
     Alice的账户状态      Uniswap合约状态
```

每个区块头包含一个 State Root，它是所有账户状态的"指纹"。任何一个账户的余额变化，都会导致 State Root 改变。

## 3.3 交易生命周期

一笔以太坊交易从创建到最终确认，经历以下步骤：

```
1. 构造交易
   ┌─────────────────────────────┐
   │ from: 0x71C7...             │
   │ to: 0x1f98...               │
   │ value: 1 ETH                │
   │ data: 0xa9059cbb...         │  ← 合约调用数据
   │ nonce: 42                   │
   │ gasLimit: 21000             │
   │ maxFeePerGas: 30 gwei      │  ← EIP-1559
   │ maxPriorityFeePerGas: 2 gwei│
   │ chainId: 1                  │
   └─────────────────────────────┘
          │
          ▼
2. 签名 (用私钥对交易哈希签名，得到 v, r, s)
          │
          ▼
3. 广播到网络 (通过 JSON-RPC 发送到节点)
          │
          ▼
4. 进入交易池 (Mempool)
   - 节点验证签名、余额、Nonce
   - 按 Gas Price 排序
          │
          ▼
5. 被验证者打包进区块
   - 验证者选择 Gas Price 最高的交易
   - 执行交易，更新状态
          │
          ▼
6. 区块被确认
   - 其他验证者验证区块
   - 经过 2 个 epoch (~12.8 分钟) 后最终确认
```

### EIP-1559 费用机制

```
总费用 = Gas Used × (Base Fee + Priority Fee)

Base Fee:     由网络自动调整，每个区块根据使用率变化
              区块使用率 > 50% → Base Fee 上升
              区块使用率 < 50% → Base Fee 下降
              Base Fee 被销毁（burn）

Priority Fee: 用户自定义的小费，给验证者
              越高越容易被优先打包

maxFeePerGas: 用户愿意支付的最高费用
maxPriorityFeePerGas: 用户愿意给的最高小费

实际支付 = Gas Used × min(maxFeePerGas, Base Fee + maxPriorityFeePerGas)
```

### 用 Go 解析真实交易

```go
package main

import (
	"context"
	"fmt"
	"log"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	// 连接以太坊节点（使用公共 RPC 或 Infura/Alchemy）
	client, err := ethclient.Dial("https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY")
	if err != nil {
		log.Fatal(err)
	}

	// 查询一笔真实交易
	txHash := common.HexToHash("0x你的交易哈希")
	tx, isPending, err := client.TransactionByHash(context.Background(), txHash)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("交易哈希: %s\n", tx.Hash().Hex())
	fmt.Printf("是否待确认: %v\n", isPending)
	fmt.Printf("目标地址: %s\n", tx.To().Hex())
	fmt.Printf("转账金额: %s ETH\n", weiToEther(tx.Value()))
	fmt.Printf("Gas Limit: %d\n", tx.Gas())
	fmt.Printf("Gas Price: %s Gwei\n", weiToGwei(tx.GasPrice()))
	fmt.Printf("Nonce: %d\n", tx.Nonce())
	fmt.Printf("Data: 0x%x\n", tx.Data()[:4]) // 函数选择器（前4字节）

	// 查询交易回执
	receipt, err := client.TransactionReceipt(context.Background(), txHash)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("状态: %d (1=成功, 0=失败)\n", receipt.Status)
	fmt.Printf("实际 Gas 消耗: %d\n", receipt.GasUsed)
	fmt.Printf("区块号: %d\n", receipt.BlockNumber.Uint64())
	fmt.Printf("日志数量: %d\n", len(receipt.Logs))
}

func weiToEther(wei *big.Int) string {
	ether := new(big.Float).Quo(
		new(big.Float).SetInt(wei),
		new(big.Float).SetInt(big.NewInt(1e18)),
	)
	return ether.Text('f', 6)
}

func weiToGwei(wei *big.Int) string {
	gwei := new(big.Float).Quo(
		new(big.Float).SetInt(wei),
		new(big.Float).SetInt(big.NewInt(1e9)),
	)
	return gwei.Text('f', 2)
}
```

## 3.4 主流公链生态全景

### EVM 兼容链对比

| 链 | Chain ID | 出块时间 | Gas 费用 | TPS | 定位 |
|---|---------|---------|---------|-----|------|
| Ethereum | 1 | ~12s | 高 | ~15 | 安全性最高的 L1 |
| BSC | 56 | ~3s | 低 | ~160 | 币安生态，高性能 |
| Polygon | 137 | ~2s | 极低 | ~65 | 以太坊侧链 |
| Arbitrum | 42161 | ~0.25s | 低 | ~40000 | Optimistic Rollup L2 |
| Optimism | 10 | ~2s | 低 | ~2000 | Optimistic Rollup L2 |
| Base | 8453 | ~2s | 低 | ~2000 | Coinbase 的 L2 |
| zkSync Era | 324 | ~1s | 低 | ~2000 | zk Rollup L2 |
| Avalanche | 43114 | ~2s | 中 | ~4500 | 子网架构 |

### L1 vs L2 的关系

```
┌─────────────────────────────────────────┐
│           Layer 1: Ethereum              │
│  安全性最高，但速度慢、费用高              │
│  所有 L2 的最终结算层                     │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │ Arbitrum  │  │ Optimism │  │ zkSync ││
│  │ Optimistic│  │ Optimistic│  │ zk     ││
│  │ Rollup    │  │ Rollup   │  │ Rollup ││
│  └──────────┘  └──────────┘  └────────┘│
│       Layer 2: 在 L1 上结算的扩展方案     │
│       速度快、费用低、继承 L1 安全性       │
└─────────────────────────────────────────┘
```

### Solana：完全不同的架构

Solana 不是 EVM 兼容链，它有自己独特的架构：

| 特性 | Ethereum | Solana |
|------|---------|--------|
| 虚拟机 | EVM | SVM (Sealevel) |
| 合约语言 | Solidity | Rust (Anchor) |
| 账户模型 | 账户存储状态 | 程序与数据账户分离 |
| 并行执行 | 串行 | 并行（Sealevel） |
| 出块时间 | ~12s | ~0.4s |
| TPS | ~15 | ~65000 |
| Gas 费用 | 高 | 极低（~$0.00025） |

## 3.5 开发环境完整搭建

### Go 环境

```bash
# 安装 Go 1.22+
# macOS
brew install go

# 验证安装
go version
# go version go1.22.0 darwin/arm64

# 初始化项目
mkdir web3-project && cd web3-project
go mod init github.com/yourname/web3-project

# 安装核心依赖
go get github.com/ethereum/go-ethereum
go get golang.org/x/crypto
go get github.com/tyler-smith/go-bip39
go get github.com/tyler-smith/go-bip32
```

### Solidity 工具链（Foundry）

```bash
# 安装 Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 验证安装
forge --version
cast --version
anvil --version

# 创建 Foundry 项目
forge init my-contracts
cd my-contracts

# 项目结构
# ├── src/          ← 合约源码
# ├── test/         ← 测试文件
# ├── script/       ← 部署脚本
# └── foundry.toml  ← 配置文件

# 编译合约
forge build

# 运行测试
forge test

# 启动本地链
anvil
# 默认在 http://127.0.0.1:8545
# 自动生成 10 个测试账户，每个有 10000 ETH
```

### Flutter 环境

```bash
# 安装 Flutter SDK
# macOS
brew install flutter

# 验证安装
flutter doctor

# 创建 Flutter 项目
flutter create --org com.yourname web3_dapp
cd web3_dapp

# 添加 Web3 相关依赖
# 编辑 pubspec.yaml，添加：
```

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # Web3 核心
  web3dart: ^2.7.3              # 以太坊交互
  walletconnect_flutter_v2: ^2.3.0  # WalletConnect
  bip39: ^1.0.6                 # 助记词
  bip32: ^2.0.0                 # HD 钱包派生
  hex: ^0.2.0                   # 十六进制工具

  # 网络
  dio: ^5.4.0                   # HTTP 客户端
  web_socket_channel: ^2.4.0    # WebSocket

  # 状态管理
  flutter_riverpod: ^2.5.0      # Riverpod
  riverpod_annotation: ^2.3.0

  # 存储
  flutter_secure_storage: ^9.0.0 # 安全存储（私钥）
  hive_flutter: ^1.1.0          # 本地数据库

  # UI
  fl_chart: ^0.68.0             # 图表
  cached_network_image: ^3.3.0  # 图片缓存
  qr_flutter: ^4.1.0            # 二维码
```

```bash
# 安装依赖
flutter pub get
```

### 节点服务配置

注册以下任一服务获取 API Key：

1. [Alchemy](https://www.alchemy.com/) — 推荐，免费额度充足
2. [Infura](https://infura.io/) — MetaMask 背后的服务
3. [QuickNode](https://www.quicknode.com/) — 多链支持好

```bash
# 创建环境变量文件
cat > .env << 'EOF'
# 以太坊主网
ETH_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
# 以太坊测试网 (Sepolia)
ETH_SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
# Polygon
POLYGON_RPC_URL=https://polygon-mainnet.g.alchemy.com/v2/YOUR_KEY
# Arbitrum
ARBITRUM_RPC_URL=https://arb-mainnet.g.alchemy.com/v2/YOUR_KEY
# BSC
BSC_RPC_URL=https://bsc-dataseed.binance.org
EOF

# 记得把 .env 加入 .gitignore！
echo ".env" >> .gitignore
```

### 验证环境：Hello Web3 全链路

```go
// main.go - 验证 Go + Ethereum 连接
package main

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
)

func main() {
	// 加载 .env
	godotenv.Load()

	// 连接以太坊节点
	client, err := ethclient.Dial(os.Getenv("ETH_RPC_URL"))
	if err != nil {
		log.Fatalf("连接失败: %v", err)
	}
	defer client.Close()

	// 获取最新区块号
	blockNumber, err := client.BlockNumber(context.Background())
	if err != nil {
		log.Fatalf("获取区块号失败: %v", err)
	}
	fmt.Printf("✅ 连接成功！当前以太坊区块高度: %d\n", blockNumber)

	// 获取链 ID
	chainID, err := client.ChainID(context.Background())
	if err != nil {
		log.Fatalf("获取链ID失败: %v", err)
	}
	fmt.Printf("✅ Chain ID: %d\n", chainID)

	// 查询 Vitalik 的 ETH 余额
	vitalik := common.HexToAddress("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
	balance, err := client.BalanceAt(context.Background(), vitalik, nil)
	if err != nil {
		log.Fatalf("查询余额失败: %v", err)
	}

	// Wei → ETH
	ethBalance := new(big.Float).Quo(
		new(big.Float).SetInt(balance),
		new(big.Float).SetInt(big.NewInt(1e18)),
	)
	fmt.Printf("✅ Vitalik 的 ETH 余额: %s ETH\n", ethBalance.Text('f', 4))
}
```

运行：
```bash
go run main.go
# ✅ 连接成功！当前以太坊区块高度: 19234567
# ✅ Chain ID: 1
# ✅ Vitalik 的 ETH 余额: 1234.5678 ETH
```

## 3.6 区块浏览器与开发工具

### Etherscan API 使用

```go
package explorer

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const etherscanAPI = "https://api.etherscan.io/api"

// GetContractABI 从 Etherscan 获取已验证合约的 ABI
func GetContractABI(address, apiKey string) (string, error) {
	url := fmt.Sprintf("%s?module=contract&action=getabi&address=%s&apikey=%s",
		etherscanAPI, address, apiKey)

	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	var result struct {
		Status  string `json:"status"`
		Message string `json:"message"`
		Result  string `json:"result"`
	}
	json.Unmarshal(body, &result)

	if result.Status != "1" {
		return "", fmt.Errorf("API 错误: %s", result.Message)
	}
	return result.Result, nil
}

// GetTokenBalance 查询 ERC-20 代币余额
func GetTokenBalance(tokenAddress, walletAddress, apiKey string) (string, error) {
	url := fmt.Sprintf(
		"%s?module=account&action=tokenbalance&contractaddress=%s&address=%s&tag=latest&apikey=%s",
		etherscanAPI, tokenAddress, walletAddress, apiKey)

	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	var result struct {
		Result string `json:"result"`
	}
	json.Unmarshal(body, &result)
	return result.Result, nil
}
```

## 3.7 本章小结与练习

### 你学到了什么

- EVM 的栈机器执行模型和 Gas 消耗机制
- EOA 和合约账户的区别
- 交易从创建到确认的完整生命周期
- EIP-1559 费用机制
- 主流公链的特点和选型依据
- 完整开发环境的搭建

### 动手练习

1. **多链连接器**：用 Go 实现一个多链连接管理器，支持同时连接 Ethereum、BSC、Polygon、Arbitrum，并查询各链的最新区块号和 Gas Price

2. **交易解码器**：实现一个工具，输入交易哈希，输出交易的完整信息（包括解码 input data 中的函数调用）

3. **区块监控器**：实现一个实时区块监控程序，订阅新区块事件，打印每个新区块的基本信息（区块号、交易数、Gas Used、Base Fee）

4. **多链部署**：在 Sepolia、BSC Testnet、Polygon Mumbai 三个测试网上部署同一个简单合约，对比部署 Gas 消耗和确认时间

### 下一章预告

下一章正式进入 Go 语言深度学习——并发编程、接口设计、工程化实践，全部围绕区块链开发场景展开。
