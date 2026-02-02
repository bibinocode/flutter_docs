import 'package:flutter/material.dart';

/// Button 按钮组件 Demo
class ButtonDemoPage extends StatelessWidget {
  const ButtonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Button 按钮')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'ElevatedButton 凸起按钮',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text('默认按钮')),
                  ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('带图标')),
                  const ElevatedButton(onPressed: null, child: Text('禁用状态')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'FilledButton 填充按钮',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(onPressed: () {}, child: const Text('填充按钮')),
                  FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.send), label: const Text('发送')),
                  FilledButton.tonal(onPressed: () {}, child: const Text('柔和填充')),
                  FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.favorite), label: const Text('收藏')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'OutlinedButton 边框按钮',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('边框按钮')),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('下载')),
                  const OutlinedButton(onPressed: null, child: Text('禁用状态')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'TextButton 文本按钮',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  TextButton(onPressed: () {}, child: const Text('文本按钮')),
                  TextButton.icon(onPressed: () {}, icon: const Icon(Icons.info), label: const Text('了解更多')),
                  const TextButton(onPressed: null, child: Text('禁用状态')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'IconButton 图标按钮',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
                  IconButton.filled(onPressed: () {}, icon: const Icon(Icons.add)),
                  IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.edit)),
                  IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.delete)),
                  const IconButton(onPressed: null, icon: Icon(Icons.block)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'FloatingActionButton 悬浮按钮',
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FloatingActionButton.small(heroTag: 'fab1', onPressed: () {}, child: const Icon(Icons.add)),
                  FloatingActionButton(heroTag: 'fab2', onPressed: () {}, child: const Icon(Icons.add)),
                  FloatingActionButton.large(heroTag: 'fab3', onPressed: () {}, child: const Icon(Icons.add)),
                  FloatingActionButton.extended(heroTag: 'fab4', onPressed: () {}, icon: const Icon(Icons.navigation), label: const Text('导航')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '按钮尺寸自定义',
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(onPressed: () {}, child: const Text('全宽大按钮')),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(onPressed: () {}, child: const Text('固定宽度按钮')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '按钮样式自定义',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('红色按钮'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('圆角按钮'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(elevation: 8, shadowColor: Colors.blue),
                    child: const Text('阴影按钮'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      foregroundColor: Colors.green,
                    ),
                    child: const Text('绿色边框'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(context, title: '按钮组 SegmentedButton', child: _SegmentedButtonDemo()),
            const SizedBox(height: 24),

            _buildSection(context, title: '加载状态按钮', child: const _LoadingButtonDemo()),
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
}

class _SegmentedButtonDemo extends StatefulWidget {
  @override
  State<_SegmentedButtonDemo> createState() => _SegmentedButtonDemoState();
}

class _SegmentedButtonDemoState extends State<_SegmentedButtonDemo> {
  Set<String> _selected = {'day'};

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'day', label: Text('日'), icon: Icon(Icons.calendar_today)),
        ButtonSegment(value: 'week', label: Text('周'), icon: Icon(Icons.calendar_view_week)),
        ButtonSegment(value: 'month', label: Text('月'), icon: Icon(Icons.calendar_month)),
      ],
      selected: _selected,
      onSelectionChanged: (newSelection) {
        setState(() {
          _selected = newSelection;
        });
      },
    );
  }
}

class _LoadingButtonDemo extends StatefulWidget {
  const _LoadingButtonDemo();

  @override
  State<_LoadingButtonDemo> createState() => _LoadingButtonDemoState();
}

class _LoadingButtonDemoState extends State<_LoadingButtonDemo> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('点击加载'),
    );
  }
}
