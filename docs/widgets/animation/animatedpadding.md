# AnimatedPadding

AnimatedPadding 是 Padding 的动画版本，当 padding 值改变时会自动执行平滑过渡动画。

## 基本用法

```dart
AnimatedPadding(
  padding: EdgeInsets.all(_expanded ? 50.0 : 8.0),
  duration: const Duration(milliseconds: 300),
  child: Container(
    color: Colors.blue,
    child: const Text('Hello'),
  ),
)
```

## 构造函数

```dart
const AnimatedPadding({
  super.key,
  required this.padding,           // 内边距
  this.child,                       // 子组件
  this.curve = Curves.linear,       // 动画曲线
  required super.duration,          // 动画时长
  super.onEnd,                      // 动画结束回调
})
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `padding` | `EdgeInsetsGeometry` | 内边距值 |
| `child` | `Widget?` | 子组件 |
| `duration` | `Duration` | 动画持续时间 |
| `curve` | `Curve` | 动画曲线 |
| `onEnd` | `VoidCallback?` | 动画完成回调 |

## 完整示例

```dart
import 'package:flutter/material.dart';

class AnimatedPaddingDemo extends StatefulWidget {
  const AnimatedPaddingDemo({super.key});

  @override
  State<AnimatedPaddingDemo> createState() => _AnimatedPaddingDemoState();
}

class _AnimatedPaddingDemoState extends State<AnimatedPaddingDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedPadding')),
      body: Column(
        children: [
          // 动画效果展示
          Container(
            height: 200,
            color: Colors.grey[200],
            child: AnimatedPadding(
              padding: EdgeInsets.all(_expanded ? 50.0 : 8.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              onEnd: () {
                print('动画完成');
              },
              child: Container(
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    'Padding 动画',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 控制按钮
          ElevatedButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Text(_expanded ? '收缩' : '展开'),
          ),
        ],
      ),
    );
  }
}
```

## 列表项展开效果

```dart
class ExpandableListItem extends StatefulWidget {
  final String title;
  final String content;

  const ExpandableListItem({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableListItem> createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          AnimatedPadding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: _isExpanded ? 16 : 0,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Text(widget.content),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 与 AnimatedContainer 对比

| 特性 | AnimatedPadding | AnimatedContainer |
|------|-----------------|-------------------|
| 动画属性 | 仅 padding | 多种属性 |
| 性能 | 更轻量 | 相对较重 |
| 使用场景 | 仅需 padding 动画 | 需要多属性动画 |

::: tip 提示
如果只需要 padding 动画，使用 AnimatedPadding 比 AnimatedContainer 更高效。
:::

## 相关组件

- [AnimatedContainer](./animatedcontainer.md) - 多属性动画容器
- [Padding](../basics/padding.md) - 静态内边距组件
