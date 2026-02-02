# 路由与导航

Flutter 提供了强大的路由系统来管理页面之间的导航。本章将介绍从基础导航到高级路由管理的完整内容。

## 基础导航

### Navigator 和 Route

Flutter 使用 Navigator 来管理路由栈，每个页面都是一个 Route：

```dart
// 跳转到新页面
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SecondPage()),
);

// 返回上一页
Navigator.pop(context);

// 返回并传递数据
Navigator.pop(context, '返回的数据');
```

### 完整示例

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 等待返回结果
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(id: '123'),
              ),
            );
            if (result != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('返回: $result')),
              );
            }
          },
          child: Text('查看详情'),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String id;
  
  const DetailPage({required this.id});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('详情 $id')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, '已完成'),
          child: Text('返回'),
        ),
      ),
    );
  }
}
```

## 命名路由

### 定义路由表

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 初始路由
      initialRoute: '/',
      // 路由表
      routes: {
        '/': (context) => HomePage(),
        '/detail': (context) => DetailPage(),
        '/settings': (context) => SettingsPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
```

### 使用命名路由

```dart
// 跳转
Navigator.pushNamed(context, '/detail');

// 带参数跳转
Navigator.pushNamed(
  context, 
  '/detail',
  arguments: {'id': '123', 'title': '文章标题'},
);

// 接收参数
class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取路由参数
    final args = ModalRoute.of(context)!.settings.arguments 
        as Map&lt;String, dynamic&gt;;
    
    return Scaffold(
      appBar: AppBar(title: Text(args['title'])),
      body: Text('ID: ${args['id']}'),
    );
  }
}
```

### 动态路由生成

```dart
MaterialApp(
  onGenerateRoute: (settings) {
    // 解析路由
    if (settings.name == '/detail') {
      final args = settings.arguments as Map&lt;String, dynamic&gt;?;
      return MaterialPageRoute(
        builder: (context) => DetailPage(
          id: args?['id'] ?? '',
        ),
      );
    }
    
    // 处理带参数的路由 /user/:id
    final uri = Uri.parse(settings.name ?? '');
    if (uri.pathSegments.length == 2 && 
        uri.pathSegments[0] == 'user') {
      final userId = uri.pathSegments[1];
      return MaterialPageRoute(
        builder: (context) => UserPage(id: userId),
      );
    }
    
    // 404 页面
    return MaterialPageRoute(
      builder: (context) => NotFoundPage(),
    );
  },
  onUnknownRoute: (settings) {
    return MaterialPageRoute(
      builder: (context) => NotFoundPage(),
    );
  },
)
```

## 导航操作大全

### 常用方法

```dart
// 1. push - 添加新页面到栈顶
Navigator.push(context, route);
Navigator.pushNamed(context, '/page');

// 2. pop - 弹出栈顶页面
Navigator.pop(context);
Navigator.pop(context, result);  // 带返回值

// 3. pushReplacement - 替换当前页面
Navigator.pushReplacement(context, route);
Navigator.pushReplacementNamed(context, '/page');

// 4. pushAndRemoveUntil - 跳转并清除之前的页面
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => HomePage()),
  (route) => false,  // 清除所有
);

// 5. popUntil - 弹出直到某个条件
Navigator.popUntil(context, (route) => route.isFirst);
Navigator.popUntil(context, ModalRoute.withName('/home'));

// 6. canPop - 检查是否可以返回
if (Navigator.canPop(context)) {
  Navigator.pop(context);
}

// 7. maybePop - 安全返回（处理 WillPopScope）
Navigator.maybePop(context);
```

### 实际应用场景

```dart
// 场景 1：登录后跳转到首页并清空登录页
void onLoginSuccess() {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => HomePage()),
    (route) => false,
  );
}

// 场景 2：退出登录回到登录页
void onLogout() {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}

// 场景 3：深层页面直接返回首页
void backToHome() {
  Navigator.popUntil(context, (route) => route.isFirst);
}
```

## 页面过渡动画

### 内置过渡效果

```dart
// MaterialPageRoute - Material 风格（Android 上下滑动）
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextPage()),
);

// CupertinoPageRoute - iOS 风格（左右滑动）
Navigator.push(
  context,
  CupertinoPageRoute(builder: (context) => NextPage()),
);
```

### 自定义过渡动画

```dart
// 淡入淡出效果
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 300),
  ),
);

// 缩放效果
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return ScaleTransition(
      scale: Tween&lt;double&gt;(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      ),
      child: child,
    );
  },
)

// 滑动效果
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);  // 从右侧进入
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end)
        .chain(CurveTween(curve: Curves.easeInOut));
    
    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  },
)
```

### 封装自定义路由

```dart
class SlideRoute&lt;T&gt; extends PageRouteBuilder&lt;T&gt; {
  final Widget page;
  final SlideDirection direction;
  
  SlideRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.right:
          begin = Offset(1.0, 0.0);
          break;
        case SlideDirection.left:
          begin = Offset(-1.0, 0.0);
          break;
        case SlideDirection.up:
          begin = Offset(0.0, 1.0);
          break;
        case SlideDirection.down:
          begin = Offset(0.0, -1.0);
          break;
      }
      
      return SlideTransition(
        position: Tween(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 300),
  );
}

enum SlideDirection { right, left, up, down }

// 使用
Navigator.push(context, SlideRoute(page: NextPage(), direction: SlideDirection.up));
```

## 拦截返回操作

### WillPopScope / PopScope

```dart
// Flutter 3.12+ 使用 PopScope
class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,  // 禁止直接返回
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // 显示确认对话框
        final shouldPop = await showDialog&lt;bool&gt;(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认退出？'),
            content: Text('您的更改尚未保存'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('退出'),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('编辑')),
        body: EditForm(),
      ),
    );
  }
}

// 旧版本使用 WillPopScope
WillPopScope(
  onWillPop: () async {
    // 返回 false 阻止返回，true 允许返回
    return await showExitConfirmDialog();
  },
  child: Scaffold(...),
)
```

## Navigator 2.0（声明式路由）

### 基本概念

Navigator 2.0 引入了声明式路由，更适合复杂的导航需求：

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State&lt;MyApp&gt; {
  final _routerDelegate = MyRouterDelegate();
  final _routeInformationParser = MyRouteInformationParser();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

// 路由状态
class AppRoutePath {
  final String? itemId;
  final bool isUnknown;
  
  AppRoutePath.home() : itemId = null, isUnknown = false;
  AppRoutePath.detail(this.itemId) : isUnknown = false;
  AppRoutePath.unknown() : itemId = null, isUnknown = true;
  
  bool get isHome => itemId == null;
  bool get isDetail => itemId != null;
}

// 路由解析器
class MyRouteInformationParser 
    extends RouteInformationParser&lt;AppRoutePath&gt; {
  @override
  Future&lt;AppRoutePath&gt; parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    
    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.home();
    }
    
    if (uri.pathSegments.length == 2 && 
        uri.pathSegments[0] == 'item') {
      return AppRoutePath.detail(uri.pathSegments[1]);
    }
    
    return AppRoutePath.unknown();
  }
  
  @override
  RouteInformation? restoreRouteInformation(AppRoutePath path) {
    if (path.isUnknown) return RouteInformation(location: '/404');
    if (path.isHome) return RouteInformation(location: '/');
    if (path.isDetail) return RouteInformation(location: '/item/${path.itemId}');
    return null;
  }
}

// 路由代理
class MyRouterDelegate extends RouterDelegate&lt;AppRoutePath&gt;
    with ChangeNotifier, PopNavigatorRouterDelegateMixin&lt;AppRoutePath&gt; {
  @override
  final GlobalKey&lt;NavigatorState&gt; navigatorKey = GlobalKey&lt;NavigatorState&gt;();
  
  AppRoutePath? _currentPath;
  
  @override
  AppRoutePath? get currentConfiguration => _currentPath;
  
  @override
  Future&lt;void&gt; setNewRoutePath(AppRoutePath path) async {
    _currentPath = path;
    notifyListeners();
  }
  
  void goToDetail(String id) {
    _currentPath = AppRoutePath.detail(id);
    notifyListeners();
  }
  
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(child: HomePage()),
        if (_currentPath?.isDetail == true)
          MaterialPage(
            child: DetailPage(id: _currentPath!.itemId!),
          ),
        if (_currentPath?.isUnknown == true)
          MaterialPage(child: NotFoundPage()),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        _currentPath = AppRoutePath.home();
        notifyListeners();
        return true;
      },
    );
  }
}
```

## go_router（推荐）

对于大多数应用，推荐使用 go_router 包，它提供了更简洁的 API：

### 安装

```yaml
dependencies:
  go_router: ^13.0.0
```

### 基本使用

```dart
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailPage(id: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
  ],
  errorBuilder: (context, state) => NotFoundPage(),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
```

### 导航操作

```dart
// 跳转
context.go('/detail/123');

// 压栈式跳转
context.push('/detail/123');

// 带查询参数
context.go('/search?q=flutter&page=1');

// 获取查询参数
final query = state.uri.queryParameters['q'];

// 返回
context.pop();

// 替换
context.replace('/home');
```

### 路由守卫（重定向）

```dart
final _router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = AuthService.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }
    
    return null;  // 不重定向
  },
  routes: [...],
);
```

### ShellRoute（嵌套导航）

```dart
GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => ExplorePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
  ],
)

class MainLayout extends StatelessWidget {
  final Widget child;
  
  const MainLayout({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context),
        onTap: (index) => _onItemTapped(context, index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
```

## 最佳实践

### 1. 集中管理路由

```dart
// routes.dart
class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const detail = '/detail';
  static const settings = '/settings';
  
  static String detailWithId(String id) => '/detail/$id';
}

// 使用
context.go(AppRoutes.detailWithId('123'));
```

### 2. 使用 TypedPath（类型安全）

```dart
// 配合 go_router_builder 生成类型安全的路由
@TypedGoRoute&lt;HomeRoute&gt;(path: '/')
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => HomePage();
}

@TypedGoRoute&lt;DetailRoute&gt;(path: '/detail/:id')
class DetailRoute extends GoRouteData {
  final String id;
  DetailRoute({required this.id});
  
  @override
  Widget build(BuildContext context, GoRouterState state) => DetailPage(id: id);
}

// 使用
DetailRoute(id: '123').go(context);
```

### 3. 深链接支持

```dart
// Android: android/app/src/main/AndroidManifest.xml
// <intent-filter>
//   <data android:scheme="myapp" />
//   <data android:host="open" />
// </intent-filter>

// iOS: ios/Runner/Info.plist
// <key>CFBundleURLTypes</key>
// <array>
//   <dict>
//     <key>CFBundleURLSchemes</key>
//     <array>
//       <string>myapp</string>
//     </array>
//   </dict>
// </array>

// 处理深链接
GoRouter(
  initialLocation: '/',
  routes: [...],
  // 深链接会自动解析到对应路由
)
```

## 下一步

掌握路由导航后，下一章我们将学习 [动画系统](./06-animation)，为应用添加生动的交互效果。
