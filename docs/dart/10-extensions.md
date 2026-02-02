# 扩展方法与扩展类型

扩展方法（Extension Methods）允许你为现有类型添加新功能，而无需修改原类或创建子类。这是 Dart 2.7 引入的强大特性。

## 为什么需要扩展方法？

### 传统方式的问题

```dart
// 问题：想给 String 添加一个方法

// 方式 1：工具类（不够优雅）
class StringUtils {
  static bool isEmail(String value) {
    return value.contains('@');
  }
}
// 使用：StringUtils.isEmail(email)

// 方式 2：继承（String 是 final 类，无法继承）
// class MyString extends String {}  // ❌ 错误

// 方式 3：包装类（太繁琐）
class StringWrapper {
  final String value;
  StringWrapper(this.value);
  
  bool get isEmail => value.contains('@');
}
```

### 扩展方法的解决方案

```dart
extension StringExtension on String {
  bool get isEmail => contains('@') && contains('.');
}

// 使用：像调用原生方法一样自然
var email = 'test@example.com';
print(email.isEmail);  // true
```

## 基本语法

### 定义扩展

```dart
// 基本语法
extension ExtensionName on TargetType {
  // 方法、getter、setter、操作符
}

// 示例
extension IntExtension on int {
  // 实例方法
  int times(int n) => this * n;
  
  // getter
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
  
  // 方法
  int squared() => this * this;
  
  // 带参数的方法
  bool between(int min, int max) => this >= min && this <= max;
}

// 使用
print(5.times(3));      // 15
print(4.isEven);        // true
print(3.squared());     // 9
print(5.between(1, 10)); // true
```

### 匿名扩展

```dart
// 不需要名称时可以省略
extension on String {
  String get reversed => split('').reversed.join('');
}

// 但匿名扩展无法被显式导入或解决冲突
```

### 扩展操作符

```dart
extension NumListExtension on List<num> {
  // 操作符重载
  List<num> operator +(List<num> other) {
    return [...this, ...other];
  }
  
  num operator [](int index) {
    if (index < 0) {
      return this[length + index];  // 支持负索引
    }
    return this[index];
  }
}

var list = [1, 2, 3];
print(list[-1]);  // 3（最后一个元素）
```

## 实用扩展示例

### String 扩展

```dart
extension StringExtensions on String {
  // 空白检查
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => !isBlank;
  
  // 邮箱验证
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  // 手机号验证（中国）
  bool get isValidPhone {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }
  
  // 首字母大写
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  // 每个单词首字母大写
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }
  
  // 截断
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
  
  // 移除所有空白
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');
  
  // 转换为 int
  int? toIntOrNull() => int.tryParse(this);
  int toInt() => int.parse(this);
  
  // 转换为 double
  double? toDoubleOrNull() => double.tryParse(this);
  double toDouble() => double.parse(this);
  
  // 重复
  String repeat(int times, {String separator = ''}) {
    return List.filled(times, this).join(separator);
  }
}

// 使用
print('  '.isBlank);                    // true
print('test@example.com'.isValidEmail); // true
print('hello world'.titleCase);         // Hello World
print('Hello World'.truncate(8));       // Hello...
print('42'.toIntOrNull());              // 42
```

### List 扩展

```dart
extension ListExtensions<T> on List<T> {
  // 安全获取元素
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  // 获取随机元素
  T? get randomElement {
    if (isEmpty) return null;
    return this[Random().nextInt(length)];
  }
  
  // 分块
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, min(i + size, length)));
    }
    return chunks;
  }
  
  // 去重（保持顺序）
  List<T> get distinct {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }
  
  // 分组
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }
  
  // 交错合并
  List<T> interleave(List<T> other) {
    final result = <T>[];
    final maxLength = max(length, other.length);
    for (var i = 0; i < maxLength; i++) {
      if (i < length) result.add(this[i]);
      if (i < other.length) result.add(other[i]);
    }
    return result;
  }
  
  // 排序的复制
  List<T> sortedBy<K extends Comparable>(K Function(T) keySelector) {
    return [...this]..sort((a, b) => keySelector(a).compareTo(keySelector(b)));
  }
  
  // 倒序排序
  List<T> sortedByDescending<K extends Comparable>(K Function(T) keySelector) {
    return [...this]..sort((a, b) => keySelector(b).compareTo(keySelector(a)));
  }
}

// 使用
var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
print(list.chunked(3));       // [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]]
print(list.randomElement);    // 随机元素

var users = [User('Alice', 25), User('Bob', 30), User('Alice', 28)];
var grouped = users.groupBy((u) => u.name);
// {Alice: [User(Alice, 25), User(Alice, 28)], Bob: [User(Bob, 30)]}
```

### Map 扩展

```dart
extension MapExtensions<K, V> on Map<K, V> {
  // 安全获取
  V? getOrNull(K key) => this[key];
  
  // 获取或默认值
  V getOrDefault(K key, V defaultValue) => this[key] ?? defaultValue;
  
  // 获取或计算
  V getOrPut(K key, V Function() ifAbsent) {
    if (containsKey(key)) return this[key] as V;
    final value = ifAbsent();
    this[key] = value;
    return value;
  }
  
  // 过滤
  Map<K, V> whereKey(bool Function(K) test) {
    return Map.fromEntries(entries.where((e) => test(e.key)));
  }
  
  Map<K, V> whereValue(bool Function(V) test) {
    return Map.fromEntries(entries.where((e) => test(e.value)));
  }
  
  // 转换键
  Map<K2, V> mapKeys<K2>(K2 Function(K) transform) {
    return map((key, value) => MapEntry(transform(key), value));
  }
  
  // 转换值
  Map<K, V2> mapValues<V2>(V2 Function(V) transform) {
    return map((key, value) => MapEntry(key, transform(value)));
  }
  
  // 合并
  Map<K, V> merge(Map<K, V> other, {V Function(V, V)? onConflict}) {
    final result = Map<K, V>.from(this);
    for (final entry in other.entries) {
      if (result.containsKey(entry.key) && onConflict != null) {
        result[entry.key] = onConflict(result[entry.key] as V, entry.value);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

// 使用
var map = {'a': 1, 'b': 2, 'c': 3};
print(map.getOrDefault('d', 0));  // 0
print(map.whereValue((v) => v > 1));  // {b: 2, c: 3}
```

### DateTime 扩展

```dart
extension DateTimeExtensions on DateTime {
  // 格式化
  String format([String pattern = 'yyyy-MM-dd']) {
    return pattern
        .replaceAll('yyyy', year.toString().padLeft(4, '0'))
        .replaceAll('MM', month.toString().padLeft(2, '0'))
        .replaceAll('dd', day.toString().padLeft(2, '0'))
        .replaceAll('HH', hour.toString().padLeft(2, '0'))
        .replaceAll('mm', minute.toString().padLeft(2, '0'))
        .replaceAll('ss', second.toString().padLeft(2, '0'));
  }
  
  // 相对时间
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}年前';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  // 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  // 是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }
  
  // 开始时间（00:00:00）
  DateTime get startOfDay => DateTime(year, month, day);
  
  // 结束时间（23:59:59）
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
  
  // 添加工作日
  DateTime addBusinessDays(int days) {
    var result = this;
    var addedDays = 0;
    while (addedDays < days) {
      result = result.add(Duration(days: 1));
      if (result.weekday != DateTime.saturday && 
          result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }
    return result;
  }
}

// 使用
var now = DateTime.now();
print(now.format('yyyy/MM/dd HH:mm'));  // 2024/01/15 14:30
print(now.isToday);                      // true
print(DateTime(2024, 1, 1).timeAgo);     // 14天前
```

### num 扩展

```dart
extension NumExtensions on num {
  // 转换为货币格式
  String toCurrency({String symbol = '¥', int decimals = 2}) {
    return '$symbol${toStringAsFixed(decimals)}';
  }
  
  // 转换为百分比
  String toPercent({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }
  
  // 范围限制
  num clamp(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
  
  // 是否在范围内
  bool between(num min, num max) => this >= min && this <= max;
  
  // 延迟（Duration）
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());
}

// 使用
print(1234.56.toCurrency());     // ¥1234.56
print(0.856.toPercent());        // 86%
print(150.clamp(0, 100));        // 100
await Future.delayed(2.seconds); // 延迟 2 秒
```

## 泛型扩展

```dart
// 为可空类型添加扩展
extension NullableExtension<T> on T? {
  // 如果为 null，执行回调
  T orElse(T Function() fallback) {
    return this ?? fallback();
  }
  
  // 转换或返回 null
  R? mapOrNull<R>(R Function(T) transform) {
    if (this == null) return null;
    return transform(this as T);
  }
  
  // 如果不为 null，执行操作
  void ifNotNull(void Function(T) action) {
    if (this != null) action(this as T);
  }
}

// 使用
String? name;
print(name.orElse(() => 'Anonymous'));  // Anonymous
name?.ifNotNull((n) => print('Hello, $n'));

// 为 Iterable 添加扩展
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
```

## 扩展类型（Dart 3.3+）

扩展类型是 Dart 3.3 引入的新特性，提供零成本的类型包装：

```dart
// 扩展类型定义
extension type UserId(int id) {
  // 可以添加方法
  bool get isValid => id > 0;
  
  // 可以添加构造函数
  UserId.generate() : id = Random().nextInt(1000000);
}

extension type Email(String value) {
  bool get isValid => value.contains('@');
  String get domain => value.split('@').last;
}

// 使用
void processUser(UserId userId) {
  print('Processing user: ${userId.id}');
}

var userId = UserId(42);
processUser(userId);

// var wrongId = 42;
// processUser(wrongId);  // ❌ 类型不匹配
```

### 扩展类型 vs 普通类

```dart
// 普通类（有运行时开销）
class Meters {
  final double value;
  Meters(this.value);
}

// 扩展类型（零开销，编译时擦除）
extension type Meters(double value) {
  Meters operator +(Meters other) => Meters(value + other.value);
  Meters operator *(double factor) => Meters(value * factor);
  
  double toKilometers() => value / 1000;
}

// 编译后，Meters 就是 double，没有包装对象
var distance = Meters(100);  // 编译时是类型安全的
// 运行时就是 double，没有额外开销
```

### 实际应用

```dart
// 类型安全的 ID
extension type ProductId(String value) implements String {
  // 实现 String 接口，可以当 String 用
}

extension type OrderId(String value) implements String {}

void processProduct(ProductId id) {
  // 只接受 ProductId
}

void processOrder(OrderId id) {
  // 只接受 OrderId
}

var productId = ProductId('prod_123');
var orderId = OrderId('order_456');

processProduct(productId);  // ✅
// processProduct(orderId);  // ❌ 编译错误

// 但可以当 String 用
print(productId.length);  // ✅
```

## 导入和冲突解决

### 导入扩展

```dart
// 文件: string_extensions.dart
extension StringExtension on String {
  String get reversed => split('').reversed.join('');
}

// 使用
import 'string_extensions.dart';

print('hello'.reversed);  // olleh
```

### 解决冲突

```dart
// 两个库都定义了同名扩展
import 'lib1.dart' as lib1;
import 'lib2.dart' as lib2;

void main() {
  var text = 'hello';
  
  // 显式使用特定扩展
  lib1.StringExtension(text).reversed;
  lib2.StringExtension(text).reversed;
  
  // 或者隐藏一个
  // import 'lib1.dart' hide StringExtension;
}
```

### 条件导入

```dart
// 只导入需要的扩展
import 'extensions.dart' show StringExtension;

// 排除某些扩展
import 'extensions.dart' hide ListExtension;
```

## 最佳实践

### 1. 命名要有意义

```dart
// ❌ 不清晰
extension E on String {}

// ✅ 清晰
extension StringValidation on String {}
extension StringFormatting on String {}
```

### 2. 按功能分组

```dart
// 验证相关
extension StringValidation on String {
  bool get isValidEmail => ...;
  bool get isValidPhone => ...;
}

// 格式化相关
extension StringFormatting on String {
  String get capitalized => ...;
  String truncate(int length) => ...;
}
```

### 3. 不要过度使用

```dart
// ❌ 不合适：复杂的业务逻辑
extension on User {
  Future<void> sendNotification() => ...;  // 应该在服务类中
}

// ✅ 合适：简单的转换和工具方法
extension on User {
  String get displayName => '$firstName $lastName';
}
```

### 4. 考虑可空类型

```dart
// 为可空类型提供便捷方法
extension NullableString on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}

String? name;
if (name.isNullOrBlank) {
  print('Please enter a name');
}
```

## 下一步

扩展方法让代码更加优雅和可读。下一章我们将学习 [Mixin 与继承](./11-mixins)，深入理解 Dart 的代码复用机制。
