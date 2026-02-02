# Drawer

`Drawer` 是 Material Design 抽屉菜单组件，从屏幕边缘滑出的面板，通常用于显示应用的导航链接。它是实现侧边栏导航的标准方式。

## 基本用法

```dart
Scaffold(
  appBar: AppBar(title: Text('抽屉菜单示例')),
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('菜单头部', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('首页'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('设置'),
          onTap: () {},
        ),
      ],
    ),
  ),
  body: Center(child: Text('页面内容')),
)
```

## Drawer 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| backgroundColor | Color? | null | 抽屉背景颜色 |
| elevation | double? | 16.0 | 阴影高度 |
| shadowColor | Color? | null | 阴影颜色 |
| surfaceTintColor | Color? | null | 表面着色颜色（Material 3） |
| shape | ShapeBorder? | null | 抽屉形状 |
| width | double? | 304.0 | 抽屉宽度 |
| child | Widget? | null | 抽屉内容 |
| semanticLabel | String? | null | 无障碍标签 |
| clipBehavior | Clip | Clip.hardEdge | 裁剪行为 |

## DrawerHeader 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| decoration | Decoration? | null | 头部装饰（背景色、图片等） |
| padding | EdgeInsetsGeometry | EdgeInsets.fromLTRB(16, 16, 16, 8) | 内边距 |
| margin | EdgeInsetsGeometry | EdgeInsets.zero | 外边距 |
| duration | Duration | 250ms | 动画持续时间 |
| curve | Curve | Curves.fastOutSlowIn | 动画曲线 |
| child | Widget? | null | 头部内容 |

## UserAccountsDrawerHeader 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| accountName | Widget? | null | 账户名称 |
| accountEmail | Widget? | null | 账户邮箱 |
| currentAccountPicture | Widget? | null | 当前账户头像 |
| otherAccountsPictures | List\<Widget\>? | null | 其他账户头像列表 |
| onDetailsPressed | VoidCallback? | null | 点击详情按钮回调 |
| decoration | Decoration? | null | 头部装饰 |

## 使用场景

### 1. 基本抽屉

```dart
Scaffold(
  drawer: Drawer(
    backgroundColor: Colors.white,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
    ),
    child: SafeArea(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text('首页'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('收藏'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('设置'),
            onTap: () {},
          ),
        ],
      ),
    ),
  ),
)
```

### 2. 用户头部

```dart
Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      UserAccountsDrawerHeader(
        accountName: Text('张三'),
        accountEmail: Text('zhangsan@example.com'),
        currentAccountPicture: CircleAvatar(
          backgroundImage: NetworkImage('https://picsum.photos/200'),
        ),
        otherAccountsPictures: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://picsum.photos/201'),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage('https://picsum.photos/202'),
          ),
        ],
        onDetailsPressed: () {
          // 显示账户切换列表
        },
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('个人资料'),
        onTap: () {},
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('退出登录'),
        onTap: () {},
      ),
    ],
  ),
)
```

### 3. 导航列表

```dart
class NavigationDrawer extends StatefulWidget {
  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'title': '仪表盘'},
    {'icon': Icons.inbox, 'title': '收件箱'},
    {'icon': Icons.send, 'title': '已发送'},
    {'icon': Icons.drafts, 'title': '草稿箱'},
    {'icon': Icons.delete, 'title': '垃圾箱'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Row(
              children: [
                Icon(Icons.mail, size: 48, color: Colors.white),
                SizedBox(width: 16),
                Text('邮件应用', style: TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                return ListTile(
                  leading: Icon(
                    item['icon'],
                    color: isSelected ? Colors.indigo : null,
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      color: isSelected ? Colors.indigo : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Colors.indigo.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. endDrawer（右侧抽屉）

```dart
Scaffold(
  appBar: AppBar(
    title: Text('双侧抽屉'),
    leading: Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
    actions: [
      Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    ],
  ),
  drawer: Drawer(
    child: Center(child: Text('左侧导航菜单')),
  ),
  endDrawer: Drawer(
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('筛选条件', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Divider(),
          CheckboxListTile(
            title: Text('显示已完成'),
            value: true,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            title: Text('显示待处理'),
            value: false,
            onChanged: (value) {},
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('排序方式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          RadioListTile(
            title: Text('按时间'),
            value: 'time',
            groupValue: 'time',
            onChanged: (value) {},
          ),
          RadioListTile(
            title: Text('按名称'),
            value: 'name',
            groupValue: 'time',
            onChanged: (value) {},
          ),
        ],
      ),
    ),
  ),
  body: Center(child: Text('页面内容')),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class DrawerDemo extends StatefulWidget {
  @override
  State<DrawerDemo> createState() => _DrawerDemoState();
}

class _DrawerDemoState extends State<DrawerDemo> {
  int _selectedIndex = 0;
  String _currentPage = '首页';

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'title': '首页', 'badge': null},
    {'icon': Icons.explore, 'title': '发现', 'badge': 'NEW'},
    {'icon': Icons.notifications, 'title': '通知', 'badge': '3'},
    {'icon': Icons.bookmark, 'title': '收藏', 'badge': null},
    {'icon': Icons.history, 'title': '历史', 'badge': null},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentPage = _navItems[index]['title'];
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage),
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // 用户账户头部
            UserAccountsDrawerHeader(
              accountName: Text(
                '张三',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text('zhangsan@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '张',
                  style: TextStyle(fontSize: 32, color: Colors.blue),
                ),
              ),
              otherAccountsPictures: [
                CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: Text('李'),
                ),
              ],
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              onDetailsPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: CircleAvatar(child: Text('张')),
                          title: Text('张三'),
                          subtitle: Text('zhangsan@example.com'),
                          trailing: Icon(Icons.check, color: Colors.blue),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Text('李')),
                          title: Text('李四'),
                          subtitle: Text('lisi@example.com'),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.add),
                          title: Text('添加账户'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.manage_accounts),
                          title: Text('管理账户'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // 导航列表
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _navItems.length,
                itemBuilder: (context, index) {
                  final item = _navItems[index];
                  final isSelected = _selectedIndex == index;
                  
                  return ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                    title: Text(item['title']),
                    trailing: item['badge'] != null
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: item['badge'] == 'NEW' ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['badge'],
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          )
                        : null,
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    onTap: () => _onItemTapped(index),
                  );
                },
              ),
            ),
            // 底部操作
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('设置'),
              onTap: () {
                Navigator.pop(context);
                // 跳转设置页面
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('帮助与反馈'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '版本 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_navItems[_selectedIndex]['icon'], size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _currentPage,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('点击左上角菜单打开抽屉', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
```

## 编程式控制

```dart
// 使用 GlobalKey 控制抽屉
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

Scaffold(
  key: _scaffoldKey,
  drawer: Drawer(...),
  body: ElevatedButton(
    onPressed: () {
      _scaffoldKey.currentState?.openDrawer();
    },
    child: Text('打开抽屉'),
  ),
)

// 或使用 Builder 获取 ScaffoldState
Builder(
  builder: (context) => IconButton(
    icon: Icon(Icons.menu),
    onPressed: () => Scaffold.of(context).openDrawer(),
  ),
)

// 关闭抽屉
Navigator.of(context).pop();
// 或
Scaffold.of(context).closeDrawer();
```

## 最佳实践

1. **合理分组**：使用 Divider 分隔不同功能的菜单项
2. **高亮当前项**：明确显示当前选中的导航项
3. **添加头部**：使用 DrawerHeader 或 UserAccountsDrawerHeader 增强视觉效果
4. **安全区域**：使用 SafeArea 避免内容被系统 UI 遮挡
5. **关闭抽屉**：导航后记得关闭抽屉 `Navigator.pop(context)`
6. **宽度适配**：在平板上考虑使用永久显示的侧边栏
7. **无障碍**：为重要元素添加语义标签

## 相关组件

- [NavigationDrawer](https://api.flutter-io.cn/flutter/material/NavigationDrawer-class.html) - Material 3 导航抽屉
- [NavigationRail](./navigationrail.md) - 侧边导航栏（适合平板）
- [Scaffold](./scaffold.md) - Drawer 的容器
- [ListTile](./listtile.md) - 菜单列表项

## 官方文档

- [Drawer API](https://api.flutter-io.cn/flutter/material/Drawer-class.html)
- [DrawerHeader API](https://api.flutter-io.cn/flutter/material/DrawerHeader-class.html)
- [UserAccountsDrawerHeader API](https://api.flutter-io.cn/flutter/material/UserAccountsDrawerHeader-class.html)
