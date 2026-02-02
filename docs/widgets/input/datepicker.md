# DatePicker

`DatePicker` 是 Flutter 中的 Material Design 日期选择器组件。与其他输入组件不同，DatePicker 通过 `showDatePicker` 函数以对话框的形式展示，用户可以通过日历视图或手动输入的方式选择日期。它支持日期范围限制、禁用特定日期、自定义文本、多种入口模式等功能，是表单中日期选择的首选方案。

## 基本用法

```dart
// showDatePicker 返回一个 Future<DateTime?>
final DateTime? selectedDate = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
);

if (selectedDate != null) {
  print('选择的日期: $selectedDate');
}
```

## showDatePicker 参数详解

### 必需参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `context` | `BuildContext` | 构建上下文，用于显示对话框 |
| `initialDate` | `DateTime?` | 初始选中的日期，为 null 时不预选任何日期 |
| `firstDate` | `DateTime` | 可选择的最早日期 |
| `lastDate` | `DateTime` | 可选择的最晚日期 |

### 入口模式与显示模式

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `initialEntryMode` | `DatePickerEntryMode` | `calendar` | 初始入口模式（日历或输入） |
| `initialDatePickerMode` | `DatePickerMode` | `day` | 日历模式下的初始显示（日/年） |

### 日期过滤

| 参数 | 类型 | 说明 |
|------|------|------|
| `selectableDayPredicate` | `bool Function(DateTime)?` | 日期过滤器，返回 false 的日期将被禁用 |

### 文本自定义

| 参数 | 类型 | 说明 |
|------|------|------|
| `helpText` | `String?` | 顶部帮助文本 |
| `cancelText` | `String?` | 取消按钮文本 |
| `confirmText` | `String?` | 确认按钮文本 |
| `errorFormatText` | `String?` | 日期格式错误提示文本 |
| `errorInvalidText` | `String?` | 日期无效（超出范围）提示文本 |
| `fieldHintText` | `String?` | 输入模式下的提示文本 |
| `fieldLabelText` | `String?` | 输入模式下的标签文本 |

### 导航与路由

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `useRootNavigator` | `bool` | `true` | 是否使用根导航器 |
| `routeSettings` | `RouteSettings?` | - | 路由设置 |

### 本地化与布局

| 参数 | 类型 | 说明 |
|------|------|------|
| `locale` | `Locale?` | 日期选择器的语言区域 |
| `textDirection` | `TextDirection?` | 文本方向（LTR/RTL） |
| `builder` | `Widget Function(BuildContext, Widget?)?` | 自定义构建器，可包装主题或媒体查询 |
| `anchorPoint` | `Offset?` | 对话框锚点位置（用于多显示器） |

### 输入模式

| 参数 | 类型 | 说明 |
|------|------|------|
| `keyboardType` | `TextInputType` | 输入模式下的键盘类型 |

### 切换图标

| 参数 | 类型 | 说明 |
|------|------|------|
| `switchToInputEntryModeIcon` | `Icon?` | 切换到输入模式的图标 |
| `switchToCalendarEntryModeIcon` | `Icon?` | 切换到日历模式的图标 |

## DatePickerEntryMode 枚举

`DatePickerEntryMode` 定义了日期选择器的入口模式：

| 值 | 说明 |
|------|------|
| `calendar` | 日历模式，可切换到输入模式 |
| `input` | 输入模式，可切换到日历模式 |
| `calendarOnly` | 仅日历模式，不可切换 |
| `inputOnly` | 仅输入模式，不可切换 |

```dart
// 使用输入模式
showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  initialEntryMode: DatePickerEntryMode.input,
);

// 仅日历模式（隐藏切换按钮）
showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  initialEntryMode: DatePickerEntryMode.calendarOnly,
);
```

## 使用场景

### 1. 基本日期选择

```dart
class BasicDatePickerExample extends StatefulWidget {
  @override
  State<BasicDatePickerExample> createState() => _BasicDatePickerExampleState();
}

class _BasicDatePickerExampleState extends State<BasicDatePickerExample> {
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '选择日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_selectedDate == null
          ? '未选择日期'
          : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'),
      trailing: Icon(Icons.calendar_today),
      onTap: _selectDate,
    );
  }
}
```

### 2. 范围限制（只能选择未来日期）

```dart
Future<void> _selectFutureDate() async {
  final DateTime now = DateTime.now();
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now, // 从今天开始
    lastDate: DateTime(now.year + 1), // 到一年后
    errorInvalidText: '请选择今天或之后的日期',
  );
  
  if (picked != null) {
    // 处理选择的日期
  }
}
```

### 3. 禁用特定日期（如周末）

```dart
Future<void> _selectWeekday() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _findNextWeekday(DateTime.now()),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
    selectableDayPredicate: (DateTime date) {
      // 禁用周六和周日
      return date.weekday != DateTime.saturday && 
             date.weekday != DateTime.sunday;
    },
  );
  
  if (picked != null) {
    // 处理选择的日期
  }
}

// 找到下一个工作日
DateTime _findNextWeekday(DateTime date) {
  while (date.weekday == DateTime.saturday || 
         date.weekday == DateTime.sunday) {
    date = date.add(Duration(days: 1));
  }
  return date;
}
```

### 4. 禁用特定日期列表（如节假日）

```dart
final Set<DateTime> _holidays = {
  DateTime(2024, 1, 1),   // 元旦
  DateTime(2024, 5, 1),   // 劳动节
  DateTime(2024, 10, 1),  // 国庆节
};

Future<void> _selectNonHoliday() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2025),
    selectableDayPredicate: (DateTime date) {
      // 检查是否是节假日（只比较年月日）
      return !_holidays.any((holiday) =>
          holiday.year == date.year &&
          holiday.month == date.month &&
          holiday.day == date.day);
    },
  );
  
  if (picked != null) {
    // 处理选择的日期
  }
}
```

### 5. 日期范围选择 (showDateRangePicker)

```dart
class DateRangePickerExample extends StatefulWidget {
  @override
  State<DateRangePickerExample> createState() => _DateRangePickerExampleState();
}

class _DateRangePickerExampleState extends State<DateRangePickerExample> {
  DateTimeRange? _selectedRange;

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '选择日期范围',
      cancelText: '取消',
      confirmText: '确定',
      saveText: '保存',
      fieldStartHintText: '开始日期',
      fieldEndHintText: '结束日期',
      fieldStartLabelText: '开始',
      fieldEndLabelText: '结束',
    );
    
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String rangeText = '未选择日期范围';
    if (_selectedRange != null) {
      rangeText = '${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}';
    }
    
    return ListTile(
      title: Text(rangeText),
      trailing: Icon(Icons.date_range),
      onTap: _selectDateRange,
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

### 6. 自定义主题

```dart
Future<void> _selectDateWithTheme() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.teal, // 主色调
            onPrimary: Colors.white, // 主色调上的文字颜色
            onSurface: Colors.black, // 日历文字颜色
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.teal, // 按钮文字颜色
            ),
          ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null) {
    // 处理选择的日期
  }
}
```

## 完整示例：预约日期选择

```dart
import 'package:flutter/material.dart';

class AppointmentDatePicker extends StatefulWidget {
  const AppointmentDatePicker({super.key});

  @override
  State<AppointmentDatePicker> createState() => _AppointmentDatePickerState();
}

class _AppointmentDatePickerState extends State<AppointmentDatePicker> {
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  
  // 不可预约的日期（已满或节假日）
  final Set<DateTime> _unavailableDates = {
    DateTime(2024, 12, 25), // 圣诞节
    DateTime(2024, 12, 31), // 跨年
    DateTime(2025, 1, 1),   // 元旦
  };

  // 检查日期是否可选
  bool _isSelectableDate(DateTime date) {
    // 禁用过去的日期
    if (date.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return false;
    }
    
    // 禁用周日
    if (date.weekday == DateTime.sunday) {
      return false;
    }
    
    // 禁用不可预约的日期
    for (final unavailable in _unavailableDates) {
      if (unavailable.year == date.year &&
          unavailable.month == date.month &&
          unavailable.day == date.day) {
        return false;
      }
    }
    
    return true;
  }

  Future<void> _selectDate() async {
    // 找到第一个可选的日期作为初始日期
    DateTime initialDate = DateTime.now();
    while (!_isSelectableDate(initialDate)) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate ?? initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)), // 只能预约90天内
      selectableDayPredicate: _isSelectableDate,
      helpText: '选择预约日期',
      cancelText: '取消',
      confirmText: '确认',
      errorInvalidText: '该日期不可预约',
      fieldLabelText: '预约日期',
      fieldHintText: '年/月/日',
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _appointmentDate = picked;
      });
      // 选择日期后自动弹出时间选择
      _selectTime();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _appointmentTime ?? TimeOfDay(hour: 9, minute: 0),
      helpText: '选择预约时间',
      cancelText: '取消',
      confirmText: '确认',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 验证时间是否在营业时间内（9:00-18:00）
      if (picked.hour < 9 || picked.hour >= 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请选择 9:00-18:00 之间的时间')),
        );
        return;
      }
      
      setState(() {
        _appointmentTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${date.year}年${date.month}月${date.day}日 ${weekdays[date.weekday - 1]}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('预约日期选择'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '预约信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // 日期选择
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                      title: Text('预约日期'),
                      subtitle: Text(
                        _appointmentDate == null
                            ? '点击选择日期'
                            : _formatDate(_appointmentDate!),
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: _selectDate,
                    ),
                    
                    Divider(),
                    
                    // 时间选择
                    ListTile(
                      leading: Icon(Icons.access_time, color: Colors.blue.shade700),
                      title: Text('预约时间'),
                      subtitle: Text(
                        _appointmentTime == null
                            ? '点击选择时间'
                            : _formatTime(_appointmentTime!),
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: _appointmentDate == null ? null : _selectTime,
                      enabled: _appointmentDate != null,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // 提示信息
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '营业时间: 周一至周六 9:00-18:00\n节假日休息',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Spacer(),
            
            // 确认按钮
            ElevatedButton(
              onPressed: (_appointmentDate != null && _appointmentTime != null)
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '预约成功: ${_formatDate(_appointmentDate!)} ${_formatTime(_appointmentTime!)}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('确认预约', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

1. **设置合理的日期范围**：根据业务需求设置 `firstDate` 和 `lastDate`，避免用户选择无效日期。

2. **提供明确的提示文本**：使用 `helpText`、`errorFormatText`、`errorInvalidText` 等参数提供清晰的用户指引。

3. **使用 selectableDayPredicate 过滤日期**：对于不可选的日期（如节假日、已预约日期），使用此参数禁用而不是在选择后报错。

4. **考虑本地化**：使用 `locale` 参数或 `builder` 包装 `Localizations` 来适配不同语言环境。

5. **选择合适的入口模式**：
   - 日期范围大时使用 `calendar` 模式方便浏览
   - 用户知道具体日期时使用 `input` 模式快速输入
   - 移动端优先使用 `calendarOnly` 避免键盘遮挡

6. **配合 TimeOfDay 使用**：如果需要同时选择日期和时间，先选日期再选时间，或使用自定义的日期时间选择器。

7. **格式化显示**：使用 `intl` 包的 `DateFormat` 类来格式化显示日期，确保符合用户的本地习惯。

8. **状态保持**：记住用户上次选择的日期作为 `initialDate`，提升用户体验。

## 相关组件

- [showDateRangePicker](https://api.flutter.dev/flutter/material/showDateRangePicker.html) - 日期范围选择器
- [showTimePicker](timepicker.md) - 时间选择器
- [CupertinoDatePicker](../cupertino/cupertinoDatePicker.md) - iOS 风格日期选择器
- [CalendarDatePicker](https://api.flutter.dev/flutter/material/CalendarDatePicker-class.html) - 可嵌入的日历组件
- [InputDatePickerFormField](https://api.flutter.dev/flutter/material/InputDatePickerFormField-class.html) - 表单中的日期输入字段

## 官方文档

- [showDatePicker API](https://api.flutter.dev/flutter/material/showDatePicker.html)
- [showDateRangePicker API](https://api.flutter.dev/flutter/material/showDateRangePicker.html)
- [DatePickerEntryMode](https://api.flutter.dev/flutter/material/DatePickerEntryMode.html)
- [Material Design Date Pickers](https://m3.material.io/components/date-pickers)
