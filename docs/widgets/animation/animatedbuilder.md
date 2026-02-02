# AnimatedBuilder

AnimatedBuilder 用于将动画逻辑与 UI 构建分离，是构建自定义动画的核心组件。

## 基本用法

```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: _controller.value * 2 * math.pi,
      child: child,
    );
  },
  child: const Icon(Icons.star, size: 100), // 不会重建
)
```

## 构造函数

```dart
const AnimatedBuilder({
  super.key,
  required this.animation,  // 要监听的动画
  required this.builder,    // 构建器函数
  this.child,               // 静态子组件（优化性能）
})
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `animation` | `Listenable` | 要监听的动画对象 |
| `builder` | `TransitionBuilder` | 每帧调用的构建函数 |
| `child` | `Widget?` | 不随动画变化的子组件 |

## 为什么使用 AnimatedBuilder

### 问题：在 StatefulWidget 中直接使用动画

```dart
// ❌ 不推荐：整个 build 方法每帧都会执行
class BadExample extends StatefulWidget {
  @override
  State<BadExample> createState() => _BadExampleState();
}

class _BadExampleState extends State<BadExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _controller.addListener(() {
      setState(() {}); // 每帧调用 setState
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _controller.value * 2 * math.pi,
      child: const Icon(Icons.star, size: 100),
    );
  }
}
```

### 解决：使用 AnimatedBuilder

```dart
// ✅ 推荐：只有 builder 部分每帧执行，child 不重建
class GoodExample extends StatefulWidget {
  @override
  State<GoodExample> createState() => _GoodExampleState();
}

class _GoodExampleState extends State<GoodExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: const Icon(Icons.star, size: 100), // 不会重建
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child, // 使用传入的 child
        );
      },
    );
  }
}
```

## 完整示例

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBuilderDemo extends StatefulWidget {
  const AnimatedBuilderDemo({super.key});

  @override
  State<AnimatedBuilderDemo> createState() => _AnimatedBuilderDemoState();
}

class _AnimatedBuilderDemoState extends State<AnimatedBuilderDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedBuilder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 旋转动画
            AnimatedBuilder(
              animation: _controller,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // 缩放动画
            AnimatedBuilder(
              animation: _controller,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              builder: (context, child) {
                final scale = 0.5 + (_controller.value * 0.5);
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 多属性动画

```dart
class MultiPropertyAnimation extends StatefulWidget {
  const MultiPropertyAnimation({super.key});

  @override
  State<MultiPropertyAnimation> createState() => _MultiPropertyAnimationState();
}

class _MultiPropertyAnimationState extends State<MultiPropertyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 自定义进度指示器

```dart
class CustomProgressIndicator extends StatefulWidget {
  final double progress; // 0.0 - 1.0

  const CustomProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  State<CustomProgressIndicator> createState() => _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(100, 100),
          painter: _ProgressPainter(
            progress: widget.progress,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;

  _ProgressPainter({
    required this.progress,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // 背景圆
    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bgPaint);

    // 进度弧
    final progressPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    final startAngle = -math.pi / 2 + (animationValue * 2 * math.pi);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue;
  }
}
```

## 监听多个动画

```dart
AnimatedBuilder(
  // 使用 Listenable.merge 监听多个动画
  animation: Listenable.merge([_controller1, _controller2]),
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(_controller1.value * 100, _controller2.value * 100),
      child: child,
    );
  },
  child: const FlutterLogo(size: 100),
)
```

## 性能优化提示

::: tip child 参数的重要性
将不随动画变化的 Widget 放在 `child` 参数中，可以避免每帧重建，显著提升性能。
:::

```dart
// ✅ 好的做法
AnimatedBuilder(
  animation: _controller,
  child: const ExpensiveWidget(), // 只构建一次
  builder: (context, child) {
    return Transform.scale(
      scale: _controller.value,
      child: child, // 复用 child
    );
  },
)

// ❌ 不好的做法
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: _controller.value,
      child: const ExpensiveWidget(), // 每帧都会构建
    );
  },
)
```

## 相关组件

- [TweenAnimationBuilder](./tweenanimationbuilder.md) - 声明式动画
- [AnimatedWidget](./index.md) - 动画基类
- [AnimationController](./index.md) - 动画控制器
