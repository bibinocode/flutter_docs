# RotationTransition

`RotationTransition` 是 Flutter 中用于创建显式旋转动画的组件。与 `AnimatedRotation` 不同，它需要配合 `AnimationController` 使用，提供了对旋转动画的完全控制能力，适用于加载指示器、刷新图标、展开/收起箭头、风车等场景。

## 基本用法

```dart
RotationTransition(
  turns: _animation,
  child: Icon(
    Icons.refresh,
    size: 48,
  ),
)
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `turns` | `Animation<double>` | 控制旋转圈数的动画对象，1.0 表示旋转一圈（360度）（必需） |
| `alignment` | `Alignment` | 旋转的对齐点/锚点，默认 `Alignment.center`，决定围绕哪个点旋转 |
| `filterQuality` | `FilterQuality?` | 旋转时的图像过滤质量，影响渲染效果和性能 |
| `child` | `Widget?` | 要应用旋转动画的子组件 |

## turns 属性说明

`turns` 属性决定旋转的角度：

- `0.0` → 不旋转（0度）
- `0.25` → 旋转四分之一圈（90度）
- `0.5` → 旋转半圈（180度）
- `1.0` → 旋转一整圈（360度）
- `2.0` → 旋转两圈（720度）

```dart
// 从 0 到 1 表示旋转一整圈
_animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

// 从 0 到 0.5 表示旋转半圈
_animation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
```

## 使用场景

### 1. 加载指示器

持续旋转的加载动画：

```dart
class LoadingIndicator extends StatefulWidget {
  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(); // 无限循环
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(
        Icons.settings,
        size: 48,
        color: Colors.blue,
      ),
    );
  }
}
```

### 2. 刷新图标

点击旋转的刷新按钮：

```dart
class RefreshButton extends StatefulWidget {
  final VoidCallback onRefresh;
  
  const RefreshButton({required this.onRefresh});

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    _controller.forward(from: 0.0);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _handleRefresh,
      icon: RotationTransition(
        turns: _controller,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### 3. 展开/收起箭头

展开状态指示器：

```dart
class ExpandableHeader extends StatefulWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ExpandableHeader({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<ExpandableHeader> createState() => _ExpandableHeaderState();
}

class _ExpandableHeaderState extends State<ExpandableHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: Row(
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18)),
          const Spacer(),
          RotationTransition(
            turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
            child: const Icon(Icons.expand_more),
          ),
        ],
      ),
    );
  }
}
```

### 4. 风车效果

持续旋转的风车动画：

```dart
class Windmill extends StatefulWidget {
  @override
  State<Windmill> createState() => _WindmillState();
}

class _WindmillState extends State<Windmill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: const Size(100, 100),
        painter: WindmillPainter(),
      ),
    );
  }
}
```

## 完整示例

旋转刷新按钮完整实现：

```dart
import 'package:flutter/material.dart';

class RotationTransitionDemo extends StatefulWidget {
  const RotationTransitionDemo({super.key});

  @override
  State<RotationTransitionDemo> createState() => _RotationTransitionDemoState();
}

class _RotationTransitionDemoState extends State<RotationTransitionDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    _controller.repeat();
    
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 2));
    
    _controller.stop();
    _controller.reset();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RotationTransition 示例'),
        actions: [
          IconButton(
            onPressed: _handleRefresh,
            icon: RotationTransition(
              turns: _animation,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 大号旋转刷新按钮
            GestureDetector(
              onTap: _handleRefresh,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: RotationTransition(
                    turns: _animation,
                    child: Icon(
                      Icons.sync,
                      size: 60,
                      color: _isLoading ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isLoading ? '刷新中...' : '点击刷新',
              style: TextStyle(
                fontSize: 18,
                color: _isLoading ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

1. **配合 `AnimationController.repeat()` 实现持续旋转**
   ```dart
   _controller = AnimationController(
     duration: const Duration(seconds: 1),
     vsync: this,
   )..repeat(); // 无限循环旋转
   ```

2. **使用 `Curves` 控制旋转节奏**
   ```dart
   _animation = CurvedAnimation(
     parent: _controller,
     curve: Curves.easeInOut, // 平滑的加速减速
   );
   ```

3. **记得在 `dispose` 中释放控制器**
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

4. **调整 `alignment` 改变旋转中心点**
   ```dart
   RotationTransition(
     turns: _animation,
     alignment: Alignment.topCenter, // 围绕顶部中心旋转
     child: child,
   )
   ```

5. **使用 `Tween` 控制旋转范围**
   ```dart
   // 只旋转 90 度
   _animation = Tween<double>(begin: 0.0, end: 0.25).animate(_controller);
   ```

## 相关组件

- [AnimatedRotation](https://api.flutter.dev/flutter/widgets/AnimatedRotation-class.html) - 隐式旋转动画，无需手动管理控制器
- [ScaleTransition](./scaletransition.md) - 显式缩放动画，可与旋转组合使用
- [Transform.rotate](https://api.flutter.dev/flutter/widgets/Transform/Transform.rotate.html) - 静态旋转变换，不带动画

## 官方文档

- [RotationTransition API](https://api.flutter.dev/flutter/widgets/RotationTransition-class.html)
