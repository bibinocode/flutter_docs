# AnimatedOpacity

`AnimatedOpacity` 是 Flutter 中用于创建隐式透明度动画的组件。当 `opacity` 属性发生变化时，会自动在新旧透明度值之间创建平滑的淡入淡出过渡效果，无需手动管理 AnimationController。

## 基本用法

```dart
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `opacity` | `double` | 透明度，取值范围 0.0（完全透明）到 1.0（完全不透明）（必需） |
| `duration` | `Duration` | 动画时长（必需） |
| `curve` | `Curve` | 动画曲线，默认 `Curves.linear` |
| `onEnd` | `VoidCallback?` | 动画结束时的回调函数 |
| `alwaysIncludeSemantics` | `bool` | 是否始终包含语义信息，默认 `false`。为 `true` 时即使透明度为 0 也会保留语义 |
| `child` | `Widget?` | 子组件 |

## 使用场景

### 1. 淡入淡出效果

```dart
class FadeInOutDemo extends StatefulWidget {
  @override
  _FadeInOutDemoState createState() => _FadeInOutDemoState();
}

class _FadeInOutDemoState extends State<FadeInOutDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Hello', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _visible = !_visible),
          child: Text(_visible ? '隐藏' : '显示'),
        ),
      ],
    );
  }
}
```

### 2. 加载指示器

```dart
class LoadingIndicator extends StatefulWidget {
  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2)); // 模拟加载
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 主内容
        AnimatedOpacity(
          opacity: _isLoading ? 0.3 : 1.0,
          duration: Duration(milliseconds: 300),
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
          ),
        ),
        // 加载指示器
        AnimatedOpacity(
          opacity: _isLoading ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: CircularProgressIndicator(),
        ),
        // 加载按钮
        Positioned(
          bottom: 20,
          child: ElevatedButton(
            onPressed: _loadData,
            child: Text('加载数据'),
          ),
        ),
      ],
    );
  }
}
```

### 3. 提示消失效果

```dart
class ToastMessage extends StatefulWidget {
  final String message;

  const ToastMessage({required this.message});

  @override
  _ToastMessageState createState() => _ToastMessageState();
}

class _ToastMessageState extends State<ToastMessage> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    // 2秒后自动消失
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      onEnd: () {
        // 动画结束后可执行其他操作
        print('Toast 已消失');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          widget.message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
```

### 4. 条件显示

```dart
class ConditionalDisplay extends StatefulWidget {
  @override
  _ConditionalDisplayState createState() => _ConditionalDisplayState();
}

class _ConditionalDisplayState extends State<ConditionalDisplay> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('商品名称'),
          subtitle: Text('￥99.00'),
          trailing: IconButton(
            icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _showDetails = !_showDetails),
          ),
        ),
        AnimatedOpacity(
          opacity: _showDetails ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('商品详情', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('这是一段商品的详细描述信息...'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

## 完整示例：点赞动画效果

```dart
import 'package:flutter/material.dart';

class LikeAnimationDemo extends StatefulWidget {
  @override
  _LikeAnimationDemoState createState() => _LikeAnimationDemoState();
}

class _LikeAnimationDemoState extends State<LikeAnimationDemo> {
  bool _isLiked = false;
  bool _showHeart = false;
  int _likeCount = 128;

  void _onLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
      if (_isLiked) {
        _showHeart = true;
        // 显示动画心形后自动隐藏
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) setState(() => _showHeart = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('点赞动画效果')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图片区域（带飘心动画）
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                // 点赞时的大心形动画
                AnimatedOpacity(
                  opacity: _showHeart ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: _showHeart ? 1.0 : 0.5),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.favorite,
                      size: 100,
                      color: Colors.red.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // 点赞按钮区域
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _onLike,
                  child: Row(
                    children: [
                      AnimatedOpacity(
                        opacity: _isLiked ? 1.0 : 0.6,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.grey,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 8),
                      AnimatedOpacity(
                        opacity: _isLiked ? 1.0 : 0.6,
                        duration: Duration(milliseconds: 200),
                        child: Text(
                          '$_likeCount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                            color: _isLiked ? Colors.red : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 32),
                // 评论按钮
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 28),
                    SizedBox(width: 8),
                    Text('56', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(width: 32),
                // 分享按钮
                Row(
                  children: [
                    Icon(Icons.share_outlined, color: Colors.grey, size: 28),
                    SizedBox(width: 8),
                    Text('分享', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

### 1. AnimatedOpacity vs Visibility

| 特性 | AnimatedOpacity | Visibility |
|------|-----------------|------------|
| 动画效果 | ✅ 平滑淡入淡出 | ❌ 无动画，瞬间切换 |
| 占用空间 | 始终占用空间 | 可配置 `maintainSize` |
| 性能 | 透明度为 0 时仍参与渲染 | `visible: false` 时不渲染 |
| 适用场景 | 需要淡入淡出效果 | 简单显示/隐藏切换 |

```dart
// 需要动画效果时使用 AnimatedOpacity
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: MyWidget(),
)

// 不需要动画、追求性能时使用 Visibility
Visibility(
  visible: _visible,
  maintainSize: false, // 不占用空间
  child: MyWidget(),
)
```

### 2. AnimatedOpacity vs AnimatedCrossFade

| 特性 | AnimatedOpacity | AnimatedCrossFade |
|------|-----------------|-------------------|
| 用途 | 单个组件淡入淡出 | 两个组件交叉淡入淡出 |
| 子组件数量 | 1 个 | 2 个 |
| 尺寸变化 | 不处理 | 自动处理尺寸过渡 |
| 适用场景 | 显示/隐藏单个组件 | 切换两个不同组件 |

```dart
// 单个组件显示/隐藏
AnimatedOpacity(
  opacity: _showFirst ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: FirstWidget(),
)

// 两个组件之间切换
AnimatedCrossFade(
  firstChild: FirstWidget(),
  secondChild: SecondWidget(),
  crossFadeState: _showFirst 
      ? CrossFadeState.showFirst 
      : CrossFadeState.showSecond,
  duration: Duration(milliseconds: 300),
)
```

### 3. 使用注意事项

- **透明度为 0 时仍占用空间**：如果需要完全移除组件，考虑结合 `Visibility` 或条件渲染
- **性能考虑**：`opacity: 0.0` 的组件仍会被渲染，对于复杂组件可能影响性能
- **语义保留**：设置 `alwaysIncludeSemantics: true` 可让屏幕阅读器在透明时仍能读取内容
- **避免频繁动画**：频繁改变 opacity 可能导致性能问题，特别是对于复杂的子组件

```dart
// 结合条件渲染优化性能
if (_shouldRender)
  AnimatedOpacity(
    opacity: _visible ? 1.0 : 0.0,
    duration: Duration(milliseconds: 300),
    onEnd: () {
      if (!_visible) setState(() => _shouldRender = false);
    },
    child: ComplexWidget(),
  ),
```

## 相关组件

- [FadeTransition](./fadetransition.md) - 显式动画版本，需要 AnimationController，控制更精细
- [Visibility](../basics/visibility.md) - 简单显示/隐藏，无动画效果
- [AnimatedCrossFade](./animatedcrossfade.md) - 两个组件之间的交叉淡入淡出
- [Opacity](../basics/opacity.md) - 静态透明度，无动画

## 官方文档

- [AnimatedOpacity API](https://api.flutter.dev/flutter/widgets/AnimatedOpacity-class.html)
- [隐式动画介绍](https://docs.flutter.dev/development/ui/animations/implicit-animations)
