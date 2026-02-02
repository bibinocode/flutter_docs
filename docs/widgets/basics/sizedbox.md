# SizedBox

`SizedBox` 是 Flutter 中用于创建固定大小盒子的基础组件。它可以强制子组件具有特定的宽度和高度，也常被用作组件之间的间距占位符。由于其轻量级的特性，`SizedBox` 是布局中最常用的工具组件之一。

## 基本用法

```dart
// 创建固定大小的盒子
SizedBox(
  width: 100,
  height: 50,
  child: Container(color: Colors.blue),
)

// 作为间距使用
Column(
  children: [
    Text('第一行'),
    SizedBox(height: 16), // 垂直间距
    Text('第二行'),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `width` | `double?` | `null` | 盒子的宽度，为 null 时由子组件决定 |
| `height` | `double?` | `null` | 盒子的高度，为 null 时由子组件决定 |
| `child` | `Widget?` | `null` | 子组件，可以为空 |

## 命名构造函数

| 构造函数 | 说明 |
|----------|------|
| `SizedBox()` | 默认构造函数，可指定宽高 |
| `SizedBox.expand()` | 扩展填充父容器的可用空间 |
| `SizedBox.shrink()` | 收缩到子组件的最小尺寸（宽高为 0） |
| `SizedBox.fromSize()` | 从 `Size` 对象创建 |
| `SizedBox.square()` | 创建正方形盒子 |

## 使用场景

### 1. 固定大小容器

强制子组件具有特定尺寸：

```dart
SizedBox(
  width: 200,
  height: 100,
  child: Card(
    color: Colors.blue,
    child: Center(
      child: Text(
        '固定大小',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
)
```

### 2. 添加间距

在组件之间创建空白间距，这是 `SizedBox` 最常见的用法：

```dart
// 垂直间距
Column(
  children: [
    Container(height: 50, color: Colors.red),
    SizedBox(height: 20), // 20 像素的垂直间距
    Container(height: 50, color: Colors.green),
    SizedBox(height: 20),
    Container(height: 50, color: Colors.blue),
  ],
)

// 水平间距
Row(
  children: [
    Icon(Icons.star, color: Colors.amber),
    SizedBox(width: 8), // 8 像素的水平间距
    Text('收藏'),
  ],
)
```

### 3. SizedBox.expand - 填充可用空间

扩展填满父容器的所有可用空间：

```dart
Container(
  width: 300,
  height: 200,
  color: Colors.grey[300],
  child: SizedBox.expand(
    child: Card(
      color: Colors.blue,
      child: Center(
        child: Text(
          '填充整个父容器',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  ),
)
```

等价于：

```dart
SizedBox(
  width: double.infinity,
  height: double.infinity,
  child: child,
)
```

### 4. SizedBox.shrink - 收缩到最小

创建一个宽高都为 0 的盒子，常用于条件渲染时的占位符：

```dart
// 条件显示组件
bool showContent = false;

Column(
  children: [
    Text('标题'),
    showContent 
      ? Container(
          height: 100,
          color: Colors.blue,
          child: Center(child: Text('内容')),
        )
      : SizedBox.shrink(), // 不占用任何空间
    Text('底部'),
  ],
)
```

### 5. SizedBox.fromSize - 从 Size 对象创建

使用 `Size` 对象指定尺寸：

```dart
final size = Size(150, 80);

SizedBox.fromSize(
  size: size,
  child: Container(
    color: Colors.purple,
    child: Center(
      child: Text(
        '${size.width} x ${size.height}',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
)
```

### 6. SizedBox.square - 创建正方形

快速创建宽高相等的正方形盒子：

```dart
SizedBox.square(
  dimension: 100,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Icon(Icons.check, color: Colors.white, size: 40),
    ),
  ),
)
```

### 7. 限制单一维度

只指定宽度或高度，另一维度由子组件决定：

```dart
// 只限制宽度
SizedBox(
  width: 200,
  child: TextField(
    decoration: InputDecoration(
      labelText: '固定宽度输入框',
      border: OutlineInputBorder(),
    ),
  ),
)

// 只限制高度
SizedBox(
  height: 48,
  child: ElevatedButton(
    onPressed: () {},
    child: Text('固定高度按钮'),
  ),
)
```

## 与 Container 对比

| 特性 | SizedBox | Container |
|------|----------|-----------|
| 性能 | ✅ 更轻量，性能更好 | 功能更多，相对较重 |
| 设置大小 | ✅ 支持 | ✅ 支持 |
| 装饰（颜色、边框等） | ❌ 不支持 | ✅ 支持 |
| 内边距/外边距 | ❌ 不支持 | ✅ 支持 |
| 变换（旋转、缩放） | ❌ 不支持 | ✅ 支持 |
| 对齐 | ❌ 不支持 | ✅ 支持 |
| 约束 | ❌ 只能设置固定值 | ✅ 支持 min/max 约束 |

### 何时使用 SizedBox

```dart
// ✅ 推荐：只需要设置大小或间距时使用 SizedBox
Column(
  children: [
    Text('标题'),
    SizedBox(height: 16),
    Text('内容'),
  ],
)

// ❌ 不推荐：使用 Container 只是为了添加间距
Column(
  children: [
    Text('标题'),
    Container(height: 16), // 过度使用
    Text('内容'),
  ],
)
```

### 何时使用 Container

```dart
// ✅ 需要装饰、内边距等功能时使用 Container
Container(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Text('带装饰的容器'),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class SizedBoxDemo extends StatelessWidget {
  const SizedBoxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SizedBox 示例')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 固定大小
            Text('1. 固定大小', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(
              width: 150,
              height: 80,
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Text('150 x 80', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // 间距示例
            Text('2. 作为间距', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                _buildBox(Colors.red),
                SizedBox(width: 16),
                _buildBox(Colors.green),
                SizedBox(width: 16),
                _buildBox(Colors.blue),
              ],
            ),
            
            SizedBox(height: 24),
            
            // SizedBox.expand
            Text('3. SizedBox.expand', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 100,
              color: Colors.grey[300],
              child: SizedBox.expand(
                child: Container(
                  margin: EdgeInsets.all(8),
                  color: Colors.purple,
                  child: Center(
                    child: Text('填充父容器', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // SizedBox.square
            Text('4. SizedBox.square', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox.square(
              dimension: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.star, color: Colors.white, size: 32),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // 条件渲染
            Text('5. 条件渲染占位', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _ConditionalDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(Color color) {
    return Container(
      width: 50,
      height: 50,
      color: color,
    );
  }
}

class _ConditionalDemo extends StatefulWidget {
  @override
  State<_ConditionalDemo> createState() => _ConditionalDemoState();
}

class _ConditionalDemoState extends State<_ConditionalDemo> {
  bool _showContent = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _showContent = !_showContent),
          child: Text(_showContent ? '隐藏内容' : '显示内容'),
        ),
        SizedBox(height: 8),
        _showContent
            ? Container(
                width: double.infinity,
                height: 60,
                color: Colors.teal,
                child: Center(
                  child: Text('可见内容', style: TextStyle(color: Colors.white)),
                ),
              )
            : SizedBox.shrink(),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Text('这行文字始终显示'),
        ),
      ],
    );
  }
}
```

## 最佳实践

### 1. 优先使用 SizedBox 添加间距

```dart
// ✅ 推荐
Column(
  children: [
    Widget1(),
    SizedBox(height: 16),
    Widget2(),
  ],
)

// ❌ 不推荐
Column(
  children: [
    Widget1(),
    Padding(
      padding: EdgeInsets.only(top: 16),
      child: Widget2(),
    ),
  ],
)
```

### 2. 使用 const 优化性能

```dart
// ✅ 推荐：使用 const 避免重复创建
Column(
  children: [
    Text('标题'),
    const SizedBox(height: 16),
    Text('内容'),
    const SizedBox(height: 8),
    Text('底部'),
  ],
)
```

### 3. 定义常用间距常量

```dart
// 在项目中定义统一的间距常量
class AppSpacing {
  static const Widget xs = SizedBox(height: 4, width: 4);
  static const Widget sm = SizedBox(height: 8, width: 8);
  static const Widget md = SizedBox(height: 16, width: 16);
  static const Widget lg = SizedBox(height: 24, width: 24);
  static const Widget xl = SizedBox(height: 32, width: 32);
  
  // 水平间距
  static const Widget horizontalSm = SizedBox(width: 8);
  static const Widget horizontalMd = SizedBox(width: 16);
  
  // 垂直间距
  static const Widget verticalSm = SizedBox(height: 8);
  static const Widget verticalMd = SizedBox(height: 16);
}

// 使用
Column(
  children: [
    Text('标题'),
    AppSpacing.verticalMd,
    Text('内容'),
  ],
)
```

### 4. 条件渲染时使用 SizedBox.shrink()

```dart
// ✅ 推荐：不显示时不占空间
condition ? SomeWidget() : SizedBox.shrink()

// 或者使用集合 if
Column(
  children: [
    Text('标题'),
    if (showContent) ContentWidget(),
    Text('底部'),
  ],
)
```

### 5. 避免不必要的嵌套

```dart
// ❌ 不推荐：不必要的嵌套
SizedBox(
  width: 100,
  height: 100,
  child: SizedBox(
    width: 100,
    height: 100,
    child: MyWidget(),
  ),
)

// ✅ 推荐：单层即可
SizedBox(
  width: 100,
  height: 100,
  child: MyWidget(),
)
```

## 注意事项

1. **SizedBox 会强制约束子组件**：子组件会被强制适应 SizedBox 的尺寸
2. **null 值表示不约束**：width 或 height 为 null 时，该维度由子组件决定
3. **无子组件时作为占位**：没有 child 的 SizedBox 可以作为空白占位符
4. **double.infinity 的使用**：设置为 `double.infinity` 时会尽可能扩展

## 相关组件

- [Container](./container.md) - 功能更丰富的容器组件
- [Padding](./padding.md) - 添加内边距
- [ConstrainedBox](./constrainedbox.md) - 添加额外约束
- [FractionallySizedBox](./fractionallysizedbox.md) - 按比例设置大小
- [Expanded](./expanded.md) - 在 Flex 布局中扩展填充
- [Spacer](./spacer.md) - Flex 布局中的弹性间距

## 官方文档

- [SizedBox API 文档](https://api.flutter.dev/flutter/widgets/SizedBox-class.html)
- [Flutter 布局教程](https://docs.flutter.dev/ui/layout)
