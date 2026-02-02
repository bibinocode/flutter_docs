# Dart 语言入门

<script setup>
import DartPad from '../.vitepress/components/DartPad.vue'
</script>

## 什么是 Dart？

Dart 是由 Google 开发的一门面向对象、类定义的编程语言。它被设计用于开发跨平台应用，是 Flutter 框架的官方编程语言。

### Dart 的特点

| 特点 | 说明 |
|------|------|
| 🎯 类型安全 | 支持静态类型检查，同时也支持类型推断 |
| 🚀 高性能 | AOT 编译为原生代码，JIT 支持热重载 |
| 📦 完善的标准库 | 内置丰富的核心库，无需额外依赖 |
| 🔄 异步支持 | 原生支持 async/await 和 Stream |
| 🌐 跨平台 | 可编译为 Web、移动端、桌面端应用 |

## 为什么选择 Dart？

作为前端开发者，你可能已经熟悉 JavaScript/TypeScript。Dart 与 JavaScript 有很多相似之处，但也有一些关键的改进：

```dart
// JavaScript/TypeScript
const greet = (name) => `Hello, ${name}!`;

// Dart
String greet(String name) => 'Hello, $name!';
```

### 与 JavaScript 的对比

| 特性 | JavaScript | Dart |
|------|-----------|------|
| 类型系统 | 动态类型（TS 可选静态） | 健全的空安全静态类型 |
| 类语法 | ES6 class | 类似 Java 的完整 OOP |
| 异步 | Promise + async/await | Future + async/await |
| 空安全 | 可选链 `?.` | 语言级空安全 |
| 私有成员 | `#` 或约定 `_` | `_` 前缀 (库级私有) |

## Hello World

让我们从最简单的 Dart 程序开始：

<DartPad code="void main() {
  print('Hello, World!');
}" />

### 代码解析

- `void main()` - 程序入口函数，`void` 表示无返回值
- `print()` - 打印输出到控制台
- 每条语句以分号 `;` 结尾（必须）

## 基本语法

### 变量声明

Dart 有多种声明变量的方式：

```dart
// 使用 var - 类型推断
var name = 'Flutter';  // 推断为 String

// 显式类型声明
String language = 'Dart';
int version = 3;
double pi = 3.14159;
bool isAwesome = true;

// final - 运行时常量（只能赋值一次）
final currentTime = DateTime.now();

// const - 编译时常量
const maxItems = 100;
```

::: tip final vs const
- `final` 变量只能被赋值一次，但值可以在运行时确定
- `const` 是编译时常量，值必须在编译时就能确定

```dart
final now = DateTime.now();  // ✅ 运行时计算
const now = DateTime.now();  // ❌ 编译错误

const list = [1, 2, 3];  // ✅ 编译时常量
final list = [1, 2, 3];  // ✅ 运行时常量
```
:::

### 字符串

Dart 的字符串支持丰富的特性：

```dart
// 单引号或双引号
String s1 = 'Single quotes';
String s2 = "Double quotes";

// 字符串插值
var name = 'Dart';
var greeting = 'Hello, $name!';  // Hello, Dart!
var math = '1 + 1 = ${1 + 1}';   // 1 + 1 = 2

// 多行字符串
var multiLine = '''
  这是一个
  多行字符串
''';

// 原始字符串（不转义）
var raw = r'换行符是 \n';  // 换行符是 \n
```

### 集合类型

```dart
// List（列表）
var numbers = [1, 2, 3, 4, 5];
var typedList = <String>['a', 'b', 'c'];

// Set（集合，元素唯一）
var uniqueNumbers = {1, 2, 3, 4, 5};
var typedSet = <String>{'a', 'b', 'c'};

// Map（键值对）
var person = {
  'name': 'Flutter',
  'version': 3,
};
var typedMap = <String, int>{
  'one': 1,
  'two': 2,
};
```

## 空安全

Dart 2.12 引入了健全的空安全（Sound Null Safety），这是与 JavaScript 最大的区别之一。

```dart
// 非空类型 - 默认不能为 null
String name = 'Flutter';  // ✅
String name = null;       // ❌ 编译错误

// 可空类型 - 使用 ? 声明
String? nullableName = null;  // ✅
String? nullableName = 'Dart';  // ✅

// 空感知操作符
String? name = null;
print(name?.length);     // null（安全访问）
print(name ?? 'default'); // default（空值替代）
name ??= 'Flutter';      // 如果为 null 则赋值

// 非空断言（谨慎使用）
String? name = 'Dart';
print(name!.length);     // 断言非空，如果为 null 会抛异常
```

::: warning 空安全最佳实践
1. 优先使用非空类型
2. 只在确实需要时使用可空类型 `?`
3. 避免过度使用非空断言 `!`
4. 善用空值合并操作符 `??`
:::

## 函数

### 基本函数

```dart
// 完整写法
int add(int a, int b) {
  return a + b;
}

// 箭头函数（单表达式）
int add(int a, int b) => a + b;

// 可选参数（位置）
void greet(String name, [String? title]) {
  print('Hello, ${title ?? ''} $name');
}
greet('Dart');           // Hello, Dart
greet('Dart', 'Mr.');    // Hello, Mr. Dart

// 可选参数（命名）
void greet({required String name, String? title}) {
  print('Hello, ${title ?? ''} $name');
}
greet(name: 'Dart');              // Hello, Dart
greet(name: 'Dart', title: 'Mr.'); // Hello, Mr. Dart

// 默认参数值
void greet(String name, {String title = 'Sir'}) {
  print('Hello, $title $name');
}
```

### 函数作为一等公民

```dart
// 函数赋值给变量
var multiply = (int a, int b) => a * b;
print(multiply(3, 4));  // 12

// 函数作为参数
void execute(int Function(int, int) operation) {
  print(operation(2, 3));
}
execute(multiply);  // 6

// 函数作为返回值
Function(int) makeAdder(int addBy) {
  return (int i) => i + addBy;
}
var add2 = makeAdder(2);
print(add2(3));  // 5
```

## 流程控制

### 条件语句

```dart
// if-else
if (score >= 90) {
  print('优秀');
} else if (score >= 60) {
  print('及格');
} else {
  print('不及格');
}

// 三元运算符
var result = score >= 60 ? '及格' : '不及格';

// switch（支持字符串和枚举）
switch (day) {
  case 'Monday':
    print('星期一');
    break;
  case 'Tuesday':
    print('星期二');
    break;
  default:
    print('其他');
}
```

### 循环

```dart
// for 循环
for (var i = 0; i < 5; i++) {
  print(i);
}

// for-in 循环
var list = [1, 2, 3];
for (var item in list) {
  print(item);
}

// forEach
list.forEach((item) => print(item));

// while
var i = 0;
while (i < 5) {
  print(i++);
}

// do-while
do {
  print(i--);
} while (i > 0);
```

## 在线练习

试着在 DartPad 中运行和修改代码：

```dart
void main() {
  // 变量声明
  var name = 'Flutter';
  final version = 3;
  
  // 字符串插值
  print('Welcome to $name $version!');
  
  // 列表操作
  var numbers = [1, 2, 3, 4, 5];
  var doubled = numbers.map((n) => n * 2).toList();
  print('Doubled: $doubled');
  
  // 可空类型
  String? nullable = null;
  print('Nullable: ${nullable ?? "default"}');
  
  // 函数调用
  greet(name: 'Dart', emoji: '🎯');
}

void greet({required String name, String emoji = '👋'}) {
  print('$emoji Hello, $name!');
}
```

::: tip 在线运行
将上述代码复制到 [DartPad](https://dartpad.dev) 在线运行和修改。
:::

## 下一步

现在你已经了解了 Dart 的基础语法，接下来我们将学习：

- [变量与类型](/dart/02-variables) - 深入了解 Dart 的类型系统
- [函数进阶](/dart/03-functions) - 闭包、高阶函数、泛型函数
- [类与对象](/dart/04-classes) - 面向对象编程

::: info 学习资源
- [Dart 官方文档](https://dart.dev/guides)
- [DartPad 在线编程](https://dartpad.dev)
- [Effective Dart 风格指南](https://dart.dev/guides/language/effective-dart)
:::
