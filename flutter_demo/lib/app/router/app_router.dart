import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_page.dart';
import '../../features/01_basics/basics_page.dart';
import '../../features/01_basics/text_demo.dart';
import '../../features/01_basics/image_demo.dart';
import '../../features/01_basics/button_demo.dart';
import '../../features/01_basics/icon_demo.dart';
import '../../features/02_layout/layout_page.dart';
import '../../features/02_layout/row_column_demo.dart';
import '../../features/02_layout/stack_demo.dart';
import '../../features/02_layout/flex_demo.dart';
import '../../features/02_layout/container_demo.dart';
import '../../features/03_scrolling/scrolling_page.dart';
import '../../features/03_scrolling/listview_demo.dart';
import '../../features/03_scrolling/gridview_demo.dart';
import '../../features/03_scrolling/pageview_demo.dart';
import '../../features/03_scrolling/custom_scrollview_demo.dart';
import '../../features/04_forms/forms_page.dart';
import '../../features/04_forms/textfield_demo.dart';
import '../../features/04_forms/checkbox_demo.dart';
import '../../features/04_forms/form_demo.dart';
import '../../features/05_navigation/navigation_page.dart';
import '../../features/05_navigation/tabs_demo.dart';
import '../../features/05_navigation/drawer_demo.dart';
import '../../features/05_navigation/bottomnav_demo.dart';
import '../../features/06_state_riverpod/riverpod_page.dart';
import '../../features/07_state_getx/getx_page.dart';
import '../../features/08_network/network_page.dart';
import '../../features/09_storage/storage_page.dart';
import '../../features/10_animation/animation_page.dart';
import '../../features/11_gesture/gesture_page.dart';
import '../../features/12_permission/permission_page.dart';
import '../../features/13_platform/platform_page.dart';
import '../../features/14_testing/testing_page.dart';
import '../../features/15_advanced/advanced_page.dart';
import '../../shared/widgets/custom_widgets_page.dart';

/// 主题模式状态管理 Notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() => ThemeModeNotifier());

/// 路由配置 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // 首页
      GoRoute(path: '/', name: 'home', builder: (context, state) => const HomePage()),

      // 01 基础组件
      GoRoute(
        path: '/basics',
        name: 'basics',
        builder: (context, state) => const BasicsPage(),
        routes: [
          GoRoute(path: 'text', name: 'text-demo', builder: (context, state) => const TextDemoPage()),
          GoRoute(path: 'image', name: 'image-demo', builder: (context, state) => const ImageDemoPage()),
          GoRoute(path: 'button', name: 'button-demo', builder: (context, state) => const ButtonDemoPage()),
          GoRoute(path: 'icon', name: 'icon-demo', builder: (context, state) => const IconDemoPage()),
        ],
      ),

      // 02 布局系统
      GoRoute(
        path: '/layout',
        name: 'layout',
        builder: (context, state) => const LayoutPage(),
        routes: [
          GoRoute(path: 'row-column', name: 'row-column-demo', builder: (context, state) => const RowColumnDemoPage()),
          GoRoute(path: 'stack', name: 'stack-demo', builder: (context, state) => const StackDemoPage()),
          GoRoute(path: 'flex', name: 'flex-demo', builder: (context, state) => const FlexDemoPage()),
          GoRoute(path: 'container', name: 'container-demo', builder: (context, state) => const ContainerDemoPage()),
        ],
      ),

      // 03 滚动组件
      GoRoute(
        path: '/scrolling',
        name: 'scrolling',
        builder: (context, state) => const ScrollingPage(),
        routes: [
          GoRoute(path: 'listview', name: 'listview-demo', builder: (context, state) => const ListViewDemoPage()),
          GoRoute(path: 'gridview', name: 'gridview-demo', builder: (context, state) => const GridViewDemoPage()),
          GoRoute(path: 'pageview', name: 'pageview-demo', builder: (context, state) => const PageViewDemoPage()),
          GoRoute(path: 'custom', name: 'custom-scrollview-demo', builder: (context, state) => const CustomScrollViewDemoPage()),
        ],
      ),

      // 04 表单输入
      GoRoute(
        path: '/forms',
        name: 'forms',
        builder: (context, state) => const FormsPage(),
        routes: [
          GoRoute(path: 'textfield', name: 'textfield-demo', builder: (context, state) => const TextFieldDemoPage()),
          GoRoute(path: 'checkbox', name: 'checkbox-demo', builder: (context, state) => const CheckboxDemoPage()),
          GoRoute(path: 'form', name: 'form-demo', builder: (context, state) => const FormDemoPage()),
        ],
      ),

      // 05 导航路由
      GoRoute(
        path: '/navigation',
        name: 'navigation',
        builder: (context, state) => const NavigationDemoPage(),
        routes: [
          GoRoute(path: 'tabs', name: 'tabs-demo', builder: (context, state) => const TabsDemoPage()),
          GoRoute(path: 'drawer', name: 'drawer-demo', builder: (context, state) => const DrawerDemoPage()),
          GoRoute(path: 'bottomnav', name: 'bottomnav-demo', builder: (context, state) => const BottomNavDemoPage()),
        ],
      ),

      // 06 Riverpod 状态管理
      GoRoute(path: '/riverpod', name: 'riverpod', builder: (context, state) => const RiverpodPage()),

      // 07 GetX 状态管理
      GoRoute(path: '/getx', name: 'getx', builder: (context, state) => const GetxPage()),

      // 08 网络请求
      GoRoute(path: '/network', name: 'network', builder: (context, state) => const NetworkPage()),

      // 09 数据存储
      GoRoute(path: '/storage', name: 'storage', builder: (context, state) => const StoragePage()),

      // 10 动画效果
      GoRoute(path: '/animation', name: 'animation', builder: (context, state) => const AnimationPage()),

      // 11 手势交互
      GoRoute(path: '/gesture', name: 'gesture', builder: (context, state) => const GesturePage()),

      // 12 权限管理
      GoRoute(path: '/permission', name: 'permission', builder: (context, state) => const PermissionPage()),

      // 13 平台适配
      GoRoute(path: '/platform', name: 'platform', builder: (context, state) => const PlatformPage()),

      // 14 测试
      GoRoute(path: '/testing', name: 'testing', builder: (context, state) => const TestingPage()),

      // 15 进阶技巧
      GoRoute(path: '/advanced', name: 'advanced', builder: (context, state) => const AdvancedPage()),

      // 自定义组件库
      GoRoute(path: '/widgets', name: 'custom-widgets', builder: (context, state) => const CustomWidgetsPage()),
    ],

    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('路径 "${state.uri.path}" 不存在'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/'), child: const Text('返回首页')),
          ],
        ),
      ),
    ),
  );
});
