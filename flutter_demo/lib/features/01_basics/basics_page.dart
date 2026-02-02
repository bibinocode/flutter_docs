import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 基础组件模块页面
class BasicsPage extends StatelessWidget {
  const BasicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础组件'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDemoCard(context, icon: '📝', title: 'Text 文本', description: '文本展示、样式、富文本、自定义字体等', route: '/basics/text'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: '🖼️', title: 'Image 图片', description: '本地图片、网络图片、图片缓存、占位图等', route: '/basics/image'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: '🔘', title: 'Button 按钮', description: 'ElevatedButton、FilledButton、OutlinedButton、IconButton 等', route: '/basics/button'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: '⭐', title: 'Icon 图标', description: 'Material Icons、自定义图标、图标按钮等', route: '/basics/icon'),
        ],
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, {required String icon, required String title, required String description, required String route}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
