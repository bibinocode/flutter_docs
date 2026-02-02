# GestureDetector

`GestureDetector` 是 Flutter 中功能最强大的手势检测组件，用于监听各种触摸事件和手势操作。它可以检测点击、双击、长按、拖拽、缩放等多种手势，是构建交互式 UI 的核心组件。

## 基本用法

```dart
GestureDetector(
  onTap: () {
    print('点击了');
  },
  child: Container(
    width: 200,
    height: 100,
    color: Colors.blue,
    child: Center(
      child: Text('点击我', style: TextStyle(color: Colors.white)),
    ),
  ),
)
```

## 常用属性

### 点击手势

| 属性 | 类型 | 说明 |
|------|------|------|
| `onTap` | `GestureTapCallback?` | 点击事件回调 |
| `onTapDown` | `GestureTapDownCallback?` | 手指按下时回调 |
| `onTapUp` | `GestureTapUpCallback?` | 手指抬起时回调 |
| `onTapCancel` | `GestureTapCancelCallback?` | 点击取消时回调 |
| `onDoubleTap` | `GestureTapCallback?` | 双击事件回调 |
| `onDoubleTapDown` | `GestureTapDownCallback?` | 双击按下时回调 |
| `onDoubleTapCancel` | `GestureTapCancelCallback?` | 双击取消时回调 |

### 长按手势

| 属性 | 类型 | 说明 |
|------|------|------|
| `onLongPress` | `GestureLongPressCallback?` | 长按事件回调 |
| `onLongPressStart` | `GestureLongPressStartCallback?` | 长按开始回调，提供位置信息 |
| `onLongPressMoveUpdate` | `GestureLongPressMoveUpdateCallback?` | 长按移动时回调 |
| `onLongPressUp` | `GestureLongPressUpCallback?` | 长按结束回调 |
| `onLongPressEnd` | `GestureLongPressEndCallback?` | 长按结束回调，提供速度信息 |

### 拖拽手势 (Pan)

| 属性 | 类型 | 说明 |
|------|------|------|
| `onPanDown` | `GestureDragDownCallback?` | 拖拽按下回调 |
| `onPanStart` | `GestureDragStartCallback?` | 拖拽开始回调 |
| `onPanUpdate` | `GestureDragUpdateCallback?` | 拖拽更新回调，提供偏移量 |
| `onPanEnd` | `GestureDragEndCallback?` | 拖拽结束回调，提供速度 |
| `onPanCancel` | `GestureDragCancelCallback?` | 拖拽取消回调 |

### 水平/垂直拖拽

| 属性 | 类型 | 说明 |
|------|------|------|
| `onHorizontalDragStart` | `GestureDragStartCallback?` | 水平拖拽开始 |
| `onHorizontalDragUpdate` | `GestureDragUpdateCallback?` | 水平拖拽更新 |
| `onHorizontalDragEnd` | `GestureDragEndCallback?` | 水平拖拽结束 |
| `onVerticalDragStart` | `GestureDragStartCallback?` | 垂直拖拽开始 |
| `onVerticalDragUpdate` | `GestureDragUpdateCallback?` | 垂直拖拽更新 |
| `onVerticalDragEnd` | `GestureDragEndCallback?` | 垂直拖拽结束 |

### 缩放手势 (Scale)

| 属性 | 类型 | 说明 |
|------|------|------|
| `onScaleStart` | `GestureScaleStartCallback?` | 缩放开始回调 |
| `onScaleUpdate` | `GestureScaleUpdateCallback?` | 缩放更新回调，提供缩放比例 |
| `onScaleEnd` | `GestureScaleEndCallback?` | 缩放结束回调 |

### 其他属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget?` | 子组件 |
| `behavior` | `HitTestBehavior?` | 命中测试行为 |
| `excludeFromSemantics` | `bool` | 是否从语义树中排除 |
| `dragStartBehavior` | `DragStartBehavior` | 拖拽开始行为 |

### HitTestBehavior 枚举

| 值 | 说明 |
|------|------|
| `deferToChild` | 默认值，只有子组件区域响应点击 |
| `opaque` | 不透明区域响应点击，阻止事件传递 |
| `translucent` | 透明区域也响应点击，事件可穿透 |

## 使用场景

### 1. 点击事件

```dart
class TapExample extends StatefulWidget {
  @override
  State<TapExample> createState() => _TapExampleState();
}

class _TapExampleState extends State<TapExample> {
  String _message = '等待点击';
  Color _color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        setState(() {
          _color = Colors.blue.shade700;
          _message = '按下位置: ${details.localPosition}';
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          _color = Colors.blue;
          _message = '抬起位置: ${details.localPosition}';
        });
      },
      onTap: () {
        setState(() {
          _message = '点击完成！';
        });
      },
      onTapCancel: () {
        setState(() {
          _color = Colors.blue;
          _message = '点击取消';
        });
      },
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            _message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
```

### 2. 双击事件

```dart
class DoubleTapExample extends StatefulWidget {
  @override
  State<DoubleTapExample> createState() => _DoubleTapExampleState();
}

class _DoubleTapExampleState extends State<DoubleTapExample> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/300'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _isFavorite ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 100,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. 长按事件

```dart
class LongPressExample extends StatefulWidget {
  @override
  State<LongPressExample> createState() => _LongPressExampleState();
}

class _LongPressExampleState extends State<LongPressExample> {
  bool _isLongPressed = false;
  Offset _position = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        setState(() {
          _isLongPressed = true;
          _position = details.localPosition;
        });
        // 显示上下文菜单
        _showContextMenu(context, details.globalPosition);
      },
      onLongPressEnd: (LongPressEndDetails details) {
        setState(() {
          _isLongPressed = false;
        });
      },
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          color: _isLongPressed ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '长按我',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(value: 'copy', child: Text('复制')),
        PopupMenuItem(value: 'share', child: Text('分享')),
        PopupMenuItem(value: 'delete', child: Text('删除')),
      ],
    );
  }
}
```

### 4. 拖拽手势

```dart
class DragExample extends StatefulWidget {
  @override
  State<DragExample> createState() => _DragExampleState();
}

class _DragExampleState extends State<DragExample> {
  double _left = 100;
  double _top = 100;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _left,
          top: _top,
          child: GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                _left += details.delta.dx;
                _top += details.delta.dy;
              });
            },
            onPanEnd: (DragEndDetails details) {
              // 获取拖拽结束时的速度
              print('速度: ${details.velocity}');
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.touch_app,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 5. 缩放手势

```dart
class ScaleExample extends StatefulWidget {
  @override
  State<ScaleExample> createState() => _ScaleExampleState();
}

class _ScaleExampleState extends State<ScaleExample> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  double _rotation = 0.0;
  double _previousRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
          _previousRotation = _rotation;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = (_previousScale * details.scale).clamp(0.5, 4.0);
            _rotation = _previousRotation + details.rotation;
          });
        },
        onScaleEnd: (ScaleEndDetails details) {
          print('缩放结束，当前比例: $_scale');
        },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(_scale)
            ..rotateZ(_rotation),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 6. 组合手势

```dart
class CombinedGestureExample extends StatefulWidget {
  @override
  State<CombinedGestureExample> createState() => _CombinedGestureExampleState();
}

class _CombinedGestureExampleState extends State<CombinedGestureExample> {
  String _gestureInfo = '等待手势...';
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_gestureInfo, style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            setState(() {
              _tapCount++;
              _gestureInfo = '单击 (第 $_tapCount 次)';
            });
          },
          onDoubleTap: () {
            setState(() {
              _gestureInfo = '双击';
            });
          },
          onLongPress: () {
            setState(() {
              _gestureInfo = '长按';
              _tapCount = 0; // 重置计数
            });
          },
          child: Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '尝试各种手势',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 手势冲突解决

### 问题场景

当多个手势检测器嵌套时，可能会发生手势冲突。Flutter 使用手势竞技场（Gesture Arena）机制来解决冲突。

### 使用 RawGestureDetector 自定义手势识别

```dart
class CustomGestureExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        AllowMultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer>(
          () => AllowMultipleGestureRecognizer(),
          (AllowMultipleGestureRecognizer instance) {
            instance.onTap = () => print('外层点击');
          },
        ),
      },
      child: Container(
        color: Colors.blue,
        child: Center(
          child: GestureDetector(
            onTap: () => print('内层点击'),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

// 自定义手势识别器，允许多个手势同时响应
class AllowMultipleGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
```

### 使用 behavior 控制点击区域

```dart
// 子组件不响应时，父组件响应
GestureDetector(
  behavior: HitTestBehavior.translucent,
  onTap: () => print('父组件点击'),
  child: Container(
    width: 200,
    height: 200,
    child: Center(
      child: GestureDetector(
        onTap: () => print('子组件点击'),
        child: Container(
          width: 100,
          height: 100,
          color: Colors.red,
        ),
      ),
    ),
  ),
)
```

### 使用 AbsorbPointer 和 IgnorePointer

```dart
// AbsorbPointer: 拦截事件，子组件不响应
AbsorbPointer(
  absorbing: true,
  child: GestureDetector(
    onTap: () => print('不会触发'),
    child: ElevatedButton(
      onPressed: () {},
      child: Text('被拦截'),
    ),
  ),
)

// IgnorePointer: 忽略事件，事件穿透到下层
IgnorePointer(
  ignoring: true,
  child: GestureDetector(
    onTap: () => print('不会触发'),
    child: Container(color: Colors.blue),
  ),
)
```

## GestureDetector 与 InkWell 对比

| 特性 | GestureDetector | InkWell |
|------|----------------|---------|
| 水波纹效果 | ❌ 无 | ✅ 有 Material 水波纹 |
| 手势类型 | 丰富（点击、拖拽、缩放等） | 有限（点击、双击、长按） |
| 适用场景 | 自定义手势、复杂交互 | Material Design 按钮效果 |
| 性能 | 轻量 | 需要 Material 祖先组件 |
| 形状裁剪 | 需手动处理 | 支持 borderRadius |
| 语义化 | 需手动添加 | 自动添加按钮语义 |

### 代码对比

```dart
// GestureDetector - 无视觉反馈
GestureDetector(
  onTap: () => print('点击'),
  child: Container(
    padding: EdgeInsets.all(16),
    color: Colors.blue,
    child: Text('GestureDetector'),
  ),
)

// InkWell - 有水波纹效果
Material(
  child: InkWell(
    onTap: () => print('点击'),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.all(16),
      child: Text('InkWell'),
    ),
  ),
)

// GestureDetector 添加自定义视觉反馈
class CustomFeedbackButton extends StatefulWidget {
  @override
  State<CustomFeedbackButton> createState() => _CustomFeedbackButtonState();
}

class _CustomFeedbackButtonState extends State<CustomFeedbackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => print('点击'),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.blue.shade700 : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isPressed
              ? []
              : [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Text(
          '自定义反馈',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
```

## 最佳实践

### 1. 合理设置 behavior

```dart
// ✅ 好：空白区域也需要响应时使用 opaque
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () => print('点击'),
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Text('有大片空白'),
  ),
)

// ❌ 差：默认 deferToChild 可能导致空白区域不响应
GestureDetector(
  onTap: () => print('点击'),
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Text('空白区域不响应'),
  ),
)
```

### 2. 避免手势冲突

```dart
// ✅ 好：明确使用水平或垂直拖拽
GestureDetector(
  onHorizontalDragUpdate: (details) {
    // 只处理水平拖拽
  },
  child: ListView(
    // ListView 的垂直滚动不受影响
    children: [...],
  ),
)

// ❌ 差：onPanUpdate 会与 ListView 滚动冲突
GestureDetector(
  onPanUpdate: (details) {
    // 可能导致滚动失效
  },
  child: ListView(...),
)
```

### 3. 提供视觉反馈

```dart
// ✅ 好：给用户明确的交互反馈
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 100),
    transform: Matrix4.identity()
      ..scale(_isPressed ? 0.95 : 1.0),
    child: MyWidget(),
  ),
)
```

### 4. 注意无障碍访问

```dart
// ✅ 好：添加语义信息
Semantics(
  button: true,
  label: '提交表单',
  child: GestureDetector(
    onTap: _submitForm,
    child: Container(...),
  ),
)

// 或使用 excludeFromSemantics 并自定义语义
GestureDetector(
  excludeFromSemantics: true,
  onTap: _submitForm,
  child: Semantics(
    button: true,
    label: '提交表单',
    child: Container(...),
  ),
)
```

### 5. 使用 const 优化性能

```dart
// ✅ 好：child 使用 const
GestureDetector(
  onTap: _handleTap,
  child: const Icon(Icons.add, size: 48),
)
```

### 6. 合理使用双击检测

```dart
// 注意：同时使用 onTap 和 onDoubleTap 时
// onTap 会有约 200ms 延迟等待双击判定
GestureDetector(
  onTap: () => print('单击'), // 会延迟触发
  onDoubleTap: () => print('双击'),
  child: Container(...),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class GestureDetectorDemo extends StatefulWidget {
  @override
  State<GestureDetectorDemo> createState() => _GestureDetectorDemoState();
}

class _GestureDetectorDemoState extends State<GestureDetectorDemo> {
  String _lastGesture = '等待手势...';
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _offset = Offset.zero;
  
  double _baseScale = 1.0;
  double _baseRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GestureDetector 示例'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              _lastGesture,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => _lastGesture = '单击');
                },
                onDoubleTap: () {
                  setState(() {
                    _lastGesture = '双击 - 重置';
                    _scale = 1.0;
                    _rotation = 0.0;
                    _offset = Offset.zero;
                  });
                },
                onLongPress: () {
                  setState(() => _lastGesture = '长按');
                },
                onScaleStart: (details) {
                  _baseScale = _scale;
                  _baseRotation = _rotation;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _scale = (_baseScale * details.scale).clamp(0.5, 3.0);
                    _rotation = _baseRotation + details.rotation;
                    _offset += details.focalPointDelta;
                    _lastGesture = '缩放: ${_scale.toStringAsFixed(2)}x';
                  });
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale)
                    ..rotateZ(_rotation),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '试试各种手势',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '双击重置',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 相关组件

- [InkWell](../material/inkwell.md) - 带水波纹效果的点击组件
- [InkResponse](../material/inkresponse.md) - 可自定义形状的水波纹组件
- [Listener](./listener.md) - 低级别指针事件监听器
- [Draggable](./draggable.md) - 可拖拽组件
- [Dismissible](../gesture/dismissible.md) - 滑动删除组件
- [InteractiveViewer](../gesture/interactiveviewer.md) - 可缩放平移的查看器

## 官方文档

- [GestureDetector API](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)
- [手势系统](https://docs.flutter.dev/development/ui/advanced/gestures)
- [处理手势](https://docs.flutter.dev/cookbook/gestures/handling-taps)
