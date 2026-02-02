# TabBar

`TabBar` 是 Material Design 选项卡栏组件，用于在不同视图之间切换。通常与 `TabBarView` 配合使用，实现选项卡导航效果。

## 基本用法

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('TabBar 示例'),
      bottom: TabBar(
        tabs: [
          Tab(text: '首页'),
          Tab(text: '发现'),
          Tab(text: '我的'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Center(child: Text('首页内容')),
        Center(child: Text('发现内容')),
        Center(child: Text('我的内容')),
      ],
    ),
  ),
)
```

## TabBar 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| tabs | List\<Widget\> | required | 选项卡列表，通常是 Tab 组件 |
| controller | TabController? | null | 选项卡控制器 |
| isScrollable | bool | false | 是否可滚动（适用于多标签） |
| padding | EdgeInsetsGeometry? | null | 内边距 |
| indicatorColor | Color? | 主题色 | 指示器颜色 |
| indicatorWeight | double | 2.0 | 指示器粗细 |
| indicatorPadding | EdgeInsetsGeometry | EdgeInsets.zero | 指示器内边距 |
| indicator | Decoration? | null | 自定义指示器装饰 |
| indicatorSize | TabBarIndicatorSize? | tab | 指示器大小（tab/label） |
| dividerColor | Color? | null | 分割线颜色 |
| dividerHeight | double? | null | 分割线高度 |
| labelColor | Color? | null | 选中标签颜色 |
| unselectedLabelColor | Color? | null | 未选中标签颜色 |
| labelStyle | TextStyle? | null | 选中标签文字样式 |
| unselectedLabelStyle | TextStyle? | null | 未选中标签文字样式 |
| labelPadding | EdgeInsetsGeometry? | null | 标签内边距 |
| overlayColor | WidgetStateProperty\<Color?\>? | null | 覆盖层颜色（点击反馈） |
| splashFactory | InteractiveInkFeatureFactory? | null | 水波纹工厂 |
| splashBorderRadius | BorderRadius? | null | 水波纹圆角 |
| mouseCursor | MouseCursor? | null | 鼠标指针样式 |
| enableFeedback | bool? | true | 是否启用触觉反馈 |
| onTap | ValueChanged\<int\>? | null | 点击标签回调 |
| physics | ScrollPhysics? | null | 滚动物理效果 |
| tabAlignment | TabAlignment? | null | 标签对齐方式 |

## Tab 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| text | String? | null | 标签文字 |
| icon | Widget? | null | 标签图标 |
| iconMargin | EdgeInsetsGeometry | EdgeInsets.only(bottom: 10.0) | 图标边距 |
| height | double? | null | 标签高度 |
| child | Widget? | null | 自定义子组件（与 text 互斥） |

## TabBarView 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| controller | TabController? | null | 选项卡控制器 |
| children | List\<Widget\> | required | 页面内容列表 |
| physics | ScrollPhysics? | null | 滚动物理效果 |
| dragStartBehavior | DragStartBehavior | DragStartBehavior.start | 拖拽开始行为 |
| viewportFraction | double | 1.0 | 视口占比 |
| clipBehavior | Clip | Clip.hardEdge | 裁剪行为 |

## 使用场景

### 1. 基本 TabBar

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('基本 TabBar'),
      bottom: TabBar(
        tabs: [
          Tab(text: '全部'),
          Tab(text: '进行中'),
          Tab(text: '已完成'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Center(child: Text('全部任务')),
        Center(child: Text('进行中任务')),
        Center(child: Text('已完成任务')),
      ],
    ),
  ),
)
```

### 2. 图标 + 文字

```dart
DefaultTabController(
  length: 4,
  child: Scaffold(
    appBar: AppBar(
      title: Text('图标 + 文字'),
      bottom: TabBar(
        tabs: [
          Tab(text: '首页', icon: Icon(Icons.home)),
          Tab(text: '消息', icon: Icon(Icons.message)),
          Tab(text: '收藏', icon: Icon(Icons.favorite)),
          Tab(text: '我的', icon: Icon(Icons.person)),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Center(child: Text('首页内容')),
        Center(child: Text('消息内容')),
        Center(child: Text('收藏内容')),
        Center(child: Text('我的内容')),
      ],
    ),
  ),
)
```

### 3. 可滚动 TabBar

```dart
DefaultTabController(
  length: 10,
  child: Scaffold(
    appBar: AppBar(
      title: Text('可滚动 TabBar'),
      bottom: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: List.generate(
          10,
          (index) => Tab(text: '分类 ${index + 1}'),
        ),
      ),
    ),
    body: TabBarView(
      children: List.generate(
        10,
        (index) => Center(child: Text('分类 ${index + 1} 内容')),
      ),
    ),
  ),
)
```

### 4. 自定义指示器

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('自定义指示器'),
      bottom: TabBar(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(text: '推荐'),
          Tab(text: '热门'),
          Tab(text: '最新'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Center(child: Text('推荐内容')),
        Center(child: Text('热门内容')),
        Center(child: Text('最新内容')),
      ],
    ),
  ),
)
```

### 5. 圆角胶囊指示器

```dart
TabBar(
  indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(25),
    color: Colors.blue,
  ),
  indicatorSize: TabBarIndicatorSize.tab,
  indicatorPadding: EdgeInsets.all(4),
  labelColor: Colors.white,
  unselectedLabelColor: Colors.blue,
  dividerColor: Colors.transparent,
  tabs: [
    Tab(text: '日'),
    Tab(text: '周'),
    Tab(text: '月'),
  ],
)
```

### 6. 使用 TabController

```dart
class TabControllerDemo extends StatefulWidget {
  @override
  State<TabControllerDemo> createState() => _TabControllerDemoState();
}

class _TabControllerDemoState extends State<TabControllerDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        print('切换到: ${_tabController.index}');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TabController 示例'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '标签 1'),
            Tab(text: '标签 2'),
            Tab(text: '标签 3'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text('内容 1')),
          Center(child: Text('内容 2')),
          Center(child: Text('内容 3')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 编程切换标签
          _tabController.animateTo(
            (_tabController.index + 1) % 3,
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
```

### 7. 仅图标 TabBar

```dart
TabBar(
  tabs: [
    Tab(icon: Icon(Icons.directions_car)),
    Tab(icon: Icon(Icons.directions_transit)),
    Tab(icon: Icon(Icons.directions_bike)),
    Tab(icon: Icon(Icons.directions_walk)),
  ],
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class NewsCategoryPage extends StatefulWidget {
  @override
  State<NewsCategoryPage> createState() => _NewsCategoryPageState();
}

class _NewsCategoryPageState extends State<NewsCategoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {'name': '推荐', 'icon': Icons.recommend},
    {'name': '热点', 'icon': Icons.whatshot},
    {'name': '科技', 'icon': Icons.computer},
    {'name': '财经', 'icon': Icons.attach_money},
    {'name': '体育', 'icon': Icons.sports_basketball},
    {'name': '娱乐', 'icon': Icons.movie},
    {'name': '军事', 'icon': Icons.military_tech},
    {'name': '国际', 'icon': Icons.public},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新闻分类'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          onTap: (index) {
            print('点击: ${_categories[index]['name']}');
          },
          tabs: _categories.map((category) {
            return Tab(text: category['name']);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return NewsList(category: category['name']);
        }).toList(),
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  final String category;

  const NewsList({required this.category});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, color: Colors.grey[600]),
            ),
            title: Text(
              '$category 新闻标题 ${index + 1}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text('来源', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 16),
                  Text('2小时前', style: TextStyle(fontSize: 12)),
                  Spacer(),
                  Icon(Icons.more_horiz, size: 16),
                ],
              ),
            ),
            contentPadding: EdgeInsets.all(12),
            onTap: () {},
          ),
        );
      },
    );
  }
}
```

## 底部 TabBar 样式

```dart
Scaffold(
  body: TabBarView(
    controller: _tabController,
    children: [
      Center(child: Text('首页')),
      Center(child: Text('分类')),
      Center(child: Text('我的')),
    ],
  ),
  bottomNavigationBar: Material(
    color: Theme.of(context).primaryColor,
    child: TabBar(
      controller: _tabController,
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      tabs: [
        Tab(text: '首页', icon: Icon(Icons.home)),
        Tab(text: '分类', icon: Icon(Icons.category)),
        Tab(text: '我的', icon: Icon(Icons.person)),
      ],
    ),
  ),
)
```

## 最佳实践

### 1. 使用 DefaultTabController

对于简单场景，推荐使用 `DefaultTabController`，无需手动管理状态：

```dart
// ✅ 推荐：简单场景
DefaultTabController(
  length: 3,
  initialIndex: 0, // 初始选中索引
  child: Scaffold(
    appBar: AppBar(
      bottom: TabBar(tabs: [...]),
    ),
    body: TabBarView(children: [...]),
  ),
)

// 获取 controller（在子组件中）
final tabController = DefaultTabController.of(context);
tabController.animateTo(1); // 切换到第二个标签
```

### 2. 何时使用 TabController

- 需要监听标签切换事件
- 需要编程式切换标签
- 需要更精细的动画控制
- 需要在 State 外部控制 TabBar

### 3. 性能优化

```dart
// 使用 AutomaticKeepAliveClientMixin 保持页面状态
class _NewsListState extends State<NewsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(...);
  }
}
```

### 4. 标签数量建议

- **3-5 个**：使用固定标签 `isScrollable: false`
- **5 个以上**：使用可滚动标签 `isScrollable: true`

### 5. 保持一致性

```dart
// 在 ThemeData 中统一配置 TabBar 样式
ThemeData(
  tabBarTheme: TabBarTheme(
    labelColor: Colors.blue,
    unselectedLabelColor: Colors.grey,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
  ),
)
```

## 相关组件

- [TabBarView](https://api.flutter-io.cn/flutter/material/TabBarView-class.html) - 选项卡内容视图
- [DefaultTabController](https://api.flutter-io.cn/flutter/material/DefaultTabController-class.html) - 默认选项卡控制器
- [TabPageSelector](https://api.flutter-io.cn/flutter/material/TabPageSelector-class.html) - 页面指示器
- [AppBar](./appbar.md) - 应用栏
- [BottomNavigationBar](./bottomnavigationbar.md) - 底部导航栏

## 官方文档

- [TabBar API](https://api.flutter-io.cn/flutter/material/TabBar-class.html)
- [Tab API](https://api.flutter-io.cn/flutter/material/Tab-class.html)
- [TabBarView API](https://api.flutter-io.cn/flutter/material/TabBarView-class.html)
