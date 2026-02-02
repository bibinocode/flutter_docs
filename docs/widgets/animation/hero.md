# Hero

`Hero` 是 Flutter 中用于实现页面间共享元素过渡动画的组件。当用户导航到新页面时，带有相同 `tag` 的 Hero 组件会自动创建"飞行"动画，非常适合图片预览、详情页过渡等场景。

## 基本用法

```dart
// 源页面
Hero(
  tag: 'avatar',
  child: CircleAvatar(
    backgroundImage: NetworkImage(imageUrl),
  ),
)

// 目标页面
Hero(
  tag: 'avatar', // 必须与源页面相同
  child: Image.network(imageUrl),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `tag` | `Object` | 唯一标识符（必需） |
| `child` | `Widget` | 子组件（必需） |
| `createRectTween` | `CreateRectTween?` | 自定义动画路径 |
| `flightShuttleBuilder` | `HeroFlightShuttleBuilder?` | 飞行中的组件构建器 |
| `placeholderBuilder` | `HeroPlaceholderBuilder?` | 占位组件构建器 |
| `transitionOnUserGestures` | `bool` | 手势返回时是否触发动画 |

## 使用场景

### 1. 基础 Hero 动画

```dart
// 列表页
class PhotoListPage extends StatelessWidget {
  final List<String> photos = [
    'https://picsum.photos/200/200?random=1',
    'https://picsum.photos/200/200?random=2',
    'https://picsum.photos/200/200?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('相册')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoDetailPage(
                    imageUrl: photos[index],
                    heroTag: 'photo_$index',
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'photo_$index', // 唯一 tag
              child: Image.network(
                photos[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

// 详情页
class PhotoDetailPage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const PhotoDetailPage({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: heroTag, // 必须与列表页相同
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
```

### 2. 卡片到详情页

```dart
// 商品卡片
class ProductCard extends StatelessWidget {
  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_image_${product.id}',
              child: Image.network(
                product.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'product_title_${product.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text('¥${product.price}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 商品详情页
class ProductDetailPage extends StatelessWidget {
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'product_title_${product.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('¥${product.price}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 16),
                  Text(product.description),
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

### 3. 自定义飞行路径

```dart
Hero(
  tag: 'custom_path',
  createRectTween: (begin, end) {
    // 使用曲线路径而非直线
    return MaterialRectCenterArcTween(begin: begin, end: end);
  },
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)

// 自定义补间
Hero(
  tag: 'custom_tween',
  createRectTween: (begin, end) {
    return RectTween(begin: begin, end: end);
  },
  child: MyWidget(),
)
```

### 4. 自定义飞行中组件

```dart
Hero(
  tag: 'shuttle',
  flightShuttleBuilder: (
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    // 飞行过程中显示不同的组件
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              animation.value * 20, // 动画过程中圆角变化
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3 * animation.value),
                blurRadius: 20 * animation.value,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(animation.value * 20),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        );
      },
    );
  },
  child: Image.network(imageUrl),
)
```

### 5. 占位符

```dart
Hero(
  tag: 'with_placeholder',
  placeholderBuilder: (context, heroSize, child) {
    // Hero 飞走后在原位置显示的占位符
    return Container(
      width: heroSize.width,
      height: heroSize.height,
      color: Colors.grey[300],
    );
  },
  child: Image.network(imageUrl),
)
```

### 6. 文本 Hero（需要 Material 包裹）

```dart
// 源页面
Hero(
  tag: 'title',
  child: Material(
    color: Colors.transparent,
    child: Text(
      '文章标题',
      style: TextStyle(fontSize: 16),
    ),
  ),
)

// 目标页面
Hero(
  tag: 'title',
  child: Material(
    color: Colors.transparent,
    child: Text(
      '文章标题',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  ),
)
```

### 7. FAB 到全屏动画

```dart
// 首页
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: Center(child: Text('内容')),
      floatingActionButton: Hero(
        tag: 'fab_to_page',
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return FadeTransition(
                    opacity: animation,
                    child: CreatePage(),
                  );
                },
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

// 创建页面
class CreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('创建')),
      body: Center(
        child: Hero(
          tag: 'fab_to_page',
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '创建内容',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 8. 支持手势返回

```dart
Hero(
  tag: 'swipe_back',
  transitionOnUserGestures: true, // iOS 侧滑返回时也显示动画
  child: Image.network(imageUrl),
)
```

## Hero 动画原理

1. Flutter 在两个页面中找到相同 `tag` 的 Hero
2. 计算两个 Hero 的位置和大小
3. 在 Overlay 层创建飞行动画
4. 源页面 Hero 变为透明占位
5. 动画完成后目标 Hero 显示

## 注意事项

::: warning Tag 必须唯一
每个页面中，Hero 的 `tag` 必须唯一。在列表中使用时，需要结合索引或 ID 创建唯一 tag。
```dart
Hero(tag: 'item_${item.id}', child: ...)
```
:::

::: tip 文本需要 Material 包裹
Text 和其他非 Material 组件在 Hero 动画中可能会丢失样式。建议用 Material 包裹：
```dart
Hero(
  tag: 'text',
  child: Material(
    color: Colors.transparent,
    child: Text('文本'),
  ),
)
```
:::

## 最佳实践

1. **使用唯一 tag**: 列表场景使用 ID 作为 tag 的一部分
2. **保持子组件相似**: 源和目标 Hero 的 child 结构应尽量相似
3. **包裹 Material**: Text 等组件用 Material 包裹
4. **启用手势返回**: iOS 上设置 `transitionOnUserGestures: true`
5. **合理使用**: 不要滥用，只在关键过渡场景使用

## 相关组件

- [Navigator](/flutter/05-navigation) - 页面导航管理
- [PageRouteBuilder](../navigation/pageroutebuilder) - 自定义页面过渡
- [AnimatedContainer](./animatedcontainer) - 隐式动画容器
- [FadeTransition](./fadetransition) - 透明度过渡

## 官方文档

- [Hero API](https://api.flutter.dev/flutter/widgets/Hero-class.html)
- [Hero 动画指南](https://docs.flutter.cn/ui/animations/hero-animations)
