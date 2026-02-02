# Flow

`Flow` 是 Flutter 中用于高性能自定义流式布局的组件。它通过 `FlowDelegate` 提供完全自定义的子组件定位能力，特别适合需要精确控制位置和动画的场景，如环形菜单、动画菜单等。

## 基本用法

```dart
Flow(
  delegate: MyFlowDelegate(),
  children: [
    Container(width: 50, height: 50, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
    Container(width: 50, height: 50, color: Colors.blue),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| delegate | FlowDelegate | 必需 | 控制子组件布局的委托 |
| clipBehavior | Clip | Clip.hardEdge | 子组件超出边界时的裁剪行为 |
| children | List\<Widget\> | const [] | 子组件列表 |

## FlowDelegate

`FlowDelegate` 是 Flow 的核心，需要继承并实现以下方法：

| 方法 | 说明 |
|------|------|
| `getConstraintsForChild(i, constraints)` | 返回第 i 个子组件的约束 |
| `paintChildren(context)` | 绘制所有子组件，控制位置和变换 |
| `shouldRepaint(oldDelegate)` | 是否需要重绘 |
| `getSize(constraints)` | 返回 Flow 组件的大小 |

### FlowDelegate 基本结构

```dart
class MyFlowDelegate extends FlowDelegate {
  MyFlowDelegate({required this.animation}) : super(repaint: animation);
  
  final Animation<double> animation;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    // 返回子组件的约束，通常返回宽松约束
    return constraints.loosen();
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // 返回 Flow 的大小
    return Size(constraints.maxWidth, 200);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // 在这里定位和绘制每个子组件
    for (int i = 0; i < context.childCount; i++) {
      context.paintChild(
        i,
        transform: Matrix4.translationValues(i * 60.0, 0, 0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MyFlowDelegate oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
```

## FlowPaintingContext

在 `paintChildren` 方法中，通过 `FlowPaintingContext` 绘制子组件：

| 属性/方法 | 说明 |
|-----------|------|
| `childCount` | 子组件数量 |
| `getChildSize(i)` | 获取第 i 个子组件的大小 |
| `paintChild(i, transform:)` | 绘制第 i 个子组件，可应用变换矩阵 |
| `size` | Flow 组件的大小 |

## 使用场景

### 1. 环形菜单

```dart
class CircleMenuDelegate extends FlowDelegate {
  CircleMenuDelegate({required this.animation}) : super(repaint: animation);
  
  final Animation<double> animation;
  
  @override
  void paintChildren(FlowPaintingContext context) {
    final n = context.childCount - 1; // 减去中心按钮
    final radius = 100.0 * animation.value;
    
    // 绘制展开的菜单项
    for (int i = 0; i < n; i++) {
      final angle = i * math.pi / (2 * (n - 1)); // 90度范围
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      
      context.paintChild(
        i,
        transform: Matrix4.translationValues(x, -y, 0),
      );
    }
    
    // 最后绘制中心按钮（始终在最上层）
    context.paintChild(n);
  }
  
  @override
  Size getSize(BoxConstraints constraints) => Size(56, 56);
  
  @override
  bool shouldRepaint(CircleMenuDelegate oldDelegate) => true;
}
```

### 2. 动画菜单（扇形展开）

```dart
class FanMenuDelegate extends FlowDelegate {
  FanMenuDelegate({required this.animation}) : super(repaint: animation);
  
  final Animation<double> animation;

  @override
  void paintChildren(FlowPaintingContext context) {
    final n = context.childCount - 1;
    final radius = 120.0 * animation.value;
    
    for (int i = 0; i < n; i++) {
      // 扇形角度分布（从 -60° 到 60°）
      final angle = math.pi / 2 + (i - (n - 1) / 2) * (math.pi / 6);
      final x = context.size.width / 2 + radius * math.cos(angle) - 28;
      final y = context.size.height - radius * math.sin(angle) - 28;
      
      // 添加缩放效果
      final scale = animation.value;
      final transform = Matrix4.identity()
        ..translate(x + 28, y + 28)
        ..scale(scale)
        ..translate(-28.0, -28.0);
      
      context.paintChild(i, transform: transform);
    }
    
    // 中心按钮
    final mainSize = context.getChildSize(n)!;
    context.paintChild(
      n,
      transform: Matrix4.translationValues(
        (context.size.width - mainSize.width) / 2,
        context.size.height - mainSize.height,
        0,
      ),
    );
  }

  @override
  Size getSize(BoxConstraints constraints) => Size(constraints.maxWidth, 200);

  @override
  bool shouldRepaint(FanMenuDelegate oldDelegate) => true;
}
```

### 3. 自定义排列算法（波浪布局）

```dart
class WaveLayoutDelegate extends FlowDelegate {
  WaveLayoutDelegate({this.amplitude = 20, this.frequency = 0.1});
  
  final double amplitude;
  final double frequency;

  @override
  void paintChildren(FlowPaintingContext context) {
    double x = 0;
    
    for (int i = 0; i < context.childCount; i++) {
      final size = context.getChildSize(i)!;
      final y = amplitude * math.sin(frequency * x * math.pi);
      
      context.paintChild(
        i,
        transform: Matrix4.translationValues(x, y + amplitude, 0),
      );
      
      x += size.width + 8;
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, amplitude * 2 + 60);
  }

  @override
  bool shouldRepaint(WaveLayoutDelegate oldDelegate) {
    return amplitude != oldDelegate.amplitude || 
           frequency != oldDelegate.frequency;
  }
}
```

## 完整示例：环形展开菜单

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularMenuDemo extends StatefulWidget {
  @override
  State<CircularMenuDemo> createState() => _CircularMenuDemoState();
}

class _CircularMenuDemoState extends State<CircularMenuDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  final List<IconData> _icons = [
    Icons.camera_alt,
    Icons.photo,
    Icons.videocam,
    Icons.music_note,
    Icons.location_on,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flow 环形菜单')),
      body: Stack(
        children: [
          // 内容区域
          Center(
            child: Text(
              '点击右下角按钮展开菜单',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          
          // 环形菜单
          Positioned(
            right: 16,
            bottom: 16,
            child: Flow(
              delegate: CircularFlowDelegate(animation: _controller),
              children: [
                // 菜单项
                ..._icons.map((icon) => _buildMenuItem(icon)),
                // 主按钮（最后添加，显示在最上层）
                _buildMainButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon) {
    return FloatingActionButton(
      mini: true,
      heroTag: icon.toString(),
      backgroundColor: Colors.blue,
      child: Icon(icon, color: Colors.white),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了 ${icon.toString()}')),
        );
        _toggleMenu();
      },
    );
  }

  Widget _buildMainButton() {
    return FloatingActionButton(
      heroTag: 'main',
      backgroundColor: _isOpen ? Colors.red : Colors.blue,
      child: AnimatedRotation(
        turns: _isOpen ? 0.125 : 0,
        duration: Duration(milliseconds: 300),
        child: Icon(Icons.add, color: Colors.white),
      ),
      onPressed: _toggleMenu,
    );
  }
}

class CircularFlowDelegate extends FlowDelegate {
  CircularFlowDelegate({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;
  final double buttonSize = 56;
  final double miniButtonSize = 40;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(buttonSize, buttonSize);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final n = context.childCount - 1; // 菜单项数量
    final radius = 80.0 * animation.value;

    // 绘制菜单项（从右下角向左上方扇形展开）
    for (int i = 0; i < n; i++) {
      // 角度范围：从 180° 到 270°（左上方 90° 范围）
      final angle = math.pi + (i / (n - 1)) * (math.pi / 2);
      
      // 计算位置（相对于主按钮中心）
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      
      // 偏移调整，使菜单项中心对齐
      final offsetX = (buttonSize - miniButtonSize) / 2 + x;
      final offsetY = (buttonSize - miniButtonSize) / 2 + y;
      
      // 缩放和透明度效果
      final scale = animation.value;
      final transform = Matrix4.identity()
        ..translate(offsetX + miniButtonSize / 2, offsetY + miniButtonSize / 2)
        ..scale(scale)
        ..translate(-miniButtonSize / 2, -miniButtonSize / 2);

      context.paintChild(i, transform: transform);
    }

    // 绘制主按钮（始终在中心位置）
    context.paintChild(n);
  }

  @override
  bool shouldRepaint(CircularFlowDelegate oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
```

## Flow vs Wrap 对比

| 特性 | Flow | Wrap |
|------|------|------|
| 性能 | ✅ 高性能（单次布局） | 普通 |
| 自定义布局 | ✅ 完全自定义 | ❌ 仅换行布局 |
| 动画支持 | ✅ 原生支持 | 需额外处理 |
| 使用复杂度 | 较高（需实现 delegate） | 简单 |
| 适用场景 | 复杂动画、自定义排列 | 标签、简单换行 |
| 子组件重叠 | ✅ 支持 | ❌ 不支持 |

## 最佳实践

1. **何时使用 Flow**
   - 需要高性能的自定义布局
   - 子组件需要重叠或复杂动画
   - 需要精确控制每个子组件的位置和变换
   - 环形菜单、扇形菜单等特殊布局

2. **何时使用 Wrap**
   - 简单的换行布局
   - 标签列表、筛选条件
   - 不需要动画或自定义位置
   - 快速实现，代码简洁

3. **性能优化**
   - Flow 只在 `shouldRepaint` 返回 true 时重绘
   - 使用 `repaint` 参数传入 `Animation` 以优化动画性能
   - 避免在 `paintChildren` 中进行复杂计算

4. **动画集成**
   - 将 `Animation` 传入 delegate 的构造函数
   - 通过 `super(repaint: animation)` 自动监听动画变化
   - 在 `paintChildren` 中使用 `animation.value` 控制布局

## 相关组件

- [Wrap](./wrap.md) - 自动换行布局（简单场景）
- [CustomMultiChildLayout](./custommultichildlayout.md) - 自定义多子组件布局
- [Stack](./stack.md) - 层叠布局
- [AnimatedPositioned](../animation/animatedpositioned.md) - 动画定位

## 官方文档

- [Flow API](https://api.flutter-io.cn/flutter/widgets/Flow-class.html)
- [FlowDelegate API](https://api.flutter-io.cn/flutter/rendering/FlowDelegate-class.html)
