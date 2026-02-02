import 'package:flutter/material.dart';

/// 动画模块页面
class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;

  double _sliderValue = 0.5;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeController.value = 1.0;
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动画')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('🎬', '隐式动画', 'AnimatedContainer, AnimatedOpacity 等，自动动画'),
          _buildInfoCard('🎮', '显式动画', 'AnimationController + Tween，精确控制'),
          _buildInfoCard('🌊', 'Hero 动画', '页面间共享元素过渡动画'),
          _buildInfoCard('📈', 'Curves', '缓动曲线：easeIn, easeOut, bounce 等'),
          _buildInfoCard('🎪', 'Staggered', '交错动画，多个动画按序列执行'),
          _buildInfoCard('⚡', 'Rive/Lottie', '导入专业动画文件'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'AnimatedContainer 演示',
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _isExpanded ? 200 : 100,
                    height: _isExpanded ? 200 : 100,
                    decoration: BoxDecoration(color: _isExpanded ? Colors.blue : Colors.orange, borderRadius: BorderRadius.circular(_isExpanded ? 32 : 16)),
                    child: Center(
                      child: Text(
                        _isExpanded ? '收缩' : '展开',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('点击切换'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '透明度/缩放/旋转',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeController,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('透明度'),
                      ],
                    ),
                    Column(
                      children: [
                        ScaleTransition(
                          scale: _scaleController,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('缩放'),
                      ],
                    ),
                    Column(
                      children: [
                        RotationTransition(
                          turns: _rotateController,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('旋转'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        if (_fadeController.value == 1) {
                          _fadeController.reverse();
                        } else {
                          _fadeController.forward();
                        }
                      },
                      child: const Text('切换透明度'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        if (_scaleController.value == 1) {
                          _scaleController.animateTo(0.5);
                        } else {
                          _scaleController.animateTo(1);
                        }
                      },
                      child: const Text('切换缩放'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        if (_rotateController.isAnimating) {
                          _rotateController.stop();
                        } else {
                          _rotateController.repeat();
                        }
                      },
                      child: const Text('切换旋转'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'TweenAnimationBuilder',
            child: Column(
              children: [
                Slider(value: _sliderValue, onChanged: (v) => setState(() => _sliderValue = v)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _sliderValue),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Container(
                      width: 100 + value * 100,
                      height: 50,
                      decoration: BoxDecoration(color: Color.lerp(Colors.blue, Colors.red, value), borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          '${(value * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ],
    );
  }
}
