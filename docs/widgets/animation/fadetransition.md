# FadeTransition

`FadeTransition` 是 Flutter 中用于创建显式透明度动画的组件。与 `AnimatedOpacity` 不同，它需要配合 `AnimationController` 使用，提供了对动画的完全控制能力，包括播放、暂停、反转和重复等操作。

## 基本用法

```dart
FadeTransition(
  opacity: _animation,
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `opacity` | `Animation<double>` | 控制透明度的动画对象，取值范围 0.0（完全透明）到 1.0（完全不透明）（必需） |
| `alwaysIncludeSemantics` | `bool` | 是否始终包含语义信息，默认 `false`。为 `true` 时即使透明度为 0 也会保留语义，对无障碍功能很重要 |
| `child` | `Widget?` | 要应用透明度动画的子组件 |

## AnimationController 配合使用

`FadeTransition` 是显式动画组件，必须与 `AnimationController` 配合使用：

```dart
class FadeTransitionDemo extends StatefulWidget {
  @override
  State<FadeTransitionDemo> createState() => _FadeTransitionDemoState();
}

class _FadeTransitionDemoState extends State<FadeTransitionDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 创建 AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 可选：添加曲线
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 必须释放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
    );
  }
}
```

### 常用控制方法

```dart
_controller.forward();  // 正向播放（0 → 1）
_controller.reverse();  // 反向播放（1 → 0）
_controller.repeat();   // 循环播放
_controller.stop();     // 停止动画
_controller.reset();    // 重置到初始状态
_controller.animateTo(0.5); // 动画到指定值
```

## 使用场景

### 1. 可控淡入淡出

适用于需要精确控制动画时机的场景：

```dart
class ControlledFadeDemo extends StatefulWidget {
  @override
  State<ControlledFadeDemo> createState() => _ControlledFadeDemoState();
}

class _ControlledFadeDemoState extends State<ControlledFadeDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _controller,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.star, color: Colors.white, size: 60),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _toggleVisibility,
          child: const Text('切换显示'),
        ),
      ],
    );
  }
}
```

### 2. 列表项依次出现

使用 `Interval` 实现交错动画效果：

```dart
class StaggeredListItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int totalItems;
  final Widget child;

  const StaggeredListItem({
    required this.controller,
    required this.index,
    required this.totalItems,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 计算每个项目的动画区间
    final double start = index / totalItems;
    final double end = (index + 1) / totalItems;

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        )),
        child: child,
      ),
    );
  }
}
```

### 3. 启动动画（Splash 效果）

```dart
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: const FlutterLogo(size: 150),
      ),
    );
  }
}
```

## 完整示例：列表依次淡入

```dart
import 'package:flutter/material.dart';

class StaggeredFadeListDemo extends StatefulWidget {
  const StaggeredFadeListDemo({super.key});

  @override
  State<StaggeredFadeListDemo> createState() => _StaggeredFadeListDemoState();
}

class _StaggeredFadeListDemoState extends State<StaggeredFadeListDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _items = [
    '🍎 Apple',
    '🍊 Orange',
    '🍋 Lemon',
    '🍇 Grape',
    '🍓 Strawberry',
    '🍑 Peach',
    '🥝 Kiwi',
    '🍍 Pineapple',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // 页面加载后自动播放动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('列表依次淡入'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: _replay,
            tooltip: '重新播放',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          // 计算每个项目的动画时间区间
          final double intervalStart = index / _items.length;
          final double intervalEnd = (index + 1) / _items.length;

          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                intervalStart,
                intervalEnd,
                curve: Curves.easeOut,
              ),
            ),
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                intervalStart,
                intervalEnd,
                curve: Curves.easeOut,
              ),
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    _items[index],
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## 最佳实践

### 显式动画 vs 隐式动画

| 特性 | FadeTransition（显式） | AnimatedOpacity（隐式） |
|------|------------------------|------------------------|
| 控制器 | 需要 AnimationController | 不需要，自动管理 |
| 复杂度 | 较高，需要手动管理生命周期 | 较低，使用简单 |
| 控制能力 | 完全控制（播放、暂停、反转、重复） | 有限，仅响应属性变化 |
| 适用场景 | 复杂动画、交错动画、需要精确控制 | 简单淡入淡出、状态切换 |
| 组合动画 | 易于与其他显式动画组合 | 难以精确同步多个动画 |
| 性能 | 可优化，按需控制 | 每次属性变化都触发动画 |

### 选择建议

**使用 `FadeTransition` 当：**
- 需要播放、暂停、反转等精确控制
- 实现交错动画或序列动画
- 需要与其他显式动画同步
- 动画需要循环播放
- 需要监听动画状态

**使用 `AnimatedOpacity` 当：**
- 简单的淡入淡出效果
- 响应单一状态变化
- 不需要复杂的动画控制
- 快速原型开发

### 性能优化

```dart
// ✅ 好：使用 const 子组件
FadeTransition(
  opacity: _animation,
  child: const MyStaticWidget(),
)

// ✅ 好：及时释放控制器
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ✅ 好：使用 AnimatedBuilder 分离动画逻辑
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Opacity(
      opacity: _controller.value,
      child: child,
    );
  },
  child: const ExpensiveWidget(), // 只构建一次
)
```

## 相关组件

- [AnimatedOpacity](./animatedopacity.md) - 隐式透明度动画，使用更简单
- [ScaleTransition](./scaletransition.md) - 显式缩放动画
- [SlideTransition](./slidetransition.md) - 显式滑动动画
- [RotationTransition](./rotationtransition.md) - 显式旋转动画
- [AnimatedSwitcher](./animatedswitcher.md) - 子组件切换动画

## 官方文档

- [FadeTransition API](https://api.flutter.dev/flutter/widgets/FadeTransition-class.html)
- [Animation and motion widgets](https://docs.flutter.dev/ui/widgets/animation)
