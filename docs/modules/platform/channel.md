# Platform Channel

Platform Channel 是 Flutter 与原生平台通信的桥梁，允许 Flutter 调用 iOS/Android 原生 API，实现平台特定功能。

## 通信机制概览

```
┌─────────────────────────────────────────────────────────────────┐
│                  Platform Channel 架构                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────┐      │
│   │                   Flutter (Dart)                     │      │
│   └─────────────────────────┬───────────────────────────┘      │
│                             │                                   │
│                    Platform Channel                             │
│   ┌─────────────────────────┼───────────────────────────┐      │
│   │  MethodChannel  │ EventChannel │ BasicMessageChannel│      │
│   └─────────────────────────┼───────────────────────────┘      │
│                             │                                   │
│   ┌──────────────┬──────────┴───────────┬──────────────┐       │
│   │   Android    │        iOS          │   其他平台    │       │
│   │   (Kotlin/   │      (Swift/        │   (C++等)    │       │
│   │    Java)     │    Objective-C)     │              │       │
│   └──────────────┴──────────────────────┴──────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 三种 Channel 类型

| 类型 | 用途 | 通信模式 |
|------|------|----------|
| **MethodChannel** | 方法调用 | 请求-响应 |
| **EventChannel** | 事件流 | 单向流（原生到 Flutter） |
| **BasicMessageChannel** | 消息传递 | 双向异步 |

## MethodChannel

### Flutter 端实现

```dart
import 'package:flutter/services.dart';

class NativeBridge {
  // 定义 Channel 名称（必须唯一）
  static const MethodChannel _channel = MethodChannel('com.example.app/native');
  
  /// 获取设备电量
  static Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      throw Exception('获取电量失败: ${e.message}');
    }
  }
  
  /// 调用带参数的原生方法
  static Future<String> processData(String input, int count) async {
    try {
      final String result = await _channel.invokeMethod('processData', {
        'input': input,
        'count': count,
      });
      return result;
    } on PlatformException catch (e) {
      throw Exception('处理数据失败: ${e.message}');
    }
  }
  
  /// 调用原生方法并获取 Map 结果
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic>? result = 
          await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw Exception('获取设备信息失败: ${e.message}');
    }
  }
  
  /// 设置原生端调用 Flutter 的处理器
  static void setMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNativeEvent':
          final data = call.arguments as Map;
          print('收到原生事件: $data');
          return 'received';
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

### Android 端实现 (Kotlin)

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
package com.example.app

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
                    "processData" -> {
                        val input = call.argument<String>("input")
                        val count = call.argument<Int>("count")
                        if (input != null && count != null) {
                            val processed = processData(input, count)
                            result.success(processed)
                        } else {
                            result.error("INVALID_ARGS", "参数无效", null)
                        }
                    }
                    "getDeviceInfo" -> {
                        val info = mapOf(
                            "brand" to Build.BRAND,
                            "model" to Build.MODEL,
                            "sdk" to Build.VERSION.SDK_INT,
                            "version" to Build.VERSION.RELEASE
                        )
                        result.success(info)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun processData(input: String, count: Int): String {
        return input.repeat(count)
    }
}
```

### iOS 端实现 (Swift)

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
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
                self?.getBatteryLevel(result: result)
            case "processData":
                if let args = call.arguments as? [String: Any],
                   let input = args["input"] as? String,
                   let count = args["count"] as? Int {
                    let processed = self?.processData(input: input, count: count)
                    result(processed)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "参数无效", details: nil))
                }
            case "getDeviceInfo":
                let info: [String: Any] = [
                    "brand": "Apple",
                    "model": UIDevice.current.model,
                    "systemName": UIDevice.current.systemName,
                    "version": UIDevice.current.systemVersion
                ]
                result(info)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getBatteryLevel(result: FlutterResult) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int(UIDevice.current.batteryLevel * 100)
        if level == -100 {
            result(FlutterError(code: "UNAVAILABLE", message: "无法获取电量", details: nil))
        } else {
            result(level)
        }
    }
    
    private func processData(input: String, count: Int) -> String {
        return String(repeating: input, count: count)
    }
}
```

## EventChannel

EventChannel 用于原生端向 Flutter 发送连续的事件流。

### Flutter 端

```dart
class SensorService {
  static const EventChannel _accelerometerChannel = 
      EventChannel('com.example.app/accelerometer');
  
  /// 监听加速度传感器数据
  static Stream<AccelerometerData> get accelerometerStream {
    return _accelerometerChannel.receiveBroadcastStream().map((event) {
      final data = Map<String, double>.from(event);
      return AccelerometerData(
        x: data['x'] ?? 0,
        y: data['y'] ?? 0,
        z: data['z'] ?? 0,
      );
    });
  }
}

class AccelerometerData {
  final double x;
  final double y;
  final double z;
  
  AccelerometerData({required this.x, required this.y, required this.z});
}

// 使用示例
class SensorWidget extends StatefulWidget {
  @override
  State<SensorWidget> createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  late StreamSubscription<AccelerometerData> _subscription;
  AccelerometerData? _data;

  @override
  void initState() {
    super.initState();
    _subscription = SensorService.accelerometerStream.listen((data) {
      setState(() => _data = data);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('X: ${_data?.x}, Y: ${_data?.y}, Z: ${_data?.z}');
  }
}
```

### Android 端 (Kotlin)

```kotlin
package com.example.app

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity(), SensorEventListener {
    private val SENSOR_CHANNEL = "com.example.app/accelerometer"
    
    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    accelerometer?.let {
                        sensorManager.registerListener(
                            this@MainActivity,
                            it,
                            SensorManager.SENSOR_DELAY_NORMAL
                        )
                    }
                }

                override fun onCancel(arguments: Any?) {
                    sensorManager.unregisterListener(this@MainActivity)
                    eventSink = null
                }
            })
    }

    override fun onSensorChanged(event: SensorEvent?) {
        event?.let {
            val data = mapOf(
                "x" to it.values[0].toDouble(),
                "y" to it.values[1].toDouble(),
                "z" to it.values[2].toDouble()
            )
            eventSink?.success(data)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
```

### iOS 端 (Swift)

```swift
import UIKit
import Flutter
import CoreMotion

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let motionManager = CMMotionManager()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        
        // EventChannel
        let eventChannel = FlutterEventChannel(
            name: "com.example.app/accelerometer",
            binaryMessenger: controller.binaryMessenger
        )
        eventChannel.setStreamHandler(AccelerometerStreamHandler(motionManager: motionManager))
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

class AccelerometerStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) {
        self.motionManager = motionManager
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard motionManager.isAccelerometerAvailable else {
            events(FlutterError(code: "UNAVAILABLE", message: "加速度计不可用", details: nil))
            return nil
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            if let error = error {
                events(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            if let data = data {
                let sensorData: [String: Double] = [
                    "x": data.acceleration.x,
                    "y": data.acceleration.y,
                    "z": data.acceleration.z
                ]
                events(sensorData)
            }
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopAccelerometerUpdates()
        return nil
    }
}
```

## BasicMessageChannel

用于传递自定义格式的消息。

```dart
class MessageService {
  static const BasicMessageChannel<String> _stringChannel = 
      BasicMessageChannel('com.example.app/string', StringCodec());
  
  static const BasicMessageChannel<Object?> _jsonChannel = 
      BasicMessageChannel('com.example.app/json', JSONMessageCodec());
  
  /// 发送字符串消息
  static Future<String?> sendString(String message) async {
    return await _stringChannel.send(message);
  }
  
  /// 发送 JSON 消息
  static Future<Map<String, dynamic>?> sendJson(Map<String, dynamic> data) async {
    final response = await _jsonChannel.send(data);
    return response as Map<String, dynamic>?;
  }
  
  /// 设置消息接收处理器
  static void setMessageHandler() {
    _stringChannel.setMessageHandler((message) async {
      print('收到字符串消息: $message');
      return 'received: $message';
    });
    
    _jsonChannel.setMessageHandler((message) async {
      print('收到 JSON 消息: $message');
      return {'status': 'ok', 'received': message};
    });
  }
}
```

## 数据类型对应

| Dart | Android (Java/Kotlin) | iOS (ObjC/Swift) |
|------|----------------------|------------------|
| null | null | nil (NSNull) |
| bool | Boolean | NSNumber(boolValue) |
| int | Integer/Long | NSNumber(intValue) |
| double | Double | NSNumber(doubleValue) |
| String | String | NSString |
| Uint8List | byte[] | FlutterStandardTypedData |
| Int32List | int[] | FlutterStandardTypedData |
| Int64List | long[] | FlutterStandardTypedData |
| Float64List | double[] | FlutterStandardTypedData |
| List | ArrayList | NSArray |
| Map | HashMap | NSDictionary |

## Pigeon 类型安全通信

Pigeon 是官方工具，可自动生成类型安全的 Platform Channel 代码。

### 安装配置

```yaml
# pubspec.yaml
dev_dependencies:
  pigeon: ^15.0.0
```

### 定义接口

```dart
// pigeons/messages.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/example/app/Messages.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.example.app'),
  swiftOut: 'ios/Runner/Messages.g.swift',
))

/// 设备信息数据类
class DeviceInfo {
  String? brand;
  String? model;
  String? osVersion;
  int? sdkVersion;
}

/// 用户数据
class User {
  String? id;
  String? name;
  String? email;
  int? age;
}

/// 宿主端（原生）API - Flutter 调用原生
@HostApi()
abstract class NativeApi {
  @async
  DeviceInfo getDeviceInfo();
  
  @async
  String processText(String input);
  
  @async
  List<User> getUsers();
  
  void saveUser(User user);
}

/// Flutter 端 API - 原生调用 Flutter
@FlutterApi()
abstract class FlutterApi {
  void onUserUpdated(User user);
  String getCurrentTheme();
}
```

### 生成代码

```bash
dart run pigeon --input pigeons/messages.dart
```

### Flutter 端使用

```dart
// lib/src/native_bridge.dart
import 'messages.g.dart';

class NativeBridge {
  final NativeApi _api = NativeApi();
  
  Future<DeviceInfo> getDeviceInfo() async {
    return await _api.getDeviceInfo();
  }
  
  Future<String> processText(String input) async {
    return await _api.processText(input);
  }
  
  Future<List<User?>> getUsers() async {
    return await _api.getUsers();
  }
  
  void saveUser(User user) {
    _api.saveUser(user);
  }
}

// 实现 FlutterApi 供原生调用
class FlutterApiImpl implements FlutterApi {
  @override
  void onUserUpdated(User user) {
    print('用户更新: ${user.name}');
  }
  
  @override
  String getCurrentTheme() {
    return 'dark';
  }
}

// 注册 Flutter API
void setupFlutterApi() {
  FlutterApi.setUp(FlutterApiImpl());
}
```

### Android 端实现 (Kotlin)

```kotlin
// Messages.g.kt 自动生成

// MainActivity.kt
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 实现原生 API
        NativeApi.setUp(flutterEngine.dartExecutor.binaryMessenger, NativeApiImpl(this))
    }
}

class NativeApiImpl(private val context: Context) : NativeApi {
    override fun getDeviceInfo(callback: (Result<DeviceInfo>) -> Unit) {
        val info = DeviceInfo().apply {
            brand = Build.BRAND
            model = Build.MODEL
            osVersion = Build.VERSION.RELEASE
            sdkVersion = Build.VERSION.SDK_INT.toLong()
        }
        callback(Result.success(info))
    }
    
    override fun processText(input: String, callback: (Result<String>) -> Unit) {
        callback(Result.success(input.uppercase()))
    }
    
    override fun getUsers(callback: (Result<List<User>>) -> Unit) {
        val users = listOf(
            User().apply { id = "1"; name = "张三"; email = "zhang@example.com"; age = 25 },
            User().apply { id = "2"; name = "李四"; email = "li@example.com"; age = 30 }
        )
        callback(Result.success(users))
    }
    
    override fun saveUser(user: User) {
        // 保存用户逻辑
        println("保存用户: ${user.name}")
    }
}
```

### iOS 端实现 (Swift)

```swift
// Messages.g.swift 自动生成

// AppDelegate.swift
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        
        // 注册原生 API
        NativeApiSetup.setUp(
            binaryMessenger: controller.binaryMessenger,
            api: NativeApiImpl()
        )
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

class NativeApiImpl: NativeApi {
    func getDeviceInfo(completion: @escaping (Result<DeviceInfo, Error>) -> Void) {
        let info = DeviceInfo(
            brand: "Apple",
            model: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            sdkVersion: nil
        )
        completion(.success(info))
    }
    
    func processText(input: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success(input.uppercased()))
    }
    
    func getUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let users = [
            User(id: "1", name: "张三", email: "zhang@example.com", age: 25),
            User(id: "2", name: "李四", email: "li@example.com", age: 30)
        ]
        completion(.success(users))
    }
    
    func saveUser(user: User) throws {
        print("保存用户: \(user.name ?? "")")
    }
}
```

## 错误处理

```dart
class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.app/native');
  
  static Future<T> callNative<T>(
    String method, [
    dynamic arguments,
  ]) async {
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      if (result == null && null is! T) {
        throw NativeException('原生方法返回空值');
      }
      return result as T;
    } on PlatformException catch (e) {
      throw NativeException(
        '平台异常: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } on MissingPluginException {
      throw NativeException('方法未实现: $method');
    } catch (e) {
      throw NativeException('未知错误: $e');
    }
  }
}

class NativeException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  NativeException(this.message, {this.code, this.details});
  
  @override
  String toString() => 'NativeException: $message (code: $code)';
}
```

## 最佳实践

::: tip 开发建议
1. **使用 Pigeon** - 获得类型安全和自动生成代码
2. **统一命名** - Channel 名称使用反向域名格式
3. **异步处理** - 原生操作可能耗时，始终使用异步
4. **错误处理** - 完善的错误处理和用户提示
5. **线程安全** - 注意原生端的线程问题
6. **文档说明** - 记录所有 Channel 方法和参数
:::

::: warning 注意事项
- Platform Channel 调用有一定性能开销，避免频繁调用
- 大数据传输考虑使用文件或内存映射
- 确保原生端正确处理生命周期
- 测试不同平台的行为差异
:::
