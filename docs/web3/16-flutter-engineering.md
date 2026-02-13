# 第 16 章：Flutter 状态管理与工程化

> 前面几章写了很多功能代码，但都是"能跑就行"的状态。这一章把整个 DApp 重构为生产级代码：用 Riverpod 统一管理状态、封装网络层、优化性能、搭建 CI/CD。

## 16.1 Riverpod 状态管理

### 为什么选 Riverpod？

```
Flutter 状态管理方案对比（Web3 DApp 场景）：

setState:     ❌ 只适合简单页面，跨组件共享状态困难
Provider:     ⭐⭐ 可以用，但类型安全差，依赖 BuildContext
GetX:         ⭐⭐ 简单但不够严谨，大项目容易混乱
Bloc:         ⭐⭐⭐ 严谨但模板代码多，Web3 场景过于繁琐
Riverpod:     ⭐⭐⭐⭐⭐ 类型安全、不依赖 Context、支持异步、完美匹配 Web3

Web3 DApp 的状态特点：
- 大量异步操作（链上查询、交易发送）
- 多个数据源（链上数据、API 数据、本地缓存）
- 状态之间有依赖关系（钱包连接 → 余额查询 → 代币列表）
- 需要自动刷新（价格、余额定时更新）

Riverpod 完美匹配这些需求。
```

### Web3 状态建模

```dart
// lib/providers/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';

/// 钱包连接状态
enum WalletStatus { disconnected, connecting, connected, error }

/// 钱包状态
class WalletState {
  final WalletStatus status;
  final String? address;
  final String? mnemonic;
  final int chainId;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.disconnected,
    this.address,
    this.mnemonic,
    this.chainId = 1,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    String? address,
    String? mnemonic,
    int? chainId,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      address: address ?? this.address,
      mnemonic: mnemonic ?? this.mnemonic,
      chainId: chainId ?? this.chainId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isConnected => status == WalletStatus.connected;
}

```dart
/// 钱包状态管理器
class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletState());

  /// 创建新钱包
  Future<void> createWallet() async {
    state = state.copyWith(status: WalletStatus.connecting);
    try {
      final mnemonic = WalletService.generateMnemonic();
      final key = WalletService.deriveEthKey(mnemonic);
      
      await SecureStorageService.saveMnemonic(mnemonic);
      
      state = state.copyWith(
        status: WalletStatus.connected,
        address: key.address.hexEip55,
        mnemonic: mnemonic,
      );
    } catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 导入钱包
  Future<void> importWallet(String mnemonic) async {
    if (!WalletService.validateMnemonic(mnemonic)) {
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: '无效的助记词',
      );
      return;
    }

    state = state.copyWith(status: WalletStatus.connecting);
    try {
      final key = WalletService.deriveEthKey(mnemonic);
      await SecureStorageService.saveMnemonic(mnemonic);
      
      state = state.copyWith(
        status: WalletStatus.connected,
        address: key.address.hexEip55,
        mnemonic: mnemonic,
      );
    } catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 切换链
  void switchChain(int chainId) {
    state = state.copyWith(chainId: chainId);
  }

  /// 断开连接
  Future<void> disconnect() async {
    await SecureStorageService.deleteWallet();
    state = const WalletState();
  }
}

// Provider 定义
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(),
);

/// ETH 余额 Provider（依赖钱包状态）
final ethBalanceProvider = FutureProvider.autoDispose<BigInt>((ref) async {
  final wallet = ref.watch(walletProvider);
  if (!wallet.isConnected) return BigInt.zero;

  final chain = Chains.getByChainId(wallet.chainId);
  final client = EthClient(rpcUrl: chain.rpcUrl, chainId: chain.chainId);
  
  final balance = await client.getBalance(wallet.address!);
  return balance.getInWei;
});

/// 代币列表 Provider
final tokenListProvider = FutureProvider.autoDispose<List<TokenBalance>>((ref) async {
  final wallet = ref.watch(walletProvider);
  if (!wallet.isConnected) return [];

  // 从后端 API 获取代币列表和余额
  // final tokens = await apiService.getTokenBalances(wallet.address!, wallet.chainId);
  return [];
});

class TokenBalance {
  final String symbol;
  final String name;
  final String contractAddress;
  final BigInt balance;
  final int decimals;
  final double priceUsd;

  TokenBalance({
    required this.symbol,
    required this.name,
    required this.contractAddress,
    required this.balance,
    required this.decimals,
    required this.priceUsd,
  });

  double get balanceFormatted => balance / BigInt.from(10).pow(decimals);
  double get valueUsd => balanceFormatted * priceUsd;
}
```

### 在 UI 中使用

```dart
// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final ethBalance = ref.watch(ethBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的钱包'),
        actions: [
          // 链切换按钮
          PopupMenuButton<int>(
            onSelected: (chainId) {
              ref.read(walletProvider.notifier).switchChain(chainId);
            },
            itemBuilder: (context) => Chains.all.map((chain) {
              return PopupMenuItem(
                value: chain.chainId,
                child: Text(chain.name),
              );
            }).toList(),
            child: Chip(
              label: Text(Chains.getByChainId(wallet.chainId).name),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 地址和余额
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    _shortenAddress(wallet.address ?? ''),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  ethBalance.when(
                    data: (balance) => Text(
                      '${_formatEth(balance)} ETH',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('错误: $e'),
                  ),
                ],
              ),
            ),
          ),
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(Icons.arrow_upward, '发送', () {
                Navigator.pushNamed(context, '/send');
              }),
              _actionButton(Icons.arrow_downward, '接收', () {
                Navigator.pushNamed(context, '/receive');
              }),
              _actionButton(Icons.swap_horiz, 'Swap', () {
                Navigator.pushNamed(context, '/swap');
              }),
              _actionButton(Icons.language, 'DApp', () {
                Navigator.pushNamed(context, '/dapp-browser');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 24, child: Icon(icon)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatEth(BigInt wei) {
    final eth = wei / BigInt.from(10).pow(18);
    return eth.toStringAsFixed(4);
  }
}
```

## 16.2 网络层封装

```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';

/// API 客户端封装
class ApiClient {
  late Dio _dio;

  ApiClient({required String baseUrl, String? authToken}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    ));

    // 日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // 重试拦截器
    _dio.interceptors.add(RetryInterceptor(dio: _dio, retries: 3));
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(path, queryParameters: params);
    return response.data as T;
  }

  Future<T> post<T>(String path, {dynamic data}) async {
    final response = await _dio.post(path, data: data);
    return response.data as T;
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;

  RetryInterceptor({required this.dio, this.retries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      for (int i = 0; i < retries; i++) {
        try {
          await Future.delayed(Duration(seconds: i + 1)); // 指数退避
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          if (i == retries - 1) break;
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
```

## 16.3 CI/CD 流水线

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      
      - name: 安装依赖
        run: flutter pub get
      
      - name: 代码分析
        run: flutter analyze
      
      - name: 运行测试
        run: flutter test --coverage
      
      - name: 上传覆盖率
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
      
      - name: 构建 APK
        run: flutter build apk --release
      
      - name: 上传 APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
      
      - name: 构建 Web
        run: flutter build web --release
      
      - name: 部署到 Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: build/web
```

## 16.4 本章小结与练习

### 你学到了什么

- Riverpod 状态管理：StateNotifier、FutureProvider、autoDispose、状态依赖
- Web3 状态建模：钱包状态、链状态、余额状态的分层管理
- 网络层封装：Dio + 拦截器 + 重试机制
- CI/CD：GitHub Actions 自动测试、构建 APK/Web、部署

### 动手练习

1. **完整状态重构**：用 Riverpod 重构前面章节的所有页面
2. **WebSocket 实时推送**：实现价格实时更新（WebSocket 连接 Go 后端）
3. **性能优化**：用 Flutter DevTools 分析并优化代币列表的滚动性能
4. **完整 CI/CD**：搭建包含 lint、test、build、deploy 的完整流水线

### 下一章预告

从下一章开始进入综合实战项目——用前面学到的所有技术，从零构建一个完整的去中心化交易所（DEX）。
