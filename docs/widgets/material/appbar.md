# AppBar

`AppBar` 是 Material Design 应用栏组件，显示在页面顶部，包含页面标题、导航图标和操作按钮等。它是构建 Flutter 应用界面最常用的组件之一。

## 基本用法

```dart
Scaffold(
  appBar: AppBar(
    title: Text('页面标题'),
  ),
  body: Center(child: Text('页面内容')),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| leading | Widget? | null | 左侧组件，通常是返回按钮或菜单图标 |
| automaticallyImplyLeading | bool | true | 是否自动添加 leading |
| title | Widget? | null | 标题组件 |
| centerTitle | bool? | 平台相关 | 标题是否居中 |
| actions | List\<Widget\>? | null | 右侧操作按钮列表 |
| bottom | PreferredSizeWidget? | null | 底部组件，通常是 TabBar |
| elevation | double? | 4.0 | 阴影高度 |
| backgroundColor | Color? | 主题色 | 背景颜色 |
| foregroundColor | Color? | null | 前景色（图标和文字） |
| iconTheme | IconThemeData? | null | 图标主题 |
| toolbarHeight | double? | kToolbarHeight | 工具栏高度 |
| flexibleSpace | Widget? | null | 灵活空间，配合 SliverAppBar 使用 |

## 使用场景

### 1. 基础应用栏

```dart
AppBar(
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {},
  ),
  title: Text('首页'),
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)
```

### 2. 带返回按钮

```dart
AppBar(
  leading: BackButton(),  // 或 IconButton
  title: Text('详情页'),
)
```

### 3. 搜索栏

```dart
class SearchAppBar extends StatefulWidget {
  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜索...',
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
            )
          : Text('应用标题'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            });
          },
        ),
      ],
    );
  }
}
```

### 4. 带 TabBar

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('带 Tab 的应用栏'),
      bottom: TabBar(
        tabs: [
          Tab(text: '推荐', icon: Icon(Icons.home)),
          Tab(text: '热门', icon: Icon(Icons.whatshot)),
          Tab(text: '我的', icon: Icon(Icons.person)),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Center(child: Text('推荐内容')),
        Center(child: Text('热门内容')),
        Center(child: Text('我的内容')),
      ],
    ),
  ),
)
```

### 5. 透明/渐变背景

```dart
AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  title: Text('渐变背景'),
)
```

### 6. 自定义高度

```dart
AppBar(
  toolbarHeight: 80,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('主标题', style: TextStyle(fontSize: 20)),
      Text('副标题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
    ],
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class AppBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text('AppBar 示例'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            tooltip: '通知',
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(value: 'settings', child: Text('设置')),
              PopupMenuItem(value: 'about', child: Text('关于')),
              PopupMenuItem(value: 'logout', child: Text('退出登录')),
            ],
          ),
        ],
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(
          title: Text('列表项 $index'),
        ),
      ),
    );
  }
}
```

## SliverAppBar（滚动效果）

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('折叠标题'),
        background: Image.network(
          'https://picsum.photos/400/200',
          fit: BoxFit.cover,
        ),
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('Item $index')),
        childCount: 50,
      ),
    ),
  ],
)
```

## Material 3 样式

```dart
// 启用 Material 3
MaterialApp(
  theme: ThemeData(useMaterial3: true),
  // ...
)

// Material 3 AppBar 自动应用新样式
AppBar(
  title: Text('Material 3 AppBar'),
  // 默认无阴影，滚动时显示
  scrolledUnderElevation: 4,
)
```

## 最佳实践

1. **保持简洁**：actions 不超过 3 个，更多放入菜单
2. **统一风格**：整个应用的 AppBar 保持一致
3. **响应式标题**：长标题使用 Text 的 overflow 属性
4. **可访问性**：为图标按钮添加 tooltip
5. **主题适配**：使用 Theme 统一管理颜色

## 相关组件

- [Scaffold](./scaffold.md) - AppBar 的容器
- [TabBar](./tabbar.md) - 选项卡栏
- [SliverAppBar](https://api.flutter-io.cn/flutter/material/SliverAppBar-class.html) - 可折叠应用栏
- [NavigationBar](./navigationbar.md) - 底部导航栏

## 官方文档

- [AppBar API](https://api.flutter-io.cn/flutter/material/AppBar-class.html)
- [SliverAppBar API](https://api.flutter-io.cn/flutter/material/SliverAppBar-class.html)
