# ElevatedButton

`ElevatedButton` 是 Material Design 3 中的凸起按钮，具有阴影效果，是 Flutter 中最常用的主要操作按钮。适用于需要强调的重要操作。

## 基本用法

```dart
ElevatedButton(
  onPressed: () {
    print('按钮被点击');
  },
  child: Text('点击我'),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `onPressed` | `VoidCallback?` | 点击回调（null 表示禁用） |
| `onLongPress` | `VoidCallback?` | 长按回调 |
| `onHover` | `ValueChanged&lt;bool&gt;?` | 悬停回调 |
| `onFocusChange` | `ValueChanged&lt;bool&gt;?` | 焦点变化回调 |
| `style` | `ButtonStyle?` | 按钮样式 |
| `focusNode` | `FocusNode?` | 焦点节点 |
| `autofocus` | `bool` | 是否自动获取焦点 |
| `clipBehavior` | `Clip` | 裁剪行为 |
| `child` | `Widget?` | 子组件 |

## ButtonStyle 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `backgroundColor` | `WidgetStateProperty&lt;Color?&gt;` | 背景色 |
| `foregroundColor` | `WidgetStateProperty&lt;Color?&gt;` | 前景色（文字/图标） |
| `overlayColor` | `WidgetStateProperty&lt;Color?&gt;` | 点击水波纹颜色 |
| `shadowColor` | `WidgetStateProperty&lt;Color?&gt;` | 阴影颜色 |
| `surfaceTintColor` | `WidgetStateProperty&lt;Color?&gt;` | 表面着色 |
| `elevation` | `WidgetStateProperty&lt;double?&gt;` | 阴影高度 |
| `padding` | `WidgetStateProperty&lt;EdgeInsetsGeometry?&gt;` | 内边距 |
| `minimumSize` | `WidgetStateProperty&lt;Size?&gt;` | 最小尺寸 |
| `fixedSize` | `WidgetStateProperty&lt;Size?&gt;` | 固定尺寸 |
| `maximumSize` | `WidgetStateProperty&lt;Size?&gt;` | 最大尺寸 |
| `side` | `WidgetStateProperty&lt;BorderSide?&gt;` | 边框 |
| `shape` | `WidgetStateProperty&lt;OutlinedBorder?&gt;` | 形状 |
| `textStyle` | `WidgetStateProperty&lt;TextStyle?&gt;` | 文本样式 |

## 使用场景

### 1. 基础按钮

```dart
Column(
  children: [
    // 启用状态
    ElevatedButton(
      onPressed: () {},
      child: Text('启用按钮'),
    ),
    
    // 禁用状态
    ElevatedButton(
      onPressed: null, // null 表示禁用
      child: Text('禁用按钮'),
    ),
  ],
)
```

### 2. 带图标的按钮

```dart
ElevatedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('添加'),
)

// 自定义图标位置
ElevatedButton(
  onPressed: () {},
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('下一步'),
      SizedBox(width: 8),
      Icon(Icons.arrow_forward),
    ],
  ),
)
```

### 3. 自定义样式

```dart
// 使用 styleFrom
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    elevation: 8,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  child: Text('自定义样式'),
)

// 完全圆角按钮
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    shape: StadiumBorder(),
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
  ),
  child: Text('圆角按钮'),
)
```

### 4. 不同状态的颜色

```dart
ElevatedButton(
  onPressed: () {},
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.green.shade700;
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.green.shade600;
        }
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey;
        }
        return Colors.green;
      },
    ),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  ),
  child: Text('状态颜色'),
)
```

### 5. 加载状态按钮

```dart
class LoadingButton extends StatefulWidget {
  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(Duration(seconds: 2)); // 模拟异步操作
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(150, 48),
      ),
      child: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text('提交'),
    );
  }
}
```

### 6. 全宽按钮

```dart
// 方法 1: 使用 minimumSize
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 48),
  ),
  child: Text('全宽按钮'),
)

// 方法 2: 使用 SizedBox
SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    onPressed: () {},
    child: Text('全宽按钮'),
  ),
)

// 方法 3: 使用 Expanded（在 Row 中）
Row(
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () {},
        child: Text('全宽按钮'),
      ),
    ),
  ],
)
```

### 7. 按钮组

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
        ),
      ),
      child: Text('左'),
    ),
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text('中'),
    ),
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
      ),
      child: Text('右'),
    ),
  ],
)
```

### 8. 渐变按钮

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    ),
    child: Text('渐变按钮', style: TextStyle(color: Colors.white)),
  ),
)
```

### 9. 全局主题设置

```dart
MaterialApp(
  theme: ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
  ),
  home: MyHomePage(),
)
```

## Material 3 按钮类型对比

| 按钮类型 | 用途 | 强调程度 |
|----------|------|----------|
| `ElevatedButton` | 主要操作 | ⭐⭐⭐⭐ |
| `FilledButton` | 重要操作（M3） | ⭐⭐⭐⭐⭐ |
| `FilledButton.tonal` | 次要重要操作 | ⭐⭐⭐ |
| `OutlinedButton` | 次要操作 | ⭐⭐ |
| `TextButton` | 最低优先级操作 | ⭐ |

## ElevatedButton vs FilledButton

| 特性 | ElevatedButton | FilledButton |
|------|----------------|--------------|
| Material 版本 | M2/M3 | M3 only |
| 阴影 | 有 | 无 |
| 背景色 | 浅色 | 主题色填充 |
| 视觉效果 | 凸起 | 扁平填充 |

## 最佳实践

1. **限制使用**: 每个页面只有一两个主要操作使用 ElevatedButton
2. **合理的尺寸**: 最小高度建议 48px（符合无障碍要求）
3. **明确的文案**: 使用动词开头的简短文案
4. **加载状态**: 异步操作时显示加载指示器
5. **禁用状态**: 条件不满足时禁用而不是隐藏
6. **主题一致性**: 使用主题统一设置样式

## 常见问题

::: warning 按钮宽度问题
ElevatedButton 默认宽度由内容决定。如需固定宽度：
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(120, 40),
    // 或 fixedSize: Size(120, 40),
  ),
  // ...
)
```
:::

::: tip 去除默认内边距
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
  // ...
)
```
:::

## 相关组件

- [FilledButton](./filledbutton) - 填充按钮（M3）
- [OutlinedButton](./outlinedbutton) - 边框按钮
- [TextButton](./textbutton) - 文本按钮
- [IconButton](./iconbutton) - 图标按钮
- [FloatingActionButton](./fab) - 浮动操作按钮

## 官方文档

- [ElevatedButton API](https://api.flutter.dev/flutter/material/ElevatedButton-class.html)
- [Material Buttons](https://m3.material.io/components/buttons/overview)
