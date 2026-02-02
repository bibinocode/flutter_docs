# ElevatedButton

`ElevatedButton` 是 Material Design 中的凸起按钮，具有阴影和填充背景，用于页面中的主要操作。

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
| `onPressed` | `VoidCallback?` | 点击回调，为 null 时按钮禁用 |
| `onLongPress` | `VoidCallback?` | 长按回调 |
| `child` | `Widget?` | 按钮内容 |
| `style` | `ButtonStyle?` | 按钮样式 |
| `autofocus` | `bool` | 是否自动获取焦点 |
| `clipBehavior` | `Clip` | 裁剪行为 |

## 使用场景

### 1. 基础按钮样式

```dart
Column(
  children: [
    // 普通按钮
    ElevatedButton(
      onPressed: () {},
      child: Text('普通按钮'),
    ),
    SizedBox(height: 10),
    
    // 禁用按钮
    ElevatedButton(
      onPressed: null,
      child: Text('禁用按钮'),
    ),
    SizedBox(height: 10),
    
    // 带图标的按钮
    ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(Icons.add),
      label: Text('带图标按钮'),
    ),
  ],
)
```

### 2. 自定义样式

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    // 前景色（文字和图标）
    foregroundColor: Colors.white,
    // 背景色
    backgroundColor: Colors.purple,
    // 禁用时的颜色
    disabledForegroundColor: Colors.grey.shade400,
    disabledBackgroundColor: Colors.grey.shade200,
    // 阴影颜色
    shadowColor: Colors.purple.withOpacity(0.5),
    // 阴影高度
    elevation: 8,
    // 内边距
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    // 最小尺寸
    minimumSize: Size(120, 48),
    // 固定尺寸
    fixedSize: Size(200, 50),
    // 圆角
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    // 文字样式
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  child: Text('自定义样式'),
)
```

### 3. 渐变背景按钮

```dart
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient gradient;

  const GradientButton({
    required this.onPressed,
    required this.child,
    this.gradient = const LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : null,
        color: onPressed == null ? Colors.grey : null,
        borderRadius: BorderRadius.circular(25),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: child,
      ),
    );
  }
}

// 使用
GradientButton(
  onPressed: () {},
  child: Text('渐变按钮', style: TextStyle(color: Colors.white)),
)
```

### 4. 加载状态按钮

```dart
class LoadingButton extends StatefulWidget {
  final Future&lt;void&gt; Function() onPressed;
  final String text;
  final String loadingText;

  const LoadingButton({
    required this.onPressed,
    required this.text,
    this.loadingText = '加载中...',
  });

  @override
  State&lt;LoadingButton&gt; createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State&lt;LoadingButton&gt; {
  bool _isLoading = false;

  Future&lt;void&gt; _handlePress() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      child: _isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(widget.loadingText),
              ],
            )
          : Text(widget.text),
    );
  }
}

// 使用
LoadingButton(
  text: '提交',
  loadingText: '提交中...',
  onPressed: () async {
    await Future.delayed(Duration(seconds: 2));
  },
)
```

### 5. 全局按钮主题

```dart
MaterialApp(
  theme: ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        minimumSize: Size(88, 48),
        padding: EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
)
```

## 按钮类型对比

| 按钮类型 | 强调程度 | 使用场景 |
|---------|---------|---------|
| `ElevatedButton` | 高 | 主要操作，如提交表单、确认购买 |
| `FilledButton` | 高 | Material 3 推荐的强调按钮 |
| `FilledButton.tonal` | 中 | 次要但重要的操作 |
| `OutlinedButton` | 中 | 次要操作，与主按钮配对使用 |
| `TextButton` | 低 | 最低优先级，如取消、跳过 |

## 最佳实践

1. **明确层次**: 一个页面通常只有一个主要操作按钮
2. **文字清晰**: 使用动词描述操作，如"提交"、"保存"、"删除"
3. **大小适中**: 确保点击区域足够大（至少 48x48）
4. **反馈状态**: 提供 loading、disabled 等状态反馈
5. **无障碍**: 添加 semanticsLabel 提高可访问性

## 相关组件

- [FilledButton](./filledbutton) - Material 3 填充按钮
- [OutlinedButton](./outlinedbutton) - 轮廓按钮
- [TextButton](./textbutton) - 文字按钮
- [IconButton](./iconbutton) - 图标按钮
- [FloatingActionButton](./floatingactionbutton) - 浮动操作按钮

## 官方文档

- [ElevatedButton API](https://api.flutter.dev/flutter/material/ElevatedButton-class.html)
- [Material Buttons](https://m3.material.io/components/buttons/overview)
