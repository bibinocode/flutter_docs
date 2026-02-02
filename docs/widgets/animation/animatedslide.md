# AnimatedSlide

`AnimatedSlide` 是一个隐式动画组件，可以平滑地动画改变子组件的位置偏移量。它基于 `Offset` 值来控制滑动方向和距离。

## 基本用法

```dart
class SlideDemo extends StatefulWidget {
  const SlideDemo({super.key});

  @override
  State<SlideDemo> createState() => _SlideDemoState();
}

class _SlideDemoState extends State<SlideDemo> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          color: Colors.grey[200],
          child: Center(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              offset: _offset,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // 方向控制按钮
        Column(
          children: [
            IconButton(
              onPressed: () => setState(() => _offset = const Offset(0, -1)),
              icon: const Icon(Icons.arrow_upward),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => _offset = const Offset(-1, 0)),
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: () => setState(() => _offset = Offset.zero),
                  icon: const Icon(Icons.center_focus_strong),
                ),
                IconButton(
                  onPressed: () => setState(() => _offset = const Offset(1, 0)),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            IconButton(
              onPressed: () => setState(() => _offset = const Offset(0, 1)),
              icon: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
      ],
    );
  }
}
```

## 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `offset` | `Offset` | 相对于子组件尺寸的偏移量 |
| `duration` | `Duration` | 动画持续时间 |
| `curve` | `Curve` | 动画曲线 |
| `onEnd` | `VoidCallback?` | 动画结束回调 |

::: info Offset 说明
- `Offset(1, 0)` - 向右移动一个子组件宽度
- `Offset(-1, 0)` - 向左移动一个子组件宽度
- `Offset(0, 1)` - 向下移动一个子组件高度
- `Offset(0, -1)` - 向上移动一个子组件高度
- `Offset(0.5, 0.5)` - 向右下移动半个子组件尺寸
:::

## 列表项滑入动画

```dart
class SlideInList extends StatefulWidget {
  const SlideInList({super.key});

  @override
  State<SlideInList> createState() => _SlideInListState();
}

class _SlideInListState extends State<SlideInList> {
  final List<bool> _visible = List.generate(10, (_) => false);

  @override
  void initState() {
    super.initState();
    _animateItems();
  }

  Future<void> _animateItems() async {
    for (int i = 0; i < _visible.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() => _visible[i] = true);
      }
    }
  }

  void _reset() {
    setState(() {
      for (int i = 0; i < _visible.length; i++) {
        _visible[i] = false;
      }
    });
    _animateItems();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _reset,
          child: const Text('重新播放'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _visible.length,
            itemBuilder: (context, index) {
              return AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                offset: _visible[index] ? Offset.zero : const Offset(1, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _visible[index] ? 1.0 : 0.0,
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('列表项 ${index + 1}'),
                      subtitle: const Text('从右侧滑入'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 通知横幅

```dart
class NotificationBanner extends StatefulWidget {
  const NotificationBanner({super.key});

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  bool _showBanner = false;
  String _message = '';

  void _showNotification(String message) {
    setState(() {
      _message = message;
      _showBanner = true;
    });

    // 3秒后自动隐藏
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showBanner = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主内容
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showNotification('操作成功！'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('成功通知'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showNotification('发生错误，请重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('错误通知'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showNotification('您有新消息'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('消息通知'),
              ),
            ],
          ),
        ),
        
        // 通知横幅
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: _showBanner ? Offset.zero : const Offset(0, -1),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _showBanner = false),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
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

## 侧边菜单

```dart
class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主内容
        GestureDetector(
          onTap: () {
            if (_isMenuOpen) {
              setState(() => _isMenuOpen = false);
            }
          },
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            offset: _isMenuOpen ? const Offset(0.7, 0) : Offset.zero,
            child: Container(
              color: Colors.white,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isMenuOpen = true),
                  child: const Text('打开菜单'),
                ),
              ),
            ),
          ),
        ),
        
        // 侧边菜单
        AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          offset: _isMenuOpen ? Offset.zero : const Offset(-1, 0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            color: Colors.blueGrey[800],
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 40),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '用户名',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'user@example.com',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  _buildMenuItem(Icons.home, '首页'),
                  _buildMenuItem(Icons.person, '个人资料'),
                  _buildMenuItem(Icons.settings, '设置'),
                  _buildMenuItem(Icons.help, '帮助'),
                  const Spacer(),
                  _buildMenuItem(Icons.logout, '退出登录'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () => setState(() => _isMenuOpen = false),
    );
  }
}
```

## 切换卡片效果

```dart
class CardSwitcher extends StatefulWidget {
  const CardSwitcher({super.key});

  @override
  State<CardSwitcher> createState() => _CardSwitcherState();
}

class _CardSwitcherState extends State<CardSwitcher> {
  int _currentIndex = 0;
  Offset _slideDirection = Offset.zero;
  
  final List<Map<String, dynamic>> _cards = [
    {'color': Colors.red, 'title': '卡片 1'},
    {'color': Colors.green, 'title': '卡片 2'},
    {'color': Colors.blue, 'title': '卡片 3'},
  ];

  void _next() {
    setState(() {
      _slideDirection = const Offset(-1, 0);
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  void _previous() {
    setState(() {
      _slideDirection = const Offset(1, 0);
      _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: _slideDirection,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: Container(
              key: ValueKey(_currentIndex),
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: _cards[_currentIndex]['color'],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _cards[_currentIndex]['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _previous,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            const SizedBox(width: 32),
            IconButton(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ],
    );
  }
}
```

## 注意事项

::: tip 使用场景
- 列表项滑入/滑出动画
- 通知横幅的显示/隐藏
- 侧边菜单的展开/收起
- 页面切换动画
- 表单验证错误提示的显示
:::

::: warning 与 SlideTransition 区别
- `AnimatedSlide` - 隐式动画，自动处理动画过程
- `SlideTransition` - 显式动画，需要 `AnimationController`
- 简单场景用 `AnimatedSlide`，复杂场景用 `SlideTransition`
:::
