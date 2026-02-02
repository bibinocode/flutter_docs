# Container

<script setup>
import DartPad from '../../.vitepress/components/DartPad.vue'
</script>

<Badge type="info" text="widgets" />
<Badge type="tip" text="基础组件" />

## 简介

`Container` 是 Flutter 中最常用的布局组件之一，它结合了绑制、定位和尺寸约束等多种功能于一身。你可以把它理解为 HTML 中的 `<div>` 元素。

Container 是一个便捷的"复合"Widget，它内部组合了以下多个 Widget：
- `Padding`
- `DecoratedBox`
- `ConstrainedBox`
- `Transform`
- `Align`

## 构造函数

```dart
Container({
  Key? key,
  AlignmentGeometry? alignment,
  EdgeInsetsGeometry? padding,
  Color? color,
  Decoration? decoration,
  Decoration? foregroundDecoration,
  double? width,
  double? height,
  BoxConstraints? constraints,
  EdgeInsetsGeometry? margin,
  Matrix4? transform,
  AlignmentGeometry? transformAlignment,
  Widget? child,
  Clip clipBehavior = Clip.none,
})
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `alignment` | `AlignmentGeometry?` | 子组件对齐方式 |
| `padding` | `EdgeInsetsGeometry?` | 内边距 |
| `color` | `Color?` | 背景色（与 decoration 互斥） |
| `decoration` | `Decoration?` | 装饰（背景、边框、圆角等） |
| `width` | `double?` | 宽度 |
| `height` | `double?` | 高度 |
| `margin` | `EdgeInsetsGeometry?` | 外边距 |
| `transform` | `Matrix4?` | 变换矩阵 |
| `child` | `Widget?` | 子组件 |
| `constraints` | `BoxConstraints?` | 尺寸约束 |

## 代码示例

### 基础用法

```dart
Container(
  width: 200,
  height: 100,
  color: Colors.blue,
  child: Text('Hello'),
)
```

### 带装饰的容器

```dart
Container(
  width: 200,
  height: 100,
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Center(
    child: Text('Card', style: TextStyle(color: Colors.white)),
  ),
)
```

### 带边框的容器

```dart
Container(
  width: 200,
  height: 100,
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.blue, width: 2),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Center(child: Text('Bordered')),
)
```

### 渐变背景

```dart
Container(
  width: 200,
  height: 100,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Center(
    child: Text('Gradient', style: TextStyle(color: Colors.white)),
  ),
)
```

## 在线演示

下面是一个 Container 的综合示例：

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Container Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 基础容器
              Container(
                width: 150,
                height: 80,
                color: Colors.blue,
                child: const Center(
                  child: Text('基础', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              
              // 圆角容器
              Container(
                width: 150,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('圆角', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              
              // 渐变容器
              Container(
                width: 150,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.pink],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('渐变+阴影', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

::: tip 在线运行
将上述代码复制到 [DartPad](https://dartpad.dev) 在线运行。
:::

## 最佳实践

### ✅ 推荐

```dart
// 使用 const 提升性能
const Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)

// 合理使用 decoration
Container(
  decoration: const BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  ),
)
```

### ❌ 避免

```dart
// 不要同时使用 color 和 decoration.color
Container(
  color: Colors.blue,  // ❌ 会报错
  decoration: BoxDecoration(color: Colors.red),
)

// 避免不必要的 Container 嵌套
Container(  // ❌ 外层 Container 无意义
  child: Container(
    color: Colors.blue,
    child: Text('Hello'),
  ),
)
```

## 注意事项

::: warning color 与 decoration 互斥
`color` 属性和 `decoration` 不能同时使用。如果需要设置背景色并添加其他装饰，请在 `BoxDecoration` 中设置 `color`。

```dart
// ❌ 错误
Container(
  color: Colors.blue,
  decoration: BoxDecoration(...),
)

// ✅ 正确
Container(
  decoration: BoxDecoration(
    color: Colors.blue,
    ...
  ),
)
```
:::

::: tip 性能提示
如果只需要添加 padding、margin 或简单的背景色，考虑使用更轻量的 Widget：
- 只需 padding → 使用 `Padding`
- 只需尺寸约束 → 使用 `SizedBox`
- 只需装饰 → 使用 `DecoratedBox`
:::

## 相关 Widget

- [SizedBox](./sizedbox) - 固定尺寸盒子
- [DecoratedBox](./decoratedbox) - 装饰盒子
- [Padding](../layout/padding) - 内边距
- [ConstrainedBox](../layout/constrainedbox) - 约束盒子

## 官方文档

- [Container class - Flutter API](https://api.flutter.dev/flutter/widgets/Container-class.html)
