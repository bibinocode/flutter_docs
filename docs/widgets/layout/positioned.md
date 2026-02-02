# Positioned

`Positioned` 是 Flutter 中用于在 `Stack` 内精确定位子组件的组件。它的工作方式类似于 CSS 中的 `position: absolute`，通过设置 `left`、`top`、`right`、`bottom` 等属性来确定子组件在 Stack 中的位置。

## 基本用法

```dart
Stack(
  children: [
    // 背景
    Container(color: Colors.grey[300]),
    // 左上角定位
    Positioned(
      left: 10,
      top: 10,
      child: Icon(Icons.star, color: Colors.amber),
    ),
    // 右下角定位
    Positioned(
      right: 10,
      bottom: 10,
      child: Icon(Icons.favorite, color: Colors.red),
    ),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| left | double? | null | 子组件左边距离 Stack 左边的距离 |
| top | double? | null | 子组件顶部距离 Stack 顶部的距离 |
| right | double? | null | 子组件右边距离 Stack 右边的距离 |
| bottom | double? | null | 子组件底部距离 Stack 底部的距离 |
| width | double? | null | 子组件的宽度 |
| height | double? | null | 子组件的高度 |
| child | Widget | required | 要定位的子组件 |

## 构造函数

### Positioned（默认构造函数）

```dart
Positioned(
  left: 20,
  top: 20,
  width: 100,
  height: 50,
  child: Container(color: Colors.blue),
)
```

### Positioned.fill

铺满整个 Stack，可通过参数设置边距：

```dart
// 完全铺满
Positioned.fill(
  child: Container(color: Colors.blue.withOpacity(0.5)),
)

// 带边距铺满
Positioned.fill(
  left: 10,
  top: 10,
  right: 10,
  bottom: 10,
  child: Container(color: Colors.green),
)
```

### Positioned.fromRect

根据 Rect 对象定位：

```dart
Positioned.fromRect(
  rect: Rect.fromLTWH(20, 30, 100, 80),
  child: Container(color: Colors.orange),
)
```

### Positioned.fromRelativeRect

根据 RelativeRect 对象定位（相对于父容器边界）：

```dart
Positioned.fromRelativeRect(
  rect: RelativeRect.fromLTRB(10, 20, 30, 40),
  child: Container(color: Colors.purple),
)
```

### Positioned.directional

支持 TextDirection 的方向性定位，适用于 RTL（从右到左）语言：

```dart
Positioned.directional(
  textDirection: TextDirection.ltr,
  start: 10,  // LTR 时等同于 left，RTL 时等同于 right
  top: 20,
  child: Text('Hello'),
)
```

## 使用场景

### 1. 四角定位

```dart
Stack(
  children: [
    Container(
      width: 200,
      height: 200,
      color: Colors.grey[200],
    ),
    // 左上角
    Positioned(
      left: 8,
      top: 8,
      child: _buildCornerIcon(Icons.north_west),
    ),
    // 右上角
    Positioned(
      right: 8,
      top: 8,
      child: _buildCornerIcon(Icons.north_east),
    ),
    // 左下角
    Positioned(
      left: 8,
      bottom: 8,
      child: _buildCornerIcon(Icons.south_west),
    ),
    // 右下角
    Positioned(
      right: 8,
      bottom: 8,
      child: _buildCornerIcon(Icons.south_east),
    ),
  ],
)

Widget _buildCornerIcon(IconData icon) {
  return Container(
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}
```

### 2. 边缘贴合

```dart
Stack(
  children: [
    Container(color: Colors.grey[100]),
    // 顶部横条
    Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 60,
      child: Container(color: Colors.blue),
    ),
    // 底部横条
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 60,
      child: Container(color: Colors.green),
    ),
    // 左侧竖条
    Positioned(
      left: 0,
      top: 60,
      bottom: 60,
      width: 60,
      child: Container(color: Colors.orange),
    ),
  ],
)
```

### 3. 相对定位（百分比）

配合 LayoutBuilder 实现百分比定位：

```dart
LayoutBuilder(
  builder: (context, constraints) {
    return Stack(
      children: [
        Container(color: Colors.grey[200]),
        // 定位到 25% 的位置
        Positioned(
          left: constraints.maxWidth * 0.25,
          top: constraints.maxHeight * 0.25,
          child: Container(
            width: 50,
            height: 50,
            color: Colors.red,
          ),
        ),
        // 定位到中心偏右
        Positioned(
          left: constraints.maxWidth * 0.5,
          top: constraints.maxHeight * 0.5,
          child: Transform.translate(
            offset: Offset(-25, -25),  // 居中修正
            child: Container(
              width: 50,
              height: 50,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  },
)
```

### 4. 铺满容器

```dart
Stack(
  children: [
    // 背景图片铺满
    Positioned.fill(
      child: Image.network(
        'https://picsum.photos/400/300',
        fit: BoxFit.cover,
      ),
    ),
    // 半透明遮罩
    Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
      ),
    ),
    // 内容区域（带边距）
    Positioned.fill(
      left: 20,
      right: 20,
      top: 40,
      bottom: 40,
      child: Center(
        child: Text(
          '标题文字',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ],
)
```

## 完整示例

图片编辑器工具栏定位：

```dart
import 'package:flutter/material.dart';

class ImageEditorDemo extends StatefulWidget {
  @override
  State<ImageEditorDemo> createState() => _ImageEditorDemoState();
}

class _ImageEditorDemoState extends State<ImageEditorDemo> {
  double _scale = 1.0;
  double _rotation = 0.0;
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('图片编辑器')),
      body: Stack(
        children: [
          // 背景
          Positioned.fill(
            child: Container(color: Colors.grey[900]),
          ),
          
          // 中间编辑区域
          Positioned.fill(
            left: 60,
            right: 60,
            top: 60,
            bottom: 100,
            child: Stack(
              children: [
                // 图片
                Center(
                  child: Transform.scale(
                    scale: _scale,
                    child: Transform.rotate(
                      angle: _rotation,
                      child: Image.network(
                        'https://picsum.photos/300/200',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // 网格线
                if (_showGrid)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GridPainter(),
                    ),
                  ),
              ],
            ),
          ),
          
          // 顶部工具栏
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 50,
            child: Container(
              color: Colors.grey[850],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTopButton(Icons.undo, '撤销'),
                  _buildTopButton(Icons.redo, '重做'),
                  VerticalDivider(color: Colors.grey),
                  _buildTopButton(Icons.crop, '裁剪'),
                  _buildTopButton(Icons.rotate_right, '旋转'),
                  _buildTopButton(Icons.flip, '翻转'),
                ],
              ),
            ),
          ),
          
          // 左侧工具栏
          Positioned(
            left: 0,
            top: 60,
            bottom: 100,
            width: 50,
            child: Container(
              color: Colors.grey[850],
              child: Column(
                children: [
                  _buildSideButton(Icons.brush, '画笔'),
                  _buildSideButton(Icons.text_fields, '文字'),
                  _buildSideButton(Icons.emoji_emotions, '贴纸'),
                  _buildSideButton(Icons.filter, '滤镜'),
                  Spacer(),
                  _buildSideButton(
                    _showGrid ? Icons.grid_on : Icons.grid_off,
                    '网格',
                    onTap: () => setState(() => _showGrid = !_showGrid),
                  ),
                ],
              ),
            ),
          ),
          
          // 右侧属性栏
          Positioned(
            right: 0,
            top: 60,
            bottom: 100,
            width: 50,
            child: Container(
              color: Colors.grey[850],
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text('缩放', style: TextStyle(color: Colors.white, fontSize: 10)),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _scale,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (v) => setState(() => _scale = v),
                    ),
                  ),
                  Text('旋转', style: TextStyle(color: Colors.white, fontSize: 10)),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _rotation,
                      min: -3.14,
                      max: 3.14,
                      onChanged: (v) => setState(() => _rotation = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部操作栏
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: Container(
              color: Colors.grey[850],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white),
                    ),
                    child: Text('取消'),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.save),
                    label: Text('保存'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                    label: Text('分享'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 浮动缩放指示器
          Positioned(
            right: 70,
            bottom: 110,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${(_scale * 100).toInt()}%',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      tooltip: tooltip,
      onPressed: () {},
    );
  }

  Widget _buildSideButton(IconData icon, String tooltip, {VoidCallback? onTap}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 22),
      tooltip: tooltip,
      onPressed: onTap ?? () {},
    );
  }
}

// 网格绘制器
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    
    // 绘制三等分线
    for (int i = 1; i < 3; i++) {
      // 垂直线
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
      // 水平线
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## 定位约束规则

Positioned 的属性有一些约束规则需要注意：

| 组合 | 效果 |
|------|------|
| left + width | 固定左边位置和宽度 |
| right + width | 固定右边位置和宽度 |
| left + right | 宽度自动计算（拉伸） |
| left + right + width | ⚠️ 冲突，会报错 |
| 仅 left 或仅 right | 使用子组件自身宽度 |

同样的规则适用于垂直方向的 top、bottom、height。

## 最佳实践

1. **避免约束冲突**：不要同时设置 left + right + width 或 top + bottom + height
   ```dart
   // ❌ 错误：约束冲突
   Positioned(
     left: 10,
     right: 10,
     width: 100,  // 冲突！
     child: Container(),
   )
   
   // ✅ 正确：使用 left + right 自动计算宽度
   Positioned(
     left: 10,
     right: 10,
     child: Container(height: 50),
   )
   ```

2. **使用 Positioned.fill 简化代码**：
   ```dart
   // ❌ 冗长
   Positioned(
     left: 0,
     top: 0,
     right: 0,
     bottom: 0,
     child: child,
   )
   
   // ✅ 简洁
   Positioned.fill(child: child)
   ```

3. **RTL 支持使用 directional**：
   ```dart
   // 支持从右到左语言
   Positioned.directional(
     textDirection: Directionality.of(context),
     start: 10,
     child: child,
   )
   ```

4. **组合 Align 实现更灵活定位**：
   ```dart
   Stack(
     children: [
       Positioned(
         left: 10,
         top: 10,
         right: 10,
         child: Align(
           alignment: Alignment.centerRight,
           child: Icon(Icons.close),
         ),
       ),
     ],
   )
   ```

5. **注意 Stack 的 fit 属性**：
   ```dart
   // Stack.fit 会影响 Positioned 的行为
   Stack(
     fit: StackFit.expand,  // 强制未定位子组件铺满
     children: [
       Positioned.fill(child: background),
       Positioned(...),  // 正常工作
     ],
   )
   ```

## 相关组件

- [Stack](./stack.md) - Positioned 的父容器
- [Align](./align.md) - 相对对齐定位
- [FractionalTranslation](../animation/fractionaltranslation.md) - 按比例偏移
- [AnimatedPositioned](../animation/animatedpositioned.md) - 带动画的 Positioned
- [PositionedTransition](../animation/positionedtransition.md) - 定位动画过渡

## 官方文档

- [Positioned API](https://api.flutter-io.cn/flutter/widgets/Positioned-class.html)
- [Stack API](https://api.flutter-io.cn/flutter/widgets/Stack-class.html)
