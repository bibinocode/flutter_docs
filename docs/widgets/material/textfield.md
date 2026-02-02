# TextField

`TextField` 是 Material Design 中的文本输入组件，用于接收用户输入的单行或多行文本。

## 基本用法

```dart
TextField(
  decoration: InputDecoration(
    labelText: '用户名',
    hintText: '请输入用户名',
  ),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `controller` | `TextEditingController?` | 文本控制器 |
| `focusNode` | `FocusNode?` | 焦点节点 |
| `decoration` | `InputDecoration?` | 输入框装饰 |
| `keyboardType` | `TextInputType?` | 键盘类型 |
| `textInputAction` | `TextInputAction?` | 键盘操作按钮 |
| `obscureText` | `bool` | 是否隐藏文本（密码） |
| `maxLines` | `int?` | 最大行数 |
| `maxLength` | `int?` | 最大字符数 |
| `onChanged` | `ValueChanged&lt;String&gt;?` | 文本变化回调 |
| `onSubmitted` | `ValueChanged&lt;String&gt;?` | 提交回调 |
| `enabled` | `bool?` | 是否启用 |
| `readOnly` | `bool` | 是否只读 |
| `autofocus` | `bool` | 是否自动获取焦点 |
| `inputFormatters` | `List&lt;TextInputFormatter&gt;?` | 输入格式化器 |

## InputDecoration 常用属性

| 属性 | 说明 |
|------|------|
| `labelText` | 标签文本 |
| `hintText` | 提示文本 |
| `helperText` | 帮助文本 |
| `errorText` | 错误文本 |
| `prefixIcon` | 前缀图标 |
| `suffixIcon` | 后缀图标 |
| `prefix` | 前缀 Widget |
| `suffix` | 后缀 Widget |
| `filled` | 是否填充背景 |
| `fillColor` | 填充颜色 |
| `border` | 边框样式 |
| `enabledBorder` | 启用时边框 |
| `focusedBorder` | 聚焦时边框 |
| `errorBorder` | 错误时边框 |

## 使用场景

### 1. 登录表单

```dart
class LoginForm extends StatefulWidget {
  @override
  State&lt;LoginForm&gt; createState() => _LoginFormState();
}

class _LoginFormState extends State&lt;LoginForm&gt; {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey&lt;FormState&gt;();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 邮箱输入
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '邮箱',
              hintText: 'example@email.com',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return '邮箱格式不正确';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          
          // 密码输入
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility 
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码至少6位';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          SizedBox(height: 24),
          
          // 提交按钮
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text('登录'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 处理登录
      print('邮箱: ${_emailController.text}');
      print('密码: ${_passwordController.text}');
    }
  }
}
```

### 2. 搜索框

```dart
class SearchField extends StatefulWidget {
  final ValueChanged&lt;String&gt; onSearch;
  
  const SearchField({required this.onSearch});

  @override
  State&lt;SearchField&gt; createState() => _SearchFieldState();
}

class _SearchFieldState extends State&lt;SearchField&gt; {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: '搜索...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: _hasText
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _focusNode.requestFocus();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
      onSubmitted: widget.onSearch,
    );
  }
}
```

### 3. 带字数统计的文本区域

```dart
class TextAreaWithCounter extends StatefulWidget {
  final int maxLength;
  final ValueChanged&lt;String&gt;? onChanged;
  
  const TextAreaWithCounter({
    this.maxLength = 200,
    this.onChanged,
  });

  @override
  State&lt;TextAreaWithCounter&gt; createState() => _TextAreaWithCounterState();
}

class _TextAreaWithCounterState extends State&lt;TextAreaWithCounter&gt; {
  final _controller = TextEditingController();
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentLength = _controller.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          maxLines: 5,
          maxLength: widget.maxLength,
          buildCounter: (context, {
            required currentLength, 
            required isFocused, 
            maxLength,
          }) => null, // 隐藏默认计数器
          decoration: InputDecoration(
            hintText: '请输入内容...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: widget.onChanged,
        ),
        Padding(
          padding: EdgeInsets.only(top: 4, right: 4),
          child: Text(
            '$_currentLength / ${widget.maxLength}',
            style: TextStyle(
              color: _currentLength > widget.maxLength * 0.9
                  ? Colors.red
                  : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
```

### 4. 格式化输入（手机号）

```dart
import 'package:flutter/services.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  
  const PhoneNumberField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _PhoneNumberFormatter(),
        LengthLimitingTextInputFormatter(13), // 11位 + 2个空格
      ],
      decoration: InputDecoration(
        labelText: '手机号',
        hintText: '138 0000 0000',
        prefixIcon: Icon(Icons.phone),
        prefixText: '+86 ',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final newText = buffer.toString();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
```

### 5. Material 3 样式

```dart
// 填充样式（推荐）
TextField(
  decoration: InputDecoration(
    labelText: 'Filled',
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// 轮廓样式
TextField(
  decoration: InputDecoration(
    labelText: 'Outlined',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// 全局主题配置
MaterialApp(
  theme: ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  ),
)
```

## 最佳实践

1. **使用 Controller**: 需要获取或设置文本时使用 TextEditingController
2. **键盘类型**: 根据输入内容设置合适的 keyboardType
3. **输入操作**: 配置 textInputAction 优化用户体验
4. **表单验证**: 使用 TextFormField 配合 Form 进行验证
5. **焦点管理**: 使用 FocusNode 管理输入焦点
6. **资源释放**: 记得在 dispose 中释放 controller 和 focusNode

## 相关组件

- [TextFormField](./textformfield) - 支持表单验证的文本输入
- [SearchBar](./searchbar) - Material 3 搜索栏
- [Autocomplete](./autocomplete) - 自动完成输入

## 官方文档

- [TextField API](https://api.flutter.dev/flutter/material/TextField-class.html)
- [Material Text Fields](https://m3.material.io/components/text-fields/overview)
