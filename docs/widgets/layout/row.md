# Row

`Row` 是 Flutter 中用于**水平排列**子组件的布局组件。它将子组件从左到右依次排列，是最常用的 Flex 布局之一。

## 基本用法

```dart
Row(
  children: [
    Icon(Icons.star),
    Text('评分'),
    Text('4.5'),
  ],
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `children` | `List&lt;Widget&gt;` | 子组件列表 |
| `mainAxisAlignment` | `MainAxisAlignment` | 主轴（水平）对齐方式 |
| `crossAxisAlignment` | `CrossAxisAlignment` | 交叉轴（垂直）对齐方式 |
| `mainAxisSize` | `MainAxisSize` | 主轴尺寸策略 |
| `textDirection` | `TextDirection?` | 文本方向（影响排列顺序） |
| `verticalDirection` | `VerticalDirection` | 垂直方向 |
| `textBaseline` | `TextBaseline?` | 文本基线对齐 |

## MainAxisAlignment 主轴对齐

| 值 | 说明 |
|----|------|
| `start` | 左对齐（默认） |
| `end` | 右对齐 |
| `center` | 居中 |
| `spaceBetween` | 两端对齐，子组件间等距 |
| `spaceAround` | 每个子组件左右等距 |
| `spaceEvenly` | 所有间距完全相等 |

## CrossAxisAlignment 交叉轴对齐

| 值 | 说明 |
|----|------|
| `start` | 顶部对齐 |
| `end` | 底部对齐 |
| `center` | 垂直居中（默认） |
| `stretch` | 拉伸填满 |
| `baseline` | 文本基线对齐 |

## MainAxisSize 主轴尺寸

| 值 | 说明 |
|----|------|
| `max` | 尽可能占满可用空间（默认） |
| `min` | 仅包裹子组件所需空间 |

## 使用场景

### 1. 主轴对齐方式

```dart
// spaceBetween - 两端对齐
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('左侧'),
    Text('右侧'),
  ],
)

// spaceEvenly - 均匀分布
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Icon(Icons.home),
    Icon(Icons.search),
    Icon(Icons.person),
  ],
)

// center - 居中
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.favorite, color: Colors.red),
    SizedBox(width: 8),
    Text('喜欢'),
  ],
)
```

### 2. 交叉轴对齐

```dart
Container(
  height: 100,
  color: Colors.grey[200],
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start, // 顶部对齐
    children: [
      Container(width: 50, height: 50, color: Colors.red),
      Container(width: 50, height: 80, color: Colors.green),
      Container(width: 50, height: 30, color: Colors.blue),
    ],
  ),
)

// stretch - 拉伸
Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Container(width: 50, color: Colors.red),  // 高度自动填满
    Container(width: 50, color: Colors.green),
    Container(width: 50, color: Colors.blue),
  ],
)
```

### 3. 文本基线对齐

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Text('大字', style: TextStyle(fontSize: 32)),
    Text('小字', style: TextStyle(fontSize: 14)),
    Text('中字', style: TextStyle(fontSize: 20)),
  ],
)
```

### 4. 使用 Expanded/Flexible 分配空间

```dart
// 均分空间
Row(
  children: [
    Expanded(
      child: Container(height: 50, color: Colors.red),
    ),
    Expanded(
      child: Container(height: 50, color: Colors.green),
    ),
    Expanded(
      child: Container(height: 50, color: Colors.blue),
    ),
  ],
)

// 按比例分配
Row(
  children: [
    Expanded(
      flex: 2,
      child: Container(height: 50, color: Colors.red),
    ),
    Expanded(
      flex: 1,
      child: Container(height: 50, color: Colors.green),
    ),
  ],
)

// 固定 + 弹性
Row(
  children: [
    Container(width: 100, height: 50, color: Colors.red), // 固定宽度
    Expanded(
      child: Container(height: 50, color: Colors.green), // 占据剩余空间
    ),
  ],
)
```

### 5. 常见布局模式

```dart
// 图标 + 文字 + 箭头（列表项）
Row(
  children: [
    Icon(Icons.person, size: 40),
    SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('用户名', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('user@email.com', style: TextStyle(color: Colors.grey)),
        ],
      ),
    ),
    Icon(Icons.chevron_right),
  ],
)

// 表单项标签 + 输入框
Row(
  children: [
    SizedBox(
      width: 80,
      child: Text('用户名'),
    ),
    Expanded(
      child: TextField(
        decoration: InputDecoration(border: OutlineInputBorder()),
      ),
    ),
  ],
)

// 底部操作栏
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.share),
        Text('分享'),
      ],
    ),
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.favorite_border),
        Text('收藏'),
      ],
    ),
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.comment),
        Text('评论'),
      ],
    ),
  ],
)
```

### 6. 处理溢出

```dart
// 使用 Flexible 避免溢出
Row(
  children: [
    Flexible(
      child: Text(
        '这是一段很长的文本内容，可能会溢出边界',
        overflow: TextOverflow.ellipsis,
      ),
    ),
    Icon(Icons.arrow_forward),
  ],
)

// 使用 SingleChildScrollView 允许滚动
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: List.generate(
      10,
      (index) => Container(
        width: 100,
        height: 100,
        margin: EdgeInsets.all(8),
        color: Colors.primaries[index % Colors.primaries.length],
      ),
    ),
  ),
)
```

### 7. MainAxisSize 对比

```dart
// max - 占满宽度（默认）
Container(
  color: Colors.grey[200],
  child: Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Container(width: 50, height: 50, color: Colors.red),
    ],
  ),
)

// min - 仅包裹内容
Container(
  color: Colors.grey[200],
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 50, height: 50, color: Colors.red),
    ],
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class ToolbarDemo extends StatelessWidget {
  const ToolbarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Row 工具栏示例')),
      body: Column(
        children: [
          // 工具栏按钮行
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolButton(Icons.format_bold, '粗体'),
                _buildToolButton(Icons.format_italic, '斜体'),
                _buildToolButton(Icons.format_underline, '下划线'),
                _buildToolButton(Icons.format_color_text, '颜色'),
                _buildToolButton(Icons.format_align_left, '对齐'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 带 Logo 的标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.flutter_dash, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flutter 教程',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '学习最新的 Flutter 开发技术',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // 底部操作栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('确认提交'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}
```

## Row vs Column 对比

| 特性 | Row | Column |
|------|-----|--------|
| 排列方向 | 水平（从左到右） | 垂直（从上到下） |
| 主轴 | 水平轴 | 垂直轴 |
| 交叉轴 | 垂直轴 | 水平轴 |
| 默认宽度 | 尽可能宽 | 尽可能宽 |
| 默认高度 | 包裹内容 | 尽可能高 |

## 最佳实践

1. **避免溢出**: 使用 `Expanded` 或 `Flexible` 包裹可能溢出的子组件
2. **使用 const**: 对静态 Row 使用 const 提升性能
3. **控制间距**: 使用 `SizedBox` 或 `mainAxisAlignment` 控制子组件间距
4. **基线对齐**: 混合不同字号文本时使用 `CrossAxisAlignment.baseline`
5. **嵌套布局**: Row 和 Column 嵌套实现复杂布局
6. **mainAxisSize.min**: 需要 Row 包裹内容时使用

## 常见问题

::: warning 溢出错误
当子组件总宽度超过可用空间时会出现溢出错误（黄黑斜条纹）。解决方法：
1. 使用 `Expanded` 或 `Flexible` 包裹可弹性子组件
2. 使用 `SingleChildScrollView` 允许水平滚动
3. 减少子组件宽度或数量
:::

## 相关组件

- [Column](./column) - 垂直排列
- [Flex](./flex) - 可配置方向的 Flex 布局
- [Wrap](./wrap) - 自动换行布局
- [Expanded](../basics/expanded) - 弹性扩展
- [Flexible](../basics/flexible) - 弹性适应
- [Spacer](../basics/spacer) - 弹性间距

## 官方文档

- [Row API](https://api.flutter.dev/flutter/widgets/Row-class.html)
- [Flutter 布局指南](https://docs.flutter.cn/ui/layout)
