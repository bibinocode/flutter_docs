# PiliPala - B站第三方客户端

## 项目概览

| 项目信息 | 详情 |
|---------|------|
| **GitHub** | [guozhigq/pilipala](https://github.com/guozhigq/pilipala) |
| **Star** | 10k+ |
| **平台** | Android |
| **状态管理** | GetX |
| **主要功能** | B站视频播放、弹幕、直播 |

## 技术栈

### 核心技术
- **Flutter** + **Dart**
- **状态管理**: GetX (路由、状态、依赖注入)
- **本地存储**: Hive (高性能 NoSQL)
- **网络请求**: Dio
- **视频播放**: media_kit

### 依赖包
```yaml
dependencies:
  get: ^4.6.6                   # GetX 全家桶
  dio: ^5.4.1                   # 网络请求
  hive_flutter: ^1.1.0          # 本地存储
  media_kit: ^1.1.10            # 视频播放
  media_kit_video: ^1.2.4       # 视频 UI
  flutter_smart_dialog: ^4.9.5  # 弹窗
  extended_image: ^8.2.0        # 图片加载
  flutter_html: ^3.0.0-beta.2   # HTML 渲染
  webview_flutter: ^4.7.0       # WebView
```

## 项目结构

```
lib/
├── main.dart                   # 入口文件
├── router/                     # 路由管理
│   ├── app_pages.dart         # 路由定义
│   └── route_path.dart        # 路由路径常量
├── http/                       # 网络请求
│   ├── api.dart               # API 接口
│   ├── init.dart              # Dio 初始化
│   ├── interceptor.dart       # 拦截器
│   └── video.dart             # 视频相关 API
├── models/                     # 数据模型
│   ├── video/
│   │   ├── video_detail.dart
│   │   └── video_info.dart
│   ├── user/
│   │   └── user_info.dart
│   └── common/
│       └── response.dart
├── pages/                      # 页面
│   ├── home/                  # 首页
│   │   ├── index.dart
│   │   ├── controller.dart
│   │   └── view.dart
│   ├── video/                 # 视频详情
│   │   ├── index.dart
│   │   ├── controller.dart
│   │   ├── view.dart
│   │   └── widgets/
│   │       ├── video_player.dart
│   │       └── danmaku_panel.dart
│   ├── live/                  # 直播
│   │   ├── index.dart
│   │   └── controller.dart
│   ├── user/                  # 用户相关
│   │   ├── login/
│   │   └── profile/
│   └── setting/               # 设置
│       └── index.dart
├── utils/                      # 工具类
│   ├── utils.dart             # 通用工具
│   ├── storage.dart           # 存储工具
│   └── video_utils.dart       # 视频工具
├── common/                     # 公共资源
│   ├── constants.dart         # 常量
│   ├── skeleton.dart          # 骨架屏
│   └── widgets/               # 公共组件
│       ├── video_card.dart
│       └── network_img.dart
└── services/                   # 全局服务
    ├── user_service.dart      # 用户服务
    └── setting_service.dart   # 设置服务
```

## 学习要点

### 1. GetX 路由管理

完整的 GetX 路由配置：

```dart
// route_path.dart - 路由路径常量
class RoutePath {
  static const String home = '/';
  static const String video = '/video';
  static const String videoDetail = '/video/detail';
  static const String live = '/live';
  static const String user = '/user';
  static const String login = '/login';
  static const String setting = '/setting';
}

// app_pages.dart - 路由定义
class AppPages {
  static final pages = [
    GetPage(
      name: RoutePath.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: RoutePath.videoDetail,
      page: () => const VideoDetailPage(),
      binding: VideoDetailBinding(),
      // 页面过渡动画
      transition: Transition.cupertino,
    ),
    GetPage(
      name: RoutePath.live,
      page: () => const LivePage(),
      binding: LiveBinding(),
    ),
    GetPage(
      name: RoutePath.login,
      page: () => const LoginPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

// 路由中间件
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // 检查登录状态
    if (!UserService.to.isLogin && route != RoutePath.login) {
      return const RouteSettings(name: RoutePath.login);
    }
    return null;
  }
}
```

### 2. GetX 状态管理

Controller 模式管理页面状态：

```dart
// video_controller.dart
class VideoDetailController extends GetxController {
  // 响应式变量
  final videoDetail = Rxn<VideoDetail>();
  final isLoading = true.obs;
  final isPlaying = false.obs;
  final danmakuList = <Danmaku>[].obs;
  
  // 依赖注入
  final VideoHttp _videoHttp = Get.find();
  
  // 视频 ID
  late String bvid;
  
  @override
  void onInit() {
    super.onInit();
    bvid = Get.arguments['bvid'];
    fetchVideoDetail();
  }
  
  // 获取视频详情
  Future<void> fetchVideoDetail() async {
    try {
      isLoading.value = true;
      final result = await _videoHttp.getVideoDetail(bvid: bvid);
      if (result.code == 0) {
        videoDetail.value = result.data;
        await fetchDanmaku();
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // 获取弹幕
  Future<void> fetchDanmaku() async {
    final cid = videoDetail.value?.cid;
    if (cid == null) return;
    
    final result = await _videoHttp.getDanmaku(cid: cid);
    danmakuList.assignAll(result);
  }
  
  // 切换播放状态
  void togglePlay() {
    isPlaying.toggle();
  }
  
  @override
  void onClose() {
    // 清理资源
    super.onClose();
  }
}

// Binding 依赖绑定
class VideoDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoDetailController());
  }
}
```

### 3. GetX UI 绑定

使用 Obx 响应式更新 UI：

```dart
class VideoDetailPage extends GetView<VideoDetailController> {
  const VideoDetailPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const VideoSkeleton();
        }
        
        final video = controller.videoDetail.value;
        if (video == null) {
          return const ErrorWidget();
        }
        
        return CustomScrollView(
          slivers: [
            // 视频播放器
            SliverToBoxAdapter(
              child: VideoPlayer(
                url: video.playUrl,
                danmakuList: controller.danmakuList,
              ),
            ),
            // 视频信息
            SliverToBoxAdapter(
              child: VideoInfo(video: video),
            ),
            // 推荐视频
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => VideoCard(
                  video: video.related[index],
                  onTap: () => Get.toNamed(
                    RoutePath.videoDetail,
                    arguments: {'bvid': video.related[index].bvid},
                  ),
                ),
                childCount: video.related.length,
              ),
            ),
          ],
        );
      }),
    );
  }
}
```

### 4. Hive 本地存储

```dart
// storage.dart
class GStorage {
  static late Box _box;
  static late Box _historyBox;
  static late Box _settingBox;
  
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // 注册适配器
    Hive.registerAdapter(VideoHistoryAdapter());
    Hive.registerAdapter(UserInfoAdapter());
    
    _box = await Hive.openBox('app');
    _historyBox = await Hive.openBox('history');
    _settingBox = await Hive.openBox('setting');
  }
  
  // 观看历史
  static Box get historyBox => _historyBox;
  
  // 设置
  static Box get settingBox => _settingBox;
  
  // 用户信息
  static UserInfo? get userInfo => _box.get('userInfo');
  static set userInfo(UserInfo? info) => _box.put('userInfo', info);
  
  // 主题模式
  static int get themeMode => _settingBox.get('themeMode', defaultValue: 0);
  static set themeMode(int value) => _settingBox.put('themeMode', value);
  
  // 播放设置
  static bool get autoPlay => _settingBox.get('autoPlay', defaultValue: true);
  static set autoPlay(bool value) => _settingBox.put('autoPlay', value);
}

// 历史记录管理
class HistoryService extends GetxService {
  final historyList = <VideoHistory>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }
  
  void loadHistory() {
    final list = GStorage.historyBox.values.toList().cast<VideoHistory>();
    historyList.assignAll(list.reversed);
  }
  
  void addHistory(VideoHistory history) {
    // 删除重复项
    GStorage.historyBox.values
        .where((e) => e.bvid == history.bvid)
        .forEach((e) => e.delete());
    
    // 添加新记录
    GStorage.historyBox.add(history);
    loadHistory();
  }
  
  void clearHistory() {
    GStorage.historyBox.clear();
    historyList.clear();
  }
}
```

### 5. B站 API 封装

```dart
// api.dart
class Api {
  static const String baseUrl = 'https://api.bilibili.com';
  
  // 视频详情
  static const String videoDetail = '/x/web-interface/view';
  // 视频流
  static const String videoStream = '/x/player/playurl';
  // 弹幕
  static const String danmaku = '/x/v1/dm/list.so';
  // 用户信息
  static const String userInfo = '/x/web-interface/nav';
  // 推荐视频
  static const String recommend = '/x/web-interface/index/top/rcmd';
}

// video.dart
class VideoHttp {
  final Dio _dio;
  
  VideoHttp(this._dio);
  
  // 获取视频详情
  Future<ApiResponse<VideoDetail>> getVideoDetail({
    required String bvid,
  }) async {
    final response = await _dio.get(
      Api.videoDetail,
      queryParameters: {'bvid': bvid},
    );
    return ApiResponse.fromJson(
      response.data,
      (json) => VideoDetail.fromJson(json),
    );
  }
  
  // 获取视频流地址
  Future<ApiResponse<PlayUrl>> getPlayUrl({
    required int cid,
    required String bvid,
    int qn = 80, // 清晰度
  }) async {
    final response = await _dio.get(
      Api.videoStream,
      queryParameters: {
        'bvid': bvid,
        'cid': cid,
        'qn': qn,
        'fnval': 16, // DASH 格式
      },
    );
    return ApiResponse.fromJson(
      response.data,
      (json) => PlayUrl.fromJson(json),
    );
  }
  
  // 获取弹幕
  Future<List<Danmaku>> getDanmaku({required int cid}) async {
    final response = await _dio.get(
      Api.danmaku,
      queryParameters: {'oid': cid},
      options: Options(responseType: ResponseType.bytes),
    );
    
    // 解析弹幕 protobuf
    return DanmakuParser.parse(response.data);
  }
}
```

### 6. 全局服务

```dart
// user_service.dart
class UserService extends GetxService {
  static UserService get to => Get.find();
  
  final userInfo = Rxn<UserInfo>();
  final isLogin = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initUser();
  }
  
  void _initUser() {
    final info = GStorage.userInfo;
    if (info != null) {
      userInfo.value = info;
      isLogin.value = true;
    }
  }
  
  Future<bool> login(String cookie) async {
    try {
      // 验证 Cookie
      final response = await Get.find<UserHttp>().getUserInfo();
      if (response.code == 0) {
        userInfo.value = response.data;
        GStorage.userInfo = response.data;
        isLogin.value = true;
        return true;
      }
    } catch (e) {
      SmartDialog.showToast('登录失败');
    }
    return false;
  }
  
  void logout() {
    userInfo.value = null;
    GStorage.userInfo = null;
    isLogin.value = false;
    Get.offAllNamed(RoutePath.home);
  }
}

// main.dart 初始化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化存储
  await GStorage.init();
  
  // 初始化服务
  await Get.putAsync(() async => UserService());
  await Get.putAsync(() async => SettingService());
  
  // 初始化网络
  Get.put(Dio()..interceptors.add(AuthInterceptor()));
  Get.put(VideoHttp(Get.find()));
  Get.put(UserHttp(Get.find()));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PiliPala',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: RoutePath.home,
      getPages: AppPages.pages,
      builder: FlutterSmartDialog.init(),
    );
  }
}
```

## 架构亮点

1. **GetX 全家桶**: 路由、状态、依赖注入一体化
2. **Hive 高性能存储**: 快速读写观看历史
3. **B站 API 完整封装**: 视频、弹幕、直播
4. **弹幕系统**: 实时弹幕渲染
5. **多清晰度支持**: DASH 视频流解析

## 适合学习

- GetX 完整项目实践
- B站 API 使用方法
- 视频播放器开发
- 弹幕系统实现
- Hive 本地存储

## 运行项目

```bash
# 克隆项目
git clone https://github.com/guozhigq/pilipala.git
cd pilipala

# 安装依赖
flutter pub get

# 运行 (仅支持 Android)
flutter run
```

::: warning 注意事项
1. 需要自行获取 B站 Cookie 登录
2. 部分 API 需要登录才能使用
3. 视频播放需要网络环境良好
:::

::: tip 学习建议
1. 从路由配置开始理解 GetX
2. 研究视频详情页的完整流程
3. 学习弹幕解析和渲染
4. 参考存储模块设计本地缓存
:::
