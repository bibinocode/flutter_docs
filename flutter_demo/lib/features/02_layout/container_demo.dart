import 'package:flutter/material.dart';

/// Container 容器组件 Demo
class ContainerDemoPage extends StatelessWidget {
  const ContainerDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Container 容器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, title: '尺寸与颜色', child: _buildSizeColorDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Padding 内边距', child: _buildPaddingDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Margin 外边距', child: _buildMarginDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'BoxDecoration 装饰', child: _buildDecorationDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Transform 变换', child: _buildTransformDemo()),
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

  Widget _buildSizeColorDemo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(width: 60, height: 60, color: Colors.red),
        Container(width: 80, height: 40, color: Colors.green),
        Container(width: 50, height: 80, color: Colors.blue),
      ],
    );
  }

  Widget _buildPaddingDemo() {
    return Container(
      color: Colors.blue[100],
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.blue,
        child: const Text('Padding 20', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMarginDemo() {
    return Container(
      color: Colors.green[100],
      child: Container(
        margin: const EdgeInsets.all(20),
        color: Colors.green,
        child: const Text('Margin 20', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDecorationDemo() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
          child: const Center(
            child: Text('圆角', style: TextStyle(color: Colors.white)),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
          child: const Center(
            child: Text('圆形', style: TextStyle(color: Colors.white)),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Text('边框')),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('渐变', style: TextStyle(color: Colors.white)),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Center(child: Text('阴影')),
        ),
      ],
    );
  }

  Widget _buildTransformDemo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Container(width: 60, height: 60, transform: Matrix4.rotationZ(0.2), color: Colors.red),
            const SizedBox(height: 8),
            const Text('旋转', style: TextStyle(fontSize: 12)),
          ],
        ),
        Column(
          children: [
            Container(width: 60, height: 60, transform: Matrix4.skewX(0.2), color: Colors.green),
            const SizedBox(height: 8),
            const Text('倾斜', style: TextStyle(fontSize: 12)),
          ],
        ),
        Column(
          children: [
            Transform.scale(scale: 0.8, child: Container(width: 60, height: 60, color: Colors.blue)),
            const SizedBox(height: 8),
            const Text('缩放', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
