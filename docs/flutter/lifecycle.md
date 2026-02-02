# 生命周期

理解 Flutter 的生命周期对于正确管理资源、处理前后台切换、优化性能至关重要。本章介绍 Widget 生命周期、App 生命周期以及实际应用场景。

## Widget 生命周期

### StatelessWidget 生命周期

`StatelessWidget` 的生命周期非常简单，只有 `build` 方法：

```dart
class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 每次 Widget 需要渲染时调用
    return const Text('Hello');
  }
}
```

### StatefulWidget 生命周期

`StatefulWidget` 有完整的生命周期：

```dart
class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  
  // 1. 构造函数
  _LifecycleDemoState() {
    print('1. 构造函数');
  }

  // 2. 初始化状态（只调用一次）
  @override
  void initState() {
    super.initState();
    print('2. initState');
    // 适合：初始化数据、订阅流、添加监听器
  }

  // 3. 依赖变化时调用
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('3. didChangeDependencies');
    // 适合：依赖 InheritedWidget 的初始化
  }

  // 4. 构建 UI（可能多次调用）
  @override
  Widget build(BuildContext context) {
    print('4. build');
    return const Scaffold(
      body: Center(child: Text('生命周期演示')),
    );
  }

  // 5. Widget 更新时调用
  @override
  void didUpdateWidget(covariant LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('5. didUpdateWidget');
    // 适合：比较新旧 Widget，更新状态
  }

  // 6. 停用（从树中移除时）
  @override
  void deactivate() {
    print('6. deactivate');
    super.deactivate();
    // 适合：清理临时状态
  }

  // 7. 销毁（只调用一次）
  @override
  void dispose() {
    print('7. dispose');
    // 适合：释放资源、取消订阅、移除监听器
    super.dispose();
  }
}
```

### 生命周期流程图

```
创建阶段:
┌─────────────────┐
│   构造函数       │
└────────┬────────┘
         ↓
┌─────────────────┐
│   initState     │  ← 只调用一次
└────────┬────────┘
         ↓
┌─────────────────┐
│didChangeDeps    │  ← 首次 + 依赖变化时
└────────┬────────┘
         ↓
┌─────────────────┐
│     build       │  ← 可多次调用
└────────┬────────┘

更新阶段:
┌─────────────────┐
│ didUpdateWidget │  ← 父 Widget 重建时
└────────┬────────┘
         ↓
┌─────────────────┐
│     build       │
└─────────────────┘

销毁阶段:
┌─────────────────┐
│   deactivate    │  ← 从树中移除
└────────┬────────┘
         ↓
┌─────────────────┐
│    dispose      │  ← 永久移除时
└─────────────────┘
```

## App 生命周期

使用 `WidgetsBindingObserver` 监听应用的前后台切换：

```dart
class AppLifecycleDemo extends StatefulWidget {
  const AppLifecycleDemo({super.key});

  @override
  State<AppLifecycleDemo> createState() => _AppLifecycleDemoState();
}

class _AppLifecycleDemoState extends State<AppLifecycleDemo>
    with WidgetsBindingObserver {
  
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    // 注册观察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });

    switch (state) {
      case AppLifecycleState.inactive:
        // 应用处于非活动状态（如来电、切换应用）
        print('App 进入非活动状态');
        _onAppInactive();
        break;
        
      case AppLifecycleState.paused:
        // 应用进入后台
        print('App 进入后台');
        _onAppPaused();
        break;
        
      case AppLifecycleState.resumed:
        // 应用回到前台
        print('App 回到前台');
        _onAppResumed();
        break;
        
      case AppLifecycleState.detached:
        // 应用即将销毁（Android 特有）
        print('App 即将销毁');
        _onAppDetached();
        break;
        
      case AppLifecycleState.hidden:
        // 应用所有视图都被隐藏（Flutter 3.13+）
        print('App 视图被隐藏');
        break;
    }
  }

  void _onAppInactive() {
    // 暂停动画、音视频
  }

  void _onAppPaused() {
    // 保存状态、停止网络请求
  }

  void _onAppResumed() {
    // 恢复数据、刷新状态
  }

  void _onAppDetached() {
    // 最后的清理工作
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 生命周期')),
      body: Center(
        child: Text(
          '当前状态: ${_lastLifecycleState?.name ?? "未知"}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
```

### AppLifecycleState 状态说明

| 状态 | 说明 | 触发场景 |
|------|------|----------|
| `inactive` | 非活动 | 来电、权限弹窗、切换应用中 |
| `paused` | 后台 | 完全进入后台 |
| `resumed` | 前台活动 | 回到前台并可交互 |
| `hidden` | 隐藏 | 所有视图不可见 |
| `detached` | 分离 | 引擎与视图分离 |

### 状态转换流程

```
启动应用:
        ┌─────────┐
        │ resumed │
        └─────────┘

切换到后台:
┌─────────┐   ┌──────────┐   ┌────────┐
│ resumed │ → │ inactive │ → │ paused │
└─────────┘   └──────────┘   └────────┘

返回前台:
┌────────┐   ┌──────────┐   ┌─────────┐
│ paused │ → │ inactive │ → │ resumed │
└────────┘   └──────────┘   └─────────┘
```

## 实际应用

### 1. 视频播放器暂停/恢复

```dart
class VideoPlayerDemo extends StatefulWidget {
  const VideoPlayerDemo({super.key});

  @override
  State<VideoPlayerDemo> createState() => _VideoPlayerDemoState();
}

class _VideoPlayerDemoState extends State<VideoPlayerDemo>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVideoPlayer();
  }

  void _initVideoPlayer() {
    _controller = VideoPlayerController.network('video_url')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 记录播放状态并暂停
      _wasPlaying = _controller.value.isPlaying;
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      // 如果之前在播放，则恢复
      if (_wasPlaying) {
        _controller.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
```

### 2. 计时器应用

```dart
class TimerDemo extends StatefulWidget {
  const TimerDemo({super.key});

  @override
  State<TimerDemo> createState() => _TimerDemoState();
}

class _TimerDemoState extends State<TimerDemo> with WidgetsBindingObserver {
  int _seconds = 0;
  Timer? _timer;
  DateTime? _pausedAt;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRunning) {
      // 记录暂停时间
      _pausedAt = DateTime.now();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed && _isRunning) {
      // 恢复时计算经过的时间
      if (_pausedAt != null) {
        final elapsed = DateTime.now().difference(_pausedAt!).inSeconds;
        setState(() {
          _seconds += elapsed;
        });
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计时器')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_seconds),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  child: Text(_isRunning ? '暂停' : '开始'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('重置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
```

### 3. 网络连接监听

```dart
class NetworkAwareWidget extends StatefulWidget {
  const NetworkAwareWidget({super.key});

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget>
    with WidgetsBindingObserver {
  
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 标记需要刷新
      _needsRefresh = true;
    } else if (state == AppLifecycleState.resumed && _needsRefresh) {
      // 回到前台时刷新数据
      _needsRefresh = false;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // 加载最新数据
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('网络感知组件')),
    );
  }
}
```

### 4. 表单数据保存

```dart
class FormSaveDemo extends StatefulWidget {
  const FormSaveDemo({super.key});

  @override
  State<FormSaveDemo> createState() => _FormSaveDemoState();
}

class _FormSaveDemoState extends State<FormSaveDemo>
    with WidgetsBindingObserver {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDraft();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // 自动保存草稿
      _saveDraft();
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('draft_name') ?? '';
      _emailController.text = prefs.getString('draft_email') ?? '';
    });
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_name', _nameController.text);
    await prefs.setString('draft_email', _emailController.text);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_name');
    await prefs.remove('draft_email');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('表单自动保存')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '邮箱'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // 提交表单
                await _clearDraft();
                // ...
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 其他生命周期回调

`WidgetsBindingObserver` 还提供其他有用的回调：

```dart
class FullObserverDemo extends StatefulWidget {
  const FullObserverDemo({super.key});

  @override
  State<FullObserverDemo> createState() => _FullObserverDemoState();
}

class _FullObserverDemoState extends State<FullObserverDemo>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// 系统亮度变化
  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    print('亮度变化: $brightness');
  }

  /// 系统语言变化
  @override
  void didChangeLocales(List<Locale>? locales) {
    print('语言变化: $locales');
  }

  /// 文字缩放比例变化
  @override
  void didChangeTextScaleFactor() {
    final textScaleFactor = WidgetsBinding.instance.platformDispatcher.textScaleFactor;
    print('文字缩放: $textScaleFactor');
  }

  /// 屏幕尺寸变化
  @override
  void didChangeMetrics() {
    final window = WidgetsBinding.instance.platformDispatcher.views.first;
    print('屏幕尺寸: ${window.physicalSize}');
  }

  /// 内存警告
  @override
  void didHaveMemoryPressure() {
    print('内存不足，需要释放资源');
    // 清理缓存、释放不必要的资源
  }

  /// 无障碍功能变化
  @override
  void didChangeAccessibilityFeatures() {
    print('无障碍设置变化');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('完整观察者演示')),
    );
  }
}
```

## 最佳实践

::: tip 开发建议
1. **initState** - 初始化控制器、添加监听器
2. **dispose** - 释放所有资源，避免内存泄漏
3. **前后台切换** - 暂停/恢复动画、音视频、网络请求
4. **状态保存** - 在 paused 时保存重要数据
5. **避免在 build 中执行耗时操作**
:::

::: warning 常见错误
- 忘记在 `dispose` 中移除监听器
- 在 `dispose` 后调用 `setState`
- 在 `initState` 中访问 `context`（此时 Widget 尚未挂载）
- 忘记调用 `super.initState()` 或 `super.dispose()`
:::

## 参考资源

- [State 类文档](https://api.flutter.dev/flutter/widgets/State-class.html)
- [WidgetsBindingObserver](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html)
- [AppLifecycleState](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)
