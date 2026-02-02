# AnimatedCrossFade

`AnimatedCrossFade` 用于在两个子组件之间实现交叉淡入淡出动画效果。当状态切换时，一个组件淡出的同时另一个组件淡入，并自动处理两个组件尺寸不同时的平滑过渡。

## 基本用法

```dart
AnimatedCrossFade(
  duration: Duration(milliseconds: 300),
  firstChild: Icon(Icons.favorite, size: 48, color: Colors.red),
  secondChild: Icon(Icons.favorite_border, size: 48, color: Colors.grey),
  crossFadeState: _isFavorite 
      ? CrossFadeState.showFirst 
      : CrossFadeState.showSecond,
)
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `firstChild` | `Widget` | 第一个子组件（必需） |
| `secondChild` | `Widget` | 第二个子组件（必需） |
| `crossFadeState` | `CrossFadeState` | 当前显示状态：`showFirst` 或 `showSecond`（必需） |
| `duration` | `Duration` | 动画时长（必需） |
| `reverseDuration` | `Duration?` | 反向动画时长，默认与 duration 相同 |
| `firstCurve` | `Curve` | 第一个子组件的动画曲线，默认 `Curves.linear` |
| `secondCurve` | `Curve` | 第二个子组件的动画曲线，默认 `Curves.linear` |
| `sizeCurve` | `Curve` | 尺寸变化的动画曲线，默认 `Curves.linear` |
| `alignment` | `AlignmentGeometry` | 子组件对齐方式，默认 `Alignment.topCenter` |
| `layoutBuilder` | `AnimatedCrossFadeBuilder?` | 自定义布局构建器 |
| `excludeBottomFocus` | `bool` | 是否排除底部组件的焦点，默认 `true` |

## CrossFadeState 状态

| 值 | 说明 |
|------|------|
| `CrossFadeState.showFirst` | 显示第一个子组件 |
| `CrossFadeState.showSecond` | 显示第二个子组件 |

## 使用场景

### 1. 加载状态切换

```dart
class LoadingStateDemo extends StatefulWidget {
  @override
  _LoadingStateDemoState createState() => _LoadingStateDemoState();
}

class _LoadingStateDemoState extends State<LoadingStateDemo> {
  bool _isLoading = false;

  void _handleSubmit() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2)); // 模拟网络请求
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 200),
      firstChild: ElevatedButton(
        onPressed: _handleSubmit,
        child: Text('提交'),
      ),
      secondChild: ElevatedButton(
        onPressed: null,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      crossFadeState: _isLoading 
          ? CrossFadeState.showSecond 
          : CrossFadeState.showFirst,
    );
  }
}
```

### 2. 展开/收起内容

```dart
class ExpandCollapseDemo extends StatefulWidget {
  @override
  _ExpandCollapseDemoState createState() => _ExpandCollapseDemoState();
}

class _ExpandCollapseDemoState extends State<ExpandCollapseDemo> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('详细信息', style: TextStyle(color: Colors.white)),
                AnimatedCrossFade(
                  duration: Duration(milliseconds: 200),
                  firstChild: Icon(Icons.expand_more, color: Colors.white),
                  secondChild: Icon(Icons.expand_less, color: Colors.white),
                  crossFadeState: _isExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
          firstChild: SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Text('这是展开后显示的详细内容...'),
          ),
          crossFadeState: _isExpanded 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}
```

### 3. 图标切换

```dart
class IconToggleDemo extends StatefulWidget {
  @override
  _IconToggleDemoState createState() => _IconToggleDemoState();
}

class _IconToggleDemoState extends State<IconToggleDemo> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 48,
      onPressed: () => setState(() => _isPlaying = !_isPlaying),
      icon: AnimatedCrossFade(
        duration: Duration(milliseconds: 200),
        firstChild: Icon(Icons.play_arrow, color: Colors.blue),
        secondChild: Icon(Icons.pause, color: Colors.blue),
        crossFadeState: _isPlaying 
            ? CrossFadeState.showSecond 
            : CrossFadeState.showFirst,
      ),
    );
  }
}
```

### 4. 内容切换（成功/错误状态）

```dart
class ResultStateDemo extends StatefulWidget {
  @override
  _ResultStateDemoState createState() => _ResultStateDemoState();
}

class _ResultStateDemoState extends State<ResultStateDemo> {
  bool _isSuccess = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedCrossFade(
          duration: Duration(milliseconds: 400),
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeOut,
          firstChild: Column(
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('操作成功！', style: TextStyle(fontSize: 18)),
            ],
          ),
          secondChild: Column(
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('操作失败，请重试', style: TextStyle(fontSize: 18)),
            ],
          ),
          crossFadeState: _isSuccess 
              ? CrossFadeState.showFirst 
              : CrossFadeState.showSecond,
        ),
        SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => setState(() => _isSuccess = !_isSuccess),
          child: Text('切换状态'),
        ),
      ],
    );
  }
}
```

## 完整示例：加载按钮状态切换

```dart
import 'package:flutter/material.dart';

class LoadingButtonDemo extends StatefulWidget {
  @override
  _LoadingButtonDemoState createState() => _LoadingButtonDemoState();
}

class _LoadingButtonDemoState extends State<LoadingButtonDemo> {
  ButtonState _state = ButtonState.idle;

  void _handlePress() async {
    if (_state != ButtonState.idle) return;
    
    setState(() => _state = ButtonState.loading);
    
    // 模拟异步操作
    await Future.delayed(Duration(seconds: 2));
    
    setState(() => _state = ButtonState.success);
    
    // 显示成功状态后恢复
    await Future.delayed(Duration(seconds: 1));
    setState(() => _state = ButtonState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimatedCrossFade 示例')),
      body: Center(
        child: SizedBox(
          width: 200,
          height: 48,
          child: AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            sizeCurve: Curves.easeInOut,
            alignment: Alignment.center,
            firstChild: _buildIdleButton(),
            secondChild: _buildLoadingOrSuccessButton(),
            crossFadeState: _state == ButtonState.idle
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          ),
        ),
      ),
    );
  }

  Widget _buildIdleButton() {
    return SizedBox(
      width: 200,
      height: 48,
      child: ElevatedButton(
        onPressed: _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          '提交',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingOrSuccessButton() {
    return SizedBox(
      width: 200,
      height: 48,
      child: AnimatedCrossFade(
        duration: Duration(milliseconds: 200),
        firstChild: _buildLoadingButton(),
        secondChild: _buildSuccessButton(),
        crossFadeState: _state == ButtonState.loading
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      width: 200,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blue[300],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessButton() {
    return Container(
      width: 200,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(Icons.check, color: Colors.white, size: 28),
      ),
    );
  }
}

enum ButtonState { idle, loading, success }
```

## 自定义布局构建器

默认情况下，两个子组件使用 Stack 堆叠。可以通过 `layoutBuilder` 自定义布局：

```dart
AnimatedCrossFade(
  duration: Duration(milliseconds: 300),
  firstChild: Text('First'),
  secondChild: Text('Second'),
  crossFadeState: CrossFadeState.showFirst,
  layoutBuilder: (
    Widget topChild,
    Key topChildKey,
    Widget bottomChild,
    Key bottomChildKey,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          key: bottomChildKey,
          child: bottomChild,
        ),
        Positioned(
          key: topChildKey,
          child: topChild,
        ),
      ],
    );
  },
)
```

## 最佳实践

### AnimatedCrossFade vs AnimatedSwitcher

| 特性 | AnimatedCrossFade | AnimatedSwitcher |
|------|-------------------|------------------|
| 子组件数量 | 固定两个 | 任意数量 |
| 尺寸过渡 | 内置平滑尺寸动画 | 需要额外处理 |
| 自定义动画 | 有限 | 高度可定制 |
| 使用场景 | 二元状态切换 | 多状态/复杂切换 |
| 性能 | 同时保持两个子组件 | 只保持当前子组件 |

**选择建议：**
- 两个固定组件切换，且尺寸不同 → `AnimatedCrossFade`
- 多个组件切换，或需要自定义过渡动画 → `AnimatedSwitcher`
- 仅需要淡入淡出单个组件 → `AnimatedOpacity`

### 注意事项

1. **两个子组件始终存在**：即使不显示，两个子组件都会被构建，注意性能开销
2. **尺寸差异处理**：组件会自动处理不同尺寸子组件之间的平滑过渡
3. **避免频繁切换**：快速连续切换可能导致动画效果不佳
4. **对齐方式**：默认 `topCenter` 对齐，根据需要调整 `alignment`

## 相关组件

- [AnimatedSwitcher](./animatedswitcher.md) - 支持任意数量子组件切换的动画组件
- [AnimatedOpacity](./animatedopacity.md) - 单个组件的透明度动画
- [FadeTransition](./fadetransition.md) - 显式淡入淡出动画

## 官方文档

- [AnimatedCrossFade API](https://api.flutter.dev/flutter/widgets/AnimatedCrossFade-class.html)
