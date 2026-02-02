import 'package:flutter/material.dart';

/// Icon 图标组件 Demo
class IconDemoPage extends StatelessWidget {
  const IconDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Icon 图标')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'Material Icons 基础',
              child: Wrap(spacing: 16, runSpacing: 16, children: const [Icon(Icons.home), Icon(Icons.search), Icon(Icons.settings), Icon(Icons.favorite), Icon(Icons.person), Icon(Icons.notifications), Icon(Icons.shopping_cart), Icon(Icons.camera_alt)]),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '图标尺寸',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Column(
                    children: [
                      Icon(Icons.star, size: 16),
                      SizedBox(height: 4),
                      Text('16', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.star, size: 24),
                      SizedBox(height: 4),
                      Text('24', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.star, size: 32),
                      SizedBox(height: 4),
                      Text('32', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.star, size: 48),
                      SizedBox(height: 4),
                      Text('48', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.star, size: 64),
                      SizedBox(height: 4),
                      Text('64', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '图标颜色',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  Icon(Icons.favorite, color: Colors.pink),
                  Icon(Icons.favorite, color: Colors.purple),
                  Icon(Icons.favorite, color: Colors.blue),
                  Icon(Icons.favorite, color: Colors.green),
                  Icon(Icons.favorite, color: Colors.orange),
                  Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
                  Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'Outlined / Rounded / Sharp 风格',
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.home, size: 32),
                          SizedBox(height: 4),
                          Text('Filled', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.home_outlined, size: 32),
                          SizedBox(height: 4),
                          Text('Outlined', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.home_rounded, size: 32),
                          SizedBox(height: 4),
                          Text('Rounded', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.home_sharp, size: 32),
                          SizedBox(height: 4),
                          Text('Sharp', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.settings, size: 32),
                          SizedBox(height: 4),
                          Text('Filled', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.settings_outlined, size: 32),
                          SizedBox(height: 4),
                          Text('Outlined', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.settings_rounded, size: 32),
                          SizedBox(height: 4),
                          Text('Rounded', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.settings_sharp, size: 32),
                          SizedBox(height: 4),
                          Text('Sharp', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '图标容器',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 圆形背景
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                    child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  // 圆角矩形背景
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.mail, color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                  // 边框圆形
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                    ),
                    child: const Icon(Icons.add),
                  ),
                  // 渐变背景
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue, Colors.purple], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flash_on, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '常用图标分类',
              child: Column(
                children: [
                  _buildIconRow('导航', [Icons.home, Icons.arrow_back, Icons.arrow_forward, Icons.menu, Icons.close, Icons.more_vert]),
                  const SizedBox(height: 16),
                  _buildIconRow('操作', [Icons.add, Icons.edit, Icons.delete, Icons.share, Icons.copy, Icons.save]),
                  const SizedBox(height: 16),
                  _buildIconRow('状态', [Icons.check, Icons.error, Icons.warning, Icons.info, Icons.help, Icons.block]),
                  const SizedBox(height: 16),
                  _buildIconRow('社交', [Icons.favorite, Icons.thumb_up, Icons.comment, Icons.send, Icons.person, Icons.group]),
                  const SizedBox(height: 16),
                  _buildIconRow('媒体', [Icons.play_arrow, Icons.pause, Icons.stop, Icons.skip_next, Icons.volume_up, Icons.fullscreen]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'ImageIcon 自定义图标',
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 使用 ImageIcon 加载网络图标
                  ImageIcon(NetworkImage('https://img.icons8.com/ios/50/000000/flutter.png'), size: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(context, title: '动态图标', child: const _AnimatedIconDemo()),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ],
    );
  }

  Widget _buildIconRow(String label, List<IconData> icons) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: icons.map((icon) => Icon(icon, size: 24)).toList()),
        ),
      ],
    );
  }
}

class _AnimatedIconDemo extends StatefulWidget {
  const _AnimatedIconDemo();

  @override
  State<_AnimatedIconDemo> createState() => _AnimatedIconDemoState();
}

class _AnimatedIconDemoState extends State<_AnimatedIconDemo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isPlaying) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            IconButton(
              iconSize: 48,
              onPressed: _toggle,
              icon: AnimatedIcon(icon: AnimatedIcons.play_pause, progress: _controller),
            ),
            const Text('play_pause', style: TextStyle(fontSize: 12)),
          ],
        ),
        Column(
          children: [
            IconButton(
              iconSize: 48,
              onPressed: _toggle,
              icon: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _controller),
            ),
            const Text('menu_close', style: TextStyle(fontSize: 12)),
          ],
        ),
        Column(
          children: [
            IconButton(
              iconSize: 48,
              onPressed: _toggle,
              icon: AnimatedIcon(icon: AnimatedIcons.add_event, progress: _controller),
            ),
            const Text('add_event', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
