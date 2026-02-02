import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';

/// 首页 - 功能模块导航
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 学习聚合'),
        actions: [
          // 主题切换按钮
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.brightness_auto,
            ),
            onPressed: () {
              final notifier = ref.read(themeModeProvider.notifier);
              if (themeMode == ThemeMode.light) {
                notifier.setThemeMode(ThemeMode.dark);
              } else if (themeMode == ThemeMode.dark) {
                notifier.setThemeMode(ThemeMode.system);
              } else {
                notifier.setThemeMode(ThemeMode.light);
              }
            },
            tooltip: '切换主题',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索框
            TextField(
              decoration: InputDecoration(
                hintText: '搜索组件 / 功能...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () {}),
              ),
            ),
            const SizedBox(height: 24),

            // 功能模块网格
            Text('功能模块', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildModuleGrid(context),

            const SizedBox(height: 32),

            // 自定义组件库入口
            Text('自定义组件库', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildWidgetLibraryCard(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    final modules = [
      _ModuleItem(icon: '📦', title: '基础组件', subtitle: 'Text / Image / Button', route: '/basics', color: Colors.blue),
      _ModuleItem(icon: '📐', title: '布局系统', subtitle: 'Row / Column / Stack', route: '/layout', color: Colors.green),
      _ModuleItem(icon: '📜', title: '滚动列表', subtitle: 'ListView / GridView', route: '/scrolling', color: Colors.orange),
      _ModuleItem(icon: '📝', title: '表单输入', subtitle: 'TextField / Form', route: '/forms', color: Colors.purple),
      _ModuleItem(icon: '🧭', title: '导航路由', subtitle: 'Navigator / go_router', route: '/navigation', color: Colors.teal),
      _ModuleItem(icon: '🔄', title: 'Riverpod', subtitle: '状态管理', route: '/riverpod', color: Colors.indigo),
      _ModuleItem(icon: '⚡', title: 'GetX', subtitle: '状态管理', route: '/getx', color: Colors.pink),
      _ModuleItem(icon: '🌐', title: '网络请求', subtitle: 'Dio / REST API', route: '/network', color: Colors.cyan),
      _ModuleItem(icon: '💾', title: '数据存储', subtitle: 'Hive / SP', route: '/storage', color: Colors.amber),
      _ModuleItem(icon: '✨', title: '动画效果', subtitle: 'Implicit / Explicit', route: '/animation', color: Colors.deepPurple),
      _ModuleItem(icon: '👆', title: '手势交互', subtitle: 'Tap / Drag / Scale', route: '/gesture', color: Colors.red),
      _ModuleItem(icon: '🔐', title: '权限管理', subtitle: 'Camera / Location', route: '/permission', color: Colors.brown),
      _ModuleItem(icon: '💻', title: '平台适配', subtitle: 'Web / Desktop', route: '/platform', color: Colors.blueGrey),
      _ModuleItem(icon: '🧪', title: '测试示例', subtitle: 'Unit / Widget Test', route: '/testing', color: Colors.lime),
      _ModuleItem(icon: '🚀', title: '进阶技巧', subtitle: 'CustomPaint / Isolate', route: '/advanced', color: Colors.deepOrange),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _ModuleCard(module: module);
      },
    );
  }

  Widget _buildWidgetLibraryCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/widgets'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('🎨', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('自定义组件库', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Button / Card / Dialog / Loading / Empty State', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleItem {
  final String icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;

  const _ModuleItem({required this.icon, required this.title, required this.subtitle, required this.route, required this.color});
}

class _ModuleCard extends StatelessWidget {
  final _ModuleItem module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: () => context.push(module.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: module.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(module.icon, style: const TextStyle(fontSize: 20))),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 20, color: colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 12),
              Text(module.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                module.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
