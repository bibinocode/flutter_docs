# CupertinoNavigationBar

`CupertinoNavigationBar` 是 iOS 风格的导航栏组件，模拟了 iOS 系统的原生导航栏外观和行为。它通常用于 `CupertinoPageScaffold` 顶部，提供返回按钮、标题和操作按钮等功能。

## 基本用法

```dart
CupertinoNavigationBar(
  middle: Text('标题'),
  leading: CupertinoNavigationBarBackButton(
    onPressed: () => Navigator.pop(context),
  ),
  trailing: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(CupertinoIcons.add),
    onPressed: () {},
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| leading | Widget? | null | 导航栏左侧组件，通常是返回按钮 |
| automaticallyImplyLeading | bool | true | 是否自动添加返回按钮 |
| previousPageTitle | String? | null | 上一页标题，用于返回按钮文字 |
| middle | Widget? | null | 导航栏中间组件，通常是标题 |
| trailing | Widget? | null | 导航栏右侧组件，通常是操作按钮 |
| border | Border? | _kDefaultNavBarBorder | 底部边框，默认为单像素分隔线 |
| backgroundColor | Color? | null | 背景颜色，默认半透明模糊效果 |
| brightness | Brightness? | null | 状态栏亮度样式 |
| padding | EdgeInsetsDirectional? | null | 内边距 |
| transitionBetweenRoutes | bool | true | 是否在路由间执行 Hero 过渡动画 |
| heroTag | Object | _defaultHeroTag | Hero 动画标签，用于自定义过渡 |

## 使用场景

### 1. 基本导航栏

```dart
CupertinoPageScaffold(
  navigationBar: CupertinoNavigationBar(
    middle: Text('首页'),
  ),
  child: SafeArea(
    child: Center(
      child: Text('页面内容'),
    ),
  ),
)
```

### 2. 带操作按钮

```dart
CupertinoNavigationBar(
  middle: Text('消息'),
  leading: CupertinoButton(
    padding: EdgeInsets.zero,
    child: Icon(CupertinoIcons.back),
    onPressed: () => Navigator.pop(context),
  ),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(CupertinoIcons.search),
        onPressed: () {},
      ),
      CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(CupertinoIcons.ellipsis_vertical),
        onPressed: () {},
      ),
    ],
  ),
)
```

### 3. 大标题样式 (CupertinoSliverNavigationBar)

```dart
CustomScrollView(
  slivers: [
    CupertinoSliverNavigationBar(
      largeTitle: Text('设置'),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text('返回'),
        onPressed: () => Navigator.pop(context),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text('编辑'),
        onPressed: () {},
      ),
    ),
    SliverFillRemaining(
      child: ListView(
        children: [
          CupertinoListTile(title: Text('通用')),
          CupertinoListTile(title: Text('隐私')),
          CupertinoListTile(title: Text('通知')),
        ],
      ),
    ),
  ],
)
```

### 4. 搜索栏

```dart
CupertinoPageScaffold(
  navigationBar: CupertinoNavigationBar(
    middle: CupertinoSearchTextField(
      placeholder: '搜索',
      onChanged: (value) {
        print('搜索内容: $value');
      },
    ),
    trailing: CupertinoButton(
      padding: EdgeInsets.zero,
      child: Text('取消'),
      onPressed: () {},
    ),
  ),
  child: SafeArea(
    child: ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return CupertinoListTile(
          title: Text('搜索结果 $index'),
        );
      },
    ),
  ),
)
```

## 完整示例

```dart
import 'package:flutter/cupertino.dart';

class CupertinoNavigationBarDemo extends StatefulWidget {
  @override
  State<CupertinoNavigationBarDemo> createState() =>
      _CupertinoNavigationBarDemoState();
}

class _CupertinoNavigationBarDemoState
    extends State<CupertinoNavigationBarDemo> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedTab,
          onTap: (index) => setState(() => _selectedTab = index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: '设置',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          if (index == 0) {
            return _buildHomePage();
          }
          return _buildSettingsPage();
        },
      ),
    );
  }

  Widget _buildHomePage() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('首页'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.add),
          onPressed: () => _navigateToDetail(context),
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return CupertinoListTile(
              title: Text('项目 ${index + 1}'),
              trailing: CupertinoListTileChevron(),
              onTap: () => _navigateToDetail(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('设置'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text('编辑'),
              onPressed: () {},
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              CupertinoListSection.insetGrouped(
                header: Text('账户'),
                children: [
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.person_fill),
                    title: Text('个人信息'),
                    trailing: CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.lock_fill),
                    title: Text('隐私设置'),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: Text('通用'),
                children: [
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.bell_fill),
                    title: Text('通知'),
                    trailing: CupertinoSwitch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.moon_fill),
                    title: Text('深色模式'),
                    trailing: CupertinoSwitch(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('详情'),
            previousPageTitle: '首页',
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.share),
              onPressed: () {},
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: 64,
                    color: CupertinoColors.activeGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '详情页面',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## 最佳实践

1. **搭配 CupertinoPageScaffold 使用**：`CupertinoNavigationBar` 应放在 `CupertinoPageScaffold` 的 `navigationBar` 属性中，以确保正确的布局和过渡动画。

2. **使用 previousPageTitle 优化返回按钮**：设置 `previousPageTitle` 可以让返回按钮显示上一页的标题，提供更好的导航体验。

3. **保持一致的 iOS 风格**：在同一个应用中，如果使用 Cupertino 组件，应保持整体风格一致，避免混用 Material 和 Cupertino 组件。

4. **大标题使用 CupertinoSliverNavigationBar**：对于需要大标题样式的页面（如设置页面），使用 `CupertinoSliverNavigationBar` 配合 `CustomScrollView` 可以实现 iOS 大标题的滚动收缩效果。

5. **合理使用 trailing 空间**：右侧操作按钮不宜过多，建议最多 2-3 个，使用 `CupertinoButton` 并设置 `padding: EdgeInsets.zero` 以获得正确的触摸区域。

6. **注意状态栏颜色**：通过 `brightness` 属性或 `backgroundColor` 来确保状态栏文字在不同背景下的可见性。

## 相关组件

- [AppBar](../material/appbar.md) - Material Design 风格的应用栏
- [SliverAppBar](../scrolling/sliverappbar.md) - 可折叠的 Material 应用栏

## 官方文档

- [CupertinoNavigationBar API](https://api.flutter.dev/flutter/cupertino/CupertinoNavigationBar-class.html)
- [CupertinoSliverNavigationBar API](https://api.flutter.dev/flutter/cupertino/CupertinoSliverNavigationBar-class.html)
