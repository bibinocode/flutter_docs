# ScaleTransition

`ScaleTransition` 是 Flutter 中用于创建显式缩放动画的组件。与 `AnimatedScale` 不同，它需要配合 `AnimationController` 使用，提供了对缩放动画的完全控制能力，适用于按钮点击反馈、弹出动画、脉冲效果等场景。

## 基本用法

```dart
ScaleTransition(
  scale: _animation,
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
| `scale` | `Animation<double>` | 控制缩放比例的动画对象，1.0 为原始大小，0.0 为完全缩小（必需） |
| `alignment` | `Alignment` | 缩放的对齐点/锚点，默认 `Alignment.center`，决定从哪个点开始缩放 |
| `filterQuality` | `FilterQuality?` | 缩放时的图像过滤质量，影响渲染效果和性能 |
| `child` | `Widget?` | 要应用缩放动画的子组件 |

## AnimationController 配合使用

`ScaleTransition` 是显式动画组件，必须与 `AnimationController` 配合使用：

```dart
class ScaleTransitionDemo extends StatefulWidget {
  @override
  State<ScaleTransitionDemo> createState() => _ScaleTransitionDemoState();
}

class _ScaleTransitionDemoState extends State<ScaleTransitionDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 添加曲线让动画更自然
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
    );
  }
}
```

## 使用场景

### 1. 按钮点击反馈

通过缩放效果提供视觉反馈：

```dart
class ScaleButtonDemo extends StatefulWidget {
  @override
  State<ScaleButtonDemo> createState() => _ScaleButtonDemoState();
}

class _ScaleButtonDemoState extends State<ScaleButtonDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _animation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '点击我',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
```

### 2. 弹出动画

元素从无到有的弹出效果：

```dart
class PopupDemo extends StatefulWidget {
  @override
  State<PopupDemo> createState() => _PopupDemoState();
}

class _PopupDemoState extends State<PopupDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPopup() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('弹出内容', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _showPopup,
          child: const Text('显示弹窗'),
        ),
      ],
    );
  }
}
```

### 3. 脉冲效果

循环缩放形成脉冲动画：

```dart
class PulseDemo extends StatefulWidget {
  @override
  State<PulseDemo> createState() => _PulseDemoState();
}

class _PulseDemoState extends State<PulseDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // 循环播放
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
```

### 4. 加载动画

缩放结合延迟创建波浪加载效果：

```dart
class LoadingDotsDemo extends StatefulWidget {
  @override
  State<LoadingDotsDemo> createState() => _LoadingDotsDemoState();
}

class _LoadingDotsDemoState extends State<LoadingDotsDemo>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // 依次启动动画，形成波浪效果
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ScaleTransition(
            scale: _animations[index],
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
```

## 完整示例：点赞心跳动画

```dart
import 'package:flutter/material.dart';

class LikeHeartbeatDemo extends StatefulWidget {
  const LikeHeartbeatDemo({super.key});

  @override
  State<LikeHeartbeatDemo> createState() => _LikeHeartbeatDemoState();
}

class _LikeHeartbeatDemoState extends State<LikeHeartbeatDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 使用 TweenSequence 创建心跳效果
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    if (_isLiked) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('点赞心跳动画'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 心跳动画
            GestureDetector(
              onTap: _toggleLike,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isLiked ? '已点赞' : '点击点赞',
              style: TextStyle(
                fontSize: 18,
                color: _isLiked ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 60),
            // 说明文字
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '点击心形图标触发心跳缩放动画\n'
                '使用 TweenSequence 创建先放大后缩小的效果',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## alignment 属性详解

`alignment` 决定缩放的锚点位置：

```dart
// 从中心缩放（默认）
ScaleTransition(
  scale: _animation,
  alignment: Alignment.center,
  child: child,
)

// 从左上角缩放
ScaleTransition(
  scale: _animation,
  alignment: Alignment.topLeft,
  child: child,
)

// 从底部中心缩放
ScaleTransition(
  scale: _animation,
  alignment: Alignment.bottomCenter,
  child: child,
)
```

## 最佳实践

### 1. 配合 CurvedAnimation 使用

添加曲线让动画更自然、更有弹性：

```dart
// 弹性效果 - 适合弹出动画
_animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.elasticOut,
);

// 回弹效果 - 适合按钮点击
_animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeOutBack,
);

// 平滑效果 - 适合一般过渡
_animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
);
```

### 2. 合理设置缩放范围

```dart
// 微小缩放 - 按钮反馈
Tween<double>(begin: 0.95, end: 1.0)

// 弹出效果 - 从无到有
Tween<double>(begin: 0.0, end: 1.0)

// 脉冲效果 - 轻微放大
Tween<double>(begin: 1.0, end: 1.2)

// 强调效果 - 明显放大
Tween<double>(begin: 1.0, end: 1.5)
```

### 3. 组合其他 Transition

```dart
// 缩放 + 淡入
FadeTransition(
  opacity: _fadeAnimation,
  child: ScaleTransition(
    scale: _scaleAnimation,
    child: child,
  ),
)

// 缩放 + 旋转
RotationTransition(
  turns: _rotationAnimation,
  child: ScaleTransition(
    scale: _scaleAnimation,
    child: child,
  ),
)
```

### 4. 及时释放资源

```dart
@override
void dispose() {
  _controller.dispose(); // 必须释放 AnimationController
  super.dispose();
}
```

### 5. 使用 TweenSequence 创建复杂动画

```dart
// 心跳效果：放大 → 缩小 → 轻微放大 → 恢复
_animation = TweenSequence<double>([
  TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 25),
  TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 25),
  TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 25),
  TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
]).animate(_controller);
```

## 相关组件

- [AnimatedScale](https://api.flutter.dev/flutter/widgets/AnimatedScale-class.html)：隐式缩放动画，更简单但控制较少
- [FadeTransition](./fadetransition.md)：显式透明度动画
- [RotationTransition](./rotationtransition.md)：显式旋转动画
- [SlideTransition](./slidetransition.md)：显式位移动画
- [AnimatedContainer](./animatedcontainer.md)：隐式动画容器

## 官方文档

- [ScaleTransition API](https://api.flutter.dev/flutter/widgets/ScaleTransition-class.html)
- [AnimationController](https://api.flutter.dev/flutter/animation/AnimationController-class.html)
- [CurvedAnimation](https://api.flutter.dev/flutter/animation/CurvedAnimation-class.html)
