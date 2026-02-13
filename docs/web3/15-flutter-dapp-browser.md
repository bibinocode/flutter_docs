# 第 15 章：Flutter DApp 浏览器与 DeFi 交互

> 一个完整的 Web3 钱包不仅能转账，还要能访问各种 DApp——Uniswap、OpenSea、Aave 等。这一章实现一个内置 DApp 浏览器（WebView + Web3 Provider 注入），以及原生的 Token Swap 和流动性管理界面。

## 15.1 DApp 浏览器架构

```
DApp 浏览器的工作原理：

┌─────────────────────────────────────────┐
│           Flutter App                    │
│  ┌───────────────────────────────────┐  │
│  │         WebView (InAppWebView)    │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │    DApp 网页 (Uniswap)      │  │  │
│  │  │                             │  │  │
│  │  │  window.ethereum.request()  │──┼──┼──→ JavaScript Bridge
│  │  │                             │  │  │         │
│  │  └─────────────────────────────┘  │  │         │
│  └───────────────────────────────────┘  │         ▼
│                                          │  ┌──────────────┐
│  ┌───────────────────────────────────┐  │  │ 钱包核心      │
│  │  注入的 Web3 Provider (JS)        │  │  │ - 签名交易    │
│  │  - eth_requestAccounts           │  │  │ - 查询余额    │
│  │  - eth_sendTransaction           │  │  │ - 切换网络    │
│  │  - eth_sign                      │  │  │              │
│  │  - wallet_switchEthereumChain    │  │  │              │
│  └───────────────────────────────────┘  │  └──────────────┘
└─────────────────────────────────────────┘

流程：
1. WebView 加载 DApp 网页
2. 注入 JavaScript 代码，模拟 MetaMask 的 window.ethereum
3. DApp 调用 window.ethereum.request() 时
4. JavaScript Bridge 把请求转发给 Flutter
5. Flutter 处理请求（弹出确认框、签名等）
6. 把结果返回给 DApp
```

## 15.2 WebView + Provider 注入

```yaml
# pubspec.yaml 新增依赖
dependencies:
  flutter_inappwebview: ^6.0.0
```

```dart
// lib/features/dapp_browser/dapp_browser_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DAppBrowserPage extends StatefulWidget {
  final String initialUrl;
  const DAppBrowserPage({super.key, required this.initialUrl});

  @override
  State<DAppBrowserPage> createState() => _DAppBrowserPageState();
}

class _DAppBrowserPageState extends State<DAppBrowserPage> {
  InAppWebViewController? _webViewController;
  final _urlController = TextEditingController();
  String _currentUrl = '';
  bool _isLoading = true;

  // 注入的 JavaScript Provider 代码
  String get _injectedProvider => '''
    (function() {
      // 模拟 MetaMask 的 window.ethereum
      const provider = {
        isMetaMask: true,
        chainId: '0x1',
        selectedAddress: null,
        
        request: async function(args) {
          // 通过 Flutter Bridge 发送请求
          return new Promise((resolve, reject) => {
            const id = Date.now().toString();
            
            // 注册回调
            window._web3Callbacks = window._web3Callbacks || {};
            window._web3Callbacks[id] = { resolve, reject };
            
            // 发送给 Flutter
            window.flutter_inappwebview.callHandler(
              'web3Request',
              JSON.stringify({ id, method: args.method, params: args.params || [] })
            );
          });
        },
        
        on: function(event, callback) {
          window._web3Events = window._web3Events || {};
          window._web3Events[event] = window._web3Events[event] || [];
          window._web3Events[event].push(callback);
        },
        
        removeListener: function(event, callback) {
          if (window._web3Events && window._web3Events[event]) {
            window._web3Events[event] = window._web3Events[event]
              .filter(cb => cb !== callback);
          }
        },
        
        emit: function(event, data) {
          if (window._web3Events && window._web3Events[event]) {
            window._web3Events[event].forEach(cb => cb(data));
          }
        }
      };
      
      window.ethereum = provider;
      
      // 响应 Flutter 的回调
      window._resolveWeb3 = function(id, result) {
        if (window._web3Callbacks && window._web3Callbacks[id]) {
          window._web3Callbacks[id].resolve(result);
          delete window._web3Callbacks[id];
        }
      };
      
      window._rejectWeb3 = function(id, error) {
        if (window._web3Callbacks && window._web3Callbacks[id]) {
          window._web3Callbacks[id].reject(new Error(error));
          delete window._web3Callbacks[id];
        }
      };
    })();
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildUrlBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              
              // 注册 JavaScript Bridge
              controller.addJavaScriptHandler(
                handlerName: 'web3Request',
                callback: (args) async {
                  final request = jsonDecode(args[0] as String);
                  await _handleWeb3Request(
                    request['id'],
                    request['method'],
                    request['params'],
                  );
                },
              );
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _currentUrl = url?.toString() ?? '';
              });
            },
            onLoadStop: (controller, url) async {
              // 页面加载完成后注入 Provider
              await controller.evaluateJavascript(source: _injectedProvider);
              setState(() => _isLoading = false);
            },
          ),
          if (_isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildUrlBar() {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: _urlController..text = _currentUrl,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          prefixIcon: const Icon(Icons.lock, size: 16),
        ),
        style: const TextStyle(fontSize: 13),
        onSubmitted: (url) {
          if (!url.startsWith('http')) url = 'https://$url';
          _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
        },
      ),
    );
  }

  /// 处理 DApp 的 Web3 请求
  Future<void> _handleWeb3Request(String id, String method, List params) async {
    switch (method) {
      case 'eth_requestAccounts':
      case 'eth_accounts':
        // 返回当前钱包地址
        final address = '0xYourWalletAddress'; // 从钱包服务获取
        _resolveRequest(id, [address]);
        break;

      case 'eth_chainId':
        _resolveRequest(id, '0x1'); // 以太坊主网
        break;

      case 'eth_sendTransaction':
        // 弹出交易确认弹窗
        final txParams = params.isNotEmpty ? params[0] : {};
        final confirmed = await _showTransactionConfirmDialog(txParams);
        if (confirmed) {
          // 签名并发送交易
          // final txHash = await walletService.sendTransaction(txParams);
          // _resolveRequest(id, txHash);
        } else {
          _rejectRequest(id, 'User rejected the request');
        }
        break;

      case 'personal_sign':
        // 弹出签名确认弹窗
        final message = params.isNotEmpty ? params[0] : '';
        final confirmed = await _showSignConfirmDialog(message);
        if (confirmed) {
          // 签名消息
          // final signature = await walletService.signMessage(message);
          // _resolveRequest(id, signature);
        } else {
          _rejectRequest(id, 'User rejected the request');
        }
        break;

      default:
        _rejectRequest(id, 'Unsupported method: $method');
    }
  }

  void _resolveRequest(String id, dynamic result) {
    final resultJson = jsonEncode(result);
    _webViewController?.evaluateJavascript(
      source: 'window._resolveWeb3("$id", $resultJson)',
    );
  }

  void _rejectRequest(String id, String error) {
    _webViewController?.evaluateJavascript(
      source: 'window._rejectWeb3("$id", "$error")',
    );
  }

  Future<bool> _showTransactionConfirmDialog(Map txParams) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认交易'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('接收地址: ${txParams['to'] ?? 'Unknown'}'),
            Text('金额: ${txParams['value'] ?? '0'} Wei'),
            Text('Data: ${(txParams['data'] ?? '').toString().substring(0, 20)}...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showSignConfirmDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('签名请求'),
        content: Text('DApp 请求签名以下消息:\n\n$message'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('拒绝'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('签名'),
          ),
        ],
      ),
    ) ?? false;
  }
}
```

## 15.3 Token Swap UI

```dart
// lib/features/swap/swap_page.dart
import 'package:flutter/material.dart';

class SwapPage extends StatefulWidget {
  const SwapPage({super.key});

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  TokenInfo? _fromToken;
  TokenInfo? _toToken;
  final _fromAmountController = TextEditingController();
  String _toAmount = '0.0';
  double _slippage = 0.5; // 默认 0.5% 滑点
  SwapQuote? _quote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSlippageSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // From Token
            _buildTokenInput(
              label: '卖出',
              token: _fromToken,
              controller: _fromAmountController,
              onTokenSelect: () => _selectToken(isFrom: true),
              onAmountChanged: _onFromAmountChanged,
            ),
            
            // 交换按钮
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton.filled(
                onPressed: _swapTokens,
                icon: const Icon(Icons.swap_vert),
              ),
            ),
            
            // To Token
            _buildTokenInput(
              label: '买入',
              token: _toToken,
              amount: _toAmount,
              onTokenSelect: () => _selectToken(isFrom: false),
              readOnly: true,
            ),
            
            const SizedBox(height: 16),
            
            // 交易详情
            if (_quote != null) _buildQuoteDetails(),
            
            const Spacer(),
            
            // Swap 按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _fromToken != null && _toToken != null
                    ? _executeSwap
                    : null,
                child: const Text('Swap', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInput({
    required String label,
    TokenInfo? token,
    TextEditingController? controller,
    String? amount,
    required VoidCallback onTokenSelect,
    ValueChanged<String>? onAmountChanged,
    bool readOnly = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                // 代币选择器
                InkWell(
                  onTap: onTokenSelect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (token != null) ...[
                          CircleAvatar(radius: 12, child: Text(token.symbol[0])),
                          const SizedBox(width: 8),
                          Text(token.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ] else
                          const Text('选择代币'),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 金额输入
                Expanded(
                  child: readOnly
                      ? Text(
                          amount ?? '0.0',
                          style: const TextStyle(fontSize: 24),
                          textAlign: TextAlign.right,
                        )
                      : TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 24),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.0',
                          ),
                          onChanged: onAmountChanged,
                        ),
                ),
              ],
            ),
            if (token != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '余额: ${token.balance}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _detailRow('汇率', '1 ${_fromToken!.symbol} = ${_quote!.rate} ${_toToken!.symbol}'),
            _detailRow('价格影响', '${_quote!.priceImpact}%'),
            _detailRow('最少收到', '${_quote!.minimumReceived} ${_toToken!.symbol}'),
            _detailRow('滑点容忍', '$_slippage%'),
            _detailRow('网络费用', '~\$${_quote!.gasCostUsd}'),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value),
        ],
      ),
    );
  }

  void _onFromAmountChanged(String value) {
    // 调用后端 API 获取报价
    // final quote = await swapService.getQuote(fromToken, toToken, amount);
    // setState(() { _toAmount = quote.outputAmount; _quote = quote; });
  }

  void _swapTokens() {
    setState(() {
      final temp = _fromToken;
      _fromToken = _toToken;
      _toToken = temp;
    });
  }

  void _selectToken({required bool isFrom}) {
    // 打开代币选择器底部弹窗
  }

  void _showSlippageSettings() {
    // 滑点设置弹窗
  }

  void _executeSwap() {
    // 执行 Swap 交易
  }
}

// 数据模型
class TokenInfo {
  final String symbol;
  final String address;
  final int decimals;
  final String balance;
  TokenInfo({required this.symbol, required this.address, required this.decimals, required this.balance});
}

class SwapQuote {
  final String rate;
  final String priceImpact;
  final String minimumReceived;
  final String gasCostUsd;
  SwapQuote({required this.rate, required this.priceImpact, required this.minimumReceived, required this.gasCostUsd});
}
```

## 15.4 多链支持

```dart
// lib/core/blockchain/chain_config.dart

/// 链配置
class ChainConfig {
  final int chainId;
  final String name;
  final String symbol;
  final String rpcUrl;
  final String explorerUrl;
  final String iconPath;
  final int decimals;

  const ChainConfig({
    required this.chainId,
    required this.name,
    required this.symbol,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.iconPath,
    this.decimals = 18,
  });

  String get chainIdHex => '0x${chainId.toRadixString(16)}';
}

/// 预定义链配置
class Chains {
  static const ethereum = ChainConfig(
    chainId: 1,
    name: 'Ethereum',
    symbol: 'ETH',
    rpcUrl: 'https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY',
    explorerUrl: 'https://etherscan.io',
    iconPath: 'assets/chains/ethereum.png',
  );

  static const bsc = ChainConfig(
    chainId: 56,
    name: 'BNB Chain',
    symbol: 'BNB',
    rpcUrl: 'https://bsc-dataseed.binance.org',
    explorerUrl: 'https://bscscan.com',
    iconPath: 'assets/chains/bsc.png',
  );

  static const polygon = ChainConfig(
    chainId: 137,
    name: 'Polygon',
    symbol: 'MATIC',
    rpcUrl: 'https://polygon-rpc.com',
    explorerUrl: 'https://polygonscan.com',
    iconPath: 'assets/chains/polygon.png',
  );

  static const arbitrum = ChainConfig(
    chainId: 42161,
    name: 'Arbitrum One',
    symbol: 'ETH',
    rpcUrl: 'https://arb1.arbitrum.io/rpc',
    explorerUrl: 'https://arbiscan.io',
    iconPath: 'assets/chains/arbitrum.png',
  );

  // 测试网
  static const sepolia = ChainConfig(
    chainId: 11155111,
    name: 'Sepolia Testnet',
    symbol: 'ETH',
    rpcUrl: 'https://rpc.sepolia.org',
    explorerUrl: 'https://sepolia.etherscan.io',
    iconPath: 'assets/chains/ethereum.png',
  );

  static const all = [ethereum, bsc, polygon, arbitrum, sepolia];

  static ChainConfig getByChainId(int chainId) {
    return all.firstWhere(
      (c) => c.chainId == chainId,
      orElse: () => ethereum,
    );
  }
}
```

## 15.5 本章小结与练习

### 你学到了什么

- DApp 浏览器架构：WebView + JavaScript Bridge + Provider 注入
- EIP-1193 Provider 实现：eth_requestAccounts、eth_sendTransaction、personal_sign
- 交易确认弹窗：安全地展示交易详情让用户确认
- Token Swap UI：代币选择器、金额输入、报价展示、滑点设置
- 多链配置管理：链 ID、RPC URL、区块浏览器的统一管理

### 动手练习

1. **完善 DApp 浏览器**：添加更多 EIP-1193 方法支持（wallet_switchEthereumChain、eth_getBalance 等）
2. **代币选择器**：实现一个搜索代币的底部弹窗，支持按名称/地址搜索
3. **流动性管理页面**：实现 Uniswap V3 风格的添加/移除流动性 UI
4. **交易状态追踪**：实现交易发送后的状态轮询（Pending → Confirmed → Failed）

### 下一章预告

下一章是 Flutter 工程化——Riverpod 状态管理重构、网络层封装、性能优化、CI/CD 流水线搭建。
