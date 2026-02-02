import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 导航路由模块页面
class NavigationDemoPage extends StatelessWidget {
  const NavigationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航路由')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDemoCard(context, icon: Icons.tab, title: 'TabBar', desc: '选项卡切换导航', route: '/navigation/tabs'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: Icons.menu, title: 'Drawer', desc: '侧边抽屉导航', route: '/navigation/drawer'),
          const SizedBox(height: 12),
          _buildDemoCard(context, icon: Icons.navigation, title: 'BottomNavigationBar', desc: '底部导航栏', route: '/navigation/bottomnav'),
          const SizedBox(height: 24),
          _buildInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, {required IconData icon, required String title, required String desc, required String route}) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('本项目导航方案', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('go_router', '声明式路由管理'),
            _buildInfoItem('嵌套路由', '模块化页面结构'),
            _buildInfoItem('路径参数', '/detail/:id 动态路由'),
            _buildInfoItem('重定向', '登录状态检查'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(
              title,
              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc)),
        ],
      ),
    );
  }
}
