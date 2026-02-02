import 'package:flutter/material.dart';

/// 网络请求模块页面
class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  String _responseText = '点击按钮发起请求';
  bool _isLoading = false;

  Future<void> _simulateRequest() async {
    setState(() {
      _isLoading = true;
      _responseText = '加载中...';
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _responseText = '{\n  "code": 200,\n  "message": "请求成功",\n  "data": {\n    "id": 1,\n    "name": "Flutter"\n  }\n}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('网络请求')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('🌐', 'Dio 库', 'Flutter 最流行的 HTTP 客户端，支持拦截器、FormData、取消请求等'),
          _buildInfoCard('🔗', 'REST API', 'GET/POST/PUT/DELETE 请求，JSON 序列化与反序列化'),
          _buildInfoCard('🔄', '拦截器', '请求/响应拦截器，统一处理 Token、错误等'),
          _buildInfoCard('📦', '数据模型', 'JSON 转 Dart 对象，使用 json_serializable 或手动解析'),
          _buildInfoCard('⚡', '并发请求', 'Future.wait 并发，Isolate 处理大数据'),
          _buildInfoCard('🔐', '安全通信', 'HTTPS 证书校验，请求签名'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '请求演示',
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: _isLoading ? null : _simulateRequest,
                  icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_download),
                  label: Text(_isLoading ? '请求中...' : '发起 GET 请求'),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                  child: Text(_responseText, style: const TextStyle(fontFamily: 'monospace')),
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
