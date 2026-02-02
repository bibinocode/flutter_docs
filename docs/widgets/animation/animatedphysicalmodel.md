# AnimatedPhysicalModel

AnimatedPhysicalModel 是 PhysicalModel 的动画版本，当阴影、颜色、圆角等属性改变时会自动执行平滑过渡动画。

## 基本用法

```dart
AnimatedPhysicalModel(
  duration: const Duration(milliseconds: 300),
  shape: BoxShape.rectangle,
  elevation: _isElevated ? 16 : 0,
  color: _isElevated ? Colors.white : Colors.grey[200]!,
  shadowColor: Colors.black,
  borderRadius: BorderRadius.circular(_isElevated ? 16 : 0),
  child: Container(
    width: 200,
    height: 100,
    child: const Center(child: Text('卡片')),
  ),
)
```

## 构造函数

```dart
const AnimatedPhysicalModel({
  super.key,
  required this.child,           // 子组件
  required this.shape,           // 形状
  this.clipBehavior = Clip.none, // 裁剪行为
  this.borderRadius = BorderRadius.zero, // 圆角
  required this.elevation,       // 阴影高度
  required this.color,           // 背景颜色
  this.animateColor = true,      // 是否动画颜色
  required this.shadowColor,     // 阴影颜色
  this.animateShadowColor = true, // 是否动画阴影颜色
  this.curve = Curves.linear,    // 动画曲线
  required super.duration,       // 动画时长
  super.onEnd,                   // 动画结束回调
})
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `shape` | `BoxShape` | 形状（rectangle/circle） |
| `elevation` | `double` | 阴影高度 |
| `color` | `Color` | 背景颜色 |
| `shadowColor` | `Color` | 阴影颜色 |
| `borderRadius` | `BorderRadius` | 圆角（仅 rectangle） |
| `clipBehavior` | `Clip` | 裁剪行为 |
| `animateColor` | `bool` | 是否动画背景颜色 |
| `animateShadowColor` | `bool` | 是否动画阴影颜色 |

## 完整示例

```dart
import 'package:flutter/material.dart';

class AnimatedPhysicalModelDemo extends StatefulWidget {
  const AnimatedPhysicalModelDemo({super.key});

  @override
  State<AnimatedPhysicalModelDemo> createState() =>
      _AnimatedPhysicalModelDemoState();
}

class _AnimatedPhysicalModelDemoState extends State<AnimatedPhysicalModelDemo> {
  bool _isElevated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedPhysicalModel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => setState(() => _isElevated = true),
              onTapUp: (_) => setState(() => _isElevated = false),
              onTapCancel: () => setState(() => _isElevated = false),
              child: AnimatedPhysicalModel(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                shape: BoxShape.rectangle,
                elevation: _isElevated ? 16.0 : 4.0,
                color: _isElevated ? Colors.blue[50]! : Colors.white,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(_isElevated ? 20 : 12),
                child: Container(
                  width: 200,
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    '按住我',
                    style: TextStyle(
                      fontSize: 18,
                      color: _isElevated ? Colors.blue : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 切换按钮
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isElevated = !_isElevated;
                });
              },
              child: const Text('切换状态'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 可选中的卡片

```dart
class SelectableCard extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SelectableCard> createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        shape: BoxShape.rectangle,
        elevation: _isPressed ? 2 : (widget.isSelected ? 8 : 4),
        color: widget.isSelected ? Colors.blue[100]! : Colors.white,
        shadowColor: widget.isSelected ? Colors.blue[300]! : Colors.black38,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected ? Colors.blue : Colors.grey[300],
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  color: widget.isSelected ? Colors.blue[800] : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 使用
class SelectableCardDemo extends StatefulWidget {
  @override
  State<SelectableCardDemo> createState() => _SelectableCardDemoState();
}

class _SelectableCardDemoState extends State<SelectableCardDemo> {
  int _selectedIndex = 0;
  final List<String> _options = ['选项一', '选项二', '选项三'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_options.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SelectableCard(
            title: _options[index],
            isSelected: _selectedIndex == index,
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      }),
    );
  }
}
```

## 圆形头像卡片

```dart
class AvatarCard extends StatefulWidget {
  final String name;
  final String avatarUrl;

  const AvatarCard({
    super.key,
    required this.name,
    required this.avatarUrl,
  });

  @override
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 200),
        shape: BoxShape.circle,
        elevation: _isHovered ? 12 : 4,
        color: Colors.white,
        shadowColor: _isHovered ? Colors.blue[200]! : Colors.black26,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(widget.avatarUrl),
          ),
        ),
      ),
    );
  }
}
```

## 浮动操作按钮效果

```dart
class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 100),
        shape: BoxShape.circle,
        elevation: _isPressed ? 4 : 8,
        color: _isPressed ? Colors.blue[700]! : Colors.blue,
        shadowColor: Colors.black38,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

## 与其他动画组件配合

```dart
class CombinedAnimationCard extends StatefulWidget {
  const CombinedAnimationCard({super.key});

  @override
  State<CombinedAnimationCard> createState() => _CombinedAnimationCardState();
}

class _CombinedAnimationCardState extends State<CombinedAnimationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 300),
        shape: BoxShape.rectangle,
        elevation: _isExpanded ? 12 : 4,
        color: Colors.white,
        shadowColor: Colors.black38,
        borderRadius: BorderRadius.circular(_isExpanded ? 24 : 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _isExpanded ? 280 : 200,
          height: _isExpanded ? 200 : 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: _isExpanded ? 24 : 18,
                  fontWeight: _isExpanded ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
                child: const Text('标题'),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Expanded(
                  child: Text(
                    '这是展开后显示的详细内容，点击卡片可以切换展开/收起状态。',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

## 注意事项

::: tip 提示
- `elevation` 值越大，阴影越明显
- 圆形形状 (`BoxShape.circle`) 会忽略 `borderRadius`
- 配合 `AnimatedContainer` 可以实现更丰富的效果
:::

## 相关组件

- [AnimatedContainer](./animatedcontainer.md) - 动画容器
- [Card](../material/card.md) - Material 卡片
- [PhysicalModel](../basics/container.md) - 物理模型（静态）
