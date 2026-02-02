# CupertinoActionSheet

`CupertinoActionSheet` 是 iOS 风格的操作表单组件，从屏幕底部弹出，用于向用户展示一组可选操作。它模拟了 iOS 原生的 UIAlertController（actionSheet 样式），通常用于让用户在多个操作中进行选择，如分享、删除确认、选择图片来源等场景。

## 基本用法

```dart
showCupertinoModalPopup(
  context: context,
  builder: (context) => CupertinoActionSheet(
    title: Text('选择操作'),
    message: Text('请选择要执行的操作'),
    actions: [
      CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'action1'),
        child: Text('操作一'),
      ),
      CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'action2'),
        child: Text('操作二'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      onPressed: () => Navigator.pop(context),
      child: Text('取消'),
    ),
  ),
);
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `title` | `Widget?` | 操作表单的标题，通常是一个 Text 组件 |
| `message` | `Widget?` | 操作表单的描述信息，显示在标题下方 |
| `actions` | `List<Widget>` | 操作按钮列表，通常使用 CupertinoActionSheetAction |
| `messageScrollController` | `ScrollController?` | 消息区域的滚动控制器（消息过长时可滚动） |
| `actionScrollController` | `ScrollController?` | 操作按钮区域的滚动控制器（按钮过多时可滚动） |
| `cancelButton` | `Widget?` | 取消按钮，显示在操作表单底部，与其他按钮分隔 |

## CupertinoActionSheetAction

`CupertinoActionSheetAction` 是专门用于 `CupertinoActionSheet` 的操作按钮组件。

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget` | 按钮内容，通常是一个 Text 组件 |
| `onPressed` | `VoidCallback` | 按钮点击回调（必需） |
| `isDefaultAction` | `bool` | 是否为默认操作（文字加粗），默认 false |
| `isDestructiveAction` | `bool` | 是否为破坏性操作（文字红色），默认 false |

## 使用场景

### 1. 基本操作表单

```dart
class BasicActionSheetDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Text('显示操作表单'),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  print('选择了编辑');
                },
                child: Text('编辑'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  print('选择了复制');
                },
                child: Text('复制'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  print('选择了移动');
                },
                child: Text('移动'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
          ),
        );
      },
    );
  }
}
```

### 2. 带标题和消息

```dart
void _showActionSheetWithTitleAndMessage(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text('选择联系方式'),
      message: Text('请选择您希望使用的联系方式与我们取得联系'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // 拨打电话
          },
          child: Text('拨打电话'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // 发送邮件
          },
          child: Text('发送邮件'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // 发送短信
          },
          child: Text('发送短信'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text('取消'),
      ),
    ),
  );
}
```

### 3. 删除确认（红色破坏性操作）

```dart
void _showDeleteConfirmation(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text('删除文件'),
      message: Text('此操作不可恢复，确定要删除这个文件吗？'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // 执行删除操作
            _deleteFile();
          },
          isDestructiveAction: true, // 红色文字
          child: Text('删除'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        isDefaultAction: true, // 加粗显示
        child: Text('取消'),
      ),
    ),
  );
}

void _deleteFile() {
  print('文件已删除');
}
```

### 4. 图片选择来源

```dart
void _showImageSourcePicker(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text('选择图片'),
      message: Text('请选择图片来源'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _pickImageFromCamera();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.camera, size: 20),
              SizedBox(width: 8),
              Text('拍摄照片'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _pickImageFromGallery();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.photo, size: 20),
              SizedBox(width: 8),
              Text('从相册选择'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _pickImageFromFiles();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.folder, size: 20),
              SizedBox(width: 8),
              Text('从文件选择'),
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text('取消'),
      ),
    ),
  );
}

void _pickImageFromCamera() => print('打开相机');
void _pickImageFromGallery() => print('打开相册');
void _pickImageFromFiles() => print('打开文件');
```

## 完整示例

```dart
import 'package:flutter/cupertino.dart';

class ShareActionSheetDemo extends StatefulWidget {
  @override
  State<ShareActionSheetDemo> createState() => _ShareActionSheetDemoState();
}

class _ShareActionSheetDemoState extends State<ShareActionSheetDemo> {
  String _lastAction = '无';

  void _showShareSheet() {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('分享到'),
        message: Text('选择您想要分享的平台'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, '微信好友'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.chat_bubble_fill, 
                     color: CupertinoColors.systemGreen),
                SizedBox(width: 12),
                Text('微信好友'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, '朋友圈'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.person_2_fill,
                     color: CupertinoColors.systemGreen),
                SizedBox(width: 12),
                Text('朋友圈'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, '微博'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.globe,
                     color: CupertinoColors.systemRed),
                SizedBox(width: 12),
                Text('微博'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'QQ'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.bubble_left_bubble_right_fill,
                     color: CupertinoColors.activeBlue),
                SizedBox(width: 12),
                Text('QQ'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, '复制链接'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.link,
                     color: CupertinoColors.systemGrey),
                SizedBox(width: 12),
                Text('复制链接'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('取消'),
        ),
      ),
    ).then((value) {
      if (value != null) {
        setState(() => _lastAction = value);
        _showShareSuccess(value);
      }
    });
  }

  void _showShareSuccess(String platform) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('分享成功'),
        content: Text('已分享到$platform'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('分享操作表单示例'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('上次操作: $_lastAction'),
              SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: _showShareSheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.share),
                    SizedBox(width: 8),
                    Text('分享'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 最佳实践

1. **使用 showCupertinoModalPopup**: 始终通过 `showCupertinoModalPopup` 显示 `CupertinoActionSheet`，这会提供正确的底部弹出动画和背景遮罩
2. **提供取消按钮**: 始终提供 `cancelButton`，让用户可以安全地关闭操作表单而不执行任何操作
3. **标记破坏性操作**: 对于删除、移除等不可逆操作，使用 `isDestructiveAction: true` 使文字显示为红色
4. **标记默认操作**: 使用 `isDefaultAction: true` 为最常用或最安全的选项添加视觉强调
5. **操作数量适中**: 避免在一个操作表单中放置过多选项，建议不超过 5-6 个
6. **关闭后执行操作**: 在 `Navigator.pop()` 之后执行实际操作，或使用返回值来传递用户选择
7. **保持文案简洁**: 操作按钮的文字应简短明了，让用户快速理解操作内容
8. **iOS 风格一致性**: 在 iOS 应用中使用 `CupertinoActionSheet`，在 Material 风格应用中考虑使用 `showModalBottomSheet`

## 相关组件

- [showModalBottomSheet](../material/showmodalbottomsheet.md): Material 风格的底部弹出表单
- [BottomSheet](../material/bottomsheet.md): Material 风格的底部表单组件
- [CupertinoAlertDialog](./cupertinoalertdialog.md): iOS 风格的警告对话框
- [CupertinoContextMenu](./cupertinocontextmenu.md): iOS 风格的上下文菜单

## 官方文档

- [CupertinoActionSheet API](https://api.flutter.dev/flutter/cupertino/CupertinoActionSheet-class.html)
- [CupertinoActionSheetAction API](https://api.flutter.dev/flutter/cupertino/CupertinoActionSheetAction-class.html)
