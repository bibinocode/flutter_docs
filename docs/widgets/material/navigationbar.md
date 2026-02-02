# NavigationBar

`NavigationBar` 是 Material Design 3 的底部导航栏组件，用于在应用的主要目的地之间切换。相比旧版 `BottomNavigationBar`，它提供了更现代的视觉效果和更好的交互体验。

## 基本用法

```dart
Scaffold(
  body: Center(child: Text('当前页面')),
  bottomNavigationBar: NavigationBar(
    selectedIndex: 0,
    onDestinationSelected: (index) {},
    destinations: [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: '首页',
      ),
      NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: '探索',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: '我的',
      ),
    ],
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| selectedIndex | int | 0 | 当前选中的目的地索引 |
| destinations | List\<NavigationDestination\> | 必填 | 导航目的地列表（2-5 个） |
| onDestinationSelected | ValueChanged\<int\>? | null | 目的地选中回调 |
| backgroundColor | Color? | 主题色 | 导航栏背景颜色 |
| elevation | double? | 3.0 | 阴影高度 |
| surfaceTintColor | Color? | 主题色 | 表面着色颜色（M3 特性） |
| shadowColor | Color? | Colors.transparent | 阴影颜色 |
| indicatorColor | Color? | secondaryContainer | 选中指示器颜色 |
| indicatorShape | ShapeBorder? | StadiumBorder | 选中指示器形状 |
| height | double? | 80.0 | 导航栏高度 |
| labelBehavior | NavigationDestinationLabelBehavior? | alwaysShow | 标签显示行为 |
| animationDuration | Duration? | 500ms | 动画持续时间 |
| overlayColor | WidgetStateProperty\<Color?\>? | null | 点击时的水波纹颜色 |

## NavigationDestination 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| icon | Widget | 必填 | 未选中时的图标 |
| selectedIcon | Widget? | null | 选中时的图标 |
| label | String | 必填 | 目的地标签文本 |
| tooltip | String? | null | 长按提示文本 |
| enabled | bool | true | 是否启用该目的地 |

## 使用场景

### 1. 基本底部导航

```dart
class BasicNavigationBar extends StatefulWidget {
  @override
  State<BasicNavigationBar> createState() => _BasicNavigationBarState();
}

class _BasicNavigationBarState extends State<BasicNavigationBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('当前页面: $_selectedIndex'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
```

### 2. 自定义图标样式

```dart
NavigationBar(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) {
    setState(() => _selectedIndex = index);
  },
  indicatorColor: Colors.amber.shade100,
  backgroundColor: Colors.white,
  elevation: 8,
  shadowColor: Colors.black26,
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.dashboard, color: Colors.amber.shade800),
      label: '仪表盘',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.analytics, color: Colors.amber.shade800),
      label: '分析',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.inventory_2, color: Colors.amber.shade800),
      label: '库存',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_circle_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.account_circle, color: Colors.amber.shade800),
      label: '账户',
    ),
  ],
)
```

### 3. 配合 IndexedStack 切换页面

```dart
class NavigationWithIndexedStack extends StatefulWidget {
  @override
  State<NavigationWithIndexedStack> createState() =>
      _NavigationWithIndexedStackState();
}

class _NavigationWithIndexedStackState
    extends State<NavigationWithIndexedStack> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用 IndexedStack 保持页面状态
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: '通知',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
```

### 4. 带角标的导航栏

```dart
class NavigationBarWithBadge extends StatefulWidget {
  @override
  State<NavigationBarWithBadge> createState() => _NavigationBarWithBadgeState();
}

class _NavigationBarWithBadgeState extends State<NavigationBarWithBadge> {
  int _selectedIndex = 0;
  int _notificationCount = 5;
  int _cartCount = 3;

  Widget _buildBadgeIcon(Widget icon, int count) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: icon,
    );
  }

  Widget _buildDotBadge(Widget icon, bool show) {
    return Badge(
      isLabelVisible: show,
      smallSize: 8,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('页面 $_selectedIndex')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            // 点击通知时清除角标
            if (index == 2) _notificationCount = 0;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: _buildBadgeIcon(
              Icon(Icons.shopping_cart_outlined),
              _cartCount,
            ),
            selectedIcon: _buildBadgeIcon(
              Icon(Icons.shopping_cart),
              _cartCount,
            ),
            label: '购物车',
          ),
          NavigationDestination(
            icon: _buildBadgeIcon(
              Icon(Icons.notifications_outlined),
              _notificationCount,
            ),
            selectedIcon: _buildBadgeIcon(
              Icon(Icons.notifications),
              _notificationCount,
            ),
            label: '通知',
          ),
          NavigationDestination(
            icon: _buildDotBadge(Icon(Icons.person_outline), true),
            selectedIcon: _buildDotBadge(Icon(Icons.person), true),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class NavigationBarDemo extends StatefulWidget {
  @override
  State<NavigationBarDemo> createState() => _NavigationBarDemoState();
}

class _NavigationBarDemoState extends State<NavigationBarDemo> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _buildPage('首页', Icons.home, Colors.blue),
    _buildPage('发现', Icons.explore, Colors.orange),
    _buildPage('消息', Icons.message, Colors.green),
    _buildPage('我的', Icons.person, Colors.purple),
  ];

  static Widget _buildPage(String title, IconData icon, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['首页', '发现', '消息', '我的'][_selectedIndex]),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        animationDuration: Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
            tooltip: '返回首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '发现',
            tooltip: '探索新内容',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('3'),
              child: Icon(Icons.message_outlined),
            ),
            selectedIcon: Badge(
              label: Text('3'),
              child: Icon(Icons.message),
            ),
            label: '消息',
            tooltip: '查看消息',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
            tooltip: '个人中心',
          ),
        ],
      ),
    );
  }
}
```

## 最佳实践

### NavigationBar vs BottomNavigationBar

| 特性 | NavigationBar (M3) | BottomNavigationBar (M2) |
|------|-------------------|-------------------------|
| 设计语言 | Material Design 3 | Material Design 2 |
| 选中指示器 | 药丸形状背景 | 无背景或颜色变化 |
| 动画效果 | 更流畅的过渡动画 | 简单的颜色/大小变化 |
| 高度 | 80dp | 56dp |
| 图标位置 | 居中，带指示器 | 居中或偏上 |
| 推荐使用 | 新项目首选 | 旧项目兼容 |

```dart
// ✅ 推荐：使用 NavigationBar（Material 3）
NavigationBar(
  destinations: [...],
)

// ⚠️ 旧版：BottomNavigationBar（Material 2）
BottomNavigationBar(
  items: [...],
)
```

### 使用建议

1. **目的地数量**：保持 3-5 个，超过 5 个考虑使用 NavigationDrawer
2. **图标一致性**：统一使用 outlined/filled 图标对
3. **标签简洁**：使用 1-2 个字的简短标签
4. **状态保持**：配合 IndexedStack 保持页面状态
5. **可访问性**：为每个目的地添加 tooltip

## 相关组件

- [BottomNavigationBar](./bottomnavigationbar.md) - Material 2 底部导航栏
- [NavigationRail](./navigationrail.md) - 侧边导航栏（适用于大屏设备）
- [TabBar](./tabbar.md) - 选项卡栏
- [Scaffold](./scaffold.md) - 页面脚手架

## 官方文档

- [NavigationBar API](https://api.flutter-io.cn/flutter/material/NavigationBar-class.html)
- [NavigationDestination API](https://api.flutter-io.cn/flutter/material/NavigationDestination-class.html)
- [Material 3 Navigation Bar 规范](https://m3.material.io/components/navigation-bar/overview)
