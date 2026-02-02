# RefreshIndicator

`RefreshIndicator` 是 Material Design 风格的下拉刷新组件，当用户下拉可滚动内容时，会显示一个圆形进度指示器，常用于列表数据的刷新操作。

## 基本用法

```dart
RefreshIndicator(
  onRefresh: () async {
    // 执行刷新操作
    await fetchData();
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ListTile(
      title: Text(items[index]),
    ),
  ),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget` | 可滚动的子组件（必须是可滚动的） |
| `onRefresh` | `RefreshCallback` | 刷新回调，必须返回 `Future` |
| `displacement` | `double` | 指示器距离顶部的位置（默认 40.0） |
| `edgeOffset` | `double` | 边缘偏移量（默认 0.0） |
| `color` | `Color?` | 进度指示器的颜色 |
| `backgroundColor` | `Color?` | 指示器背景颜色 |
| `notificationPredicate` | `ScrollNotificationPredicate` | 决定哪些滚动通知触发刷新 |
| `semanticsLabel` | `String?` | 无障碍标签 |
| `semanticsValue` | `String?` | 无障碍值 |
| `strokeWidth` | `double` | 进度指示器线条宽度（默认 2.5） |
| `triggerMode` | `RefreshIndicatorTriggerMode` | 触发模式 |

## RefreshIndicatorTriggerMode

| 值 | 说明 |
|------|------|
| `onEdge` | 只有在滚动到边缘时才能触发（默认） |
| `anywhere` | 任意位置下拉都可触发 |

## 使用场景

### 1. 基本下拉刷新

```dart
class BasicRefreshDemo extends StatefulWidget {
  @override
  State<BasicRefreshDemo> createState() => _BasicRefreshDemoState();
}

class _BasicRefreshDemoState extends State<BasicRefreshDemo> {
  List<String> _items = List.generate(20, (i) => '项目 ${i + 1}');

  Future<void> _handleRefresh() async {
    // 模拟网络请求
    await Future.delayed(Duration(seconds: 2));
    
    setState(() {
      // 添加新数据到列表顶部
      _items.insert(0, '新项目 ${DateTime.now().second}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('下拉刷新')),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(_items[index]),
            );
          },
        ),
      ),
    );
  }
}
```

### 2. 自定义样式

```dart
class CustomStyleRefresh extends StatefulWidget {
  @override
  State<CustomStyleRefresh> createState() => _CustomStyleRefreshState();
}

class _CustomStyleRefreshState extends State<CustomStyleRefresh> {
  List<String> _items = List.generate(15, (i) => '数据 ${i + 1}');

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _items = List.generate(15, (i) => '刷新后 ${i + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('自定义样式')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        // 自定义颜色
        color: Colors.white,
        backgroundColor: Colors.blue,
        // 调整位置
        displacement: 60,
        // 线条宽度
        strokeWidth: 3,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(title: Text(_items[index])),
            );
          },
        ),
      ),
    );
  }
}
```

### 3. 配合 GridView 使用

```dart
class RefreshGridView extends StatefulWidget {
  @override
  State<RefreshGridView> createState() => _RefreshGridViewState();
}

class _RefreshGridViewState extends State<RefreshGridView> {
  List<Color> _colors = List.generate(
    12,
    (i) => Colors.primaries[i % Colors.primaries.length],
  );

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _colors.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('网格刷新')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _colors.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: _colors[index],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

### 4. 配合 CustomScrollView 使用

```dart
class RefreshCustomScrollView extends StatefulWidget {
  @override
  State<RefreshCustomScrollView> createState() => _RefreshCustomScrollViewState();
}

class _RefreshCustomScrollViewState extends State<RefreshCustomScrollView> {
  List<String> _news = List.generate(10, (i) => '新闻 ${i + 1}');
  bool _isLoading = false;

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _news = List.generate(10, (i) => '最新新闻 ${i + 1}');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        edgeOffset: 100, // SliverAppBar 高度
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('新闻列表'),
                background: Image.network(
                  'https://picsum.photos/400/200',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  leading: Icon(Icons.article),
                  title: Text(_news[index]),
                  subtitle: Text('发布于 ${DateTime.now().toString().substring(0, 16)}'),
                ),
                childCount: _news.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5. 空列表状态处理

```dart
class EmptyListRefresh extends StatefulWidget {
  @override
  State<EmptyListRefresh> createState() => _EmptyListRefreshState();
}

class _EmptyListRefreshState extends State<EmptyListRefresh> {
  List<String> _items = [];

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _items = List.generate(10, (i) => '加载的数据 ${i + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('空列表刷新')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _items.isEmpty
            ? ListView(
                // 空列表时需要用 ListView 包裹以支持滚动
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无数据'),
                        SizedBox(height: 8),
                        Text(
                          '下拉刷新加载数据',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_items[index]),
                ),
              ),
      ),
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class RefreshIndicatorDemo extends StatefulWidget {
  @override
  State<RefreshIndicatorDemo> createState() => _RefreshIndicatorDemoState();
}

class _RefreshIndicatorDemoState extends State<RefreshIndicatorDemo> {
  List<Map<String, dynamic>> _messages = [];
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _messages = _generateMessages();
      _isFirstLoad = false;
    });
  }

  List<Map<String, dynamic>> _generateMessages() {
    return List.generate(15, (index) {
      return {
        'id': DateTime.now().millisecondsSinceEpoch + index,
        'sender': '用户 ${index + 1}',
        'message': '这是一条消息内容 ${index + 1}',
        'time': DateTime.now().subtract(Duration(minutes: index * 5)),
        'avatar': Colors.primaries[index % Colors.primaries.length],
      };
    });
  }

  Future<void> _handleRefresh() async {
    // 模拟网络延迟
    await Future.delayed(Duration(seconds: 2));
    
    setState(() {
      // 在列表顶部插入新消息
      _messages.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender': '新用户',
        'message': '新消息 - ${DateTime.now().second}',
        'time': DateTime.now(),
        'avatar': Colors.primaries[DateTime.now().second % Colors.primaries.length],
      });
    });

    // 显示刷新成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('刷新成功，加载了 1 条新消息'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('消息列表'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: _isFirstLoad
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              displacement: 50,
              strokeWidth: 2.5,
              child: _messages.isEmpty
                  ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.message_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                '暂无消息',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '下拉刷新获取新消息',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: _messages.length,
                      separatorBuilder: (_, __) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: msg['avatar'],
                            child: Text(
                              msg['sender'][0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(msg['sender']),
                          subtitle: Text(
                            msg['message'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            _formatTime(msg['time']),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('点击了 ${msg['sender']}')),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${time.month}/${time.day}';
  }
}
```

## 最佳实践

### 1. 必须返回 Future

```dart
// ✅ 正确：返回 Future
RefreshIndicator(
  onRefresh: () async {
    await fetchData();
  },
  child: ListView(...),
)

// ❌ 错误：没有 async/await
RefreshIndicator(
  onRefresh: () {
    fetchData(); // 不会等待完成
  },
  child: ListView(...),
)
```

### 2. 空列表需要可滚动

```dart
// ✅ 正确：空列表时仍可滚动
RefreshIndicator(
  onRefresh: _refresh,
  child: ListView(
    physics: AlwaysScrollableScrollPhysics(), // 关键！
    children: [
      Center(child: Text('暂无数据')),
    ],
  ),
)

// ❌ 错误：空 Container 无法滚动
RefreshIndicator(
  onRefresh: _refresh,
  child: Container(
    child: Center(child: Text('暂无数据')),
  ),
)
```

### 3. 配合 SliverAppBar 使用时设置 edgeOffset

```dart
RefreshIndicator(
  onRefresh: _refresh,
  edgeOffset: 120, // SliverAppBar 的高度
  child: CustomScrollView(
    slivers: [
      SliverAppBar(expandedHeight: 120, ...),
      SliverList(...),
    ],
  ),
)
```

### 4. 避免重复刷新

```dart
bool _isRefreshing = false;

Future<void> _handleRefresh() async {
  if (_isRefreshing) return; // 防止重复触发
  
  _isRefreshing = true;
  try {
    await fetchData();
  } finally {
    _isRefreshing = false;
  }
}
```

### 5. 错误处理

```dart
Future<void> _handleRefresh() async {
  try {
    await fetchData();
    _showSuccess('刷新成功');
  } catch (e) {
    _showError('刷新失败，请重试');
  }
}
```

## 与 CupertinoSliverRefreshControl 对比

| 特性 | RefreshIndicator | CupertinoSliverRefreshControl |
|------|------------------|-------------------------------|
| 风格 | Material Design | iOS 风格 |
| 使用方式 | 包裹可滚动组件 | 作为 Sliver 使用 |
| 指示器 | 圆形进度条 | 下拉箭头 + 菊花 |
| 适用场景 | 大多数 Material 应用 | iOS 风格应用 |

## 相关组件

- [ListView](./listview.md) - 列表视图
- [CustomScrollView](./customscrollview.md) - 自定义滚动视图
- [CupertinoSliverRefreshControl](../cupertino/cupertinosliverrefreshcontrol.md) - iOS 风格下拉刷新

## 官方文档

- [RefreshIndicator API](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html)
