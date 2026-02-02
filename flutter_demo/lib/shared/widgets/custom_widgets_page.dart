import 'package:flutter/material.dart';

/// 自定义组件展示页面
class CustomWidgetsPage extends StatelessWidget {
  const CustomWidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义组件')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '渐变按钮',
            child: Center(
              child: GradientButton(
                onPressed: () {},
                gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                child: const Text('渐变按钮', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '头像徽章',
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AvatarBadge(imageUrl: 'https://i.pravatar.cc/150?img=1', badgeCount: 3),
                AvatarBadge(imageUrl: 'https://i.pravatar.cc/150?img=2', isOnline: true),
                AvatarBadge(imageUrl: 'https://i.pravatar.cc/150?img=3', badgeCount: 99),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '评分组件',
            child: const Center(child: RatingBar(rating: 3.5)),
          ),
          const SizedBox(height: 16),
          _buildSection(context, title: '骨架屏', child: const SkeletonLoader()),
          const SizedBox(height: 16),
          _buildSection(context, title: '标签输入', child: const TagInput()),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '空状态',
            child: const EmptyState(icon: Icons.inbox_outlined, title: '暂无数据', subtitle: '数据将在这里显示'),
          ),
        ],
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

/// 渐变按钮
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const GradientButton({super.key, this.onPressed, required this.gradient, required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12), this.borderRadius = const BorderRadius.all(Radius.circular(8))});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient, borderRadius: borderRadius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// 头像徽章
class AvatarBadge extends StatelessWidget {
  final String imageUrl;
  final int? badgeCount;
  final bool isOnline;
  final double size;

  const AvatarBadge({super.key, required this.imageUrl, this.badgeCount, this.isOnline = false, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(radius: size / 2, backgroundImage: NetworkImage(imageUrl)),
        if (badgeCount != null && badgeCount! > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                badgeCount! > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// 评分组件
class RatingBar extends StatefulWidget {
  final double rating;
  final int starCount;
  final double size;
  final ValueChanged<double>? onRatingChanged;

  const RatingBar({super.key, this.rating = 0, this.starCount = 5, this.size = 32, this.onRatingChanged});

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return GestureDetector(
          onTap: widget.onRatingChanged != null
              ? () {
                  setState(() => _rating = index + 1.0);
                  widget.onRatingChanged?.call(_rating);
                }
              : null,
          child: Icon(index < _rating.floor() ? Icons.star : (index < _rating ? Icons.star_half : Icons.star_border), color: Colors.amber, size: widget.size),
        );
      }),
    );
  }
}

/// 骨架屏
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildShimmer(context, width: 48, height: 48, isCircle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildShimmer(context, width: 150, height: 16), const SizedBox(height: 8), _buildShimmer(context, width: 100, height: 12)]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildShimmer(context, width: double.infinity, height: 12),
        const SizedBox(height: 8),
        _buildShimmer(context, width: double.infinity, height: 12),
        const SizedBox(height: 8),
        _buildShimmer(context, width: 200, height: 12),
      ],
    );
  }

  Widget _buildShimmer(BuildContext context, {required double height, double? width, bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: isCircle ? null : BorderRadius.circular(4), shape: isCircle ? BoxShape.circle : BoxShape.rectangle),
    );
  }
}

/// 标签输入
class TagInput extends StatefulWidget {
  const TagInput({super.key});

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final List<String> _tags = ['Flutter', 'Dart'];
  final _controller = TextEditingController();

  void _addTag() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tags.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) => Chip(label: Text(tag), onDeleted: () => setState(() => _tags.remove(tag)))).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: '输入标签', border: OutlineInputBorder(), isDense: true),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _addTag, icon: const Icon(Icons.add)),
          ],
        ),
      ],
    );
  }
}

/// 空状态
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline))],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
