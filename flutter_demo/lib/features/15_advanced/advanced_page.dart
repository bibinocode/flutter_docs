import 'package:flutter/material.dart';

/// 高级主题模块页面
class AdvancedPage extends StatelessWidget {
  const AdvancedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('高级主题')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('🎨', 'CustomPaint', '自定义绘制，Canvas 绑制图形、路径'),
          _buildInfoCard('🧩', 'RenderObject', '底层渲染对象，自定义布局算法'),
          _buildInfoCard('⚡', '性能优化', 'DevTools、Repaint Rainbow、const 优化'),
          _buildInfoCard('🔀', 'Isolate', '多线程并行计算，处理 CPU 密集任务'),
          _buildInfoCard('🔌', 'FFI', '调用 C/C++ 原生代码'),
          _buildInfoCard('📦', '插件开发', '开发 Flutter 插件，封装原生功能'),
          _buildInfoCard('🌍', '国际化', 'intl、arb 文件、多语言支持'),
          _buildInfoCard('♿', '无障碍', 'Semantics、屏幕阅读器支持'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'CustomPaint 示例',
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                size: const Size(double.infinity, 150),
                painter: _WavePainter(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '性能优化清单',
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_OptimizationItem('使用 const 构造函数', true), _OptimizationItem('避免在 build 中创建对象', true), _OptimizationItem('使用 ListView.builder 懒加载', true), _OptimizationItem('图片缓存和预加载', true), _OptimizationItem('使用 RepaintBoundary 隔离重绘', true), _OptimizationItem('Profile 模式下分析性能', true)]),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Isolate 使用场景',
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('• JSON 解析大量数据'), SizedBox(height: 8), Text('• 图片处理和压缩'), SizedBox(height: 8), Text('• 复杂算法计算'), SizedBox(height: 8), Text('• 文件读写操作'), SizedBox(height: 8), Text('• 数据库批量操作')]),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'DevTools 功能',
            child: Wrap(spacing: 8, runSpacing: 8, children: [_buildChip(context, 'Widget Inspector'), _buildChip(context, 'Timeline'), _buildChip(context, 'Memory'), _buildChip(context, 'Performance'), _buildChip(context, 'Network'), _buildChip(context, 'Logging')]),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '学习资源',
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📚 Flutter 源码阅读'), SizedBox(height: 8), Text('📝 Flutter 官方博客'), SizedBox(height: 8), Text('🎥 Flutter Engage 系列视频'), SizedBox(height: 8), Text('💬 Flutter 社区 Discord'), SizedBox(height: 8), Text('🔧 Flutter DevTools 实战')]),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildInfoCard(String emoji, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ],
    );
  }
}

class _OptimizationItem extends StatelessWidget {
  final String text;
  final bool checked;

  const _OptimizationItem(this.text, this.checked);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, color: checked ? Colors.green : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    for (var i = 0.0; i <= size.width; i++) {
      path.lineTo(i, size.height * 0.5 + 30 * (i / 50).sin() + 20 * ((i / 30) + 1).sin());
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // 第二层波浪
    final paint2 = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);

    for (var i = 0.0; i <= size.width; i++) {
      path2.lineTo(i, size.height * 0.6 + 20 * ((i / 40) + 2).sin() + 15 * ((i / 25) + 1).sin());
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on double {
  double sin() => _sin(this);
}

double _sin(double x) {
  // 简单的正弦近似
  x = x % (2 * 3.14159);
  double result = x;
  double term = x;
  for (int i = 1; i <= 5; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }
  return result;
}
