import 'package:flutter/material.dart';

/// ListView 演示页面
class ListViewDemoPage extends StatefulWidget {
  const ListViewDemoPage({super.key});

  @override
  State<ListViewDemoPage> createState() => _ListViewDemoPageState();
}

class _ListViewDemoPageState extends State<ListViewDemoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _items = List.generate(50, (index) => '列表项 ${index + 1}');
  final List<String> _loadedItems = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadedItems.addAll(_items.take(10));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _loadedItems.length >= _items.length) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      final end = (_loadedItems.length + 10).clamp(0, _items.length);
      _loadedItems.addAll(_items.sublist(_loadedItems.length, end));
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '基础'),
            Tab(text: 'Builder'),
            Tab(text: '分隔线'),
            Tab(text: '下拉刷新'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildBasicListView(), _buildBuilderListView(), _buildSeparatedListView(), _buildRefreshListView()]),
    );
  }

  /// 基础 ListView
  Widget _buildBasicListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('ListView 基础用法', '直接传入 children，适合少量固定项'),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [_buildColorCard(Colors.red, 'Red'), _buildColorCard(Colors.orange, 'Orange'), _buildColorCard(Colors.yellow, 'Yellow'), _buildColorCard(Colors.green, 'Green'), _buildColorCard(Colors.blue, 'Blue'), _buildColorCard(Colors.indigo, 'Indigo'), _buildColorCard(Colors.purple, 'Purple')]),
        ),
      ],
    );
  }

  /// ListView.builder
  Widget _buildBuilderListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('ListView.builder', '懒加载构建，适合大量数据'),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _loadedItems.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _loadedItems.length) {
                return const Center(
                  child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                );
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(_loadedItems[index]),
                  subtitle: Text('这是第 ${index + 1} 项的描述'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('已加载 ${_loadedItems.length}/${_items.length} 项', style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  /// ListView.separated
  Widget _buildSeparatedListView() {
    final contacts = [
      {'name': '张三', 'phone': '138****1234'},
      {'name': '李四', 'phone': '139****5678'},
      {'name': '王五', 'phone': '137****9012'},
      {'name': '赵六', 'phone': '136****3456'},
      {'name': '钱七', 'phone': '135****7890'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('ListView.separated', '带分隔线的列表'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: Text(contact['name']![0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(contact['name']!),
                subtitle: Text(contact['phone']!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.message), onPressed: () {}),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 下拉刷新
  Widget _buildRefreshListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('RefreshIndicator', '下拉刷新列表'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('刷新成功！'), duration: Duration(seconds: 1)));
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 20,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.article, color: Theme.of(context).colorScheme.primary),
                    title: Text('文章标题 ${index + 1}'),
                    subtitle: Text('下拉可刷新列表 · ${DateTime.now().toString().substring(0, 16)}'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
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

  Widget _buildColorCard(Color color, String name) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
