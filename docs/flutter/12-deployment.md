# 发布部署

应用开发完成后，需要发布到各平台应用商店。本章介绍 Android 和 iOS 的打包发布流程。

## 发布前准备

### 应用图标

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  # iOS 特定
  remove_alpha_ios: true
  # Android 特定
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

```bash
# 生成图标
dart run flutter_launcher_icons
```

### 启动页（Splash Screen）

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_native_splash: ^2.3.10

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/splash/logo.png
  android_12:
    color: "#FFFFFF"
    icon_background_color: "#FFFFFF"
    image: assets/splash/logo.png
  ios: true
```

```bash
# 生成启动页
dart run flutter_native_splash:create
```

### 应用名称

**Android** - `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="我的应用"
    ...>
</application>
```

**iOS** - `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>我的应用</string>
```

### 应用 ID (Bundle Identifier)

**Android** - `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        applicationId "com.example.myapp"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

**iOS** - Xcode 中设置 Bundle Identifier

## Android 发布

### 1. 创建签名密钥

```bash
# 创建 keystore
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

### 2. 配置签名

创建 `android/key.properties`:

```properties
storePassword=<密码>
keyPassword=<密钥密码>
keyAlias=key
storeFile=/Users/yourname/key.jks
```

修改 `android/app/build.gradle`:

```groovy
// 在 android { 之前添加
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. 配置 ProGuard

创建 `android/app/proguard-rules.pro`:

```proguard
# Flutter 相关
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 保留 JSON 序列化类
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 保留枚举
-keepclassmembers enum * { *; }
```

### 4. 构建 APK/App Bundle

```bash
# 构建 APK
flutter build apk --release

# 构建分架构 APK
flutter build apk --split-per-abi

# 构建 App Bundle (推荐)
flutter build appbundle --release
```

### 5. 发布到 Google Play

1. 注册 [Google Play Console](https://play.google.com/console) 账号
2. 创建新应用
3. 填写商品详情（描述、截图、分类等）
4. 上传 App Bundle
5. 设置发布范围和定价
6. 提交审核

## iOS 发布

### 1. Apple 开发者账号

- 注册 [Apple Developer Program](https://developer.apple.com/programs/)（每年 $99）
- 在 App Store Connect 创建应用

### 2. Xcode 配置

1. 打开 `ios/Runner.xcworkspace`
2. 选择 Runner target
3. 设置 Bundle Identifier
4. 选择 Team（开发者账号）
5. 配置 Signing & Capabilities

### 3. 配置 Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>我的应用</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<key>CFBundleVersion</key>
<string>1</string>

<!-- 权限描述 -->
<key>NSCameraUsageDescription</key>
<string>需要相机权限来拍摄照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要相册权限来选择照片</string>
```

### 4. 构建 iOS 应用

```bash
# 构建 iOS Release
flutter build ios --release

# 在 Xcode 中归档
# Product -> Archive
```

### 5. 上传到 App Store Connect

使用 Xcode 或 Transporter 上传：

1. Xcode: Window -> Organizer -> Distribute App
2. 选择 App Store Connect
3. 上传

### 6. 提交审核

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择应用
3. 填写版本信息
4. 添加截图和描述
5. 提交审核

## 版本管理

### 版本号规范

```
version: 1.2.3+4
        │ │ │ │
        │ │ │ └── build number (内部版本号)
        │ │ └──── patch (修复版本)
        │ └────── minor (功能版本)
        └──────── major (主版本)
```

### 自动版本号

```yaml
# pubspec.yaml
version: 1.0.0+1
```

```bash
# 自动递增版本
# 可以使用 CI/CD 工具或脚本
```

## CI/CD 持续集成

### GitHub Actions

```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Analyze
        run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
```

### Fastlane 自动化

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Google Play Internal"
  lane :internal do
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
  
  desc "Deploy to Google Play Production"
  lane :production do
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end
```

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Push to TestFlight"
  lane :beta do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner"
    )
    upload_to_testflight
  end
  
  desc "Push to App Store"
  lane :release do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner"
    )
    upload_to_app_store(
      skip_metadata: true,
      skip_screenshots: true
    )
  end
end
```

## 应用商店优化 (ASO)

### 1. 关键词优化

- 研究竞品关键词
- 在标题和描述中使用关键词
- 定期更新关键词

### 2. 截图和视频

```
推荐尺寸：
- iPhone: 1290 x 2796 (6.7")
- iPad: 2048 x 2732 (12.9")
- Android: 1080 x 1920 或更高
```

### 3. 应用描述

```
结构建议：
1. 开头：核心价值主张
2. 主要功能列表
3. 用户好评/社交证明
4. 结尾：行动召唤
```

## 发布检查清单

### 通用检查

- [ ] 更新版本号
- [ ] 测试 Release 构建
- [ ] 检查权限配置
- [ ] 验证隐私政策 URL
- [ ] 准备应用截图
- [ ] 编写发布说明

### Android 检查

- [ ] 签名配置正确
- [ ] ProGuard 规则完整
- [ ] 测试不同设备/API 级别
- [ ] App Bundle 测试

### iOS 检查

- [ ] Bundle Identifier 正确
- [ ] 证书和配置文件有效
- [ ] Info.plist 权限描述完整
- [ ] 测试 TestFlight 版本
- [ ] 应用内购买配置（如有）

## 发布后监控

### 崩溃报告

```yaml
dependencies:
  firebase_crashlytics: ^3.4.18
```

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // 捕获 Flutter 错误
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  
  // 捕获异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(MyApp());
}
```

### 用户分析

```yaml
dependencies:
  firebase_analytics: ^10.8.9
```

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future&lt;void&gt; logEvent(String name, Map&lt;String, dynamic&gt;? params) async {
    await _analytics.logEvent(name: name, parameters: params);
  }
  
  Future&lt;void&gt; logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
  
  Future&lt;void&gt; setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
```

## 最佳实践

### 1. 保护敏感信息

```bash
# .gitignore
android/key.properties
android/app/key.jks
ios/Runner/GoogleService-Info.plist
*.env
```

### 2. 环境配置

```dart
// lib/config/env.dart
enum Environment { dev, staging, prod }

class AppConfig {
  static Environment env = Environment.dev;
  
  static String get apiBaseUrl {
    switch (env) {
      case Environment.dev:
        return 'https://dev-api.example.com';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.prod:
        return 'https://api.example.com';
    }
  }
}
```

```bash
# 不同环境构建
flutter build apk --dart-define=ENV=prod
```

### 3. 发布前测试

```dart
// 发布前检查清单
class ReleaseChecklist {
  static Future&lt;void&gt; verify() async {
    // 检查网络连接
    assert(await hasNetwork());
    
    // 检查必要权限
    assert(await checkPermissions());
    
    // 验证 API 连接
    assert(await verifyApiConnection());
  }
}
```

## 总结

恭喜你完成了 Flutter 教程的学习！现在你已经掌握了：

1. **基础知识** - Dart 语言、Widget 系统
2. **UI 开发** - 布局、状态管理、动画
3. **数据处理** - 网络请求、本地存储
4. **平台集成** - 原生交互、权限处理
5. **质量保证** - 测试、调试、性能优化
6. **发布部署** - 打包、上架、监控

继续探索 Flutter 生态，构建更多精彩的应用！

## 相关资源

- [Flutter 官方文档](https://docs.flutter.dev)
- [Dart 包仓库](https://pub.dev)
- [Flutter GitHub](https://github.com/flutter/flutter)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)
