# setState 详解

`setState` 是 Flutter 中最基础的状态管理方式，也是理解其他状态管理方案的前提。本章将深入剖析 setState 的工作原理和最佳实践。

## 基本用法

### 最简示例

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

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
    print('build 被调用');  // 每次 setState 都会打印
    return Scaffold(
      appBar: AppBar(title: Text('计数器')),
      body: Center(
        child: Text(
          '$_count',
          style: TextStyle(fontSize: 48),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### setState 的签名

```dart
void setState(VoidCallback fn);
```

`setState` 接受一个无参无返回值的函数。这个函数内部应该包含状态变更的逻辑。

## 深入理解 setState

### setState 到底做了什么？

当你调用 `setState` 时，Flutter 内部执行了以下步骤：

```dart
// 伪代码展示 setState 的内部实现
void setState(VoidCallback fn) {
  // 1. 检查 State 是否还在树中
  assert(_debugLifecycleState != _StateLifecycle.defunct);
  
  // 2. 执行你传入的函数（修改状态）
  fn();
  
  // 3. 标记这个 Element 为"脏"（需要重建）
  _element!.markNeedsBuild();
}
```

关键点：
1. **fn() 在 markNeedsBuild() 之前执行** - 状态先改变，再标记需要重建
2. **markNeedsBuild() 不会立即触发重建** - 它只是标记，实际重建在下一帧
3. **同一帧内多次 setState 只会导致一次重建**

### 验证：多次 setState 只重建一次

```dart
class MultiSetStateDemo extends StatefulWidget {
  @override
  State<MultiSetStateDemo> createState() => _MultiSetStateDemoState();
}

class _MultiSetStateDemoState extends State<MultiSetStateDemo> {
  int _a = 0;
  int _b = 0;
  int _c = 0;
  int _buildCount = 0;

  void _updateAll() {
    // 同一个方法中调用三次 setState
    setState(() => _a++);
    setState(() => _b++);
    setState(() => _c++);
    // 结果：只会触发一次 build！
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('a=$_a, b=$_b, c=$_c'),
        Text('build 次数: $_buildCount'),
        ElevatedButton(
          onPressed: _updateAll,
          child: Text('更新全部'),
        ),
      ],
    );
  }
}
```

运行这段代码，点击按钮后你会发现：
- a、b、c 都增加了 1
- 但 build 只被调用了 1 次

**原理**：Flutter 使用调度器（Scheduler）在每一帧统一处理所有标记为"脏"的 Widget，避免重复重建。

### setState 的执行时机

```dart
void _updateState() {
  print('1. setState 之前');
  
  setState(() {
    print('2. setState 回调内部');
    _count++;
  });
  
  print('3. setState 之后');
  print('4. 此时 _count = $_count');  // 已经是新值了！
}

// 输出顺序：
// 1. setState 之前
// 2. setState 回调内部
// 3. setState 之后
// 4. 此时 _count = 1
// （然后在下一帧）
// build 方法被调用
```

**关键理解**：
- setState 回调是 **同步执行** 的
- 状态变更 **立即生效**
- 但 UI 更新是 **异步的**（下一帧）

## setState 的正确姿势

### ✅ 正确：在回调内修改状态

```dart
void _increment() {
  setState(() {
    _count++;
  });
}
```

### ✅ 也正确：先修改后调用

```dart
void _increment() {
  _count++;
  setState(() {});
}
```

虽然这种写法也能工作，但不推荐，因为：
1. 代码意图不清晰
2. 如果忘记调用 setState，UI 不会更新
3. 不符合约定俗成的模式

### ❌ 错误：异步修改状态

```dart
void _loadData() {
  setState(() async {  // ❌ 不要这样做！
    _data = await fetchData();
  });
}
```

这是一个常见错误！`setState` 的回调必须是同步的。

### ✅ 正确的异步处理

```dart
void _loadData() async {
  // 1. 设置加载状态
  setState(() {
    _isLoading = true;
  });
  
  // 2. 执行异步操作
  try {
    final data = await fetchData();
    
    // 3. 检查 Widget 是否还在树中
    if (!mounted) return;
    
    // 4. 更新数据
    setState(() {
      _data = data;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}
```

**关键**：异步操作完成后，一定要检查 `mounted`！

### 为什么要检查 mounted？

```dart
class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await api.fetchUser();  // 假设需要 3 秒
    
    // ❌ 危险！如果用户在 3 秒内返回上一页，Widget 已被销毁
    // 此时调用 setState 会抛出异常
    setState(() {
      _user = user;
    });
  }

  // ...
}
```

正确做法：

```dart
Future<void> _loadUser() async {
  final user = await api.fetchUser();
  
  // ✅ 检查 Widget 是否还在 Widget 树中
  if (!mounted) return;
  
  setState(() {
    _user = user;
  });
}
```

## setState 的性能陷阱

### 陷阱 1：不必要的重建

```dart
class BadExample extends StatefulWidget {
  @override
  State<BadExample> createState() => _BadExampleState();
}

class _BadExampleState extends State<BadExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 这个 Text 需要因为 _count 变化而更新
        Text('Count: $_count'),
        
        // ❌ 这些 Widget 完全不依赖 _count，但每次也会重建！
        const SizedBox(height: 20),
        Image.network('https://example.com/large-image.jpg'),
        ListView.builder(
          shrinkWrap: true,
          itemCount: 100,
          itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
        ),
        
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: Text('增加'),
        ),
      ],
    );
  }
}
```

### 优化 1：使用 const

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Count: $_count'),
      
      // ✅ const Widget 不会重建
      const SizedBox(height: 20),
      const MyExpensiveWidget(),
      
      ElevatedButton(
        onPressed: () => setState(() => _count++),
        child: const Text('增加'),  // ✅ 按钮文字也可以是 const
      ),
    ],
  );
}
```

### 优化 2：拆分 Widget

```dart
// 把频繁变化的部分提取成独立 Widget
class CounterDisplay extends StatefulWidget {
  @override
  State<CounterDisplay> createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    // 现在只有这个小 Widget 会重建
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: Text('增加'),
        ),
      ],
    );
  }
}

// 父 Widget 保持稳定
class OptimizedExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CounterDisplay(),  // 状态变化只影响这个
        const SizedBox(height: 20),
        const MyExpensiveWidget(),  // 不受影响
        const MyListWidget(),       // 不受影响
      ],
    );
  }
}
```

### 陷阱 2：build 中创建对象

```dart
class BadBuild extends StatefulWidget {
  @override
  State<BadBuild> createState() => _BadBuildState();
}

class _BadBuildState extends State<BadBuild> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    // ❌ 每次 build 都会创建新的 TextStyle 对象
    final style = TextStyle(fontSize: 24, color: Colors.blue);
    
    // ❌ 每次 build 都会创建新的 List
    final items = List.generate(100, (i) => 'Item $i');
    
    // ❌ 每次 build 都会创建新的回调
    final onPressed = () {
      print('clicked');
    };
    
    return Column(
      children: [
        Text('$_count', style: style),
        // ...
      ],
    );
  }
}
```

### 优化：移到 build 外部

```dart
class GoodBuild extends StatefulWidget {
  @override
  State<GoodBuild> createState() => _GoodBuildState();
}

class _GoodBuildState extends State<GoodBuild> {
  int _count = 0;
  
  // ✅ 静态或实例级别的常量
  static const _style = TextStyle(fontSize: 24, color: Colors.blue);
  
  // ✅ 懒加载，只创建一次
  late final _items = List.generate(100, (i) => 'Item $i');
  
  // ✅ 方法引用，不会每次创建新对象
  void _handlePressed() {
    print('clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count', style: _style),
        ElevatedButton(
          onPressed: _handlePressed,  // ✅ 方法引用
          child: Text('Click'),
        ),
      ],
    );
  }
}
```

## 完整示例：Todo List

让我们用 setState 实现一个完整的 Todo List：

```dart
// 数据模型
class Todo {
  final String id;
  String title;
  bool isCompleted;
  
  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

// Todo List 页面
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Todo> _todos = [];
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _todos.add(Todo(
        id: DateTime.now().toString(),
        title: text,
      ));
    });
    
    _textController.clear();
  }

  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((t) => t.id == id);
      todo.isCompleted = !todo.isCompleted;
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
  }

  void _editTodo(String id, String newTitle) {
    setState(() {
      final todo = _todos.firstWhere((t) => t.id == id);
      todo.title = newTitle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todos.where((t) => t.isCompleted).length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text('${completedCount}/${_todos.length}'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 输入区域
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '添加新任务...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          
          // 列表区域
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: Text(
                      '暂无任务\n点击 + 添加',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return TodoItem(
                        todo: todo,
                        onToggle: () => _toggleTodo(todo.id),
                        onDelete: () => _deleteTodo(todo.id),
                        onEdit: (newTitle) => _editTodo(todo.id, newTitle),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Todo 项组件（StatelessWidget，状态由父组件管理）
class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;

  const TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

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
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _showEditDialog(context),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: todo.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑任务'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              onEdit(controller.text);
              Navigator.pop(context);
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }
}
```

## setState 的局限性

通过上面的 Todo List 示例，我们可以看到 setState 的一些局限：

### 1. 状态和 UI 耦合

```dart
class _TodoListPageState extends State<TodoListPage> {
  final List<Todo> _todos = [];  // 状态在 State 类中
  
  // 业务逻辑也在 State 类中
  void _addTodo() { ... }
  void _toggleTodo() { ... }
  void _deleteTodo() { ... }
  
  // UI 也在 State 类中
  @override
  Widget build(BuildContext context) { ... }
}
```

问题：
- 难以复用业务逻辑
- 难以单独测试业务逻辑
- 文件会越来越大

### 2. 状态难以共享

```dart
// 如果另一个页面也需要访问 todos？
class OtherPage extends StatelessWidget {
  // 怎么获取 _TodoListPageState 中的 _todos？
  // 只能通过：
  // 1. 构造函数传递（麻烦）
  // 2. 全局变量（危险）
  // 3. 用其他状态管理方案
}
```

### 3. 状态难以持久化

```dart
// 用户关闭 App 后重新打开，todos 就丢失了
// 需要：
// 1. 在适当时机保存到本地存储
// 2. 在 initState 中读取
// 状态管理方案通常会提供更优雅的解决方式
```

## 何时使用 setState？

**适合用 setState 的场景：**
- 简单的 UI 交互（展开/折叠、切换 Tab）
- 表单输入状态
- 动画状态
- 只在单个页面使用的临时数据
- 学习 Flutter 的初期

**不适合用 setState 的场景：**
- 多个页面共享的数据
- 需要复杂业务逻辑的场景
- 需要单独测试业务逻辑
- 团队协作的大型项目

## 总结

| 要点 | 说明 |
|-----|------|
| 同步执行 | setState 的回调是同步执行的 |
| 异步更新 | UI 更新是在下一帧 |
| 批量合并 | 同一帧内多次 setState 只触发一次 build |
| 检查 mounted | 异步操作后必须检查 mounted |
| 使用 const | const Widget 不会重建 |
| 拆分 Widget | 把频繁变化的部分独立出去 |

## 下一步

当 setState 无法满足需求时，我们需要更强大的状态管理方案。下一章将学习 [Provider 详解](./02-provider)，这是 Flutter 官方推荐的入门级状态管理方案。
