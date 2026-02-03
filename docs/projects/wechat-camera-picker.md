# Flutter WeChat Camera Picker

基于微信 UI 的 Flutter 相机选择器，支持拍照和录像功能。

## 📋 项目概述

| 项目信息 | 详情 |
|---------|------|
| 🔗 GitHub | [fluttercandies/flutter_wechat_camera_picker](https://github.com/fluttercandies/flutter_wechat_camera_picker) |
| 📦 pub.dev | [wechat_camera_picker](https://pub.dev/packages/wechat_camera_picker) |
| ⭐ Stars | 400+ |
| 📅 最后更新 | 活跃维护中 |
| 📄 协议 | Apache 2.0 |
| 🎯 定位 | 微信风格相机选择器插件 |

## 🛠️ 技术栈

### 核心依赖

```yaml
dependencies:
  camera: ^0.10.0           # 相机控制
  photo_manager: ^3.0.0     # 媒体资源管理
  video_player: ^2.8.0      # 视频播放
  sensors_plus: ^4.0.0      # 传感器支持
  wechat_picker_library: ^1.0.0  # 共享库
```

### 技术特点

- **无障碍支持** - 完整支持 TalkBack 和 VoiceOver
- **State 可重载** - 支持自定义 State 实现
- **主题定制** - 基于 ThemeData 的完全定制
- **国际化** - 多语言支持 (中文/英文/越南语)

## 📁 项目结构

```
lib/
├── wechat_camera_picker.dart     # 主入口，导出所有公开 API
└── src/
    ├── constants/
    │   ├── config.dart           # CameraPickerConfig 配置类
    │   ├── enums.dart            # 枚举定义
    │   └── type_defs.dart        # 类型定义
    ├── delegates/
    │   └── camera_picker_text_delegate.dart  # 文本代理（多语言）
    ├── internals/
    │   ├── methods.dart          # 内部方法
    │   └── singleton.dart        # 单例管理
    ├── states/
    │   ├── camera_picker_state.dart         # 相机选择器状态
    │   └── camera_picker_viewer_state.dart  # 预览查看器状态
    └── widgets/
        ├── camera_picker.dart               # 主入口 Widget
        ├── camera_picker_viewer.dart        # 预览查看器
        ├── camera_picker_page_route.dart    # 路由
        ├── camera_focus_point.dart          # 对焦点组件
        └── camera_progress_button.dart      # 进度按钮
```

## 📝 学习要点

### 1. 配置类设计模式

```dart
/// CameraPickerConfig - 完善的配置类设计
final class CameraPickerConfig {
  const CameraPickerConfig({
    // 功能开关
    this.enableRecording = false,
    this.onlyEnableRecording = false,
    this.enableTapRecording = false,
    this.enableAudio = true,
    
    // 交互设置
    this.enableSetExposure = true,
    this.enableExposureControlOnPoint = true,
    this.enablePinchToZoom = true,
    this.enablePullToZoomInRecord = true,
    
    // 预览设置
    this.enableScaledPreview = false,
    this.shouldDeletePreviewFile = false,
    this.shouldAutoPreviewVideo = true,
    
    // 时长限制
    this.maximumRecordingDuration = const Duration(seconds: 15),
    this.minimumRecordingDuration = const Duration(seconds: 1),
    
    // 主题与文本
    this.theme,
    this.textDelegate,
    
    // 相机设置
    this.resolutionPreset = ResolutionPreset.ultraHigh,
    this.cameraQuarterTurns = 0,
    this.imageFormatGroup = ImageFormatGroup.unknown,
    this.preferredLensDirection = CameraLensDirection.back,
    
    // 回调
    this.onEntitySaving,
    this.onXFileCaptured,
    this.onError,
    this.onMinimumRecordDurationNotMet,
    this.onPickConfirmed,
  });
  
  // ... 字段定义
}
```

### 2. State 可重载设计

```dart
/// 支持自定义 State 的设计模式
class CameraPicker extends StatefulWidget {
  const CameraPicker({
    super.key,
    this.pickerConfig = const CameraPickerConfig(),
    this.createPickerState,  // 支持自定义 State 创建
    this.locale,
  });

  /// 自定义 State 创建工厂
  final CameraPickerState Function()? createPickerState;

  @override
  CameraPickerState createState() =>
      createPickerState?.call() ?? CameraPickerState();
      
  /// 静态入口方法
  static Future<AssetEntity?> pickFromCamera(
    BuildContext context, {
    CameraPickerConfig pickerConfig = const CameraPickerConfig(),
    CameraPickerState Function()? createPickerState,
    Locale? locale,
  }) async {
    // 实现...
  }
}

/// 使用自定义 State
class CustomCameraPickerState extends CameraPickerState {
  @override
  Widget buildBody(BuildContext context) {
    // 自定义实现
  }
}

// 调用
final entity = await CameraPicker.pickFromCamera(
  context,
  createPickerState: () => CustomCameraPickerState(),
);
```

### 3. 主题系统

```dart
/// 微信风格主题色
const Color defaultThemeColorWeChat = Color(0xFF00BC56);

/// 主题数据构建
static ThemeData themeData(Color themeColor) {
  return ThemeData.dark().copyWith(
    primaryColor: themeColor,
    colorScheme: ColorScheme.dark(
      primary: themeColor,
      secondary: themeColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
    ),
    // 更多主题配置...
  );
}
```

### 4. 文本代理模式（国际化）

```dart
/// 文本代理基类
abstract class CameraPickerTextDelegate {
  const CameraPickerTextDelegate();
  
  /// 拍摄按钮提示
  String get shootingTips;
  
  /// 录像按钮提示  
  String get shootingWithRecordingTips;
  
  /// 点击录像提示
  String get shootingTapRecordingTips;
  
  /// 加载中
  String get loadingText;
  
  /// 保存中
  String get savingText;
}

/// 中文实现
class CameraPickerTextDelegateZh extends CameraPickerTextDelegate {
  const CameraPickerTextDelegateZh();
  
  @override
  String get shootingTips => '轻触拍照';
  
  @override
  String get shootingWithRecordingTips => '轻触拍照，长按摄像';
  
  @override
  String get shootingTapRecordingTips => '轻触摄像';
  
  @override
  String get loadingText => '加载中...';
  
  @override
  String get savingText => '保存中...';
}

/// 英文实现
class CameraPickerTextDelegateEn extends CameraPickerTextDelegate {
  const CameraPickerTextDelegateEn();
  
  @override
  String get shootingTips => 'Tap to take photo';
  
  // ...
}
```

### 5. 预览查看器设计

```dart
/// 预览查看器 - 图片/视频预览
class CameraPickerViewer extends StatefulWidget {
  const CameraPickerViewer._({
    required this.viewType,       // 预览类型
    required this.previewXFile,   // 预览文件
    required this.pickerConfig,   // 配置
    this.createViewerState,       // 自定义 State
  });

  /// 视频播放控制
  final isPlaying = ValueNotifier<bool>(false);

  /// 推送到预览页
  static Future<AssetEntity?> pushToViewer(
    BuildContext context, {
    required CameraPickerViewType viewType,
    required XFile previewXFile,
    required CameraPickerConfig pickerConfig,
    CameraPickerViewerState Function()? createViewerState,
  }) async {
    return Navigator.of(context).push<AssetEntity?>(
      CameraPickerPageRoute<AssetEntity?>(
        builder: (context) => CameraPickerViewer._(
          viewType: viewType,
          previewXFile: previewXFile,
          pickerConfig: pickerConfig,
          createViewerState: createViewerState,
        ),
      ),
    );
  }
}
```

## ✨ 架构亮点

### 1. 组合优于继承
通过配置类和回调实现功能定制，而非继承复杂类

### 2. State 可重载
允许完全自定义 UI 实现，同时复用核心逻辑

### 3. 完善的无障碍支持
从设计之初就考虑无障碍支持

### 4. 模块化文本系统
通过 TextDelegate 实现灵活的国际化

### 5. 与 photo_manager 深度集成
直接返回 `AssetEntity`，方便后续媒体操作

## 🚀 运行指南

### 安装

```yaml
dependencies:
  wechat_camera_picker: ^4.5.0
```

### 基础使用

```dart
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

// 简单拍照
final AssetEntity? entity = await CameraPicker.pickFromCamera(context);

// 支持录像
final entity = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: const CameraPickerConfig(enableRecording: true),
);

// 仅录像
final entity = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: const CameraPickerConfig(
    enableRecording: true,
    onlyEnableRecording: true,
  ),
);
```

### 平台配置

#### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>需要相机权限以拍照和录像</string>
<key>NSMicrophoneUsageDescription</key>
<string>需要麦克风权限以录制声音</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要相册权限以保存照片</string>
```

#### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

## 💡 使用技巧

### 自定义主题
```dart
final entity = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: CameraPickerConfig(
    theme: CameraPicker.themeData(Colors.blue),
  ),
);
```

### 限制录像时长
```dart
final entity = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: const CameraPickerConfig(
    enableRecording: true,
    maximumRecordingDuration: Duration(seconds: 30),
    minimumRecordingDuration: Duration(seconds: 3),
  ),
);
```

### 拦截保存操作
```dart
final entity = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: CameraPickerConfig(
    onXFileCaptured: (XFile file, CameraPickerViewType type) async {
      // 自定义保存逻辑
      return true;  // 返回 true 阻止默认保存
    },
  ),
);
```

## ⚠️ 注意事项

::: warning 权限处理
- iOS 需要在 Info.plist 中声明所有权限描述
- Android 11+ 需要处理 Scoped Storage 限制
:::

::: tip 搭配使用
推荐与 `wechat_assets_picker` 配合使用，提供完整的微信风格媒体选择体验
:::

::: info 版本兼容
| 版本 | Flutter 3.3 | Flutter 3.16 | Flutter 3.22 |
|------|:-----------:|:------------:|:------------:|
| 4.5.0+ | ❌ | ✅ | ✅ |
| 4.2.0+ | ❌ | ✅ | ❌ |
| 4.0.0+ | ✅ | ❌ | ❌ |
:::
