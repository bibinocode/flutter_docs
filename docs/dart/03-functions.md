# 函数与闭包

Dart 是一门真正的面向对象语言，函数也是对象，类型为 `Function`。本章介绍函数的定义、参数和高级特性。

## 函数定义

### 基本语法

```dart
// 完整语法
String greet(String name) {
  return 'Hello, $name!';
}

// 返回类型可省略（不推荐）
greet(String name) {
  return 'Hello, $name!';
}

// 箭头函数（单表达式）
String greet(String name) => 'Hello, $name!';

// void 函数
void printMessage(String message) {
  print(message);
}
```

### main 函数

```dart
// 程序入口
void main() {
  print('Hello, Dart!');
}

// 带命令行参数
void main(List<String> args) {
  print('参数: $args');
}
```

## 函数参数

### 位置参数（必需）

```dart
// 按顺序传递
String fullName(String first, String last) {
  return '$first $last';
}

// 调用
fullName('John', 'Doe');
```

### 可选位置参数

```dart
// 用 [] 包裹
String greet(String name, [String? title]) {
  if (title != null) {
    return 'Hello, $title $name!';
  }
  return 'Hello, $name!';
}

// 带默认值
String greet(String name, [String title = 'Mr.']) {
  return 'Hello, $title $name!';
}

// 调用
greet('John');          // Hello, Mr. John!
greet('John', 'Dr.');   // Hello, Dr. John!
```

### 命名参数

```dart
// 用 {} 包裹，默认可选
void createUser({String? name, int? age}) {
  print('Name: $name, Age: $age');
}

// required 关键字标记必需
void createUser({required String name, int age = 18}) {
  print('Name: $name, Age: $age');
}

// 调用（参数顺序任意）
createUser(name: 'Alice', age: 25);
createUser(age: 30, name: 'Bob');
createUser(name: 'Charlie');  // age 使用默认值
```

### 混合参数

```dart
// 位置参数 + 命名参数
void log(String message, {bool timestamp = true, String? tag}) {
  var output = '';
  if (timestamp) output += '[${DateTime.now()}] ';
  if (tag != null) output += '[$tag] ';
  output += message;
  print(output);
}

log('Hello');
log('Error!', tag: 'ERROR');
log('Debug', timestamp: false, tag: 'DEBUG');
```

## 函数作为一等公民

### 函数赋值给变量

```dart
// 函数类型
int add(int a, int b) => a + b;
int subtract(int a, int b) => a - b;

// 赋值给变量
var operation = add;
print(operation(5, 3));  // 8

operation = subtract;
print(operation(5, 3));  // 2

// 指定类型
int Function(int, int) mathOp = add;
```

### 函数作为参数

```dart
// 高阶函数
void executeOperation(int a, int b, int Function(int, int) operation) {
  print('结果: ${operation(a, b)}');
}

executeOperation(10, 5, add);       // 结果: 15
executeOperation(10, 5, subtract);  // 结果: 5

// 常见使用场景：集合操作
var numbers = [1, 2, 3, 4, 5];
var doubled = numbers.map((n) => n * 2);
var evens = numbers.where((n) => n.isEven);
var sum = numbers.reduce((a, b) => a + b);
```

### 函数作为返回值

```dart
// 返回函数
Function makeAdder(int addBy) {
  return (int i) => i + addBy;
}

// 使用
var add2 = makeAdder(2);
var add5 = makeAdder(5);

print(add2(3));  // 5
print(add5(3));  // 8
```

## 匿名函数（Lambda）

```dart
// 无参数
var sayHello = () {
  print('Hello!');
};

// 带参数
var greet = (String name) {
  print('Hello, $name!');
};

// 箭头语法
var add = (int a, int b) => a + b;

// 常用于回调
var numbers = [1, 2, 3];
numbers.forEach((n) {
  print('Number: $n');
});

// 简化写法
numbers.forEach((n) => print('Number: $n'));
```

## 闭包 (Closure)

闭包是一个函数对象，它可以访问其词法作用域内的变量，即使函数在其原始作用域之外执行。

```dart
// 基本闭包
Function makeCounter() {
  var count = 0;  // 被闭包捕获
  return () {
    count++;
    return count;
  };
}

var counter = makeCounter();
print(counter());  // 1
print(counter());  // 2
print(counter());  // 3

// 每次调用 makeCounter 都创建新的闭包
var counter2 = makeCounter();
print(counter2()); // 1 - 独立的计数

// 实际应用：事件处理
void setupButton(String buttonName) {
  var clickCount = 0;
  
  // 返回的函数闭包捕获了 buttonName 和 clickCount
  return () {
    clickCount++;
    print('$buttonName 被点击了 $clickCount 次');
  };
}
```

### 闭包与循环

```dart
// 常见陷阱
var callbacks = <Function>[];
for (var i = 0; i < 3; i++) {
  callbacks.add(() => print(i));
}
// 全部输出 3（因为闭包捕获的是变量引用）

// 解决方案：使用 forEach 或 for-in
for (var i in [0, 1, 2]) {
  callbacks.add(() => print(i));
}
// 输出 0, 1, 2
```

## 级联操作符

```dart
// 不使用级联
var sb = StringBuffer();
sb.write('foo');
sb.write('bar');
var result = sb.toString();

// 使用级联 (..)
var result = StringBuffer()
  ..write('foo')
  ..write('bar')
  ..toString();

// 实际应用
var button = Button()
  ..text = 'Click Me'
  ..color = Colors.blue
  ..onPressed = () => print('Clicked');
```

## typedef 类型别名

```dart
// 定义函数类型别名
typedef IntOperation = int Function(int a, int b);

// 使用
IntOperation add = (a, b) => a + b;
IntOperation multiply = (a, b) => a * b;

void calculate(int a, int b, IntOperation op) {
  print('结果: ${op(a, b)}');
}

calculate(5, 3, add);       // 结果: 8
calculate(5, 3, multiply);  // 结果: 15

// 泛型类型别名
typedef Compare<T> = int Function(T a, T b);

int compareInt(int a, int b) => a - b;
Compare<int> intComparator = compareInt;
```

## 生成器函数

### 同步生成器 (sync*)

```dart
// 返回 Iterable
Iterable<int> range(int start, int end) sync* {
  for (var i = start; i <= end; i++) {
    yield i;  // 逐个产出值
  }
}

// 使用
for (var n in range(1, 5)) {
  print(n);  // 1, 2, 3, 4, 5
}

// yield* 委托
Iterable<int> extendedRange(int start, int end) sync* {
  yield start - 1;
  yield* range(start, end);  // 委托给另一个生成器
  yield end + 1;
}
```

### 异步生成器 (async*)

```dart
// 返回 Stream
Stream<int> countStream(int max) async* {
  for (var i = 1; i <= max; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// 使用
await for (var count in countStream(5)) {
  print(count);  // 每秒输出 1, 2, 3, 4, 5
}
```

## 实践练习

```dart
void main() {
  // 练习 1：高阶函数
  var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  
  // 找出所有偶数并翻倍
  var result = numbers
      .where((n) => n.isEven)
      .map((n) => n * 2)
      .toList();
  print('结果: $result');  // [4, 8, 12, 16, 20]
  
  // 练习 2：闭包
  var multiplier = makeMultiplier(3);
  print(multiplier(5));  // 15
  
  // 练习 3：自定义高阶函数
  var doubled = transform([1, 2, 3], (n) => n * 2);
  print(doubled);  // [2, 4, 6]
}

// 闭包工厂
Function makeMultiplier(int factor) {
  return (int n) => n * factor;
}

// 自定义 map 函数
List<R> transform<T, R>(List<T> list, R Function(T) transformer) {
  var result = <R>[];
  for (var item in list) {
    result.add(transformer(item));
  }
  return result;
}
```

## 下一步

掌握函数后，下一章我们将学习 [类与对象](./04-classes)，了解 Dart 的面向对象编程。
