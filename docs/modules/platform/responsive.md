# 响应式布局

Flutter 支持从手机、平板到桌面、Web 等多种屏幕尺寸。本章介绍如何构建自适应的响应式界面。

## 响应式设计原理

```
┌─────────────────────────────────────────────────────────────────┐
│                    响应式布局断点                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   手机          平板           桌面小屏        桌面大屏           │
│   < 600        600-900       900-1200       > 1200              │
│                                                                 │
│   ┌────┐      ┌────────┐    ┌──────────┐   ┌────────────┐      │
│   │    │      │   │    │    │ │        │   │ │    │     │      │
│   │    │      │   │    │    │ │        │   │ │    │     │      │
│   │    │      │   │    │    │ │        │   │ │    │     │      │
│   └────┘      └────────┘    └──────────┘   └────────────┘      │
│   单列         双列侧边       三栏布局        多面板布局          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 获取屏幕信息

### MediaQuery

```dart
class ScreenInfo extends StatelessWidget {
  const ScreenInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('屏幕宽度: ${mediaQuery.size.width}'),
        Text('屏幕高度: ${mediaQuery.size.height}'),
        Text('设备像素比: ${mediaQuery.devicePixelRatio}'),
        Text('方向: ${mediaQuery.orientation}'),
        Text('顶部安全区: ${mediaQuery.padding.top}'),
        Text('底部安全区: ${mediaQuery.padding.bottom}'),
        Text('是否深色模式: ${mediaQuery.platformBrightness == Brightness.dark}'),
        Text('文字缩放: ${mediaQuery.textScaler.scale(1.0)}'),
      ],
    );
  }
}

// 性能优化：使用 MediaQuery.sizeOf 只监听尺寸变化
class OptimizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 只在尺寸变化时重建
    final size = MediaQuery.sizeOf(context);
    
    // 只获取方向
    final orientation = MediaQuery.orientationOf(context);
    
    // 只获取视图内边距
    final padding = MediaQuery.viewPaddingOf(context);
    
    return Container();
  }
}
```

### LayoutBuilder

```dart
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据可用宽度决定布局
        if (constraints.maxWidth < 600) {
          return const MobileLayout();
        } else if (constraints.maxWidth < 900) {
          return const TabletLayout();
        } else {
          return const DesktopLayout();
        }
      },
    );
  }
}
```

## 响应式工具类

### 断点定义

```dart
/// 响应式断点
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double desktopLarge = 1800;
}

/// 设备类型
enum DeviceType {
  mobile,
  tablet,
  desktop,
  desktopLarge,
}

/// 响应式工具
class ResponsiveUtils {
  final BuildContext context;
  
  ResponsiveUtils(this.context);
  
  /// 获取屏幕宽度
  double get screenWidth => MediaQuery.sizeOf(context).width;
  
  /// 获取屏幕高度
  double get screenHeight => MediaQuery.sizeOf(context).height;
  
  /// 获取设备类型
  DeviceType get deviceType {
    if (screenWidth < Breakpoints.mobile) return DeviceType.mobile;
    if (screenWidth < Breakpoints.tablet) return DeviceType.tablet;
    if (screenWidth < Breakpoints.desktop) return DeviceType.desktop;
    return DeviceType.desktopLarge;
  }
  
  /// 是否为移动设备
  bool get isMobile => screenWidth < Breakpoints.mobile;
  
  /// 是否为平板
  bool get isTablet => 
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  
  /// 是否为桌面
  bool get isDesktop => screenWidth >= Breakpoints.tablet;
  
  /// 是否为大屏桌面
  bool get isDesktopLarge => screenWidth >= Breakpoints.desktopLarge;
  
  /// 根据设备类型返回值
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? desktopLarge,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.desktopLarge:
        return desktopLarge ?? desktop ?? tablet ?? mobile;
    }
  }
  
  /// 响应式间距
  double get spacing => responsive(
    mobile: 8,
    tablet: 12,
    desktop: 16,
    desktopLarge: 24,
  );
  
  /// 响应式内边距
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: responsive(
      mobile: 16,
      tablet: 24,
      desktop: 32,
      desktopLarge: 48,
    ),
    vertical: responsive(
      mobile: 16,
      tablet: 20,
      desktop: 24,
    ),
  );
}

// 扩展方法，方便使用
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
```

### 使用示例

```dart
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final resp = context.responsive;
    
    return Padding(
      padding: resp.pagePadding,
      child: Column(
        children: [
          // 响应式文字大小
          Text(
            '标题',
            style: TextStyle(
              fontSize: resp.responsive(
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
          ),
          SizedBox(height: resp.spacing),
          // 响应式网格
          GridView.count(
            crossAxisCount: resp.responsive(
              mobile: 2,
              tablet: 3,
              desktop: 4,
              desktopLarge: 6,
            ),
            children: [...],
          ),
        ],
      ),
    );
  }
}
```

## 响应式组件

### ResponsiveBuilder

```dart
/// 响应式构建器
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DeviceType deviceType;
        if (constraints.maxWidth < Breakpoints.mobile) {
          deviceType = DeviceType.mobile;
        } else if (constraints.maxWidth < Breakpoints.tablet) {
          deviceType = DeviceType.tablet;
        } else if (constraints.maxWidth < Breakpoints.desktop) {
          deviceType = DeviceType.desktop;
        } else {
          deviceType = DeviceType.desktopLarge;
        }
        
        return builder(context, deviceType);
      },
    );
  }
}

// 使用示例
class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return ListView.builder(
              itemBuilder: (context, index) => ProductListTile(index: index),
            );
          case DeviceType.tablet:
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) => ProductCard(index: index),
            );
          case DeviceType.desktop:
          case DeviceType.desktopLarge:
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (context, index) => ProductCard(index: index),
            );
        }
      },
    );
  }
}
```

### AdaptiveScaffold

```dart
/// 自适应脚手架
class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final List<NavigationItem> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  
  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return _buildMobileLayout(context);
          case DeviceType.tablet:
            return _buildTabletLayout(context);
          case DeviceType.desktop:
          case DeviceType.desktopLarge:
            return _buildDesktopLayout(context);
        }
      },
    );
  }

  // 移动端：底部导航栏
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  // 平板：可收起的导航栏
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: destinations.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  // 桌面：完整侧边栏
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Column(
              children: [
                // 应用标题
                Container(
                  height: 64,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(height: 1),
                // 导航列表
                Expanded(
                  child: ListView.builder(
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final item = destinations[index];
                      final isSelected = index == selectedIndex;
                      
                      return ListTile(
                        leading: Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : null,
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : null,
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : null,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () => onDestinationSelected(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// 导航项
class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
```

## 响应式网格

### 自适应网格

```dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 200,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算每行可放置的项目数
        final crossAxisCount = (constraints.maxWidth / minItemWidth).floor();
        final actualCrossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: actualCrossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
```

### 瀑布流布局

```dart
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ResponsiveStaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  
  const ResponsiveStaggeredGrid({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final resp = context.responsive;
    
    return MasonryGridView.count(
      crossAxisCount: resp.responsive(
        mobile: 2,
        tablet: 3,
        desktop: 4,
        desktopLarge: 6,
      ),
      mainAxisSpacing: resp.spacing,
      crossAxisSpacing: resp.spacing,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
```

## Master-Detail 布局

```dart
class MasterDetailLayout<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, bool isSelected) masterItemBuilder;
  final Widget Function(T? item) detailBuilder;
  final String masterTitle;
  
  const MasterDetailLayout({
    super.key,
    required this.items,
    required this.masterItemBuilder,
    required this.detailBuilder,
    required this.masterTitle,
  });

  @override
  State<MasterDetailLayout<T>> createState() => _MasterDetailLayoutState<T>();
}

class _MasterDetailLayoutState<T> extends State<MasterDetailLayout<T>> {
  T? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.mobile) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout(deviceType);
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.masterTitle)),
              body: _buildMasterList(
                onItemTap: (item) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(),
                        body: widget.detailBuilder(item),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(DeviceType deviceType) {
    final masterWidth = deviceType == DeviceType.tablet ? 300.0 : 350.0;
    
    return Row(
      children: [
        SizedBox(
          width: masterWidth,
          child: Column(
            children: [
              AppBar(
                title: Text(widget.masterTitle),
                automaticallyImplyLeading: false,
              ),
              Expanded(
                child: _buildMasterList(
                  onItemTap: (item) {
                    setState(() => _selectedItem = item);
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedItem != null
              ? widget.detailBuilder(_selectedItem)
              : const Center(
                  child: Text('选择一个项目查看详情'),
                ),
        ),
      ],
    );
  }

  Widget _buildMasterList({required ValueChanged<T> onItemTap}) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = item == _selectedItem;
        
        return InkWell(
          onTap: () => onItemTap(item),
          child: widget.masterItemBuilder(item, isSelected),
        );
      },
    );
  }
}
```

## 方向适配

```dart
class OrientationAdaptive extends StatelessWidget {
  final Widget portrait;
  final Widget landscape;
  
  const OrientationAdaptive({
    super.key,
    required this.portrait,
    required this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return portrait;
        } else {
          return landscape;
        }
      },
    );
  }
}

// 使用示例
class MediaPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrientationAdaptive(
      portrait: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayer(),
          ),
          Expanded(child: VideoControls()),
          Expanded(child: RelatedVideos()),
        ],
      ),
      landscape: Row(
        children: [
          Expanded(
            flex: 2,
            child: VideoPlayer(),
          ),
          Expanded(
            child: Column(
              children: [
                VideoControls(),
                Expanded(child: RelatedVideos()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Flex 响应式布局

### Wrap 组件

```dart
class ResponsiveWrap extends StatelessWidget {
  const ResponsiveWrap({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16, // 水平间距
      runSpacing: 16, // 垂直间距
      alignment: WrapAlignment.center,
      children: List.generate(
        10,
        (index) => Container(
          width: 150,
          height: 100,
          color: Colors.primaries[index % Colors.primaries.length],
          child: Center(child: Text('Item $index')),
        ),
      ),
    );
  }
}
```

### Flexible 响应式

```dart
class FlexibleLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;
    
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      children: [
        Flexible(
          flex: isWide ? 1 : 0,
          child: Container(
            height: isWide ? null : 200,
            color: Colors.blue,
            child: const Center(child: Text('区域 A')),
          ),
        ),
        Flexible(
          flex: isWide ? 2 : 0,
          child: Container(
            height: isWide ? null : 300,
            color: Colors.green,
            child: const Center(child: Text('区域 B')),
          ),
        ),
      ],
    );
  }
}
```

## 文字适配

### 响应式文字大小

```dart
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    // 基于屏幕宽度计算字体大小
    double scaleFactor;
    if (screenWidth < 600) {
      scaleFactor = 1.0;
    } else if (screenWidth < 900) {
      scaleFactor = 1.1;
    } else {
      scaleFactor = 1.2;
    }
    
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    
    return Text(
      text,
      style: baseStyle?.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * scaleFactor,
      ),
    );
  }
}
```

### 最大行宽限制

```dart
class ReadableWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  
  const ReadableWidth({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// 使用示例
class ArticlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ReadableWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('文章标题', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            const Text(
              '这是文章的正文内容，限制最大宽度可以提高长文本的可读性...',
            ),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

::: tip 响应式设计要点
1. **使用相对单位** - 优先使用 Flexible、Expanded 而非固定尺寸
2. **断点设计** - 定义清晰的断点，统一管理
3. **内容优先** - 根据内容决定断点，而非设备
4. **渐进增强** - 先设计小屏，再扩展到大屏
5. **测试多尺寸** - 在不同设备和窗口大小下测试
:::

::: warning 常见问题
- 避免硬编码尺寸值
- 注意文字在小屏幕上的可读性
- 处理好横竖屏切换的状态保持
- 考虑不同设备的交互方式差异（触摸 vs 鼠标）
:::

## 参考资源

- [Flutter 官方响应式设计指南](https://docs.flutter.dev/development/ui/layout/responsive)
- [Material Design 响应式布局](https://m3.material.io/foundations/adaptive-design)
