# CustomScrollView

`CustomScrollView` 是 Flutter 中功能最强大的滚动组件，它允许你使用 **Slivers** 来创建各种自定义的滚动效果。与 `ListView` 或 `GridView` 不同，`CustomScrollView` 可以在同一个滚动视图中组合多种不同类型的滚动内容。

## Slivers 概念

**Sliver** 是 Flutter 中一种特殊的可滚动组件协议。"Sliver" 这个词意为"薄片"，形象地描述了这些组件在滚动视图中像薄片一样堆叠的特性。

### 为什么需要 Slivers？

```
┌─────────────────────────────────┐
│       CustomScrollView          │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │      SliverAppBar         │  │  ← 可折叠的应用栏
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │      SliverList           │  │  ← 列表区域
│  │  ┌─────────────────────┐  │  │
│  │  │      Item 1         │  │  │
│  │  ├─────────────────────┤  │  │
│  │  │      Item 2         │  │  │
│  │  └─────────────────────┘  │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │      SliverGrid           │  │  ← 网格区域
│  │  ┌─────┐ ┌─────┐ ┌─────┐  │  │
│  │  │  1  │ │  2  │ │  3  │  │  │
│  │  └─────┘ └─────┘ └─────┘  │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

普通的滚动组件（如 `ListView`）只能包含同类型的子元素，而 `CustomScrollView` 通过 Slivers 可以：

- 组合多种滚动布局（列表 + 网格）
- 实现复杂的滚动效果（折叠头部、吸顶等）
- 精确控制每个区域的滚动行为

## 常用 Sliver 组件

| 组件 | 说明 | 用途 |
|------|------|------|
| `SliverAppBar` | 可折叠的应用栏 | 实现滚动时收缩/展开的头部 |
| `SliverList` | Sliver 版本的列表 | 垂直排列的列表项 |
| `SliverGrid` | Sliver 版本的网格 | 网格布局 |
| `SliverFixedExtentList` | 固定高度的列表 | 性能更好的等高列表 |
| `SliverToBoxAdapter` | 普通组件适配器 | 将非 Sliver 组件嵌入 |
| `SliverPersistentHeader` | 持久头部 | 吸顶效果 |
| `SliverFillRemaining` | 填充剩余空间 | 底部内容填充 |
| `SliverPadding` | 内边距 | 为 Sliver 添加间距 |
| `SliverAnimatedList` | 动画列表 | 带动画的列表操作 |
| `SliverPrototypeExtentList` | 原型高度列表 | 根据原型计算高度 |

## 基本用法

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: Text('标题'),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('项目 $index')),
        childCount: 20,
      ),
    ),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `slivers` | `List<Widget>` | 必填 | Sliver 组件列表 |
| `scrollDirection` | `Axis` | `vertical` | 滚动方向 |
| `reverse` | `bool` | `false` | 是否反向滚动 |
| `controller` | `ScrollController?` | `null` | 滚动控制器 |
| `physics` | `ScrollPhysics?` | `null` | 滚动物理效果 |
| `shrinkWrap` | `bool` | `false` | 是否根据内容收缩 |
| `anchor` | `double` | `0.0` | 滚动锚点位置 |
| `cacheExtent` | `double?` | `null` | 缓存区域大小 |
| `semanticChildCount` | `int?` | `null` | 语义子元素数量 |
| `dragStartBehavior` | `DragStartBehavior` | `start` | 拖拽开始行为 |
| `keyboardDismissBehavior` | `KeyboardDismissBehavior` | `manual` | 键盘消失行为 |
| `clipBehavior` | `Clip` | `hardEdge` | 裁剪行为 |

## 使用场景示例

### 1. SliverAppBar 折叠效果

实现滚动时应用栏自动折叠/展开的效果：

```dart
import 'package:flutter/material.dart';

class SliverAppBarDemo extends StatelessWidget {
  const SliverAppBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 可折叠的应用栏
          SliverAppBar(
            expandedHeight: 200.0,  // 展开时的高度
            floating: false,        // 向下滚动时是否立即显示
            pinned: true,           // 是否固定在顶部
            snap: false,            // 是否有吸附效果
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('折叠效果'),
              centerTitle: true,
              background: Image.network(
                'https://picsum.photos/800/400',
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          // 列表内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('列表项 ${index + 1}'),
                subtitle: Text('这是第 ${index + 1} 个列表项的描述'),
              ),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
```

**SliverAppBar 关键属性说明：**

| 属性 | 效果 |
|------|------|
| `floating: true` | 向下滚动时，AppBar 会立即显示 |
| `pinned: true` | AppBar 收缩后固定在顶部 |
| `snap: true` | 配合 floating 使用，有吸附效果 |
| `expandedHeight` | 完全展开时的高度 |
| `collapsedHeight` | 折叠后的高度 |

### 2. SliverList + SliverGrid 混合布局

在同一滚动视图中组合列表和网格：

```dart
import 'package:flutter/material.dart';

class MixedScrollDemo extends StatelessWidget {
  const MixedScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 应用栏
          const SliverAppBar(
            title: Text('混合布局'),
            pinned: true,
          ),

          // 标题区域
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '推荐列表',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 横向列表区域
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 10,
                itemBuilder: (context, index) => Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100 * ((index % 9) + 1)],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text('推荐 ${index + 1}')),
                ),
              ),
            ),
          ),

          // 分类标题
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '热门分类',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 网格区域
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[100 * ((index % 9) + 1)],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '分类 ${index + 1}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                childCount: 6,
              ),
            ),
          ),

          // 列表标题
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '全部商品',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 垂直列表区域
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green[100 * ((index % 9) + 1)],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  title: Text('商品 ${index + 1}'),
                  subtitle: Text('商品描述 ${index + 1}'),
                  trailing: Text('¥${(index + 1) * 99}'),
                ),
              ),
              childCount: 20,
            ),
          ),

          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}
```

### 3. SliverToBoxAdapter 嵌入普通组件

将非 Sliver 组件嵌入到 CustomScrollView 中：

```dart
import 'package:flutter/material.dart';

class SliverToBoxAdapterDemo extends StatelessWidget {
  const SliverToBoxAdapterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('SliverToBoxAdapter'),
            pinned: true,
          ),

          // 嵌入 Banner 轮播图
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              child: PageView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Banner ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 嵌入统计卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard('订单', '12', Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard('收藏', '36', Colors.red),
                  const SizedBox(width: 12),
                  _buildStatCard('足迹', '99+', Colors.orange),
                ],
              ),
            ),
          ),

          // 嵌入搜索框
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索商品...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
          ),

          // 列表内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: Text('商品 ${index + 1}'),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
```

### 4. SliverPersistentHeader 吸顶效果

实现滚动时固定在顶部的吸顶标题：

```dart
import 'package:flutter/material.dart';

class StickyHeaderDemo extends StatelessWidget {
  const StickyHeaderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('吸顶效果'),
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: ColoredBox(color: Colors.blue),
            ),
          ),

          // 第一个吸顶标题
          SliverPersistentHeader(
            pinned: true,  // 吸顶
            delegate: _StickyHeaderDelegate(
              minHeight: 50,
              maxHeight: 50,
              child: Container(
                color: Colors.teal,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  '分类 A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 分类 A 的内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('A - 项目 ${index + 1}'),
              ),
              childCount: 8,
            ),
          ),

          // 第二个吸顶标题
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: 50,
              maxHeight: 50,
              child: Container(
                color: Colors.orange,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  '分类 B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 分类 B 的内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('B - 项目 ${index + 1}'),
              ),
              childCount: 8,
            ),
          ),

          // 第三个吸顶标题（可伸缩）
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: 50,
              maxHeight: 100,  // 可伸缩
              child: Container(
                color: Colors.purple,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  '分类 C（可伸缩）',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 分类 C 的内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('C - 项目 ${index + 1}'),
              ),
              childCount: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// 自定义 SliverPersistentHeaderDelegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
```

### 5. NestedScrollView 嵌套滚动

实现 TabBar + TabBarView 的协调滚动效果：

```dart
import 'package:flutter/material.dart';

class NestedScrollDemo extends StatelessWidget {
  const NestedScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 可折叠的应用栏
              SliverAppBar(
                title: const Text('NestedScrollView'),
                pinned: true,
                expandedHeight: 200,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue, Colors.purple],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: Icon(Icons.person, size: 40),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '用户名',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // TabBar 放在 AppBar 底部
                bottom: const TabBar(
                  tabs: [
                    Tab(text: '动态'),
                    Tab(text: '收藏'),
                    Tab(text: '关注'),
                  ],
                ),
              ),
            ];
          },
          // TabBarView 作为内容区域
          body: TabBarView(
            children: [
              _buildTabContent('动态', Colors.blue),
              _buildTabContent('收藏', Colors.green),
              _buildTabContent('关注', Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String title, Color color) {
    return ListView.builder(
      // 重要：设置 padding 避免内容被遮挡
      padding: EdgeInsets.zero,
      itemCount: 30,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text('${index + 1}'),
        ),
        title: Text('$title 项目 ${index + 1}'),
        subtitle: Text('这是 $title 的第 ${index + 1} 项'),
      ),
    );
  }
}
```

### 6. SliverFillRemaining 填充剩余空间

确保内容不足时也能填满屏幕：

```dart
import 'package:flutter/material.dart';

class FillRemainingDemo extends StatelessWidget {
  const FillRemainingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('填充剩余空间'),
            pinned: true,
          ),

          // 少量内容
          SliverList(
            delegate: SliverChildListDelegate([
              const ListTile(title: Text('项目 1')),
              const ListTile(title: Text('项目 2')),
              const ListTile(title: Text('项目 3')),
            ]),
          ),

          // 填充剩余空间
          SliverFillRemaining(
            hasScrollBody: false,  // 内容不可滚动
            child: Container(
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有更多内容了',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 性能优化

### 1. 使用 SliverChildBuilderDelegate

```dart
// ✅ 推荐：按需创建，内存效率高
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => ListTile(title: Text('项目 $index')),
    childCount: 1000,
  ),
)

// ❌ 避免：一次性创建所有子元素
SliverList(
  delegate: SliverChildListDelegate([
    // 所有子元素都会立即创建
    for (var i = 0; i < 1000; i++) ListTile(title: Text('项目 $i')),
  ]),
)
```

### 2. 使用固定高度列表

```dart
// ✅ 推荐：已知固定高度时使用
SliverFixedExtentList(
  itemExtent: 60.0,  // 固定高度
  delegate: SliverChildBuilderDelegate(
    (context, index) => ListTile(title: Text('项目 $index')),
    childCount: 1000,
  ),
)

// 或者使用原型高度
SliverPrototypeExtentList(
  prototypeItem: const ListTile(title: Text('原型')),  // 原型元素
  delegate: SliverChildBuilderDelegate(
    (context, index) => ListTile(title: Text('项目 $index')),
    childCount: 1000,
  ),
)
```

### 3. 设置合理的缓存范围

```dart
CustomScrollView(
  // 默认 250 像素，可根据需要调整
  cacheExtent: 500.0,  // 增加缓存可减少重建，但增加内存
  slivers: [...],
)
```

### 4. 使用 RepaintBoundary 隔离重绘

```dart
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => RepaintBoundary(
      child: ComplexListItem(index: index),
    ),
    childCount: 1000,
  ),
)
```

### 5. 避免在 delegate 中进行耗时操作

```dart
// ❌ 避免
SliverChildBuilderDelegate(
  (context, index) {
    final data = expensiveComputation();  // 耗时操作
    return ListTile(title: Text(data));
  },
)

// ✅ 推荐：提前计算好数据
final precomputedData = computeAllData();
SliverChildBuilderDelegate(
  (context, index) => ListTile(title: Text(precomputedData[index])),
)
```

## 最佳实践

### 1. 合理组织 Sliver 结构

```dart
CustomScrollView(
  slivers: [
    // 1. 顶部固定区域
    const SliverAppBar(...),

    // 2. 各个内容区域用 SliverPadding 包裹
    SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(...),
    ),

    // 3. 底部留白
    const SliverToBoxAdapter(
      child: SizedBox(height: 80),
    ),
  ],
)
```

### 2. 添加 Key 优化列表更新

```dart
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      final item = items[index];
      return ListTile(
        key: ValueKey(item.id),  // 添加唯一 key
        title: Text(item.title),
      );
    },
    childCount: items.length,
  ),
)
```

### 3. 处理空状态

```dart
slivers: items.isEmpty
    ? [
        const SliverFillRemaining(
          child: Center(child: Text('暂无数据')),
        ),
      ]
    : [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ItemWidget(items[index]),
            childCount: items.length,
          ),
        ),
      ],
```

### 4. 配合 ScrollController 使用

```dart
class _MyPageState extends State<MyPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 监听滚动位置
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 加载更多
      _loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [...],
    );
  }
}
```

### 5. 使用 SliverAnimatedList 实现动画

```dart
final _listKey = GlobalKey<SliverAnimatedListState>();
final _items = <String>[];

void _addItem() {
  _items.insert(0, 'New Item');
  _listKey.currentState?.insertItem(0);
}

void _removeItem(int index) {
  final removed = _items.removeAt(index);
  _listKey.currentState?.removeItem(
    index,
    (context, animation) => SizeTransition(
      sizeFactor: animation,
      child: ListTile(title: Text(removed)),
    ),
  );
}

// 在 CustomScrollView 中使用
SliverAnimatedList(
  key: _listKey,
  initialItemCount: _items.length,
  itemBuilder: (context, index, animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(_items[index]),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _removeItem(index),
        ),
      ),
    );
  },
)
```

## 相关组件

- [ListView](./listview.md) - 简单列表滚动
- [GridView](./gridview.md) - 网格滚动
- [SingleChildScrollView](./singlechildscrollview.md) - 单子元素滚动
- [NestedScrollView](./nestedscrollview.md) - 嵌套滚动
- [PageView](./pageview.md) - 页面滚动

## 官方文档

- [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)
- [SliverAppBar API](https://api.flutter.dev/flutter/material/SliverAppBar-class.html)
- [SliverList API](https://api.flutter.dev/flutter/widgets/SliverList-class.html)
- [SliverGrid API](https://api.flutter.dev/flutter/widgets/SliverGrid-class.html)
- [Slivers 官方教程](https://docs.flutter.dev/ui/layout/scrolling/slivers)
