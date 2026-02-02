import 'package:flutter/material.dart';

/// 底部导航演示页面
class BottomNavDemoPage extends StatefulWidget {
  const BottomNavDemoPage({super.key});

  @override
  State<BottomNavDemoPage> createState() => _BottomNavDemoPageState();
}

class _BottomNavDemoPageState extends State<BottomNavDemoPage> {
  int _demoType = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('底部导航'),
        actions: [
          PopupMenuButton<int>(
            initialValue: _demoType,
            onSelected: (value) => setState(() => _demoType = value),
            itemBuilder: (context) => [const PopupMenuItem(value: 0, child: Text('BottomNavigationBar')), const PopupMenuItem(value: 1, child: Text('NavigationBar (M3)')), const PopupMenuItem(value: 2, child: Text('自定义样式'))],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [Text('切换样式'), Icon(Icons.arrow_drop_down)]),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _demoType, children: const [_ClassicBottomNavDemo(), _NavigationBarDemo(), _CustomBottomNavDemo()]),
    );
  }
}

/// 经典 BottomNavigationBar
class _ClassicBottomNavDemo extends StatefulWidget {
  const _ClassicBottomNavDemo();

  @override
  State<_ClassicBottomNavDemo> createState() => _ClassicBottomNavDemoState();
}

class _ClassicBottomNavDemoState extends State<_ClassicBottomNavDemo> {
  int _currentIndex = 0;
  BottomNavigationBarType _type = BottomNavigationBarType.fixed;

  final List<Map<String, dynamic>> _items = [
    {'icon': Icons.home, 'activeIcon': Icons.home_filled, 'label': '首页'},
    {'icon': Icons.search, 'activeIcon': Icons.search, 'label': '搜索'},
    {'icon': Icons.add_circle_outline, 'activeIcon': Icons.add_circle, 'label': '发布'},
    {'icon': Icons.message_outlined, 'activeIcon': Icons.message, 'label': '消息'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': '我的'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('类型: '),
                ChoiceChip(label: const Text('Fixed'), selected: _type == BottomNavigationBarType.fixed, onSelected: (_) => setState(() => _type = BottomNavigationBarType.fixed)),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Shifting'), selected: _type == BottomNavigationBarType.shifting, onSelected: (_) => setState(() => _type = BottomNavigationBarType.shifting)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_items[_currentIndex]['activeIcon'], size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(_items[_currentIndex]['label'], style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('BottomNavigationBar', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: _type,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: _items.map((item) => BottomNavigationBarItem(icon: Icon(item['icon']), activeIcon: Icon(item['activeIcon']), label: item['label'], backgroundColor: Theme.of(context).colorScheme.primaryContainer)).toList(),
      ),
    );
  }
}

/// Material 3 NavigationBar
class _NavigationBarDemo extends StatefulWidget {
  const _NavigationBarDemo();

  @override
  State<_NavigationBarDemo> createState() => _NavigationBarDemoState();
}

class _NavigationBarDemoState extends State<_NavigationBarDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon([Icons.home, Icons.explore, Icons.bookmark, Icons.person][_currentIndex], size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(['首页', '探索', '收藏', '我的'][_currentIndex], style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('NavigationBar (Material 3)', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Material 3 特点:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text('• 更圆润的指示器'),
                    const Text('• 更好的可访问性'),
                    const Text('• 支持 Badge 徽章'),
                    const Text('• 自动适配主题色'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
          const NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: '探索'),
          NavigationDestination(
            icon: Badge(label: const Text('3'), child: const Icon(Icons.bookmark_border)),
            selectedIcon: Badge(label: const Text('3'), child: const Icon(Icons.bookmark)),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Badge(smallSize: 8, child: const Icon(Icons.person_outline)),
            selectedIcon: Badge(smallSize: 8, child: const Icon(Icons.person)),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 自定义底部导航
class _CustomBottomNavDemo extends StatefulWidget {
  const _CustomBottomNavDemo();

  @override
  State<_CustomBottomNavDemo> createState() => _CustomBottomNavDemoState();
}

class _CustomBottomNavDemoState extends State<_CustomBottomNavDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon([Icons.home, Icons.search, Icons.add, Icons.favorite, Icons.person][_currentIndex], size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(['首页', '搜索', '发布', '收藏', '我的'][_currentIndex], style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('自定义底部导航', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildNavItem(0, Icons.home_outlined, Icons.home, '首页'), _buildNavItem(1, Icons.search, Icons.search, '搜索'), _buildCenterButton(), _buildNavItem(3, Icons.favorite_border, Icons.favorite, '收藏'), _buildNavItem(4, Icons.person_outline, Icons.person, '我的')]),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Icon(_currentIndex == 2 ? Icons.close : Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
