# 变量与数据类型

Dart 是一门强类型语言，但支持类型推断。本章介绍 Dart 中的变量声明和基本数据类型。

## 变量声明

### var 关键字（类型推断）

```dart
var name = 'Flutter';  // 推断为 String
var count = 42;        // 推断为 int
var price = 3.14;      // 推断为 double
var isActive = true;   // 推断为 bool

// 注意：一旦推断类型，不能赋值其他类型
name = 123;  // ❌ 编译错误
```

### 显式类型声明

```dart
String name = 'Flutter';
int count = 42;
double price = 3.14;
bool isActive = true;
```

### final 和 const

```dart
// final - 运行时常量，只能赋值一次
final String name = 'Flutter';
final now = DateTime.now();  // ✅ 可以使用运行时值

// const - 编译时常量
const double pi = 3.14159;
const list = [1, 2, 3];  // 列表也是常量，不可修改

// const now = DateTime.now();  // ❌ 编译错误，DateTime.now() 是运行时值
```

### late 关键字

```dart
// 延迟初始化，用于后续赋值
late String description;

void init() {
  description = '这是延迟初始化的变量';
}

// 懒加载，首次使用时才计算
late String expensive = _computeExpensiveValue();
```

## 基本数据类型

### 数字类型

```dart
// int - 整数
int age = 25;
int hex = 0xDEADBEEF;  // 十六进制

// double - 浮点数
double pi = 3.14159;
double exponent = 1.42e5;  // 科学计数法

// num - 可以是 int 或 double
num x = 1;
x = 1.5;  // ✅ 可以

// 数字操作
print(5 / 2);   // 2.5 (除法)
print(5 ~/ 2);  // 2 (整除)
print(5 % 2);   // 1 (取模)
print(2.abs()); // 2 (绝对值)
```

### 字符串

```dart
// 单引号或双引号
String s1 = 'Hello';
String s2 = "World";

// 字符串插值
var name = 'Flutter';
print('Hello, $name');           // Hello, Flutter
print('1 + 1 = ${1 + 1}');       // 1 + 1 = 2

// 多行字符串
var multiLine = '''
这是
多行
字符串
''';

// 原始字符串（不转义）
var raw = r'换行符是 \n';  // 输出: 换行符是 \n

// 字符串拼接
var combined = 'Hello' + ' ' + 'World';
var combined2 = 'Hello' ' ' 'World';  // 相邻字符串自动拼接
```

### 布尔类型

```dart
bool isTrue = true;
bool isFalse = false;

// 注意：Dart 不会隐式转换类型
var name = 'Flutter';
// if (name) { }  // ❌ 编译错误，不能这样用

// 正确做法
if (name.isNotEmpty) { }
```

## 集合类型

### List（列表/数组）

```dart
// 创建列表
var list1 = [1, 2, 3];
List<int> list2 = [1, 2, 3];
var emptyList = <int>[];

// 常用操作
list1.add(4);           // [1, 2, 3, 4]
list1.addAll([5, 6]);   // [1, 2, 3, 4, 5, 6]
list1.remove(1);        // [2, 3, 4, 5, 6]
list1.removeAt(0);      // [3, 4, 5, 6]
list1.insert(0, 1);     // [1, 3, 4, 5, 6]
print(list1.length);    // 5
print(list1[0]);        // 1
print(list1.first);     // 1
print(list1.last);      // 6
print(list1.reversed);  // (6, 5, 4, 3, 1)

// 扩展操作符
var list3 = [0, ...list1];  // [0, 1, 3, 4, 5, 6]
var list4 = [0, ...?nullableList];  // 安全扩展

// 集合 if 和 for
var nav = [
  'Home',
  'Products',
  if (isAdmin) 'Admin',
];

var doubled = [
  for (var i in list1) i * 2
];
```

### Set（集合）

```dart
// 创建 Set（不重复元素）
var set1 = {1, 2, 3};
Set<int> set2 = {1, 2, 3};
var emptySet = <int>{};

// 常用操作
set1.add(4);            // {1, 2, 3, 4}
set1.add(1);            // {1, 2, 3, 4} - 重复元素不添加
set1.remove(1);         // {2, 3, 4}
print(set1.contains(2)); // true

// 集合运算
var a = {1, 2, 3};
var b = {2, 3, 4};
print(a.union(b));        // {1, 2, 3, 4} 并集
print(a.intersection(b)); // {2, 3} 交集
print(a.difference(b));   // {1} 差集
```

### Map（映射/字典）

```dart
// 创建 Map
var map1 = {'name': 'Flutter', 'version': 3};
Map<String, dynamic> map2 = {'name': 'Flutter', 'version': 3};
var emptyMap = <String, int>{};

// 常用操作
map1['author'] = 'Google';  // 添加/修改
print(map1['name']);        // Flutter
print(map1.keys);           // (name, version, author)
print(map1.values);         // (Flutter, 3, Google)
print(map1.containsKey('name')); // true
map1.remove('version');     // 删除键值对

// 遍历
map1.forEach((key, value) {
  print('$key: $value');
});

for (var entry in map1.entries) {
  print('${entry.key}: ${entry.value}');
}
```

## 空安全 (Null Safety)

Dart 2.12+ 默认开启空安全，变量默认不可为 null。

```dart
// 非空类型
String name = 'Flutter';  // 不能为 null
// name = null;  // ❌ 编译错误

// 可空类型（加 ?）
String? nullableName;     // 可以为 null
nullableName = null;      // ✅ OK
nullableName = 'Flutter'; // ✅ OK

// 空感知操作符
String? input;

// ?? 空值合并
var result = input ?? 'default';  // input 为 null 则用 default

// ??= 空值赋值
input ??= 'default';  // input 为 null 才赋值

// ?. 空值访问
print(input?.length);  // input 为 null 返回 null，否则返回 length

// ! 强制非空（谨慎使用）
String notNull = input!;  // 断言 input 不为 null，为 null 则抛异常
```

## 类型检查和转换

```dart
// is 类型检查
if (value is String) {
  print(value.length);  // 自动类型提升
}

if (value is! int) {
  print('不是整数');
}

// as 类型转换
var name = (value as String).toUpperCase();

// 安全转换
var str = value as String?;  // 可能为 null
```

## 实践练习

```dart
void main() {
  // 练习 1：类型推断
  var message = 'Hello, Dart!';
  print('message 类型: ${message.runtimeType}');
  
  // 练习 2：空安全
  String? nullableStr;
  print('nullableStr 长度: ${nullableStr?.length ?? "null"}');
  
  // 练习 3：集合操作
  var numbers = [1, 2, 3, 4, 5];
  var doubled = numbers.map((n) => n * 2).toList();
  print('翻倍后: $doubled');
  
  // 练习 4：Map 操作
  var person = {'name': 'Alice', 'age': 25};
  person['city'] = 'Beijing';
  print('person: $person');
}
```

## 下一步

掌握了变量和数据类型后，下一章我们将学习 [函数与闭包](./03-functions)。
