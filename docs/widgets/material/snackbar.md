# SnackBar

`SnackBar` 是 Material Design 消息提示条组件，用于在屏幕底部显示简短的消息提示。它通常用于向用户展示操作反馈，如保存成功、删除完成等，并可以包含一个可选的操作按钮（如撤销）。

## 基本用法

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('操作已完成'),
  ),
);
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| content | Widget | 必填 | 消息内容，通常是 Text |
| action | SnackBarAction? | null | 操作按钮，如"撤销" |
| actionOverflowThreshold | double? | 0.25 | 操作按钮换行的阈值 |
| duration | Duration | 4秒 | 显示时长 |
| elevation | double? | 6.0 | 阴影高度 |
| margin | EdgeInsetsGeometry? | null | 外边距（floating 模式下有效） |
| padding | EdgeInsetsGeometry? | null | 内边距 |
| width | double? | null | 宽度（floating 模式下有效） |
| shape | ShapeBorder? | null | 形状，如圆角 |
| behavior | SnackBarBehavior? | fixed | 行为模式：fixed（固定底部）或 floating（浮动） |
| backgroundColor | Color? | 主题色 | 背景颜色 |
| closeIconColor | Color? | null | 关闭图标颜色 |
| dismissDirection | DismissDirection | down | 滑动关闭方向 |
| showCloseIcon | bool | false | 是否显示关闭图标 |
| clipBehavior | Clip | Clip.hardEdge | 裁剪行为 |
| animation | Animation\<double\>? | null | 自定义动画 |

## 使用场景

### 1. 简单提示

```dart
ElevatedButton(
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('文件已保存'),
        duration: Duration(seconds: 2),
      ),
    );
  },
  child: Text('保存文件'),
)
```

### 2. 带操作按钮（撤销）

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('邮件已删除'),
    action: SnackBarAction(
      label: '撤销',
      onPressed: () {
        // 执行撤销操作
        print('撤销删除');
      },
    ),
    duration: Duration(seconds: 5),
  ),
);
```

### 3. 浮动样式

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('这是浮动样式的 SnackBar'),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
```

### 4. 自定义样式

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text('操作成功！')),
      ],
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    showCloseIcon: true,
    closeIconColor: Colors.white,
    duration: Duration(seconds: 3),
  ),
);
```

## 完整示例

以下是一个删除操作带撤销功能的完整示例：

```dart
import 'package:flutter/material.dart';

class SnackBarDemo extends StatefulWidget {
  const SnackBarDemo({super.key});

  @override
  State<SnackBarDemo> createState() => _SnackBarDemoState();
}

class _SnackBarDemoState extends State<SnackBarDemo> {
  List<String> items = ['项目 1', '项目 2', '项目 3', '项目 4', '项目 5'];

  void _deleteItem(int index) {
    final deletedItem = items[index];
    final deletedIndex = index;

    setState(() {
      items.removeAt(index);
    });

    // 先清除之前的 SnackBar
    ScaffoldMessenger.of(context).clearSnackBars();

    // 显示带撤销的 SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除 "$deletedItem"'),
        action: SnackBarAction(
          label: '撤销',
          textColor: Colors.yellow,
          onPressed: () {
            setState(() {
              items.insert(deletedIndex, deletedItem);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SnackBar 示例'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(index),
            ),
          );
        },
      ),
    );
  }
}
```

## 最佳实践

### ScaffoldMessenger 使用方式

Flutter 2.0 引入了 `ScaffoldMessenger`，推荐使用它来显示 SnackBar：

```dart
// ✅ 推荐方式：使用 ScaffoldMessenger
ScaffoldMessenger.of(context).showSnackBar(snackBar);

// ❌ 已废弃：直接使用 Scaffold
Scaffold.of(context).showSnackBar(snackBar);  // 已废弃
```

### 管理多个 SnackBar

```dart
// 清除当前显示的 SnackBar
ScaffoldMessenger.of(context).clearSnackBars();

// 移除当前 SnackBar
ScaffoldMessenger.of(context).removeCurrentSnackBar();

// 隐藏当前 SnackBar（带动画）
ScaffoldMessenger.of(context).hideCurrentSnackBar();
```

### 全局 SnackBar

在 `MaterialApp` 中设置 `scaffoldMessengerKey`，实现全局调用：

```dart
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

MaterialApp(
  scaffoldMessengerKey: scaffoldMessengerKey,
  home: MyHomePage(),
);

// 在任意位置调用
scaffoldMessengerKey.currentState?.showSnackBar(
  SnackBar(content: Text('全局消息')),
);
```

### 注意事项

1. **显示时机**：确保在 Scaffold 上下文中调用
2. **避免堆叠**：显示新 SnackBar 前调用 `clearSnackBars()`
3. **时长控制**：重要操作（如撤销）使用较长的 duration
4. **无障碍**：SnackBar 自动支持屏幕阅读器

## 相关组件

- [MaterialBanner](./materialbanner.md) - 页面顶部的持久性消息提示
- [AlertDialog](./alertdialog.md) - 需要用户确认的对话框
- [Toast](https://pub.dev/packages/fluttertoast) - 第三方轻量级提示（不阻塞交互）

## 官方文档

- [SnackBar API](https://api.flutter.dev/flutter/material/SnackBar-class.html)
