# 网络请求

现代应用离不开网络请求。本章将介绍 Flutter 中的网络请求方案，从基础的 http 包到功能强大的 Dio。

## http 包（官方）

### 安装

```yaml
dependencies:
  http: ^1.1.0
```

### 基本使用

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// GET 请求
Future&lt;void&gt; fetchData() async {
  final response = await http.get(
    Uri.parse('https://api.example.com/users'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
  } else {
    throw Exception('请求失败: ${response.statusCode}');
  }
}

// POST 请求
Future&lt;void&gt; createUser(String name, String email) async {
  final response = await http.post(
    Uri.parse('https://api.example.com/users'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'email': email,
    }),
  );
  
  if (response.statusCode == 201) {
    print('创建成功');
  }
}

// 带查询参数
Future&lt;void&gt; searchUsers(String query) async {
  final uri = Uri.parse('https://api.example.com/users').replace(
    queryParameters: {'q': query, 'limit': '10'},
  );
  
  final response = await http.get(uri);
  // ...
}
```

## Dio（推荐）

Dio 是 Flutter 最流行的网络请求库，功能强大且易用。

### 安装

```yaml
dependencies:
  dio: ^5.4.0
```

### 基本使用

```dart
import 'package:dio/dio.dart';

final dio = Dio();

// GET 请求
Future&lt;void&gt; fetchUsers() async {
  try {
    final response = await dio.get('https://api.example.com/users');
    print(response.data);
  } on DioException catch (e) {
    print('请求错误: ${e.message}');
  }
}

// POST 请求
Future&lt;void&gt; createUser(Map&lt;String, dynamic&gt; data) async {
  final response = await dio.post(
    'https://api.example.com/users',
    data: data,
  );
  print(response.data);
}

// PUT 请求
Future&lt;void&gt; updateUser(String id, Map&lt;String, dynamic&gt; data) async {
  final response = await dio.put(
    'https://api.example.com/users/$id',
    data: data,
  );
  print(response.data);
}

// DELETE 请求
Future&lt;void&gt; deleteUser(String id) async {
  await dio.delete('https://api.example.com/users/$id');
}
```

### Dio 配置

```dart
class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  static Dio get instance => _dio;
}

// 使用
final response = await ApiClient.instance.get('/users');
```

### 请求参数

```dart
// 查询参数
await dio.get('/users', queryParameters: {
  'page': 1,
  'limit': 20,
  'sort': 'name',
});

// 路径参数
await dio.get('/users/$userId/posts');

// 请求体
await dio.post('/users', data: {
  'name': 'Alice',
  'email': 'alice@example.com',
});

// FormData（表单/文件上传）
final formData = FormData.fromMap({
  'name': 'Alice',
  'avatar': await MultipartFile.fromFile(
    '/path/to/file.jpg',
    filename: 'avatar.jpg',
  ),
});
await dio.post('/upload', data: formData);
```

## 拦截器

### 基本拦截器

```dart
class LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    handler.next(err);
  }
}

// 添加拦截器
dio.interceptors.add(LogInterceptor());
```

### Token 拦截器

```dart
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  
  AuthInterceptor(this._tokenStorage);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token 过期，尝试刷新
      try {
        await _refreshToken();
        // 重试原请求
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 刷新失败，跳转登录
        _tokenStorage.clear();
        // 导航到登录页...
      }
    }
    handler.next(err);
  }
  
  Future&lt;void&gt; _refreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    final response = await Dio().post(
      'https://api.example.com/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    await _tokenStorage.saveTokens(
      response.data['access_token'],
      response.data['refresh_token'],
    );
  }
  
  Future&lt;Response&gt; _retry(RequestOptions requestOptions) async {
    final token = await _tokenStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );
    return Dio().request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
```

### 缓存拦截器

```dart
class CacheInterceptor extends Interceptor {
  final Map&lt;String, CacheEntry&gt; _cache = {};
  final Duration _maxAge;
  
  CacheInterceptor({Duration maxAge = const Duration(minutes: 5)})
      : _maxAge = maxAge;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'GET') {
      final key = _generateKey(options);
      final cached = _cache[key];
      
      if (cached != null && !cached.isExpired) {
        // 返回缓存数据
        handler.resolve(Response(
          requestOptions: options,
          data: cached.data,
          statusCode: 200,
        ));
        return;
      }
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'GET') {
      final key = _generateKey(response.requestOptions);
      _cache[key] = CacheEntry(
        data: response.data,
        expiry: DateTime.now().add(_maxAge),
      );
    }
    handler.next(response);
  }
  
  String _generateKey(RequestOptions options) {
    return '${options.uri}';
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiry;
  
  CacheEntry({required this.data, required this.expiry});
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}
```

## 错误处理

### DioException 类型

```dart
Future&lt;void&gt; fetchData() async {
  try {
    final response = await dio.get('/data');
    return response.data;
  } on DioException catch (e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw NetworkException('连接超时');
      case DioExceptionType.sendTimeout:
        throw NetworkException('发送超时');
      case DioExceptionType.receiveTimeout:
        throw NetworkException('接收超时');
      case DioExceptionType.badResponse:
        _handleBadResponse(e.response!);
        break;
      case DioExceptionType.cancel:
        throw NetworkException('请求已取消');
      case DioExceptionType.connectionError:
        throw NetworkException('网络连接错误');
      case DioExceptionType.unknown:
        throw NetworkException('未知错误: ${e.message}');
      default:
        throw NetworkException('请求失败');
    }
  }
}

void _handleBadResponse(Response response) {
  switch (response.statusCode) {
    case 400:
      throw BadRequestException(response.data['message']);
    case 401:
      throw UnauthorizedException();
    case 403:
      throw ForbiddenException();
    case 404:
      throw NotFoundException();
    case 500:
      throw ServerException();
    default:
      throw NetworkException('HTTP ${response.statusCode}');
  }
}
```

### 统一错误处理

```dart
// 自定义异常
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class ServerException extends AppException {
  final int? statusCode;
  ServerException({this.statusCode}) : super('服务器错误');
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super('未授权，请重新登录');
}

// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapToAppException(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
    ));
  }
  
  AppException _mapToAppException(DioException err) {
    if (err.type == DioExceptionType.connectionError) {
      return NetworkException('网络连接失败，请检查网络');
    }
    
    final statusCode = err.response?.statusCode;
    if (statusCode == 401) {
      return UnauthorizedException();
    }
    
    return NetworkException(err.message ?? '请求失败');
  }
}
```

## 数据模型与序列化

### 手动序列化

```dart
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });
  
  factory User.fromJson(Map&lt;String, dynamic&gt; json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map&lt;String, dynamic&gt; toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// 使用
final response = await dio.get('/users/1');
final user = User.fromJson(response.data);
```

### 使用 json_serializable

```yaml
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
```

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });
  
  factory User.fromJson(Map&lt;String, dynamic&gt; json) => _$UserFromJson(json);
  
  Map&lt;String, dynamic&gt; toJson() => _$UserToJson(this);
}

// 运行生成命令
// dart run build_runner build
```

### 使用 freezed（推荐）

```yaml
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _User;
  
  factory User.fromJson(Map&lt;String, dynamic&gt; json) => _$UserFromJson(json);
}

// freezed 自动生成:
// - copyWith 方法
// - == 和 hashCode
// - toString
// - fromJson / toJson
```

## API 服务封装

### Repository 模式

```dart
// 抽象接口
abstract class UserRepository {
  Future&lt;List&lt;User&gt;&gt; getUsers({int page = 1, int limit = 20});
  Future&lt;User&gt; getUserById(String id);
  Future&lt;User&gt; createUser(CreateUserRequest request);
  Future&lt;User&gt; updateUser(String id, UpdateUserRequest request);
  Future&lt;void&gt; deleteUser(String id);
}

// 实现
class UserRepositoryImpl implements UserRepository {
  final Dio _dio;
  
  UserRepositoryImpl(this._dio);
  
  @override
  Future&lt;List&lt;User&gt;&gt; getUsers({int page = 1, int limit = 20}) async {
    final response = await _dio.get('/users', queryParameters: {
      'page': page,
      'limit': limit,
    });
    
    return (response.data['data'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }
  
  @override
  Future&lt;User&gt; getUserById(String id) async {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data);
  }
  
  @override
  Future&lt;User&gt; createUser(CreateUserRequest request) async {
    final response = await _dio.post('/users', data: request.toJson());
    return User.fromJson(response.data);
  }
  
  @override
  Future&lt;User&gt; updateUser(String id, UpdateUserRequest request) async {
    final response = await _dio.put('/users/$id', data: request.toJson());
    return User.fromJson(response.data);
  }
  
  @override
  Future&lt;void&gt; deleteUser(String id) async {
    await _dio.delete('/users/$id');
  }
}
```

### API 响应封装

```dart
@freezed
class ApiResponse&lt;T&gt; with _$ApiResponse&lt;T&gt; {
  const factory ApiResponse.success(T data) = _Success;
  const factory ApiResponse.error(String message, {int? code}) = _Error;
  const factory ApiResponse.loading() = _Loading;
}

// 使用
class UserService {
  final UserRepository _repository;
  
  UserService(this._repository);
  
  Future&lt;ApiResponse&lt;List&lt;User&gt;&gt;&gt; getUsers() async {
    try {
      final users = await _repository.getUsers();
      return ApiResponse.success(users);
    } on AppException catch (e) {
      return ApiResponse.error(e.message);
    }
  }
}

// UI 中使用
FutureBuilder&lt;ApiResponse&lt;List&lt;User&gt;&gt;&gt;(
  future: userService.getUsers(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    
    return snapshot.data!.when(
      success: (users) => UserList(users: users),
      error: (message, code) => ErrorWidget(message: message),
      loading: () => CircularProgressIndicator(),
    );
  },
)
```

## 请求取消

```dart
class SearchService {
  CancelToken? _cancelToken;
  
  Future&lt;List&lt;SearchResult&gt;&gt; search(String query) async {
    // 取消之前的请求
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    
    try {
      final response = await dio.get(
        '/search',
        queryParameters: {'q': query},
        cancelToken: _cancelToken,
      );
      
      return (response.data as List)
          .map((json) => SearchResult.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return [];  // 被取消，返回空
      }
      rethrow;
    }
  }
  
  void dispose() {
    _cancelToken?.cancel();
  }
}
```

## 文件上传下载

### 上传文件

```dart
Future&lt;String&gt; uploadFile(File file) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });
  
  final response = await dio.post(
    '/upload',
    data: formData,
    onSendProgress: (sent, total) {
      final progress = sent / total;
      print('上传进度: ${(progress * 100).toStringAsFixed(1)}%');
    },
  );
  
  return response.data['url'];
}
```

### 下载文件

```dart
Future&lt;void&gt; downloadFile(String url, String savePath) async {
  await dio.download(
    url,
    savePath,
    onReceiveProgress: (received, total) {
      if (total != -1) {
        final progress = received / total;
        print('下载进度: ${(progress * 100).toStringAsFixed(1)}%');
      }
    },
  );
}
```

## 最佳实践

### 1. 使用单例 Dio 实例

```dart
class HttpClient {
  static Dio? _instance;
  
  static Dio get instance {
    _instance ??= Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ))
      ..interceptors.addAll([
        AuthInterceptor(),
        LogInterceptor(),
        ErrorInterceptor(),
      ]);
    
    return _instance!;
  }
}
```

### 2. 环境配置

```dart
class AppConfig {
  static const String _devBaseUrl = 'https://dev-api.example.com';
  static const String _prodBaseUrl = 'https://api.example.com';
  
  static String get apiBaseUrl {
    return kReleaseMode ? _prodBaseUrl : _devBaseUrl;
  }
}
```

### 3. 超时重试

```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  
  RetryInterceptor({this.maxRetries = 3});
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: retryCount + 1));
        
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // 继续传递错误
        }
      }
    }
    handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           (err.response?.statusCode ?? 0) >= 500;
  }
}
```

## 下一步

掌握网络请求后，下一章我们将学习 [数据持久化](./09-storage)，本地存储和数据库操作。
