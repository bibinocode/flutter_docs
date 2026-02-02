import 'package:flutter/material.dart';

/// TabBar 演示页面
class TabsDemoPage extends StatelessWidget {
  const TabsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TabBar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '基础', icon: Icon(Icons.article)),
              Tab(text: '样式', icon: Icon(Icons.palette)),
              Tab(text: '滚动', icon: Icon(Icons.swipe)),
            ],
          ),
        ),
        body: const TabBarView(children: [_BasicTabDemo(), _StyledTabDemo(), _ScrollableTabDemo()]),
      ),
    );
  }
}

class _BasicTabDemo extends StatelessWidget {
  const _BasicTabDemo();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('基础 TabBar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('核心组件：'), const SizedBox(height: 8), _buildCodeItem('DefaultTabController', '管理 Tab 状态'), _buildCodeItem('TabBar', '显示 Tab 标签'), _buildCodeItem('TabBarView', '显示 Tab 内容'), _buildCodeItem('Tab', '单个标签项')]),
            ),
          ),
          const SizedBox(height: 24),
          Text('使用示例', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
            child: const Text('''
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      bottom: TabBar(
        tabs: [
          Tab(text: 'Tab 1'),
          Tab(text: 'Tab 2'),
          Tab(text: 'Tab 3'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Page1(),
        Page2(),
        Page3(),
      ],
    ),
  ),
)''', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
          const SizedBox(height: 24),
          _NestedTabDemo(),
        ],
      ),
    );
  }

  Widget _buildCodeItem(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(
              name,
              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Text(desc),
        ],
      ),
    );
  }
}

class _NestedTabDemo extends StatefulWidget {
  @override
  State<_NestedTabDemo> createState() => _NestedTabDemoState();
}

class _NestedTabDemoState extends State<_NestedTabDemo> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('手动控制 TabController', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '首页'),
              Tab(text: '分类'),
              Tab(text: '消息'),
              Tab(text: '我的'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: TabBarView(controller: _tabController, children: [_buildTabContent('首页内容', Icons.home), _buildTabContent('分类内容', Icons.category), _buildTabContent('消息内容', Icons.message), _buildTabContent('我的内容', Icons.person)]),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonal(onPressed: () => _tabController.animateTo(0), child: const Text('首页')),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () {
                if (_tabController.index > 0) {
                  _tabController.animateTo(_tabController.index - 1);
                }
              },
              child: const Text('上一个'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () {
                if (_tabController.index < 3) {
                  _tabController.animateTo(_tabController.index + 1);
                }
              },
              child: const Text('下一个'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabContent(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _StyledTabDemo extends StatelessWidget {
  const _StyledTabDemo();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('自定义样式', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // 圆角背景
            Text('圆角背景', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(25)),
              child: TabBar(
                indicator: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(25)),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '日'),
                  Tab(text: '周'),
                  Tab(text: '月'),
                ],
              ),
            ),
            const SizedBox(height: 100),

            // 下划线指示器
            Text('自定义指示器', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TabBar(
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 4, color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(2),
              ),
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '热门'),
                Tab(text: '推荐'),
                Tab(text: '关注'),
              ],
            ),
            const SizedBox(height: 100),

            // 只有图标
            Text('图标标签', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.image)),
                Tab(icon: Icon(Icons.videocam)),
                Tab(icon: Icon(Icons.mic)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollableTabDemo extends StatelessWidget {
  const _ScrollableTabDemo();

  @override
  Widget build(BuildContext context) {
    final categories = ['全部', '手机', '电脑', '平板', '耳机', '手表', '配件', '家电', '服装', '食品'];

    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: categories.map((c) => Tab(text: c)).toList(),
            ),
          ),
          Expanded(child: TabBarView(children: categories.map((category) => _buildCategoryContent(context, category)).toList())),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(BuildContext context, String category) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Icon(Icons.shopping_bag, size: 48, color: Colors.primaries[index % Colors.primaries.length]),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$category 商品 ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '¥${(index + 1) * 99}',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
