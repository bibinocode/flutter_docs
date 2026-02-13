# GO + Flutter Web3 从零到一 · 全栈开发实战教学大纲

> 以项目实战为核心驱动，覆盖 Go 后端、Solidity/Rust 智能合约、Flutter 跨平台 DApp 前端，从区块链基础认知到独立交付企业级 Web3 产品的完整学习路径。

---

## 课程定位与目标

- 面向 Web2 开发者转型 Web3 全栈工程师
- 技术栈：Go + Solidity + Rust + Flutter + Dart
- 最终产出：独立完成 DEX、NFT Marketplace、DeFi 借贷平台、跨链钱包等企业级项目
- 学习周期：约 20 周（可根据个人节奏调整）

---

## 课程总览架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    Web3 全栈开发课程体系                       │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│  第一模块  │  第二模块  │  第三模块  │  第四模块  │    第五模块     │
│ 区块链基础 │ Go后端开发 │ 智能合约  │ Flutter  │  综合实战项目   │
│ 与密码学   │ 与链交互   │ 开发     │ DApp前端 │  与部署上线     │
│ (2周)     │ (4周)     │ (4周)    │ (4周)    │  (6周)         │
└──────────┴──────────┴──────────┴──────────┴─────────────────┘
```

---

## 第一模块：区块链基础与密码学原理（2 周）

> 不写一行代码之前，先把底层逻辑搞透。这个模块不是"了解概念"，而是能手写一个最小区块链。

### 第 1 周：区块链核心原理

#### 1.1 区块链本质与演进

- 分布式账本 vs 传统数据库：数据结构对比实操
- 共识机制全景：PoW / PoS / DPoS / PBFT / PoA 原理与代码模拟
- 区块结构深度解析：Block Header、Merkle Tree、Nonce、Difficulty
- 实操：用 Go 从零实现一个最小区块链（含区块生成、链验证、难度调整）

#### 1.2 密码学基础（实战向）

- 哈希函数：SHA-256 / Keccak-256 原理与 Go 实现
- 非对称加密：ECDSA（secp256k1）签名与验签的 Go 实现
- 助记词与 HD 钱包：BIP-32 / BIP-39 / BIP-44 推导路径实现
- 零知识证明入门：zk-SNARK / zk-STARK 概念与简单电路构建
- 实操：用 Go 实现一个 HD 钱包生成器（助记词 → 私钥 → 公钥 → 地址）

#### 1.3 以太坊架构深度剖析

- EVM 执行模型：Stack Machine、Opcode、Gas 计算机制
- 账户模型：EOA vs Contract Account，State Trie 结构
- 交易生命周期：从签名到打包到确认的完整流程
- 以太坊 2.0 / PoS：Beacon Chain、Validator、Slashing 机制
- 实操：用 Go 解析一笔真实以太坊交易的 RLP 编码

### 第 2 周：多链生态与开发环境

#### 2.1 主流公链对比与选型

- EVM 兼容链：Ethereum / BSC / Polygon / Arbitrum / Optimism / Base
- Solana 架构：Account Model / Program / PDA / CPI
- 新兴 L2：zkSync / StarkNet / Scroll / Linea
- Cosmos / Polkadot 跨链生态概览
- 实操：在 5 条不同链的测试网上部署同一个合约，对比 Gas 和确认时间

#### 2.2 开发环境全套搭建

- Go 开发环境：Go 1.22+、GoLand/VSCode、Go Modules
- Solidity 工具链：Hardhat / Foundry / Remix / solc
- Rust + Anchor（Solana 开发）
- Flutter 开发环境：Flutter SDK、Dart、Android Studio / Xcode
- 节点服务：Infura / Alchemy / QuickNode 配置与使用
- 本地链：Hardhat Network / Anvil / Ganache
- 实操：搭建完整的全栈开发环境，跑通第一个 "Hello Web3" 全链路

#### 2.3 Web3 开发者必备工具

- 区块浏览器：Etherscan / BscScan / Solscan API 使用
- 钱包工具：MetaMask / Phantom / WalletConnect 协议
- The Graph：子图定义与部署
- IPFS / Arweave：去中心化存储
- 实操：用 The Graph 索引一个已部署合约的事件数据

---

## 第二模块：Go 语言与区块链后端开发（4 周）

> 原大纲 10 天的 Go 课程，这里扩展为 4 周，每个知识点都配合区块链场景实战。

### 第 3 周：Go 语言核心精通

#### 3.1 Go 语言基础（快速过关）

- 变量、常量、基本数据类型、类型推断
- 数组、切片（Slice）底层原理与扩容机制
- Map 的哈希实现与并发安全（sync.Map）
- 结构体、方法、嵌入（Embedding）
- 接口与多态：空接口、类型断言、类型开关
- 错误处理哲学：error / panic / recover / 自定义错误类型
- 实操：实现一个区块链交易数据的序列化/反序列化工具库

#### 3.2 Go 并发编程深度实战

- Goroutine 调度模型：GMP 模型深度解析
- Channel 通信：无缓冲/有缓冲、单向 Channel、Channel 方向
- Select 多路复用与超时控制
- sync 包全家桶：Mutex / RWMutex / WaitGroup / Once / Pool
- Context 包：超时控制、取消传播、值传递
- 并发模式：Fan-In / Fan-Out / Pipeline / Worker Pool / Rate Limiting
- 实操：实现一个高并发的区块链事件监听器（监听多个合约的多种事件）

#### 3.3 Go 工程化实践

- 项目结构：Standard Go Project Layout
- 依赖管理：Go Modules 深度使用
- 单元测试：testing 包、表驱动测试、Mock、Benchmark
- 代码质量：golangci-lint、go vet、race detector
- 实操：为区块链工具库编写完整的测试套件

### 第 4 周：Go-Ethereum 与链交互

#### 4.1 go-ethereum（Geth）客户端

- Geth 源码编译与安装
- 节点配置：主网/测试网/私链参数
- JSON-RPC 接口全解：eth_* / net_* / web3_* / debug_*
- IPC / HTTP / WebSocket 三种连接方式
- 实操：搭建本地私链，通过 RPC 完成转账

#### 4.2 ethclient 深度使用

- 连接管理：连接池、重连机制、多节点负载均衡
- 区块数据读取：区块头、交易列表、交易回执
- 账户操作：余额查询、Nonce 管理、Gas 估算
- 交易构建与签名：Legacy / EIP-1559 / EIP-2930 交易类型
- 交易发送与确认：广播、等待确认、Receipt 解析
- 实操：用 Go 实现一个批量转账工具（支持 ETH 和 ERC-20）

#### 4.3 智能合约交互（Go 端）

- ABI 编码解码：类型映射、参数打包/解包、动态类型处理
- abigen 工具：从 ABI 生成 Go 绑定代码
- 合约调用：只读调用（Call）vs 写入调用（Transact）
- 事件监听：FilterLogs / SubscribeFilterLogs / 历史事件扫描
- Gas 优化：估算策略、EIP-1559 费用计算、加速/取消交易
- 实操：用 Go 封装一个 Uniswap V3 Router 的完整交互 SDK

### 第 5 周：区块链后端微服务架构

#### 5.1 RESTful API 服务（Gin/Echo）

- 框架选型：Gin vs Echo vs Fiber 对比
- 路由设计：RESTful 规范、版本控制、参数校验
- 中间件开发：JWT 认证、CORS、限流（令牌桶/漏桶）、日志、Recovery
- Swagger/OpenAPI 文档自动生成
- 实操：搭建 DApp 后端 API 服务骨架

#### 5.2 gRPC 微服务

- Protocol Buffers 3 语法与设计
- 四种通信模式：Unary / Server Stream / Client Stream / Bidirectional
- 拦截器（Interceptor）：认证、日志、链路追踪
- gRPC-Gateway：同时提供 REST 和 gRPC
- 实操：实现区块链数据同步服务的 gRPC 接口

#### 5.3 消息队列与异步处理

- Kafka / RabbitMQ / NATS 选型与集成
- 事件驱动架构：链上事件 → 消息队列 → 业务处理
- 幂等性设计与消息去重
- 死信队列与重试策略
- 实操：实现链上交易事件的异步处理管道

### 第 6 周：数据存储与高可用

#### 6.1 关系型数据库

- PostgreSQL 深度使用：GORM / sqlx / pgx
- 数据模型设计：区块数据、交易记录、用户资产表设计
- 事务处理与并发控制
- 分库分表策略：按链分库、按时间分表
- 数据库迁移：golang-migrate
- 实操：设计并实现 DEX 交易平台的完整数据库 Schema

#### 6.2 缓存与 NoSQL

- Redis 深度使用：数据结构选型、Pipeline、Lua 脚本
- 缓存模式：Cache-Aside / Write-Through / Write-Behind
- 分布式锁：Redlock 算法实现
- MongoDB：链上数据的文档存储方案
- 实操：实现代币价格缓存服务（含缓存穿透/雪崩/击穿防护）

#### 6.3 IPFS 与去中心化存储

- IPFS 原理：Content Addressing、DHT、Bitswap
- Go-IPFS 客户端集成
- Pinata / Web3.Storage / NFT.Storage API
- Arweave 永久存储方案
- 实操：实现 NFT 元数据上传与检索服务

#### 6.4 高可用与可观测性

- 服务注册发现：Consul / etcd
- 负载均衡：Nginx / Envoy / Go 内置
- 熔断降级：go-resilience / gobreaker
- 链路追踪：OpenTelemetry + Jaeger
- 指标监控：Prometheus + Grafana
- 日志聚合：ELK / Loki
- 实操：为 DApp 后端搭建完整的可观测性体系

---

## 第三模块：智能合约开发（4 周）

> 原大纲的 Solidity 10 天课程 + Uniswap V3/V4 实战，这里扩展为 4 周，增加 Rust/Solana 合约开发。

### 第 7 周：Solidity 基础与进阶

#### 7.1 Solidity 语言核心

- 数据类型全解：值类型 / 引用类型 / 映射
- 存储布局：Storage / Memory / Calldata / Stack 的区别与 Gas 影响
- 函数可见性：public / external / internal / private
- 函数修饰符：view / pure / payable / modifier
- 继承体系：单继承 / 多继承 / 菱形继承 / super 关键字
- 接口与抽象合约
- 库合约（Library）：内部调用 vs delegatecall
- 实操：实现一个完整的 ERC-20 代币合约（含铸造、销毁、授权、转账）

#### 7.2 Solidity 高级特性

- 事件（Event）与日志（Log）：indexed 参数、Topic 结构
- 错误处理：require / revert / assert / 自定义 Error（Gas 优化）
- Assembly / Yul 内联汇编：直接操作 EVM
- 代理模式：Transparent Proxy / UUPS / Beacon Proxy / Diamond（EIP-2535）
- 存储槽（Storage Slot）管理与冲突避免
- Create2 确定性部署
- 实操：实现一个可升级的代币合约（UUPS 模式 + OpenZeppelin）

#### 7.3 ERC 标准全解与实现

- ERC-20：同质化代币标准（含 Permit / ERC-2612）
- ERC-721：NFT 标准（含 Enumerable / Metadata / Royalty ERC-2981）
- ERC-1155：多代币标准
- ERC-4626：代币化金库标准
- ERC-6551：代币绑定账户（TBA）
- 实操：实现一个支持版税的 NFT 合约（ERC-721 + ERC-2981）

#### 7.4 开发框架实战

- Hardhat 全流程：编译 → 测试 → 部署 → 验证
- Foundry 全流程：forge build / test / script / verify
- 测试技巧：Fuzz Testing / Invariant Testing / Fork Testing
- Gas 报告与优化分析
- 实操：用 Foundry 为 ERC-20 合约编写完整的 Fuzz 测试套件

### 第 8 周：DeFi 协议开发 — Uniswap V3/V4

#### 8.1 AMM 原理与数学基础

- 恒定乘积公式：x * y = k 的数学推导
- 集中流动性：Uniswap V3 的 Tick 数学（Q64.96 定点数）
- 价格区间与流动性分布
- 手续费计算：Fee Growth / Position Fee
- 无常损失（Impermanent Loss）量化分析
- 实操：用 Go 实现 AMM 数学库（含价格计算、流动性计算、滑点估算）

#### 8.2 Uniswap V3 核心合约精读

- UniswapV3Factory：Pool 创建与管理
- UniswapV3Pool：Swap / Mint / Burn / Collect / Flash
- Tick 管理：TickBitmap / TickMath / SqrtPriceMath
- Oracle：TWAP 价格预言机实现
- NonfungiblePositionManager：Position NFT 管理
- SwapRouter：多路径交易路由
- 实操：Fork Uniswap V3 合约，修改手续费等级，部署到测试网

#### 8.3 Uniswap V4 核心创新

- Singleton Pool 架构：所有池共享一个合约
- Hooks 机制：beforeSwap / afterSwap / beforeAddLiquidity 等 8 个钩子
- Flash Accounting：瞬态存储（EIP-1153）优化 Gas
- 自定义交易逻辑：动态手续费、限价单、TWAMM
- PoolManager 与 PoolKey 设计
- 实操：开发一个自定义 Hook（动态手续费 Hook：根据波动率调整费率）

#### 8.4 流动性管理与策略

- Position 管理：添加/移除/调整流动性
- 范围订单（Range Order）实现
- 流动性挖矿激励设计
- 自动化流动性管理：类 Arrakis / Gamma 策略
- 实操：实现一个自动再平衡的流动性管理合约

### 第 9 周：合约安全与审计

#### 9.1 常见漏洞深度分析

- 重入攻击：经典案例（The DAO）+ 跨函数重入 + 只读重入
- 闪电贷攻击：价格操纵、治理攻击、清算攻击
- 预言机操纵：Spot Price vs TWAP、Chainlink 集成最佳实践
- 整数溢出/下溢：Solidity 0.8+ 的 checked/unchecked
- 前端运行（Front-Running）与 MEV
- 访问控制漏洞：tx.origin vs msg.sender、权限提升
- 存储碰撞：代理合约的存储布局冲突
- 拒绝服务（DoS）：Gas Limit、外部调用失败
- 实操：复现 5 个经典攻击案例（用 Foundry Fork 主网状态）

#### 9.2 安全开发模式

- Checks-Effects-Interactions 模式
- Pull over Push 模式
- 重入锁（ReentrancyGuard）
- 时间锁（Timelock）与多签（Multisig）
- 紧急暂停（Pausable）
- 速率限制与金额限制
- 实操：为 DeFi 协议实现完整的安全防护层

#### 9.3 审计工具与流程

- 静态分析：Slither / Mythril / Aderyn
- 模糊测试：Echidna / Medusa
- 形式化验证：Certora / Halmos
- 手动审计方法论：代码走查清单
- 审计报告编写
- 实操：对自己开发的 Uniswap Hook 进行完整安全审计

### 第 10 周：Solana 合约开发（Rust + Anchor）

#### 10.1 Rust 语言快速入门（面向 Solana）

- 所有权系统：Ownership / Borrowing / Lifetime
- 枚举与模式匹配
- Trait 与泛型
- 错误处理：Result / Option / ? 运算符
- 宏（Macro）基础
- 实操：用 Rust 实现一个简单的代币转账逻辑

#### 10.2 Solana 编程模型

- Account Model vs EVM 的区别
- Program / Instruction / Account 三元组
- PDA（Program Derived Address）原理与使用
- CPI（Cross-Program Invocation）跨程序调用
- SPL Token 程序
- 实操：用 Native Rust 实现一个计数器程序

#### 10.3 Anchor 框架实战

- Anchor 项目结构与工作流
- Account 约束与验证
- 指令处理器设计
- 事件与错误定义
- 测试：Bankrun / anchor test
- 实操：用 Anchor 实现一个 SPL Token Staking 程序

#### 10.4 Solana DeFi 开发

- Raydium / Orca AMM 原理
- Jupiter 聚合器集成
- Solana 上的 NFT：Metaplex 标准
- 实操：实现一个简单的 Solana DEX（Token Swap 程序）

---

## 第四模块：Flutter DApp 前端开发（4 周）

> 原大纲使用 React Native + Wagmi，本课程替换为 Flutter + Dart，实现真正的跨平台 Web3 客户端（iOS / Android / Web / Desktop）。

### 第 11 周：Dart 语言与 Flutter Web3 基础

#### 11.1 Dart 语言核心（Web3 开发视角）

- 类型系统与空安全（Null Safety）
- 异步编程：Future / async-await / Stream / StreamController
- Isolate 并发：计算密集型任务（如密钥派生）的隔离执行
- 扩展方法（Extension）：为 BigInt / Uint8List 添加链上数据处理方法
- 代码生成：build_runner / json_serializable / freezed
- 实操：实现一个 Dart 版的以太坊地址工具库（含校验和地址 EIP-55）

#### 11.2 Flutter 基础快速过关

- Widget 树、Element 树、RenderObject 树
- StatelessWidget vs StatefulWidget
- 布局系统：Row / Column / Stack / Flex / Wrap
- 列表与滚动：ListView / GridView / CustomScrollView / Sliver
- 路由与导航：GoRouter / auto_route
- 主题与样式：Material 3 / ThemeData / ColorScheme
- 实操：搭建 DApp 的 UI 骨架（底部导航 + 页面路由 + 主题切换）

#### 11.3 Flutter Web3 核心库

- web3dart 包：连接节点、读写合约、签名交易
- walletconnect_flutter_v2：WalletConnect 协议集成
- webthree 包：增强版 Web3 交互
- bip39_mnemonic / bip32_ed25519：助记词与密钥派生
- 实操：实现 Flutter 连接 MetaMask（WalletConnect）并读取余额

### 第 12 周：Flutter 钱包开发

#### 12.1 钱包核心功能

- 助记词生成与安全存储（flutter_secure_storage）
- HD 钱包派生：BIP-44 多链地址生成
- 私钥管理：加密存储、生物识别解锁
- 多链支持：EVM 链 + Solana 地址生成
- 实操：实现一个完整的 HD 钱包创建/导入/备份流程

#### 12.2 交易功能

- 交易构建：Legacy / EIP-1559 交易类型
- Gas 估算与费用展示
- 交易签名：本地签名 vs WalletConnect 远程签名
- 交易状态追踪：Pending → Confirmed → Failed
- 交易历史：链上数据 + 本地缓存
- 实操：实现 ETH 和 ERC-20 代币的转账功能（含 Gas 估算 UI）

#### 12.3 代币与资产管理

- ERC-20 代币列表：自动发现 + 手动添加
- 代币余额批量查询（Multicall 合约）
- 代币价格获取：CoinGecko / DeFiLlama API
- NFT 展示：ERC-721 / ERC-1155 元数据解析与图片渲染
- 实操：实现资产总览页面（代币列表 + 总资产估值 + NFT Gallery）

#### 12.4 安全与用户体验

- 生物识别：指纹/面容解锁（local_auth）
- 交易确认弹窗：金额、Gas、目标地址的清晰展示
- 钓鱼防护：地址校验、合约交互风险提示
- 深度链接（Deep Link）：WalletConnect URI 处理
- 实操：实现完整的安全交互流程（解锁 → 确认 → 签名 → 结果）

### 第 13 周：Flutter DApp 浏览器与 DeFi 交互

#### 13.1 DApp 浏览器

- WebView 集成：flutter_inappwebview
- JavaScript Bridge：注入 Web3 Provider
- EIP-1193 Provider 实现：eth_requestAccounts / eth_sendTransaction
- DApp 白名单与安全策略
- 实操：实现一个内置 DApp 浏览器（可访问 Uniswap 等 DApp）

#### 13.2 DEX 交易界面

- Token Swap UI：代币选择器、金额输入、滑点设置
- 价格影响计算与展示
- 交易路由可视化
- 交易确认与状态追踪
- 实操：实现 Uniswap 风格的 Token Swap 页面（连接自己的 Go 后端）

#### 13.3 流动性管理界面

- Position 列表展示
- 添加/移除流动性 UI
- 价格区间选择器（Range Selector）
- 收益分析图表（fl_chart）
- 实操：实现 Uniswap V3 风格的流动性管理页面

#### 13.4 多链支持

- 链配置管理：Chain ID / RPC URL / 区块浏览器
- 链切换 UI 与逻辑
- 跨链资产展示
- 网络状态监控
- 实操：支持 Ethereum / BSC / Polygon / Arbitrum 四链切换

### 第 14 周：Flutter 状态管理与工程化

#### 14.1 状态管理方案

- Riverpod 2.0：Provider / StateNotifier / AsyncValue
- Web3 状态建模：钱包连接状态、链状态、交易状态
- 合约数据缓存与自动刷新
- 乐观更新（Optimistic Update）策略
- 实操：用 Riverpod 重构整个 DApp 的状态管理

#### 14.2 网络层封装

- Dio + Interceptor：API 请求封装
- WebSocket 长连接：实时价格推送、交易状态更新
- 离线优先策略：本地缓存 + 网络同步
- 错误处理与重试机制
- 实操：封装完整的网络层（REST API + WebSocket + 链上 RPC）

#### 14.3 性能优化

- 列表性能：大量代币/NFT 的虚拟滚动
- 图片优化：NFT 图片缓存与懒加载（cached_network_image）
- 启动优化：延迟初始化、预加载关键数据
- 内存管理：大数运算（BigInt）的内存优化
- 实操：性能 Profiling 与优化实战

#### 14.4 测试与 CI/CD

- Widget 测试：关键 UI 组件测试
- 集成测试：完整交易流程测试
- Golden 测试：UI 快照对比
- CI/CD：GitHub Actions 自动构建 APK / IPA / Web
- 实操：搭建完整的 Flutter CI/CD 流水线

---

## 第五模块：综合实战项目与部署上线（6 周）

> 这是整个课程的核心。三个完整的企业级项目，从架构设计到部署上线，全流程实战。

### 项目一：去中心化交易所 DEX（2 周）

#### 第 15 周：DEX 核心开发

##### 智能合约层
- Fork Uniswap V3/V4 核心合约并定制
- 自定义 Hook 开发：动态手续费、限价单、TWAMM
- 多代币 Factory 部署
- 合约测试：Foundry Fuzz + Fork Testing

##### Go 后端服务
- 订单撮合引擎：内存撮合 + 链上结算
- 交易路由服务：最优路径计算（类 1inch 路由算法）
- 价格聚合服务：多源价格聚合 + TWAP 计算
- 链上事件索引：Swap / Mint / Burn 事件实时同步
- K 线数据服务：1m / 5m / 1h / 1d 时序数据生成

##### Flutter 前端
- Token Swap 页面：代币选择、金额计算、滑点设置、价格影响
- 流动性页面：添加/移除流动性、Position 管理、收益追踪
- K 线图表：TradingView 风格的价格图表
- 交易历史：链上交易记录展示

#### 第 16 周：DEX 高级功能与部署

##### 高级功能
- MEV 保护：Flashbots 集成 / 私有交易池
- 跨链交易：跨链桥接口集成
- 限价单系统：链下签名 + 链上执行
- 套利监控：价格偏差检测与告警

##### 部署与运维
- 合约部署：多链部署脚本（Hardhat / Foundry）
- 合约验证：Etherscan 源码验证
- 后端部署：Docker + Kubernetes
- 前端部署：Flutter Web → Vercel / IPFS
- 监控告警：链上异常监控 + 服务健康检查

---

### 项目二：NFT 交易市场（2 周）

#### 第 17 周：NFT 市场核心开发

##### 智能合约层
- NFT 铸造合约：ERC-721 + 白名单 + 分阶段铸造
- 交易合约：挂单 / 购买 / 取消 / 出价 / 接受出价
- 拍卖合约：英式拍卖 / 荷兰式拍卖
- 版税合约：ERC-2981 + 强制版税（Operator Filter）
- 合约升级：UUPS 代理模式

##### Go 后端服务
- NFT 元数据服务：IPFS 上传 + 元数据缓存
- 订单簿服务：链下签名订单（类 OpenSea Seaport 协议）
- 索引服务：NFT Transfer / Sale / Listing 事件索引
- 搜索服务：Elasticsearch 全文搜索 + 属性过滤
- 排行榜服务：Collection / Trader 排行

##### Flutter 前端
- NFT 浏览页：瀑布流展示、属性过滤、排序
- NFT 详情页：图片/视频/3D 模型展示、属性、交易历史
- 铸造页面：连接钱包 → 选择数量 → 铸造 → 展示结果
- 个人中心：我的 NFT、收藏、出价、交易记录

#### 第 18 周：NFT 市场高级功能与部署

##### 高级功能
- 批量操作：批量购买 / 批量挂单（Seaport 批量执行）
- 稀有度计算：属性稀有度评分算法
- 价格估算：地板价追踪、历史成交分析
- 社交功能：关注 Collection、活动通知
- 多链 NFT 聚合：跨链 NFT 展示

##### 部署与运维
- 合约安全审计 Checklist
- IPFS 节点部署与 Pin 服务
- CDN 配置：NFT 图片加速
- 数据备份与恢复策略

---

### 项目三：DeFi 借贷平台（2 周）

#### 第 19 周：借贷平台核心开发

##### 智能合约层
- 借贷池合约：存款 / 借款 / 还款 / 提取
- 利率模型：动态利率曲线（类 Aave / Compound）
- 抵押率管理：LTV / 清算阈值 / 健康因子
- 清算合约：清算触发 / 清算奖励 / 坏账处理
- 预言机集成：Chainlink Price Feed + 备用预言机
- 闪电贷：Flash Loan 实现
- 治理代币：ERC-20 + 投票权 + 时间锁

##### Go 后端服务
- 利率计算服务：实时利率更新
- 清算机器人：健康因子监控 + 自动清算执行
- 预言机价格服务：多源价格聚合 + 异常检测
- 风控服务：大额操作预警、异常行为检测
- 数据分析服务：TVL / 借贷量 / 利率历史

##### Flutter 前端
- 市场总览：各资产的存借利率、TVL、利用率
- 存款页面：选择资产 → 输入金额 → 确认存入
- 借款页面：选择抵押品 → 选择借款资产 → 健康因子预览
- 仪表盘：我的存款、借款、健康因子、收益
- 清算页面：可清算头寸列表、一键清算

#### 第 20 周：借贷平台高级功能与课程总结

##### 高级功能
- 闪电贷套利：利用闪电贷进行清算套利
- 杠杆策略：循环借贷实现杠杆
- 跨链借贷：跨链消息传递（LayerZero / Wormhole）
- 治理系统：提案 / 投票 / 执行

##### 全课程总结与就业准备
- 项目代码整理与 GitHub 展示
- 技术博客撰写指导
- 简历优化：Web3 项目经验包装
- 面试准备：技术面试高频题 + 系统设计题
- 远程工作指南：Web3 远程岗位获取渠道

---

## 附录 A：技术栈速查表

| 层级 | 技术选型 | 用途 |
|------|---------|------|
| 智能合约（EVM） | Solidity + Foundry/Hardhat | 以太坊及 EVM 兼容链合约开发 |
| 智能合约（Solana） | Rust + Anchor | Solana 链上程序开发 |
| 后端语言 | Go 1.22+ | 高并发区块链后端服务 |
| Web 框架 | Gin / Echo | RESTful API 服务 |
| RPC 框架 | gRPC + protobuf | 微服务间通信 |
| 链交互 | go-ethereum (ethclient) | 以太坊节点交互 |
| 前端框架 | Flutter 3.x + Dart 3.x | 跨平台 DApp 客户端 |
| Web3 库（Dart） | web3dart / webthree | 合约交互、交易签名 |
| 钱包连接 | walletconnect_flutter_v2 | WalletConnect 协议 |
| 状态管理 | Riverpod 2.0 | Flutter 状态管理 |
| 关系数据库 | PostgreSQL | 结构化数据存储 |
| 缓存 | Redis | 热数据缓存、分布式锁 |
| 消息队列 | Kafka / NATS | 异步事件处理 |
| 去中心化存储 | IPFS / Arweave | NFT 元数据、文件存储 |
| 数据索引 | The Graph | 链上数据索引查询 |
| 预言机 | Chainlink | 链下数据上链 |
| 监控 | Prometheus + Grafana | 服务指标监控 |
| 链路追踪 | OpenTelemetry + Jaeger | 分布式链路追踪 |
| 容器化 | Docker + Kubernetes | 服务部署与编排 |
| CI/CD | GitHub Actions | 自动化构建部署 |

---

## 附录 B：每周实战项目产出清单

| 周次 | 实战产出 |
|------|---------|
| 第 1 周 | Go 最小区块链 + HD 钱包生成器 + RLP 解码器 |
| 第 2 周 | 多链合约部署 + 全栈开发环境 + The Graph 子图 |
| 第 3 周 | 区块链交易序列化库 + 高并发事件监听器 + 测试套件 |
| 第 4 周 | 批量转账工具 + Uniswap V3 Go SDK |
| 第 5 周 | DApp 后端 API 骨架 + gRPC 数据同步服务 + 异步处理管道 |
| 第 6 周 | DEX 数据库 Schema + 价格缓存服务 + NFT 元数据服务 + 可观测性体系 |
| 第 7 周 | ERC-20 代币 + 可升级合约 + NFT 合约 + Fuzz 测试套件 |
| 第 8 周 | AMM 数学库 + 自定义 Uniswap V4 Hook + 流动性管理合约 |
| 第 9 周 | 5 个攻击复现 + 安全防护层 + 完整安全审计报告 |
| 第 10 周 | Rust 代币转账 + Solana 计数器 + SPL Staking + Solana DEX |
| 第 11 周 | Dart 地址工具库 + DApp UI 骨架 + MetaMask 连接 |
| 第 12 周 | HD 钱包完整流程 + 转账功能 + 资产总览页面 + 安全交互流程 |
| 第 13 周 | DApp 浏览器 + Token Swap 页面 + 流动性管理页面 + 多链支持 |
| 第 14 周 | Riverpod 状态重构 + 网络层封装 + 性能优化 + CI/CD 流水线 |
| 第 15-16 周 | 完整 DEX 交易所（合约 + 后端 + 前端 + 部署） |
| 第 17-18 周 | 完整 NFT 交易市场（合约 + 后端 + 前端 + 部署） |
| 第 19-20 周 | 完整 DeFi 借贷平台（合约 + 后端 + 前端 + 部署）+ 就业准备 |

---

## 附录 C：推荐学习资源

### 官方文档
- [Go 官方文档](https://go.dev/doc/)
- [Solidity 官方文档](https://docs.soliditylang.org/)
- [Flutter 官方文档](https://docs.flutter.dev/)
- [Ethereum 开发者文档](https://ethereum.org/developers)
- [Solana 开发者文档](https://solana.com/docs)
- [Foundry Book](https://book.getfoundry.sh/)
- [Anchor 文档](https://www.anchor-lang.com/)

### 开源项目参考
- [go-ethereum](https://github.com/ethereum/go-ethereum) — Go 实现的以太坊客户端
- [Uniswap V3 Core](https://github.com/Uniswap/v3-core) — Uniswap V3 核心合约
- [Uniswap V4 Core](https://github.com/Uniswap/v4-core) — Uniswap V4 核心合约
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) — 安全合约库
- [web3dart](https://pub.dev/packages/web3dart) — Dart Web3 库
- [walletconnect_flutter_v2](https://pub.dev/packages/walletconnect_flutter_v2) — Flutter WalletConnect

### 学习平台
- [Cyfrin Updraft](https://updraft.cyfrin.io/) — Solidity 与安全审计课程
- [Road to Web3](https://www.web3.university/tracks/road-to-web3) — Web3 University 学习路径
- [Speedrun Ethereum](https://speedrunethereum.com/) — 以太坊快速上手挑战
- [Solana Cookbook](https://solanacookbook.com/) — Solana 开发食谱

### 安全资源
- [SWC Registry](https://swcregistry.io/) — 智能合约弱点分类
- [Rekt News](https://rekt.news/) — DeFi 安全事件分析
- [DeFi Hack Labs](https://github.com/SunWeb3Sec/DeFiHackLabs) — DeFi 攻击复现

---

## 附录 D：项目架构总览

```
Web3 全栈项目架构
├── contracts/                    # 智能合约
│   ├── ethereum/                 # EVM 合约 (Solidity + Foundry)
│   │   ├── src/                  # 合约源码
│   │   │   ├── core/             # 核心合约 (Pool, Factory, Router)
│   │   │   ├── hooks/            # Uniswap V4 Hooks
│   │   │   ├── tokens/           # ERC-20 / ERC-721 / ERC-1155
│   │   │   ├── lending/          # 借贷协议合约
│   │   │   ├── nft-market/       # NFT 市场合约
│   │   │   └── governance/       # 治理合约
│   │   ├── test/                 # 测试 (Fuzz + Fork + Invariant)
│   │   ├── script/               # 部署脚本
│   │   └── foundry.toml
│   └── solana/                   # Solana 合约 (Rust + Anchor)
│       ├── programs/             # Anchor 程序
│       ├── tests/                # 测试
│       └── Anchor.toml
│
├── backend/                      # Go 后端微服务
│   ├── cmd/                      # 服务入口
│   │   ├── api-gateway/          # API 网关
│   │   ├── indexer/              # 链上事件索引服务
│   │   ├── matching-engine/      # 撮合引擎
│   │   ├── liquidation-bot/      # 清算机器人
│   │   └── price-oracle/         # 价格聚合服务
│   ├── internal/                 # 内部包
│   │   ├── blockchain/           # 链交互层
│   │   ├── service/              # 业务逻辑层
│   │   ├── repository/           # 数据访问层
│   │   └── middleware/           # 中间件
│   ├── pkg/                      # 公共包
│   │   ├── abi/                  # ABI 绑定
│   │   ├── crypto/               # 密码学工具
│   │   └── math/                 # AMM 数学库
│   ├── api/                      # API 定义 (protobuf / OpenAPI)
│   ├── deployments/              # 部署配置 (Docker / K8s)
│   └── go.mod
│
├── flutter_app/                  # Flutter DApp 客户端
│   ├── lib/
│   │   ├── core/                 # 核心层
│   │   │   ├── blockchain/       # 链交互 (web3dart / WalletConnect)
│   │   │   ├── wallet/           # 钱包管理 (HD 派生 / 签名)
│   │   │   ├── network/          # 网络层 (Dio / WebSocket)
│   │   │   └── storage/          # 本地存储 (Hive / SecureStorage)
│   │   ├── features/             # 功能模块
│   │   │   ├── swap/             # Token Swap
│   │   │   ├── liquidity/        # 流动性管理
│   │   │   ├── nft/              # NFT 浏览与交易
│   │   │   ├── lending/          # 借贷操作
│   │   │   ├── portfolio/        # 资产总览
│   │   │   └── dapp_browser/     # DApp 浏览器
│   │   ├── shared/               # 共享组件与工具
│   │   └── app.dart              # 应用入口
│   ├── test/                     # 测试
│   ├── integration_test/         # 集成测试
│   └── pubspec.yaml
│
└── infrastructure/               # 基础设施
    ├── docker/                   # Docker 配置
    ├── k8s/                      # Kubernetes 配置
    ├── terraform/                # 基础设施即代码
    ├── monitoring/               # 监控配置 (Prometheus / Grafana)
    └── ci/                       # CI/CD 配置 (GitHub Actions)
```

---

> 本大纲基于 [秀才 Web3 大师之路](https://github.com/xiucai-web3-master-road/xiucai-web3-master-road-university) 课程体系进行扩写，结合 Go + Flutter 技术栈重新设计，融合了 [Road to Web3](https://www.web3.university/tracks/road-to-web3)、[Cyfrin Updraft](https://updraft.cyfrin.io/)、[Solana 官方文档](https://solana.com/docs) 等多方资源，以项目实战为核心驱动。
