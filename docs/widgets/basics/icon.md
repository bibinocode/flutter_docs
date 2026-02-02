# Icon

`Icon` 是 Flutter 中用于显示矢量图标的组件，支持 Material Icons、Cupertino Icons 以及自定义图标字体。

## 基本用法

```dart
// Material 图标
Icon(Icons.favorite)

// Cupertino 图标
Icon(CupertinoIcons.heart)

// 带样式的图标
Icon(
  Icons.star,
  size: 32,
  color: Colors.amber,
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `icon` | `IconData?` | 图标数据（必需） |
| `size` | `double?` | 图标大小，默认 24 |
| `color` | `Color?` | 图标颜色 |
| `semanticLabel` | `String?` | 无障碍标签 |
| `textDirection` | `TextDirection?` | 图标方向 |
| `fill` | `double?` | 填充程度（0.0-1.0） |
| `weight` | `double?` | 笔画粗细 |
| `grade` | `double?` | 粗细等级 |
| `opticalSize` | `double?` | 视觉大小 |
| `shadows` | `List&lt;Shadow&gt;?` | 图标阴影 |

## Material Icons 分类

| 类别 | 示例 | 说明 |
|------|------|------|
| 基础 | `Icons.home`, `Icons.search` | 常用操作图标 |
| 导航 | `Icons.arrow_back`, `Icons.menu` | 导航相关 |
| 通知 | `Icons.notifications`, `Icons.alarm` | 提醒通知 |
| 社交 | `Icons.share`, `Icons.person` | 社交功能 |
| 媒体 | `Icons.play_arrow`, `Icons.pause` | 音视频控制 |
| 文件 | `Icons.folder`, `Icons.file_copy` | 文件操作 |
| 编辑 | `Icons.edit`, `Icons.delete` | 编辑操作 |
| 状态 | `Icons.check`, `Icons.close`, `Icons.error` | 状态指示 |

## 使用场景

### 1. 基础图标展示

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // 默认图标
    Icon(Icons.home),
    
    // 自定义大小和颜色
    Icon(Icons.favorite, size: 32, color: Colors.red),
    
    // 带阴影
    Icon(
      Icons.star,
      size: 40,
      color: Colors.amber,
      shadows: [
        Shadow(
          color: Colors.amber.withOpacity(0.5),
          blurRadius: 12,
        ),
      ],
    ),
  ],
)
```

### 2. 图标变体（Material Symbols）

```dart
// 需要在 pubspec.yaml 中添加 material_symbols_icons 包
// 或使用 Flutter 3.16+ 内置支持

// 不同填充程度
Row(
  children: [
    Icon(Icons.settings, fill: 0), // 轮廓
    Icon(Icons.settings, fill: 1), // 填充
  ],
)

// 不同粗细
Row(
  children: [
    Icon(Icons.search, weight: 100), // 细
    Icon(Icons.search, weight: 400), // 正常
    Icon(Icons.search, weight: 700), // 粗
  ],
)
```

### 3. 图标按钮

```dart
// 使用 IconButton
IconButton(
  icon: Icon(Icons.favorite_border),
  onPressed: () {},
  color: Colors.red,
  iconSize: 32,
  tooltip: '添加收藏',
)

// 切换图标状态
StatefulBuilder(
  builder: (context, setState) {
    bool isFavorite = false;
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
      onPressed: () => setState(() => isFavorite = !isFavorite),
    );
  },
)
```

### 4. 带徽章的图标

```dart
// 使用 Badge Widget
Badge(
  label: Text('3'),
  child: Icon(Icons.notifications),
)

// 自定义徽章
Stack(
  clipBehavior: Clip.none,
  children: [
    Icon(Icons.shopping_cart, size: 32),
    Positioned(
      right: -8,
      top: -8,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          '5',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ),
    ),
  ],
)
```

### 5. 动画图标

```dart
// AnimatedIcon 动画图标
class AnimatedIconDemo extends StatefulWidget {
  @override
  _AnimatedIconDemoState createState() => _AnimatedIconDemoState();
}

class _AnimatedIconDemoState extends State<AnimatedIconDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _controller,
        size: 32,
      ),
      onPressed: () {
        setState(() {
          _isPlaying = !_isPlaying;
          _isPlaying ? _controller.forward() : _controller.reverse();
        });
      },
    );
  }
}
```

### 6. 自定义图标字体

```yaml
# 1. 在 pubspec.yaml 中声明字体
flutter:
  fonts:
    - family: CustomIcons
      fonts:
        - asset: assets/fonts/custom_icons.ttf
```

```dart
// 2. 定义图标数据
class CustomIcons {
  CustomIcons._();
  
  static const String _fontFamily = 'CustomIcons';
  
  static const IconData logo = IconData(
    0xe900,
    fontFamily: _fontFamily,
  );
  static const IconData custom_star = IconData(
    0xe901,
    fontFamily: _fontFamily,
  );
}

// 3. 使用自定义图标
Icon(CustomIcons.logo, size: 48)
```

### 7. Cupertino 图标

```dart
// 需要导入 cupertino_icons 包
import 'package:flutter/cupertino.dart';

Row(
  children: [
    Icon(CupertinoIcons.heart),
    Icon(CupertinoIcons.heart_fill),
    Icon(CupertinoIcons.bell),
    Icon(CupertinoIcons.gear),
    Icon(CupertinoIcons.person),
  ],
)
```

### 8. 响应主题的图标

```dart
// 图标颜色跟随主题
Icon(
  Icons.brightness_6,
  color: Theme.of(context).iconTheme.color,
)

// 在 IconTheme 中设置默认样式
IconTheme(
  data: IconThemeData(
    color: Colors.blue,
    size: 28,
    opacity: 0.8,
  ),
  child: Row(
    children: [
      Icon(Icons.home),
      Icon(Icons.favorite),
      Icon(Icons.settings),
    ],
  ),
)
```

## Icon vs 其他图标方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| `Icon` | 轻量、矢量、可着色 | 单色限制 |
| `Image` | 支持多色、细节丰富 | 文件大、不可着色 |
| `SvgPicture` | 矢量、支持多色 | 需额外包 |
| `CustomPaint` | 完全自定义 | 开发成本高 |

## 最佳实践

1. **使用语义标签**: 为重要图标提供 `semanticLabel`
2. **适配主题**: 使用 `IconTheme` 统一管理图标样式
3. **选择合适图标集**: Material 用于 Android 风格，Cupertino 用于 iOS 风格
4. **控制图标大小**: 保持一致的图标尺寸（通常 24 或 28）
5. **避免过多自定义字体**: 会增加应用体积
6. **使用 Outlined 变体**: 列表等场景使用轮廓图标减少视觉噪音

## 常用图标速查

```dart
// 导航
Icons.home, Icons.arrow_back, Icons.menu, Icons.close

// 操作
Icons.add, Icons.edit, Icons.delete, Icons.share

// 状态
Icons.check, Icons.error, Icons.warning, Icons.info

// 媒体
Icons.play_arrow, Icons.pause, Icons.stop, Icons.volume_up

// 社交
Icons.person, Icons.people, Icons.message, Icons.notifications

// 文件
Icons.folder, Icons.file_copy, Icons.upload, Icons.download
```

## 相关组件

- [IconButton](../material/iconbutton) - 图标按钮
- [Image](./image) - 图片组件
- [Badge](../material/badge) - 徽章组件
- [AnimatedIcon](../animation/animatedicon) - 动画图标

## 官方文档

- [Icon API](https://api.flutter.dev/flutter/widgets/Icon-class.html)
- [Material Icons](https://fonts.google.com/icons)
- [Cupertino Icons](https://api.flutter.dev/flutter/cupertino/CupertinoIcons-class.html)
- [Material Symbols](https://m3.material.io/styles/icons/overview)
