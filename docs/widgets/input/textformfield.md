# TextFormField

`TextFormField` 是 Flutter 中带表单验证功能的文本输入框组件。它是 `TextField` 的封装，集成了 `FormField` 的验证能力，专门用于表单场景。TextFormField 可以与 `Form` 组件配合使用，实现统一的表单验证、保存和重置功能，是构建用户注册、登录、数据录入等表单界面的核心组件。

## 基本用法

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: '用户名',
    hintText: '请输入用户名',
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '用户名不能为空';
    }
    return null;
  },
)
```

## 属性详解

### 继承自 TextField 的属性

TextFormField 继承了 TextField 的所有属性，包括 `controller`、`decoration`、`keyboardType`、`obscureText`、`maxLines`、`onChanged` 等。详细属性请参考 [TextField](./textfield.md) 文档。

### 表单特有属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `validator` | `FormFieldValidator<String>?` | - | 验证函数，返回 `null` 表示验证通过，返回字符串表示错误信息 |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | 自动验证模式 |
| `onSaved` | `FormFieldSetter<String>?` | - | 表单保存时的回调函数 |
| `initialValue` | `String?` | - | 初始值（与 `controller` 互斥） |
| `restorationId` | `String?` | - | 状态恢复标识符 |
| `onFieldSubmitted` | `ValueChanged<String>?` | - | 字段提交时回调 |
| `enabled` | `bool?` | `true` | 是否启用 |

## AutovalidateMode 详解

`AutovalidateMode` 控制表单字段的自动验证时机：

| 模式 | 说明 |
|------|------|
| `AutovalidateMode.disabled` | 禁用自动验证，仅在调用 `validate()` 时验证 |
| `AutovalidateMode.always` | 始终自动验证，每次内容变化都会触发验证 |
| `AutovalidateMode.onUserInteraction` | 用户首次交互后自动验证，提供更好的用户体验 |

```dart
TextFormField(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '此字段为必填';
    }
    return null;
  },
)
```

## 与 Form 配合使用

TextFormField 通常与 `Form` 组件配合使用，实现统一的表单管理：

```dart
class MyFormPage extends StatefulWidget {
  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  // 1. 创建 GlobalKey 用于访问 FormState
  final _formKey = GlobalKey<FormState>();
  
  String _username = '';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: '用户名'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名';
              }
              return null;
            },
            onSaved: (value) => _username = value ?? '',
          ),
          TextFormField(
            decoration: InputDecoration(labelText: '邮箱'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱';
              }
              if (!value.contains('@')) {
                return '请输入有效的邮箱地址';
              }
              return null;
            },
            onSaved: (value) => _email = value ?? '',
          ),
          ElevatedButton(
            onPressed: () {
              // 2. 验证表单
              if (_formKey.currentState!.validate()) {
                // 3. 保存表单数据
                _formKey.currentState!.save();
                // 处理数据...
                print('用户名: $_username, 邮箱: $_email');
              }
            },
            child: Text('提交'),
          ),
        ],
      ),
    );
  }
}
```

### FormState 常用方法

| 方法 | 说明 |
|------|------|
| `validate()` | 验证所有字段，返回是否全部通过 |
| `save()` | 调用所有字段的 `onSaved` 回调 |
| `reset()` | 重置所有字段到初始值 |

## 使用场景

### 1. 必填字段验证

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: '姓名 *',
    hintText: '请输入您的姓名',
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return '姓名为必填项';
    }
    return null;
  },
)
```

### 2. 邮箱格式验证

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: '邮箱',
    prefixIcon: Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    // 使用正则表达式验证邮箱格式
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  },
)
```

### 3. 密码强度验证

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: '密码',
    prefixIcon: Icon(Icons.lock),
  ),
  obscureText: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 8) {
      return '密码长度至少8位';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return '密码必须包含大写字母';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return '密码必须包含小写字母';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return '密码必须包含数字';
    }
    return null;
  },
)
```

### 4. 密码确认验证

```dart
class PasswordFormFields extends StatefulWidget {
  @override
  State<PasswordFormFields> createState() => _PasswordFormFieldsState();
}

class _PasswordFormFieldsState extends State<PasswordFormFields> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: '密码'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.length < 6) {
              return '密码至少6位';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: '确认密码'),
          obscureText: true,
          validator: (value) {
            if (value != _passwordController.text) {
              return '两次输入的密码不一致';
            }
            return null;
          },
        ),
      ],
    );
  }
}
```

### 5. 手机号码验证

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: '手机号码',
    prefixIcon: Icon(Icons.phone),
    prefixText: '+86 ',
  ),
  keyboardType: TextInputType.phone,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号码';
    }
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的手机号码';
    }
    return null;
  },
)
```

## 完整示例：注册表单

```dart
import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  // 表单数据
  String _username = '';
  String _email = '';
  String _phone = '';
  String _password = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // 提交表单
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() => _isLoading = true);
      
      // 模拟网络请求
      await Future.delayed(Duration(seconds: 2));
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注册成功！欢迎 $_username'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // 重置表单
  void _resetForm() {
    _formKey.currentState!.reset();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户注册'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 用户名
              TextFormField(
                decoration: InputDecoration(
                  labelText: '用户名 *',
                  hintText: '3-20个字符',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入用户名';
                  }
                  if (value.length < 3) {
                    return '用户名至少3个字符';
                  }
                  if (value.length > 20) {
                    return '用户名最多20个字符';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return '用户名只能包含字母、数字和下划线';
                  }
                  return null;
                },
                onSaved: (value) => _username = value!.trim(),
              ),
              SizedBox(height: 16),
              
              // 邮箱
              TextFormField(
                decoration: InputDecoration(
                  labelText: '邮箱 *',
                  hintText: 'example@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              SizedBox(height: 16),
              
              // 手机号
              TextFormField(
                decoration: InputDecoration(
                  labelText: '手机号码',
                  hintText: '选填',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return '请输入有效的手机号码';
                    }
                  }
                  return null;
                },
                onSaved: (value) => _phone = value ?? '',
              ),
              SizedBox(height: 16),
              
              // 密码
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码 *',
                  hintText: '至少8位，包含大小写字母和数字',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
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
                ),
                obscureText: _obscurePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 8) {
                    return '密码至少8位';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return '密码必须包含大写字母';
                  }
                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                    return '密码必须包含小写字母';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return '密码必须包含数字';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 16),
              
              // 确认密码
              TextFormField(
                decoration: InputDecoration(
                  labelText: '确认密码 *',
                  hintText: '再次输入密码',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请确认密码';
                  }
                  if (value != _passwordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              
              // 提交按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('注册', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 12),
              
              // 重置按钮
              OutlinedButton(
                onPressed: _isLoading ? null : _resetForm,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('重置', style: TextStyle(fontSize: 16)),
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

### 1. 正确使用 GlobalKey

```dart
// ✅ 推荐：在 State 类中声明 GlobalKey
class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      // ...
    );
  }
}

// ❌ 避免：在 build 方法中创建 GlobalKey
@override
Widget build(BuildContext context) {
  final formKey = GlobalKey<FormState>(); // 每次重建都会创建新的 Key
  return Form(key: formKey, ...);
}
```

### 2. 使用 onUserInteraction 模式

```dart
// ✅ 推荐：用户交互后再验证，避免初始显示错误
TextFormField(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (value) => ...,
)

// ❌ 避免：always 模式会在初始化时就显示错误
TextFormField(
  autovalidateMode: AutovalidateMode.always,
  validator: (value) => ...,
)
```

### 3. controller 与 initialValue 互斥

```dart
// ✅ 使用 controller
final _controller = TextEditingController(text: '初始值');
TextFormField(controller: _controller)

// ✅ 使用 initialValue
TextFormField(initialValue: '初始值')

// ❌ 不能同时使用
TextFormField(
  controller: _controller,
  initialValue: '初始值', // 会报错
)
```

### 4. 及时释放资源

```dart
class _MyFormState extends State<MyForm> {
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose(); // 记得释放 controller
    super.dispose();
  }
}
```

### 5. 封装通用验证器

```dart
class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '此字段为必填';
    }
    return null;
  }
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return '请输入有效的邮箱';
    }
    return null;
  }
  
  static String? minLength(int length) {
    return (String? value) {
      if (value != null && value.length < length) {
        return '最少 $length 个字符';
      }
      return null;
    };
  }
  
  // 组合多个验证器
  static String? compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

// 使用
TextFormField(
  validator: Validators.compose([
    Validators.required,
    Validators.email,
  ]),
)
```

## 相关组件

- [Form](https://api.flutter.dev/flutter/widgets/Form-class.html) - 表单容器，管理多个 FormField 的验证和保存
- [FormField](https://api.flutter.dev/flutter/widgets/FormField-class.html) - 表单字段基类，TextFormField 继承自它
- [TextField](./textfield.md) - 基础文本输入框，不带表单验证功能
- [DropdownButtonFormField](./dropdownbuttonformfield.md) - 带表单验证的下拉选择框

## 官方文档

- [TextFormField API](https://api.flutter.dev/flutter/material/TextFormField-class.html)
- [Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation)
