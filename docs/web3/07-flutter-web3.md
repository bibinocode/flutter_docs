# 第 7 章：Flutter DApp 前端开发

> 用 Flutter 构建跨平台 Web3 客户端——一套代码同时运行在 iOS、Android、Web 和桌面端。这一章从连接钱包开始，到完成一个能查余额、发交易的 DApp。

## 7.1 Flutter Web3 项目初始化

```bash
# 创建项目
flutter create --org com.web3 --platforms=android,ios,web web3_dapp
cd web3_dapp
```

### 核心依赖配置

```yaml
# pubspec.yaml
name: web3_dapp
description: A Web3 DApp built with Flutter

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Web3 核心
  web3dart: ^2.7.3
  http: ^1.2.0
  web_socket_channel: ^2.4.0

  # 钱包
  bip39: ^1.0.6
  bip32: ^2.0.0
  hex: ^0.2.0
  convert: ^3.1.1
  pointycastle: ^3.7.3

  # 安全存储
  flutter_secure_storage: ^9.0.0

  # 状态管理
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # 网络
  dio: ^5.4.0

  # UI
  fl_chart: ^0.68.0
  cached_network_image: ^3.3.0
  qr_flutter: ^4.1.0
  shimmer: ^3.0.0

  # 工具
  intl: ^0.19.0
  url_launcher: ^6.2.0
  share_plus: ^7.2.0
```

### 项目结构

```
lib/
├── core/                       # 核心层
│   ├── blockchain/
│   │   ├── ethereum_client.dart    # 以太坊客户端
│   │   ├── contract_service.dart   # 合约交互
│   │   └── chain_config.dart       # 链配置
│   ├── wallet/
│   │   ├── wallet_manager.dart     # 钱包管理
│   │   ├── hd_wallet.dart          # HD 钱包
│   │   └── key_store.dart          # 密钥存储
│   └── network/
│       ├── api_client.dart         # API 客户端
│       └── rpc_client.dart         # RPC 客户端
├── features/                   # 功能模块
│   ├── home/
│   │   └── home_page.dart
│   ├── wallet/
│   │   ├── wallet_page.dart
│   │   ├── send_page.dart
│   │   └── receive_page.dart
│   ├── tokens/
│   │   ├── token_list_page.dart
│   │   └── token_detail_page.dart
│   └── settings/
│       └── settings_page.dart
├── shared/                     # 共享组件
│   ├── widgets/
│   │   ├── address_display.dart
│   │   ├── balance_card.dart
│   │   └── transaction_tile.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── providers/                  # Riverpod Providers
│   ├── wallet_provider.dart
│   ├── balance_provider.dart
│   └── chain_provider.dart
└── app.dart                    # 应用入口
```

## 7.2 以太坊客户端封装

```dart
// lib/core/blockchain/chain_config.dart

/// 链配置
class ChainConfig {
  final int chainId;
  final String name;
  final String rpcUrl;
  final String symbol;
  final int decimals;
  final String? explorerUrl;

  const ChainConfig({
    required this.chainId,
    required this.name,
    required this.rpcUrl,
    required this.symbol,
    this.decimals = 18,
    this.explorerUrl,
  });

  /// 预定义链配置
  static const ethereum = ChainConfig(
    chainId: 1,
    name: 'Ethereum',
    rpcUrl: 'https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY',
    symbol: 'ETH',
    explorerUrl: 'https://etherscan.io',
  );

  static const sepolia = ChainConfig(
    chainId: 11155111,
    name: 'Sepolia',
    rpcUrl: 'https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY',
    symbol: 'ETH',
    explorerUrl: 'https://sepolia.etherscan.io',
  );

  static const bsc = ChainConfig(
    chainId: 56,
    name: 'BSC',
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
}
```

```dart
// lib/core/blockchain/ethereum_client.dart
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

/// 以太坊客户端封装
class EthereumClient {
  late Web3Client _client;
  final ChainConfig chain;

  EthereumClient(this.chain) {
    _client = Web3Client(chain.rpcUrl, http.Client());
  }

  Web3Client get client => _client;

  /// 获取当前区块号
  Future<int> getBlockNumber() async {
    return await _client.getBlockNumber();
  }

  /// 获取 ETH 余额
  Future<EtherAmount> getBalance(String address) async {
    final addr = EthereumAddress.fromHex(address);
    return await _client.getBalance(addr);
  }

  /// 获取 ETH 余额（格式化为可读字符串）
  Future<String> getBalanceFormatted(String address) async {
    final balance = await getBalance(address);
    final ethValue = balance.getValueInUnit(EtherUnit.ether);
    return ethValue.toStringAsFixed(4);
  }

  /// 获取 Gas Price
  Future<EtherAmount> getGasPrice() async {
    return await _client.getGasPrice();
  }

  /// 获取 Nonce
  Future<int> getNonce(String address) async {
    final addr = EthereumAddress.fromHex(address);
    return await _client.getTransactionCount(addr);
  }

  /// 发送已签名的交易
  Future<String> sendRawTransaction(Uint8List signedTx) async {
    return await _client.sendRawTransaction(signedTx);
  }

  /// 获取交易回执
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await _client.getTransactionReceipt(txHash);
  }

  /// 切换链
  void switchChain(ChainConfig newChain) {
    _client.dispose();
    _client = Web3Client(newChain.rpcUrl, http.Client());
  }

  void dispose() {
    _client.dispose();
  }
}
```

## 7.3 HD 钱包实现

```dart
// lib/core/wallet/hd_wallet.dart
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import 'package:pointycastle/digests/sha3.dart';
import 'package:convert/convert.dart';

/// HD 钱包
class HDWallet {
  final String mnemonic;
  late bip32.BIP32 _masterKey;

  HDWallet._(this.mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    _masterKey = bip32.BIP32.fromSeed(seed);
  }

  /// 创建新钱包（生成新助记词）
  static HDWallet create() {
    final mnemonic = bip39.generateMnemonic(strength: 128); // 12 个单词
    return HDWallet._(mnemonic);
  }

  /// 从助记词恢复钱包
  static HDWallet fromMnemonic(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError('无效的助记词');
    }
    return HDWallet._(mnemonic);
  }

  /// 派生以太坊地址
  /// BIP-44 路径: m/44'/60'/0'/0/index
  WalletAccount deriveAccount(int index) {
    final child = _masterKey
        .derivePath("m/44'/60'/0'/0/$index");

    final privateKey = EthPrivateKey(Uint8List.fromList(child.privateKey!));
    final address = privateKey.address;

    return WalletAccount(
      index: index,
      address: address.hexEip55,
      privateKey: privateKey,
    );
  }

  /// 批量派生多个地址
  List<WalletAccount> deriveAccounts(int count) {
    return List.generate(count, (i) => deriveAccount(i));
  }
}

/// 钱包账户
class WalletAccount {
  final int index;
  final String address;
  final EthPrivateKey privateKey;

  WalletAccount({
    required this.index,
    required this.address,
    required this.privateKey,
  });
}
```

### 安全存储

```dart
// lib/core/wallet/key_store.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// 密钥安全存储
/// 使用系统级加密存储（iOS Keychain / Android Keystore）
class KeyStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _mnemonicKey = 'wallet_mnemonic';
  static const _accountsKey = 'wallet_accounts';

  /// 保存助记词
  static Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(key: _mnemonicKey, value: mnemonic);
  }

  /// 读取助记词
  static Future<String?> getMnemonic() async {
    return await _storage.read(key: _mnemonicKey);
  }

  /// 删除助记词（重置钱包）
  static Future<void> deleteMnemonic() async {
    await _storage.delete(key: _mnemonicKey);
  }

  /// 检查是否已有钱包
  static Future<bool> hasWallet() async {
    final mnemonic = await getMnemonic();
    return mnemonic != null && mnemonic.isNotEmpty;
  }

  /// 清除所有数据
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

## 7.4 状态管理（Riverpod）

```dart
// lib/providers/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/wallet/hd_wallet.dart';
import '../core/wallet/key_store.dart';
import '../core/blockchain/ethereum_client.dart';
import '../core/blockchain/chain_config.dart';

/// 当前链配置
final chainProvider = StateProvider<ChainConfig>((ref) {
  return ChainConfig.sepolia; // 默认使用测试网
});

/// 以太坊客户端
final ethClientProvider = Provider<EthereumClient>((ref) {
  final chain = ref.watch(chainProvider);
  return EthereumClient(chain);
});

/// 钱包状态
enum WalletStatus { none, loading, ready, error }

class WalletState {
  final WalletStatus status;
  final HDWallet? wallet;
  final WalletAccount? currentAccount;
  final List<WalletAccount> accounts;
  final String? error;

  const WalletState({
    this.status = WalletStatus.none,
    this.wallet,
    this.currentAccount,
    this.accounts = const [],
    this.error,
  });

  WalletState copyWith({
    WalletStatus? status,
    HDWallet? wallet,
    WalletAccount? currentAccount,
    List<WalletAccount>? accounts,
    String? error,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      currentAccount: currentAccount ?? this.currentAccount,
      accounts: accounts ?? this.accounts,
      error: error ?? this.error,
    );
  }
}

/// 钱包管理 Notifier
class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletState());

  /// 初始化：检查是否已有钱包
  Future<void> initialize() async {
    state = state.copyWith(status: WalletStatus.loading);

    try {
      final hasWallet = await KeyStore.hasWallet();
      if (hasWallet) {
        final mnemonic = await KeyStore.getMnemonic();
        final wallet = HDWallet.fromMnemonic(mnemonic!);
        final accounts = wallet.deriveAccounts(3);

        state = state.copyWith(
          status: WalletStatus.ready,
          wallet: wallet,
          currentAccount: accounts.first,
          accounts: accounts,
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

  /// 创建新钱包
  Future<String> createWallet() async {
    final wallet = HDWallet.create();
    await KeyStore.saveMnemonic(wallet.mnemonic);

    final accounts = wallet.deriveAccounts(3);
    state = state.copyWith(
      status: WalletStatus.ready,
      wallet: wallet,
      currentAccount: accounts.first,
      accounts: accounts,
    );

    return wallet.mnemonic; // 返回助记词让用户备份
  }

  /// 导入钱包
  Future<void> importWallet(String mnemonic) async {
    final wallet = HDWallet.fromMnemonic(mnemonic);
    await KeyStore.saveMnemonic(mnemonic);

    final accounts = wallet.deriveAccounts(3);
    state = state.copyWith(
      status: WalletStatus.ready,
      wallet: wallet,
      currentAccount: accounts.first,
      accounts: accounts,
    );
  }

  /// 切换账户
  void switchAccount(int index) {
    if (index < state.accounts.length) {
      state = state.copyWith(currentAccount: state.accounts[index]);
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});

/// 当前账户余额
final balanceProvider = FutureProvider<String>((ref) async {
  final walletState = ref.watch(walletProvider);
  final ethClient = ref.watch(ethClientProvider);

  if (walletState.currentAccount == null) return '0.0000';

  return await ethClient.getBalanceFormatted(
    walletState.currentAccount!.address,
  );
});
```

## 7.5 核心 UI 页面

### 钱包首页

```dart
// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/wallet_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 初始化钱包
    ref.read(walletProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final balance = ref.watch(balanceProvider);
    final chain = ref.watch(chainProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 Wallet'),
        actions: [
          // 链选择器
          PopupMenuButton<ChainConfig>(
            onSelected: (config) {
              ref.read(chainProvider.notifier).state = config;
            },
            itemBuilder: (context) => [
              _chainMenuItem(ChainConfig.ethereum, '🔷 Ethereum'),
              _chainMenuItem(ChainConfig.sepolia, '🧪 Sepolia'),
              _chainMenuItem(ChainConfig.bsc, '🟡 BSC'),
              _chainMenuItem(ChainConfig.polygon, '🟣 Polygon'),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(chain.name),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(walletState, balance),
    );
  }

  Widget _buildBody(WalletState walletState, AsyncValue<String> balance) {
    switch (walletState.status) {
      case WalletStatus.none:
        return _buildWelcome();
      case WalletStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case WalletStatus.ready:
        return _buildWallet(walletState, balance);
      case WalletStatus.error:
        return Center(child: Text('错误: ${walletState.error}'));
    }
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              '欢迎使用 Web3 Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('创建或导入钱包开始使用', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createWallet,
                child: const Text('创建新钱包'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _importWallet,
                child: const Text('导入助记词'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallet(WalletState walletState, AsyncValue<String> balance) {
    final account = walletState.currentAccount!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 余额卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('总资产', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  balance.when(
                    data: (value) => Text(
                      '$value ETH',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('加载失败: $e'),
                  ),
                  const SizedBox(height: 16),
                  // 地址显示
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: account.address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('地址已复制')),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _shortenAddress(account.address),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.arrow_upward,
                  label: '发送',
                  onTap: () => Navigator.pushNamed(context, '/send'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.arrow_downward,
                  label: '接收',
                  onTap: () => Navigator.pushNamed(context, '/receive'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.swap_horiz,
                  label: '兑换',
                  onTap: () => Navigator.pushNamed(context, '/swap'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.blue),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<ChainConfig> _chainMenuItem(ChainConfig config, String label) {
    return PopupMenuItem(value: config, child: Text(label));
  }

  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  Future<void> _createWallet() async {
    final mnemonic = await ref.read(walletProvider.notifier).createWallet();

    // 显示助记词备份对话框
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ 请备份助记词'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请将以下助记词抄写在纸上，妥善保管。这是恢复钱包的唯一方式。'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mnemonic,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('我已备份'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importWallet() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入助记词'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '输入 12 个助记词，用空格分隔',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('导入'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await ref.read(walletProvider.notifier).importWallet(result);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('导入失败: $e')),
          );
        }
      }
    }
  }
}
```

### 发送交易页面

```dart
// lib/features/wallet/send_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';
import '../../providers/wallet_provider.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSending = false;
  String? _txHash;

  @override
  Widget build(BuildContext context) {
    final chain = ref.watch(chainProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('发送')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 接收地址
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '接收地址',
                hintText: '0x...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // 金额
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '金额',
                hintText: '0.0',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.monetization_on),
                suffixText: chain.symbol,
              ),
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
                  : const Text('确认发送', style: TextStyle(fontSize: 16)),
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
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      const Text('交易已发送!'),
                      const SizedBox(height: 8),
                      SelectableText(
                        'TX: $_txHash',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendTransaction() async {
    final address = _addressController.text.trim();
    final amountStr = _amountController.text.trim();

    if (address.isEmpty || amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final walletState = ref.read(walletProvider);
      final ethClient = ref.read(ethClientProvider);
      final account = walletState.currentAccount!;
      final chain = ref.read(chainProvider);

      // 构造交易
      final amount = EtherAmount.fromBigInt(
        EtherUnit.wei,
        BigInt.from(double.parse(amountStr) * 1e18),
      );

      final nonce = await ethClient.getNonce(account.address);
      final gasPrice = await ethClient.getGasPrice();

      final transaction = Transaction(
        to: EthereumAddress.fromHex(address),
        value: amount,
        gasPrice: gasPrice,
        maxGas: 21000,
        nonce: nonce,
      );

      // 签名并发送
      final credentials = account.privateKey;
      final txHash = await ethClient.client.sendTransaction(
        credentials,
        transaction,
        chainId: chain.chainId,
      );

      setState(() {
        _txHash = txHash;
        _isSending = false;
      });

      // 刷新余额
      ref.invalidate(balanceProvider);
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
```

## 7.6 ERC-20 代币交互

```dart
// lib/core/blockchain/contract_service.dart
import 'package:web3dart/web3dart.dart';

/// ERC-20 合约交互服务
class ERC20Service {
  final Web3Client client;
  final DeployedContract contract;

  ERC20Service._({required this.client, required this.contract});

  /// 从合约地址创建 ERC-20 服务
  static ERC20Service fromAddress(Web3Client client, String contractAddress) {
    final abi = ContractAbi.fromJson(_erc20Abi, 'ERC20');
    final contract = DeployedContract(
      abi,
      EthereumAddress.fromHex(contractAddress),
    );
    return ERC20Service._(client: client, contract: contract);
  }

  /// 查询代币名称
  Future<String> name() async {
    final result = await client.call(
      contract: contract,
      function: contract.function('name'),
      params: [],
    );
    return result.first as String;
  }

  /// 查询代币符号
  Future<String> symbol() async {
    final result = await client.call(
      contract: contract,
      function: contract.function('symbol'),
      params: [],
    );
    return result.first as String;
  }

  /// 查询精度
  Future<int> decimals() async {
    final result = await client.call(
      contract: contract,
      function: contract.function('decimals'),
      params: [],
    );
    return (result.first as BigInt).toInt();
  }

  /// 查询余额
  Future<BigInt> balanceOf(String address) async {
    final result = await client.call(
      contract: contract,
      function: contract.function('balanceOf'),
      params: [EthereumAddress.fromHex(address)],
    );
    return result.first as BigInt;
  }

  /// 查询余额（格式化）
  Future<String> balanceOfFormatted(String address) async {
    final balance = await balanceOf(address);
    final dec = await decimals();
    final divisor = BigInt.from(10).pow(dec);
    final whole = balance ~/ divisor;
    final fraction = (balance % divisor).toString().padLeft(dec, '0');
    return '$whole.${fraction.substring(0, 4)}';
  }

  /// 转账代币
  Future<String> transfer(
    Credentials credentials,
    String to,
    BigInt amount, {
    required int chainId,
  }) async {
    return await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: contract.function('transfer'),
        parameters: [EthereumAddress.fromHex(to), amount],
      ),
      chainId: chainId,
    );
  }
}

/// ERC-20 标准 ABI
const _erc20Abi = '''[
  {"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},
  {"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},
  {"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"},
  {"constant":false,"inputs":[{"name":"spender","type":"address"},{"name":"amount","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"type":"function"},
  {"constant":true,"inputs":[{"name":"owner","type":"address"},{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"type":"function"},
  {"constant":false,"inputs":[{"name":"from","type":"address"},{"name":"to","type":"address"},{"name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"type":"function"}
]''';
```

## 7.7 本章小结与练习

### 你学到了什么

- Flutter Web3 项目结构和核心依赖
- 以太坊客户端封装（web3dart）
- HD 钱包实现：助记词生成、密钥派生、安全存储
- Riverpod 状态管理：钱包状态、余额查询、链切换
- 核心 UI：钱包首页、发送交易、ERC-20 代币交互

### 动手练习

1. **接收页面**：实现接收页面，显示当前地址的二维码（使用 qr_flutter），支持复制地址和分享

2. **代币列表**：实现代币列表页面，显示用户持有的所有 ERC-20 代币余额（提示：使用 Multicall 合约批量查询）

3. **交易历史**：实现交易历史页面，从 Etherscan API 获取地址的交易记录，按时间倒序展示

4. **多链切换**：完善链切换功能，切换链后自动刷新余额和代币列表

### 下一章预告

下一章我们进入第一个综合实战项目——DEX 去中心化交易所，整合 Go 后端 + Solidity 合约 + Flutter 前端，完成一个可以真正交易代币的 DApp。
