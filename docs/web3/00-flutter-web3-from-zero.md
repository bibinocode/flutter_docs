# Flutter Web3 从 0 到 1：完整开发路线图

> 从学习加密货币基础，到开发完整的 Web3 应用——这份指南是你的学习地图。跟随 MetaMask Mobile 的架构设计，我们用 Flutter 构建一个企业级钱包。

---

## 🗺️ 学习路线完整时间表

```
第一阶段：基础知识（必读）
│
├─ 1. 区块链和加密货币基础
├─ 2. 以太坊和智能合约入门
├─ 3. Dart 和 Flutter 基础
└─ 4. Web3 概念理解

第二阶段：单机钱包（无网络）
│
├─ 5. 密钥生成和管理（HD 钱包）
├─ 6. 安全存储方案
├─ 7. 交易构造和签名
└─ 8. 本地 UI 完成

第三阶段：网络集成（连接区块链）
│
├─ 9. RPC 客户端实现
├─ 10. 合约交互（ERC-20）
├─ 11. Gas 估算和优化
└─ 12. 交易广播和确认

第四阶段：高级功能
│
├─ 13. DApp 浏览器集成
├─ 14. WalletConnect 实现
├─ 15. 多链支持
├─ 16. 权限管理系统
└─ 17. 安全审计

第五阶段：生产就位
│
├─ 18. App Store/Play Store 发布
├─ 19. 性能优化和监控
└─ 20. 用户反馈和迭代
```

---

## 📚 学习大纲 & 对应文档

### 第一阶段：基础知识（不能跳过！）

#### 🎯 目标
理解 Web3 的唯一底层原理，不需要深入代码。

| 课程 | 主要内容 | 时间 | 对应章节 |
|-----|--------|------|--------|
| **01 区块链基础** | 什么是区块链？比特币和以太坊的区别？ | 2h | docs/web3/01-blockchain-fundamentals.md |
| **02 加密学** | 公钥、私钥、签名原理 | 2h | docs/web3/02-cryptography.md |
| **03 以太坊详解** | EVM、Gas、地址、账户模型 | 3h | docs/web3/03-ethereum-multichain.md |
| **04 智能合约初级** | Solidity 基础，ERC-20 标准 | 3h | docs/web3/06-solidity-fundamentals.md |

**✅ 检查点**：
- [ ] 能解释什么是私钥、地址、助记词的关系
- [ ] 明白 Gas 费用怎么计算
- [ ] 知道 ERC-20 代币合约的 transfer 函数做了什么
- [ ] 理解为什么需要签名交易

---

### 第二阶段：Dart 基础 & Flutter 项目初始化

#### 🎯 目标
掌握 Dart 语言，建立 Flutter 项目骨架。

| 课程 | 主要内容 | 时间 | 对应章节 |
|-----|--------|------|--------|
| **Dart 基础** | 语法、类型系统、异步编程 | 4h | docs/dart/ |
| **Flutter 基础** | Widget、Layout、State Management | 4h | Flutter 官方教程 |
| **项目初始化** | 项目结构、依赖管理、编译配置 | 1h | 本章 2.1 |

**💻 动手练习：创建第一个 Flutter App**

```bash
# 创建项目
flutter create --org com.web3 --platforms=android,ios,web web3_wallet
cd web3_wallet

# 运行
flutter run
```

**✅ 检查点**：
- [ ] 能创建并运行 Flutter 应用
- [ ] 理解 StatelessWidget 和 StatefulWidget
- [ ] 会使用 async/await 处理异步操作
- [ ] 会使用基本的状态管理（Provider 或 Riverpod）

---

### 第三阶段：密钥管理和 HD 钱包（最重要！）

#### 🎯 目标
实现一个安全的本地钱包，能生成和管理私钥。

#### 3.1 理论：HD 钱包原理

```
用户设定密码
     ↓
PBKDF2 派生 → 加密密钥
     ↓
用户输入或生成助记词（12个英文单词）
     ↓
PBKDF2("Bitcoin seed") → Master Key
     ↓
BIP-32 从 Master Key 派生子密钥树
     ↓
BIP-44 选择 Ethereum 分支：m/44'/60'/0'/0/n
     ↓
第 n 个账户的私钥 → 派生公钥 → 转换为以太坊地址
```

#### 3.2 实现步骤

**Step 1: 安装依赖**

```yaml
# pubspec.yaml
dependencies:
  # Web3 核心
  web3dart: ^2.7.3
  http: ^1.2.0

  # 钱包相关
  bip39: ^1.0.6          # 助记词
  bip32: ^2.0.0          # HD 钱包
  pointycastle: ^3.7.3   # 加密库
  hex: ^0.2.0
  convert: ^3.1.1

  # 安全存储
  flutter_secure_storage: ^9.0.0

  # 状态管理
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # 其他
  intl: ^0.19.0
  uuid: ^4.0.0
```

**Step 2: 创建 HD 钱包类**

```dart
// lib/core/wallet/hd_wallet.dart
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';

/// 钱包账户数据类
class WalletAccount {
  final int index;
  final String address;      // 以太坊地址（EIP-55 格式）
  final String publicKey;    // 公钥（hex）
  final EthPrivateKey privateKey;  // 私钥对象（不要暴露！）

  WalletAccount({
    required this.index,
    required this.address,
    required this.publicKey,
    required this.privateKey,
  });
}

/// HD 钱包实现
class HDWallet {
  final String mnemonic;           // 12 个单词
  final String derivationPath;     // BIP-44 路径

  late bip32.BIP32 _masterKey;

  HDWallet._({
    required this.mnemonic,
    required this.derivationPath,
  }) {
    // 从助记词生成 seed
    final seed = bip39.mnemonicToSeed(mnemonic);
    // 从 seed 生成主密钥（BIP-32）
    _masterKey = bip32.BIP32.fromSeed(seed);
  }

  /// ✅ 创建新随机钱包
  static HDWallet create() {
    final mnemonic = bip39.generateMnemonic(strength: 128); // 12 words
    return HDWallet._(
      mnemonic: mnemonic,
      derivationPath: "m/44'/60'/0'/0", // 标准以太坊路径
    );
  }

  /// ✅ 从已有助记词恢复
  static HDWallet fromMnemonic(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid mnemonic');
    }
    return HDWallet._(
      mnemonic: mnemonic,
      derivationPath: "m/44'/60'/0'/0",
    );
  }

  /// ✅ 派生第 n 个账户的地址和私钥
  WalletAccount deriveAccount(int index) {
    try {
      // 完整路径：m/44'/60'/0'/0/index
      final child = _masterKey.derivePath("m/44'/60'/0'/0/$index");

      // 获取私钥
      final privateKeyBytes = child.privateKey;
      if (privateKeyBytes == null) {
        throw Exception('Failed to derive private key');
      }

      // 创建 EthPrivateKey 对象
      final ethPrivateKey = EthPrivateKey(privateKeyBytes);

      // 从私钥推导公钥（自动）
      final ethAddress = ethPrivateKey.address;

      return WalletAccount(
        index: index,
        address: ethAddress.hexEip55,  // EIP-55 格式：0x...（大小写混合）
        publicKey: ethPrivateKey.publicKey.toString(),
        privateKey: ethPrivateKey,
      );
    } catch (e) {
      throw Exception('Account derivation failed: $e');
    }
  }

  /// ✅ 一次性派生多个账户（常见需求）
  List<WalletAccount> deriveAccounts(int count) {
    return List.generate(count, (i) => deriveAccount(i));
  }
}
```

**Step 3: 安全存储私钥**

```dart
// lib/core/wallet/key_store.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 密钥安全存储器
/// 对应 MetaMask 的 KeyManager
class KeyStore {
  // 原生安全存储（系统加密）
  static const _storage = FlutterSecureStorage(
    // Android：使用加密的 SharedPreferences
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.rsa_ecb_oaepwithsha256andmgf1padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.aes_gcm_nokwp,
    ),
    // iOS：使用 Keychain
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device_only,
    ),
  );

  static const String _mnemonicKey = 'encrypted_mnemonic';
  static const String _versionKey = 'wallet_version';

  /// ✅ 保存助记词（自动加密）
  static Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(
      key: _mnemonicKey,
      value: mnemonic, // 底层自动加密
    );
    // 记录版本，方便以后升级
    await _storage.write(key: _versionKey, value: '1');
  }

  /// ✅ 读取助记词（自动解密）
  static Future<String?> getMnemonic() async {
    return await _storage.read(key: _mnemonicKey);
  }

  /// ✅ 检查是否已有钱包
  static Future<bool> hasWallet() async {
    final mnemonic = await getMnemonic();
    return mnemonic != null && mnemonic.isNotEmpty;
  }

  /// ✅ 清除所有数据（重置钱包）
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

**Step 4: 集成 Riverpod 状态管理**

```dart
// lib/providers/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WalletStatus { none, loading, ready, error }

class WalletState {
  final WalletStatus status;
  final HDWallet? wallet;
  final String? mnemonic;  // ⚠️ 只在创建时显示，不要长期存储！
  final List<WalletAccount> accounts;
  final WalletAccount? currentAccount;
  final String? error;

  const WalletState({
    this.status = WalletStatus.none,
    this.wallet,
    this.mnemonic,
    this.accounts = const [],
    this.currentAccount,
    this.error,
  });

  WalletState copyWith({
    WalletStatus? status,
    HDWallet? wallet,
    String? mnemonic,
    List<WalletAccount>? accounts,
    WalletAccount? currentAccount,
    String? error,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      mnemonic: mnemonic ?? this.mnemonic,
      accounts: accounts ?? this.accounts,
      currentAccount: currentAccount ?? this.currentAccount,
      error: error ?? this.error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletState());

  /// ✅ 初始化（启动应用时调用）
  Future<void> initialize() async {
    state = state.copyWith(status: WalletStatus.loading);
    try {
      final hasWallet = await KeyStore.hasWallet();
      if (hasWallet) {
        final mnemonic = await KeyStore.getMnemonic();
        if (mnemonic == null) throw Exception('Mnemonic not found');

        final wallet = HDWallet.fromMnemonic(mnemonic);
        final accounts = wallet.deriveAccounts(3);

        state = state.copyWith(
          status: WalletStatus.ready,
          wallet: wallet,
          accounts: accounts,
          currentAccount: accounts.first,
        );
      } else {
        state = state.copyWith(status: WalletStatus.none);
      }
    } catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        error: e.toString(),
      );
    }
  }

  /// ✅ 创建新钱包
  Future<String> createWallet() async {
    try {
      final wallet = HDWallet.create();
      await KeyStore.saveMnemonic(wallet.mnemonic);

      final accounts = wallet.deriveAccounts(3);

      state = state.copyWith(
        status: WalletStatus.ready,
        wallet: wallet,
        mnemonic: wallet.mnemonic, // ⚠️ 临时显示
        accounts: accounts,
        currentAccount: accounts.first,
      );

      return wallet.mnemonic; // 返回给 UI 显示
    } catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// ✅ 导入钱包
  Future<void> importWallet(String mnemonic) async {
    try {
      final wallet = HDWallet.fromMnemonic(mnemonic);
      await KeyStore.saveMnemonic(mnemonic);

      final accounts = wallet.deriveAccounts(3);
      state = state.copyWith(
        status: WalletStatus.ready,
        wallet: wallet,
        accounts: accounts,
        currentAccount: accounts.first,
      );
    } catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// ✅ 切换当前账户
  void switchAccount(int index) {
    if (index >= 0 && index < state.accounts.length) {
      state = state.copyWith(currentAccount: state.accounts[index]);
    }
  }
}

// Riverpod provider
final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});
```

**✅ 检查点：第三阶段完成**
- [ ] 能创建新钱包并展示助记词
- [ ] 能从助记词恢复钱包
- [ ] 助记词安全存储在系统 Keychain/Keystore
- [ ] 能派生多个账户地址
- [ ] UI 能显示账户列表和切换

---

### 第四阶段：区块链交互基础

#### 🎯 目标
连接以太坊节点，查询链上数据（余额、交易）。

#### 4.1 RPC 客户端

```dart
// lib/core/blockchain/ethereum_client.dart
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

/// 以太坊链配置
class ChainConfig {
  final int chainId;
  final String name;
  final String rpcUrl;
  final String symbol;
  final String? explorerUrl;

  const ChainConfig({
    required this.chainId,
    required this.name,
    required this.rpcUrl,
    required this.symbol,
    this.explorerUrl,
  });

  // 预定义的链配置
  static const ethereum = ChainConfig(
    chainId: 1,
    name: 'Ethereum Mainnet',
    rpcUrl: 'https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY',
    symbol: 'ETH',
    explorerUrl: 'https://etherscan.io',
  );

  static const sepolia = ChainConfig(
    chainId: 11155111,
    name: 'Sepolia Testnet',
    rpcUrl: 'https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY',
    symbol: 'ETH',
    explorerUrl: 'https://sepolia.etherscan.io',
  );

  static const bsc = ChainConfig(
    chainId: 56,
    name: 'BSC Mainnet',
    rpcUrl: 'https://bsc-dataseed.binance.org',
    symbol: 'BNB',
    explorerUrl: 'https://bscscan.com',
  );

  static const polygon = ChainConfig(
    chainId: 137,
    name: 'Polygon',
    rpcUrl: 'https://polygon-rpc.com',
    symbol: 'MATIC',
    explorerUrl: 'https://polygonscan.com',
  );

  static const List<ChainConfig> all = [ethereum, sepolia, bsc, polygon];
}

/// 以太坊 JSON-RPC 客户端
class EthereumClient {
  late Web3Client _client;
  ChainConfig chain;

  EthereumClient(this.chain) {
    // Web3Client 底层使用 JSON-RPC 调用节点
    _client = Web3Client(chain.rpcUrl, http.Client());
  }

  Web3Client get client => _client;

  /// ✅ 获取当前区块号
  Future<int> getBlockNumber() async {
    return await _client.getBlockNumber();
  }

  /// ✅ 查询 ETH 余额
  Future<EtherAmount> getBalance(String address) async {
    final addr = EthereumAddress.fromHex(address);
    return await _client.getBalance(addr);
  }

  /// ✅ 查询余额（格式化）
  Future<String> getBalanceFormatted(String address) async {
    final balance = await getBalance(address);
    return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(6);
  }

  /// ✅ 获取 Gas Price
  Future<GasPrice> getGasPrice() async {
    return await _client.getGasPrice();
  }

  /// ✅ 获取交易计数（用于 Nonce）
  Future<int> getTransactionCount(String address) async {
    final addr = EthereumAddress.fromHex(address);
    return await _client.getTransactionCount(addr);
  }

  /// ✅ 估算 Gas 消耗
  Future<BigInt> estimateGas(Transaction tx) async {
    return await _client.estimateGas(
      sender: tx.from,
      to: tx.to,
      value: tx.value,
      data: tx.data,
    );
  }

  /// ✅ 获取交易回执
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await _client.getTransactionReceipt(txHash);
  }

  /// ✅ 广播（发送）交易
  Future<String> sendRawTransaction(Uint8List serializedTx) async {
    return await _client.sendRawTransaction(serializedTx);
  }

  /// ✅ 切换链
  void switchChain(ChainConfig newChain) {
    _client.dispose();
    chain = newChain;
    _client = Web3Client(newChain.rpcUrl, http.Client());
  }

  void dispose() {
    _client.dispose();
  }
}
```

#### 4.2 Riverpod Providers

```dart
// lib/providers/blockchain_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前选中的链配置
final chainProvider = StateProvider<ChainConfig>((ref) {
  return ChainConfig.sepolia; // 默认测试网
});

/// 以太坊客户端实例
final ethClientProvider = Provider<EthereumClient>((ref) {
  final chain = ref.watch(chainProvider);
  return EthereumClient(chain);
});

/// 当前账户的 ETH 余额
final balanceProvider = FutureProvider<String>((ref) async {
  final walletState = ref.watch(walletProvider);
  final ethClient = ref.watch(ethClientProvider);

  if (walletState.currentAccount == null) return '0.0000';

  return await ethClient.getBalanceFormatted(
    walletState.currentAccount!.address,
  );
});

/// Gas Price 信息
final gasPriceProvider = FutureProvider<GasPrice>((ref) async {
  final ethClient = ref.watch(ethClientProvider);
  return await ethClient.getGasPrice();
});
```

**✅ 检查点：第四阶段完成**
- [ ] 能连接以太坊节点并查询数据
- [ ] 能显示账户余额
- [ ] 能显示当前 Gas Price
- [ ] UI 能显示基本的钱包信息

---

### 第五阶段：交易构造与签名

#### 🎯 目标
构造、签名、发送真实交易。这是钱包的核心能力。

#### 5.1 交易模型

```dart
// lib/core/blockchain/transaction.dart

/// 交易状态追踪
enum TransactionStatus { pending, confirmed, failed }

/// 本地交易缓存
class CachedTransaction {
  final String hash;
  final String from;
  final String to;
  final BigInt value;
  final DateTime timestamp;
  final TransactionStatus status;

  CachedTransaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.timestamp,
    required this.status,
  });
}
```

#### 5.2 交易服务

```dart
// lib/core/blockchain/transaction_service.dart
import 'package:web3dart/web3dart.dart';

/// 交易管理服务
/// 对应 MetaMask 的 TransactionController
class TransactionService {
  final EthereumClient ethClient;
  final List<CachedTransaction> _history = [];

  TransactionService(this.ethClient);

  /// ✅ 发送 ETH
  Future<String> sendEth({
    required WalletAccount account,
    required String toAddress,
    required BigInt amountWei,
    BigInt? gasPrice,
    BigInt? gasLimit,
  }) async {
    try {
      // 1️⃣ 验证地址
      if (!isValidEthereumAddress(toAddress)) {
        throw Exception('Invalid recipient address');
      }

      // 2️⃣ 检查余额
      final balance = await ethClient.getBalance(account.address);
      final totalCost =
          amountWei + (gasPrice ?? await ethClient.getGasPrice() as BigInt) * (gasLimit ?? BigInt.from(21000));
      if (balance.getInWei < totalCost) {
        throw Exception('Insufficient balance');
      }

      // 3️⃣ 获取 Nonce（交易序号）
      final nonce = await ethClient.getTransactionCount(account.address);

      // 4️⃣ 构造交易对象
      final transaction = Transaction(
        from: EthereumAddress.fromHex(account.address),
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.inWei(amountWei),
        nonce: nonce,
        maxGas: (gasLimit ?? BigInt.from(21000)).toInt(),
        gasPrice: EtherAmount.inWei(gasPrice ?? await ethClient.getGasPrice() as BigInt),
      );

      // 5️⃣ 签名交易（使用私钥）
      final signedTx = await ethClient.client.sendTransaction(
        account.privateKey,
        transaction,
      );

      // 6️⃣ 缓存交易
      _history.add(CachedTransaction(
        hash: signedTx,
        from: account.address,
        to: toAddress,
        value: amountWei,
        timestamp: DateTime.now(),
        status: TransactionStatus.pending,
      ));

      // 7️⃣ 后台轮询确认
      _waitForConfirmation(signedTx);

      return signedTx;
    } catch (e) {
      throw Exception('Send ETH failed: $e');
    }
  }

  /// ✅ 获取交易历史
  List<CachedTransaction> getHistory() => _history;

  /// ✅ 监听交易确认
  Future<void> _waitForConfirmation(String txHash) async {
    int attempts = 0;
    const maxAttempts = 120; // 最多轮询 2 分钟

    while (attempts < maxAttempts) {
      final receipt = await ethClient.getTransactionReceipt(txHash);

      if (receipt != null) {
        final index = _history.indexWhere((t) => t.hash == txHash);
        if (index >= 0) {
          final status = receipt.status == true
              ? TransactionStatus.confirmed
              : TransactionStatus.failed;

          _history[index] = CachedTransaction(
            hash: txHash,
            from: _history[index].from,
            to: _history[index].to,
            value: _history[index].value,
            timestamp: _history[index].timestamp,
            status: status,
          );
        }
        return;
      }

      await Future.delayed(const Duration(seconds: 1));
      attempts++;
    }
  }
}

bool isValidEthereumAddress(String address) {
  try {
    EthereumAddress.fromHex(address);
    return true;
  } catch (e) {
    return false;
  }
}
```

#### 5.3 UI：发送交易页面

```dart
// lib/features/wallet/send_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSending = false;
  String? _txHash;

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final chain = ref.watch(chainProvider);
    final gasPrice = ref.watch(gasPriceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 接收地址输入框
              TextField(
                controller: _toAddressController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Address',
                  hintText: '0x...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 金额输入框
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.0',
                  border: const OutlineInputBorder(),
                  suffixText: chain.symbol,
                ),
              ),
              const SizedBox(height: 16),

              // Gas 信息
              gasPrice.when(
                data: (price) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gas Price',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${price.getValueInUnit(EtherUnit.gwei).toStringAsFixed(2)} Gwei',
                        ),
                        const SizedBox(height: 8),
                        const Text('Estimated Gas: 21,000'),
                        Text(
                          'Total Fee: ${(price.getValueInUnit(EtherUnit.gwei) * 21000 / 1e9).toStringAsFixed(6)} ${chain.symbol}',
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) =>
                    Text('Error loading gas: $e', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 24),

              // 发送按钮
              ElevatedButton(
                onPressed: _isSending ? null : _sendTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send', style: TextStyle(fontSize: 16)),
              ),

              // 交易结果
              if (_txHash != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 48),
                        const SizedBox(height: 8),
                        const Text('Transaction Sent!'),
                        const SizedBox(height: 8),
                        SelectableText(
                          'TX: $_txHash',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendTransaction() async {
    final to = _toAddressController.text.trim();
    final amount = _amountController.text.trim();

    if (to.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final walletState = ref.read(walletProvider);
      final account = walletState.currentAccount;

      if (account == null) throw Exception('No account selected');

      // 构造交易服务
      final ethClient = ref.read(ethClientProvider);
      final txService = TransactionService(ethClient);

      // 发送交易
      final amountWei = BigInt.from(double.parse(amount) * 1e18);
      final txHash = await txService.sendEth(
        account: account,
        toAddress: to,
        amountWei: amountWei,
      );

      setState(() {
        _txHash = txHash;
        _isSending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction sent: $txHash')),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Send failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
```

**✅ 检查点：第五阶段完成**
- [ ] 能构造标准的以太坊交易
- [ ] 能使用私钥签名交易
- [ ] 能发送交易到网络
- [ ] 能显示交易状态（pending → confirmed）

---

### 第六阶段：代币交互（ERC-20）

#### 🎯 目标
与智能合约交互，支持代币转账。

#### 6.1 ERC-20 ABI

```dart
// lib/core/blockchain/erc20_abi.dart

/// ERC-20 标准 ABI
const String erc20AbiJson = '''
[
  {
    "constant": true,
    "inputs": [],
    "name": "name",
    "outputs": [{"name": "", "type": "string"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "symbol",
    "outputs": [{"name": "", "type": "string"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "decimals",
    "outputs": [{"name": "", "type": "uint8"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [{"name": "_owner", "type": "address"}],
    "name": "balanceOf",
    "outputs": [{"name": "balance", "type": "uint256"}],
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {"name": "_to", "type": "address"},
      {"name": "_value", "type": "uint256"}
    ],
    "name": "transfer",
    "outputs": [{"name": "", "type": "bool"}],
    "type": "function"
  }
]
''';
```

#### 6.2 ERC-20 合约交互

```dart
//lib/core/blockchain/erc20_service.dart
import 'package:web3dart/web3dart.dart';

class ERC20Service {
  final Web3Client client;
  final DeployedContract contract;
  final String address;

  ERC20Service({
    required this.client,
    required this.contract,
    required this.address,
  });

  /// ✅ 从合约地址创建 ERC-20 服务
  static ERC20Service create(Web3Client client, String contractAddress) {
    final abi = ContractAbi.fromJson(erc20AbiJson, 'ERC20');
    final contract = DeployedContract(
      abi,
      EthereumAddress.fromHex(contractAddress),
    );
    return ERC20Service(
      client: client,
      contract: contract,
      address: contractAddress,
    );
  }

  /// ✅ 查询代币名称
  Future<String> name() async {
    final result = await client.call(
      contract: contract,
      function: contract.function('name'),
      params: [],
    );
    return result.first as String;
  }

  /// ✅ 查询代币符号
  Future<String> symbol() async {
    final result = await client.call(
      contract: contract,
      function: contract.function('symbol'),
      params: [],
    );
    return result.first as String;
  }

  /// ✅ 查询精度
  Future<int> decimals() async {
    final result = await client.call(
      contract: contract,
      function: contract.function('decimals'),
      params: [],
    );
    return (result.first as BigInt).toInt();
  }

  /// ✅ 查询余额
  Future<BigInt> balanceOf(String address) async {
    final result = await client.call(
      contract: contract,
      function: contract.function('balanceOf'),
      params: [EthereumAddress.fromHex(address)],
    );
    return result.first as BigInt;
  }

  /// ✅ 查询余额（格式化）
  Future<String> balanceOfFormatted(String address) async {
    final balance = await balanceOf(address);
    final dec = await decimals();
    final divisor = BigInt.from(10).pow(dec);
    final whole = balance ~/ divisor;
    final fraction = (balance % divisor).toString().padLeft(dec, '0');
    return '$whole.${fraction.substring(0, min(dec, 6))}';
  }

  /// ✅ 转账代币
  Future<String> transfer(
    Credentials credentials,
    String toAddress,
    BigInt amount, {
    required int chainId,
    BigInt? gasPrice,
    BigInt? gasLimit,
  }) async {
    return await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: contract.function('transfer'),
        parameters: [EthereumAddress.fromHex(toAddress), amount],
        maxGas: (gasLimit ?? BigInt.from(100000)).toInt(),
        gasPrice: gasPrice != null
            ? EtherAmount.inWei(gasPrice)
            : null,
      ),
      chainId: chainId,
    );
  }
}

import 'dart:math';
```

**✅ 检查点：第六阶段完成**
- [ ] 能与 ERC-20 合约交互
- [ ] 能查询代币信息和余额
- [ ] 能发送代币转账交易

---

### 第七阶段：高级功能

#### 🎯 选题（按优先级）

**高优先级（建议实现）**：
1. ⭐⭐⭐⭐⭐ **多链支持** - 切换不同区块链
2. ⭐⭐⭐⭐ **DApp 浏览器** - 内嵌 WebView + Web3 注入
3. ⭐⭐⭐⭐ **交易历史** - 从 Etherscan API 获取
4. ⭐⭐⭐ **权限管理** - 与 DApp 交互时的细粒度控制

**中等优先级**：
5. ⭐⭐⭐ **WalletConnect** - 与外部应用集成
6. ⭐⭐ **NFT 支持** - ERC-721 查看器
7. ⭐⭐ **Swap 集成** - Uniswap API

**低优先级（生产后）**：
8. ⭐ **Ledger 硬件钱包集成**
9. ⭐ **多签钱包**
10. ⭐ **Staking 功能**

---

## 📱 项目存储库结构

```
web3_wallet/
│
├── lib/
│   ├── main.dart                   # 应用入口
│   │
│   ├── core/                       # 核心业务逻辑
│   │   ├── wallet/
│   │   │   ├── hd_wallet.dart      # ✅ HD 钱包
│   │   │   └── key_store.dart      # ✅ 安全存储
│   │   │
│   │   └── blockchain/
│   │       ├── ethereum_client.dart # ✅ RPC 客户端
│   │       ├── chain_config.dart    # ✅ 链配置
│   │       ├── transaction_service.dart # ✅ 交易
│   │       ├── erc20_service.dart   # ✅ 代币
│   │       └── erc20_abi.dart       # ✅ ABI
│   │
│   ├── features/                   # 功能模块
│   │   ├── home/
│   │   │   └── home_page.dart      # 主页（显示余额）
│   │   │
│   │   ├── wallet/
│   │   │   ├── wallet_page.dart    # 钱包首页
│   │   │   ├── send_page.dart      # 发送交易
│   │   │   ├── receive_page.dart   # 接收地址
│   │   │   └── tokens_page.dart    # 代币列表
│   │   │
│   │   └── settings/
│   │       └── settings_page.dart  # 设置
│   │
│   ├── providers/                  # Riverpod Providers
│   │   ├── wallet_provider.dart    # ✅ 钱包状态
│   │   ├── blockchain_provider.dart # ✅ 区块链状态
│   │   └── tokens_provider.dart    # 代币列表
│   │
│   ├── shared/                     # 共享代码
│   │   ├── widgets/
│   │   │   ├── address_card.dart
│   │   │   ├── balance_card.dart
│   │   │   └── transaction_tile.dart
│   │   │
│   │   └── utils/
│   │       ├── formatters.dart
│   │       ├── validators.dart
│   │       └── constants.dart
│   │
│   └── app.dart                    # App 主体
│
├── android/                        # Android 特定配置
│   ├── app/
│   │   └── build.gradle
│   └── build.gradle
│
├── ios/                            # iOS 特定配置
│   ├── Podfile
│   └── Runner.xcworkspace
│
├── web/                            # Web 支持（2024 可选）
│
├── pubspec.yaml                    # ✅ 依赖管理
├── analysis_options.yaml           # Lint 配置
├── .github/
│   └── workflows/
│       └── ci.yml                  # CI/CD 配置
│
└── README.md
```

---

## 🎓 学习资源汇总

### 文档和教程
- **MetaMask 官方文档**: https://docs.metamask.io/
- **以太坊官方网站**: https://ethereum.org/en/developers/
- **Solidity 官方文档**: https://docs.soliditylang.org/
- **web3dart 文档**: https://pub.dev/packages/web3dart
- **Flutter 官方文档**: https://flutter.dev/docs

### 示例项目
- **MetaMask Mobile**: https://github.com/MetaMask/metamask-mobile
- **Trust Wallet**: https://github.com/trustwallet/trust-wallet-android-source
- **Coinbase Wallet**: https://github.com/coinbase/coinbase-wallet-sdk

### 在线课程
- **CryptoZombies**: https://cryptozombies.io/ (Solidity 交互式教程)
- **Ethereum.org Developers**: https://ethereum.org/en/developers/learning-tools/
- **Udemy Web3 课程**: https://www.udemy.com/topic/web3/

### 安全资源
- **OpenZeppelin Contracts**: https://docs.openzeppelin.com/contracts/
- **Consensys Best Practices**: https://consensys.github.io/smart-contract-best-practices/

---

## ✅ 自检清单

启动项目前，确保你能答上这些问题：

- [ ] 什么是私钥、公钥、地址的关系？
- [ ] BIP-44 路径 `m/44'/60'/0'/0/0` 各部分代表什么？
- [ ] 为什么需要 Gas 费用？
- [ ] 交易发送和交易确认是两个不同的概念，为什么？
- [ ] ERC-20 的 `transfer` 函数底层做了什么？
- [ ] MetaMask 如何保护你的私钥？
- [ ] 什么是 Nonce，它在交易中的作用？

---

## 🚀 下一步

1. **完成第一个阶段**：理解区块链基础知识
2. **搭建开发环境**：安装 Flutter、配置 IDE
3. **创建钱包**：实现 HD 钱包和密钥存储（第 3 阶段）
4. **连接节点**：实现区块链交互（第 4 阶段）
5. **发送交易**：完整的交易签名和广播（第 5 阶段）

祝你开发顺利！有问题可以参考 MetaMask 的源代码和以太坊文档。

