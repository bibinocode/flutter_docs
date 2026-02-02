import 'package:flutter/material.dart';

/// Stack 层叠布局 Demo
class StackDemoPage extends StatelessWidget {
  const StackDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stack 层叠布局')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, title: '基础层叠', child: _buildBasicStack()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Positioned 定位', child: _buildPositionedStack()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Alignment 对齐', child: _buildAlignmentDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: '实际应用：图片角标', child: _buildBadgeExample()),
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

  Widget _buildBasicStack() {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Container(width: 150, height: 150, color: Colors.red),
          Container(width: 120, height: 120, color: Colors.green),
          Container(width: 90, height: 90, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildPositionedStack() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _buildBox('左上', Colors.red)),
          Positioned(top: 0, right: 0, child: _buildBox('右上', Colors.green)),
          Positioned(bottom: 0, left: 0, child: _buildBox('左下', Colors.blue)),
          Positioned(bottom: 0, right: 0, child: _buildBox('右下', Colors.orange)),
          const Positioned.fill(child: Center(child: Text('居中'))),
        ],
      ),
    );
  }

  Widget _buildAlignmentDemo() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 150, height: 150, color: Colors.grey[300]),
          Container(width: 100, height: 100, color: Colors.blue),
          Container(width: 50, height: 50, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildBadgeExample() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network('https://picsum.photos/100/100', width: 80, height: 80, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                child: const Text(
                  '图片标题',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBox(String text, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
