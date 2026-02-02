import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextField 演示页面
class TextFieldDemoPage extends StatefulWidget {
  const TextFieldDemoPage({super.key});

  @override
  State<TextFieldDemoPage> createState() => _TextFieldDemoPageState();
}

class _TextFieldDemoPageState extends State<TextFieldDemoPage> {
  final _basicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  final _multilineController = TextEditingController();
  bool _obscurePassword = true;
  String _inputValue = '';

  @override
  void dispose() {
    _basicController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TextField')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '基础输入框',
              child: Column(
                children: [
                  TextField(
                    controller: _basicController,
                    decoration: const InputDecoration(labelText: '用户名', hintText: '请输入用户名', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                    onChanged: (value) => setState(() => _inputValue = value),
                  ),
                  const SizedBox(height: 8),
                  Text('输入内容: $_inputValue', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '密码输入框',
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '搜索框样式',
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '多行输入',
              child: TextField(
                controller: _multilineController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: '备注', hintText: '请输入备注信息...', alignLabelWithHint: true, border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '输入限制',
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: '手机号', hintText: '11位手机号', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: '金额', hintText: '请输入金额', prefixIcon: Icon(Icons.attach_money), prefixText: '¥ ', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '不同装饰样式',
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(labelText: 'Outlined (默认)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Underline', border: UnderlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'Filled', filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, border: InputBorder.none),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
