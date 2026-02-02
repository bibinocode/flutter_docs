# Provider 详解

Provider 是 Flutter 官方推荐的入门级状态管理方案，由社区开发者 Remi Rousselet 创建。它基于 InheritedWidget，提供了简洁的 API 来实现状态的跨 Widget 共享。

## 安装配置

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
```

然后运行：
```bash
flutter pub get
```

### 导入

```dart
import 'package:provider/provider.dart';
```

## 核心概念

### Provider 是什么？

Provider 本质上是对 InheritedWidget 的封装，它解决了三个核心问题：

1. **提供数据**：在 Widget 树的某个位置"提供"数据
2. **获取数据**：在子 Widget 中方便地"获取"数据
3. **通知更新**：数据变化时自动通知依赖的 Widget 重建

### 类比理解

想象一棵大树（Widget 树）：
- **Provider** 就像在树干上挂了一个水袋
- **子 Widget** 就像树枝，可以从水袋取水
- **ChangeNotifier** 就像水袋的水位传感器，水量变化时通知所有需要水的树枝

## 基础用法

### 第一步：创建数据模型

```dart
import 'package:flutter/foundation.dart';

class Counter with ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();  // 通知所有监听者
  }
  
  void decrement() {
    _count--;
    notifyListeners();
  }
  
  void reset() {
    _count = 0;
    notifyListeners();
  }
}
```

**关键点：**
- 使用 `with ChangeNotifier` 混入（或 `extends ChangeNotifier` 继承）
- 状态变量设为私有（`_count`），通过 getter 暴露
- 修改状态后调用 `notifyListeners()` 通知更新

### 第二步：提供数据

```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterPage(),
    );
  }
}
```

**关键点：**
- `ChangeNotifierProvider` 创建并提供 `Counter` 实例
- `create` 参数是一个工厂函数，Provider 会在需要时调用它
- 所有 `child` 的子孙 Widget 都可以访问这个 `Counter`

### 第三步：使用数据

#### 方式一：context.watch（推荐）

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // watch 会监听变化，Counter 变化时这个 Widget 会重建
    final counter = context.watch<Counter>();
    
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: Text(
          '${counter.count}',
          style: TextStyle(fontSize: 48),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counter.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### 方式二：Consumer

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        // Consumer 只重建它包裹的部分
        child: Consumer<Counter>(
          builder: (context, counter, child) {
            return Text(
              '${counter.count}',
              style: TextStyle(fontSize: 48),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 这里只调用方法，不需要监听变化
        onPressed: () => context.read<Counter>().increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### 方式三：context.read（不监听）

```dart
// 只获取值，不监听变化（Widget 不会因为这个值变化而重建）
final counter = context.read<Counter>();
counter.increment();
```

#### 方式四：context.select（精确监听）

```dart
// 只监听 count 属性，其他属性变化不会触发重建
final count = context.select<Counter, int>((counter) => counter.count);
```

## watch vs read vs select

这三个方法是使用 Provider 时最重要的区分点：

| 方法 | 是否监听 | 使用场景 |
|-----|---------|---------|
| `watch` | ✅ 监听整个对象 | 在 build 方法中获取数据 |
| `read` | ❌ 不监听 | 在回调/事件处理中调用方法 |
| `select` | ✅ 只监听选定的部分 | 性能优化，避免不必要的重建 |

### 详细对比

```dart
class DetailedExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ watch：在 build 中使用，自动监听变化
    final counter = context.watch<Counter>();
    
    // ❌ 错误：read 在 build 中使用不会自动更新
    // final counter = context.read<Counter>();
    
    // ✅ select：只监听 count，如果 Counter 有其他属性变化不会触发重建
    final count = context.select<Counter, int>((c) => c.count);
    
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () {
            // ✅ read：在回调中使用，只是调用方法
            context.read<Counter>().increment();
            
            // ❌ 警告：watch 不应该在回调中使用
            // context.watch<Counter>().increment();
          },
          child: Text('增加'),
        ),
      ],
    );
  }
}
```

### 记忆口诀

> **build 用 watch，callback 用 read，优化用 select**

## Consumer 深入

### Consumer 的优势

Consumer 可以精确控制重建范围：

```dart
class OptimizedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('OptimizedPage build');  // 只在首次和路由变化时打印
    
    return Scaffold(
      appBar: AppBar(title: Text('优化示例')),
      body: Column(
        children: [
          // 只有这个 Consumer 内部会重建
          Consumer<Counter>(
            builder: (context, counter, child) {
              print('Consumer build');  // counter 变化时打印
              return Text('${counter.count}');
            },
          ),
          
          // 这些不会重建
          const ExpensiveWidget(),
          const AnotherWidget(),
          
          ElevatedButton(
            onPressed: () => context.read<Counter>().increment(),
            child: Text('增加'),
          ),
        ],
      ),
    );
  }
}
```

### Consumer 的 child 参数

```dart
Consumer<Counter>(
  // child 参数不会随状态变化重建
  child: const ExpensiveWidget(),  // 只创建一次
  builder: (context, counter, child) {
    return Column(
      children: [
        Text('${counter.count}'),  // 会重建
        child!,                     // 不会重建，复用之前的
      ],
    );
  },
)
```

### Consumer2, Consumer3...

监听多个 Provider：

```dart
Consumer2<Counter, User>(
  builder: (context, counter, user, child) {
    return Text('${user.name} 的计数: ${counter.count}');
  },
)

// 最多支持到 Consumer6
Consumer6<A, B, C, D, E, F>(
  builder: (context, a, b, c, d, e, f, child) {
    // ...
  },
)
```

## Provider 类型详解

### 1. Provider（最基础）

提供一个不会变化的值：

```dart
// 提供配置
Provider<AppConfig>(
  create: (_) => AppConfig(apiUrl: 'https://api.example.com'),
  child: MyApp(),
)

// 使用
final config = context.read<AppConfig>();
```

### 2. ChangeNotifierProvider（最常用）

提供一个可变的对象，变化时通知更新：

```dart
ChangeNotifierProvider(
  create: (_) => Counter(),
  child: MyApp(),
)
```

### 3. FutureProvider

提供异步获取的数据：

```dart
FutureProvider<User>(
  create: (_) async {
    final response = await http.get(Uri.parse('api/user'));
    return User.fromJson(jsonDecode(response.body));
  },
  initialData: User.empty(),  // 加载时的初始值
  child: MyApp(),
)

// 使用
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();
    return Text(user.name);
  }
}
```

### 4. StreamProvider

提供流数据：

```dart
StreamProvider<List<Message>>(
  create: (_) => chatService.messagesStream,
  initialData: [],
  child: MyApp(),
)
```

### 5. ProxyProvider

依赖其他 Provider：

```dart
MultiProvider(
  providers: [
    Provider<ApiClient>(create: (_) => ApiClient()),
    
    // UserRepository 依赖 ApiClient
    ProxyProvider<ApiClient, UserRepository>(
      update: (_, apiClient, __) => UserRepository(apiClient),
    ),
  ],
  child: MyApp(),
)
```

### 6. ChangeNotifierProxyProvider

当依赖变化时更新 ChangeNotifier：

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => Auth()),
    
    // CartModel 依赖 Auth，当 Auth 变化时更新 CartModel
    ChangeNotifierProxyProvider<Auth, CartModel>(
      create: (_) => CartModel(),
      update: (_, auth, cart) => cart!..updateUser(auth.user),
    ),
  ],
  child: MyApp(),
)
```

## MultiProvider

当需要提供多个 Provider 时：

```dart
// ❌ 嵌套地狱
ChangeNotifierProvider(
  create: (_) => A(),
  child: ChangeNotifierProvider(
    create: (_) => B(),
    child: ChangeNotifierProvider(
      create: (_) => C(),
      child: MyApp(),
    ),
  ),
)

// ✅ 使用 MultiProvider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => A()),
    ChangeNotifierProvider(create: (_) => B()),
    ChangeNotifierProvider(create: (_) => C()),
    Provider(create: (_) => ApiService()),
    FutureProvider(create: (_) => loadConfig()),
  ],
  child: MyApp(),
)
```

## 实战：Todo App with Provider

让我们用 Provider 重构之前的 Todo App：

### 第一步：定义数据模型

```dart
// models/todo.dart
class Todo {
  final String id;
  String title;
  bool isCompleted;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 第二步：创建 Provider

```dart
// providers/todo_provider.dart
import 'package:flutter/foundation.dart';
import '../models/todo.dart';

enum TodoFilter { all, active, completed }

class TodoProvider with ChangeNotifier {
  final List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;

  // Getters
  List<Todo> get todos => _todos;
  TodoFilter get filter => _filter;
  
  // 根据过滤器返回列表
  List<Todo> get filteredTodos {
    switch (_filter) {
      case TodoFilter.active:
        return _todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return _todos.where((t) => t.isCompleted).toList();
      case TodoFilter.all:
      default:
        return _todos;
    }
  }
  
  // 统计信息
  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  // 设置过滤器
  void setFilter(TodoFilter filter) {
    if (_filter != filter) {
      _filter = filter;
      notifyListeners();
    }
  }

  // 添加
  void add(String title) {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _todos.insert(0, todo);  // 新添加的在最前面
    notifyListeners();
  }

  // 切换完成状态
  void toggle(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();
    }
  }

  // 编辑
  void edit(String id, String newTitle) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].title = newTitle;
      notifyListeners();
    }
  }

  // 删除
  void remove(String id) {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // 清除已完成
  void clearCompleted() {
    _todos.removeWhere((t) => t.isCompleted);
    notifyListeners();
  }

  // 全部标记为完成/未完成
  void toggleAll() {
    final allCompleted = _todos.every((t) => t.isCompleted);
    for (var todo in _todos) {
      todo.isCompleted = !allCompleted;
    }
    notifyListeners();
  }
}
```

### 第三步：设置 Provider

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'pages/todo_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: TodoPage(),
    );
  }
}
```

### 第四步：实现 UI

```dart
// pages/todo_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_input.dart';
import '../widgets/todo_list.dart';
import '../widgets/todo_filter.dart';
import '../widgets/todo_stats.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          // 统计信息
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: TodoStats()),
          ),
        ],
      ),
      body: Column(
        children: [
          // 输入框
          TodoInput(),
          
          // 过滤器
          TodoFilterBar(),
          
          // 列表
          const Expanded(child: TodoList()),
        ],
      ),
    );
  }
}
```

```dart
// widgets/todo_input.dart
class TodoInput extends StatefulWidget {
  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    // 使用 read 调用方法
    context.read<TodoProvider>().add(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '添加新任务...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

```dart
// widgets/todo_filter.dart
class TodoFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 使用 select 只监听 filter 变化
    final currentFilter = context.select<TodoProvider, TodoFilter>(
      (provider) => provider.filter,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FilterChip(
            label: '全部',
            filter: TodoFilter.all,
            currentFilter: currentFilter,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '进行中',
            filter: TodoFilter.active,
            currentFilter: currentFilter,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '已完成',
            filter: TodoFilter.completed,
            currentFilter: currentFilter,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final TodoFilter filter;
  final TodoFilter currentFilter;

  const _FilterChip({
    required this.label,
    required this.filter,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == currentFilter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        context.read<TodoProvider>().setFilter(filter);
      },
    );
  }
}
```

```dart
// widgets/todo_list.dart
class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 select 只监听 filteredTodos
    final todos = context.select<TodoProvider, List<Todo>>(
      (provider) => provider.filteredTodos,
    );
    
    if (todos.isEmpty) {
      return const Center(
        child: Text('暂无任务', style: TextStyle(color: Colors.grey)),
      );
    }
    
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(key: ValueKey(todo.id), todo: todo);
      },
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({required this.todo, super.key});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TodoProvider>().remove(todo.id);
      },
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) {
            context.read<TodoProvider>().toggle(todo.id);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
}
```

```dart
// widgets/todo_stats.dart
class TodoStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 分别 select 需要的值
    final completed = context.select<TodoProvider, int>(
      (p) => p.completedCount,
    );
    final total = context.select<TodoProvider, int>(
      (p) => p.totalCount,
    );
    
    return Text(
      '$completed / $total',
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
```

## 测试 Provider

Provider 的一大优势是便于测试：

```dart
// test/todo_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/providers/todo_provider.dart';

void main() {
  group('TodoProvider', () {
    late TodoProvider provider;

    setUp(() {
      provider = TodoProvider();
    });

    test('初始状态为空列表', () {
      expect(provider.todos, isEmpty);
      expect(provider.totalCount, 0);
    });

    test('添加 todo', () {
      provider.add('测试任务');
      
      expect(provider.totalCount, 1);
      expect(provider.todos.first.title, '测试任务');
      expect(provider.todos.first.isCompleted, false);
    });

    test('切换完成状态', () {
      provider.add('测试任务');
      final id = provider.todos.first.id;
      
      provider.toggle(id);
      expect(provider.todos.first.isCompleted, true);
      
      provider.toggle(id);
      expect(provider.todos.first.isCompleted, false);
    });

    test('过滤器工作正常', () {
      provider.add('任务1');
      provider.add('任务2');
      provider.toggle(provider.todos.first.id);  // 完成第一个
      
      provider.setFilter(TodoFilter.active);
      expect(provider.filteredTodos.length, 1);
      expect(provider.filteredTodos.first.title, '任务1');
      
      provider.setFilter(TodoFilter.completed);
      expect(provider.filteredTodos.length, 1);
      expect(provider.filteredTodos.first.title, '任务2');
    });

    test('删除 todo', () {
      provider.add('测试任务');
      final id = provider.todos.first.id;
      
      provider.remove(id);
      expect(provider.todos, isEmpty);
    });
  });
}
```

## Provider 最佳实践

### 1. 合理拆分 Provider

```dart
// ❌ 一个巨大的 Provider
class AppState with ChangeNotifier {
  User? user;
  List<Product> products;
  Cart cart;
  List<Order> orders;
  AppSettings settings;
  // ... 太多了
}

// ✅ 按职责拆分
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ],
  child: MyApp(),
)
```

### 2. 使用 select 优化性能

```dart
// ❌ 监听整个 provider，任何属性变化都会重建
final provider = context.watch<UserProvider>();
return Text(provider.user.name);

// ✅ 只监听需要的属性
final name = context.select<UserProvider, String>((p) => p.user.name);
return Text(name);
```

### 3. 在正确的位置提供 Provider

```dart
// ❌ 在太高的位置提供（如果只在某个功能模块使用）
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SomethingOnlyUsedInOnePage(),  // 浪费资源
      child: MyApp(),
    ),
  );
}

// ✅ 在需要的位置提供
class SomeFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SomethingOnlyUsedHere(),
      child: SomeFeatureContent(),
    );
  }
}
```

### 4. 避免在 notifyListeners 中有副作用

```dart
// ❌ 不好
void updateUser(User user) {
  _user = user;
  saveToStorage(user);  // 副作用
  analytics.track('user_updated');  // 副作用
  notifyListeners();
}

// ✅ 分离副作用
void updateUser(User user) {
  _user = user;
  notifyListeners();
}

// 在 UI 层或专门的服务中处理副作用
```

## Provider 的局限性

1. **模板代码多**：每个 Provider 都需要继承 ChangeNotifier
2. **运行时错误**：如果 Provider 不存在，会在运行时抛异常
3. **组合困难**：多个 Provider 相互依赖时比较麻烦
4. **缺乏代码生成**：不像 Riverpod 有编译时检查

## 下一步

Provider 是一个优秀的入门方案，但随着项目复杂度增加，你可能需要更强大的工具。下一章将学习 [Riverpod 详解](./03-riverpod)，它是 Provider 作者的新作，解决了 Provider 的诸多局限。
