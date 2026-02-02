# AnimatedPositioned

`AnimatedPositioned` 是 Flutter 中用于隐式位置动画的组件。它必须作为 `Stack` 的子组件使用，当位置属性（left、top、right、bottom）发生变化时，会自动在新旧位置之间创建平滑的过渡动画，无需手动管理 AnimationController。

## 基本用法

```dart
Stack(
  children: [
    AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      left: _isLeft ? 0 : 200,
      top: _isTop ? 0 : 200,
      child: Container(
        width: 50,
        height: 50,
        color: Colors.blue,
      ),
    ),
  ],
)
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `left` | `double?` | 距离 Stack 左边缘的距离 |
| `top` | `double?` | 距离 Stack 顶部边缘的距离 |
| `right` | `double?` | 距离 Stack 右边缘的距离 |
| `bottom` | `double?` | 距离 Stack 底部边缘的距离 |
| `width` | `double?` | 子组件宽度 |
| `height` | `double?` | 子组件高度 |
| `duration` | `Duration` | 动画时长（必需） |
| `curve` | `Curve` | 动画曲线，默认 `Curves.linear` |
| `onEnd` | `VoidCallback?` | 动画结束回调 |
| `child` | `Widget` | 子组件（必需） |

::: tip 定位规则
- 水平方向：`left`、`right`、`width` 三者最多指定两个
- 垂直方向：`top`、`bottom`、`height` 三者最多指定两个
- 如果三个都指定会导致布局冲突
:::

## 使用场景

### 1. 卡片移动

```dart
class CardMoveDemo extends StatefulWidget {
  @override
  State<CardMoveDemo> createState() => _CardMoveDemoState();
}

class _CardMoveDemoState extends State<CardMoveDemo> {
  bool _moved = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          left: _moved ? 200 : 20,
          top: _moved ? 300 : 50,
          child: GestureDetector(
            onTap: () => setState(() => _moved = !_moved),
            child: Card(
              elevation: 8,
              child: Container(
                width: 150,
                height: 100,
                alignment: Alignment.center,
                child: Text('点击移动'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 2. 侧滑菜单

```dart
class SlideMenuDemo extends StatefulWidget {
  @override
  State<SlideMenuDemo> createState() => _SlideMenuDemoState();
}

class _SlideMenuDemoState extends State<SlideMenuDemo> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主内容
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (_isOpen) setState(() => _isOpen = false);
            },
            child: Container(color: Colors.grey[200]),
          ),
        ),
        // 侧滑菜单
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: _isOpen ? 0 : -250,
          top: 0,
          bottom: 0,
          width: 250,
          child: Material(
            elevation: 16,
            child: Container(
              color: Colors.white,
              child: ListView(
                children: [
                  DrawerHeader(child: Text('菜单')),
                  ListTile(title: Text('选项 1')),
                  ListTile(title: Text('选项 2')),
                  ListTile(title: Text('选项 3')),
                ],
              ),
            ),
          ),
        ),
        // 菜单按钮
        Positioned(
          left: 16,
          top: 16,
          child: IconButton(
            icon: Icon(_isOpen ? Icons.close : Icons.menu),
            onPressed: () => setState(() => _isOpen = !_isOpen),
          ),
        ),
      ],
    );
  }
}
```

### 3. 拖拽定位动画

```dart
class DragPositionDemo extends StatefulWidget {
  @override
  State<DragPositionDemo> createState() => _DragPositionDemoState();
}

class _DragPositionDemoState extends State<DragPositionDemo> {
  double _left = 100;
  double _top = 100;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: _isDragging ? 0 : 300),
          curve: Curves.elasticOut,
          left: _left,
          top: _top,
          child: GestureDetector(
            onPanStart: (_) => setState(() => _isDragging = true),
            onPanUpdate: (details) {
              setState(() {
                _left += details.delta.dx;
                _top += details.delta.dy;
              });
            },
            onPanEnd: (_) {
              setState(() {
                _isDragging = false;
                // 吸附到网格
                _left = (_left / 50).round() * 50.0;
                _top = (_top / 50).round() * 50.0;
              });
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: _isDragging ? 20 : 8,
                    offset: Offset(0, _isDragging ? 12 : 4),
                  ),
                ],
              ),
              child: Icon(Icons.drag_indicator, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 4. 游戏角色移动

```dart
class GameCharacterDemo extends StatefulWidget {
  @override
  State<GameCharacterDemo> createState() => _GameCharacterDemoState();
}

class _GameCharacterDemoState extends State<GameCharacterDemo> {
  double _x = 150;
  double _y = 150;
  final double _step = 50;
  final double _size = 40;

  void _move(double dx, double dy) {
    setState(() {
      _x = (_x + dx).clamp(0, 300 - _size);
      _y = (_y + dy).clamp(0, 300 - _size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 游戏区域
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.green[100],
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: _x,
                top: _y,
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        // 方向控制
        Column(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: () => _move(0, -_step),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _move(-_step, 0),
                ),
                SizedBox(width: 40),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => _move(_step, 0),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: () => _move(0, _step),
            ),
          ],
        ),
      ],
    );
  }
}
```

## 完整示例：点击移动方块

```dart
import 'package:flutter/material.dart';

class AnimatedPositionedDemo extends StatefulWidget {
  const AnimatedPositionedDemo({super.key});

  @override
  State<AnimatedPositionedDemo> createState() => _AnimatedPositionedDemoState();
}

class _AnimatedPositionedDemoState extends State<AnimatedPositionedDemo> {
  // 方块位置索引 (0-3 对应四个角)
  int _positionIndex = 0;

  // 四个角的位置
  final List<Map<String, double>> _positions = [
    {'left': 20, 'top': 20},      // 左上
    {'left': 220, 'top': 20},     // 右上
    {'left': 220, 'top': 220},    // 右下
    {'left': 20, 'top': 220},     // 左下
  ];

  void _moveToNext() {
    setState(() {
      _positionIndex = (_positionIndex + 1) % 4;
    });
  }

  void _moveToPosition(int index) {
    setState(() {
      _positionIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = _positions[_positionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('AnimatedPositioned 示例'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // 四个角的目标指示器
                  for (int i = 0; i < 4; i++)
                    Positioned(
                      left: _positions[i]['left'],
                      top: _positions[i]['top'],
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: i == _positionIndex
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  // 动画方块
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    left: position['left'],
                    top: position['top'],
                    onEnd: () {
                      debugPrint('动画完成，当前位置: $_positionIndex');
                    },
                    child: GestureDetector(
                      onTap: _moveToNext,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 位置控制按钮
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPositionButton(0, '左上'),
                _buildPositionButton(1, '右上'),
                _buildPositionButton(2, '右下'),
                _buildPositionButton(3, '左下'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionButton(int index, String label) {
    final isActive = _positionIndex == index;
    return ElevatedButton(
      onPressed: () => _moveToPosition(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black87,
      ),
      child: Text(label),
    );
  }
}
```

## 最佳实践

1. **必须在 Stack 中使用**：`AnimatedPositioned` 只能作为 `Stack` 的子组件，否则会抛出异常

2. **避免位置冲突**：水平方向 `left`/`right`/`width` 最多指定两个，垂直方向同理

3. **合理设置动画时长**：
   - 短距离移动：200-300ms
   - 长距离移动：400-600ms
   - 复杂动画：根据实际效果调整

4. **选择合适的曲线**：
   - 普通移动：`Curves.easeInOut`
   - 弹性效果：`Curves.elasticOut`
   - 快速响应：`Curves.easeOutCubic`

5. **拖拽场景优化**：拖拽时将 `duration` 设为 0，释放后恢复动画时长

6. **使用 onEnd 回调**：在动画结束后执行后续逻辑，如连续动画

7. **性能考虑**：避免在 Stack 中放置过多 AnimatedPositioned，考虑使用 `AnimatedBuilder` 做更复杂的动画

## 与 Positioned 的区别

| 特性 | Positioned | AnimatedPositioned |
|------|------------|-------------------|
| 位置变化 | 立即生效 | 平滑过渡动画 |
| 动画控制 | 无 | 支持 duration、curve |
| 使用场景 | 静态定位 | 需要位置动画 |
| 性能 | 更轻量 | 有动画开销 |

## 相关组件

- [Positioned](https://api.flutter.dev/flutter/widgets/Positioned-class.html) - 基础定位组件，无动画效果
- [SlideTransition](./slidetransition.md) - 显式滑动动画，需要 AnimationController
- [AnimatedAlign](https://api.flutter.dev/flutter/widgets/AnimatedAlign-class.html) - 基于对齐方式的隐式动画

## 官方文档

- [AnimatedPositioned API](https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html)
