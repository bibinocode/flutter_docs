import 'package:flutter/material.dart';

/// GridView 演示页面
class GridViewDemoPage extends StatefulWidget {
  const GridViewDemoPage({super.key});

  @override
  State<GridViewDemoPage> createState() => _GridViewDemoPageState();
}

class _GridViewDemoPageState extends State<GridViewDemoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _crossAxisCount = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GridView'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'count'),
            Tab(text: 'extent'),
            Tab(text: 'builder'),
            Tab(text: '瀑布流'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildCountGrid(), _buildExtentGrid(), _buildBuilderGrid(), _buildStaggeredGrid()]),
    );
  }

  /// GridView.count - 固定列数
  Widget _buildCountGrid() {
    return Column(
      children: [
        _buildHeader('GridView.count', '固定列数的网格'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('列数: '),
              ...List.generate(4, (index) {
                final count = index + 2;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$count'),
                    selected: _crossAxisCount == count,
                    onSelected: (selected) {
                      if (selected) setState(() => _crossAxisCount = count);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: _crossAxisCount,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: List.generate(20, (index) {
              return _buildGridItem(index);
            }),
          ),
        ),
      ],
    );
  }

  /// GridView.extent - 固定最大宽度
  Widget _buildExtentGrid() {
    return Column(
      children: [
        _buildHeader('GridView.extent', '固定子项最大宽度'),
        Expanded(
          child: GridView.extent(
            maxCrossAxisExtent: 150,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: List.generate(20, (index) {
              return _buildGridItem(index);
            }),
          ),
        ),
      ],
    );
  }

  /// GridView.builder - 懒加载
  Widget _buildBuilderGrid() {
    return Column(
      children: [
        _buildHeader('GridView.builder', '懒加载构建，适合大量数据'),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.8),
            itemCount: 100,
            itemBuilder: (context, index) {
              return _buildProductCard(index);
            },
          ),
        ),
      ],
    );
  }

  /// 瀑布流效果（模拟）
  Widget _buildStaggeredGrid() {
    return Column(
      children: [
        _buildHeader('瀑布流', '不同高度的网格布局（CustomScrollView + SliverGrid）'),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.7),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final height = 150.0 + (index % 3) * 50;
                    return _buildStaggeredItem(index, height);
                  }, childCount: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGridItem(int index) {
    final colors = [Colors.red, Colors.orange, Colors.green, Colors.blue, Colors.purple];
    return Container(
      decoration: BoxDecoration(color: colors[index % colors.length], borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.primaries[index % Colors.primaries.length].shade100,
              child: Center(child: Icon(Icons.image, size: 40, color: Colors.primaries[index % Colors.primaries.length])),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('商品 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(
                    '¥${(index + 1) * 10}.00',
                    style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredItem(int index, double height) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.primaries[index % Colors.primaries.length].shade200,
              child: Center(child: Icon(Icons.photo, size: 48, color: Colors.primaries[index % Colors.primaries.length])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('图片 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('瀑布流示例', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
