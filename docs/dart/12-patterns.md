# 模式匹配详解

模式匹配（Pattern Matching）是 Dart 3.0 引入的重大特性，它让代码更加简洁、安全和可读。本章将全面介绍 Dart 的模式匹配系统。

## 什么是模式匹配？

模式匹配允许你检查值是否具有特定的形状，并同时提取其中的数据：

```dart
// 传统方式
var list = [1, 2, 3];
if (list.length == 2) {
  var first = list[0];
  var second = list[1];
  print('$first, $second');
}

// 模式匹配方式
var list = [1, 2, 3];
if (list case [var first, var second]) {
  print('$first, $second');  // 只有两个元素时匹配
}
```

## 模式的使用位置

### 1. 变量声明

```dart
// 解构列表
var [a, b, c] = [1, 2, 3];
print('$a, $b, $c');  // 1, 2, 3

// 解构 Map
var {'name': name, 'age': age} = {'name': 'Alice', 'age': 25};
print('$name is $age');  // Alice is 25

// 解构对象
var Point(:x, :y) = Point(3, 4);
print('x=$x, y=$y');  // x=3, y=4

// 解构记录（Record）
var (first, second, third) = (1, 2, 3);
print('$first, $second, $third');  // 1, 2, 3

// 命名字段记录
var (name: userName, age: userAge) = (name: 'Bob', age: 30);
print('$userName is $userAge');  // Bob is 30
```

### 2. 赋值

```dart
var (a, b) = (1, 2);

// 交换变量
(a, b) = (b, a);
print('$a, $b');  // 2, 1

// 从函数返回多值
(String, int) getUserInfo() => ('Alice', 25);
var (name, age) = getUserInfo();
```

### 3. switch 语句和表达式

```dart
// switch 表达式
String describe(Object obj) {
  return switch (obj) {
    int n when n < 0 => 'negative integer',
    int n => 'positive integer: $n',
    String s => 'string: $s',
    [int a, int b] => 'list of two ints: $a, $b',
    {'name': String name} => 'map with name: $name',
    _ => 'something else',
  };
}

// switch 语句
void process(Object value) {
  switch (value) {
    case int n when n > 100:
      print('Large number: $n');
    case int n:
      print('Number: $n');
    case String s:
      print('String: $s');
    default:
      print('Unknown');
  }
}
```

### 4. if-case 语句

```dart
void processJson(Map<String, dynamic> json) {
  if (json case {'user': {'name': String name, 'age': int age}}) {
    print('User: $name, Age: $age');
  } else {
    print('Invalid JSON structure');
  }
}

// 带 when 条件
if (value case int n when n > 0 && n < 100) {
  print('Value is between 1 and 99');
}
```

### 5. for 循环

```dart
var pairs = [(1, 'one'), (2, 'two'), (3, 'three')];

for (var (number, word) in pairs) {
  print('$number is $word');
}

// 解构 Map entries
var map = {'a': 1, 'b': 2, 'c': 3};
for (var MapEntry(:key, :value) in map.entries) {
  print('$key: $value');
}
```

## 模式类型

### 常量模式

```dart
String getDescription(int value) {
  return switch (value) {
    0 => 'zero',
    1 => 'one',
    2 => 'two',
    42 => 'the answer',
    _ => 'other',
  };
}

// 枚举常量
enum Status { pending, approved, rejected }

String statusText(Status status) {
  return switch (status) {
    Status.pending => '待审核',
    Status.approved => '已通过',
    Status.rejected => '已拒绝',
  };
}
```

### 变量模式

```dart
// 使用 var 推断类型
var [var first, var second] = [1, 2];

// 显式类型
var [int first, int second] = [1, 2];

// final 变量
var [final first, final second] = [1, 2];
// first = 10;  // ❌ 错误，final 不可修改
```

### 通配符模式

```dart
// _ 匹配任何值但不绑定
var [first, _, third] = [1, 2, 3];
print('$first, $third');  // 1, 3

// 忽略多个值
var [first, ..., last] = [1, 2, 3, 4, 5];
print('$first, $last');  // 1, 5

// switch 中的通配符
String describe(Object obj) {
  return switch (obj) {
    int _ => 'some integer',  // 匹配任何 int
    _ => 'something else',     // 匹配任何值
  };
}
```

### 类型检查模式

```dart
String describe(Object obj) {
  return switch (obj) {
    int() => 'integer',
    String() => 'string',
    List<int>() => 'list of integers',
    Map<String, dynamic>() => 'map',
    _ => 'unknown',
  };
}

// 结合变量绑定
void process(Object value) {
  if (value case int n) {
    print('Integer: $n');
  } else if (value case String s) {
    print('String: $s');
  }
}
```

### 列表模式

```dart
// 固定长度匹配
var [a, b, c] = [1, 2, 3];  // 必须正好 3 个元素

// 使用 rest 模式
var [first, ...rest] = [1, 2, 3, 4, 5];
print(first);  // 1
print(rest);   // [2, 3, 4, 5]

var [first, ...middle, last] = [1, 2, 3, 4, 5];
print(first);   // 1
print(middle);  // [2, 3, 4]
print(last);    // 5

// 忽略 rest
var [first, ..., last] = [1, 2, 3, 4, 5];
print('$first, $last');  // 1, 5

// 嵌套列表
var [[a, b], [c, d]] = [[1, 2], [3, 4]];
print('$a, $b, $c, $d');  // 1, 2, 3, 4
```

### Map 模式

```dart
// 基本匹配
var {'name': name, 'age': age} = {'name': 'Alice', 'age': 25};

// 部分匹配（Map 可以有额外的键）
var {'name': name} = {'name': 'Alice', 'age': 25, 'city': 'Beijing'};
print(name);  // Alice（忽略其他键）

// 嵌套 Map
var json = {
  'user': {
    'name': 'Alice',
    'profile': {
      'avatar': 'url',
    }
  }
};

if (json case {'user': {'name': String name, 'profile': {'avatar': String avatar}}}) {
  print('$name, $avatar');
}
```

### 对象模式

```dart
class Point {
  final int x;
  final int y;
  
  Point(this.x, this.y);
}

// 解构对象
var Point(:x, :y) = Point(3, 4);
print('$x, $y');  // 3, 4

// 重命名
var Point(x: px, y: py) = Point(3, 4);
print('$px, $py');  // 3, 4

// 在 switch 中使用
String describePoint(Point p) {
  return switch (p) {
    Point(x: 0, y: 0) => 'origin',
    Point(x: 0, :var y) => 'on Y axis at $y',
    Point(:var x, y: 0) => 'on X axis at $x',
    Point(:var x, :var y) => 'at ($x, $y)',
  };
}
```

### 记录模式

```dart
// 位置记录
var (a, b, c) = (1, 2, 3);

// 命名记录
var (name: n, age: a) = (name: 'Alice', age: 25);

// 混合记录
var (String name, age: int userAge) = ('Alice', age: 25);

// 从函数返回
(int, int, int) getColor() => (255, 128, 0);
var (r, g, b) = getColor();
```

### 逻辑模式

```dart
// OR 模式
String describe(int n) {
  return switch (n) {
    0 || 1 || 2 => 'small',
    3 || 4 || 5 => 'medium',
    _ => 'large',
  };
}

// AND 模式（较少使用）
void process(Object value) {
  if (value case int n && > 0) {  // 同时满足 int 和 > 0
    print('Positive integer: $n');
  }
}
```

### 关系模式

```dart
String grade(int score) {
  return switch (score) {
    >= 90 => 'A',
    >= 80 => 'B',
    >= 70 => 'C',
    >= 60 => 'D',
    _ => 'F',
  };
}

// 结合使用
String describe(int n) {
  return switch (n) {
    < 0 => 'negative',
    == 0 => 'zero',
    > 0 && < 10 => 'single digit',
    >= 10 && < 100 => 'double digit',
    _ => 'large',
  };
}
```

## Guard 子句（when）

```dart
String describeNumber(int n) {
  return switch (n) {
    int x when x < 0 => 'negative: $x',
    int x when x == 0 => 'zero',
    int x when x % 2 == 0 => 'positive even: $x',
    int x => 'positive odd: $x',
  };
}

// 复杂条件
void processUser(Map<String, dynamic> json) {
  switch (json) {
    case {'name': String name, 'age': int age} when age >= 18:
      print('Adult: $name');
    case {'name': String name, 'age': int age} when age < 18:
      print('Minor: $name');
    case {'name': String name}:
      print('User without age: $name');
    default:
      print('Invalid user data');
  }
}
```

## 实际应用示例

### JSON 解析

```dart
class User {
  final String name;
  final int age;
  final String? email;
  
  User({required this.name, required this.age, this.email});
  
  static User? fromJson(Map<String, dynamic> json) {
    if (json case {
      'name': String name,
      'age': int age,
      'email': String? email,
    }) {
      return User(name: name, age: age, email: email);
    }
    return null;
  }
}

// 更复杂的 JSON
void processResponse(Map<String, dynamic> response) {
  switch (response) {
    case {'status': 'success', 'data': Map<String, dynamic> data}:
      print('Success: $data');
    case {'status': 'error', 'message': String message}:
      print('Error: $message');
    case {'status': 'error', 'code': int code}:
      print('Error code: $code');
    default:
      print('Unknown response format');
  }
}
```

### 状态机

```dart
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String userId;
  AuthAuthenticated(this.userId);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

Widget buildAuthWidget(AuthState state) {
  return switch (state) {
    AuthInitial() => const WelcomeScreen(),
    AuthLoading() => const LoadingIndicator(),
    AuthAuthenticated(:var userId) => HomeScreen(userId: userId),
    AuthError(:var message) => ErrorScreen(message: message),
  };
}
```

### 命令处理

```dart
sealed class Command {}

class MoveCommand extends Command {
  final int x, y;
  MoveCommand(this.x, this.y);
}

class ResizeCommand extends Command {
  final int width, height;
  ResizeCommand(this.width, this.height);
}

class DeleteCommand extends Command {}

class UndoCommand extends Command {}

void executeCommand(Command command) {
  switch (command) {
    case MoveCommand(:var x, :var y):
      print('Moving to ($x, $y)');
    case ResizeCommand(:var width, :var height):
      print('Resizing to ${width}x$height');
    case DeleteCommand():
      print('Deleting');
    case UndoCommand():
      print('Undoing last action');
  }
}
```

### 表达式求值

```dart
sealed class Expr {}

class Literal extends Expr {
  final int value;
  Literal(this.value);
}

class Add extends Expr {
  final Expr left, right;
  Add(this.left, this.right);
}

class Multiply extends Expr {
  final Expr left, right;
  Multiply(this.left, this.right);
}

int evaluate(Expr expr) {
  return switch (expr) {
    Literal(:var value) => value,
    Add(:var left, :var right) => evaluate(left) + evaluate(right),
    Multiply(:var left, :var right) => evaluate(left) * evaluate(right),
  };
}

// 使用
var expr = Add(
  Literal(5),
  Multiply(Literal(3), Literal(4)),
);
print(evaluate(expr));  // 17 (5 + 3*4)
```

### API 响应处理

```dart
sealed class ApiResponse<T> {}

class Loading<T> extends ApiResponse<T> {}

class Success<T> extends ApiResponse<T> {
  final T data;
  Success(this.data);
}

class Error<T> extends ApiResponse<T> {
  final String message;
  final int? statusCode;
  Error(this.message, {this.statusCode});
}

Widget buildWidget<T>(ApiResponse<T> response, Widget Function(T) builder) {
  return switch (response) {
    Loading() => const CircularProgressIndicator(),
    Success(:var data) => builder(data),
    Error(:var message, statusCode: 401) => const LoginScreen(),
    Error(:var message, statusCode: 404) => const NotFoundScreen(),
    Error(:var message) => ErrorWidget(message: message),
  };
}
```

### 路由匹配

```dart
typedef RouteHandler = Widget Function(Map<String, String> params);

class Route {
  final String pattern;
  final RouteHandler handler;
  
  Route(this.pattern, this.handler);
}

Widget? matchRoute(String path, List<Route> routes) {
  for (var route in routes) {
    if (parseRoute(route.pattern, path) case var params?) {
      return route.handler(params);
    }
  }
  return null;
}

Map<String, String>? parseRoute(String pattern, String path) {
  // 简化的路由匹配逻辑
  var patternParts = pattern.split('/');
  var pathParts = path.split('/');
  
  if (patternParts.length != pathParts.length) return null;
  
  var params = <String, String>{};
  for (var i = 0; i < patternParts.length; i++) {
    var patternPart = patternParts[i];
    var pathPart = pathParts[i];
    
    if (patternPart.startsWith(':')) {
      params[patternPart.substring(1)] = pathPart;
    } else if (patternPart != pathPart) {
      return null;
    }
  }
  return params;
}
```

## 最佳实践

### 1. 使用 sealed 类实现穷尽匹配

```dart
// ✅ sealed 类确保 switch 覆盖所有情况
sealed class Result<T> {}
class Success<T> extends Result<T> { final T value; Success(this.value); }
class Failure<T> extends Result<T> { final Exception error; Failure(this.error); }

String handle(Result<int> result) {
  return switch (result) {
    Success(:var value) => 'Success: $value',
    Failure(:var error) => 'Error: $error',
    // 不需要 default，编译器知道已经覆盖所有情况
  };
}
```

### 2. 优先使用对象模式而非类型检查

```dart
// ❌ 不够简洁
if (value is Point && value.x == 0) {
  print('On Y axis');
}

// ✅ 更简洁
if (value case Point(x: 0)) {
  print('On Y axis');
}
```

### 3. 利用 when 子句简化复杂条件

```dart
// ❌ 嵌套的 if
if (value case int n) {
  if (n > 0 && n < 100) {
    print('Valid');
  }
}

// ✅ 使用 when
if (value case int n when n > 0 && n < 100) {
  print('Valid');
}
```

### 4. 合理使用解构简化代码

```dart
// ❌ 繁琐的访问
void processPoint(Point p) {
  final x = p.x;
  final y = p.y;
  print('($x, $y)');
}

// ✅ 使用解构
void processPoint(Point p) {
  final Point(:x, :y) = p;
  print('($x, $y)');
}

// 或直接在参数中解构（如果支持）
void processPoints(List<Point> points) {
  for (final Point(:x, :y) in points) {
    print('($x, $y)');
  }
}
```

## 下一步

模式匹配让 Dart 代码更加优雅和安全。至此，你已经掌握了 Dart 语言的核心特性，可以进入 Flutter 开发了！

接下来请学习 [Flutter 简介](/flutter/01-introduction)，开始你的 Flutter 之旅。
