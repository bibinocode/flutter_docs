# PageView

`PageView` 是 Flutter 中用于创建可滑动页面视图的组件，每次滑动显示一个完整页面。它是实现引导页、图片轮播、Tab 页面切换等场景的核心组件，支持水平和垂直方向滚动，并提供页面吸附效果。

## 基本用法

```dart
// 1. 使用 children 直接创建
PageView(
  children: [
    Container(color: Colors.red),
    Container(color: Colors.green),
    Container(color: Colors.blue),
  ],
)

// 2. 使用 builder 懒加载创建（推荐大量页面时使用）
PageView.builder(
  itemCount: 10,
  itemBuilder: (context, index) {
    return Center(child: Text('Page $index'));
  },
)

// 3. 使用 custom 自定义创建
PageView.custom(
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => Center(child: Text('Page $index')),
    childCount: 5,
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `controller` | `PageController?` | `null` | 页面控制器，用于控制页面跳转和监听滚动 |
| `scrollDirection` | `Axis` | `Axis.horizontal` | 滚动方向：水平或垂直 |
| `reverse` | `bool` | `false` | 是否反向滚动 |
| `pageSnapping` | `bool` | `true` | 是否启用页面吸附效果 |
| `onPageChanged` | `ValueChanged<int>?` | `null` | 页面切换时的回调函数 |
| `physics` | `ScrollPhysics?` | `null` | 滚动物理效果 |
| `allowImplicitScrolling` | `bool` | `false` | 是否允许隐式滚动（辅助功能相关） |
| `padEnds` | `bool` | `true` | 是否在两端添加填充 |
| `clipBehavior` | `Clip` | `Clip.hardEdge` | 内容裁剪行为 |
| `dragStartBehavior` | `DragStartBehavior` | `DragStartBehavior.start` | 拖拽开始行为 |
| `restorationId` | `String?` | `null` | 状态恢复标识符 |

## PageController 详解

`PageController` 是控制 `PageView` 的核心类，提供页面跳转、滚动监听等功能。

### 构造函数参数

```dart
PageController({
  int initialPage = 0,        // 初始页面索引
  bool keepPage = true,       // 是否保存当前页面位置
  double viewportFraction = 1.0, // 每个页面占视口的比例（0.0 - 1.0）
})
```

### 常用属性和方法

```dart
final controller = PageController(
  initialPage: 0,
  viewportFraction: 1.0,
);

// 获取当前页面索引
int currentPage = controller.page?.round() ?? 0;

// 跳转到指定页面（无动画）
controller.jumpToPage(2);

// 动画跳转到指定页面
controller.animateToPage(
  2,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// 跳转到下一页
controller.nextPage(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// 跳转到上一页
controller.previousPage(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// 监听滚动
controller.addListener(() {
  print('当前位置: ${controller.page}');
});

// 记得在 dispose 中释放
controller.dispose();
```

### viewportFraction 效果

```dart
// 显示相邻页面的部分内容，实现卡片轮播效果
PageController(viewportFraction: 0.85)
```

## 使用场景

### 1. 基础页面滚动

```dart
class BasicPageView extends StatefulWidget {
  @override
  State<BasicPageView> createState() => _BasicPageViewState();
}

class _BasicPageViewState extends State<BasicPageView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('基础 PageView')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _colors.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Container(
                  color: _colors[index],
                  child: Center(
                    child: Text(
                      'Page ${index + 1}',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('当前页面: ${_currentPage + 1} / ${_colors.length}'),
          ),
        ],
      ),
    );
  }
}
```

### 2. 引导页/欢迎页

```dart
class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.explore,
      title: '探索发现',
      description: '发现身边精彩内容，开启全新体验',
      color: Colors.blue,
    ),
    OnboardingItem(
      icon: Icons.favorite,
      title: '收藏喜欢',
      description: '一键收藏喜欢的内容，随时查看',
      color: Colors.pink,
    ),
    OnboardingItem(
      icon: Icons.share,
      title: '分享快乐',
      description: '与好友分享，让快乐加倍',
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 完成引导，跳转到主页
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text('跳过'),
              ),
            ),
            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 120,
                          color: item.color,
                        ),
                        SizedBox(height: 40),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 页面指示器和按钮
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 指示器
                  Row(
                    children: List.generate(_items.length, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _items[_currentPage].color
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // 下一步/开始按钮
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _items[_currentPage].color,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage == _items.length - 1 ? '开始使用' : '下一步',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
```

### 3. 图片轮播

```dart
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const ImageCarousel({
    required this.images,
    this.height = 200,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentPage < widget.images.length - 1) {
        _controller.nextPage(
          duration: Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      } else {
        _controller.animateToPage(
          0,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double value = 1.0;
                  if (_controller.position.haveDimensions) {
                    value = (_controller.page! - index).abs();
                    value = (1 - (value * 0.1)).clamp(0.9, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        // 指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return GestureDetector(
              onTap: () {
                _controller.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// 使用示例
ImageCarousel(
  images: [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
  ],
  height: 200,
  autoPlay: true,
  autoPlayInterval: Duration(seconds: 4),
)
```

### 4. Tab 联动

```dart
class TabPageViewSync extends StatefulWidget {
  @override
  State<TabPageViewSync> createState() => _TabPageViewSyncState();
}

class _TabPageViewSyncState extends State<TabPageViewSync>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  final List<String> _tabs = ['推荐', '热门', '最新', '关注', '收藏'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController();

    // 监听 TabController 变化
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tab + PageView 联动'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _tabs.length,
        onPageChanged: (index) {
          // 同步 TabBar（不触发动画）
          _tabController.index = index;
        },
        itemBuilder: (context, index) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pages,
                  size: 64,
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
                SizedBox(height: 16),
                Text(
                  _tabs[index],
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  '这是 ${_tabs[index]} 页面的内容',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### 5. 无限循环

```dart
class InfiniteLoopPageView extends StatefulWidget {
  final List<Widget> children;
  final bool autoPlay;
  final Duration interval;

  const InfiniteLoopPageView({
    required this.children,
    this.autoPlay = false,
    this.interval = const Duration(seconds: 3),
  });

  @override
  State<InfiniteLoopPageView> createState() => _InfiniteLoopPageViewState();
}

class _InfiniteLoopPageViewState extends State<InfiniteLoopPageView> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  // 使用一个很大的初始值实现"无限"滚动
  static const int _initialPage = 10000;

  int get _realItemCount => widget.children.length;
  int get _realIndex => _currentPage % _realItemCount;

  @override
  void initState() {
    super.initState();
    _currentPage = _initialPage;
    _controller = PageController(initialPage: _initialPage);

    if (widget.autoPlay && _realItemCount > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.interval, (timer) {
      _controller.nextPage(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final realIndex = index % _realItemCount;
              return widget.children[realIndex];
            },
          ),
        ),
        // 指示器
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_realItemCount, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _realIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// 使用示例
InfiniteLoopPageView(
  autoPlay: true,
  interval: Duration(seconds: 3),
  children: [
    Container(color: Colors.red, child: Center(child: Text('Page 1'))),
    Container(color: Colors.green, child: Center(child: Text('Page 2'))),
    Container(color: Colors.blue, child: Center(child: Text('Page 3'))),
  ],
)
```

## 页面指示器实现

### 1. 圆点指示器

```dart
class DotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final double spacing;

  const DotIndicator({
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.size = 8,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
```

### 2. 带动画的扩展指示器

```dart
class ExpandingDotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double expandedWidth;

  const ExpandingDotIndicator({
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.dotSize = 8,
    this.expandedWidth = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? expandedWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
```

### 3. 平滑滚动指示器

```dart
class SmoothPageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  const SmoothPageIndicator({
    required this.controller,
    required this.count,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.page ?? controller.initialPage.toDouble();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            // 计算每个点的活跃程度（0.0 - 1.0）
            final distance = (page - index).abs();
            final activeFactor = (1 - distance).clamp(0.0, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: size + (size * 0.5 * activeFactor),
              height: size,
              decoration: BoxDecoration(
                color: Color.lerp(inactiveColor, activeColor, activeFactor),
                borderRadius: BorderRadius.circular(size / 2),
              ),
            );
          }),
        );
      },
    );
  }
}
```

### 4. 数字指示器

```dart
class NumberIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final TextStyle? style;

  const NumberIndicator({
    required this.currentIndex,
    required this.itemCount,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${currentIndex + 1} / $itemCount',
        style: style ?? TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
```

## 垂直方向 PageView

```dart
class VerticalPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical, // 设置垂直方向
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.primaries[index % Colors.primaries.length],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '向上滑动',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_up,
                    size: 48,
                    color: Colors.white,
                  ),
                  Text(
                    'Page ${index + 1}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## 最佳实践

### 1. 及时释放 PageController

```dart
class MyPageView extends StatefulWidget {
  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose(); // 必须释放
    super.dispose();
  }
  
  // ...
}
```

### 2. 使用 AutomaticKeepAliveClientMixin 保持页面状态

```dart
class KeepAlivePage extends StatefulWidget {
  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持页面存活

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return Container(/* ... */);
  }
}
```

### 3. 大量页面使用 PageView.builder

```dart
// ✅ 推荐：懒加载，按需创建
PageView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => PageContent(index: index),
)

// ❌ 避免：一次性创建所有页面
PageView(
  children: List.generate(1000, (index) => PageContent(index: index)),
)
```

### 4. 禁用页面吸附实现自由滚动

```dart
PageView.builder(
  pageSnapping: false, // 禁用吸附
  physics: ClampingScrollPhysics(), // 使用 Clamping 物理效果
  itemCount: 10,
  itemBuilder: (context, index) => Container(),
)
```

### 5. 预缓存相邻页面

```dart
// 使用 cacheExtent 或结合 precacheImage 预加载图片
PageView.builder(
  controller: PageController(viewportFraction: 1.0),
  itemCount: images.length,
  itemBuilder: (context, index) {
    // 预缓存下一张图片
    if (index < images.length - 1) {
      precacheImage(NetworkImage(images[index + 1]), context);
    }
    return Image.network(images[index]);
  },
)
```

### 6. 处理键盘遮挡

```dart
// 在 PageView 内使用输入框时，使用 SingleChildScrollView 包裹
PageView(
  children: [
    SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            TextField(),
            // 其他内容
          ],
        ),
      ),
    ),
  ],
)
```

## 常见问题

### Q1: 如何获取当前页面索引？

```dart
// 方式一：使用 onPageChanged 回调
PageView(
  onPageChanged: (index) {
    print('当前页面: $index');
  },
)

// 方式二：通过 controller 获取
final currentPage = _controller.page?.round() ?? 0;
```

### Q2: 如何实现预加载？

```dart
// PageView 默认会预加载相邻页面
// 可以通过 allowImplicitScrolling 控制辅助功能的隐式滚动
PageView(
  allowImplicitScrolling: true,
)
```

### Q3: 页面切换时如何添加自定义动画？

```dart
// 监听 controller 实现自定义动画
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    final page = _controller.page ?? 0;
    // 根据 page 值计算动画效果
    return Transform(/* ... */);
  },
)
```

## 相关组件

- [ListView](./listview.md) - 列表视图，适合显示大量数据项
- [TabBarView](./tabbarview.md) - Tab 页面视图，与 TabBar 配合使用
- [SingleChildScrollView](./singlechildscrollview.md) - 单子组件滚动视图
- [CustomScrollView](./customscrollview.md) - 自定义滚动视图

## 官方文档

- [PageView API](https://api.flutter.dev/flutter/widgets/PageView-class.html)
- [PageController API](https://api.flutter.dev/flutter/widgets/PageController-class.html)
- [PageView Cookbook](https://docs.flutter.dev/cookbook/animation/page-route-animation)
