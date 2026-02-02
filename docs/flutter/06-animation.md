# 动画系统

Flutter 提供了强大而灵活的动画系统。本章将从基础到高级，全面介绍 Flutter 动画开发。

## 动画基础概念

### 核心组件

- **Animation**: 动画值的抽象，包含当前值和状态
- **AnimationController**: 控制动画的播放、暂停、反转等
- **Tween**: 定义动画的起始和结束值
- **Curve**: 定义动画的变化曲线（缓动函数）

### 基本流程

```
AnimationController → Tween → Animation → Widget
     (控制器)        (范围)    (值)      (UI)
```

## 隐式动画（Implicit Animations）

最简单的动画方式，只需改变属性值，Flutter 自动执行动画。

### AnimatedContainer

```dart
class AnimatedContainerDemo extends StatefulWidget {
  @override
  _AnimatedContainerDemoState createState() => _AnimatedContainerDemoState();
}

class _AnimatedContainerDemoState extends State&lt;AnimatedContainerDemo&gt; {
  bool _expanded = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _expanded ? 200 : 100,
        height: _expanded ? 200 : 100,
        decoration: BoxDecoration(
          color: _expanded ? Colors.blue : Colors.red,
          borderRadius: BorderRadius.circular(_expanded ? 32 : 8),
        ),
        child: Center(
          child: Text(
            '点击',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
```

### 常用隐式动画组件

```dart
// AnimatedOpacity - 透明度动画
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 500),
  child: Container(width: 100, height: 100, color: Colors.blue),
)

// AnimatedAlign - 对齐动画
AnimatedAlign(
  alignment: _alignTop ? Alignment.topCenter : Alignment.bottomCenter,
  duration: Duration(milliseconds: 300),
  child: Container(width: 50, height: 50, color: Colors.green),
)

// AnimatedPadding - 内边距动画
AnimatedPadding(
  padding: EdgeInsets.all(_expanded ? 32 : 8),
  duration: Duration(milliseconds: 200),
  child: Container(color: Colors.orange),
)

// AnimatedPositioned - 定位动画（需要在 Stack 中使用）
Stack(
  children: [
    AnimatedPositioned(
      left: _moved ? 100 : 0,
      top: _moved ? 100 : 0,
      duration: Duration(milliseconds: 300),
      child: Container(width: 50, height: 50, color: Colors.purple),
    ),
  ],
)

// AnimatedDefaultTextStyle - 文字样式动画
AnimatedDefaultTextStyle(
  style: TextStyle(
    fontSize: _large ? 32 : 16,
    color: _large ? Colors.blue : Colors.black,
  ),
  duration: Duration(milliseconds: 300),
  child: Text('Hello'),
)

// AnimatedCrossFade - 交叉淡入淡出
AnimatedCrossFade(
  firstChild: Icon(Icons.play_arrow, size: 48),
  secondChild: Icon(Icons.pause, size: 48),
  crossFadeState: _playing 
      ? CrossFadeState.showSecond 
      : CrossFadeState.showFirst,
  duration: Duration(milliseconds: 200),
)

// AnimatedSwitcher - 通用切换动画
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return ScaleTransition(scale: animation, child: child);
  },
  child: Text(
    '$_count',
    key: ValueKey(_count),  // 关键：需要不同的 key
    style: TextStyle(fontSize: 48),
  ),
)
```

### TweenAnimationBuilder（自定义隐式动画）

```dart
TweenAnimationBuilder&lt;double&gt;(
  tween: Tween(begin: 0, end: _progress),
  duration: Duration(milliseconds: 500),
  builder: (context, value, child) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
          ),
        ),
        Text('${(value * 100).toInt()}%'),
      ],
    );
  },
)

// 自定义颜色动画
TweenAnimationBuilder&lt;Color?&gt;(
  tween: ColorTween(begin: Colors.red, end: _targetColor),
  duration: Duration(milliseconds: 300),
  builder: (context, color, child) {
    return Container(
      width: 100,
      height: 100,
      color: color,
    );
  },
)
```

## 显式动画（Explicit Animations）

需要更精细控制时，使用 AnimationController。

### 基本结构

```dart
class ExplicitAnimationDemo extends StatefulWidget {
  @override
  _ExplicitAnimationDemoState createState() => _ExplicitAnimationDemoState();
}

class _ExplicitAnimationDemoState extends State&lt;ExplicitAnimationDemo&gt;
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation&lt;double&gt; _animation;
  
  @override
  void initState() {
    super.initState();
    
    // 创建控制器
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,  // 需要 TickerProvider
    );
    
    // 创建动画（可选：添加曲线和范围）
    _animation = Tween&lt;double&gt;(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // 监听动画状态
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    
    // 开始动画
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();  // 必须释放
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * pi,
          child: child,
        );
      },
      child: Icon(Icons.refresh, size: 48),  // 优化：不变的 child
    );
  }
}
```

### AnimationController 操作

```dart
// 正向播放
_controller.forward();
_controller.forward(from: 0.5);  // 从中间开始

// 反向播放
_controller.reverse();
_controller.reverse(from: 1.0);

// 重复播放
_controller.repeat();
_controller.repeat(reverse: true);  // 往返

// 停止
_controller.stop();

// 重置
_controller.reset();

// 直接设置值
_controller.value = 0.5;

// 动画到指定值
_controller.animateTo(0.8, duration: Duration(milliseconds: 500));
_controller.animateBack(0.2);
```

### 常用过渡动画组件

```dart
// FadeTransition
FadeTransition(
  opacity: _animation,
  child: Container(...),
)

// ScaleTransition
ScaleTransition(
  scale: _animation,
  child: Container(...),
)

// RotationTransition
RotationTransition(
  turns: _animation,  // 1.0 = 360度
  child: Container(...),
)

// SlideTransition
SlideTransition(
  position: Tween&lt;Offset&gt;(
    begin: Offset(-1, 0),  // 从左侧
    end: Offset.zero,
  ).animate(_controller),
  child: Container(...),
)

// SizeTransition
SizeTransition(
  sizeFactor: _animation,
  axis: Axis.vertical,
  child: Container(...),
)

// DecoratedBoxTransition
DecoratedBoxTransition(
  decoration: DecorationTween(
    begin: BoxDecoration(color: Colors.red),
    end: BoxDecoration(color: Colors.blue),
  ).animate(_controller),
  child: Container(width: 100, height: 100),
)
```

### 组合多个动画

```dart
class MultiAnimationDemo extends StatefulWidget {
  @override
  _MultiAnimationDemoState createState() => _MultiAnimationDemoState();
}

class _MultiAnimationDemoState extends State&lt;MultiAnimationDemo&gt;
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation&lt;double&gt; _scaleAnimation;
  late Animation&lt;double&gt; _rotationAnimation;
  late Animation&lt;Color?&gt; _colorAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    // 不同阶段的动画
    _scaleAnimation = Tween&lt;double&gt;(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _rotationAnimation = Tween&lt;double&gt;(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              color: _colorAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
```

## 曲线（Curves）

### 内置曲线

```dart
// 线性
Curves.linear

// 缓动
Curves.ease
Curves.easeIn
Curves.easeOut
Curves.easeInOut

// 弹性
Curves.bounceIn
Curves.bounceOut
Curves.bounceInOut

// 弹簧
Curves.elasticIn
Curves.elasticOut
Curves.elasticInOut

// 快慢
Curves.fastOutSlowIn
Curves.slowMiddle

// 减速
Curves.decelerate
```

### 自定义曲线

```dart
// 使用 Cubic
final customCurve = Cubic(0.68, -0.55, 0.265, 1.55);

// 继承 Curve
class SineCurve extends Curve {
  final double count;
  
  const SineCurve({this.count = 1});
  
  @override
  double transform(double t) {
    return sin(count * 2 * pi * t);
  }
}

// 组合曲线
final combinedCurve = Interval(
  0.0, 0.5,
  curve: Curves.easeOut,
);
```

## Hero 动画

### 基本使用

```dart
// 源页面
class SourcePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DestinationPage()),
        ),
        child: Hero(
          tag: 'image-hero',  // 唯一标识
          child: Image.network(
            'https://example.com/image.jpg',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// 目标页面
class DestinationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'image-hero',  // 相同的 tag
          child: Image.network(
            'https://example.com/image.jpg',
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
```

### 自定义 Hero 动画

```dart
Hero(
  tag: 'avatar',
  flightShuttleBuilder: (
    BuildContext flightContext,
    Animation&lt;double&gt; animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Transform.rotate(
            angle: animation.value * 2 * pi,
            child: child,
          ),
        );
      },
      child: toHeroContext.widget,
    );
  },
  child: CircleAvatar(
    backgroundImage: NetworkImage(imageUrl),
  ),
)
```

## 物理动画

### 弹簧动画

```dart
class SpringAnimationDemo extends StatefulWidget {
  @override
  _SpringAnimationDemoState createState() => _SpringAnimationDemoState();
}

class _SpringAnimationDemoState extends State&lt;SpringAnimationDemo&gt;
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation&lt;double&gt; _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),  // 近似持续时间
    );
    
    // 使用弹簧模拟
    final spring = SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 10,
    );
    
    final simulation = SpringSimulation(spring, 0, 1, 0);
    
    _controller.animateWith(simulation);
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + _controller.value * 0.5,
          child: child,
        );
      },
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
    );
  }
}
```

### 摩擦力动画

```dart
// 模拟拖拽后的减速
final friction = FrictionSimulation(
  0.5,  // 摩擦系数
  position,  // 初始位置
  velocity,  // 初始速度
);

_controller.animateWith(friction);
```

## Stagger 动画（交错动画）

```dart
class StaggeredAnimationDemo extends StatefulWidget {
  @override
  _StaggeredAnimationDemoState createState() => _StaggeredAnimationDemoState();
}

class _StaggeredAnimationDemoState extends State&lt;StaggeredAnimationDemo&gt;
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return SlideTransition(
          position: Tween&lt;Offset&gt;(
            begin: Offset(-1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.1,  // 开始时间
                0.5 + index * 0.1,  // 结束时间
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.1,
                0.5 + index * 0.1,
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              width: 200,
              height: 40,
              color: Colors.blue[100 * (index + 1)],
            ),
          ),
        );
      }),
    );
  }
}
```

## 自定义 AnimatedWidget

```dart
class AnimatedLogo extends AnimatedWidget {
  const AnimatedLogo({required Animation&lt;double&gt; animation})
      : super(listenable: animation);
  
  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation&lt;double&gt;;
    return Transform.rotate(
      angle: animation.value * 2 * pi,
      child: Container(
        width: 100,
        height: 100,
        child: FlutterLogo(),
      ),
    );
  }
}

// 使用
AnimatedLogo(animation: _controller)
```

## 动画最佳实践

### 1. 性能优化

```dart
// ✅ 使用 child 参数缓存不变的组件
AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Transform.scale(
      scale: _animation.value,
      child: child,  // 复用 child
    );
  },
  child: ExpensiveWidget(),  // 只构建一次
)

// ✅ 使用 RepaintBoundary 隔离重绘
RepaintBoundary(
  child: AnimatedWidget(),
)
```

### 2. 合适的动画时长

```dart
// 微交互：100-200ms
// 页面过渡：200-300ms
// 复杂动画：300-500ms
// 强调效果：500-1000ms

const kFastAnimation = Duration(milliseconds: 150);
const kNormalAnimation = Duration(milliseconds: 300);
const kSlowAnimation = Duration(milliseconds: 500);
```

### 3. 用户体验

```dart
// 响应用户偏好
final reduceMotion = MediaQuery.of(context).disableAnimations;

AnimatedContainer(
  duration: reduceMotion 
      ? Duration.zero 
      : Duration(milliseconds: 300),
  child: content,
)
```

## 下一步

掌握动画系统后，下一章我们将学习 [主题与样式](./07-theming)，打造统一美观的应用界面。
