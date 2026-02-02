# 空安全详解

空安全（Null Safety）是 Dart 2.12 引入的重要特性，它在编译时检测潜在的空引用错误，让代码更安全、更可靠。

## 什么是空安全？

在没有空安全的语言中，任何变量都可能是 `null`，这导致了大量的运行时错误：

```dart
// 没有空安全时的问题
String name = null;  // 允许
print(name.length);  // 💥 运行时崩溃！

// 防御性编程
if (name != null) {
  print(name.length);
}
```

有了空安全，Dart 在编译时就能发现这类问题：

```dart
// 有空安全
String name = null;  // ❌ 编译错误！

String? name = null;  // ✅ 明确声明可为空
print(name?.length);  // ✅ 安全访问
```

## 可空类型和非空类型

### 非空类型（默认）

```dart
// 默认情况下，变量不能为 null
String name = 'Alice';
int age = 25;
List<String> items = [];

name = null;  // ❌ 编译错误
```

### 可空类型（类型?）

在类型后加 `?` 表示可以为 null：

```dart
String? name = null;      // ✅ 可以为 null
int? age;                 // ✅ 默认为 null
List<String>? items;      // ✅ 整个列表可为 null
List<String?> values = ['a', null, 'b'];  // ✅ 列表元素可为 null
```

### 类型关系

```dart
// String 是 String? 的子类型
String nonNull = 'hello';
String? nullable = nonNull;  // ✅ 自动向上转型

// 反过来需要处理 null
String? nullable = 'hello';
String nonNull = nullable;   // ❌ 编译错误
String nonNull = nullable!;  // ✅ 断言非空
```

## 空安全操作符

### 安全访问 `?.`

```dart
String? name;

// 如果 name 为 null，整个表达式返回 null
print(name?.length);      // null
print(name?.toUpperCase());  // null

// 链式安全访问
String? getName() => null;
print(getName()?.trim()?.toUpperCase());  // null
```

### 空值合并 `??`

```dart
String? name;

// 如果左边为 null，使用右边的值
String displayName = name ?? 'Anonymous';

// 可以链式使用
String? first;
String? second;
String result = first ?? second ?? 'default';
```

### 空值合并赋值 `??=`

```dart
String? name;

// 如果 name 为 null，赋值
name ??= 'Default';
print(name);  // Default

// 已有值时不会覆盖
name ??= 'New Value';
print(name);  // 仍然是 Default
```

### 非空断言 `!`

```dart
String? name = 'Alice';

// 告诉编译器：我确定这不是 null
String definitelyNotNull = name!;

// ⚠️ 危险：如果实际是 null，运行时崩溃
String? nullValue;
String crash = nullValue!;  // 💥 运行时错误
```

::: danger 慎用非空断言
`!` 会绕过编译时检查，如果值实际为 null，会导致运行时错误。只在你 100% 确定值不为 null 时使用。
:::

## 空安全与流程分析

Dart 编译器会进行智能的流程分析（Flow Analysis）：

### 空值检查后自动升级类型

```dart
void printLength(String? text) {
  if (text == null) {
    print('Text is null');
    return;
  }
  
  // 这里 text 自动升级为 String（非空）
  print(text.length);  // ✅ 无需 ?. 或 !
}
```

### 多种检查方式

```dart
String? name;

// 方式 1：if 检查
if (name != null) {
  print(name.length);  // name 是 String
}

// 方式 2：逻辑与
if (name != null && name.length > 5) {
  print('Long name');
}

// 方式 3：提前返回
void process(String? input) {
  if (input == null) return;
  print(input.length);  // input 是 String
}

// 方式 4：throw
void mustHave(String? value) {
  if (value == null) {
    throw ArgumentError('Value cannot be null');
  }
  print(value.length);  // value 是 String
}
```

### 局部变量 vs 实例变量

```dart
class Example {
  String? name;
  
  void process() {
    if (name != null) {
      // ⚠️ 仍然需要 ! 或 ?.
      // 因为 name 可能在检查后被其他代码修改
      print(name!.length);
    }
    
    // 更好的方式：使用局部变量
    final localName = name;
    if (localName != null) {
      print(localName.length);  // ✅ 自动升级
    }
  }
}
```

## late 关键字

### 延迟初始化

```dart
class UserProfile {
  // 声明时不初始化，但保证使用前会初始化
  late String name;
  late int age;
  
  void initialize(Map<String, dynamic> data) {
    name = data['name'];
    age = data['age'];
  }
  
  void display() {
    print('$name, $age');  // ✅ 使用时已初始化
  }
}
```

### 懒加载

```dart
class DataService {
  // 首次访问时才计算
  late final String config = _loadConfig();
  
  String _loadConfig() {
    print('Loading config...');  // 只在首次访问时打印
    return 'config data';
  }
}

var service = DataService();
print('Service created');
print(service.config);  // 现在才打印 "Loading config..."
print(service.config);  // 不再重新加载
```

### late 的风险

```dart
class Risky {
  late String name;
  
  void printName() {
    print(name);  // 💥 如果没初始化，运行时错误！
  }
}

var obj = Risky();
obj.printName();  // LateInitializationError
```

## required 关键字

用于命名参数，表示必须提供：

```dart
// 可选命名参数
void greet({String? name}) {
  print('Hello, ${name ?? "Guest"}');
}

// 必需命名参数
void createUser({
  required String name,
  required String email,
  int? age,  // 可选
}) {
  print('Creating user: $name');
}

createUser(name: 'Alice', email: 'alice@example.com');  // ✅
createUser(name: 'Bob');  // ❌ 缺少 email
```

## 集合中的空安全

### 可空元素 vs 可空集合

```dart
// 列表可为 null，元素非空
List<String>? maybeList;

// 列表非空，元素可为 null
List<String?> listWithNulls = ['a', null, 'b'];

// 两者都可为 null
List<String?>? maybeListWithNulls;
```

### 处理可空集合

```dart
List<String>? items;

// 安全访问
print(items?.length ?? 0);
print(items?.first);
print(items?.isEmpty ?? true);

// 空值合并
var safeItems = items ?? [];
for (var item in safeItems) {
  print(item);
}

// 展开运算符
var combined = [...?items, 'extra'];
```

### 处理可空元素

```dart
List<String?> items = ['a', null, 'b', null, 'c'];

// 过滤 null
var nonNull = items.whereType<String>().toList();
// ['a', 'b', 'c']

// 或者
var nonNull2 = items.where((e) => e != null).cast<String>().toList();

// 处理每个元素
for (var item in items) {
  if (item != null) {
    print(item.toUpperCase());
  }
}
```

## 类中的空安全

### 构造函数

```dart
class User {
  final String name;      // 必须在构造函数中初始化
  final String? nickname;  // 可以为 null
  late String id;         // 稍后初始化
  
  User(this.name, {this.nickname}) {
    id = generateId();
  }
  
  // 命名构造函数
  User.guest() : name = 'Guest', nickname = null {
    id = 'guest_${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

### Getter 和 Setter

```dart
class Product {
  String? _name;
  
  // 可空 getter
  String? get name => _name;
  
  // 非空 getter（带默认值）
  String get displayName => _name ?? 'Unknown Product';
  
  // 可空 setter
  set name(String? value) {
    _name = value?.trim();
  }
}
```

### 继承中的空安全

```dart
abstract class Animal {
  String get name;
  String? get nickname;
  
  void speak();
}

class Dog extends Animal {
  @override
  final String name;
  
  @override
  final String? nickname;
  
  Dog(this.name, {this.nickname});
  
  @override
  void speak() {
    print('$name says: Woof!');
  }
}
```

## 实际应用模式

### 安全解析 JSON

```dart
class User {
  final String name;
  final String? email;
  final int? age;
  
  User({
    required this.name,
    this.email,
    this.age,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      age: json['age'] as int?,
    );
  }
  
  // 更安全的方式
  static User? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    
    final name = json['name'];
    if (name is! String) return null;
    
    return User(
      name: name,
      email: json['email'] as String?,
      age: json['age'] as int?,
    );
  }
}
```

### 链式可空处理

```dart
class Company {
  Department? department;
}

class Department {
  Manager? manager;
}

class Manager {
  String? name;
}

// 安全访问深层属性
String getManagerName(Company? company) {
  return company?.department?.manager?.name ?? 'No Manager';
}
```

### 条件赋值模式

```dart
class Settings {
  String? _theme;
  String? _language;
  
  void applyDefaults() {
    _theme ??= 'light';
    _language ??= 'en';
  }
  
  void update({String? theme, String? language}) {
    // 只更新非 null 的值
    if (theme != null) _theme = theme;
    if (language != null) _language = language;
  }
}
```

## 迁移到空安全

如果你有旧代码需要迁移：

### 步骤

1. 确保依赖包都支持空安全
2. 运行迁移工具：`dart migrate`
3. 检查并调整生成的代码
4. 运行测试确保功能正常

### 常见迁移模式

```dart
// 迁移前
String name;  // 隐式可为 null

// 迁移后 - 选项 1：保持可空
String? name;

// 迁移后 - 选项 2：提供默认值
String name = '';

// 迁移后 - 选项 3：使用 late
late String name;

// 迁移后 - 选项 4：在构造函数初始化
class User {
  final String name;
  User(this.name);
}
```

## 最佳实践

### 1. 尽量使用非空类型

```dart
// ❌ 过度使用可空类型
String? getName() {
  return 'Alice';  // 永远返回非空
}

// ✅ 返回非空类型
String getName() {
  return 'Alice';
}
```

### 2. 避免滥用非空断言

```dart
// ❌ 危险
String value = nullableValue!;

// ✅ 安全处理
String value = nullableValue ?? 'default';

// ✅ 或者检查
if (nullableValue != null) {
  String value = nullableValue;
}
```

### 3. 使用局部变量进行类型升级

```dart
class Example {
  String? name;
  
  // ❌ 需要重复使用 ! 或 ?.
  void bad() {
    if (name != null) {
      print(name!.length);
      print(name!.toUpperCase());
    }
  }
  
  // ✅ 使用局部变量
  void good() {
    final name = this.name;
    if (name != null) {
      print(name.length);
      print(name.toUpperCase());
    }
  }
}
```

### 4. 合理使用 late

```dart
// ✅ 适合使用 late：确定会在使用前初始化
class Widget {
  late final Controller controller;
  
  void init() {
    controller = Controller();
  }
}

// ❌ 不适合：不确定是否会初始化
class Risky {
  late String data;  // 可能忘记初始化
}
```

## 下一步

掌握空安全后，下一章我们将学习 [泛型](./08-generics)，实现类型安全的复用代码。
