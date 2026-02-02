# Flutter 传感器

Flutter 可以通过 sensors_plus 插件访问设备的各种传感器，包括加速度计、陀螺仪、磁力计等。本章介绍如何在 Flutter 中使用设备传感器。

## 安装

```yaml
dependencies:
  sensors_plus: ^4.0.2
```

```bash
flutter pub add sensors_plus
```

## 支持的传感器

| 传感器 | 说明 | 用途 |
|--------|------|------|
| Accelerometer | 加速度计 | 检测设备加速度 |
| UserAccelerometer | 用户加速度计 | 排除重力的加速度 |
| Gyroscope | 陀螺仪 | 检测设备旋转 |
| Magnetometer | 磁力计 | 检测磁场（指南针） |

## 基础用法

### 加速度计

```dart
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerDemo extends StatefulWidget {
  @override
  State<AccelerometerDemo> createState() => _AccelerometerDemoState();
}

class _AccelerometerDemoState extends State<AccelerometerDemo> {
  double x = 0, y = 0, z = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen((event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('加速度计'),
        Text('X: \${x.toStringAsFixed(2)}'),
        Text('Y: \${y.toStringAsFixed(2)}'),
        Text('Z: \${z.toStringAsFixed(2)}'),
      ],
    );
  }
}
```

### 陀螺仪

```dart
class GyroscopeDemo extends StatefulWidget {
  @override
  State<GyroscopeDemo> createState() => _GyroscopeDemoState();
}

class _GyroscopeDemoState extends State<GyroscopeDemo> {
  double x = 0, y = 0, z = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = gyroscopeEventStream().listen((event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('陀螺仪 (rad/s)'),
        Text('X: \${x.toStringAsFixed(2)}'),
        Text('Y: \${y.toStringAsFixed(2)}'),
        Text('Z: \${z.toStringAsFixed(2)}'),
      ],
    );
  }
}
```

### 磁力计（指南针）

```dart
import 'dart:math' as math;

class CompassDemo extends StatefulWidget {
  @override
  State<CompassDemo> createState() => _CompassDemoState();
}

class _CompassDemoState extends State<CompassDemo> {
  double _heading = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = magnetometerEventStream().listen((event) {
      // 计算方向角
      double heading = math.atan2(event.y, event.x);
      // 转换为度数
      heading = heading * 180 / math.pi;
      // 标准化到 0-360
      if (heading < 0) heading += 360;
      
      setState(() {
        _heading = heading;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('指南针'),
        Text('方向: \${_heading.toStringAsFixed(1)}°'),
        Transform.rotate(
          angle: -_heading * math.pi / 180,
          child: Icon(Icons.navigation, size: 100, color: Colors.red),
        ),
        Text(_getDirection(_heading)),
      ],
    );
  }

  String _getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return '北';
    if (heading >= 22.5 && heading < 67.5) return '东北';
    if (heading >= 67.5 && heading < 112.5) return '东';
    if (heading >= 112.5 && heading < 157.5) return '东南';
    if (heading >= 157.5 && heading < 202.5) return '南';
    if (heading >= 202.5 && heading < 247.5) return '西南';
    if (heading >= 247.5 && heading < 292.5) return '西';
    return '西北';
  }
}
```

## 采样频率控制

```dart
// 设置采样间隔
accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval).listen((event) {
  // 处理数据
});

// 可用的采样间隔
// SensorInterval.fastestInterval - 最快
// SensorInterval.gameInterval    - 游戏级别 (~20ms)
// SensorInterval.uiInterval      - UI 级别 (~60ms)
// SensorInterval.normalInterval  - 普通 (~200ms)
```

## 实际应用：摇一摇

```dart
class ShakeDetector extends StatefulWidget {
  final VoidCallback onShake;
  final Widget child;

  const ShakeDetector({
    required this.onShake,
    required this.child,
  });

  @override
  State<ShakeDetector> createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  StreamSubscription? _subscription;
  DateTime? _lastShakeTime;
  static const double _shakeThreshold = 15.0;
  static const Duration _shakeCooldown = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final acceleration = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );

    if (acceleration > _shakeThreshold) {
      final now = DateTime.now();
      if (_lastShakeTime == null || 
          now.difference(_lastShakeTime!) > _shakeCooldown) {
        _lastShakeTime = now;
        widget.onShake();
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// 使用
ShakeDetector(
  onShake: () {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('摇一摇触发！')),
    );
  },
  child: YourWidget(),
)
```

## 实际应用：水平仪

```dart
class LevelMeter extends StatefulWidget {
  @override
  State<LevelMeter> createState() => _LevelMeterState();
}

class _LevelMeterState extends State<LevelMeter> {
  double _x = 0, _y = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      setState(() {
        // 限制范围
        _x = (event.x / 10).clamp(-1.0, 1.0);
        _y = (event.y / 10).clamp(-1.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 十字线
          Container(width: 1, height: 200, color: Colors.grey),
          Container(width: 200, height: 1, color: Colors.grey),
          // 气泡
          Transform.translate(
            offset: Offset(_x * 80, _y * 80),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_x.abs() < 0.1 && _y.abs() < 0.1)
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 实际应用：计步器

```dart
class StepCounter extends StatefulWidget {
  @override
  State<StepCounter> createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int _steps = 0;
  double _lastMagnitude = 0;
  bool _isStep = false;
  StreamSubscription? _subscription;
  
  static const double _threshold = 12.0;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_detectStep);
  }

  void _detectStep(AccelerometerEvent event) {
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );

    if (magnitude > _threshold && !_isStep) {
      _isStep = true;
      setState(() => _steps++);
    } else if (magnitude < _threshold - 2) {
      _isStep = false;
    }
    
    _lastMagnitude = magnitude;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.directions_walk, size: 64),
        Text('步数', style: TextStyle(fontSize: 16)),
        Text('\$_steps', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => setState(() => _steps = 0),
          child: Text('重置'),
        ),
      ],
    );
  }
}
```

## 封装传感器服务

```dart
class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  final _accelerometerController = StreamController<AccelerometerEvent>.broadcast();
  final _gyroscopeController = StreamController<GyroscopeEvent>.broadcast();
  final _magnetometerController = StreamController<MagnetometerEvent>.broadcast();

  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;
  StreamSubscription? _magSub;

  Stream<AccelerometerEvent> get accelerometerStream => _accelerometerController.stream;
  Stream<GyroscopeEvent> get gyroscopeStream => _gyroscopeController.stream;
  Stream<MagnetometerEvent> get magnetometerStream => _magnetometerController.stream;

  void startListening() {
    _accelSub = accelerometerEventStream().listen((e) {
      _accelerometerController.add(e);
    });
    _gyroSub = gyroscopeEventStream().listen((e) {
      _gyroscopeController.add(e);
    });
    _magSub = magnetometerEventStream().listen((e) {
      _magnetometerController.add(e);
    });
  }

  void stopListening() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magSub?.cancel();
  }

  void dispose() {
    stopListening();
    _accelerometerController.close();
    _gyroscopeController.close();
    _magnetometerController.close();
  }
}
```

## 注意事项

::: warning 注意
1. **电池消耗** - 频繁读取传感器会消耗电池，不需要时应停止监听
2. **采样频率** - 根据需要选择合适的采样频率
3. **平台差异** - 不同设备的传感器精度和特性可能不同
4. **权限** - 部分平台可能需要特定权限
5. **模拟器** - 传感器在模拟器上可能不可用或行为不同
:::

## 性能优化

::: tip 优化建议
1. **按需监听** - 只在需要时启动传感器监听
2. **降低频率** - 使用合适的采样间隔
3. **数据过滤** - 使用低通滤波器平滑数据
4. **批量处理** - 避免每次事件都更新 UI
:::

## 官方文档

- [sensors_plus](https://pub.dev/packages/sensors_plus)
- [Flutter 传感器 API](https://flutter.dev/docs/cookbook/plugins/sensors)
