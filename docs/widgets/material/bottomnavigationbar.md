# BottomNavigationBar

`BottomNavigationBar` 是 Material Design 底部导航栏组件（旧版），用于在应用底部显示 3-5 个导航项，方便用户在不同页面间快速切换。这是 Material 2 的设计风格，在 Material 3 中推荐使用 `NavigationBar`。

## 基本用法

```dart
Scaffold(
  body: _pages[_selectedIndex],
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: (index) {
      setState(() => _selectedIndex = index);
    },
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
    ],
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| items | List\<BottomNavigationBarItem\> | 必需 | 导航项列表，至少 2 个 |
| currentIndex | int | 0 | 当前选中项的索引 |
| onTap | ValueChanged\<int\>? | null | 点击项时的回调 |
| type | BottomNavigationBarType? | 自动 | 类型：fixed 或 shifting |
| elevation | double? | 8.0 | 阴影高度 |
| backgroundColor | Color? | null | 背景颜色 |
| fixedColor | Color? | null | fixed 类型时选中项颜色（已弃用，用 selectedItemColor） |
| selectedItemColor | Color? | 主题色 | 选中项颜色 |
| unselectedItemColor | Color? | null | 未选中项颜色 |
| selectedIconTheme | IconThemeData? | null | 选中图标主题 |
| unselectedIconTheme | IconThemeData? | null | 未选中图标主题 |
| selectedLabelStyle | TextStyle? | null | 选中标签样式 |
| unselectedLabelStyle | TextStyle? | null | 未选中标签样式 |
| showSelectedLabels | bool? | true | 是否显示选中项标签 |
| showUnselectedLabels | bool? | type 相关 | 是否显示未选中项标签 |
| iconSize | double | 24.0 | 图标大小 |
| selectedFontSize | double | 14.0 | 选中标签字体大小 |
| unselectedFontSize | double | 12.0 | 未选中标签字体大小 |
| mouseCursor | MouseCursor? | null | 鼠标指针样式 |
| enableFeedback | bool? | true | 是否启用触觉反馈 |
| landscapeLayout | BottomNavigationBarLandscapeLayout? | null | 横屏布局方式 |

## BottomNavigationBarItem 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| icon | Widget | 必需 | 默认图标 |
| activeIcon | Widget? | null | 选中时的图标 |
| label | String? | null | 标签文本 |
| backgroundColor | Color? | null | shifting 类型时的背景色 |
| tooltip | String? | null | 长按提示文本 |

## 使用场景

### 1. 基本导航

```dart
class BasicBottomNavDemo extends StatefulWidget {
  @override
  State<BasicBottomNavDemo> createState() => _BasicBottomNavDemoState();
}

class _BasicBottomNavDemoState extends State<BasicBottomNavDemo> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('首页')),
    Center(child: Text('搜索')),
    Center(child: Text('我的')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
```

### 2. Shifting 类型（颜色切换效果）

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.shifting,
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '首页',
      backgroundColor: Colors.blue,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: '收藏',
      backgroundColor: Colors.red,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: '购物车',
      backgroundColor: Colors.green,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '我的',
      backgroundColor: Colors.purple,
    ),
  ],
)
```

### 3. 隐藏标签（仅显示图标）

```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  showSelectedLabels: false,
  showUnselectedLabels: false,
  type: BottomNavigationBarType.fixed,
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home, size: 28),
      label: '',  // 仍需提供 label（可为空字符串）
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore, size: 28),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications, size: 28),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings, size: 28),
      label: '',
    ),
  ],
)
```

### 4. 配合 PageView（带滑动切换）

```dart
class PageViewNavDemo extends StatefulWidget {
  @override
  State<PageViewNavDemo> createState() => _PageViewNavDemoState();
}

class _PageViewNavDemoState extends State<PageViewNavDemo> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          Container(color: Colors.red[100], child: Center(child: Text('页面 1'))),
          Container(color: Colors.green[100], child: Center(child: Text('页面 2'))),
          Container(color: Colors.blue[100], child: Center(child: Text('页面 3'))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.looks_one), label: '页面 1'),
          BottomNavigationBarItem(icon: Icon(Icons.looks_two), label: '页面 2'),
          BottomNavigationBarItem(icon: Icon(Icons.looks_3), label: '页面 3'),
        ],
      ),
    );
  }
}
```

### 5. 自定义样式

```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  elevation: 10,
  selectedItemColor: Color(0xFF6200EE),
  unselectedItemColor: Colors.grey,
  selectedFontSize: 12,
  unselectedFontSize: 12,
  selectedIconTheme: IconThemeData(size: 28),
  unselectedIconTheme: IconThemeData(size: 24),
  selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
    BottomNavigationBarItem(icon: Icon(Icons.category), label: '分类'),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
  ],
)
```

### 6. 带角标/徽章

```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Badge(
        label: Text('3'),
        child: Icon(Icons.message),
      ),
      label: '消息',
    ),
    BottomNavigationBarItem(
      icon: Badge(
        label: Text('99+'),
        child: Icon(Icons.notifications),
      ),
      label: '通知',
    ),
    BottomNavigationBarItem(
      icon: Badge(
        smallSize: 8,  // 小红点
        child: Icon(Icons.person),
      ),
      label: '我的',
    ),
  ],
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class BottomNavigationBarDemo extends StatefulWidget {
  @override
  State<BottomNavigationBarDemo> createState() => _BottomNavigationBarDemoState();
}

class _BottomNavigationBarDemoState extends State<BottomNavigationBarDemo> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['首页', '搜索', '购物车', '我的'][_selectedIndex]),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
            tooltip: '返回首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '搜索',
            tooltip: '搜索商品',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              label: Text('2'),
              child: Icon(Icons.shopping_cart),
            ),
            label: '购物车',
            tooltip: '查看购物车',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
            tooltip: '个人中心',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.article),
        title: Text('推荐内容 ${index + 1}'),
        subtitle: Text('这是推荐内容的描述'),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('搜索页面', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('购物车页面', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          SizedBox(height: 16),
          Text('个人中心', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
```

## BottomNavigationBar vs NavigationBar

| 特性 | BottomNavigationBar | NavigationBar |
|------|---------------------|---------------|
| 设计规范 | Material 2 | Material 3 |
| 视觉风格 | 扁平、紧凑 | 圆润、更大触摸区域 |
| 指示器 | 无 | 药丸形状指示器 |
| 推荐使用 | 旧项目维护 | 新项目开发 |
| type 属性 | fixed/shifting | 无 |

```dart
// Material 3 推荐使用 NavigationBar
NavigationBar(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
  destinations: [
    NavigationDestination(icon: Icon(Icons.home), label: '首页'),
    NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
    NavigationDestination(icon: Icon(Icons.person), label: '我的'),
  ],
)
```

## 最佳实践

1. **项目数量**：保持 3-5 个导航项，不宜过多
2. **图标选择**：使用清晰、易识别的图标，选中/未选中状态有区分
3. **标签文本**：简短明了，1-4 个字为佳
4. **状态保持**：使用 `IndexedStack` 或 `PageStorageKey` 保持页面状态
5. **迁移建议**：新项目推荐使用 Material 3 的 `NavigationBar`
6. **可访问性**：为每个 item 添加 tooltip 提供额外信息

## 相关组件

- [NavigationBar](./navigationbar.md) - Material 3 底部导航栏（推荐）
- [TabBar](./tabbar.md) - 选项卡栏
- [NavigationRail](./navigationrail.md) - 侧边导航栏（平板/桌面端）
- [Drawer](./drawer.md) - 抽屉导航

## 官方文档

- [BottomNavigationBar API](https://api.flutter-io.cn/flutter/material/BottomNavigationBar-class.html)
- [BottomNavigationBarItem API](https://api.flutter-io.cn/flutter/widgets/BottomNavigationBarItem-class.html)
