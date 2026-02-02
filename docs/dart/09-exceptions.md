# 异常处理详解

程序运行时难免会遇到错误，良好的异常处理能让你的应用更加健壮。本章将深入讲解 Dart 的异常处理机制。

## 异常基础

### 什么是异常？

异常是程序运行时发生的错误，会中断正常的执行流程：

```dart
void main() {
  int result = 10 ~/ 0;  // 💥 IntegerDivisionByZeroException
  print(result);  // 永远不会执行
}
```

### Dart 的异常类型

```dart
// Dart 有两种错误类型：

// 1. Exception（异常）- 可以被捕获和处理
// FormatException, IOException, HttpException 等

// 2. Error（错误）- 通常是程序bug，不应该捕获
// TypeError, ArgumentError, StateError, AssertionError 等
```

## 抛出异常

### 使用 throw

```dart
// 抛出内置异常
void validateAge(int age) {
  if (age < 0) {
    throw ArgumentError('Age cannot be negative');
  }
  if (age > 150) {
    throw RangeError.range(age, 0, 150, 'age');
  }
}

// 抛出任意对象（不推荐）
throw 'Something went wrong';  // 可以，但不推荐
throw 42;  // 也可以，但更不推荐

// 推荐：抛出 Exception 或其子类
throw Exception('Something went wrong');
throw FormatException('Invalid format');
```

### 自定义异常

```dart
// 简单的自定义异常
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

// 带详细信息的异常
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;
  
  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });
  
  @override
  String toString() => 'ApiException($statusCode): $message';
  
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
}

// 使用
void fetchData() {
  throw ApiException(
    statusCode: 404,
    message: 'Resource not found',
  );
}
```

### 异常层次结构

```dart
// 创建异常层次结构
abstract class AppException implements Exception {
  String get message;
}

class NetworkException extends AppException {
  @override
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, {this.statusCode});
}

class CacheException extends AppException {
  @override
  final String message;
  
  CacheException(this.message);
}

class AuthException extends AppException {
  @override
  final String message;
  final AuthErrorType type;
  
  AuthException(this.message, this.type);
}

enum AuthErrorType { invalidCredentials, tokenExpired, unauthorized }
```

## 捕获异常

### try-catch

```dart
void main() {
  try {
    int result = int.parse('not a number');
    print(result);
  } catch (e) {
    print('Error: $e');  // Error: FormatException: not a number
  }
}
```

### 捕获特定类型

```dart
void processInput(String input) {
  try {
    var number = int.parse(input);
    var result = 100 ~/ number;
    print('Result: $result');
  } on FormatException {
    print('Invalid number format');
  } on IntegerDivisionByZeroException {
    print('Cannot divide by zero');
  } catch (e) {
    print('Unknown error: $e');
  }
}
```

### 获取堆栈跟踪

```dart
void riskyOperation() {
  try {
    throw Exception('Something failed');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace:\n$stackTrace');
    
    // 记录到日志系统
    logger.error('Operation failed', error: e, stackTrace: stackTrace);
  }
}
```

### finally 块

```dart
void readFile() {
  File? file;
  try {
    file = File('data.txt');
    file.openSync();
    // 读取文件...
  } catch (e) {
    print('Error reading file: $e');
  } finally {
    // 无论是否出错，都会执行
    file?.close();
    print('File closed');
  }
}
```

### rethrow

```dart
void processData() {
  try {
    fetchData();
  } catch (e) {
    // 记录日志后重新抛出
    print('Error occurred: $e');
    rethrow;  // 保留原始堆栈跟踪
  }
}

// 对比：throw e 会丢失原始堆栈信息
void badProcess() {
  try {
    fetchData();
  } catch (e) {
    throw e;  // ❌ 丢失原始堆栈
  }
}
```

## 异步异常处理

### Future 中的异常

```dart
// async/await 方式
Future<void> loadData() async {
  try {
    var data = await fetchFromServer();
    print('Data: $data');
  } catch (e) {
    print('Failed to load: $e');
  }
}

// then/catchError 方式
void loadData() {
  fetchFromServer()
      .then((data) => print('Data: $data'))
      .catchError((e) => print('Failed to load: $e'));
}

// 处理特定类型
Future<void> loadUser() async {
  try {
    var user = await fetchUser();
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  } on AuthException catch (e) {
    print('Auth error: ${e.message}');
    // 跳转到登录页
  } catch (e) {
    print('Unknown error: $e');
  }
}
```

### Stream 中的异常

```dart
void listenToStream() {
  myStream.listen(
    (data) {
      print('Received: $data');
    },
    onError: (error, stackTrace) {
      print('Stream error: $error');
    },
    onDone: () {
      print('Stream closed');
    },
    cancelOnError: false,  // 出错后是否取消订阅
  );
}

// 使用 handleError
myStream
    .handleError((error) {
      print('Handled: $error');
      // 不会中断 stream
    })
    .listen((data) => print(data));

// 转换错误
myStream
    .transform(StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) {
        if (error is NetworkException) {
          sink.addError(UserFriendlyException('网络连接失败'));
        } else {
          sink.addError(error, stackTrace);
        }
      },
    ))
    .listen((data) => print(data));
```

### Zone 错误处理

```dart
// 捕获所有未处理的错误
void main() {
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print('Uncaught error: $error');
    print('Stack trace: $stackTrace');
    // 上报到错误监控系统
    ErrorReporter.report(error, stackTrace);
  });
}
```

## 错误处理模式

### Result 模式

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final Exception exception;
  final StackTrace? stackTrace;
  const Failure(this.exception, [this.stackTrace]);
}

// 使用
Future<Result<User>> fetchUser(String id) async {
  try {
    final user = await api.getUser(id);
    return Success(user);
  } catch (e, s) {
    return Failure(e as Exception, s);
  }
}

// 处理结果
final result = await fetchUser('123');
switch (result) {
  case Success(:final value):
    print('User: ${value.name}');
  case Failure(:final exception):
    print('Error: ${exception.message}');
}
```

### Either 模式

```dart
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool isRight;
  
  Either.left(L value) : _left = value, _right = null, isRight = false;
  Either.right(R value) : _left = null, _right = value, isRight = true;
  
  L get left => _left!;
  R get right => _right!;
  
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return isRight ? onRight(_right as R) : onLeft(_left as L);
  }
}

// 使用
typedef ApiResult<T> = Either<ApiException, T>;

Future<ApiResult<User>> getUser(String id) async {
  try {
    final user = await api.fetchUser(id);
    return Either.right(user);
  } on ApiException catch (e) {
    return Either.left(e);
  }
}

// 处理
final result = await getUser('123');
final message = result.fold(
  (error) => 'Error: ${error.message}',
  (user) => 'Hello, ${user.name}',
);
```

### 优雅降级模式

```dart
Future<String> fetchWithFallback() async {
  try {
    // 尝试从网络获取
    return await fetchFromNetwork();
  } on NetworkException {
    try {
      // 网络失败，尝试从缓存获取
      return await fetchFromCache();
    } on CacheException {
      // 缓存也失败，返回默认值
      return 'Default Value';
    }
  }
}

// 更优雅的链式写法
Future<String> fetchWithFallback() async {
  return await fetchFromNetwork()
      .catchError((_) => fetchFromCache())
      .catchError((_) => Future.value('Default Value'));
}
```

### 重试模式

```dart
Future<T> retry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  int attempts = 0;
  
  while (true) {
    try {
      attempts++;
      return await operation();
    } catch (e) {
      if (attempts >= maxAttempts) {
        rethrow;
      }
      print('Attempt $attempts failed, retrying in ${delay.inSeconds}s...');
      await Future.delayed(delay);
    }
  }
}

// 使用
final data = await retry(
  () => fetchFromServer(),
  maxAttempts: 3,
  delay: Duration(seconds: 2),
);

// 指数退避重试
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
}) async {
  int attempts = 0;
  
  while (true) {
    try {
      attempts++;
      return await operation();
    } catch (e) {
      if (attempts >= maxAttempts) rethrow;
      
      final delay = Duration(seconds: pow(2, attempts).toInt());
      await Future.delayed(delay);
    }
  }
}
```

## Flutter 中的错误处理

### 全局错误处理

```dart
void main() {
  // Flutter 框架错误
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter error: ${details.exception}');
    // 发送到错误监控
    ErrorReporter.report(details.exception, details.stack);
  };
  
  // 其他未捕获的异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform error: $error');
    ErrorReporter.report(error, stack);
    return true;  // 已处理
  };
  
  runApp(MyApp());
}
```

### ErrorWidget

```dart
void main() {
  // 自定义错误显示
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.white, size: 40),
          Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
          if (kDebugMode)
            Text(
              details.exception.toString(),
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  };
  
  runApp(MyApp());
}
```

### ErrorBoundary Widget

```dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;
  
  const ErrorBoundary({
    required this.child,
    this.errorBuilder,
  });
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  
  @override
  void initState() {
    super.initState();
    // 这里无法捕获 build 中的错误
    // Flutter 的 ErrorWidget 会处理
  }
  
  void _handleError(Object error, StackTrace stack) {
    setState(() {
      _error = error;
      _stackTrace = stack;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          Center(child: Text('Error: $_error'));
    }
    return widget.child;
  }
}
```

## 断言（Assert）

```dart
// 断言用于开发时检查条件
void setAge(int age) {
  assert(age >= 0, 'Age cannot be negative');
  assert(age <= 150, 'Age cannot exceed 150');
  // ...
}

// 断言只在 debug 模式下生效
// 生产环境中会被忽略

// 类中使用
class Circle {
  final double radius;
  
  Circle(this.radius) : assert(radius > 0, 'Radius must be positive');
  
  double get area {
    assert(radius > 0);  // 虽然构造函数已检查，但这里再次确认
    return 3.14159 * radius * radius;
  }
}
```

## 最佳实践

### 1. 不要忽略异常

```dart
// ❌ 吞掉异常
try {
  riskyOperation();
} catch (e) {
  // 什么都不做
}

// ✅ 至少记录日志
try {
  riskyOperation();
} catch (e, s) {
  logger.warning('Operation failed', error: e, stackTrace: s);
}
```

### 2. 捕获特定异常

```dart
// ❌ 捕获所有异常
try {
  parseInput(input);
} catch (e) {
  print('Error');
}

// ✅ 捕获特定异常
try {
  parseInput(input);
} on FormatException catch (e) {
  print('Invalid format: ${e.message}');
} on RangeError catch (e) {
  print('Value out of range: $e');
}
```

### 3. 提供有意义的错误信息

```dart
// ❌ 无意义的错误信息
throw Exception('Error');

// ✅ 有意义的错误信息
throw ValidationException(
  'Email format is invalid: $email. '
  'Expected format: user@domain.com'
);
```

### 4. 在适当的层级处理异常

```dart
// Repository 层：转换技术异常为业务异常
class UserRepository {
  Future<User> getUser(String id) async {
    try {
      return await api.fetchUser(id);
    } on SocketException {
      throw NetworkException('Unable to connect to server');
    } on HttpException catch (e) {
      if (e.statusCode == 404) {
        throw NotFoundException('User not found');
      }
      throw ServerException('Server error: ${e.message}');
    }
  }
}

// UI 层：展示用户友好的信息
class UserPage extends StatelessWidget {
  Future<void> _loadUser() async {
    try {
      final user = await repository.getUser(userId);
      // 显示用户信息
    } on NetworkException {
      _showError('请检查网络连接');
    } on NotFoundException {
      _showError('用户不存在');
    } catch (e) {
      _showError('加载失败，请稍后重试');
    }
  }
}
```

### 5. 使用 finally 清理资源

```dart
Future<void> processFile(String path) async {
  File? file;
  try {
    file = File(path);
    await file.open();
    // 处理文件...
  } finally {
    await file?.close();  // 确保文件被关闭
  }
}
```

## 下一步

掌握异常处理后，下一章我们将学习 [扩展方法与扩展类型](./10-extensions)，让你能够为现有类型添加新功能。
