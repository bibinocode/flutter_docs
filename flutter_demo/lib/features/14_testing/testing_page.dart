import 'package:flutter/material.dart';

/// 测试模块页面
class TestingPage extends StatelessWidget {
  const TestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('测试')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('🧪', '单元测试', '测试单个函数、方法的逻辑正确性'),
          _buildInfoCard('🔧', 'Widget 测试', '测试 UI 组件的渲染和交互'),
          _buildInfoCard('📱', '集成测试', '测试完整应用流程，模拟真实使用场景'),
          _buildInfoCard('🎭', 'Mock 测试', '使用 Mockito 模拟依赖项'),
          _buildInfoCard('📊', '覆盖率', '测量代码被测试覆盖的百分比'),
          _buildInfoCard('🔄', 'CI/CD', '自动化测试和持续集成'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '测试金字塔',
            child: Column(children: [_buildPyramidLevel('集成测试', Colors.red, 0.4, '少量'), const SizedBox(height: 8), _buildPyramidLevel('Widget 测试', Colors.orange, 0.6, '适中'), const SizedBox(height: 8), _buildPyramidLevel('单元测试', Colors.green, 1.0, '大量')]),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '单元测试示例',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
              child: const Text('''
import 'package:test/test.dart';

void main() {
  group('Calculator', () {
    test('add should return sum', () {
      expect(add(2, 3), equals(5));
    });
    
    test('subtract should return difference', () {
      expect(subtract(5, 3), equals(2));
    });
  });
}''', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Widget 测试示例',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
              child: const Text('''
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments', (tester) async {
    await tester.pumpWidget(MyApp());
    
    expect(find.text('0'), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    
    expect(find.text('1'), findsOneWidget);
  });
}''', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '常用测试命令',
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_CommandRow('运行所有测试', 'flutter test'), _CommandRow('运行单个文件', 'flutter test test/xxx_test.dart'), _CommandRow('查看覆盖率', 'flutter test --coverage'), _CommandRow('集成测试', 'flutter test integration_test')]),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '测试最佳实践',
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('✅ 测试名称要描述预期行为'), SizedBox(height: 8), Text('✅ 每个测试只测一个功能点'), SizedBox(height: 8), Text('✅ 使用 AAA 模式: Arrange, Act, Assert'), SizedBox(height: 8), Text('✅ Mock 外部依赖（网络、数据库）'), SizedBox(height: 8), Text('✅ 保持测试独立，不依赖执行顺序')]),
          ),
        ],
      ),
    );
  }

  Widget _buildPyramidLevel(String text, Color color, double widthFactor, String amount) {
    return Row(
      children: [
        Expanded(
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(amount, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildInfoCard(String emoji, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
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

class _CommandRow extends StatelessWidget {
  final String label;
  final String command;

  const _CommandRow(this.label, this.command);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
              child: Text(command, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
