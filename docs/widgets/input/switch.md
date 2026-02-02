# Switch

`Switch` 是 Material Design 风格的开关组件，用于在两种状态（开/关）之间切换。它是一种直观的布尔值输入控件，常用于设置页面中控制功能的启用或禁用。

## 基本用法

```dart
bool _isEnabled = false;

Switch(
  value: _isEnabled,
  onChanged: (bool newValue) {
    setState(() {
      _isEnabled = newValue;
    });
  },
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| value | bool | 必需 | 开关当前状态，true 为开启 |
| onChanged | ValueChanged\<bool\>? | 必需 | 状态改变时的回调，为 null 时禁用 |
| activeColor | Color? | 主题色 | 开启时滑块（thumb）颜色 |
| activeTrackColor | Color? | - | 开启时轨道颜色 |
| inactiveThumbColor | Color? | - | 关闭时滑块颜色 |
| inactiveTrackColor | Color? | - | 关闭时轨道颜色 |
| thumbColor | WidgetStateProperty\<Color?\>? | - | 滑块颜色（支持多状态） |
| trackColor | WidgetStateProperty\<Color?\>? | - | 轨道颜色（支持多状态） |
| trackOutlineColor | WidgetStateProperty\<Color?\>? | - | 轨道边框颜色 |
| thumbIcon | WidgetStateProperty\<Icon?\>? | - | 滑块上的图标 |
| dragStartBehavior | DragStartBehavior | start | 拖拽开始行为 |
| mouseCursor | MouseCursor? | - | 鼠标悬停时的光标样式 |
| focusColor | Color? | - | 获得焦点时的颜色 |
| hoverColor | Color? | - | 鼠标悬停时的颜色 |
| overlayColor | WidgetStateProperty\<Color?\>? | - | 水波纹颜色 |
| splashRadius | double? | - | 水波纹半径 |
| focusNode | FocusNode? | - | 焦点控制节点 |
| autofocus | bool | false | 是否自动获取焦点 |

## 使用场景示例

### 1. 基础开关

```dart
class BasicSwitchDemo extends StatefulWidget {
  const BasicSwitchDemo({super.key});

  @override
  State<BasicSwitchDemo> createState() => _BasicSwitchDemoState();
}

class _BasicSwitchDemoState extends State<BasicSwitchDemo> {
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('WiFi'),
            const SizedBox(width: 16),
            Switch(
              value: _wifiEnabled,
              onChanged: (value) {
                setState(() {
                  _wifiEnabled = value;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('蓝牙'),
            const SizedBox(width: 16),
            Switch(
              value: _bluetoothEnabled,
              onChanged: (value) {
                setState(() {
                  _bluetoothEnabled = value;
                });
              },
            ),
          ],
        ),
        // 禁用状态的开关
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('禁用'),
            const SizedBox(width: 16),
            Switch(
              value: true,
              onChanged: null, // 设为 null 禁用开关
            ),
          ],
        ),
      ],
    );
  }
}
```

### 2. SwitchListTile 列表开关

`SwitchListTile` 将 Switch 与 ListTile 结合，适合设置列表场景：

```dart
class SwitchListTileDemo extends StatefulWidget {
  const SwitchListTileDemo({super.key});

  @override
  State<SwitchListTileDemo> createState() => _SwitchListTileDemoState();
}

class _SwitchListTileDemoState extends State<SwitchListTileDemo> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _autoUpdate = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('推送通知'),
          subtitle: const Text('接收应用推送消息'),
          secondary: const Icon(Icons.notifications),
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
          },
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('深色模式'),
          subtitle: const Text('使用深色主题'),
          secondary: const Icon(Icons.dark_mode),
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
          },
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: const Text('自动更新'),
          subtitle: const Text('在 WiFi 下自动更新应用'),
          secondary: const Icon(Icons.system_update),
          value: _autoUpdate,
          onChanged: (value) {
            setState(() {
              _autoUpdate = value;
            });
          },
        ),
        const Divider(height: 1),
        // 自适应平台样式
        SwitchListTile.adaptive(
          title: const Text('自适应开关'),
          subtitle: const Text('iOS 显示 CupertinoSwitch'),
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
          },
        ),
      ],
    );
  }
}
```

### 3. 自定义颜色

```dart
class CustomColorSwitchDemo extends StatefulWidget {
  const CustomColorSwitchDemo({super.key});

  @override
  State<CustomColorSwitchDemo> createState() => _CustomColorSwitchDemoState();
}

class _CustomColorSwitchDemoState extends State<CustomColorSwitchDemo> {
  bool _value1 = true;
  bool _value2 = false;
  bool _value3 = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 简单颜色自定义
        Switch(
          value: _value1,
          activeColor: Colors.green,
          activeTrackColor: Colors.green.shade200,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: (value) {
            setState(() => _value1 = value);
          },
        ),
        const SizedBox(height: 16),
        // 使用 WidgetStateProperty 多状态颜色
        Switch(
          value: _value2,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.orange;
            }
            return Colors.grey.shade400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.orange.shade200;
            }
            return Colors.grey.shade300;
          }),
          onChanged: (value) {
            setState(() => _value2 = value);
          },
        ),
        const SizedBox(height: 16),
        // 带轨道边框
        Switch(
          value: _value3,
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.transparent;
            }
            return Colors.grey;
          }),
          onChanged: (value) {
            setState(() => _value3 = value);
          },
        ),
      ],
    );
  }
}
```

### 4. 带图标的开关（Material 3）

```dart
class IconSwitchDemo extends StatefulWidget {
  const IconSwitchDemo({super.key});

  @override
  State<IconSwitchDemo> createState() => _IconSwitchDemoState();
}

class _IconSwitchDemoState extends State<IconSwitchDemo> {
  bool _soundOn = true;
  bool _locationOn = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 声音开关
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('声音'),
            const SizedBox(width: 16),
            Switch(
              value: _soundOn,
              thumbIcon: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.volume_up, size: 16);
                }
                return const Icon(Icons.volume_off, size: 16);
              }),
              onChanged: (value) {
                setState(() => _soundOn = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 位置开关
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('位置'),
            const SizedBox(width: 16),
            Switch(
              value: _locationOn,
              thumbIcon: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.location_on, size: 16);
                }
                return const Icon(Icons.location_off, size: 16);
              }),
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() => _locationOn = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 勾选/叉号图标
        Switch(
          value: _soundOn,
          thumbIcon: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Icon(Icons.check, size: 16, color: Colors.white);
            }
            return const Icon(Icons.close, size: 16, color: Colors.grey);
          }),
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() => _soundOn = value);
          },
        ),
      ],
    );
  }
}
```

### 5. 设置页面完整示例

```dart
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 通知设置
  bool _pushNotification = true;
  bool _emailNotification = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // 隐私设置
  bool _showOnlineStatus = true;
  bool _allowLocationAccess = false;

  // 其他设置
  bool _autoPlayVideo = true;
  bool _saveDataMode = false;
  bool _biometricLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 通知设置分组
          _buildSectionHeader('通知设置'),
          SwitchListTile(
            title: const Text('推送通知'),
            subtitle: const Text('接收新消息推送'),
            secondary: const Icon(Icons.notifications_active),
            value: _pushNotification,
            onChanged: (value) {
              setState(() => _pushNotification = value);
            },
          ),
          SwitchListTile(
            title: const Text('邮件通知'),
            subtitle: const Text('接收邮件提醒'),
            secondary: const Icon(Icons.email),
            value: _emailNotification,
            onChanged: (value) {
              setState(() => _emailNotification = value);
            },
          ),
          SwitchListTile(
            title: const Text('通知声音'),
            secondary: const Icon(Icons.volume_up),
            value: _soundEnabled,
            onChanged: _pushNotification
                ? (value) {
                    setState(() => _soundEnabled = value);
                  }
                : null, // 依赖于推送通知开启
          ),
          SwitchListTile(
            title: const Text('震动'),
            secondary: const Icon(Icons.vibration),
            value: _vibrationEnabled,
            onChanged: _pushNotification
                ? (value) {
                    setState(() => _vibrationEnabled = value);
                  }
                : null,
          ),

          // 隐私设置分组
          _buildSectionHeader('隐私设置'),
          SwitchListTile(
            title: const Text('显示在线状态'),
            subtitle: const Text('允许他人查看你的在线状态'),
            secondary: const Icon(Icons.visibility),
            value: _showOnlineStatus,
            onChanged: (value) {
              setState(() => _showOnlineStatus = value);
            },
          ),
          SwitchListTile(
            title: const Text('位置访问'),
            subtitle: const Text('允许应用访问你的位置'),
            secondary: const Icon(Icons.location_on),
            value: _allowLocationAccess,
            onChanged: (value) {
              setState(() => _allowLocationAccess = value);
              if (value) {
                _showLocationPermissionDialog();
              }
            },
          ),

          // 其他设置分组
          _buildSectionHeader('其他设置'),
          SwitchListTile(
            title: const Text('自动播放视频'),
            subtitle: const Text('在 WiFi 下自动播放'),
            secondary: const Icon(Icons.play_circle),
            value: _autoPlayVideo,
            onChanged: (value) {
              setState(() => _autoPlayVideo = value);
            },
          ),
          SwitchListTile(
            title: const Text('省流模式'),
            subtitle: const Text('降低图片质量节省流量'),
            secondary: const Icon(Icons.data_saver_on),
            value: _saveDataMode,
            onChanged: (value) {
              setState(() => _saveDataMode = value);
            },
          ),
          SwitchListTile(
            title: const Text('生物识别登录'),
            subtitle: const Text('使用指纹或面容登录'),
            secondary: const Icon(Icons.fingerprint),
            value: _biometricLogin,
            onChanged: (value) async {
              // 可以在这里添加验证逻辑
              final confirmed = await _confirmBiometricChange(value);
              if (confirmed) {
                setState(() => _biometricLogin = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('位置权限'),
        content: const Text('开启位置访问后，应用将能够获取你的地理位置以提供个性化服务。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmBiometricChange(bool enable) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enable ? '开启生物识别' : '关闭生物识别'),
        content: Text(enable ? '是否开启生物识别登录？' : '关闭后需要使用密码登录'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
```

## Material 3 样式

Material 3 为 Switch 带来了全新的设计：

```dart
class Material3SwitchDemo extends StatefulWidget {
  const Material3SwitchDemo({super.key});

  @override
  State<Material3SwitchDemo> createState() => _Material3SwitchDemoState();
}

class _Material3SwitchDemoState extends State<Material3SwitchDemo> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 启用 Material 3
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        // 自定义 Switch 主题
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.grey.shade600;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue;
            }
            return Colors.grey.shade300;
          }),
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.transparent;
            }
            return Colors.grey.shade400;
          }),
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Material 3 默认样式（thumb 在关闭时更小）
              Switch(
                value: _value,
                onChanged: (value) => setState(() => _value = value),
              ),
              const SizedBox(height: 20),
              // 带图标的 Material 3 开关
              Switch(
                value: _value,
                thumbIcon: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(Icons.check);
                  }
                  return null;
                }),
                onChanged: (value) => setState(() => _value = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Material 3 主要变化

| 特性 | Material 2 | Material 3 |
|------|-----------|-----------|
| 关闭时 thumb 大小 | 与开启时相同 | 更小 |
| 轨道边框 | 无 | 关闭时有边框 |
| 图标支持 | 无 | 支持 thumbIcon |
| 状态层 | 标准 | 更明显的状态反馈 |

## 最佳实践

### 1. 语义化与无障碍

```dart
// ✅ 正确：提供语义标签
Semantics(
  label: 'WiFi 开关',
  hint: _wifiOn ? '当前已开启，点击关闭' : '当前已关闭，点击开启',
  child: Switch(
    value: _wifiOn,
    onChanged: (value) => setState(() => _wifiOn = value),
  ),
)

// ✅ 使用 SwitchListTile 自动提供语义
SwitchListTile(
  title: const Text('WiFi'),
  value: _wifiOn,
  onChanged: (value) => setState(() => _wifiOn = value),
)
```

### 2. 明确的视觉反馈

```dart
// ✅ 禁用时提供明确的视觉提示
SwitchListTile(
  title: Text(
    '高级功能',
    style: TextStyle(
      color: _isPremiumUser ? null : Colors.grey,
    ),
  ),
  subtitle: Text(_isPremiumUser ? '已启用' : '需要升级到高级版'),
  value: _advancedFeature,
  onChanged: _isPremiumUser
      ? (value) => setState(() => _advancedFeature = value)
      : null,
)
```

### 3. 操作确认

```dart
// ✅ 重要操作前确认
SwitchListTile(
  title: const Text('删除确认'),
  subtitle: const Text('删除前弹出确认对话框'),
  value: _confirmBeforeDelete,
  onChanged: (value) async {
    if (!value) {
      // 关闭确认功能前提示用户
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认关闭'),
          content: const Text('关闭后删除操作将不再提示确认，是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        setState(() => _confirmBeforeDelete = value);
      }
    } else {
      setState(() => _confirmBeforeDelete = value);
    }
  },
)
```

### 4. 持久化状态

```dart
// ✅ 使用 SharedPreferences 持久化开关状态
class PersistentSwitchDemo extends StatefulWidget {
  @override
  State<PersistentSwitchDemo> createState() => _PersistentSwitchDemoState();
}

class _PersistentSwitchDemoState extends State<PersistentSwitchDemo> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('深色模式'),
      value: _darkMode,
      onChanged: _saveDarkMode,
    );
  }
}
```

### 5. 避免的问题

```dart
// ❌ 避免：没有 onChanged 但看起来可交互
Switch(
  value: true,
  onChanged: null, // 禁用但没有视觉提示
)

// ✅ 正确：明确禁用原因
Column(
  children: [
    Switch(
      value: true,
      onChanged: null,
    ),
    Text(
      '请先登录',
      style: TextStyle(color: Colors.grey, fontSize: 12),
    ),
  ],
)

// ❌ 避免：立即执行不可逆操作
Switch(
  value: _deleteAll,
  onChanged: (value) {
    if (value) deleteAllData(); // 危险！
    setState(() => _deleteAll = value);
  },
)
```

## 与 CupertinoSwitch 对比

| 特性 | Switch (Material) | CupertinoSwitch (iOS) |
|------|-------------------|----------------------|
| 设计风格 | Material Design | iOS 原生 |
| 尺寸 | 较小 | 较大 |
| 动画 | Material 动画 | iOS 弹性动画 |
| 颜色自定义 | 丰富 | 有限 |
| 图标支持 | 支持 (M3) | 不支持 |
| 平台适配 | 跨平台一致 | iOS 风格 |

```dart
// 自适应开关 - 根据平台自动选择样式
Switch.adaptive(
  value: _value,
  onChanged: (value) => setState(() => _value = value),
)

// 手动使用 CupertinoSwitch
import 'package:flutter/cupertino.dart';

CupertinoSwitch(
  value: _value,
  activeColor: CupertinoColors.activeGreen,
  onChanged: (value) => setState(() => _value = value),
)
```

## 相关组件

- [Checkbox](./checkbox.md) - 复选框，用于多选场景
- [Radio](./radio.md) - 单选按钮，用于单选场景
- [ToggleButtons](../buttons/togglebuttons.md) - 切换按钮组
- [SwitchListTile](./switchlisttile.md) - 带标签的开关列表项
- [CupertinoSwitch](../cupertino/cupertinoswitch.md) - iOS 风格开关

## 官方文档

- [Switch API](https://api.flutter.dev/flutter/material/Switch-class.html)
- [SwitchListTile API](https://api.flutter.dev/flutter/material/SwitchListTile-class.html)
- [SwitchThemeData API](https://api.flutter.dev/flutter/material/SwitchThemeData-class.html)
- [Material Design 3 - Switch](https://m3.material.io/components/switch/overview)
