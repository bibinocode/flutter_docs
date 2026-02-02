# TextField

`TextField` 是 Flutter 中用于文本输入的 Material Design 组件。它是最常用的文本输入控件，支持单行和多行输入、各种键盘类型、输入验证、装饰样式、焦点管理等功能。TextField 提供了丰富的自定义选项，可以满足从简单文本输入到复杂表单验证的各种需求。

## 基本用法

```dart
TextField(
  decoration: InputDecoration(
    labelText: '用户名',
    hintText: '请输入用户名',
  ),
)
```

## 属性详解

### 基础属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `controller` | `TextEditingController?` | - | 文本控制器，用于获取和设置文本内容 |
| `focusNode` | `FocusNode?` | - | 焦点节点，用于控制焦点 |
| `decoration` | `InputDecoration?` | - | 输入装饰，定义外观样式 |
| `keyboardType` | `TextInputType?` | - | 键盘类型 |
| `textInputAction` | `TextInputAction?` | - | 键盘操作按钮类型 |
| `textCapitalization` | `TextCapitalization` | `none` | 文本大小写策略 |
| `style` | `TextStyle?` | - | 输入文本样式 |
| `strutStyle` | `StrutStyle?` | - | 文本行高样式 |
| `textAlign` | `TextAlign` | `start` | 文本水平对齐方式 |
| `textAlignVertical` | `TextAlignVertical?` | - | 文本垂直对齐方式 |
| `textDirection` | `TextDirection?` | - | 文本方向 |
| `autofocus` | `bool` | `false` | 是否自动获取焦点 |

### 文本隐藏与安全

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `obscuringCharacter` | `String` | `'•'` | 密码模式下显示的替代字符 |
| `obscureText` | `bool` | `false` | 是否隐藏文本（密码模式） |
| `autocorrect` | `bool` | `true` | 是否启用自动纠错 |
| `enableSuggestions` | `bool` | `true` | 是否启用输入建议 |

### 多行与长度控制

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `maxLines` | `int?` | `1` | 最大行数，`null` 表示无限制 |
| `minLines` | `int?` | - | 最小行数 |
| `expands` | `bool` | `false` | 是否扩展填充父容器 |
| `maxLength` | `int?` | - | 最大字符数 |
| `maxLengthEnforcement` | `MaxLengthEnforcement?` | - | 最大长度强制策略 |

### 回调函数

| 属性 | 类型 | 说明 |
|------|------|------|
| `onChanged` | `ValueChanged<String>?` | 内容变化时回调 |
| `onSubmitted` | `ValueChanged<String>?` | 提交时回调（按下键盘完成键） |
| `onEditingComplete` | `VoidCallback?` | 编辑完成回调 |
| `onTap` | `GestureTapCallback?` | 点击回调 |
| `onTapOutside` | `TapRegionCallback?` | 点击外部区域回调 |

### 输入控制

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `inputFormatters` | `List<TextInputFormatter>?` | - | 输入格式化器列表 |
| `enabled` | `bool?` | `true` | 是否启用 |
| `readOnly` | `bool` | `false` | 是否只读 |

### 光标样式

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `cursorWidth` | `double` | `2.0` | 光标宽度 |
| `cursorHeight` | `double?` | - | 光标高度 |
| `cursorRadius` | `Radius?` | - | 光标圆角 |
| `cursorColor` | `Color?` | - | 光标颜色 |

### 选择与交互

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `selectionHeightStyle` | `BoxHeightStyle` | `tight` | 选中区域高度样式 |
| `selectionWidthStyle` | `BoxWidthStyle` | `tight` | 选中区域宽度样式 |
| `keyboardAppearance` | `Brightness?` | - | 键盘外观（iOS） |
| `scrollPadding` | `EdgeInsets` | `20.0` | 滚动时的内边距 |
| `enableInteractiveSelection` | `bool?` | `true` | 是否启用交互式选择 |
| `selectionControls` | `TextSelectionControls?` | - | 选择控制器 |
| `mouseCursor` | `MouseCursor?` | - | 鼠标光标样式 |

### 高级属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `buildCounter` | `InputCounterWidgetBuilder?` | 自定义字符计数器构建器 |
| `scrollController` | `ScrollController?` | 滚动控制器 |
| `scrollPhysics` | `ScrollPhysics?` | 滚动物理效果 |
| `autofillHints` | `Iterable<String>?` | 自动填充提示 |
| `clipBehavior` | `Clip` | 裁剪行为 |
| `restorationId` | `String?` | 状态恢复 ID |
| `scribbleEnabled` | `bool` | 是否启用 Apple Pencil 涂写（iPadOS） |
| `enableIMEPersonalizedLearning` | `bool` | 是否启用输入法个性化学习 |
| `contextMenuBuilder` | `EditableTextContextMenuBuilder?` | 上下文菜单构建器 |
| `spellCheckConfiguration` | `SpellCheckConfiguration?` | 拼写检查配置 |
| `magnifierConfiguration` | `TextMagnifierConfiguration?` | 放大镜配置 |

## InputDecoration 详解

`InputDecoration` 用于定义 TextField 的外观装饰，包括标签、提示、图标、边框等。

### 文本属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `labelText` | `String?` | 标签文本，获取焦点时会浮动到上方 |
| `labelStyle` | `TextStyle?` | 标签文本样式 |
| `floatingLabelStyle` | `TextStyle?` | 浮动标签样式 |
| `floatingLabelBehavior` | `FloatingLabelBehavior?` | 浮动标签行为 |
| `hintText` | `String?` | 提示文本，输入为空时显示 |
| `hintStyle` | `TextStyle?` | 提示文本样式 |
| `hintMaxLines` | `int?` | 提示文本最大行数 |
| `helperText` | `String?` | 帮助文本，显示在输入框下方 |
| `helperStyle` | `TextStyle?` | 帮助文本样式 |
| `helperMaxLines` | `int?` | 帮助文本最大行数 |
| `errorText` | `String?` | 错误文本，显示时隐藏 helperText |
| `errorStyle` | `TextStyle?` | 错误文本样式 |
| `errorMaxLines` | `int?` | 错误文本最大行数 |

### 图标与前后缀

| 属性 | 类型 | 说明 |
|------|------|------|
| `icon` | `Widget?` | 输入框外部左侧图标 |
| `iconColor` | `Color?` | 图标颜色 |
| `prefixIcon` | `Widget?` | 前缀图标（边框内） |
| `prefixIconColor` | `Color?` | 前缀图标颜色 |
| `prefixIconConstraints` | `BoxConstraints?` | 前缀图标约束 |
| `prefix` | `Widget?` | 前缀组件 |
| `prefixText` | `String?` | 前缀文本 |
| `prefixStyle` | `TextStyle?` | 前缀文本样式 |
| `suffixIcon` | `Widget?` | 后缀图标（边框内） |
| `suffixIconColor` | `Color?` | 后缀图标颜色 |
| `suffixIconConstraints` | `BoxConstraints?` | 后缀图标约束 |
| `suffix` | `Widget?` | 后缀组件 |
| `suffixText` | `String?` | 后缀文本 |
| `suffixStyle` | `TextStyle?` | 后缀文本样式 |

### 计数器

| 属性 | 类型 | 说明 |
|------|------|------|
| `counter` | `Widget?` | 自定义计数器组件 |
| `counterText` | `String?` | 计数器文本（设为空字符串可隐藏） |
| `counterStyle` | `TextStyle?` | 计数器样式 |

### 边框样式

| 属性 | 类型 | 说明 |
|------|------|------|
| `border` | `InputBorder?` | 默认边框 |
| `focusedBorder` | `InputBorder?` | 获取焦点时边框 |
| `enabledBorder` | `InputBorder?` | 启用状态边框 |
| `disabledBorder` | `InputBorder?` | 禁用状态边框 |
| `errorBorder` | `InputBorder?` | 错误状态边框 |
| `focusedErrorBorder` | `InputBorder?` | 错误且获取焦点时边框 |

### 填充与间距

| 属性 | 类型 | 说明 |
|------|------|------|
| `filled` | `bool?` | 是否填充背景 |
| `fillColor` | `Color?` | 填充颜色 |
| `focusColor` | `Color?` | 获取焦点时的颜色 |
| `hoverColor` | `Color?` | 悬停时的颜色 |
| `contentPadding` | `EdgeInsetsGeometry?` | 内容内边距 |
| `isDense` | `bool?` | 是否使用紧凑布局 |
| `isCollapsed` | `bool` | 是否折叠（移除所有额外空间） |

### 其他属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `enabled` | `bool` | 是否启用装饰 |
| `semanticCounterText` | `String?` | 无障碍计数器文本 |
| `alignLabelWithHint` | `bool?` | 标签是否与提示文本对齐（多行时） |
| `constraints` | `BoxConstraints?` | 输入框约束 |

## 使用场景

### 1. 基本输入框

```dart
TextField(
  decoration: InputDecoration(
    labelText: '用户名',
    hintText: '请输入用户名',
    helperText: '用户名长度为 4-16 个字符',
    border: OutlineInputBorder(),
  ),
)
```

### 2. 密码输入框

```dart
class PasswordField extends StatefulWidget {
  const PasswordField({super.key});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscureText,
      obscuringCharacter: '●',
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: '密码',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscureText = !_obscureText);
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
```

### 3. 搜索框

```dart
class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        // 执行搜索
        print('搜索: $value');
      },
      decoration: InputDecoration(
        hintText: '搜索...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, child) {
            return _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _controller.clear(),
                  )
                : const SizedBox.shrink();
          },
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
    );
  }
}
```

### 4. 带验证的输入框

```dart
class ValidatedField extends StatefulWidget {
  const ValidatedField({super.key});

  @override
  State<ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<ValidatedField> {
  final _controller = TextEditingController();
  String? _errorText;

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = '邮箱不能为空';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _errorText = '请输入有效的邮箱地址';
      } else {
        _errorText = null;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: _validateEmail,
      decoration: InputDecoration(
        labelText: '邮箱',
        hintText: 'example@email.com',
        prefixIcon: const Icon(Icons.email),
        errorText: _errorText,
        border: const OutlineInputBorder(),
        suffixIcon: _errorText == null && _controller.text.isNotEmpty
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }
}
```

### 5. 多行文本输入

```dart
TextField(
  maxLines: null, // 无限行数，自动扩展
  minLines: 3, // 最小显示 3 行
  keyboardType: TextInputType.multiline,
  textInputAction: TextInputAction.newline,
  decoration: InputDecoration(
    labelText: '留言',
    hintText: '请输入您的留言...',
    alignLabelWithHint: true, // 标签与第一行对齐
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.all(16),
  ),
)

// 固定高度的多行输入
TextField(
  maxLines: 5,
  expands: false,
  decoration: InputDecoration(
    labelText: '描述',
    border: OutlineInputBorder(),
  ),
)
```

### 6. 带格式化的输入框

```dart
import 'package:flutter/services.dart';

// 手机号输入（只允许数字，最多11位）
TextField(
  keyboardType: TextInputType.phone,
  maxLength: 11,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  decoration: InputDecoration(
    labelText: '手机号',
    prefixText: '+86 ',
    counterText: '', // 隐藏计数器
    border: OutlineInputBorder(),
  ),
)

// 金额输入（允许小数点）
TextField(
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ],
  decoration: InputDecoration(
    labelText: '金额',
    prefixText: '¥ ',
    border: OutlineInputBorder(),
  ),
)

// 银行卡号格式化
class BankCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 19) return oldValue;
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    BankCardFormatter(),
  ],
  decoration: InputDecoration(
    labelText: '银行卡号',
    hintText: '0000 0000 0000 0000',
    border: OutlineInputBorder(),
  ),
)
```

## 完整示例：登录表单

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginFormDemo extends StatefulWidget {
  const LoginFormDemo({super.key});

  @override
  State<LoginFormDemo> createState() => _LoginFormDemoState();
}

class _LoginFormDemoState extends State<LoginFormDemo> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // 监听焦点变化
    _usernameFocus.addListener(_onUsernameFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocus.hasFocus) {
      _validateUsername(_usernameController.text);
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocus.hasFocus) {
      _validatePassword(_passwordController.text);
    }
  }

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = '请输入用户名';
      } else if (value.length < 4) {
        _usernameError = '用户名至少 4 个字符';
      } else if (value.length > 16) {
        _usernameError = '用户名最多 16 个字符';
      } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
        _usernameError = '只能包含字母、数字和下划线';
      } else {
        _usernameError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = '请输入密码';
      } else if (value.length < 6) {
        _passwordError = '密码至少 6 个字符';
      } else if (value.length > 20) {
        _passwordError = '密码最多 20 个字符';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _usernameError == null &&
        _passwordError == null &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    // 验证所有字段
    _validateUsername(_usernameController.text);
    _validatePassword(_passwordController.text);

    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录成功: ${_usernameController.text}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo 或标题
              const Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 40),

              // 用户名输入框
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 16,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                ],
                onChanged: (value) {
                  if (_usernameError != null) {
                    _validateUsername(value);
                  }
                },
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
                decoration: InputDecoration(
                  labelText: '用户名',
                  hintText: '请输入用户名',
                  helperText: '4-16 个字符，只能包含字母、数字和下划线',
                  errorText: _usernameError,
                  counterText: '',
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: _usernameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _usernameController.clear();
                            setState(() => _usernameError = null);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 密码输入框
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                enabled: !_isLoading,
                textInputAction: TextInputAction.done,
                obscureText: _obscurePassword,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 20,
                onChanged: (value) {
                  if (_passwordError != null) {
                    _validatePassword(value);
                  }
                },
                onSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  helperText: '6-20 个字符',
                  errorText: _passwordError,
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 登录按钮
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '登录',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 忘记密码
              TextButton(
                onPressed: () {
                  // 跳转忘记密码页面
                },
                child: const Text('忘记密码？'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## TextInputType 键盘类型

| 类型 | 说明 |
|------|------|
| `text` | 普通文本（默认） |
| `multiline` | 多行文本 |
| `number` | 数字 |
| `numberWithOptions(decimal: true)` | 带小数点的数字 |
| `phone` | 电话号码 |
| `datetime` | 日期时间 |
| `emailAddress` | 邮箱 |
| `url` | URL |
| `visiblePassword` | 可见密码 |
| `name` | 人名 |
| `streetAddress` | 街道地址 |

## TextInputAction 键盘操作

| 类型 | 说明 |
|------|------|
| `none` | 无操作 |
| `done` | 完成 |
| `go` | 前往 |
| `search` | 搜索 |
| `send` | 发送 |
| `next` | 下一步 |
| `previous` | 上一步 |
| `continueAction` | 继续 |
| `join` | 加入 |
| `route` | 路线 |
| `emergencyCall` | 紧急呼叫 |
| `newline` | 换行 |

## TextCapitalization 大小写策略

| 类型 | 说明 |
|------|------|
| `none` | 无（默认） |
| `characters` | 所有字符大写 |
| `words` | 每个单词首字母大写 |
| `sentences` | 每句话首字母大写 |

## 最佳实践

### 1. 资源管理

```dart
// ✅ 正确：在 dispose 中释放资源
@override
void dispose() {
  _controller.dispose();
  _focusNode.dispose();
  super.dispose();
}
```

### 2. 无障碍访问

```dart
// ✅ 正确：提供 labelText 而不仅是 hintText
TextField(
  decoration: InputDecoration(
    labelText: '用户名', // 屏幕阅读器会读取
    hintText: '请输入用户名',
  ),
)

// ❌ 错误：只有 hintText
TextField(
  decoration: InputDecoration(
    hintText: '用户名',
  ),
)
```

### 3. 键盘导航

```dart
// ✅ 正确：使用 textInputAction 配合焦点管理
TextField(
  textInputAction: TextInputAction.next,
  onSubmitted: (_) {
    FocusScope.of(context).requestFocus(_nextFocus);
  },
)
```

### 4. 输入验证

```dart
// ✅ 正确：使用 inputFormatters 在输入时限制
TextField(
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
  ],
)
```

### 5. 密码安全

```dart
// ✅ 正确：密码输入禁用自动填充和建议
TextField(
  obscureText: true,
  autocorrect: false,
  enableSuggestions: false,
  enableIMEPersonalizedLearning: false,
)
```

### 6. 主题统一

```dart
// ✅ 正确：使用 InputDecorationTheme 统一样式
ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
)
```

### 7. 点击外部收起键盘

```dart
// ✅ 正确：包裹 GestureDetector 或使用 onTapOutside
Scaffold(
  body: GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: // ...
  ),
)

// 或使用 onTapOutside
TextField(
  onTapOutside: (_) => FocusScope.of(context).unfocus(),
)
```

## 常见问题

::: warning 键盘遮挡输入框
在 Scaffold 中确保 `resizeToAvoidBottomInset: true`（默认值），或将 TextField 放入 SingleChildScrollView 中使其可滚动。
:::

::: tip 多行输入不换行
多行输入需要同时设置 `maxLines` 和 `keyboardType`:
```dart
TextField(
  maxLines: null,
  keyboardType: TextInputType.multiline,
)
```
:::

::: warning Controller 重复使用
不要在多个 TextField 中共用同一个 Controller，每个输入框应有独立的 Controller。
:::

## 相关组件

- [TextFormField](./textformfield) - 表单文本输入（配合 Form 使用，内置验证）
- [CupertinoTextField](../cupertino/cupertinotextfield) - iOS 风格输入框
- [Form](../layout/form) - 表单组件
- [Focus](../basics/focus) - 焦点管理

## 官方文档

- [TextField API](https://api.flutter.dev/flutter/material/TextField-class.html)
- [InputDecoration API](https://api.flutter.dev/flutter/material/InputDecoration-class.html)
- [文本输入指南](https://docs.flutter.cn/cookbook/forms/text-input)
- [处理表单](https://docs.flutter.cn/cookbook/forms)
