# 第 8 章：Web3 前端交互 — 从浏览器连接区块链

> 这一章是很多新手最想学的内容：怎么在网页里连接 MetaMask？怎么用 JavaScript 读取链上数据？怎么发起一笔交易？我们从最基础的 HTML 页面开始，一步步讲透 web3.js、ethers.js、MetaMask 交互的每一个细节。

## 8.1 先搞清楚：DApp 前端到底在干什么？

传统 Web 应用和 Web3 DApp 的区别：

```
传统 Web 应用:
┌──────────┐     HTTP      ┌──────────┐     SQL      ┌──────────┐
│  浏览器   │ ──────────→  │  后端服务  │ ──────────→ │  数据库   │
│ (React)  │ ←────────── │ (Node.js) │ ←────────── │ (MySQL)  │
└──────────┘              └──────────┘              └──────────┘

Web3 DApp:
┌──────────┐    JSON-RPC    ┌──────────────┐
│  浏览器   │ ──────────→   │  区块链节点    │
│ (React)  │ ←──────────   │ (Ethereum)   │
│ + 钱包   │               └──────────────┘
└──────────┘                      ↑
      │                           │
      │    签名请求                │ 读写合约
      ▼                           │
┌──────────┐              ┌──────────────┐
│ MetaMask │              │  智能合约     │
│  钱包    │              │ (Solidity)   │
└──────────┘              └──────────────┘
```

关键区别：
- 传统应用：用户名密码登录 → 后端验证 → 操作数据库
- Web3 DApp：钱包签名登录 → 直接和区块链交互 → 数据存在链上

### 你需要理解的核心概念

1. **Provider（提供者）**：连接区块链的通道，负责发送请求和接收响应
2. **Signer（签名者）**：能签名交易的对象，通常是钱包（MetaMask）
3. **Contract（合约）**：链上的智能合约，通过 ABI 描述它有哪些方法
4. **ABI（应用二进制接口）**：合约的"说明书"，告诉前端合约有哪些函数、参数、返回值

```
你的 DApp 代码
      │
      │ 使用 ethers.js / web3.js
      ▼
┌─────────────┐
│  Provider   │ ← 只能读取数据（查余额、读合约）
│  (只读)     │
└─────────────┘
      │
      │ 需要签名时
      ▼
┌─────────────┐
│   Signer    │ ← 可以签名交易（转账、调用合约写入方法）
│  (MetaMask) │
└─────────────┘
      │
      │ 通过 ABI 调用
      ▼
┌─────────────┐
│  Contract   │ ← 链上的智能合约
│  (链上)     │
└─────────────┘
```

## 8.2 MetaMask 是什么？为什么需要它？

MetaMask 是一个浏览器插件钱包，它做了三件事：

1. **管理你的私钥**：安全地存储在浏览器中，不会暴露给网站
2. **提供 Provider**：让网页可以通过它连接区块链
3. **签名交易**：当网站请求发送交易时，弹出确认窗口让你审核

### 安装 MetaMask

1. 打开 [metamask.io](https://metamask.io/)
2. 安装 Chrome/Firefox 插件
3. 创建新钱包（记住助记词！）
4. 切换到测试网络：设置 → 网络 → 显示测试网络 → 选择 Sepolia

### 获取测试 ETH

去水龙头（Faucet）领取免费的测试 ETH：
- [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)
- [Infura Sepolia Faucet](https://www.infura.io/faucet/sepolia)

### MetaMask 注入了什么？

当你安装了 MetaMask，它会在浏览器的 `window` 对象上注入一个 `ethereum` 对象：

```javascript
// 打开浏览器控制台（F12），输入：
console.log(window.ethereum)
// 如果安装了 MetaMask，会输出一个对象
// 如果没安装，输出 undefined
```

这个 `window.ethereum` 就是 MetaMask 提供的 Provider，它遵循 [EIP-1193](https://eips.ethereum.org/EIPS/eip-1193) 标准。

## 8.3 纯 JavaScript + MetaMask（不用任何库）

在用 ethers.js 之前，我们先用最原始的方式和 MetaMask 交互，这样你能理解底层到底发生了什么。

### 创建一个最简单的 DApp 页面

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的第一个 DApp</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background: #1a1a2e;
            color: #eee;
        }
        button {
            background: #e94560;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            margin: 5px;
        }
        button:hover { background: #c73e54; }
        button:disabled { background: #555; cursor: not-allowed; }
        .card {
            background: #16213e;
            border-radius: 12px;
            padding: 20px;
            margin: 15px 0;
        }
        .address { font-family: monospace; word-break: break-all; color: #0f3460; }
        #status { padding: 10px; border-radius: 8px; margin: 10px 0; }
        .connected { background: #1b4332; color: #95d5b2; }
        .disconnected { background: #3d0000; color: #ff6b6b; }
    </style>
</head>
<body>
    <h1>🦊 我的第一个 DApp</h1>

    <div id="status" class="disconnected">❌ 未连接钱包</div>

    <div class="card">
        <h3>1. 连接钱包</h3>
        <button id="connectBtn" onclick="connectWallet()">连接 MetaMask</button>
        <p>地址: <span id="account">-</span></p>
        <p>网络: <span id="network">-</span></p>
    </div>

    <div class="card">
        <h3>2. 查询余额</h3>
        <button onclick="getBalance()" id="balanceBtn" disabled>查询 ETH 余额</button>
        <p>余额: <span id="balance">-</span></p>
    </div>

    <div class="card">
        <h3>3. 查询区块</h3>
        <button onclick="getBlockNumber()" id="blockBtn" disabled>获取最新区块号</button>
        <p>区块号: <span id="blockNumber">-</span></p>
    </div>

    <div class="card">
        <h3>4. 签名消息</h3>
        <input type="text" id="messageInput" placeholder="输入要签名的消息"
               style="width:100%;padding:10px;border-radius:8px;border:1px solid #333;background:#0f3460;color:#eee;box-sizing:border-box;">
        <br><br>
        <button onclick="signMessage()" id="signBtn" disabled>签名</button>
        <p style="word-break:break-all;">签名结果: <span id="signature">-</span></p>
    </div>

    <div class="card">
        <h3>5. 发送 ETH</h3>
        <input type="text" id="toAddress" placeholder="接收地址 0x..."
               style="width:100%;padding:10px;border-radius:8px;border:1px solid #333;background:#0f3460;color:#eee;box-sizing:border-box;margin-bottom:10px;">
        <input type="text" id="sendAmount" placeholder="金额 (ETH)"
               style="width:100%;padding:10px;border-radius:8px;border:1px solid #333;background:#0f3460;color:#eee;box-sizing:border-box;">
        <br><br>
        <button onclick="sendETH()" id="sendBtn" disabled>发送</button>
        <p style="word-break:break-all;">交易哈希: <span id="txHash">-</span></p>
    </div>

    <script>
    // ============================================================
    // 全局变量
    // ============================================================
    let currentAccount = null;

    // ============================================================
    // 检查 MetaMask 是否安装
    // ============================================================
    function checkMetaMask() {
        if (typeof window.ethereum === 'undefined') {
            alert('请先安装 MetaMask 插件！\nhttps://metamask.io/');
            return false;
        }
        return true;
    }

    // ============================================================
    // 1. 连接钱包
    // ============================================================
    async function connectWallet() {
        if (!checkMetaMask()) return;

        try {
            // eth_requestAccounts 会弹出 MetaMask 授权窗口
            // 用户点击"连接"后，返回授权的地址数组
            const accounts = await window.ethereum.request({
                method: 'eth_requestAccounts'
            });

            currentAccount = accounts[0];
            document.getElementById('account').textContent = currentAccount;

            // 获取当前网络
            const chainId = await window.ethereum.request({
                method: 'eth_chainId'
            });
            const networkName = getNetworkName(chainId);
            document.getElementById('network').textContent =
                `${networkName} (Chain ID: ${parseInt(chainId, 16)})`;

            // 更新 UI 状态
            document.getElementById('status').textContent = '✅ 已连接';
            document.getElementById('status').className = 'connected';
            document.getElementById('connectBtn').textContent = '已连接 ✓';

            // 启用其他按钮
            document.getElementById('balanceBtn').disabled = false;
            document.getElementById('blockBtn').disabled = false;
            document.getElementById('signBtn').disabled = false;
            document.getElementById('sendBtn').disabled = false;

            console.log('已连接账户:', currentAccount);
            console.log('网络:', networkName);

        } catch (error) {
            // 用户拒绝连接
            if (error.code === 4001) {
                console.log('用户拒绝了连接请求');
            } else {
                console.error('连接失败:', error);
            }
        }
    }

    // ============================================================
    // 2. 查询 ETH 余额
    // ============================================================
    async function getBalance() {
        if (!currentAccount) return;

        try {
            // eth_getBalance 返回的是十六进制的 Wei 值
            const balanceHex = await window.ethereum.request({
                method: 'eth_getBalance',
                params: [currentAccount, 'latest']
            });

            // 将十六进制 Wei 转换为 ETH
            const balanceWei = parseInt(balanceHex, 16);
            const balanceETH = balanceWei / 1e18;

            document.getElementById('balance').textContent =
                `${balanceETH.toFixed(6)} ETH (${balanceWei} Wei)`;

        } catch (error) {
            console.error('查询余额失败:', error);
        }
    }

    // ============================================================
    // 3. 获取最新区块号
    // ============================================================
    async function getBlockNumber() {
        try {
            const blockHex = await window.ethereum.request({
                method: 'eth_blockNumber'
            });
            const blockNumber = parseInt(blockHex, 16);
            document.getElementById('blockNumber').textContent = blockNumber;
        } catch (error) {
            console.error('获取区块号失败:', error);
        }
    }

    // ============================================================
    // 4. 签名消息（不需要 Gas，不上链）
    // ============================================================
    async function signMessage() {
        if (!currentAccount) return;

        const message = document.getElementById('messageInput').value;
        if (!message) {
            alert('请输入要签名的消息');
            return;
        }

        try {
            // personal_sign 会弹出 MetaMask 签名窗口
            // 用户可以看到要签名的消息内容
            const signature = await window.ethereum.request({
                method: 'personal_sign',
                params: [message, currentAccount]
            });

            document.getElementById('signature').textContent = signature;
            console.log('签名结果:', signature);

            // 签名的用途：
            // 1. 登录验证（后端验证签名来确认身份）
            // 2. 链下订单签名（如 OpenSea 的挂单）
            // 3. 投票签名

        } catch (error) {
            if (error.code === 4001) {
                console.log('用户拒绝签名');
            } else {
                console.error('签名失败:', error);
            }
        }
    }

    // ============================================================
    // 5. 发送 ETH 转账
    // ============================================================
    async function sendETH() {
        if (!currentAccount) return;

        const to = document.getElementById('toAddress').value;
        const amountETH = document.getElementById('sendAmount').value;

        if (!to || !amountETH) {
            alert('请填写接收地址和金额');
            return;
        }

        try {
            // 将 ETH 转换为 Wei（十六进制）
            const amountWei = BigInt(Math.floor(parseFloat(amountETH) * 1e18));
            const amountHex = '0x' + amountWei.toString(16);

            // eth_sendTransaction 会弹出 MetaMask 确认窗口
            // 用户可以看到转账金额、Gas 费用等信息
            const txHash = await window.ethereum.request({
                method: 'eth_sendTransaction',
                params: [{
                    from: currentAccount,
                    to: to,
                    value: amountHex,
                    // gas 和 gasPrice 可以不填，MetaMask 会自动估算
                }]
            });

            document.getElementById('txHash').textContent = txHash;
            console.log('交易已发送:', txHash);

            // 注意：txHash 返回不代表交易已确认！
            // 交易还在 mempool 中等待被打包
            // 需要等待区块确认

        } catch (error) {
            if (error.code === 4001) {
                console.log('用户拒绝了交易');
            } else {
                console.error('发送失败:', error);
                alert('发送失败: ' + error.message);
            }
        }
    }

    // ============================================================
    // 监听事件
    // ============================================================

    if (window.ethereum) {
        // 监听账户切换
        window.ethereum.on('accountsChanged', (accounts) => {
            if (accounts.length === 0) {
                // 用户断开了连接
                currentAccount = null;
                document.getElementById('status').textContent = '❌ 已断开';
                document.getElementById('status').className = 'disconnected';
            } else {
                currentAccount = accounts[0];
                document.getElementById('account').textContent = currentAccount;
                console.log('账户已切换:', currentAccount);
                getBalance(); // 自动刷新余额
            }
        });

        // 监听网络切换
        window.ethereum.on('chainChanged', (chainId) => {
            const networkName = getNetworkName(chainId);
            document.getElementById('network').textContent =
                `${networkName} (Chain ID: ${parseInt(chainId, 16)})`;
            console.log('网络已切换:', networkName);
            // 网络切换后建议刷新页面
            // window.location.reload();
        });
    }

    // ============================================================
    // 工具函数
    // ============================================================
    function getNetworkName(chainId) {
        const networks = {
            '0x1': 'Ethereum 主网',
            '0xaa36a7': 'Sepolia 测试网',
            '0x38': 'BSC 主网',
            '0x89': 'Polygon 主网',
            '0xa4b1': 'Arbitrum One',
            '0xa': 'Optimism',
            '0x2105': 'Base',
        };
        return networks[chainId] || `未知网络 (${chainId})`;
    }
    </script>
</body>
</html>
```

::: tip 动手试试
把上面的代码保存为 `index.html`，直接用浏览器打开就能用。不需要任何构建工具、不需要 npm、不需要 Node.js。这就是 Web3 前端的魅力——你的代码直接和区块链对话。
:::

### 底层发生了什么？

当你点击"连接 MetaMask"时：

```
你的网页代码                    MetaMask 插件                以太坊节点
     │                              │                          │
     │ eth_requestAccounts          │                          │
     │ ──────────────────────────→  │                          │
     │                              │ 弹出授权窗口              │
     │                              │ 用户点击"连接"            │
     │ 返回 [地址数组]              │                          │
     │ ←──────────────────────────  │                          │
     │                              │                          │
     │ eth_getBalance               │                          │
     │ ──────────────────────────→  │ JSON-RPC 请求            │
     │                              │ ──────────────────────→  │
     │                              │ 返回余额                 │
     │                              │ ←──────────────────────  │
     │ 返回余额                     │                          │
     │ ←──────────────────────────  │                          │
     │                              │                          │
     │ eth_sendTransaction          │                          │
     │ ──────────────────────────→  │                          │
     │                              │ 弹出确认窗口              │
     │                              │ 显示金额、Gas 费用        │
     │                              │ 用户点击"确认"            │
     │                              │ 用私钥签名交易            │
     │                              │ 发送签名后的交易          │
     │                              │ ──────────────────────→  │
     │                              │ 返回交易哈希              │
     │                              │ ←──────────────────────  │
     │ 返回交易哈希                  │                          │
     │ ←──────────────────────────  │                          │
```

::: warning 重要安全原则
你的网页代码永远接触不到用户的私钥！所有签名操作都在 MetaMask 内部完成。这就是为什么 Web3 比传统 Web 更安全——网站无法偷走你的密码，因为密码（私钥）根本不在网站手里。
:::

## 8.4 ethers.js — 现代 Web3 前端首选库

直接用 `window.ethereum` 太底层了，实际开发中我们用 ethers.js（或 web3.js）来简化操作。

### ethers.js vs web3.js 对比

| 特性 | ethers.js v6 | web3.js v4 |
|------|-------------|------------|
| 包大小 | ~120KB (压缩后) | ~590KB (压缩后) |
| API 设计 | Provider/Signer 分离，更清晰 | 单一 web3 对象，较臃肿 |
| TypeScript | 原生支持 | v4 开始支持 |
| 社区趋势 | 新项目首选，增长快 | 老牌库，存量项目多 |
| 维护者 | Richard Moore (个人) | ChainSafe (团队) |
| 推荐度 | ⭐⭐⭐⭐⭐ 新项目首选 | ⭐⭐⭐ 维护老项目用 |

本教程两个都讲，但以 ethers.js 为主。

### 安装 ethers.js

```bash
# npm 项目中
npm install ethers

# 或者直接在 HTML 中用 CDN
# <script src="https://cdn.ethers.io/lib/ethers-6.min.js"></script>
```

### ethers.js 核心概念图解

```
ethers.js 架构
│
├── Provider（提供者）— 只读，连接区块链
│   ├── BrowserProvider    ← 包装 MetaMask 的 window.ethereum
│   ├── JsonRpcProvider    ← 直接连接 RPC 节点
│   ├── InfuraProvider     ← 连接 Infura 服务
│   └── AlchemyProvider    ← 连接 Alchemy 服务
│
├── Signer（签名者）— 可签名，代表一个账户
│   ├── Wallet             ← 用私钥创建（后端/脚本用）
│   └── BrowserProvider.getSigner() ← 从 MetaMask 获取
│
├── Contract（合约）— 与智能合约交互
│   ├── new Contract(address, abi, provider)  ← 只读
│   └── new Contract(address, abi, signer)    ← 可读写
│
└── 工具函数
    ├── parseEther("1.0")     → 1000000000000000000n (BigInt)
    ├── formatEther(wei)      → "1.0" (字符串)
    ├── parseUnits("1.0", 6)  → 1000000n (USDT 6位精度)
    ├── formatUnits(val, 6)   → "1.0"
    ├── id("Transfer(address,address,uint256)")  → 事件签名哈希
    └── keccak256(data)       → 哈希值
```

### 完整示例：用 ethers.js 重写上面的 DApp

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>ethers.js DApp 示例</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ethers/6.9.0/ethers.umd.min.js"></script>
    <style>
        body { font-family: sans-serif; max-width: 700px; margin: 40px auto; padding: 20px; }
        .card { border: 1px solid #ddd; border-radius: 12px; padding: 20px; margin: 15px 0; }
        button { background: #5865F2; color: white; border: none; padding: 10px 20px;
                 border-radius: 8px; cursor: pointer; font-size: 14px; }
        button:hover { background: #4752C4; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 4px; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 8px; overflow-x: auto; }
        .mono { font-family: monospace; word-break: break-all; }
        input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px;
                box-sizing: border-box; margin: 5px 0; }
    </style>
</head>
<body>
    <h1>ethers.js v6 完整示例</h1>

    <div class="card">
        <h3>🔗 连接钱包</h3>
        <button onclick="connect()">连接 MetaMask</button>
        <p>地址: <span id="addr" class="mono">-</span></p>
        <p>余额: <span id="bal">-</span></p>
        <p>网络: <span id="net">-</span></p>
    </div>

    <div class="card">
        <h3>📖 读取 ERC-20 代币信息</h3>
        <input id="tokenAddr" placeholder="代币合约地址 (试试 USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7)">
        <button onclick="readToken()">查询代币</button>
        <div id="tokenInfo"></div>
    </div>

    <div class="card">
        <h3>💸 发送 ETH</h3>
        <input id="sendTo" placeholder="接收地址">
        <input id="sendVal" placeholder="金额 (ETH)">
        <button onclick="send()">发送</button>
        <p class="mono" id="txResult"></p>
    </div>

    <div class="card">
        <h3>📝 调用合约写入方法（ERC-20 Transfer）</h3>
        <input id="transferToken" placeholder="代币合约地址">
        <input id="transferTo" placeholder="接收地址">
        <input id="transferAmt" placeholder="金额 (代币单位，如 100)">
        <button onclick="transferToken()">转账代币</button>
        <p class="mono" id="transferResult"></p>
    </div>

    <div class="card">
        <h3>👂 监听链上事件</h3>
        <input id="listenAddr" placeholder="监听的合约地址">
        <button onclick="listenEvents()">开始监听 Transfer 事件</button>
        <button onclick="stopListening()">停止</button>
        <div id="events" style="max-height:200px;overflow-y:auto;"></div>
    </div>

<script>
// ============================================================
// 全局变量
// ============================================================
let provider;   // ethers.BrowserProvider
let signer;     // 签名者（MetaMask 账户）
let contract;   // 当前监听的合约

// ============================================================
// 连接钱包
// ============================================================
async function connect() {
    if (!window.ethereum) {
        alert('请安装 MetaMask!');
        return;
    }

    try {
        // BrowserProvider 包装了 MetaMask 的 window.ethereum
        provider = new ethers.BrowserProvider(window.ethereum);

        // 请求用户授权（弹出 MetaMask 窗口）
        signer = await provider.getSigner();

        // 获取地址
        const address = await signer.getAddress();
        document.getElementById('addr').textContent = address;

        // 获取余额
        const balance = await provider.getBalance(address);
        // ethers.formatEther 自动将 Wei 转换为 ETH 字符串
        document.getElementById('bal').textContent =
            ethers.formatEther(balance) + ' ETH';

        // 获取网络信息
        const network = await provider.getNetwork();
        document.getElementById('net').textContent =
            `${network.name} (Chain ID: ${network.chainId})`;

        console.log('✅ 连接成功');
        console.log('地址:', address);
        console.log('余额:', ethers.formatEther(balance), 'ETH');

    } catch (err) {
        console.error('连接失败:', err);
    }
}

// ============================================================
// 读取 ERC-20 代币信息（只读操作，不需要签名）
// ============================================================
async function readToken() {
    if (!provider) { alert('请先连接钱包'); return; }

    const tokenAddress = document.getElementById('tokenAddr').value;
    if (!tokenAddress) { alert('请输入代币地址'); return; }

    // ERC-20 标准 ABI（只需要你要调用的方法）
    const erc20ABI = [
        // 只读方法
        "function name() view returns (string)",
        "function symbol() view returns (string)",
        "function decimals() view returns (uint8)",
        "function totalSupply() view returns (uint256)",
        "function balanceOf(address account) view returns (uint256)",
        // 写入方法
        "function transfer(address to, uint256 amount) returns (bool)",
        "function approve(address spender, uint256 amount) returns (bool)",
        // 事件
        "event Transfer(address indexed from, address indexed to, uint256 value)",
        "event Approval(address indexed owner, address indexed spender, uint256 value)",
    ];

    try {
        // 创建合约实例（用 provider = 只读）
        const token = new ethers.Contract(tokenAddress, erc20ABI, provider);

        // 调用只读方法（不需要 Gas，不需要签名）
        const [name, symbol, decimals, totalSupply] = await Promise.all([
            token.name(),
            token.symbol(),
            token.decimals(),
            token.totalSupply(),
        ]);

        // 查询当前用户的代币余额
        const myAddress = await signer.getAddress();
        const myBalance = await token.balanceOf(myAddress);

        document.getElementById('tokenInfo').innerHTML = `
            <pre>
代币名称: ${name}
代币符号: ${symbol}
精度: ${decimals}
总供应量: ${ethers.formatUnits(totalSupply, decimals)} ${symbol}
我的余额: ${ethers.formatUnits(myBalance, decimals)} ${symbol}
            </pre>
        `;

    } catch (err) {
        document.getElementById('tokenInfo').innerHTML =
            `<p style="color:red">查询失败: ${err.message}</p>`;
    }
}

// ============================================================
// 发送 ETH
// ============================================================
async function send() {
    if (!signer) { alert('请先连接钱包'); return; }

    const to = document.getElementById('sendTo').value;
    const value = document.getElementById('sendVal').value;

    try {
        document.getElementById('txResult').textContent = '⏳ 发送中...';

        // signer.sendTransaction 会弹出 MetaMask 确认窗口
        const tx = await signer.sendTransaction({
            to: to,
            value: ethers.parseEther(value), // "0.01" → 10000000000000000n
        });

        document.getElementById('txResult').textContent =
            `📤 已发送! TX: ${tx.hash}\n⏳ 等待确认...`;

        // 等待交易被打包确认（1 个区块确认）
        const receipt = await tx.wait(1);

        document.getElementById('txResult').textContent =
            `✅ 已确认! 区块: ${receipt.blockNumber}, Gas: ${receipt.gasUsed}`;

        // 刷新余额
        const balance = await provider.getBalance(await signer.getAddress());
        document.getElementById('bal').textContent =
            ethers.formatEther(balance) + ' ETH';

    } catch (err) {
        document.getElementById('txResult').textContent = `❌ 失败: ${err.message}`;
    }
}

// ============================================================
// ERC-20 代币转账（合约写入操作）
// ============================================================
async function transferToken() {
    if (!signer) { alert('请先连接钱包'); return; }

    const tokenAddr = document.getElementById('transferToken').value;
    const to = document.getElementById('transferTo').value;
    const amount = document.getElementById('transferAmt').value;

    const erc20ABI = [
        "function transfer(address to, uint256 amount) returns (bool)",
        "function decimals() view returns (uint8)",
    ];

    try {
        // 用 signer 创建合约实例（可读写）
        const token = new ethers.Contract(tokenAddr, erc20ABI, signer);

        // 获取精度
        const decimals = await token.decimals();

        // 将人类可读的金额转换为链上的最小单位
        // 例如 USDT: "100" → 100000000n (6位精度)
        const amountWei = ethers.parseUnits(amount, decimals);

        document.getElementById('transferResult').textContent = '⏳ 发送中...';

        // 调用合约的 transfer 方法
        // 这会弹出 MetaMask 确认窗口
        const tx = await token.transfer(to, amountWei);

        document.getElementById('transferResult').textContent =
            `📤 TX: ${tx.hash}\n⏳ 等待确认...`;

        const receipt = await tx.wait(1);

        document.getElementById('transferResult').textContent =
            `✅ 转账成功! 区块: ${receipt.blockNumber}`;

    } catch (err) {
        document.getElementById('transferResult').textContent = `❌ ${err.message}`;
    }
}

// ============================================================
// 监听链上事件
// ============================================================
async function listenEvents() {
    if (!provider) { alert('请先连接钱包'); return; }

    const addr = document.getElementById('listenAddr').value;
    if (!addr) { alert('请输入合约地址'); return; }

    const abi = [
        "event Transfer(address indexed from, address indexed to, uint256 value)"
    ];

    contract = new ethers.Contract(addr, abi, provider);

    document.getElementById('events').innerHTML = '<p>🔍 监听中...</p>';

    // 监听 Transfer 事件
    contract.on("Transfer", (from, to, value, event) => {
        const div = document.getElementById('events');
        const item = document.createElement('p');
        item.style.borderBottom = '1px solid #eee';
        item.style.padding = '5px 0';
        item.style.fontSize = '12px';
        item.innerHTML = `
            <b>Transfer</b><br>
            From: ${from.slice(0,8)}...${from.slice(-4)}<br>
            To: ${to.slice(0,8)}...${to.slice(-4)}<br>
            Value: ${value.toString()}<br>
            Block: ${event.log.blockNumber}
        `;
        div.prepend(item);
    });
}

function stopListening() {
    if (contract) {
        contract.removeAllListeners();
        document.getElementById('events').innerHTML += '<p>⏹ 已停止监听</p>';
    }
}
</script>
</body>
</html>
```

::: tip ethers.js v6 的关键变化
如果你看到网上的旧教程用 `ethers.providers.Web3Provider`，那是 v5 的写法。v6 改成了 `ethers.BrowserProvider`。主要变化：
- `ethers.providers.Web3Provider` → `ethers.BrowserProvider`
- `ethers.utils.parseEther` → `ethers.parseEther`
- `ethers.utils.formatEther` → `ethers.formatEther`
- `BigNumber` → 原生 `BigInt`
:::

## 8.5 web3.js — 另一个主流选择

web3.js 是最早的以太坊 JavaScript 库，很多老项目在用。你需要会读它的代码。

```bash
npm install web3
```

### web3.js 核心用法对照

```javascript
import Web3 from 'web3';

// ============================================================
// 1. 连接（对比 ethers.js）
// ============================================================

// web3.js 方式
const web3 = new Web3(window.ethereum);
await window.ethereum.request({ method: 'eth_requestAccounts' });
const accounts = await web3.eth.getAccounts();
const myAddress = accounts[0];

// ethers.js 方式（对比）
// const provider = new ethers.BrowserProvider(window.ethereum);
// const signer = await provider.getSigner();
// const myAddress = await signer.getAddress();

// ============================================================
// 2. 查询余额
// ============================================================

// web3.js
const balanceWei = await web3.eth.getBalance(myAddress);
const balanceETH = web3.utils.fromWei(balanceWei, 'ether');
console.log(`余额: ${balanceETH} ETH`);

// ethers.js 对比
// const balance = await provider.getBalance(myAddress);
// console.log(ethers.formatEther(balance));

// ============================================================
// 3. 发送 ETH
// ============================================================

// web3.js
const tx = await web3.eth.sendTransaction({
    from: myAddress,
    to: '0x接收地址',
    value: web3.utils.toWei('0.01', 'ether'),
});
console.log('TX Hash:', tx.transactionHash);

// ethers.js 对比
// const tx = await signer.sendTransaction({
//     to: '0x接收地址',
//     value: ethers.parseEther('0.01'),
// });

// ============================================================
// 4. 合约交互
// ============================================================

// web3.js
const contract = new web3.eth.Contract(erc20ABI, tokenAddress);

// 只读调用
const name = await contract.methods.name().call();
const balance = await contract.methods.balanceOf(myAddress).call();

// 写入调用（发送交易）
const tx2 = await contract.methods.transfer(toAddress, amount).send({
    from: myAddress,
});

// ethers.js 对比
// const contract = new ethers.Contract(tokenAddress, erc20ABI, signer);
// const name = await contract.name();
// const tx = await contract.transfer(toAddress, amount);

// ============================================================
// 5. 事件监听
// ============================================================

// web3.js
contract.events.Transfer({
    filter: { from: myAddress }, // 可选：过滤条件
})
.on('data', (event) => {
    console.log('Transfer:', event.returnValues);
})
.on('error', console.error);

// ethers.js 对比
// contract.on("Transfer", (from, to, value) => { ... });

// ============================================================
// 6. 工具函数对比
// ============================================================

// 单位转换
web3.utils.toWei('1', 'ether');     // ethers.parseEther('1')
web3.utils.fromWei('1000000000000000000', 'ether'); // ethers.formatEther(...)

// 哈希
web3.utils.sha3('hello');           // ethers.keccak256(ethers.toUtf8Bytes('hello'))
web3.utils.keccak256('hello');      // 同上

// 地址校验
web3.utils.isAddress('0x...');      // ethers.isAddress('0x...')
web3.utils.toChecksumAddress('0x...'); // ethers.getAddress('0x...')

// ABI 编码
web3.eth.abi.encodeFunctionCall(abi, params);  // contract.interface.encodeFunctionData(...)
```

### 什么时候用 web3.js？

- 维护使用 web3.js 的老项目
- 团队已经熟悉 web3.js
- 需要 web3.js 特有的功能（如 `web3.eth.subscribe`）

### 什么时候用 ethers.js？

- 新项目（推荐）
- 需要更小的包体积
- 喜欢 Provider/Signer 分离的设计
- TypeScript 项目

## 8.6 不用 MetaMask 也能连接区块链

MetaMask 只是连接区块链的方式之一。你也可以直接连接 RPC 节点：

```javascript
// ============================================================
// 方式一：直接连接公共 RPC（只读，不能签名）
// ============================================================
const provider = new ethers.JsonRpcProvider('https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY');

// 可以读取数据
const blockNumber = await provider.getBlockNumber();
const balance = await provider.getBalance('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045');
console.log('Vitalik 余额:', ethers.formatEther(balance));

// ============================================================
// 方式二：用私钥创建 Wallet（可签名，用于后端脚本/机器人）
// ============================================================
const wallet = new ethers.Wallet('你的私钥', provider);

// 可以发送交易
const tx = await wallet.sendTransaction({
    to: '0x接收地址',
    value: ethers.parseEther('0.01'),
});

// ⚠️ 警告：永远不要在前端代码中硬编码私钥！
// 这种方式只用于：
// - 后端服务（Node.js）
// - 部署脚本
// - 自动化机器人

// ============================================================
// 方式三：WalletConnect（移动端钱包连接）
// ============================================================
// WalletConnect 让用户用手机钱包扫码连接
// 支持 MetaMask Mobile、Trust Wallet、Rainbow 等
// 后面 Flutter 章节会详细讲
```

## 8.7 ABI 详解 — 合约的"说明书"

ABI（Application Binary Interface）是前端和合约之间的桥梁。没有 ABI，前端不知道合约有哪些方法。

### ABI 从哪来？

```
方式一：编译合约时自动生成
  forge build → out/MyContract.sol/MyContract.json 里有 abi 字段

方式二：从 Etherscan 获取（已验证的合约）
  https://etherscan.io/address/0x合约地址#code → Contract ABI

方式三：手写（ethers.js 支持人类可读的 ABI）
  "function transfer(address to, uint256 amount) returns (bool)"
```

### ABI 的两种格式

```javascript
// 格式一：JSON ABI（标准格式，从编译器或 Etherscan 获取）
const jsonABI = [
    {
        "inputs": [
            { "name": "to", "type": "address" },
            { "name": "amount", "type": "uint256" }
        ],
        "name": "transfer",
        "outputs": [{ "name": "", "type": "bool" }],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            { "indexed": true, "name": "from", "type": "address" },
            { "indexed": true, "name": "to", "type": "address" },
            { "indexed": false, "name": "value", "type": "uint256" }
        ],
        "name": "Transfer",
        "type": "event"
    }
];

// 格式二：人类可读 ABI（ethers.js 独有，更简洁）
const humanABI = [
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function decimals() view returns (uint8)",
    "function totalSupply() view returns (uint256)",
    "function balanceOf(address) view returns (uint256)",
    "function transfer(address to, uint256 amount) returns (bool)",
    "function approve(address spender, uint256 amount) returns (bool)",
    "function allowance(address owner, address spender) view returns (uint256)",
    "event Transfer(address indexed from, address indexed to, uint256 value)",
    "event Approval(address indexed owner, address indexed spender, uint256 value)",
];

// 两种格式都可以用来创建 Contract 实例
const contract1 = new ethers.Contract(address, jsonABI, provider);
const contract2 = new ethers.Contract(address, humanABI, provider);
// 效果完全一样！
```

### 函数选择器（Function Selector）

当你调用 `contract.transfer(to, amount)` 时，ethers.js 在底层做了什么？

```javascript
// 1. 计算函数选择器 = keccak256("transfer(address,uint256)") 的前 4 字节
const selector = ethers.id("transfer(address,uint256)").slice(0, 10);
// selector = "0xa9059cbb"

// 2. ABI 编码参数
const encodedParams = ethers.AbiCoder.defaultAbiCoder().encode(
    ["address", "uint256"],
    ["0x接收地址", ethers.parseEther("100")]
);

// 3. 拼接成 calldata = selector + encodedParams
const calldata = selector + encodedParams.slice(2);

// 4. 发送交易，data 字段就是这个 calldata
const tx = await signer.sendTransaction({
    to: contractAddress,
    data: calldata,
});

// ethers.js 的 Contract 对象帮你自动完成了上面所有步骤！
// 你只需要写：
const tx2 = await contract.transfer("0x接收地址", ethers.parseEther("100"));
```

## 8.8 实战：与 Uniswap 合约交互

```javascript
// 查询 Uniswap V3 上 ETH/USDC 的价格
const { ethers } = require('ethers');

const provider = new ethers.JsonRpcProvider('https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY');

// Uniswap V3 Quoter 合约（用于查询价格，不需要签名）
const quoterAddress = '0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6';
const quoterABI = [
    `function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut)`
];

const quoter = new ethers.Contract(quoterAddress, quoterABI, provider);

// 代币地址
const WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
const USDC = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

async function getETHPrice() {
    try {
        // 查询 1 ETH 能换多少 USDC
        const amountIn = ethers.parseEther('1'); // 1 ETH
        const fee = 3000; // 0.3% 手续费池

        // 注意：quoteExactInputSingle 虽然标记为 external（不是 view），
        // 但我们用 callStatic 来模拟调用，不实际发送交易
        const amountOut = await quoter.quoteExactInputSingle.staticCall(
            WETH, USDC, fee, amountIn, 0
        );

        // USDC 精度是 6
        const price = ethers.formatUnits(amountOut, 6);
        console.log(`1 ETH = ${price} USDC`);

    } catch (err) {
        console.error('查询价格失败:', err.message);
    }
}

getETHPrice();
```

## 8.9 在 Flutter 中使用这些知识

前面讲的 web3.js / ethers.js 是 JavaScript 生态的。在 Flutter 中，我们用 Dart 的 `web3dart` 包来做同样的事情。概念完全一样：

| JavaScript (ethers.js) | Dart (web3dart) | 说明 |
|------------------------|-----------------|------|
| `new ethers.BrowserProvider(ethereum)` | `Web3Client(rpcUrl, httpClient)` | 创建 Provider |
| `provider.getBalance(addr)` | `client.getBalance(addr)` | 查询余额 |
| `new ethers.Contract(addr, abi, signer)` | `DeployedContract(abi, addr)` | 创建合约实例 |
| `contract.transfer(to, amount)` | `client.sendTransaction(...)` | 调用合约 |
| `ethers.parseEther("1.0")` | `EtherAmount.fromBigInt(EtherUnit.ether, ...)` | 单位转换 |
| `signer.sendTransaction(tx)` | `client.sendTransaction(credentials, tx)` | 发送交易 |

Flutter 中连接钱包用 WalletConnect（因为移动端没有浏览器插件）：

```
Flutter App                    用户的手机钱包
    │                              │
    │ 生成 WalletConnect URI       │
    │ 显示二维码                    │
    │ ──────────────────────────→  │ 用户扫码
    │                              │ 确认连接
    │ ←──────────────────────────  │
    │ 建立加密通道                  │
    │                              │
    │ 请求签名交易                  │
    │ ──────────────────────────→  │ 弹出确认
    │                              │ 用户确认
    │ ←──────────────────────────  │ 返回签名
    │ 广播交易到链上                │
```

这部分在第 7 章的 Flutter 代码中已经有实现，回去看 `walletconnect_flutter_v2` 的用法。

## 8.10 本章小结与练习

### 你学到了什么

- DApp 前端的工作原理：Provider → Signer → Contract
- MetaMask 的作用：管理私钥、提供 Provider、签名交易
- 纯 JavaScript 直接调用 `window.ethereum` 的底层方法
- ethers.js v6 的完整用法：连接、查余额、读合约、写合约、监听事件
- web3.js 的核心用法和与 ethers.js 的对比
- ABI 的两种格式和函数选择器原理
- 与 Uniswap 等真实合约的交互

### 动手练习

1. **代币仪表盘**：创建一个网页，连接 MetaMask 后自动显示用户持有的 USDT、USDC、DAI 余额（提示：分别查询三个合约的 balanceOf）

2. **NFT 查看器**：输入一个 ERC-721 合约地址和 Token ID，显示 NFT 的名称、图片（从 tokenURI 获取元数据）

3. **Gas 追踪器**：实时显示当前以太坊的 Gas Price（Base Fee + Priority Fee），每 12 秒自动刷新

4. **签名登录**：实现一个"用钱包登录"的流程——前端生成随机消息 → 用户签名 → 前端验证签名恢复出的地址是否匹配

5. **Swap 价格查询器**：用 Uniswap V3 Quoter 合约，实现一个页面，输入代币对和金额，显示预期兑换数量和价格影响

### 下一章预告

下一章我们深入 Go 后端微服务架构——用 Gin 框架搭建 RESTful API，用 gRPC 做微服务通信，用 Kafka 处理链上事件，构建一个完整的 DApp 后端。
