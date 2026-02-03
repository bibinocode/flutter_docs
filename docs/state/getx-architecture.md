# GetX 架构与最佳实践

本章深入讲解 GetX 项目架构、目录组织、性能优化和生产级最佳实践。

## 推荐目录结构

### 小型项目

```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   ├── app_pages.dart      # 路由配置
│   │   └── app_routes.dart     # 路由名称常量
│   ├── bindings/
│   │   └── initial_binding.dart
│   └── theme/
│       └── app_theme.dart
├── modules/
│   ├── home/
│   │   ├── home_binding.dart
│   │   ├── home_controller.dart
│   │   └── home_view.dart
│   ├── login/
│   │   ├── login_binding.dart
│   │   ├── login_controller.dart
│   │   └── login_view.dart
│   └── profile/
│       ├── profile_binding.dart
│       ├── profile_controller.dart
│       └── profile_view.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── providers/
│   │   └── api_provider.dart
│   └── repositories/
│       └── user_repository.dart
└── core/
    ├── utils/
    │   └── helpers.dart
    ├── constants/
    │   └── api_constants.dart
    └── widgets/
        └── custom_button.dart
```

### 大型项目（Clean Architecture）

```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   ├── bindings/
│   │   └── initial_binding.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── translations/
│       ├── app_translations.dart
│       ├── en_us.dart
│       └── zh_cn.dart
│
├── modules/                    # 按功能模块划分
│   ├── auth/
│   │   ├── bindings/
│   │   │   ├── login_binding.dart
│   │   │   └── register_binding.dart
│   │   ├── controllers/
│   │   │   ├── login_controller.dart
│   │   │   └── register_controller.dart
│   │   ├── views/
│   │   │   ├── login_view.dart
│   │   │   └── register_view.dart
│   │   └── widgets/
│   │       └── auth_form.dart
│   │
│   ├── home/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   │
│   └── product/
│       ├── bindings/
│       ├── controllers/
│       ├── views/
│       └── widgets/
│
├── data/                       # 数据层
│   ├── models/                 # 数据模型
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   └── order_model.dart
│   │
│   ├── providers/              # API 调用
│   │   ├── api_provider.dart
│   │   ├── auth_provider.dart
│   │   └── product_provider.dart
│   │
│   ├── repositories/           # 仓储层（数据聚合）
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   └── product_repository.dart
│   │
│   └── services/               # 服务层
│       ├── storage_service.dart
│       ├── auth_service.dart
│       └── notification_service.dart
│
├── domain/                     # 领域层（可选）
│   ├── entities/
│   ├── usecases/
│   └── repositories/           # 抽象接口
│
└── core/                       # 核心工具
    ├── network/
    │   ├── api_client.dart
    │   ├── api_exceptions.dart
    │   └── api_interceptors.dart
    ├── utils/
    │   ├── validators.dart
    │   ├── formatters.dart
    │   └── extensions.dart
    ├── constants/
    │   ├── api_constants.dart
    │   ├── app_constants.dart
    │   └── storage_keys.dart
    └── widgets/
        ├── custom_button.dart
        ├── loading_widget.dart
        └── error_widget.dart
```

## 完整示例实现

### 1. 入口文件

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await initServices();
  
  runApp(const MyApp());
}

Future<void> initServices() async {
  print('Starting services...');
  
  // 初始化存储服务
  await Get.putAsync(() => StorageService().init());
  
  // 初始化 API 客户端
  Get.put(ApiClient());
  
  print('All services started!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX App',
      debugShowCheckedModeBanner: false,
      
      // 主题
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      
      // 国际化
      translations: AppTranslations(),
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('en', 'US'),
      
      // 路由
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      // 初始绑定
      initialBinding: InitialBinding(),
      
      // 默认过渡动画
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
```

### 2. 路由配置

```dart
// lib/app/routes/app_routes.dart
abstract class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const productDetail = '/product/:id';
  static const settings = '/settings';
}

// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/auth/bindings/login_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
// ... 其他导入

class AppPages {
  static const initial = Routes.splash;
  
  static final routes = [
    // 启动页
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    
    // 登录
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    
    // 注册
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    
    // 首页
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],  // 需要登录
    ),
    
    // 商品详情（带参数）
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
    ),
    
    // 设置（嵌套路由）
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      children: [
        GetPage(
          name: '/account',
          page: () => const AccountSettingsView(),
        ),
        GetPage(
          name: '/notification',
          page: () => const NotificationSettingsView(),
        ),
      ],
    ),
  ];
}
```

### 3. 路由中间件

```dart
// lib/app/middlewares/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;
  
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // 未登录则跳转到登录页
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
  
  @override
  GetPage? onPageCalled(GetPage? page) {
    print('Page called: ${page?.name}');
    return page;
  }
  
  @override
  Widget onPageBuilt(Widget page) {
    print('Page built: $page');
    return page;
  }
}
```

### 4. 初始绑定

```dart
// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Provider（API 调用层）
    Get.lazyPut<ApiProvider>(() => ApiProvider(), fenix: true);
    
    // Repository（数据仓储层）
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    
    // Service（全局服务）
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
```

### 5. API 客户端封装

```dart
// lib/core/network/api_client.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_interceptors.dart';
import 'api_exceptions.dart';

class ApiClient extends GetxService {
  late final Dio _dio;
  
  Dio get dio => _dio;
  
  @override
  void onInit() {
    super.onInit();
    
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // 添加拦截器
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
  
  // GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  // POST 请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  // PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  // DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

// lib/core/network/api_interceptors.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = Get.find<StorageService>().getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class LoggingInterceptor extends Interceptor {
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

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 401:
        // Token 过期，跳转登录
        Get.find<AuthService>().logout();
        Get.offAllNamed(Routes.login);
        break;
      case 403:
        Get.snackbar('错误', '没有权限访问');
        break;
      case 500:
        Get.snackbar('错误', '服务器错误，请稍后重试');
        break;
    }
    handler.next(err);
  }
}
```

### 6. 数据模型

```dart
// lib/data/models/user_model.dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime? createdAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 7. Repository 仓储层

```dart
// lib/data/repositories/user_repository.dart
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';

class UserRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  
  /// 获取当前用户信息
  Future<UserModel> getCurrentUser() async {
    final response = await _apiProvider.get('/user/profile');
    return UserModel.fromJson(response.data);
  }
  
  /// 更新用户信息
  Future<UserModel> updateUser(Map<String, dynamic> data) async {
    final response = await _apiProvider.put('/user/profile', data: data);
    return UserModel.fromJson(response.data);
  }
  
  /// 获取用户列表
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20}) async {
    final response = await _apiProvider.get(
      '/users',
      queryParameters: {'page': page, 'limit': limit},
    );
    
    final List<dynamic> data = response.data['data'];
    return data.map((json) => UserModel.fromJson(json)).toList();
  }
  
  /// 通过 ID 获取用户
  Future<UserModel> getUserById(int id) async {
    final response = await _apiProvider.get('/users/$id');
    return UserModel.fromJson(response.data);
  }
}
```

### 8. Controller 控制器

```dart
// lib/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/product_repository.dart';

class HomeController extends GetxController with StateMixin<HomeData> {
  final UserRepository _userRepo = Get.find<UserRepository>();
  final ProductRepository _productRepo = Get.find<ProductRepository>();
  
  // 状态
  final currentIndex = 0.obs;
  final searchQuery = ''.obs;
  
  // 数据
  UserModel? currentUser;
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  
  @override
  void onInit() {
    super.onInit();
    loadData();
    
    // 监听搜索
    debounce(searchQuery, _filterProducts, time: const Duration(milliseconds: 300));
  }
  
  /// 加载数据
  Future<void> loadData() async {
    change(null, status: RxStatus.loading());
    
    try {
      // 并行请求
      final results = await Future.wait([
        _userRepo.getCurrentUser(),
        _productRepo.getProducts(),
      ]);
      
      currentUser = results[0] as UserModel;
      products = results[1] as List<ProductModel>;
      filteredProducts = products;
      
      change(
        HomeData(user: currentUser!, products: products),
        status: RxStatus.success(),
      );
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
  
  /// 刷新数据
  Future<void> refreshData() async {
    await loadData();
  }
  
  /// 切换底部导航
  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  /// 搜索过滤
  void _filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = products;
    } else {
      filteredProducts = products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    update(['productList']);  // 精确更新
  }
  
  /// 跳转商品详情
  void goToProductDetail(ProductModel product) {
    Get.toNamed(
      Routes.productDetail.replaceFirst(':id', product.id.toString()),
      arguments: product,
    );
  }
}

class HomeData {
  final UserModel user;
  final List<ProductModel> products;
  
  HomeData({required this.user, required this.products});
}
```

### 9. View 视图层

```dart
// lib/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/product_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: controller.obx(
        // 成功状态
        (data) => RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              // 用户信息
              SliverToBoxAdapter(
                child: _buildUserHeader(data!.user),
              ),
              
              // 搜索框
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              
              // 商品列表
              GetBuilder<HomeController>(
                id: 'productList',
                builder: (c) => SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = c.filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => c.goToProductDetail(product),
                        );
                      },
                      childCount: c.filteredProducts.length,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 加载状态
        onLoading: const Center(child: CircularProgressIndicator()),
        
        // 错误状态
        onError: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.loadData,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        
        // 空状态
        onEmpty: const Center(child: Text('暂无数据')),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: '分类'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      )),
    );
  }
  
  Widget _buildUserHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user.avatar != null 
                ? NetworkImage(user.avatar!) 
                : null,
            child: user.avatar == null 
                ? Text(user.name[0].toUpperCase()) 
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '欢迎回来，${user.name}',
                style: Get.textTheme.titleMedium,
              ),
              Text(
                user.email,
                style: Get.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: '搜索商品...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: ProductSearchDelegate(),
    );
  }
}
```

### 10. Binding 绑定

```dart
// lib/modules/home/bindings/home_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/repositories/product_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    
    // Controller
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

## 性能优化

### 1. 精确更新

```dart
class OptimizedController extends GetxController {
  // ❌ 不好：整个列表都是响应式
  var items = <Item>[].obs;
  
  // ✅ 好：使用 GetBuilder + update([id]) 精确更新
  List<Item> items = [];
  
  void updateItem(int index, Item newItem) {
    items[index] = newItem;
    update(['item_$index']);  // 只更新特定项
  }
}

// View
GetBuilder<OptimizedController>(
  id: 'item_$index',
  builder: (c) => ItemWidget(item: c.items[index]),
)
```

### 2. 避免不必要的重建

```dart
class MyController extends GetxController {
  // ❌ 不好：每次 build 都创建新对象
  var user = User().obs;
  
  // ✅ 好：使用 Rx 扩展
  final _user = Rx<User?>(null);
  User? get user => _user.value;
  set user(User? value) => _user.value = value;
}

// View
// ❌ 不好：Obx 内部访问了 controller
Obx(() => Text('${Get.find<MyController>().user?.name}'))

// ✅ 好：在外部获取 controller 引用
final c = Get.find<MyController>();
Obx(() => Text('${c.user?.name}'))
```

### 3. 列表优化

```dart
class ListController extends GetxController {
  final items = <Item>[].obs;
  
  // ❌ 不好：频繁的小更新
  void addItems(List<Item> newItems) {
    for (var item in newItems) {
      items.add(item);  // 每次都触发更新
    }
  }
  
  // ✅ 好：批量更新
  void addItems(List<Item> newItems) {
    items.addAll(newItems);  // 一次更新
  }
  
  // ✅ 更好：替换整个列表
  void setItems(List<Item> newItems) {
    items.assignAll(newItems);  // 最高效
  }
}
```

### 4. 内存管理

```dart
class ResourceController extends GetxController {
  StreamSubscription? _subscription;
  Timer? _timer;
  
  @override
  void onInit() {
    super.onInit();
    
    // 订阅
    _subscription = someStream.listen((data) {
      // 处理数据
    });
    
    // 定时器
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshData();
    });
  }
  
  @override
  void onClose() {
    // ⚠️ 必须清理资源！
    _subscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
```

### 5. 使用 StateMixin

```dart
// 替代手动管理 loading/error/empty 状态
class ProductController extends GetxController with StateMixin<List<Product>> {
  
  Future<void> loadProducts() async {
    change(null, status: RxStatus.loading());
    
    try {
      final products = await repository.getProducts();
      
      if (products.isEmpty) {
        change(null, status: RxStatus.empty());
      } else {
        change(products, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}

// View
controller.obx(
  (products) => ListView.builder(...),
  onLoading: LoadingWidget(),
  onError: (error) => ErrorWidget(error: error),
  onEmpty: EmptyWidget(),
)
```

## 测试

### 1. Controller 测试

```dart
// test/modules/home/home_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late HomeController controller;
  late MockUserRepository mockUserRepo;
  late MockProductRepository mockProductRepo;
  
  setUp(() {
    Get.testMode = true;
    
    mockUserRepo = MockUserRepository();
    mockProductRepo = MockProductRepository();
    
    Get.put<UserRepository>(mockUserRepo);
    Get.put<ProductRepository>(mockProductRepo);
    
    controller = HomeController();
    Get.put(controller);
  });
  
  tearDown(() {
    Get.reset();
  });
  
  test('loadData should update state on success', () async {
    // Arrange
    final mockUser = UserModel(id: 1, name: 'Test', email: 'test@test.com');
    final mockProducts = [ProductModel(id: 1, name: 'Product 1')];
    
    when(mockUserRepo.getCurrentUser()).thenAnswer((_) async => mockUser);
    when(mockProductRepo.getProducts()).thenAnswer((_) async => mockProducts);
    
    // Act
    await controller.loadData();
    
    // Assert
    expect(controller.status.isSuccess, true);
    expect(controller.currentUser, mockUser);
    expect(controller.products.length, 1);
  });
  
  test('searchQuery should filter products', () async {
    // Arrange
    controller.products = [
      ProductModel(id: 1, name: 'Apple'),
      ProductModel(id: 2, name: 'Banana'),
    ];
    
    // Act
    controller.searchQuery.value = 'apple';
    await Future.delayed(const Duration(milliseconds: 400));  // 等待 debounce
    
    // Assert
    expect(controller.filteredProducts.length, 1);
    expect(controller.filteredProducts.first.name, 'Apple');
  });
}
```

### 2. Widget 测试

```dart
// test/modules/home/home_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });
  
  tearDown(() {
    Get.reset();
  });
  
  testWidgets('HomeView should display user name', (tester) async {
    // Arrange
    final controller = HomeController();
    controller.currentUser = UserModel(id: 1, name: 'John', email: 'john@test.com');
    Get.put(controller);
    
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: const HomeView(),
      ),
    );
    
    // Assert
    expect(find.text('欢迎回来，John'), findsOneWidget);
  });
}
```

## 常见问题

### Q: Get.find 找不到 Controller？

```dart
// ❌ 错误：Controller 未注入
final c = Get.find<MyController>();  // Error!

// ✅ 解决方案 1：确保先 put
Get.put(MyController());
final c = Get.find<MyController>();

// ✅ 解决方案 2：使用 Binding
class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyController>(() => MyController());
  }
}

// ✅ 解决方案 3：使用 fenix 参数（Controller 销毁后可重建）
Get.lazyPut<MyController>(() => MyController(), fenix: true);
```

### Q: Controller 被意外销毁？

```dart
// ❌ 问题：页面返回后 Controller 被销毁
GetPage(
  name: '/detail',
  page: () => DetailView(),
  binding: DetailBinding(),
);

// ✅ 解决方案 1：permanent 标记
Get.put(MyController(), permanent: true);

// ✅ 解决方案 2：使用 SmartManagement
GetMaterialApp(
  smartManagement: SmartManagement.keepFactory,  // 保留工厂
);
```

### Q: 如何在非 Widget 中访问 Controller？

```dart
// ✅ 直接使用 Get.find
class SomeService {
  void doSomething() {
    final controller = Get.find<MyController>();
    controller.updateData();
  }
}

// ✅ 或通过参数传递
class SomeService {
  final MyController controller;
  SomeService(this.controller);
}
```

## 总结

| 场景 | 推荐方式 |
|------|---------|
| 简单计数器 | `.obs` + `Obx` |
| 表单输入 | `GetBuilder` + `update([id])` |
| 列表数据 | `StateMixin` + `obx` |
| 全局状态 | `Get.put(permanent: true)` |
| 页面状态 | `Binding` + `Get.lazyPut` |
| 异步数据 | `StateMixin` |

::: tip 最佳实践
1. **Controller 职责单一** - 一个页面一个 Controller
2. **使用 Binding** - 统一管理依赖注入
3. **精确更新** - 使用 `update([id])` 而非全量更新
4. **清理资源** - 在 `onClose` 中取消订阅和定时器
5. **错误处理** - 使用 `StateMixin` 统一处理加载/错误状态
:::
