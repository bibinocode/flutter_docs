# Mixin 与继承详解

Dart 支持单继承，但通过 Mixin 可以实现代码的多重复用。本章将深入讲解 Dart 的继承体系和 Mixin 机制。

## 类的继承

### 基本继承

```dart
class Animal {
  String name;
  
  Animal(this.name);
  
  void eat() {
    print('$name is eating');
  }
  
  void sleep() {
    print('$name is sleeping');
  }
}

class Dog extends Animal {
  String breed;
  
  // 调用父类构造函数
  Dog(String name, this.breed) : super(name);
  
  // 覆盖父类方法
  @override
  void eat() {
    print('$name is eating dog food');
  }
  
  // 子类特有方法
  void bark() {
    print('$name says: Woof!');
  }
}

var dog = Dog('Buddy', 'Golden Retriever');
dog.eat();    // Buddy is eating dog food
dog.sleep();  // Buddy is sleeping（继承的方法）
dog.bark();   // Buddy says: Woof!
```

### super 关键字

```dart
class Parent {
  String name;
  
  Parent(this.name);
  
  void greet() {
    print('Hello from $name');
  }
}

class Child extends Parent {
  int age;
  
  // 调用父类构造函数
  Child(String name, this.age) : super(name);
  
  // 命名构造函数
  Child.baby(String name) : age = 0, super(name);
  
  @override
  void greet() {
    super.greet();  // 调用父类方法
    print('I am $age years old');
  }
}
```

### 构造函数继承

```dart
class Vehicle {
  String brand;
  int year;
  
  Vehicle(this.brand, this.year);
  Vehicle.modern(this.brand) : year = DateTime.now().year;
}

class Car extends Vehicle {
  int doors;
  
  // 方式 1：显式调用父类构造函数
  Car(String brand, int year, this.doors) : super(brand, year);
  
  // 方式 2：调用父类命名构造函数
  Car.modern(String brand, this.doors) : super.modern(brand);
  
  // 方式 3：初始化列表 + super
  Car.withDefaults(String brand)
      : doors = 4,
        super(brand, 2024);
}
```

### 抽象类

```dart
abstract class Shape {
  // 抽象方法（子类必须实现）
  double get area;
  double get perimeter;
  
  // 普通方法（子类可以继承）
  void describe() {
    print('Area: $area, Perimeter: $perimeter');
  }
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

class Circle extends Shape {
  final double radius;
  
  Circle(this.radius);
  
  @override
  double get area => 3.14159 * radius * radius;
  
  @override
  double get perimeter => 2 * 3.14159 * radius;
}
```

## Mixin 基础

### 什么是 Mixin？

Mixin 是一种在多个类之间共享代码的方式，无需使用继承。

```dart
// 定义 Mixin
mixin Flyable {
  void fly() {
    print('Flying...');
  }
}

mixin Swimmable {
  void swim() {
    print('Swimming...');
  }
}

// 使用 Mixin
class Duck extends Animal with Flyable, Swimmable {
  Duck(String name) : super(name);
}

var duck = Duck('Donald');
duck.fly();   // Flying...
duck.swim();  // Swimming...
duck.eat();   // Donald is eating（来自 Animal）
```

### Mixin vs 继承 vs 接口

```dart
// 继承：is-a 关系（Dog is an Animal）
class Dog extends Animal {}

// 接口：can-do 约定（必须实现所有方法）
abstract interface class Comparable<T> {
  int compareTo(T other);
}

// Mixin：has-ability 能力复用（获得某种能力的实现）
mixin Flyable {
  void fly() => print('Flying');
}

class Bird extends Animal with Flyable {}
```

### Mixin 的限制

```dart
// Mixin 不能有构造函数
mixin MyMixin {
  // MyMixin() {}  // ❌ 错误
  
  // 但可以有普通方法和属性
  int value = 0;
  void doSomething() {}
}

// Mixin 可以有抽象成员
mixin Logger {
  // 使用此 Mixin 的类必须提供这个
  String get logPrefix;
  
  void log(String message) {
    print('[$logPrefix] $message');
  }
}

class MyService with Logger {
  @override
  String get logPrefix => 'MyService';
  
  void doWork() {
    log('Starting work...');  // [MyService] Starting work...
  }
}
```

## Mixin 高级用法

### on 关键字约束

```dart
// Mixin 只能用于特定类型
mixin Musician on Person {
  void playMusic() {
    print('$name is playing music');  // 可以访问 Person 的属性
  }
}

class Person {
  String name;
  Person(this.name);
}

class Artist extends Person with Musician {
  Artist(String name) : super(name);
}

// class Robot with Musician {}  // ❌ 错误：Robot 不是 Person
```

### Mixin 组合

```dart
mixin Walking {
  void walk() => print('Walking');
}

mixin Running {
  void run() => print('Running');
}

mixin Jumping {
  void jump() => print('Jumping');
}

// 组合多个 Mixin
class Athlete with Walking, Running, Jumping {
  void warmUp() {
    walk();
    run();
    jump();
  }
}
```

### Mixin 顺序（线性化）

```dart
mixin A {
  void greet() => print('A');
}

mixin B {
  void greet() => print('B');
}

mixin C {
  void greet() => print('C');
}

// Mixin 从右到左应用，最右边的优先级最高
class MyClass with A, B, C {}

var obj = MyClass();
obj.greet();  // C（最后一个 Mixin）

// 如果要调用链中的下一个
mixin D {
  void greet() {
    super.greet();  // 调用链中的下一个
    print('D');
  }
}

class MyClass2 with A, B, D {}
var obj2 = MyClass2();
obj2.greet();
// 输出：
// B（super.greet() 调用了 B）
// D
```

### 实际应用示例

```dart
// 日志功能
mixin Loggable {
  void log(String message) {
    print('[${DateTime.now()}] $message');
  }
  
  void logError(String message) {
    print('[ERROR] $message');
  }
}

// 缓存功能
mixin Cacheable<K, V> {
  final Map<K, V> _cache = {};
  
  V? getFromCache(K key) => _cache[key];
  
  void addToCache(K key, V value) {
    _cache[key] = value;
  }
  
  void clearCache() => _cache.clear();
}

// 可观察功能
mixin Observable<T> {
  final List<void Function(T)> _listeners = [];
  
  void addListener(void Function(T) listener) {
    _listeners.add(listener);
  }
  
  void removeListener(void Function(T) listener) {
    _listeners.remove(listener);
  }
  
  void notifyListeners(T value) {
    for (final listener in _listeners) {
      listener(value);
    }
  }
}

// 组合使用
class UserRepository with Loggable, Cacheable<String, User> {
  Future<User> getUser(String id) async {
    // 先检查缓存
    var cached = getFromCache(id);
    if (cached != null) {
      log('Cache hit for user $id');
      return cached;
    }
    
    log('Fetching user $id from API');
    var user = await api.fetchUser(id);
    addToCache(id, user);
    return user;
  }
}
```

## 接口

### 隐式接口

在 Dart 中，每个类都隐式定义了一个接口：

```dart
class Printer {
  void print(String content) {
    print(content);
  }
}

// 实现 Printer 接口
class ConsolePrinter implements Printer {
  @override
  void print(String content) {
    print('Console: $content');
  }
}

// 可以实现多个接口
class MultiFunctionDevice implements Printer, Scanner, Copier {
  @override
  void print(String content) {}
  
  @override
  void scan() {}
  
  @override
  void copy() {}
}
```

### 抽象接口

```dart
// Dart 3.0+ 可以显式声明接口
abstract interface class Serializable {
  Map<String, dynamic> toJson();
  factory Serializable.fromJson(Map<String, dynamic> json);
}

// 实现接口
class User implements Serializable {
  final String name;
  User(this.name);
  
  @override
  Map<String, dynamic> toJson() => {'name': name};
  
  // 工厂构造函数实现
  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['name']);
  }
}
```

### extends vs implements vs with

```dart
class Animal {
  void breathe() => print('Breathing');
}

mixin Flyable {
  void fly() => print('Flying');
}

abstract interface class Comparable<T> {
  int compareTo(T other);
}

// extends: 继承实现
// implements: 实现接口（必须重写所有方法）
// with: 混入能力

class Bird extends Animal with Flyable implements Comparable<Bird> {
  final int size;
  Bird(this.size);
  
  @override
  int compareTo(Bird other) => size.compareTo(other.size);
}

var bird = Bird(10);
bird.breathe();  // 继承自 Animal
bird.fly();      // 混入自 Flyable
bird.compareTo(Bird(5));  // 实现了 Comparable
```

## 类修饰符（Dart 3.0+）

### base 修饰符

```dart
// base 类可以被继承，但在库外不能被实现
base class Vehicle {
  void start() => print('Starting');
}

// 同一库内
class Car extends Vehicle {}  // ✅
class MockVehicle implements Vehicle {}  // ✅

// 其他库中
// class Car extends Vehicle {}  // ✅ 可以继承
// class MockVehicle implements Vehicle {}  // ❌ 不能实现
```

### final 修饰符

```dart
// final 类不能被继承或实现
final class Config {
  final String apiUrl;
  Config(this.apiUrl);
}

// class MyConfig extends Config {}  // ❌ 错误
// class MockConfig implements Config {}  // ❌ 错误
```

### sealed 修饰符

```dart
// sealed 类只能在同一库内被继承
sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T value;
  Success(this.value);
}

class Failure<T> extends Result<T> {
  final Exception exception;
  Failure(this.exception);
}

// 使用 switch 时编译器知道所有子类
String handleResult(Result<int> result) {
  return switch (result) {
    Success(:final value) => 'Success: $value',
    Failure(:final exception) => 'Error: $exception',
  };  // 不需要 default，因为 sealed 类的子类是已知的
}
```

### interface 修饰符

```dart
// 只能被实现，不能被继承
interface class Printable {
  void print() => _defaultPrint();
  
  void _defaultPrint() {
    print('Default print');
  }
}

class Document implements Printable {
  @override
  void print() {
    // 必须自己实现，无法使用默认实现
  }
}
```

### 修饰符组合

```dart
// base mixin: 可以被混入，但不能在库外被实现
base mixin Loggable {
  void log(String message) => print(message);
}

// interface class: 只能被实现
interface class Serializable {
  Map<String, dynamic> toJson();
}

// sealed class: 密封类
sealed class State {}
final class LoadingState extends State {}
final class LoadedState extends State {}
final class ErrorState extends State {}
```

## 设计模式示例

### 模板方法模式

```dart
abstract class DataProcessor {
  // 模板方法
  void process() {
    final data = fetchData();
    final processed = transform(data);
    save(processed);
  }
  
  // 抽象方法，子类必须实现
  String fetchData();
  String transform(String data);
  void save(String data);
}

class CsvProcessor extends DataProcessor {
  @override
  String fetchData() => 'csv,data,here';
  
  @override
  String transform(String data) => data.toUpperCase();
  
  @override
  void save(String data) => print('Saving CSV: $data');
}
```

### 策略模式

```dart
mixin SortStrategy<T> {
  List<T> sort(List<T> items);
}

class QuickSort<T extends Comparable> with SortStrategy<T> {
  @override
  List<T> sort(List<T> items) {
    // 快速排序实现
    return [...items]..sort();
  }
}

class BubbleSort<T extends Comparable> with SortStrategy<T> {
  @override
  List<T> sort(List<T> items) {
    // 冒泡排序实现
    final result = [...items];
    // ...
    return result;
  }
}

class Sorter<T extends Comparable> {
  SortStrategy<T> strategy;
  
  Sorter(this.strategy);
  
  List<T> sort(List<T> items) => strategy.sort(items);
}
```

### 装饰器模式

```dart
abstract class Coffee {
  String get description;
  double get cost;
}

class SimpleCoffee implements Coffee {
  @override
  String get description => 'Simple Coffee';
  
  @override
  double get cost => 10.0;
}

mixin CoffeeDecorator on Coffee {
  Coffee get wrapped;
}

class MilkDecorator extends Coffee with CoffeeDecorator {
  @override
  final Coffee wrapped;
  
  MilkDecorator(this.wrapped);
  
  @override
  String get description => '${wrapped.description}, Milk';
  
  @override
  double get cost => wrapped.cost + 2.0;
}

class SugarDecorator extends Coffee with CoffeeDecorator {
  @override
  final Coffee wrapped;
  
  SugarDecorator(this.wrapped);
  
  @override
  String get description => '${wrapped.description}, Sugar';
  
  @override
  double get cost => wrapped.cost + 1.0;
}

// 使用
var coffee = SugarDecorator(MilkDecorator(SimpleCoffee()));
print(coffee.description);  // Simple Coffee, Milk, Sugar
print(coffee.cost);         // 13.0
```

## 最佳实践

### 1. 优先使用组合而非继承

```dart
// ❌ 过度使用继承
class Button extends Widget {}
class IconButton extends Button {}
class TextIconButton extends IconButton {}  // 继承层次太深

// ✅ 使用组合
class Button extends Widget {
  final Icon? icon;
  final String? text;
  
  Button({this.icon, this.text});
}
```

### 2. 使用 Mixin 共享行为

```dart
// ❌ 为了共享代码而继承
class LoggableService extends BaseLogger {}
class CacheableService extends BaseLogger {}  // 不能同时继承两个

// ✅ 使用 Mixin
mixin Loggable { ... }
mixin Cacheable { ... }

class MyService with Loggable, Cacheable {}
```

### 3. 合理使用类修饰符

```dart
// 不希望被继承的工具类
final class StringUtils {
  StringUtils._();
  static String capitalize(String s) => ...;
}

// 限制子类的状态类
sealed class ConnectionState {}
final class Connected extends ConnectionState {}
final class Disconnected extends ConnectionState {}
```

### 4. 保持继承层次简单

```dart
// 建议的继承深度：最多 2-3 层
// Object -> Animal -> Dog ✅
// Object -> A -> B -> C -> D -> E ❌ 太深
```

## 下一步

理解了继承和 Mixin 后，下一章我们将学习 [模式匹配](./12-patterns)，这是 Dart 3.0 引入的强大特性。
