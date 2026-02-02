# NavigationRail

`NavigationRail` 是 Material Design 侧边导航栏组件，垂直显示在页面左侧或右侧。它特别适合平板和桌面设备，在大屏幕上提供高效的导航体验。

## 基本用法

```dart
Scaffold(
  body: Row(
    children: [
      NavigationRail(
        selectedIndex: 0,
        onDestinationSelected: (index) {},
        destinations: [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('首页'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: Text('搜索'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('设置'),
          ),
        ],
      ),
      VerticalDivider(thickness: 1, width: 1),
      Expanded(child: Center(child: Text('页面内容'))),
    ],
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| selectedIndex | int? | null | 当前选中的目标索引 |
| destinations | List\<NavigationRailDestination\> | 必需 | 导航目标列表，至少 2 个 |
| onDestinationSelected | ValueChanged\<int\>? | null | 目标选中回调 |
| backgroundColor | Color? | null | 背景颜色 |
| elevation | double? | null | 阴影高度 |
| groupAlignment | double? | -1.0 | 目标组垂直对齐（-1 顶部，0 居中，1 底部） |
| labelType | NavigationRailLabelType? | none | 标签显示类型 |
| leading | Widget? | null | 顶部组件，通常放 FAB |
| trailing | Widget? | null | 底部组件 |
| minWidth | double? | 72.0 | 最小宽度（未展开时） |
| minExtendedWidth | double? | 256.0 | 最小展开宽度 |
| extended | bool | false | 是否展开显示标签 |
| useIndicator | bool? | true | 是否显示选中指示器 |
| indicatorColor | Color? | null | 指示器颜色 |
| indicatorShape | ShapeBorder? | null | 指示器形状 |

### NavigationRailLabelType

| 值 | 说明 |
|------|------|
| none | 不显示标签 |
| selected | 仅选中时显示标签 |
| all | 始终显示所有标签 |

## NavigationRailDestination 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| icon | Widget | 必需 | 未选中时的图标 |
| selectedIcon | Widget? | null | 选中时的图标 |
| label | Widget | 必需 | 标签文本 |
| padding | EdgeInsetsGeometry? | null | 目标内边距 |
| disabled | bool | false | 是否禁用 |

## 使用场景

### 1. 基本侧边栏

```dart
class BasicNavigationRail extends StatefulWidget {
  @override
  State<BasicNavigationRail> createState() => _BasicNavigationRailState();
}

class _BasicNavigationRailState extends State<BasicNavigationRail> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.selected,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('首页'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('收藏'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('我的'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                Center(child: Text('首页内容')),
                Center(child: Text('收藏内容')),
                Center(child: Text('我的内容')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. 带扩展标签

```dart
class ExtendedNavigationRail extends StatefulWidget {
  @override
  State<ExtendedNavigationRail> createState() => _ExtendedNavigationRailState();
}

class _ExtendedNavigationRailState extends State<ExtendedNavigationRail> {
  int _selectedIndex = 0;
  bool _extended = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: _extended,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            leading: IconButton(
              icon: Icon(_extended ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() => _extended = !_extended);
              },
            ),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.inbox_outlined),
                selectedIcon: Icon(Icons.inbox),
                label: Text('收件箱'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.send_outlined),
                selectedIcon: Icon(Icons.send),
                label: Text('已发送'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.drafts_outlined),
                selectedIcon: Icon(Icons.drafts),
                label: Text('草稿箱'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.delete_outline),
                selectedIcon: Icon(Icons.delete),
                label: Text('垃圾箱'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: Center(child: Text('内容区域'))),
        ],
      ),
    );
  }
}
```

### 3. Leading 放 FAB

```dart
NavigationRail(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (index) {
    setState(() => _selectedIndex = index);
  },
  leading: FloatingActionButton(
    onPressed: () {
      // 新建操作
    },
    elevation: 0,
    child: Icon(Icons.add),
  ),
  groupAlignment: -0.85,
  labelType: NavigationRailLabelType.all,
  destinations: [
    NavigationRailDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: Text('文件'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.photo_outlined),
      selectedIcon: Icon(Icons.photo),
      label: Text('图片'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.share_outlined),
      selectedIcon: Icon(Icons.share),
      label: Text('共享'),
    ),
  ],
  trailing: Expanded(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {},
        ),
      ),
    ),
  ),
)
```

### 4. 响应式切换 (NavigationRail ↔ NavigationBar)

```dart
class ResponsiveNavigation extends StatefulWidget {
  @override
  State<ResponsiveNavigation> createState() => _ResponsiveNavigationState();
}

class _ResponsiveNavigationState extends State<ResponsiveNavigation> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _bottomDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '首页',
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: '发现',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.bookmark),
      label: '书签',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  final List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('首页'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: Text('发现'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.bookmark),
      label: Text('书签'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('我的'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: _railDestinations,
            ),
          if (isWide) VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildPage(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: _bottomDestinations,
            ),
    );
  }

  Widget _buildPage(int index) {
    final pages = ['首页', '发现', '书签', '我的'];
    return Center(
      child: Text(
        '${pages[index]}页面',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class NavigationRailDemo extends StatefulWidget {
  @override
  State<NavigationRailDemo> createState() => _NavigationRailDemoState();
}

class _NavigationRailDemoState extends State<NavigationRailDemo> {
  int _selectedIndex = 0;
  bool _extended = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final isDesktop = width >= 900;

    // 桌面端自动展开
    final showExtended = isDesktop || _extended;

    return Scaffold(
      body: Row(
        children: [
          if (isTablet)
            NavigationRail(
              extended: showExtended,
              minExtendedWidth: 200,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              leading: isDesktop
                  ? null
                  : IconButton(
                      icon: Icon(showExtended ? Icons.menu_open : Icons.menu),
                      onPressed: () {
                        setState(() => _extended = !_extended);
                      },
                    ),
              labelType: NavigationRailLabelType.none,
              useIndicator: true,
              indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('仪表盘'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('数据分析'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('库存管理'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('用户管理'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('系统设置'),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: showExtended
                        ? TextButton.icon(
                            icon: Icon(Icons.logout),
                            label: Text('退出登录'),
                            onPressed: () {},
                          )
                        : IconButton(
                            icon: Icon(Icons.logout),
                            onPressed: () {},
                            tooltip: '退出登录',
                          ),
                  ),
                ),
              ),
            ),
          if (isTablet) VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: '仪表盘',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: '分析',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: '库存',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  label: '更多',
                ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    final titles = ['仪表盘', '数据分析', '库存管理', '用户管理', '系统设置'];
    final icons = [
      Icons.dashboard,
      Icons.analytics,
      Icons.inventory_2,
      Icons.people,
      Icons.settings,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[_selectedIndex], size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '${titles[_selectedIndex]}页面',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              '这是一个平板/桌面响应式导航示例',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

1. **适配屏幕宽度**：在 600px 以上使用 NavigationRail，以下使用 NavigationBar
2. **目标数量**：保持 3-7 个导航目标，过多会影响用户体验
3. **图标对比**：为选中和未选中状态提供不同图标样式
4. **展开策略**：桌面端（>900px）可默认展开，平板端提供切换按钮
5. **垂直对齐**：根据内容布局调整 groupAlignment
6. **可访问性**：确保标签清晰描述导航目标
7. **一致性**：与 NavigationBar 使用相同的图标和标签

## 相关组件

- [NavigationBar](./navigationbar.md) - 底部导航栏，适合手机端
- [Drawer](./drawer.md) - 抽屉式侧边栏
- [NavigationDrawer](./navigationdrawer.md) - Material 3 导航抽屉
- [BottomNavigationBar](./bottomnavigationbar.md) - Material 2 底部导航

## 官方文档

- [NavigationRail API](https://api.flutter-io.cn/flutter/material/NavigationRail-class.html)
- [NavigationRailDestination API](https://api.flutter-io.cn/flutter/material/NavigationRailDestination-class.html)
