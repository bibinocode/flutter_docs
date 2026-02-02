# SliverList & SliverGrid

`SliverList` 和 `SliverGrid` 是在 `CustomScrollView` 中使用的 Sliver 版本列表和网格组件，它们可以与其他 Sliver 组件（如 SliverAppBar）组合使用，创建复杂的滚动效果。

## SliverList 基本用法

```dart
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(title: Text('Item $index'));
        },
        childCount: 20,
      ),
    ),
  ],
)
```

## SliverGrid 基本用法

```dart
CustomScrollView(
  slivers: [
    SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Card(
            child: Center(child: Text('$index')),
          );
        },
        childCount: 20,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    ),
  ],
)
```

## SliverChildDelegate 类型

### SliverChildBuilderDelegate（推荐）

懒加载构建，适合长列表：

```dart
SliverChildBuilderDelegate(
  (context, index) {
    return ListTile(title: Text('Item $index'));
  },
  childCount: 100,  // 必须指定
  addAutomaticKeepAlives: true,  // 保持子组件状态
  addRepaintBoundaries: true,    // 添加重绘边界
  addSemanticIndexes: true,      // 添加语义索引
)
```

### SliverChildListDelegate

直接传入子组件列表，适合少量固定项目：

```dart
SliverChildListDelegate([
  const ListTile(title: Text('Item 1')),
  const ListTile(title: Text('Item 2')),
  const ListTile(title: Text('Item 3')),
])
```

## SliverGridDelegate 类型

### SliverGridDelegateWithFixedCrossAxisCount

固定列数：

```dart
const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,           // 列数
  mainAxisSpacing: 8,          // 主轴间距
  crossAxisSpacing: 8,         // 交叉轴间距
  childAspectRatio: 1.0,       // 宽高比
  mainAxisExtent: 100,         // 主轴固定尺寸（优先于宽高比）
)
```

### SliverGridDelegateWithMaxCrossAxisExtent

固定子项最大宽度，自动计算列数：

```dart
const SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 150,     // 子项最大宽度
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  childAspectRatio: 1.0,
)
```

## 使用场景

### 1. 列表 + 网格混合

```dart
class MixedScrollDemo extends StatelessWidget {
  const MixedScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          const SliverAppBar(
            title: Text('混合布局'),
            floating: true,
          ),
          
          // 标题
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '推荐分类',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 横向分类网格
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final categories = ['电子', '服装', '食品', '家居', '美妆', '运动'];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, color: Colors.blue[300]),
                      const SizedBox(height: 4),
                      Text(categories[index]),
                    ],
                  ),
                );
              },
              childCount: 6,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
          ),
          
          // 标题
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '热门商品',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 商品列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                  title: Text('商品 ${index + 1}'),
                  subtitle: Text('¥${(index + 1) * 99}'),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. 分组列表（带标题）

```dart
class GroupedListDemo extends StatelessWidget {
  const GroupedListDemo({super.key});

  final groups = const [
    {'title': 'A', 'items': ['Apple', 'Apricot', 'Avocado']},
    {'title': 'B', 'items': ['Banana', 'Blueberry', 'Blackberry']},
    {'title': 'C', 'items': ['Cherry', 'Coconut', 'Cranberry']},
    {'title': 'D', 'items': ['Date', 'Dragonfruit', 'Durian']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分组列表')),
      body: CustomScrollView(
        slivers: [
          for (final group in groups) ...[
            // 分组标题（固定）
            SliverPersistentHeader(
              pinned: true,
              delegate: _SectionHeaderDelegate(
                title: group['title'] as String,
              ),
            ),
            // 分组内容
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final items = group['items'] as List<String>;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(items[index][0]),
                    ),
                    title: Text(items[index]),
                  );
                },
                childCount: (group['items'] as List).length,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _SectionHeaderDelegate({required this.title});

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return title != oldDelegate.title;
  }
}
```

### 3. 瀑布流布局

使用 `flutter_staggered_grid_view` 包实现：

```dart
// 需要添加依赖: flutter_staggered_grid_view
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WaterfallDemo extends StatelessWidget {
  const WaterfallDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('瀑布流')),
      body: CustomScrollView(
        slivers: [
          SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childCount: 30,
            itemBuilder: (context, index) {
              // 随机高度模拟瀑布流
              final height = 100.0 + (index % 5) * 30;
              return Container(
                height: height,
                color: Colors.primaries[index % Colors.primaries.length][200],
                child: Center(child: Text('$index')),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 4. 带 Header/Footer 的列表

```dart
class HeaderFooterListDemo extends StatelessWidget {
  const HeaderFooterListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'Header',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
          
          // 列表内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(title: Text('Item $index'));
              },
              childCount: 20,
            ),
          ),
          
          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: const Center(
                child: Text(
                  '— 没有更多了 —',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## SliverList.builder / SliverGrid.builder

Flutter 3.x 提供的简化构造器：

```dart
// SliverList.builder
SliverList.builder(
  itemCount: 20,
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
)

// SliverList.list
SliverList.list(
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
  ],
)

// SliverList.separated（带分隔线）
SliverList.separated(
  itemCount: 20,
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
  separatorBuilder: (context, index) => const Divider(),
)

// SliverGrid.builder
SliverGrid.builder(
  itemCount: 20,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
  ),
  itemBuilder: (context, index) {
    return Card(child: Center(child: Text('$index')));
  },
)
```

## 性能优化

```dart
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      return ExpensiveWidget(index: index);
    },
    childCount: 1000,
    // 保持子组件活跃状态（切换 Tab 时保持滚动位置）
    addAutomaticKeepAlives: true,
    // 添加重绘边界，隔离重绘
    addRepaintBoundaries: true,
    // 查找子组件（用于语义树）
    findChildIndexCallback: (key) {
      if (key is ValueKey<int>) {
        return key.value;
      }
      return null;
    },
  ),
)
```

## 相关组件

- [CustomScrollView](customscrollview.md)：自定义滚动视图
- [ListView](listview.md)：普通列表
- [GridView](gridview.md)：普通网格
- [SliverAppBar](../material/sliverappbar.md)：Sliver 应用栏

## 官方文档

- [SliverList API](https://api.flutter.dev/flutter/widgets/SliverList-class.html)
- [SliverGrid API](https://api.flutter.dev/flutter/widgets/SliverGrid-class.html)
