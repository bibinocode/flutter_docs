
# CupertinoSwitch

`CupertinoSwitch` 是 iOS 风格的开关组件，遵循 Apple Human Interface Guidelines 设计规范。它提供了一个可切换的开关控件，通常用于设置页面中的布尔选项。

## 基本用法

```dart
CupertinoSwitch(
  value: _isEnabled,
  onChanged: (bool value) {
    setState(() {
      _isEnabled = value;
    });
  },
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `value` | `bool` | 开关的当前状态，`true` 为开启，`false` 为关闭 |
| `onChanged` | `ValueChanged<bool>?` | 状态改变时的回调，为 `null` 时开关禁用 |
| `activeColor` | `Color?` | 开启状态时的轨道颜色（默认为系统绿色） |
| `trackColor` | `Color?` | 关闭状态时的轨道颜色 |
| `thumbColor` | `Color?` | 滑块（圆形按钮）的颜色 |
| `dragStartBehavior` | `DragStartBehavior` | 拖拽手势开始的行为（默认为 `DragStartBehavior.start`） |
| `applyTheme` | `bool?` | 是否应用 CupertinoTheme 的颜色 |
| `focusColor` | `Color?` | 获得焦点时的颜色 |
| `focusNode` | `FocusNode?` | 焦点节点 |
| `autofocus` | `bool` | 是否自动获得焦点 |

## 使用场景

### 1. 基本使用

```dart
import 'package:flutter/cupertino.dart';

class BasicSwitchDemo extends StatefulWidget {
  @override
  State<BasicSwitchDemo> createState() => _BasicSwitchDemoState();
}

class _BasicSwitchDemoState extends State<BasicSwitchDemo> {
  bool _isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('基本开关'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoSwitch(
              value: _isEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              _isEnabled ? '已开启' : '已关闭',
              style: TextStyle(
                color: CupertinoColors.label,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. 设置列表项

```dart
class SettingsListDemo extends StatefulWidget {
  @override
  State<SettingsListDemo> createState() => _SettingsListDemoState();
}

class _SettingsListDemoState extends State<SettingsListDemo> {
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = false;
  bool _airplaneMode = false;
  bool _doNotDisturb = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('设置'),
      ),
      child: SafeArea(
        child: CupertinoListSection.insetGrouped(
          header: Text('无线网络'),
          children: [
            CupertinoListTile(
              leading: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  CupertinoIcons.wifi,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
              title: Text('无线局域网'),
              trailing: CupertinoSwitch(
                value: _wifiEnabled,
                onChanged: (value) {
                  setState(() => _wifiEnabled = value);
                },
              ),
            ),
            CupertinoListTile(
              leading: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  CupertinoIcons.bluetooth,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
              title: Text('蓝牙'),
              trailing: CupertinoSwitch(
                value: _bluetoothEnabled,
                onChanged: (value) {
                  setState(() => _bluetoothEnabled = value);
                },
              ),
            ),
            CupertinoListTile(
              leading: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  CupertinoIcons.airplane,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
              title: Text('飞行模式'),
              trailing: CupertinoSwitch(
                value: _airplaneMode,
                onChanged: (value) {
                  setState(() => _airplaneMode = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. 自定义颜色

```dart
class CustomColorSwitchDemo extends StatefulWidget {
  @override
  State<CustomColorSwitchDemo> createState() => _CustomColorSwitchDemoState();
}

class _CustomColorSwitchDemoState extends State<CustomColorSwitchDemo> {
  bool _switch1 = true;
  bool _switch2 = false;
  bool _switch3 = true;
  bool _switch4 = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('自定义颜色'),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // 默认样式
            _buildSwitchRow(
              '默认样式',
              CupertinoSwitch(
                value: _switch1,
                onChanged: (value) => setState(() => _switch1 = value),
              ),
            ),
            
            // 自定义激活颜色
            _buildSwitchRow(
              '自定义激活颜色（紫色）',
              CupertinoSwitch(
                value: _switch2,
                activeColor: CupertinoColors.systemPurple,
                onChanged: (value) => setState(() => _switch2 = value),
              ),
            ),
            
            // 自定义轨道颜色
            _buildSwitchRow(
              '自定义轨道颜色',
              CupertinoSwitch(
                value: _switch3,
                activeColor: CupertinoColors.systemGreen,
                trackColor: CupertinoColors.systemGrey4,
                onChanged: (value) => setState(() => _switch3 = value),
              ),
            ),
            
            // 自定义滑块颜色
            _buildSwitchRow(
              '自定义滑块颜色',
              CupertinoSwitch(
                value: _switch4,
                activeColor: CupertinoColors.systemIndigo,
                thumbColor: CupertinoColors.systemYellow,
                onChanged: (value) => setState(() => _switch4 = value),
              ),
            ),
            
            // 禁用状态
            _buildSwitchRow(
              '禁用状态',
              CupertinoSwitch(
                value: true,
                onChanged: null, // 禁用
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String label, Widget switchWidget) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
            ),
          ),
          switchWidget,
        ],
      ),
    );
  }
}
```

### 4. 配合 CupertinoListTile

```dart
class ListTileSwitchDemo extends StatefulWidget {
  @override
  State<ListTileSwitchDemo> createState() => _ListTileSwitchDemoState();
}

class _ListTileSwitchDemoState extends State<ListTileSwitchDemo> {
  bool _notifications = true;
  bool _sounds = true;
  bool _badges = true;
  bool _previews = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('通知设置'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: Text('推送通知'),
              footer: Text('开启后，您将收到来自应用的通知提醒'),
              children: [
                CupertinoListTile(
                  title: Text('允许通知'),
                  trailing: CupertinoSwitch(
                    value: _notifications,
                    onChanged: (value) {
                      setState(() => _notifications = value);
                    },
                  ),
                ),
              ],
            ),
            
            CupertinoListSection.insetGrouped(
              header: Text('通知样式'),
              children: [
                CupertinoListTile(
                  title: Text('声音'),
                  subtitle: Text('收到通知时播放声音'),
                  trailing: CupertinoSwitch(
                    value: _sounds,
                    onChanged: _notifications
                        ? (value) => setState(() => _sounds = value)
                        : null,
                  ),
                ),
                CupertinoListTile(
                  title: Text('标记'),
                  subtitle: Text('在应用图标上显示未读数量'),
                  trailing: CupertinoSwitch(
                    value: _badges,
                    onChanged: _notifications
                        ? (value) => setState(() => _badges = value)
                        : null,
                  ),
                ),
                CupertinoListTile(
                  title: Text('显示预览'),
                  subtitle: Text('在锁定屏幕上显示通知内容'),
                  trailing: CupertinoSwitch(
                    value: _previews,
                    onChanged: _notifications
                        ? (value) => setState(() => _previews = value)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 完整示例：iOS 风格设置页面

```dart
import 'package:flutter/cupertino.dart';

class CupertinoSettingsPage extends StatefulWidget {
  const CupertinoSettingsPage({super.key});

  @override
  State<CupertinoSettingsPage> createState() => _CupertinoSettingsPageState();
}

class _CupertinoSettingsPageState extends State<CupertinoSettingsPage> {
  // 网络设置
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = false;
  bool _airplaneMode = false;
  bool _cellularData = true;
  bool _personalHotspot = false;
  bool _vpnEnabled = false;

  // 通知设置
  bool _notifications = true;
  bool _sounds = true;
  bool _badges = true;

  // 显示设置
  bool _darkMode = false;
  bool _autoLock = true;
  bool _reduceMotion = false;

  // 隐私设置
  bool _locationServices = true;
  bool _analytics = false;
  bool _personalizedAds = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('设置'),
        previousPageTitle: '返回',
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // 用户信息
            _buildUserSection(),

            // 网络设置
            CupertinoListSection.insetGrouped(
              children: [
                _buildSwitchTile(
                  icon: CupertinoIcons.airplane,
                  iconColor: CupertinoColors.systemOrange,
                  title: '飞行模式',
                  value: _airplaneMode,
                  onChanged: (value) {
                    setState(() {
                      _airplaneMode = value;
                      if (value) {
                        _wifiEnabled = false;
                        _bluetoothEnabled = false;
                        _cellularData = false;
                      }
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.wifi,
                  iconColor: CupertinoColors.activeBlue,
                  title: '无线局域网',
                  value: _wifiEnabled,
                  onChanged: _airplaneMode
                      ? null
                      : (value) => setState(() => _wifiEnabled = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.bluetooth,
                  iconColor: CupertinoColors.activeBlue,
                  title: '蓝牙',
                  value: _bluetoothEnabled,
                  onChanged: _airplaneMode
                      ? null
                      : (value) => setState(() => _bluetoothEnabled = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.antenna_radiowaves_left_right,
                  iconColor: CupertinoColors.systemGreen,
                  title: '蜂窝网络',
                  value: _cellularData,
                  onChanged: _airplaneMode
                      ? null
                      : (value) => setState(() => _cellularData = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.personalhotspot,
                  iconColor: CupertinoColors.systemGreen,
                  title: '个人热点',
                  value: _personalHotspot,
                  onChanged: _cellularData && !_airplaneMode
                      ? (value) => setState(() => _personalHotspot = value)
                      : null,
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.lock_shield,
                  iconColor: CupertinoColors.activeBlue,
                  title: 'VPN',
                  value: _vpnEnabled,
                  onChanged: (value) => setState(() => _vpnEnabled = value),
                ),
              ],
            ),

            // 通知设置
            CupertinoListSection.insetGrouped(
              header: Text('通知'),
              children: [
                _buildSwitchTile(
                  icon: CupertinoIcons.bell_fill,
                  iconColor: CupertinoColors.systemRed,
                  title: '通知',
                  value: _notifications,
                  onChanged: (value) => setState(() => _notifications = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.speaker_2_fill,
                  iconColor: CupertinoColors.systemPink,
                  title: '声音',
                  value: _sounds,
                  onChanged: _notifications
                      ? (value) => setState(() => _sounds = value)
                      : null,
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.app_badge,
                  iconColor: CupertinoColors.systemRed,
                  title: '标记',
                  value: _badges,
                  onChanged: _notifications
                      ? (value) => setState(() => _badges = value)
                      : null,
                ),
              ],
            ),

            // 显示设置
            CupertinoListSection.insetGrouped(
              header: Text('显示与亮度'),
              children: [
                _buildSwitchTile(
                  icon: CupertinoIcons.moon_fill,
                  iconColor: CupertinoColors.systemIndigo,
                  title: '深色模式',
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.lock_fill,
                  iconColor: CupertinoColors.systemGrey,
                  title: '自动锁定',
                  value: _autoLock,
                  onChanged: (value) => setState(() => _autoLock = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.sparkles,
                  iconColor: CupertinoColors.systemPurple,
                  title: '减弱动态效果',
                  value: _reduceMotion,
                  onChanged: (value) => setState(() => _reduceMotion = value),
                ),
              ],
            ),

            // 隐私设置
            CupertinoListSection.insetGrouped(
              header: Text('隐私'),
              footer: Text('关闭后，您将不会收到个性化广告推荐'),
              children: [
                _buildSwitchTile(
                  icon: CupertinoIcons.location_fill,
                  iconColor: CupertinoColors.activeBlue,
                  title: '定位服务',
                  value: _locationServices,
                  onChanged: (value) =>
                      setState(() => _locationServices = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.chart_bar_fill,
                  iconColor: CupertinoColors.systemOrange,
                  title: '分析与改进',
                  value: _analytics,
                  onChanged: (value) => setState(() => _analytics = value),
                ),
                _buildSwitchTile(
                  icon: CupertinoIcons.rectangle_stack_person_crop_fill,
                  iconColor: CupertinoColors.systemGreen,
                  title: '个性化广告',
                  value: _personalizedAds,
                  onChanged: (value) =>
                      setState(() => _personalizedAds = value),
                ),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              size: 36,
              color: CupertinoColors.white,
            ),
          ),
          title: Text(
            '用户名',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          subtitle: Text('Apple ID、iCloud、媒体与购买项目'),
          trailing: CupertinoListTileChevron(),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return CupertinoListTile(
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: CupertinoColors.white,
          size: 20,
        ),
      ),
      title: Text(title),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
```

## 最佳实践

### 1. CupertinoSwitch 与 Switch 的区别

| 特性 | CupertinoSwitch | Switch (Material) |
|------|-----------------|-------------------|
| 设计风格 | iOS 风格 | Material Design 风格 |
| 外观形状 | 较宽的椭圆形轨道 | 较窄的圆角矩形轨道 |
| 默认颜色 | 绿色激活色 | 主题色激活色 |
| 滑块样式 | 白色圆形带阴影 | 圆形带不同状态颜色 |
| 动画效果 | iOS 特有的弹性动画 | Material 波纹效果 |
| 适用场景 | iOS 风格应用 | Android / 跨平台应用 |

### 2. 使用建议

```dart
// ✅ 推荐：在 iOS 风格页面中使用
CupertinoPageScaffold(
  child: CupertinoListSection(
    children: [
      CupertinoListTile(
        title: Text('设置项'),
        trailing: CupertinoSwitch(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
      ),
    ],
  ),
)

// ✅ 推荐：根据平台自动选择
import 'dart:io' show Platform;

Widget buildAdaptiveSwitch() {
  if (Platform.isIOS) {
    return CupertinoSwitch(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
  return Switch(
    value: _value,
    onChanged: (v) => setState(() => _value = v),
  );
}

// ✅ 推荐：使用 Switch.adaptive 自动适配
Switch.adaptive(
  value: _value,
  onChanged: (v) => setState(() => _value = v),
)

// ❌ 避免：在 Material 页面中混用 CupertinoSwitch
Scaffold(
  body: CupertinoSwitch(...), // 风格不协调
)
```

### 3. 状态管理

```dart
// ✅ 推荐：及时更新状态
CupertinoSwitch(
  value: _isEnabled,
  onChanged: (bool value) {
    setState(() {
      _isEnabled = value;
    });
    // 执行相关操作
    _savePreference(value);
  },
)

// ✅ 推荐：禁用时传入 null
CupertinoSwitch(
  value: _isEnabled,
  onChanged: _canToggle ? (value) {
    setState(() => _isEnabled = value);
  } : null,
)
```

### 4. 无障碍支持

```dart
// ✅ 推荐：配合 CupertinoListTile 使用，自动提供语义信息
CupertinoListTile(
  title: Text('启用通知'),
  trailing: CupertinoSwitch(
    value: _notifications,
    onChanged: (value) => setState(() => _notifications = value),
  ),
)

// ✅ 推荐：单独使用时添加 Semantics
Semantics(
  label: '启用通知',
  value: _notifications ? '已开启' : '已关闭',
  child: CupertinoSwitch(
    value: _notifications,
    onChanged: (value) => setState(() => _notifications = value),
  ),
)
```

## 相关组件

- [Switch](../basics/switch.md) - Material Design 风格开关
- [SwitchListTile](../basics/switchlisttile.md) - 带标签的 Material 开关列表项
- [CupertinoListTile](./cupertinolisttile.md) - iOS 风格列表项
- [CupertinoSlider](./cupertinoslider.md) - iOS 风格滑块
- [Checkbox](../input/checkbox.md) - 复选框（用于多选场景）

## 官方文档

- [CupertinoSwitch API](https://api.flutter.dev/flutter/cupertino/CupertinoSwitch-class.html)
- [Apple Human Interface Guidelines - Toggles](https://developer.apple.com/design/human-interface-guidelines/toggles)

