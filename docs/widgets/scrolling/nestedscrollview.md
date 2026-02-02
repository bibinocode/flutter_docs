# NestedScrollView

`NestedScrollView` 是 Flutter 中用于处理嵌套滚动的高级组件，它可以协调外部滚动视图（如 AppBar）和内部滚动视图（如 TabBarView 中的 ListView）之间的滚动行为，避免滚动冲突。

## 基本用法

```dart
NestedScrollView(
  headerSliverBuilder: (context, innerBoxIsScrolled) {
    return [
      SliverAppBar(
        title: const Text('NestedScrollView'),
        pinned: true,
        floating: true,
        expandedHeight: 200,
        flexibleSpace: FlexibleSpaceBar(
          background: Image.network(
            'https://picsum.photos/400/200',
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];
  },
  body: ListView.builder(
    itemCount: 50,
    itemBuilder: (context, index) {
      return ListTile(title: Text('Item $index'));
    },
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `headerSliverBuilder` | `NestedScrollViewHeaderSliversBuilder` | 必需 | 构建头部 Sliver 组件 |
| `body` | `Widget` | 必需 | 内部滚动区域 |
| `controller` | `ScrollController?` | - | 外部滚动控制器 |
| `scrollDirection` | `Axis` | `Axis.vertical` | 滚动方向 |
| `reverse` | `bool` | `false` | 是否反向滚动 |
| `physics` | `ScrollPhysics?` | - | 滚动物理效果 |
| `floatHeaderSlivers` | `bool` | `false` | 头部是否浮动 |
| `clipBehavior` | `Clip` | `Clip.hardEdge` | 裁剪行为 |

## 使用场景

### 1. 可折叠头部 + Tab 页面

```dart
class CollapsibleTabDemo extends StatelessWidget {
  const CollapsibleTabDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('我的主页'),
                pinned: true,
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://picsum.photos/100/100',
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '用户名',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 固定 TabBar
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
          body: TabBarView(
            children: [
              _buildListView('动态'),
              _buildListView('收藏'),
              _buildListView('关注'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(String type) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 30,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('$type 项目 $index'),
          subtitle: const Text('这是描述信息'),
        );
      },
    );
  }
}
```

### 2. 多 Sliver 组合头部

```dart
class MultiSliverHeaderDemo extends StatelessWidget {
  const MultiSliverHeaderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 可折叠 AppBar
            SliverAppBar(
              title: const Text('商品详情'),
              pinned: true,
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://picsum.photos/400/300',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // 商品信息
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '商品名称',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '¥ 299.00',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 固定的 TabBar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: Container(
                  color: Colors.white,
                  child: const TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: '详情'),
                      Tab(text: '评价'),
                      Tab(text: '推荐'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildDetailTab(),
            _buildReviewTab(),
            _buildRecommendTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(10, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('详情图片 ${index + 1}')),
          );
        }),
      ),
    );
  }

  Widget _buildReviewTab() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('用户评价 $index'),
          subtitle: const Text('这是一条很好的评价...'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              return const Icon(Icons.star, color: Colors.orange, size: 16);
            }),
          ),
        );
      },
    );
  }

  Widget _buildRecommendTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('推荐商品 $index'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(context, shrinkOffset, overlapsContent) => child;

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
```

### 3. 控制内外滚动

```dart
class ScrollControlDemo extends StatefulWidget {
  const ScrollControlDemo({super.key});

  @override
  State<ScrollControlDemo> createState() => _ScrollControlDemoState();
}

class _ScrollControlDemoState extends State<ScrollControlDemo> {
  final _outerController = ScrollController();
  
  @override
  void dispose() {
    _outerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _outerController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('滚动控制'),
              pinned: true,
              expandedHeight: 200,
              // 根据内部滚动状态显示阴影
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: Colors.blue[100]),
              ),
            ),
          ];
        },
        body: Builder(
          builder: (context) {
            // 获取内部滚动控制器
            final innerController = PrimaryScrollController.of(context);
            
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // 监听内部滚动
                if (notification is ScrollUpdateNotification) {
                  print('内部滚动位置: ${notification.metrics.pixels}');
                }
                return false;
              },
              child: ListView.builder(
                // 使用内部控制器
                controller: innerController,
                itemCount: 50,
                itemBuilder: (context, index) {
                  return ListTile(title: Text('Item $index'));
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 滚动到顶部
          _outerController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
}
```

### 4. 配合 SliverOverlapAbsorber

处理头部与内容区重叠问题：

```dart
class OverlapDemo extends StatelessWidget {
  const OverlapDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  title: const Text('Overlap Demo'),
                  pinned: true,
                  expandedHeight: 200,
                  forceElevated: innerBoxIsScrolled,
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Tab 1'),
                      Tab(text: 'Tab 2'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildSafeList('Tab 1'),
              _buildSafeList('Tab 2'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafeList(String title) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            // 处理重叠区域
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ListTile(
                    title: Text('$title - Item $index'),
                  );
                },
                childCount: 30,
              ),
            ),
          ],
        );
      },
    );
  }
}
```

## 内部滚动器访问

```dart
// 方式一：使用 Builder 获取 PrimaryScrollController
Builder(
  builder: (context) {
    final controller = PrimaryScrollController.of(context);
    return ListView.builder(
      controller: controller,
      // ...
    );
  },
)

// 方式二：使用 GlobalKey 访问 NestedScrollViewState
final _nestedKey = GlobalKey<NestedScrollViewState>();

NestedScrollView(
  key: _nestedKey,
  // ...
)

// 获取内部控制器
void _scrollInner() {
  _nestedKey.currentState?.innerController.animateTo(0);
}
```

## 常见问题

### Q: TabBarView 中的列表滚动位置不保持？

使用 `AutomaticKeepAliveClientMixin`：

```dart
class _KeepAliveListState extends State<KeepAliveList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);  // 必须调用
    return ListView.builder(...);
  }
}
```

### Q: 内部列表滚动到顶部后继续折叠头部？

这是 NestedScrollView 的默认行为。如果不需要，可以使用普通的 CustomScrollView 配合 SliverAppBar。

## 相关组件

- [CustomScrollView](customscrollview.md)：自定义滚动视图
- [SliverAppBar](../material/sliverappbar.md)：可折叠应用栏
- [TabBarView](../material/tabbar.md)：Tab 页面

## 官方文档

- [NestedScrollView API](https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html)
