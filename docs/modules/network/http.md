# http 包

`http` 是 Dart 官方维护的 HTTP 请求库，提供简洁的 Future-based API，适合简单的网络请求场景。

## 安装

```yaml
dependencies:
  http: ^1.6.0
```

```bash
flutter pub add http
```

## 基础使用

### 导入

```dart
import 'package:http/http.dart' as http;
```

### GET 请求

```dart
// 简单 GET 请求
Future<void> fetchData() async {
  final url = Uri.https('jsonplaceholder.typicode.com', '/posts/1');
  final response = await http.get(url);
  
  print('状态码: ${response.statusCode}');
  print('响应体: ${response.body}');
}

// 带查询参数的 GET 请求
Future<void> fetchWithParams() async {
  final url = Uri.https(
    'jsonplaceholder.typicode.com',
    '/posts',
    {'userId': '1', '_limit': '5'},  // 查询参数
  );
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('获取到 ${data.length} 条数据');
  }
}
```

### POST 请求

```dart
// 发送 JSON 数据
Future<void> createPost() async {
  final url = Uri.https('jsonplaceholder.typicode.com', '/posts');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': 'Hello',
      'body': 'World',
      'userId': 1,
    }),
  );
  
  print('状态码: ${response.statusCode}');
  print('响应: ${response.body}');
}

// 发送表单数据
Future<void> submitForm() async {
  final url = Uri.https('example.com', '/api/submit');
  final response = await http.post(
    url,
    body: {
      'name': 'Flutter',
      'version': '3.19',
    },
  );
  
  print('状态码: ${response.statusCode}');
}
```

### PUT 请求

```dart
Future<void> updatePost() async {
  final url = Uri.https('jsonplaceholder.typicode.com', '/posts/1');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': 1,
      'title': 'Updated Title',
      'body': 'Updated Body',
      'userId': 1,
    }),
  );
  
  print('更新结果: ${response.statusCode}');
}
```

### PATCH 请求

```dart
Future<void> patchPost() async {
  final url = Uri.https('jsonplaceholder.typicode.com', '/posts/1');
  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': 'Only Update Title',
    }),
  );
  
  print('部分更新结果: ${response.statusCode}');
}
```

### DELETE 请求

```dart
Future<void> deletePost() async {
  final url = Uri.https('jsonplaceholder.typicode.com', '/posts/1');
  final response = await http.delete(url);
  
  print('删除结果: ${response.statusCode}');
}
```

### 快捷读取方法

```dart
// 直接获取响应内容字符串
final content = await http.read(Uri.https('example.com', '/data.txt'));
print(content);

// 直接获取响应字节
final bytes = await http.readBytes(Uri.https('example.com', '/image.png'));
print('字节数: ${bytes.length}');
```

---

## 使用 Client

对于多次请求同一服务器，建议使用 `Client` 保持连接复用：

```dart
Future<void> multipleRequests() async {
  final client = http.Client();
  
  try {
    // 复用同一个 client 发起多次请求
    final response1 = await client.get(
      Uri.https('jsonplaceholder.typicode.com', '/posts/1'),
    );
    print('请求1: ${response1.statusCode}');
    
    final response2 = await client.get(
      Uri.https('jsonplaceholder.typicode.com', '/posts/2'),
    );
    print('请求2: ${response2.statusCode}');
    
    final response3 = await client.post(
      Uri.https('jsonplaceholder.typicode.com', '/posts'),
      body: {'title': 'New Post'},
    );
    print('请求3: ${response3.statusCode}');
    
  } finally {
    // 重要：使用完毕后关闭 client
    client.close();
  }
}
```

### 封装 API 服务类

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client _client;
  final String _baseUrl = 'https://api.example.com';
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  // 通用请求头
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // GET 请求
  Future<Map<String, dynamic>> get(String path) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await _client.get(url, headers: _headers);
    return _handleResponse(response);
  }
  
  // POST 请求
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await _client.post(
      url,
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }
  
  // 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(
        '请求失败: ${response.statusCode}',
        response.statusCode,
      );
    }
  }
  
  // 关闭连接
  void dispose() {
    _client.close();
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  
  HttpException(this.message, this.statusCode);
  
  @override
  String toString() => 'HttpException: $message (status: $statusCode)';
}
```

### 使用示例

```dart
void main() async {
  final api = ApiService();
  
  try {
    // GET 请求
    final user = await api.get('/users/1');
    print('用户: ${user['name']}');
    
    // POST 请求
    final newPost = await api.post('/posts', {
      'title': 'Hello',
      'body': 'World',
    });
    print('创建成功: ${newPost['id']}');
    
  } catch (e) {
    print('错误: $e');
  } finally {
    api.dispose();
  }
}
```

---

## 自定义请求

使用 `Request` 对象可以进行更精细的控制：

```dart
Future<void> customRequest() async {
  final client = http.Client();
  
  try {
    // 创建请求对象
    final request = http.Request(
      'POST',
      Uri.https('api.example.com', '/data'),
    );
    
    // 设置请求头
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer token123',
      'X-Custom-Header': 'custom-value',
    });
    
    // 设置请求体
    request.body = jsonEncode({'key': 'value'});
    
    // 发送请求
    final streamedResponse = await client.send(request);
    
    // 获取响应
    final response = await http.Response.fromStream(streamedResponse);
    print('响应: ${response.body}');
    
  } finally {
    client.close();
  }
}
```

### 流式请求

```dart
Future<void> streamedRequest() async {
  final client = http.Client();
  
  try {
    final request = http.StreamedRequest(
      'POST',
      Uri.https('api.example.com', '/upload'),
    );
    
    request.headers['Content-Type'] = 'application/octet-stream';
    
    // 写入数据流
    request.sink.add([0, 1, 2, 3, 4]);
    request.sink.close();
    
    final response = await client.send(request);
    print('状态码: ${response.statusCode}');
    
  } finally {
    client.close();
  }
}
```

---

## 自定义 Client

通过继承 `BaseClient` 可以添加统一的行为：

### 添加 User-Agent

```dart
class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner;

  UserAgentClient(this.userAgent, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] = userAgent;
    return _inner.send(request);
  }
  
  @override
  void close() => _inner.close();
}

// 使用
final client = UserAgentClient('MyApp/1.0', http.Client());
```

### 添加认证 Token

```dart
class AuthClient extends http.BaseClient {
  final http.Client _inner;
  String? _token;

  AuthClient(this._inner);

  void setToken(String token) {
    _token = token;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    return _inner.send(request);
  }
  
  @override
  void close() => _inner.close();
}
```

### 日志 Client

```dart
class LoggingClient extends http.BaseClient {
  final http.Client _inner;

  LoggingClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 请求日志
    print('➡️ ${request.method} ${request.url}');
    print('   Headers: ${request.headers}');
    
    final stopwatch = Stopwatch()..start();
    final response = await _inner.send(request);
    stopwatch.stop();
    
    // 响应日志
    print('⬅️ ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
    
    return response;
  }
  
  @override
  void close() => _inner.close();
}
```

### 组合多个 Client

```dart
// 链式组合
final client = LoggingClient(
  AuthClient(
    UserAgentClient('MyApp/1.0', http.Client()),
  )..setToken('my-token'),
);

// 使用
final response = await client.get(Uri.https('api.example.com', '/data'));
```

---

## 请求重试

使用 `RetryClient` 自动重试失败的请求：

```dart
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

Future<void> fetchWithRetry() async {
  // 默认：重试 503 错误，最多 3 次，延迟递增
  final client = RetryClient(http.Client());
  
  try {
    final response = await client.get(
      Uri.https('api.example.com', '/data'),
    );
    print('响应: ${response.body}');
  } finally {
    client.close();
  }
}

// 自定义重试策略
final customRetryClient = RetryClient(
  http.Client(),
  retries: 5,  // 最多重试 5 次
  when: (response) {
    // 指定哪些状态码需要重试
    return response.statusCode == 503 || response.statusCode == 502;
  },
  whenError: (error, stackTrace) {
    // 指定哪些错误需要重试
    return error is SocketException;
  },
  delay: (retryCount) {
    // 自定义延迟策略（指数退避）
    return Duration(seconds: math.pow(2, retryCount).toInt());
  },
  onRetry: (request, response, retryCount) {
    // 重试回调
    print('重试第 $retryCount 次: ${request.url}');
  },
);
```

---

## 取消请求

使用 `AbortableRequest` 取消正在进行的请求：

```dart
import 'dart:async';
import 'package:http/http.dart' as http;

Future<void> abortableRequest() async {
  final abortTrigger = Completer<void>();
  final client = http.Client();
  
  final request = http.AbortableRequest(
    'GET',
    Uri.https('api.example.com', '/slow-endpoint'),
    abortTrigger: abortTrigger.future,
  );
  
  // 5 秒后取消请求
  Future.delayed(Duration(seconds: 5), () {
    if (!abortTrigger.isCompleted) {
      abortTrigger.complete();
      print('请求已取消');
    }
  });
  
  try {
    final response = await client.send(request);
    final body = await response.stream.bytesToString();
    print('响应: $body');
  } on http.RequestAbortedException {
    print('请求被取消');
  } finally {
    client.close();
  }
}
```

---

## 错误处理

```dart
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> fetchWithErrorHandling() async {
  try {
    final response = await http.get(
      Uri.https('api.example.com', '/data'),
    ).timeout(Duration(seconds: 10));
    
    switch (response.statusCode) {
      case 200:
        print('成功: ${response.body}');
        break;
      case 400:
        print('请求参数错误');
        break;
      case 401:
        print('未授权，请登录');
        break;
      case 403:
        print('无权限访问');
        break;
      case 404:
        print('资源不存在');
        break;
      case 500:
        print('服务器内部错误');
        break;
      default:
        print('未知错误: ${response.statusCode}');
    }
    
  } on SocketException catch (e) {
    print('网络连接失败: $e');
  } on TimeoutException catch (e) {
    print('请求超时: $e');
  } on FormatException catch (e) {
    print('数据格式错误: $e');
  } catch (e) {
    print('未知错误: $e');
  }
}
```

### 封装统一错误处理

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;
  
  ApiException(this.message, {this.statusCode, this.body});
  
  @override
  String toString() => 'ApiException: $message';
  
  factory ApiException.fromResponse(http.Response response) {
    String message;
    switch (response.statusCode) {
      case 400:
        message = '请求参数错误';
        break;
      case 401:
        message = '未授权，请重新登录';
        break;
      case 403:
        message = '无权限访问';
        break;
      case 404:
        message = '请求的资源不存在';
        break;
      case 500:
        message = '服务器错误，请稍后重试';
        break;
      default:
        message = '请求失败';
    }
    return ApiException(
      message,
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}
```

---

## 测试支持

`http` 包提供了方便的测试工具：

```dart
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

// 被测试的服务类
class UserService {
  final http.Client client;
  
  UserService({http.Client? client}) : client = client ?? http.Client();
  
  Future<String> fetchUserName(int id) async {
    final response = await client.get(
      Uri.https('api.example.com', '/users/$id'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'];
    }
    throw Exception('Failed to fetch user');
  }
}

// 测试代码
void main() {
  test('fetchUserName returns correct name', () async {
    // 创建 Mock Client
    final mockClient = MockClient((request) async {
      // 验证请求
      expect(request.url.path, '/users/1');
      
      // 返回模拟响应
      return http.Response(
        '{"id": 1, "name": "John Doe"}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    
    // 注入 Mock Client
    final service = UserService(client: mockClient);
    
    // 执行测试
    final name = await service.fetchUserName(1);
    expect(name, 'John Doe');
  });
  
  test('fetchUserName throws on error', () async {
    final mockClient = MockClient((request) async {
      return http.Response('Not Found', 404);
    });
    
    final service = UserService(client: mockClient);
    
    expect(
      () => service.fetchUserName(999),
      throwsException,
    );
  });
}
```

---

## 完整示例

### Flutter 中获取数据

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Post {
  final int id;
  final String title;
  final String body;
  
  Post({required this.id, required this.title, required this.body});
  
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class PostListPage extends StatefulWidget {
  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late Future<List<Post>> _postsFuture;
  
  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }
  
  Future<List<Post>> _fetchPosts() async {
    final response = await http.get(
      Uri.https('jsonplaceholder.typicode.com', '/posts'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('加载失败');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文章列表')),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _postsFuture = _fetchPosts();
                      });
                    },
                    child: Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(post.title),
                subtitle: Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## http vs dio 对比

| 特性 | http | dio |
|------|------|-----|
| 维护方 | Dart 官方 | 社区 |
| 包大小 | 小 | 大 |
| API 复杂度 | 简单 | 丰富 |
| 拦截器 | 需自定义 BaseClient | 内置完善 |
| 请求取消 | 支持 | 支持 |
| 文件上传 | 需手动处理 | 内置 FormData |
| 进度监听 | 需使用 Stream | 内置回调 |
| 全局配置 | 需封装 | 内置 BaseOptions |
| 适用场景 | 简单请求 | 复杂项目 |

## 最佳实践

1. **使用 Client 复用连接** - 避免每次请求都创建新连接
2. **记得关闭 Client** - 使用 `try-finally` 确保资源释放
3. **统一错误处理** - 封装通用的错误处理逻辑
4. **使用依赖注入** - 便于测试时替换 Mock Client
5. **添加超时设置** - 避免请求无限等待

## 相关资源

- [http 官方文档](https://pub.dev/packages/http)
- [Dart 网络请求教程](https://dart.dev/tutorials/server/fetch-data)
- [Flutter 网络请求 Cookbook](https://docs.flutter.dev/cookbook/networking/fetch-data)
