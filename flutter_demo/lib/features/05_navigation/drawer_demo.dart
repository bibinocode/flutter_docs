import 'package:flutter/material.dart';

/// Drawer 抽屉导航演示页面
class DrawerDemoPage extends StatefulWidget {
  const DrawerDemoPage({super.key});

  @override
  State<DrawerDemoPage> createState() => _DrawerDemoPageState();
}

class _DrawerDemoPageState extends State<DrawerDemoPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.home, 'title': '首页', 'subtitle': '返回主页面'},
    {'icon': Icons.person, 'title': '个人中心', 'subtitle': '查看个人信息'},
    {'icon': Icons.shopping_cart, 'title': '购物车', 'subtitle': '查看购物车'},
    {'icon': Icons.favorite, 'title': '收藏', 'subtitle': '我的收藏列表'},
    {'icon': Icons.history, 'title': '历史记录', 'subtitle': '浏览历史'},
    {'icon': Icons.settings, 'title': '设置', 'subtitle': '应用设置'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Drawer 抽屉'),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        actions: [IconButton(icon: const Icon(Icons.menu_open), onPressed: () => _scaffoldKey.currentState?.openEndDrawer(), tooltip: '打开右侧抽屉')],
      ),
      drawer: _buildDrawer(context),
      endDrawer: _buildEndDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '当前选中',
              child: Card(
                child: ListTile(leading: Icon(_menuItems[_selectedIndex]['icon']), title: Text(_menuItems[_selectedIndex]['title']), subtitle: Text(_menuItems[_selectedIndex]['subtitle'])),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '操作说明',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInfoRow(Icons.swipe_right, '从左边缘向右滑动打开左侧抽屉'), _buildInfoRow(Icons.swipe_left, '从右边缘向左滑动打开右侧抽屉'), _buildInfoRow(Icons.menu, '点击左上角图标打开左侧抽屉'), _buildInfoRow(Icons.menu_open, '点击右上角图标打开右侧抽屉')]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '代码要点',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildCodeItem('Scaffold.drawer', '左侧抽屉'), _buildCodeItem('Scaffold.endDrawer', '右侧抽屉'), _buildCodeItem('DrawerHeader', '抽屉头部'), _buildCodeItem('UserAccountsDrawerHeader', '用户信息头部'), _buildCodeItem('NavigationDrawer', 'Material 3 导航抽屉'), _buildCodeItem('ScaffoldState.openDrawer()', '代码打开抽屉')]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            otherAccountsPictures: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: const Icon(Icons.add, color: Colors.blue),
              ),
            ],
            accountName: const Text('Flutter 学习者'),
            accountEmail: const Text('flutter@example.com'),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary])),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = index == _selectedIndex;
                return ListTile(
                  leading: Icon(item['icon'], color: isSelected ? Theme.of(context).colorScheme.primary : null),
                  title: Text(
                    item['title'],
                    style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : null, fontWeight: isSelected ? FontWeight.bold : null),
                  ),
                  subtitle: Text(item['subtitle']),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('退出登录'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('退出登录')));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEndDrawer(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text('Navigation Drawer', style: Theme.of(context).textTheme.titleSmall),
        ),
        ...List.generate(_menuItems.length, (index) {
          final item = _menuItems[index];
          return NavigationDrawerDestination(icon: Icon(item['icon']), label: Text(item['title']));
        }),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 28), child: Divider()),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text('其他', style: Theme.of(context).textTheme.titleSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('帮助'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            onTap: () => Navigator.pop(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildCodeItem(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(
              name,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Text(desc),
        ],
      ),
    );
  }
}
