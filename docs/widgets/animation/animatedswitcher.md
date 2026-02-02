# AnimatedSwitcher

`AnimatedSwitcher` 是 Flutter 中的通用组件切换动画组件。当其子组件发生变化时，会自动在新旧组件之间产生平滑的过渡效果，非常适合用于内容切换场景。

## 基本用法

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: Text(
    '$_count',
    key: ValueKey<int>(_count), // key 变化时触发动画
  ),
)
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget?` | 当前显示的子组件（key 变化时触发动画） |
| `duration` | `Duration` | 切入动画时长（必需） |
| `reverseDuration` | `Duration?` | 切出动画时长，默认与 duration 相同 |
| `switchInCurve` | `Curve` | 切入动画曲线，默认 `Curves.linear` |
| `switchOutCurve` | `Curve` | 切出动画曲线，默认 `Curves.linear` |
| `transitionBuilder` | `AnimatedSwitcherTransitionBuilder` | 过渡动画构建器，默认为 FadeTransition |
| `layoutBuilder` | `AnimatedSwitcherLayoutBuilder` | 布局构建器，控制新旧组件的叠放方式 |

## 使用场景

### 1. 数字计数器

```dart
class CounterAnimation extends StatefulWidget {
  @override
  _CounterAnimationState createState() => _CounterAnimationState();
}

class _CounterAnimationState extends State<CounterAnimation> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Text(
            '$_count',
            key: ValueKey<int>(_count),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => setState(() => _count--),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => setState(() => _count++),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 2. 页面切换

```dart
class PageSwitcher extends StatefulWidget {
  @override
  _PageSwitcherState createState() => _PageSwitcherState();
}

class _PageSwitcherState extends State<PageSwitcher> {
  int _pageIndex = 0;
  
  final List<Widget> _pages = [
    Container(key: ValueKey(0), color: Colors.red, child: Center(child: Text('页面 1'))),
    Container(key: ValueKey(1), color: Colors.green, child: Center(child: Text('页面 2'))),
    Container(key: ValueKey(2), color: Colors.blue, child: Center(child: Text('页面 3'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _pages[_pageIndex],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return TextButton(
              onPressed: () => setState(() => _pageIndex = index),
              child: Text('页面 ${index + 1}'),
            );
          }),
        ),
      ],
    );
  }
}
```

### 3. 图片切换

```dart
class ImageSwitcher extends StatefulWidget {
  @override
  _ImageSwitcherState createState() => _ImageSwitcherState();
}

class _ImageSwitcherState extends State<ImageSwitcher> {
  int _imageIndex = 0;
  final List<String> _images = [
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _imageIndex = (_imageIndex + 1) % _images.length;
        });
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        switchInCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Image.asset(
          _images[_imageIndex],
          key: ValueKey<int>(_imageIndex),
          fit: BoxFit.cover,
          width: 300,
          height: 200,
        ),
      ),
    );
  }
}
```

### 4. 自定义转场动画

```dart
class CustomTransitionSwitcher extends StatefulWidget {
  @override
  _CustomTransitionSwitcherState createState() => _CustomTransitionSwitcherState();
}

class _CustomTransitionSwitcherState extends State<CustomTransitionSwitcher> {
  bool _showFirst = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showFirst = !_showFirst),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 600),
        transitionBuilder: (child, animation) {
          // 组合多种动画效果
          return RotationTransition(
            turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Container(
          key: ValueKey<bool>(_showFirst),
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: _showFirst ? Colors.blue : Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              _showFirst ? Icons.star : Icons.favorite,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class AnimatedSwitcherDemo extends StatefulWidget {
  @override
  _AnimatedSwitcherDemoState createState() => _AnimatedSwitcherDemoState();
}

class _AnimatedSwitcherDemoState extends State<AnimatedSwitcherDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedSwitcher 示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 带动画的计数器
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                // 使用上下滑动 + 淡入淡出效果
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(0.0, _count > 0 ? 1.0 : -1.0),
                  end: Offset.zero,
                ).animate(animation);
                
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Text(
                '$_count',
                // ⚠️ key 是触发动画的关键
                key: ValueKey<int>(_count),
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'decrement',
                  onPressed: () => setState(() => _count--),
                  child: Icon(Icons.remove),
                ),
                SizedBox(width: 40),
                FloatingActionButton(
                  heroTag: 'increment',
                  onPressed: () => setState(() => _count++),
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

### 1. Key 的重要性

AnimatedSwitcher 通过比较 child 的 key 来判断是否需要执行动画。**如果 key 不变，即使 child 内容变化也不会触发动画**。

```dart
// ❌ 错误：没有设置 key，不会触发动画
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: Text('$_count'), // key 始终为 null
)

// ✅ 正确：使用 ValueKey 标识内容变化
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: Text(
    '$_count',
    key: ValueKey<int>(_count), // key 变化时触发动画
  ),
)

// ✅ 也可以使用其他类型的 Key
child: Icon(
  _isPlaying ? Icons.pause : Icons.play_arrow,
  key: ValueKey<bool>(_isPlaying),
)
```

### 2. 自定义 transitionBuilder

默认的 transitionBuilder 是 FadeTransition，可以自定义实现各种效果：

```dart
// 缩放动画
transitionBuilder: (child, animation) {
  return ScaleTransition(scale: animation, child: child);
}

// 旋转动画
transitionBuilder: (child, animation) {
  return RotationTransition(turns: animation, child: child);
}

// 滑动动画
transitionBuilder: (child, animation) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1.0, 0.0), // 从右侧滑入
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

// 组合多种动画
transitionBuilder: (child, animation) {
  return FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: animation,
      child: child,
    ),
  );
}
```

### 3. 自定义 layoutBuilder

layoutBuilder 控制新旧组件如何叠放：

```dart
// 默认布局：新组件覆盖旧组件
layoutBuilder: (currentChild, previousChildren) {
  return Stack(
    children: [
      ...previousChildren,
      if (currentChild != null) currentChild,
    ],
  );
}

// 居中对齐
layoutBuilder: (currentChild, previousChildren) {
  return Stack(
    alignment: Alignment.center,
    children: [
      ...previousChildren,
      if (currentChild != null) currentChild,
    ],
  );
}
```

### 4. 性能优化

```dart
// 使用 const 构造器提高性能
child: const Icon(
  Icons.star,
  key: ValueKey('star'),
)

// 避免在 transitionBuilder 中创建复杂对象
// ✅ 提取到外部
final _offsetTween = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero);

transitionBuilder: (child, animation) {
  return SlideTransition(
    position: _offsetTween.animate(animation),
    child: child,
  );
}
```

## 相关组件

- [AnimatedCrossFade](animatedcrossfade.md) - 两个子组件之间的交叉淡入淡出动画
- [PageView](../scrolling/pageview.md) - 可滑动的页面视图
- [FadeTransition](fadetransition.md) - 淡入淡出过渡动画
- [ScaleTransition](scaletransition.md) - 缩放过渡动画
- [SlideTransition](slidetransition.md) - 滑动过渡动画

## 官方文档

- [AnimatedSwitcher API](https://api.flutter.dev/flutter/widgets/AnimatedSwitcher-class.html)
