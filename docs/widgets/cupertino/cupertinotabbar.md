# CupertinoTabBar

`CupertinoTabBar` 是 iOS 风格的底部标签栏组件，模拟了 iOS 系统原生的 Tab Bar 外观和行为。它通常与 `CupertinoTabScaffold` 配合使用，用于在不同页面之间进行切换导航。

## 基本用法

```dart
CupertinoTabBar(
  currentIndex: 0,
  onTap: (index) {
    print('选中标签: $index');
  },
  items: [
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.search),
      label: '搜索',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.person),
      label: '我的',
    ),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| items | List\<BottomNavigationBarItem\> | 必需 | 标签项列表，至少需要 2 个 |
| currentIndex | int | 0 | 当前选中的标签索引 |
| onTap | ValueChanged\<int\>? | null | 点击标签时的回调函数 |
| activeColor | Color? | CupertinoTheme.primaryColor | 选中状态的图标和文字颜色 |
| inactiveColor | Color | CupertinoColors.inactiveGray | 未选中状态的图标和文字颜色 |
| backgroundColor | Color? | null | 背景颜色，默认为半透明模糊效果 |
| border | Border? | _kDefaultTabBarBorder | 顶部边框，默认为单像素分隔线 |
| iconSize | double | 30.0 | 图标大小 |

## 使用场景

### 1. 基本使用

```dart
class BasicTabBarDemo extends StatefulWidget {
  @override
  State<BasicTabBarDemo> createState() => _BasicTabBarDemoState();
}

class _BasicTabBarDemoState extends State<BasicTabBarDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(['首页', '搜索', '我的'][_currentIndex]),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('当前页面: ${_currentIndex + 1}'),
            ),
          ),
          CupertinoTabBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: '首页',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: '搜索',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                label: '我的',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 2. 配合 CupertinoTabScaffold

```dart
class TabScaffoldDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.compass_fill),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell_fill),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: '我的',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(['首页', '发现', '消息', '我的'][index]),
              ),
              child: Center(
                child: Text('标签页 ${index + 1}'),
              ),
            );
          },
        );
      },
    );
  }
}
```

### 3. 自定义图标颜色

```dart
CupertinoTabBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  activeColor: CupertinoColors.systemBlue,
  inactiveColor: CupertinoColors.systemGrey,
  backgroundColor: CupertinoColors.white,
  border: Border(
    top: BorderSide(
      color: CupertinoColors.systemGrey4,
      width: 0.5,
    ),
  ),
  items: [
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.home),
      activeIcon: Icon(CupertinoIcons.house_fill),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.heart),
      activeIcon: Icon(CupertinoIcons.heart_fill),
      label: '收藏',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.settings),
      activeIcon: Icon(CupertinoIcons.settings_solid),
      label: '设置',
    ),
  ],
)
```

### 4. 带角标

```dart
class BadgeTabBarDemo extends StatefulWidget {
  @override
  State<BadgeTabBarDemo> createState() => _BadgeTabBarDemoState();
}

class _BadgeTabBarDemoState extends State<BadgeTabBarDemo> {
  int _currentIndex = 0;
  int _messageCount = 5;

  Widget _buildBadgeIcon(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -3,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) _messageCount = 0; // 清除未读数
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: _buildBadgeIcon(CupertinoIcons.bell, _messageCount),
            activeIcon: _buildBadgeIcon(CupertinoIcons.bell_fill, _messageCount),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: '我的',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(['首页', '搜索', '消息', '我的'][index]),
          ),
          child: Center(
            child: Text('标签页 ${index + 1}'),
          ),
        );
      },
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/cupertino.dart';

class CupertinoTabBarDemo extends StatefulWidget {
  @override
  State<CupertinoTabBarDemo> createState() => _CupertinoTabBarDemoState();
}

class _CupertinoTabBarDemoState extends State<CupertinoTabBarDemo> {
  int _messageCount = 3;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: CupertinoColors.systemBlue,
          inactiveColor: CupertinoColors.systemGrey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.compass),
              activeIcon: Icon(CupertinoIcons.compass_fill),
              label: '发现',
            ),
            BottomNavigationBarItem(
              icon: _buildBadgeIcon(CupertinoIcons.bell, _messageCount),
              activeIcon: _buildBadgeIcon(CupertinoIcons.bell_fill, _messageCount),
              label: '消息',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: '我的',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildHomePage();
            case 1:
              return _buildDiscoverPage();
            case 2:
              return _buildMessagePage();
            case 3:
              return _buildProfilePage();
            default:
              return _buildHomePage();
          }
        },
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -3,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHomePage() {
    return CupertinoTabView(
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('首页'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.add),
            onPressed: () {},
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return CupertinoListTile(
                title: Text('项目 ${index + 1}'),
                subtitle: Text('描述信息'),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_fill,
                    color: CupertinoColors.white,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () => _navigateToDetail(context, '项目 ${index + 1}'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverPage() {
    return CupertinoTabView(
      builder: (context) => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text('发现'),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('卡片 ${index + 1}'),
                      ),
                    );
                  },
                  childCount: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagePage() {
    return CupertinoTabView(
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('消息'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('编辑'),
            onPressed: () {},
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return CupertinoListTile(
                title: Text('联系人 ${index + 1}'),
                subtitle: Text('最近消息内容...'),
                leading: CircleAvatar(
                  backgroundColor: CupertinoColors.systemGrey4,
                  child: Text('${index + 1}'),
                ),
                additionalInfo: Text('下午3:30'),
                trailing: CupertinoListTileChevron(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return CupertinoTabView(
      builder: (context) => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text('我的'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.gear),
                onPressed: () {},
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: CupertinoColors.systemBlue,
                        child: Icon(
                          CupertinoIcons.person_fill,
                          size: 50,
                          color: CupertinoColors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '用户名',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.heart_fill,
                          color: CupertinoColors.systemRed),
                      title: Text('收藏'),
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.clock_fill,
                          color: CupertinoColors.systemOrange),
                      title: Text('历史'),
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.download_circle_fill,
                          color: CupertinoColors.systemGreen),
                      title: Text('下载'),
                      trailing: CupertinoListTileChevron(),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String title) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(title),
            previousPageTitle: '首页',
          ),
          child: SafeArea(
            child: Center(
              child: Text('$title 详情页'),
            ),
          ),
        ),
      ),
    );
  }
}
```

## 最佳实践

1. **配合 CupertinoTabScaffold 使用**：`CupertinoTabBar` 最佳搭配是 `CupertinoTabScaffold`，它会自动处理标签切换和页面状态保持。

2. **使用 CupertinoTabView 实现独立导航**：每个标签页使用 `CupertinoTabView` 包裹，可以让每个标签页拥有独立的导航栈。

3. **提供 activeIcon 和 icon**：为每个 `BottomNavigationBarItem` 同时提供 `icon` 和 `activeIcon`，使选中和未选中状态有明显区分（如空心/实心图标）。

4. **标签数量控制在 3-5 个**：iOS 设计规范建议底部标签栏最多 5 个标签，过多会影响用户体验。

5. **保持颜色风格一致**：`activeColor` 应与应用主题色保持一致，`inactiveColor` 使用灰色系。

6. **角标实现使用 Stack**：通过 Stack 和 Positioned 组合实现角标，注意设置 `clipBehavior: Clip.none` 以允许角标溢出。

7. **避免频繁重建**：标签页内容应该被缓存，避免每次切换时重新构建，`CupertinoTabScaffold` 会自动处理这一点。

## 相关组件

- [BottomNavigationBar](../material/bottomnavigationbar.md) - Material Design 风格的底部导航栏
- [NavigationBar](../material/navigationbar.md) - Material 3 风格的底部导航栏
- [CupertinoNavigationBar](./cupertinonavigationbar.md) - iOS 风格的顶部导航栏

## 官方文档

- [CupertinoTabBar API](https://api.flutter.dev/flutter/cupertino/CupertinoTabBar-class.html)
- [CupertinoTabScaffold API](https://api.flutter.dev/flutter/cupertino/CupertinoTabScaffold-class.html)
