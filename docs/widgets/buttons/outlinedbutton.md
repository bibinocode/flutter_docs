# OutlinedButton

`OutlinedButton` 是 Flutter Material Design 中的轮廓按钮组件。它具有透明背景和可见边框，适用于中等强调程度的操作。相比 `ElevatedButton`，轮廓按钮的视觉层级较低，常用于次要操作或与主按钮配合使用。

## 组件特点

- **透明背景**：默认无填充色，仅显示边框
- **边框样式**：可自定义边框颜色、宽度和形状
- **中等强调**：视觉层级介于 TextButton 和 ElevatedButton 之间
- **Material 3 支持**：完全兼容 Material Design 3 规范

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `onPressed` | `VoidCallback?` | 点击回调，为 null 时按钮禁用 |
| `onLongPress` | `VoidCallback?` | 长按回调 |
| `onHover` | `ValueChanged<bool>?` | 鼠标悬停回调 |
| `onFocusChange` | `ValueChanged<bool>?` | 焦点变化回调 |
| `style` | `ButtonStyle?` | 按钮样式配置 |
| `focusNode` | `FocusNode?` | 焦点节点 |
| `autofocus` | `bool` | 是否自动获取焦点，默认 false |
| `clipBehavior` | `Clip` | 裁剪行为，默认 Clip.none |
| `statesController` | `WidgetStatesController?` | 状态控制器 |
| `child` | `Widget?` | 子组件，通常是 Text |

## 构造函数

### 默认构造函数

```dart
OutlinedButton({
  Key? key,
  required VoidCallback? onPressed,
  VoidCallback? onLongPress,
  ValueChanged<bool>? onHover,
  ValueChanged<bool>? onFocusChange,
  ButtonStyle? style,
  FocusNode? focusNode,
  bool autofocus = false,
  Clip clipBehavior = Clip.none,
  WidgetStatesController? statesController,
  required Widget? child,
})
```

### OutlinedButton.icon 构造函数

```dart
OutlinedButton.icon({
  Key? key,
  required VoidCallback? onPressed,
  VoidCallback? onLongPress,
  ButtonStyle? style,
  FocusNode? focusNode,
  bool? autofocus,
  Clip? clipBehavior,
  WidgetStatesController? statesController,
  required Widget icon,
  required Widget label,
})
```

## 使用场景代码示例

### 基础轮廓按钮

```dart
import 'package:flutter/material.dart';

class BasicOutlinedButtonDemo extends StatelessWidget {
  const BasicOutlinedButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础轮廓按钮')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 基础用法
            OutlinedButton(
              onPressed: () {
                print('轮廓按钮被点击');
              },
              child: const Text('轮廓按钮'),
            ),
            const SizedBox(height: 16),

            // 带长按的按钮
            OutlinedButton(
              onPressed: () {
                print('点击');
              },
              onLongPress: () {
                print('长按');
              },
              child: const Text('支持长按'),
            ),
            const SizedBox(height: 16),

            // 设置大小
            SizedBox(
              width: 200,
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('自定义大小'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 带图标的按钮

```dart
import 'package:flutter/material.dart';

class IconOutlinedButtonDemo extends StatelessWidget {
  const IconOutlinedButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('带图标的轮廓按钮')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 使用 .icon 构造函数
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('添加'),
            ),
            const SizedBox(height: 16),

            // 图标在右侧（自定义方式）
            OutlinedButton(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('下一步'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 仅图标按钮
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.favorite_border),
            ),
            const SizedBox(height: 16),

            // 下载按钮示例
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('下载文件'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 自定义边框颜色和样式

```dart
import 'package:flutter/material.dart';

class CustomBorderOutlinedButtonDemo extends StatelessWidget {
  const CustomBorderOutlinedButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义边框样式')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 自定义边框颜色
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green, width: 2),
              ),
              child: const Text('绿色边框'),
            ),
            const SizedBox(height: 16),

            // 圆角边框
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: const BorderSide(color: Colors.purple, width: 2),
                foregroundColor: Colors.purple,
              ),
              child: const Text('圆角边框'),
            ),
            const SizedBox(height: 16),

            // 虚线边框效果（使用 Container 包装）
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.orange,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                foregroundColor: Colors.orange,
              ),
              child: const Text('橙色边框'),
            ),
            const SizedBox(height: 16),

            // 渐变边框效果（需要自定义）
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pink, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    foregroundColor: Colors.purple,
                  ),
                  child: const Text('渐变边框'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 根据状态改变边框颜色
            OutlinedButton(
              onPressed: () {},
              style: ButtonStyle(
                side: WidgetStateProperty.resolveWith<BorderSide>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const BorderSide(color: Colors.red, width: 2);
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return const BorderSide(color: Colors.blue, width: 2);
                    }
                    return const BorderSide(color: Colors.grey, width: 1);
                  },
                ),
              ),
              child: const Text('状态响应边框'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 禁用状态

```dart
import 'package:flutter/material.dart';

class DisabledOutlinedButtonDemo extends StatefulWidget {
  const DisabledOutlinedButtonDemo({super.key});

  @override
  State<DisabledOutlinedButtonDemo> createState() =>
      _DisabledOutlinedButtonDemoState();
}

class _DisabledOutlinedButtonDemoState
    extends State<DisabledOutlinedButtonDemo> {
  bool _isEnabled = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('禁用状态')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 禁用按钮（onPressed 为 null）
            OutlinedButton(
              onPressed: null,
              child: const Text('禁用按钮'),
            ),
            const SizedBox(height: 16),

            // 自定义禁用样式
            OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                disabledForegroundColor: Colors.grey.shade400,
                disabledBackgroundColor: Colors.grey.shade100,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text('自定义禁用样式'),
            ),
            const SizedBox(height: 16),

            // 动态切换禁用状态
            OutlinedButton(
              onPressed: _isEnabled ? () {} : null,
              child: Text(_isEnabled ? '可点击' : '已禁用'),
            ),
            const SizedBox(height: 8),
            Switch(
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // 加载状态按钮
            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await Future.delayed(const Duration(seconds: 2));
                      setState(() {
                        _isLoading = false;
                      });
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('点击加载'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## ButtonStyle 配置

### 使用 styleFrom 快捷方法

```dart
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    // 前景色（文字和图标颜色）
    foregroundColor: Colors.blue,
    // 背景色
    backgroundColor: Colors.transparent,
    // 禁用时的前景色
    disabledForegroundColor: Colors.grey,
    // 禁用时的背景色
    disabledBackgroundColor: Colors.grey.shade100,
    // 阴影颜色
    shadowColor: Colors.black,
    // 表面色调
    surfaceTintColor: Colors.blue,
    // 阴影高度
    elevation: 0,
    // 文字样式
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    // 内边距
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    // 最小尺寸
    minimumSize: const Size(88, 36),
    // 固定尺寸
    fixedSize: const Size(200, 50),
    // 最大尺寸
    maximumSize: const Size(300, 60),
    // 边框样式
    side: const BorderSide(color: Colors.blue, width: 2),
    // 形状
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    // 鼠标光标
    mouseCursor: SystemMouseCursors.click,
    // 视觉密度
    visualDensity: VisualDensity.standard,
    // 点击效果颜色
    tapTargetSize: MaterialTapTargetSize.padded,
    // 动画时长
    animationDuration: const Duration(milliseconds: 200),
    // 是否启用反馈
    enableFeedback: true,
    // 对齐方式
    alignment: Alignment.center,
    // 水波纹效果
    splashFactory: InkRipple.splashFactory,
  ),
  child: const Text('完整样式配置'),
)
```

### 使用 ButtonStyle 直接配置

```dart
OutlinedButton(
  onPressed: () {},
  style: ButtonStyle(
    // 根据状态设置前景色
    foregroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey;
        }
        if (states.contains(WidgetState.pressed)) {
          return Colors.blue.shade700;
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.blue.shade600;
        }
        return Colors.blue;
      },
    ),
    // 根据状态设置背景色
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.blue.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.blue.withOpacity(0.05);
        }
        return Colors.transparent;
      },
    ),
    // 根据状态设置边框
    side: WidgetStateProperty.resolveWith<BorderSide>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: Colors.grey.shade300);
        }
        if (states.contains(WidgetState.pressed)) {
          return const BorderSide(color: Colors.blue, width: 2);
        }
        return const BorderSide(color: Colors.blue);
      },
    ),
    // 覆盖层颜色（水波纹）
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.blue.withOpacity(0.2);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.blue.withOpacity(0.1);
        }
        return null;
      },
    ),
    // 形状
    shape: WidgetStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    // 内边距
    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  child: const Text('状态响应样式'),
)
```

## 主题配置

### 全局主题配置

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        // 配置 OutlinedButton 主题
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal,
            side: const BorderSide(color: Colors.teal, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.tealAccent,
            side: const BorderSide(color: Colors.tealAccent, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const MyApp(),
    ),
  );
}
```

### 局部主题覆盖

```dart
OutlinedButtonTheme(
  data: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.orange,
      side: const BorderSide(color: Colors.orange),
    ),
  ),
  child: Column(
    children: [
      OutlinedButton(
        onPressed: () {},
        child: const Text('继承主题样式'),
      ),
      OutlinedButton(
        onPressed: () {},
        child: const Text('继承主题样式 2'),
      ),
    ],
  ),
)
```

### Material 3 主题配置

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light,
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      // Material 3 风格配置
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class OutlinedButtonDemo extends StatefulWidget {
  const OutlinedButtonDemo({super.key});

  @override
  State<OutlinedButtonDemo> createState() => _OutlinedButtonDemoState();
}

class _OutlinedButtonDemoState extends State<OutlinedButtonDemo> {
  bool _isFollowing = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OutlinedButton 完整示例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 场景1：关注按钮
            _buildSection(
              '关注按钮',
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isFollowing = !_isFollowing;
                  });
                },
                icon: Icon(
                  _isFollowing ? Icons.check : Icons.add,
                ),
                label: Text(_isFollowing ? '已关注' : '关注'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isFollowing ? Colors.grey : Colors.blue,
                  side: BorderSide(
                    color: _isFollowing ? Colors.grey : Colors.blue,
                  ),
                ),
              ),
            ),

            // 场景2：筛选标签组
            _buildSection(
              '筛选标签',
              Wrap(
                spacing: 8,
                children: ['全部', '进行中', '已完成', '已取消']
                    .asMap()
                    .entries
                    .map((entry) {
                  final isSelected = _selectedIndex == entry.key;
                  return OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = entry.key;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isSelected ? Colors.white : Colors.blue,
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.transparent,
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: Text(entry.value),
                  );
                }).toList(),
              ),
            ),

            // 场景3：对话框按钮组
            _buildSection(
              '对话框按钮',
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('确认'),
                  ),
                ],
              ),
            ),

            // 场景4：社交操作按钮
            _buildSection(
              '社交操作',
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up_outlined),
                    label: const Text('点赞'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.comment_outlined),
                    label: const Text('评论'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('分享'),
                  ),
                ],
              ),
            ),

            // 场景5：边框颜色变化
            _buildSection(
              '状态颜色',
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: const Text('成功'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text('警告'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('危险'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
```

## 最佳实践

### 1. 选择合适的按钮类型

```dart
// ✅ OutlinedButton 适用于次要操作
Row(
  children: [
    OutlinedButton(
      onPressed: () {},
      child: const Text('取消'),  // 次要操作
    ),
    const SizedBox(width: 8),
    ElevatedButton(
      onPressed: () {},
      child: const Text('确认'),  // 主要操作
    ),
  ],
)
```

### 2. 保持边框与文字颜色一致

```dart
// ✅ 正确：边框与文字颜色协调
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.blue,
    side: const BorderSide(color: Colors.blue),
  ),
  child: const Text('统一颜色'),
)

// ❌ 避免：颜色不协调
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.red,
    side: const BorderSide(color: Colors.green),
  ),
  child: const Text('颜色混乱'),
)
```

### 3. 合理设置触摸区域

```dart
// ✅ 确保足够的触摸区域
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(48, 48),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  child: const Text('易于点击'),
)
```

### 4. 处理禁用状态反馈

```dart
// ✅ 为禁用按钮提供视觉反馈
OutlinedButton(
  onPressed: isEnabled ? () {} : null,
  style: OutlinedButton.styleFrom(
    disabledForegroundColor: Colors.grey.shade400,
    side: BorderSide(
      color: isEnabled ? Colors.blue : Colors.grey.shade300,
    ),
  ),
  child: Text(isEnabled ? '可用' : '不可用'),
)
```

### 5. 使用主题统一样式

```dart
// ✅ 通过主题统一应用内所有 OutlinedButton 样式
MaterialApp(
  theme: ThemeData(
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
  // ...
)
```

### 6. 无障碍支持

```dart
// ✅ 提供语义化标签
Semantics(
  label: '关注此用户',
  button: true,
  child: OutlinedButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.add),
    label: const Text('关注'),
  ),
)
```

## 常见问题

### Q: 如何去除 OutlinedButton 的边框？

```dart
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    side: BorderSide.none,
  ),
  child: const Text('无边框'),
)
```

### Q: 如何让按钮填满宽度？

```dart
SizedBox(
  width: double.infinity,
  child: OutlinedButton(
    onPressed: () {},
    child: const Text('填满宽度'),
  ),
)
```

### Q: 如何实现圆形按钮？

```dart
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    shape: const CircleBorder(),
    padding: const EdgeInsets.all(20),
  ),
  child: const Icon(Icons.add),
)
```

## 相关组件

- [ElevatedButton](./elevatedbutton.md) - 凸起按钮，用于主要操作
- [TextButton](./textbutton.md) - 文本按钮，用于低强调操作
- [FilledButton](./filledbutton.md) - 填充按钮，Material 3 主要按钮
- [IconButton](./iconbutton.md) - 图标按钮
- [FloatingActionButton](./floatingactionbutton.md) - 悬浮操作按钮

## 官方文档

- [OutlinedButton API](https://api.flutter.dev/flutter/material/OutlinedButton-class.html)
- [OutlinedButton.styleFrom](https://api.flutter.dev/flutter/material/OutlinedButton/styleFrom.html)
- [OutlinedButtonTheme](https://api.flutter.dev/flutter/material/OutlinedButtonTheme-class.html)
- [Material Design Buttons](https://m3.material.io/components/buttons/overview)
