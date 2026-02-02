# Wrap

`Wrap` 是 Flutter 中用于自动换行布局的组件。当子组件在主轴方向上空间不足时，会自动换行到下一行（或列）继续排列，非常适合标签、筛选条件等场景。

## 基本用法

```dart
Wrap(
  spacing: 8.0,  // 主轴方向间距
  runSpacing: 4.0,  // 交叉轴方向间距
  children: [
    Chip(label: Text('标签1')),
    Chip(label: Text('标签2')),
    Chip(label: Text('标签3')),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| direction | Axis | Axis.horizontal | 主轴方向 |
| alignment | WrapAlignment | start | 主轴对齐方式 |
| spacing | double | 0.0 | 主轴方向子组件间距 |
| runAlignment | WrapAlignment | start | 交叉轴对齐方式 |
| runSpacing | double | 0.0 | 行/列之间的间距 |
| crossAxisAlignment | WrapCrossAlignment | start | 行内交叉轴对齐 |
| textDirection | TextDirection? | null | 文本方向 |
| verticalDirection | VerticalDirection | down | 垂直方向 |
| clipBehavior | Clip | Clip.none | 裁剪行为 |

## WrapAlignment 对齐选项

| 值 | 说明 |
|-----|------|
| start | 起始对齐 |
| end | 末尾对齐 |
| center | 居中对齐 |
| spaceBetween | 两端对齐，中间均分 |
| spaceAround | 子组件两侧间距相等 |
| spaceEvenly | 所有间距相等 |

## 使用场景

### 1. 标签列表

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    '美食', '旅游', '科技', '娱乐', '体育', '财经',
  ].map((tag) => Chip(
    label: Text(tag),
    deleteIcon: Icon(Icons.close, size: 18),
    onDeleted: () {},
  )).toList(),
)
```

### 2. 筛选条件（可选中）

```dart
class FilterDemo extends StatefulWidget {
  @override
  State<FilterDemo> createState() => _FilterDemoState();
}

class _FilterDemoState extends State<FilterDemo> {
  final Set<String> _selected = {};
  final List<String> options = ['全部', '待付款', '待发货', '待收货', '已完成'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((option) => FilterChip(
        label: Text(option),
        selected: _selected.contains(option),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selected.add(option);
            } else {
              _selected.remove(option);
            }
          });
        },
      )).toList(),
    );
  }
}
```

### 3. 图片网格（自适应换行）

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: List.generate(9, (index) => Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      image: DecorationImage(
        image: NetworkImage('https://picsum.photos/100?random=$index'),
        fit: BoxFit.cover,
      ),
    ),
  )),
)
```

### 4. 商品规格选择

```dart
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: ['S', 'M', 'L', 'XL', 'XXL'].map((size) => ChoiceChip(
    label: Text(size),
    selected: selectedSize == size,
    onSelected: (selected) {
      setState(() => selectedSize = size);
    },
  )).toList(),
)
```

### 5. 垂直方向换行

```dart
Container(
  height: 200,
  child: Wrap(
    direction: Axis.vertical,
    spacing: 8,
    runSpacing: 8,
    children: List.generate(10, (i) => Chip(label: Text('标签 $i'))),
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class WrapDemo extends StatefulWidget {
  @override
  State<WrapDemo> createState() => _WrapDemoState();
}

class _WrapDemoState extends State<WrapDemo> {
  WrapAlignment _alignment = WrapAlignment.start;
  double _spacing = 8;
  double _runSpacing = 8;

  final List<String> tags = [
    'Flutter', 'Dart', 'Android', 'iOS', 'Web',
    'Desktop', 'Mobile', 'UI', 'Widget', 'Layout',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wrap 示例')),
      body: Column(
        children: [
          // 控制面板
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('对齐方式:'),
                    SizedBox(width: 16),
                    DropdownButton<WrapAlignment>(
                      value: _alignment,
                      items: WrapAlignment.values.map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.name),
                      )).toList(),
                      onChanged: (v) => setState(() => _alignment = v!),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('间距: ${_spacing.toInt()}'),
                    Expanded(
                      child: Slider(
                        value: _spacing,
                        min: 0,
                        max: 32,
                        onChanged: (v) => setState(() => _spacing = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(),
          
          // Wrap 演示
          Expanded(
            child: Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(16),
              child: Wrap(
                alignment: _alignment,
                spacing: _spacing,
                runSpacing: _runSpacing,
                children: tags.map((tag) => Chip(
                  label: Text(tag),
                  avatar: CircleAvatar(child: Text(tag[0])),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Wrap vs Row/Column

| 特性 | Wrap | Row/Column |
|------|------|------------|
| 换行支持 | ✅ 自动换行 | ❌ 不换行会溢出 |
| 滚动 | ❌ 不支持 | 需配合 SingleChildScrollView |
| 性能 | 子组件较多时较好 | 固定子组件数量时更好 |
| 适用场景 | 动态数量、标签 | 固定布局 |

## 最佳实践

1. **合理设置间距**：spacing 和 runSpacing 保持视觉协调
2. **避免过多子组件**：大量子组件考虑使用 ListView + Wrap 组合
3. **响应式布局**：配合 LayoutBuilder 根据宽度调整
4. **使用 Chip 组件**：Wrap 与各种 Chip 配合最佳
5. **考虑可访问性**：确保子组件有足够的点击区域

## 相关组件

- [Row](./row.md) - 水平布局（不换行）
- [Column](./column.md) - 垂直布局（不换行）
- [Flow](./flow.md) - 自定义流式布局
- [Chip](../material/chip.md) - 常用于 Wrap 的子组件

## 官方文档

- [Wrap API](https://api.flutter-io.cn/flutter/widgets/Wrap-class.html)
- [WrapAlignment](https://api.flutter-io.cn/flutter/rendering/WrapAlignment.html)
