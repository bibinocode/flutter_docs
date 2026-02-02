# Hive 数据库

Hive 是一个轻量级、高性能的 NoSQL 键值数据库，纯 Dart 编写，无需原生依赖。适合存储应用数据、用户配置、缓存等。

## 特性

- 🚀 **跨平台** - 支持移动端、桌面、Web
- ⚡ **高性能** - 比 SharedPreferences 和 SQLite 更快
- ❤️ **简单易用** - 类似 Map 的 API
- 🔒 **内置加密** - 支持 AES-256 加密
- 🎈 **无原生依赖** - 纯 Dart 实现

## 安装

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

```bash
flutter pub add hive hive_flutter
flutter pub add --dev hive_generator build_runner
```

## 基本概念

- **Box** - 数据容器，类似于 SQL 中的表
- **HiveObject** - 可存储的对象基类
- **TypeAdapter** - 自定义类型序列化适配器

---

## 快速开始

### 初始化

```dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // 初始化 Hive（Flutter 项目）
  await Hive.initFlutter();
  
  // 打开一个 Box
  await Hive.openBox('settings');
  
  runApp(MyApp());
}
```

### 基本操作

```dart
// 获取已打开的 Box
var box = Hive.box('settings');

// 写入数据
box.put('username', 'Flutter');
box.put('darkMode', true);
box.put('fontSize', 16.0);

// 读取数据
String? username = box.get('username');
bool darkMode = box.get('darkMode', defaultValue: false);
double fontSize = box.get('fontSize', defaultValue: 14.0);

// 删除数据
box.delete('username');

// 清空 Box
box.clear();

// 关闭 Box
box.close();

// 关闭所有 Box
Hive.close();
```

### 支持的数据类型

Hive 原生支持以下类型：

- `bool`
- `int`
- `double`
- `String`
- `List`
- `Map`
- `DateTime`
- `BigInt`
- `Uint8List`

---

## 存储自定义对象

### 1. 定义模型类

```dart
import 'package:hive/hive.dart';

part 'user.g.dart'; // 生成的代码

@HiveType(typeId: 0) // typeId 必须唯一且不变
class User extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late int age;

  @HiveField(3)
  DateTime? createdAt;

  @HiveField(4, defaultValue: false) // 可设置默认值
  late bool isActive;

  User({
    required this.name,
    required this.email,
    required this.age,
    this.createdAt,
    this.isActive = false,
  });

  @override
  String toString() => 'User(name: $name, email: $email, age: $age)';
}
```

### 2. 生成 TypeAdapter

```bash
dart run build_runner build
```

生成的 `user.g.dart`：

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      name: fields[0] as String,
      email: fields[1] as String,
      age: fields[2] as int,
      createdAt: fields[3] as DateTime?,
      isActive: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
```

### 3. 注册并使用

```dart
void main() async {
  await Hive.initFlutter();
  
  // 注册 Adapter（在 openBox 之前）
  Hive.registerAdapter(UserAdapter());
  
  // 打开类型化的 Box
  await Hive.openBox<User>('users');
  
  runApp(MyApp());
}

// 使用
void userOperations() {
  final box = Hive.box<User>('users');
  
  // 添加用户
  final user = User(
    name: '张三',
    email: 'zhangsan@example.com',
    age: 25,
    createdAt: DateTime.now(),
  );
  
  // 使用自动生成的 key（索引）
  box.add(user);
  
  // 使用自定义 key
  box.put('user_001', user);
  
  // 读取
  final savedUser = box.get('user_001');
  print(savedUser); // User(name: 张三, ...)
  
  // 通过索引读取
  final firstUser = box.getAt(0);
  
  // 获取所有用户
  final allUsers = box.values.toList();
  
  // 更新（HiveObject 提供的便捷方法）
  user.age = 26;
  user.save(); // 自动保存到 Box
  
  // 删除
  user.delete(); // 从 Box 中删除
  // 或
  box.delete('user_001');
  box.deleteAt(0);
}
```

---

## HiveObject 的便捷方法

继承 `HiveObject` 可以获得额外的便捷方法：

```dart
@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late bool completed;

  Task({required this.title, this.completed = false});
}

void taskOperations() {
  final box = Hive.box<Task>('tasks');
  
  final task = Task(title: '学习 Hive');
  box.add(task);
  
  // 获取 key
  print(task.key); // 0
  
  // 检查是否在 Box 中
  print(task.isInBox); // true
  
  // 更新并保存
  task.completed = true;
  task.save(); // 自动保存到原来的位置
  
  // 删除自己
  task.delete();
}
```

---

## 监听数据变化

Hive 支持响应式监听，非常适合与 Flutter 结合使用。

### ValueListenableBuilder

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, widget) {
        final darkMode = box.get('darkMode', defaultValue: false);
        
        return SwitchListTile(
          title: Text('深色模式'),
          value: darkMode,
          onChanged: (value) {
            box.put('darkMode', value);
          },
        );
      },
    );
  }
}
```

### 监听特定 Key

```dart
ValueListenableBuilder(
  // 只监听指定的 keys
  valueListenable: Hive.box('settings').listenable(keys: ['darkMode', 'language']),
  builder: (context, Box box, widget) {
    // 只有这两个 key 变化时才会重建
    return Column(
      children: [
        Text('Dark Mode: ${box.get('darkMode')}'),
        Text('Language: ${box.get('language')}'),
      ],
    );
  },
);
```

### Stream 监听

```dart
void watchChanges() {
  final box = Hive.box('settings');
  
  // 监听所有变化
  box.watch().listen((event) {
    print('Key: ${event.key}');
    print('Value: ${event.value}');
    print('Deleted: ${event.deleted}');
  });
  
  // 监听特定 key
  box.watch(key: 'darkMode').listen((event) {
    print('Dark mode changed: ${event.value}');
  });
}
```

---

## 数据加密

Hive 支持 AES-256 加密，保护敏感数据。

```dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureHive {
  static const _keyName = 'hive_encryption_key';
  static final _secureStorage = FlutterSecureStorage();
  
  /// 获取或生成加密密钥
  static Future<List<int>> getEncryptionKey() async {
    final storedKey = await _secureStorage.read(key: _keyName);
    
    if (storedKey != null) {
      return base64Decode(storedKey);
    }
    
    // 生成新密钥
    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _keyName,
      value: base64Encode(newKey),
    );
    return newKey;
  }
  
  /// 打开加密 Box
  static Future<Box<T>> openEncryptedBox<T>(String name) async {
    final key = await getEncryptionKey();
    return Hive.openBox<T>(
      name,
      encryptionCipher: HiveAesCipher(key),
    );
  }
}

// 使用
void main() async {
  await Hive.initFlutter();
  
  // 打开加密的 Box
  final secureBox = await SecureHive.openEncryptedBox('secure_data');
  
  // 存储敏感数据
  secureBox.put('token', 'sensitive_token_value');
  secureBox.put('password', 'user_password');
  
  runApp(MyApp());
}
```

---

## 懒加载 Box

对于大型数据集，使用懒加载 Box 可以减少内存占用：

```dart
// 普通 Box 会将所有数据加载到内存
var box = await Hive.openBox('normalBox');

// LazyBox 只在需要时加载数据
var lazyBox = await Hive.openLazyBox('lazyBox');

// 读取（异步）
var value = await lazyBox.get('key');

// 写入（同普通 Box）
await lazyBox.put('key', 'value');
```

---

## 完整示例：Todo 应用

### 模型定义

```dart
// models/todo.dart
import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late bool completed;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  String? description;

  Todo({
    required this.title,
    this.completed = false,
    DateTime? createdAt,
    this.description,
  }) : createdAt = createdAt ?? DateTime.now();
}
```

### 初始化

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todos');
  
  runApp(TodoApp());
}
```

### Todo 列表页面

```dart
// pages/todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

class TodoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () => _clearCompleted(context),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Todo>('todos').listenable(),
        builder: (context, Box<Todo> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('暂无待办事项'));
          }
          
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final todo = box.getAt(index)!;
              return _buildTodoItem(context, todo, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildTodoItem(BuildContext context, Todo todo, int index) {
    return Dismissible(
      key: ValueKey(todo.key),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => todo.delete(),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (value) {
            todo.completed = value ?? false;
            todo.save();
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: todo.description != null
            ? Text(todo.description!)
            : null,
        trailing: Text(
          '${todo.createdAt.month}/${todo.createdAt.day}',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
  
  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加待办'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: '输入待办事项'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final todo = Todo(title: controller.text);
                Hive.box<Todo>('todos').add(todo);
              }
              Navigator.pop(context);
            },
            child: Text('添加'),
          ),
        ],
      ),
    );
  }
  
  void _clearCompleted(BuildContext context) {
    final box = Hive.box<Todo>('todos');
    final keysToDelete = box.values
        .where((todo) => todo.completed)
        .map((todo) => todo.key)
        .toList();
    
    box.deleteAll(keysToDelete);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已清除 ${keysToDelete.length} 项')),
    );
  }
}
```

---

## 数据迁移

当模型字段变化时，需要处理数据迁移：

```dart
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String email;

  // 新增字段，设置默认值
  @HiveField(2, defaultValue: '')
  late String phone;

  // 删除字段：不要删除 @HiveField 注解，
  // 只是不再使用该字段即可
  // @HiveField(3) // 已废弃，保留注释
  // late String oldField;

  // 新增字段使用新的 field ID
  @HiveField(4, defaultValue: 'zh')
  late String language;
}
```

::: warning 重要规则
1. **typeId 不能改变** - 每个类型的 typeId 必须唯一且永不改变
2. **fieldId 不能复用** - 删除字段后，其 fieldId 不能被新字段使用
3. **使用 defaultValue** - 新增字段必须设置默认值
:::

---

## 性能优化

### 批量操作

```dart
// 单个操作（每次都会写入磁盘）
for (var user in users) {
  box.put(user.id, user);
}

// 批量操作（更高效）
final map = {for (var u in users) u.id: u};
box.putAll(map);

// 批量删除
box.deleteAll(['key1', 'key2', 'key3']);
```

### 压缩数据

Hive 删除数据时不会立即回收空间，需要手动压缩：

```dart
// 检查是否需要压缩（已删除超过50%）
if (box.length > 0) {
  // 压缩 Box 文件
  await box.compact();
}
```

---

## 最佳实践

1. **合理划分 Box** - 按功能模块分开存储
2. **使用类型化 Box** - `Hive.box<User>('users')` 而非 `Hive.box('users')`
3. **注册 Adapter 顺序一致** - 在所有使用处保持相同顺序
4. **处理空安全** - 使用 `get()` 的 `defaultValue` 参数
5. **大数据用 LazyBox** - 减少内存占用
6. **敏感数据加密** - 使用 `HiveAesCipher`

## Hive vs 其他方案

| 特性 | Hive | SharedPreferences | SQLite |
|------|------|-------------------|--------|
| 数据类型 | 任意 Dart 对象 | 基本类型 | SQL 类型 |
| 查询能力 | 弱（仅 key） | 无 | 强（SQL） |
| 性能 | ⚡⚡⚡ | ⚡⚡ | ⚡ |
| 学习成本 | 低 | 低 | 中 |
| 适用场景 | 缓存、配置、对象存储 | 简单配置 | 复杂关系数据 |

## 相关资源

- [Hive 官方文档](https://docs.hivedb.dev/)
- [Hive GitHub](https://github.com/hivedb/hive)
- [Isar 数据库](https://isar.dev/) - Hive 作者的新项目，支持查询
