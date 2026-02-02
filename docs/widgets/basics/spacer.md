# Spacer

`Spacer` 是 Flutter 中用于在 Flex 布局（`Row`、`Column`、`Flex`）中创建可伸缩空白空间的组件。它本质上是一个空的 `Expanded` 组件，会占用布局中所有可用的剩余空间，帮助实现灵活的间距控制和元素对齐。

## 基本用法

```dart
// 在 Row 中使用 Spacer 将元素推向两端
Row(
  children: [
    Text('左侧'),
    Spacer(),  // 占用中间所有空间
    Text('右侧'),
  ],
)

// 使用 flex 参数控制空间比例
Row(
  children: [
    Text('A'),
    Spacer(flex: 2),  // 占用 2 份空间
    Text('B'),
    Spacer(flex: 1),  // 占用 1 份空间
    Text('C'),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `flex` | `int` | `1` | 弹性因子，决定 Spacer 占用剩余空间的比例。值越大，占用的空间越多 |

## 使用场景

### 1. 均匀分布元素

```dart
class EvenDistributionDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('均匀分布')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.home, size: 40),
            Spacer(),
            Icon(Icons.search, size: 40),
            Spacer(),
            Icon(Icons.favorite, size: 40),
            Spacer(),
            Icon(Icons.person, size: 40),
          ],
        ),
      ),
    );
  }
}
```

### 2. 左右对齐（两端对齐）

```dart
class AlignmentDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('左右对齐')),
      body: Column(
        children: [
          // 标题栏：Logo 在左，操作按钮在右
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Text(
                  'Logo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),  // 将后面的元素推到右侧
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // 列表项：标题在左，价格在右
          ListTile(
            title: Row(
              children: [
                Text('商品名称'),
                Spacer(),
                Text(
                  '¥99.00',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Text('商品描述'),
          ),
        ],
      ),
    );
  }
}
```

### 3. 灵活间距（按比例分配）

```dart
class FlexibleSpacingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('灵活间距')),
      body: Column(
        children: [
          // 使用不同 flex 值创建不等比例间距
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.blue,
                  child: Center(child: Text('1')),
                ),
                Spacer(flex: 1),  // 1 份空间
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.green,
                  child: Center(child: Text('2')),
                ),
                Spacer(flex: 2),  // 2 份空间（是前一个的两倍）
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.orange,
                  child: Center(child: Text('3')),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // 底部导航：中间按钮突出
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.home), onPressed: () {}),
                Spacer(flex: 1),
                IconButton(icon: Icon(Icons.search), onPressed: () {}),
                Spacer(flex: 2),
                FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.add),
                  onPressed: () {},
                ),
                Spacer(flex: 2),
                IconButton(icon: Icon(Icons.message), onPressed: () {}),
                Spacer(flex: 1),
                IconButton(icon: Icon(Icons.person), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. 垂直布局中的应用

```dart
class VerticalSpacerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部 Logo
              Icon(Icons.flutter_dash, size: 80, color: Colors.blue),
              
              SizedBox(height: 20),
              
              Text(
                '欢迎使用',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              
              Spacer(flex: 2),  // 上部分占更多空间
              
              // 中间的登录表单
              TextField(
                decoration: InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
              ),
              
              Spacer(flex: 1),  // 下部分空间较少
              
              // 底部按钮
              ElevatedButton(
                onPressed: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('登录', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: Text('还没有账号？立即注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Spacer 与 SizedBox 对比

| 特性 | Spacer | SizedBox |
|------|--------|----------|
| **空间类型** | 弹性空间，自动填充剩余空间 | 固定空间，指定具体尺寸 |
| **使用范围** | 只能在 Flex 容器中使用（Row/Column/Flex） | 可在任何位置使用 |
| **尺寸控制** | 通过 `flex` 属性按比例分配 | 通过 `width`/`height` 指定固定值 |
| **响应式** | 自动适应父容器大小变化 | 固定尺寸，不随父容器变化 |
| **性能** | 略优（不渲染任何内容） | 可作为空白占位或包裹子组件 |

### 对比示例

```dart
class SpacerVsSizedBoxDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spacer vs SizedBox')),
      body: Column(
        children: [
          // 使用 Spacer：自动填充剩余空间
          Container(
            color: Colors.blue.shade50,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Text('Spacer 示例'),
                Spacer(),  // 自动占用剩余空间
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // 使用 SizedBox：固定间距
          Container(
            color: Colors.green.shade50,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Text('SizedBox 示例'),
                SizedBox(width: 50),  // 固定 50 像素间距
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // 组合使用
          Container(
            color: Colors.orange.shade50,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Text('组合使用'),
                SizedBox(width: 10),  // 固定小间距
                Icon(Icons.star),
                Spacer(),  // 弹性填充
                Text('尾部'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 何时选择 Spacer

```dart
// ✅ 适合使用 Spacer 的场景
Row(
  children: [
    BackButton(),
    Spacer(),      // 将标题居中
    Title(),
    Spacer(),      // 保持标题居中
    ActionButton(),
  ],
)

// ✅ 需要按比例分配空间
Row(
  children: [
    SideMenu(),
    Spacer(flex: 1),  // 1/3 空间
    Content(),
    Spacer(flex: 2),  // 2/3 空间
  ],
)
```

### 何时选择 SizedBox

```dart
// ✅ 需要固定间距
Column(
  children: [
    Text('标题'),
    SizedBox(height: 16),  // 固定 16 像素间距
    Text('内容'),
  ],
)

// ✅ 在非 Flex 容器中使用
Padding(
  padding: EdgeInsets.all(16),
  child: SizedBox(height: 20),  // Spacer 在这里无法使用
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class SpacerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spacer 示例'),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 示例 1: 基础两端对齐
          _buildSection(
            '基础两端对齐',
            Row(
              children: [
                Text('左侧文本', style: TextStyle(fontSize: 16)),
                Spacer(),
                Text('右侧文本', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          
          // 示例 2: 三等分布局
          _buildSection(
            '三等分布局',
            Row(
              children: [
                _buildBox(Colors.red, 'A'),
                Spacer(),
                _buildBox(Colors.green, 'B'),
                Spacer(),
                _buildBox(Colors.blue, 'C'),
              ],
            ),
          ),
          
          // 示例 3: 不等比例分配
          _buildSection(
            '不等比例分配 (1:2:1)',
            Row(
              children: [
                _buildBox(Colors.purple, '1'),
                Spacer(flex: 1),
                _buildBox(Colors.orange, '2'),
                Spacer(flex: 2),
                _buildBox(Colors.teal, '3'),
                Spacer(flex: 1),
                _buildBox(Colors.pink, '4'),
              ],
            ),
          ),
          
          // 示例 4: 工具栏布局
          _buildSection(
            '工具栏布局',
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  Text(
                    '应用标题',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  IconButton(icon: Icon(Icons.search), onPressed: () {}),
                  IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                ],
              ),
            ),
          ),
          
          // 示例 5: 卡片底部操作栏
          _buildSection(
            '卡片底部操作',
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文章标题',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('这是文章的简短描述内容...'),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '2024-01-15',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Spacer(),
                        TextButton.icon(
                          icon: Icon(Icons.thumb_up_outlined, size: 18),
                          label: Text('点赞'),
                          onPressed: () {},
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.comment_outlined, size: 18),
                          label: Text('评论'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildBox(Color color, String label) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

## 最佳实践

### 1. 仅在 Flex 容器中使用

```dart
// ✅ 正确：在 Row 中使用
Row(
  children: [
    Text('左'),
    Spacer(),
    Text('右'),
  ],
)

// ❌ 错误：在 Stack 中使用（会报错）
Stack(
  children: [
    Text('内容'),
    Spacer(),  // 错误！Spacer 不能在 Stack 中使用
  ],
)
```

### 2. 避免在 Scrollable 中直接使用

```dart
// ❌ 错误：在 ListView 的直接子级中使用
ListView(
  children: [
    Text('项目1'),
    Spacer(),  // 错误！ListView 有无限高度
    Text('项目2'),
  ],
)

// ✅ 正确：在 ListView 的固定高度容器内使用
ListView(
  children: [
    Container(
      height: 100,
      child: Row(
        children: [
          Text('左'),
          Spacer(),  // 正确，在有限宽度的 Row 中
          Text('右'),
        ],
      ),
    ),
  ],
)
```

### 3. 合理使用 flex 值

```dart
// ✅ 使用简单的比例关系
Row(
  children: [
    Widget1(),
    Spacer(flex: 1),  // 1 份
    Widget2(),
    Spacer(flex: 2),  // 2 份
    Widget3(),
  ],
)

// ❌ 避免过大或复杂的 flex 值
Row(
  children: [
    Widget1(),
    Spacer(flex: 137),  // 不推荐
    Widget2(),
    Spacer(flex: 259),  // 难以理解比例关系
    Widget3(),
  ],
)
```

### 4. 与 Expanded 的区别

```dart
// Spacer 本质上等同于空的 Expanded
Spacer(flex: 1)
// 等价于
Expanded(flex: 1, child: SizedBox.shrink())

// 当需要在弹性空间中放置内容时，使用 Expanded
Row(
  children: [
    Text('标签'),
    Expanded(  // 使用 Expanded 而不是 Spacer
      child: TextField(),  // 输入框填充剩余空间
    ),
    IconButton(icon: Icon(Icons.send), onPressed: () {}),
  ],
)
```

### 5. 响应式布局技巧

```dart
// 使用 Spacer 实现自适应布局
class ResponsiveHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Logo(),
        Spacer(),  // 自动适应不同屏幕宽度
        if (MediaQuery.of(context).size.width > 600) ...[
          NavItem('首页'),
          NavItem('产品'),
          NavItem('关于'),
        ] else
          IconButton(icon: Icon(Icons.menu), onPressed: () {}),
      ],
    );
  }
}
```

## 注意事项

1. **Spacer 不渲染任何可见内容**：它只占用空间，不会显示任何东西
2. **flex 必须为正整数**：传入 0 或负数会导致断言错误
3. **多个 Spacer 按比例分配**：当有多个 Spacer 时，它们会按各自的 flex 值比例分配剩余空间
4. **无法直接设置背景色**：如需可见的弹性空间，使用 `Expanded` + `Container`

## 相关组件

- [Expanded](./expanded.md) - 弹性扩展组件，可包含子组件
- [Flexible](./flexible.md) - 灵活布局组件，提供更多控制选项
- [SizedBox](./sizedbox.md) - 固定尺寸的空白组件
- [Padding](./padding.md) - 内边距组件
- [Gap](https://pub.dev/packages/gap) - 第三方包，提供更简洁的间距语法

## 官方文档

- [Spacer API 文档](https://api.flutter.dev/flutter/widgets/Spacer-class.html)
- [Expanded API 文档](https://api.flutter.dev/flutter/widgets/Expanded-class.html)
- [Flex 布局指南](https://docs.flutter.dev/development/ui/layout)
