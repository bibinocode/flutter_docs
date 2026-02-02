import 'package:flutter/material.dart';

/// 权限处理模块页面
class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限处理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard('📷', '相机权限', '拍照、录像功能所需权限'),
          _buildInfoCard('🎤', '麦克风权限', '录音、语音识别所需权限'),
          _buildInfoCard('📍', '位置权限', '获取用户地理位置，分为粗略和精确'),
          _buildInfoCard('🖼️', '相册权限', '访问设备照片和视频'),
          _buildInfoCard('📞', '通讯录权限', '读取联系人信息'),
          _buildInfoCard('📅', '日历权限', '读写日历事件'),
          _buildInfoCard('💬', '通知权限', '发送本地和推送通知'),
          _buildInfoCard('🔵', '蓝牙权限', '扫描和连接蓝牙设备'),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'permission_handler 库',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flutter 最常用的权限处理库', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('主要功能:'),
                SizedBox(height: 8),
                Text('✅ 检查权限状态'),
                Text('✅ 请求权限'),
                Text('✅ 打开设置页面'),
                Text('✅ 跨平台支持 (iOS/Android)'),
                SizedBox(height: 12),
                Text('权限状态:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• granted - 已授权'),
                Text('• denied - 已拒绝（可再次请求）'),
                Text('• permanentlyDenied - 永久拒绝'),
                Text('• restricted - 受限（iOS）'),
                Text('• limited - 有限访问（iOS 相册）'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '权限请求演示',
            child: Column(children: [_buildPermissionTile(context, Icons.camera_alt, '相机', '拍照功能'), _buildPermissionTile(context, Icons.mic, '麦克风', '录音功能'), _buildPermissionTile(context, Icons.location_on, '位置', '定位功能'), _buildPermissionTile(context, Icons.photo_library, '相册', '图片选择')]),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '最佳实践',
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('1️⃣ 按需请求: 只在需要时请求权限'), SizedBox(height: 8), Text('2️⃣ 解释原因: 在请求前告知用户为什么需要'), SizedBox(height: 8), Text('3️⃣ 优雅降级: 权限被拒绝时提供替代方案'), SizedBox(height: 8), Text('4️⃣ 引导设置: 永久拒绝时引导用户到设置页')]),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: FilledButton.tonal(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('模拟请求 $title 权限')));
        },
        child: const Text('请求'),
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
