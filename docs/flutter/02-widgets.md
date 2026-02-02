# Widget 基础

在 Flutter 中，一切皆为 Widget。本章介绍 Widget 的概念和核心知识。

## 什么是 Widget？

Widget 是 Flutter 应用的基本构建块，描述了 UI 的一部分在给定配置和状态下应该如何显示。

```dart
// 一个简单的 Widget
class HelloWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello, Flutter!');
  }
}
```

## Widget 的特点

### 1. 不可变性

Widget 是不可变的（immutable）。一旦创建，其属性就不能改变。

```dart
// ❌ 错误：不能修改 Widget 的属性
final text = Text('Hello');
text.data = 'World';  // 编译错误

// ✅ 正确：创建新的 Widget
final newText = Text('World');
```

### 2. 声明式 UI

描述 UI 应该是什么样子，而不是如何构建它。

```dart
// 声明式
Widget build(BuildContext context) {
  return Container(
    color: isActive ? Colors.blue : Colors.grey,
    child: Text(isActive ? '激活' : '未激活'),
  );
}

// vs 命令式（其他框架）
// button.setColor(isActive ? blue : grey);
// button.setText(isActive ? '激活' : '未激活');
```

### 3. 组合优于继承

通过组合小 Widget 构建复杂 UI。

```dart
class ProfileCard extends StatelessWidget {
  final String name;
  final String avatar;
  
  const ProfileCard({required this.name, required this.avatar});
  
  @override
  Widget build(BuildContext context) {
    return Card(                    // 组合 Card
      child: Row(                   // 组合 Row
        children: [
          CircleAvatar(             // 组合 CircleAvatar
            backgroundImage: NetworkImage(avatar),
          ),
          SizedBox(width: 16),
          Text(name),               // 组合 Text
        ],
      ),
    );
  }
}
```

## StatelessWidget vs StatefulWidget

### StatelessWidget

不维护任何状态，build 方法只依赖于构造函数参数。

```dart
class Greeting extends StatelessWidget {
  final String name;
  
  const Greeting({required this.name, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}

// 使用
Greeting(name: 'Flutter');
```

**适用场景：**
- 静态内容显示
- 只依赖父 Widget 传入数据
- 不需要动态更新

### StatefulWidget

维护可变状态，状态改变时会重新 build。

```dart
class Counter extends StatefulWidget {
  const Counter({super.key});
  
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  
  void _increment() {
    setState(() {
      _count++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: Text('增加'),
        ),
      ],
    );
  }
}
```

**适用场景：**
- 需要响应用户交互
- 有内部可变状态
- 需要动态更新 UI

## Widget 生命周期

### StatelessWidget 生命周期

```dart
class MyStateless extends StatelessWidget {
  MyStateless() {
    print('1. 构造函数');
  }
  
  @override
  Widget build(BuildContext context) {
    print('2. build');
    return Container();
  }
}
```

### StatefulWidget 生命周期

```dart
class MyStateful extends StatefulWidget {
  MyStateful() {
    print('1. Widget 构造函数');
  }
  
  @override
  State<MyStateful> createState() {
    print('2. createState');
    return _MyStatefulState();
  }
}

class _MyStatefulState extends State<MyStateful> {
  _MyStatefulState() {
    print('3. State 构造函数');
  }
  
  @override
  void initState() {
    super.initState();
    print('4. initState - 初始化状态');
    // 订阅、初始化控制器等
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('5. didChangeDependencies - 依赖变化');
    // InheritedWidget 变化时调用
  }
  
  @override
  Widget build(BuildContext context) {
    print('6. build - 构建 UI');
    return Container();
  }
  
  @override
  void didUpdateWidget(MyStateful oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('7. didUpdateWidget - Widget 更新');
    // 父 Widget 重建时调用
  }
  
  @override
  void deactivate() {
    super.deactivate();
    print('8. deactivate - 从树中移除（可能重新插入）');
  }
  
  @override
  void dispose() {
    print('9. dispose - 永久移除，清理资源');
    // 取消订阅、释放控制器等
    super.dispose();
  }
}
```

## BuildContext

BuildContext 是 Widget 在 Widget 树中的位置标识。

```dart
Widget build(BuildContext context) {
  // 获取主题
  var theme = Theme.of(context);
  
  // 获取屏幕尺寸
  var size = MediaQuery.of(context).size;
  
  // 导航
  Navigator.of(context).push(...);
  
  // 显示 SnackBar
  ScaffoldMessenger.of(context).showSnackBar(...);
  
  return Container();
}
```

### 常见错误

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // ❌ 错误：initState 中不能使用某些 context 方法
    // var size = MediaQuery.of(context).size;
    
    // ✅ 正确：使用 addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var size = MediaQuery.of(context).size;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## Key 的作用

Key 帮助 Flutter 识别 Widget，在列表和动画中尤为重要。

### 问题场景

```dart
// 没有 Key 时，移除第一项会导致状态错乱
List<Widget> items = [
  CounterTile(color: Colors.red),    // 状态: count = 5
  CounterTile(color: Colors.blue),   // 状态: count = 3
  CounterTile(color: Colors.green),  // 状态: count = 1
];

// 移除红色项后
// Flutter 认为蓝色项变成了红色项（基于位置）
// 状态会错乱！
```

### 解决方案

```dart
// 使用 Key
List<Widget> items = [
  CounterTile(key: ValueKey('red'), color: Colors.red),
  CounterTile(key: ValueKey('blue'), color: Colors.blue),
  CounterTile(key: ValueKey('green'), color: Colors.green),
];
```

### Key 类型

```dart
// ValueKey - 基于值
ValueKey('unique_id')
ValueKey(item.id)

// ObjectKey - 基于对象引用
ObjectKey(myObject)

// UniqueKey - 每次都是新的（谨慎使用）
UniqueKey()

// GlobalKey - 全局唯一，可跨 Widget 访问状态
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: ...,
)

// 验证表单
_formKey.currentState?.validate();
```

## 常用基础 Widget

### 文本显示

```dart
Text(
  'Hello, Flutter!',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// 富文本
RichText(
  text: TextSpan(
    text: 'Hello ',
    style: DefaultTextStyle.of(context).style,
    children: [
      TextSpan(
        text: 'bold',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: ' world!'),
    ],
  ),
)
```

### 图片显示

```dart
// 网络图片
Image.network(
  'https://example.com/image.png',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator();
  },
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error);
  },
)

// 本地资源
Image.asset('assets/images/logo.png')

// 文件图片
Image.file(File('/path/to/image.png'))
```

### 按钮

```dart
// Material 3 按钮
ElevatedButton(onPressed: () {}, child: Text('Elevated'))
FilledButton(onPressed: () {}, child: Text('Filled'))
OutlinedButton(onPressed: () {}, child: Text('Outlined'))
TextButton(onPressed: () {}, child: Text('Text'))

// 图标按钮
IconButton(onPressed: () {}, icon: Icon(Icons.add))

// FAB
FloatingActionButton(onPressed: () {}, child: Icon(Icons.add))
```

## 实践练习

```dart
// 创建一个可切换的用户卡片
class UserCard extends StatefulWidget {
  final String name;
  final String email;
  
  const UserCard({required this.name, required this.email, super.key});
  
  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(widget.name[0])),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              if (_isExpanded) ...[
                SizedBox(height: 16),
                Text('邮箱: ${widget.email}'),
                SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: Text('编辑')),
                    TextButton(onPressed: () {}, child: Text('删除')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

## 下一步

掌握 Widget 基础后，下一章我们将学习 [布局系统](./03-layout)，了解如何排列组合 Widget。
