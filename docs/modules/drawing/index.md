# Flutter 绘图

Flutter 提供了强大的 2D 绘图能力，通过 CustomPaint 和 Canvas API 可以绘制任意图形。本章介绍 Flutter 绘图的核心概念和常用技巧。

## 概述

### 绘图核心类

| 类 | 说明 |
|---|------|
| CustomPaint | 提供绘图画布的 Widget |
| CustomPainter | 绘图逻辑的抽象类 |
| Canvas | 绘图画布，提供绘图 API |
| Paint | 画笔，控制颜色、样式等 |
| Path | 路径，定义复杂形状 |

## CustomPaint 基础

```dart
class MyPainter extends CustomPainter {
  @override
  void paint (Canvas canvas , Size size ) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// 使用
CustomPaint(
  size: const Size(200, 200),
  painter: MyPainter(),
)
```

## Paint 画笔属性

```dart
final paint = Paint()
  ..color = Colors.blue              // 颜色
  ..strokeWidth = 2.0                // 线宽
  ..style = PaintingStyle.stroke // 样式：stroke(描边) / fill(填充)
  ..strokeCap = StrokeCap.round      // 线帽：butt / round / square
  ..strokeJoin = StrokeJoin.round    // 连接：miter / round / bevel
  ..isAntiAlias = true               // 抗锯齿
  ..blendMode = BlendMode.srcOver    // 混合模式
  ..shader = linearGradient          // 着色器（渐变）
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);  // 模糊
```

## 基础图形绘制

### 点和线

```dart
class LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 绘制点
    canvas.drawPoints(
      PointMode.points,
      [Offset(50, 50), Offset(100, 50), Offset(150, 50)],
      paint,
    );

    // 绘制线段
    canvas.drawLine(Offset(50, 100), Offset(150, 100), paint);

    // 绘制折线
    canvas.drawPoints(
      PointMode.polygon,
      [Offset(50, 200), Offset(75, 180), Offset(100, 220), Offset(125, 180), Offset(150, 200)],
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 矩形

```dart
// 普通矩形
canvas.drawRect(Rect.fromLTWH(20, 20, 100, 60), paint);

// 圆角矩形
canvas.drawRRect(
  RRect.fromRectAndRadius(Rect.fromLTWH(20, 100, 100, 60), Radius.circular(12)),
  paint,
);
```

### 圆形和椭圆

```dart
// 圆形
canvas.drawCircle(Offset(100, 100), 50, paint);

// 椭圆
canvas.drawOval(
  Rect.fromCenter(center: Offset(200, 100), width: 120, height: 60),
  paint,
);
```

### 弧线和扇形

```dart
// 弧线（从 0 度开始，绘制 270 度）
canvas.drawArc(rect, 0, 3 * pi / 2, false, paint);

// 扇形（连接到圆心）
canvas.drawArc(rect, 0, pi / 2, true, paint);
```

## Path 路径

```dart
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(50, 100);
    path.lineTo(100, 50);
    path.lineTo(150, 100);
    
    // 二次贝塞尔曲线
    path.quadraticBezierTo(175, 150, 150, 200);
    
    // 三次贝塞尔曲线
    path.cubicTo(125, 250, 75, 250, 50, 200);
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## 渐变

```dart
class GradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 线性渐变
    final linearGradient = LinearGradient(
      colors: [Colors.red, Colors.orange, Colors.yellow],
    ).createShader(Rect.fromLTWH(0, 0, size.width, 80));

    canvas.drawRect(
      Rect.fromLTWH(10, 10, size.width - 20, 60),
      Paint()..shader = linearGradient,
    );

    // 径向渐变
    final radialGradient = RadialGradient(
      colors: [Colors.blue, Colors.purple],
    ).createShader(Rect.fromLTWH(10, 90, size.width - 20, 100));

    canvas.drawOval(
      Rect.fromLTWH(10, 90, size.width - 20, 100),
      Paint()..shader = radialGradient,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## 文字绘制

```dart
class TextdrawPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: 'Hello Flutter',
      style: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## Canvas 变换

```dart
class TransformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(pi / 4);
    canvas.scale(0.8, 0.8);
    canvas.drawRect(Rect.fromLTWH(-50, -50, 100, 100), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## 实际应用：圆形进度条

```dart
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    this.progressColor = Colors.blue,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // 背景圆
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 进度弧
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
```

## 折线图

```dart
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  LineChartPainter({required this.data, this.lineColor = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal;
    final stepX = size.width / (data.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minVal) / range * size.height);
      points.add(Offset(x, y));
    }

    // 填充区域
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = lineColor.withOpacity(0.2));

    // 线条
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // 点
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => data != oldDelegate.data;
}
```

## 性能优化

::: tip 优化建议
1. **shouldRepaint** - 正确实现，避免不必要的重绘
2. **RepaintBoundary** - 隔离绘图区域的重绘
3. **避免在 paint 中创建对象** - 将 Paint 等作为成员变量
4. **使用 canvas.save/restore** - 管理变换状态
5. **复杂路径预计算** - 缓存不变的 Path
:::

## 官方文档

- [CustomPaint](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)
- [Canvas](https://api.flutter.dev/flutter/Dart-ui/Canvas-class.html)
- [Paint](https://api.flutter.dev/flutter/Dart-ui/Paint-class.html)
- [Path](https://api.flutter.dev/flutter/Dart-ui/Path-class.html)
