# Card

`Card` 是 Material Design 卡片组件，用于展示相关信息的容器，具有圆角和阴影效果。常用于展示列表项、商品信息、用户资料等场景。

## 基本用法

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('卡片内容'),
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| child | Widget? | null | 卡片内容 |
| color | Color? | 主题卡片色 | 背景颜色 |
| shadowColor | Color? | null | 阴影颜色 |
| surfaceTintColor | Color? | null | 表面色调 (M3) |
| elevation | double? | 1.0 | 阴影高度 |
| shape | ShapeBorder? | RoundedRectangleBorder | 形状 |
| borderOnForeground | bool | true | 边框是否在前景 |
| margin | EdgeInsetsGeometry? | EdgeInsets.all(4) | 外边距 |
| clipBehavior | Clip | Clip.none | 裁剪行为 |
| semanticContainer | bool | true | 是否为语义容器 |

## 使用场景

### 1. 基础卡片

```dart
Card(
  elevation: 4,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('卡片标题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('这是卡片的描述内容，可以放置多行文字。'),
      ],
    ),
  ),
)
```

### 2. 图片卡片

```dart
Card(
  clipBehavior: Clip.antiAlias,  // 裁剪图片
  child: Column(
    children: [
      Image.network(
        'https://picsum.photos/400/200',
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('风景照片', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('这是一张美丽的风景照片', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(child: Text('分享'), onPressed: () {}),
                TextButton(child: Text('查看'), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### 3. 可点击卡片

```dart
Card(
  child: InkWell(
    onTap: () {
      print('卡片被点击');
    },
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
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
      ),
    ),
  ),
)
```

### 4. 商品卡片

```dart
Card(
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          Image.network(
            'https://picsum.photos/200',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('热卖', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
      Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品名称', maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4),
            Row(
              children: [
                Text('¥99', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Text('¥199', style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### 5. 自定义形状

```dart
// 圆形卡片
Card(
  shape: CircleBorder(),
  child: SizedBox(
    width: 100,
    height: 100,
    child: Center(child: Icon(Icons.star, size: 40)),
  ),
)

// 斜切角卡片
Card(
  shape: BeveledRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('斜切角卡片'),
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class CardDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card 示例')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 简单卡片
          Card(
            child: ListTile(
              leading: Icon(Icons.album),
              title: Text('音乐专辑'),
              subtitle: Text('艺术家名称'),
              trailing: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {},
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // 带操作的卡片
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage('https://picsum.photos/100'),
                  ),
                  title: Text('文章标题'),
                  subtitle: Text('2024-01-15'),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('这是文章的摘要内容，显示前两行...'),
                ),
                ButtonBar(
                  children: [
                    TextButton(child: Text('喜欢'), onPressed: () {}),
                    TextButton(child: Text('评论'), onPressed: () {}),
                    TextButton(child: Text('分享'), onPressed: () {}),
                  ],
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

## Material 3 卡片变体

```dart
// 填充卡片 (Filled Card)
Card(
  color: Theme.of(context).colorScheme.surfaceVariant,
  elevation: 0,
  child: ...
)

// 轮廓卡片 (Outlined Card)
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: Theme.of(context).colorScheme.outline),
  ),
  child: ...
)
```

## 最佳实践

1. **合适的阴影**：根据层级使用适当的 elevation
2. **圆角裁剪**：图片需设置 clipBehavior 为 Clip.antiAlias
3. **点击效果**：使用 InkWell 而非 GestureDetector 获得涟漪效果
4. **内容间距**：保持一致的 padding，通常 16px
5. **语义化**：为卡片添加适当的语义标签

## 相关组件

- [ListTile](./listtile.md) - 常用于卡片内的列表项
- [InkWell](../gesture/inkwell.md) - 为卡片添加点击效果
- [Container](../basics/container.md) - 更灵活的容器
- [Chip](./chip.md) - 标签组件

## 官方文档

- [Card API](https://api.flutter-io.cn/flutter/material/Card-class.html)
- [Material Design Cards](https://m3.material.io/components/cards)
