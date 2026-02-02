# InkWell

`InkWell` 是 Flutter 中带有 Material Design 涟漪（水波纹）效果的触摸响应组件。当用户点击时，会在触摸点产生向外扩散的水波纹动画效果，为用户提供直观的视觉反馈。它是构建 Material Design 风格交互元素的核心组件。

## 基本用法

```dart
Material(
  child: InkWell(
    onTap: () {
      print('点击了');
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text('点击我'),
    ),
  ),
)
```

> **注意**：`InkWell` 必须有一个 `Material` 祖先组件才能正确显示涟漪效果。

## 常用属性

### 点击回调

| 属性 | 类型 | 说明 |
|------|------|------|
| `onTap` | `GestureTapCallback?` | 点击事件回调 |
| `onDoubleTap` | `GestureTapCallback?` | 双击事件回调 |
| `onLongPress` | `GestureLongPressCallback?` | 长按事件回调 |
| `onTapDown` | `GestureTapDownCallback?` | 手指按下时回调 |
| `onTapUp` | `GestureTapUpCallback?` | 手指抬起时回调 |
| `onTapCancel` | `GestureTapCancelCallback?` | 点击取消时回调 |

### 状态变化回调

| 属性 | 类型 | 说明 |
|------|------|------|
| `onHighlightChanged` | `ValueChanged<bool>?` | 高亮状态变化回调 |
| `onHover` | `ValueChanged<bool>?` | 悬停状态变化回调（桌面端/Web） |
| `onFocusChange` | `ValueChanged<bool>?` | 焦点状态变化回调 |

### 颜色配置

| 属性 | 类型 | 说明 |
|------|------|------|
| `focusColor` | `Color?` | 获得焦点时的覆盖颜色 |
| `hoverColor` | `Color?` | 鼠标悬停时的覆盖颜色 |
| `highlightColor` | `Color?` | 按下高亮时的覆盖颜色 |
| `overlayColor` | `WidgetStateProperty<Color?>?` | 各状态下的覆盖颜色（优先级最高） |
| `splashColor` | `Color?` | 涟漪效果的颜色 |

### 涟漪效果配置

| 属性 | 类型 | 说明 |
|------|------|------|
| `splashFactory` | `InteractiveInkFeatureFactory?` | 涟漪效果工厂，控制涟漪样式 |
| `radius` | `double?` | 涟漪效果的半径 |
| `borderRadius` | `BorderRadius?` | 涟漪效果的圆角边框 |
| `customBorder` | `ShapeBorder?` | 自定义涟漪边框形状 |

### 其他属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `mouseCursor` | `MouseCursor?` | 鼠标光标样式 |
| `enableFeedback` | `bool` | 是否启用触觉反馈，默认 `true` |
| `excludeFromSemantics` | `bool` | 是否从语义树中排除，默认 `false` |
| `focusNode` | `FocusNode?` | 焦点节点 |
| `canRequestFocus` | `bool` | 是否可以请求焦点，默认 `true` |
| `autofocus` | `bool` | 是否自动获取焦点，默认 `false` |
| `statesController` | `WidgetStatesController?` | 状态控制器 |
| `hoverDuration` | `Duration?` | 悬停动画持续时间 |
| `child` | `Widget?` | 子组件 |

### splashFactory 预设值

| 值 | 说明 |
|------|------|
| `InkSplash.splashFactory` | 默认圆形扩散涟漪 |
| `InkRipple.splashFactory` | 快速扩散涟漪 |
| `NoSplash.splashFactory` | 无涟漪效果 |
| `InkSparkle.splashFactory` | 闪烁涟漪效果（Material 3） |

## 使用场景

### 1. 自定义按钮

```dart
class CustomButtonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('自定义按钮被点击');
        },
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Text(
              '渐变按钮',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2. 卡片点击

```dart
class ClickableCardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          print('卡片被点击');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://picsum.photos/260/140',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '卡片标题',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '这是卡片的描述内容，点击整个卡片区域都会有涟漪效果。',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3. 列表项点击

```dart
class ListItemExample extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {'icon': Icons.person, 'title': '个人信息', 'subtitle': '编辑您的个人资料'},
    {'icon': Icons.settings, 'title': '设置', 'subtitle': '应用程序设置'},
    {'icon': Icons.notifications, 'title': '通知', 'subtitle': '管理通知偏好'},
    {'icon': Icons.help, 'title': '帮助', 'subtitle': '获取帮助和支持'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print('点击了: ${item['title']}');
            },
            onLongPress: () {
              print('长按了: ${item['title']}');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'],
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          item['subtitle'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

### 4. 带圆角涟漪

```dart
class RoundedRippleExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 圆形涟漪
        Material(
          color: Colors.blue,
          shape: CircleBorder(),
          child: InkWell(
            onTap: () {},
            customBorder: CircleBorder(),
            child: Container(
              width: 80,
              height: 80,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        
        // 胶囊形涟漪
        Material(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text(
                '胶囊按钮',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        
        // 自定义圆角涟漪
        Material(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text(
                '不规则圆角',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class InkWellDemo extends StatefulWidget {
  @override
  State<InkWellDemo> createState() => _InkWellDemoState();
}

class _InkWellDemoState extends State<InkWellDemo> {
  String _status = '等待交互...';
  bool _isHighlighted = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InkWell 示例'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态显示
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _status,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusChip('高亮', _isHighlighted),
                      SizedBox(width: 12),
                      _buildStatusChip('悬停', _isHovered),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            
            // 自定义卡片按钮
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _status = '✅ 点击完成');
                  },
                  onDoubleTap: () {
                    setState(() => _status = '👆👆 双击');
                  },
                  onLongPress: () {
                    setState(() => _status = '👇 长按');
                  },
                  onTapDown: (details) {
                    setState(() => _status = '⬇️ 按下 ${details.localPosition}');
                  },
                  onTapUp: (details) {
                    setState(() => _status = '⬆️ 抬起');
                  },
                  onTapCancel: () {
                    setState(() => _status = '❌ 取消');
                  },
                  onHighlightChanged: (highlighted) {
                    setState(() => _isHighlighted = highlighted);
                  },
                  onHover: (hovered) {
                    setState(() => _isHovered = hovered);
                  },
                  splashColor: Colors.blue.withOpacity(0.3),
                  highlightColor: Colors.blue.withOpacity(0.1),
                  hoverColor: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.purple.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 280,
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.touch_app,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '自定义卡片按钮',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '尝试点击、双击、长按',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            
            // 不同涟漪效果展示
            Text(
              '涟漪效果样式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSplashDemo(
                  '默认',
                  InkSplash.splashFactory,
                  Colors.blue,
                ),
                _buildSplashDemo(
                  'Ripple',
                  InkRipple.splashFactory,
                  Colors.green,
                ),
                _buildSplashDemo(
                  '无涟漪',
                  NoSplash.splashFactory,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSplashDemo(
    String label,
    InteractiveInkFeatureFactory factory,
    Color color,
  ) {
    return Column(
      children: [
        Material(
          color: color,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {},
            splashFactory: factory,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              child: Icon(
                Icons.touch_app,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
```

## 最佳实践

### 1. InkWell vs GestureDetector

```dart
// ✅ 需要 Material 视觉反馈时使用 InkWell
Material(
  child: InkWell(
    onTap: () => print('有涟漪效果'),
    child: ListTile(title: Text('设置')),
  ),
)

// ✅ 需要复杂手势（拖拽、缩放）时使用 GestureDetector
GestureDetector(
  onPanUpdate: (details) => print('拖拽'),
  onScaleUpdate: (details) => print('缩放'),
  child: Container(),
)

// ✅ 只需简单点击且不需要视觉反馈时使用 GestureDetector
GestureDetector(
  onTap: () => print('无视觉反馈'),
  child: CustomWidget(),
)
```

| 场景 | 推荐使用 |
|------|---------|
| Material Design 风格按钮 | `InkWell` |
| 列表项点击 | `InkWell` |
| 卡片点击 | `InkWell` |
| 拖拽操作 | `GestureDetector` |
| 缩放操作 | `GestureDetector` |
| 自定义视觉反馈 | `GestureDetector` |
| 非 Material 风格界面 | `GestureDetector` |

### 2. 涟漪效果配置

```dart
// ✅ 好：确保涟漪在正确的边界内显示
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(16), // 与卡片圆角匹配
    child: Content(),
  ),
)

// ❌ 差：涟漪会超出圆角边界
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: InkWell(
    onTap: () {},
    // 缺少 borderRadius
    child: Content(),
  ),
)

// ✅ 使用 Ink 组件设置背景
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(12),
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('按钮'),
      ),
    ),
  ),
)

// ❌ 差：Container 的颜色会遮挡涟漪效果
Material(
  child: InkWell(
    onTap: () {},
    child: Container(
      color: Colors.blue, // 会遮挡涟漪
      child: Text('按钮'),
    ),
  ),
)
```

### 3. 自定义涟漪颜色

```dart
// ✅ 使用 overlayColor 统一管理各状态颜色
InkWell(
  onTap: () {},
  overlayColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) {
      return Colors.blue.withOpacity(0.2);
    }
    if (states.contains(WidgetState.hovered)) {
      return Colors.blue.withOpacity(0.1);
    }
    if (states.contains(WidgetState.focused)) {
      return Colors.blue.withOpacity(0.15);
    }
    return null;
  }),
  child: Content(),
)

// ✅ 深色背景使用浅色涟漪
InkWell(
  onTap: () {},
  splashColor: Colors.white24,
  highlightColor: Colors.white10,
  child: DarkBackgroundContent(),
)
```

### 4. 确保有 Material 祖先

```dart
// ✅ 好：确保有 Material 祖先
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: () {},
    child: MyWidget(),
  ),
)

// ✅ 好：Scaffold、Card、Dialog 等自带 Material
Scaffold(
  body: InkWell(
    onTap: () {},
    child: MyWidget(),
  ),
)

// ❌ 差：缺少 Material 祖先，涟漪不显示
Container(
  child: InkWell(
    onTap: () {},
    child: MyWidget(),
  ),
)
```

### 5. 无障碍支持

```dart
// ✅ InkWell 自动添加按钮语义
InkWell(
  onTap: () => _submitForm(),
  child: Text('提交'),
)

// ✅ 需要排除语义时使用 excludeFromSemantics
InkWell(
  onTap: () {},
  excludeFromSemantics: true,
  child: Semantics(
    button: true,
    label: '自定义语义标签',
    child: MyWidget(),
  ),
)
```

## 相关组件

- [GestureDetector](./gesturedetector.md) - 无视觉反馈的手势检测器
- [InkResponse](./inkresponse.md) - 可自定义形状的涟漪响应组件
- [Ink](../material/ink.md) - 用于在 Material 上绘制图像和装饰
- [Material](../material/material.md) - Material Design 视觉效果的基础组件

## 官方文档

- [InkWell API](https://api.flutter.dev/flutter/material/InkWell-class.html)
- [Adding interactivity](https://docs.flutter.dev/development/ui/interactive)
- [Material Design Ripple](https://material.io/design/interaction/states.html)
