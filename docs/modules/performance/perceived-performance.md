# 性能优化进阶

即使帧率稳定在 60 FPS，用户依然可能感觉应用"卡顿"。本章深入探讨 Flutter 应用真正的性能瓶颈，以及如何构建"体感流畅"的应用。

## 60 FPS 的误区

### 帧率 vs 响应速度

```
┌─────────────────────────────────────────────────────────────────┐
│                  用户体验的关键指标                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   帧率 (FPS)                    响应延迟 (Latency)              │
│   ────────────                  ────────────────                │
│   渲染性能指标                   用户感知指标                    │
│                                                                 │
│   ✓ DevTools 可测量             ✗ 难以量化                      │
│   ✓ 60 FPS = 16.67ms/帧        ✓ 点击 → 反馈的时间              │
│                                                                 │
│   用户不感知"帧"                用户感知"延迟"                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 真实案例

> "我们的应用帧率稳在 60 FPS，但用户还是抱怨卡顿。"

这种情况非常常见。原因在于：

- **按钮点击后反馈迟缓** - 即使不掉帧
- **页面切换感觉沉重** - 等待依赖注入
- **首次交互很慢** - 启动任务溢出

## 体感迟缓的根源

### 1. UI 在等待网络

即使网络很快，等待网络响应也会让用户感到摩擦：

```dart
// ❌ 错误方式：UI 等待网络
class BadProductPage extends StatefulWidget {
  @override
  State<BadProductPage> createState() => _BadProductPageState();
}

class _BadProductPageState extends State<BadProductPage> {
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    // UI 被阻塞，等待网络
    final product = await api.getProduct(widget.id);
    setState(() {
      _product = product;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator(); // 用户看到加载中
    }
    return ProductContent(product: _product!);
  }
}
```

```dart
// ✅ 正确方式：UI 监听本地状态，网络负责同步
class GoodProductPage extends StatelessWidget {
  final String productId;
  
  const GoodProductPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductRepository>(
      builder: (context, repo, _) {
        // 先显示本地缓存数据
        final product = repo.getProduct(productId);
        
        if (product == null) {
          // 只有完全没有数据时才显示加载
          return const LoadingIndicator();
        }
        
        return ProductContent(
          product: product,
          isRefreshing: repo.isRefreshing(productId),
        );
      },
    );
  }
}

class ProductRepository extends ChangeNotifier {
  final Map<String, Product> _cache = {};
  final Set<String> _refreshing = {};
  
  Product? getProduct(String id) {
    // 返回缓存数据的同时触发后台刷新
    if (!_refreshing.contains(id)) {
      _refreshInBackground(id);
    }
    return _cache[id];
  }
  
  bool isRefreshing(String id) => _refreshing.contains(id);
  
  Future<void> _refreshInBackground(String id) async {
    _refreshing.add(id);
    notifyListeners();
    
    try {
      final product = await api.getProduct(id);
      _cache[id] = product;
    } finally {
      _refreshing.remove(id);
      notifyListeners();
    }
  }
}
```

### 2. 不掉帧的重绘风暴

有些重绘不会导致掉帧，但会延迟反馈：

```dart
// ❌ 错误：简单点击触发整个树重建
class BadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppBloc(),
      child: BlocBuilder<AppBloc, AppState>(
        // 整个应用都在监听，任何状态变化都重建
        builder: (context, state) {
          return MaterialApp(
            home: HomePage(),
          );
        },
      ),
    );
  }
}
```

```dart
// ✅ 正确：状态变化是局部的
class GoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => SettingsBloc()),
      ],
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 只有 UserHeader 监听用户状态
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) => UserHeader(user: state.user),
          ),
          // 内容区域不受影响
          const ContentArea(),
          // 只有设置按钮监听设置状态
          BlocSelector<SettingsBloc, SettingsState, bool>(
            selector: (state) => state.isDarkMode,
            builder: (context, isDark) => ThemeToggle(isDark: isDark),
          ),
        ],
      ),
    );
  }
}
```

### 3. 启动任务溢出

冷启动不在第一帧结束，太多初始化任务会让首屏交互变慢：

```dart
// ❌ 错误：所有初始化都在启动时执行
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 这些都阻塞了首屏渲染
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await dotenv.load();
  await initAnalytics();
  await syncUserData();
  await preloadImages();
  await checkForUpdates();
  
  runApp(MyApp());
}
```

```dart
// ✅ 正确：延迟非关键初始化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 只保留必要的初始化
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 首帧渲染后再执行其他初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deferredInit();
    });
  }
  
  Future<void> _deferredInit() async {
    // 延迟执行非关键任务
    await Future.delayed(const Duration(milliseconds: 500));
    
    await Hive.initFlutter();
    await initAnalytics();
    
    // 更低优先级的任务
    Future.microtask(() async {
      await syncUserData();
      await checkForUpdates();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
```

## 让应用体感飞快的原则

### 核心原则

1. **UI 永远不等待网络**
2. **本地状态是唯一数据源**
3. **启动任务激进延迟**
4. **同步逻辑显式可中断**
5. **状态改变是局部的**

### 实践：乐观更新

```dart
class OptimisticUpdateExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TodoRepository>(
      builder: (context, repo, _) {
        return ListView.builder(
          itemCount: repo.todos.length,
          itemBuilder: (context, index) {
            final todo = repo.todos[index];
            return CheckboxListTile(
              value: todo.completed,
              title: Text(todo.title),
              onChanged: (value) {
                // 乐观更新：立即更新 UI
                repo.toggleTodo(todo.id);
              },
            );
          },
        );
      },
    );
  }
}

class TodoRepository extends ChangeNotifier {
  final List<Todo> _todos = [];
  final TodoApi _api;
  
  List<Todo> get todos => List.unmodifiable(_todos);
  
  Future<void> toggleTodo(String id) async {
    // 1. 立即更新本地状态（乐观更新）
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    
    final oldTodo = _todos[index];
    _todos[index] = oldTodo.copyWith(completed: !oldTodo.completed);
    notifyListeners(); // UI 立即更新
    
    // 2. 后台同步到服务器
    try {
      await _api.updateTodo(_todos[index]);
    } catch (e) {
      // 3. 失败时回滚
      _todos[index] = oldTodo;
      notifyListeners();
      // 显示错误提示
    }
  }
}
```

### 实践：预加载与预渲染

```dart
class PreloadExample extends StatefulWidget {
  @override
  State<PreloadExample> createState() => _PreloadExampleState();
}

class _PreloadExampleState extends State<PreloadExample> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        // 预加载下一页数据
        if (index == items.length - 5) {
          context.read<ItemRepository>().preloadNextPage();
        }
        
        return ItemCard(
          item: items[index],
          onTap: () => _navigateToDetail(items[index]),
        );
      },
    );
  }
  
  void _navigateToDetail(Item item) {
    // 导航前预加载详情数据
    context.read<DetailRepository>().preload(item.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(itemId: item.id),
      ),
    );
  }
}
```

### 实践：骨架屏而非加载圈

```dart
class SkeletonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductRepository>(
      builder: (context, repo, _) {
        final products = repo.products;
        
        if (products == null) {
          // 显示骨架屏，而不是转圈
          return ProductListSkeleton();
        }
        
        return ProductList(products: products);
      },
    );
  }
}

class ProductListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: const ProductCardSkeleton(),
        );
      },
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图片占位
            Container(
              width: 80,
              height: 80,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题占位
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // 副标题占位
                  Container(
                    height: 14,
                    width: 150,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 状态管理优化

### 精确的状态订阅

```dart
// ❌ 订阅整个状态对象
BlocBuilder<UserBloc, UserState>(
  builder: (context, state) {
    // 任何字段变化都会重建
    return Text(state.user.name);
  },
)

// ✅ 只订阅需要的字段
BlocSelector<UserBloc, UserState, String>(
  selector: (state) => state.user.name,
  builder: (context, name) {
    return Text(name);
  },
)

// ✅ 使用 buildWhen 控制重建
BlocBuilder<UserBloc, UserState>(
  buildWhen: (previous, current) {
    // 只有 name 变化时才重建
    return previous.user.name != current.user.name;
  },
  builder: (context, state) {
    return Text(state.user.name);
  },
)
```

### 使用 Selector 优化 Provider

```dart
class OptimizedConsumer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 只监听 name
        Selector<UserModel, String>(
          selector: (_, user) => user.name,
          builder: (_, name, __) => Text(name),
        ),
        
        // 只监听 avatar
        Selector<UserModel, String?>(
          selector: (_, user) => user.avatarUrl,
          builder: (_, avatarUrl, __) => Avatar(url: avatarUrl),
        ),
        
        // 这个按钮不需要监听任何状态
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                // 只在点击时读取，不订阅
                context.read<UserModel>().logout();
              },
              child: const Text('退出'),
            );
          },
        ),
      ],
    );
  }
}
```

## 渲染优化

### 使用 const 构造函数

```dart
// ❌ 每次父组件重建都会重建
class BadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Hello'),  // 非 const，每次都重建
        Icon(Icons.star),
        SizedBox(height: 16),
      ],
    );
  }
}

// ✅ const Widget 不会重建
class GoodWidget extends StatelessWidget {
  const GoodWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Hello'),  // const，复用实例
        Icon(Icons.star),
        SizedBox(height: 16),
      ],
    );
  }
}
```

### RepaintBoundary 隔离重绘

```dart
class AnimatedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        // 每个 item 独立重绘，不影响其他
        return RepaintBoundary(
          child: ListItem(index: index),
        );
      },
    );
  }
}
```

### 避免不必要的布局计算

```dart
// ❌ 使用 ListView 显示固定数量的项目
Widget buildBadList() {
  return ListView(
    children: [
      Item1(),
      Item2(),
      Item3(),
    ],
  );
}

// ✅ 使用 Column + SingleChildScrollView
Widget buildGoodList() {
  return SingleChildScrollView(
    child: Column(
      children: [
        const Item1(),
        const Item2(),
        const Item3(),
      ],
    ),
  );
}
```

## 思维转变

### 新的性能问题

不要再问：

> "我们达到 60 FPS 了吗？"

开始问：

> "应用反馈给用户的速度有多快？"

### 检查清单

| 检查项 | 说明 |
|--------|------|
| 点击后立即有反馈吗？ | 按钮按下状态、涟漪效果 |
| 首屏多久可交互？ | 不只是显示，而是可以操作 |
| 列表滚动时有预加载吗？ | 滚动到底部前加载更多 |
| 本地数据优先显示吗？ | 先缓存后刷新 |
| 状态订阅精确吗？ | 避免不必要的重建 |

## 性能监测

```dart
// 自定义性能追踪
class PerformanceTracker {
  static final Map<String, Stopwatch> _timers = {};
  
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }
  
  static Duration? stopTimer(String name) {
    final timer = _timers.remove(name);
    if (timer == null) return null;
    timer.stop();
    
    final duration = timer.elapsed;
    debugPrint('[$name] took ${duration.inMilliseconds}ms');
    return duration;
  }
  
  static T measure<T>(String name, T Function() action) {
    startTimer(name);
    final result = action();
    stopTimer(name);
    return result;
  }
  
  static Future<T> measureAsync<T>(String name, Future<T> Function() action) async {
    startTimer(name);
    final result = await action();
    stopTimer(name);
    return result;
  }
}

// 使用
await PerformanceTracker.measureAsync('loadProducts', () async {
  await productRepo.loadProducts();
});
```

## 最佳实践

::: tip 性能优化原则
1. **用户感知优先** - 优化用户能感受到的延迟
2. **本地状态为主** - 减少对网络的等待
3. **延迟非关键任务** - 首屏优先，其他延后
4. **精确状态订阅** - 避免不必要的重建
5. **乐观更新** - 先更新 UI，后台同步
:::

::: warning 常见误区
- 盲目追求 60 FPS，忽视响应延迟
- 所有初始化都在启动时执行
- 整个页面订阅同一个状态
- 等待网络才更新 UI
:::

## 参考资源

- [Flutter 性能最佳实践](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools 性能视图](https://docs.flutter.dev/tools/devtools/performance)
- [渲染性能优化](https://docs.flutter.dev/perf/rendering-performance)
