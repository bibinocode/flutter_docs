# AnimatedDefaultTextStyle

AnimatedDefaultTextStyle 是 DefaultTextStyle 的动画版本，当文本样式改变时会自动执行平滑过渡动画。

## 基本用法

```dart
AnimatedDefaultTextStyle(
  style: TextStyle(
    fontSize: _large ? 40 : 20,
    color: _large ? Colors.blue : Colors.black,
    fontWeight: _large ? FontWeight.bold : FontWeight.normal,
  ),
  duration: const Duration(milliseconds: 300),
  child: const Text('Hello Flutter'),
)
```

## 构造函数

```dart
const AnimatedDefaultTextStyle({
  super.key,
  required this.child,              // 子组件（通常是 Text）
  required this.style,              // 文本样式
  this.textAlign,                   // 文本对齐
  this.softWrap = true,             // 是否自动换行
  this.overflow = TextOverflow.clip, // 溢出处理
  this.maxLines,                    // 最大行数
  this.textWidthBasis = TextWidthBasis.parent,
  this.textHeightBehavior,
  this.curve = Curves.linear,       // 动画曲线
  required super.duration,          // 动画时长
  super.onEnd,                      // 动画结束回调
})
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `style` | `TextStyle` | 文本样式 |
| `child` | `Widget` | 子组件 |
| `textAlign` | `TextAlign?` | 文本对齐方式 |
| `softWrap` | `bool` | 是否自动换行 |
| `overflow` | `TextOverflow` | 溢出处理方式 |
| `maxLines` | `int?` | 最大行数 |
| `duration` | `Duration` | 动画持续时间 |
| `curve` | `Curve` | 动画曲线 |

## 完整示例

```dart
import 'package:flutter/material.dart';

class AnimatedTextStyleDemo extends StatefulWidget {
  const AnimatedTextStyleDemo({super.key});

  @override
  State<AnimatedTextStyleDemo> createState() => _AnimatedTextStyleDemoState();
}

class _AnimatedTextStyleDemoState extends State<AnimatedTextStyleDemo> {
  bool _isLarge = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedDefaultTextStyle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              style: TextStyle(
                fontSize: _isLarge ? 48 : 24,
                color: _isLarge ? Colors.blue : Colors.grey,
                fontWeight: _isLarge ? FontWeight.bold : FontWeight.normal,
                letterSpacing: _isLarge ? 4 : 0,
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: const Text('Flutter'),
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLarge = !_isLarge;
                });
              },
              child: Text(_isLarge ? '缩小' : '放大'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 多状态文本样式

```dart
class MultiStateTextDemo extends StatefulWidget {
  const MultiStateTextDemo({super.key});

  @override
  State<MultiStateTextDemo> createState() => _MultiStateTextDemoState();
}

class _MultiStateTextDemoState extends State<MultiStateTextDemo> {
  int _currentState = 0;

  final List<TextStyle> _styles = [
    const TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.normal,
    ),
    const TextStyle(
      fontSize: 28,
      color: Colors.blue,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    ),
    const TextStyle(
      fontSize: 36,
      color: Colors.red,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
    const TextStyle(
      fontSize: 24,
      color: Colors.green,
      fontWeight: FontWeight.w300,
      letterSpacing: 8,
    ),
  ];

  void _nextState() {
    setState(() {
      _currentState = (_currentState + 1) % _styles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextState,
      child: AnimatedDefaultTextStyle(
        style: _styles[_currentState],
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: const Text('点击切换样式'),
      ),
    );
  }
}
```

## 输入框焦点提示动画

```dart
class AnimatedLabelTextField extends StatefulWidget {
  const AnimatedLabelTextField({super.key});

  @override
  State<AnimatedLabelTextField> createState() => _AnimatedLabelTextFieldState();
}

class _AnimatedLabelTextFieldState extends State<AnimatedLabelTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          style: TextStyle(
            fontSize: _isFocused ? 14 : 12,
            color: _isFocused ? Colors.blue : Colors.grey,
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
          ),
          duration: const Duration(milliseconds: 200),
          child: const Text('用户名'),
        ),
        const SizedBox(height: 8),
        TextField(
          focusNode: _focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isFocused ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 可动画的样式属性

以下 TextStyle 属性支持动画过渡：

- `fontSize` - 字体大小
- `color` - 文字颜色
- `backgroundColor` - 背景色
- `fontWeight` - 字重
- `letterSpacing` - 字符间距
- `wordSpacing` - 单词间距
- `height` - 行高
- `decorationColor` - 装饰线颜色
- `decorationThickness` - 装饰线粗细

::: warning 注意
`fontFamily`、`fontStyle`、`decoration` 等属性不支持平滑过渡，会直接切换。
:::

## 相关组件

- [AnimatedContainer](./animatedcontainer.md) - 动画容器
- [Text](../basics/text.md) - 文本组件
