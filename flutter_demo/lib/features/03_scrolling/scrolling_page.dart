import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 滚动组件模块页面
class ScrollingPage extends StatelessWidget {
  const ScrollingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('滚动组件')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDemoCard(context, icon: '📜', title: 'ListView', description: '最常用的滚动列表组件', route: '/scrolling/listview'),
          _buildDemoCard(context, icon: '🔲', title: 'GridView', description: '网格布局滚动组件', route: '/scrolling/gridview'),
          _buildDemoCard(context, icon: '📖', title: 'PageView', description: '页面切换滚动组件', route: '/scrolling/pageview'),
          _buildDemoCard(context, icon: '🎛️', title: 'CustomScrollView', description: '自定义滚动效果，Sliver 系列', route: '/scrolling/custom'),
        ],
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, {required String icon, required String title, required String description, required String route}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
