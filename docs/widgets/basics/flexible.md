# Flexible

`Flexible` 是 Flutter 中用于弹性布局的核心组件，它允许子组件在 `Row`、`Column` 或 `Flex` 布局中按比例分配剩余空间。与 `Expanded` 不同的是，`Flexible` 提供了更灵活的空间占用策略，子组件可以选择占用全部分配空间或仅占用所需空间。

## 组件介绍

`Flexible` 组件是 `Expanded` 的父类，它控制 `Row`、`Column` 或 `Flex` 的子组件如何弹性地填充主轴上的可用空间。通过 `flex` 属性设置弹性因子，通过 `fit` 属性控制子组件如何适应分配到的空间。

### 工作原理

1. **空间分配**：父组件（如 `Row`）首先为非弹性子组件分配空间
2. **剩余空间计算**：计算剩余的可用空间
3. **比例分配**：根据各个 `Flexible` 子组件的 `flex` 值按比例分配剩余空间
4. **约束传递**：根据 `fit` 属性决定传递给子组件的约束条件

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `flex` | `int` | `1` | 弹性因子，决定子组件占用剩余空间的比例。值越大，分配的空间越多 |
| `fit` | `FlexFit` | `FlexFit.loose` | 决定子组件如何适应分配到的空间 |
| `child` | `Widget` | 必需 | 子组件，将被约束在分配的空间内 |

## FlexFit.tight vs FlexFit.loose 详解

`FlexFit` 枚举定义了子组件如何填充分配到的空间：

### FlexFit.tight（紧凑填充）

- 子组件**必须**填满分配到的全部空间
- 传递给子组件的约束是**紧约束**（min = max = 分配的空间）
- `Expanded` 组件实际上就是 `fit` 设为 `FlexFit.tight` 的 `Flexible`

```dart
// FlexFit.tight 示例
Row(
  children: [
    Flexible(
      flex: 1,
      fit: FlexFit.tight, // 强制填满分配空间
      child: Container(
        color: Colors.blue,
        child: Text('我会填满整个分配空间'),
      ),
    ),
  ],
)
```

### FlexFit.loose（宽松填充）

- 子组件**可以**小于分配到的空间
- 传递给子组件的约束是**松约束**（min = 0, max = 分配的空间）
- 子组件会根据自身内容决定实际大小，但不会超过分配的空间

```dart
// FlexFit.loose 示例
Row(
  children: [
    Flexible(
      flex: 1,
      fit: FlexFit.loose, // 默认值，允许子组件小于分配空间
      child: Container(
        color: Colors.green,
        child: Text('我只占用需要的空间'),
      ),
    ),
  ],
)
```

### 可视化对比

```dart
class FlexFitComparisonDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FlexFit 对比')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FlexFit.tight:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 50,
              color: Colors.grey[200],
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      color: Colors.blue,
                      child: Center(child: Text('Tight', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  Container(width: 100, color: Colors.orange),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('FlexFit.loose:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 50,
              color: Colors.grey[200],
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Container(
                      color: Colors.green,
                      child: Text('Loose - 只占用文本宽度'),
                    ),
                  ),
                  Container(width: 100, color: Colors.orange),
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

## 使用场景代码示例

### 示例1：按比例分配空间

```dart
class FlexRatioDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flexible 比例分配')),
      body: Column(
        children: [
          // 水平方向 1:2:1 比例分配
          Container(
            height: 100,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(color: Colors.red, child: Center(child: Text('1'))),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Container(color: Colors.green, child: Center(child: Text('2'))),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(color: Colors.blue, child: Center(child: Text('1'))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 示例2：防止文本溢出

```dart
class TextOverflowDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('防止文本溢出')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.person, size: 40),
            SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '这是一个很长很长的用户名，可能会超出屏幕宽度',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '这是一段很长的描述文字，使用 Flexible 可以防止溢出',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

### 示例3：混合固定与弹性布局

```dart
class MixedLayoutDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('混合布局')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 搜索栏：固定图标 + 弹性输入框 + 固定按钮
            Container(
              height: 50,
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('搜索'),
                  ),
                ],
              ),
            ),
            Divider(),
            // 价格标签：弹性标题 + 固定价格
            Row(
              children: [
                Flexible(
                  child: Text(
                    '商品名称可能很长很长很长很长',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '¥99.00',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 示例4：响应式卡片布局

```dart
class ResponsiveCardDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('响应式卡片')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // 左侧卡片占 2 份
            Flexible(
              flex: 2,
              child: Card(
                color: Colors.blue[100],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 48, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('主要内容', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            // 右侧卡片占 1 份
            Flexible(
              flex: 1,
              child: Card(
                color: Colors.green[100],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info, size: 32, color: Colors.green),
                      SizedBox(height: 8),
                      Text('次要', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Flexible 与 Expanded 对比

| 特性 | Flexible | Expanded |
|------|----------|----------|
| **默认 fit 值** | `FlexFit.loose` | `FlexFit.tight` |
| **空间占用** | 可以小于分配空间 | 必须填满分配空间 |
| **子组件约束** | 松约束（min=0） | 紧约束（min=max） |
| **适用场景** | 防止溢出、保持原有大小 | 填充剩余空间 |
| **继承关系** | 父类 | 继承自 Flexible |

### 代码等价关系

```dart
// 以下两种写法完全等价
Expanded(
  flex: 1,
  child: Container(),
)

Flexible(
  flex: 1,
  fit: FlexFit.tight,
  child: Container(),
)
```

### 实际对比示例

```dart
class FlexibleVsExpandedDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flexible vs Expanded')),
      body: Column(
        children: [
          // 使用 Expanded
          Text('使用 Expanded:', style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            height: 60,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all()),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.blue,
                    child: Text('Expanded', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          // 使用 Flexible (loose)
          Text('使用 Flexible (loose):', style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            height: 60,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all()),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    color: Colors.green,
                    child: Text('Flexible', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 最佳实践

### 1. 根据需求选择合适的 fit

```dart
// ✅ 需要填满空间时使用 tight 或 Expanded
Row(
  children: [
    Flexible(
      fit: FlexFit.tight, // 或直接使用 Expanded
      child: Container(color: Colors.blue),
    ),
  ],
)

// ✅ 只需防止溢出时使用默认的 loose
Row(
  children: [
    Flexible(
      child: Text('很长的文本内容...'),
    ),
  ],
)
```

### 2. 正确处理嵌套布局

```dart
// ✅ 在嵌套的 Row/Column 中合理使用 Flexible
Column(
  children: [
    Flexible(
      child: Row(
        children: [
          Flexible(child: Text('文本1')),
          Flexible(child: Text('文本2')),
        ],
      ),
    ),
  ],
)
```

### 3. 避免无意义的 Flexible

```dart
// ❌ 错误：Flexible 必须是 Row/Column/Flex 的直接子组件
Container(
  child: Flexible( // 这里会报错！
    child: Text('文本'),
  ),
)

// ✅ 正确用法
Row(
  children: [
    Flexible(
      child: Text('文本'),
    ),
  ],
)
```

### 4. 合理设置 flex 比例

```dart
// ✅ 使用简单整数比例，易于理解
Row(
  children: [
    Flexible(flex: 1, child: WidgetA()), // 25%
    Flexible(flex: 2, child: WidgetB()), // 50%
    Flexible(flex: 1, child: WidgetC()), // 25%
  ],
)

// ❌ 避免过于复杂的比例
Row(
  children: [
    Flexible(flex: 37, child: WidgetA()),
    Flexible(flex: 63, child: WidgetB()),
  ],
)
```

### 5. 配合 overflow 处理文本

```dart
// ✅ Flexible + TextOverflow 组合使用
Row(
  children: [
    Flexible(
      child: Text(
        '这是一段可能很长的文本',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
    Icon(Icons.arrow_forward),
  ],
)
```

## 常见问题

### Q: Flexible 和 Expanded 应该用哪个？

- 如果希望子组件**填满**分配的空间，使用 `Expanded`
- 如果希望子组件**最多**占用分配的空间但可以更小，使用 `Flexible`

### Q: 为什么 Flexible 放在 Container 里会报错？

`Flexible` 只能作为 `Row`、`Column` 或 `Flex` 的直接子组件使用，因为它依赖于这些父组件来计算和分配空间。

### Q: 多个 Flexible 的 flex 值相同时如何分配？

会平均分配剩余空间。例如，三个 `flex: 1` 的组件会各占剩余空间的 1/3。

## 相关组件

- [Expanded](./expanded.md) - 强制填满剩余空间的弹性组件
- [Row](./row.md) - 水平布局组件
- [Column](./column.md) - 垂直布局组件
- [Spacer](./spacer.md) - 弹性空白组件
- [Flex](https://api.flutter.dev/flutter/widgets/Flex-class.html) - Row 和 Column 的基类

## 官方文档

- [Flexible API 文档](https://api.flutter.dev/flutter/widgets/Flexible-class.html)
- [FlexFit 枚举](https://api.flutter.dev/flutter/rendering/FlexFit.html)
- [Flutter 布局教程](https://docs.flutter.dev/ui/layout)
