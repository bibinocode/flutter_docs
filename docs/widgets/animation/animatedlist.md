# AnimatedList

AnimatedList 是一个支持插入和删除动画的列表组件，当列表项增加或删除时会自动执行动画效果。

## 基本用法

```dart
AnimatedList(
  key: _listKey,
  initialItemCount: _items.length,
  itemBuilder: (context, index, animation) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1, 0), end: Offset.zero),
      ),
      child: ListTile(title: Text(_items[index])),
    );
  },
)
```

## 构造函数

```dart
const AnimatedList({
  super.key,
  required this.itemBuilder,        // 列表项构建器
  this.initialItemCount = 0,        // 初始项数量
  this.scrollDirection = Axis.vertical, // 滚动方向
  this.reverse = false,             // 是否反向
  this.controller,                  // 滚动控制器
  this.primary,                     // 是否是主滚动视图
  this.physics,                     // 滚动物理效果
  this.shrinkWrap = false,          // 是否收缩包裹
  this.padding,                     // 内边距
  this.clipBehavior = Clip.hardEdge,
})
```

## 核心概念

### GlobalKey

必须使用 `GlobalKey<AnimatedListState>` 来操作列表：

```dart
final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
```

### 插入项

```dart
void _insertItem(int index, String item) {
  _items.insert(index, item);
  _listKey.currentState?.insertItem(
    index,
    duration: const Duration(milliseconds: 300),
  );
}
```

### 删除项

```dart
void _removeItem(int index) {
  final removedItem = _items.removeAt(index);
  _listKey.currentState?.removeItem(
    index,
    (context, animation) => _buildRemovedItem(removedItem, animation),
    duration: const Duration(milliseconds: 300),
  );
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class AnimatedListDemo extends StatefulWidget {
  const AnimatedListDemo({super.key});

  @override
  State<AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _items = ['项目 1', '项目 2', '项目 3'];
  int _counter = 3;

  // 插入项
  void _addItem() {
    _counter++;
    final index = _items.length;
    _items.add('项目 $_counter');
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 300),
    );
  }

  // 删除项
  void _removeItem(int index) {
    final removedItem = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedItem, animation, removing: true),
      duration: const Duration(milliseconds: 300),
    );
  }

  // 构建列表项
  Widget _buildItem(String item, Animation<double> animation, {bool removing = false}) {
    return SizeTransition(
      sizeFactor: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(
            begin: Offset(removing ? -1 : 1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: removing ? null : () {
                final index = _items.indexOf(item);
                if (index != -1) _removeItem(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedList'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _items.length,
        padding: const EdgeInsets.only(top: 8),
        itemBuilder: (context, index, animation) {
          return _buildItem(_items[index], animation);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## 不同的动画效果

### 淡入淡出

```dart
Widget _buildFadeItem(String item, Animation<double> animation) {
  return FadeTransition(
    opacity: animation,
    child: ListTile(title: Text(item)),
  );
}
```

### 缩放效果

```dart
Widget _buildScaleItem(String item, Animation<double> animation) {
  return ScaleTransition(
    scale: animation,
    child: ListTile(title: Text(item)),
  );
}
```

### 组合动画

```dart
Widget _buildCombinedItem(String item, Animation<double> animation) {
  return FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: ListTile(title: Text(item)),
      ),
    ),
  );
}
```

## 在指定位置插入

```dart
void _insertAtIndex(int index, String item) {
  if (index < 0) index = 0;
  if (index > _items.length) index = _items.length;
  
  _items.insert(index, item);
  _listKey.currentState?.insertItem(index);
}

// 在开头插入
void _insertAtBeginning(String item) {
  _insertAtIndex(0, item);
}

// 在中间插入
void _insertInMiddle(String item) {
  _insertAtIndex(_items.length ~/ 2, item);
}
```

## SliverAnimatedList

在 CustomScrollView 中使用：

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: const Text('SliverAnimatedList'),
      floating: true,
    ),
    SliverAnimatedList(
      key: _sliverListKey,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: ListTile(title: Text(_items[index])),
        );
      },
    ),
  ],
)
```

## 带分隔线的列表

```dart
Widget _buildItemWithDivider(String item, Animation<double> animation, int index) {
  return SizeTransition(
    sizeFactor: animation,
    child: Column(
      children: [
        ListTile(
          title: Text(item),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeItem(index),
          ),
        ),
        const Divider(height: 1),
      ],
    ),
  );
}
```

## 批量操作

```dart
// 批量插入
void _insertMultiple(List<String> items) {
  for (var i = 0; i < items.length; i++) {
    Future.delayed(Duration(milliseconds: 100 * i), () {
      final index = _items.length;
      _items.add(items[i]);
      _listKey.currentState?.insertItem(index);
    });
  }
}

// 清空列表（带动画）
void _clearAll() {
  for (var i = _items.length - 1; i >= 0; i--) {
    Future.delayed(Duration(milliseconds: 50 * (_items.length - 1 - i)), () {
      if (_items.isNotEmpty) {
        _removeItem(_items.length - 1);
      }
    });
  }
}
```

## 注意事项

::: warning 重要
1. 删除项时，必须在 `removeItem` 回调中构建被删除项的 UI
2. 不要在动画进行时直接修改 `_items` 列表
3. 删除和插入操作应确保索引有效
:::

## 相关组件

- [ListView](../scrolling/listview.md) - 基础列表
- [AnimatedSwitcher](./animatedswitcher.md) - 组件切换动画
- [SlideTransition](./slidetransition.md) - 滑动过渡
