# Flutter 鸿蒙适配

Flutter 已支持 OpenHarmony/HarmonyOS 平台，可将 Flutter 应用编译为鸿蒙原生应用。本章介绍鸿蒙平台的开发环境配置、项目创建、构建发布等完整流程。

## 概述

```
┌─────────────────────────────────────────────────────────────────┐
│                  Flutter 鸿蒙架构                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────┐      │
│   │                 Flutter Framework                    │      │
│   │        (Dart 代码 - 跨平台 UI 与业务逻辑)             │      │
│   └─────────────────────────┬───────────────────────────┘      │
│                             │                                   │
│   ┌─────────────────────────┴───────────────────────────┐      │
│   │               Flutter Engine (OHOS)                  │      │
│   │     Impeller-Vulkan / Skia-GL 渲染引擎               │      │
│   └─────────────────────────┬───────────────────────────┘      │
│                             │                                   │
│   ┌─────────────────────────┴───────────────────────────┐      │
│   │              OpenHarmony / HarmonyOS                 │      │
│   │           ArkTS / ArkUI / 系统服务                    │      │
│   └─────────────────────────────────────────────────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 支持版本

| Flutter OHOS 版本 | 基于 Flutter 版本 | 说明 |
|------------------|------------------|------|
| 3.7.12-ohos-1.x.x | Flutter 3.7.12 | 稳定版本 |
| 3.22.0-ohos-1.x.x | Flutter 3.22.0 | 新特性支持 |
| 3.27.4-ohos-1.x.x | Flutter 3.27.4 | 最新版本 |

## 环境配置

### 系统要求

- **操作系统**: Windows 10+、macOS 10.15+、Ubuntu 18.04+
- **DevEco Studio**: 5.1.0 或更高版本
- **Java**: JDK 17
- **HarmonyOS API**: API 18 或更高
- **磁盘空间**: 至少 20GB

### 安装 DevEco Studio

1. 下载 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/)
2. 安装并配置 HarmonyOS SDK
3. 配置 Node.js 和 ohpm 包管理器

### 配置 Flutter OHOS SDK

```bash
# 方式一：使用 Git 克隆
git clone https://gitcode.com/openharmony-tpc/flutter_flutter.git -b 3.7.12-ohos
cd flutter_flutter
export PATH="$PWD/bin:$PATH"

# 方式二：直接下载
# 从 https://gitcode.com/openharmony-tpc/flutter_flutter/releases 下载对应版本
```

### 环境变量配置

```bash
# ~/.bashrc 或 ~/.zshrc

# Flutter SDK 路径
export FLUTTER_HOME=/path/to/flutter_flutter
export PATH="$FLUTTER_HOME/bin:$PATH"

# DevEco Studio SDK 路径
export DEVECO_SDK_HOME=/path/to/DevEcoStudio/sdk
export TOOL_HOME=$DEVECO_SDK_HOME/default/openharmony
export PATH="$DEVECO_SDK_HOME/hmscore/5.1.0/toolchains:$PATH"

# Node.js 和 ohpm
export NODE_HOME=$DEVECO_SDK_HOME/default/node
export PATH="$NODE_HOME:$PATH"
export OHPM_HOME=$DEVECO_SDK_HOME/default/ohpm
export PATH="$OHPM_HOME/bin:$PATH"

# Java 17
export JAVA_HOME=/path/to/jdk-17
export PATH="$JAVA_HOME/bin:$PATH"

# 国内镜像加速（可选）
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export OHPM_REGISTRY=https://ohpm.openharmony.cn/ohpm/
```

### 验证安装

```bash
# 检查 Flutter 环境
flutter doctor -v

# 应显示 OpenHarmony 相关信息
# [✓] Flutter (Channel ohos, 3.7.12-ohos-1.1.7)
# [✓] OpenHarmony toolchain
```

## 创建项目

### 新建鸿蒙项目

```bash
# 创建包含鸿蒙平台的项目
flutter create --platforms ohos my_app

# 或创建包含多平台的项目
flutter create --platforms ohos,android,ios my_app

cd my_app
```

### 为现有项目添加鸿蒙支持

```bash
cd existing_flutter_project
flutter create --platforms ohos .
```

### 项目结构

```
my_app/
├── lib/                    # Flutter Dart 代码
│   └── main.dart
├── ohos/                   # 鸿蒙平台代码
│   ├── entry/             # 应用入口模块
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── ets/
│   │   │       │   ├── entryability/
│   │   │       │   │   └── EntryAbility.ets
│   │   │       │   └── pages/
│   │   │       │       └── Index.ets
│   │   │       └── resources/
│   │   ├── build-profile.json5
│   │   └── oh-package.json5
│   ├── build-profile.json5
│   └── oh-package.json5
├── android/
├── ios/
└── pubspec.yaml
```

## 运行与调试

### 启动模拟器或连接设备

```bash
# 使用 DevEco Studio 启动模拟器
# 或连接真机设备，开启开发者模式

# 查看可用设备
flutter devices

# 应显示鸿蒙设备
# OH Device (mobile) • xxx • ohos-arm64 • OpenHarmony x.x.x
```

### 运行应用

```bash
# 调试模式运行
flutter run -d <device_id>

# 指定鸿蒙设备运行
flutter run -d ohos

# 热重载运行
flutter run --hot
```

### 调试技巧

```bash
# 查看日志
flutter logs

# 连接 DevTools
flutter run --debug

# 在 DevEco Studio 中调试
# 打开 ohos/ 目录作为项目
```

## 构建发布

### 构建 HAP 包

```bash
# 构建 debug HAP
flutter build hap --debug

# 构建 release HAP
flutter build hap --release

# 产物位置
# ohos/entry/build/default/outputs/default/entry-default-signed.hap
```

### 构建 APP 包

```bash
# 构建完整 APP 包（用于应用商店发布）
flutter build app --release

# 产物位置
# ohos/build/outputs/default/my_app-default-signed.app
```

### 签名配置

在 `ohos/build-profile.json5` 中配置签名：

```json5
{
  "app": {
    "signingConfigs": [
      {
        "name": "default",
        "type": "HarmonyOS",
        "material": {
          "certpath": "/path/to/certificate.cer",
          "storeFile": "/path/to/keystore.p12",
          "signAlg": "SHA256withECDSA",
          "storePassword": "your_password",
          "keyAlias": "your_alias",
          "keyPassword": "your_key_password",
          "profile": "/path/to/provision.p7b"
        }
      }
    ]
  }
}
```

## 原生交互

### Platform Channel (ETS)

**Flutter 端：**

```dart
import 'package:flutter/services.dart';

class HarmonyBridge {
  static const MethodChannel _channel = 
      MethodChannel('com.example.app/harmony');
  
  /// 获取设备信息
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await _channel.invokeMethod('getDeviceInfo');
    return Map<String, dynamic>.from(result);
  }
  
  /// 调用鸿蒙系统能力
  static Future<void> showToast(String message) async {
    await _channel.invokeMethod('showToast', {'message': message});
  }
  
  /// 打开系统设置
  static Future<void> openSettings() async {
    await _channel.invokeMethod('openSettings');
  }
}
```

**鸿蒙端 (ETS)：**

```typescript
// ohos/entry/src/main/ets/entryability/EntryAbility.ets
import { FlutterAbility, FlutterEngine } from '@aspect/flutter';
import { MethodChannel, MethodCallHandler, MethodResult } from '@aspect/flutter';
import deviceInfo from '@ohos.deviceInfo';
import promptAction from '@ohos.promptAction';
import bundleManager from '@ohos.bundle.bundleManager';

export default class EntryAbility extends FlutterAbility {
  private channel: MethodChannel | null = null;

  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    super.configureFlutterEngine(flutterEngine);
    
    // 创建 Method Channel
    this.channel = new MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      'com.example.app/harmony'
    );
    
    // 设置方法处理器
    this.channel.setMethodCallHandler({
      onMethodCall: (call, result) => {
        switch (call.method) {
          case 'getDeviceInfo':
            this.handleGetDeviceInfo(result);
            break;
          case 'showToast':
            this.handleShowToast(call.arguments, result);
            break;
          case 'openSettings':
            this.handleOpenSettings(result);
            break;
          default:
            result.notImplemented();
        }
      }
    } as MethodCallHandler);
  }

  private handleGetDeviceInfo(result: MethodResult): void {
    const info = {
      brand: deviceInfo.brand,
      model: deviceInfo.productModel,
      osVersion: deviceInfo.osFullName,
      sdkVersion: deviceInfo.sdkApiVersion
    };
    result.success(info);
  }

  private handleShowToast(args: Map<string, string>, result: MethodResult): void {
    const message = args.get('message') || '';
    promptAction.showToast({
      message: message,
      duration: 2000
    });
    result.success(null);
  }

  private handleOpenSettings(result: MethodResult): void {
    // 打开系统设置
    // 使用 want 启动设置页面
    result.success(null);
  }
}
```

### EventChannel 实现

**Flutter 端：**

```dart
class BatteryService {
  static const EventChannel _batteryChannel = 
      EventChannel('com.example.app/battery');
  
  static Stream<int> get batteryLevelStream {
    return _batteryChannel.receiveBroadcastStream().map((level) => level as int);
  }
}
```

**鸿蒙端：**

```typescript
import { EventChannel, EventSink, StreamHandler } from '@aspect/flutter';
import batteryInfo from '@ohos.batteryInfo';

// 在 configureFlutterEngine 中添加
const eventChannel = new EventChannel(
  flutterEngine.dartExecutor.binaryMessenger,
  'com.example.app/battery'
);

eventChannel.setStreamHandler({
  onListen: (args: Object, events: EventSink) => {
    // 发送当前电量
    events.success(batteryInfo.batterySOC);
    
    // 可以设置定时器持续发送
    const intervalId = setInterval(() => {
      events.success(batteryInfo.batterySOC);
    }, 5000);
    
    return () => {
      clearInterval(intervalId);
    };
  },
  onCancel: (args: Object) => {
    // 清理资源
  }
} as StreamHandler);
```

## 集成到现有鸿蒙项目

### 方式一：har 包集成

```bash
# 生成 Flutter har 包
flutter build har --release

# 产物位置
# build/har/flutter.har
```

在鸿蒙项目中引用：

```json5
// oh-package.json5
{
  "dependencies": {
    "flutter": "file:./libs/flutter.har"
  }
}
```

### 方式二：源码集成

```json5
// oh-package.json5
{
  "dependencies": {
    "flutter": "file:../flutter_module/ohos"
  }
}
```

### 在 ArkUI 中嵌入 Flutter

```typescript
// Index.ets
import { FlutterEntry } from '@aspect/flutter';

@Entry
@Component
struct Index {
  build() {
    Column() {
      // 原生 ArkUI 组件
      Text('这是原生组件')
        .fontSize(20)
        .margin(10)
      
      // 嵌入 Flutter 视图
      FlutterEntry({
        routeName: '/flutter_page',
        initialParams: {
          'title': 'Hello from ArkUI'
        }
      })
        .width('100%')
        .height(400)
      
      // 更多原生组件
      Button('原生按钮')
        .onClick(() => {
          // 处理点击
        })
    }
    .width('100%')
    .height('100%')
  }
}
```

## 路由管理

### flutter_boost 路由方案

```yaml
# pubspec.yaml
dependencies:
  flutter_boost:
    git:
      url: https://gitcode.com/ArkUI-x/flutter_boost.git
      ref: ohos
```

**Flutter 端：**

```dart
import 'package:flutter_boost/flutter_boost.dart';

void main() {
  FlutterBoost.singleton.setup(
    // 路由配置
    routeFactory: (settings, uniqueId) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(builder: (_) => HomePage());
        case '/detail':
          return MaterialPageRoute(
            builder: (_) => DetailPage(
              params: settings.arguments as Map<String, dynamic>?,
            ),
          );
        default:
          return MaterialPageRoute(builder: (_) => NotFoundPage());
      }
    },
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FlutterBoost.singleton.appBuilder(),
      home: Container(),
    );
  }
}
```

**鸿蒙端：**

```typescript
import { FlutterBoost } from '@aspect/flutter_boost';

// 从原生打开 Flutter 页面
FlutterBoost.open('/detail', {
  'id': '123',
  'title': 'Product Detail'
});

// 关闭 Flutter 页面
FlutterBoost.close();

// 接收 Flutter 返回结果
FlutterBoost.openWithResult('/select', {}).then((result) => {
  console.log('Flutter returned:', result);
});
```

## 插件适配

### 检查插件兼容性

查看鸿蒙适配插件列表：
- [Flutter OHOS 三方库适配进展](https://docs.qq.com/sheet/DVVJDWWt1V09zUFN2)

### 常用已适配插件

| 插件 | 功能 | 鸿蒙版本 |
|------|------|----------|
| shared_preferences | 本地存储 | ✅ |
| path_provider | 路径获取 | ✅ |
| url_launcher | 打开链接 | ✅ |
| image_picker | 图片选择 | ✅ |
| camera | 相机 | ✅ |
| permission_handler | 权限管理 | ✅ |
| webview_flutter | WebView | ✅ |
| video_player | 视频播放 | ✅ |

### 使用鸿蒙适配版本

```yaml
# pubspec.yaml
dependencies:
  shared_preferences:
    git:
      url: https://gitcode.com/ArkUI-x/plugins.git
      path: packages/shared_preferences/shared_preferences
      ref: ohos
  
  path_provider:
    git:
      url: https://gitcode.com/ArkUI-x/plugins.git
      path: packages/path_provider/path_provider
      ref: ohos
```

### 开发自定义鸿蒙插件

```dart
// lib/my_plugin.dart
import 'package:flutter/services.dart';

class MyPlugin {
  static const MethodChannel _channel = MethodChannel('my_plugin');
  
  static Future<String> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version ?? 'Unknown';
  }
}
```

```typescript
// ohos/src/main/ets/MyPlugin.ets
import { FlutterPlugin, MethodChannel, MethodCall, MethodResult } from '@aspect/flutter';

export class MyPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.binaryMessenger, 'my_plugin');
    this.channel.setMethodCallHandler(this);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'getPlatformVersion') {
      result.success('OpenHarmony');
    } else {
      result.notImplemented();
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }
}
```

## 渲染引擎配置

### Impeller vs Skia

Flutter OHOS 默认使用 **Impeller-Vulkan** 渲染，也支持切换到 **Skia-GL**。

```json5
// ohos/entry/src/main/module.json5
{
  "module": {
    "metadata": [
      {
        "name": "flutter_render_backend",
        "value": "impeller"  // 或 "skia"
      }
    ]
  }
}
```

### 性能对比

| 特性 | Impeller | Skia |
|------|----------|------|
| 渲染性能 | 更优 | 良好 |
| 启动时间 | 更快 | 较慢 |
| 着色器编译 | AOT 预编译 | JIT 编译 |
| 首帧卡顿 | 无 | 可能有 |
| 兼容性 | 新设备 | 更广泛 |

## 常见问题

### 编译错误排查

```bash
# 清理构建缓存
flutter clean
cd ohos && rm -rf .cxx build oh_modules
cd ..

# 重新获取依赖
flutter pub get
cd ohos && ohpm install && cd ..

# 重新构建
flutter build hap
```

### 运行时问题

```bash
# 查看详细日志
flutter run -v

# DevEco Studio 查看 Hilog
hilog | grep flutter
```

### 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| SDK not found | 环境变量未配置 | 检查 DEVECO_SDK_HOME |
| Sign failed | 签名配置错误 | 检查 build-profile.json5 |
| Module not found | 依赖未安装 | 执行 ohpm install |
| Plugin not supported | 插件未适配 | 使用适配版本或自行适配 |

## 离线构建

### 下载离线资源

```bash
# Flutter SDK 离线
# 下载完整 SDK 包而非 git clone

# ohpm 依赖离线
ohpm download <package_name> -o ./offline_packages

# Dart 依赖离线
flutter pub cache repair
```

### 配置离线镜像

```bash
# 配置本地 ohpm 仓库
export OHPM_REGISTRY=http://localhost:8080/ohpm/

# 配置 Flutter 镜像
export FLUTTER_STORAGE_BASE_URL=http://localhost:8080/flutter/
export PUB_HOSTED_URL=http://localhost:8080/pub/
```

## 最佳实践

::: tip 开发建议
1. **保持 SDK 更新** - 及时更新到最新 OHOS 适配版本
2. **检查插件兼容** - 使用前确认插件已适配鸿蒙
3. **使用 Impeller** - 优先使用 Impeller 渲染引擎
4. **测试真机** - 模拟器与真机可能有差异
5. **关注社区** - 关注 OpenHarmony TPC 社区更新
:::

::: warning 注意事项
- Flutter OHOS 仍在快速迭代，API 可能变化
- 部分高级特性可能尚未完全支持
- 调试工具可能不如 Android/iOS 完善
- 应用商店发布需要华为开发者账号
:::

## 相关资源

- [Flutter OHOS 官方仓库](https://gitcode.com/openharmony-tpc/flutter_flutter)
- [OpenHarmony TPC 社区](https://gitcode.com/openharmony-tpc)
- [华为开发者文档](https://developer.huawei.com/consumer/cn/doc/)
- [三方库适配列表](https://docs.qq.com/sheet/DVVJDWWt1V09zUFN2)
- [flutter_boost 路由](https://gitcode.com/ArkUI-x/flutter_boost)
