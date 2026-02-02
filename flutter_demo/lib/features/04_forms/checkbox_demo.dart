import 'package:flutter/material.dart';

/// 复选框和开关演示页面
class CheckboxDemoPage extends StatefulWidget {
  const CheckboxDemoPage({super.key});

  @override
  State<CheckboxDemoPage> createState() => _CheckboxDemoPageState();
}

class _CheckboxDemoPageState extends State<CheckboxDemoPage> {
  bool _basicCheck = false;
  bool _switchValue = false;
  bool? _triState;

  final List<Map<String, dynamic>> _hobbies = [
    {'name': '阅读', 'checked': true},
    {'name': '音乐', 'checked': false},
    {'name': '运动', 'checked': true},
    {'name': '旅行', 'checked': false},
    {'name': '编程', 'checked': true},
  ];

  final List<Map<String, dynamic>> _settings = [
    {'title': '推送通知', 'subtitle': '接收新消息推送', 'value': true},
    {'title': '深色模式', 'subtitle': '使用深色主题', 'value': false},
    {'title': '自动更新', 'subtitle': '自动下载最新版本', 'value': true},
    {'title': '数据同步', 'subtitle': '同步到云端', 'value': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkbox & Switch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '基础 Checkbox',
              child: Row(
                children: [
                  Checkbox(value: _basicCheck, onChanged: (value) => setState(() => _basicCheck = value!)),
                  Text(_basicCheck ? '已选中' : '未选中'),
                  const SizedBox(width: 32),
                  Checkbox(
                    value: true,
                    onChanged: null,
                    // 禁用状态
                  ),
                  const Text('禁用', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '三态 Checkbox',
              child: Row(
                children: [
                  Checkbox(tristate: true, value: _triState, onChanged: (value) => setState(() => _triState = value)),
                  Text(_triState == null ? '不确定' : (_triState! ? '选中' : '未选中')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'CheckboxListTile',
              child: Card(
                child: Column(
                  children: _hobbies.asMap().entries.map((entry) {
                    final index = entry.key;
                    final hobby = entry.value;
                    return CheckboxListTile(
                      title: Text(hobby['name']),
                      subtitle: Text('兴趣爱好 ${index + 1}'),
                      value: hobby['checked'],
                      secondary: Icon(_getHobbyIcon(hobby['name']), color: Theme.of(context).colorScheme.primary),
                      onChanged: (value) {
                        setState(() => _hobbies[index]['checked'] = value);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '基础 Switch',
              child: Row(
                children: [
                  Switch(value: _switchValue, onChanged: (value) => setState(() => _switchValue = value)),
                  Text(_switchValue ? '开启' : '关闭'),
                  const SizedBox(width: 32),
                  Switch(value: true, onChanged: null),
                  const Text('禁用', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'SwitchListTile',
              child: Card(
                child: Column(
                  children: _settings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final setting = entry.value;
                    return SwitchListTile(
                      title: Text(setting['title']),
                      subtitle: Text(setting['subtitle']),
                      value: setting['value'],
                      secondary: Icon(_getSettingIcon(setting['title']), color: Theme.of(context).colorScheme.primary),
                      onChanged: (value) {
                        setState(() => _settings[index]['value'] = value);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '自定义样式',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Checkbox(value: true, onChanged: (_) {}, activeColor: Colors.green, checkColor: Colors.white),
                      Checkbox(
                        value: true,
                        onChanged: (_) {},
                        activeColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      Checkbox(value: true, onChanged: (_) {}, activeColor: Colors.purple, shape: const CircleBorder()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Switch(value: true, onChanged: (_) {}, activeColor: Colors.green, activeTrackColor: Colors.green.withOpacity(0.5)),
                      Switch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: Colors.orange,
                        thumbIcon: WidgetStateProperty.resolveWith((states) {
                          return states.contains(WidgetState.selected) ? const Icon(Icons.check, color: Colors.white, size: 16) : const Icon(Icons.close, size: 16);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(context, title: 'Radio 单选', child: _RadioDemo()),
          ],
        ),
      ),
    );
  }

  IconData _getHobbyIcon(String name) {
    switch (name) {
      case '阅读':
        return Icons.book;
      case '音乐':
        return Icons.music_note;
      case '运动':
        return Icons.sports_basketball;
      case '旅行':
        return Icons.flight;
      case '编程':
        return Icons.code;
      default:
        return Icons.star;
    }
  }

  IconData _getSettingIcon(String title) {
    switch (title) {
      case '推送通知':
        return Icons.notifications;
      case '深色模式':
        return Icons.dark_mode;
      case '自动更新':
        return Icons.system_update;
      case '数据同步':
        return Icons.sync;
      default:
        return Icons.settings;
    }
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
        child,
      ],
    );
  }
}

class _RadioDemo extends StatefulWidget {
  @override
  State<_RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<_RadioDemo> {
  String _selectedGender = 'male';
  int _selectedPlan = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Radio<String>(value: 'male', groupValue: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value!)),
            const Text('男'),
            Radio<String>(value: 'female', groupValue: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value!)),
            const Text('女'),
            Radio<String>(value: 'other', groupValue: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value!)),
            const Text('其他'),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              RadioListTile<int>(title: const Text('基础版'), subtitle: const Text('免费 - 基础功能'), value: 0, groupValue: _selectedPlan, secondary: const Icon(Icons.star_border), onChanged: (value) => setState(() => _selectedPlan = value!)),
              RadioListTile<int>(title: const Text('专业版'), subtitle: const Text('¥29/月 - 高级功能'), value: 1, groupValue: _selectedPlan, secondary: const Icon(Icons.star_half), onChanged: (value) => setState(() => _selectedPlan = value!)),
              RadioListTile<int>(title: const Text('企业版'), subtitle: const Text('¥99/月 - 全部功能'), value: 2, groupValue: _selectedPlan, secondary: const Icon(Icons.star), onChanged: (value) => setState(() => _selectedPlan = value!)),
            ],
          ),
        ),
      ],
    );
  }
}
