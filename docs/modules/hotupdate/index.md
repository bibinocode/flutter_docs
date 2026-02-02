# Flutter 热更新方案

Flutter 热更新是指在不重新发布 App 的情况下，动态更新应用的 UI 或逻辑。由于 Flutter 使用 AOT 编译，原生热更新较为困难，但社区提供了多种解决方案。

## 方案概览

| 方案 | 原理 | 优点 | 缺点 | 推荐场景 |
|------|------|------|------|----------|
| Shorebird | Dart 补丁 | 官方背书、稳定 | 商业付费 | 生产环境 |
| Fair | DSL 转换 | 58同城开源、免费 | 学习成本高 | 复杂业务 |
| MXFlutter | JS 渲染 | 灵活 | 性能损耗 | 简单页面 |
| OTA Update | 整包更新 | 简单 | 体验差 | 小型应用 |
| Web 渲染 | WebView/H5 | 灵活度高 | 性能受限 | 运营页面 |

## Shorebird（推荐）

Shorebird 是 Flutter 官方团队成员创建的热更新解决方案，通过补丁机制实现代码热更新。

### 特点

- ✅ Dart 代码热更新
- ✅ 支持 Android 和 iOS
- ✅ 增量更新，补丁小
- ✅ 回滚支持
- ❌ 商业收费

### 安装

```bash
# macOS/Linux
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash

# 验证安装
shorebird --version
```

### 初始化项目

```bash
cd your_flutter_project
shorebird init
```

### 发布版本

```bash
# 发布 Android
shorebird release android

# 发布 iOS
shorebird release ios
```

### 推送补丁

```bash
# 推送 Android 补丁
shorebird patch android

# 推送 iOS 补丁
shorebird patch ios
```

### 集成示例

```dart
import 'package:shorebird_code_push/shorebird_code_push.dart';

class UpdateService {
  final _shorebirdCodePush = ShorebirdCodePush();
  
  /// 检查更新
  Future<void> checkForUpdate() async {
    final isUpdateAvailable = await _shorebirdCodePush.isNewPatchAvailableForDownload();
    
    if (isUpdateAvailable) {
      // 下载并安装补丁
      await _shorebirdCodePush.downloadUpdateIfAvailable();
      
      // 提示用户重启应用
      _showRestartDialog();
    }
  }
  
  /// 获取当前补丁版本
  Future<int?> getCurrentPatchNumber() async {
    return await _shorebirdCodePush.currentPatchNumber();
  }
}
```

## Fair（58同城）

Fair 是58同城开源的 Flutter 动态化框架，通过将 Widget 转换为 DSL（JSON），在运行时解析渲染。

### 特点

- ✅ 完全开源免费
- ✅ 支持复杂 Widget 树
- ✅ 支持逻辑动态化
- ❌ 学习曲线陡峭
- ❌ 需要额外编译步骤

### 安装

```yaml
dependencies:
  fair: ^3.3.0

dev_dependencies:
  fair_compiler: ^1.8.0
```

### 配置

**pubspec.yaml**

```yaml
fair:
  assets:
    - assets/fair/
```

### 基础用法

**1. 创建动态 Widget**

```dart
@FairPatch()
class DynamicPage extends StatefulWidget {
  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  @FairWell('title')
  String title = '默认标题';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            ElevatedButton(
              onPressed: _onTap,
              child: Text('点击'),
            ),
          ],
        ),
      ),
    );
  }
  
  @FairWell('onTap')
  void _onTap() {
    setState(() {
      title = '已更新';
    });
  }
}
```

**2. 编译生成 DSL**

```bash
flutter pub run fair_compiler
```

**3. 加载动态 Widget**

```dart
FairWidget(
  name: 'DynamicPage',
  path: 'assets/fair/dynamic_page.fair.json',
  data: {'title': '动态标题'},
)
```

### 服务端下发

```dart
class FairUpdateService {
  /// 下载并缓存 Fair 资源
  Future<String?> downloadFairBundle(String url, String name) async {
    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getApplicationDocumentsDirectory();
      final file = File('\${dir.path}/fair/\$name.fair.json');
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
  
  /// 加载动态页面
  Widget loadDynamicPage(String localPath, Map<String, dynamic> data) {
    return FairWidget(
      name: 'DynamicPage',
      path: localPath,
      data: data,
    );
  }
}
```

## MXFlutter

MXFlutter 使用 JavaScript 编写 Flutter UI，通过 JS 引擎执行并渲染原生 Widget。

### 特点

- ✅ 使用 JS 开发
- ✅ 前端开发友好
- ❌ 性能有损耗
- ❌ 维护不活跃

### 基础用法

```javascript
// JS 代码
class MyPage extends MXJSWidget {
  build(context) {
    return new Scaffold({
      appBar: new AppBar({
        title: new Text("动态页面"),
      }),
      body: new Center({
        child: new Text("Hello from JS!"),
      }),
    });
  }
}
```

## OTA 整包更新

最简单的更新方式，检测新版本后引导用户下载安装包。

### 实现

```dart
class AppUpdateService {
  static const String _versionUrl = 'https://your-server.com/api/version';
  
  /// 检查更新
  Future<UpdateInfo?> checkUpdate() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      final data = jsonDecode(response.body);
      
      final currentVersion = await _getCurrentVersion();
      final latestVersion = data['version'];
      
      if (_compareVersion(latestVersion, currentVersion) > 0) {
        return UpdateInfo(
          version: latestVersion,
          downloadUrl: data['download_url'],
          changelog: data['changelog'],
          forceUpdate: data['force_update'] ?? false,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<String> _getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
  
  int _compareVersion(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1 - p2;
    }
    return 0;
  }
  
  /// 下载并安装（Android）
  Future<void> downloadAndInstall(String url) async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      final savePath = '\${dir!.path}/update.apk';
      
      await Dio().download(url, savePath, onReceiveProgress: (received, total) {
        final progress = received / total;
        // 更新进度
      });
      
      // 安装 APK
      await OpenFile.open(savePath);
    } else if (Platform.isIOS) {
      // iOS 跳转到 App Store
      await launchUrl(Uri.parse(url));
    }
  }
}

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String changelog;
  final bool forceUpdate;
  
  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.changelog,
    required this.forceUpdate,
  });
}
```

### 更新对话框

```dart
class UpdateDialog extends StatelessWidget {
  final UpdateInfo info;
  final VoidCallback onUpdate;
  
  const UpdateDialog({required this.info, required this.onUpdate});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('发现新版本 v\${info.version}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('更新内容：'),
          SizedBox(height: 8),
          Text(info.changelog),
        ],
      ),
      actions: [
        if (!info.forceUpdate)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('稍后再说'),
          ),
        ElevatedButton(
          onPressed: onUpdate,
          child: Text('立即更新'),
        ),
      ],
    );
  }
}
```

## Flutter Web 热更新方案

通过 WebView 加载 Flutter Web 构建的页面，实现热更新效果。

### 原理

1. 将部分页面用 Flutter Web 构建
2. 部署到 CDN/服务器
3. App 中用 WebView 加载
4. 需要更新时只需部署新的 Web 资源

### 实现

```dart
class WebHotUpdatePage extends StatefulWidget {
  final String url;
  
  const WebHotUpdatePage({required this.url});
  
  @override
  State<WebHotUpdatePage> createState() => _WebHotUpdatePageState();
}

class _WebHotUpdatePageState extends State<WebHotUpdatePage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (error) {
          // 加载失败，显示降级页面
          setState(() => _isLoading = false);
        },
      ))
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: _handleJsMessage,
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  
  void _handleJsMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message);
    switch (data['action']) {
      case 'navigate':
        Navigator.pushNamed(context, data['route']);
        break;
      case 'close':
        Navigator.pop(context);
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
```

### 与原生通信

**Flutter Web 端（JS）**

```javascript
// 调用原生方法
function callNative(action, params) {
  if (window.FlutterBridge) {
    FlutterBridge.postMessage(JSON.stringify({
      action: action,
      ...params,
    }));
  }
}

// 关闭页面
function closePage() {
  callNative('close');
}

// 跳转原生页面
function navigateTo(route) {
  callNative('navigate', { route: route });
}
```

## 方案选择建议

### 生产环境推荐

```
┌─────────────────────────────────────┐
│  需要热更新？                        │
└──────────────┬──────────────────────┘
               │
       ┌───────▼───────┐
       │  预算充足？    │
       └───────┬───────┘
               │
    ┌──────────┼──────────┐
    │ Yes      │          │ No
    ▼          │          ▼
┌─────────┐    │    ┌──────────┐
│Shorebird│    │    │   Fair   │
└─────────┘    │    └──────────┘
               │
    ┌──────────┼──────────┐
    │ 简单页面  │ 复杂逻辑  │
    ▼          │          ▼
┌─────────┐    │    ┌──────────┐
│Web方案  │    │    │   Fair   │
└─────────┘    │    └──────────┘
```

### 混合策略

```dart
class HotUpdateManager {
  /// 根据页面类型选择加载方式
  Widget loadPage(PageConfig config) {
    switch (config.type) {
      case PageType.native:
        // 原生页面
        return _buildNativePage(config);
        
      case PageType.fair:
        // Fair 动态页面
        return FairWidget(
          name: config.name,
          path: config.fairPath,
          data: config.data,
        );
        
      case PageType.web:
        // WebView 页面
        return WebHotUpdatePage(url: config.webUrl);
        
      default:
        return _buildNativePage(config);
    }
  }
}
```

## 注意事项

::: warning 合规风险
1. **iOS 审核** - Apple 限制动态代码执行，纯 JS 执行可能被拒
2. **Shorebird** - 已获得 Apple 许可，相对安全
3. **敏感功能** - 支付、登录等核心功能建议走原生
4. **降级策略** - 热更新失败时应有降级方案
:::

## 官方资源

- [Shorebird](https://shorebird.dev/)
- [Fair](https://github.com/niceshiki/fair)
- [MXFlutter](https://github.com/niceshiki/mxflutter)
