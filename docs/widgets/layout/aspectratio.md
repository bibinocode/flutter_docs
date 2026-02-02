# AspectRatio

`AspectRatio` 是 Flutter 中用于保持子组件固定宽高比的布局组件。它会根据父组件的约束和指定的宽高比来确定子组件的尺寸，非常适合视频播放器、图片展示等需要固定比例的场景。

## 基本用法

```dart
AspectRatio(
  aspectRatio: 16 / 9,  // 宽高比 = 宽度 / 高度
  child: Container(
    color: Colors.blue,
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| aspectRatio | double | 必填 | 宽高比，计算方式为 width / height |
| child | Widget? | null | 子组件 |

## aspectRatio 计算方式

宽高比 = 宽度 ÷ 高度

| 常见比例 | aspectRatio 值 | 应用场景 |
|----------|---------------|----------|
| 16:9 | 16 / 9 ≈ 1.78 | 视频播放器、横屏内容 |
| 4:3 | 4 / 3 ≈ 1.33 | 传统电视、卡片图片 |
| 1:1 | 1.0 | 头像、正方形图片 |
| 3:2 | 3 / 2 = 1.5 | 相机照片 |
| 21:9 | 21 / 9 ≈ 2.33 | 超宽屏电影 |
| 9:16 | 9 / 16 ≈ 0.56 | 竖屏视频、短视频 |

## 使用场景

### 1. 视频播放器 16:9

```dart
AspectRatio(
  aspectRatio: 16 / 9,
  child: Container(
    color: Colors.black,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.play_circle_outline,
          size: 64,
          color: Colors.white,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Colors.grey[800],
          ),
        ),
      ],
    ),
  ),
)
```

### 2. 头像 1:1

```dart
AspectRatio(
  aspectRatio: 1,
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        image: NetworkImage('https://picsum.photos/200'),
        fit: BoxFit.cover,
      ),
    ),
  ),
)
```

### 3. 卡片图片 4:3

```dart
Card(
  clipBehavior: Clip.antiAlias,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(
          'https://picsum.photos/400/300',
          fit: BoxFit.cover,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('卡片标题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('这是卡片描述内容', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ],
  ),
)
```

### 4. 响应式广告位

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // 根据屏幕宽度调整广告比例
    double ratio = constraints.maxWidth > 600 ? 4 / 1 : 16 / 9;
    
    return AspectRatio(
      aspectRatio: ratio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '广告位',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  },
)
```

### 5. 网格图片列表

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 16 / 9,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
  itemCount: 10,
  itemBuilder: (context, index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage('https://picsum.photos/320/180?random=$index'),
          fit: BoxFit.cover,
        ),
      ),
    );
  },
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class AspectRatioDemo extends StatefulWidget {
  @override
  State<AspectRatioDemo> createState() => _AspectRatioDemoState();
}

class _AspectRatioDemoState extends State<AspectRatioDemo> {
  double _aspectRatio = 16 / 9;
  bool _isPlaying = false;
  double _progress = 0.0;

  final Map<String, double> presets = {
    '16:9 视频': 16 / 9,
    '4:3 传统': 4 / 3,
    '1:1 正方形': 1.0,
    '21:9 超宽': 21 / 9,
    '9:16 竖屏': 9 / 16,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AspectRatio 示例')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 比例选择器
            Text('选择宽高比:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.entries.map((entry) {
                bool isSelected = (_aspectRatio - entry.value).abs() < 0.01;
                return ChoiceChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _aspectRatio = entry.value),
                );
              }).toList(),
            ),
            
            SizedBox(height: 24),
            
            // 视频播放器占位
            Text('视频播放器:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            AspectRatio(
              aspectRatio: _aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // 视频封面
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://picsum.photos/800/450',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[900],
                            child: Icon(Icons.movie, color: Colors.grey, size: 48),
                          ),
                        ),
                      ),
                    ),
                    
                    // 播放按钮
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPlaying = !_isPlaying),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // 控制栏
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          children: [
                            Slider(
                              value: _progress,
                              onChanged: (v) => setState(() => _progress = v),
                              activeColor: Colors.red,
                              inactiveColor: Colors.grey,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '00:${(_progress * 60).toInt().toString().padLeft(2, '0')} / 01:00',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.volume_up, color: Colors.white, size: 20),
                                    SizedBox(width: 16),
                                    Icon(Icons.fullscreen, color: Colors.white, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 比例指示
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_aspectRatio.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // 当前比例信息
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '当前宽高比: ${_aspectRatio.toStringAsFixed(2)} (宽度 / 高度)',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## AspectRatio vs 其他尺寸控制方式

| 方式 | 特点 | 适用场景 |
|------|------|----------|
| AspectRatio | 保持固定宽高比 | 视频、图片、响应式卡片 |
| SizedBox | 固定宽高像素值 | 固定尺寸元素 |
| FractionallySizedBox | 相对父组件的比例 | 百分比布局 |
| ConstrainedBox | 设置最大最小约束 | 限制尺寸范围 |

## 最佳实践

1. **正确计算 aspectRatio**：始终使用 宽度 / 高度 的方式计算
2. **配合 FittedBox 使用**：当内容需要缩放适配时
3. **响应式设计**：配合 LayoutBuilder 根据屏幕尺寸调整比例
4. **图片裁剪**：配合 BoxFit.cover 确保图片填满且不变形
5. **避免无限约束**：AspectRatio 需要父组件提供有限的宽度或高度约束
6. **嵌套使用注意**：在 ListView 等滚动组件中使用时需要限制宽度

## 相关组件

- [FittedBox](../basics/fittedbox.md) - 缩放适配子组件
- [LayoutBuilder](./layoutbuilder.md) - 根据父约束构建布局
- [FractionallySizedBox](./fractionallysizedbox.md) - 相对尺寸布局
- [ConstrainedBox](./constrainedbox.md) - 约束盒子

## 官方文档

- [AspectRatio API](https://api.flutter-io.cn/flutter/widgets/AspectRatio-class.html)
