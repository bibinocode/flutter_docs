import 'package:flutter/material.dart';

/// Text 文本组件 Demo
class TextDemoPage extends StatelessWidget {
  const TextDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text 文本')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '基础文本',
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('这是一段普通文本'), SizedBox(height: 8), Text('这是一段较长的文本，用于演示文本换行效果。Flutter 的 Text 组件会自动处理换行，适应容器宽度。')]),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '文本样式',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('粗体文本', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('斜体文本', style: TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text('彩色文本', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  const Text('大号文本', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  const Text('下划线文本', style: TextStyle(decoration: TextDecoration.underline)),
                  const SizedBox(height: 8),
                  const Text('删除线文本', style: TextStyle(decoration: TextDecoration.lineThrough)),
                  const SizedBox(height: 8),
                  const Text('字间距调整', style: TextStyle(letterSpacing: 4)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '文本对齐',
              child: const Column(
                children: [
                  Text('左对齐（默认）', textAlign: TextAlign.left),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text('居中对齐', textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text('右对齐', textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '文本溢出处理',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('这是一段很长很长的文本，用于演示文本溢出时的省略号效果，当文本超出容器宽度时会显示省略号', maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  Text('这是一段很长很长的文本，用于演示文本溢出时的淡出效果，当文本超出容器宽度时会有淡出效果', maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                  SizedBox(height: 8),
                  Text('限制两行显示的文本，超出部分显示省略号。这是第一行内容，这是第二行内容，这是第三行内容（不显示）', maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '富文本 RichText',
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(text: '这是'),
                    TextSpan(
                      text: '红色',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '文本，这是'),
                    TextSpan(
                      text: '蓝色',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '文本，这是'),
                    TextSpan(
                      text: '大号',
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                    const TextSpan(text: '文本。'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'Text.rich 简化写法',
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '价格：'),
                    TextSpan(
                      text: '¥99.00',
                      style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' 原价：¥199.00',
                      style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(context, title: 'SelectableText 可选择文本', child: const SelectableText('这是一段可以选择复制的文本。长按可以选择文本内容进行复制。')),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '主题文本样式',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('displayLarge', style: Theme.of(context).textTheme.displayLarge),
                  Text('headlineLarge', style: Theme.of(context).textTheme.headlineLarge),
                  Text('titleLarge', style: Theme.of(context).textTheme.titleLarge),
                  Text('bodyLarge', style: Theme.of(context).textTheme.bodyLarge),
                  Text('labelLarge', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
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
