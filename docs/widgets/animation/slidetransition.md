# SlideTransition

`SlideTransition` 是 Flutter 中用于创建显式位移动画的组件。它通过 `Animation<Offset>` 控制子组件的位置变化，需要配合 `AnimationController` 使用，提供对动画的完全控制能力。位移值以子组件自身尺寸为单位，例如 `Offset(1, 0)` 表示向右移动一个组件宽度。

## 基本用法

```dart
SlideTransition(
  position: _offsetAnimation,
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
| `position` | `Animation<Offset>` | 控制位移的动画对象，值为相对于子组件尺寸的偏移量（必需） |
| `textDirection` | `TextDirection?` | 文本方向，影响水平位移的方向。`ltr` 时正值向右，`rtl` 时正值向左 |
| `transformHitTests` | `bool` | 是否变换点击测试区域，默认 `true`。为 `true` 时点击区域随组件移动 |
| `child` | `Widget?` | 要应用位移动画的子组件 |

## Offset 说明

`Offset` 的值是相对于子组件自身尺寸的比例：

| Offset 值 | 效果说明 |
|-----------|----------|
| `Offset(0, 0)` | 原始位置 |
| `Offset(1, 0)` | 向右移动一个组件宽度 |
| `Offset(-1, 0)` | 向左移动一个组件宽度 |
| `Offset(0, 1)` | 向下移动一个组件高度 |
| `Offset(0, -1)` | 向上移动一个组件高度 |
| `Offset(0.5, 0.5)` | 向右下移动半个组件尺寸 |
| `Offset(2, 0)` | 向右移动两个组件宽度 |

## AnimationController 配合使用

`SlideTransition` 是显式动画组件，必须与 `AnimationController` 配合使用：

```dart
class SlideTransitionDemo extends StatefulWidget {
  @override
  State<SlideTransitionDemo> createState() => _SlideTransitionDemoState();
}

class _SlideTransitionDemoState extends State<SlideTransitionDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 使用 Tween<Offset> 定义起始和结束位置
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // 从左侧屏幕外开始
      end: Offset.zero,            // 移动到原位置
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

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        width: 200,
        height: 100,
        color: Colors.blue,
        child: const Center(
          child: Text('滑入内容', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
```

## 使用场景

### 1. 入场动画

页面元素从屏幕外滑入：

```dart
class EntryAnimationDemo extends StatefulWidget {
  @override
  State<EntryAnimationDemo> createState() => _EntryAnimationDemoState();
}

class _EntryAnimationDemoState extends State<EntryAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 从底部滑入
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    // 页面加载后自动播放
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('欢迎回来！', style: Theme.of(context).textTheme.headlineMedium),
        ),
      ),
    );
  }
}
```

### 2. 侧滑菜单

从侧边滑出的菜单面板：

```dart
class SlideMenuDemo extends StatefulWidget {
  @override
  State<SlideMenuDemo> createState() => _SlideMenuDemoState();
}

class _SlideMenuDemoState extends State<SlideMenuDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // 从左侧隐藏
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
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
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: _toggleMenu,
            ),
            title: const Text('侧滑菜单示例'),
          ),
          body: const Center(child: Text('主页面内容')),
        ),
        // 侧边菜单
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: 250,
            height: double.infinity,
            color: Colors.blueGrey[800],
            child: SafeArea(
              child: Column(
                children: [
                  const UserAccountsDrawerHeader(
                    accountName: Text('用户名'),
                    accountEmail: Text('user@example.com'),
                    currentAccountPicture: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.white),
                    title: const Text('首页', style: TextStyle(color: Colors.white)),
                    onTap: _toggleMenu,
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text('设置', style: TextStyle(color: Colors.white)),
                    onTap: _toggleMenu,
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

### 3. 消息提示滑入

顶部或底部滑入的提示消息：

```dart
class SlideNotificationDemo extends StatefulWidget {
  @override
  State<SlideNotificationDemo> createState() => _SlideNotificationDemoState();
}

class _SlideNotificationDemoState extends State<SlideNotificationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // 从顶部滑入
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

  void _showNotification() async {
    _controller.forward();
    await Future.delayed(const Duration(seconds: 2));
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息提示')),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _showNotification,
              child: const Text('显示通知'),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('操作成功！', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. 列表项滑入动画

列表项依次滑入的效果：

```dart
class SlideListDemo extends StatefulWidget {
  @override
  State<SlideListDemo> createState() => _SlideListDemoState();
}

class _SlideListDemoState extends State<SlideListDemo>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  final List<String> _items = ['项目 1', '项目 2', '项目 3', '项目 4', '项目 5'];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(1, 0), // 从右侧滑入
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();
    
    // 依次播放动画
    _playAnimations();
  }

  void _playAnimations() async {
    for (var controller in _controllers) {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('列表滑入动画')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: _animations[index],
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(_items[index]),
                subtitle: const Text('描述信息'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (var controller in _controllers) {
            controller.reset();
          }
          _playAnimations();
        },
        child: const Icon(Icons.replay),
      ),
    );
  }
}
```

## 完整示例：侧边栏滑入动画

```dart
import 'package:flutter/material.dart';

class SidebarSlideDemo extends StatefulWidget {
  const SidebarSlideDemo({super.key});

  @override
  State<SidebarSlideDemo> createState() => _SidebarSlideDemoState();
}

class _SidebarSlideDemoState extends State<SidebarSlideDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _sidebarAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 侧边栏滑入动画
    _sidebarAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // 遮罩层淡入动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主内容区域
          _buildMainContent(),

          // 遮罩层
          if (_isSidebarOpen || _controller.isAnimating)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _toggleSidebar,
                  child: Container(
                    color: Colors.black.withOpacity(_fadeAnimation.value),
                  ),
                );
              },
            ),

          // 侧边栏
          SlideTransition(
            position: _sidebarAnimation,
            child: _buildSidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _controller,
          ),
          onPressed: _toggleSidebar,
        ),
        title: const Text('SlideTransition 示例'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swipe_right, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              '点击左上角菜单按钮\n或从左侧滑动打开侧边栏',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Material(
      elevation: 16,
      child: Container(
        width: 280,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[700]!, Colors.indigo[900]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.indigo),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '欢迎使用',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'user@example.com',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              // 菜单项
              _buildMenuItem(Icons.home, '首页', true),
              _buildMenuItem(Icons.favorite, '收藏', false),
              _buildMenuItem(Icons.history, '历史记录', false),
              _buildMenuItem(Icons.settings, '设置', false),
              const Spacer(),
              const Divider(color: Colors.white24),
              _buildMenuItem(Icons.logout, '退出登录', false),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: _toggleSidebar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
```

## 最佳实践

### 1. Tween\<Offset\> 使用技巧

```dart
// 常用的滑动方向设置
// 从左侧滑入
Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)

// 从右侧滑入
Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)

// 从顶部滑入
Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)

// 从底部滑入
Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)

// 对角线滑入
Tween<Offset>(begin: const Offset(-1, -1), end: Offset.zero)

// 滑出到右侧
Tween<Offset>(begin: Offset.zero, end: const Offset(1, 0))
```

### 2. 配合 CurvedAnimation 使用

```dart
_offsetAnimation = Tween<Offset>(
  begin: const Offset(-1, 0),
  end: Offset.zero,
).animate(CurvedAnimation(
  parent: _controller,
  curve: Curves.easeOutCubic,    // 推荐用于入场动画
  reverseCurve: Curves.easeInCubic, // 推荐用于退出动画
));
```

### 3. 组合多个动画

```dart
// 同时实现滑入和淡入效果
FadeTransition(
  opacity: _fadeAnimation,
  child: SlideTransition(
    position: _slideAnimation,
    child: YourWidget(),
  ),
)
```

### 4. 注意事项

- 始终在 `dispose` 中释放 `AnimationController`
- 使用 `SingleTickerProviderStateMixin`（单个动画）或 `TickerProviderStateMixin`（多个动画）
- `transformHitTests` 设为 `false` 可以让点击区域保持在原位置
- 在 RTL 语言环境下注意 `textDirection` 的影响

## 相关组件

- [AnimatedPositioned](./animatedpositioned.md) - 隐式位置动画，适合简单场景
- [PositionedTransition](https://api.flutter.dev/flutter/widgets/PositionedTransition-class.html) - 在 Stack 中使用的显式位置动画
- [FadeTransition](./fadetransition.md) - 显式透明度动画，常与 SlideTransition 配合使用

## 官方文档

- [SlideTransition API](https://api.flutter.dev/flutter/widgets/SlideTransition-class.html)
- [Tween API](https://api.flutter.dev/flutter/animation/Tween-class.html)
