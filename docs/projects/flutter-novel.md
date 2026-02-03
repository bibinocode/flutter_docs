# Flutter Novel - 小说阅读器

## 项目概览

| 项目信息 | 详情 |
|---------|------|
| **GitHub** | [fluttercandies/flutter_novel](https://github.com/fluttercandies/flutter_novel) |
| **Star** | 1k+ |
| **平台** | Android, iOS, Web, Desktop |
| **状态管理** | Riverpod (with code generation) |
| **主要功能** | 小说阅读、多书源、收藏、历史记录 |

## 技术栈

### 核心技术
- **Flutter** + **Dart**
- **状态管理**: Riverpod + riverpod_annotation (代码生成)
- **路由管理**: auto_route (自动路由生成)
- **本地存储**: SharedPreferences
- **网络请求**: Dio

### 依赖包
```yaml
dependencies:
  flutter_riverpod: ^2.5.1        # 状态管理
  riverpod_annotation: ^2.3.5     # Riverpod 代码生成
  auto_route: ^7.8.0              # 路由管理
  dio: ^5.4.1                     # 网络请求
  flutter_smart_dialog: ^4.9.5    # 弹窗组件
  extended_image: ^8.2.0          # 图片加载
  extended_text: ^10.0.0          # 富文本
  wechat_assets_picker: ^9.0.0    # 图片选择
  carousel_slider: ^4.2.1         # 轮播图
  window_manager: ^0.3.9          # 桌面窗口管理
  
dev_dependencies:
  riverpod_generator: ^2.4.0      # Riverpod 生成器
  auto_route_generator: ^7.3.0    # 路由生成器
  build_runner: ^2.4.9            # 代码生成
```

## 项目结构

```
lib/
├── main.dart                      # 入口文件
├── frame.dart                     # 主框架 (底部导航)
├── assets/                        # 本地资源生成
├── base/                          # 基础类
│   └── base_state.dart           # 状态基类
├── db/                            # 数据缓存
│   └── preferences_db.dart       # SharedPreferences 封装
├── entry/                         # 通用实体
│   └── book_source_entry.dart    # 书源配置
├── icons/                         # 图标
│   └── novel_icon_icons.dart     # 自定义图标
├── net/                           # 网络请求
│   ├── http_config.dart          # 配置
│   ├── novel_http.dart           # HTTP 封装
│   ├── new_novel_http.dart       # 新版 HTTP
│   ├── net_state.dart            # 网络状态
│   └── service_result.dart       # 响应封装
├── route/                         # 路由
│   ├── route.dart                # 路由配置
│   └── route.gr.dart             # 生成的路由
├── theme/                         # 主题
│   └── theme_style.dart          # 主题样式
├── tools/                         # 工具类
│   ├── logger_tools.dart         # 日志
│   ├── parse_source_rule.dart    # 书源解析
│   ├── padding_extension.dart    # Padding 扩展
│   └── size_extension.dart       # Size 扩展
├── widget/                        # 公共组件
│   ├── empty.dart                # 空状态
│   ├── loading.dart              # 加载状态
│   ├── image.dart                # 图片组件
│   ├── net_state_tools.dart      # 网络状态组件
│   └── special_text_span_builder.dart  # 特殊文本
├── n_pages/                       # 新版页面 (推荐)
│   ├── home/                     # 首页
│   │   ├── view/home_page.dart
│   │   ├── view_model/home_view_model.dart
│   │   └── state/home_state.dart
│   ├── search/                   # 搜索
│   │   ├── view/search_page.dart
│   │   ├── view_model/search_view_model.dart
│   │   └── entry/search_entry.dart
│   ├── detail/                   # 书籍详情
│   │   ├── view/detail_page.dart
│   │   ├── view_model/detail_view_model.dart
│   │   ├── state/detail_state.dart
│   │   └── entry/detail_book_entry.dart
│   ├── read/                     # 阅读页
│   │   ├── view/read_page.dart
│   │   ├── view_model/read_view_model.dart
│   │   └── state/read_state.dart
│   ├── history/                  # 历史记录
│   │   ├── view/history_page.dart
│   │   ├── view_model/history_view_model.dart
│   │   └── state/history_state.dart
│   └── like/                     # 收藏书架
│       └── view/like_page.dart
└── pages/                         # 旧版页面 (已废弃)
    └── ...
```

## 学习要点

### 1. Riverpod 代码生成模式

使用 `@riverpod` 注解自动生成 Provider：

```dart
// detail_view_model.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'detail_view_model.g.dart';

/// 详情搜索
/// 时间 2024-10-1
/// 7-bit
@riverpod
class NewDetailViewModel extends _$NewDetailViewModel {
  /// 书源
  late BookSourceEntry bookSourceEntry;
  
  final DetailState detailState = DetailState();
  
  /// 排序顺序
  late bool reverse = false;
  
  /// 阅读索引
  late int readIndex = 0;

  @override
  Future<DetailState> build({
    required String detailUrl,
    required BookSourceEntry bookSource,
  }) async {
    bookSourceEntry = bookSource;
    await _initData(detailUrl: detailUrl);
    return detailState;
  }

  /// 初始化数据
  Future<void> _initData({required String detailUrl}) async {
    // 获取书籍详情
    final result = await NewNovelHttp.getDetail(
      url: detailUrl,
      source: bookSourceEntry,
    );
    detailState.detailBookEntry = result;
    detailState.netState = NetState.success;
  }

  /// 获取阅读索引
  int getReadIndex() => readIndex;
  
  /// 设置阅读索引
  void setReadIndex(Chapter chapter) {
    final list = detailState.detailBookEntry?.chapter;
    if (list != null) {
      readIndex = list.indexOf(chapter);
    }
  }
}

// 使用生成的 Provider
final detailViewModel = ref.watch(
  NewDetailViewModelProvider(
    detailUrl: widget.searchEntry.url ?? "",
    bookSource: widget.bookSourceEntry,
  ),
);
```

### 2. auto_route 路由管理

声明式路由配置：

```dart
// route.dart
import 'package:auto_route/auto_route.dart';
import 'package:novel_flutter_bit/route/route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: NewSearchRoute.page),
    AutoRoute(page: NewDetailRoute.page),
    AutoRoute(page: ReadRoute.page),
    AutoRoute(page: LikeRoute.page),
    AutoRoute(page: HistoryRoute.page),
    AutoRoute(page: ImagePreviewRoute.page),
    AutoRoute(page: ColorPreviewRoute.page),
    AutoRoute(page: FrameRoute.page),
  ];
}

// 页面声明
@RoutePage()
class ReadPage extends ConsumerStatefulWidget {
  ReadPage({
    super.key,
    required this.searchEntry,
    required this.chapter,
    required this.source,
    this.chapterList,
  });
  
  late Chapter chapter;
  final BookSourceEntry source;
  final SearchEntry searchEntry;
  final List<Chapter>? chapterList;
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReadPageState();
}

// 路由跳转
context.router.push(ReadRoute(
  searchEntry: searchEntry,
  chapter: chapter,
  source: bookSource,
  chapterList: chapterList,
));

// 路由替换
context.router.replace(NovelRoute(
  url: data?.url ?? "",
  name: data?.name ?? "",
  bookDatum: widget.bookDatum,
));
```

### 3. 状态基类设计

统一的状态基类管理网络状态：

```dart
// base_state.dart
class BaseState {
  NetState netState = NetState.loading;
}

// 网络状态枚举
enum NetState {
  loading,
  success,
  error,
  empty,
}

// 具体状态继承
class DetailState extends BaseState {
  DetailBookEntry? detailBookEntry;
}

class ReadState extends BaseState {
  String? content;
  List<String>? listContent;
  List<Chapter>? chapterList;
  Uint8List? backgroundImage;
  int? backgroundColor;
  int? textColor;
}

// 状态 Widget 工具
class NetStateTools {
  static Widget? getWidget(NetState state) {
    switch (state) {
      case NetState.loading:
        return const LoadingBuild();
      case NetState.error:
        return const ErrorBuild();
      case NetState.empty:
        return const EmptyBuild();
      case NetState.success:
        return null; // 返回 null 表示使用业务 Widget
    }
  }
}

// 在 UI 中使用
switch (readViewModel) {
  AsyncData(:final value) => Builder(builder: (BuildContext context) {
    Widget? child = NetStateTools.getWidget(value.netState);
    if (child != null) {
      return child;
    }
    return _buildSuccess(value: value, style: _style);
  }),
  AsyncError() => EmptyBuild(),
  _ => const LoadingBuild(),
}
```

### 4. 阅读页面实现

完整的小说阅读器实现：

```dart
class _ReadPageState extends ConsumerState<ReadPage> {
  ThemeData get _themeData => Theme.of(context);
  
  /// 特殊文本构建器
  final NovelSpecialTextSpanBuilder _specialTextSpanBuilder =
      NovelSpecialTextSpanBuilder(color: Colors.black);
  
  late TextStyle _style;
  
  /// 动画时长
  final Duration _duration = const Duration(milliseconds: 400);
  
  /// 控制AppBar和BottomNavigationBar的可见性
  bool _isAppBarVisible = false;
  bool _isBottomBarVisible = false;
  
  /// 轮播图控制器 (翻页模式)
  late CarouselSliderController _carouselSliderController;
  
  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// 初始化数据
  _initData() async {
    _carouselSliderController = CarouselSliderController();
    _initFont();
    _chapter = widget.chapter;
    _detailViewModel = ref.read(NewDetailViewModelProvider(
      detailUrl: widget.searchEntry.url ?? "",
      bookSource: widget.source,
    ).notifier);
  }

  /// 初始化字体
  _initFont() async {
    final size = await PreferencesDB.instance.getNovelFontSize();
    NovelReadState.size = size;
    _style = TextStyle(
      fontSize: NovelReadState.size,
      height: 2,
      color: NovelReadState.textColor,
      fontWeight: NovelReadState.weight.weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildInitData();
    final readViewModel = ref.watch(readViewModelProvider(
      chapter1: widget.chapter,
      bookSource: widget.source,
      chapterList: widget.chapterList,
      detailView: _detailViewModel,
      searchEntry: widget.searchEntry,
    ));
    
    return Container(
      color: Colors.white,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: NovelReadState.bgColor,
        appBar: _buildAppBar(
          height: appbarHeight,
          minHeight: 40,
          duration: _duration,
          isAppBarVisible: _isAppBarVisible,
        ),
        body: switch (readViewModel) {
          AsyncData(:final value) => _buildSuccess(value: value, style: _style),
          AsyncError() => EmptyBuild(),
          _ => const LoadingBuild(),
        },
        bottomNavigationBar: _buildBottmAppBar(
          height: 100,
          minHeight: 0,
          duration: _duration,
          isBottomBarVisible: _isBottomBarVisible,
        ),
      ),
    );
  }
}
```

### 5. 书源解析系统

支持多书源的解析规则：

```dart
// book_source_entry.dart
class BookSourceEntry {
  String? bookSourceUrl;
  String? bookSourceName;
  String? bookSourceGroup;
  String? bookSourceType;
  
  /// 搜索规则
  String? searchUrl;
  String? ruleSearch;
  
  /// 详情规则
  String? ruleBookInfo;
  
  /// 目录规则
  String? ruleToc;
  
  /// 内容规则
  String? ruleContent;
}

// parse_source_rule.dart
class ParseSourceRule {
  /// 解析搜索结果
  static List<SearchEntry> parseSearch(String html, BookSourceEntry source) {
    // 根据书源规则解析 HTML
    final doc = parse(html);
    // ... 解析逻辑
  }
  
  /// 解析书籍详情
  static DetailBookEntry parseDetail(String html, BookSourceEntry source) {
    // ... 解析逻辑
  }
  
  /// 解析章节内容
  static String parseContent(String html, BookSourceEntry source) {
    // ... 解析逻辑
  }
}
```

### 6. 阅读设置状态

全局阅读设置：

```dart
class NovelReadState {
  static double size = 18;
  static NovelReadFontWeightEnum weight = NovelReadFontWeightEnum.w300;
  static bool isChange = false;
  static Color textColor = const Color(0xff000000);
  static Color bgColor = const Color(0xfffafafa);
  static Color selectText = const Color(0xff000000);
  
  static void initFontWeight(String fontWeight) {
    if (fontWeight == NovelReadFontWeightEnum.w200.id) {
      weight = NovelReadFontWeightEnum.w200;
    } else if (fontWeight == NovelReadFontWeightEnum.w300.id) {
      weight = NovelReadFontWeightEnum.w300;
    }
    // ...
  }
}

// 字体粗细枚举
enum NovelReadFontWeightEnum {
  w200('w200', FontWeight.w200),
  w300('w300', FontWeight.w300),
  w400('w400', FontWeight.w400),
  w500('w500', FontWeight.w500);
  
  final String id;
  final FontWeight weight;
  
  const NovelReadFontWeightEnum(this.id, this.weight);
}
```

### 7. 扩展方法

简化代码的扩展方法：

```dart
// padding_extension.dart
extension PaddingExtension on num {
  EdgeInsets get padding => EdgeInsets.all(toDouble());
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: toDouble());
}

// size_extension.dart
extension SizeExtension on num {
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}

// 使用
Container(
  padding: 15.padding,
  margin: 8.padding,
)

Column(
  children: [
    Text('Hello'),
    10.verticalSpace,
    Text('World'),
  ],
)
```

## 架构亮点

1. **MVVM 架构**: View + ViewModel + State 分离
2. **代码生成**: Riverpod + auto_route 减少样板代码
3. **多书源支持**: 可配置的书源解析规则
4. **状态基类**: 统一的网络状态管理
5. **跨平台**: 支持 Android/iOS/Web/Desktop
6. **FlutterCandies 包**: 使用社区优质组件

## 适合学习

- Riverpod 代码生成模式
- auto_route 声明式路由
- 小说阅读器完整实现
- 多书源解析系统
- MVVM 架构实践

## 运行项目

```bash
# 克隆项目
git clone https://github.com/fluttercandies/flutter_novel.git
cd flutter_novel

# 安装依赖
flutter pub get

# 生成代码
dart run build_runner build

# 运行
flutter run
```

::: tip 学习建议
1. 从 `n_pages/` 目录开始学习 (新版代码)
2. 研究 ViewModel 和 State 的设计模式
3. 学习书源解析规则的实现
4. 参考阅读页面的交互设计
:::

::: warning 注意事项
1. `pages/` 目录已废弃，请参考 `n_pages/`
2. 运行前需要执行 `build_runner` 生成代码
3. 书源规则需要自行配置
:::
