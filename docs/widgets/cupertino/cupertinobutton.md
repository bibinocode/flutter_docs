# CupertinoButton

`CupertinoButton` 是 iOS 风格的按钮组件，遵循 Apple Human Interface Guidelines，具有按下时的半透明反馈效果。

## 基本用法

```dart
CupertinoButton(
  onPressed: () {
    print('按钮被点击');
  },
  child: Text('点击我'),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `child` | `Widget` | 按钮内容 |
| `onPressed` | `VoidCallback?` | 点击回调，为 null 时按钮禁用 |
| `color` | `Color?` | 背景颜色（仅 filled 变体有效） |
| `disabledColor` | `Color` | 禁用时背景颜色 |
| `padding` | `EdgeInsetsGeometry?` | 内边距 |
| `minSize` | `double?` | 最小尺寸 |
| `pressedOpacity` | `double?` | 按下时的透明度（默认 0.4） |
| `borderRadius` | `BorderRadius?` | 圆角 |
| `alignment` | `AlignmentGeometry` | 对齐方式 |

## 使用场景

### 1. 按钮样式对比

```dart
import 'package:flutter/cupertino.dart';

class ButtonStylesDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('按钮样式'),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // 标准按钮（无背景）
            _buildSection(
              '标准按钮',
              CupertinoButton(
                onPressed: () {},
                child: Text('标准按钮'),
              ),
            ),
            
            // 填充按钮
            _buildSection(
              '填充按钮',
              CupertinoButton.filled(
                onPressed: () {},
                child: Text('填充按钮'),
              ),
            ),
            
            // 灰色填充按钮
            _buildSection(
              '灰色按钮',
              CupertinoButton(
                onPressed: () {},
                color: CupertinoColors.systemGrey5,
                child: Text(
                  '灰色按钮',
                  style: TextStyle(color: CupertinoColors.label),
                ),
              ),
            ),
            
            // 禁用按钮
            _buildSection(
              '禁用按钮',
              CupertinoButton.filled(
                onPressed: null,
                child: Text('禁用按钮'),
              ),
            ),
            
            // 带图标的按钮
            _buildSection(
              '图标按钮',
              CupertinoButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add),
                    SizedBox(width: 8),
                    Text('添加'),
                  ],
                ),
              ),
            ),
            
            // 危险操作按钮
            _buildSection(
              '危险操作',
              CupertinoButton(
                onPressed: () {},
                child: Text(
                  '删除',
                  style: TextStyle(color: CupertinoColors.destructiveRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget button) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 8),
          Center(child: button),
        ],
      ),
    );
  }
}
```

### 2. 导航栏按钮

```dart
CupertinoNavigationBar(
  leading: CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: () => Navigator.pop(context),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.back, size: 28),
        Text('返回'),
      ],
    ),
  ),
  middle: Text('页面标题'),
  trailing: CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: () {},
    child: Text('完成'),
  ),
)
```

### 3. 列表操作按钮

```dart
class ListWithButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text('账户设置'),
      children: [
        CupertinoListTile(
          title: Text('编辑资料'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Icon(
              CupertinoIcons.pencil,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ),
        CupertinoListTile(
          title: Text('退出登录'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showLogoutDialog(context),
            child: Text(
              '退出',
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
        title: Text('确认退出'),
        content: Text('您确定要退出登录吗？'),
        actions: [
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('退出'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
```

### 4. 加载状态按钮

```dart
class CupertinoLoadingButton extends StatefulWidget {
  final Future&lt;void&gt; Function() onPressed;
  final String text;

  const CupertinoLoadingButton({
    required this.onPressed,
    required this.text,
  });

  @override
  State&lt;CupertinoLoadingButton&gt; createState() => _CupertinoLoadingButtonState();
}

class _CupertinoLoadingButtonState extends State&lt;CupertinoLoadingButton&gt; {
  bool _isLoading = false;

  Future&lt;void&gt; _handlePress() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: _isLoading ? null : _handlePress,
      child: _isLoading
          ? CupertinoActivityIndicator(color: CupertinoColors.white)
          : Text(widget.text),
    );
  }
}

// 使用
CupertinoLoadingButton(
  text: '提交',
  onPressed: () async {
    await Future.delayed(Duration(seconds: 2));
  },
)
```

### 5. 全宽按钮

```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.symmetric(horizontal: 20),
  child: CupertinoButton.filled(
    onPressed: () {},
    child: Text('继续'),
  ),
)

// 或者使用 SizedBox
SizedBox(
  width: double.infinity,
  child: CupertinoButton.filled(
    onPressed: () {},
    borderRadius: BorderRadius.circular(12),
    child: Text('登录'),
  ),
)
```

### 6. 底部安全区域按钮

```dart
Column(
  children: [
    Expanded(
      child: // 页面内容
    ),
    SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: () {},
            child: Text('下一步'),
          ),
        ),
      ),
    ),
  ],
)
```

## 完整示例：iOS 风格表单页面

```dart
import 'package:flutter/cupertino.dart';

class CupertinoFormPage extends StatefulWidget {
  const CupertinoFormPage({super.key});

  @override
  State<CupertinoFormPage> createState() => _CupertinoFormPageState();
}

class _CupertinoFormPageState extends State<CupertinoFormPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.length >= 6 &&
        _agreeToTerms;
  }

  Future<void> _handleSubmit() async {
    if (!_isFormValid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('注册成功'),
        content: const Text('欢迎加入我们！'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('创建账户'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 表单输入区域
            CupertinoListSection.insetGrouped(
              header: const Text('账户信息'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _usernameController,
                  prefix: const Text('用户名'),
                  placeholder: '请输入用户名',
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                CupertinoTextFormFieldRow(
                  controller: _emailController,
                  prefix: const Text('邮箱'),
                  placeholder: '请输入邮箱地址',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                CupertinoTextFormFieldRow(
                  controller: _passwordController,
                  prefix: const Text('密码'),
                  placeholder: '至少6位字符',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 服务条款
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('同意服务条款和隐私政策'),
                  trailing: CupertinoSwitch(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() => _agreeToTerms = value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 查看条款按钮
            Center(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // 打开条款页面
                },
                child: const Text(
                  '查看服务条款',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 主要提交按钮
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: _isFormValid && !_isLoading ? _handleSubmit : null,
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : const Text('创建账户'),
              ),
            ),

            const SizedBox(height: 16),

            // 次要操作按钮
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                onPressed: () {
                  // 跳转到登录页
                },
                child: const Text('已有账户？立即登录'),
              ),
            ),

            const SizedBox(height: 32),

            // 第三方登录
            const Center(
              child: Text(
                '或使用以下方式注册',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 社交登录按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: () {},
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      CupertinoIcons.person_circle,
                      size: 30,
                    ),
                  ),
                ),
                CupertinoButton(
                  onPressed: () {},
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      CupertinoIcons.envelope,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Material vs Cupertino 按钮对比

| 特性 | Material Button | CupertinoButton |
|------|-----------------|-----------------|
| 设计规范 | Material Design | Apple HIG |
| 点击反馈 | 水波纹扩散效果 | 透明度变化 (pressedOpacity) |
| 默认外观 | 有背景色和阴影 | 无背景，仅文字 |
| 填充变体 | ElevatedButton | CupertinoButton.filled |
| 圆角样式 | 可高度定制 | 默认较大圆角 (8.0) |
| 禁用状态 | 灰色文字和背景 | 半透明效果 |
| 最小尺寸 | 48x48 | 44x44 |
| 适用平台 | Android、Web | iOS、macOS |

## 最佳实践

### 何时使用 CupertinoButton vs Material Button

**使用 CupertinoButton 的场景：**
- 开发专门针对 iOS/macOS 平台的应用
- 需要严格遵循 Apple Human Interface Guidelines
- 用户群体主要是 Apple 设备用户
- 在 CupertinoPageScaffold 等 iOS 风格页面中
- 需要与系统原生应用保持一致的体验

**使用 Material Button 的场景：**
- 开发跨平台应用，希望保持统一风格
- Android 平台应用
- 需要丰富的按钮样式变体（ElevatedButton、FilledButton、OutlinedButton、TextButton）
- 需要更多自定义选项（如涟漪效果、elevation）

### 通用最佳实践

1. **保持平台一致性**：在 iOS 应用中使用 Cupertino 组件，保持原生体验
2. **主次分明**：使用 `CupertinoButton.filled` 表示主要操作，普通按钮表示次要操作
3. **危险操作提示**：使用 `CupertinoColors.destructiveRed` 标识危险操作
4. **无障碍设计**：确保按钮点击区域至少 44x44 像素
5. **加载状态**：异步操作时显示 `CupertinoActivityIndicator` 并禁用按钮
6. **合理使用 padding**：导航栏按钮通常设置 `padding: EdgeInsets.zero`
7. **风格统一**：同一页面或模块保持按钮风格一致

```dart
// 根据平台选择按钮样式
import 'dart:io';

Widget buildPlatformButton({
  required VoidCallback? onPressed,
  required Widget child,
}) {
  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      child: child,
    );
  }
  return ElevatedButton(
    onPressed: onPressed,
    child: child,
  );
}
```

## 相关组件

- [ElevatedButton](../buttons/elevatedbutton) - Material 凸起按钮
- [TextButton](../buttons/textbutton) - Material 文本按钮
- [CupertinoSegmentedControl](./cupertinosegmentedcontrol) - iOS 分段控制器
- [CupertinoSlidingSegmentedControl](./cupertinoslidsegmentedcontrol) - iOS 滑动分段控制器
- [CupertinoDialogAction](./cupertinodialogaction) - iOS 对话框按钮

## 官方文档

- [CupertinoButton API](https://api.flutter.dev/flutter/cupertino/CupertinoButton-class.html)
- [iOS Buttons - Apple HIG](https://developer.apple.com/design/human-interface-guidelines/buttons)
