# Dio 详解

Dio 是 Flutter/Dart 生态中最强大的 HTTP 网络请求库，支持拦截器、全局配置、FormData、请求取消、文件上传下载、超时设置、自定义适配器等功能。

## 安装

```yaml
dependencies:
  dio: ^5.9.1
```

```bash
flutter pub add dio
```

## 快速开始

### 基础使用

```dart
import 'package:dio/dio.dart';

final dio = Dio();

// GET 请求
void getRequest() async {
  final response = await dio.get('https://api.example.com/users');
  print(response.data);
}

// POST 请求
void postRequest() async {
  final response = await dio.post(
    'https://api.example.com/users',
    data: {'name': 'Flutter', 'age': 5},
  );
  print(response.data);
}
```

### 完整请求示例

```dart
// GET 请求带查询参数
final response = await dio.get(
  '/users',
  queryParameters: {'page': 1, 'limit': 10},
);

// POST 请求
final response = await dio.post('/users', data: {'name': 'John'});

// PUT 请求
final response = await dio.put('/users/1', data: {'name': 'Updated'});

// PATCH 请求
final response = await dio.patch('/users/1', data: {'age': 30});

// DELETE 请求
final response = await dio.delete('/users/1');

// HEAD 请求
final response = await dio.head('/users');

// 并发请求
final responses = await Future.wait([
  dio.get('/users'),
  dio.get('/posts'),
]);
```

---

## 全局配置

### 创建 Dio 实例

推荐在项目中使用单例模式管理 Dio 实例：

```dart
import 'package:dio/dio.dart';

class Http {
  static final Http _instance = Http._internal();
  factory Http() => _instance;
  
  late Dio dio;
  
  Http._internal() {
    dio = Dio(BaseOptions(
      // 基础 URL
      baseUrl: 'https://api.example.com',
      // 连接超时
      connectTimeout: Duration(seconds: 10),
      // 接收超时
      receiveTimeout: Duration(seconds: 15),
      // 发送超时
      sendTimeout: Duration(seconds: 10),
      // 请求头
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // 响应类型
      responseType: ResponseType.json,
    ));
  }
}

// 使用
final http = Http();
final response = await http.dio.get('/users');
```

### BaseOptions 配置项

```dart
final options = BaseOptions(
  // 基础 URL，请求时会与 path 拼接
  baseUrl: 'https://api.example.com/v1',
  
  // 请求方法，默认 GET
  method: 'GET',
  
  // 超时设置
  connectTimeout: Duration(seconds: 5),   // 连接超时
  receiveTimeout: Duration(seconds: 3),   // 接收超时
  sendTimeout: Duration(seconds: 3),      // 发送超时
  
  // 请求头
  headers: {
    'Authorization': 'Bearer token',
    'User-Agent': 'MyApp/1.0',
  },
  
  // 响应类型
  responseType: ResponseType.json,  // json, stream, plain, bytes
  
  // 内容类型
  contentType: Headers.jsonContentType,
  
  // 状态码验证
  validateStatus: (status) => status != null && status < 500,
  
  // 是否跟随重定向
  followRedirects: true,
  maxRedirects: 5,
  
  // 请求数据编码
  listFormat: ListFormat.multi,  // 数组参数格式
);
```

---

## 请求配置 Options

单次请求可以覆盖全局配置：

```dart
final response = await dio.get(
  '/users',
  options: Options(
    // 覆盖超时
    receiveTimeout: Duration(seconds: 30),
    // 覆盖请求头
    headers: {'X-Custom-Header': 'value'},
    // 自定义响应类型
    responseType: ResponseType.plain,
    // 额外参数（可在拦截器中获取）
    extra: {'showLoading': true, 'retry': 3},
  ),
);
```

---

## 响应数据 Response

```dart
final response = await dio.get('/users/1');

// 响应数据（已根据 responseType 自动解析）
print(response.data);           // Map 或 List

// 响应头
print(response.headers);        // Headers
print(response.headers.value('content-type'));

// 状态信息
print(response.statusCode);     // 200
print(response.statusMessage);  // OK

// 请求配置
print(response.requestOptions); // RequestOptions

// 重定向信息
print(response.isRedirect);
print(response.redirects);

// 额外数据
print(response.extra);
```

---

## 拦截器

拦截器是 Dio 最强大的功能之一，可以在请求/响应/错误时进行统一处理。

### 基础拦截器

```dart
dio.interceptors.add(
  InterceptorsWrapper(
    // 请求拦截
    onRequest: (options, handler) {
      print('REQUEST[${options.method}] => ${options.uri}');
      // 添加 token
      options.headers['Authorization'] = 'Bearer $token';
      // 继续请求
      handler.next(options);
    },
    // 响应拦截
    onResponse: (response, handler) {
      print('RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
      // 继续响应
      handler.next(response);
    },
    // 错误拦截
    onError: (error, handler) {
      print('ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
      // 继续错误
      handler.next(error);
    },
  ),
);
```

### 自定义拦截器类

```dart
class AuthInterceptor extends Interceptor {
  final TokenManager tokenManager;
  
  AuthInterceptor(this.tokenManager);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenManager.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Token 过期，尝试刷新
    if (err.response?.statusCode == 401) {
      try {
        await tokenManager.refreshToken();
        // 重新发起请求
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 刷新失败，跳转登录
        tokenManager.logout();
      }
    }
    handler.next(err);
  }
}

// 使用
dio.interceptors.add(AuthInterceptor(tokenManager));
```

### 日志拦截器

```dart
// 使用内置日志拦截器
dio.interceptors.add(LogInterceptor(
  request: true,
  requestHeader: true,
  requestBody: true,
  responseHeader: true,
  responseBody: true,
  error: true,
  logPrint: (log) => debugPrint(log.toString()),
));
```

### 重试拦截器

```dart
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  
  RetryInterceptor({required this.dio, this.maxRetries = 3});
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;
    
    // 检查是否需要重试
    if (_shouldRetry(err) && retryCount < maxRetries) {
      extra['retryCount'] = retryCount + 1;
      
      // 延迟重试（指数退避）
      await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
      
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 重试失败，继续抛出错误
      }
    }
    
    handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.response?.statusCode == 503;
  }
}
```

### 缓存拦截器

```dart
class CacheInterceptor extends Interceptor {
  final Map<String, Response> _cache = {};
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 只缓存 GET 请求
    if (options.method == 'GET') {
      final key = options.uri.toString();
      if (_cache.containsKey(key)) {
        // 返回缓存
        handler.resolve(_cache[key]!);
        return;
      }
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 缓存成功的 GET 响应
    if (response.requestOptions.method == 'GET' &&
        response.statusCode == 200) {
      final key = response.requestOptions.uri.toString();
      _cache[key] = response;
    }
    handler.next(response);
  }
  
  void clearCache() => _cache.clear();
}
```

### QueuedInterceptor

当需要拦截器按顺序执行时（如 Token 刷新），使用 `QueuedInterceptor`：

```dart
class TokenRefreshInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenManager tokenManager;
  bool _isRefreshing = false;
  
  TokenRefreshInterceptor(this.dio, this.tokenManager);
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      
      try {
        await tokenManager.refreshToken();
        _isRefreshing = false;
        
        // 重新发起原请求
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        _isRefreshing = false;
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
```

---

## 错误处理

### DioException 类型

```dart
try {
  final response = await dio.get('/users');
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      print('连接超时');
      break;
    case DioExceptionType.sendTimeout:
      print('发送超时');
      break;
    case DioExceptionType.receiveTimeout:
      print('接收超时');
      break;
    case DioExceptionType.badCertificate:
      print('证书错误');
      break;
    case DioExceptionType.badResponse:
      print('响应错误: ${e.response?.statusCode}');
      break;
    case DioExceptionType.cancel:
      print('请求取消');
      break;
    case DioExceptionType.connectionError:
      print('连接错误');
      break;
    case DioExceptionType.unknown:
      print('未知错误: ${e.error}');
      break;
  }
}
```

### 封装统一错误处理

```dart
class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic data;
  
  ApiException(this.message, {this.code, this.data});
  
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('网络连接超时，请稍后重试');
      case DioExceptionType.connectionError:
        return ApiException('网络连接失败，请检查网络');
      case DioExceptionType.cancel:
        return ApiException('请求已取消');
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      default:
        return ApiException('网络异常，请稍后重试');
    }
  }
  
  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    
    // 尝试从响应体获取错误信息
    String message = '请求失败';
    if (data is Map && data.containsKey('message')) {
      message = data['message'];
    }
    
    switch (statusCode) {
      case 400:
        return ApiException('请求参数错误', code: 400, data: data);
      case 401:
        return ApiException('登录已过期，请重新登录', code: 401);
      case 403:
        return ApiException('没有权限访问', code: 403);
      case 404:
        return ApiException('请求的资源不存在', code: 404);
      case 500:
        return ApiException('服务器错误，请稍后重试', code: 500);
      default:
        return ApiException(message, code: statusCode, data: data);
    }
  }
  
  @override
  String toString() => message;
}
```

---

## 文件上传

### 单文件上传

```dart
Future<void> uploadFile() async {
  final formData = FormData.fromMap({
    'name': 'avatar',
    'file': await MultipartFile.fromFile(
      '/path/to/file.jpg',
      filename: 'avatar.jpg',
    ),
  });
  
  final response = await dio.post(
    '/upload',
    data: formData,
    onSendProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(1);
      print('上传进度: $progress%');
    },
  );
  
  print('上传成功: ${response.data}');
}
```

### 多文件上传

```dart
Future<void> uploadMultipleFiles(List<String> filePaths) async {
  final formData = FormData();
  
  // 添加普通字段
  formData.fields.add(MapEntry('description', '批量上传'));
  
  // 添加多个文件
  for (var i = 0; i < filePaths.length; i++) {
    formData.files.add(MapEntry(
      'files',
      await MultipartFile.fromFile(
        filePaths[i],
        filename: 'file_$i.jpg',
      ),
    ));
  }
  
  final response = await dio.post('/upload/batch', data: formData);
  print('批量上传成功');
}
```

### 从内存上传

```dart
// 上传字节数据
final bytes = Uint8List.fromList([0, 1, 2, 3]);
final formData = FormData.fromMap({
  'file': MultipartFile.fromBytes(
    bytes,
    filename: 'data.bin',
  ),
});

// 上传字符串
final formData = FormData.fromMap({
  'file': MultipartFile.fromString(
    'Hello World',
    filename: 'hello.txt',
  ),
});
```

---

## 文件下载

### 基础下载

```dart
Future<void> downloadFile() async {
  final savePath = '/path/to/save/file.zip';
  
  await dio.download(
    'https://example.com/file.zip',
    savePath,
    onReceiveProgress: (received, total) {
      if (total != -1) {
        final progress = (received / total * 100).toStringAsFixed(1);
        print('下载进度: $progress%');
      }
    },
  );
  
  print('下载完成: $savePath');
}
```

### 断点续传

```dart
Future<void> resumeDownload(String url, String savePath) async {
  final file = File(savePath);
  int downloadedBytes = 0;
  
  // 检查已下载的部分
  if (await file.exists()) {
    downloadedBytes = await file.length();
  }
  
  await dio.download(
    url,
    savePath,
    options: Options(
      headers: {
        // 设置断点续传的起始位置
        'Range': 'bytes=$downloadedBytes-',
      },
    ),
    // 追加模式
    deleteOnError: false,
    onReceiveProgress: (received, total) {
      final actualTotal = total + downloadedBytes;
      final actualReceived = received + downloadedBytes;
      final progress = (actualReceived / actualTotal * 100).toStringAsFixed(1);
      print('下载进度: $progress%');
    },
  );
}
```

---

## 请求取消

```dart
// 创建取消令牌
final cancelToken = CancelToken();

// 发起请求
dio.get('/users', cancelToken: cancelToken).then((response) {
  print('请求成功');
}).catchError((e) {
  if (CancelToken.isCancel(e)) {
    print('请求被取消: ${e.message}');
  }
});

// 取消请求
cancelToken.cancel('用户取消了请求');
```

### 批量取消

```dart
class RequestManager {
  final Map<String, CancelToken> _tokens = {};
  
  CancelToken createToken(String tag) {
    // 取消同标签的旧请求
    cancelByTag(tag);
    
    final token = CancelToken();
    _tokens[tag] = token;
    return token;
  }
  
  void cancelByTag(String tag) {
    _tokens[tag]?.cancel('取消请求: $tag');
    _tokens.remove(tag);
  }
  
  void cancelAll() {
    for (var token in _tokens.values) {
      token.cancel('取消所有请求');
    }
    _tokens.clear();
  }
}
```

---

## 代理设置

```dart
import 'package:dio/io.dart';

void setupProxy() {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.findProxy = (uri) {
        // 设置代理
        return 'PROXY localhost:8888';
      };
      // 忽略证书验证（仅开发环境）
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );
}
```

---

## HTTPS 证书验证

```dart
void setupCertificateVerification() {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient(
        context: SecurityContext(withTrustedRoots: false),
      );
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
    validateCertificate: (cert, host, port) {
      if (cert == null) return false;
      // 验证证书指纹
      final fingerprint = sha256.convert(cert.der).toString();
      return fingerprint == 'expected_fingerprint';
    },
  );
}
```

---

## 完整封装示例

```dart
import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late Dio _dio;
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com/v1',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    // 认证拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = TokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token 过期处理
          TokenStorage.clear();
          // 跳转登录...
        }
        handler.next(error);
      },
    ));
    
    // 日志拦截器（仅 debug 模式）
    assert(() {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
      return true;
    }());
  }
  
  // GET 请求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
  
  // POST 请求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
  
  // PUT 请求
  Future<T> put<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
  
  // DELETE 请求
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
  
  // 文件上传
  Future<T> upload<T>(
    String path,
    String filePath, {
    String? filename,
    Map<String, dynamic>? extraData,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      ...?extraData,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filename,
      ),
    });
    
    return post<T>(
      path,
      data: formData,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
  
  // 文件下载
  Future<void> download(
    String url,
    String savePath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

// 使用示例
void main() async {
  final api = ApiClient();
  
  try {
    // GET
    final users = await api.get<List>('/users');
    print('用户数: ${users.length}');
    
    // POST
    final newUser = await api.post<Map>('/users', data: {
      'name': 'John',
      'email': 'john@example.com',
    });
    print('创建用户: ${newUser['id']}');
    
    // 上传
    await api.upload(
      '/upload',
      '/path/to/file.jpg',
      onProgress: (sent, total) {
        print('上传: ${(sent / total * 100).toStringAsFixed(1)}%');
      },
    );
    
  } on ApiException catch (e) {
    print('API 错误: ${e.message}');
  }
}
```

---

## 最佳实践

1. **使用单例模式** - 全局共享一个 Dio 实例
2. **配置合理超时** - 根据接口特性设置不同超时时间
3. **统一拦截器处理** - Token 注入、错误处理、日志记录
4. **封装错误类型** - 便于 UI 层展示友好提示
5. **支持请求取消** - 页面销毁时取消未完成请求
6. **日志仅开发环境** - 使用 `assert` 或条件编译

## 相关资源

- [Dio 官方文档](https://pub.dev/packages/dio)
- [Dio GitHub](https://github.com/cfug/dio)
- [Dio 插件列表](https://pub.dev/documentation/dio/latest/topics/Plugins-topic.html)
