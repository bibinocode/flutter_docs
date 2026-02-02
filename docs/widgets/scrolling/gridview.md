# GridView

`GridView` 是 Flutter 中用于显示网格布局的可滚动组件。它将子组件排列成二维网格，支持懒加载，非常适合展示图片墙、商品列表等场景。

## 四种构造方式

| 构造函数 | 用途 | 适用场景 |
|----------|------|----------|
| `GridView()` | 自定义 delegate | 完全自定义 |
| `GridView.count()` | 固定列数 | 已知列数 |
| `GridView.extent()` | 固定子项最大宽度 | 响应式布局 |
| `GridView.builder()` | 按需构建 | 长列表、动态数据 |

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `gridDelegate` | `SliverGridDelegate` | 网格布局代理 |
| `children` | `List&lt;Widget&gt;` | 子组件列表 |
| `itemBuilder` | `IndexedWidgetBuilder` | 构建器函数 |
| `itemCount` | `int?` | 网格项数量 |
| `scrollDirection` | `Axis` | 滚动方向 |
| `reverse` | `bool` | 是否反向 |
| `controller` | `ScrollController?` | 滚动控制器 |
| `physics` | `ScrollPhysics?` | 滚动物理效果 |
| `shrinkWrap` | `bool` | 是否收缩包裹 |
| `padding` | `EdgeInsetsGeometry?` | 内边距 |
| `crossAxisCount` | `int` | 交叉轴子项数量（列数） |
| `mainAxisSpacing` | `double` | 主轴间距 |
| `crossAxisSpacing` | `double` | 交叉轴间距 |
| `childAspectRatio` | `double` | 子项宽高比 |

## SliverGridDelegate 类型

| 类型 | 说明 |
|------|------|
| `SliverGridDelegateWithFixedCrossAxisCount` | 固定列数 |
| `SliverGridDelegateWithMaxCrossAxisExtent` | 最大子项宽度 |

## 使用场景

### 1. GridView.count（固定列数）

```dart
GridView.count(
  crossAxisCount: 3, // 3 列
  mainAxisSpacing: 10, // 行间距
  crossAxisSpacing: 10, // 列间距
  padding: EdgeInsets.all(10),
  children: List.generate(
    9,
    (index) => Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(
        child: Text(
          '$index',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ),
  ),
)

// 指定宽高比
GridView.count(
  crossAxisCount: 2,
  childAspectRatio: 16 / 9, // 宽:高 = 16:9
  children: [
    Container(color: Colors.red),
    Container(color: Colors.blue),
    Container(color: Colors.green),
    Container(color: Colors.yellow),
  ],
)
```

### 2. GridView.extent（响应式）

```dart
// 子项最大宽度为 150，自动计算列数
GridView.extent(
  maxCrossAxisExtent: 150,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  padding: EdgeInsets.all(8),
  children: List.generate(
    20,
    (index) => Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('$index')),
    ),
  ),
)
```

### 3. GridView.builder（长列表）

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 1, // 正方形
  ),
  padding: EdgeInsets.all(10),
  itemCount: 100,
  itemBuilder: (context, index) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50),
          Text('Item $index'),
        ],
      ),
    );
  },
)

// 使用 maxCrossAxisExtent
GridView.builder(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 0.75, // 竖向卡片
  ),
  itemCount: 50,
  itemBuilder: (context, index) {
    return ProductCard(index: index);
  },
)
```

### 4. 图片网格（相册）

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 2,
    crossAxisSpacing: 2,
  ),
  itemCount: photos.length,
  itemBuilder: (context, index) {
    return GestureDetector(
      onTap: () => _openPhoto(index),
      child: Image.network(
        photos[index],
        fit: BoxFit.cover,
      ),
    );
  },
)
```

### 5. 商品列表

```dart
class ProductGrid extends StatelessWidget {
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7, // 竖向卡片
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '¥${product.price}',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 6. 自适应高度（瀑布流）

```dart
// 使用 flutter_staggered_grid_view 包
// pubspec.yaml: flutter_staggered_grid_view: ^0.6.2

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

MasonryGridView.count(
  crossAxisCount: 2,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Container(
      height: (index % 5 + 1) * 50.0, // 不同高度
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('$index')),
    );
  },
)
```

### 7. 选择模式网格

```dart
class SelectableGrid extends StatefulWidget {
  @override
  _SelectableGridState createState() => _SelectableGridState();
}

class _SelectableGridState extends State<SelectableGrid> {
  final Set<int> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final isSelected = _selectedItems.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedItems.remove(index);
              } else {
                _selectedItems.add(index);
              }
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.grey[300],
                child: Center(child: Text('$index')),
              ),
              if (isSelected)
                Container(
                  color: Colors.blue.withOpacity(0.3),
                  child: Icon(Icons.check_circle, color: Colors.blue),
                ),
            ],
          ),
        );
      },
    );
  }
}
```

### 8. 水平滚动网格

```dart
SizedBox(
  height: 250,
  child: GridView.builder(
    scrollDirection: Axis.horizontal,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // 2 行
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1,
    ),
    itemCount: 20,
    itemBuilder: (context, index) {
      return Container(
        color: Colors.primaries[index % Colors.primaries.length],
        child: Center(child: Text('$index')),
      );
    },
  ),
)
```

### 9. 嵌套使用

```dart
// 在 Column 中使用
Column(
  children: [
    Text('推荐商品'),
    Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: 10,
        itemBuilder: (context, index) => ProductCard(index: index),
      ),
    ),
  ],
)

// 或使用 shrinkWrap（短列表）
Column(
  children: [
    Text('热门分类'),
    GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      children: categories.map((c) => CategoryIcon(c)).toList(),
    ),
    Text('推荐商品'),
    // ...
  ],
)
```

## GridView.count vs GridView.extent

| 特性 | GridView.count | GridView.extent |
|------|----------------|-----------------|
| 列数 | 固定 | 自动计算 |
| 子项大小 | 自动计算 | 最大宽度限制 |
| 响应式 | 否 | 是 |
| 适用场景 | 固定布局 | 自适应屏幕 |

## 性能优化

```dart
// 1. 长列表使用 builder
GridView.builder(
  itemCount: 1000,
  // ...
)

// 2. 嵌套时避免 shrinkWrap
// ❌ 性能差
GridView.count(shrinkWrap: true, /* ... */)

// ✅ 使用 Expanded 或 SliverGrid
Expanded(child: GridView.builder(/* ... */))

// 3. 使用 cacheExtent 调整缓存
GridView.builder(
  cacheExtent: 500, // 预渲染 500 像素
  // ...
)
```

## 最佳实践

1. **长列表用 builder**: 避免一次性创建所有子组件
2. **设置 childAspectRatio**: 控制子项宽高比
3. **响应式用 extent**: 屏幕尺寸不确定时使用
4. **合理使用间距**: mainAxisSpacing + crossAxisSpacing
5. **瀑布流用第三方包**: `flutter_staggered_grid_view`
6. **避免 shrinkWrap**: 长列表严重影响性能

## 常见问题

::: warning 子项高度问题
GridView 子项高度由 `childAspectRatio` 和列宽决定，不能自适应内容高度。需要自适应高度时：
1. 使用 `flutter_staggered_grid_view` 包
2. 或使用 `Wrap` + 手动计算宽度
:::

::: tip 列数响应式
```dart
// 根据屏幕宽度动态计算列数
int getCrossAxisCount(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width > 1200) return 6;
  if (width > 900) return 4;
  if (width > 600) return 3;
  return 2;
}
```
:::

## 相关组件

- [ListView](./listview) - 列表视图
- [CustomScrollView](./customscrollview) - 自定义滚动视图
- [SliverGrid](./slivergrid) - Sliver 网格
- [Wrap](../layout/wrap) - 自动换行布局

## 官方文档

- [GridView API](https://api.flutter.dev/flutter/widgets/GridView-class.html)
- [Flutter 网格指南](https://docs.flutter.cn/cookbook/lists/grid-lists)
