# TweenAnimationBuilder

TweenAnimationBuilder 是一个声明式的动画构建器，无需手动管理 AnimationController，适合简单的隐式动画场景。

## 基本用法

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: 1),
  duration: const Duration(seconds: 1),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: child,
    );
  },
  child: const Text('Hello'),
)
```

## 构造函数

```dart
const TweenAnimationBuilder<T extends Object?>({
  super.key,
  required this.tween,       // Tween 对象
  required this.duration,    // 动画时长
  this.curve = Curves.linear, // 动画曲线
  required this.builder,      // 构建器
  this.onEnd,                // 动画结束回调
  this.child,                // 静态子组件
})
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `tween` | `Tween<T>` | 定义动画值范围 |
| `duration` | `Duration` | 动画持续时间 |
| `curve` | `Curve` | 动画曲线 |
| `builder` | `ValueWidgetBuilder<T>` | 构建器函数 |
| `onEnd` | `VoidCallback?` | 动画完成回调 |
| `child` | `Widget?` | 不变的子组件 |

## 与 AnimatedBuilder 对比

| 特性 | TweenAnimationBuilder | AnimatedBuilder |
|------|----------------------|-----------------|
| 需要 AnimationController | ❌ | ✅ |
| 手动控制动画 | ❌ | ✅ |
| 声明式使用 | ✅ | ❌ |
| 适合场景 | 简单动画 | 复杂动画 |
| 循环动画 | 不支持 | 支持 |

## 完整示例

```dart
import 'package:flutter/material.dart';

class TweenAnimationBuilderDemo extends StatefulWidget {
  const TweenAnimationBuilderDemo({super.key});

  @override
  State<TweenAnimationBuilderDemo> createState() =>
      _TweenAnimationBuilderDemoState();
}

class _TweenAnimationBuilderDemoState extends State<TweenAnimationBuilderDemo> {
  double _targetValue = 1.0;

  void _toggle() {
    setState(() {
      _targetValue = _targetValue == 1.0 ? 0.0 : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TweenAnimationBuilder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 透明度动画
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _targetValue),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Container(
                width: 150,
                height: 150,
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    'Flutter',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: _toggle,
              child: Text(_targetValue == 1.0 ? '隐藏' : '显示'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 常见动画效果

### 缩放动画

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.5, end: _isExpanded ? 1.5 : 1.0),
  duration: const Duration(milliseconds: 300),
  curve: Curves.elasticOut,
  builder: (context, scale, child) {
    return Transform.scale(
      scale: scale,
      child: child,
    );
  },
  child: const FlutterLogo(size: 100),
)
```

### 旋转动画

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: _rotated ? 3.14 : 0),
  duration: const Duration(milliseconds: 500),
  builder: (context, angle, child) {
    return Transform.rotate(
      angle: angle,
      child: child,
    );
  },
  child: const Icon(Icons.arrow_forward, size: 50),
)
```

### 颜色动画

```dart
TweenAnimationBuilder<Color?>(
  tween: ColorTween(
    begin: Colors.blue,
    end: _isActive ? Colors.green : Colors.red,
  ),
  duration: const Duration(milliseconds: 300),
  builder: (context, color, child) {
    return Container(
      width: 100,
      height: 100,
      color: color,
      child: child,
    );
  },
  child: const Icon(Icons.check, color: Colors.white),
)
```

### 尺寸动画

```dart
TweenAnimationBuilder<Size>(
  tween: SizeTween(
    begin: const Size(100, 100),
    end: _expanded ? const Size(200, 150) : const Size(100, 100),
  ),
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeOutCubic,
  builder: (context, size, child) {
    return Container(
      width: size?.width,
      height: size?.height,
      color: Colors.purple,
      child: child,
    );
  },
  child: const Center(child: Text('Size', style: TextStyle(color: Colors.white))),
)
```

### 位置动画

```dart
TweenAnimationBuilder<Offset>(
  tween: Tween(
    begin: Offset.zero,
    end: _moved ? const Offset(100, 50) : Offset.zero,
  ),
  duration: const Duration(milliseconds: 500),
  curve: Curves.bounceOut,
  builder: (context, offset, child) {
    return Transform.translate(
      offset: offset,
      child: child,
    );
  },
  child: Container(
    width: 80,
    height: 80,
    color: Colors.orange,
  ),
)
```

## 边框圆角动画

```dart
TweenAnimationBuilder<BorderRadius>(
  tween: BorderRadiusTween(
    begin: BorderRadius.zero,
    end: _rounded ? BorderRadius.circular(50) : BorderRadius.zero,
  ),
  duration: const Duration(milliseconds: 300),
  builder: (context, radius, child) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: radius,
      ),
      child: child,
    );
  },
  child: const Icon(Icons.star, color: Colors.white),
)
```

## 组合多个动画

```dart
class CombinedAnimation extends StatefulWidget {
  const CombinedAnimation({super.key});

  @override
  State<CombinedAnimation> createState() => _CombinedAnimationState();
}

class _CombinedAnimationState extends State<CombinedAnimation> {
  bool _isAnimated = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAnimated = !_isAnimated;
        });
      },
      // 缩放 + 旋转 + 颜色
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _isAnimated ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          return TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: Colors.blue,
              end: _isAnimated ? Colors.red : Colors.blue,
            ),
            duration: const Duration(milliseconds: 500),
            builder: (context, color, _) {
              return Transform.scale(
                scale: 1 + (value * 0.3),
                child: Transform.rotate(
                  angle: value * 3.14,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16 + value * 34),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## 计数器动画

```dart
class AnimatedCounter extends StatelessWidget {
  final int value;

  const AnimatedCounter({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '$animatedValue',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

// 使用
AnimatedCounter(value: 1000)
```

## 进度条动画

```dart
class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0

  const AnimatedProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${(value * 100).toInt()}%'),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

## 使用 onEnd 回调

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: _value),
  duration: const Duration(milliseconds: 500),
  onEnd: () {
    // 动画完成时的回调
    print('动画完成！');
    // 可以触发下一个动画或执行其他逻辑
  },
  builder: (context, value, child) {
    return Opacity(opacity: value, child: child);
  },
  child: const Text('Fade In'),
)
```

## 注意事项

::: warning 重要
1. 当 `tween.end` 值改变时，动画会自动从当前值过渡到新值
2. 初始构建时会从 `tween.begin` 动画到 `tween.end`
3. 不支持循环动画，如需循环请使用 AnimationController
:::

## 相关组件

- [AnimatedBuilder](./animatedbuilder.md) - 需要更多控制时使用
- [AnimatedContainer](./animatedcontainer.md) - 容器隐式动画
- [AnimatedOpacity](./animatedopacity.md) - 透明度隐式动画
