# 类与对象

Dart 是一门面向对象的语言，支持基于类的继承和 mixin 的复用。本章介绍类的定义和使用。

## 类的定义

### 基本语法

```dart
class Person {
  // 实例变量（属性）
  String name;
  int age;
  
  // 构造函数
  Person(this.name, this.age);
  
  // 实例方法
  void introduce() {
    print('我是 $name，今年 $age 岁');
  }
}

// 创建实例
var person = Person('Alice', 25);
person.introduce();  // 我是 Alice，今年 25 岁
```

### 属性访问控制

```dart
class BankAccount {
  // 公有属性（默认）
  String owner;
  
  // 私有属性（以 _ 开头）
  double _balance = 0;
  
  BankAccount(this.owner);
  
  // getter
  double get balance => _balance;
  
  // setter（带验证）
  set balance(double value) {
    if (value >= 0) {
      _balance = value;
    }
  }
  
  // 只读属性（只有 getter）
  bool get isEmpty => _balance == 0;
}

var account = BankAccount('Bob');
account.balance = 100;
print(account.balance);  // 100
print(account.isEmpty);  // false
```

## 构造函数

### 默认构造函数

```dart
class Point {
  double x;
  double y;
  
  // 语法糖：自动赋值
  Point(this.x, this.y);
  
  // 等价于
  // Point(double x, double y) {
  //   this.x = x;
  //   this.y = y;
  // }
}
```

### 命名构造函数

```dart
class Point {
  double x;
  double y;
  
  Point(this.x, this.y);
  
  // 命名构造函数
  Point.origin() : x = 0, y = 0;
  
  Point.fromJson(Map<String, double> json)
      : x = json['x'] ?? 0,
        y = json['y'] ?? 0;
}

var p1 = Point(3, 4);
var p2 = Point.origin();
var p3 = Point.fromJson({'x': 1.0, 'y': 2.0});
```

### 初始化列表

```dart
class Rectangle {
  final double width;
  final double height;
  final double area;
  
  // 初始化列表：在构造函数体之前执行
  Rectangle(this.width, this.height)
      : area = width * height,
        assert(width > 0),
        assert(height > 0);
}
```

### const 构造函数

```dart
class ImmutablePoint {
  final double x;
  final double y;
  
  // const 构造函数：创建编译时常量
  const ImmutablePoint(this.x, this.y);
}

// 编译时常量
const origin = ImmutablePoint(0, 0);

// 相同参数的 const 对象是同一个实例
const p1 = ImmutablePoint(1, 2);
const p2 = ImmutablePoint(1, 2);
print(identical(p1, p2));  // true
```

### 工厂构造函数

```dart
class Logger {
  final String name;
  static final Map<String, Logger> _cache = {};
  
  // 私有构造函数
  Logger._internal(this.name);
  
  // 工厂构造函数：控制实例创建
  factory Logger(String name) {
    return _cache.putIfAbsent(name, () => Logger._internal(name));
  }
}

var logger1 = Logger('UI');
var logger2 = Logger('UI');
print(identical(logger1, logger2));  // true（单例）
```

### 重定向构造函数

```dart
class Point {
  double x;
  double y;
  
  Point(this.x, this.y);
  
  // 重定向到另一个构造函数
  Point.alongXAxis(double x) : this(x, 0);
  Point.alongYAxis(double y) : this(0, y);
}
```

## 静态成员

```dart
class MathUtils {
  // 静态常量
  static const double pi = 3.14159;
  
  // 静态变量
  static int _counter = 0;
  
  // 静态方法
  static double circleArea(double radius) {
    return pi * radius * radius;
  }
  
  static int get counter => _counter;
  static void incrementCounter() => _counter++;
}

// 通过类名访问
print(MathUtils.pi);
print(MathUtils.circleArea(5));
MathUtils.incrementCounter();
```

## 继承

### extends 关键字

```dart
class Animal {
  String name;
  
  Animal(this.name);
  
  void speak() {
    print('$name makes a sound');
  }
}

class Dog extends Animal {
  String breed;
  
  // 调用父类构造函数
  Dog(String name, this.breed) : super(name);
  
  // 重写方法
  @override
  void speak() {
    print('$name barks!');
  }
  
  // 新方法
  void fetch() {
    print('$name fetches the ball');
  }
}

var dog = Dog('Buddy', 'Labrador');
dog.speak();  // Buddy barks!
dog.fetch();  // Buddy fetches the ball
```

### super 关键字

```dart
class Cat extends Animal {
  Cat(String name) : super(name);
  
  @override
  void speak() {
    super.speak();  // 调用父类方法
    print('$name also meows!');
  }
}

var cat = Cat('Whiskers');
cat.speak();
// Whiskers makes a sound
// Whiskers also meows!
```

### 抽象类

```dart
// 不能实例化
abstract class Shape {
  // 抽象方法（无实现）
  double get area;
  double get perimeter;
  
  // 具体方法
  void describe() {
    print('面积: $area, 周长: $perimeter');
  }
}

class Circle extends Shape {
  final double radius;
  
  Circle(this.radius);
  
  @override
  double get area => 3.14159 * radius * radius;
  
  @override
  double get perimeter => 2 * 3.14159 * radius;
}

class Rectangle extends Shape {
  final double width;
  final double height;
  
  Rectangle(this.width, this.height);
  
  @override
  double get area => width * height;
  
  @override
  double get perimeter => 2 * (width + height);
}
```

## 接口

Dart 中每个类都隐式定义了一个接口。

```dart
// 定义接口（通过抽象类）
abstract class Printable {
  void printContent();
}

abstract class Savable {
  void save();
}

// 实现多个接口
class Document implements Printable, Savable {
  String content;
  
  Document(this.content);
  
  @override
  void printContent() {
    print('打印: $content');
  }
  
  @override
  void save() {
    print('保存: $content');
  }
}

// 类型检查
void processItem(Printable item) {
  item.printContent();
}
```

## Mixin

Mixin 是一种在多个类层次结构中复用代码的方式。

```dart
// 定义 mixin
mixin Flyable {
  void fly() {
    print('Flying!');
  }
}

mixin Swimmable {
  void swim() {
    print('Swimming!');
  }
}

// 使用 mixin
class Duck extends Animal with Flyable, Swimmable {
  Duck(String name) : super(name);
}

var duck = Duck('Donald');
duck.speak();  // Donald makes a sound
duck.fly();    // Flying!
duck.swim();   // Swimming!

// mixin 限制
mixin Musical on Animal {
  // 只能用于 Animal 的子类
  void sing() {
    print('$name is singing!');
  }
}
```

## 扩展方法

```dart
// 为现有类添加功能
extension StringExtension on String {
  String get reversed => split('').reversed.join('');
  
  bool get isEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// 使用
print('hello'.reversed);           // olleh
print('test@email.com'.isEmail);   // true
print('很长的文本...'.truncate(5)); // 很长的文本...
```

## 枚举

### 基本枚举

```dart
enum Status {
  pending,
  approved,
  rejected,
}

var status = Status.pending;

switch (status) {
  case Status.pending:
    print('等待处理');
    break;
  case Status.approved:
    print('已批准');
    break;
  case Status.rejected:
    print('已拒绝');
    break;
}

print(Status.values);  // [Status.pending, Status.approved, Status.rejected]
print(status.index);   // 0
print(status.name);    // pending
```

### 增强枚举（Dart 2.17+）

```dart
enum Planet {
  mercury(3.303e+23, 2.4397e6),
  venus(4.869e+24, 6.0518e6),
  earth(5.976e+24, 6.37814e6);
  
  // 属性
  final double mass;
  final double radius;
  
  // 构造函数
  const Planet(this.mass, this.radius);
  
  // getter
  double get surfaceGravity {
    const G = 6.67430e-11;
    return G * mass / (radius * radius);
  }
}

print(Planet.earth.surfaceGravity);  // 9.8...
```

## 泛型类

```dart
// 泛型类
class Box<T> {
  T value;
  
  Box(this.value);
  
  T get content => value;
}

var intBox = Box<int>(42);
var stringBox = Box<String>('Hello');

// 泛型约束
class NumberBox<T extends num> {
  T value;
  
  NumberBox(this.value);
  
  T add(T other) => (value + other) as T;
}

var numBox = NumberBox<double>(3.14);
// var strBox = NumberBox<String>('');  // ❌ 编译错误
```

## 实践练习

```dart
void main() {
  // 练习：设计一个简单的购物车系统
  var cart = ShoppingCart();
  
  cart.addItem(Product('苹果', 5.0), 3);
  cart.addItem(Product('香蕉', 3.0), 2);
  
  cart.printReceipt();
  print('总计: ¥${cart.total}');
}

class Product {
  final String name;
  final double price;
  
  const Product(this.name, this.price);
}

class CartItem {
  final Product product;
  int quantity;
  
  CartItem(this.product, this.quantity);
  
  double get subtotal => product.price * quantity;
}

class ShoppingCart {
  final List<CartItem> _items = [];
  
  void addItem(Product product, int quantity) {
    var existing = _items.where((item) => item.product.name == product.name);
    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      _items.add(CartItem(product, quantity));
    }
  }
  
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);
  
  void printReceipt() {
    print('=== 购物清单 ===');
    for (var item in _items) {
      print('${item.product.name} x${item.quantity} = ¥${item.subtotal}');
    }
  }
}
```

## 下一步

掌握类与对象后，下一章我们将学习 [异步编程](./05-async)，了解 Future 和 Stream。
