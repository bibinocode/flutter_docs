# 权限管理

permission_handler 是 Flutter 中最流行的权限管理插件，提供跨平台 API 来请求和检查权限状态。

## 安装

```yaml
dependencies:
  permission_handler: ^12.0.1
```

```bash
flutter pub add permission_handler
```

## 支持平台

| 平台 | 支持情况 |
|------|----------|
| Android | ✅ |
| iOS | ✅ |
| Windows | ✅ |
| Web | ✅ |

---

## 平台配置

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加需要的权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- 相机 -->
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <!-- 麦克风 -->
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    
    <!-- 位置 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    
    <!-- 存储（Android 12 及以下） -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <!-- 媒体文件（Android 13+） -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    
    <!-- 通讯录 -->
    <uses-permission android:name="android.permission.READ_CONTACTS"/>
    <uses-permission android:name="android.permission.WRITE_CONTACTS"/>
    
    <!-- 日历 -->
    <uses-permission android:name="android.permission.READ_CALENDAR"/>
    <uses-permission android:name="android.permission.WRITE_CALENDAR"/>
    
    <!-- 电话 -->
    <uses-permission android:name="android.permission.CALL_PHONE"/>
    <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
    
    <!-- 短信 -->
    <uses-permission android:name="android.permission.SEND_SMS"/>
    <uses-permission android:name="android.permission.READ_SMS"/>
    
    <!-- 通知 -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <!-- 蓝牙 -->
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    
    <!-- 传感器 -->
    <uses-permission android:name="android.permission.BODY_SENSORS"/>
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>

    <application ...>
        ...
    </application>
</manifest>
```

### iOS 配置

在 `ios/Runner/Info.plist` 中添加权限描述：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 相机 -->
    <key>NSCameraUsageDescription</key>
    <string>我们需要访问相机以拍摄照片</string>
    
    <!-- 麦克风 -->
    <key>NSMicrophoneUsageDescription</key>
    <string>我们需要访问麦克风以录制音频</string>
    
    <!-- 相册 -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>我们需要访问相册以选择照片</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>我们需要保存照片到相册</string>
    
    <!-- 位置 -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>我们需要在使用时获取您的位置</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>我们需要持续获取您的位置以提供导航服务</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>我们需要在后台获取您的位置</string>
    
    <!-- 通讯录 -->
    <key>NSContactsUsageDescription</key>
    <string>我们需要访问通讯录以查找好友</string>
    
    <!-- 日历 -->
    <key>NSCalendarsUsageDescription</key>
    <string>我们需要访问日历以添加提醒</string>
    
    <!-- 提醒事项 -->
    <key>NSRemindersUsageDescription</key>
    <string>我们需要访问提醒事项</string>
    
    <!-- 蓝牙 -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>我们需要使用蓝牙连接设备</string>
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>我们需要使用蓝牙连接外设</string>
    
    <!-- 语音识别 -->
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>我们需要使用语音识别功能</string>
    
    <!-- 运动与健身 -->
    <key>NSMotionUsageDescription</key>
    <string>我们需要访问运动数据以记录步数</string>
    
    <!-- Face ID -->
    <key>NSFaceIDUsageDescription</key>
    <string>我们需要使用 Face ID 进行身份验证</string>
    
    <!-- 媒体库 -->
    <key>NSAppleMusicUsageDescription</key>
    <string>我们需要访问媒体库以播放音乐</string>
    
    <!-- 健康 -->
    <key>NSHealthShareUsageDescription</key>
    <string>我们需要读取您的健康数据</string>
    <key>NSHealthUpdateUsageDescription</key>
    <string>我们需要更新您的健康数据</string>
</dict>
</plist>
```

::: danger 重要
iOS 上如果 Info.plist 中缺少对应权限的描述，请求权限时应用会直接崩溃！
:::

---

## 权限状态

权限有以下几种状态：

| 状态 | 说明 |
|------|------|
| `granted` | 已授权 |
| `denied` | 已拒绝（可再次请求） |
| `restricted` | 受限（iOS 家长控制等） |
| `limited` | 有限授权（iOS 14+ 照片） |
| `permanentlyDenied` | 永久拒绝（需要去设置开启） |
| `provisional` | 临时授权（iOS 通知） |

```dart
import 'package:permission_handler/permission_handler.dart';

// 检查状态
var status = await Permission.camera.status;

if (status.isGranted) {
  print('已授权');
}

if (status.isDenied) {
  print('已拒绝，可再次请求');
}

if (status.isPermanentlyDenied) {
  print('永久拒绝，需要去设置开启');
}

if (status.isRestricted) {
  print('受限（iOS 特有）');
}

if (status.isLimited) {
  print('有限授权（iOS 照片）');
}

// 便捷检查方法
if (await Permission.camera.isGranted) {
  // 已授权
}

if (await Permission.camera.isDenied) {
  // 已拒绝
}
```

---

## 请求权限

### 请求单个权限

```dart
// 方式一：直接请求
if (await Permission.camera.request().isGranted) {
  // 权限已授予
  openCamera();
}

// 方式二：先检查再请求
var status = await Permission.camera.status;
if (status.isDenied) {
  status = await Permission.camera.request();
}

if (status.isGranted) {
  openCamera();
} else if (status.isPermanentlyDenied) {
  // 引导用户去设置页面
  openAppSettings();
}
```

### 请求多个权限

```dart
// 同时请求多个权限
Map<Permission, PermissionStatus> statuses = await [
  Permission.camera,
  Permission.microphone,
  Permission.storage,
].request();

// 检查各权限状态
if (statuses[Permission.camera]!.isGranted &&
    statuses[Permission.microphone]!.isGranted) {
  // 可以录制视频
  startVideoRecording();
}

// 打印状态
statuses.forEach((permission, status) {
  print('$permission: $status');
});
```

### 回调风格 API

```dart
await Permission.camera
  .onDeniedCallback(() {
    // 用户拒绝了权限
    showSnackBar('需要相机权限才能拍照');
  })
  .onGrantedCallback(() {
    // 用户授予了权限
    openCamera();
  })
  .onPermanentlyDeniedCallback(() {
    // 用户永久拒绝了权限
    showSettingsDialog();
  })
  .onRestrictedCallback(() {
    // iOS: 权限受限
    showSnackBar('相机权限受到限制');
  })
  .onLimitedCallback(() {
    // iOS: 有限授权
    showSnackBar('仅授予部分照片访问权限');
  })
  .onProvisionalCallback(() {
    // iOS: 临时授权（通知）
    print('临时授权');
  })
  .request();
```

---

## 常用权限

### 相机权限

```dart
Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  
  if (status.isGranted) {
    // 打开相机
    _openCamera();
  } else if (status.isPermanentlyDenied) {
    _showSettingsDialog('相机');
  } else {
    _showPermissionDeniedMessage('相机');
  }
}
```

### 位置权限

```dart
Future<void> requestLocationPermission() async {
  // 先检查位置服务是否开启
  if (!await Permission.locationWhenInUse.serviceStatus.isEnabled) {
    _showSnackBar('请先开启位置服务');
    return;
  }
  
  // 请求前台定位权限
  var status = await Permission.locationWhenInUse.request();
  
  if (status.isGranted) {
    // 如果需要后台定位，再请求 Always 权限
    // 注意：Android 10+ 必须先获得 WhenInUse 权限
    if (needBackgroundLocation) {
      final alwaysStatus = await Permission.locationAlways.request();
      if (alwaysStatus.isGranted) {
        _startBackgroundLocationTracking();
      }
    } else {
      _getCurrentLocation();
    }
  }
}
```

::: warning Android 10+ 位置权限
从 Android 10 开始，必须先获得 `locationWhenInUse` 权限，才能请求 `locationAlways` 权限。直接请求 `locationAlways` 会被忽略。
:::

### 存储权限

```dart
Future<void> requestStoragePermission() async {
  // Android 13+ 使用新的媒体权限
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    
    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+ 请求具体的媒体权限
      final statuses = await [
        Permission.photos,      // 图片
        Permission.videos,      // 视频
        Permission.audio,       // 音频
      ].request();
      
      if (statuses[Permission.photos]!.isGranted) {
        _loadImages();
      }
    } else {
      // Android 12 及以下
      final status = await Permission.storage.request();
      if (status.isGranted) {
        _loadFiles();
      }
    }
  } else {
    // iOS
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      _loadImages();
    }
  }
}
```

### 通知权限

```dart
Future<void> requestNotificationPermission() async {
  // Android 13+ 和 iOS 需要请求通知权限
  final status = await Permission.notification.request();
  
  if (status.isGranted) {
    print('通知权限已授予');
  } else if (status.isDenied) {
    // Android 13 以下会直接返回 granted
    print('通知权限被拒绝');
  }
}
```

### 蓝牙权限

```dart
Future<void> requestBluetoothPermission() async {
  // Android 需要多个蓝牙相关权限
  if (Platform.isAndroid) {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    
    final allGranted = statuses.values.every((s) => s.isGranted);
    if (allGranted) {
      _startBluetoothScan();
    }
  } else {
    // iOS
    final status = await Permission.bluetooth.request();
    if (status.isGranted) {
      _startBluetoothScan();
    }
  }
}
```

---

## 打开系统设置

当用户永久拒绝权限时，需要引导用户去系统设置页面手动开启：

```dart
Future<void> handlePermanentlyDenied(String permissionName) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('需要$permissionName权限'),
      content: Text('请在设置中开启$permissionName权限，否则该功能无法正常使用。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('去设置'),
        ),
      ],
    ),
  );
  
  if (result == true) {
    // 打开应用设置页面
    await openAppSettings();
  }
}
```

---

## 权限理由（Android）

Android 允许在请求权限前展示理由，说明为什么需要该权限：

```dart
Future<void> requestWithRationale() async {
  // 检查是否应该显示权限理由
  // 当用户之前拒绝过权限时返回 true
  if (await Permission.camera.shouldShowRequestRationale) {
    // 显示理由对话框
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('相机权限说明'),
        content: Text('我们需要相机权限来拍摄照片和扫描二维码。您的照片不会被上传到服务器。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('继续'),
          ),
        ],
      ),
    );
    
    if (shouldRequest != true) return;
  }
  
  // 请求权限
  final status = await Permission.camera.request();
  // 处理结果...
}
```

---

## 封装权限工具类

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  /// 请求单个权限
  static Future<bool> request(
    Permission permission, {
    BuildContext? context,
    String? permissionName,
  }) async {
    // 检查当前状态
    var status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isPermanentlyDenied) {
      if (context != null && permissionName != null) {
        await _showSettingsDialog(context, permissionName);
      }
      return false;
    }
    
    // 请求权限
    status = await permission.request();
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isPermanentlyDenied && context != null && permissionName != null) {
      await _showSettingsDialog(context, permissionName);
    }
    
    return false;
  }
  
  /// 请求多个权限
  static Future<bool> requestMultiple(
    List<Permission> permissions, {
    BuildContext? context,
  }) async {
    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }
  
  /// 请求相机权限
  static Future<bool> requestCamera({BuildContext? context}) {
    return request(Permission.camera, context: context, permissionName: '相机');
  }
  
  /// 请求麦克风权限
  static Future<bool> requestMicrophone({BuildContext? context}) {
    return request(Permission.microphone, context: context, permissionName: '麦克风');
  }
  
  /// 请求位置权限
  static Future<bool> requestLocation({BuildContext? context}) async {
    // 检查位置服务
    if (!await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      if (context != null) {
        _showSnackBar(context, '请先开启位置服务');
      }
      return false;
    }
    return request(
      Permission.locationWhenInUse,
      context: context,
      permissionName: '位置',
    );
  }
  
  /// 请求存储/相册权限
  static Future<bool> requestPhotos({BuildContext? context}) async {
    if (Platform.isAndroid) {
      // Android 13+ 使用 photos 权限
      return request(Permission.photos, context: context, permissionName: '相册');
    } else {
      final status = await Permission.photos.request();
      // iOS 的 limited 状态也算授权
      return status.isGranted || status.isLimited;
    }
  }
  
  /// 请求通知权限
  static Future<bool> requestNotification({BuildContext? context}) {
    return request(
      Permission.notification,
      context: context,
      permissionName: '通知',
    );
  }
  
  /// 请求录制视频所需权限（相机+麦克风）
  static Future<bool> requestVideoRecording({BuildContext? context}) async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    
    final cameraGranted = statuses[Permission.camera]!.isGranted;
    final microphoneGranted = statuses[Permission.microphone]!.isGranted;
    
    if (!cameraGranted && context != null) {
      _showSnackBar(context, '需要相机权限');
    } else if (!microphoneGranted && context != null) {
      _showSnackBar(context, '需要麦克风权限');
    }
    
    return cameraGranted && microphoneGranted;
  }
  
  /// 显示设置对话框
  static Future<void> _showSettingsDialog(
    BuildContext context,
    String permissionName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要$permissionName权限'),
        content: Text(
          '$permissionName权限已被禁用，请在设置中手动开启。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      await openAppSettings();
    }
  }
  
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// 使用示例
class CameraPage extends StatelessWidget {
  Future<void> _openCamera(BuildContext context) async {
    final granted = await PermissionUtil.requestCamera(context: context);
    if (granted) {
      // 打开相机
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CameraView()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _openCamera(context),
      child: Text('打开相机'),
    );
  }
}
```

---

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDemoPage extends StatefulWidget {
  const PermissionDemoPage({super.key});

  @override
  State<PermissionDemoPage> createState() => _PermissionDemoPageState();
}

class _PermissionDemoPageState extends State<PermissionDemoPage> {
  final List<PermissionItem> _permissions = [
    PermissionItem(Permission.camera, '相机', Icons.camera_alt),
    PermissionItem(Permission.microphone, '麦克风', Icons.mic),
    PermissionItem(Permission.locationWhenInUse, '位置', Icons.location_on),
    PermissionItem(Permission.photos, '相册', Icons.photo_library),
    PermissionItem(Permission.notification, '通知', Icons.notifications),
    PermissionItem(Permission.contacts, '通讯录', Icons.contacts),
    PermissionItem(Permission.calendar, '日历', Icons.calendar_today),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限管理')),
      body: ListView.builder(
        itemCount: _permissions.length,
        itemBuilder: (context, index) {
          final item = _permissions[index];
          return _PermissionTile(
            permission: item.permission,
            name: item.name,
            icon: item.icon,
          );
        },
      ),
    );
  }
}

class PermissionItem {
  final Permission permission;
  final String name;
  final IconData icon;

  PermissionItem(this.permission, this.name, this.icon);
}

class _PermissionTile extends StatefulWidget {
  final Permission permission;
  final String name;
  final IconData icon;

  const _PermissionTile({
    required this.permission,
    required this.name,
    required this.icon,
  });

  @override
  State<_PermissionTile> createState() => _PermissionTileState();
}

class _PermissionTileState extends State<_PermissionTile> {
  PermissionStatus _status = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await widget.permission.status;
    setState(() => _status = status);
  }

  Future<void> _requestPermission() async {
    final status = await widget.permission.request();
    setState(() => _status = status);
    
    if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要${widget.name}权限'),
        content: const Text('权限已被永久拒绝，请在设置中手动开启。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  String get _statusText {
    switch (_status) {
      case PermissionStatus.granted:
        return '已授权';
      case PermissionStatus.denied:
        return '未授权';
      case PermissionStatus.restricted:
        return '受限';
      case PermissionStatus.limited:
        return '有限授权';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionStatus.provisional:
        return '临时授权';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, size: 32),
      title: Text(widget.name),
      subtitle: Text(
        _statusText,
        style: TextStyle(color: _statusColor),
      ),
      trailing: _status.isGranted
          ? const Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('请求'),
            ),
      onTap: _checkStatus,
    );
  }
}
```

---

## 常见问题

### 1. Android 13+ 存储权限返回 denied

Android 13 移除了 `READ_EXTERNAL_STORAGE` 和 `WRITE_EXTERNAL_STORAGE` 权限，改用细分的媒体权限：

- `Permission.photos` - 图片
- `Permission.videos` - 视频
- `Permission.audio` - 音频

### 2. iOS 请求权限时崩溃

确保 `Info.plist` 中包含对应权限的 Usage Description，否则 iOS 会直接终止应用。

### 3. locationAlways 总是返回 denied

Android 10+ 必须先获得 `locationWhenInUse` 权限，然后才能请求 `locationAlways` 权限。

### 4. 某些权限不显示弹窗

以下权限不会显示请求弹窗，而是直接返回状态或打开设置页面：

- `notification` - 读取系统设置
- `bluetooth` - 读取系统设置
- `manageExternalStorage` - 打开设置页面
- `systemAlertWindow` - 打开设置页面

---

## 最佳实践

1. **按需请求** - 在需要使用功能时请求，而非应用启动时
2. **解释原因** - 请求前告知用户为何需要该权限
3. **优雅降级** - 权限被拒绝时提供替代方案
4. **处理永久拒绝** - 引导用户去设置页面
5. **最小权限原则** - 只请求必要的权限

## 相关资源

- [permission_handler 官方文档](https://pub.dev/packages/permission_handler)
- [Android 权限指南](https://developer.android.com/guide/topics/permissions/overview)
- [iOS 权限指南](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)
