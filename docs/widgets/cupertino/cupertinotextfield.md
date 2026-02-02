# CupertinoTextField

`CupertinoTextField` 是 iOS 风格的输入框组件，遵循 Apple Human Interface Guidelines，提供圆角边框、内置清除按钮等原生 iOS 输入体验。

## 基本用法

```dart
CupertinoTextField(
  placeholder: '请输入内容',
  onChanged: (value) {
    print('输入内容: $value');
  },
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `controller` | `TextEditingController?` | 文本控制器，用于获取或设置输入内容 |
| `focusNode` | `FocusNode?` | 焦点控制节点 |
| `placeholder` | `String?` | 占位提示文本 |
| `prefix` | `Widget?` | 输入框前缀组件 |
| `suffix` | `Widget?` | 输入框后缀组件 |
| `clearButtonMode` | `OverlayVisibilityMode` | 清除按钮显示模式（never/editing/notEditing/always） |
| `keyboardType` | `TextInputType?` | 键盘类型（text/number/email/phone 等） |
| `textInputAction` | `TextInputAction?` | 键盘操作按钮类型（done/next/search 等） |
| `obscureText` | `bool` | 是否隐藏输入内容（密码模式） |
| `maxLines` | `int?` | 最大行数，设为 null 可自动换行 |
| `decoration` | `BoxDecoration?` | 输入框装饰，设为 null 移除默认边框 |
| `padding` | `EdgeInsetsGeometry` | 内边距 |
| `style` | `TextStyle?` | 输入文本样式 |
| `placeholderStyle` | `TextStyle?` | 占位文本样式 |
| `readOnly` | `bool` | 是否只读 |
| `enabled` | `bool?` | 是否启用 |

## 使用场景

### 1. 基本输入

```dart
import 'package:flutter/cupertino.dart';

class BasicInputDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('基本输入'),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // 基本输入框
              CupertinoTextField(
                placeholder: '请输入用户名',
              ),
              SizedBox(height: 16),
              
              // 带清除按钮
              CupertinoTextField(
                placeholder: '输入时显示清除按钮',
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
              SizedBox(height: 16),
              
              // 带边框样式
              CupertinoTextField(
                placeholder: '自定义边框样式',
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.activeBlue,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
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

### 2. 带前缀图标

```dart
class PrefixInputDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 用户名输入
          CupertinoTextField(
            prefix: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                CupertinoIcons.person,
                color: CupertinoColors.systemGrey,
              ),
            ),
            placeholder: '用户名',
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          SizedBox(height: 16),
          
          // 邮箱输入
          CupertinoTextField(
            prefix: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                CupertinoIcons.mail,
                color: CupertinoColors.systemGrey,
              ),
            ),
            placeholder: '邮箱地址',
            keyboardType: TextInputType.emailAddress,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          SizedBox(height: 16),
          
          // 电话输入
          CupertinoTextField(
            prefix: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                CupertinoIcons.phone,
                color: CupertinoColors.systemGrey,
              ),
            ),
            placeholder: '手机号码',
            keyboardType: TextInputType.phone,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
        ],
      ),
    );
  }
}
```

### 3. 搜索框

```dart
class SearchFieldDemo extends StatefulWidget {
  @override
  State<SearchFieldDemo> createState() => _SearchFieldDemoState();
}

class _SearchFieldDemoState extends State<SearchFieldDemo> {
  final _searchController = TextEditingController();
  List<String> _results = [];
  
  final _allItems = ['苹果', '香蕉', '橙子', '葡萄', '西瓜', '草莓', '蓝莓'];

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = [];
      } else {
        _results = _allItems
            .where((item) => item.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('搜索'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: CupertinoTextField(
                controller: _searchController,
                prefix: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                suffix: CupertinoButton(
                  padding: EdgeInsets.only(right: 8),
                  minSize: 0,
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: CupertinoColors.systemGrey3,
                    size: 18,
                  ),
                ),
                placeholder: '搜索水果...',
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: _search,
                textInputAction: TextInputAction.search,
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        '输入关键词搜索',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        return CupertinoListTile(
                          title: Text(_results[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

### 4. 密码输入

```dart
class PasswordInputDemo extends StatefulWidget {
  @override
  State<PasswordInputDemo> createState() => _PasswordInputDemoState();
}

class _PasswordInputDemoState extends State<PasswordInputDemo> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: CupertinoTextField(
        prefix: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(
            CupertinoIcons.lock,
            color: CupertinoColors.systemGrey,
          ),
        ),
        suffix: CupertinoButton(
          padding: EdgeInsets.only(right: 8),
          minSize: 0,
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: CupertinoColors.systemGrey,
            size: 20,
          ),
        ),
        placeholder: '请输入密码',
        obscureText: _obscureText,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}
```

### 5. 多行输入

```dart
class MultilineInputDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '反馈内容',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 8),
          CupertinoTextField(
            placeholder: '请详细描述您的问题或建议...',
            maxLines: 5,
            minLines: 3,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            textAlignVertical: TextAlignVertical.top,
          ),
          SizedBox(height: 24),
          
          // 自动扩展的多行输入
          Text(
            '备注（自动扩展）',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 8),
          CupertinoTextField(
            placeholder: '输入备注信息...',
            maxLines: null, // 无限制，自动扩展
            padding: EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/cupertino.dart';

/// iOS 风格登录表单示例
class CupertinoLoginForm extends StatefulWidget {
  @override
  State<CupertinoLoginForm> createState() => _CupertinoLoginFormState();
}

class _CupertinoLoginFormState extends State<CupertinoLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() => _emailError = '请输入邮箱地址');
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = '请输入有效的邮箱地址');
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() => _passwordError = '请输入密码');
      return false;
    }
    if (password.length < 6) {
      setState(() => _passwordError = '密码至少需要6个字符');
      return false;
    }
    setState(() => _passwordError = null);
    return true;
  }

  Future<void> _login() async {
    final emailValid = _validateEmail(_emailController.text);
    final passwordValid = _validatePassword(_passwordController.text);
    
    if (!emailValid || !passwordValid) return;

    setState(() => _isLoading = true);
    
    // 模拟登录请求
    await Future.delayed(Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('登录成功'),
        content: Text('欢迎回来，${_emailController.text}'),
        actions: [
          CupertinoDialogAction(
            child: Text('确定'),
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
        middle: Text('登录'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              
              // Logo
              Icon(
                CupertinoIcons.person_circle,
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
              SizedBox(height: 40),
              
              // 邮箱输入框
              _buildInputSection(
                label: '邮箱',
                error: _emailError,
                child: CupertinoTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.mail,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                  placeholder: '请输入邮箱地址',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  padding: EdgeInsets.fromLTRB(8, 14, 12, 14),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(10),
                    border: _emailError != null
                        ? Border.all(color: CupertinoColors.destructiveRed)
                        : null,
                  ),
                  onSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                  onChanged: (_) {
                    if (_emailError != null) {
                      _validateEmail(_emailController.text);
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              
              // 密码输入框
              _buildInputSection(
                label: '密码',
                error: _passwordError,
                child: CupertinoTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.lock,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                  suffix: CupertinoButton(
                    padding: EdgeInsets.only(right: 12),
                    minSize: 0,
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                  placeholder: '请输入密码',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  padding: EdgeInsets.fromLTRB(8, 14, 0, 14),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(10),
                    border: _passwordError != null
                        ? Border.all(color: CupertinoColors.destructiveRed)
                        : null,
                  ),
                  onSubmitted: (_) => _login(),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      _validatePassword(_passwordController.text);
                    }
                  },
                ),
              ),
              SizedBox(height: 12),
              
              // 忘记密码
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () {},
                  child: Text(
                    '忘记密码？',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              SizedBox(height: 32),
              
              // 登录按钮
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text('登录'),
              ),
              SizedBox(height: 16),
              
              // 注册链接
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '还没有账号？',
                    style: TextStyle(color: CupertinoColors.secondaryLabel),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.only(left: 4),
                    minSize: 0,
                    onPressed: () {},
                    child: Text('立即注册'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String label,
    required Widget child,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        SizedBox(height: 8),
        child,
        if (error != null) ...[
          SizedBox(height: 6),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
```

## 最佳实践

### 1. 输入验证

```dart
// 实时验证输入
CupertinoTextField(
  onChanged: (value) {
    setState(() {
      _error = _validate(value);
    });
  },
  decoration: BoxDecoration(
    color: CupertinoColors.systemGrey6,
    borderRadius: BorderRadius.circular(10),
    border: _error != null 
        ? Border.all(color: CupertinoColors.destructiveRed)
        : null,
  ),
)
```

### 2. 焦点管理

```dart
// 表单字段之间跳转
final _field1Focus = FocusNode();
final _field2Focus = FocusNode();

CupertinoTextField(
  focusNode: _field1Focus,
  textInputAction: TextInputAction.next,
  onSubmitted: (_) => _field2Focus.requestFocus(),
)
```

### 3. 资源释放

```dart
// 始终在 dispose 中释放控制器和焦点节点
@override
void dispose() {
  _controller.dispose();
  _focusNode.dispose();
  super.dispose();
}
```

### 4. 合适的键盘类型

```dart
// 根据输入内容选择合适的键盘类型
CupertinoTextField(
  keyboardType: TextInputType.emailAddress, // 邮箱
  // TextInputType.phone  // 电话
  // TextInputType.number // 数字
  // TextInputType.url    // 网址
)
```

### 5. 无障碍支持

```dart
// 添加语义标签
Semantics(
  label: '邮箱输入框',
  hint: '请输入您的邮箱地址',
  child: CupertinoTextField(
    placeholder: '邮箱地址',
  ),
)
```

## 相关组件

- [TextField](../input/textfield.md) - Material Design 风格输入框
- [TextFormField](../input/textformfield.md) - 支持表单验证的 Material 输入框
- [CupertinoSearchTextField](./cupertino-search-textfield.md) - iOS 风格搜索框
- [CupertinoButton](./cupertinobutton.md) - iOS 风格按钮
