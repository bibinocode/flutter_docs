import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 表单输入模块页面
class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('表单输入')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDemoCard(context, icon: '📝', title: 'TextField', description: '文本输入框，支持装饰、验证、格式化', route: '/forms/textfield'),
          _buildDemoCard(context, icon: '☑️', title: 'Checkbox & Switch', description: '复选框和开关组件', route: '/forms/checkbox'),
          _buildDemoCard(context, icon: '📋', title: 'Form 表单', description: '完整表单验证和提交示例', route: '/forms/form'),
        ],
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, {required String icon, required String title, required String description, required String route}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
