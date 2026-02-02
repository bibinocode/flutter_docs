import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

/// Image 图片组件 Demo
class ImageDemoPage extends StatelessWidget {
  const ImageDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image 图片')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '网络图片',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://picsum.photos/400/200',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(width: double.infinity, height: 200, color: Colors.grey[200], child: const Icon(Icons.error, size: 48));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '缓存网络图片 (CachedNetworkImage)',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: 'https://picsum.photos/400/200?random=1',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(width: double.infinity, height: 200, color: Colors.grey[200], child: const Icon(Icons.error, size: 48)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'BoxFit 填充模式',
              child: Column(children: [_buildFitDemo('BoxFit.fill', BoxFit.fill), const SizedBox(height: 12), _buildFitDemo('BoxFit.contain', BoxFit.contain), const SizedBox(height: 12), _buildFitDemo('BoxFit.cover', BoxFit.cover), const SizedBox(height: 12), _buildFitDemo('BoxFit.fitWidth', BoxFit.fitWidth), const SizedBox(height: 12), _buildFitDemo('BoxFit.fitHeight', BoxFit.fitHeight)]),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '圆形头像',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // CircleAvatar
                  const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://picsum.photos/100/100?random=2')),
                  // ClipOval
                  ClipOval(child: Image.network('https://picsum.photos/100/100?random=3', width: 80, height: 80, fit: BoxFit.cover)),
                  // Container + BoxDecoration
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(image: NetworkImage('https://picsum.photos/100/100?random=4'), fit: BoxFit.cover),
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '圆角图片',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ClipRRect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network('https://picsum.photos/100/100?random=5', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  // Container + BoxDecoration
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(image: NetworkImage('https://picsum.photos/100/100?random=6'), fit: BoxFit.cover),
                    ),
                  ),
                  // 不同角度圆角
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                    child: Image.network('https://picsum.photos/100/100?random=7', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '图片滤镜效果',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 灰度滤镜
                  Column(
                    children: [
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network('https://picsum.photos/80/80?random=8', width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('灰度', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  // 颜色叠加
                  Column(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.5), BlendMode.color),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network('https://picsum.photos/80/80?random=9', width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('蓝色调', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  // 透明度
                  Column(
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network('https://picsum.photos/80/80?random=10', width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('半透明', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: 'FadeInImage 渐入效果',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: 'https://picsum.photos/400/200?random=11', width: double.infinity, height: 200, fit: BoxFit.cover, fadeInDuration: const Duration(milliseconds: 500)),
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
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ],
    );
  }

  Widget _buildFitDemo(String label, BoxFit fit) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12))),
        Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Image.network('https://picsum.photos/200/100?random=fit', fit: fit),
        ),
      ],
    );
  }
}

// 透明图片占位
final Uint8List kTransparentImage = Uint8List.fromList(<int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82]);
