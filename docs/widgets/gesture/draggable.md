# Draggable

`Draggable` 是 Flutter 中用于创建可拖拽组件的核心 Widget，允许用户通过拖拽手势将数据从一个位置移动到另一个位置。它通常与 `DragTarget` 配合使用，实现拖放交互功能。

## 基本用法

```dart
Draggable<String>(
  data: '任务数据',
  feedback: Material(
    elevation: 4,
    child: Container(
      width: 100,
      height: 50,
      color: Colors.blue,
      child: Center(child: Text('拖拽中')),
    ),
  ),
  child: Container(
    width: 100,
    height: 50,
    color: Colors.blue,
    child: Center(child: Text('拖我')),
  ),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget` | 默认状态下显示的子组件 |
| `feedback` | `Widget` | 拖拽时跟随手指移动的组件 |
| `childWhenDragging` | `Widget?` | 拖拽时原位置显示的组件，默认为 null 时显示 child |
| `data` | `T?` | 拖拽携带的数据，传递给 DragTarget |
| `axis` | `Axis?` | 限制拖拽方向，null 表示任意方向 |
| `affinity` | `Axis?` | 拖拽手势的识别优先方向 |
| `maxSimultaneousDrags` | `int?` | 最大同时拖拽数量，null 表示无限制 |
| `onDragStarted` | `VoidCallback?` | 拖拽开始时回调 |
| `onDragUpdate` | `DragUpdateCallback?` | 拖拽过程中回调，提供位置信息 |
| `onDraggableCanceled` | `DraggableCanceledCallback?` | 拖拽取消时回调（未放到 DragTarget 上） |
| `onDragEnd` | `DragEndCallback?` | 拖拽结束时回调，提供拖拽详情 |
| `onDragCompleted` | `VoidCallback?` | 拖拽成功完成时回调（放到 DragTarget 上） |
| `ignoringFeedbackSemantics` | `bool` | 是否忽略 feedback 的语义信息，默认 true |
| `ignoringFeedbackPointer` | `bool` | 是否忽略 feedback 的指针事件，默认 true |
| `feedbackOffset` | `Offset` | feedback 组件的偏移量，默认 Offset.zero |
| `dragAnchorStrategy` | `DragAnchorStrategy?` | 拖拽锚点策略，决定 feedback 相对于手指的位置 |
| `rootOverlay` | `bool` | 是否将 feedback 添加到根 Overlay，默认 false |
| `hitTestBehavior` | `HitTestBehavior` | 命中测试行为，默认 deferToChild |

### DragAnchorStrategy 策略

| 策略 | 说明 |
|------|------|
| `childDragAnchorStrategy` | 默认策略，feedback 以触摸点在 child 中的相对位置为锚点 |
| `pointerDragAnchorStrategy` | feedback 的左上角跟随触摸点 |

## 使用场景

### 1. 拖拽排序

```dart
class DragSortExample extends StatefulWidget {
  @override
  State<DragSortExample> createState() => _DragSortExampleState();
}

class _DragSortExampleState extends State<DragSortExample> {
  List<String> items = ['项目 A', '项目 B', '项目 C', '项目 D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return DragTarget<int>(
          onAcceptWithDetails: (details) {
            setState(() {
              final fromIndex = details.data;
              final movedItem = items.removeAt(fromIndex);
              items.insert(index, movedItem);
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Draggable<int>(
              data: index,
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item, style: TextStyle(fontSize: 16)),
                ),
              ),
              childWhenDragging: Container(
                width: 300,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                ),
                child: Text(item, style: TextStyle(color: Colors.grey)),
              ),
              child: Container(
                width: 300,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty 
                      ? Colors.blue.shade50 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: candidateData.isNotEmpty 
                        ? Colors.blue 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(item, style: TextStyle(fontSize: 16)),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
```

### 2. 看板任务卡片

```dart
class KanbanBoard extends StatefulWidget {
  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  Map<String, List<String>> columns = {
    '待办': ['设计 UI', '编写文档'],
    '进行中': ['开发功能'],
    '已完成': ['代码审查'],
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.entries.map((entry) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                DragTarget<Map<String, String>>(
                  onAcceptWithDetails: (details) {
                    setState(() {
                      final data = details.data;
                      columns[data['from']]!.remove(data['task']);
                      columns[entry.key]!.add(data['task']!);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      constraints: BoxConstraints(minHeight: 200),
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty
                            ? Colors.blue.shade50
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: entry.value.map((task) {
                          return Draggable<Map<String, String>>(
                            data: {'from': entry.key, 'task': task},
                            feedback: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(8),
                              child: _buildTaskCard(task, dragging: true),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: _buildTaskCard(task),
                            ),
                            child: _buildTaskCard(task),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard(String task, {bool dragging = false}) {
    return Container(
      width: dragging ? 150 : double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dragging ? 0.2 : 0.1),
            blurRadius: dragging ? 8 : 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(task),
    );
  }
}
```

### 3. 购物车添加

```dart
class ShoppingCartExample extends StatefulWidget {
  @override
  State<ShoppingCartExample> createState() => _ShoppingCartExampleState();
}

class _ShoppingCartExampleState extends State<ShoppingCartExample> {
  List<String> products = ['手机', '耳机', '手表', '平板'];
  List<String> cart = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('商品列表', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: products.map((product) {
            return Draggable<String>(
              data: product,
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      product,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    product,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 32),
        DragTarget<String>(
          onAcceptWithDetails: (details) {
            setState(() {
              cart.add(details.data);
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: candidateData.isNotEmpty
                      ? Colors.green
                      : Colors.grey,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 40,
                    color: candidateData.isNotEmpty
                        ? Colors.green
                        : Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    candidateData.isNotEmpty
                        ? '松开添加到购物车'
                        : '购物车 (${cart.length}件)',
                    style: TextStyle(
                      color: candidateData.isNotEmpty
                          ? Colors.green
                          : Colors.grey.shade700,
                    ),
                  ),
                  if (cart.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        cart.join(', '),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
```

### 4. 拖拽到垃圾桶

```dart
class TrashBinExample extends StatefulWidget {
  @override
  State<TrashBinExample> createState() => _TrashBinExampleState();
}

class _TrashBinExampleState extends State<TrashBinExample> {
  List<String> items = ['文件 A', '文件 B', '文件 C', '文件 D'];
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Draggable<String>(
                data: item,
                feedback: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text(item),
                      ],
                    ),
                  ),
                ),
                childWhenDragging: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item, style: TextStyle(color: Colors.grey)),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file),
                      SizedBox(width: 12),
                      Text(item),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: DragTarget<String>(
            onWillAcceptWithDetails: (details) {
              setState(() => _isHovering = true);
              return true;
            },
            onLeave: (data) {
              setState(() => _isHovering = false);
            },
            onAcceptWithDetails: (details) {
              setState(() {
                items.remove(details.data);
                _isHovering = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除 ${details.data}')),
              );
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: _isHovering ? 100 : 80,
                height: _isHovering ? 100 : 80,
                decoration: BoxDecoration(
                  color: _isHovering ? Colors.red : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isHovering ? Icons.delete_forever : Icons.delete,
                  size: _isHovering ? 50 : 40,
                  color: _isHovering ? Colors.white : Colors.grey.shade600,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 完整示例：拖拽任务到不同分类

```dart
import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final Color color;

  Task({required this.id, required this.title, required this.color});
}

class TaskCategoryExample extends StatefulWidget {
  @override
  State<TaskCategoryExample> createState() => _TaskCategoryExampleState();
}

class _TaskCategoryExampleState extends State<TaskCategoryExample> {
  final Map<String, List<Task>> categories = {
    '工作': [
      Task(id: '1', title: '完成报告', color: Colors.blue),
      Task(id: '2', title: '开会', color: Colors.blue),
    ],
    '学习': [
      Task(id: '3', title: '阅读书籍', color: Colors.green),
    ],
    '生活': [
      Task(id: '4', title: '购物', color: Colors.orange),
      Task(id: '5', title: '健身', color: Colors.orange),
    ],
  };

  String? _draggingFrom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('任务分类'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categories.entries.map((entry) {
            return Expanded(
              child: _buildCategoryColumn(entry.key, entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryColumn(String category, List<Task> tasks) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) {
        return _draggingFrom != category;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          // 从原分类移除
          categories.forEach((key, value) {
            value.removeWhere((t) => t.id == details.data.id);
          });
          // 添加到新分类
          categories[category]!.add(
            Task(
              id: details.data.id,
              title: details.data.title,
              color: _getCategoryColor(category),
            ),
          );
          _draggingFrom = null;
        });
      },
      onLeave: (data) {
        setState(() {});
      },
      builder: (context, candidateData, rejectedData) {
        final isAccepting = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAccepting
                ? _getCategoryColor(category).withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAccepting
                  ? _getCategoryColor(category)
                  : Colors.grey.shade300,
              width: isAccepting ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ...tasks.map((task) => _buildTaskCard(task, category)),
              if (isAccepting)
                Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCategoryColor(category),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: _getCategoryColor(category),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '放置到这里',
                        style: TextStyle(
                          color: _getCategoryColor(category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, String category) {
    return Draggable<Task>(
      data: task,
      onDragStarted: () {
        setState(() {
          _draggingFrom = category;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggingFrom = null;
        });
      },
      feedback: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 150,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.drag_indicator, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Text(
          task.title,
          style: TextStyle(color: Colors.grey),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: task.color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: task.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.drag_indicator,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '工作':
        return Colors.blue;
      case '学习':
        return Colors.green;
      case '生活':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '工作':
        return Icons.work;
      case '学习':
        return Icons.school;
      case '生活':
        return Icons.favorite;
      default:
        return Icons.folder;
    }
  }
}
```

## 最佳实践

### 1. 配合 DragTarget 使用

```dart
// Draggable 和 DragTarget 的典型配合模式
class DragDropPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 拖拽源
        Draggable<String>(
          data: '数据',
          feedback: _buildFeedback(),
          childWhenDragging: _buildPlaceholder(),
          child: _buildDraggableItem(),
        ),
        
        SizedBox(width: 50),
        
        // 拖拽目标
        DragTarget<String>(
          // 判断是否接受
          onWillAcceptWithDetails: (details) {
            return details.data.isNotEmpty;
          },
          // 接受数据
          onAcceptWithDetails: (details) {
            print('接收到: ${details.data}');
          },
          // 构建 UI
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isHovering ? Colors.green.shade100 : Colors.grey.shade200,
                border: Border.all(
                  color: isHovering ? Colors.green : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(isHovering ? '松开放置' : '拖到这里'),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildFeedback() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('拖拽中', style: TextStyle(color: Colors.white)),
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
      ),
      child: Text('占位符', style: TextStyle(color: Colors.grey)),
    );
  }
  
  Widget _buildDraggableItem() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('拖我', style: TextStyle(color: Colors.white)),
    );
  }
}
```

### 2. 使用泛型携带复杂数据

```dart
// 定义数据模型
class DragItem {
  final String id;
  final String title;
  final String sourceList;
  
  DragItem({
    required this.id,
    required this.title,
    required this.sourceList,
  });
}

// 使用泛型
Draggable<DragItem>(
  data: DragItem(id: '1', title: '任务', sourceList: 'todo'),
  // ...
)

DragTarget<DragItem>(
  onAcceptWithDetails: (details) {
    final item = details.data;
    print('来自 ${item.sourceList} 的 ${item.title}');
  },
  // ...
)
```

### 3. 限制拖拽方向

```dart
// 只允许水平拖拽
Draggable<String>(
  axis: Axis.horizontal,
  data: '数据',
  feedback: _buildFeedback(),
  child: _buildChild(),
)

// 只允许垂直拖拽
Draggable<String>(
  axis: Axis.vertical,
  data: '数据',
  feedback: _buildFeedback(),
  child: _buildChild(),
)
```

### 4. 自定义拖拽锚点

```dart
Draggable<String>(
  data: '数据',
  // 使用指针锚点策略，feedback 左上角跟随手指
  dragAnchorStrategy: pointerDragAnchorStrategy,
  // 或自定义偏移
  feedbackOffset: Offset(-20, -20),
  feedback: _buildFeedback(),
  child: _buildChild(),
)
```

### 5. 监听拖拽状态

```dart
Draggable<String>(
  data: '数据',
  onDragStarted: () {
    print('开始拖拽');
    // 可以触发震动反馈
    HapticFeedback.mediumImpact();
  },
  onDragUpdate: (details) {
    print('当前位置: ${details.globalPosition}');
  },
  onDragEnd: (details) {
    print('拖拽结束，是否被接受: ${details.wasAccepted}');
  },
  onDragCompleted: () {
    print('拖拽成功完成');
  },
  onDraggableCanceled: (velocity, offset) {
    print('拖拽取消，速度: $velocity, 位置: $offset');
  },
  feedback: _buildFeedback(),
  child: _buildChild(),
)
```

## 相关组件

- [DragTarget](./dragtarget.md) - 拖拽目标，接收 Draggable 释放的数据
- [LongPressDraggable](./longpressdraggable.md) - 长按后才能拖拽的组件
- [ReorderableListView](../scrolling/reorderablelistview.md) - 内置拖拽排序功能的列表
