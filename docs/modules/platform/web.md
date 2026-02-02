# Flutter Web 适配

Flutter 支持将应用编译为 Web 应用，可以运行在任何现代浏览器中。本章介绍 Web 平台的特性、限制和最佳实践。

## Web 渲染模式

Flutter Web 提供两种渲染模式：

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Web 渲染引擎                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────────────┐     ┌─────────────────────┐      │
│   │    HTML 渲染器       │     │    CanvasKit 渲染器  │      │
│   │  (html renderer)    │     │  (canvaskit)        │      │
│   ├─────────────────────┤     ├─────────────────────┤      │
│   │ • DOM + CSS + Canvas │     │ • WebGL + Skia      │      │
│   │ • 体积小 (~400KB)    │     │ • 体积大 (~2MB)      │      │
│   │ • 兼容性好           │     │ • 渲染一致性高       │      │
│   │ • 文本渲染原生       │     │ • 动画性能好         │      │
│   │ • 适合文本密集型     │     │ • 适合图形密集型     │      │
│   └─────────────────────┘     └─────────────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 选择渲染模式

```bash
# 使用 HTML 渲染器
flutter build web --web-renderer html

# 使用 CanvasKit 渲染器
flutter build web --web-renderer canvaskit

# 自动选择 (移动端用 HTML，桌面端用 CanvasKit)
flutter build web --web-renderer auto
```

### 渲染模式对比

| 特性 | HTML | CanvasKit |
|------|------|-----------|
| 首次加载大小 | ~400KB | ~2MB |
| 渲染一致性 | 中等 | 高 |
| 文本渲染 | 原生 | Skia |
| 动画性能 | 一般 | 优秀 |
| 浏览器兼容性 | 优秀 | 需要 WebGL |
| SEO 友好 | 较好 | 较差 |

## 平台检测

### 检测是否运行在 Web 平台

```dart
import 'package:flutter/foundation.dart';

class PlatformUtils {
  // 是否是 Web 平台
  static bool get isWeb => kIsWeb;
  
  // 条件导入示例
  static void doSomething() {
    if (kIsWeb) {
      // Web 特定代码
      print('Running on Web');
    } else {
      // 原生平台代码
      print('Running on Native');
    }
  }
}
```

### 条件导入

```dart
// platform_web.dart
String getPlatformInfo() => 'Web Platform';

// platform_native.dart
String getPlatformInfo() => 'Native Platform';

// platform_stub.dart (存根文件)
String getPlatformInfo() => throw UnimplementedError();

// 主文件中使用条件导入
export 'platform_stub.dart'
    if (dart.library.html) 'platform_web.dart'
    if (dart.library.io) 'platform_native.dart';
```

## Web 特有 API

### 访问 JavaScript

```dart
import 'dart:js_interop';

// 定义 JavaScript 绑定
@JS('console.log')
external void consoleLog(String message);

@JS('window.localStorage.getItem')
external String? localStorageGetItem(String key);

@JS('window.localStorage.setItem')
external void localStorageSetItem(String key, String value);

// 使用示例
void webExample() {
  if (kIsWeb) {
    consoleLog('Hello from Flutter Web!');
    localStorageSetItem('key', 'value');
  }
}
```

### 调用 JavaScript 函数

```dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

void callJavaScript() {
  // 调用全局函数
  final result = globalContext.callMethod('eval'.toJS, '1 + 2'.toJS);
  print(result); // 3
  
  // 访问 window 对象
  final location = globalContext['location'];
  print(location['href']);
}
```

### 嵌入 HTML 元素

```dart
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class HtmlElementView extends StatelessWidget {
  const HtmlElementView({super.key});

  @override
  Widget build(BuildContext context) {
    // 只在 Web 平台可用
    if (kIsWeb) {
      // 注册视图工厂
      ui_web.platformViewRegistry.registerViewFactory(
        'my-html-view',
        (int viewId) {
          final element = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.backgroundColor = 'lightblue'
            ..innerHtml = '<h1>Hello from HTML!</h1>';
          return element;
        },
      );

      return const HtmlElementView(viewType: 'my-html-view');
    }
    
    return const Text('Not supported on this platform');
  }
}
```

## URL 路由策略

### Hash 路由 vs Path 路由

```dart
// main.dart
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  // 使用 Path 路由 (推荐生产环境)
  // URL: https://example.com/home
  usePathUrlStrategy();
  
  // 或使用 Hash 路由 (默认)
  // URL: https://example.com/#/home
  // setUrlStrategy(HashUrlStrategy());
  
  runApp(const MyApp());
}
```

### 服务器配置 (Path 路由)

使用 Path 路由需要服务器配置，将所有路由指向 `index.html`：

**Nginx 配置：**
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

**Apache 配置 (.htaccess)：**
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

## SEO 优化

### 添加元数据

```html
<!-- web/index.html -->
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- SEO 元数据 -->
  <title>我的 Flutter 应用</title>
  <meta name="description" content="这是一个使用 Flutter 构建的 Web 应用">
  <meta name="keywords" content="Flutter, Web, App">
  
  <!-- Open Graph -->
  <meta property="og:title" content="我的 Flutter 应用">
  <meta property="og:description" content="这是一个使用 Flutter 构建的 Web 应用">
  <meta property="og:image" content="https://example.com/og-image.png">
  <meta property="og:url" content="https://example.com">
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="我的 Flutter 应用">
  <meta name="twitter:description" content="这是一个使用 Flutter 构建的 Web 应用">
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  
  <!-- 预加载关键资源 -->
  <link rel="preload" href="main.dart.js" as="script">
</head>
<body>
  <!-- 加载指示器 -->
  <div id="loading">
    <style>
      #loading {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        background: #ffffff;
      }
      .spinner {
        width: 50px;
        height: 50px;
        border: 3px solid #f3f3f3;
        border-top: 3px solid #3498db;
        border-radius: 50%;
        animation: spin 1s linear infinite;
      }
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
    </style>
    <div class="spinner"></div>
  </div>
  
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

### 动态更新页面标题

```dart
import 'package:flutter/services.dart';

class WebSeoHelper {
  static void updatePageTitle(String title) {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: title,
        primaryColor: 0xFF0175C2,
      ),
    );
  }
}

// 在页面中使用
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WebSeoHelper.updatePageTitle('首页 - 我的应用');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: const Center(child: Text('欢迎')),
    );
  }
}
```

## 性能优化

### 延迟加载

```dart
// 使用 deferred loading 延迟加载
import 'heavy_feature.dart' deferred as heavy;

class LazyLoadExample extends StatefulWidget {
  const LazyLoadExample({super.key});

  @override
  State<LazyLoadExample> createState() => _LazyLoadExampleState();
}

class _LazyLoadExampleState extends State<LazyLoadExample> {
  bool _isLoaded = false;

  Future<void> _loadFeature() async {
    await heavy.loadLibrary();
    setState(() => _isLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _loadFeature,
          child: const Text('加载功能'),
        ),
        if (_isLoaded) heavy.HeavyFeatureWidget(),
      ],
    );
  }
}
```

### 图片优化

```dart
class WebOptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const WebOptimizedImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      // Web 特定优化
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
      // 缓存优化
      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
      cacheHeight: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
    );
  }
}
```

### 构建优化

```bash
# 生产构建优化
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/ \
  --pwa-strategy offline-first

# Tree shaking 图标
flutter build web --tree-shake-icons
```

## Web 平台限制

### 不支持的功能

| 功能 | 状态 | 替代方案 |
|------|------|---------|
| 文件系统访问 | ❌ | 使用 File Picker / IndexedDB |
| 后台服务 | ❌ | Service Worker |
| 推送通知 | ⚠️ | Web Push API |
| 蓝牙 | ⚠️ | Web Bluetooth API |
| NFC | ❌ | 无 |
| 传感器 | ⚠️ | Web Sensors API |

### 处理不支持的插件

```dart
import 'package:flutter/foundation.dart';

class CrossPlatformService {
  Future<void> shareContent(String text) async {
    if (kIsWeb) {
      // Web 实现：使用 Web Share API
      await _webShare(text);
    } else {
      // 原生实现：使用 share_plus 插件
      // await Share.share(text);
    }
  }

  Future<void> _webShare(String text) async {
    // 调用 JavaScript Web Share API
    // 或显示自定义分享对话框
  }
}
```

## PWA 支持

### 配置 Service Worker

```javascript
// web/flutter_service_worker.js (Flutter 自动生成)

// 自定义 service-worker.js
const CACHE_NAME = 'my-app-cache-v1';
const urlsToCache = [
  '/',
  '/main.dart.js',
  '/flutter.js',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => response || fetch(event.request))
  );
});
```

### 配置 Manifest

```json
// web/manifest.json
{
  "name": "我的 Flutter 应用",
  "short_name": "Flutter App",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#0175C2",
  "description": "一个使用 Flutter 构建的 PWA 应用",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

## 调试技巧

### 使用浏览器开发者工具

```dart
// 在 Web 上打印调试信息
void debugOnWeb(String message) {
  if (kIsWeb && kDebugMode) {
    // 使用 console.log
    print('[DEBUG] $message');
    
    // 或使用 JavaScript console
    // js.context.callMethod('console', ['log', message]);
  }
}
```

### 热重载

```bash
# 启动开发服务器（支持热重载）
flutter run -d chrome --web-port 8080

# 使用特定渲染器
flutter run -d chrome --web-renderer html
```

## 部署

### 构建生产版本

```bash
# 构建生产版本
flutter build web --release

# 构建产物在 build/web 目录
```

### 部署到 Firebase Hosting

```bash
# 安装 Firebase CLI
npm install -g firebase-tools

# 登录
firebase login

# 初始化项目
firebase init hosting

# 部署
firebase deploy --only hosting
```

### 部署到 GitHub Pages

```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      
      - run: flutter pub get
      - run: flutter build web --release --base-href "/your-repo-name/"
      
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## 注意事项

::: tip 最佳实践
1. **选择合适的渲染器** - 文本密集型应用用 HTML，图形密集型用 CanvasKit
2. **优化首次加载** - 使用延迟加载、代码分割
3. **处理浏览器兼容性** - 测试主流浏览器
4. **配置 PWA** - 提供离线体验
5. **SEO 优化** - 添加元数据、使用 Path 路由
:::

::: warning 注意事项
- Web 平台不支持某些原生功能（文件系统、后台服务等）
- CanvasKit 渲染器需要加载较大的 WASM 文件
- 某些插件可能不支持 Web 平台
- 跨域请求需要服务器配置 CORS
:::
