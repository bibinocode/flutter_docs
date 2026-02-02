# 布局系统

Flutter 的布局系统基于 Widget 组合，使用约束（Constraints）从上向下传递，尺寸（Size）从下向上返回。

## 布局原理

### 约束传递

```
父 Widget
    ↓ 约束 (Constraints)
子 Widget
    ↓ 约束
孙 Widget
    ↑ 尺寸 (Size)
子 Widget
    ↑ 尺寸
父 Widget
```

### 三条规则

1. **约束向下传递**：父 Widget 告诉子 Widget 可用空间范围
2. **尺寸向上返回**：子 Widget 决定自己的尺寸
3. **父 Widget 决定位置**：父 Widget 根据子 Widget 尺寸决定其位置

## 基础布局 Widget

### Container

最常用的布局 Widget，结合了装饰、填充、约束等功能。

```dart
Container(
  width: 200,
  height: 100,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(vertical: 8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Text('Hello'),
)
```

### SizedBox

固定尺寸或作为间距。

```dart
// 固定尺寸
SizedBox(
  width: 100,
  height: 50,
  child: Text('固定大小'),
)

// 作为间距
Column(
  children: [
    Text('上'),
    SizedBox(height: 16),  // 垂直间距
    Text('下'),
  ],
)

// 占满可用空间
SizedBox.expand(child: Text('占满'))
```

### ConstrainedBox

添加额外约束。

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 300,
    minHeight: 50,
    maxHeight: 200,
  ),
  child: Text('受约束的内容'),
)
```

## 线性布局

### Row（水平）

```dart
Row(
  // 主轴对齐（水平）
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // 交叉轴对齐（垂直）
  crossAxisAlignment: CrossAxisAlignment.center,
  // 主轴尺寸
  mainAxisSize: MainAxisSize.max,
  children: [
    Icon(Icons.star),
    Text('评分'),
    Text('4.5'),
  ],
)
```

### Column（垂直）

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text('标题'),
    SizedBox(height: 8),
    Text('描述文本'),
    Spacer(),  // 弹性空间
    ElevatedButton(onPressed: () {}, child: Text('确定')),
  ],
)
```

### MainAxisAlignment 选项

```dart
MainAxisAlignment.start      // 起始位置
MainAxisAlignment.end        // 结束位置
MainAxisAlignment.center     // 居中
MainAxisAlignment.spaceBetween  // 两端对齐
MainAxisAlignment.spaceAround   // 等间距（两端半间距）
MainAxisAlignment.spaceEvenly   // 完全等间距
```

### CrossAxisAlignment 选项

```dart
CrossAxisAlignment.start     // 起始对齐
CrossAxisAlignment.end       // 结束对齐
CrossAxisAlignment.center    // 居中
CrossAxisAlignment.stretch   // 拉伸填满
CrossAxisAlignment.baseline  // 基线对齐
```

## 弹性布局

### Expanded

占据剩余空间。

```dart
Row(
  children: [
    Container(width: 100, color: Colors.red),
    Expanded(  // 占据剩余空间
      child: Container(color: Colors.green),
    ),
    Container(width: 100, color: Colors.blue),
  ],
)

// flex 属性控制比例
Row(
  children: [
    Expanded(flex: 1, child: Container(color: Colors.red)),
    Expanded(flex: 2, child: Container(color: Colors.green)),
    Expanded(flex: 1, child: Container(color: Colors.blue)),
  ],
)
// 红:绿:蓝 = 1:2:1
```

### Flexible

类似 Expanded，但可以不占满分配空间。

```dart
Row(
  children: [
    Flexible(
      fit: FlexFit.loose,  // 可以小于分配空间
      child: Text('短文本'),
    ),
    Flexible(
      fit: FlexFit.tight,  // 必须占满分配空间（同 Expanded）
      child: Text('长文本...'),
    ),
  ],
)
```

### Spacer

Expanded 的简写，用于创建弹性空间。

```dart
Row(
  children: [
    Text('左'),
    Spacer(),       // flex: 1
    Text('中'),
    Spacer(flex: 2), // flex: 2
    Text('右'),
  ],
)
```

## 层叠布局

### Stack

子 Widget 层叠显示。

```dart
Stack(
  alignment: Alignment.center,
  children: [
    Image.network('background.jpg'),
    Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Text('标题'),
    ),
    Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {},
      ),
    ),
  ],
)
```

### Positioned

在 Stack 中精确定位。

```dart
Positioned(
  top: 10,      // 距顶部
  left: 10,     // 距左侧
  // right: 10,  // 距右侧
  // bottom: 10, // 距底部
  width: 100,   // 宽度
  height: 50,   // 高度
  child: Container(color: Colors.red),
)

// Positioned.fill - 填满
Positioned.fill(
  child: Container(color: Colors.blue.withOpacity(0.5)),
)
```

### IndexedStack

同一时间只显示一个子 Widget。

```dart
IndexedStack(
  index: _currentIndex,
  children: [
    HomePage(),
    SearchPage(),
    ProfilePage(),
  ],
)
```

## 流式布局

### Wrap

自动换行的布局。

```dart
Wrap(
  spacing: 8,        // 水平间距
  runSpacing: 8,     // 垂直间距（行间距）
  alignment: WrapAlignment.start,
  children: [
    Chip(label: Text('Flutter')),
    Chip(label: Text('Dart')),
    Chip(label: Text('Widget')),
    Chip(label: Text('Layout')),
    Chip(label: Text('State')),
  ],
)
```

### Flow

更灵活的流式布局（需要自定义 delegate）。

```dart
Flow(
  delegate: _MyFlowDelegate(),
  children: items.map((item) => 
    Container(
      width: 50,
      height: 50,
      color: item.color,
    )
  ).toList(),
)
```

## 对齐与填充

### Align

对齐子 Widget。

```dart
Container(
  width: 200,
  height: 200,
  color: Colors.grey,
  child: Align(
    alignment: Alignment.topRight,
    child: Text('右上角'),
  ),
)

// Alignment 值
Alignment.topLeft      // (-1, -1)
Alignment.topCenter    // (0, -1)
Alignment.topRight     // (1, -1)
Alignment.centerLeft   // (-1, 0)
Alignment.center       // (0, 0)
Alignment.centerRight  // (1, 0)
Alignment.bottomLeft   // (-1, 1)
Alignment.bottomCenter // (0, 1)
Alignment.bottomRight  // (1, 1)

// 自定义位置
Alignment(0.5, -0.5)  // x=0.5, y=-0.5
```

### Center

居中对齐（Align 的简写）。

```dart
Center(
  child: Text('居中'),
)
```

### Padding

添加内边距。

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Text('有内边距'),
)

// EdgeInsets 选项
EdgeInsets.all(16)                    // 四边相同
EdgeInsets.symmetric(horizontal: 16, vertical: 8)
EdgeInsets.only(left: 8, top: 16)
EdgeInsets.fromLTRB(8, 16, 8, 16)
```

## 约束与尺寸

### IntrinsicHeight / IntrinsicWidth

让子 Widget 使用固有尺寸。

```dart
// 让所有子 Widget 高度相同（取最高的）
IntrinsicHeight(
  child: Row(
    children: [
      Container(color: Colors.red, width: 50),
      Container(color: Colors.green, width: 50, height: 100),
      Container(color: Colors.blue, width: 50),
    ],
  ),
)
```

### FittedBox

缩放子 Widget 以适应空间。

```dart
FittedBox(
  fit: BoxFit.contain,
  child: Text('这段文字会缩放'),
)

// BoxFit 选项
BoxFit.fill       // 拉伸填满（可能变形）
BoxFit.contain    // 保持比例，完整显示
BoxFit.cover      // 保持比例，裁剪填满
BoxFit.fitWidth   // 宽度填满
BoxFit.fitHeight  // 高度填满
BoxFit.none       // 不缩放
BoxFit.scaleDown  // 只缩小不放大
```

### AspectRatio

固定宽高比。

```dart
AspectRatio(
  aspectRatio: 16 / 9,
  child: Container(color: Colors.blue),
)
```

### FractionallySizedBox

按比例设置尺寸。

```dart
FractionallySizedBox(
  widthFactor: 0.8,   // 80% 宽度
  heightFactor: 0.5,  // 50% 高度
  child: Container(color: Colors.red),
)
```

## 常见布局模式

### 卡片布局

```dart
Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.network('image.jpg'),
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('标题', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('描述文本...'),
          ],
        ),
      ),
      ButtonBar(
        children: [
          TextButton(onPressed: () {}, child: Text('分享')),
          TextButton(onPressed: () {}, child: Text('了解更多')),
        ],
      ),
    ],
  ),
)
```

### 列表项布局

```dart
ListTile(
  leading: CircleAvatar(backgroundImage: NetworkImage('avatar.jpg')),
  title: Text('标题'),
  subtitle: Text('副标题'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

### 登录表单布局

```dart
Scaffold(
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
          Text('欢迎登录', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 48),
          TextField(decoration: InputDecoration(labelText: '邮箱')),
          SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: '密码'), obscureText: true),
          SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: Text('登录')),
          Spacer(flex: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('还没有账号？'),
              TextButton(onPressed: () {}, child: Text('注册')),
            ],
          ),
        ],
      ),
    ),
  ),
)
```

## 调试布局

```dart
// 显示布局边界
debugPaintSizeEnabled = true;

// 在 Widget 上添加边框查看范围
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.red),
  ),
  child: yourWidget,
)
```

## 下一步

掌握布局系统后，下一章我们将学习 [状态管理基础](./04-state)，了解如何管理应用状态。
