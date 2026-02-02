# DragTarget

`DragTarget` 是 Flutter 中用于接收拖拽数据的目标区域组件。它与 `Draggable` 配合使用，可以实现拖放交互功能，如拖拽删除、拖拽排序、拖拽到购物车等场景。

## 基本用法

```dart
DragTarget<String>(
  builder: (context, candidateData, rejectedData) {
    return Container(
      width: 200,
      height: 200,
      color: candidateData.isNotEmpty ? Colors.green : Colors.grey,
      child: Center(
        child: Text('拖到这里'),
      ),
    );
  },
  onAcceptWithDetails: (details) {
    print('接收到数据: ${details.data}');
  },
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `builder` | `DragTargetBuilder<T>` | 构建目标区域的 Widget，必需参数 |
| `onWillAcceptWithDetails` | `DragTargetWillAcceptWithDetails<T>?` | 判断是否接受拖入的数据，返回 `bool` |
| `onAcceptWithDetails` | `DragTargetAcceptWithDetails<T>?` | 接受数据时的回调，提供详细信息 |
| `onLeave` | `DragTargetLeave<T>?` | 拖拽项离开目标区域时的回调 |
| `onMove` | `DragTargetMove<T>?` | 拖拽项在目标区域内移动时的回调 |
| `hitTestBehavior` | `HitTestBehavior` | 命中测试行为，默认 `HitTestBehavior.translucent` |

### builder 参数说明

`builder` 是一个函数，接收三个参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| `context` | `BuildContext` | 构建上下文 |
| `candidateData` | `List<T?>` | 当前悬停在目标上且被接受的数据列表 |
| `rejectedData` | `List<dynamic>` | 当前悬停在目标上但被拒绝的数据列表 |

```dart
builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
  final isHovering = candidateData.isNotEmpty;
  final isRejected = rejectedData.isNotEmpty;
  
  return Container(
    color: isHovering ? Colors.green : (isRejected ? Colors.red : Colors.grey),
    child: Text('目标区域'),
  );
}
```

### HitTestBehavior 枚举

| 值 | 说明 |
|------|------|
| `deferToChild` | 只有子组件区域响应点击 |
| `opaque` | 不透明区域响应点击，阻止事件传递 |
| `translucent` | 默认值，透明区域也响应点击 |

## 使用场景

### 1. 购物车拖入

```dart
class ShoppingCartExample extends StatefulWidget {
  @override
  State<ShoppingCartExample> createState() => _ShoppingCartExampleState();
}

class _ShoppingCartExampleState extends State<ShoppingCartExample> {
  final List<String> _products = ['iPhone', 'MacBook', 'iPad', 'AirPods'];
  final List<String> _cart = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 商品列表
        Wrap(
          spacing: 10,
          children: _products.map((product) {
            return Draggable<String>(
              data: product,
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue,
                  child: Text(product, style: TextStyle(color: Colors.white)),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: _buildProductCard(product),
              ),
              child: _buildProductCard(product),
            );
          }).toList(),
        ),
        SizedBox(height: 40),
        // 购物车目标
        DragTarget<String>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty 
                    ? Colors.green.shade100 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: candidateData.isNotEmpty ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 40),
                  Text('购物车 (${_cart.length} 件)'),
                  if (_cart.isNotEmpty)
                    Text(_cart.join(', '), style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
          onWillAcceptWithDetails: (details) {
            // 可以添加条件判断是否接受
            return true;
          },
          onAcceptWithDetails: (details) {
            setState(() {
              _cart.add(details.data);
            });
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(String product) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(product),
    );
  }
}
```

### 2. 垃圾桶删除

```dart
class DeleteExample extends StatefulWidget {
  @override
  State<DeleteExample> createState() => _DeleteExampleState();
}

class _DeleteExampleState extends State<DeleteExample> {
  List<String> _items = ['任务 1', '任务 2', '任务 3', '任务 4'];
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 任务列表
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Draggable<int>(
                data: index,
                feedback: Material(
                  elevation: 8,
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.all(16),
                    color: Colors.red.shade100,
                    child: Text(item),
                  ),
                ),
                childWhenDragging: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item, style: TextStyle(color: Colors.grey)),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.drag_handle),
                      SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // 删除区域
        DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: _isHovering ? 100 : 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isHovering ? Colors.red : Colors.red.shade100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete,
                    size: _isHovering ? 40 : 32,
                    color: _isHovering ? Colors.white : Colors.red,
                  ),
                  Text(
                    '拖到这里删除',
                    style: TextStyle(
                      color: _isHovering ? Colors.white : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
          onWillAcceptWithDetails: (details) {
            setState(() => _isHovering = true);
            return true;
          },
          onLeave: (data) {
            setState(() => _isHovering = false);
          },
          onAcceptWithDetails: (details) {
            setState(() {
              _isHovering = false;
              _items.removeAt(details.data);
            });
          },
        ),
      ],
    );
  }
}
```

### 3. 看板列（Kanban）

```dart
class KanbanExample extends StatefulWidget {
  @override
  State<KanbanExample> createState() => _KanbanExampleState();
}

class _KanbanExampleState extends State<KanbanExample> {
  Map<String, List<String>> _columns = {
    '待办': ['设计界面', '编写文档'],
    '进行中': ['开发功能'],
    '已完成': ['需求分析'],
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _columns.keys.map((columnName) {
        return Expanded(
          child: _buildColumn(columnName, _columns[columnName]!),
        );
      }).toList(),
    );
  }

  Widget _buildColumn(String name, List<String> tasks) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? Colors.blue.shade50 
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...tasks.map((task) => _buildTaskCard(task, name)).toList(),
            ],
          ),
        );
      },
      onWillAcceptWithDetails: (details) {
        // 不接受来自同一列的拖拽
        return details.data['from'] != name;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          final task = details.data['task'] as String;
          final from = details.data['from'] as String;
          _columns[from]!.remove(task);
          _columns[name]!.add(task);
        });
      },
    );
  }

  Widget _buildTaskCard(String task, String column) {
    return Draggable<Map<String, dynamic>>(
      data: {'task': task, 'from': column},
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 150,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(task),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCard(task),
      ),
      child: _buildCard(task),
    );
  }

  Widget _buildCard(String task) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Text(task),
    );
  }
}
```

### 4. 文件夹拖入

```dart
class FolderDropExample extends StatefulWidget {
  @override
  State<FolderDropExample> createState() => _FolderDropExampleState();
}

class _FolderDropExampleState extends State<FolderDropExample> {
  final Map<String, List<String>> _folders = {
    '文档': [],
    '图片': [],
    '视频': [],
  };
  
  final List<Map<String, String>> _files = [
    {'name': '报告.pdf', 'type': '文档'},
    {'name': '照片.jpg', 'type': '图片'},
    {'name': '电影.mp4', 'type': '视频'},
    {'name': '笔记.txt', 'type': '文档'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 文件列表
        Wrap(
          spacing: 10,
          children: _files.map((file) {
            return Draggable<Map<String, String>>(
              data: file,
              feedback: Material(
                elevation: 4,
                child: _buildFileIcon(file, dragging: true),
              ),
              child: _buildFileIcon(file),
            );
          }).toList(),
        ),
        SizedBox(height: 40),
        // 文件夹
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _folders.keys.map((folder) {
            return DragTarget<Map<String, String>>(
              builder: (context, candidateData, rejectedData) {
                final isAccepting = candidateData.isNotEmpty;
                final isRejecting = rejectedData.isNotEmpty;
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isAccepting 
                        ? Colors.green.shade100 
                        : (isRejecting ? Colors.red.shade100 : Colors.amber.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAccepting ? Colors.green : Colors.amber,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder, size: 40, color: Colors.amber),
                      Text(folder),
                      Text('${_folders[folder]!.length} 个文件', 
                           style: TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
              onWillAcceptWithDetails: (details) {
                // 只接受匹配类型的文件
                return details.data['type'] == folder;
              },
              onAcceptWithDetails: (details) {
                setState(() {
                  _folders[folder]!.add(details.data['name']!);
                  _files.remove(details.data);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileIcon(Map<String, String> file, {bool dragging = false}) {
    IconData icon;
    switch (file['type']) {
      case '文档':
        icon = Icons.description;
        break;
      case '图片':
        icon = Icons.image;
        break;
      case '视频':
        icon = Icons.movie;
        break;
      default:
        icon = Icons.insert_drive_file;
    }
    return Container(
      width: 80,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: dragging ? Colors.blue.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: dragging ? [BoxShadow(blurRadius: 8)] : null,
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          Text(file['name']!, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
```

## 完整示例：拖拽删除

```dart
import 'package:flutter/material.dart';

class DragToDeleteDemo extends StatefulWidget {
  const DragToDeleteDemo({super.key});

  @override
  State<DragToDeleteDemo> createState() => _DragToDeleteDemoState();
}

class _DragToDeleteDemoState extends State<DragToDeleteDemo> {
  List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  
  bool _isOverDelete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('拖拽删除示例')),
      body: Stack(
        children: [
          // 颜色块网格
          Padding(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _colors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                return Draggable<int>(
                  data: index,
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.drag_indicator, color: Colors.white),
                    ),
                  ),
                  childWhenDragging: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color, style: BorderStyle.solid),
                    ),
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.drag_indicator, color: Colors.white54),
                  ),
                );
              }).toList(),
            ),
          ),
          // 底部删除区域
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: _isOverDelete ? 120 : 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _isOverDelete
                          ? [Colors.red.shade400, Colors.red.shade700]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_isOverDelete ? 30 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _isOverDelete ? 1.3 : 1.0,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          _isOverDelete ? Icons.delete_forever : Icons.delete_outline,
                          size: 36,
                          color: _isOverDelete ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _isOverDelete ? '松开删除' : '拖到这里删除',
                        style: TextStyle(
                          color: _isOverDelete ? Colors.white : Colors.grey.shade600,
                          fontWeight: _isOverDelete ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
              onWillAcceptWithDetails: (details) {
                setState(() => _isOverDelete = true);
                return true;
              },
              onLeave: (data) {
                setState(() => _isOverDelete = false);
              },
              onMove: (details) {
                // 可以根据位置调整 UI
              },
              onAcceptWithDetails: (details) {
                setState(() {
                  _isOverDelete = false;
                  _colors.removeAt(details.data);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _colors = [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.indigo,
              Colors.purple,
            ];
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

## 最佳实践

### 1. 数据类型匹配

确保 `DragTarget<T>` 的泛型类型与 `Draggable<T>` 的数据类型一致：

```dart
// ✅ 正确：类型匹配
Draggable<String>(
  data: 'item',
  child: ...,
)

DragTarget<String>(
  builder: ...,
  onAcceptWithDetails: (details) {
    // details.data 是 String 类型
  },
)

// ❌ 错误：类型不匹配
Draggable<int>(
  data: 123,
  child: ...,
)

DragTarget<String>(  // 无法接收 int 类型数据
  builder: ...,
)
```

### 2. 使用 onWillAcceptWithDetails 进行验证

```dart
DragTarget<Map<String, dynamic>>(
  onWillAcceptWithDetails: (details) {
    // 进行业务逻辑验证
    final data = details.data;
    if (data['status'] == 'locked') {
      return false;  // 拒绝锁定的项目
    }
    if (_items.length >= 10) {
      return false;  // 拒绝超出容量
    }
    return true;
  },
  builder: (context, candidateData, rejectedData) {
    // 根据 rejectedData 显示不同的 UI 反馈
    if (rejectedData.isNotEmpty) {
      return Container(color: Colors.red.shade100, child: Text('无法放置'));
    }
    return Container(child: Text('放置区域'));
  },
)
```

### 3. 提供视觉反馈

```dart
DragTarget<String>(
  builder: (context, candidateData, rejectedData) {
    Color backgroundColor;
    String hint;
    
    if (candidateData.isNotEmpty) {
      backgroundColor = Colors.green.shade100;
      hint = '松开放置';
    } else if (rejectedData.isNotEmpty) {
      backgroundColor = Colors.red.shade100;
      hint = '无法放置此项';
    } else {
      backgroundColor = Colors.grey.shade100;
      hint = '拖放到这里';
    }
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      color: backgroundColor,
      child: Center(child: Text(hint)),
    );
  },
)
```

### 4. 处理复杂数据结构

```dart
// 定义数据模型
class DragItem {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  
  DragItem({required this.id, required this.type, required this.data});
}

// 使用模型
DragTarget<DragItem>(
  onWillAcceptWithDetails: (details) {
    return details.data.type == 'allowed_type';
  },
  onAcceptWithDetails: (details) {
    final item = details.data;
    print('接收: ${item.id}, 位置: ${details.offset}');
  },
)
```

## 相关组件

- [Draggable](./draggable.md) - 可拖拽的组件，与 DragTarget 配合使用
- [LongPressDraggable](./longpressdraggable.md) - 长按后可拖拽的组件
- [DraggableScrollableSheet](../scrolling/draggablescrollablesheet.md) - 可拖拽的底部弹出面板
- [ReorderableListView](../scrolling/reorderablelistview.md) - 可重新排序的列表视图
