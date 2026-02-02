# 集合类型详解

Dart 提供了三种核心集合类型：List（列表）、Set（集合）和 Map（映射）。本章将深入讲解它们的使用方法和最佳实践。

## List（列表）

List 是有序的元素集合，类似于 JavaScript 的 Array。

### 创建 List

```dart
// 字面量创建（最常用）
var numbers = [1, 2, 3, 4, 5];
var names = <String>['Alice', 'Bob', 'Charlie'];  // 显式指定类型

// 空列表
var emptyList = <int>[];
List<String> emptyStrings = [];

// 构造函数创建
var list1 = List<int>.filled(5, 0);      // [0, 0, 0, 0, 0]
var list2 = List<int>.generate(5, (i) => i * 2);  // [0, 2, 4, 6, 8]

// 从其他可迭代对象创建
var fromSet = List<int>.from({1, 2, 3});
var fromIterable = List<int>.of([1, 2, 3]);

// 不可变列表
var constList = const [1, 2, 3];
var unmodifiable = List.unmodifiable([1, 2, 3]);
```

### 访问元素

```dart
var fruits = ['apple', 'banana', 'cherry', 'date'];

// 索引访问（从 0 开始）
print(fruits[0]);    // apple
print(fruits[2]);    // cherry

// 负索引不支持！需要用 length
print(fruits[fruits.length - 1]);  // date

// first 和 last
print(fruits.first);  // apple
print(fruits.last);   // date

// 安全访问（避免越界）
print(fruits.elementAtOrNull(10));  // null（Dart 3.0+）

// 获取子列表
print(fruits.sublist(1, 3));  // [banana, cherry]
print(fruits.sublist(2));     // [cherry, date]
```

### 修改 List

```dart
var list = [1, 2, 3];

// 添加元素
list.add(4);                // [1, 2, 3, 4]
list.addAll([5, 6]);        // [1, 2, 3, 4, 5, 6]
list.insert(0, 0);          // [0, 1, 2, 3, 4, 5, 6]
list.insertAll(2, [10, 11]); // [0, 1, 10, 11, 2, 3, 4, 5, 6]

// 删除元素
list.remove(10);            // 删除第一个匹配的元素
list.removeAt(0);           // 删除索引位置的元素
list.removeLast();          // 删除最后一个元素
list.removeWhere((e) => e > 3);  // 删除满足条件的元素
list.removeRange(1, 3);     // 删除范围内的元素
list.clear();               // 清空列表

// 修改元素
var nums = [1, 2, 3, 4, 5];
nums[0] = 10;               // [10, 2, 3, 4, 5]
nums.replaceRange(1, 3, [20, 30, 40]);  // [10, 20, 30, 40, 4, 5]
nums.fillRange(0, 2, 0);    // [0, 0, 30, 40, 4, 5]
```

### 排序和查找

```dart
var numbers = [5, 2, 8, 1, 9];

// 排序
numbers.sort();                          // [1, 2, 5, 8, 9]
numbers.sort((a, b) => b.compareTo(a));  // [9, 8, 5, 2, 1] 降序

// 自定义对象排序
var users = [
  User('Alice', 25),
  User('Bob', 30),
  User('Charlie', 20),
];
users.sort((a, b) => a.age.compareTo(b.age));

// 查找
var list = [1, 2, 3, 4, 5, 3];
print(list.indexOf(3));         // 2（第一个匹配的索引）
print(list.lastIndexOf(3));     // 5（最后一个匹配的索引）
print(list.indexWhere((e) => e > 3));  // 3
print(list.contains(3));        // true

// 二分查找（需要已排序）
var sorted = [1, 2, 3, 4, 5];
print(binarySearch(sorted, 3)); // 需要导入 package:collection
```

### 遍历和转换

```dart
var numbers = [1, 2, 3, 4, 5];

// for 循环
for (var i = 0; i < numbers.length; i++) {
  print(numbers[i]);
}

// for-in 循环
for (var num in numbers) {
  print(num);
}

// forEach
numbers.forEach((num) => print(num));

// map - 转换每个元素
var doubled = numbers.map((n) => n * 2).toList();  // [2, 4, 6, 8, 10]

// where - 过滤
var evens = numbers.where((n) => n % 2 == 0).toList();  // [2, 4]

// expand - 展开（flatMap）
var nested = [[1, 2], [3, 4]];
var flat = nested.expand((list) => list).toList();  // [1, 2, 3, 4]

// reduce - 归约
var sum = numbers.reduce((a, b) => a + b);  // 15

// fold - 带初始值的归约
var product = numbers.fold(1, (acc, n) => acc * n);  // 120

// every 和 any
print(numbers.every((n) => n > 0));   // true（所有都满足）
print(numbers.any((n) => n > 4));     // true（至少一个满足）

// take 和 skip
print(numbers.take(3).toList());      // [1, 2, 3]
print(numbers.skip(2).toList());      // [3, 4, 5]
print(numbers.takeWhile((n) => n < 4).toList());  // [1, 2, 3]
```

### 展开运算符

```dart
var list1 = [1, 2, 3];
var list2 = [4, 5, 6];

// 合并列表
var combined = [...list1, ...list2];  // [1, 2, 3, 4, 5, 6]

// 条件展开
var includeExtra = true;
var result = [
  ...list1,
  if (includeExtra) ...[7, 8, 9],
];

// 空安全展开
List<int>? maybeNull;
var safe = [...?maybeNull, 1, 2, 3];  // [1, 2, 3]

// 集合推导
var squares = [for (var i = 1; i <= 5; i++) i * i];  // [1, 4, 9, 16, 25]

// 条件推导
var evenSquares = [
  for (var i = 1; i <= 10; i++)
    if (i % 2 == 0) i * i,
];  // [4, 16, 36, 64, 100]
```

## Set（集合）

Set 是无序且元素唯一的集合。

### 创建 Set

```dart
// 字面量创建
var numbers = {1, 2, 3, 4, 5};
var names = <String>{'Alice', 'Bob', 'Charlie'};

// 空 Set（注意：{} 是 Map，不是 Set）
var emptySet = <int>{};
Set<String> emptyStrings = {};

// 构造函数
var fromList = Set<int>.from([1, 2, 2, 3, 3]);  // {1, 2, 3}
var identity = Set<int>.identity();  // 使用 identical 比较

// 不可变 Set
var constSet = const {1, 2, 3};
```

### 基本操作

```dart
var set = {1, 2, 3};

// 添加
set.add(4);           // {1, 2, 3, 4}
set.addAll([5, 6]);   // {1, 2, 3, 4, 5, 6}

// 删除
set.remove(1);                      // {2, 3, 4, 5, 6}
set.removeWhere((e) => e > 4);      // {2, 3, 4}
set.removeAll([2, 3]);              // {4}
set.retainWhere((e) => e % 2 == 0); // 只保留满足条件的
set.retainAll([4]);                 // 只保留指定的
set.clear();

// 查找
print(set.contains(1));         // true
print(set.containsAll([1, 2])); // true
print(set.lookup(1));           // 1（返回集合中的元素）
```

### 集合运算

```dart
var a = {1, 2, 3, 4};
var b = {3, 4, 5, 6};

// 并集
print(a.union(b));        // {1, 2, 3, 4, 5, 6}

// 交集
print(a.intersection(b)); // {3, 4}

// 差集
print(a.difference(b));   // {1, 2}（a 中有但 b 中没有的）
print(b.difference(a));   // {5, 6}
```

### 实际应用场景

```dart
// 去重
var listWithDuplicates = [1, 2, 2, 3, 3, 3];
var unique = listWithDuplicates.toSet().toList();  // [1, 2, 3]

// 检查是否有重复
bool hasDuplicates(List<int> list) {
  return list.length != list.toSet().length;
}

// 快速成员检查（比 List 快）
var validCodes = {'A', 'B', 'C', 'D'};
bool isValid(String code) => validCodes.contains(code);

// 标签系统
class Article {
  final Set<String> tags;
  
  Article(this.tags);
  
  bool hasTag(String tag) => tags.contains(tag);
  bool hasAnyTag(Set<String> searchTags) => 
      tags.intersection(searchTags).isNotEmpty;
}
```

## Map（映射）

Map 是键值对集合，类似于 JavaScript 的 Object 或 Map。

### 创建 Map

```dart
// 字面量创建
var user = {
  'name': 'Alice',
  'age': 25,
  'email': 'alice@example.com',
};

// 指定类型
var scores = <String, int>{
  'math': 90,
  'english': 85,
};

// 空 Map
var emptyMap = <String, int>{};
Map<String, dynamic> empty = {};

// 构造函数
var map1 = Map<String, int>();
var map2 = Map.fromIterables(
  ['a', 'b', 'c'],
  [1, 2, 3],
);  // {a: 1, b: 2, c: 3}

var map3 = Map.fromEntries([
  MapEntry('a', 1),
  MapEntry('b', 2),
]);

// 从列表创建
var list = ['a', 'b', 'c'];
var indexed = list.asMap();  // {0: a, 1: b, 2: c}

// 不可变 Map
var constMap = const {'key': 'value'};
```

### 访问和修改

```dart
var map = {'name': 'Alice', 'age': 25};

// 访问
print(map['name']);        // Alice
print(map['unknown']);     // null

// 安全访问（带默认值）
print(map['unknown'] ?? 'default');

// 检查键是否存在
print(map.containsKey('name'));    // true
print(map.containsValue(25));      // true

// 添加/修改
map['email'] = 'alice@example.com';
map.addAll({'city': 'Beijing', 'country': 'China'});

// putIfAbsent - 不存在时才添加
map.putIfAbsent('name', () => 'Default');  // 已存在，不添加
map.putIfAbsent('phone', () => '123456');  // 不存在，添加

// update - 更新值
map.update('age', (value) => value + 1);
map.update('height', (value) => value, ifAbsent: () => 170);

// 删除
map.remove('email');
map.removeWhere((key, value) => key.startsWith('c'));
map.clear();
```

### 遍历 Map

```dart
var map = {'a': 1, 'b': 2, 'c': 3};

// forEach
map.forEach((key, value) {
  print('$key: $value');
});

// for-in 遍历 entries
for (var entry in map.entries) {
  print('${entry.key}: ${entry.value}');
}

// 遍历键
for (var key in map.keys) {
  print(key);
}

// 遍历值
for (var value in map.values) {
  print(value);
}

// map 转换
var doubled = map.map((key, value) => MapEntry(key, value * 2));
// {a: 2, b: 4, c: 6}
```

### Map 操作技巧

```dart
// 合并 Map
var map1 = {'a': 1, 'b': 2};
var map2 = {'b': 3, 'c': 4};

// 使用展开运算符（后面的覆盖前面的）
var merged = {...map1, ...map2};  // {a: 1, b: 3, c: 4}

// 使用 addAll（修改原 Map）
map1.addAll(map2);

// 条件添加
var result = {
  'name': 'Alice',
  if (includeAge) 'age': 25,
  for (var item in items) item.key: item.value,
};

// 转换为 List
var entries = map.entries.toList();
var keys = map.keys.toList();
var values = map.values.toList();

// 根据值查找键
var reverseLookup = map.entries
    .firstWhere((e) => e.value == 2)
    .key;  // 'b'
```

### 嵌套结构

```dart
// 复杂嵌套结构
var company = {
  'name': 'TechCorp',
  'departments': [
    {
      'name': 'Engineering',
      'employees': [
        {'name': 'Alice', 'role': 'Developer'},
        {'name': 'Bob', 'role': 'Designer'},
      ],
    },
    {
      'name': 'Marketing',
      'employees': [
        {'name': 'Charlie', 'role': 'Manager'},
      ],
    },
  ],
};

// 安全访问嵌套数据
String? getFirstEmployeeName(Map<String, dynamic> data) {
  final departments = data['departments'] as List?;
  if (departments == null || departments.isEmpty) return null;
  
  final firstDept = departments[0] as Map<String, dynamic>?;
  if (firstDept == null) return null;
  
  final employees = firstDept['employees'] as List?;
  if (employees == null || employees.isEmpty) return null;
  
  final firstEmployee = employees[0] as Map<String, dynamic>?;
  return firstEmployee?['name'] as String?;
}
```

## 集合实用技巧

### 链式操作

```dart
var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

var result = numbers
    .where((n) => n % 2 == 0)     // 过滤偶数
    .map((n) => n * n)             // 平方
    .take(3)                       // 取前 3 个
    .toList();                     // 转为 List

print(result);  // [4, 16, 36]
```

### 分组

```dart
// 按条件分组
var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// 手动分组
var grouped = <String, List<int>>{};
for (var n in numbers) {
  var key = n % 2 == 0 ? 'even' : 'odd';
  (grouped[key] ??= []).add(n);
}
// {odd: [1, 3, 5, 7, 9], even: [2, 4, 6, 8, 10]}

// 使用 collection 包的 groupBy
// import 'package:collection/collection.dart';
// var grouped = groupBy(numbers, (n) => n % 2 == 0 ? 'even' : 'odd');
```

### 去重保持顺序

```dart
List<T> removeDuplicates<T>(List<T> list) {
  return list.fold<List<T>>([], (result, item) {
    if (!result.contains(item)) {
      result.add(item);
    }
    return result;
  });
}

// 或使用 LinkedHashSet
var unique = LinkedHashSet<int>.from([1, 2, 2, 3, 3, 3]).toList();
```

### 性能对比

| 操作 | List | Set | Map |
|------|------|-----|-----|
| 添加元素 | O(1)* | O(1) | O(1) |
| 查找元素 | O(n) | O(1) | O(1) |
| 删除元素 | O(n) | O(1) | O(1) |
| 索引访问 | O(1) | - | O(1) |

> * List 末尾添加是 O(1)，中间插入是 O(n)

### 选择建议

| 需求 | 推荐类型 |
|------|---------|
| 有序、可重复 | List |
| 无序、唯一 | Set |
| 键值对存储 | Map |
| 需要索引访问 | List |
| 频繁查找 | Set 或 Map |
| 需要去重 | Set |

## 下一步

掌握集合类型后，下一章我们将学习 [空安全](./07-null-safety)，这是 Dart 2.12 引入的重要特性。
