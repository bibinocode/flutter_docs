# Column

`Column` 是 Flutter 中用于**垂直排列**子组件的布局组件。它将子组件从上到下依次排列，是最常用的 Flex 布局之一。

## 基本用法

```dart
Column(
  children: [
    Text('第一行'),
    Text('第二行'),
    Text('第三行'),
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| mainAxisAlignment | MainAxisAlignment | start | 主轴（垂直）对齐方式 |
| mainAxisSize | MainAxisSize | max | 主轴尺寸，max 占满可用空间，min 仅包裹内容 |
| crossAxisAlignment | CrossAxisAlignment | center | 交叉轴（水平）对齐方式 |
| textDirection | TextDirection? | null | 文本方向，影响 crossAxisAlignment 的 start/end |
| verticalDirection | VerticalDirection | down | 子组件排列方向，down 从上到下，up 从下到上 |
| textBaseline | TextBaseline? | null | 文本基线对齐方式，crossAxisAlignment 为 baseline 时必须设置 |
| children | List\<Widget\> | - | 子组件列表 |

## MainAxisAlignment 主轴对齐

| 值 | 说明 |
|----|------|
| `start` | 顶部对齐（默认） |
| `end` | 底部对齐 |
| `center` | 垂直居中 |
| `spaceBetween` | 两端对齐，子组件间等距 |
| `spaceAround` | 每个子组件上下等距 |
| `spaceEvenly` | 所有间距完全相等 |

## CrossAxisAlignment 交叉轴对齐

| 值 | 说明 |
|----|------|
| `start` | 左对齐 |
| `end` | 右对齐 |
| `center` | 水平居中（默认） |
| `stretch` | 拉伸填满宽度 |
| `baseline` | 文本基线对齐 |

## 使用场景

### 1. 主轴对齐方式

```dart
Container(
  height: 300,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Container(width: 100, height: 50, color: Colors.red),
      Container(width: 100, height: 50, color: Colors.green),
      Container(width: 100, height: 50, color: Colors.blue),
    ],
  ),
)

// spaceBetween - 常用于页面顶部内容和底部按钮分离
Column(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('页面内容'),
    ElevatedButton(onPressed: () {}, child: Text('底部按钮')),
  ],
)
```

### 2. 交叉轴对齐

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
  children: [
    Text('标题', style: TextStyle(fontSize: 24)),
    Text('副标题', style: TextStyle(color: Colors.grey)),
    Text('这是一段描述文字'),
  ],
)

// stretch - 拉伸填满宽度
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Container(height: 50, color: Colors.red),  // 宽度自动填满
    Container(height: 50, color: Colors.green),
    Container(height: 50, color: Colors.blue),
  ],
)
```

### 3. 使用 Expanded/Flexible 分配空间

```dart
Column(
  children: [
    // 固定高度的头部
    Container(
      height: 60,
      color: Colors.blue,
      child: Center(child: Text('Header')),
    ),
    
    // 可滚动的主内容区域
    Expanded(
      child: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
      ),
    ),
    
    // 固定高度的底部
    Container(
      height: 60,
      color: Colors.grey,
      child: Center(child: Text('Footer')),
    ),
  ],
)

// 按比例分配高度
Column(
  children: [
    Expanded(
      flex: 2,
      child: Container(color: Colors.red),
    ),
    Expanded(
      flex: 1,
      child: Container(color: Colors.green),
    ),
  ],
)
```

### 4. 表单布局

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('登录', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      SizedBox(height: 24),
      
      TextField(
        decoration: InputDecoration(
          labelText: '用户名',
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
      SizedBox(height: 24),
      
      ElevatedButton(
        onPressed: () {},
        child: Text('登录'),
      ),
      
      TextButton(
        onPressed: () {},
        child: Text('忘记密码？'),
      ),
    ],
  ),
)
```

### 5. 卡片内容布局

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 高度包裹内容
      children: [
        Row(
          children: [
            CircleAvatar(child: Icon(Icons.person)),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('用户名', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('2小时前', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        Text('这是一条动态内容，展示了 Column 在卡片布局中的应用。'),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.thumb_up_outlined),
              label: Text('赞'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.comment_outlined),
              label: Text('评论'),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

### 6. 列表项布局

```dart
ListTile(
  leading: CircleAvatar(backgroundImage: NetworkImage('...')),
  title: Text('联系人名称'),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('最后消息内容'),
      Text('10:30', style: TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  ),
  isThreeLine: true,
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class ColumnDemo extends StatelessWidget {
  const ColumnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人信息卡片')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 个人信息卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 头像
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://picsum.photos/200'),
                    ),
                    const SizedBox(height: 16),
                    
                    // 姓名
                    const Text(
                      '张三',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // 职位
                    Text(
                      'Flutter 开发工程师',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 简介
                    const Text(
                      '热爱编程，专注于移动端开发，擅长 Flutter 和原生开发。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    
                    // 统计信息
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('关注', '128'),
                        _buildStatItem('粉丝', '1.2k'),
                        _buildStatItem('获赞', '3.5k'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('关注'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('私信'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 详细信息卡片
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '详细信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildInfoRow(Icons.email, '邮箱', 'zhangsan@example.com'),
                  _buildInfoRow(Icons.phone, '电话', '138****8888'),
                  _buildInfoRow(Icons.location_on, '地址', '北京市朝阳区'),
                  _buildInfoRow(Icons.work, '公司', 'ABC 科技有限公司'),
                  _buildInfoRow(Icons.calendar_today, '加入时间', '2023年6月'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
```

## 处理溢出

```dart
// 在可滚动容器中使用
SingleChildScrollView(
  child: Column(
    children: List.generate(
      20,
      (index) => ListTile(title: Text('Item $index')),
    ),
  ),
)

// 使用 Expanded 内嵌 ListView
Column(
  children: [
    Text('标题'),
    Expanded(
      child: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) => Text('Item $index'),
      ),
    ),
  ],
)
```

## MainAxisSize 对比

```dart
// max - 占满高度
Container(
  color: Colors.grey[200],
  child: Column(
    mainAxisSize: MainAxisSize.max, // 默认
    mainAxisAlignment: MainAxisAlignment.center,
    children: [Text('居中显示')],
  ),
)

// min - 仅包裹内容（常用于 Dialog、卡片）
AlertDialog(
  title: Text('提示'),
  content: Column(
    mainAxisSize: MainAxisSize.min, // 避免 Dialog 撑满高度
    children: [
      Text('内容1'),
      Text('内容2'),
    ],
  ),
)
```

## Column 在不同容器中的行为

| 容器 | Column 默认高度 | 注意事项 |
|------|-----------------|----------|
| `Scaffold.body` | 填满屏幕 | 正常使用 |
| `ListView` | 包裹内容 | 使用 `shrinkWrap: true` |
| `AlertDialog` | 尽可能大 | 使用 `mainAxisSize: min` |
| `SingleChildScrollView` | 包裹内容 | 正常使用 |
| 嵌套 `Column` | 包裹内容 | 内层用 `Expanded` 需外层有约束 |

## 最佳实践

### 1. 在 ListView 中正确使用 Column

```dart
// ✅ 正确：Column 作为 ListView 的子项时设置 mainAxisSize.min
ListView(
  children: [
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('标题'),
        Text('内容'),
      ],
    ),
  ],
)

// ❌ 错误：ListView 中嵌套未约束的 Column 会导致问题
ListView(
  children: [
    Column(
      mainAxisSize: MainAxisSize.max, // 这会导致布局问题
      children: [...],
    ),
  ],
)
```

### 2. 处理溢出问题

```dart
// ✅ 方案一：使用 SingleChildScrollView 包裹
SingleChildScrollView(
  child: Column(
    children: [
      // 内容可能超出屏幕
    ],
  ),
)

// ✅ 方案二：使用 Expanded 分配剩余空间给可滚动组件
Column(
  children: [
    Text('固定内容'),
    Expanded(
      child: ListView(
        children: [/* 可滚动内容 */],
      ),
    ),
  ],
)

// ✅ 方案三：设置 mainAxisSize 为 min
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    // 仅占用所需空间
  ],
)
```

### 3. 其他最佳实践

1. **避免无限高度**: 在 ListView 等可滚动组件中使用 Column 时注意约束
2. **使用 mainAxisSize.min**: 在 Dialog、BottomSheet 等弹出组件中使用
3. **合理使用 Expanded**: 需要可滚动区域时用 Expanded 包裹 ListView
4. **控制间距**: 使用 `SizedBox` 代替空 Container 设置间距
5. **交叉轴对齐**: 表单、列表使用 `CrossAxisAlignment.start` 左对齐
6. **const 优化**: 静态布局使用 const 提升性能

## 常见问题

::: warning 无限高度错误
Column 在某些容器中会尝试获取无限高度，导致报错：
```
Vertical viewport was given unbounded height.
```
解决方法：
1. 给 Column 设置固定高度的父容器
2. 使用 `mainAxisSize: MainAxisSize.min`
3. 使用 Expanded 包裹 ListView 等可滚动组件
:::

## 相关组件

- [Row](./row.md) - 水平布局组件
- [Flex](./flex.md) - 通用弹性布局（Column 和 Row 的基类）
- [ListView](../scrolling/listview.md) - 可滚动的列表组件
- [Expanded](../basics/expanded.md) - 扩展子组件填满剩余空间
- [Flexible](../basics/flexible.md) - 弹性子组件
- [Spacer](../basics/spacer.md) - 占据剩余空间的间隔组件

## 官方文档

- [Column API](https://api.flutter-io.cn/flutter/widgets/Column-class.html)
- [MainAxisAlignment](https://api.flutter-io.cn/flutter/rendering/MainAxisAlignment.html)
- [CrossAxisAlignment](https://api.flutter-io.cn/flutter/rendering/CrossAxisAlignment.html)
