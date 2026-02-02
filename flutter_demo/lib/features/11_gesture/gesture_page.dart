import 'package:flutter/material.dart';

/// 手势处理模块页面
class GesturePage extends StatefulWidget {
  const GesturePage({super.key});

  @override
  State<GesturePage> createState() => _GesturePageState();
}

class _GesturePageState extends State<GesturePage> {
  String _lastGesture = '等待手势...';
  Offset _position = const Offset(100, 100);
  double _scale = 1.0;
  double _rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手势处理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('👆', 'GestureDetector', '核心手势组件，支持点击、双击、长按等'),
          _buildInfoCard('🖐️', 'InkWell', '带 Material 水波纹效果的点击'),
          _buildInfoCard('👋', 'Draggable', '拖拽组件，支持拖放操作'),
          _buildInfoCard('✌️', 'ScaleGesture', '缩放手势，双指缩放'),
          _buildInfoCard('🔄', 'RotationGesture', '旋转手势，双指旋转'),
          _buildInfoCard('📜', 'Scrollable', '滚动手势，自定义滚动行为'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '点击手势演示',
            child: Column(
              children: [
                Text(_lastGesture, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    GestureDetector(onTap: () => setState(() => _lastGesture = '单击'), child: _buildGestureBox('单击', Colors.blue)),
                    GestureDetector(onDoubleTap: () => setState(() => _lastGesture = '双击'), child: _buildGestureBox('双击', Colors.green)),
                    GestureDetector(onLongPress: () => setState(() => _lastGesture = '长按'), child: _buildGestureBox('长按', Colors.orange)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '拖拽手势演示',
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Positioned(
                    left: _position.dx,
                    top: _position.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _position = Offset((_position.dx + details.delta.dx).clamp(0, 200), (_position.dy + details.delta.dy).clamp(0, 130));
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: const Center(child: Icon(Icons.open_with, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '缩放/旋转手势演示',
            child: Column(
              children: [
                const Text('使用双指进行缩放和旋转', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                GestureDetector(
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = details.scale.clamp(0.5, 3.0);
                      _rotation = details.rotation;
                    });
                  },
                  child: Transform.scale(
                    scale: _scale,
                    child: Transform.rotate(
                      angle: _rotation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.pink, Colors.purple]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Icon(Icons.zoom_out_map, color: Colors.white, size: 40)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('缩放: ${_scale.toStringAsFixed(2)}x  旋转: ${(_rotation * 180 / 3.14159).toStringAsFixed(0)}°'),
                TextButton(
                  onPressed: () => setState(() {
                    _scale = 1.0;
                    _rotation = 0.0;
                  }),
                  child: const Text('重置'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureBox(String text, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
            child: Center(child: child),
          ),
        ),
      ],
    );
  }
}
