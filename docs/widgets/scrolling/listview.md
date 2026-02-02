# ListView

`ListView` 是 Flutter 中最常用的可滚动列表组件，用于显示一组垂直或水平排列的子组件。它支持懒加载，仅构建可见区域的子组件，非常适合长列表。

## 四种构造方式

| 构造函数 | 用途 | 适用场景 |
|----------|------|----------|
| `ListView()` | 直接传入 children | 少量固定子组件 |
| `ListView.builder()` | 按需构建 | 长列表、动态数据 |
| `ListView.separated()` | 带分隔符 | 需要分隔线的列表 |
| `ListView.custom()` | 自定义 | 完全自定义 Sliver |

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `children` | `List&lt;Widget&gt;` | 子组件列表 |
| `itemBuilder` | `IndexedWidgetBuilder` | 构建器函数 |
| `itemCount` | `int?` | 列表项数量 |
| `scrollDirection` | `Axis` | 滚动方向 |
| `reverse` | `bool` | 是否反向排列 |
| `controller` | `ScrollController?` | 滚动控制器 |
| `physics` | `ScrollPhysics?` | 滚动物理效果 |
| `shrinkWrap` | `bool` | 是否收缩包裹 |
| `padding` | `EdgeInsetsGeometry?` | 内边距 |
| `itemExtent` | `double?` | 固定子项高度（优化性能） |
| `prototypeItem` | `Widget?` | 原型子项（优化性能） |
| `cacheExtent` | `double?` | 预渲染区域 |

## 使用场景

### 1. 基础 ListView

```dart
// 适用于少量固定子组件
ListView(
  children: [
    ListTile(leading: Icon(Icons.map), title: Text('地图')),
    ListTile(leading: Icon(Icons.photo), title: Text('相册')),
    ListTile(leading: Icon(Icons.phone), title: Text('电话')),
    ListTile(leading: Icon(Icons.settings), title: Text('设置')),
  ],
)

// 带 padding
ListView(
  padding: EdgeInsets.all(16),
  children: [
    Card(child: ListTile(title: Text('卡片 1'))),
    Card(child: ListTile(title: Text('卡片 2'))),
    Card(child: ListTile(title: Text('卡片 3'))),
  ],
)
```

### 2. ListView.builder（最常用）

```dart
// 长列表必用 - 懒加载构建
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text('Item $index'),
      subtitle: Text('This is item number $index'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => print('Tapped item $index'),
    );
  },
)

// 带数据源
final List<String> items = ['Apple', 'Banana', 'Cherry', 'Date'];

ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index]),
    );
  },
)
```

### 3. ListView.separated（带分隔符）

```dart
ListView.separated(
  itemCount: 25,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage('https://picsum.photos/50?random=$index'),
      ),
      title: Text('Contact $index'),
      subtitle: Text('Last message...'),
    );
  },
  separatorBuilder: (context, index) {
    return Divider(height: 1, indent: 72);
  },
)

// 自定义分隔符
ListView.separated(
  itemCount: 10,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  separatorBuilder: (context, index) {
    // 可以根据 index 返回不同分隔符
    if (index == 4) {
      return Container(
        height: 40,
        color: Colors.grey[200],
        child: Center(child: Text('Section Header')),
      );
    }
    return Divider();
  },
)
```

### 4. 水平滚动列表

```dart
SizedBox(
  height: 150,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 10,
    itemBuilder: (context, index) {
      return Container(
        width: 120,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.primaries[index % Colors.primaries.length],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Item $index',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    },
  ),
)
```

### 5. 使用 ScrollController

```dart
class ScrollControllerExample extends StatefulWidget {
  @override
  _ScrollControllerExampleState createState() => _ScrollControllerExampleState();
}

class _ScrollControllerExampleState extends State<ScrollControllerExample> {
  final ScrollController _controller = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showBackToTop = _controller.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _controller,
        itemCount: 100,
        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
```

### 6. 下拉刷新 + 上拉加载

```dart
class RefreshLoadExample extends StatefulWidget {
  @override
  _RefreshLoadExampleState createState() => _RefreshLoadExampleState();
}

class _RefreshLoadExampleState extends State<RefreshLoadExample> {
  final List<int> _items = List.generate(20, (i) => i);
  final ScrollController _controller = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _items.clear();
      _items.addAll(List.generate(20, (i) => i));
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      _items.addAll(List.generate(10, (i) => _items.length + i));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _controller,
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _isLoading
                ? Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ))
                : SizedBox.shrink();
          }
          return ListTile(title: Text('Item ${_items[index]}'));
        },
      ),
    );
  }
}
```

### 7. itemExtent 性能优化

```dart
// 已知子项高度时使用 itemExtent 大幅提升性能
ListView.builder(
  itemCount: 10000,
  itemExtent: 60, // 固定高度
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
)

// 或使用 prototypeItem（Flutter 3.0+）
ListView.builder(
  itemCount: 10000,
  prototypeItem: ListTile(title: Text('Prototype')),
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
)
```

### 8. 嵌套 ListView

```dart
// 在 Column 中使用
Column(
  children: [
    Text('Header'),
    Expanded(
      child: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
      ),
    ),
  ],
)

// 或使用 shrinkWrap（注意性能）
ListView(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
  ],
)
```

### 9. 自定义滚动效果

```dart
// iOS 弹性效果
ListView.builder(
  physics: BouncingScrollPhysics(),
  itemCount: 50,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// Android 边缘发光效果
ListView.builder(
  physics: ClampingScrollPhysics(),
  itemCount: 50,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// 禁止滚动
ListView.builder(
  physics: NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  itemCount: 5,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// 总是可滚动（即使内容不足）
ListView.builder(
  physics: AlwaysScrollableScrollPhysics(),
  itemCount: 2,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
```

## ScrollPhysics 对比

| 类型 | 效果 | 平台 |
|------|------|------|
| `BouncingScrollPhysics` | 弹性回弹 | iOS 默认 |
| `ClampingScrollPhysics` | 边缘发光 | Android 默认 |
| `NeverScrollableScrollPhysics` | 禁止滚动 | 嵌套时使用 |
| `AlwaysScrollableScrollPhysics` | 始终可滚动 | 下拉刷新 |

## 性能优化要点

| 优化方式 | 说明 | 效果 |
|----------|------|------|
| `itemExtent` | 固定子项高度 | ⭐⭐⭐ |
| `prototypeItem` | 原型子项 | ⭐⭐⭐ |
| `addAutomaticKeepAlives: false` | 禁用自动保活 | ⭐⭐ |
| `addRepaintBoundaries: false` | 禁用重绘边界 | ⭐ |
| `cacheExtent` | 调整缓存区域 | ⭐ |

## 最佳实践

1. **长列表必用 builder**: 避免一次性创建所有子组件
2. **指定 itemExtent**: 已知子项高度时大幅提升性能
3. **合理使用 shrinkWrap**: 仅在嵌套且列表较短时使用
4. **添加 key**: 列表数据可能变化时添加唯一 key
5. **释放 controller**: 在 dispose 中释放 ScrollController
6. **下拉刷新**: 配合 RefreshIndicator 使用

## 常见问题

::: warning shrinkWrap 性能问题
`shrinkWrap: true` 会导致 ListView 计算所有子组件高度，失去懒加载优势。长列表应避免使用，改用 `Expanded` 或 `SliverList`。
:::

::: tip 嵌套滚动
在 Column/ListView 中嵌套 ListView 时：
1. 内层使用 `shrinkWrap: true` + `NeverScrollableScrollPhysics()`
2. 或外层使用 `CustomScrollView` + `SliverList`
:::

## 相关组件

- [GridView](./gridview) - 网格列表
- [CustomScrollView](./customscrollview) - 自定义滚动视图
- [SingleChildScrollView](./singlechildscrollview) - 单子组件滚动
- [ListTile](../material/listtile) - 列表项
- [RefreshIndicator](./refreshindicator) - 下拉刷新

## 官方文档

- [ListView API](https://api.flutter.dev/flutter/widgets/ListView-class.html)
- [Flutter 列表指南](https://docs.flutter.cn/cookbook/lists/basic-list)
