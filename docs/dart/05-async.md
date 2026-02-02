# 异步编程

Dart 的异步编程基于 Future 和 Stream，使用 async/await 语法让异步代码更易读。

## 为什么需要异步？

```dart
// 同步代码会阻塞
void syncExample() {
  var data = fetchDataSync();  // 等待 3 秒
  print(data);                  // 继续执行
  print('完成');
}

// 异步代码不阻塞
void asyncExample() async {
  var data = await fetchDataAsync();  // 不阻塞，等待时可执行其他任务
  print(data);
  print('完成');
}
```

## Future

Future 表示一个可能在未来完成的异步操作。

### 创建 Future

```dart
// 直接返回值
Future<String> getValue() {
  return Future.value('Hello');
}

// 延迟执行
Future<String> getDelayedValue() {
  return Future.delayed(
    Duration(seconds: 2),
    () => 'Delayed Hello',
  );
}

// 返回错误
Future<String> getError() {
  return Future.error('Something went wrong');
}

// 使用构造函数
Future<int> compute() {
  return Future(() {
    // 计算密集型任务
    var sum = 0;
    for (var i = 0; i < 1000000; i++) {
      sum += i;
    }
    return sum;
  });
}
```

### 使用 then/catchError

```dart
fetchUser()
    .then((user) {
      print('用户: $user');
      return fetchOrders(user.id);
    })
    .then((orders) {
      print('订单: $orders');
    })
    .catchError((error) {
      print('错误: $error');
    })
    .whenComplete(() {
      print('完成');
    });
```

### 使用 async/await

```dart
Future<void> loadData() async {
  try {
    var user = await fetchUser();
    print('用户: $user');
    
    var orders = await fetchOrders(user.id);
    print('订单: $orders');
  } catch (error) {
    print('错误: $error');
  } finally {
    print('完成');
  }
}
```

### 并行执行

```dart
// Future.wait - 等待所有完成
Future<void> loadAllData() async {
  var results = await Future.wait([
    fetchUser(),
    fetchProducts(),
    fetchSettings(),
  ]);
  
  var user = results[0];
  var products = results[1];
  var settings = results[2];
}

// 更优雅的方式
Future<void> loadAllData() async {
  var (user, products, settings) = await (
    fetchUser(),
    fetchProducts(),
    fetchSettings(),
  ).wait;
}

// Future.any - 返回最先完成的
Future<String> fetchFromFastest() {
  return Future.any([
    fetchFromServer1(),
    fetchFromServer2(),
    fetchFromServer3(),
  ]);
}
```

### 超时处理

```dart
Future<String> fetchWithTimeout() async {
  try {
    return await fetchData().timeout(
      Duration(seconds: 5),
      onTimeout: () => '超时，返回默认值',
    );
  } on TimeoutException {
    return '超时异常';
  }
}
```

## Stream

Stream 是一系列异步事件，可以是数据或错误。

### 创建 Stream

```dart
// Stream.fromIterable
var stream1 = Stream.fromIterable([1, 2, 3, 4, 5]);

// Stream.periodic - 周期性事件
var stream2 = Stream.periodic(
  Duration(seconds: 1),
  (count) => count,
).take(5);  // 只取前 5 个

// Stream.fromFuture
var stream3 = Stream.fromFuture(fetchData());

// async* 生成器
Stream<int> countStream(int max) async* {
  for (var i = 1; i <= max; i++) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i;
  }
}
```

### 监听 Stream

```dart
// listen 方法
var subscription = stream.listen(
  (data) => print('数据: $data'),
  onError: (error) => print('错误: $error'),
  onDone: () => print('完成'),
  cancelOnError: false,
);

// 取消订阅
subscription.cancel();

// await for 语法
Future<void> processStream() async {
  await for (var value in countStream(5)) {
    print('值: $value');
  }
  print('流结束');
}
```

### Stream 操作

```dart
var numbers = Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

// map - 转换
var doubled = numbers.map((n) => n * 2);

// where - 过滤
var evens = numbers.where((n) => n.isEven);

// take/skip
var first3 = numbers.take(3);
var skip3 = numbers.skip(3);

// reduce/fold
var sum = await numbers.reduce((a, b) => a + b);
var sumWithInitial = await numbers.fold(0, (prev, n) => prev + n);

// toList
var list = await numbers.toList();

// 链式操作
var result = await Stream.fromIterable([1, 2, 3, 4, 5])
    .where((n) => n.isOdd)
    .map((n) => n * 10)
    .toList();
print(result);  // [10, 30, 50]
```

### 单订阅 vs 广播 Stream

```dart
// 单订阅 Stream（默认）- 只能有一个监听者
var singleStream = Stream.fromIterable([1, 2, 3]);

// 广播 Stream - 可以有多个监听者
var broadcastStream = singleStream.asBroadcastStream();

broadcastStream.listen((data) => print('监听者1: $data'));
broadcastStream.listen((data) => print('监听者2: $data'));
```

### StreamController

```dart
// 创建可控的 Stream
var controller = StreamController<int>();

// 添加数据
controller.sink.add(1);
controller.sink.add(2);
controller.sink.add(3);

// 添加错误
controller.sink.addError('出错了');

// 监听
controller.stream.listen(
  (data) => print('数据: $data'),
  onError: (e) => print('错误: $e'),
);

// 关闭
controller.close();

// 广播 StreamController
var broadcastController = StreamController<int>.broadcast();
```

### StreamTransformer

```dart
// 自定义转换器
var transformer = StreamTransformer<int, String>.fromHandlers(
  handleData: (data, sink) {
    sink.add('值: $data');
  },
  handleError: (error, stackTrace, sink) {
    sink.add('错误: $error');
  },
  handleDone: (sink) {
    sink.close();
  },
);

Stream.fromIterable([1, 2, 3])
    .transform(transformer)
    .listen(print);
// 值: 1
// 值: 2
// 值: 3
```

## 异步模式

### 串行执行

```dart
Future<void> serial() async {
  var result1 = await task1();
  var result2 = await task2(result1);  // 依赖 result1
  var result3 = await task3(result2);  // 依赖 result2
  return result3;
}
```

### 并行执行

```dart
Future<void> parallel() async {
  // 同时开始所有任务
  var future1 = task1();
  var future2 = task2();
  var future3 = task3();
  
  // 等待所有完成
  var results = await Future.wait([future1, future2, future3]);
}
```

### 竞态处理

```dart
// 取消之前的请求
class SearchService {
  CancelableOperation? _currentSearch;
  
  Future<List<String>> search(String query) async {
    // 取消之前的搜索
    _currentSearch?.cancel();
    
    var operation = CancelableOperation.fromFuture(
      _performSearch(query),
    );
    _currentSearch = operation;
    
    return operation.value;
  }
}
```

### 防抖和节流

```dart
import 'dart:async';

class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({required this.delay});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

// 使用
final debouncer = Debouncer(delay: Duration(milliseconds: 300));

void onSearchChanged(String query) {
  debouncer.run(() => performSearch(query));
}
```

## 异常处理

```dart
Future<void> robustAsync() async {
  try {
    var data = await fetchData();
    await processData(data);
  } on NetworkException catch (e) {
    // 处理网络错误
    print('网络错误: ${e.message}');
  } on FormatException catch (e) {
    // 处理格式错误
    print('格式错误: ${e.message}');
  } catch (e, stackTrace) {
    // 处理其他错误
    print('未知错误: $e');
    print('堆栈: $stackTrace');
  } finally {
    // 清理资源
    cleanup();
  }
}

// 自定义异常
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, {this.statusCode});
  
  @override
  String toString() => 'NetworkException: $message (code: $statusCode)';
}
```

## 实践练习

```dart
void main() async {
  // 练习 1：模拟 API 请求
  print('开始加载数据...');
  
  try {
    var (user, posts) = await (
      fetchUser(1),
      fetchPosts(1),
    ).wait;
    
    print('用户: ${user.name}');
    print('文章数: ${posts.length}');
  } catch (e) {
    print('加载失败: $e');
  }
  
  // 练习 2：Stream 处理
  print('\n实时计数:');
  await for (var count in countDown(5)) {
    print(count);
  }
  print('发射!');
}

// 模拟 API
Future<User> fetchUser(int id) async {
  await Future.delayed(Duration(seconds: 1));
  return User(id, 'Alice');
}

Future<List<Post>> fetchPosts(int userId) async {
  await Future.delayed(Duration(seconds: 1));
  return [
    Post(1, 'Hello Dart'),
    Post(2, 'Async Programming'),
  ];
}

// 倒计时 Stream
Stream<int> countDown(int from) async* {
  for (var i = from; i > 0; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

class User {
  final int id;
  final String name;
  User(this.id, this.name);
}

class Post {
  final int id;
  final String title;
  Post(this.id, this.title);
}
```

## 下一步

掌握异步编程后，你已经具备了 Dart 开发的核心技能！接下来可以学习 [Flutter 入门](../flutter/01-introduction)，开始构建精美的应用。
