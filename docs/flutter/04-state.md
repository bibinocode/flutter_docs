# 状态管理

状态管理是 Flutter 开发中的核心概念。本章介绍从简单到复杂的状态管理方案。

## 什么是状态？

状态是 UI 在任何时刻需要用来构建界面的数据。

```dart
// 临时状态（Ephemeral State）
// 单个 Widget 内部使用，如 TabBar 当前选中项
int _currentTabIndex = 0;

// 应用状态（App State）
// 多个 Widget 共享，如用户登录信息、购物车
UserInfo? currentUser;
List<CartItem> cartItems;
```

## setState（基础方案）

最简单的状态管理，适合单个 Widget 的临时状态。

```dart
class CounterPage extends StatefulWidget {
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$_count')),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

**优点：** 简单直接  
**缺点：** 状态无法跨 Widget 共享

## InheritedWidget

Flutter 内置的跨 Widget 共享数据方案。

```dart
// 1. 定义 InheritedWidget
class CounterProvider extends InheritedWidget {
  final int count;
  final VoidCallback increment;

  const CounterProvider({
    required this.count,
    required this.increment,
    required Widget child,
  }) : super(child: child);

  static CounterProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>()!;
  }

  @override
  bool updateShouldNotify(CounterProvider oldWidget) {
    return count != oldWidget.count;
  }
}

// 2. 创建状态管理 Widget
class CounterState extends StatefulWidget {
  final Widget child;
  const CounterState({required this.child});

  @override
  State<CounterState> createState() => _CounterStateState();
}

class _CounterStateState extends State<CounterState> {
  int _count = 0;

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return CounterProvider(
      count: _count,
      increment: _increment,
      child: widget.child,
    );
  }
}

// 3. 使用
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CounterState(
      child: MaterialApp(
        home: CounterDisplay(),
      ),
    );
  }
}

class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = CounterProvider.of(context);
    return Text('${counter.count}');
  }
}
```

## Provider（推荐入门）

基于 InheritedWidget 的封装，简化使用。

### 安装

```yaml
dependencies:
  provider: ^6.1.0
```

### 基本使用

```dart
// 1. 定义 Model
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();  // 通知监听者
  }
}

// 2. 提供数据
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Counter(),
      child: MyApp(),
    ),
  );
}

// 3. 消费数据
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 方式1：context.watch - 会重建
    final count = context.watch<Counter>().count;
    
    // 方式2：Consumer - 精确重建范围
    return Consumer<Counter>(
      builder: (context, counter, child) {
        return Text('${counter.count}');
      },
    );
  }
}

// 4. 调用方法（不需要监听变化）
class IncrementButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // 只调用方法，不监听变化
        context.read<Counter>().increment();
      },
      child: Text('增加'),
    );
  }
}
```

### 多 Provider

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserModel()),
    ChangeNotifierProvider(create: (_) => CartModel()),
    Provider(create: (_) => ApiService()),
  ],
  child: MyApp(),
)
```

## Riverpod（推荐进阶）

Provider 的进化版，更安全、更灵活。

### 安装

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
```

### 基本使用

```dart
// 1. 定义 Provider
final counterProvider = StateProvider<int>((ref) => 0);

// 2. 包裹根 Widget
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// 3. 消费数据
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Scaffold(
      body: Center(child: Text('$count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).state++;
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Provider 类型

```dart
// Provider - 只读值
final configProvider = Provider<Config>((ref) => Config());

// StateProvider - 简单可变状态
final counterProvider = StateProvider<int>((ref) => 0);

// StateNotifierProvider - 复杂状态逻辑
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  
  void increment() => state++;
  void decrement() => state--;
}

final counterProvider = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

// FutureProvider - 异步数据
final userProvider = FutureProvider<User>((ref) async {
  final api = ref.read(apiProvider);
  return api.fetchUser();
});

// StreamProvider - 流数据
final messagesProvider = StreamProvider<List<Message>>((ref) {
  final api = ref.read(apiProvider);
  return api.messagesStream();
});
```

### NotifierProvider（Riverpod 2.0 推荐）

```dart
// 定义 Notifier
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;  // 初始值
  
  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// 创建 Provider
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

// 使用
ref.watch(counterProvider);           // 获取值
ref.read(counterProvider.notifier).increment();  // 调用方法
```

### 异步 Notifier

```dart
class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return await _fetchUser();
  }
  
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _api.login(email, password));
  }
  
  void logout() {
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);

// 使用
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (user) => user != null 
          ? Text('Welcome, ${user.name}')
          : Text('Please login'),
    );
  }
}
```

## GetX（简单快速）

轻量级解决方案，包含路由、依赖注入、状态管理。

### 安装

```yaml
dependencies:
  get: ^4.6.6
```

### 基本使用

```dart
// 1. 定义控制器
class CounterController extends GetxController {
  var count = 0.obs;  // .obs 使其可观察
  
  void increment() => count++;
}

// 2. 使用
class CounterPage extends StatelessWidget {
  final controller = Get.put(CounterController());  // 依赖注入
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Text('${controller.count}')),  // 响应式
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### GetBuilder（更高性能）

```dart
class CounterController extends GetxController {
  int count = 0;
  
  void increment() {
    count++;
    update();  // 手动触发更新
  }
}

// 使用
GetBuilder<CounterController>(
  builder: (controller) => Text('${controller.count}'),
)
```

## Bloc（企业级）

基于事件和状态的模式，适合大型应用。

### 安装

```yaml
dependencies:
  flutter_bloc: ^8.1.0
```

### 基本使用

```dart
// 1. 定义事件
abstract class CounterEvent {}
class IncrementEvent extends CounterEvent {}
class DecrementEvent extends CounterEvent {}

// 2. 定义状态
class CounterState {
  final int count;
  CounterState(this.count);
}

// 3. 定义 Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
    on<DecrementEvent>((event, emit) {
      emit(CounterState(state.count - 1));
    });
  }
}

// 4. 提供 Bloc
BlocProvider(
  create: (_) => CounterBloc(),
  child: MyApp(),
)

// 5. 使用
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    return Text('${state.count}');
  },
)

// 触发事件
context.read<CounterBloc>().add(IncrementEvent());
```

### Cubit（简化版）

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

// 使用
BlocBuilder<CounterCubit, int>(
  builder: (context, count) => Text('$count'),
)

context.read<CounterCubit>().increment();
```

## 方案对比

| 方案 | 复杂度 | 适用场景 | 学习曲线 |
|-----|-------|---------|---------|
| setState | 低 | 单 Widget 临时状态 | 低 |
| Provider | 中 | 中小型应用 | 低 |
| Riverpod | 中 | 中大型应用 | 中 |
| GetX | 低 | 快速开发 | 低 |
| Bloc | 高 | 大型/企业应用 | 高 |

## 最佳实践

### 1. 分离 UI 和业务逻辑

```dart
// ❌ 不好
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<User> users = [];
  
  Future<void> _loadUsers() async {
    final response = await http.get(Uri.parse('api/users'));
    setState(() {
      users = jsonDecode(response.body);
    });
  }
}

// ✅ 好 - 分离到 Controller/Notifier
class UserNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() => _loadUsers();
  
  Future<List<User>> _loadUsers() async {
    final api = ref.read(apiProvider);
    return api.getUsers();
  }
}
```

### 2. 状态提升

```dart
// 把状态放在最近的公共祖先
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
```

### 3. 避免不必要的重建

```dart
// 使用 select 只监听需要的部分
final userName = ref.watch(userProvider.select((user) => user.name));

// 使用 Consumer 缩小重建范围
Consumer<Counter>(
  builder: (context, counter, child) {
    return Text('${counter.count}');
  },
  child: ExpensiveWidget(),  // 不会重建
)
```

## 下一步

掌握状态管理后，下一章我们将学习 [网络请求](./05-networking)，处理 API 调用。
