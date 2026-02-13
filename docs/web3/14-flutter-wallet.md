# 第 14 章：Flutter 钱包深度开发

> 钱包是 Web3 用户的入口——没有钱包就无法和区块链交互。这一章带你用 Flutter 开发一个完整的跨平台 HD 钱包，支持助记词生成、多链地址派生、安全存储、交易签名、代币管理。学完这章，你就能做出一个类似 MetaMask 移动版的产品。

## 14.1 钱包架构设计

```
Flutter 钱包架构：
┌─────────────────────────────────────────────────┐
│                    UI 层                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ 创建钱包  │ │ 资产总览  │ │ 发送/接收交易     │ │
│  │ 导入钱包  │ │ 代币列表  │ │ 交易历史         │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
├─────────────────────────────────────────────────┤
│                 状态管理层 (Riverpod)             │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ 钱包状态  │ │ 链状态    │ │ 交易状态         │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
├─────────────────────────────────────────────────┤
│                   核心层                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ HD 钱包   │ │ 链交互    │ │ 安全存储         │ │
│  │ 密钥派生  │ │ web3dart │ │ SecureStorage    │ │
│  │ BIP-44   │ │ RPC 调用  │ │ 生物识别         │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
└─────────────────────────────────────────────────┘
```

## 14.2 HD 钱包核心实现

### 依赖配置

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Web3 核心
  web3dart: ^2.7.3
  bip39: ^1.0.6              # 助记词生成
  bip32: ^2.0.0              # HD 密钥派生
  hex: ^0.2.0                # 十六进制编解码
  convert: ^3.1.1
  
  # 安全存储
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.8         # 生物识别
  
  # 状态管理
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # 网络
  dio: ^5.4.0
  web_socket_channel: ^2.4.0
  
  # UI
  qr_flutter: ^4.1.0         # 二维码生成
  mobile_scanner: ^3.5.6      # 二维码扫描
  cached_network_image: ^3.3.1
  fl_chart: ^0.66.0           # 图表

### 钱包核心服务

```dart
// lib/core/wallet/wallet_service.dart
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/web3dart.dart';
import 'package:hex/hex.dart';

/// HD 钱包服务 - 管理助记词、密钥派生、地址生成
class WalletService {
  
  /// 生成新的助记词（12 个单词）
  static String generateMnemonic() {
    return bip39.generateMnemonic();
    // 返回类似: "abandon ability able about above absent ..."
  }

  /// 验证助记词是否有效
  static bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  /// 从助记词派生以太坊钱包
  /// BIP-44 路径: m/44'/60'/0'/0/index
  ///   44'  = BIP-44 标准
  ///   60'  = 以太坊 (coin type)
  ///   0'   = 第一个账户
  ///   0    = 外部链（接收地址）
  ///   index = 地址索引
  static EthPrivateKey deriveEthKey(String mnemonic, {int index = 0}) {
    // 1. 助记词 → 种子
    final seed = bip39.mnemonicToSeed(mnemonic);
    
    // 2. 种子 → HD 根密钥
    final root = bip32.BIP32.fromSeed(seed);
    
    // 3. 按 BIP-44 路径派生子密钥
    final child = root.derivePath("m/44'/60'/0'/0/$index");
    
    // 4. 私钥 → 以太坊凭证
    final privateKey = EthPrivateKey(Uint8List.fromList(child.privateKey!));
    
    return privateKey;
  }

  /// 从助记词生成多个地址
  static List<WalletAccount> deriveAccounts(String mnemonic, {int count = 5}) {
    final accounts = <WalletAccount>[];
    
    for (int i = 0; i < count; i++) {
      final key = deriveEthKey(mnemonic, index: i);
      final address = key.address;
      
      accounts.add(WalletAccount(
        index: i,
        address: address.hexEip55,
        path: "m/44'/60'/0'/0/$i",
      ));
    }
    
    return accounts;
  }

  /// 多链地址派生
  /// 不同链使用不同的 coin type
  static Map<String, String> deriveMultiChainAddresses(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    
    // EVM 链共享同一个地址（coin type = 60）
    final ethChild = root.derivePath("m/44'/60'/0'/0/0");
    final ethKey = EthPrivateKey(Uint8List.fromList(ethChild.privateKey!));
    final evmAddress = ethKey.address.hexEip55;
    
    return {
      'ethereum': evmAddress,
      'bsc': evmAddress,        // BSC 和 ETH 地址相同
      'polygon': evmAddress,    // Polygon 也是
      'arbitrum': evmAddress,   // Arbitrum 也是
      // Solana 使用不同的派生路径和地址格式
      // 'solana': deriveSolanaAddress(mnemonic),
    };
  }
}

/// 钱包账户信息
class WalletAccount {
  final int index;
  final String address;
  final String path;
  
  WalletAccount({
    required this.index,
    required this.address,
    required this.path,
  });
}
```

### 安全存储

```dart
// lib/core/wallet/secure_storage.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// 安全存储服务 - 加密存储助记词和私钥
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  
  static const _mnemonicKey = 'wallet_mnemonic';
  static const _pinKey = 'wallet_pin';
  static const _biometricKey = 'biometric_enabled';

  /// 保存助记词（加密存储）
  static Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(key: _mnemonicKey, value: mnemonic);
  }

  /// 读取助记词
  static Future<String?> getMnemonic() async {
    return await _storage.read(key: _mnemonicKey);
  }

  /// 删除钱包数据
  static Future<void> deleteWallet() async {
    await _storage.delete(key: _mnemonicKey);
  }

  /// 检查是否已创建钱包
  static Future<bool> hasWallet() async {
    final mnemonic = await _storage.read(key: _mnemonicKey);
    return mnemonic != null && mnemonic.isNotEmpty;
  }

  /// 设置 PIN 码
  static Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// 验证 PIN 码
  static Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored == pin;
  }

  /// 启用/禁用生物识别
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  /// 生物识别认证
  static Future<bool> authenticateWithBiometrics() async {
    final localAuth = LocalAuthentication();
    
    // 检查设备是否支持
    final canAuth = await localAuth.canCheckBiometrics;
    if (!canAuth) return false;

    try {
      return await localAuth.authenticate(
        localizedReason: '请验证身份以访问钱包',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

## 14.3 交易功能实现

```dart
// lib/core/blockchain/eth_client.dart
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

/// 以太坊客户端 - 封装链上交互
class EthClient {
  late Web3Client _client;
  final String rpcUrl;
  final int chainId;

  EthClient({required this.rpcUrl, required this.chainId}) {
    _client = Web3Client(rpcUrl, http.Client());
  }

  /// 查询 ETH 余额
  Future<EtherAmount> getBalance(String address) async {
    final addr = EthereumAddress.fromHex(address);
    return await _client.getBalance(addr);
  }

  /// 查询 ERC-20 代币余额
  Future<BigInt> getTokenBalance(String tokenAddress, String walletAddress) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20Abi, 'ERC20'),
      EthereumAddress.fromHex(tokenAddress),
    );
    
    final balanceOf = contract.function('balanceOf');
    final result = await _client.call(
      contract: contract,
      function: balanceOf,
      params: [EthereumAddress.fromHex(walletAddress)],
    );
    
    return result.first as BigInt;
  }

  /// 估算 Gas
  Future<GasEstimate> estimateGas({
    required String from,
    required String to,
    required BigInt value,
    String? data,
  }) async {
    final gasPrice = await _client.getGasPrice();
    final gasLimit = await _client.estimateGas(
      sender: EthereumAddress.fromHex(from),
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.inWei(value),
    );

    final totalCost = gasPrice.getInWei * gasLimit;

    return GasEstimate(
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      totalCostWei: totalCost,
    );
  }

  /// 发送 ETH 交易
  Future<String> sendEth({
    required EthPrivateKey credentials,
    required String to,
    required BigInt valueWei,
    BigInt? gasPrice,
    int? gasLimit,
  }) async {
    final tx = Transaction(
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.inWei(valueWei),
      maxGas: gasLimit,
      gasPrice: gasPrice != null ? EtherAmount.inWei(gasPrice) : null,
    );

    final txHash = await _client.sendTransaction(
      credentials,
      tx,
      chainId: chainId,
    );

    return txHash;
  }

  /// 发送 ERC-20 代币
  Future<String> sendToken({
    required EthPrivateKey credentials,
    required String tokenAddress,
    required String to,
    required BigInt amount,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20Abi, 'ERC20'),
      EthereumAddress.fromHex(tokenAddress),
    );

    final transfer = contract.function('transfer');
    
    final txHash = await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transfer,
        parameters: [EthereumAddress.fromHex(to), amount],
      ),
      chainId: chainId,
    );

    return txHash;
  }

  /// 查询交易状态
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await _client.getTransactionReceipt(txHash);
  }

  void dispose() {
    _client.dispose();
  }
}

class GasEstimate {
  final EtherAmount gasPrice;
  final BigInt gasLimit;
  final BigInt totalCostWei;

  GasEstimate({
    required this.gasPrice,
    required this.gasLimit,
    required this.totalCostWei,
  });

  /// 格式化为 ETH
  String get totalCostEth {
    final ethValue = totalCostWei / BigInt.from(10).pow(18);
    return '${(totalCostWei / BigInt.from(10).pow(14)).toDouble() / 10000} ETH';
  }
}

// ERC-20 ABI（简化版）
const _erc20Abi = '''[
  {"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},
  {"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"}
]''';
```

## 14.4 钱包 UI 实现

### 创建/导入钱包页面

```dart
// lib/features/wallet/create_wallet_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({super.key});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  String? _mnemonic;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建钱包')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _mnemonic == null
            ? _buildCreateStep()
            : _confirmed
                ? _buildSuccessStep()
                : _buildBackupStep(),
      ),
    );
  }

  Widget _buildCreateStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          '创建新钱包',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '我们将为你生成一组助记词，请务必安全备份',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 48),
        FilledButton.icon(
          onPressed: () {
            setState(() {
              _mnemonic = WalletService.generateMnemonic();
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('生成助记词'),
        ),
      ],
    );
  }

  Widget _buildBackupStep() {
    final words = _mnemonic!.split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚠️ 请安全备份你的助记词',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '这是恢复钱包的唯一方式。请抄写在纸上，不要截图或复制到剪贴板。',
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 24),
        // 助记词网格
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(words.length, (index) {
            return Chip(
              avatar: CircleAvatar(
                radius: 12,
                child: Text('${index + 1}', style: const TextStyle(fontSize: 10)),
              ),
              label: Text(words[index]),
            );
          }),
        ),
        const Spacer(),
        // 复制按钮（开发用，生产环境应该移除）
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _mnemonic!));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已复制（仅开发用）')),
            );
          },
          icon: const Icon(Icons.copy),
          label: const Text('复制助记词'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              // 保存助记词
              await SecureStorageService.saveMnemonic(_mnemonic!);
              setState(() => _confirmed = true);
            },
            child: const Text('我已安全备份'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    final accounts = WalletService.deriveAccounts(_mnemonic!);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text('钱包创建成功！', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        Text(
          accounts.first.address,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        const SizedBox(height: 48),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
          child: const Text('进入钱包'),
        ),
      ],
    );
  }
}
```

### 发送交易页面

```dart
// lib/features/wallet/send_transaction_page.dart
import 'package:flutter/material.dart';

class SendTransactionPage extends StatefulWidget {
  const SendTransactionPage({super.key});

  @override
  State<SendTransactionPage> createState() => _SendTransactionPageState();
}

class _SendTransactionPageState extends State<SendTransactionPage> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  GasEstimate? _gasEstimate;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发送 ETH')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 收款地址
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: '收款地址',
                hintText: '0x...',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanQRCode,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 金额
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '金额 (ETH)',
                hintText: '0.0',
                prefixIcon: Icon(Icons.monetization_on),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _estimateGas(),
            ),
            const SizedBox(height: 24),

            // Gas 估算
            if (_gasEstimate != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('交易费用估算',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildGasRow('Gas Price',
                          '${_gasEstimate!.gasPrice.getInWei / BigInt.from(10).pow(9)} Gwei'),
                      _buildGasRow('Gas Limit', '${_gasEstimate!.gasLimit}'),
                      const Divider(),
                      _buildGasRow('预估费用', _gasEstimate!.totalCostEth,
                          bold: true),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // 发送按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _sending ? null : _sendTransaction,
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('确认发送', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGasRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }

  Future<void> _estimateGas() async {
    // 估算 Gas 费用
    // final estimate = await ethClient.estimateGas(...);
    // setState(() => _gasEstimate = estimate);
  }

  Future<void> _scanQRCode() async {
    // 扫描二维码获取地址
  }

  Future<void> _sendTransaction() async {
    // 1. 生物识别验证
    final authenticated = await SecureStorageService.authenticateWithBiometrics();
    if (!authenticated) return;

    setState(() => _sending = true);

    try {
      // 2. 获取私钥
      final mnemonic = await SecureStorageService.getMnemonic();
      final credentials = WalletService.deriveEthKey(mnemonic!);

      // 3. 发送交易
      // final txHash = await ethClient.sendEth(
      //   credentials: credentials,
      //   to: _addressController.text,
      //   valueWei: parseEther(_amountController.text),
      // );

      // 4. 显示结果
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('交易已发送！')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    } finally {
      setState(() => _sending = false);
    }
  }
}
```

## 14.5 本章小结与练习

### 你学到了什么

- HD 钱包完整实现：助记词生成、BIP-44 路径派生、多链地址生成
- 安全存储：flutter_secure_storage 加密存储、生物识别认证
- 链交互封装：ETH 余额查询、ERC-20 代币操作、Gas 估算、交易发送
- 钱包 UI：创建/导入钱包流程、助记词备份、发送交易页面
- 交易安全流程：生物识别 → 获取私钥 → 签名 → 发送 → 状态追踪

### 动手练习

1. **导入钱包**：实现通过助记词导入已有钱包的功能
2. **代币列表**：实现 ERC-20 代币列表页面，支持添加自定义代币
3. **交易历史**：调用 Etherscan API 获取并展示交易历史
4. **多链切换**：实现 Ethereum / BSC / Polygon 链切换功能
5. **收款页面**：生成包含钱包地址的二维码，支持分享

### 下一章预告

下一章开发 Flutter DApp 浏览器和 DeFi 交互界面——内置 WebView 注入 Web3 Provider，实现 Token Swap UI 和流动性管理页面。
