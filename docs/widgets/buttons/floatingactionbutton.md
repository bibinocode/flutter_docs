# FloatingActionButton

`FloatingActionButton`（浮动操作按钮，简称 FAB）是 Material Design 中的核心组件，用于表示屏幕上最重要的操作。它悬浮在内容之上，通常位于屏幕右下角，以圆形按钮的形式呈现，带有阴影效果，非常醒目。

## 基本用法

```dart
FloatingActionButton(
  onPressed: () {
    // 执行操作
  },
  child: Icon(Icons.add),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `onPressed` | `VoidCallback?` | 必需 | 点击回调，为 null 时按钮禁用 |
| `child` | `Widget?` | - | 按钮内容，通常是图标 |
| `tooltip` | `String?` | - | 长按提示文本 |
| `backgroundColor` | `Color?` | 主题色 | 按钮背景色 |
| `foregroundColor` | `Color?` | - | 前景色（图标/文字颜色） |
| `elevation` | `double?` | 6.0 | 正常状态阴影高度 |
| `focusElevation` | `double?` | 8.0 | 获得焦点时阴影高度 |
| `hoverElevation` | `double?` | 8.0 | 悬停时阴影高度 |
| `highlightElevation` | `double?` | 12.0 | 按下时阴影高度 |
| `disabledElevation` | `double?` | 6.0 | 禁用时阴影高度 |
| `heroTag` | `Object?` | 自动生成 | Hero 动画标签，同屏多个 FAB 需设置不同值 |
| `shape` | `ShapeBorder?` | CircleBorder | 按钮形状 |
| `mini` | `bool` | false | 是否使用小尺寸（40x40） |
| `splashColor` | `Color?` | - | 水波纹颜色 |
| `focusColor` | `Color?` | - | 获得焦点时的颜色 |
| `hoverColor` | `Color?` | - | 悬停时的颜色 |
| `autofocus` | `bool` | false | 是否自动获取焦点 |
| `clipBehavior` | `Clip` | Clip.none | 裁剪行为 |
| `enableFeedback` | `bool?` | true | 是否启用触觉反馈 |

## FAB 的四种变体

Flutter 提供了四种 FAB 构造函数，适用于不同场景：

### 1. 标准 FAB（Regular）

默认尺寸为 56x56 像素：

```dart
FloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
)
```

### 2. 小型 FAB（Small）

使用 `mini: true` 或 `.small()` 构造函数，尺寸为 40x40 像素：

```dart
// 方式一：使用 mini 属性
FloatingActionButton(
  mini: true,
  onPressed: () {},
  child: Icon(Icons.add),
)

// 方式二：使用 small 构造函数
FloatingActionButton.small(
  onPressed: () {},
  child: Icon(Icons.add),
)
```

### 3. 大型 FAB（Large）

使用 `.large()` 构造函数，尺寸为 96x96 像素：

```dart
FloatingActionButton.large(
  onPressed: () {},
  child: Icon(Icons.add, size: 36),
)
```

### 4. 扩展 FAB（Extended）

带有文字标签的 FAB，适合需要更明确操作提示的场景：

```dart
FloatingActionButton.extended(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('新建任务'),
)
```

## 使用场景示例

### 基础 FAB

```dart
import 'package:flutter/material.dart';

class BasicFabDemo extends StatelessWidget {
  const BasicFabDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础 FAB')),
      body: const Center(
        child: Text('点击右下角按钮添加项目'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FAB 被点击了！')),
          );
        },
        tooltip: '添加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 扩展 FAB（带文字）

```dart
class ExtendedFabDemo extends StatefulWidget {
  const ExtendedFabDemo({super.key});

  @override
  State<ExtendedFabDemo> createState() => _ExtendedFabDemoState();
}

class _ExtendedFabDemoState extends State<ExtendedFabDemo> {
  bool _isExtended = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扩展 FAB')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(
          title: Text('项目 $index'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 创建新内容
        },
        isExtended: _isExtended, // 可以动态控制是否展开
        icon: const Icon(Icons.edit),
        label: const Text('撰写'),
      ),
    );
  }
}
```

### 动态收缩的扩展 FAB

根据滚动方向动态展开/收缩：

```dart
class AnimatedExtendedFab extends StatefulWidget {
  const AnimatedExtendedFab({super.key});

  @override
  State<AnimatedExtendedFab> createState() => _AnimatedExtendedFabState();
}

class _AnimatedExtendedFabState extends State<AnimatedExtendedFab> {
  bool _isExtended = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态扩展 FAB')),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            // 向下滚动时收缩，向上滚动时展开
            setState(() {
              _isExtended = notification.scrollDelta! < 0;
            });
          }
          return false;
        },
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(child: Text('$index')),
            title: Text('列表项 $index'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        isExtended: _isExtended,
        icon: const Icon(Icons.navigation),
        label: const Text('导航'),
      ),
    );
  }
}
```

### 多个 FAB（Speed Dial 效果）

```dart
class SpeedDialDemo extends StatefulWidget {
  const SpeedDialDemo({super.key});

  @override
  State<SpeedDialDemo> createState() => _SpeedDialDemoState();
}

class _SpeedDialDemoState extends State<SpeedDialDemo>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speed Dial FAB')),
      body: const Center(child: Text('展开 FAB 查看更多选项')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 子按钮们
          ScaleTransition(
            scale: _animation,
            child: FloatingActionButton(
              heroTag: 'camera',
              mini: true,
              onPressed: () {},
              tooltip: '拍照',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          const SizedBox(height: 12),
          ScaleTransition(
            scale: _animation,
            child: FloatingActionButton(
              heroTag: 'image',
              mini: true,
              onPressed: () {},
              tooltip: '相册',
              child: const Icon(Icons.image),
            ),
          ),
          const SizedBox(height: 12),
          ScaleTransition(
            scale: _animation,
            child: FloatingActionButton(
              heroTag: 'file',
              mini: true,
              onPressed: () {},
              tooltip: '文件',
              child: const Icon(Icons.attach_file),
            ),
          ),
          const SizedBox(height: 16),
          // 主按钮
          FloatingActionButton(
            heroTag: 'main',
            onPressed: _toggleMenu,
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0, // 旋转 45 度
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 不同位置的 FAB

```dart
class FabPositionDemo extends StatefulWidget {
  const FabPositionDemo({super.key});

  @override
  State<FabPositionDemo> createState() => _FabPositionDemoState();
}

class _FabPositionDemoState extends State<FabPositionDemo> {
  FloatingActionButtonLocation _fabLocation =
      FloatingActionButtonLocation.endFloat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAB 位置')),
      body: Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildLocationButton('endFloat', FloatingActionButtonLocation.endFloat),
            _buildLocationButton('centerFloat', FloatingActionButtonLocation.centerFloat),
            _buildLocationButton('startFloat', FloatingActionButtonLocation.startFloat),
            _buildLocationButton('endDocked', FloatingActionButtonLocation.endDocked),
            _buildLocationButton('centerDocked', FloatingActionButtonLocation.centerDocked),
            _buildLocationButton('startDocked', FloatingActionButtonLocation.startDocked),
            _buildLocationButton('endTop', FloatingActionButtonLocation.endTop),
            _buildLocationButton('centerTop', FloatingActionButtonLocation.centerTop),
            _buildLocationButton('startTop', FloatingActionButtonLocation.startTop),
            _buildLocationButton('miniEndFloat', FloatingActionButtonLocation.miniEndFloat),
            _buildLocationButton('miniCenterFloat', FloatingActionButtonLocation.miniCenterFloat),
            _buildLocationButton('miniStartFloat', FloatingActionButtonLocation.miniStartFloat),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: _fabLocation,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            const SizedBox(width: 48), // FAB 位置占位
            IconButton(icon: const Icon(Icons.favorite), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(String label, FloatingActionButtonLocation location) {
    return ElevatedButton(
      onPressed: () => setState(() => _fabLocation = location),
      style: ElevatedButton.styleFrom(
        backgroundColor: _fabLocation == location ? Colors.blue : null,
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}
```

## 与 Scaffold 配合使用

FAB 最常与 `Scaffold` 配合使用，通过 `floatingActionButton` 和 `floatingActionButtonLocation` 属性进行配置：

### 嵌入 BottomNavigationBar

```dart
class DockFabDemo extends StatelessWidget {
  const DockFabDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('嵌入底部导航')),
      body: const Center(child: Text('FAB 嵌入底部导航栏')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // 创建缺口
        notchMargin: 8.0, // 缺口边距
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            const SizedBox(width: 48), // FAB 占位
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

### FAB 位置一览

| 位置常量 | 说明 |
|---------|------|
| `endFloat` | 右下角悬浮（默认） |
| `centerFloat` | 底部居中悬浮 |
| `startFloat` | 左下角悬浮 |
| `endDocked` | 右下角嵌入 BottomAppBar |
| `centerDocked` | 底部居中嵌入 BottomAppBar |
| `startDocked` | 左下角嵌入 BottomAppBar |
| `endTop` | 右上角 |
| `centerTop` | 顶部居中 |
| `startTop` | 左上角 |
| `miniEndFloat` | 右下角悬浮（mini 专用） |
| `miniCenterFloat` | 底部居中悬浮（mini 专用） |
| `miniStartFloat` | 左下角悬浮（mini 专用） |

## 动画效果

### FAB 出现/消失动画

```dart
class FabAnimationDemo extends StatefulWidget {
  const FabAnimationDemo({super.key});

  @override
  State<FabAnimationDemo> createState() => _FabAnimationDemoState();
}

class _FabAnimationDemoState extends State<FabAnimationDemo> {
  bool _showFab = true;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAB 动画')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('切换底部导航，FAB 会有动画效果'),
            const SizedBox(height: 20),
            Switch(
              value: _showFab,
              onChanged: (value) => setState(() => _showFab = value),
            ),
            const Text('手动控制 FAB 显示'),
          ],
        ),
      ),
      // FAB 切换时会自动有缩放动画
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // 在特定页面隐藏 FAB
            _showFab = index == 0;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
```

### 自定义 Hero 动画

```dart
class HeroFabDemo extends StatelessWidget {
  const HeroFabDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero FAB')),
      body: const Center(child: Text('点击 FAB 查看 Hero 动画')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'uniqueTag', // 自定义 Hero 标签
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SecondPage()),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第二页')),
      body: const Center(child: Text('FAB 通过 Hero 动画过渡')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'uniqueTag', // 相同的 Hero 标签
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
```

## 自定义样式

### 自定义颜色和形状

```dart
FloatingActionButton(
  onPressed: () {},
  backgroundColor: Colors.purple,
  foregroundColor: Colors.white,
  elevation: 10,
  highlightElevation: 20,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Icon(Icons.star),
)
```

### 渐变背景

```dart
Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.pink, Colors.orange],
    ),
    shape: BoxShape.circle,
  ),
  child: FloatingActionButton(
    onPressed: () {},
    backgroundColor: Colors.transparent,
    elevation: 0,
    child: const Icon(Icons.favorite),
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class FloatingActionButtonDemo extends StatefulWidget {
  const FloatingActionButtonDemo({super.key});

  @override
  State<FloatingActionButtonDemo> createState() =>
      _FloatingActionButtonDemoState();
}

class _FloatingActionButtonDemoState extends State<FloatingActionButtonDemo> {
  int _counter = 0;
  bool _isExtended = true;
  FloatingActionButtonLocation _fabLocation =
      FloatingActionButtonLocation.endFloat;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FloatingActionButton 示例'),
        actions: [
          PopupMenuButton<FloatingActionButtonLocation>(
            icon: const Icon(Icons.location_on),
            onSelected: (location) {
              setState(() => _fabLocation = location);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: FloatingActionButtonLocation.endFloat,
                child: Text('endFloat'),
              ),
              const PopupMenuItem(
                value: FloatingActionButtonLocation.centerFloat,
                child: Text('centerFloat'),
              ),
              const PopupMenuItem(
                value: FloatingActionButtonLocation.centerDocked,
                child: Text('centerDocked'),
              ),
              const PopupMenuItem(
                value: FloatingActionButtonLocation.endDocked,
                child: Text('endDocked'),
              ),
            ],
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final delta = notification.scrollDelta ?? 0;
            if (delta > 0 && _isExtended) {
              setState(() => _isExtended = false);
            } else if (delta < 0 && !_isExtended) {
              setState(() => _isExtended = true);
            }
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '计数器: $_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('点击右下角的 FAB 增加计数'),
                    const Text('滚动页面查看扩展 FAB 的动态效果'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('FAB 变体展示:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'small',
                      onPressed: () {},
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 4),
                    const Text('Small'),
                  ],
                ),
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'regular',
                      onPressed: () {},
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 4),
                    const Text('Regular'),
                  ],
                ),
                Column(
                  children: [
                    FloatingActionButton.large(
                      heroTag: 'large',
                      onPressed: () {},
                      child: const Icon(Icons.add, size: 32),
                    ),
                    const SizedBox(height: 4),
                    const Text('Large'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'extended_demo',
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Extended FAB'),
            ),
            // 添加更多内容以便滚动
            ...List.generate(
              20,
              (index) => ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('列表项 ${index + 1}'),
                subtitle: const Text('滚动查看 FAB 效果'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementCounter,
        isExtended: _isExtended,
        icon: const Icon(Icons.add),
        label: const Text('添加'),
        tooltip: '增加计数',
      ),
      floatingActionButtonLocation: _fabLocation,
      bottomNavigationBar: _fabLocation.toString().contains('Docked')
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: const Icon(Icons.home), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  const SizedBox(width: 48),
                  IconButton(icon: const Icon(Icons.favorite), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.person), onPressed: () {}),
                ],
              ),
            )
          : null,
    );
  }
}
```

## 最佳实践

1. **一个屏幕一个 FAB**：FAB 代表屏幕上最重要的操作，每个屏幕最多只应有一个主要 FAB

2. **使用正向操作**：FAB 应该执行正向、建设性的操作，如创建、添加、分享等，避免用于删除等破坏性操作

3. **设置唯一 heroTag**：如果同一页面有多个 FAB，必须为每个设置不同的 `heroTag`，否则会导致 Hero 动画冲突

4. **提供 tooltip**：始终设置 `tooltip` 属性，提高可访问性

5. **响应式设计**：在大屏幕上考虑使用 `FloatingActionButton.extended` 提供更多上下文

6. **避免遮挡内容**：确保 FAB 不会遮挡重要内容，必要时调整位置或在滚动时隐藏

7. **图标选择**：使用清晰、易于理解的图标，如 `+` 表示添加，编辑图标表示编辑

8. **颜色对比**：确保 FAB 与背景有足够的颜色对比度，提高可见性

9. **禁用状态处理**：当操作不可用时，设置 `onPressed: null` 而不是空函数

10. **配合 Scaffold 使用**：优先使用 `Scaffold.floatingActionButton` 而非手动定位

## 相关组件

- [ElevatedButton](./elevatedbutton.md) - 常规凸起按钮
- [IconButton](./iconbutton.md) - 图标按钮
- [BottomAppBar](../material/bottomappbar.md) - 底部应用栏，可与 FAB 配合
- [Scaffold](../material/scaffold.md) - 页面脚手架，管理 FAB 位置

## 官方文档

- [FloatingActionButton API](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html)
- [Material Design FAB 规范](https://m3.material.io/components/floating-action-button/overview)
