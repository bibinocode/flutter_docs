# AnimatedContainer

`AnimatedContainer` 是 Flutter 中最简单易用的隐式动画组件。当其属性发生变化时，会自动在新旧值之间创建平滑的过渡动画，无需手动管理 AnimationController。

## 基本用法

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  width: _isExpanded ? 200 : 100,
  height: _isExpanded ? 200 : 100,
  color: _isExpanded ? Colors.blue : Colors.red,
  child: Center(child: Text('点击我')),
)
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `duration` | `Duration` | 动画时长（必需） |
| `curve` | `Curve` | 动画曲线，默认 `Curves.linear` |
| `onEnd` | `VoidCallback?` | 动画结束回调 |
| `alignment` | `AlignmentGeometry?` | 子组件对齐方式 |
| `padding` | `EdgeInsetsGeometry?` | 内边距 |
| `color` | `Color?` | 背景色（不能与 decoration 同时使用） |
| `decoration` | `Decoration?` | 装饰（边框、圆角、阴影等） |
| `foregroundDecoration` | `Decoration?` | 前景装饰（绘制在 child 之上） |
| `width` | `double?` | 宽度 |
| `height` | `double?` | 高度 |
| `constraints` | `BoxConstraints?` | 尺寸约束 |
| `margin` | `EdgeInsetsGeometry?` | 外边距 |
| `transform` | `Matrix4?` | 变换矩阵（旋转、缩放、平移） |
| `transformAlignment` | `AlignmentGeometry?` | 变换原点对齐 |
| `clipBehavior` | `Clip` | 裁剪行为，默认 `Clip.none` |
| `child` | `Widget?` | 子组件（不参与动画） |

## 常用 Curve 曲线

| 曲线 | 效果 |
|------|------|
| `Curves.linear` | 线性（匀速） |
| `Curves.easeIn` | 先慢后快 |
| `Curves.easeOut` | 先快后慢 |
| `Curves.easeInOut` | 两头慢中间快 |
| `Curves.bounceIn` | 弹入效果 |
| `Curves.bounceOut` | 弹出效果 |
| `Curves.elasticIn` | 弹性进入 |
| `Curves.elasticOut` | 弹性退出 |
| `Curves.fastOutSlowIn` | Material 标准曲线 |

## 使用场景

### 1. 尺寸动画

```dart
class SizeAnimation extends StatefulWidget {
  @override
  _SizeAnimationState createState() => _SizeAnimationState();
}

class _SizeAnimationState extends State<SizeAnimation> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _isExpanded ? 200 : 100,
        height: _isExpanded ? 200 : 100,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(_isExpanded ? 24 : 8),
        ),
        child: Center(
          child: Text(
            _isExpanded ? '收起' : '展开',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
```

### 2. 颜色动画

```dart
class ColorAnimation extends StatefulWidget {
  @override
  _ColorAnimationState createState() => _ColorAnimationState();
}

class _ColorAnimationState extends State<ColorAnimation> {
  int _colorIndex = 0;
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _colorIndex = (_colorIndex + 1) % _colors.length;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: _colors[_colorIndex],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _colors[_colorIndex].withOpacity(0.5),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '点击变色',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
```

### 3. 位置动画（对齐）

```dart
class AlignmentAnimation extends StatefulWidget {
  @override
  _AlignmentAnimationState createState() => _AlignmentAnimationState();
}

class _AlignmentAnimationState extends State<AlignmentAnimation> {
  Alignment _alignment = Alignment.topLeft;

  void _changeAlignment() {
    setState(() {
      if (_alignment == Alignment.topLeft) {
        _alignment = Alignment.topRight;
      } else if (_alignment == Alignment.topRight) {
        _alignment = Alignment.bottomRight;
      } else if (_alignment == Alignment.bottomRight) {
        _alignment = Alignment.bottomLeft;
      } else {
        _alignment = Alignment.topLeft;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeAlignment,
      child: Container(
        width: 300,
        height: 300,
        color: Colors.grey[200],
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          alignment: _alignment,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 4. 渐变动画

```dart
class GradientAnimation extends StatefulWidget {
  @override
  _GradientAnimationState createState() => _GradientAnimationState();
}

class _GradientAnimationState extends State<GradientAnimation> {
  bool _isFirst = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isFirst = !_isFirst),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isFirst
                ? [Colors.blue, Colors.purple]
                : [Colors.orange, Colors.red],
          ),
        ),
        width: 200,
        height: 200,
        child: Center(
          child: Text(
            '渐变动画',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
```

### 5. 边框动画

```dart
class BorderAnimation extends StatefulWidget {
  @override
  _BorderAnimationState createState() => _BorderAnimationState();
}

class _BorderAnimationState extends State<BorderAnimation> {
  bool _hasBorder = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _hasBorder = !_hasBorder),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_hasBorder ? 20 : 8),
          border: Border.all(
            color: _hasBorder ? Colors.blue : Colors.grey,
            width: _hasBorder ? 4 : 1,
          ),
          boxShadow: _hasBorder
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Center(child: Text('选中效果')),
      ),
    );
  }
}
```

### 6. 旋转和缩放动画

```dart
class TransformAnimation extends StatefulWidget {
  @override
  _TransformAnimationState createState() => _TransformAnimationState();
}

class _TransformAnimationState extends State<TransformAnimation> {
  bool _isTransformed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isTransformed = !_isTransformed),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: 150,
        height: 150,
        transform: Matrix4.identity()
          ..rotateZ(_isTransformed ? 0.5 : 0) // 旋转
          ..scale(_isTransformed ? 1.2 : 1.0), // 缩放
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.refresh,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}
```

### 7. 卡片展开动画

```dart
class ExpandableCard extends StatefulWidget {
  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        width: double.infinity,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isExpanded ? 0.15 : 0.08),
              blurRadius: _isExpanded ? 20 : 10,
              offset: Offset(0, _isExpanded ? 10 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '卡片标题',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            AnimatedCrossFade(
              firstChild: SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  '这是展开后的详细内容。AnimatedContainer 配合 AnimatedCrossFade 可以实现丰富的卡片展开效果。',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 8. 动画结束回调

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  width: _isExpanded ? 200 : 100,
  onEnd: () {
    // 动画结束后执行
    print('动画完成');
    if (_isExpanded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('展开完成')),
      );
    }
  },
  child: Container(),
)
```

## 隐式动画组件对比

| 组件 | 动画属性 |
|------|----------|
| `AnimatedContainer` | 尺寸、颜色、装饰、边距等 |
| `AnimatedOpacity` | 透明度 |
| `AnimatedPositioned` | Stack 中的位置 |
| `AnimatedAlign` | 对齐方式 |
| `AnimatedPadding` | 内边距 |
| `AnimatedDefaultTextStyle` | 文本样式 |
| `AnimatedCrossFade` | 两个子组件切换 |
| `AnimatedSwitcher` | 子组件切换 |

## AnimatedContainer vs TweenAnimationBuilder

| 特性 | AnimatedContainer | TweenAnimationBuilder |
|------|-------------------|----------------------|
| 使用难度 | 简单 | 中等 |
| 属性支持 | 固定属性 | 任意值 |
| 控制粒度 | 低 | 高 |
| 适用场景 | 常见属性动画 | 自定义动画值 |

## 最佳实践

### 隐式动画 vs 显式动画

| 特性 | 隐式动画 (AnimatedContainer) | 显式动画 (AnimationController) |
|------|------------------------------|--------------------------------|
| 控制方式 | 自动管理 | 手动控制 |
| 使用难度 | 简单 | 复杂 |
| 代码量 | 少 | 多 |
| 灵活性 | 有限 | 完全控制 |
| 适用场景 | 状态切换、简单过渡 | 循环动画、手势驱动、复杂编排 |
| 性能开销 | 较低 | 可优化 |

**何时选择隐式动画：**
- 只需简单的状态切换动画
- 动画由某个属性值变化触发
- 不需要中途暂停、反向或重复播放

**何时选择显式动画：**
- 需要循环播放或重复动画
- 需要精确控制动画进度
- 需要多个动画协同工作
- 需要手势驱动动画

### 实用建议

1. **选择合适的 duration**: 200-400ms 通常体验最佳
2. **使用正确的 curve**: Material 推荐 `Curves.fastOutSlowIn`
3. **避免过度动画**: 不要同时动画太多属性
4. **使用 onEnd**: 需要链式动画时使用回调
5. **注意 decoration 限制**: color 和 decoration 不能同时使用
6. **考虑可访问性**: 尊重用户的「减少动画」偏好设置

```dart
// 检查减少动画偏好
MediaQuery.of(context).disableAnimations
```

## 常见问题

::: warning color 和 decoration 冲突
与 Container 一样，AnimatedContainer 的 `color` 和 `decoration` 不能同时使用。需要背景色时，请在 BoxDecoration 中设置。
:::

::: tip 子组件动画
AnimatedContainer 不会为 child 创建动画。如需子组件动画，可以：
1. 使用 AnimatedSwitcher
2. 在 child 内部使用其他动画组件
3. 使用显式动画 (AnimationController)
:::

## 相关组件

- [Container](../basics/container) - 基础容器组件
- [AnimatedOpacity](./animatedopacity) - 透明度动画
- [AnimatedPositioned](./animatedpositioned) - 位置动画
- [AnimatedCrossFade](./animatedcrossfade) - 交叉淡入淡出
- [AnimatedSwitcher](./animatedswitcher) - 子组件切换
- [TweenAnimationBuilder](./tweenanimationbuilder) - 自定义补间动画

## 官方文档

- [AnimatedContainer API](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html)
- [隐式动画指南](https://docs.flutter.cn/ui/animations/implicit-animations)
