import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 计数器状态 Notifier
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(() => CounterNotifier());

// 用户列表 Provider
final usersProvider = FutureProvider<List<String>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return ['张三', '李四', '王五', '赵六'];
});

/// Riverpod 状态管理模块页面
class RiverpodPage extends ConsumerWidget {
  const RiverpodPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod 状态管理')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'NotifierProvider 计数器',
              child: Column(
                children: [
                  Text('$counter', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(onPressed: () => ref.read(counterProvider.notifier).decrement(), icon: const Icon(Icons.remove), label: const Text('减少')),
                      const SizedBox(width: 16),
                      FilledButton.icon(onPressed: () => ref.read(counterProvider.notifier).increment(), icon: const Icon(Icons.add), label: const Text('增加')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => ref.read(counterProvider.notifier).reset(), child: const Text('重置')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'FutureProvider 异步数据',
              child: users.when(
                data: (data) => Column(
                  children: data
                      .map(
                        (name) => ListTile(
                          leading: CircleAvatar(child: Text(name[0])),
                          title: Text(name),
                        ),
                      )
                      .toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('错误: $err'),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Riverpod 特点',
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('✅ 编译时安全，无运行时错误'), SizedBox(height: 8), Text('✅ 不依赖 BuildContext'), SizedBox(height: 8), Text('✅ 支持异步数据 (FutureProvider)'), SizedBox(height: 8), Text('✅ 支持流数据 (StreamProvider)'), SizedBox(height: 8), Text('✅ 自动缓存和销毁')]),
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
