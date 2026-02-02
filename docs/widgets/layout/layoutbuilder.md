# LayoutBuilder

`LayoutBuilder` 是 Flutter 中的响应式布局构建器，它可以根据父组件提供的约束条件动态构建子组件。这使得我们能够根据可用空间的大小来调整布局，实现真正的自适应 UI。

## 基本用法

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth > 600) {
      return _buildWideLayout();
    } else {
      return _buildNarrowLayout();
    }
  },
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| builder | Widget Function(BuildContext, BoxConstraints) | 必需 | 根据约束构建子组件的回调函数 |

## BoxConstraints 属性

`builder` 回调中的 `BoxConstraints` 参数包含父组件传递的约束信息：

| 属性 | 类型 | 说明 |
|------|------|------|
| minWidth | double | 最小宽度约束 |
| maxWidth | double | 最大宽度约束 |
| minHeight | double | 最小高度约束 |
| maxHeight | double | 最大高度约束 |
| hasBoundedWidth | bool | 宽度是否有边界（maxWidth < infinity） |
| hasBoundedHeight | bool | 高度是否有边界（maxHeight < infinity） |
| isTight | bool | 约束是否是紧约束（min == max） |

### BoxConstraints 常用方法

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // 检查约束属性
    print('最大宽度: ${constraints.maxWidth}');
    print('最大高度: ${constraints.maxHeight}');
    print('宽度有边界: ${constraints.hasBoundedWidth}');
    print('是紧约束: ${constraints.isTight}');
    
    // 约束指定尺寸
    final constrainedSize = constraints.constrain(Size(200, 200));
    
    return Container();
  },
)
```

## 使用场景

### 1. 响应式布局（手机/平板）

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // 根据宽度判断设备类型
    if (constraints.maxWidth >= 1200) {
      // 桌面端：三栏布局
      return Row(
        children: [
          SizedBox(width: 250, child: NavigationPanel()),
          Expanded(child: ContentPanel()),
          SizedBox(width: 300, child: DetailPanel()),
        ],
      );
    } else if (constraints.maxWidth >= 600) {
      // 平板：两栏布局
      return Row(
        children: [
          SizedBox(width: 200, child: NavigationPanel()),
          Expanded(child: ContentPanel()),
        ],
      );
    } else {
      // 手机：单栏布局
      return ContentPanel();
    }
  },
)
```

### 2. 根据宽度切换 Row/Column

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isWide = constraints.maxWidth > 400;
    
    final children = [
      _buildInfoCard('用户总数', '12,345'),
      _buildInfoCard('今日活跃', '1,234'),
      _buildInfoCard('新增用户', '56'),
    ];
    
    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      );
    } else {
      return Column(
        children: children.map((child) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: child,
        )).toList(),
      );
    }
  },
)
```

### 3. 动态调整网格列数

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // 根据宽度计算列数
    int crossAxisCount;
    if (constraints.maxWidth >= 1200) {
      crossAxisCount = 6;
    } else if (constraints.maxWidth >= 900) {
      crossAxisCount = 4;
    } else if (constraints.maxWidth >= 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 20,
      itemBuilder: (context, index) => Card(
        child: Center(child: Text('Item $index')),
      ),
    );
  },
)
```

### 4. 自适应字体大小

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // 根据宽度计算字体大小
    double fontSize = constraints.maxWidth * 0.05;
    fontSize = fontSize.clamp(14.0, 32.0);
    
    return Text(
      '自适应标题',
      style: TextStyle(fontSize: fontSize),
    );
  },
)
```

### 5. 条件显示侧边栏

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final showSidebar = constraints.maxWidth > 800;
    
    return Row(
      children: [
        if (showSidebar)
          Container(
            width: 250,
            color: Colors.grey[200],
            child: ListView(
              children: [
                ListTile(leading: Icon(Icons.home), title: Text('首页')),
                ListTile(leading: Icon(Icons.person), title: Text('个人中心')),
                ListTile(leading: Icon(Icons.settings), title: Text('设置')),
              ],
            ),
          ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Text('主内容区域'),
          ),
        ),
      ],
    );
  },
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class LayoutBuilderDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LayoutBuilder 自适应网格')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AdaptiveGrid(constraints: constraints);
        },
      ),
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  final BoxConstraints constraints;

  const AdaptiveGrid({required this.constraints});

  @override
  Widget build(BuildContext context) {
    // 计算每个卡片的理想宽度
    const double minCardWidth = 150;
    const double maxCardWidth = 250;
    const double spacing = 16;

    // 计算可用宽度（减去边距）
    final availableWidth = constraints.maxWidth - spacing * 2;
    
    // 计算列数
    int crossAxisCount = (availableWidth / minCardWidth).floor();
    crossAxisCount = crossAxisCount.clamp(1, 6);
    
    // 计算实际卡片宽度
    final cardWidth = (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
    final childAspectRatio = cardWidth / (cardWidth * 1.2);

    return Padding(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示约束信息
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前约束信息',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('可用宽度: ${constraints.maxWidth.toStringAsFixed(0)}px'),
                Text('可用高度: ${constraints.maxHeight.toStringAsFixed(0)}px'),
                Text('列数: $crossAxisCount'),
                Text('卡片宽度: ${cardWidth.toStringAsFixed(0)}px'),
              ],
            ),
          ),
          // 自适应网格
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return ProductCard(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final int index;

  const ProductCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red[100],
      Colors.blue[100],
      Colors.green[100],
      Colors.orange[100],
      Colors.purple[100],
      Colors.teal[100],
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(Icons.image, size: 48, color: Colors.white70),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '商品 ${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '¥${(index + 1) * 99}',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
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

## 最佳实践

### 1. 配合 MediaQuery 使用

```dart
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final orientation = MediaQuery.of(context).orientation;
  
  return LayoutBuilder(
    builder: (context, constraints) {
      // MediaQuery 提供屏幕级别信息
      // LayoutBuilder 提供父组件约束信息
      
      // 结合使用，实现更精确的响应式布局
      final isLandscape = orientation == Orientation.landscape;
      final isWideScreen = screenWidth > 1200;
      final hasEnoughSpace = constraints.maxWidth > 600;
      
      if (isWideScreen && hasEnoughSpace) {
        return _buildDesktopLayout();
      } else if (isLandscape || hasEnoughSpace) {
        return _buildTabletLayout();
      } else {
        return _buildMobileLayout();
      }
    },
  );
}
```

### 2. 避免在 builder 中进行复杂计算

```dart
// ✗ 不推荐：每次重建都会创建新列表
LayoutBuilder(
  builder: (context, constraints) {
    final items = List.generate(1000, (i) => ExpensiveWidget(i));
    return ListView(children: items);
  },
)

// ✓ 推荐：将数据移到外部
class MyWidget extends StatelessWidget {
  final List<Widget> items = List.generate(1000, (i) => ExpensiveWidget(i));
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(children: items);
      },
    );
  }
}
```

### 3. 定义断点常量

```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= Breakpoints.desktop) {
      return DesktopLayout();
    } else if (constraints.maxWidth >= Breakpoints.tablet) {
      return TabletLayout();
    } else {
      return MobileLayout();
    }
  },
)
```

### 4. 使用扩展方法简化判断

```dart
extension BoxConstraintsX on BoxConstraints {
  bool get isMobile => maxWidth < 600;
  bool get isTablet => maxWidth >= 600 && maxWidth < 1200;
  bool get isDesktop => maxWidth >= 1200;
  
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}

// 使用
LayoutBuilder(
  builder: (context, constraints) {
    return constraints.responsive(
      mobile: MobileLayout(),
      tablet: TabletLayout(),
      desktop: DesktopLayout(),
    );
  },
)
```

## 注意事项

1. **无限约束问题**：在 `ListView` 或 `Column` 中使用时，可能会收到无限高度约束，需要用 `SizedBox` 或 `Expanded` 包装
2. **性能考虑**：`builder` 会在约束变化时重新调用，避免在其中执行耗时操作
3. **与 MediaQuery 的区别**：`LayoutBuilder` 获取的是父组件的约束，`MediaQuery` 获取的是整个屏幕的信息

## 相关组件

- [MediaQuery](../basics/mediaquery.md) - 获取屏幕和设备信息
- [OrientationBuilder](./orientationbuilder.md) - 根据设备方向构建布局
- [AspectRatio](./aspectratio.md) - 保持固定宽高比
