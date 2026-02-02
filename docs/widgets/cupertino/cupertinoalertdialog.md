# CupertinoAlertDialog

`CupertinoAlertDialog` 是 iOS 风格的警告对话框组件，遵循 Apple Human Interface Guidelines。它通常用于向用户展示重要信息、请求确认或提供选择，具有毛玻璃背景效果和圆角设计。

## 基本用法

```dart
showCupertinoDialog(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: Text('提示'),
    content: Text('这是一条提示信息'),
    actions: [
      CupertinoDialogAction(
        child: Text('确定'),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  ),
);
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `title` | `Widget?` | 对话框标题，通常是 Text 组件 |
| `content` | `Widget?` | 对话框内容，可以是任意 Widget |
| `actions` | `List<Widget>` | 操作按钮列表，通常使用 CupertinoDialogAction |
| `scrollController` | `ScrollController?` | 内容区域的滚动控制器 |
| `actionScrollController` | `ScrollController?` | 按钮区域的滚动控制器（当按钮过多时） |
| `insetAnimationDuration` | `Duration` | 键盘弹出时的动画时长（默认 100ms） |
| `insetAnimationCurve` | `Curve` | 键盘弹出时的动画曲线（默认 decelerate） |

## CupertinoDialogAction 属性

`CupertinoDialogAction` 是专门用于 `CupertinoAlertDialog` 的按钮组件。

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget` | 按钮内容，通常是 Text |
| `onPressed` | `VoidCallback?` | 点击回调，为 null 时按钮禁用 |
| `isDefaultAction` | `bool` | 是否为默认操作（文字加粗），默认 false |
| `isDestructiveAction` | `bool` | 是否为破坏性操作（文字红色），默认 false |
| `textStyle` | `TextStyle?` | 自定义文字样式 |

## 使用场景

### 1. 简单确认对话框

```dart
import 'package:flutter/cupertino.dart';

class SimpleConfirmDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('简单确认'),
      ),
      child: Center(
        child: CupertinoButton.filled(
          onPressed: () => _showConfirmDialog(context),
          child: Text('显示对话框'),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('更新可用'),
        content: Text('新版本已发布，是否立即更新？'),
        actions: [
          CupertinoDialogAction(
            child: Text('稍后'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('更新'),
            onPressed: () {
              Navigator.pop(context);
              // 执行更新操作
            },
          ),
        ],
      ),
    );
  }
}
```

### 2. 删除警告（红色按钮）

```dart
class DeleteWarningDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('删除警告'),
      ),
      child: Center(
        child: CupertinoButton(
          onPressed: () => _showDeleteDialog(context),
          child: Text(
            '删除文件',
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('删除文件'),
        content: Text('此操作无法撤销，确定要删除这个文件吗？'),
        actions: [
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('删除'),
            onPressed: () {
              Navigator.pop(context);
              // 执行删除操作
            },
          ),
        ],
      ),
    );
  }
}
```

### 3. 带输入框的对话框

```dart
class InputDialogDemo extends StatefulWidget {
  @override
  State<InputDialogDemo> createState() => _InputDialogDemoState();
}

class _InputDialogDemoState extends State<InputDialogDemo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('输入对话框'),
      ),
      child: Center(
        child: CupertinoButton.filled(
          onPressed: () => _showInputDialog(context),
          child: Text('新建文件夹'),
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    _controller.clear();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('新建文件夹'),
        content: Padding(
          padding: EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: '请输入文件夹名称',
            autofocus: true,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('创建'),
            onPressed: () {
              final name = _controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                // 创建文件夹
                print('创建文件夹: $name');
              }
            },
          ),
        ],
      ),
    );
  }
}
```

### 4. 多个选项对话框

```dart
class MultipleOptionsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('多选项'),
      ),
      child: Center(
        child: CupertinoButton.filled(
          onPressed: () => _showOptionsDialog(context),
          child: Text('保存文档'),
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('保存更改'),
        content: Text('您有未保存的更改，是否保存？'),
        actions: [
          CupertinoDialogAction(
            child: Text('不保存'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              // 不保存直接退出
            },
          ),
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('保存'),
            onPressed: () {
              Navigator.pop(context);
              // 保存并退出
            },
          ),
        ],
      ),
    );
  }
}
```

## 完整示例：退出登录确认

```dart
import 'package:flutter/cupertino.dart';

class LogoutConfirmDemo extends StatefulWidget {
  @override
  State<LogoutConfirmDemo> createState() => _LogoutConfirmDemoState();
}

class _LogoutConfirmDemoState extends State<LogoutConfirmDemo> {
  bool _isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.light,
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('账户'),
          trailing: _isLoggedIn
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showLogoutDialog(context),
                  child: Text(
                    '退出',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                )
              : null,
        ),
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!_isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_circle,
              size: 80,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 20),
            Text(
              '您已退出登录',
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: () {
                setState(() {
                  _isLoggedIn = true;
                });
              },
              child: Text('重新登录'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        SizedBox(height: 40),
        // 用户头像
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              size: 60,
              color: CupertinoColors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        // 用户名
        Center(
          child: Text(
            '张三',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            'zhangsan@example.com',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        SizedBox(height: 40),
        // 设置列表
        CupertinoListSection.insetGrouped(
          children: [
            CupertinoListTile(
              leading: Icon(CupertinoIcons.person),
              title: Text('个人信息'),
              trailing: CupertinoListTileChevron(),
              onTap: () {},
            ),
            CupertinoListTile(
              leading: Icon(CupertinoIcons.bell),
              title: Text('通知设置'),
              trailing: CupertinoListTileChevron(),
              onTap: () {},
            ),
            CupertinoListTile(
              leading: Icon(CupertinoIcons.lock),
              title: Text('隐私设置'),
              trailing: CupertinoListTileChevron(),
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: 20),
        // 退出登录按钮
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: CupertinoButton(
            color: CupertinoColors.systemGrey6,
            onPressed: () => _showLogoutDialog(context),
            child: Text(
              '退出登录',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('退出登录'),
        content: Text('确定要退出当前账户吗？退出后需要重新登录才能使用完整功能。'),
        actions: [
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('退出'),
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // 模拟退出登录操作
    setState(() {
      _isLoggedIn = false;
    });
  }
}
```

## 最佳实践

1. **标题简洁明了**：标题应该简短，直接说明对话框的目的
2. **内容清晰**：内容文本应该清楚解释用户需要做出的决定
3. **按钮顺序**：
   - iOS 规范中，取消按钮通常在左侧
   - 确认/主要操作在右侧
   - 当有三个以上按钮时会垂直排列
4. **破坏性操作**：使用 `isDestructiveAction: true` 标记删除、退出等不可逆操作
5. **默认操作**：使用 `isDefaultAction: true` 标记推荐的操作（文字会加粗）
6. **避免滥用**：对话框会打断用户流程，只在必要时使用
7. **可关闭性**：考虑是否允许点击外部关闭（`barrierDismissible` 参数）
8. **键盘适配**：带输入框时，对话框会自动避开键盘

## 相关组件

- [AlertDialog](../material/alertdialog.md)：Material 风格的对话框
- [showDialog](../material/showdialog.md)：显示 Material 对话框的方法
- [CupertinoActionSheet](./cupertinoactionsheet.md)：iOS 风格的底部操作表
- [CupertinoTextField](./cupertinotextfield.md)：iOS 风格的输入框

## 官方文档

- [CupertinoAlertDialog API](https://api.flutter.dev/flutter/cupertino/CupertinoAlertDialog-class.html)
- [CupertinoDialogAction API](https://api.flutter.dev/flutter/cupertino/CupertinoDialogAction-class.html)
- [showCupertinoDialog API](https://api.flutter.dev/flutter/cupertino/showCupertinoDialog.html)
