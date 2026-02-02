# 平台集成

Flutter 应用经常需要与原生平台交互。本章介绍 Platform Channels、平台检测、权限处理和常用原生功能集成。

## 平台检测

### 检测运行平台

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isMacOS || isWindows || isLinux;
}

// 使用
if (PlatformUtils.isAndroid) {
  // Android 特定逻辑
} else if (PlatformUtils.isIOS) {
  // iOS 特定逻辑
}
```

### 平台自适应 Widget

```dart
class PlatformAdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const PlatformAdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// 平台自适应对话框
Future&lt;bool?&gt; showPlatformDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  if (PlatformUtils.isIOS) {
    return showCupertinoDialog&lt;bool&gt;(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
  
  return showDialog&lt;bool&gt;(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('确定'),
        ),
      ],
    ),
  );
}
```

## Platform Channels

Platform Channels 允许 Flutter 与原生代码通信。

### MethodChannel（方法调用）

**Flutter 端：**

```dart
import 'package:flutter/services.dart';

class NativeBridge {
  static const _channel = MethodChannel('com.example.app/native');
  
  // 调用原生方法
  static Future&lt;String&gt; getBatteryLevel() async {
    try {
      final int level = await _channel.invokeMethod('getBatteryLevel');
      return '$level%';
    } on PlatformException catch (e) {
      return '获取失败: ${e.message}';
    }
  }
  
  // 带参数调用
  static Future&lt;Map&lt;String, dynamic&gt;&gt; getUserInfo(String userId) async {
    final result = await _channel.invokeMethod('getUserInfo', {
      'userId': userId,
    });
    return Map&lt;String, dynamic&gt;.from(result);
  }
  
  // 监听原生事件
  static void setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNativeEvent':
          final data = call.arguments;
          print('收到原生事件: $data');
          return 'handled';
        default:
          throw PlatformException(
            code: 'NOT_IMPLEMENTED',
            message: '方法 ${call.method} 未实现',
          );
      }
    });
  }
}
```

**Android 端 (Kotlin)：**

```kotlin
// MainActivity.kt
package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/native"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val batteryLevel = getBatteryLevel()
                        if (batteryLevel != -1) {
                            result.success(batteryLevel)
                        } else {
                            result.error("UNAVAILABLE", "无法获取电量", null)
                        }
                    }
                    "getUserInfo" -> {
                        val userId = call.argument<String>("userId")
                        result.success(mapOf(
                            "userId" to userId,
                            "platform" to "Android"
                        ))
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun getBatteryLevel(): Int {
        val batteryIntent = registerReceiver(
            null, 
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
        return batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
    }
}
```

**iOS 端 (Swift)：**

```swift
// AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.example.app/native",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getBatteryLevel":
                result(self?.getBatteryLevel())
            case "getUserInfo":
                if let args = call.arguments as? [String: Any],
                   let userId = args["userId"] as? String {
                    result([
                        "userId": userId,
                        "platform": "iOS"
                    ])
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "参数无效", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getBatteryLevel() -> Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return Int(level * 100)
    }
}
```

### EventChannel（事件流）

用于原生向 Flutter 推送连续事件。

**Flutter 端：**

```dart
class SensorService {
  static const _eventChannel = EventChannel('com.example.app/sensors');
  
  static Stream&lt;Map&lt;String, double&gt;&gt; get accelerometerStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map&lt;String, double&gt;.from(event);
    });
  }
}

// 使用
class SensorPage extends StatefulWidget {
  @override
  State&lt;SensorPage&gt; createState() => _SensorPageState();
}

class _SensorPageState extends State&lt;SensorPage&gt; {
  StreamSubscription? _subscription;
  Map&lt;String, double&gt;? _sensorData;
  
  @override
  void initState() {
    super.initState();
    _subscription = SensorService.accelerometerStream.listen((data) {
      setState(() => _sensorData = data);
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('X: ${_sensorData?['x']}, Y: ${_sensorData?['y']}'),
    );
  }
}
```

## 权限处理

### permission_handler

```yaml
dependencies:
  permission_handler: ^11.3.0
```

**配置权限（Android）- AndroidManifest.xml：**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <!-- ... -->
</manifest>
```

**配置权限（iOS）- Info.plist：**

```xml
<key>NSCameraUsageDescription</key>
<string>需要相机权限来拍摄照片</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要相册权限来选择照片</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要位置权限来显示您附近的内容</string>
```

**使用：**

```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // 请求单个权限
  static Future&lt;bool&gt; requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  // 请求多个权限
  static Future&lt;Map&lt;Permission, bool&gt;&gt; requestMultiple() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
    
    return statuses.map((key, value) => MapEntry(key, value.isGranted));
  }
  
  // 检查权限状态
  static Future&lt;PermissionStatus&gt; checkCamera() async {
    return Permission.camera.status;
  }
  
  // 打开应用设置
  static Future&lt;void&gt; openSettings() async {
    await openAppSettings();
  }
  
  // 完整的权限请求流程
  static Future&lt;bool&gt; ensurePermission(
    Permission permission, {
    required String rationale,
    required BuildContext context,
  }) async {
    // 检查当前状态
    var status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      // 首次请求或之前拒绝
      status = await permission.request();
      return status.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // 永久拒绝，引导用户去设置
      final shouldOpen = await showDialog&lt;bool&gt;(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('需要权限'),
          content: Text(rationale),
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
      
      if (shouldOpen == true) {
        await openAppSettings();
      }
      return false;
    }
    
    return false;
  }
}

// 使用示例
class CameraPage extends StatelessWidget {
  Future&lt;void&gt; _openCamera(BuildContext context) async {
    final granted = await PermissionService.ensurePermission(
      Permission.camera,
      rationale: '拍摄照片需要相机权限，请在设置中允许',
      context: context,
    );
    
    if (granted) {
      // 打开相机
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _openCamera(context),
      child: Text('拍照'),
    );
  }
}
```

## 常用原生功能集成

### 相机和相册

```yaml
dependencies:
  image_picker: ^1.0.7
```

```dart
import 'package:image_picker/image_picker.dart';

class ImageService {
  final _picker = ImagePicker();
  
  // 从相机拍照
  Future&lt;XFile?&gt; takePhoto() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }
  
  // 从相册选择
  Future&lt;XFile?&gt; pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }
  
  // 选择多张图片
  Future&lt;List&lt;XFile&gt;&gt; pickMultiple() async {
    return _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }
  
  // 录制视频
  Future&lt;XFile?&gt; recordVideo() async {
    return _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(minutes: 1),
    );
  }
}

// 使用
class PhotoWidget extends StatefulWidget {
  @override
  State&lt;PhotoWidget&gt; createState() => _PhotoWidgetState();
}

class _PhotoWidgetState extends State&lt;PhotoWidget&gt; {
  final _imageService = ImageService();
  XFile? _image;
  
  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('拍照'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _imageService.takePhoto();
                if (image != null) {
                  setState(() => _image = image);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('从相册选择'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _imageService.pickFromGallery();
                if (image != null) {
                  setState(() => _image = image);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_image != null)
          Image.file(File(_image!.path), height: 200),
        ElevatedButton(
          onPressed: _showPicker,
          child: Text('选择图片'),
        ),
      ],
    );
  }
}
```

### 位置服务

```yaml
dependencies:
  geolocator: ^11.0.0
  geocoding: ^2.1.1
```

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // 检查并请求权限
  Future&lt;bool&gt; checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  // 获取当前位置
  Future&lt;Position?&gt; getCurrentPosition() async {
    if (!await checkPermission()) {
      return null;
    }
    
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  // 监听位置变化
  Stream&lt;Position&gt; getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,  // 最小移动距离（米）
      ),
    );
  }
  
  // 计算两点距离
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
  
  // 地理编码（地址 -> 坐标）
  Future&lt;List&lt;Location&gt;&gt; getCoordinatesFromAddress(String address) async {
    return locationFromAddress(address);
  }
  
  // 逆地理编码（坐标 -> 地址）
  Future&lt;List&lt;Placemark&gt;&gt; getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    return placemarkFromCoordinates(lat, lng);
  }
}
```

### 分享功能

```yaml
dependencies:
  share_plus: ^7.2.2
```

```dart
import 'package:share_plus/share_plus.dart';

class ShareService {
  // 分享文本
  static Future&lt;void&gt; shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
  
  // 分享链接
  static Future&lt;void&gt; shareLink(String url, {String? text}) async {
    final content = text != null ? '$text\n$url' : url;
    await Share.share(content);
  }
  
  // 分享文件
  static Future&lt;void&gt; shareFiles(
    List&lt;String&gt; paths, {
    String? text,
    String? subject,
  }) async {
    await Share.shareXFiles(
      paths.map((p) => XFile(p)).toList(),
      text: text,
      subject: subject,
    );
  }
  
  // 分享到指定位置（弹窗位置）
  static Future&lt;void&gt; shareWithPosition(
    String text,
    Rect sharePositionOrigin,
  ) async {
    await Share.share(
      text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

// 使用
ElevatedButton(
  onPressed: () => ShareService.shareText(
    '快来看看这个超棒的 Flutter 教程！',
    subject: 'Flutter 教程分享',
  ),
  child: Text('分享'),
)
```

### 本地通知

```yaml
dependencies:
  flutter_local_notifications: ^16.3.2
```

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _notifications = FlutterLocalNotificationsPlugin();
  
  Future&lt;void&gt; initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }
  
  void _onNotificationTap(NotificationResponse response) {
    // 处理通知点击
    final payload = response.payload;
    if (payload != null) {
      // 根据 payload 导航到对应页面
    }
  }
  
  // 显示即时通知
  Future&lt;void&gt; showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      '默认通知',
      channelDescription: '应用默认通知渠道',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }
  
  // 定时通知
  Future&lt;void&gt; scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      '定时通知',
      channelDescription: '定时提醒通知',
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(scheduledDate, local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  // 取消通知
  Future&lt;void&gt; cancel(int id) async {
    await _notifications.cancel(id);
  }
  
  // 取消所有通知
  Future&lt;void&gt; cancelAll() async {
    await _notifications.cancelAll();
  }
}
```

### URL 启动器

```yaml
dependencies:
  url_launcher: ^6.2.4
```

```dart
import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  // 打开网页
  static Future&lt;bool&gt; openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }
  
  // 在应用内打开网页
  static Future&lt;bool&gt; openInApp(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
      );
    }
    return false;
  }
  
  // 拨打电话
  static Future&lt;bool&gt; makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
  
  // 发送短信
  static Future&lt;bool&gt; sendSms(String phoneNumber, {String? body}) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: body != null ? {'body': body} : null,
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
  
  // 发送邮件
  static Future&lt;bool&gt; sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
  
  static String _encodeQueryParameters(Map&lt;String, String&gt; params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  
  // 打开地图
  static Future&lt;bool&gt; openMap(double lat, double lng, {String? label}) async {
    final uri = Uri.parse(
      'https://maps.google.com/maps?q=$lat,$lng${label != null ? '($label)' : ''}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

## 应用生命周期

```dart
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用可见且可交互
        print('应用恢复');
        break;
      case AppLifecycleState.inactive:
        // 应用失去焦点（来电、系统对话框等）
        print('应用不活跃');
        break;
      case AppLifecycleState.paused:
        // 应用进入后台
        print('应用暂停');
        break;
      case AppLifecycleState.detached:
        // 应用销毁
        print('应用销毁');
        break;
      case AppLifecycleState.hidden:
        // 应用隐藏
        print('应用隐藏');
        break;
    }
  }
}

// 使用
class MyApp extends StatefulWidget {
  @override
  State&lt;MyApp&gt; createState() => _MyAppState();
}

class _MyAppState extends State&lt;MyApp&gt; {
  final _observer = AppLifecycleObserver();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_observer);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(...);
  }
}
```

## 最佳实践

### 1. 抽象平台特定代码

```dart
// 定义接口
abstract class PlatformService {
  Future&lt;String&gt; getDeviceId();
  Future&lt;void&gt; vibrate();
}

// Android 实现
class AndroidPlatformService implements PlatformService {
  @override
  Future&lt;String&gt; getDeviceId() async {
    // Android 特定实现
  }
  
  @override
  Future&lt;void&gt; vibrate() async {
    // Android 特定实现
  }
}

// iOS 实现
class IOSPlatformService implements PlatformService {
  @override
  Future&lt;String&gt; getDeviceId() async {
    // iOS 特定实现
  }
  
  @override
  Future&lt;void&gt; vibrate() async {
    // iOS 特定实现
  }
}

// 工厂创建
PlatformService createPlatformService() {
  if (Platform.isAndroid) {
    return AndroidPlatformService();
  } else if (Platform.isIOS) {
    return IOSPlatformService();
  }
  throw UnsupportedError('不支持的平台');
}
```

### 2. 优雅降级

```dart
Future&lt;void&gt; shareContent(String content) async {
  try {
    await Share.share(content);
  } catch (e) {
    // 分享失败，复制到剪贴板
    await Clipboard.setData(ClipboardData(text: content));
    // 显示提示
  }
}
```

## 下一步

掌握平台集成后，下一章我们将学习 [测试与调试](./11-testing)，确保应用质量。
