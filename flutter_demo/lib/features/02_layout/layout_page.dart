import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 布局系统模块页面
class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('布局系统'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDemoCard(context, icon: '↔️', title: 'Row & Column', description: '线性布局：水平排列和垂直排列', route: '/layout/row-column'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: '📚', title: 'Stack 层叠布局', description: '组件层叠、定位、对齐', route: '/layout/stack'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: '📏', title: 'Flex 弹性布局', description: 'Expanded、Flexible、Spacer', route: '/layout/flex'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: '📦', title: 'Container 容器', description: '装饰、边距、约束、变换', route: '/layout/container'),
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
