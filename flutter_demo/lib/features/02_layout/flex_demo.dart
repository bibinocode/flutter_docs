import 'package:flutter/material.dart';

/// Flex 弹性布局 Demo
class FlexDemoPage extends StatelessWidget {
  const FlexDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flex 弹性布局')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, title: 'Expanded 等分空间', child: _buildExpandedDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Expanded flex 比例', child: _buildFlexDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Flexible 弹性填充', child: _buildFlexibleDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Spacer 空白间隔', child: _buildSpacerDemo()),
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
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ],
    );
  }

  Widget _buildExpandedDemo() {
    return Row(
      children: [
        Expanded(child: _buildBox('1', Colors.red)),
        const SizedBox(width: 8),
        Expanded(child: _buildBox('2', Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildBox('3', Colors.blue)),
      ],
    );
  }

  Widget _buildFlexDemo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 1, child: _buildBox('flex:1', Colors.red)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildBox('flex:2', Colors.green)),
            const SizedBox(width: 8),
            Expanded(flex: 3, child: _buildBox('flex:3', Colors.blue)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('比例 1:2:3', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFlexibleDemo() {
    return Column(
      children: [
        Row(
          children: [
            Flexible(child: _buildBox('Flexible', Colors.orange)),
            const SizedBox(width: 8),
            _buildBox('Fixed 100', Colors.purple, width: 100),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Flexible 填充剩余空间', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSpacerDemo() {
    return Row(children: [_buildBox('Left', Colors.red, width: 60), const Spacer(), _buildBox('Center', Colors.green, width: 60), const Spacer(flex: 2), _buildBox('Right', Colors.blue, width: 60)]);
  }

  Widget _buildBox(String text, Color color, {double? width}) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
