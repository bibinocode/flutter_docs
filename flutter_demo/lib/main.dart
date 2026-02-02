import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  runApp(const ProviderScope(child: FlutterDemoApp()));
}

/// Flutter 学习聚合 Demo App
///
/// 这是一个用于学习 Flutter 的示例项目，包含了 Flutter 开发中常用的功能模块：
/// - 基础组件展示
/// - 布局系统
/// - 状态管理（Riverpod、GetX）
/// - 网络请求
/// - 本地存储
/// - 动画效果
/// - 手势交互
/// - 权限管理
/// - 平台适配
class FlutterDemoApp extends ConsumerWidget {
  const FlutterDemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Flutter 学习聚合',
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // 路由配置
      routerConfig: router,
    );
  }
}
