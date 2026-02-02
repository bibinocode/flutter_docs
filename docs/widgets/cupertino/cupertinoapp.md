# CupertinoApp

`CupertinoApp` 是 iOS 风格的应用根组件，类似于 `MaterialApp`，但专为 iOS 设计语言打造。它提供了 iOS 风格的导航、主题和本地化支持，是构建原生 iOS 风格 Flutter 应用的基础组件。

## 基本用法

```dart
import 'package:flutter/cupertino.dart';

void main() {
  runApp(
    CupertinoApp(
      title: 'My iOS App',
      home: MyHomePage(),
    ),
  );
}
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `home` | `Widget?` | 应用的主页面组件 |
| `routes` | `Map<String, WidgetBuilder>?` | 命名路由表 |
| `initialRoute` | `String?` | 初始路由名称 |
| `onGenerateRoute` | `RouteFactory?` | 动态路由生成器 |
| `onUnknownRoute` | `RouteFactory?` | 未知路由处理器 |
| `navigatorKey` | `GlobalKey<NavigatorState>?` | Navigator 的 GlobalKey |
| `navigatorObservers` | `List<NavigatorObserver>` | 导航观察者列表 |
| `builder` | `TransitionBuilder?` | 在 Navigator 上方插入组件 |
| `title` | `String` | 应用标题 |
| `onGenerateTitle` | `GenerateAppTitle?` | 动态生成标题 |
| `color` | `Color?` | 应用主颜色（用于任务切换器） |
| `theme` | `CupertinoThemeData?` | iOS 风格主题数据 |
| `locale` | `Locale?` | 应用的语言区域 |
| `localizationsDelegates` | `Iterable<LocalizationsDelegate>?` | 本地化代理 |
| `supportedLocales` | `Iterable<Locale>` | 支持的语言区域列表 |
| `showPerformanceOverlay` | `bool` | 显示性能覆盖层 |
| `debugShowCheckedModeBanner` | `bool` | 显示 Debug 标签 |

## CupertinoThemeData

`CupertinoThemeData` 定义了 iOS 风格应用的视觉主题：

| 属性 | 类型 | 说明 |
|------|------|------|
| `brightness` | `Brightness?` | 亮度模式（light/dark） |
| `primaryColor` | `Color?` | 主色调（用于可交互元素） |
| `primaryContrastingColor` | `Color?` | 主色调的对比色 |
| `textTheme` | `CupertinoTextThemeData?` | 文字主题 |
| `barBackgroundColor` | `Color?` | 导航栏/标签栏背景色 |
| `scaffoldBackgroundColor` | `Color?` | 页面脚手架背景色 |

## 使用场景

### 1. 基本应用

```dart
import 'package:flutter/cupertino.dart';

class BasicCupertinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'iOS 风格应用',
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('首页'),
        ),
        child: SafeArea(
          child: Center(
            child: Text('欢迎使用 CupertinoApp'),
          ),
        ),
      ),
    );
  }
}
```

### 2. 自定义主题

```dart
import 'package:flutter/cupertino.dart';

class ThemedCupertinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '自定义主题',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemIndigo,
        primaryContrastingColor: CupertinoColors.white,
        barBackgroundColor: CupertinoColors.systemBackground,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.systemIndigo,
          textStyle: TextStyle(
            fontSize: 16,
            color: CupertinoColors.label,
          ),
          navTitleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ),
      home: ThemedHomePage(),
    );
  }
}

class ThemedHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('自定义主题'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.settings),
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: Text('设置'),
              children: [
                CupertinoListTile(
                  title: Text('通知'),
                  leading: Icon(CupertinoIcons.bell, color: CupertinoColors.systemRed),
                  trailing: CupertinoSwitch(value: true, onChanged: (_) {}),
                ),
                CupertinoListTile(
                  title: Text('隐私'),
                  leading: Icon(CupertinoIcons.lock, color: CupertinoColors.systemBlue),
                  trailing: CupertinoListTileChevron(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. 暗色模式支持

```dart
import 'package:flutter/cupertino.dart';

class DarkModeApp extends StatefulWidget {
  @override
  State<DarkModeApp> createState() => _DarkModeAppState();
}

class _DarkModeAppState extends State<DarkModeApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '暗色模式',
      theme: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('暗色模式'),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isDarkMode ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                  size: 80,
                  color: _isDarkMode ? CupertinoColors.systemYellow : CupertinoColors.systemOrange,
                ),
                SizedBox(height: 20),
                Text(
                  _isDarkMode ? '暗色模式' : '亮色模式',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                CupertinoSwitch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 跟随系统主题
class SystemThemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '跟随系统主题',
      // 不设置 brightness，自动跟随系统
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: Builder(
        builder: (context) {
          final brightness = MediaQuery.platformBrightnessOf(context);
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text('当前: ${brightness == Brightness.dark ? "暗色" : "亮色"}'),
            ),
            child: Center(
              child: Text('自动跟随系统主题'),
            ),
          );
        },
      ),
    );
  }
}
```

### 4. 路由配置

```dart
import 'package:flutter/cupertino.dart';

class RoutingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '路由示例',
      // 命名路由表
      routes: {
        '/': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(),
      },
      initialRoute: '/',
      // 动态路由
      onGenerateRoute: (settings) {
        // 处理带参数的路由
        if (settings.name?.startsWith('/user/') ?? false) {
          final userId = settings.name!.split('/').last;
          return CupertinoPageRoute(
            builder: (context) => UserDetailPage(userId: userId),
            settings: settings,
          );
        }
        
        // 处理 /product/:id 路由
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'product') {
          return CupertinoPageRoute(
            builder: (context) => ProductPage(
              productId: uri.pathSegments[1],
            ),
            settings: settings,
          );
        }
        
        return null;
      },
      // 未知路由处理
      onUnknownRoute: (settings) {
        return CupertinoPageRoute(
          builder: (context) => NotFoundPage(route: settings.name),
        );
      },
      // 导航观察者
      navigatorObservers: [
        CupertinoNavigatorObserver(),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('首页'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListTile(
              title: Text('个人资料'),
              trailing: CupertinoListTileChevron(),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            CupertinoListTile(
              title: Text('设置'),
              trailing: CupertinoListTileChevron(),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            CupertinoListTile(
              title: Text('用户详情'),
              trailing: CupertinoListTileChevron(),
              onTap: () => Navigator.pushNamed(context, '/user/12345'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('个人资料'),
        previousPageTitle: '首页',
      ),
      child: Center(child: Text('个人资料页面')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('设置'),
        previousPageTitle: '首页',
      ),
      child: Center(child: Text('设置页面')),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final String userId;
  
  const UserDetailPage({required this.userId});
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('用户 $userId'),
      ),
      child: Center(child: Text('用户详情: $userId')),
    );
  }
}

class ProductPage extends StatelessWidget {
  final String productId;
  
  const ProductPage({required this.productId});
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('产品详情'),
      ),
      child: Center(child: Text('产品ID: $productId')),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  final String? route;
  
  const NotFoundPage({this.route});
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('页面未找到'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle, size: 64),
            SizedBox(height: 16),
            Text('路由 "$route" 不存在'),
            SizedBox(height: 16),
            CupertinoButton.filled(
              child: Text('返回首页'),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 自定义导航观察者
class CupertinoNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('导航到: ${route.settings.name}');
  }
  
  @override
  void didPop(Route route, Route? previousRoute) {
    print('返回自: ${route.settings.name}');
  }
}
```

## 完整示例

```dart
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MyiOSApp());
}

class MyiOSApp extends StatefulWidget {
  @override
  State<MyiOSApp> createState() => _MyiOSAppState();
}

class _MyiOSAppState extends State<MyiOSApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = CupertinoColors.activeBlue;

  void _updateTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _updatePrimaryColor(Color color) {
    setState(() {
      _primaryColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'iOS 风格应用',
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      theme: CupertinoThemeData(
        brightness: _themeMode == ThemeMode.system
            ? null
            : (_themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light),
        primaryColor: _primaryColor,
        primaryContrastingColor: CupertinoColors.white,
        textTheme: CupertinoTextThemeData(
          primaryColor: _primaryColor,
        ),
      ),
      
      // 本地化
      localizationsDelegates: [
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      
      home: MainTabPage(
        onThemeChanged: _updateTheme,
        onColorChanged: _updatePrimaryColor,
        currentThemeMode: _themeMode,
        currentColor: _primaryColor,
      ),
    );
  }
}

class MainTabPage extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;
  final ThemeMode currentThemeMode;
  final Color currentColor;

  const MainTabPage({
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.currentThemeMode,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: '设置',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => HomeTab(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => DiscoverTab(),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => SettingsTab(
                onThemeChanged: onThemeChanged,
                onColorChanged: onColorChanged,
                currentThemeMode: currentThemeMode,
                currentColor: currentColor,
              ),
            );
          default:
            return CupertinoTabView(
              builder: (context) => HomeTab(),
            );
        }
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('首页'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.add),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                title: Text('新建'),
                actions: [
                  CupertinoActionSheetAction(
                    child: Text('新建笔记'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoActionSheetAction(
                    child: Text('新建文件夹'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('取消'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return CupertinoListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(CupertinoIcons.doc_text, size: 20),
              ),
              title: Text('笔记 ${index + 1}'),
              subtitle: Text('上次编辑: 今天'),
              trailing: CupertinoListTileChevron(),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => NoteDetailPage(index: index + 1),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NoteDetailPage extends StatelessWidget {
  final int index;
  
  const NoteDetailPage({required this.index});
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('笔记 $index'),
        previousPageTitle: '首页',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.ellipsis),
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('笔记 $index 的内容...'),
        ),
      ),
    );
  }
}

class DiscoverTab extends StatefulWidget {
  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('发现'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: '搜索',
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5.resolveFrom(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.folder,
                            size: 40,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                          SizedBox(height: 8),
                          Text('分类 ${index + 1}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;
  final ThemeMode currentThemeMode;
  final Color currentColor;

  const SettingsTab({
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.currentThemeMode,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('设置'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: Text('外观'),
              children: [
                CupertinoListTile(
                  title: Text('主题'),
                  additionalInfo: Text(_getThemeModeText()),
                  trailing: CupertinoListTileChevron(),
                  onTap: () => _showThemePicker(context),
                ),
                CupertinoListTile(
                  title: Text('主题色'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: currentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      CupertinoListTileChevron(),
                    ],
                  ),
                  onTap: () => _showColorPicker(context),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text('账户'),
              children: [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.person),
                  title: Text('个人资料'),
                  trailing: CupertinoListTileChevron(),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.lock),
                  title: Text('隐私'),
                  trailing: CupertinoListTileChevron(),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.bell),
                  title: Text('通知'),
                  trailing: CupertinoListTileChevron(),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text('关于'),
              children: [
                CupertinoListTile(
                  title: Text('版本'),
                  additionalInfo: Text('1.0.0'),
                ),
                CupertinoListTile(
                  title: Text('使用条款'),
                  trailing: CupertinoListTileChevron(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText() {
    switch (currentThemeMode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '亮色';
      case ThemeMode.dark:
        return '暗色';
    }
  }

  void _showThemePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('选择主题'),
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: currentThemeMode == ThemeMode.system,
            child: Text('跟随系统'),
            onPressed: () {
              onThemeChanged(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            isDefaultAction: currentThemeMode == ThemeMode.light,
            child: Text('亮色'),
            onPressed: () {
              onThemeChanged(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            isDefaultAction: currentThemeMode == ThemeMode.dark,
            child: Text('暗色'),
            onPressed: () {
              onThemeChanged(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final colors = [
      CupertinoColors.activeBlue,
      CupertinoColors.systemIndigo,
      CupertinoColors.systemPurple,
      CupertinoColors.systemPink,
      CupertinoColors.systemRed,
      CupertinoColors.systemOrange,
      CupertinoColors.systemGreen,
      CupertinoColors.systemTeal,
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 200,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择主题色',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: colors.map((color) {
                    final isSelected = color == currentColor;
                    return GestureDetector(
                      onTap: () {
                        onColorChanged(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: CupertinoColors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(CupertinoIcons.check_mark, color: CupertinoColors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

### 何时使用 CupertinoApp vs MaterialApp

| 场景 | 推荐 | 原因 |
|------|------|------|
| 仅针对 iOS 用户 | `CupertinoApp` | 提供原生 iOS 体验 |
| 仅针对 Android 用户 | `MaterialApp` | 提供原生 Material Design 体验 |
| 跨平台应用 | `MaterialApp` + 平台判断 | Material 组件在两个平台都有良好表现 |
| iOS 优先但支持 Android | `CupertinoApp` | 统一 iOS 风格设计 |
| 需要自适应 UI | 使用 `Platform.isIOS` 判断 | 根据平台显示不同组件 |

```dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 根据平台选择不同的应用
    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'iOS App',
        home: CupertinoHomePage(),
      );
    } else {
      return MaterialApp(
        title: 'Android App',
        home: MaterialHomePage(),
      );
    }
  }
}
```

### 设计建议

1. **保持一致性**: 使用 `CupertinoApp` 时，内部组件也应使用 Cupertino 系列
2. **遵循 HIG**: 遵循 Apple Human Interface Guidelines 的设计规范
3. **测试暗色模式**: 确保应用在亮色和暗色模式下都有良好表现
4. **合理使用 SafeArea**: 处理 iOS 设备的刘海和圆角
5. **导航栏样式**: 使用 `CupertinoNavigationBar` 而非 `AppBar`

## 相关组件

- [MaterialApp](../material/materialapp.md) - Material Design 风格应用根组件
- [CupertinoTheme](./cupertinotheme.md) - iOS 风格主题组件
- [CupertinoPageScaffold](./cupertinopagescaffold.md) - iOS 风格页面脚手架
- [CupertinoNavigationBar](./cupertinonavigationbar.md) - iOS 风格导航栏
- [CupertinoTabScaffold](./cupertitabscaffold.md) - iOS 风格标签页脚手架
- [CupertinoTabBar](./cupertinotabbar.md) - iOS 风格标签栏

## 官方文档

- [CupertinoApp API](https://api.flutter.dev/flutter/cupertino/CupertinoApp-class.html)
- [CupertinoThemeData API](https://api.flutter.dev/flutter/cupertino/CupertinoThemeData-class.html)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
