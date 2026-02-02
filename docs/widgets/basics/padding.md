# Padding

<script setup>
import DartPad from '../../.vitepress/components/DartPad.vue'
</script>

<Badge type="info" text="widgets" />
<Badge type="tip" text="基础组件" />

## 简介

`Padding` 是 Flutter 中用于在子组件周围添加空白区域的基础布局组件。它是最简单、最常用的间距控制组件之一，用于在子 Widget 的四周添加指定的内边距。

与 CSS 中的 `padding` 属性类似，`Padding` 组件允许你精确控制内容与其边界之间的距离。它只接受一个子组件，并通过 `padding` 属性定义边距大小。

::: tip 提示
如果你只需要添加空白间距而不需要其他装饰效果，使用 `Padding` 比 `Container` 更加轻量和高效。
:::

## 构造函数

```dart
const Padding({
  Key? key,
  required EdgeInsetsGeometry padding,
  Widget? child,
})
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `padding` | `EdgeInsetsGeometry` | **必填** | 内边距，定义子组件与 Padding 边界之间的空白区域 |
| `child` | `Widget?` | `null` | 子组件，被添加内边距的目标组件 |

### EdgeInsets 常用构造方法

| 构造方法 | 说明 | 示例 |
|----------|------|------|
| `EdgeInsets.all(double value)` | 四边相同的边距 | `EdgeInsets.all(16.0)` |
| `EdgeInsets.symmetric({vertical, horizontal})` | 对称边距 | `EdgeInsets.symmetric(vertical: 8, horizontal: 16)` |
| `EdgeInsets.only({left, top, right, bottom})` | 单独指定各边 | `EdgeInsets.only(left: 10, top: 20)` |
| `EdgeInsets.fromLTRB(left, top, right, bottom)` | 按顺序指定四边 | `EdgeInsets.fromLTRB(10, 20, 10, 20)` |
| `EdgeInsets.zero` | 零边距 | `EdgeInsets.zero` |

## 代码示例

### 基础用法 - EdgeInsets.all

使用 `EdgeInsets.all()` 为四个方向设置相同的边距：

```dart
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Container(
    color: Colors.blue,
    child: const Text(
      'Hello Padding',
      style: TextStyle(color: Colors.white, fontSize: 18),
    ),
  ),
)
```

### 对称边距 - EdgeInsets.symmetric

使用 `EdgeInsets.symmetric()` 分别设置水平和垂直方向的边距：

```dart
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 24.0,  // 左右各 24
    vertical: 12.0,    // 上下各 12
  ),
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('Symmetric Padding'),
  ),
)
```

### 单边边距 - EdgeInsets.only

使用 `EdgeInsets.only()` 仅为特定方向设置边距：

```dart
Padding(
  padding: const EdgeInsets.only(
    left: 20.0,
    top: 10.0,
    // right 和 bottom 默认为 0
  ),
  child: const Text('只有左边和顶部有边距'),
)
```

### 精确控制 - EdgeInsets.fromLTRB

使用 `EdgeInsets.fromLTRB()` 按 左-上-右-下 的顺序精确控制每边的边距：

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(10.0, 20.0, 30.0, 40.0),
  child: Container(
    color: Colors.green,
    child: const Text(
      'LTRB: 左10 上20 右30 下40',
      style: TextStyle(color: Colors.white),
    ),
  ),
)
```

### 响应式边距

结合 `MediaQuery` 实现响应式边距：

```dart
Padding(
  padding: EdgeInsets.all(
    MediaQuery.of(context).size.width * 0.05, // 屏幕宽度的 5%
  ),
  child: const Card(
    child: ListTile(
      title: Text('响应式边距'),
      subtitle: Text('边距随屏幕宽度自适应'),
    ),
  ),
)
```

### 嵌套 Padding

多层嵌套实现复杂的间距效果：

```dart
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Container(
    color: Colors.grey[300],
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.blue,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '多层嵌套',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  ),
)
```

## 完整示例

下面是一个展示各种 `Padding` 用法的完整示例：

<DartPad id="padding_demo" />

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
      home: const PaddingDemo(),
    );
  }
}

class PaddingDemo extends StatelessWidget {
  const PaddingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Padding 组件示例'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // EdgeInsets.all 示例
            _buildSection(
              'EdgeInsets.all(16.0)',
              Container(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    color: Colors.blue,
                    height: 60,
                    child: const Center(
                      child: Text(
                        '四边相等边距',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // EdgeInsets.symmetric 示例
            _buildSection(
              'EdgeInsets.symmetric(h: 32, v: 8)',
              Container(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    color: Colors.green,
                    height: 60,
                    child: const Center(
                      child: Text(
                        '水平32 垂直8',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // EdgeInsets.only 示例
            _buildSection(
              'EdgeInsets.only(left: 40, top: 20)',
              Container(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 40.0,
                    top: 20.0,
                  ),
                  child: Container(
                    color: Colors.orange,
                    height: 60,
                    child: const Center(
                      child: Text(
                        '仅左边和顶部',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // EdgeInsets.fromLTRB 示例
            _buildSection(
              'EdgeInsets.fromLTRB(10, 20, 30, 40)',
              Container(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 30, 40),
                  child: Container(
                    color: Colors.purple,
                    height: 60,
                    child: const Center(
                      child: Text(
                        '左10 上20 右30 下40',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 实际应用：卡片列表
            _buildSection(
              '实际应用：卡片内边距',
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '卡片标题',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '这是卡片内容，使用 Padding 组件来控制内边距，让内容与卡片边缘保持适当的距离。',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('取消'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
```

## 最佳实践

### 1. 使用 const 构造函数

当边距值是固定的时，始终使用 `const` 关键字以提高性能：

```dart
// ✅ 推荐
const Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
)

// ❌ 避免（没有使用 const）
Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
)
```

### 2. 统一管理间距值

在项目中定义统一的间距常量，保持设计一致性：

```dart
// 定义间距常量
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

// 使用
Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: child,
)
```

### 3. Padding vs Container

- 仅需要添加内边距时，使用 `Padding`（更轻量）
- 需要背景色、边框、阴影等装饰时，使用 `Container`

```dart
// ✅ 仅需要边距时使用 Padding
const Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Simple padding'),
)

// ✅ 需要装饰时使用 Container
Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text('With decoration'),
)
```

### 4. 避免过度嵌套

过多的 Padding 嵌套会增加 Widget 树的复杂度，尽量合并或使用 `Container`：

```dart
// ❌ 避免过度嵌套
Padding(
  padding: const EdgeInsets.all(8.0),
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: child,
  ),
)

// ✅ 合并边距
Padding(
  padding: const EdgeInsets.all(16.0),
  child: child,
)
```

### 5. 列表项使用 ListView.separated

在列表中添加间距时，优先使用 `ListView.separated` 而不是在每个项目中添加 Padding：

```dart
// ✅ 推荐
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => const SizedBox(height: 8),
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

## 相关组件

- [Container](./container.md) - 多功能容器，包含 padding 属性
- [SizedBox](./sizedbox.md) - 固定尺寸的盒子，常用于添加固定间距
- [Spacer](./spacer.md) - 弹性空白，用于 Flex 布局中
- [Center](./center.md) - 居中组件
- [Expanded](./expanded.md) - 扩展组件，用于 Flex 布局

## 官方文档

- [Padding Class - Flutter API](https://api.flutter.dev/flutter/widgets/Padding-class.html)
- [EdgeInsets Class - Flutter API](https://api.flutter.dev/flutter/painting/EdgeInsets-class.html)
- [EdgeInsetsGeometry Class - Flutter API](https://api.flutter.dev/flutter/painting/EdgeInsetsGeometry-class.html)

