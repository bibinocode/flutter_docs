# AnimatedIcon

AnimatedIcon 是一个支持动画过渡的图标组件，可以在两个图标状态之间平滑切换。

## 基本用法

```dart
AnimatedIcon(
  icon: AnimatedIcons.menu_close,
  progress: _animationController,
  size: 48,
  color: Colors.blue,
)
```

## 构造函数

```dart
const AnimatedIcon({
  super.key,
  required this.icon,      // 动画图标数据
  required this.progress,  // 动画进度
  this.color,              // 图标颜色
  this.size,               // 图标大小
  this.semanticLabel,      // 语义标签
  this.textDirection,      // 文本方向
})
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `icon` | `AnimatedIconData` | 动画图标数据 |
| `progress` | `Animation<double>` | 动画进度（0.0 - 1.0） |
| `color` | `Color?` | 图标颜色 |
| `size` | `double?` | 图标大小 |
| `semanticLabel` | `String?` | 无障碍标签 |

## 可用的动画图标

Flutter 内置了以下动画图标：

| AnimatedIcons | 起始图标 | 结束图标 |
|---------------|---------|---------|
| `menu_arrow` | 菜单 | 箭头 |
| `menu_close` | 菜单 | 关闭 |
| `menu_home` | 菜单 | 主页 |
| `play_pause` | 播放 | 暂停 |
| `pause_play` | 暂停 | 播放 |
| `close_menu` | 关闭 | 菜单 |
| `home_menu` | 主页 | 菜单 |
| `arrow_menu` | 箭头 | 菜单 |
| `add_event` | 添加 | 事件 |
| `event_add` | 事件 | 添加 |
| `ellipsis_search` | 省略号 | 搜索 |
| `search_ellipsis` | 搜索 | 省略号 |
| `view_list` | 网格 | 列表 |
| `list_view` | 列表 | 网格 |

## 完整示例

```dart
import 'package:flutter/material.dart';

class AnimatedIconDemo extends StatefulWidget {
  const AnimatedIconDemo({super.key});

  @override
  State<AnimatedIconDemo> createState() => _AnimatedIconDemoState();
}

class _AnimatedIconDemoState extends State<AnimatedIconDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpened = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpened) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isOpened = !_isOpened;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedIcon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 菜单/关闭
            IconButton(
              iconSize: 48,
              onPressed: _toggle,
              icon: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _controller,
              ),
            ),
            const Text('menu_close'),
            
            const SizedBox(height: 40),
            
            // 播放/暂停
            _AnimatedIconItem(
              icon: AnimatedIcons.play_pause,
              label: 'play_pause',
            ),
            
            const SizedBox(height: 20),
            
            // 列表/网格
            _AnimatedIconItem(
              icon: AnimatedIcons.list_view,
              label: 'list_view',
            ),
            
            const SizedBox(height: 20),
            
            // 搜索
            _AnimatedIconItem(
              icon: AnimatedIcons.search_ellipsis,
              label: 'search_ellipsis',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedIconItem extends StatefulWidget {
  final AnimatedIconData icon;
  final String label;

  const _AnimatedIconItem({
    required this.icon,
    required this.label,
  });

  @override
  State<_AnimatedIconItem> createState() => _AnimatedIconItemState();
}

class _AnimatedIconItemState extends State<_AnimatedIconItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 36,
          onPressed: _toggle,
          icon: AnimatedIcon(
            icon: widget.icon,
            progress: _controller,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Text(widget.label),
      ],
    );
  }
}
```

## AppBar 中使用

```dart
class AnimatedAppBarDemo extends StatefulWidget {
  const AnimatedAppBarDemo({super.key});

  @override
  State<AnimatedAppBarDemo> createState() => _AnimatedAppBarDemoState();
}

class _AnimatedAppBarDemoState extends State<AnimatedAppBarDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      _controller.reverse();
      Navigator.pop(context); // 关闭 drawer
    } else {
      _controller.forward();
      Scaffold.of(context).openDrawer();
    }
    _isDrawerOpen = !_isDrawerOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: _controller,
          ),
          onPressed: _toggleDrawer,
        ),
        title: const Text('Animated AppBar'),
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(child: Text('菜单')),
            ListTile(title: Text('选项 1')),
            ListTile(title: Text('选项 2')),
          ],
        ),
      ),
      body: const Center(child: Text('主内容')),
    );
  }
}
```

## 播放器控制按钮

```dart
class PlayPauseButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isPlaying;

  const PlayPauseButton({
    super.key,
    this.onPressed,
    this.isPlaying = false,
  });

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isPlaying ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 64,
      onPressed: widget.onPressed,
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _controller,
        color: Colors.white,
      ),
    );
  }
}
```

## 使用 TweenAnimationBuilder

如果不想手动管理 AnimationController，可以使用 TweenAnimationBuilder：

```dart
class SimpleAnimatedIcon extends StatefulWidget {
  const SimpleAnimatedIcon({super.key});

  @override
  State<SimpleAnimatedIcon> createState() => _SimpleAnimatedIconState();
}

class _SimpleAnimatedIconState extends State<SimpleAnimatedIcon> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _isOpen ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return IconButton(
          iconSize: 48,
          onPressed: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: AlwaysStoppedAnimation(value),
          ),
        );
      },
    );
  }
}
```

## 注意事项

::: tip 提示
- AnimatedIcon 需要配合 AnimationController 或其他 Animation 使用
- 内置图标数量有限，复杂动画建议使用 Lottie 或自定义绘制
- progress 值范围是 0.0 到 1.0
:::

## 相关组件

- [Icon](../basics/icon.md) - 静态图标
- [IconButton](../buttons/iconbutton.md) - 图标按钮
- [AnimatedSwitcher](./animatedswitcher.md) - 组件切换动画
