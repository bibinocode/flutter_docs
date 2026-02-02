# AnimatedModalBarrier

`AnimatedModalBarrier` 是一个隐式动画组件，用于创建带有平滑颜色过渡动画的模态屏障层，通常用于阻止用户与屏障后面的内容进行交互。

## 基本用法

```dart
class ModalBarrierDemo extends StatefulWidget {
  const ModalBarrierDemo({super.key});

  @override
  State<ModalBarrierDemo> createState() => _ModalBarrierDemoState();
}

class _ModalBarrierDemoState extends State<ModalBarrierDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool _showBarrier = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black54,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBarrier() {
    setState(() {
      _showBarrier = !_showBarrier;
      if (_showBarrier) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景内容
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('点击按钮显示模态屏障'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _toggleBarrier,
                child: const Text('显示屏障'),
              ),
            ],
          ),
        ),
        
        // 模态屏障
        if (_showBarrier)
          AnimatedModalBarrier(
            color: _colorAnimation,
            dismissible: true,
            onDismiss: _toggleBarrier,
          ),
        
        // 屏障上方的内容
        if (_showBarrier)
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('模态对话框'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _toggleBarrier,
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

## 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `color` | `Animation<Color?>` | 屏障颜色的动画 |
| `dismissible` | `bool` | 点击屏障是否可以关闭 |
| `onDismiss` | `VoidCallback?` | 点击屏障时的回调 |
| `semanticsLabel` | `String?` | 无障碍标签 |
| `barrierSemanticsDismissible` | `bool` | 语义上是否可关闭 |

## 自定义加载遮罩

```dart
class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black.withOpacity(0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
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
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading) ...[
          AnimatedModalBarrier(
            color: _colorAnimation,
            dismissible: false,
          ),
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

// 使用示例
class LoadingDemo extends StatefulWidget {
  const LoadingDemo({super.key});

  @override
  State<LoadingDemo> createState() => _LoadingDemoState();
}

class _LoadingDemoState extends State<LoadingDemo> {
  bool _isLoading = false;

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _simulateLoading,
          child: const Text('开始加载'),
        ),
      ),
    );
  }
}
```

## 底部弹出菜单

```dart
class BottomSheetWithBarrier extends StatefulWidget {
  const BottomSheetWithBarrier({super.key});

  @override
  State<BottomSheetWithBarrier> createState() => _BottomSheetWithBarrierState();
}

class _BottomSheetWithBarrierState extends State<BottomSheetWithBarrier>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _barrierAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _barrierAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black54,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主内容
        Center(
          child: ElevatedButton(
            onPressed: _toggle,
            child: const Text('打开菜单'),
          ),
        ),
        
        // 屏障
        if (_isOpen)
          AnimatedModalBarrier(
            color: _barrierAnimation,
            dismissible: true,
            onDismiss: _toggle,
          ),
        
        // 底部弹出内容
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('分享'),
                    onTap: _toggle,
                  ),
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('复制链接'),
                    onTap: _toggle,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('删除'),
                    onTap: _toggle,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 带动画的确认对话框

```dart
class AnimatedConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const AnimatedConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<AnimatedConfirmDialog> createState() => _AnimatedConfirmDialogState();
}

class _AnimatedConfirmDialogState extends State<AnimatedConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _barrierAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _barrierAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black54,
    ).animate(_controller);
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss(VoidCallback callback) async {
    await _controller.reverse();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedModalBarrier(
          color: _barrierAnimation,
          dismissible: true,
          onDismiss: () => _dismiss(widget.onCancel),
        ),
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.message),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _dismiss(widget.onCancel),
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _dismiss(widget.onConfirm),
                            child: const Text('确认'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 注意事项

::: tip 使用场景
- 自定义对话框的背景遮罩
- 加载状态的覆盖层
- 抽屉菜单的背景
- 底部弹出菜单的遮罩
:::

::: warning 注意
- `AnimatedModalBarrier` 需要一个 `Animation<Color?>` 而不是静态颜色
- 通常与 `AnimationController` 配合使用
- 如果只需要静态遮罩，使用 `ModalBarrier` 即可
- 记得在 `dispose` 中释放 `AnimationController`
:::
