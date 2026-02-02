# Expanded

`Expanded` 是 Flutter 中用于在 Flex 布局（`Row`、`Column`、`Flex`）中扩展子组件的组件。它会强制子组件填充 Flex 布局中的剩余可用空间，是实现灵活布局的核心工具之一。

## 组件介绍

`Expanded` 继承自 `Flexible`，本质上是 `Flexible` 的一个特例，其 `fit` 属性固定为 `FlexFit.tight`。这意味着子组件**必须**填满分配给它的所有空间。

### 工作原理

1. Flex 布局首先放置所有非弹性子组件（没有被 `Expanded` 或 `Flexible` 包裹的组件）
2. 计算剩余可用空间
3. 根据 `flex` 因子按比例分配剩余空间给所有 `Expanded` 和 `Flexible` 子组件
4. `Expanded` 的子组件会被强制拉伸以填满分配的空间

## 基本用法

```dart
Row(
  children: [
    Container(width: 100, color: Colors.red),
    Expanded(
      child: Container(color: Colors.blue),  // 填充剩余空间
    ),
    Container(width: 100, color: Colors.green),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `flex` | `int` | `1` | 弹性因子，决定子组件占用剩余空间的比例 |
| `child` | `Widget` | 必需 | 要扩展的子组件 |

### flex 属性详解

`flex` 属性用于指定该组件在剩余空间中所占的比例：

```dart
Row(
  children: [
    Expanded(
      flex: 2,  // 占 2 份
      child: Container(color: Colors.red),
    ),
    Expanded(
      flex: 1,  // 占 1 份
      child: Container(color: Colors.blue),
    ),
  ],
)
// 红色区域宽度是蓝色区域的 2 倍
```

## 使用场景

### 1. 等分空间

多个子组件平均分配可用空间：

```dart
Row(
  children: [
    Expanded(
      child: Container(
        height: 100,
        color: Colors.red,
        child: Center(child: Text('1/3')),
      ),
    ),
    Expanded(
      child: Container(
        height: 100,
        color: Colors.green,
        child: Center(child: Text('1/3')),
      ),
    ),
    Expanded(
      child: Container(
        height: 100,
        color: Colors.blue,
        child: Center(child: Text('1/3')),
      ),
    ),
  ],
)
```

### 2. 按比例分配空间

使用不同的 `flex` 值实现自定义比例：

```dart
Column(
  children: [
    Expanded(
      flex: 3,
      child: Container(
        color: Colors.amber,
        child: Center(child: Text('头部 - 30%')),
      ),
    ),
    Expanded(
      flex: 5,
      child: Container(
        color: Colors.lightBlue,
        child: Center(child: Text('内容 - 50%')),
      ),
    ),
    Expanded(
      flex: 2,
      child: Container(
        color: Colors.lightGreen,
        child: Center(child: Text('底部 - 20%')),
      ),
    ),
  ],
)
```

### 3. 填充剩余空间

固定部分元素，其余空间由 `Expanded` 填充：

```dart
Row(
  children: [
    // 固定宽度的头像
    CircleAvatar(
      radius: 25,
      backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
    ),
    SizedBox(width: 12),
    // 填充剩余空间的文本区域
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '用户名称',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '这是一段很长的描述文字，会自动换行或截断...',
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
    // 固定宽度的操作按钮
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)
```

### 4. 搜索栏布局

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(
    children: [
      Icon(Icons.search, color: Colors.grey),
      SizedBox(width: 8),
      Expanded(
        child: TextField(
          decoration: InputDecoration(
            hintText: '搜索...',
            border: InputBorder.none,
          ),
        ),
      ),
      IconButton(
        icon: Icon(Icons.mic),
        onPressed: () {},
      ),
    ],
  ),
)
```

### 5. 底部导航按钮

```dart
Row(
  children: [
    Expanded(
      child: TextButton(
        onPressed: () {},
        child: Text('取消'),
      ),
    ),
    Container(width: 1, height: 40, color: Colors.grey[300]),
    Expanded(
      child: TextButton(
        onPressed: () {},
        child: Text('确定'),
      ),
    ),
  ],
)
```

## 与 Flexible 对比

`Expanded` 和 `Flexible` 的主要区别在于 `fit` 属性：

| 特性 | Expanded | Flexible |
|------|----------|----------|
| fit 属性 | 固定为 `FlexFit.tight` | 默认为 `FlexFit.loose` |
| 子组件尺寸 | **必须**填满分配的空间 | **最多**可以占用分配的空间 |
| 使用场景 | 需要子组件完全填充空间 | 子组件保持自身尺寸，但不超过分配空间 |

### 对比示例

```dart
// Expanded: 子组件被强制拉伸
Row(
  children: [
    Expanded(
      child: Container(
        color: Colors.red,
        child: Text('Expanded'),  // Container 填满空间
      ),
    ),
  ],
)

// Flexible: 子组件保持自身尺寸
Row(
  children: [
    Flexible(
      child: Container(
        color: Colors.blue,
        child: Text('Flexible'),  // Container 只包裹文本
      ),
    ),
  ],
)
```

### 实际对比效果

```dart
Column(
  children: [
    // 使用 Expanded
    Container(
      height: 60,
      color: Colors.grey[200],
      child: Row(
        children: [
          Container(width: 50, color: Colors.red),
          Expanded(
            child: Container(
              color: Colors.blue,
              child: Text('Expanded - 填满剩余空间'),
            ),
          ),
        ],
      ),
    ),
    SizedBox(height: 20),
    // 使用 Flexible
    Container(
      height: 60,
      color: Colors.grey[200],
      child: Row(
        children: [
          Container(width: 50, color: Colors.red),
          Flexible(
            child: Container(
              color: Colors.green,
              child: Text('Flexible - 保持自身大小'),
            ),
          ),
        ],
      ),
    ),
  ],
)
```

### 何时选择

- **使用 Expanded**：当你希望子组件**完全填充**可用空间时
- **使用 Flexible**：当你希望子组件**保持自身尺寸**但在空间不足时可以收缩时

## 常见错误和解决方案

### 错误 1: 在非 Flex 布局中使用

```dart
// ❌ 错误：在 Container 中直接使用 Expanded
Container(
  child: Expanded(  // 报错！
    child: Text('Hello'),
  ),
)

// ✅ 正确：在 Row/Column/Flex 中使用
Container(
  child: Row(
    children: [
      Expanded(
        child: Text('Hello'),
      ),
    ],
  ),
)
```

**错误信息**：
```
Incorrect use of ParentDataWidget.
Expanded widgets must be placed inside Flex widgets.
```

### 错误 2: 嵌套 Expanded

```dart
// ❌ 错误：嵌套的 Expanded
Row(
  children: [
    Expanded(
      child: Expanded(  // 报错！
        child: Text('Hello'),
      ),
    ),
  ],
)

// ✅ 正确：只使用一层 Expanded
Row(
  children: [
    Expanded(
      child: Text('Hello'),
    ),
  ],
)
```

### 错误 3: 在 ListView/SingleChildScrollView 中使用

```dart
// ❌ 错误：在滚动视图的 Column 中使用 Expanded
SingleChildScrollView(
  child: Column(
    children: [
      Expanded(  // 报错！Column 在滚动视图中没有固定高度
        child: Container(),
      ),
    ],
  ),
)

// ✅ 解决方案 1：给 Container 指定固定高度
SingleChildScrollView(
  child: Column(
    children: [
      Container(
        height: 200,
        child: Text('固定高度'),
      ),
    ],
  ),
)

// ✅ 解决方案 2：使用 SizedBox.expand 配合约束
ConstrainedBox(
  constraints: BoxConstraints(
    minHeight: MediaQuery.of(context).size.height,
  ),
  child: Column(
    children: [
      Expanded(
        child: Container(),
      ),
    ],
  ),
)
```

### 错误 4: Row 在无约束宽度的环境中

```dart
// ❌ 错误：Row 在无约束的环境中使用 Expanded
ListView(
  children: [
    Row(
      children: [
        Expanded(  // 可能报错，因为 Row 被包在 ListView 中
          child: Text('Hello'),
        ),
      ],
    ),
  ],
)

// ✅ 正确：Row 通常可以正常工作，但 Column 中的 Expanded 需要约束
```

### 错误 5: flex 值为 0 或负数

```dart
// ❌ 错误：flex 不能为 0 或负数
Expanded(
  flex: 0,  // 报错！
  child: Container(),
)

// ✅ 正确：flex 必须是正整数
Expanded(
  flex: 1,
  child: Container(),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class ExpandedDemo extends StatelessWidget {
  const ExpandedDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expanded 示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例 1: 等分空间
            const Text('1. 等分空间', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.red[300],
                      child: const Center(child: Text('1')),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.green[300],
                      child: const Center(child: Text('2')),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.blue[300],
                      child: const Center(child: Text('3')),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 示例 2: 按比例分配
            const Text('2. 按比例分配 (1:2:1)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.orange[300],
                      child: const Center(child: Text('1')),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.purple[300],
                      child: const Center(child: Text('2')),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.teal[300],
                      child: const Center(child: Text('1')),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 示例 3: 填充剩余空间
            const Text('3. 填充剩余空间', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('用户名', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('这是一段很长的描述...', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 示例 4: Expanded vs Flexible 对比
            const Text('4. Expanded vs Flexible', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 50,
              color: Colors.grey[200],
              child: Row(
                children: [
                  Container(width: 50, color: Colors.red, child: const Center(child: Text('固定'))),
                  Expanded(
                    child: Container(
                      color: Colors.blue[200],
                      child: const Center(child: Text('Expanded')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              color: Colors.grey[200],
              child: Row(
                children: [
                  Container(width: 50, color: Colors.red, child: const Center(child: Text('固定'))),
                  Flexible(
                    child: Container(
                      color: Colors.green[200],
                      child: const Text('Flexible'),
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

## 最佳实践

### 1. 优先使用 Expanded 而非固定尺寸

```dart
// ❌ 不推荐：使用固定宽度
Row(
  children: [
    Container(width: 200, child: Text('内容')),  // 可能溢出
  ],
)

// ✅ 推荐：使用 Expanded 自适应
Row(
  children: [
    Expanded(child: Text('内容')),  // 自动适应屏幕
  ],
)
```

### 2. 合理使用 flex 比例

```dart
// 使用易于理解的比例
Row(
  children: [
    Expanded(flex: 1, child: sidebar),    // 侧边栏 25%
    Expanded(flex: 3, child: content),    // 内容区 75%
  ],
)
```

### 3. 配合 CrossAxisAlignment 使用

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,  // 垂直方向也拉伸
  children: [
    Expanded(
      child: Container(color: Colors.red),  // 高度也会填满
    ),
  ],
)
```

### 4. 处理文本溢出

```dart
Row(
  children: [
    Expanded(
      child: Text(
        '很长的文本内容...',
        overflow: TextOverflow.ellipsis,  // 防止溢出
        maxLines: 1,
      ),
    ),
  ],
)
```

### 5. 嵌套 Flex 布局时注意约束传递

```dart
Row(
  children: [
    Expanded(
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.red)),   // 正确：Column 有约束
          Expanded(child: Container(color: Colors.blue)),
        ],
      ),
    ),
  ],
)
```

## 相关组件

- [Flexible](./flexible.md) - 更灵活的弹性布局组件
- [Row](./row.md) - 水平方向的 Flex 布局
- [Column](./column.md) - 垂直方向的 Flex 布局
- [Spacer](./spacer.md) - 创建空白的 Expanded
- [SizedBox](./sizedbox.md) - 固定尺寸的盒子

## 官方文档

- [Expanded API](https://api.flutter.dev/flutter/widgets/Expanded-class.html)
- [Flexible API](https://api.flutter.dev/flutter/widgets/Flexible-class.html)
- [Flutter 布局教程](https://docs.flutter.dev/development/ui/layout)
