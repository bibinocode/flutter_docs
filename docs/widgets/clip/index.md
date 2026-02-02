# Clip 裁剪组件

Flutter 提供了一系列 Clip 组件用于裁剪子组件的绘制区域。本章介绍 `ClipRect`、`ClipRRect`、`ClipOval`、`ClipPath` 等常用裁剪组件的使用方法。

## 组件概览

| 组件 | 说明 | 适用场景 |
|------|------|----------|
| `ClipRect` | 矩形裁剪 | 简单矩形裁剪 |
| `ClipRRect` | 圆角矩形裁剪 | 圆角图片、卡片 |
| `ClipOval` | 椭圆/圆形裁剪 | 头像、圆形按钮 |
| `ClipPath` | 路径裁剪 | 复杂形状裁剪 |

## ClipRect 矩形裁剪

`ClipRect` 将子组件裁剪为矩形区域。

```dart
ClipRect(
  child: Align(
    alignment: Alignment.topCenter,
    heightFactor: 0.5,  // 只显示上半部分
    child: Image.network(
      'https://picsum.photos/200/200',
      width: 200,
      height: 200,
    ),
  ),
)
```

### 自定义裁剪区域

```dart
ClipRect(
  clipper: _MyClipper(),  // 自定义裁剪器
  child: Image.network('https://picsum.photos/200/200'),
)

class _MyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // 只裁剪中间区域
    return Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.5,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
```

## ClipRRect 圆角矩形裁剪

`ClipRRect` 将子组件裁剪为圆角矩形。

### 基本用法

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Image.network(
    'https://picsum.photos/200/200',
    width: 200,
    height: 200,
    fit: BoxFit.cover,
  ),
)
```

### 不同圆角

```dart
ClipRRect(
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
    bottomLeft: Radius.circular(10),
    bottomRight: Radius.circular(10),
  ),
  child: Container(
    width: 200,
    height: 150,
    color: Colors.blue,
    child: const Center(
      child: Text('不同圆角', style: TextStyle(color: Colors.white)),
    ),
  ),
)
```

### 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `borderRadius` | `BorderRadiusGeometry?` | 圆角半径 |
| `clipper` | `CustomClipper<RRect>?` | 自定义裁剪器 |
| `clipBehavior` | `Clip` | 裁剪行为 |

## ClipOval 椭圆/圆形裁剪

`ClipOval` 将子组件裁剪为椭圆形。当子组件是正方形时，裁剪结果为圆形。

### 圆形头像

```dart
ClipOval(
  child: Image.network(
    'https://picsum.photos/100/100',
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  ),
)
```

### 椭圆形

```dart
ClipOval(
  child: Container(
    width: 200,
    height: 100,
    color: Colors.purple,
    child: const Center(
      child: Text('椭圆形', style: TextStyle(color: Colors.white)),
    ),
  ),
)
```

### 带边框的圆形头像

```dart
Container(
  padding: const EdgeInsets.all(4),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: Colors.blue, width: 3),
  ),
  child: ClipOval(
    child: Image.network(
      'https://picsum.photos/100/100',
      width: 100,
      height: 100,
      fit: BoxFit.cover,
    ),
  ),
)
```

## ClipPath 路径裁剪

`ClipPath` 使用自定义路径裁剪子组件，可以创建任意形状。

### 三角形裁剪

```dart
ClipPath(
  clipper: TriangleClipper(),
  child: Container(
    width: 200,
    height: 200,
    color: Colors.orange,
  ),
)

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);  // 顶部中点
    path.lineTo(size.width, size.height);  // 右下角
    path.lineTo(0, size.height);  // 左下角
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
```

### 波浪形裁剪

```dart
ClipPath(
  clipper: WaveClipper(),
  child: Container(
    height: 200,
    color: Colors.blue,
  ),
)

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    
    // 波浪曲线
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    
    final secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    final secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
```

### 六边形裁剪

```dart
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    
    path.moveTo(width * 0.5, 0);
    path.lineTo(width, height * 0.25);
    path.lineTo(width, height * 0.75);
    path.lineTo(width * 0.5, height);
    path.lineTo(0, height * 0.75);
    path.lineTo(0, height * 0.25);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
```

### 星形裁剪

```dart
class StarClipper extends CustomClipper<Path> {
  final int points;
  
  StarClipper({this.points = 5});

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    
    final angle = (2 * pi) / points;
    final halfAngle = angle / 2;
    
    path.moveTo(
      center.dx + outerRadius * cos(-pi / 2),
      center.dy + outerRadius * sin(-pi / 2),
    );
    
    for (int i = 0; i < points; i++) {
      // 内点
      path.lineTo(
        center.dx + innerRadius * cos(-pi / 2 + halfAngle + angle * i),
        center.dy + innerRadius * sin(-pi / 2 + halfAngle + angle * i),
      );
      // 外点
      path.lineTo(
        center.dx + outerRadius * cos(-pi / 2 + angle * (i + 1)),
        center.dy + outerRadius * sin(-pi / 2 + angle * (i + 1)),
      );
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant StarClipper oldClipper) {
    return points != oldClipper.points;
  }
}
```

## Clip 行为

`clipBehavior` 属性控制裁剪的抗锯齿效果：

| 值 | 说明 | 性能 |
|----|------|------|
| `Clip.none` | 不裁剪 | 最快 |
| `Clip.hardEdge` | 硬边缘裁剪，无抗锯齿 | 快 |
| `Clip.antiAlias` | 抗锯齿裁剪 | 较慢 |
| `Clip.antiAliasWithSaveLayer` | 抗锯齿 + 保存图层 | 最慢 |

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  clipBehavior: Clip.antiAlias,  // 推荐用于圆角
  child: Image.network('https://picsum.photos/200/200'),
)
```

## 实际应用

### 1. 图片画廊

```dart
class ImageGalleryDemo extends StatelessWidget {
  const ImageGalleryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://picsum.photos/200/200?random=$index',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
```

### 2. 用户头像列表

```dart
class AvatarListDemo extends StatelessWidget {
  const AvatarListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipOval(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Image.network(
                  'https://picsum.photos/50/50?random=$index',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 3. 波浪形 Header

```dart
class WaveHeaderDemo extends StatelessWidget {
  const WaveHeaderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                '欢迎',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // 其他内容...
      ],
    );
  }
}
```

### 4. 对角线裁剪卡片

```dart
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DiagonalCardDemo extends StatelessWidget {
  const DiagonalCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: DiagonalClipper(),
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://picsum.photos/400/200'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
```

## 动画裁剪

结合 `AnimatedBuilder` 实现动画裁剪效果：

```dart
class AnimatedClipDemo extends StatefulWidget {
  const AnimatedClipDemo({super.key});

  @override
  State<AnimatedClipDemo> createState() => _AnimatedClipDemoState();
}

class _AnimatedClipDemoState extends State<AnimatedClipDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(_controller.value * 100),
          child: child,
        );
      },
      child: Image.network(
        'https://picsum.photos/200/200',
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }
}
```

## 性能注意

::: warning 性能提示
- 裁剪操作会影响性能，尤其是 `ClipPath`
- 避免在大量组件上使用复杂裁剪
- 优先使用 `Clip.hardEdge`，仅在需要时使用抗锯齿
- 静态裁剪考虑使用预处理好的图片
:::

## 相关组件

- [Container](../basics/container.md)：也可通过 decoration 实现裁剪
- [CircleAvatar](../material/circleavatar.md)：内置圆形裁剪的头像组件
- [Card](../material/card.md)：内置圆角的卡片组件

## 官方文档

- [ClipRect API](https://api.flutter.dev/flutter/widgets/ClipRect-class.html)
- [ClipRRect API](https://api.flutter.dev/flutter/widgets/ClipRRect-class.html)
- [ClipOval API](https://api.flutter.dev/flutter/widgets/ClipOval-class.html)
- [ClipPath API](https://api.flutter.dev/flutter/widgets/ClipPath-class.html)
