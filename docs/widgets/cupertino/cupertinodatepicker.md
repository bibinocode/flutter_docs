# CupertinoDatePicker

`CupertinoDatePicker` 是 iOS 风格的日期时间选择器，使用经典的 iOS 滚轮样式让用户选择日期、时间或日期时间。它完美模拟了 iOS 原生的日期选择器外观和交互体验，支持多种选择模式、日期范围限制和灵活的格式配置。

## 基本用法

```dart
CupertinoDatePicker(
  mode: CupertinoDatePickerMode.date,
  initialDateTime: DateTime.now(),
  onDateTimeChanged: (DateTime value) {
    print('选择的日期: $value');
  },
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `mode` | `CupertinoDatePickerMode` | 选择模式 |
| `initialDateTime` | `DateTime?` | 初始日期时间 |
| `minimumDate` | `DateTime?` | 最小可选日期 |
| `maximumDate` | `DateTime?` | 最大可选日期 |
| `minimumYear` | `int` | 最小年份（默认1） |
| `maximumYear` | `int?` | 最大年份 |
| `minuteInterval` | `int` | 分钟间隔（默认1） |
| `use24hFormat` | `bool` | 是否使用24小时制 |
| `dateOrder` | `DatePickerDateOrder?` | 日期顺序 |
| `onDateTimeChanged` | `ValueChanged&lt;DateTime&gt;` | 日期变化回调 |
| `backgroundColor` | `Color?` | 背景颜色 |
| `showDayOfWeek` | `bool` | 是否显示星期（iOS 17+） |

## 选择模式

| 模式 | 说明 |
|------|------|
| `CupertinoDatePickerMode.date` | 仅日期 |
| `CupertinoDatePickerMode.time` | 仅时间 |
| `CupertinoDatePickerMode.dateAndTime` | 日期和时间 |
| `CupertinoDatePickerMode.monthYear` | 月份和年份 |

## 日期顺序

| 顺序 | 说明 |
|------|------|
| `DatePickerDateOrder.dmy` | 日-月-年 |
| `DatePickerDateOrder.mdy` | 月-日-年（美式） |
| `DatePickerDateOrder.ymd` | 年-月-日（中式） |
| `DatePickerDateOrder.ydm` | 年-日-月 |

## 使用场景

### 1. 底部弹出日期选择器

```dart
class DatePickerDemo extends StatefulWidget {
  @override
  State&lt;DatePickerDemo&gt; createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State&lt;DatePickerDemo&gt; {
  DateTime _selectedDate = DateTime.now();

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // 顶部操作栏
              Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text('取消'),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                        // 处理选择的日期
                      },
                      child: Text('确定'),
                    ),
                  ],
                ),
              ),
              // 日期选择器
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2030),
                  onDateTimeChanged: (DateTime value) {
                    setState(() => _selectedDate = value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('日期选择'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: _showDatePicker,
                child: Text('选择日期'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. 生日选择器

```dart
class BirthdayPicker extends StatefulWidget {
  final ValueChanged&lt;DateTime&gt; onChanged;
  
  const BirthdayPicker({required this.onChanged});

  @override
  State&lt;BirthdayPicker&gt; createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State&lt;BirthdayPicker&gt; {
  late DateTime _birthday;

  @override
  void initState() {
    super.initState();
    // 默认18岁
    _birthday = DateTime.now().subtract(Duration(days: 365 * 18));
  }

  String get _formattedBirthday {
    return '${_birthday.year}年${_birthday.month}月${_birthday.day}日';
  }

  int get _age {
    final now = DateTime.now();
    int age = now.year - _birthday.year;
    if (now.month < _birthday.month ||
        (now.month == _birthday.month && now.day < _birthday.day)) {
      age--;
    }
    return age;
  }

  void _showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text('确定'),
                    onPressed: () {
                      widget.onChanged(_birthday);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _birthday,
                minimumYear: 1920,
                maximumYear: DateTime.now().year,
                maximumDate: DateTime.now(),
                dateOrder: DatePickerDateOrder.ymd, // 年月日顺序
                onDateTimeChanged: (value) {
                  setState(() => _birthday = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text('生日'),
      additionalInfo: Text('$_formattedBirthday ($_age岁)'),
      trailing: CupertinoListTileChevron(),
      onTap: _showPicker,
    );
  }
}
```

### 3. 预约时间选择器

```dart
class AppointmentPicker extends StatefulWidget {
  @override
  State<AppointmentPicker> createState() => _AppointmentPickerState();
}

class _AppointmentPickerState extends State<AppointmentPicker> {
  DateTime _appointmentTime = DateTime.now().add(Duration(hours: 1));

  // 获取最近的可预约时间（向上取整到30分钟）
  DateTime _getNextAvailableTime() {
    final now = DateTime.now();
    final minutes = now.minute;
    final roundedMinutes = ((minutes / 30).ceil()) * 30;
    return DateTime(now.year, now.month, now.day, now.hour, 0)
        .add(Duration(minutes: roundedMinutes + 30));
  }

  String get _formattedAppointment {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[_appointmentTime.weekday - 1];
    return '${_appointmentTime.month}月${_appointmentTime.day}日 $weekday '
        '${_appointmentTime.hour.toString().padLeft(2, '0')}:'
        '${_appointmentTime.minute.toString().padLeft(2, '0')}';
  }

  void _showPicker() {
    final minTime = _getNextAvailableTime();
    final maxTime = DateTime.now().add(Duration(days: 30));
    
    // 确保初始时间在有效范围内
    if (_appointmentTime.isBefore(minTime)) {
      _appointmentTime = minTime;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    '选择预约时间',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('确定'),
                    onPressed: () {
                      Navigator.pop(context);
                      // 处理预约逻辑
                      _confirmAppointment();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _appointmentTime,
                minimumDate: minTime,
                maximumDate: maxTime,
                minuteInterval: 30, // 30分钟间隔
                use24hFormat: true,
                showDayOfWeek: true, // iOS 17+ 显示星期
                onDateTimeChanged: (value) {
                  setState(() => _appointmentTime = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAppointment() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('预约成功'),
        content: Text('您已预约 $_formattedAppointment'),
        actions: [
          CupertinoDialogAction(
            child: Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text('预约信息'),
      children: [
        CupertinoListTile(
          leading: Icon(CupertinoIcons.calendar),
          title: Text('预约时间'),
          additionalInfo: Text(_formattedAppointment),
          trailing: CupertinoListTileChevron(),
          onTap: _showPicker,
        ),
      ],
    );
  }
}
```

### 4. 时间选择器

```dart
class TimePickerDemo extends StatefulWidget {
  @override
  State&lt;TimePickerDemo&gt; createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State&lt;TimePickerDemo&gt; {
  DateTime _selectedTime = DateTime.now();

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('选择时间'),
                  CupertinoButton(
                    child: Text('确定'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _selectedTime,
                use24hFormat: true,
                minuteInterval: 5, // 5分钟间隔
                onDateTimeChanged: (value) {
                  setState(() => _selectedTime = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text('闹钟设置'),
      children: [
        CupertinoListTile(
          title: Text('起床时间'),
          additionalInfo: Text(
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
          ),
          trailing: CupertinoListTileChevron(),
          onTap: _showTimePicker,
        ),
      ],
    );
  }
}
```

### 5. 月年选择器

```dart
class MonthYearPickerDemo extends StatefulWidget {
  @override
  State<MonthYearPickerDemo> createState() => _MonthYearPickerDemoState();
}

class _MonthYearPickerDemoState extends State<MonthYearPickerDemo> {
  DateTime _selectedMonth = DateTime.now();

  String get _formattedMonth {
    return '${_selectedMonth.year}年${_selectedMonth.month}月';
  }

  void _showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    '选择月份',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('确定'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.monthYear,
                initialDateTime: _selectedMonth,
                minimumYear: 2020,
                maximumYear: 2030,
                onDateTimeChanged: (value) {
                  setState(() => _selectedMonth = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text('账单查询'),
      children: [
        CupertinoListTile(
          leading: Icon(CupertinoIcons.doc_text),
          title: Text('账单月份'),
          additionalInfo: Text(_formattedMonth),
          trailing: CupertinoListTileChevron(),
          onTap: _showPicker,
        ),
      ],
    );
  }
}
```

### 6. 日期范围选择

```dart
class DateRangePicker extends StatefulWidget {
  @override
  State&lt;DateRangePicker&gt; createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State&lt;DateRangePicker&gt; {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  void _selectDate({required bool isStart}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = isStart ? _startDate : _endDate;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      isStart ? '开始日期' : '结束日期',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text('确定'),
                      onPressed: () {
                        setState(() {
                          if (isStart) {
                            _startDate = tempDate;
                            // 确保开始日期不晚于结束日期
                            if (_startDate.isAfter(_endDate)) {
                              _endDate = _startDate;
                            }
                          } else {
                            _endDate = tempDate;
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: isStart ? _startDate : _endDate,
                  minimumDate: isStart ? null : _startDate,
                  maximumDate: isStart 
                      ? _endDate 
                      : DateTime.now().add(Duration(days: 365)),
                  onDateTimeChanged: (value) {
                    tempDate = value;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Text('日期范围'),
      children: [
        CupertinoListTile(
          title: Text('开始'),
          additionalInfo: Text(_formatDate(_startDate)),
          trailing: CupertinoListTileChevron(),
          onTap: () => _selectDate(isStart: true),
        ),
        CupertinoListTile(
          title: Text('结束'),
          additionalInfo: Text(_formatDate(_endDate)),
          trailing: CupertinoListTileChevron(),
          onTap: () => _selectDate(isStart: false),
        ),
      ],
    );
  }
}
```

### 7. 倒计时选择器

```dart
class CountdownPicker extends StatefulWidget {
  @override
  State<CountdownPicker> createState() => _CountdownPickerState();
}

class _CountdownPickerState extends State<CountdownPicker> {
  Duration _duration = Duration(minutes: 5);

  void _showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text('开始'),
                    onPressed: () {
                      Navigator.pop(context);
                      // 开始倒计时
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm, // 时:分
                initialTimerDuration: _duration,
                minuteInterval: 1,
                onTimerDurationChanged: (Duration value) {
                  setState(() => _duration = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _formattedDuration {
    final hours = _duration.inHours;
    final minutes = _duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours小时$minutes分钟';
    }
    return '$minutes分钟';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: _showPicker,
      child: Text('设置倒计时: $_formattedDuration'),
    );
  }
}
```

## 完整示例

### 综合日期时间选择演示

```dart
import 'package:flutter/cupertino.dart';

class DateTimePickerDemo extends StatefulWidget {
  @override
  State<DateTimePickerDemo> createState() => _DateTimePickerDemoState();
}

class _DateTimePickerDemoState extends State<DateTimePickerDemo> {
  DateTime _birthday = DateTime(2000, 1, 1);
  DateTime _appointmentDate = DateTime.now();
  DateTime _appointmentTime = DateTime.now();
  DateTime _selectedMonth = DateTime.now();

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showDatePicker({
    required CupertinoDatePickerMode mode,
    required DateTime initialDate,
    required ValueChanged<DateTime> onChanged,
    DateTime? minimumDate,
    DateTime? maximumDate,
    int? minimumYear,
    int? maximumYear,
    int minuteInterval = 1,
    bool use24hFormat = true,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime tempDate = initialDate;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              // 顶部工具栏
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('确定'),
                      onPressed: () {
                        onChanged(tempDate);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              // 日期选择器
              Expanded(
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: initialDate,
                  minimumDate: minimumDate,
                  maximumDate: maximumDate,
                  minimumYear: minimumYear ?? 1,
                  maximumYear: maximumYear,
                  minuteInterval: minuteInterval,
                  use24hFormat: use24hFormat,
                  onDateTimeChanged: (value) {
                    tempDate = value;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('日期时间选择器'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // 生日选择
            CupertinoListSection.insetGrouped(
              header: Text('生日选择'),
              children: [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.gift),
                  title: Text('出生日期'),
                  additionalInfo: Text(_formatDate(_birthday)),
                  trailing: CupertinoListTileChevron(),
                  onTap: () => _showDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDate: _birthday,
                    minimumYear: 1920,
                    maximumYear: DateTime.now().year,
                    maximumDate: DateTime.now(),
                    onChanged: (value) => setState(() => _birthday = value),
                  ),
                ),
              ],
            ),

            // 预约时间
            CupertinoListSection.insetGrouped(
              header: Text('预约时间'),
              children: [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.calendar),
                  title: Text('日期'),
                  additionalInfo: Text(_formatDate(_appointmentDate)),
                  trailing: CupertinoListTileChevron(),
                  onTap: () => _showDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDate: _appointmentDate,
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime.now().add(Duration(days: 90)),
                    onChanged: (value) => setState(() => _appointmentDate = value),
                  ),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.clock),
                  title: Text('时间'),
                  additionalInfo: Text(_formatTime(_appointmentTime)),
                  trailing: CupertinoListTileChevron(),
                  onTap: () => _showDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDate: _appointmentTime,
                    minuteInterval: 15,
                    onChanged: (value) => setState(() => _appointmentTime = value),
                  ),
                ),
              ],
            ),

            // 月份选择
            CupertinoListSection.insetGrouped(
              header: Text('月份选择'),
              children: [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.doc_chart),
                  title: Text('报表月份'),
                  additionalInfo: Text('${_selectedMonth.year}年${_selectedMonth.month}月'),
                  trailing: CupertinoListTileChevron(),
                  onTap: () => _showDatePicker(
                    mode: CupertinoDatePickerMode.monthYear,
                    initialDate: _selectedMonth,
                    minimumYear: 2020,
                    maximumYear: 2030,
                    onChanged: (value) => setState(() => _selectedMonth = value),
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

## Material vs Cupertino 日期选择器

| 特性 | Material | Cupertino |
|------|----------|-----------|
| 外观 | 日历网格 | 滚轮选择 |
| 交互 | 点击选择 | 滚动选择 |
| 弹出方式 | 对话框 | 底部面板 |
| 范围选择 | 支持 | 需自定义 |

## 最佳实践

1. **底部弹出**: 日期选择器通常从底部弹出，使用 `showCupertinoModalPopup`
2. **显示确认按钮**: 提供明确的确认和取消操作，让用户可以取消选择
3. **合理的默认值**: 设置符合使用场景的初始值，减少用户操作
4. **限制范围**: 根据业务需求合理限制可选范围（如生日不能超过今天）
5. **分钟间隔**: 对于预约场景，使用 `minuteInterval` 设置合理间隔（如 15、30 分钟）
6. **本地化**: 使用 `dateOrder` 配置日期顺序以适应不同地区习惯
7. **状态管理**: 使用临时变量存储选择值，确认后再更新状态
8. **高度适配**: 选择器容器高度建议 250-300，保证良好的滚动体验
9. **使用 24 小时制**: 中国用户习惯 24 小时制，设置 `use24hFormat: true`
10. **显示星期**: iOS 17+ 可启用 `showDayOfWeek` 让用户更直观地选择日期

## 注意事项

- `initialDateTime` 必须在 `minimumDate` 和 `maximumDate` 范围内
- `minuteInterval` 必须是 60 的因数（1、2、3、4、5、6、10、12、15、20、30）
- 在 `time` 模式下，日期部分会被忽略
- 在 `monthYear` 模式下，只考虑年月，日会被设为 1

## 相关组件

- [CupertinoTimerPicker](./cupertinotimerpicker) - 时长选择器
- [CupertinoPicker](./cupertinopicker) - 通用滚轮选择器
- [showDatePicker](../material/showdatepicker) - Material 风格日期选择器
- [DatePickerDialog](../material/datepickerdialog) - Material 日期选择对话框

## 官方文档

- [CupertinoDatePicker API](https://api.flutter.dev/flutter/cupertino/CupertinoDatePicker-class.html)
- [iOS Date and Time Pickers](https://developer.apple.com/design/human-interface-guidelines/pickers)
