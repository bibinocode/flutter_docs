import 'package:flutter/material.dart';

/// Row & Column 布局 Demo
class RowColumnDemoPage extends StatelessWidget {
  const RowColumnDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Row & Column')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, title: 'Row 水平排列', child: _buildRowDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Column 垂直排列', child: _buildColumnDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'MainAxisAlignment 主轴对齐', child: _buildMainAxisDemo()),
            const SizedBox(height: 24),
            _buildSection(context, title: 'CrossAxisAlignment 交叉轴对齐', child: _buildCrossAxisDemo()),
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

  Widget _buildRowDemo() {
    return Row(children: [_buildBox('1', Colors.red), const SizedBox(width: 8), _buildBox('2', Colors.green), const SizedBox(width: 8), _buildBox('3', Colors.blue)]);
  }

  Widget _buildColumnDemo() {
    return Column(
      children: [
        _buildBox('A', Colors.orange, width: double.infinity),
        const SizedBox(height: 8),
        _buildBox('B', Colors.purple, width: double.infinity),
        const SizedBox(height: 8),
        _buildBox('C', Colors.teal, width: double.infinity),
      ],
    );
  }

  Widget _buildMainAxisDemo() {
    return Column(
      children: [_buildAlignRow('start', MainAxisAlignment.start), const SizedBox(height: 8), _buildAlignRow('center', MainAxisAlignment.center), const SizedBox(height: 8), _buildAlignRow('end', MainAxisAlignment.end), const SizedBox(height: 8), _buildAlignRow('spaceBetween', MainAxisAlignment.spaceBetween), const SizedBox(height: 8), _buildAlignRow('spaceAround', MainAxisAlignment.spaceAround), const SizedBox(height: 8), _buildAlignRow('spaceEvenly', MainAxisAlignment.spaceEvenly)],
    );
  }

  Widget _buildAlignRow(String label, MainAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          color: Colors.grey[200],
          child: Row(mainAxisAlignment: alignment, children: [_buildBox('1', Colors.red, size: 30), _buildBox('2', Colors.green, size: 30), _buildBox('3', Colors.blue, size: 30)]),
        ),
      ],
    );
  }

  Widget _buildCrossAxisDemo() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start, children: [_buildCrossColumn('start', CrossAxisAlignment.start), _buildCrossColumn('center', CrossAxisAlignment.center), _buildCrossColumn('end', CrossAxisAlignment.end)]);
  }

  Widget _buildCrossColumn(String label, CrossAxisAlignment alignment) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 100,
          color: Colors.grey[200],
          child: Row(crossAxisAlignment: alignment, mainAxisAlignment: MainAxisAlignment.center, children: [_buildBox('', Colors.red, size: 20), _buildBox('', Colors.green, size: 30), _buildBox('', Colors.blue, size: 40)]),
        ),
      ],
    );
  }

  Widget _buildBox(String text, Color color, {double size = 50, double? width}) {
    return Container(
      width: width ?? size,
      height: size,
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
