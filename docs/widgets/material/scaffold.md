# Scaffold

`Scaffold` 是 Material Design 应用的视觉脚手架，提供了应用页面的基本布局结构，包括 AppBar、Drawer、BottomNavigationBar、FloatingActionButton 等常见组件的插槽。

## 基本用法

```dart
Scaffold(
  appBar: AppBar(title: Text('页面标题')),
  body: Center(child: Text('页面内容')),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `appBar` | `PreferredSizeWidget?` | 顶部应用栏 |
| `body` | `Widget?` | 主体内容区域 |
| `floatingActionButton` | `Widget?` | 浮动操作按钮 |
| `floatingActionButtonLocation` | `FloatingActionButtonLocation?` | FAB 位置 |
| `drawer` | `Widget?` | 左侧抽屉菜单 |
| `endDrawer` | `Widget?` | 右侧抽屉菜单 |
| `bottomNavigationBar` | `Widget?` | 底部导航栏 |
| `bottomSheet` | `Widget?` | 持久性底部面板 |
| `backgroundColor` | `Color?` | 背景颜色 |
| `resizeToAvoidBottomInset` | `bool?` | 键盘弹出时是否调整布局 |
| `extendBody` | `bool` | body 是否延伸到底部导航后面 |
| `extendBodyBehindAppBar` | `bool` | body 是否延伸到 AppBar 后面 |

## 使用场景

### 1. 标准页面布局

```dart
class StandardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('标准页面'),
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
      ),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('$index')),
            title: Text('列表项 $index'),
            subtitle: Text('这是列表项的描述'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 2. 带抽屉导航的页面

```dart
class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('带抽屉的页面')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text('用户名',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('user@email.com',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('首页'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('设置'),
              onTap: () => Navigator.pop(context),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('退出登录'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Center(child: Text('主内容区域')),
    );
  }
}
```

### 3. 带底部导航的页面

```dart
class BottomNavPage extends StatefulWidget {
  @override
  State&lt;BottomNavPage&gt; createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State&lt;BottomNavPage&gt; {
  int _selectedIndex = 0;
  
  final List&lt;Widget&gt; _pages = [
    Center(child: Text('首页')),
    Center(child: Text('搜索')),
    Center(child: Text('消息')),
    Center(child: Text('我的')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('底部导航示例')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: '消息',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
```

### 4. 透明 AppBar 效果

```dart
class TransparentAppBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('透明 AppBar'),
      ),
      body: Stack(
        children: [
          // 背景图
          Image.network(
            'https://picsum.photos/800/600',
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
          ),
          // 内容
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('页面内容...'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5. 使用 ScaffoldMessenger 显示 SnackBar

```dart
// 显示 SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('操作成功'),
    action: SnackBarAction(
      label: '撤销',
      onPressed: () {
        // 撤销操作
      },
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
```

## 最佳实践

1. **键盘适配**: 使用 `resizeToAvoidBottomInset: true` 确保键盘弹出时内容可见
2. **SafeArea**: body 内容应考虑使用 SafeArea 处理刘海屏
3. **FAB 位置**: 根据场景选择合适的 `floatingActionButtonLocation`
4. **抽屉控制**: 使用 `ScaffoldState.openDrawer()` 和 `closeDrawer()` 控制抽屉
5. **背景延伸**: 使用 `extendBody` 和 `extendBodyBehindAppBar` 创建沉浸式效果

## 相关组件

- [AppBar](./appbar) - 顶部应用栏
- [Drawer](./drawer) - 侧边抽屉
- [NavigationBar](./navigationbar) - Material 3 底部导航
- [BottomNavigationBar](./bottomnavigationbar) - 底部导航栏
- [FloatingActionButton](./floatingactionbutton) - 浮动操作按钮
- [BottomSheet](./bottomsheet) - 底部面板

## 官方文档

- [Scaffold API](https://api.flutter.dev/flutter/material/Scaffold-class.html)
- [Material Design Scaffold](https://m3.material.io/foundations/layout/applying-layout)
