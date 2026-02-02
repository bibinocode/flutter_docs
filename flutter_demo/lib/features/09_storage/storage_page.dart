import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 数据存储模块页面
class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  String _savedValue = '';
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedValue();
  }

  Future<void> _loadSavedValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedValue = prefs.getString('demo_key') ?? '(暂无保存的数据)';
    });
  }

  Future<void> _saveValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('demo_key', _textController.text);
    _loadSavedValue();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功!')));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据存储')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('📝', 'SharedPreferences', '轻量级键值对存储，适合存储简单配置'),
          _buildInfoCard('📦', 'Hive', '高性能 NoSQL 数据库，支持加密，无需原生依赖'),
          _buildInfoCard('🗄️', 'SQLite', '关系型数据库，适合复杂查询'),
          _buildInfoCard('📁', '文件存储', '使用 path_provider 获取路径，读写文件'),
          _buildInfoCard('🔐', '安全存储', 'flutter_secure_storage 加密存储敏感数据'),
          _buildInfoCard('☁️', '云存储', 'Firebase Storage, 云对象存储'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'SharedPreferences 演示',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已保存的值: $_savedValue', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: '输入要保存的内容', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(onPressed: _saveValue, icon: const Icon(Icons.save), label: const Text('保存')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '存储方案对比',
            child: Table(
              border: TableBorder.all(color: Theme.of(context).dividerColor),
              children: const [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('方案', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('适用场景', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('SharedPreferences')),
                    Padding(padding: EdgeInsets.all(8), child: Text('配置项、简单状态')),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('Hive')),
                    Padding(padding: EdgeInsets.all(8), child: Text('对象存储、离线数据')),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('SQLite')),
                    Padding(padding: EdgeInsets.all(8), child: Text('复杂查询、大量数据')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
