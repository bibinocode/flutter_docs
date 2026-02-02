# Image

`Image` 是 Flutter 中用于显示图片的核心组件，支持多种图片来源：网络、本地资源、文件系统、内存等。

## 基本用法

```dart
// 网络图片
Image.network('https://example.com/image.png')

// 本地资源图片
Image.asset('assets/images/logo.png')

// 文件图片
Image.file(File('/path/to/image.png'))

// 内存图片
Image.memory(Uint8List bytes)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `image` | `ImageProvider` | 图片提供者（必需） |
| `width` | `double?` | 图片宽度 |
| `height` | `double?` | 图片高度 |
| `fit` | `BoxFit?` | 图片填充方式 |
| `alignment` | `AlignmentGeometry` | 对齐方式，默认居中 |
| `repeat` | `ImageRepeat` | 重复方式 |
| `color` | `Color?` | 颜色混合 |
| `colorBlendMode` | `BlendMode?` | 颜色混合模式 |
| `filterQuality` | `FilterQuality` | 过滤质量 |
| `semanticLabel` | `String?` | 无障碍标签 |
| `excludeFromSemantics` | `bool` | 是否排除无障碍 |
| `isAntiAlias` | `bool` | 是否抗锯齿 |
| `frameBuilder` | `ImageFrameBuilder?` | 帧构建器 |
| `loadingBuilder` | `ImageLoadingBuilder?` | 加载进度构建器 |
| `errorBuilder` | `ImageErrorWidgetBuilder?` | 错误构建器 |

## BoxFit 图片填充方式

| 值 | 说明 |
|----|------|
| `BoxFit.fill` | 拉伸填满，可能变形 |
| `BoxFit.contain` | 保持比例，完整显示 |
| `BoxFit.cover` | 保持比例，裁剪填满 |
| `BoxFit.fitWidth` | 宽度填满，高度按比例 |
| `BoxFit.fitHeight` | 高度填满，宽度按比例 |
| `BoxFit.none` | 原始大小，居中显示 |
| `BoxFit.scaleDown` | 缩小以完整显示 |

## 使用场景

### 1. 网络图片

```dart
// 基础用法
Image.network(
  'https://picsum.photos/250?image=9',
  width: 250,
  height: 250,
  fit: BoxFit.cover,
)

// 带加载进度
Image.network(
  'https://example.com/large-image.jpg',
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.error, color: Colors.red),
    );
  },
)
```

### 2. 本地资源图片

```yaml
# 首先在 pubspec.yaml 中声明资源
flutter:
  assets:
    - assets/images/
    - assets/icons/logo.png
```

```dart
// 加载资源图片
Image.asset(
  'assets/images/background.png',
  fit: BoxFit.cover,
)

// 指定图片包
Image.asset(
  'assets/icons/logo.png',
  package: 'my_package', // 来自其他包
)

// 使用不同分辨率
// assets/
//   images/
//     logo.png       (1x)
//     2.0x/logo.png  (2x)
//     3.0x/logo.png  (3x)
```

### 3. 图片颜色处理

```dart
// 着色图标（适合单色图片）
Image.asset(
  'assets/icons/heart.png',
  color: Colors.red,
  colorBlendMode: BlendMode.srcIn,
)

// 灰度效果
Image.network(
  'https://example.com/photo.jpg',
  color: Colors.grey,
  colorBlendMode: BlendMode.saturation,
)

// 半透明效果
Image.network(
  'https://example.com/photo.jpg',
  color: Colors.white.withOpacity(0.5),
  colorBlendMode: BlendMode.modulate,
)
```

### 4. 圆形和圆角图片

```dart
// 圆形头像
ClipOval(
  child: Image.network(
    'https://example.com/avatar.jpg',
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  ),
)

// 圆角图片
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: Image.network(
    'https://example.com/photo.jpg',
    width: 200,
    height: 150,
    fit: BoxFit.cover,
  ),
)

// 使用 Container 装饰
Container(
  width: 100,
  height: 100,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    image: DecorationImage(
      image: NetworkImage('https://example.com/avatar.jpg'),
      fit: BoxFit.cover,
    ),
  ),
)

// 使用 CircleAvatar
CircleAvatar(
  radius: 50,
  backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
)
```

### 5. 渐变加载效果

```dart
Image.network(
  'https://example.com/photo.jpg',
  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: child,
    );
  },
)
```

### 6. 图片平铺背景

```dart
Container(
  width: double.infinity,
  height: 200,
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/pattern.png'),
      repeat: ImageRepeat.repeat,
    ),
  ),
)
```

### 7. 缓存和预加载

```dart
// 预加载图片到缓存
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(
    AssetImage('assets/images/hero.png'),
    context,
  );
  precacheImage(
    NetworkImage('https://example.com/banner.jpg'),
    context,
  );
}

// 清除图片缓存
void clearCache() {
  imageCache.clear();
  imageCache.clearLiveImages();
}
```

## 高级用法

### 使用 FadeInImage 渐变过渡

```dart
FadeInImage.assetNetwork(
  placeholder: 'assets/images/placeholder.png',
  image: 'https://example.com/photo.jpg',
  fadeInDuration: Duration(milliseconds: 300),
  fadeOutDuration: Duration(milliseconds: 100),
  fit: BoxFit.cover,
)

// 使用内存占位符
FadeInImage.memoryNetwork(
  placeholder: kTransparentImage, // 来自 transparent_image 包
  image: 'https://example.com/photo.jpg',
)
```

### 使用 cached_network_image 包

```dart
// 推荐用于网络图片缓存
CachedNetworkImage(
  imageUrl: 'https://example.com/photo.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fadeInDuration: Duration(milliseconds: 300),
  memCacheWidth: 500, // 内存缓存尺寸
  memCacheHeight: 500,
)
```

## 图片提供者对比

| ImageProvider | 用途 | 缓存 |
|--------------|------|------|
| `AssetImage` | 本地资源 | 是 |
| `NetworkImage` | 网络图片 | 内存缓存 |
| `FileImage` | 文件系统 | 否 |
| `MemoryImage` | 内存数据 | 否 |
| `ResizeImage` | 调整大小 | 是 |

## 最佳实践

1. **使用适当的分辨率**: 提供 1x、2x、3x 资源适配不同屏幕
2. **预加载关键图片**: 使用 `precacheImage` 提前加载
3. **处理加载状态**: 使用 `loadingBuilder` 和 `errorBuilder`
4. **控制缓存大小**: 使用 `ResizeImage` 限制内存占用
5. **使用正确的 fit**: 根据需求选择合适的 `BoxFit`
6. **无障碍支持**: 为图片提供 `semanticLabel`
7. **使用缓存库**: 网络图片建议使用 `cached_network_image`

## 相关组件

- [Icon](./icon) - 矢量图标
- [CircleAvatar](../material/circleavatar) - 圆形头像
- [FadeInImage](./fadeinimage) - 渐变加载图片
- [DecorationImage](./decorationimage) - 装饰图片

## 官方文档

- [Image API](https://api.flutter.dev/flutter/widgets/Image-class.html)
- [ImageProvider API](https://api.flutter.dev/flutter/painting/ImageProvider-class.html)
- [Flutter 图片指南](https://docs.flutter.cn/ui/assets/assets-and-images)
