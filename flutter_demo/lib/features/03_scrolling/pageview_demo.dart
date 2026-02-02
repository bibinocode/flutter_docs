import 'package:flutter/material.dart';

/// PageView 演示页面
class PageViewDemoPage extends StatefulWidget {
  const PageViewDemoPage({super.key});

  @override
  State<PageViewDemoPage> createState() => _PageViewDemoPageState();
}

class _PageViewDemoPageState extends State<PageViewDemoPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {'color': Colors.blue, 'title': '欢迎使用', 'icon': Icons.waving_hand, 'desc': '这是一个 PageView 演示'},
    {'color': Colors.green, 'title': '探索功能', 'icon': Icons.explore, 'desc': '左右滑动切换页面'},
    {'color': Colors.orange, 'title': '开始使用', 'icon': Icons.rocket_launch, 'desc': '点击下方按钮开始'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageView')),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return _buildPage(page);
              },
            ),
          ),
          _buildIndicators(),
          _buildControls(),
          const SizedBox(height: 16),
          _buildVerticalPageViewSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PageView 页面视图', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('支持水平/垂直滑动切换', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text('${_currentPage + 1}/${_pages.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: page['color'],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: (page['color'] as Color).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page['icon'], size: 80, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            page['title'],
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(page['desc'], style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey[300], borderRadius: BorderRadius.circular(4)),
          );
        }),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _currentPage > 0 ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut) : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('上一页'),
          ),
          FilledButton(
            onPressed: _currentPage < _pages.length - 1
                ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('开始使用！')));
                  },
            child: Text(_currentPage < _pages.length - 1 ? '下一页' : '完成'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalPageViewSection() {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('垂直 PageView', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: PageView(scrollDirection: Axis.vertical, children: [_buildVerticalCard(Colors.purple, '向上滑动'), _buildVerticalCard(Colors.teal, '继续滑动'), _buildVerticalCard(Colors.pink, '最后一页')]),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalCard(Color color, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
