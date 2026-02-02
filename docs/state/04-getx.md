# GetX 详解

GetX 是一个轻量级且功能强大的 Flutter 解决方案。它不仅提供状态管理，还包括路由管理、依赖注入、国际化等功能，号称是 "Flutter 的瑞士军刀"。

## 为什么选择 GetX？

### GetX 的特点

| 特点 | 说明 |
|-----|------|
| 语法简洁 | 最少的代码实现功能 |
| 无 context | 大多数操作不需要 context |
| 功能全面 | 状态、路由、依赖注入一体化 |
| 性能优秀 | 只重建需要更新的 Widget |

### 代码对比

```dart
// 原生 Flutter 方式
class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => count++),
        child: Icon(Icons.add),
      ),
    );
  }
}

// GetX 方式
class CounterController extends GetxController {
  var count = 0.obs;
  void increment() => count++;
}

class CounterPage extends StatelessWidget {
  final controller = Get.put(CounterController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Obx(() => Text('${controller.count}'))),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 安装配置

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
```

### 基础设置

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(
    GetMaterialApp(  // 替换 MaterialApp
      title: 'GetX App',
      home: HomePage(),
    ),
  );
}
```

## 三种状态管理方式

GetX 提供三种状态管理方式，适用于不同场景：

### 1. 响应式状态管理（.obs）

最简单的方式，使用 `.obs` 创建响应式变量：

```dart
// 基本类型
var count = 0.obs;
var name = 'John'.obs;
var isActive = false.obs;
var price = 9.99.obs;

// 列表
var items = <String>[].obs;
var products = <Product>[].obs;

// Map
var userData = <String, dynamic>{}.obs;

// 自定义对象
var user = User(name: 'John', age: 25).obs;
```

#### Obs 的使用方式

```dart
class CounterController extends GetxController {
  var count = 0.obs;
  
  // 修改值
  void increment() {
    count++;  // 直接使用 ++
    // 或
    count.value++;  // 使用 .value
    // 或
    count(count.value + 1);  // 使用函数调用语法
  }
}

// 在 UI 中使用
class CounterPage extends StatelessWidget {
  final CounterController c = Get.put(CounterController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 方式 1：Obx（最常用）
        child: Obx(() => Text('${c.count}')),
        
        // 方式 2：GetX widget
        // child: GetX<CounterController>(
        //   builder: (controller) => Text('${controller.count}'),
        // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: c.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### 列表操作

```dart
class TodoController extends GetxController {
  var todos = <Todo>[].obs;
  
  void addTodo(Todo todo) {
    todos.add(todo);  // 自动触发更新
  }
  
  void removeTodo(int index) {
    todos.removeAt(index);
  }
  
  void updateTodo(int index, Todo newTodo) {
    todos[index] = newTodo;
  }
  
  void clearCompleted() {
    todos.removeWhere((todo) => todo.isCompleted);
  }
  
  // 批量操作（性能更好）
  void loadTodos(List<Todo> newTodos) {
    todos.assignAll(newTodos);  // 替换整个列表，只触发一次更新
  }
}
```

#### 对象更新

```dart
class UserController extends GetxController {
  var user = User(name: 'John', age: 25).obs;
  
  // 方式 1：替换整个对象
  void updateName(String newName) {
    user.value = user.value.copyWith(name: newName);
  }
  
  // 方式 2：使用 update 方法
  void incrementAge() {
    user.update((val) {
      val?.age++;
    });
  }
  
  // 方式 3：直接修改（需要手动刷新）
  void updateEmail(String email) {
    user.value.email = email;
    user.refresh();  // 手动触发更新
  }
}
```

### 2. 简单状态管理（GetBuilder）

不使用响应式变量，手动触发更新，内存占用更小：

```dart
class SimpleCounterController extends GetxController {
  int count = 0;  // 普通变量
  
  void increment() {
    count++;
    update();  // 手动触发更新
  }
  
  void decrement() {
    count--;
    update();
  }
}

// 使用 GetBuilder
class SimplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleCounterController>(
      init: SimpleCounterController(),  // 初始化 Controller
      builder: (controller) {
        return Text('${controller.count}');
      },
    );
  }
}
```

#### 精确更新（使用 id）

```dart
class FormController extends GetxController {
  String username = '';
  String email = '';
  String password = '';
  
  void updateUsername(String value) {
    username = value;
    update(['username']);  // 只更新 id 为 'username' 的 GetBuilder
  }
  
  void updateEmail(String value) {
    email = value;
    update(['email']);
  }
  
  void updatePassword(String value) {
    password = value;
    update(['password']);
  }
}

// UI
class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 只在 username 变化时重建
        GetBuilder<FormController>(
          id: 'username',
          builder: (c) => TextField(
            onChanged: c.updateUsername,
            decoration: InputDecoration(labelText: c.username),
          ),
        ),
        
        // 只在 email 变化时重建
        GetBuilder<FormController>(
          id: 'email',
          builder: (c) => TextField(
            onChanged: c.updateEmail,
            decoration: InputDecoration(labelText: c.email),
          ),
        ),
        
        // 只在 password 变化时重建
        GetBuilder<FormController>(
          id: 'password',
          builder: (c) => TextField(
            onChanged: c.updatePassword,
            obscureText: true,
          ),
        ),
      ],
    );
  }
}
```

### 3. 混合使用

可以在同一个 Controller 中混合使用：

```dart
class HybridController extends GetxController {
  // 响应式（频繁变化的数据）
  var searchQuery = ''.obs;
  var isLoading = false.obs;
  
  // 非响应式（不常变化的数据）
  List<User> users = [];
  User? selectedUser;
  
  Future<void> searchUsers(String query) async {
    searchQuery.value = query;
    isLoading.value = true;
    
    users = await api.searchUsers(query);
    isLoading.value = false;
    
    update(['userList']);  // 手动更新用户列表
  }
  
  void selectUser(User user) {
    selectedUser = user;
    update(['selectedUser']);
  }
}
```

## GetxController 生命周期

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // 初始化逻辑
    // 类似于 initState
    print('Controller 已创建');
    fetchInitialData();
  }
  
  @override
  void onReady() {
    super.onReady();
    // Widget 渲染完成后调用
    // 适合执行动画、请求焦点等
    print('Widget 已渲染');
  }
  
  @override
  void onClose() {
    // 清理逻辑
    // 类似于 dispose
    print('Controller 已销毁');
    subscription?.cancel();
    timer?.cancel();
    super.onClose();
  }
}
```

## 依赖注入

### Get.put

立即创建并注入：

```dart
// 基本用法
final controller = Get.put(MyController());

// 带参数
Get.put(
  MyController(),
  permanent: true,   // 不会被销毁
  tag: 'unique_tag', // 用于区分同类型的多个实例
);

// 在 Widget 中使用
class MyPage extends StatelessWidget {
  final controller = Get.put(MyController());
  
  @override
  Widget build(BuildContext context) {
    return ...;
  }
}
```

### Get.lazyPut

延迟创建，首次使用时才实例化：

```dart
void main() {
  // 注册（不会立即创建）
  Get.lazyPut<ApiService>(() => ApiService());
  Get.lazyPut<AuthController>(() => AuthController());
  
  runApp(MyApp());
}

// 使用时才创建
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();  // 此时才创建
    return ...;
  }
}
```

### Get.putAsync

异步创建：

```dart
void main() async {
  await Get.putAsync<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );
  
  runApp(MyApp());
}
```

### Get.find

获取已注入的实例：

```dart
// 获取 Controller
final controller = Get.find<MyController>();

// 带 tag
final specificController = Get.find<MyController>(tag: 'specific');
```

### Bindings（推荐方式）

统一管理页面的依赖：

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<UserService>(() => UserService());
    Get.lazyPut<ProductRepository>(() => ProductRepository());
  }
}

// 使用
GetMaterialApp(
  initialBinding: HomeBinding(),  // 全局 Binding
  getPages: [
    GetPage(
      name: '/home',
      page: () => HomePage(),
      binding: HomeBinding(),  // 页面级 Binding
    ),
    GetPage(
      name: '/profile',
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
  ],
);
```

## 路由管理

GetX 提供强大的路由管理，无需 context：

### 基本导航

```dart
// 跳转到新页面
Get.to(HomePage());

// 跳转并移除当前页（替换）
Get.off(LoginPage());

// 跳转并清空所有路由栈
Get.offAll(HomePage());

// 返回
Get.back();

// 返回并传递数据
Get.back(result: 'some data');

// 接收返回数据
var result = await Get.to(SelectPage());
print(result);  // 'some data'
```

### 命名路由

```dart
// 配置
GetMaterialApp(
  initialRoute: '/home',
  getPages: [
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/user/:id', page: () => UserPage()),  // 动态参数
    GetPage(
      name: '/admin',
      page: () => AdminPage(),
      middlewares: [AuthMiddleware()],  // 中间件
    ),
  ],
);

// 使用
Get.toNamed('/home');
Get.offNamed('/login');
Get.offAllNamed('/home');

// 带参数
Get.toNamed('/user/123');
Get.toNamed('/product', arguments: product);
Get.toNamed('/search?keyword=flutter&page=1');

// 获取参数
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Get.parameters['id'];  // 路径参数
    final product = Get.arguments as Product;  // arguments
    final keyword = Get.parameters['keyword'];  // 查询参数
    
    return ...;
  }
}
```

### 页面过渡动画

```dart
GetPage(
  name: '/home',
  page: () => HomePage(),
  transition: Transition.fade,  // 淡入淡出
  transitionDuration: Duration(milliseconds: 300),
);

// 可用的过渡效果
// Transition.fade
// Transition.rightToLeft
// Transition.leftToRight
// Transition.upToDown
// Transition.downToUp
// Transition.scale
// Transition.rotate
// Transition.size
// Transition.cupertino  // iOS 风格
```

## Workers（响应式监听）

监听响应式变量的变化：

```dart
class MyController extends GetxController {
  var count = 0.obs;
  var name = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // ever: 每次变化都执行
    ever(count, (value) {
      print('count 变化: $value');
    });
    
    // once: 只执行一次
    once(count, (value) {
      print('count 第一次变化: $value');
    });
    
    // debounce: 防抖（停止变化后执行）
    debounce(name, (value) {
      print('搜索: $value');
      searchApi(value);
    }, time: Duration(milliseconds: 500));
    
    // interval: 节流（固定间隔执行）
    interval(count, (value) {
      print('节流输出: $value');
    }, time: Duration(seconds: 1));
    
    // everAll: 监听多个变量
    everAll([count, name], (values) {
      print('某个值变化了');
    });
  }
}
```

## 工具类

### Snackbar

```dart
Get.snackbar(
  '标题',
  '消息内容',
  snackPosition: SnackPosition.BOTTOM,
  duration: Duration(seconds: 3),
  backgroundColor: Colors.black87,
  colorText: Colors.white,
  icon: Icon(Icons.info, color: Colors.white),
  mainButton: TextButton(
    onPressed: () => Get.back(),
    child: Text('关闭'),
  ),
);
```

### Dialog

```dart
Get.dialog(
  AlertDialog(
    title: Text('确认'),
    content: Text('确定要删除吗？'),
    actions: [
      TextButton(
        onPressed: () => Get.back(),
        child: Text('取消'),
      ),
      TextButton(
        onPressed: () {
          // 删除操作
          Get.back();
        },
        child: Text('确定'),
      ),
    ],
  ),
);

// 简单确认对话框
Get.defaultDialog(
  title: '提示',
  middleText: '操作成功！',
  textConfirm: '确定',
  onConfirm: () => Get.back(),
);
```

### BottomSheet

```dart
Get.bottomSheet(
  Container(
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.camera),
          title: Text('拍照'),
          onTap: () {
            Get.back();
            takePhoto();
          },
        ),
        ListTile(
          leading: Icon(Icons.image),
          title: Text('从相册选择'),
          onTap: () {
            Get.back();
            pickFromGallery();
          },
        ),
      ],
    ),
  ),
);
```

## 实战：完整的待办事项应用

```dart
// === 数据模型 ===
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
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// === 存储服务 ===
class StorageService extends GetxService {
  late SharedPreferences _prefs;
  
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  List<Todo> getTodos() {
    final jsonString = _prefs.getString('todos');
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }
  
  Future<void> saveTodos(List<Todo> todos) async {
    final jsonString = json.encode(todos.map((t) => t.toJson()).toList());
    await _prefs.setString('todos', jsonString);
  }
}

// === Controller ===
class TodoController extends GetxController {
  final storage = Get.find<StorageService>();
  
  var todos = <Todo>[].obs;
  var filter = 'all'.obs;  // all, active, completed
  
  // 计算属性
  List<Todo> get filteredTodos {
    switch (filter.value) {
      case 'active':
        return todos.where((t) => !t.isCompleted).toList();
      case 'completed':
        return todos.where((t) => t.isCompleted).toList();
      default:
        return todos;
    }
  }
  
  int get activeCount => todos.where((t) => !t.isCompleted).length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  
  @override
  void onInit() {
    super.onInit();
    loadTodos();
    
    // 自动保存
    ever(todos, (_) => storage.saveTodos(todos));
  }
  
  void loadTodos() {
    todos.assignAll(storage.getTodos());
  }
  
  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    
    todos.add(todo);
    
    Get.snackbar(
      '成功',
      '已添加: ${todo.title}',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
  
  void toggleTodo(String id) {
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      todos[index].isCompleted = !todos[index].isCompleted;
      todos.refresh();  // 刷新列表
    }
  }
  
  void updateTodoTitle(String id, String newTitle) {
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      todos[index].title = newTitle;
      todos.refresh();
    }
  }
  
  void deleteTodo(String id) {
    final todo = todos.firstWhereOrNull((t) => t.id == id);
    if (todo != null) {
      todos.remove(todo);
      
      Get.snackbar(
        '已删除',
        todo.title,
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () {
            todos.add(todo);  // 撤销
            Get.back();
          },
          child: Text('撤销', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }
  
  void clearCompleted() {
    Get.defaultDialog(
      title: '确认',
      middleText: '确定清除所有已完成的任务？',
      textCancel: '取消',
      textConfirm: '确定',
      onConfirm: () {
        todos.removeWhere((t) => t.isCompleted);
        Get.back();
      },
    );
  }
  
  void setFilter(String value) {
    filter.value = value;
  }
}

// === Binding ===
class TodoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodoController>(() => TodoController());
  }
}

// === 初始化 ===
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await Get.putAsync(() => StorageService().init());
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialBinding: TodoBinding(),
      home: TodoPage(),
    );
  }
}

// === UI ===
class TodoPage extends GetView<TodoController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('待办事项'),
        actions: [
          Obx(() => controller.completedCount > 0
            ? IconButton(
                icon: Icon(Icons.delete_sweep),
                onPressed: controller.clearCompleted,
                tooltip: '清除已完成',
              )
            : SizedBox.shrink()
          ),
        ],
      ),
      body: Column(
        children: [
          // 输入框
          Padding(
            padding: EdgeInsets.all(16),
            child: AddTodoInput(),
          ),
          
          // 过滤器
          FilterChips(),
          
          // 统计信息
          Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${controller.activeCount} 项待完成'),
                Spacer(),
                Text('共 ${controller.todos.length} 项'),
              ],
            ),
          )),
          
          // 列表
          Expanded(
            child: Obx(() {
              final filteredTodos = controller.filteredTodos;
              
              if (filteredTodos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        controller.filter.value == 'all'
                          ? '暂无待办事项'
                          : '没有${controller.filter.value == 'active' ? '待完成' : '已完成'}的任务',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: filteredTodos.length,
                itemBuilder: (context, index) {
                  return TodoItem(todo: filteredTodos[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class AddTodoInput extends GetView<TodoController> {
  final textController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        hintText: '添加新任务...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            controller.addTodo(textController.text);
            textController.clear();
          },
        ),
      ),
      onSubmitted: (value) {
        controller.addTodo(value);
        textController.clear();
      },
    );
  }
}

class FilterChips extends GetView<TodoController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilterChip(
          label: Text('全部'),
          selected: controller.filter.value == 'all',
          onSelected: (_) => controller.setFilter('all'),
        ),
        SizedBox(width: 8),
        FilterChip(
          label: Text('待完成'),
          selected: controller.filter.value == 'active',
          onSelected: (_) => controller.setFilter('active'),
        ),
        SizedBox(width: 8),
        FilterChip(
          label: Text('已完成'),
          selected: controller.filter.value == 'completed',
          onSelected: (_) => controller.setFilter('completed'),
        ),
      ],
    ));
  }
}

class TodoItem extends GetView<TodoController> {
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
      onDismissed: (_) => controller.deleteTodo(todo.id),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => controller.toggleTodo(todo.id),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted
              ? TextDecoration.lineThrough
              : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          _formatDate(todo.createdAt),
          style: TextStyle(fontSize: 12),
        ),
        onTap: () => _showEditDialog(context),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: todo.title);
    
    Get.dialog(
      AlertDialog(
        title: Text('编辑任务'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '任务内容',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.updateTodoTitle(todo.id, textController.text);
              Get.back();
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }
}
```

## GetView 和 GetWidget

### GetView

简化了 `Get.find()` 的使用：

```dart
// 不使用 GetView
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyController>();
    return Text(controller.data);
  }
}

// 使用 GetView
class MyPage extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return Text(controller.data);  // controller 自动可用
  }
}
```

### GetWidget

类似 GetView，但 Controller 不会被自动销毁：

```dart
class MyWidget extends GetWidget<MyController> {
  @override
  Widget build(BuildContext context) {
    return Text(controller.data);
  }
}
```

## 最佳实践

### 1. 项目结构

```
lib/
├── app/
│   ├── data/
│   │   ├── models/
│   │   ├── providers/
│   │   └── services/
│   ├── modules/
│   │   ├── home/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   └── profile/
│   │       ├── bindings/
│   │       ├── controllers/
│   │       └── views/
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── core/
│       └── utils/
└── main.dart
```

### 2. 使用 Bindings

```dart
// app_pages.dart
class AppPages {
  static final pages = [
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfilePage(),
      binding: ProfileBinding(),
    ),
  ];
}
```

### 3. 服务层分离

```dart
// 服务
class AuthService extends GetxService {
  // ...
}

// Repository
class UserRepository {
  final api = Get.find<ApiService>();
  // ...
}

// Controller
class UserController extends GetxController {
  final repo = Get.find<UserRepository>();
  // ...
}
```

## GetX 的争议

GetX 虽然功能强大，但也有一些争议：

| 优点 | 缺点 |
|------|------|
| 语法简洁 | 过度封装 |
| 学习成本低 | 不符合 Flutter 设计理念 |
| 功能全面 | 难以追踪状态变化 |
| 开发效率高 | 测试相对困难 |

**适用场景：**
- 小到中型项目
- 快速原型开发
- 个人项目
- 对开发效率要求高的场景

**不建议使用：**
- 大型团队项目
- 对代码质量要求高的项目
- 需要严格测试的项目

## 下一步

GetX 是一个追求简洁的全功能方案。下一章我们将学习 [Bloc 详解](./05-bloc)，一个更加规范和可预测的状态管理方案。
