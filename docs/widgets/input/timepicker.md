# TimePicker

`TimePicker` 是 Flutter 中的 Material Design 时间选择器组件。与其他输入组件不同，TimePicker 通过 `showTimePicker` 函数以对话框的形式展示，用户可以通过表盘视图或手动输入的方式选择时间。它支持 12/24 小时制、多种入口模式、自定义文本等功能，是表单中时间选择的首选方案。

## 基本用法

```dart
// showTimePicker 返回一个 Future<TimeOfDay?>
final TimeOfDay? selectedTime = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
);

if (selectedTime != null) {
  print('选择的时间: ${selectedTime.hour}:${selectedTime.minute}');
}
```

## showTimePicker 参数详解

### 必需参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `context` | `BuildContext` | 构建上下文，用于显示对话框 |
| `initialTime` | `TimeOfDay` | 初始选中的时间 |

### 入口模式

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `initialEntryMode` | `TimePickerEntryMode` | `dial` | 初始入口模式（表盘或输入） |

### 文本自定义

| 参数 | 类型 | 说明 |
|------|------|------|
| `helpText` | `String?` | 顶部帮助文本 |
| `cancelText` | `String?` | 取消按钮文本 |
| `confirmText` | `String?` | 确认按钮文本 |
| `errorInvalidText` | `String?` | 时间无效提示文本 |
| `hourLabelText` | `String?` | 小时输入框标签文本 |
| `minuteLabelText` | `String?` | 分钟输入框标签文本 |

### 导航与路由

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `useRootNavigator` | `bool` | `true` | 是否使用根导航器 |
| `routeSettings` | `RouteSettings?` | - | 路由设置 |

### 布局与显示

| 参数 | 类型 | 说明 |
|------|------|------|
| `builder` | `Widget Function(BuildContext, Widget?)?` | 自定义构建器，可包装主题或媒体查询 |
| `orientation` | `Orientation?` | 强制设置横向或纵向布局 |
| `anchorPoint` | `Offset?` | 对话框锚点位置（用于多显示器） |

## TimePickerEntryMode 枚举

`TimePickerEntryMode` 定义了时间选择器的入口模式：

| 值 | 说明 |
|------|------|
| `dial` | 表盘模式，可切换到输入模式 |
| `input` | 输入模式，可切换到表盘模式 |
| `dialOnly` | 仅表盘模式，不可切换 |
| `inputOnly` | 仅输入模式，不可切换 |

```dart
// 使用输入模式
showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
  initialEntryMode: TimePickerEntryMode.input,
);

// 仅表盘模式（隐藏切换按钮）
showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
  initialEntryMode: TimePickerEntryMode.dialOnly,
);
```

## TimeOfDay 类

`TimeOfDay` 是表示一天中某个时间点的类，不包含日期信息。

### 构造函数

```dart
// 指定小时和分钟
final time = TimeOfDay(hour: 14, minute: 30);

// 获取当前时间
final now = TimeOfDay.now();

// 从 DateTime 创建
final fromDateTime = TimeOfDay.fromDateTime(DateTime.now());
```

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `hour` | `int` | 小时（0-23） |
| `minute` | `int` | 分钟（0-59） |
| `period` | `DayPeriod` | 时段（am 或 pm） |
| `hourOfPeriod` | `int` | 12小时制的小时数（0-11） |
| `periodOffset` | `int` | 时段偏移量（am=0, pm=12） |

### 方法

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `format(BuildContext context)` | `String` | 根据本地化格式化时间 |
| `replacing({int? hour, int? minute})` | `TimeOfDay` | 返回替换指定值后的新实例 |

```dart
final time = TimeOfDay(hour: 14, minute: 30);

// 属性访问
print(time.hour);         // 14
print(time.minute);       // 30
print(time.period);       // DayPeriod.pm
print(time.hourOfPeriod); // 2
print(time.periodOffset); // 12

// 格式化（根据设备本地化设置）
print(time.format(context)); // "2:30 PM" 或 "14:30"

// 创建新实例
final newTime = time.replacing(hour: 16); // 16:30
```

## 使用场景

### 1. 基本时间选择

```dart
class BasicTimePickerExample extends StatefulWidget {
  @override
  State<BasicTimePickerExample> createState() => _BasicTimePickerExampleState();
}

class _BasicTimePickerExampleState extends State<BasicTimePickerExample> {
  TimeOfDay? _selectedTime;

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: '选择时间',
      cancelText: '取消',
      confirmText: '确定',
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_selectedTime == null
          ? '未选择时间'
          : _selectedTime!.format(context)),
      trailing: Icon(Icons.access_time),
      onTap: _selectTime,
    );
  }
}
```

### 2. 24小时制时间选择

```dart
Future<void> _selectTime24Hour() async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: true,
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null) {
    // 格式化为24小时制
    final hour = picked.hour.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    print('$hour:$minute');
  }
}
```

### 3. 输入模式时间选择

```dart
Future<void> _selectTimeInput() async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.input,
    helpText: '输入时间',
    hourLabelText: '小时',
    minuteLabelText: '分钟',
    errorInvalidText: '请输入有效时间',
  );
  
  if (picked != null) {
    // 处理选择的时间
  }
}
```

### 4. 配合日期选择使用

```dart
class DateTimePickerExample extends StatefulWidget {
  @override
  State<DateTimePickerExample> createState() => _DateTimePickerExampleState();
}

class _DateTimePickerExampleState extends State<DateTimePickerExample> {
  DateTime? _selectedDateTime;

  Future<void> _selectDateTime() async {
    // 先选择日期
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (date == null) return;
    
    // 再选择时间
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.now(),
    );
    
    if (time == null) return;
    
    // 合并日期和时间
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_selectedDateTime == null
          ? '未选择日期时间'
          : '${_selectedDateTime!.year}-${_selectedDateTime!.month}-${_selectedDateTime!.day} '
            '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'),
      trailing: Icon(Icons.event),
      onTap: _selectDateTime,
    );
  }
}
```

### 5. 自定义主题

```dart
Future<void> _selectTimeWithTheme() async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.white,
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.deepPurple.shade200),
            ),
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            dialHandColor: Colors.deepPurple,
            dialBackgroundColor: Colors.deepPurple.shade50,
            hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? Colors.deepPurple
                    : Colors.deepPurple.shade50),
            hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? Colors.white
                    : Colors.deepPurple),
          ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null) {
    // 处理选择的时间
  }
}
```

## 完整示例：闹钟设置

```dart
import 'package:flutter/material.dart';

class AlarmSettingPage extends StatefulWidget {
  const AlarmSettingPage({super.key});

  @override
  State<AlarmSettingPage> createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  final List<AlarmItem> _alarms = [];
  
  Future<void> _addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 7, minute: 0),
      helpText: '设置闹钟时间',
      cancelText: '取消',
      confirmText: '确定',
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialHandColor: Colors.indigo,
              dialBackgroundColor: Colors.indigo.shade50,
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.indigo),
              hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.indigo
                      : Colors.indigo.shade50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _alarms.add(AlarmItem(
          time: picked,
          isEnabled: true,
          label: '闹钟 ${_alarms.length + 1}',
        ));
        // 按时间排序
        _alarms.sort((a, b) {
          final aMinutes = a.time.hour * 60 + a.time.minute;
          final bMinutes = b.time.hour * 60 + b.time.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  Future<void> _editAlarm(int index) async {
    final alarm = _alarms[index];
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: alarm.time,
      helpText: '修改闹钟时间',
      cancelText: '取消',
      confirmText: '确定',
    );

    if (picked != null) {
      setState(() {
        _alarms[index] = alarm.copyWith(time: picked);
        // 重新排序
        _alarms.sort((a, b) {
          final aMinutes = a.time.hour * 60 + a.time.minute;
          final bMinutes = b.time.hour * 60 + b.time.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  void _toggleAlarm(int index, bool value) {
    setState(() {
      _alarms[index] = _alarms[index].copyWith(isEnabled: value);
    });
  }

  void _deleteAlarm(int index) {
    setState(() {
      _alarms.removeAt(index);
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTimeUntilAlarm(TimeOfDay alarmTime) {
    final now = TimeOfDay.now();
    int nowMinutes = now.hour * 60 + now.minute;
    int alarmMinutes = alarmTime.hour * 60 + alarmTime.minute;
    
    if (alarmMinutes <= nowMinutes) {
      alarmMinutes += 24 * 60; // 添加一天
    }
    
    final diffMinutes = alarmMinutes - nowMinutes;
    final hours = diffMinutes ~/ 60;
    final minutes = diffMinutes % 60;
    
    if (hours > 0) {
      return '$hours 小时 $minutes 分钟后响铃';
    } else {
      return '$minutes 分钟后响铃';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('闹钟'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '暂无闹钟',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '点击 + 添加新闹钟',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Dismissible(
                  key: Key('alarm_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteAlarm(index),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(
                        Icons.alarm,
                        size: 32,
                        color: alarm.isEnabled
                            ? Colors.indigo
                            : Colors.grey.shade400,
                      ),
                      title: Text(
                        _formatTime(alarm.time),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: alarm.isEnabled
                              ? Colors.black87
                              : Colors.grey.shade400,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alarm.label,
                            style: TextStyle(
                              color: alarm.isEnabled
                                  ? Colors.black54
                                  : Colors.grey.shade400,
                            ),
                          ),
                          if (alarm.isEnabled)
                            Text(
                              _getTimeUntilAlarm(alarm.time),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                              ),
                            ),
                        ],
                      ),
                      trailing: Switch(
                        value: alarm.isEnabled,
                        onChanged: (value) => _toggleAlarm(index, value),
                        activeColor: Colors.indigo,
                      ),
                      onTap: () => _editAlarm(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AlarmItem {
  final TimeOfDay time;
  final bool isEnabled;
  final String label;

  AlarmItem({
    required this.time,
    required this.isEnabled,
    required this.label,
  });

  AlarmItem copyWith({
    TimeOfDay? time,
    bool? isEnabled,
    String? label,
  }) {
    return AlarmItem(
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
    );
  }
}
```

## 最佳实践

1. **选择合适的入口模式**：
   - 表盘模式（`dial`）适合触屏设备，更直观
   - 输入模式（`input`）适合知道具体时间的场景，输入更快
   - 根据设备类型和使用场景选择合适的模式

2. **提供明确的提示文本**：使用 `helpText`、`errorInvalidText`、`hourLabelText`、`minuteLabelText` 等参数提供清晰的用户指引。

3. **考虑时间格式**：
   - 使用 `builder` 和 `MediaQuery.alwaysUse24HourFormat` 控制 12/24 小时制
   - 根据用户偏好或业务需求选择合适的格式

4. **验证时间有效性**：在用户选择时间后，验证是否在有效范围内（如营业时间、工作时间等）。

5. **配合日期选择器使用**：需要同时选择日期和时间时，先选日期再选时间，或考虑使用第三方日期时间选择器组件。

6. **主题定制**：使用 `TimePickerThemeData` 自定义时间选择器的外观，保持与应用整体风格一致。

7. **响应式布局**：使用 `orientation` 参数可以强制横向或纵向布局，但通常让系统自动选择即可。

8. **状态保持**：记住用户上次选择的时间作为 `initialTime`，提升用户体验。

## 相关组件

- [showDatePicker](datepicker.md) - 日期选择器
- [CupertinoDatePicker](../cupertino/cupertinoDatePicker.md) - iOS 风格日期时间选择器
- [CupertinoTimerPicker](../cupertino/cupertinoTimerPicker.md) - iOS 风格计时器选择器

## 官方文档

- [showTimePicker API](https://api.flutter.dev/flutter/material/showTimePicker.html)
- [TimeOfDay API](https://api.flutter.dev/flutter/material/TimeOfDay-class.html)
- [TimePickerEntryMode](https://api.flutter.dev/flutter/material/TimePickerEntryMode.html)
- [TimePickerThemeData](https://api.flutter.dev/flutter/material/TimePickerThemeData-class.html)
- [Material Design Time Pickers](https://m3.material.io/components/time-pickers)
