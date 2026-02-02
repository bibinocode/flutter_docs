import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 平台相关模块页面
class PlatformPage extends StatelessWidget {
  const PlatformPage({super.key});

  String get _currentPlatform {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('平台相关')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('📱', 'iOS 适配', 'Cupertino 风格组件、Safe Area、状态栏'),
          _buildInfoCard('🤖', 'Android 适配', 'Material 风格、返回键处理、通知渠道'),
          _buildInfoCard('🖥️', 'Desktop 适配', 'macOS/Windows/Linux，窗口管理、快捷键'),
          _buildInfoCard('🌐', 'Web 适配', 'URL 路由、SEO、响应式布局'),
          _buildInfoCard('📐', '响应式布局', 'MediaQuery、LayoutBuilder、自适应设计'),
          _buildInfoCard('🔌', '平台通道', 'MethodChannel 调用原生代码'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '当前平台',
            child: Column(
              children: [
                Icon(_getPlatformIcon(), size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(_currentPlatform, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!kIsWeb) ...[Text('操作系统版本: ${Platform.operatingSystemVersion}'), Text('Dart 版本: ${Platform.version.split(' ').first}')],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '平台判断示例',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlatformCheck('kIsWeb', kIsWeb),
                if (!kIsWeb) ...[_buildPlatformCheck('Platform.isAndroid', Platform.isAndroid), _buildPlatformCheck('Platform.isIOS', Platform.isIOS), _buildPlatformCheck('Platform.isMacOS', Platform.isMacOS), _buildPlatformCheck('Platform.isWindows', Platform.isWindows), _buildPlatformCheck('Platform.isLinux', Platform.isLinux)],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '自适应组件',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('根据平台显示不同风格的组件:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          FilledButton(onPressed: () {}, child: const Text('Material')),
                          const SizedBox(height: 4),
                          const Text('Android/Web', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Cupertino', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 4),
                          const Text('iOS/macOS', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '屏幕信息',
            child: Builder(
              builder: (context) {
                final mediaQuery = MediaQuery.of(context);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('屏幕宽度: ${mediaQuery.size.width.toStringAsFixed(0)}'), Text('屏幕高度: ${mediaQuery.size.height.toStringAsFixed(0)}'), Text('像素密度: ${mediaQuery.devicePixelRatio.toStringAsFixed(2)}'), Text('安全区域上: ${mediaQuery.padding.top}'), Text('安全区域下: ${mediaQuery.padding.bottom}'), Text('文字缩放: ${mediaQuery.textScaler.scale(1.0)}')]);
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon() {
    if (kIsWeb) return Icons.web;
    if (Platform.isAndroid) return Icons.android;
    if (Platform.isIOS) return Icons.phone_iphone;
    if (Platform.isMacOS) return Icons.laptop_mac;
    if (Platform.isWindows) return Icons.desktop_windows;
    if (Platform.isLinux) return Icons.computer;
    return Icons.devices;
  }

  Widget _buildPlatformCheck(String name, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(value ? Icons.check_circle : Icons.cancel, color: value ? Colors.green : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(name),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ],
    );
  }
}
