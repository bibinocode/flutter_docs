# Riverpod 详解

Riverpod 是 Provider 作者 Remi Rousselet 的新作，被称为 "Provider 2.0"。它保留了 Provider 的核心理念，同时解决了 Provider 的诸多局限，是目前最受推崇的 Flutter 状态管理方案之一。

## 为什么选择 Riverpod？

### Provider 的痛点

```dart
// 问题 1：运行时错误
class SomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 如果忘记提供 UserProvider，运行时才会报错
    final user = context.watch<UserProvider>();
    return Text(user.name);
  }
}

// 问题 2：组合困难
// AuthProvider 依赖 ApiClient
// 需要使用 ProxyProvider，写法繁琐
```

### Riverpod 的解决方案

```dart
// 编译时检查：如果 userProvider 不存在，编译就会报错
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

// 组合简单：直接使用 ref.watch
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(apiClientProvider);  // 直接获取依赖
  return AuthNotifier(api);
});
```

## 安装配置

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5  # 可选：代码生成

dev_dependencies:
  riverpod_generator: ^2.4.0   # 可选：代码生成
  build_runner: ^2.4.8         # 可选：代码生成
```

### 基础设置

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // ProviderScope 是必须的，用于存储 Provider 的状态
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## 核心概念

### Provider vs Riverpod 对比

| 概念 | Provider | Riverpod |
|-----|----------|----------|
| 状态容器 | ChangeNotifierProvider | 多种 Provider 类型 |
| 提供位置 | Widget 树中 | 全局声明 |
| 获取方式 | context.watch/read | ref.watch/read |
| 依赖注入 | ProxyProvider | ref.watch 自动处理 |
| 错误检测 | 运行时 | 编译时 |

### Ref 对象

`ref` 是 Riverpod 的核心，用于：
- 读取其他 Provider
- 监听其他 Provider 的变化
- 控制 Provider 的生命周期

```dart
final myProvider = Provider<String>((ref) {
  // 在 Provider 内部使用 ref
  final otherValue = ref.watch(otherProvider);
  return 'Hello, $otherValue';
});

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 在 Widget 中使用 ref
    final value = ref.watch(myProvider);
    return Text(value);
  }
}
```

## Provider 类型详解

### 1. Provider（只读值）

最简单的 Provider，提供一个不会主动变化的值：

```dart
// 提供配置
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig(
    apiUrl: 'https://api.example.com',
    timeout: Duration(seconds: 30),
  );
});

// 提供服务（单例）
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(config.apiUrl);
});

// 使用
class SomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return Text('API: ${config.apiUrl}');
  }
}
```

### 2. StateProvider（简单可变状态）

用于简单的状态，如开关、计数器：

```dart
// 定义
final counterProvider = StateProvider<int>((ref) => 0);

// 使用
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Column(
      children: [
        Text('$count'),
        ElevatedButton(
          onPressed: () {
            // 方式 1：直接修改
            ref.read(counterProvider.notifier).state++;
            
            // 方式 2：使用 update
            ref.read(counterProvider.notifier).update((state) => state + 1);
          },
          child: Text('增加'),
        ),
      ],
    );
  }
}

// 更多示例
final isDarkModeProvider = StateProvider<bool>((ref) => false);
final selectedTabProvider = StateProvider<int>((ref) => 0);
final searchQueryProvider = StateProvider<String>((ref) => '');
```

### 3. StateNotifierProvider（复杂可变状态）

用于有多个操作的复杂状态：

```dart
// 状态类
class TodoListState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;
  
  const TodoListState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
  });
  
  TodoListState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodoListState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// StateNotifier
class TodoListNotifier extends StateNotifier<TodoListState> {
  TodoListNotifier() : super(const TodoListState());
  
  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
    );
    state = state.copyWith(
      todos: [...state.todos, newTodo],
    );
  }
  
  void toggleTodo(String id) {
    state = state.copyWith(
      todos: state.todos.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList(),
    );
  }
  
  void removeTodo(String id) {
    state = state.copyWith(
      todos: state.todos.where((t) => t.id != id).toList(),
    );
  }
  
  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final todos = await api.fetchTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// Provider 定义
final todoListProvider = StateNotifierProvider<TodoListNotifier, TodoListState>((ref) {
  return TodoListNotifier();
});

// 使用
class TodoPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoListProvider);
    
    if (todoState.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (todoState.error != null) {
      return Text('错误: ${todoState.error}');
    }
    
    return ListView.builder(
      itemCount: todoState.todos.length,
      itemBuilder: (context, index) {
        final todo = todoState.todos[index];
        return ListTile(
          title: Text(todo.title),
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) {
              ref.read(todoListProvider.notifier).toggleTodo(todo.id);
            },
          ),
        );
      },
    );
  }
}
```

### 4. FutureProvider（异步数据）

用于一次性的异步操作：

```dart
// 基本用法
final userProvider = FutureProvider<User>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.fetchCurrentUser();
});

// 带参数的 FutureProvider
final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  final api = ref.watch(apiClientProvider);
  return api.fetchUser(userId);
});

// 使用
class UserProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    // 使用 when 处理所有状态
    return userAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('错误: $error'),
      data: (user) => Column(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
          Text(user.name),
          Text(user.email),
        ],
      ),
    );
  }
}

// 使用带参数的版本
class OtherUserPage extends ConsumerWidget {
  final String userId;
  
  const OtherUserPage({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));
    
    return userAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('错误: $e'),
      data: (user) => Text(user.name),
    );
  }
}
```

### 5. StreamProvider（流数据）

用于持续监听的流：

```dart
// 定义
final messagesProvider = StreamProvider<List<Message>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.messagesStream;
});

// WebSocket 示例
final webSocketProvider = StreamProvider<dynamic>((ref) {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://example.com/socket'),
  );
  
  // 当 Provider 被销毁时关闭连接
  ref.onDispose(() {
    channel.sink.close();
  });
  
  return channel.stream;
});

// 使用
class ChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider);
    
    return messagesAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('连接失败: $error')),
      data: (messages) => ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return MessageBubble(message: message);
        },
      ),
    );
  }
}
```

### 6. NotifierProvider（Riverpod 2.0 推荐）

新版 Riverpod 推荐的方式，替代 StateNotifierProvider：

```dart
// 同步 Notifier
class Counter extends Notifier<int> {
  @override
  int build() {
    // 初始值
    return 0;
  }
  
  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<Counter, int>(() {
  return Counter();
});

// 异步 Notifier
class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // 初始加载
    return _fetchCurrentUser();
  }
  
  Future<User?> _fetchCurrentUser() async {
    final api = ref.read(apiClientProvider);
    try {
      return await api.fetchCurrentUser();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      return api.login(email, password);
    });
  }
  
  Future<void> logout() async {
    state = const AsyncLoading();
    final api = ref.read(apiClientProvider);
    await api.logout();
    state = const AsyncData(null);
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchCurrentUser);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});

// 使用
class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('错误: $e')),
      data: (user) {
        if (user == null) {
          return const LoginPrompt();
        }
        return UserProfile(user: user);
      },
    );
  }
}
```

## ref.watch vs ref.read vs ref.listen

### ref.watch

- 监听 Provider 的变化
- Provider 变化时自动重建 Widget
- **必须在 build 方法中使用**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // ✅ 正确：在 build 中使用 watch
  final count = ref.watch(counterProvider);
  
  return Text('$count');
}
```

### ref.read

- 只读取当前值，不监听变化
- **适合在回调/事件处理中使用**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return ElevatedButton(
    onPressed: () {
      // ✅ 正确：在回调中使用 read
      ref.read(counterProvider.notifier).state++;
    },
    child: Text('增加'),
  );
}
```

### ref.listen

- 监听变化并执行副作用
- **适合显示 Snackbar、导航等**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // 监听错误状态，显示 Snackbar
  ref.listen<AsyncValue<User?>>(userProvider, (previous, next) {
    if (next.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: ${next.error}')),
      );
    }
  });
  
  // 监听登录状态，自动导航
  ref.listen<User?>(currentUserProvider, (previous, next) {
    if (previous != null && next == null) {
      // 用户登出，跳转到登录页
      Navigator.of(context).pushReplacementNamed('/login');
    }
  });
  
  return ...;
}
```

## Provider 修饰符

### .family（带参数）

```dart
// 根据 ID 获取用户
final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  final api = ref.watch(apiClientProvider);
  return api.fetchUser(userId);
});

// 根据分类获取商品
final productsByCategoryProvider = FutureProvider.family<List<Product>, String>((ref, category) async {
  final api = ref.watch(apiClientProvider);
  return api.fetchProducts(category: category);
});

// 使用
ref.watch(userByIdProvider('user_123'));
ref.watch(productsByCategoryProvider('electronics'));
```

### .autoDispose（自动销毁）

```dart
// 当没有 Widget 监听时，自动销毁状态
final searchResultsProvider = FutureProvider.autoDispose
    .family<List<Product>, String>((ref, query) async {
  // 取消上一次请求
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());
  
  // 防抖
  await Future.delayed(const Duration(milliseconds: 300));
  
  // 检查是否已被取消
  if (cancelToken.isCancelled) {
    throw Exception('Cancelled');
  }
  
  final api = ref.watch(apiClientProvider);
  return api.searchProducts(query, cancelToken: cancelToken);
});

// 保持存活一段时间
final cachedDataProvider = FutureProvider.autoDispose<Data>((ref) async {
  // 即使没有监听者，也保持 5 分钟
  ref.keepAlive();
  final timer = Timer(Duration(minutes: 5), () {
    ref.invalidateSelf();  // 5 分钟后失效
  });
  ref.onDispose(() => timer.cancel());
  
  return fetchData();
});
```

## 组合 Provider

Riverpod 的强大之处在于 Provider 之间可以轻松组合：

```dart
// 基础 Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// 依赖 apiClient 的 Repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return UserRepository(api);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ProductRepository(api);
});

// 依赖 Repository 的 UseCase
final getCurrentUserProvider = FutureProvider<User?>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getCurrentUser();
});

// 依赖多个 Provider 的派生状态
final isLoggedInProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(getCurrentUserProvider);
  return userAsync.valueOrNull != null;
});

// 条件依赖
final personalizedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final productRepo = ref.watch(productRepositoryProvider);
  
  if (isLoggedIn) {
    final user = await ref.watch(getCurrentUserProvider.future);
    return productRepo.getRecommendations(user!.id);
  } else {
    return productRepo.getPopularProducts();
  }
});
```

## Consumer Widget 详解

### ConsumerWidget

替代 StatelessWidget：

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(myProvider);
    return Text(value);
  }
}
```

### ConsumerStatefulWidget

替代 StatefulWidget：

```dart
class MyStatefulPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyStatefulPage> createState() => _MyStatefulPageState();
}

class _MyStatefulPageState extends ConsumerState<MyStatefulPage> {
  @override
  void initState() {
    super.initState();
    // 可以在 initState 中使用 ref
    ref.read(analyticsProvider).logPageView('MyPage');
  }
  
  @override
  Widget build(BuildContext context) {
    final value = ref.watch(myProvider);
    return Text(value);
  }
}
```

### Consumer（局部使用）

在普通 Widget 中局部使用：

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('不需要 Provider 的部分'),
        
        // 只有这部分需要 Provider
        Consumer(
          builder: (context, ref, child) {
            final value = ref.watch(myProvider);
            return Text(value);
          },
        ),
        
        Text('也不需要 Provider 的部分'),
      ],
    );
  }
}
```

## 实战：购物车应用

完整的购物车示例，展示 Riverpod 的实际应用：

```dart
// === 数据模型 ===
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class CartItem {
  final Product product;
  final int quantity;
  
  const CartItem({required this.product, this.quantity = 1});
  
  double get total => product.price * quantity;
  
  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// === Providers ===

// 商品列表
final productsProvider = FutureProvider<List<Product>>((ref) async {
  // 模拟 API 请求
  await Future.delayed(Duration(seconds: 1));
  return [
    Product(id: '1', name: 'iPhone 15', price: 7999, imageUrl: '...'),
    Product(id: '2', name: 'MacBook Pro', price: 14999, imageUrl: '...'),
    Product(id: '3', name: 'AirPods Pro', price: 1899, imageUrl: '...'),
  ];
});

// 购物车状态
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];
  
  void addItem(Product product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );
    
    if (existingIndex >= 0) {
      // 已存在，增加数量
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      // 不存在，添加新项
      state = [...state, CartItem(product: product)];
    }
  }
  
  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }
  
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }
  
  void clear() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

// 派生状态：购物车数量
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

// 派生状态：购物车总价
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.total);
});

// === UI ===

// 商品列表页
class ProductListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('商品列表'),
        actions: [
          Badge(
            label: Text('$cartCount'),
            isLabelVisible: cartCount > 0,
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('加载失败: $e')),
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        ),
      ),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final Product product;
  
  const ProductCard({required this.product});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(product.imageUrl, width: 50, height: 50),
        title: Text(product.name),
        subtitle: Text('¥${product.price}'),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: () {
            ref.read(cartProvider.notifier).addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已添加 ${product.name}'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 购物车页
class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('购物车'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clear();
              },
              child: Text('清空', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(child: Text('购物车是空的'))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return CartItemTile(item: item);
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '总计: ¥${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // 结算逻辑
                      },
                      child: Text('结算'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class CartItemTile extends ConsumerWidget {
  final CartItem item;
  
  const CartItemTile({required this.item});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(cartProvider.notifier).removeItem(item.product.id);
      },
      child: ListTile(
        leading: Image.network(item.product.imageUrl, width: 50, height: 50),
        title: Text(item.product.name),
        subtitle: Text('¥${item.product.price}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                ref.read(cartProvider.notifier).updateQuantity(
                  item.product.id,
                  item.quantity - 1,
                );
              },
            ),
            Text('${item.quantity}'),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                ref.read(cartProvider.notifier).updateQuantity(
                  item.product.id,
                  item.quantity + 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 测试

Riverpod 非常便于测试：

```dart
void main() {
  group('CartNotifier', () {
    test('添加商品', () {
      final container = ProviderContainer();
      final notifier = container.read(cartProvider.notifier);
      
      notifier.addItem(testProduct);
      
      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartItemCountProvider), 1);
    });
    
    test('相同商品增加数量', () {
      final container = ProviderContainer();
      final notifier = container.read(cartProvider.notifier);
      
      notifier.addItem(testProduct);
      notifier.addItem(testProduct);
      
      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartProvider).first.quantity, 2);
    });
  });
}
```

## 最佳实践

1. **使用 NotifierProvider** 而非 StateNotifierProvider（Riverpod 2.0+）
2. **使用 select** 优化性能
3. **使用 autoDispose** 避免内存泄漏
4. **使用 family** 处理参数化场景
5. **在 Provider 内使用 ref.watch** 实现响应式依赖

## 下一步

Riverpod 是功能强大且灵活的状态管理方案。下一章我们将学习 [GetX 详解](./04-getx)，一个追求简洁的全功能方案。
