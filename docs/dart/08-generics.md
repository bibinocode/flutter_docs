# 泛型详解

泛型（Generics）允许你编写灵活、可复用的代码，同时保持类型安全。本章将深入讲解 Dart 的泛型系统。

## 为什么需要泛型？

### 没有泛型的问题

```dart
// 问题 1：类型不安全
class IntBox {
  int value;
  IntBox(this.value);
}

class StringBox {
  String value;
  StringBox(this.value);
}

// 需要为每种类型写一个类，代码重复

// 问题 2：使用 dynamic 失去类型检查
class DynamicBox {
  dynamic value;
  DynamicBox(this.value);
}

var box = DynamicBox(42);
box.value = 'hello';  // 可以存任何类型，容易出错
int num = box.value;  // 运行时可能报错
```

### 使用泛型的解决方案

```dart
// 泛型类 Box，T 是类型参数
class Box&lt;T&gt; {
  T value;
  Box(this.value);
}

var intBox = Box&lt;int&gt;(42);
var stringBox = Box&lt;String&gt;('hello');

intBox.value = 'test';  // ❌ 编译错误，类型安全
```

## 泛型类

### 基本语法

```dart
// 两个类型参数 K 和 V
class Pair&lt;K, V&gt; {
  final K first;
  final V second;
  
  Pair(this.first, this.second);
  
  @override
  String toString() => '($first, $second)';
}

// 使用
var point = Pair&lt;int, int&gt;(10, 20);
var entry = Pair&lt;String, dynamic&gt;('name', 'Alice');
```

### 类型推断

```dart
// Dart 可以推断泛型类型
var box = Box(42);  // 自动推断为 Box 的 int 版本
var pair = Pair('key', 100);  // 自动推断

// 显式指定更清晰
var box2 = Box&lt;int&gt;(42);
```

### 实际示例：结果类型

```dart
// 封装操作结果
class Result&lt;T&gt; {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  Result._({this.data, this.error, required this.isSuccess});
  
  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }
  
  factory Result.failure(String error) {
    return Result._(error: error, isSuccess: false);
  }
}

// 使用示例
Result&lt;String&gt; fetchData() {
  try {
    return Result.success('数据内容');
  } catch (e) {
    return Result.failure(e.toString());
  }
}
```

## 泛型方法

### 基本语法

```dart
// 泛型方法，T 是方法的类型参数
T getFirst&lt;T&gt;(List&lt;T&gt; items) {
  return items.first;
}

// 多个类型参数
Map&lt;K, V&gt; createMap&lt;K, V&gt;(K key, V value) {
  return {key: value};
}

// 使用
var first = getFirst&lt;int&gt;([1, 2, 3]);  // 返回 int
var first2 = getFirst(['a', 'b', 'c']); // 类型推断为 String

var map = createMap&lt;String, int&gt;('count', 10);
```

### 实际示例

```dart
// 通用解析方法
T? tryParse&lt;T&gt;(dynamic value) {
  if (value == null) return null;
  if (value is T) return value;
  
  if (T == int) {
    return int.tryParse(value.toString()) as T?;
  } else if (T == double) {
    return double.tryParse(value.toString()) as T?;
  }
  
  return null;
}

// 使用
var intValue = tryParse&lt;int&gt;('42');       // 42
var doubleValue = tryParse&lt;double&gt;('3.14'); // 3.14
```

## 泛型约束

### extends 约束

```dart
// 约束 T 必须是 num 或其子类
class NumberBox&lt;T extends num&gt; {
  T value;
  NumberBox(this.value);
  
  T add(T other) {
    return (value + other) as T;
  }
}

var intBox = NumberBox&lt;int&gt;(10);
var doubleBox = NumberBox&lt;double&gt;(3.14);
// var stringBox = NumberBox&lt;String&gt;('hello');  // ❌ 编译错误

// 约束为 Comparable 接口
class Sortable&lt;T extends Comparable&lt;T&gt;&gt; {
  List&lt;T&gt; items;
  Sortable(this.items);
  
  void sort() {
    items.sort();
  }
}
```

## 协变与逆变

### 协变（Covariant）

Dart 的泛型是协变的，子类型的泛型可以赋值给父类型的泛型：

```dart
// int 是 num 的子类型
// 所以 List of int 可以赋值给 List of num
var ints = [1, 2, 3];
List&lt;num&gt; nums = ints;  // ✅ 协变

// 但要注意：通过 nums 添加 double 会导致运行时错误
// nums.add(3.14);  // 运行时错误
```

### covariant 关键字

```dart
class Animal {
  void chase(Animal other) {}
}

class Dog extends Animal {
  // 使用 covariant 放宽参数类型限制
  @override
  void chase(covariant Dog other) {
    // 只能追狗
  }
}
```

## 常用泛型集合

### List

```dart
var numbers = &lt;int&gt;[1, 2, 3];
var names = &lt;String&gt;['Alice', 'Bob'];
var users = &lt;Map&lt;String, dynamic&gt;&gt;[
  {'name': 'Alice', 'age': 25},
  {'name': 'Bob', 'age': 30},
];
```

### Map

```dart
var scores = &lt;String, int&gt;{'math': 90, 'english': 85};
var grouped = &lt;int, List&lt;String&gt;&gt;{
  1: ['a', 'b'],
  2: ['c', 'd'],
};
```

### Set

```dart
var numbers = &lt;int&gt;{1, 2, 3};
var tags = &lt;String&gt;{'flutter', 'dart', 'mobile'};
```

### Future 和 Stream

```dart
Future&lt;String&gt; fetchData() async {
  return 'data';
}

Stream&lt;int&gt; countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}
```

## 高级泛型模式

### 工厂模式

```dart
abstract class Serializable&lt;T&gt; {
  Map&lt;String, dynamic&gt; toJson();
  T fromJson(Map&lt;String, dynamic&gt; json);
}

// 工厂类
class JsonFactory&lt;T extends Serializable&lt;T&gt;&gt; {
  final T Function(Map&lt;String, dynamic&gt;) creator;
  
  JsonFactory(this.creator);
  
  T parse(String jsonString) {
    final map = json.decode(jsonString) as Map&lt;String, dynamic&gt;;
    return creator(map);
  }
}
```

### 仓储模式

```dart
abstract class Repository&lt;T, ID&gt; {
  Future&lt;T?&gt; findById(ID id);
  Future&lt;List&lt;T&gt;&gt; findAll();
  Future&lt;T&gt; save(T entity);
  Future&lt;void&gt; delete(ID id);
}

// 具体实现
class UserRepository extends Repository&lt;User, String&gt; {
  @override
  Future&lt;User?&gt; findById(String id) async {
    // 实现查询逻辑
    return null;
  }
  
  @override
  Future&lt;List&lt;User&gt;&gt; findAll() async {
    return [];
  }
  
  @override
  Future&lt;User&gt; save(User entity) async {
    return entity;
  }
  
  @override
  Future&lt;void&gt; delete(String id) async {
    // 实现删除逻辑
  }
}
```

## 泛型与类型别名

```dart
// 类型别名简化复杂类型
typedef JsonMap = Map&lt;String, dynamic&gt;;
typedef Callback&lt;T&gt; = void Function(T value);
typedef Predicate&lt;T&gt; = bool Function(T value);
typedef Comparator&lt;T&gt; = int Function(T a, T b);

// 使用
JsonMap user = {'name': 'Alice', 'age': 25};

void processData(Callback&lt;String&gt; callback) {
  callback('data processed');
}

List&lt;T&gt; filter&lt;T&gt;(List&lt;T&gt; items, Predicate&lt;T&gt; test) {
  return items.where(test).toList();
}
```

## 运行时类型检查

```dart
void process&lt;T&gt;(T value) {
  // 运行时类型检查
  if (value is List) {
    print('It is a list with ${value.length} items');
  }
  
  // 注意：泛型类型在运行时会被擦除
  if (T == int) {
    print('T is int');
  }
}

// 使用 runtimeType
void printType&lt;T&gt;(T value) {
  print('Compile-time type: $T');
  print('Runtime type: ${value.runtimeType}');
}

printType&lt;num&gt;(42);
// Compile-time type: num
// Runtime type: int
```

## 最佳实践

### 1. 使用有意义的类型参数名

```dart
// ❌ 不清晰
class MyClass&lt;A, B, C&gt; {}

// ✅ 清晰
class MyClass&lt;Key, Value, Error&gt; {}

// 常用约定：
// T - Type（通用类型）
// E - Element（元素）
// K - Key（键）
// V - Value（值）
// R - Return（返回值）
```

### 2. 尽量使用泛型约束

```dart
// ❌ 过于宽泛，无法调用 compareTo
class Sorter&lt;T&gt; {
  void sort(List&lt;T&gt; items) {
    // 无法排序
  }
}

// ✅ 添加约束
class Sorter&lt;T extends Comparable&lt;T&gt;&gt; {
  void sort(List&lt;T&gt; items) {
    items.sort((a, b) => a.compareTo(b));
  }
}
```

### 3. 避免不必要的泛型

```dart
// ❌ 泛型没有实际用途
class Logger&lt;T&gt; {
  void log(String message) {
    print(message);
  }
}

// ✅ 直接用普通类
class Logger {
  void log(String message) {
    print(message);
  }
}
```

### 4. 利用类型推断

```dart
// ❌ 冗余的类型声明
var numbers = &lt;int&gt;[1, 2, 3];

// ✅ 利用类型推断
var numbers = [1, 2, 3];  // 自动推断为 List of int
var scores = {'a': 1};    // 自动推断为 Map of String to int
```

## 下一步

掌握泛型后，下一章我们将学习 [异常处理](./09-exceptions)，学会优雅地处理程序中的错误。
