# Bloc 详解

Bloc（Business Logic Component）是 Flutter 社区最推崇的状态管理方案之一。它强调清晰的架构、可预测的状态变化和高度的可测试性。

## 为什么选择 Bloc？

### 核心理念

Bloc 遵循严格的单向数据流：

```
UI → Event → Bloc → State → UI
```

这种模式让每一次状态变化都是可追踪、可预测的。

### 与其他方案对比

| 特点 | setState | Provider | GetX | Bloc |
|------|----------|----------|------|------|
| 学习曲线 | 低 | 中 | 低 | 高 |
| 可预测性 | 低 | 中 | 中 | 高 |
| 可测试性 | 低 | 中 | 低 | 高 |
| 样板代码 | 无 | 少 | 少 | 多 |
| 适合规模 | 小 | 中 | 小中 | 大 |

## 安装配置

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.5
  equatable: ^2.0.5  # 推荐：简化状态比较

dev_dependencies:
  bloc_test: ^9.1.7  # 测试工具
```

### VS Code 扩展

推荐安装 **Bloc** 扩展，提供代码片段和文件生成功能。

## 核心概念

### 三要素：Event、State、Bloc

```dart
// 1. Event：用户行为或外部事件
abstract class CounterEvent {}

class IncrementPressed extends CounterEvent {}
class DecrementPressed extends CounterEvent {}
class ResetPressed extends CounterEvent {}

// 2. State：应用状态
class CounterState {
  final int count;
  const CounterState(this.count);
}

// 3. Bloc：连接 Event 和 State
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0)) {
    on<IncrementPressed>((event, emit) {
      emit(CounterState(state.count + 1));
    });
    
    on<DecrementPressed>((event, emit) {
      emit(CounterState(state.count - 1));
    });
    
    on<ResetPressed>((event, emit) {
      emit(const CounterState(0));
    });
  }
}
```

### 使用 Equatable（推荐）

Equatable 简化了状态和事件的比较：

```dart
// 不使用 Equatable
class UserState {
  final String name;
  final int age;
  
  const UserState({required this.name, required this.age});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserState &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age;
  
  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

// 使用 Equatable
class UserState extends Equatable {
  final String name;
  final int age;
  
  const UserState({required this.name, required this.age});
  
  @override
  List<Object?> get props => [name, age];
}
```

## Cubit：简化版 Bloc

如果业务逻辑简单，可以使用 Cubit（不需要定义 Event）：

```dart
// Cubit 定义
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

// 使用
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<CounterCubit, int>(
          builder: (context, count) {
            return Text('$count', style: TextStyle(fontSize: 48));
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().increment(),
            child: Icon(Icons.add),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

### Cubit vs Bloc 对比

| 场景 | 推荐 |
|------|------|
| 简单状态（计数器、开关） | Cubit |
| 需要追踪事件历史 | Bloc |
| 需要 EventTransformer | Bloc |
| 复杂的业务逻辑 | Bloc |
| 快速原型 | Cubit |

## Event 详解

### 定义 Event

使用密封类（Dart 3.0+）或抽象类：

```dart
// 方式 1：密封类（推荐）
sealed class TodoEvent {}

class TodosLoaded extends TodoEvent {}

class TodoAdded extends TodoEvent {
  final String title;
  TodoAdded(this.title);
}

class TodoToggled extends TodoEvent {
  final String id;
  TodoToggled(this.id);
}

class TodoDeleted extends TodoEvent {
  final String id;
  TodoDeleted(this.id);
}

// 方式 2：Equatable
abstract class TodoEvent extends Equatable {
  const TodoEvent();
  
  @override
  List<Object?> get props => [];
}

class TodoAdded extends TodoEvent {
  final String title;
  
  const TodoAdded(this.title);
  
  @override
  List<Object?> get props => [title];
}
```

### Event Transformer

控制事件处理方式：

```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    // 防抖：停止输入 300ms 后才处理
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    
    // 节流：每 1 秒最多处理一次
    on<SearchResultTapped>(
      _onSearchResultTapped,
      transformer: throttle(const Duration(seconds: 1)),
    );
    
    // 顺序处理：一个一个处理
    on<SearchSubmitted>(
      _onSearchSubmitted,
      transformer: sequential(),
    );
    
    // 只处理最新：取消之前的，只处理最新
    on<SearchRefreshed>(
      _onSearchRefreshed,
      transformer: restartable(),
    );
  }
}

// 自定义 transformer
EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) {
    return events.debounceTime(duration).asyncExpand(mapper);
  };
}

EventTransformer<T> throttle<T>(Duration duration) {
  return (events, mapper) {
    return events.throttleTime(duration).asyncExpand(mapper);
  };
}
```

## State 详解

### 状态设计模式

#### 单一状态类（适合简单场景）

```dart
class CounterState extends Equatable {
  final int count;
  
  const CounterState({this.count = 0});
  
  CounterState copyWith({int? count}) {
    return CounterState(count: count ?? this.count);
  }
  
  @override
  List<Object?> get props => [count];
}
```

#### 状态枚举 + 数据（常用模式）

```dart
enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  final TodoStatus status;
  final List<Todo> todos;
  final String? error;
  
  const TodoState({
    this.status = TodoStatus.initial,
    this.todos = const [],
    this.error,
  });
  
  TodoState copyWith({
    TodoStatus? status,
    List<Todo>? todos,
    String? error,
  }) {
    return TodoState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      error: error ?? this.error,
    );
  }
  
  @override
  List<Object?> get props => [status, todos, error];
}
```

#### 多状态类（适合复杂场景）

```dart
sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}

// 使用 switch 处理
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return switch (state) {
      AuthInitial() => SplashScreen(),
      AuthLoading() => LoadingIndicator(),
      AuthAuthenticated(:final user) => HomePage(user: user),
      AuthUnauthenticated() => LoginPage(),
      AuthFailure(:final message) => ErrorPage(message: message),
    };
  },
)
```

## BlocProvider 详解

### 提供 Bloc

```dart
// 单个 Bloc
BlocProvider(
  create: (context) => CounterBloc(),
  child: CounterPage(),
)

// 多个 Bloc
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => AuthBloc()),
    BlocProvider(create: (context) => ThemeBloc()),
    BlocProvider(create: (context) => TodoBloc(
      repository: context.read<TodoRepository>(),  // 依赖注入
    )),
  ],
  child: MyApp(),
)

// 使用已存在的 Bloc（不会自动销毁）
BlocProvider.value(
  value: existingBloc,
  child: SomePage(),
)
```

### 访问 Bloc

```dart
// 方式 1：context.read（不监听变化）
// 适合在回调中使用
ElevatedButton(
  onPressed: () {
    context.read<CounterBloc>().add(IncrementPressed());
  },
  child: Text('增加'),
)

// 方式 2：context.watch（监听变化，触发重建）
// 适合在 build 中使用
Widget build(BuildContext context) {
  final state = context.watch<CounterBloc>().state;
  return Text('${state.count}');
}

// 方式 3：context.select（只监听部分状态）
Widget build(BuildContext context) {
  final count = context.select<CounterBloc, int>(
    (bloc) => bloc.state.count,
  );
  return Text('$count');
}

// 方式 4：BlocProvider.of（同 context.read）
final bloc = BlocProvider.of<CounterBloc>(context);
```

## BlocBuilder 详解

```dart
// 基本用法
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    return Text('${state.count}');
  },
)

// 条件重建（优化性能）
BlocBuilder<CounterBloc, CounterState>(
  buildWhen: (previous, current) {
    // 只在 count 变化时重建
    return previous.count != current.count;
  },
  builder: (context, state) {
    return Text('${state.count}');
  },
)

// 指定 Bloc 实例
BlocBuilder<CounterBloc, CounterState>(
  bloc: specificBlocInstance,  // 不使用 context 中的 Bloc
  builder: (context, state) {
    return Text('${state.count}');
  },
)
```

## BlocListener 详解

监听状态变化执行副作用（导航、弹窗等）：

```dart
// 基本用法
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: LoginForm(),
)

// 条件监听
BlocListener<TodoBloc, TodoState>(
  listenWhen: (previous, current) {
    return previous.status != current.status;
  },
  listener: (context, state) {
    if (state.status == TodoStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? '操作失败')),
      );
    }
  },
  child: TodoList(),
)

// 多个 Listener
MultiBlocListener(
  listeners: [
    BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // 处理认证状态
      },
    ),
    BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        // 处理通知
      },
    ),
  ],
  child: MyPage(),
)
```

## BlocConsumer 详解

同时需要 builder 和 listener：

```dart
BlocConsumer<AuthBloc, AuthState>(
  listenWhen: (previous, current) {
    // 监听条件
    return current is AuthFailure;
  },
  listener: (context, state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  buildWhen: (previous, current) {
    // 重建条件
    return true;
  },
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    return LoginForm();
  },
)
```

## 实战：完整的待办应用

```dart
// === 数据模型 ===
class Todo extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  
  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });
  
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
  
  @override
  List<Object?> get props => [id, title, isCompleted, createdAt];
}

// === Repository ===
class TodoRepository {
  final List<Todo> _todos = [];
  
  Future<List<Todo>> getTodos() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _todos;
  }
  
  Future<void> addTodo(Todo todo) async {
    await Future.delayed(Duration(milliseconds: 300));
    _todos.add(todo);
  }
  
  Future<void> updateTodo(Todo todo) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
    }
  }
  
  Future<void> deleteTodo(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    _todos.removeWhere((t) => t.id == id);
  }
}

// === Event ===
sealed class TodoEvent extends Equatable {
  const TodoEvent();
  
  @override
  List<Object?> get props => [];
}

class TodosLoadRequested extends TodoEvent {}

class TodoAdded extends TodoEvent {
  final String title;
  
  const TodoAdded(this.title);
  
  @override
  List<Object?> get props => [title];
}

class TodoToggled extends TodoEvent {
  final String id;
  
  const TodoToggled(this.id);
  
  @override
  List<Object?> get props => [id];
}

class TodoDeleted extends TodoEvent {
  final String id;
  
  const TodoDeleted(this.id);
  
  @override
  List<Object?> get props => [id];
}

class TodoFilterChanged extends TodoEvent {
  final TodoFilter filter;
  
  const TodoFilterChanged(this.filter);
  
  @override
  List<Object?> get props => [filter];
}

// === State ===
enum TodoStatus { initial, loading, success, failure }
enum TodoFilter { all, active, completed }

class TodoState extends Equatable {
  final TodoStatus status;
  final List<Todo> todos;
  final TodoFilter filter;
  final String? errorMessage;
  
  const TodoState({
    this.status = TodoStatus.initial,
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.errorMessage,
  });
  
  List<Todo> get filteredTodos {
    switch (filter) {
      case TodoFilter.active:
        return todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.isCompleted).toList();
      case TodoFilter.all:
        return todos;
    }
  }
  
  int get activeCount => todos.where((t) => !t.isCompleted).length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  
  TodoState copyWith({
    TodoStatus? status,
    List<Todo>? todos,
    TodoFilter? filter,
    String? errorMessage,
  }) {
    return TodoState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, todos, filter, errorMessage];
}

// === Bloc ===
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;
  
  TodoBloc({required TodoRepository repository})
      : _repository = repository,
        super(const TodoState()) {
    on<TodosLoadRequested>(_onLoadRequested);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
    on<TodoFilterChanged>(_onFilterChanged);
  }
  
  Future<void> _onLoadRequested(
    TodosLoadRequested event,
    Emitter<TodoState> emit,
  ) async {
    emit(state.copyWith(status: TodoStatus.loading));
    
    try {
      final todos = await _repository.getTodos();
      emit(state.copyWith(
        status: TodoStatus.success,
        todos: todos,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _onTodoAdded(
    TodoAdded event,
    Emitter<TodoState> emit,
  ) async {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      createdAt: DateTime.now(),
    );
    
    try {
      await _repository.addTodo(todo);
      emit(state.copyWith(
        todos: [...state.todos, todo],
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: '添加失败'));
    }
  }
  
  Future<void> _onTodoToggled(
    TodoToggled event,
    Emitter<TodoState> emit,
  ) async {
    final index = state.todos.indexWhere((t) => t.id == event.id);
    if (index == -1) return;
    
    final todo = state.todos[index];
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    
    try {
      await _repository.updateTodo(updatedTodo);
      
      final updatedTodos = [...state.todos];
      updatedTodos[index] = updatedTodo;
      
      emit(state.copyWith(todos: updatedTodos));
    } catch (e) {
      emit(state.copyWith(errorMessage: '更新失败'));
    }
  }
  
  Future<void> _onTodoDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _repository.deleteTodo(event.id);
      emit(state.copyWith(
        todos: state.todos.where((t) => t.id != event.id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: '删除失败'));
    }
  }
  
  void _onFilterChanged(
    TodoFilterChanged event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }
}

// === UI ===
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TodoRepository(),
      child: BlocProvider(
        create: (context) => TodoBloc(
          repository: context.read<TodoRepository>(),
        )..add(TodosLoadRequested()),
        child: MaterialApp(
          title: 'Bloc Todo',
          theme: ThemeData(useMaterial3: true),
          home: TodoPage(),
        ),
      ),
    );
  }
}

class TodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('待办事项'),
          actions: [
            BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                return Badge(
                  label: Text('${state.activeCount}'),
                  isLabelVisible: state.activeCount > 0,
                  child: Icon(Icons.notifications_outlined),
                );
              },
            ),
            SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            AddTodoInput(),
            FilterChips(),
            Expanded(child: TodoList()),
          ],
        ),
      ),
    );
  }
}

class AddTodoInput extends StatefulWidget {
  @override
  State<AddTodoInput> createState() => _AddTodoInputState();
}

class _AddTodoInputState extends State<AddTodoInput> {
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      context.read<TodoBloc>().add(TodoAdded(title));
      _controller.clear();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: '添加新任务...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: _submit,
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (previous, current) => previous.filter != current.filter,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(context, '全部', TodoFilter.all, state.filter),
              SizedBox(width: 8),
              _buildChip(context, '待完成', TodoFilter.active, state.filter),
              SizedBox(width: 8),
              _buildChip(context, '已完成', TodoFilter.completed, state.filter),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildChip(
    BuildContext context,
    String label,
    TodoFilter filter,
    TodoFilter currentFilter,
  ) {
    return FilterChip(
      label: Text(label),
      selected: currentFilter == filter,
      onSelected: (_) {
        context.read<TodoBloc>().add(TodoFilterChanged(filter));
      },
    );
  }
}

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state.status == TodoStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (state.status == TodoStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('加载失败'),
                ElevatedButton(
                  onPressed: () {
                    context.read<TodoBloc>().add(TodosLoadRequested());
                  },
                  child: Text('重试'),
                ),
              ],
            ),
          );
        }
        
        final todos = state.filteredTodos;
        
        if (todos.isEmpty) {
          return Center(
            child: Text(
              state.filter == TodoFilter.all
                  ? '暂无待办事项'
                  : '没有${state.filter == TodoFilter.active ? '待完成' : '已完成'}的任务',
            ),
          );
        }
        
        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            return TodoItem(todo: todos[index]);
          },
        );
      },
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  
  const TodoItem({required this.todo});
  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TodoBloc>().add(TodoDeleted(todo.id));
      },
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) {
            context.read<TodoBloc>().add(TodoToggled(todo.id));
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          _formatDate(todo.createdAt),
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
```

## 测试

Bloc 的一大优势是易于测试：

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  group('TodoBloc', () {
    late TodoRepository repository;
    late TodoBloc bloc;
    
    setUp(() {
      repository = MockTodoRepository();
      bloc = TodoBloc(repository: repository);
    });
    
    tearDown(() {
      bloc.close();
    });
    
    test('初始状态正确', () {
      expect(bloc.state.status, TodoStatus.initial);
      expect(bloc.state.todos, isEmpty);
    });
    
    blocTest<TodoBloc, TodoState>(
      '加载待办列表成功',
      build: () {
        when(() => repository.getTodos()).thenAnswer(
          (_) async => [
            Todo(id: '1', title: '任务1', createdAt: DateTime.now()),
          ],
        );
        return bloc;
      },
      act: (bloc) => bloc.add(TodosLoadRequested()),
      expect: () => [
        isA<TodoState>().having((s) => s.status, 'status', TodoStatus.loading),
        isA<TodoState>()
            .having((s) => s.status, 'status', TodoStatus.success)
            .having((s) => s.todos.length, 'todos length', 1),
      ],
    );
    
    blocTest<TodoBloc, TodoState>(
      '添加待办成功',
      build: () {
        when(() => repository.addTodo(any())).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => TodoState(status: TodoStatus.success),
      act: (bloc) => bloc.add(TodoAdded('新任务')),
      expect: () => [
        isA<TodoState>().having(
          (s) => s.todos.any((t) => t.title == '新任务'),
          'contains new todo',
          true,
        ),
      ],
    );
    
    blocTest<TodoBloc, TodoState>(
      '切换待办状态',
      build: () {
        when(() => repository.updateTodo(any())).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => TodoState(
        status: TodoStatus.success,
        todos: [
          Todo(id: '1', title: '任务1', createdAt: DateTime.now()),
        ],
      ),
      act: (bloc) => bloc.add(TodoToggled('1')),
      expect: () => [
        isA<TodoState>().having(
          (s) => s.todos.first.isCompleted,
          'isCompleted',
          true,
        ),
      ],
    );
  });
}
```

## BlocObserver

全局监听所有 Bloc 的事件和状态变化：

```dart
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate: ${bloc.runtimeType}');
  }
  
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent: ${bloc.runtimeType}, $event');
  }
  
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange: ${bloc.runtimeType}');
    print('  currentState: ${change.currentState}');
    print('  nextState: ${change.nextState}');
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('onError: ${bloc.runtimeType}, $error');
  }
  
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose: ${bloc.runtimeType}');
  }
}

// 使用
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(MyApp());
}
```

## 最佳实践

### 1. 项目结构

```
lib/
├── app/
│   ├── app.dart
│   └── bloc_observer.dart
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── models/
│   │   │   └── user.dart
│   │   ├── repository/
│   │   │   └── auth_repository.dart
│   │   └── view/
│   │       ├── login_page.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   └── todo/
│       ├── bloc/
│       ├── models/
│       ├── repository/
│       └── view/
└── main.dart
```

### 2. 状态不可变

```dart
// ✅ 正确：创建新状态
emit(state.copyWith(count: state.count + 1));

// ❌ 错误：修改现有状态
state.count++;  // 这不会触发 UI 更新
emit(state);
```

### 3. 单一职责

```dart
// ✅ 每个 Bloc 只负责一个功能模块
class AuthBloc extends Bloc<AuthEvent, AuthState> { ... }
class TodoBloc extends Bloc<TodoEvent, TodoState> { ... }
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> { ... }

// ❌ 不要创建 "上帝 Bloc"
class AppBloc extends Bloc<AppEvent, AppState> {
  // 处理认证、待办、设置... 太多职责
}
```

### 4. 合理使用 buildWhen 和 listenWhen

```dart
BlocBuilder<TodoBloc, TodoState>(
  // 只在过滤器变化时重建
  buildWhen: (previous, current) => previous.filter != current.filter,
  builder: (context, state) => FilterChips(filter: state.filter),
)

BlocListener<TodoBloc, TodoState>(
  // 只监听错误
  listenWhen: (previous, current) => current.errorMessage != null,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.errorMessage!)),
    );
  },
  child: ...,
)
```

## 下一步

Bloc 是一个强大且规范的状态管理方案。下一章我们将进行 [方案对比与选择](./06-comparison)，帮助你根据项目需求选择最合适的状态管理方案。
