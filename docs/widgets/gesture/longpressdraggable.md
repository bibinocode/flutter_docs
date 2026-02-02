# LongPressDraggable

`LongPressDraggable` 是 Flutter 中需要长按后才能开始拖拽的组件，继承自 `Draggable`。它适用于需要区分点击和拖拽操作的场景，避免意外触发拖拽，特别适合在可滚动列表中使用。

## 基本用法

```dart
LongPressDraggable<String>(
  data: 'item_1',
  delay: Duration(milliseconds: 500),
  feedback: Material(
    elevation: 4,
    child: Container(
      width: 80,
      height: 80,
      color: Colors.blue.withOpacity(0.8),
      child: Icon(Icons.apps, color: Colors.white, size: 40),
    ),
  ),
  child: Container(
    width: 80,
    height: 80,
    color: Colors.blue,
    child: Icon(Icons.apps, color: Colors.white, size: 40),
  ),
)
```

## 属性

### 继承自 Draggable 的属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget` | 默认状态下显示的子组件 |
| `feedback` | `Widget` | 拖拽时跟随手指移动的组件 |
| `data` | `T?` | 拖拽携带的数据 |
| `axis` | `Axis?` | 限制拖拽方向（水平或垂直） |
| `childWhenDragging` | `Widget?` | 拖拽时原位置显示的组件 |
| `feedbackOffset` | `Offset` | feedback 组件的偏移量 |
| `dragAnchorStrategy` | `DragAnchorStrategy?` | 拖拽锚点策略 |
| `affinity` | `Axis?` | 多方向拖拽时的优先方向 |
| `maxSimultaneousDrags` | `int?` | 最大同时拖拽数量 |
| `onDragStarted` | `VoidCallback?` | 拖拽开始回调 |
| `onDragUpdate` | `DragUpdateCallback?` | 拖拽更新回调 |
| `onDraggableCanceled` | `DraggableCanceledCallback?` | 拖拽取消回调 |
| `onDragEnd` | `DragEndCallback?` | 拖拽结束回调 |
| `onDragCompleted` | `VoidCallback?` | 拖拽成功放置回调 |
| `rootOverlay` | `bool` | 是否使用根 Overlay |
| `hitTestBehavior` | `HitTestBehavior` | 命中测试行为 |
| `allowedButtonsFilter` | `AllowedButtonsFilter?` | 允许的按钮过滤器 |

### LongPressDraggable 特有属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|------|------|
| `delay` | `Duration` | `kLongPressTimeout` | 长按触发拖拽的延迟时间（约 500ms） |
| `hapticFeedbackOnStart` | `bool` | `true` | 开始拖拽时是否触发触觉反馈（振动） |

## 使用场景

### 1. 桌面图标重排

长按图标后拖拽到新位置，类似手机桌面的图标整理功能。

```dart
class DesktopIconRearrange extends StatefulWidget {
  @override
  State<DesktopIconRearrange> createState() => _DesktopIconRearrangeState();
}

class _DesktopIconRearrangeState extends State<DesktopIconRearrange> {
  List<AppItem> apps = [
    AppItem(id: '1', name: '相机', icon: Icons.camera_alt, color: Colors.orange),
    AppItem(id: '2', name: '相册', icon: Icons.photo_library, color: Colors.pink),
    AppItem(id: '3', name: '设置', icon: Icons.settings, color: Colors.grey),
    AppItem(id: '4', name: '邮件', icon: Icons.email, color: Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return DragTarget<AppItem>(
          onAcceptWithDetails: (details) {
            setState(() {
              final oldIndex = apps.indexOf(details.data);
              apps.removeAt(oldIndex);
              apps.insert(index, details.data);
            });
          },
          builder: (context, candidateData, rejectedData) {
            return LongPressDraggable<AppItem>(
              data: app,
              hapticFeedbackOnStart: true,
              feedback: _buildAppIcon(app, isDragging: true),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildAppIcon(app),
              ),
              child: _buildAppIcon(app, isTarget: candidateData.isNotEmpty),
            );
          },
        );
      },
    );
  }

  Widget _buildAppIcon(AppItem app, {bool isDragging = false, bool isTarget = false}) {
    return Material(
      color: Colors.transparent,
      elevation: isDragging ? 8 : 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isTarget ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: app.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(app.icon, color: Colors.white, size: 30),
            ),
            SizedBox(height: 4),
            Text(
              app.name,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class AppItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  AppItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
```

### 2. 长按移动列表项

在列表中长按后拖动项目，避免与列表滚动冲突。

```dart
class DraggableListExample extends StatefulWidget {
  @override
  State<DraggableListExample> createState() => _DraggableListExampleState();
}

class _DraggableListExampleState extends State<DraggableListExample> {
  List<String> items = List.generate(10, (index) => '项目 ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return DragTarget<int>(
          onAcceptWithDetails: (details) {
            setState(() {
              final movedItem = items.removeAt(details.data);
              items.insert(index, movedItem);
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isTarget = candidateData.isNotEmpty;
            return LongPressDraggable<int>(
              data: index,
              delay: Duration(milliseconds: 300),
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              childWhenDragging: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                ),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isTarget ? Colors.blue.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(item),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
```

### 3. 避免与滚动冲突

在 `GridView` 或 `ListView` 中使用，长按后才能拖拽，确保正常滚动不受影响。

```dart
class ScrollConflictExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return LongPressDraggable<int>(
          data: index,
          // 较长的延迟确保滚动优先
          delay: Duration(milliseconds: 400),
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.primaries[index % Colors.primaries.length],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.primaries[index % Colors.primaries.length],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 完整示例：手机桌面图标拖拽

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(PhoneDesktopApp());

class PhoneDesktopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: PhoneDesktopScreen(),
    );
  }
}

class PhoneDesktopScreen extends StatefulWidget {
  @override
  State<PhoneDesktopScreen> createState() => _PhoneDesktopScreenState();
}

class _PhoneDesktopScreenState extends State<PhoneDesktopScreen> {
  // 桌面应用图标数据
  List<DesktopApp?> desktopApps = [
    DesktopApp(id: '1', name: '电话', icon: Icons.phone, color: Colors.green),
    DesktopApp(id: '2', name: '信息', icon: Icons.message, color: Colors.blue),
    DesktopApp(id: '3', name: '相机', icon: Icons.camera_alt, color: Colors.orange),
    DesktopApp(id: '4', name: '相册', icon: Icons.photo_library, color: Colors.pink),
    DesktopApp(id: '5', name: '设置', icon: Icons.settings, color: Colors.grey),
    DesktopApp(id: '6', name: '时钟', icon: Icons.access_time, color: Colors.deepPurple),
    DesktopApp(id: '7', name: '日历', icon: Icons.calendar_today, color: Colors.red),
    DesktopApp(id: '8', name: '天气', icon: Icons.wb_sunny, color: Colors.amber),
    null, // 空位
    DesktopApp(id: '9', name: '音乐', icon: Icons.music_note, color: Colors.teal),
    DesktopApp(id: '10', name: '视频', icon: Icons.play_circle, color: Colors.indigo),
    null, // 空位
    DesktopApp(id: '11', name: '地图', icon: Icons.map, color: Colors.lightGreen),
    DesktopApp(id: '12', name: '备忘录', icon: Icons.note, color: Colors.yellow.shade700),
    DesktopApp(id: '13', name: '计算器', icon: Icons.calculate, color: Colors.blueGrey),
    DesktopApp(id: '14', name: '浏览器', icon: Icons.language, color: Colors.cyan),
  ];

  int? draggingIndex;
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 状态栏
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '9:41',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.wifi, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.battery_full, color: Colors.white, size: 18),
                      ],
                    ),
                  ],
                ),
              ),

              // 应用图标网格
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: desktopApps.length,
                  itemBuilder: (context, index) {
                    return _buildGridItem(index);
                  },
                ),
              ),

              // 底部 Dock 栏
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDockIcon(Icons.phone, Colors.green),
                    _buildDockIcon(Icons.message, Colors.blue),
                    _buildDockIcon(Icons.email, Colors.lightBlue),
                    _buildDockIcon(Icons.language, Colors.cyan),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(int index) {
    final app = desktopApps[index];

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        return details.data != index;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          // 交换位置
          final draggedApp = desktopApps[details.data];
          desktopApps[details.data] = desktopApps[index];
          desktopApps[index] = draggedApp;
          draggingIndex = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isTarget = candidateData.isNotEmpty;

        if (app == null) {
          // 空位
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isTarget
                  ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
                  : null,
            ),
          );
        }

        return LongPressDraggable<int>(
          data: index,
          delay: Duration(milliseconds: 500),
          hapticFeedbackOnStart: true,
          onDragStarted: () {
            setState(() {
              draggingIndex = index;
              isEditing = true;
            });
            HapticFeedback.mediumImpact();
          },
          onDragEnd: (details) {
            setState(() {
              draggingIndex = null;
            });
          },
          feedback: Transform.scale(
            scale: 1.1,
            child: _buildAppIcon(app, isFloating: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildAppIcon(app),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            transform: isTarget
                ? (Matrix4.identity()..scale(1.1))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            child: _buildAppIcon(
              app,
              showDeleteBadge: isEditing && draggingIndex == null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppIcon(
    DesktopApp app, {
    bool isFloating = false,
    bool showDeleteBadge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: app.color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isFloating
                      ? [
                          BoxShadow(
                            color: app.color.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  app.icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              if (showDeleteBadge)
                Positioned(
                  top: -6,
                  left: -6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final index = desktopApps.indexWhere((a) => a?.id == app.id);
                        if (index != -1) {
                          desktopApps[index] = null;
                        }
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            app.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDockIcon(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class DesktopApp {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  DesktopApp({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
```

## 最佳实践

### LongPressDraggable vs Draggable 选择指南

| 场景 | 推荐组件 | 原因 |
|------|------|------|
| 在可滚动列表中拖拽 | `LongPressDraggable` | 避免与滚动手势冲突 |
| 桌面/网格图标排序 | `LongPressDraggable` | 符合用户习惯（手机桌面） |
| 卡片拖拽到垃圾桶 | `Draggable` | 即时响应更流畅 |
| 拼图游戏 | `Draggable` | 需要快速拖拽 |
| 表单字段排序 | `LongPressDraggable` | 防止误触 |
| 购物车添加商品 | `Draggable` | 直观的拖拽添加 |

### 注意事项

```dart
// ✅ 正确：设置合适的延迟时间
LongPressDraggable(
  delay: Duration(milliseconds: 300), // 不要太短也不要太长
  // ...
)

// ✅ 正确：提供清晰的视觉反馈
LongPressDraggable(
  hapticFeedbackOnStart: true,
  feedback: Material(
    elevation: 8,  // 添加阴影表示正在拖拽
    child: /* ... */,
  ),
  childWhenDragging: Opacity(
    opacity: 0.5,  // 原位置变淡
    child: /* ... */,
  ),
  // ...
)

// ❌ 避免：在需要快速响应的场景使用
// 游戏或需要即时反馈的场景应使用 Draggable

// ✅ 正确：与 DragTarget 配合使用
DragTarget<T>(
  onAcceptWithDetails: (details) {
    // 处理接收到的数据
  },
  builder: (context, candidateData, rejectedData) {
    return LongPressDraggable<T>(
      // ...
    );
  },
)
```

### 性能优化

```dart
// 使用 const 构造函数优化 feedback
LongPressDraggable(
  feedback: const _DragFeedback(),  // 使用独立的 StatelessWidget
  // ...
)

// 避免在 feedback 中使用复杂动画
// feedback 会跟随手指移动，过于复杂会影响性能
```

## 相关组件

- [Draggable](./draggable.md) - 基础拖拽组件，无需长按即可拖拽
- [DragTarget](./dragtarget.md) - 拖拽目标组件，接收拖拽数据
- [ReorderableListView](../scrolling/reorderablelistview.md) - 可重新排序的列表视图，内置长按拖拽功能
