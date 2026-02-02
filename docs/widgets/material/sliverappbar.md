# SliverAppBar

`SliverAppBar` 是 Flutter 中用于 `CustomScrollView` 的可折叠应用栏组件。它可以随着滚动展开、折叠、固定或浮动，常用于创建炫酷的头部效果，如个人主页、商品详情页等。

## 基本用法

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: const Text('SliverAppBar'),
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          'https://picsum.photos/400/200',
          fit: BoxFit.cover,
        ),
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('Item $index')),
        childCount: 30,
      ),
    ),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `expandedHeight` | `double?` | - | 展开时的高度 |
| `collapsedHeight` | `double?` | - | 折叠后的高度 |
| `pinned` | `bool` | `false` | 折叠后是否固定在顶部 |
| `floating` | `bool` | `false` | 下拉时是否立即显示 |
| `snap` | `bool` | `false` | 是否在松手后自动展开/折叠 |
| `stretch` | `bool` | `false` | 是否支持拉伸效果 |
| `flexibleSpace` | `Widget?` | - | 可伸缩区域内容 |
| `title` | `Widget?` | - | 标题 |
| `actions` | `List<Widget>?` | - | 右侧操作按钮 |
| `leading` | `Widget?` | - | 左侧按钮 |
| `backgroundColor` | `Color?` | - | 背景颜色 |
| `foregroundColor` | `Color?` | - | 前景颜色（标题、图标） |
| `elevation` | `double?` | - | 阴影高度 |
| `forceElevated` | `bool` | `false` | 强制显示阴影 |

## 行为组合

| pinned | floating | snap | 效果 |
|--------|----------|------|------|
| `false` | `false` | `false` | 完全滚出视图 |
| `true` | `false` | `false` | 折叠后固定在顶部 |
| `false` | `true` | `false` | 下拉时立即显示 |
| `true` | `true` | `false` | 固定 + 下拉显示 |
| `false` | `true` | `true` | 下拉显示 + 自动弹出 |
| `true` | `true` | `true` | 固定 + 下拉 + 自动弹出 |

## 使用场景

### 1. 基础可折叠头部

```dart
class BasicSliverAppBarDemo extends StatelessWidget {
  const BasicSliverAppBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // 展开高度
            expandedHeight: 250,
            // 固定在顶部
            pinned: true,
            // 可伸缩空间
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Flutter 教程'),
              // 标题位置
              centerTitle: true,
              // 标题与背景的视差效果
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://picsum.photos/400/300',
                    fit: BoxFit.cover,
                  ),
                  // 渐变遮罩
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 操作按钮
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          // 列表内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('列表项 ${index + 1}'),
                  subtitle: const Text('这是描述信息'),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. 拉伸效果（Stretch）

```dart
class StretchSliverAppBarDemo extends StatelessWidget {
  const StretchSliverAppBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        // 开启物理弹性
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            // 开启拉伸
            stretch: true,
            // 拉伸触发回调
            onStretchTrigger: () async {
              print('触发刷新');
            },
            // 拉伸触发的偏移量
            stretchTriggerOffset: 100,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('拉伸效果'),
              // 拉伸模式
              stretchModes: const [
                StretchMode.zoomBackground,    // 背景缩放
                StretchMode.fadeTitle,         // 标题淡出
                StretchMode.blurBackground,    // 背景模糊
              ],
              background: Image.network(
                'https://picsum.photos/400/400',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item $index')),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. 浮动快速访问（Floating + Snap）

```dart
class FloatingSnapDemo extends StatelessWidget {
  const FloatingSnapDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // 不固定
            pinned: false,
            // 下拉时浮动显示
            floating: true,
            // 自动弹出/收起
            snap: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('快速搜索'),
              background: Container(color: Colors.blue),
            ),
            // 底部搜索栏
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item $index')),
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. 个人主页布局

```dart
class ProfilePageDemo extends StatelessWidget {
  const ProfilePageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 背景图
                      Image.network(
                        'https://picsum.photos/400/300',
                        fit: BoxFit.cover,
                      ),
                      // 渐变遮罩
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // 用户信息
                      Positioned(
                        bottom: 60,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                'https://picsum.photos/100/100',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '用户名',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '这是个人简介...',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                              ),
                              child: const Text('编辑'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 固定 TabBar
                bottom: const TabBar(
                  indicatorColor: Colors.white,
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
              _buildPostList(),
              _buildFavoriteGrid(),
              _buildFollowList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('动态 ${index + 1}'),
                const SizedBox(height: 8),
                const Text('这是动态内容...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[200],
          child: Center(child: Text('${index + 1}')),
        );
      },
    );
  }

  Widget _buildFollowList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 15,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('用户 ${index + 1}'),
          subtitle: const Text('粉丝 1.2k'),
          trailing: ElevatedButton(
            onPressed: () {},
            child: const Text('关注'),
          ),
        );
      },
    );
  }
}
```

### 5. 动态改变透明度

```dart
class DynamicOpacityDemo extends StatefulWidget {
  const DynamicOpacityDemo({super.key});

  @override
  State<DynamicOpacityDemo> createState() => _DynamicOpacityDemoState();
}

class _DynamicOpacityDemoState extends State<DynamicOpacityDemo> {
  double _opacity = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            // 根据滚动位置计算透明度
            final pixels = notification.metrics.pixels;
            final expandedHeight = 200 - kToolbarHeight;
            setState(() {
              _opacity = (pixels / expandedHeight).clamp(0, 1);
            });
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              // 动态背景颜色
              backgroundColor: Colors.blue.withOpacity(_opacity),
              title: Opacity(
                opacity: _opacity,
                child: const Text('标题'),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 1 - _opacity,
                  child: Image.network(
                    'https://picsum.photos/400/200',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(title: Text('Item $index')),
                childCount: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## FlexibleSpaceBar 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `title` | `Widget?` | 标题 |
| `background` | `Widget?` | 背景内容 |
| `centerTitle` | `bool?` | 标题是否居中 |
| `titlePadding` | `EdgeInsetsGeometry?` | 标题内边距 |
| `collapseMode` | `CollapseMode` | 折叠模式 |
| `stretchModes` | `List<StretchMode>` | 拉伸模式列表 |

### CollapseMode 折叠模式

- `parallax`：视差效果（默认）
- `pin`：固定不动
- `none`：无效果

### StretchMode 拉伸模式

- `zoomBackground`：背景缩放
- `fadeTitle`：标题淡出
- `blurBackground`：背景模糊

## 相关组件

- [CustomScrollView](../scrolling/customscrollview.md)：自定义滚动视图
- [NestedScrollView](../scrolling/nestedscrollview.md)：嵌套滚动视图
- [AppBar](appbar.md)：普通应用栏

## 官方文档

- [SliverAppBar API](https://api.flutter.dev/flutter/material/SliverAppBar-class.html)
- [FlexibleSpaceBar API](https://api.flutter.dev/flutter/material/FlexibleSpaceBar-class.html)
