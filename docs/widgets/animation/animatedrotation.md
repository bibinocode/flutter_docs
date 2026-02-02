# AnimatedRotation

`AnimatedRotation` 是一个隐式动画组件，可以平滑地动画改变子组件的旋转角度。它使用 `turns` 属性来控制旋转，其中 1.0 表示完整旋转 360 度。

## 基本用法

```dart
class RotationDemo extends StatefulWidget {
  const RotationDemo({super.key});

  @override
  State<RotationDemo> createState() => _RotationDemoState();
}

class _RotationDemoState extends State<RotationDemo> {
  double _turns = 0.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedRotation(
            turns: _turns,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _turns -= 0.25),
                child: const Text('逆时针 90°'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => setState(() => _turns += 0.25),
                child: const Text('顺时针 90°'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _turns += 1.0),
            child: const Text('旋转 360°'),
          ),
        ],
      ),
    );
  }
}
```

## 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `turns` | `double` | 旋转圈数 (1.0 = 360°, 0.5 = 180°, 0.25 = 90°) |
| `alignment` | `Alignment` | 旋转中心点，默认为 `Alignment.center` |
| `duration` | `Duration` | 动画持续时间 |
| `curve` | `Curve` | 动画曲线 |
| `onEnd` | `VoidCallback?` | 动画结束回调 |

::: info Turns 值说明
- `0.25` = 90° 顺时针
- `0.5` = 180°
- `1.0` = 360° (一圈)
- `-0.25` = 90° 逆时针
- 可以使用任意小数值，如 `0.125` = 45°
:::

## 加载按钮

```dart
class LoadingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;
  double _turns = 0.0;

  void _startLoading() async {
    setState(() => _isLoading = true);
    
    // 持续旋转
    while (_isLoading && mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && _isLoading) {
        setState(() => _turns += 1.0);
      }
    }
  }

  void _handlePress() async {
    _startLoading();
    widget.onPressed();
    
    // 模拟异步操作
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedRotation(
                turns: _turns,
                duration: const Duration(milliseconds: 800),
                curve: Curves.linear,
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.sync, size: 16),
                ),
              ),
            ),
          Text(_isLoading ? '加载中...' : widget.text),
        ],
      ),
    );
  }
}
```

## 展开/收起箭头

```dart
class ExpandableCard extends StatefulWidget {
  final String title;
  final String content;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.content),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

// 使用示例
class ExpandableListDemo extends StatelessWidget {
  const ExpandableListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ExpandableCard(
          title: '什么是 Flutter？',
          content: 'Flutter 是 Google 开发的开源 UI 软件开发工具包，'
              '用于从单一代码库构建跨平台应用程序。',
        ),
        ExpandableCard(
          title: 'Flutter 的优势',
          content: '热重载、跨平台、高性能、丰富的组件库、强大的社区支持。',
        ),
        ExpandableCard(
          title: '如何学习 Flutter？',
          content: '官方文档、在线教程、实践项目、社区交流。',
        ),
      ],
    );
  }
}
```

## 设置齿轮动画

```dart
class SettingsIcon extends StatefulWidget {
  const SettingsIcon({super.key});

  @override
  State<SettingsIcon> createState() => _SettingsIconState();
}

class _SettingsIconState extends State<SettingsIcon> {
  double _turns = 0.0;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _turns += 0.25;
        });
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _turns += 0.5),
        child: AnimatedRotation(
          turns: _turns,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: _isHovered ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.settings,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
```

## 翻转卡片

```dart
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  bool _showFront = true;
  double _turns = 0.0;

  void _flip() {
    setState(() {
      _turns += 0.5;
      // 在旋转到一半时切换内容
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() => _showFront = !_showFront);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedRotation(
        turns: _turns,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        child: Container(
          width: 200,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _showFront ? widget.front : widget.back,
          ),
        ),
      ),
    );
  }
}

// 使用示例
class FlipCardDemo extends StatelessWidget {
  const FlipCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlipCard(
        front: Container(
          color: Colors.blue,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: Colors.white, size: 50),
                SizedBox(height: 16),
                Text(
                  '点击翻转',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        back: Container(
          color: Colors.orange,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.white, size: 50),
                SizedBox(height: 16),
                Text(
                  '背面内容',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 旋转菜单

```dart
class RotatingMenu extends StatefulWidget {
  const RotatingMenu({super.key});

  @override
  State<RotatingMenu> createState() => _RotatingMenuState();
}

class _RotatingMenuState extends State<RotatingMenu> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 菜单项
        ..._buildMenuItems(),
        
        // 中心按钮
        GestureDetector(
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0.0, // 45度
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _isOpen ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    final items = [
      {'icon': Icons.camera_alt, 'color': Colors.purple, 'angle': -0.25},
      {'icon': Icons.photo, 'color': Colors.green, 'angle': -0.125},
      {'icon': Icons.edit, 'color': Colors.orange, 'angle': 0.0},
      {'icon': Icons.share, 'color': Colors.pink, 'angle': 0.125},
    ];

    return items.map((item) {
      final angle = (item['angle'] as double) * 3.14159 * 2;
      final radius = _isOpen ? 100.0 : 0.0;
      
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        left: 150 + radius * cos(angle) - 25,
        top: 150 + radius * sin(angle) - 25,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isOpen ? 1.0 : 0.0,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item['color'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'] as IconData,
              color: Colors.white,
            ),
          ),
        ),
      );
    }).toList();
  }
}

double cos(double x) => x.cos();
double sin(double x) => x.sin();

extension on double {
  double cos() => math.cos(this);
  double sin() => math.sin(this);
}
```

需要在文件顶部添加：
```dart
import 'dart:math' as math;
```

## 注意事项

::: tip 使用场景
- 刷新/加载图标动画
- 展开/收起指示箭头
- 设置齿轮悬停效果
- 翻转卡片动画
- 旋转菜单按钮
:::

::: warning 与 RotationTransition 区别
- `AnimatedRotation` - 隐式动画，使用 `turns` 值
- `RotationTransition` - 显式动画，需要 `AnimationController`
- `AnimatedRotation` 适合简单的角度切换
- `RotationTransition` 适合持续旋转动画
:::
