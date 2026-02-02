# 屏幕适配

在移动端开发中，不同设备有着不同的屏幕尺寸和像素密度。为了让应用在各种设备上都能呈现良好的视觉效果，屏幕适配是必不可少的环节。

本章介绍两种主流适配方案：
1. **flutter_screenutil** - 基于设计稿尺寸的等比缩放方案
2. **MediaQuery** - Flutter 原生的响应式布局方案

## 为什么需要屏幕适配？

假设设计稿是基于 375×812（iPhone X）设计的：

```
设计稿上一个按钮宽度是 200px
在 iPhone X 上显示正常
但在 iPad 上会显得太小
在小屏手机上可能会溢出
```

适配的目标是让 UI 元素在不同设备上保持一致的视觉比例。

## 方案一：flutter_screenutil

`flutter_screenutil` 是最流行的 Flutter 屏幕适配库，通过等比缩放实现适配。

### 安装

```yaml
dependencies:
  flutter_screenutil: ^5.9.3
```

### 初始化

在应用入口处初始化，设置设计稿尺寸：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 ScreenUtilInit 包裹 MaterialApp
    return ScreenUtilInit(
      // 设计稿尺寸（通常是设计师给的设计稿宽高，单位 dp）
      designSize: const Size(375, 812),
      // 是否根据宽度/高度中的最小值适配文字
      minTextAdapt: true,
      // 支持分屏模式
      splitScreenMode: true,
      // builder 返回应用
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ScreenUtil Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            // 主题中也可以使用 .sp 适配字体
            textTheme: Typography.englishLike2018.apply(
              fontSizeFactor: 1.sp,
            ),
          ),
          home: child,
        );
      },
      child: const HomePage(),
    );
  }
}
```

### 核心 API

| 扩展方法 | 说明 | 示例 |
|----------|------|------|
| `.w` | 根据屏幕宽度适配 | `100.w` |
| `.h` | 根据屏幕高度适配 | `100.h` |
| `.r` | 根据宽高最小值适配（用于圆形） | `50.r` |
| `.sp` | 字体大小适配 | `16.sp` |
| `.sw` | 屏幕宽度的比例 | `0.5.sw` = 50% 屏幕宽度 |
| `.sh` | 屏幕高度的比例 | `0.5.sh` = 50% 屏幕高度 |

### 基本使用

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '屏幕适配示例',
          style: TextStyle(fontSize: 18.sp), // 字体适配
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w), // 边距适配
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 宽度适配
            Container(
              width: 200.w,
              height: 100.h,
              color: Colors.blue,
              child: Center(
                child: Text(
                  '200.w × 100.h',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            // 正方形使用 .r 确保是正方形
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  '100.r',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            // 圆形头像
            CircleAvatar(
              radius: 40.r,
              backgroundColor: Colors.orange,
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            // 全屏宽度按钮
            SizedBox(
              width: 1.sw, // 100% 屏幕宽度
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  '全屏宽度按钮',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 边距和圆角快捷方式

```dart
// 原始写法
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 12.h,
  ),
  child: Container(),
)

// 快捷写法
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12).w,
  child: Container(),
)

// 使用 R 前缀的响应式类
Container(
  padding: REdgeInsets.all(16), // 等同于 EdgeInsets.all(16.r)
  margin: REdgeInsets.symmetric(horizontal: 20),
  child: Text('内容'),
)

// 圆角
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12).w,
    // 或者
    borderRadius: BorderRadius.all(Radius.circular(12.r)),
  ),
)
```

### 获取屏幕信息

```dart
class ScreenInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('屏幕宽度: ${ScreenUtil().screenWidth}'),
        Text('屏幕高度: ${ScreenUtil().screenHeight}'),
        Text('像素密度: ${ScreenUtil().pixelRatio}'),
        Text('状态栏高度: ${ScreenUtil().statusBarHeight}'),
        Text('底部安全区: ${ScreenUtil().bottomBarHeight}'),
        Text('宽度缩放比: ${ScreenUtil().scaleWidth}'),
        Text('高度缩放比: ${ScreenUtil().scaleHeight}'),
        Text('屏幕方向: ${ScreenUtil().orientation}'),
      ],
    );
  }
}
```

### 间距快捷组件

```dart
Column(
  children: [
    Text('第一行'),
    20.verticalSpace, // 等同于 SizedBox(height: 20.h)
    Text('第二行'),
    30.verticalSpace,
    Text('第三行'),
  ],
)

Row(
  children: [
    Text('左'),
    20.horizontalSpace, // 等同于 SizedBox(width: 20.w)
    Text('右'),
  ],
)
```

### 适配最佳实践

```dart
class AdaptiveCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    required this.title,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### .w 和 .h 的选择

```dart
// ❌ 错误：正方形使用 .w 和 .h 会变成长方形
Container(
  width: 100.w,
  height: 100.h, // 在不同宽高比设备上会变形
)

// ✅ 正确：正方形统一使用 .r 或 .w
Container(
  width: 100.r,
  height: 100.r, // 始终是正方形
)

// ✅ 或者统一用 .w
Container(
  width: 100.w,
  height: 100.w, // 始终是正方形
)

// 💡 何时使用 .h？
// 当你确实需要根据屏幕高度来适配时
// 比如：需要填满剩余高度的容器
Container(
  height: 0.3.sh, // 占屏幕高度的 30%
)
```

---

## 方案二：MediaQuery 响应式适配

MediaQuery 是 Flutter 原生提供的获取设备信息的方式，适合实现响应式布局。

### 获取设备信息

```dart
class MediaQueryDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取 MediaQuery 数据
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('MediaQuery 信息')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('屏幕尺寸', '${mediaQuery.size}'),
            _buildInfoRow('屏幕宽度', '${mediaQuery.size.width}'),
            _buildInfoRow('屏幕高度', '${mediaQuery.size.height}'),
            _buildInfoRow('像素密度', '${mediaQuery.devicePixelRatio}'),
            _buildInfoRow('顶部安全区', '${mediaQuery.padding.top}'),
            _buildInfoRow('底部安全区', '${mediaQuery.padding.bottom}'),
            _buildInfoRow('文字缩放', '${mediaQuery.textScaleFactor}'),
            _buildInfoRow('屏幕方向', '${mediaQuery.orientation}'),
            _buildInfoRow('是否暗色模式', '${mediaQuery.platformBrightness}'),
            _buildInfoRow('是否高对比度', '${mediaQuery.highContrast}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
```

### 响应式布局

根据屏幕宽度切换布局：

```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 定义断点
    const mobileBreakpoint = 600.0;
    const tabletBreakpoint = 900.0;
    
    if (screenWidth < mobileBreakpoint) {
      return MobileLayout();
    } else if (screenWidth < tabletBreakpoint) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  }
}

// 手机布局：单列
class MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(child: Text('$index')),
        title: Text('项目 $index'),
        subtitle: Text('手机布局'),
      ),
    );
  }
}

// 平板布局：两列
class TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: 10,
      itemBuilder: (context, index) => Card(
        child: Center(child: Text('项目 $index')),
      ),
    );
  }
}

// 桌面布局：三列 + 侧边栏
class DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 侧边栏
        Container(
          width: 250,
          color: Colors.grey[200],
          child: ListView(
            children: List.generate(5, (index) => ListTile(
              leading: Icon(Icons.folder),
              title: Text('菜单 $index'),
            )),
          ),
        ),
        // 主内容区
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: 12,
            itemBuilder: (context, index) => Card(
              child: Center(child: Text('项目 $index')),
            ),
          ),
        ),
      ],
    );
  }
}
```

### LayoutBuilder 组件

LayoutBuilder 可以获取父容器的约束信息，实现更精细的响应式：

```dart
class ResponsiveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据可用宽度决定布局
        if (constraints.maxWidth < 400) {
          // 窄屏：垂直布局
          return Column(
            children: [
              _buildImage(constraints.maxWidth),
              _buildContent(),
            ],
          );
        } else {
          // 宽屏：水平布局
          return Row(
            children: [
              _buildImage(constraints.maxWidth * 0.4),
              Expanded(child: _buildContent()),
            ],
          );
        }
      },
    );
  }

  Widget _buildImage(double width) {
    return Container(
      width: width,
      height: 150,
      color: Colors.blue[100],
      child: Icon(Icons.image, size: 50),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('标题', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('这是一段描述文字，会根据布局方向自动调整。'),
        ],
      ),
    );
  }
}
```

### OrientationBuilder 组件

根据屏幕方向调整布局：

```dart
class OrientationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('屏幕方向适配')),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.count(
            // 横屏显示 4 列，竖屏显示 2 列
            crossAxisCount: orientation == Orientation.landscape ? 4 : 2,
            children: List.generate(20, (index) {
              return Card(
                color: Colors.primaries[index % Colors.primaries.length],
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
```

### 自适应网格列数

```dart
class AdaptiveGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('自适应网格')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 计算最佳列数（每项最小宽度 150）
          final crossAxisCount = (constraints.maxWidth / 150).floor();
          
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount.clamp(2, 6), // 限制在 2-6 列
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: 30,
            itemBuilder: (context, index) => Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.widgets, size: 32),
                    SizedBox(height: 8),
                    Text('Item $index'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 安全区域适配

```dart
class SafeAreaDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 可以选择性地启用各边的安全区
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: Column(
          children: [
            Text('内容在安全区域内'),
            Spacer(),
            // 底部按钮
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('确定'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 手动获取安全区域边距
class ManualSafeArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    
    return Container(
      padding: EdgeInsets.only(
        top: padding.top,
        bottom: padding.bottom,
      ),
      child: Column(
        children: [
          Text('顶部安全区: ${padding.top}'),
          Spacer(),
          Text('底部安全区: ${padding.bottom}'),
        ],
      ),
    );
  }
}
```

---

## 封装响应式工具类

结合两种方案，封装一个实用的响应式工具类：

```dart
import 'package:flutter/material.dart';

/// 设备类型枚举
enum DeviceType { mobile, tablet, desktop }

/// 响应式工具类
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late DeviceType deviceType;
  
  /// 初始化（在应用入口调用）
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    
    // 判断设备类型
    if (screenWidth < 600) {
      deviceType = DeviceType.mobile;
    } else if (screenWidth < 1200) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.desktop;
    }
  }
  
  /// 是否是手机
  static bool get isMobile => deviceType == DeviceType.mobile;
  
  /// 是否是平板
  static bool get isTablet => deviceType == DeviceType.tablet;
  
  /// 是否是桌面
  static bool get isDesktop => deviceType == DeviceType.desktop;
  
  /// 根据设备类型返回不同值
  static T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
  
  /// 根据屏幕宽度百分比计算
  static double wp(double percentage) => blockSizeHorizontal * percentage;
  
  /// 根据屏幕高度百分比计算
  static double hp(double percentage) => blockSizeVertical * percentage;
}

/// 响应式布局组件
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### 使用示例

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 初始化
    Responsive.init(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('响应式布局'),
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      // 根据设备类型显示不同的 FAB
      floatingActionButton: Responsive.isMobile
          ? FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            )
          : FloatingActionButton.extended(
              onPressed: () {},
              label: Text('添加'),
              icon: Icon(Icons.add),
            ),
    );
  }
  
  Widget _buildMobileLayout() {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) => ListTile(
        title: Text('项目 $index'),
      ),
    );
  }
  
  Widget _buildTabletLayout() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
      ),
      itemCount: 20,
      itemBuilder: (context, index) => Card(
        child: Center(child: Text('项目 $index')),
      ),
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('首页'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('设置'),
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
            ),
            itemCount: 20,
            itemBuilder: (context, index) => Card(
              child: Center(child: Text('项目 $index')),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 两种方案对比

| 特性 | flutter_screenutil | MediaQuery |
|------|-------------------|------------|
| 适配原理 | 等比缩放 | 响应式断点 |
| 学习成本 | 低 | 中 |
| 适用场景 | UI 还原设计稿 | 多端响应式布局 |
| 代码侵入性 | 高（需要加 .w/.h） | 低 |
| 灵活性 | 一般 | 高 |
| 维护成本 | 低 | 中 |
| 推荐场景 | 纯移动端应用 | 跨平台/响应式应用 |

## 最佳实践

### 1. 移动端应用推荐

```dart
// 使用 flutter_screenutil，简单直接
Container(
  width: 200.w,
  height: 100.h,
  padding: EdgeInsets.all(16.r),
  child: Text('Hello', style: TextStyle(fontSize: 16.sp)),
)
```

### 2. 跨平台应用推荐

```dart
// 使用 MediaQuery + LayoutBuilder 实现响应式
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    }
    return DesktopLayout();
  },
)
```

### 3. 混合使用

```dart
// 响应式结构 + screenutil 细节适配
ResponsiveBuilder(
  mobile: Container(
    padding: EdgeInsets.all(16.w),
    child: MobileContent(),
  ),
  desktop: Container(
    padding: EdgeInsets.all(24.w),
    child: DesktopContent(),
  ),
)
```

### 4. 字体适配注意事项

```dart
// 禁止系统字体缩放影响（可选）
MaterialApp(
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: child!,
    );
  },
)
```

## 常见问题

### Q1: .w 和 .h 什么时候用？

- 宽度、水平边距、水平间距：用 `.w`
- 正方形、圆形、圆角：用 `.r` 或统一用 `.w`
- 需要占满屏幕高度的特殊场景：用 `.h` 或 `.sh`

### Q2: 文字大小用什么？

始终使用 `.sp`，它会根据屏幕适配并可选择是否跟随系统字体设置。

### Q3: 设计稿尺寸怎么设置？

向设计师确认设计稿的基准尺寸，常见的有：
- iPhone X: 375×812
- iPhone 14: 390×844  
- Android 常用: 360×690

### Q4: 热重载后适配失效？

确保 `ScreenUtilInit` 在 `MaterialApp` 外层，并且使用 `builder` 参数。

## 总结

- **flutter_screenutil** 适合快速开发移动端应用，代码简洁
- **MediaQuery** 适合构建跨平台响应式应用，灵活性强
- 两者可以结合使用，取长补短
- 根据项目需求选择合适的方案

## 相关资源

- [flutter_screenutil 官方文档](https://pub.dev/packages/flutter_screenutil)
- [Flutter 响应式设计指南](https://docs.flutter.dev/ui/layout/responsive/adaptive-responsive)
- [MediaQuery 官方文档](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
