# Dialog 对话框

对话框是 Flutter 中用于与用户进行重要交互的模态组件。Flutter 提供了多种对话框类型，包括 `AlertDialog`、`SimpleDialog` 和基础 `Dialog`，满足不同的使用场景。

## 对话框类型介绍

### AlertDialog

`AlertDialog` 是最常用的对话框类型，用于向用户显示警告信息或需要用户确认的操作。它通常包含标题、内容和操作按钮。

```dart
AlertDialog(
  title: Text('提示'),
  content: Text('确定要执行此操作吗？'),
  actions: [
    TextButton(onPressed: () {}, child: Text('取消')),
    TextButton(onPressed: () {}, child: Text('确定')),
  ],
)
```

### SimpleDialog

`SimpleDialog` 用于显示一个简单的选项列表，让用户从中选择。

```dart
SimpleDialog(
  title: Text('选择一个选项'),
  children: [
    SimpleDialogOption(
      onPressed: () {},
      child: Text('选项 1'),
    ),
    SimpleDialogOption(
      onPressed: () {},
      child: Text('选项 2'),
    ),
  ],
)
```

### Dialog

`Dialog` 是最基础的对话框组件，提供了完全自定义的能力。

```dart
Dialog(
  child: Container(
    padding: EdgeInsets.all(20),
    child: Text('自定义内容'),
  ),
)
```

## showDialog 函数

`showDialog` 是显示对话框的核心函数，它返回一个 `Future`，可以获取对话框的返回值。

```dart
Future<T?> showDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
})
```

### 主要参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| context | BuildContext | 必需 | 构建上下文 |
| builder | WidgetBuilder | 必需 | 构建对话框的函数 |
| barrierDismissible | bool | true | 点击遮罩是否关闭对话框 |
| barrierColor | Color? | Colors.black54 | 遮罩颜色 |
| useSafeArea | bool | true | 是否避开系统 UI 区域 |
| useRootNavigator | bool | true | 是否使用根导航器 |

## AlertDialog 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| title | Widget? | 对话框标题 |
| titlePadding | EdgeInsetsGeometry? | 标题内边距 |
| titleTextStyle | TextStyle? | 标题文本样式 |
| content | Widget? | 对话框内容 |
| contentPadding | EdgeInsetsGeometry | 内容内边距，默认 `EdgeInsets.fromLTRB(24, 20, 24, 24)` |
| contentTextStyle | TextStyle? | 内容文本样式 |
| actions | List\<Widget\>? | 操作按钮列表 |
| actionsPadding | EdgeInsetsGeometry | 操作区域内边距 |
| actionsAlignment | MainAxisAlignment? | 操作按钮对齐方式 |
| actionsOverflowAlignment | OverflowBarAlignment? | 按钮溢出时的对齐方式 |
| actionsOverflowDirection | VerticalDirection? | 按钮溢出时的排列方向 |
| actionsOverflowButtonSpacing | double? | 溢出时按钮间距 |
| buttonPadding | EdgeInsetsGeometry? | 按钮内边距 |
| backgroundColor | Color? | 背景颜色 |
| elevation | double? | 阴影高度 |
| shadowColor | Color? | 阴影颜色 |
| surfaceTintColor | Color? | 表面着色 |
| semanticLabel | String? | 无障碍标签 |
| insetPadding | EdgeInsets | 对话框与屏幕边缘的距离 |
| clipBehavior | Clip | 裁剪行为，默认 `Clip.none` |
| shape | ShapeBorder? | 对话框形状 |
| alignment | AlignmentGeometry? | 对话框对齐方式 |
| scrollable | bool | 内容是否可滚动，默认 false |
| icon | Widget? | 图标 |
| iconPadding | EdgeInsetsGeometry? | 图标内边距 |
| iconColor | Color? | 图标颜色 |

## 使用场景代码示例

### 1. 确认对话框

最常见的使用场景，用于确认用户操作。

```dart
class ConfirmDialogDemo extends StatelessWidget {
  const ConfirmDialogDemo({super.key});

  Future<void> _showConfirmDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
          title: const Text('确认删除'),
          content: const Text('此操作将永久删除该文件，删除后无法恢复。确定要继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // 执行删除操作
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('文件已删除')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('确认对话框')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showConfirmDialog(context),
          child: const Text('删除文件'),
        ),
      ),
    );
  }
}
```

### 2. 带输入框的对话框

用于收集用户输入，如修改名称、添加备注等。

```dart
class InputDialogDemo extends StatelessWidget {
  const InputDialogDemo({super.key});

  Future<void> _showInputDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    
    final String? result = await showDialog<String>(
      context: context,
      barrierDismissible: false, // 防止误触关闭
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('重命名文件'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '请输入新名称',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('新名称: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('输入对话框')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showInputDialog(context),
          child: const Text('重命名'),
        ),
      ),
    );
  }
}
```

### 3. 列表选择对话框

使用 `SimpleDialog` 提供选项列表供用户选择。

```dart
class ListDialogDemo extends StatefulWidget {
  const ListDialogDemo({super.key});

  @override
  State<ListDialogDemo> createState() => _ListDialogDemoState();
}

class _ListDialogDemoState extends State<ListDialogDemo> {
  String _selectedLanguage = 'Dart';

  final List<Map<String, dynamic>> _languages = [
    {'name': 'Dart', 'icon': Icons.flutter_dash},
    {'name': 'Kotlin', 'icon': Icons.android},
    {'name': 'Swift', 'icon': Icons.apple},
    {'name': 'JavaScript', 'icon': Icons.javascript},
    {'name': 'Python', 'icon': Icons.code},
  ];

  Future<void> _showLanguageDialog() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('选择编程语言'),
          children: _languages.map((lang) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, lang['name']),
              child: ListTile(
                leading: Icon(lang['icon']),
                title: Text(lang['name']),
                trailing: _selectedLanguage == lang['name']
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );

    if (result != null) {
      setState(() => _selectedLanguage = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('列表选择对话框')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('当前选择: $_selectedLanguage', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showLanguageDialog,
              child: const Text('选择语言'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. 自定义对话框

使用基础 `Dialog` 组件创建完全自定义的对话框样式。

```dart
class CustomDialogDemo extends StatelessWidget {
  const CustomDialogDemo({super.key});

  Future<void> _showCustomDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 自定义头像
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                // 标题
                const Text(
                  '欢迎回来！',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // 副标题
                Text(
                  '您已成功登录',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // 信息卡片
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('您有 3 条新消息待查看'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 按钮
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('开始使用'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义对话框')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showCustomDialog(context),
          child: const Text('显示欢迎对话框'),
        ),
      ),
    );
  }
}
```

### 5. 全屏对话框

适用于需要大量内容展示或复杂表单的场景。

```dart
class FullScreenDialogDemo extends StatelessWidget {
  const FullScreenDialogDemo({super.key});

  void _showFullScreenDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return const _FullScreenDialogContent();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('全屏对话框')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showFullScreenDialog(context),
          child: const Text('创建新事件'),
        ),
      ),
    );
  }
}

class _FullScreenDialogContent extends StatefulWidget {
  const _FullScreenDialogContent();

  @override
  State<_FullScreenDialogContent> createState() => _FullScreenDialogContentState();
}

class _FullScreenDialogContentState extends State<_FullScreenDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('事件已创建')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建事件'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '事件标题',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: '事件描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('选择日期'),
              subtitle: Text('${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 对话框返回值处理

对话框通过 `Navigator.pop()` 返回值，调用方使用 `await` 获取结果。

```dart
// 定义返回值类型
enum DialogAction { save, discard, cancel }

Future<void> handleUnsavedChanges(BuildContext context) async {
  final DialogAction? action = await showDialog<DialogAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('未保存的更改'),
      content: const Text('您有未保存的更改，要如何处理？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, DialogAction.cancel),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, DialogAction.discard),
          child: const Text('放弃'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, DialogAction.save),
          child: const Text('保存'),
        ),
      ],
    ),
  );

  // 根据返回值执行不同操作
  switch (action) {
    case DialogAction.save:
      await saveData();
      navigateAway();
      break;
    case DialogAction.discard:
      navigateAway();
      break;
    case DialogAction.cancel:
    case null:
      // 用户取消或点击了遮罩，不做任何操作
      break;
  }
}
```

### 处理 null 返回值

当用户点击遮罩关闭对话框或按返回键时，返回值为 `null`。

```dart
final result = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('确认'),
    content: const Text('是否继续？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('否'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('是'),
      ),
    ],
  ),
);

// 安全处理返回值
if (result == true) {
  // 用户明确点击了"是"
  doSomething();
}
```

## 最佳实践

### 1. 设置 barrierDismissible

对于重要操作，应禁止点击遮罩关闭对话框：

```dart
showDialog(
  context: context,
  barrierDismissible: false, // 必须通过按钮关闭
  builder: (context) => AlertDialog(...),
);
```

### 2. 使用恰当的对话框类型

- **AlertDialog**：确认操作、显示警告信息
- **SimpleDialog**：简单的选项选择
- **Dialog**：完全自定义的复杂布局
- **全屏对话框**：复杂表单、详细内容展示

### 3. 保持内容简洁

对话框应聚焦于单一任务，避免包含过多内容：

```dart
// ✅ 好的做法：内容简洁明了
AlertDialog(
  title: const Text('删除文件'),
  content: const Text('确定要删除这个文件吗？'),
  actions: [...],
)

// ❌ 避免：内容过于复杂
AlertDialog(
  title: const Text('文件操作'),
  content: Column(
    children: [
      // 过多的选项和信息...
    ],
  ),
)
```

### 4. 按钮顺序和样式

- 取消/否定操作放在左边，使用 `TextButton`
- 确认/肯定操作放在右边，使用 `FilledButton` 或 `TextButton`
- 危险操作使用红色强调

```dart
actions: [
  TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('取消'),
  ),
  FilledButton(
    onPressed: () => Navigator.pop(context, true),
    child: const Text('确认'),
  ),
],
```

### 5. 处理 WillPopScope / PopScope

防止用户通过系统返回键意外关闭对话框：

```dart
showDialog(
  context: context,
  builder: (context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      // 可以在这里显示提示或执行自定义逻辑
    },
    child: AlertDialog(...),
  ),
);
```

### 6. 响应式设计

对于宽屏设备，限制对话框宽度：

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 24,
    ),
    // 或使用 ConstrainedBox 限制最大宽度
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Text('内容'),
    ),
  ),
);
```

## 相关组件

- [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html) - 警告对话框
- [SimpleDialog](https://api.flutter.dev/flutter/material/SimpleDialog-class.html) - 简单选择对话框
- [showModalBottomSheet](./bottomsheet.md) - 底部弹出面板
- [SnackBar](./snackbar.md) - 轻量级消息提示
- [PopupMenuButton](./popupmenu.md) - 弹出菜单

## 官方文档

- [Dialog API](https://api.flutter.dev/flutter/material/Dialog-class.html)
- [AlertDialog API](https://api.flutter.dev/flutter/material/AlertDialog-class.html)
- [SimpleDialog API](https://api.flutter.dev/flutter/material/SimpleDialog-class.html)
- [showDialog 函数](https://api.flutter.dev/flutter/material/showDialog.html)
