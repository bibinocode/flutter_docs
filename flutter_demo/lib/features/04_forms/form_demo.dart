import 'package:flutter/material.dart';

/// 表单验证演示页面
class FormDemoPage extends StatefulWidget {
  const FormDemoPage({super.key});

  @override
  State<FormDemoPage> createState() => _FormDemoPageState();
}

class _FormDemoPageState extends State<FormDemoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  String? _selectedCity;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final List<String> _cities = ['北京', '上海', '广州', '深圳', '杭州', '成都'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form 表单')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('用户注册', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('请填写以下信息完成注册', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),

              // 用户名
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '用户名 *', hintText: '2-20个字符', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  if (value.length < 2) {
                    return '用户名至少2个字符';
                  }
                  if (value.length > 20) {
                    return '用户名不能超过20个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 邮箱
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: '邮箱 *', hintText: 'example@email.com', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 手机号
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '手机号', hintText: '11位手机号', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return '请输入有效的手机号';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 城市选择
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(labelText: '所在城市', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
                items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                onChanged: (value) => setState(() => _selectedCity = value),
              ),
              const SizedBox(height: 16),

              // 密码
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '密码 *',
                  hintText: '至少6位，包含字母和数字',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 6) {
                    return '密码至少6位';
                  }
                  if (!RegExp(r'(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                    return '密码需包含字母和数字';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 确认密码
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: '确认密码 *',
                  hintText: '再次输入密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                  border: const OutlineInputBorder(),
                ),
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
              const SizedBox(height: 16),

              // 同意条款
              FormField<bool>(
                initialValue: _agreeTerms,
                validator: (value) {
                  if (value != true) {
                    return '请同意用户协议';
                  }
                  return null;
                },
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: const Text('我已阅读并同意《用户协议》'),
                        value: _agreeTerms,
                        onChanged: (value) {
                          setState(() => _agreeTerms = value!);
                          state.didChange(value);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(state.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 提交按钮
              FilledButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('注册', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),

              // 重置按钮
              OutlinedButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.refresh),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('重置', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),

              // 表单说明
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('表单验证说明', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('• Form widget 管理表单状态'),
                      const Text('• GlobalKey<FormState> 访问表单'),
                      const Text('• TextFormField 自带验证支持'),
                      const Text('• validator 返回 null 表示通过'),
                      const Text('• autovalidateMode 控制验证时机'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (_formKey.currentState!.validate()) {
      // 表单验证通过
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('注册成功'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('用户名: ${_nameController.text}'), Text('邮箱: ${_emailController.text}'), if (_phoneController.text.isNotEmpty) Text('手机号: ${_phoneController.text}'), if (_selectedCity != null) Text('城市: $_selectedCity')]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _agreeTerms = false;
      _selectedCity = null;
      _autovalidateMode = AutovalidateMode.disabled;
    });
  }
}
