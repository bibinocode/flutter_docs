# IconButton

`IconButton` 是 Flutter 中的图标按钮组件，它在一个圆形区域内显示一个图标，点击时会产生水波纹效果。IconButton 是工具栏、AppBar 和各种交互界面中最常用的按钮类型之一，非常适合用于触发简单操作或切换状态。

## 组件特点

- **紧凑设计**：仅显示图标，不包含文字，节省界面空间
- **触摸反馈**：内置水波纹（ripple）效果，提供良好的触觉反馈
- **无障碍支持**：支持 tooltip 提示，便于屏幕阅读器识别
- **Material 3 支持**：提供 `filled`、`filledTonal`、`outlined` 等变体样式

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `icon` | `Widget` | 必需 | 按钮显示的图标，通常是 `Icon` 组件 |
| `onPressed` | `VoidCallback?` | `null` | 点击回调，为 null 时按钮禁用 |
| `tooltip` | `String?` | `null` | 长按时显示的提示文字 |
| `iconSize` | `double?` | `24.0` | 图标大小 |
| `color` | `Color?` | `null` | 图标颜色（未按下状态） |
| `splashRadius` | `double?` | `null` | 水波纹半径 |
| `splashColor` | `Color?` | `null` | 水波纹颜色 |
| `highlightColor` | `Color?` | `null` | 按下时的高亮颜色 |
| `hoverColor` | `Color?` | `null` | 悬停时的颜色 |
| `focusColor` | `Color?` | `null` | 获得焦点时的颜色 |
| `disabledColor` | `Color?` | `null` | 禁用状态时的图标颜色 |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(8.0)` | 内边距 |
| `alignment` | `AlignmentGeometry` | `Alignment.center` | 图标对齐方式 |
| `constraints` | `BoxConstraints?` | `null` | 按钮约束（最小宽高） |
| `style` | `ButtonStyle?` | `null` | 按钮样式（Material 3） |
| `isSelected` | `bool?` | `null` | 是否选中状态（Material 3） |
| `selectedIcon` | `Widget?` | `null` | 选中状态显示的图标 |
| `visualDensity` | `VisualDensity?` | `null` | 视觉密度 |
| `autofocus` | `bool` | `false` | 是否自动获取焦点 |
| `enableFeedback` | `bool?` | `true` | 是否启用触觉反馈 |

## 基本用法

### 基础图标按钮

```dart
IconButton(
  icon: const Icon(Icons.favorite),
  onPressed: () {
    print('喜欢按钮被点击');
  },
)
```

### 带 tooltip 的图标按钮

```dart
IconButton(
  icon: const Icon(Icons.share),
  tooltip: '分享',
  onPressed: () {
    print('分享内容');
  },
)
```

### 禁用状态

```dart
IconButton(
  icon: const Icon(Icons.delete),
  tooltip: '删除',
  onPressed: null, // null 表示禁用
)
```

## 使用场景示例

### 1. AppBar 中使用

```dart
class AppBarIconButtonDemo extends StatelessWidget {
  const AppBarIconButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图标按钮示例'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: '菜单',
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {
              print('打开搜索');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: '通知',
            onPressed: () {
              print('查看通知');
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: '更多',
            onPressed: () {
              print('显示更多选项');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('AppBar 中的图标按钮'),
      ),
    );
  }
}
```

### 2. 切换状态按钮（收藏功能）

```dart
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorited ? Icons.favorite : Icons.favorite_border,
        color: _isFavorited ? Colors.red : null,
      ),
      tooltip: _isFavorited ? '取消收藏' : '收藏',
      onPressed: () {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      },
    );
  }
}
```

### 3. 使用 isSelected 属性（Material 3）

```dart
class ToggleIconButton extends StatefulWidget {
  const ToggleIconButton({super.key});

  @override
  State<ToggleIconButton> createState() => _ToggleIconButtonState();
}

class _ToggleIconButtonState extends State<ToggleIconButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      isSelected: _isSelected,
      icon: const Icon(Icons.bookmark_border),
      selectedIcon: const Icon(Icons.bookmark),
      tooltip: '书签',
      onPressed: () {
        setState(() {
          _isSelected = !_isSelected;
        });
      },
    );
  }
}
```

### 4. 自定义样式

```dart
class CustomStyledIconButton extends StatelessWidget {
  const CustomStyledIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 自定义颜色和大小
        IconButton(
          icon: const Icon(Icons.thumb_up),
          iconSize: 36,
          color: Colors.blue,
          splashRadius: 28,
          tooltip: '点赞',
          onPressed: () {},
        ),
        const SizedBox(height: 16),

        // 自定义水波纹颜色
        IconButton(
          icon: const Icon(Icons.star),
          iconSize: 32,
          color: Colors.amber,
          splashColor: Colors.amber.withOpacity(0.3),
          highlightColor: Colors.amber.withOpacity(0.1),
          onPressed: () {},
        ),
        const SizedBox(height: 16),

        // 减小点击区域
        IconButton(
          icon: const Icon(Icons.edit),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
          iconSize: 20,
          onPressed: () {},
        ),
      ],
    );
  }
}
```

### 5. 带背景色的图标按钮

```dart
class IconButtonWithBackground extends StatelessWidget {
  const IconButtonWithBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 方式一：使用 Container 包裹
        Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),

        // 方式二：使用 Ink 组件
        Ink(
          decoration: const ShapeDecoration(
            color: Colors.green,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: const Icon(Icons.check),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),

        // 方式三：使用 CircleAvatar
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
```

## Material 3 变体样式

Flutter 3.x 引入了 Material 3 设计，为 IconButton 提供了新的变体构造函数：

### IconButton.filled

填充背景色的图标按钮，用于强调主要操作：

```dart
class FilledIconButtonDemo extends StatelessWidget {
  const FilledIconButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          icon: const Icon(Icons.add),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const Icon(Icons.edit),
          onPressed: null, // 禁用状态
        ),
      ],
    );
  }
}
```

### IconButton.filledTonal

使用次要颜色填充的图标按钮，比 filled 更柔和：

```dart
IconButton.filledTonal(
  icon: const Icon(Icons.volume_up),
  onPressed: () {},
)
```

### IconButton.outlined

带边框轮廓的图标按钮，适合次要操作：

```dart
class OutlinedIconButtonDemo extends StatelessWidget {
  const OutlinedIconButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          icon: const Icon(Icons.share),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {},
        ),
      ],
    );
  }
}
```

### 所有 M3 变体对比

```dart
class M3IconButtonVariants extends StatelessWidget {
  const M3IconButtonVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
            const Text('标准'),
          ],
        ),
        Column(
          children: [
            IconButton.filled(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
            const Text('Filled'),
          ],
        ),
        Column(
          children: [
            IconButton.filledTonal(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
            const Text('Tonal'),
          ],
        ),
        Column(
          children: [
            IconButton.outlined(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
            const Text('Outlined'),
          ],
        ),
      ],
    );
  }
}
```

## 使用 ButtonStyle 自定义样式

```dart
IconButton(
  icon: const Icon(Icons.favorite),
  style: IconButton.styleFrom(
    foregroundColor: Colors.pink,
    backgroundColor: Colors.pink.shade50,
    disabledForegroundColor: Colors.grey,
    hoverColor: Colors.pink.shade100,
    focusColor: Colors.pink.shade200,
    highlightColor: Colors.pink.shade300,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: () {},
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class IconButtonDemo extends StatefulWidget {
  const IconButtonDemo({super.key});

  @override
  State<IconButtonDemo> createState() => _IconButtonDemoState();
}

class _IconButtonDemoState extends State<IconButtonDemo> {
  bool _isFavorited = false;
  bool _isBookmarked = false;
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IconButton 示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
            tooltip: _isMuted ? '取消静音' : '静音',
            onPressed: () {
              setState(() => _isMuted = !_isMuted);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基础按钮
            const Text('基础图标按钮', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : null,
                  ),
                  tooltip: '收藏',
                  onPressed: () {
                    setState(() => _isFavorited = !_isFavorited);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: '分享',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: '删除（禁用）',
                  onPressed: null,
                ),
              ],
            ),
            const Divider(height: 32),

            // Material 3 变体
            const Text('Material 3 变体', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            const Divider(height: 32),

            // 切换按钮
            const Text('切换状态按钮', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filled(
                  isSelected: _isBookmarked,
                  icon: const Icon(Icons.bookmark_border),
                  selectedIcon: const Icon(Icons.bookmark),
                  onPressed: () {
                    setState(() => _isBookmarked = !_isBookmarked);
                  },
                ),
                const SizedBox(width: 16),
                Text(_isBookmarked ? '已添加书签' : '添加书签'),
              ],
            ),
            const Divider(height: 32),

            // 自定义大小
            const Text('自定义大小', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.star),
                  iconSize: 16,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  iconSize: 24,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  iconSize: 32,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  iconSize: 48,
                  onPressed: () {},
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

1. **始终提供 tooltip**：为了无障碍访问，每个 IconButton 都应该设置有意义的 tooltip 属性

2. **使用语义化图标**：选择能够清晰表达操作含义的图标，避免歧义

3. **合理设置点击区域**：默认的 48x48 点击区域符合 Material Design 规范，不建议设置得过小

4. **状态切换使用 isSelected**：Material 3 推荐使用 `isSelected` 和 `selectedIcon` 来实现切换效果

5. **禁用状态提供反馈**：当按钮禁用时，考虑使用 tooltip 说明原因

6. **注意颜色对比度**：确保图标颜色与背景有足够的对比度，特别是自定义颜色时

7. **选择合适的变体**：
   - 主要操作：使用 `IconButton.filled`
   - 次要操作：使用 `IconButton.filledTonal` 或 `IconButton.outlined`
   - 常规操作：使用标准 `IconButton`

8. **在列表中优化性能**：大量 IconButton 时避免使用匿名函数作为 onPressed

```dart
// ❌ 避免
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: () => deleteItem(item.id),
)

// ✅ 推荐
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: () => _handleDelete(item.id),
)
```

## 相关组件

- [ElevatedButton](./elevatedbutton.md) - 凸起按钮，用于主要操作
- [TextButton](./textbutton.md) - 文字按钮，用于次要操作
- [OutlinedButton](./outlinedbutton.md) - 边框按钮
- [FloatingActionButton](./floatingactionbutton.md) - 浮动操作按钮
- [PopupMenuButton](./popupmenubutton.md) - 弹出菜单按钮
- [Icon](../basics/icon.md) - 图标组件
- [InkWell](../gesture/inkwell.md) - 水波纹效果组件

## 官方文档

- [IconButton API](https://api.flutter.dev/flutter/material/IconButton-class.html)
- [Material Design 3 - Icon Buttons](https://m3.material.io/components/icon-buttons/overview)
