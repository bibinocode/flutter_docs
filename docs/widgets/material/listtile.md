# ListTile

`ListTile` 是 Material Design 列表项组件，用于在列表中展示一行内容。它提供了标准化的布局，包含可选的前导图标、标题、副标题和尾部组件，是构建列表界面最常用的组件之一。

## 基本用法

```dart
ListTile(
  leading: Icon(Icons.person),
  title: Text('用户名'),
  subtitle: Text('这是副标题'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {},
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| leading | Widget? | null | 左侧组件，通常是图标或头像 |
| title | Widget? | null | 标题组件 |
| subtitle | Widget? | null | 副标题组件 |
| trailing | Widget? | null | 右侧组件，通常是图标或按钮 |
| isThreeLine | bool | false | 是否为三行布局 |
| dense | bool? | null | 是否紧凑模式 |
| visualDensity | VisualDensity? | null | 视觉密度 |
| shape | ShapeBorder? | null | 形状边框 |
| style | ListTileStyle? | null | 列表项样式 |
| selectedColor | Color? | null | 选中时的图标和文字颜色 |
| iconColor | Color? | null | 图标颜色 |
| textColor | Color? | null | 文字颜色 |
| titleTextStyle | TextStyle? | null | 标题文字样式 |
| subtitleTextStyle | TextStyle? | null | 副标题文字样式 |
| leadingAndTrailingTextStyle | TextStyle? | null | 前导和尾部文字样式 |
| contentPadding | EdgeInsetsGeometry? | null | 内容内边距 |
| enabled | bool | true | 是否启用 |
| selected | bool | false | 是否选中 |
| onTap | VoidCallback? | null | 点击回调 |
| onLongPress | VoidCallback? | null | 长按回调 |
| mouseCursor | MouseCursor? | null | 鼠标光标样式 |
| focusColor | Color? | null | 聚焦时颜色 |
| hoverColor | Color? | null | 悬停时颜色 |
| splashColor | Color? | null | 水波纹颜色 |
| selectedTileColor | Color? | null | 选中时背景颜色 |
| tileColor | Color? | null | 背景颜色 |
| enableFeedback | bool? | null | 是否启用触觉反馈 |
| horizontalTitleGap | double? | null | 标题与前导/尾部的水平间距 |
| minVerticalPadding | double? | null | 最小垂直内边距 |
| minLeadingWidth | double? | null | 前导组件最小宽度 |

## 使用场景

### 1. 基本列表项

```dart
ListView(
  children: [
    ListTile(
      title: Text('基本列表项'),
    ),
    ListTile(
      title: Text('带副标题'),
      subtitle: Text('这是副标题内容'),
    ),
    ListTile(
      title: Text('三行列表项'),
      subtitle: Text('这是一段较长的副标题内容，可以显示更多信息'),
      isThreeLine: true,
    ),
  ],
)
```

### 2. 带图标

```dart
ListView(
  children: [
    ListTile(
      leading: Icon(Icons.wifi),
      title: Text('Wi-Fi'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    ),
    ListTile(
      leading: Icon(Icons.bluetooth),
      title: Text('蓝牙'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    ),
    ListTile(
      leading: Icon(Icons.battery_full),
      title: Text('电池'),
      subtitle: Text('80%'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    ),
  ],
)
```

### 3. 联系人列表

```dart
ListView.builder(
  itemCount: contacts.length,
  itemBuilder: (context, index) {
    final contact = contacts[index];
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(contact.avatar),
        child: contact.avatar.isEmpty 
            ? Text(contact.name[0]) 
            : null,
      ),
      title: Text(contact.name),
      subtitle: Text(contact.phone),
      trailing: IconButton(
        icon: Icon(Icons.phone),
        onPressed: () => _callContact(contact),
      ),
      onTap: () => _viewContact(contact),
    );
  },
)
```

### 4. 设置项

```dart
ListView(
  children: [
    ListTile(
      leading: Icon(Icons.person, color: Colors.blue),
      title: Text('账号设置'),
      subtitle: Text('管理您的账号信息'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, '/account'),
    ),
    ListTile(
      leading: Icon(Icons.notifications, color: Colors.orange),
      title: Text('通知设置'),
      subtitle: Text('消息和推送通知'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, '/notifications'),
    ),
    ListTile(
      leading: Icon(Icons.security, color: Colors.green),
      title: Text('隐私与安全'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, '/privacy'),
    ),
  ],
)
```

### 5. 带尾部组件

```dart
ListView(
  children: [
    ListTile(
      title: Text('飞行模式'),
      leading: Icon(Icons.airplanemode_active),
      trailing: Switch(
        value: _airplaneMode,
        onChanged: (value) {
          setState(() => _airplaneMode = value);
        },
      ),
    ),
    ListTile(
      title: Text('音量'),
      leading: Icon(Icons.volume_up),
      trailing: SizedBox(
        width: 150,
        child: Slider(
          value: _volume,
          onChanged: (value) {
            setState(() => _volume = value);
          },
        ),
      ),
    ),
    ListTile(
      title: Text('语言'),
      leading: Icon(Icons.language),
      trailing: DropdownButton<String>(
        value: _language,
        underline: SizedBox(),
        items: ['中文', 'English', '日本語']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) {
          setState(() => _language = value!);
        },
      ),
    ),
  ],
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoUpdate = true;
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 用户信息区域
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                'https://picsum.photos/100/100',
              ),
            ),
            title: Text(
              '张三',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('zhangsan@email.com'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () {
              // 跳转到个人资料页
            },
          ),
          Divider(),
          
          // 外观设置
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '外观',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('深色模式'),
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text('字体大小'),
            subtitle: Text('${_fontSize.toInt()}'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: _fontSize,
                min: 12,
                max: 24,
                divisions: 6,
                onChanged: (value) {
                  setState(() => _fontSize = value);
                },
              ),
            ),
          ),
          Divider(),
          
          // 通知设置
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '通知',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('推送通知'),
            subtitle: Text('接收消息和更新通知'),
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                setState(() => _notifications = value);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text('自动更新'),
            subtitle: Text('在 Wi-Fi 下自动更新应用'),
            trailing: Switch(
              value: _autoUpdate,
              onChanged: (value) {
                setState(() => _autoUpdate = value);
              },
            ),
          ),
          Divider(),
          
          // 其他设置
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '其他',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('语言'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('简体中文', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              // 跳转到语言选择页
            },
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('存储空间'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('2.5 GB', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              // 跳转到存储管理页
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('帮助与反馈'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 跳转到帮助页
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('关于'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('v1.0.0', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '我的应用',
                applicationVersion: 'v1.0.0',
              );
            },
          ),
          Divider(),
          
          // 退出登录
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('退出登录', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('确认退出'),
                  content: Text('确定要退出登录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 执行退出登录逻辑
                      },
                      child: Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## 最佳实践

### 1. 与 CheckboxListTile 配合

```dart
CheckboxListTile(
  title: Text('记住密码'),
  subtitle: Text('下次自动登录'),
  value: _rememberPassword,
  onChanged: (value) {
    setState(() => _rememberPassword = value!);
  },
  secondary: Icon(Icons.lock),
)
```

### 2. 与 SwitchListTile 配合

```dart
SwitchListTile(
  title: Text('启用通知'),
  subtitle: Text('接收推送消息'),
  value: _enableNotifications,
  onChanged: (value) {
    setState(() => _enableNotifications = value);
  },
  secondary: Icon(Icons.notifications),
)
```

### 3. 与 RadioListTile 配合

```dart
Column(
  children: [
    RadioListTile<String>(
      title: Text('选项一'),
      value: 'option1',
      groupValue: _selectedOption,
      onChanged: (value) {
        setState(() => _selectedOption = value!);
      },
    ),
    RadioListTile<String>(
      title: Text('选项二'),
      value: 'option2',
      groupValue: _selectedOption,
      onChanged: (value) {
        setState(() => _selectedOption = value!);
      },
    ),
  ],
)
```

### 4. 自定义样式

```dart
ListTile(
  tileColor: Colors.blue.shade50,
  selectedTileColor: Colors.blue.shade100,
  selected: _isSelected,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  leading: Icon(Icons.star, color: Colors.amber),
  title: Text('收藏项目'),
  titleTextStyle: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
  onTap: () {
    setState(() => _isSelected = !_isSelected);
  },
)
```

### 5. 注意事项

1. **点击区域**：整个 ListTile 都是可点击区域
2. **高度限制**：默认高度根据内容自动调整，使用 `dense` 可压缩
3. **内容溢出**：标题过长时使用 `Text` 的 `overflow` 属性
4. **分隔线**：使用 `Divider` 或 `ListView.separated` 添加分隔线
5. **可访问性**：为重要操作添加语义标签

## 相关组件

- [CheckboxListTile](./checkboxlisttile.md) - 带复选框的列表项
- [RadioListTile](./radiolisttile.md) - 带单选按钮的列表项
- [SwitchListTile](./switchlisttile.md) - 带开关的列表项
- [ExpansionTile](./expansiontile.md) - 可展开的列表项
- [Dismissible](../gesture/dismissible.md) - 可滑动删除的组件

## 官方文档

- [ListTile API](https://api.flutter-io.cn/flutter/material/ListTile-class.html)
- [CheckboxListTile API](https://api.flutter-io.cn/flutter/material/CheckboxListTile-class.html)
- [SwitchListTile API](https://api.flutter-io.cn/flutter/material/SwitchListTile-class.html)
