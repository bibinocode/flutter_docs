# MetaMask Mobile 项目深度解析

> MetaMask Mobile 是全球最流行的移动端加密钱包，本文深度解读其架构设计、核心模块、交互流程，帮助你理解企业级 Web3 应用的开发模式。

## 📋 项目信息

- **GitHub**: https://github.com/MetaMask/metamask-mobile
- **技术栈**: React Native + TypeScript (94.8%)
- **Stars**: 2.8k | Forks: 1.5k
- **支持平台**: iOS / Android / Web
- **主要功能**: 钱包、代币管理、DApp 浏览器、交易管理

---

## 1. 项目概览

### 1.1 MetaMask 是什么？

MetaMask 是一个去中心化钱包和 Web3 网关：

```
用户的钱包 ← 管理私钥、助记词
    ↓
DApp 浏览器 ← 进入 Web3 应用
    ↓
区块链网络 ← 读写数据、发起交易
```

**核心职责**：
1. **安全管理私钥** - 离线存存储，不归中心化服务器
2. **提供钱包功能** - ETH/代币转账、余额查询
3. **DApp 网关** - 让网站能通过 injectWeb3 连接钱包
4. **多链支持** - 以太坊、BSC、Polygon、Arbitrum 等
5. **交易签名** - 对交易进行私钥签名

### 1.2 为什么用 React Native？

对于钱包类应用，React Native 的优势：

| 特性 | React Native | 原生开发 | Flutter |
|------|-------------|--------|---------|
| 开发速度 | 快（一套代码） | 慢（两套代码） | 中等（Dart学习曲线） |
| 代码共享 | iOS/Android/Web | 不支持 | iOS/Android/Web |
| 性能 | 中等 | 最好 | 优秀 |
| 依赖库生态 | 最丰富 | 丰富 | 中等 |
| 团队学习成本 | 低（JS/TS） | 高（6种语言） | 中等（Dart） |
| Web3 库支持 | 最完整 | 一般 | 中等 |

MetaMask 团队是 Consensys 公司，Node.js/JavaScript 社区背景强，选择 React Native 自然而然。

---

## 2. 项目架构

### 2.1 目录结构

```
metamask-mobile/
├── app/                          # 应用核心代码
│   ├── core/                     # 核心业务逻辑
│   │   ├── Engine.ts             # 区块链引擎（最重要！）
│   │   ├── AppState.ts           # 应用全局状态
│   │   └── NotificationManager.ts # 通知系统
│   │
│   ├── components/               # React 组件
│   │   ├── Views/                # 页面级组件
│   │   │   ├── Wallet/           # 钱包页面
│   │   │   ├── Browser/          # DApp 浏览器
│   │   │   ├── Send/             # 发送交易
│   │   │   └── Settings/         # 设置
│   │   └── UI/                   # 通用 UI 组件
│   │
│   ├── actions/                  # Redux Actions
│   │   ├── wallet.ts             # 钱包 action
│   │   ├── transaction.ts        # 交易 action
│   │   └── network.ts            # 网络 action
│   │
│   ├── reducers/                 # Redux Reducers
│   │   ├── wallet.ts
│   │   ├── transaction.ts
│   │   └── engine.ts
│   │
│   ├── util/                     # 工具函数
│   │   ├── address.ts            # 地址处理
│   │   ├── number.ts             # 数字/余额处理
│   │   ├── keyManager.ts         # 私钥管理
│   │   └── gas.ts                # Gas 估算
│   │
│   └── store/                    # Redux Store
│       └── index.ts
│
├── android/                      # Android 原生代码
│   ├── app/                      # App 层
│   ├── keystoremanager/          # 密钥存储（Android Keystore）
│   └── build.gradle
│
├── ios/                          # iOS 原生代码
│   ├── MetaMask/
│   ├── KeychainManager/          # Keychain（iOS 密钥管理）
│   └── Podfile
│
└── docs/                         # 开发文档
```

### 2.2 核心模块解析

#### **Engine.js 模块**（最核心！）

MetaMask 的心脏是 `Engine.ts`，它暴露了一系列 RPC 方法供 DApp 调用：

```typescript
// app/core/Engine.ts（简化版）
export class Engine {
  private providerEngine;      // JSON-RPC 提供者
  private accountsController;  // 账户管理
  private networkController;   // 网络切换
  private txController;        // 交易管理

  // DApp 通过这些方法和钱包交互
  async eth_requestAccounts() { }       // 请求授权账户
  async eth_sendTransaction(tx) { }     // 发送交易
  async personal_sign(msg) { }          // 签名消息
  async wallet_switchEthereumChain() {} // 切换网络

  // 内部方法
  private async signTransaction(tx) { }  // 使用私钥签名
  private async broadcastTx(signed) { }  // 广播交易
}
```

#### **Wallet Store（Redux）**

钱包状态管理：

```typescript
// app/reducers/wallet.ts
interface WalletState {
  accounts: string[];              // 用户地址列表
  selectedAddress: string;         // 当前选中的地址
  identities: {                    // 地址到账户的映射
    [address: string]: {
      name: string;               // 账户别名
      address: string;
    }
  };
  keyrings: any[];                 // 密钥管理器
  seedphraseBackedUp: boolean;    // 是否备份过助记词
}
```

#### **KeyManager（私钥存储）**

最敏感的部分 - 如何安全存储：

```
用户的私钥
    ↓
AES-256 加密
    ↓
存储位置：
  - Android：Android Keystore（由系统加密）
  - iOS：Keychain（由系统加密）
  - 同步：iCloud Keychain（可选）
```

**关键点**：
- 私钥**永远不会通过网络传输**
- 每次签名都在本地进行
- 支持 HD 钱包（BIP-44 派生）

---

## 3. 工作流程

### 3.1 用户启动应用流程

```
┌─────────────────┐
│ 打开应用        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 检查本地存储    │ ← 检查是否有备份的加密钥匙
└────────┬────────┘
         │
    ┌────┴────┐
    │          │
    ▼          ▼
有钱包      无钱包
  │           │
  │           ▼
  │      ┌────────────────┐
  │      │ 导入或创建钱包  │
  │      │ - 导入助记词    │
  │      │ - 导入私钥      │
  │      │ - 创建新钱包    │
  │      └────────┬────────┘
  │               │
  │      ┌────────▼────────┐
  │      │ 派生账户地址     │ ← BIP-44
  │      │ m/44'/60'/0'/0/n │
  │      └────────┬────────┘
  │               │
  ├───────────────┤
  │               │
  ▼               ▼
┌─────────────────────────────┐
│ 初始化 Engine               │
│ - 连接 RPC 节点             │
│ - 启动账户控制器            │
│ - 加载交易历史              │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ 显示钱包首页                │
│ - 显示账户地址和余额        │
│ - 显示最近交易              │
└─────────────────────────────┘
```

### 3.2 用户发送交易流程

```
1️⃣ 用户点击"发送"
   ↓
2️⃣ 输入接收地址和金额
   ↓
3️⃣ MetaMask 本地验证
   - 地址有效性
   - 金额不超过余额
   ↓
4️⃣ 构造交易对象
   {
     from: 0x...,           // 从地址
     to: 0x...,             // 接收地址
     value: 100000...,      // 金额（Wei）
     data: 0x...,           // 合约调用数据（如果有）
     gasLimit: 21000,       // Gas 限额
     gasPrice: 50 Gwei,     // Gas 价格
   }
   ↓
5️⃣ 估算 Gas（调用 eth_estimateGas）
   ↓
6️⃣ 显示确认界面
   - 显示接收地址、金额、Gas 费用
   - 用户审核后点击"确认"
   ↓
7️⃣ 使用私钥签名交易
   signature = sign(tx 哈希, 私钥)
   ↓
8️⃣ 组装签名交易并发送
   eth_sendRawTransaction(signedTx)
   ↓
9️⃣ 返回交易哈希给用户
   ↓
🔟 后台轮询 getTransactionReceipt
   检查交易是否已确认
   ↓
1️⃣1️⃣ 确认完成，更新 UI
```

### 3.3 DApp 浏览器流程

```
┌────────────────┐
│ 用户打开 DApp   │
│ (如 Uniswap)   │
└────────┬───────┘
         │
         ▼
┌────────────────────────────┐
│ MetaMask 将 Engine 注入      │
│ 到网页的 window.ethereum    │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ 网页代码调用：              │
│ window.ethereum.request({   │
│   method: 'eth_requestAccounts'
│ })                         │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ MetaMask 显示确认对话框    │
│ "MetaMask 想要连接到此网站" │
└────────┬───────────────────┘
         │
         ▼
        用户授权
         │
         ▼
┌────────────────────────────┐
│ 返回账户地址给网页         │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ 网页显示已连接状态         │
│ 可以调用更多 RPC 方法：    │
│ - eth_getBalance           │
│ - eth_sendTransaction      │
│ - personal_sign            │
│ - 智能合约交互             │
└────────────────────────────┘
```

---

## 4. 核心技术细节

### 4.1 私钥保管机制

```
┌────────────────────────────────────────┐
│ 用户输入密码                           │
└────────┬─────────────────────────────┘
         │
         ▼ PBKDF2 或 scrypt 派生
┌────────────────────────────────────────┐
│ 加密密钥                               │
└────────┬─────────────────────────────┘
         │
         ▼ AES-256-GCM 加密
┌────────────────────────────────────────┐
│ 加密的私钥                             │
└────────┬─────────────────────────────┘
         │
         ▼ 存储在本地
┌────────────────────────────────────────┐
│ Android Keystore / iOS Keychain        │
│ （系统级硬件加密）                     │
└────────────────────────────────────────┘
```

### 4.2 HD 钱包导出（BIP-44）

```
助记词（12 个英文单词）
    ↓
PBKDF2 哈希成 512 位 seed
    ↓
BIP-32：从 seed 生成主密钥
    ↓
BIP-44：派生多个账户
    │
    ├─ m/44'/60'/0'/0/0 → 账户 1
    ├─ m/44'/60'/0'/0/1 → 账户 2
    └─ m/44'/60'/0'/0/2 → 账户 3

其中：
  44'  = BIP-44 标准
  60'  = 以太坊的 coin_type
  0'   = 账户索引
  0    = 链
  0-∞  = 地址索引
```

### 4.3 RPC 节点连接

```typescript
// 支持多种 RPC 提供者
interface RpcProvider {
  name: string;
  url: string;
  chainId: number;
}

// MetaMask 支持的节点服务
const providers = [
  { name: 'Infura', url: 'https://mainnet.infura.io/v3/<KEY>' },
  { name: 'Alchemy', url: 'https://eth-mainnet.g.alchemy.com/v2/<KEY>' },
  { name: '本地节点', url: 'http://localhost:8545' },
];

// 用户也可以自定义 RPC 节点
```

---

## 5. 交互模式设计

### 5.1 三种交互方式

#### ✅ 方式一：Native 钱包功能
```
用户在 MetaMask 应用内：
- 查看余额
- 查看交易历史
- 编辑账户
- 发送代币
- 管理网络
```

#### ✅ 方式二：DApp 浏览器
```
用户在 MetaMask 内打开网站：
- 访问 Uniswap、OpenSea 等
- 网站自动连接到 MetaMask
- 通过 window.ethereum 调用钱包功能
```

#### ✅ 方式三：跨应用集成 (WalletConnect)
```
外部应用（如 DEX）调用 MetaMask：
- 用户扫码连接
- 交易由外部应用构造
- 由 MetaMask 签名后返回
```

### 5.2 权限管理（EIP-2255）

MetaMask 实现了细粒度权限控制：

```javascript
// 之前：DApp 连接后有所有权限 ❌ 不安全
// 现在：根据需要授予具体权限 ✅ 更安全

const requiredPermissions = [
  'eth_accounts',           // 只能读取地址，不能签名
  'wallet_switchEthereumChain', // 可以请求切换网络
];

// DApp 请求权限
wallet_requestPermissions(requiredPermissions)
```

---

## 6. 数据存储

### 6.1 本地存储结构

```
Android:
  /data/data/io.metamask/
  ├── shared_prefs/          # SharedPreferences（明文非敏感数据）
  ├── files/
  │   └── encrypted_data/    # 加密数据
  └── databases/
      └── keystore.db        # 加密的密钥信息

iOS:
  ~/Library/KeyChain/        # 系统 Keychain（强加密）
  ~/Documents/
  └── metamask_data/         # 用户数据（加密）
```

### 6.2 同步机制

```
iCloud Keychain：
  用户私钥可选同步到 iCloud
  但需要用户明确授权
  ↓
  同步加密：密钥在客户端加密后再上传
  ↓
  多设备：同一 Apple ID 下的多个设备可同步钱包
```

---

## 7. 学习价值 & 复刻建议

### 7.1 你应该学习什么

| 组件 | 学习价值 | 难度 |
|------|--------|------|
| **密钥管理** | 核心安全机制，适用所有钱包 | ⭐⭐⭐⭐⭐ |
| **交易栈** | 如何构造、签名、广播交易 | ⭐⭐⭐⭐ |
| **Engine 架构** | 如何设计可扩展的 RPC 引擎 | ⭐⭐⭐⭐ |
| **Redux 状态** | 大型应用的状态管理 | ⭐⭐⭐ |
| **DApp 浏览器** | Web3 集成难题 | ⭐⭐⭐⭐ |
| **权限系统** | 用户隐私和安全 | ⭐⭐⭐ |
| **多链支持** | 扩展性设计 | ⭐⭐⭐ |
| **Gas 优化** | 用户体验优化 | ⭐⭐ |

### 7.2 复刻时的注意点

✅ **Do（应该做）**：
- 学习其权限模型和安全架构
- 学习业界标准的密钥派生流程
- 学习交易构造和签名逻辑
- 学习多链切换设计

❌ **Don't（不应该做）**：
- 直接复制 MetaMask 的代码（有 License 限制）
- 使用相似的商标和名称
- 宣称自己是官方钱包
- 忽视安全审计

✅ **Best Practice（最佳实践）**：
- 创建自己的钱包品牌
- 进行安全审计（OpenZeppelin、Trail of Bits）
- 实现自动化测试
- 定期安全更新

---

## 8. 与 Flutter 钱包的对比

### 8.1 MetaMask Mobile vs Flutter Web3 钱包

| 特性 | MetaMask | Flutter 钱包 |
|------|---------|------------|
| 平台 | RN (iOS/Android) | Flutter (iOS/Android/Web/Desktop) |
| 编程语言 | TypeScript/JavaScript | Dart |
| 开发速度 | 快 | 中等 |
| 性能 | 中等（JS 执行） | 优秀（Native） |
| 热更新 | 可以（code push） | 困难 |
| DApp 浏览器 | 完整支持 | 支持但复杂 |
| 多链 | 支持 | 可实现 |
| 生态库 | 最丰富的 web3 库 | 中等 |

### 8.2 为什么用 Flutter 复刻？

```
MetaMask 优点：
  ✓ 使用人数最多
  ✓ 库生态最完整
  ✓ 文档最完善

Flutter 优点：
  ✓ 学习 Dart + Flutter 生态
  ✓ 跨平台能力更强（包括 Web/Desktop）
  ✓ 性能更好
  ✓ 适合教学演示
  ✓ 代码更简洁
```

---

## 9. 核心代码示例

### 9.1 Engine 核心逻辑（简化版）

```typescript
class Engine {
  private keyManager: KeyManager;
  private networkController: NetworkController;
  private txController: TransactionController;

  // DApp 调用的 RPC 方法
  async handleRequest(request: JSONRPCRequest): Promise<any> {
    const { method, params } = request;

    switch (method) {
      case 'eth_requestAccounts':
        // 用户授权，返回账户列表
        return await this.getAuthorizedAccounts();

      case 'eth_sendTransaction':
        // 构造、签名、发送交易
        const tx = params[0];
        const signedTx = await this.signTransaction(tx);
        return await this.broadcastTransaction(signedTx);

      case 'personal_sign':
        // 签名消息
        const message = params[0];
        const address = params[1];
        return await this.signMessage(message, address);

      case 'wallet_switchEthereumChain':
        // 切换网络
        const chainId = params[0].chainId;
        return await this.networkController.switchChain(chainId);

      default:
        // 其他 RPC 方法代理到节点
        return await this.rpcProxy(method, params);
    }
  }

  private async signTransaction(tx: Transaction): Promise<Uint8Array> {
    // 1. 获取私钥
    const privateKey = await this.keyManager.getPrivateKey(tx.from);

    // 2. 计算交易哈希
    const hash = keccak256(serializeTransaction(tx));

    // 3. 使用私钥签名
    const signature = sign(hash, privateKey);

    // 4. 返回完整的签名交易
    return serializeTransaction(tx, signature);
  }
}
```

### 9.2 Android 密钥存储

```kotlin
// android/keystoremanager/KeyStoreManager.kt
class KeyStoreManager {
    private val keyStore = KeyStore.getInstance("AndroidKeyStore")

    fun saveEncryptedKey(alias: String, key: ByteArray) {
        val keySpec = KeyGenParameterSpec.Builder(alias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
            .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
            // 可选：需要生物识别认证
            .setUserAuthenticationRequired(true)
            .build()

        val kpg = KeyPairGenerator.getInstance("RSA", "AndroidKeyStore")
        kpg.initialize(keySpec)
        kpg.generateKeyPair()

        // 用系统密钥加密用户的私钥
        val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
        cipher.init(Cipher.ENCRYPT_MODE, keyStore.getCertificate(alias).publicKey)
        val encryptedKey = cipher.doFinal(key)

        // 保存加密的密钥
        saveToPreferences(alias, encryptedKey)
    }

    fun getDecryptedKey(alias: String): ByteArray {
        val encryptedKey = readFromPreferences(alias)
        val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
        cipher.init(Cipher.DECRYPT_MODE, keyStore.getKey(alias, null))
        return cipher.doFinal(encryptedKey)
    }
}
```

---

## 10. 进阶阅读

### 📚 相关 EIP/标准

- **EIP-1193**: `provider.request()` 标准
- **EIP-1102**: 账户授权（`eth_requestAccounts`）
- **EIP-2255**: 权限管理系统
- **EIP-6963**: 多钱包支持标准
- **BIP-39**: 助记词标准
- **BIP-43, 44, 45**: HD 钱包派生标准
- **EIP-155**: 交易签名（chainId 防护）
- **EIP-712**: 结构化签名（改进用户体验）

### 🔗 参考资源

- MetaMask Docs: https://docs.metamask.io/
- Consensys Web3 学习路径
- Ethereum JSON-RPC 规范
- 《Mastering Ethereum》书籍
- sec3 安全审计报告

---

## 11. 核心思考题

1. **为什么 MetaMask 要在本地签名，而不是由服务器签名？**
   答：服务器签名意味着要上传私钥，私钥泄露就完全暴露。本地签名私钥永不离开设备。

2. **为什么需要多个账户派生（0/0, 0/1, 0/2...）？**
   答：用户可能有多个身份：工作账户、个人账户、alt 账户等，从同一个助记词派生多个账户更安全。

3. **DApp 连接时为什么要弹出确认对话框？**
   答：防止恶意网站偷偷读取你的地址和余额，强制用户确认是真正要授权的网站。

4. **为什么交易发送后还要轮询 receipt？**
   答：交易发送（broadcast）和交易确认（mined）是两回事。轮询是为了告诉用户"交易已上链"。

5. **MetaMask 如何支持多条区块链？**
   答：维护多个 RPC 端点的映射表，用户切换网络时切换 RPC URL。

---

## 总结

MetaMask Mobile 是一个工业级别的 Web3 应用，其核心是：

```
安全的私钥管理 ← 最重要
    ↓
完整的交易栈（构造→签名→广播）
    ↓
灵活的 RPC 引擎（支持多链、多方法）
    ↓
透明的用户交互（每次签名都需要用户确认）
    ↓
健壮的 DApp 集成（Web3 Provider）
```

下一步，让我们用 Flutter 从零开始复刻这个架构！

