# Mock 数据

在开发阶段，后端 API 可能还未完成，或者我们需要测试各种边界情况。Mock 数据可以帮助前端独立开发和测试。

本文介绍几种 Flutter 中常用的 Mock 方案：

## 方案一：本地 JSON 文件

最简单的方式，将 Mock 数据放在 `assets` 目录。

### 1. 创建 JSON 文件

```
assets/
  mock/
    users.json
    posts.json
```

```json
// assets/mock/users.json
[
  {"id": 1, "name": "张三", "email": "zhangsan@example.com"},
  {"id": 2, "name": "李四", "email": "lisi@example.com"},
  {"id": 3, "name": "王五", "email": "wangwu@example.com"}
]
```

### 2. 配置 pubspec.yaml

```yaml
flutter:
  assets:
    - assets/mock/
```

### 3. 读取 Mock 数据

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

class MockDataLoader {
  static Future<List<dynamic>> loadUsers() async {
    final jsonString = await rootBundle.loadString('assets/mock/users.json');
    return jsonDecode(jsonString);
  }
  
  static Future<T> load<T>(String path) async {
    final jsonString = await rootBundle.loadString('assets/mock/$path');
    return jsonDecode(jsonString) as T;
  }
}

// 使用
final users = await MockDataLoader.loadUsers();
```

### 4. 封装 Mock 服务

```dart
class UserService {
  final bool useMock;
  
  UserService({this.useMock = false});
  
  Future<List<User>> getUsers() async {
    if (useMock) {
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 500));
      final data = await MockDataLoader.load<List>('users.json');
      return data.map((e) => User.fromJson(e)).toList();
    }
    
    // 真实 API 请求
    final response = await dio.get('/users');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }
}
```

---

## 方案二：Dio 拦截器 Mock

使用 Dio 拦截器拦截请求，返回 Mock 数据，无需修改业务代码。

### Mock 拦截器

```dart
import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  // Mock 数据映射表
  final Map<String, dynamic> _mockData = {
    'GET /users': [
      {'id': 1, 'name': '张三', 'email': 'zhangsan@example.com'},
      {'id': 2, 'name': '李四', 'email': 'lisi@example.com'},
    ],
    'GET /users/1': {
      'id': 1,
      'name': '张三',
      'email': 'zhangsan@example.com',
      'phone': '13800138000',
    },
    'POST /users': {
      'id': 3,
      'name': 'New User',
      'message': '创建成功',
    },
    'GET /posts': [
      {'id': 1, 'title': '第一篇文章', 'content': '内容...'},
      {'id': 2, 'title': '第二篇文章', 'content': '内容...'},
    ],
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 生成 key: "METHOD /path"
    final key = '${options.method} ${options.path}';
    
    if (_mockData.containsKey(key)) {
      // 模拟网络延迟
      Future.delayed(Duration(milliseconds: 300), () {
        handler.resolve(Response(
          requestOptions: options,
          data: _mockData[key],
          statusCode: 200,
        ));
      });
    } else {
      // 没有 Mock 数据，继续真实请求
      handler.next(options);
    }
  }
}
```

### 使用方式

```dart
final dio = Dio();

// 开发环境添加 Mock 拦截器
if (kDebugMode) {
  dio.interceptors.add(MockInterceptor());
}

// 业务代码不变
final response = await dio.get('/users');
print(response.data); // Mock 数据
```

### 增强版：支持动态响应

```dart
class MockInterceptor extends Interceptor {
  // 使用函数生成动态 Mock 数据
  final Map<String, dynamic Function(RequestOptions)> _mockHandlers = {};

  MockInterceptor() {
    _setupMocks();
  }

  void _setupMocks() {
    // GET /users - 列表
    _mockHandlers['GET /users'] = (options) {
      final page = options.queryParameters['page'] ?? 1;
      final limit = options.queryParameters['limit'] ?? 10;
      
      return List.generate(limit, (i) => {
        'id': (page - 1) * limit + i + 1,
        'name': '用户 ${(page - 1) * limit + i + 1}',
        'email': 'user${(page - 1) * limit + i + 1}@example.com',
      });
    };

    // GET /users/:id - 详情（使用正则匹配）
    _mockHandlers[r'GET /users/\d+'] = (options) {
      final id = int.parse(options.path.split('/').last);
      return {
        'id': id,
        'name': '用户 $id',
        'email': 'user$id@example.com',
        'avatar': 'https://i.pravatar.cc/150?img=$id',
        'createdAt': DateTime.now().toIso8601String(),
      };
    };

    // POST /users - 创建
    _mockHandlers['POST /users'] = (options) {
      final data = options.data as Map<String, dynamic>;
      return {
        'id': DateTime.now().millisecondsSinceEpoch,
        ...data,
        'message': '创建成功',
      };
    };

    // DELETE /users/:id
    _mockHandlers[r'DELETE /users/\d+'] = (options) {
      return {'message': '删除成功'};
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = '${options.method} ${options.path}';
    
    // 精确匹配
    if (_mockHandlers.containsKey(key)) {
      _respond(options, handler, _mockHandlers[key]!(options));
      return;
    }
    
    // 正则匹配
    for (var entry in _mockHandlers.entries) {
      if (RegExp(entry.key).hasMatch(key)) {
        _respond(options, handler, entry.value(options));
        return;
      }
    }
    
    handler.next(options);
  }

  void _respond(
    RequestOptions options,
    RequestInterceptorHandler handler,
    dynamic data,
  ) {
    Future.delayed(Duration(milliseconds: 200 + Random().nextInt(300)), () {
      handler.resolve(Response(
        requestOptions: options,
        data: data,
        statusCode: 200,
      ));
    });
  }
}
```

---

## 方案三：http 包 MockClient

`http` 包自带 `MockClient`，非常适合单元测试。

```dart
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// 创建 MockClient
final mockClient = MockClient((request) async {
  // 根据请求返回不同响应
  if (request.url.path == '/users') {
    return http.Response(
      jsonEncode([
        {'id': 1, 'name': '张三'},
        {'id': 2, 'name': '李四'},
      ]),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
  
  if (request.url.path.startsWith('/users/')) {
    final id = request.url.pathSegments.last;
    return http.Response(
      jsonEncode({'id': int.parse(id), 'name': '用户 $id'}),
      200,
    );
  }
  
  // 404
  return http.Response('Not Found', 404);
});

// 注入使用
class ApiService {
  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();
  
  Future<List<User>> getUsers() async {
    final response = await client.get(Uri.parse('https://api.example.com/users'));
    final data = jsonDecode(response.body) as List;
    return data.map((e) => User.fromJson(e)).toList();
  }
}

// 测试
void main() {
  test('getUsers returns list of users', () async {
    final service = ApiService(client: mockClient);
    final users = await service.getUsers();
    expect(users.length, 2);
    expect(users[0].name, '张三');
  });
}
```

---

## 方案四：json_server 本地服务

使用 `json-server` 快速搭建 RESTful Mock 服务器。

### 1. 安装 json-server

```bash
npm install -g json-server
```

### 2. 创建数据文件

```json
// db.json
{
  "users": [
    {"id": 1, "name": "张三", "email": "zhangsan@example.com"},
    {"id": 2, "name": "李四", "email": "lisi@example.com"}
  ],
  "posts": [
    {"id": 1, "title": "Hello", "body": "World", "userId": 1},
    {"id": 2, "title": "Flutter", "body": "is awesome", "userId": 1}
  ],
  "comments": [
    {"id": 1, "body": "Great!", "postId": 1}
  ]
}
```

### 3. 启动服务

```bash
json-server --watch db.json --port 3000
```

### 4. 自动生成的 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /users | 获取所有用户 |
| GET | /users/1 | 获取 ID 为 1 的用户 |
| GET | /users?name=张三 | 筛选查询 |
| GET | /posts?userId=1 | 关联查询 |
| GET | /posts?_page=1&_limit=10 | 分页 |
| POST | /users | 创建用户 |
| PUT | /users/1 | 更新用户 |
| PATCH | /users/1 | 部分更新 |
| DELETE | /users/1 | 删除用户 |

### 5. Flutter 中使用

```dart
// 开发环境配置
const baseUrl = kDebugMode 
    ? 'http://localhost:3000'  // Mock 服务器
    : 'https://api.example.com'; // 生产环境

final dio = Dio(BaseOptions(baseUrl: baseUrl));

// 请求方式不变
final response = await dio.get('/users');
```

---

## 方案五：Mockito 单元测试

使用 `mockito` 生成 Mock 对象进行单元测试。

### 1. 添加依赖

```yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### 2. 创建 Mock 类

```dart
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

// 生成 Mock 类
@GenerateMocks([Dio])
void main() {}
```

运行生成命令：

```bash
dart run build_runner build
```

### 3. 编写测试

```dart
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'user_service_test.mocks.dart'; // 生成的文件

void main() {
  late MockDio mockDio;
  late UserService userService;

  setUp(() {
    mockDio = MockDio();
    userService = UserService(dio: mockDio);
  });

  test('getUsers returns list of users', () async {
    // 设置 Mock 行为
    when(mockDio.get('/users')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/users'),
      data: [
        {'id': 1, 'name': '张三'},
        {'id': 2, 'name': '李四'},
      ],
      statusCode: 200,
    ));

    // 执行测试
    final users = await userService.getUsers();

    // 验证结果
    expect(users.length, 2);
    expect(users[0].name, '张三');
    
    // 验证调用
    verify(mockDio.get('/users')).called(1);
  });

  test('getUsers throws on error', () async {
    when(mockDio.get('/users')).thenThrow(DioException(
      requestOptions: RequestOptions(path: '/users'),
      type: DioExceptionType.connectionError,
    ));

    expect(() => userService.getUsers(), throwsA(isA<ApiException>()));
  });
}
```

---

## 方案六：环境配置切换

通过环境变量或配置文件切换 Mock/真实环境。

### 配置类

```dart
enum Environment { dev, staging, prod }

class AppConfig {
  static Environment environment = Environment.dev;
  
  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.prod:
        return 'https://api.example.com';
    }
  }
  
  static bool get useMock => environment == Environment.dev;
}
```

### 条件编译

```dart
// main_dev.dart
void main() {
  AppConfig.environment = Environment.dev;
  runApp(MyApp());
}

// main_prod.dart  
void main() {
  AppConfig.environment = Environment.prod;
  runApp(MyApp());
}
```

运行命令：

```bash
# 开发环境
flutter run -t lib/main_dev.dart

# 生产环境
flutter run -t lib/main_prod.dart
```

### 使用 --dart-define

```dart
void main() {
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  AppConfig.environment = Environment.values.byName(env);
  runApp(MyApp());
}
```

```bash
flutter run --dart-define=ENV=prod
```

---

## 完整 Mock 服务封装

```dart
import 'dart:math';
import 'package:dio/dio.dart';

/// Mock 配置
class MockConfig {
  /// 是否启用 Mock
  static bool enabled = true;
  
  /// 模拟延迟范围（毫秒）
  static int minDelay = 200;
  static int maxDelay = 800;
  
  /// 模拟错误概率（0-1）
  static double errorRate = 0.0;
}

/// Mock 响应构建器
class MockResponse {
  final dynamic data;
  final int statusCode;
  final Map<String, String>? headers;
  
  MockResponse(this.data, {this.statusCode = 200, this.headers});
  
  factory MockResponse.success(dynamic data) => MockResponse(data);
  
  factory MockResponse.error(String message, {int code = 400}) {
    return MockResponse({'error': message}, statusCode: code);
  }
  
  factory MockResponse.paginated(
    List<dynamic> items, {
    int page = 1,
    int total = 100,
    int pageSize = 10,
  }) {
    return MockResponse({
      'items': items,
      'page': page,
      'pageSize': pageSize,
      'total': total,
      'totalPages': (total / pageSize).ceil(),
    });
  }
}

/// Mock 拦截器
class MockInterceptor extends Interceptor {
  final Map<String, MockResponse Function(RequestOptions)> _handlers = {};
  final Random _random = Random();

  MockInterceptor() {
    _registerMocks();
  }

  /// 注册 Mock 接口
  void _registerMocks() {
    // 用户列表
    register('GET', '/users', (options) {
      final page = int.tryParse('${options.queryParameters['page']}') ?? 1;
      final limit = int.tryParse('${options.queryParameters['limit']}') ?? 10;
      
      final users = List.generate(limit, (i) {
        final id = (page - 1) * limit + i + 1;
        return {
          'id': id,
          'name': '用户 $id',
          'email': 'user$id@example.com',
          'avatar': 'https://i.pravatar.cc/150?img=$id',
        };
      });
      
      return MockResponse.paginated(users, page: page, total: 100);
    });

    // 用户详情（支持动态 ID）
    registerPattern(r'GET /users/(\d+)', (options, match) {
      final id = int.parse(match.group(1)!);
      return MockResponse.success({
        'id': id,
        'name': '用户 $id',
        'email': 'user$id@example.com',
        'phone': '138${id.toString().padLeft(8, '0')}',
        'address': '北京市朝阳区xxx街道',
        'createdAt': DateTime.now()
            .subtract(Duration(days: id))
            .toIso8601String(),
      });
    });

    // 创建用户
    register('POST', '/users', (options) {
      final data = options.data as Map<String, dynamic>? ?? {};
      return MockResponse.success({
        'id': DateTime.now().millisecondsSinceEpoch,
        ...data,
        'createdAt': DateTime.now().toIso8601String(),
      });
    });

    // 更新用户
    registerPattern(r'PUT /users/(\d+)', (options, match) {
      final id = int.parse(match.group(1)!);
      final data = options.data as Map<String, dynamic>? ?? {};
      return MockResponse.success({
        'id': id,
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });

    // 删除用户
    registerPattern(r'DELETE /users/(\d+)', (options, match) {
      return MockResponse.success({'message': '删除成功'});
    });

    // 登录
    register('POST', '/auth/login', (options) {
      final data = options.data as Map<String, dynamic>? ?? {};
      final username = data['username'];
      final password = data['password'];
      
      if (username == 'admin' && password == '123456') {
        return MockResponse.success({
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': 1,
            'name': 'Admin',
            'role': 'admin',
          },
        });
      }
      
      return MockResponse.error('用户名或密码错误', code: 401);
    });

    // 文件上传
    register('POST', '/upload', (options) {
      return MockResponse.success({
        'url': 'https://example.com/uploads/${DateTime.now().millisecondsSinceEpoch}.jpg',
        'size': 1024 * 100,
      });
    });
  }

  /// 注册精确匹配的 Mock
  void register(
    String method,
    String path,
    MockResponse Function(RequestOptions) handler,
  ) {
    _handlers['$method $path'] = handler;
  }

  /// 注册正则匹配的 Mock
  void registerPattern(
    String pattern,
    MockResponse Function(RequestOptions, RegExpMatch) handler,
  ) {
    _handlers[pattern] = (options) {
      final key = '${options.method} ${options.path}';
      final match = RegExp(pattern).firstMatch(key);
      return handler(options, match!);
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!MockConfig.enabled) {
      handler.next(options);
      return;
    }

    final key = '${options.method} ${options.path}';
    MockResponse Function(RequestOptions)? mockHandler;

    // 精确匹配
    if (_handlers.containsKey(key)) {
      mockHandler = _handlers[key];
    } else {
      // 正则匹配
      for (var entry in _handlers.entries) {
        if (RegExp(entry.key).hasMatch(key)) {
          mockHandler = entry.value;
          break;
        }
      }
    }

    if (mockHandler != null) {
      _delayedResponse(options, handler, mockHandler);
    } else {
      handler.next(options);
    }
  }

  void _delayedResponse(
    RequestOptions options,
    RequestInterceptorHandler handler,
    MockResponse Function(RequestOptions) mockHandler,
  ) {
    // 随机延迟
    final delay = MockConfig.minDelay +
        _random.nextInt(MockConfig.maxDelay - MockConfig.minDelay);

    Future.delayed(Duration(milliseconds: delay), () {
      // 模拟错误
      if (_random.nextDouble() < MockConfig.errorRate) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'Mock 模拟网络错误',
        ));
        return;
      }

      final mockResponse = mockHandler(options);
      handler.resolve(Response(
        requestOptions: options,
        data: mockResponse.data,
        statusCode: mockResponse.statusCode,
        headers: Headers.fromMap(
          mockResponse.headers?.map((k, v) => MapEntry(k, [v])) ?? {},
        ),
      ));
    });
  }
}
```

### 使用示例

```dart
void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  
  // 开发环境启用 Mock
  if (kDebugMode) {
    MockConfig.enabled = true;
    MockConfig.minDelay = 300;
    MockConfig.maxDelay = 1000;
    // MockConfig.errorRate = 0.1; // 10% 错误率，测试错误处理
    
    dio.interceptors.add(MockInterceptor());
  }
  
  // 日志
  dio.interceptors.add(LogInterceptor(responseBody: true));
  
  runApp(MyApp(dio: dio));
}
```

---

## 方案对比

| 方案 | 适用场景 | 优点 | 缺点 |
|------|----------|------|------|
| 本地 JSON | 静态数据 | 简单直接 | 不支持动态逻辑 |
| Dio 拦截器 | 开发调试 | 无需修改业务代码 | 需要维护 Mock 数据 |
| http MockClient | 单元测试 | 官方支持 | 仅限 http 包 |
| json-server | 完整 API 模拟 | 功能完整、支持 CRUD | 需要 Node.js |
| Mockito | 单元测试 | 灵活强大 | 学习成本高 |

## 最佳实践

1. **开发环境**：Dio 拦截器 + json-server
2. **单元测试**：Mockito 或 http MockClient
3. **集成测试**：json-server 或真实测试环境
4. **生产环境**：确保禁用所有 Mock

## 相关资源

- [json-server](https://github.com/typicode/json-server)
- [Mockito](https://pub.dev/packages/mockito)
- [http testing](https://pub.dev/documentation/http/latest/testing/testing-library.html)
