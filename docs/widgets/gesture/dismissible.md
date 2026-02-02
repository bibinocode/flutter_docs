# Dismissible

`Dismissible` 是 Flutter 中用于实现滑动删除功能的组件，允许用户通过水平或垂直滑动手势来移除列表项。它常用于邮件列表、待办事项、消息通知等需要快速删除或归档操作的场景。

## 基本用法

```dart
Dismissible(
  key: Key('item_1'),
  onDismissed: (direction) {
    print('项目已删除');
  },
  child: ListTile(
    title: Text('滑动删除我'),
  ),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `key` | `Key` | **必需**，用于标识组件的唯一键 |
| `child` | `Widget` | 子组件，通常是列表项 |
| `background` | `Widget?` | 向右/向下滑动时显示的背景组件 |
| `secondaryBackground` | `Widget?` | 向左/向上滑动时显示的背景组件 |
| `confirmDismiss` | `ConfirmDismissCallback?` | 确认是否执行删除的回调，返回 `Future<bool>` |
| `onResize` | `VoidCallback?` | 组件大小变化时的回调 |
| `onUpdate` | `DismissUpdateCallback?` | 滑动更新时的回调，提供进度信息 |
| `onDismissed` | `DismissDirectionCallback?` | 删除完成后的回调 |
| `direction` | `DismissDirection` | 允许滑动的方向 |
| `resizeDuration` | `Duration?` | 删除后收缩动画的持续时间 |
| `dismissThresholds` | `Map&lt;DismissDirection, double&gt;` | 触发删除的滑动阈值 |
| `movementDuration` | `Duration` | 滑动动画的持续时间 |
| `crossAxisEndOffset` | `double` | 交叉轴方向的偏移量 |
| `dragStartBehavior` | `DragStartBehavior` | 拖拽开始行为 |
| `behavior` | `HitTestBehavior` | 命中测试行为 |

## DismissDirection 枚举

| 值 | 说明 |
|------|------|
| `horizontal` | 水平方向（左右都可） |
| `vertical` | 垂直方向（上下都可） |
| `endToStart` | 从右向左滑动（LTR布局） |
| `startToEnd` | 从左向右滑动（LTR布局） |
| `up` | 向上滑动 |
| `down` | 向下滑动 |
| `none` | 禁用滑动 |

## 使用场景

### 1. 列表滑动删除

```dart
class SwipeDeleteList extends StatefulWidget {
  @override
  State<SwipeDeleteList> createState() => _SwipeDeleteListState();
}

class _SwipeDeleteListState extends State<SwipeDeleteList> {
  final List<String> _items = List.generate(10, (index) => '项目 ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Dismissible(
          key: Key(item),
          onDismissed: (direction) {
            setState(() {
              _items.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$item 已删除')),
            );
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(item),
            leading: Icon(Icons.label),
          ),
        );
      },
    );
  }
}
```

### 2. 邮件归档

```dart
class EmailArchiveExample extends StatefulWidget {
  @override
  State<EmailArchiveExample> createState() => _EmailArchiveExampleState();
}

class _EmailArchiveExampleState extends State<EmailArchiveExample> {
  final List<Map<String, String>> _emails = [
    {'id': '1', 'subject': '会议通知', 'sender': '张三'},
    {'id': '2', 'subject': '项目进度', 'sender': '李四'},
    {'id': '3', 'subject': '周报提醒', 'sender': '王五'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _emails.length,
      itemBuilder: (context, index) {
        final email = _emails[index];
        return Dismissible(
          key: Key(email['id']!),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            final action = direction == DismissDirection.startToEnd ? '归档' : '删除';
            setState(() {
              _emails.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('邮件已$action')),
            );
          },
          // 向右滑动 - 归档
          background: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Icon(Icons.archive, color: Colors.white),
                SizedBox(width: 8),
                Text('归档', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          // 向左滑动 - 删除
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('删除', style: TextStyle(color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(child: Text(email['sender']![0])),
            title: Text(email['subject']!),
            subtitle: Text('来自: ${email['sender']}'),
          ),
        );
      },
    );
  }
}
```

### 3. 带确认的删除

```dart
class ConfirmDeleteExample extends StatefulWidget {
  @override
  State<ConfirmDeleteExample> createState() => _ConfirmDeleteExampleState();
}

class _ConfirmDeleteExampleState extends State<ConfirmDeleteExample> {
  final List<String> _items = ['重要文件', '工作文档', '个人资料'];

  Future<bool?> _showConfirmDialog(BuildContext context, String item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除 "$item" 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Dismissible(
          key: Key(item),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => _showConfirmDialog(context, item),
          onDismissed: (direction) {
            setState(() {
              _items.removeAt(index);
            });
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete_forever, color: Colors.white),
          ),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file),
            title: Text(item),
            trailing: Icon(Icons.warning, color: Colors.orange),
          ),
        );
      },
    );
  }
}
```

### 4. 自定义背景

```dart
class CustomBackgroundExample extends StatefulWidget {
  @override
  State<CustomBackgroundExample> createState() => _CustomBackgroundExampleState();
}

class _CustomBackgroundExampleState extends State<CustomBackgroundExample> {
  final List<Map<String, dynamic>> _tasks = [
    {'id': '1', 'title': '完成报告', 'done': false},
    {'id': '2', 'title': '回复邮件', 'done': false},
    {'id': '3', 'title': '准备会议', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Dismissible(
          key: Key(task['id']),
          dismissThresholds: {
            DismissDirection.startToEnd: 0.3,
            DismissDirection.endToStart: 0.3,
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // 标记完成
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${task['title']} 已完成'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              // 删除
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${task['title']} 已删除'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              _tasks.removeAt(index);
            });
          },
          // 向右滑动 - 完成任务
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade600],
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 30),
                SizedBox(width: 12),
                Text(
                  '完成',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 向左滑动 - 删除任务
          secondaryBackground: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade600, Colors.red.shade300],
              ),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '删除',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.delete, color: Colors.white, size: 30),
              ],
            ),
          ),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Checkbox(
                value: task['done'],
                onChanged: (value) {
                  setState(() {
                    task['done'] = value;
                  });
                },
              ),
              title: Text(task['title']),
              trailing: Icon(Icons.drag_handle),
            ),
          ),
        );
      },
    );
  }
}
```

## 完整示例：邮件列表滑动操作

```dart
import 'package:flutter/material.dart';

class Email {
  final String id;
  final String sender;
  final String subject;
  final String preview;
  final DateTime time;
  final bool isStarred;
  final bool isRead;

  Email({
    required this.id,
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
    this.isStarred = false,
    this.isRead = false,
  });
}

class EmailListPage extends StatefulWidget {
  @override
  State<EmailListPage> createState() => _EmailListPageState();
}

class _EmailListPageState extends State<EmailListPage> {
  final List<Email> _emails = [
    Email(
      id: '1',
      sender: '张三',
      subject: '项目进度更新',
      preview: '本周项目进度如下：前端完成80%，后端完成90%...',
      time: DateTime.now().subtract(Duration(minutes: 30)),
      isStarred: true,
    ),
    Email(
      id: '2',
      sender: '李四',
      subject: '会议邀请',
      preview: '邀请您参加明天下午3点的产品评审会议...',
      time: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Email(
      id: '3',
      sender: '王五',
      subject: '周报提醒',
      preview: '请在今天下班前提交本周工作周报...',
      time: DateTime.now().subtract(Duration(hours: 5)),
      isRead: true,
    ),
    Email(
      id: '4',
      sender: '系统通知',
      subject: '账号安全提醒',
      preview: '检测到您的账号在新设备上登录...',
      time: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
    ),
    Email(
      id: '5',
      sender: '人事部',
      subject: '假期申请已批准',
      preview: '您提交的年假申请已经审批通过...',
      time: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
    ),
  ];

  final List<Email> _archivedEmails = [];
  final List<Email> _deletedEmails = [];

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${diff.inDays}天前';
    }
  }

  void _undoArchive(Email email, int index) {
    setState(() {
      _archivedEmails.remove(email);
      _emails.insert(index, email);
    });
  }

  void _undoDelete(Email email, int index) {
    setState(() {
      _deletedEmails.remove(email);
      _emails.insert(index, email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收件箱'),
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
      body: _emails.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('收件箱为空', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _emails.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final email = _emails[index];
                return Dismissible(
                  key: Key(email.id),
                  // 滑动更新回调
                  onUpdate: (details) {
                    // 可用于实现滑动时的视觉反馈
                  },
                  // 确认删除
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // 删除操作需要确认
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('删除邮件'),
                          content: Text('确定要删除这封邮件吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('删除'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ) ?? false;
                    }
                    // 归档操作直接执行
                    return true;
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _emails.removeAt(index);
                    });

                    if (direction == DismissDirection.startToEnd) {
                      // 归档
                      _archivedEmails.add(email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已归档'),
                          action: SnackBarAction(
                            label: '撤销',
                            onPressed: () => _undoArchive(email, index),
                          ),
                        ),
                      );
                    } else {
                      // 删除
                      _deletedEmails.add(email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已删除'),
                          action: SnackBarAction(
                            label: '撤销',
                            onPressed: () => _undoDelete(email, index),
                          ),
                        ),
                      );
                    }
                  },
                  // 向右滑动 - 归档
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.archive, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          '归档',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // 向左滑动 - 删除
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          '删除',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: email.isRead
                          ? Colors.grey.shade300
                          : Colors.blue,
                      child: Text(
                        email.sender[0],
                        style: TextStyle(
                          color: email.isRead ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            email.sender,
                            style: TextStyle(
                              fontWeight: email.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(email.time),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email.subject,
                          style: TextStyle(
                            fontWeight: email.isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email.preview,
                          style: TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: email.isStarred
                        ? Icon(Icons.star, color: Colors.amber)
                        : null,
                    isThreeLine: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.edit),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EmailListPage(),
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
    ),
  ));
}
```

## 最佳实践

### 1. Key 的重要性

`Dismissible` **必须**提供唯一的 `key`，这对于正确识别和删除列表项至关重要：

```dart
// ✅ 正确：使用唯一标识符
Dismissible(
  key: Key(item.id),  // 使用数据的唯一 ID
  child: ...,
)

// ✅ 正确：使用 ValueKey
Dismissible(
  key: ValueKey(item.id),
  child: ...,
)

// ❌ 错误：使用索引作为 key
Dismissible(
  key: Key(index.toString()),  // 删除后索引会变化，导致问题
  child: ...,
)

// ❌ 错误：没有提供 key
Dismissible(
  child: ...,  // 编译错误，key 是必需的
)
```

### 2. confirmDismiss 防误删

对于重要数据，使用 `confirmDismiss` 添加确认步骤：

```dart
Dismissible(
  key: Key(item.id),
  confirmDismiss: (direction) async {
    // 方式1：显示对话框确认
    if (item.isImportant) {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('确认删除'),
          content: Text('这是重要项目，确定要删除吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('确定'),
            ),
          ],
        ),
      ) ?? false;
    }
    
    // 方式2：根据方向决定是否需要确认
    if (direction == DismissDirection.endToStart) {
      // 删除需要确认
      return await _showDeleteConfirmation(context);
    }
    // 归档直接执行
    return true;
  },
  onDismissed: (direction) {
    // 执行删除逻辑
  },
  child: ...,
)
```

### 3. 提供撤销功能

删除后提供撤销选项，提升用户体验：

```dart
onDismissed: (direction) {
  final removedItem = items[index];
  setState(() {
    items.removeAt(index);
  });
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('已删除'),
      action: SnackBarAction(
        label: '撤销',
        onPressed: () {
          setState(() {
            items.insert(index, removedItem);
          });
        },
      ),
    ),
  );
}
```

### 4. 设置合适的滑动阈值

根据操作的重要性设置不同的阈值：

```dart
Dismissible(
  key: Key(item.id),
  dismissThresholds: {
    // 删除操作需要滑动更多距离
    DismissDirection.endToStart: 0.6,
    // 归档操作较容易触发
    DismissDirection.startToEnd: 0.3,
  },
  child: ...,
)
```

## 相关组件

- [Draggable](./draggable.md) - 可拖拽组件，支持自由拖放
- [GestureDetector](./gesturedetector.md) - 通用手势检测组件
