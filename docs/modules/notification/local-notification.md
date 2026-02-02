# 本地通知

本地通知是提高用户参与度的重要手段。与推送通知不同，本地通知完全在设备端生成，无需后端服务器，支持离线使用。本章介绍如何使用 `flutter_local_notifications` 实现各种通知场景。

## 概述

### 本地通知 vs 推送通知

| 特性 | 本地通知 | 推送通知 |
|------|----------|----------|
| 需要服务器 | ❌ 不需要 | ✅ 需要 |
| 离线使用 | ✅ 支持 | ❌ 不支持 |
| 定时触发 | ✅ 支持 | ❌ 依赖服务器 |
| 复杂度 | 低 | 高 |
| 隐私 | 设备本地 | 需传输数据 |

### 应用场景

- 🕒 **事件提醒** - 日程、会议提醒
- 💊 **服药提醒** - 定时健康提醒
- 🏋️ **目标达成** - 完成每日任务通知
- 🛒 **购物车提醒** - 提醒未完成的订单
- 📅 **每日任务** - 习惯养成提醒
- ⏰ **闹钟计时** - 计时器到期通知

## 安装配置

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^17.2.0
  timezone: ^0.9.2  # 用于定时通知
```

```bash
flutter pub get
```

### Android 配置

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- 通知权限 -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <!-- 精确闹钟权限 (Android 12+) -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    
    <application>
        <!-- 开机自启动接收器 -->
        <receiver 
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            </intent-filter>
        </receiver>
        
        <!-- 通知接收器 -->
        <receiver 
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" 
            android:exported="false"/>
    </application>
</manifest>
```

### iOS 配置

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 请求通知权限
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 初始化

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  /// 初始化
  Future<void> init() async {
    // 初始化时区
    tz.initializeTimeZones();
    
    // Android 设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // macOS 设置
    const macOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macOSSettings,
    );
    
    // 初始化插件
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );
  }
  
  /// 处理通知点击
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // 根据 payload 导航到相应页面
      print('通知被点击: $payload');
    }
  }
  
  /// 后台通知点击处理
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    print('后台通知被点击: ${response.payload}');
  }
  
  /// 请求权限
  Future<bool> requestPermission() async {
    // Android 13+ 需要请求权限
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    
    // iOS
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return true;
  }
}
```

## 显示通知

### 即时通知

```dart
class NotificationService {
  // ... 初始化代码 ...
  
  /// 显示简单通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      '默认通知',
      channelDescription: '应用的默认通知通道',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _plugin.show(id, title, body, details, payload: payload);
  }
  
  /// 显示带大图的通知
  Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imagePath,
  }) async {
    final bigPictureStyle = BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath),
      contentTitle: title,
      summaryText: body,
      htmlFormatContentTitle: true,
      htmlFormatSummaryText: true,
    );
    
    final androidDetails = AndroidNotificationDetails(
      'big_picture_channel',
      '图片通知',
      channelDescription: '带大图的通知',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureStyle,
    );
    
    final details = NotificationDetails(android: androidDetails);
    
    await _plugin.show(id, title, body, details);
  }
  
  /// 显示进度通知
  Future<void> showProgressNotification({
    required int id,
    required String title,
    required int progress,
    required int maxProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'progress_channel',
      '进度通知',
      channelDescription: '显示进度的通知',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      onlyAlertOnce: true,  // 只提醒一次
    );
    
    final details = NotificationDetails(android: androidDetails);
    
    await _plugin.show(id, title, '进度: $progress/$maxProgress', details);
  }
}
```

### 使用示例

```dart
// 在 main.dart 中初始化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(MyApp());
}

// 显示通知
class HomePage extends StatelessWidget {
  final _notificationService = NotificationService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 先请求权限
            final granted = await _notificationService.requestPermission();
            if (granted) {
              await _notificationService.showNotification(
                id: 1,
                title: '欢迎回来！',
                body: '今天有 3 个待办事项等待处理 🎯',
                payload: '/todos',
              );
            }
          },
          child: const Text('显示通知'),
        ),
      ),
    );
  }
}
```

## 定时通知

### 延迟通知

```dart
class NotificationService {
  // ... 其他代码 ...
  
  /// 延迟显示通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
    
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      '定时通知',
      channelDescription: '定时提醒通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  /// 在指定时间显示通知
  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    final scheduledTime = tz.TZDateTime.from(dateTime, tz.local);
    
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      '定时通知',
      channelDescription: '定时提醒通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
}
```

### 重复通知

```dart
class NotificationService {
  // ... 其他代码 ...
  
  /// 每日定时通知
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    // 如果时间已过，安排到明天
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    const androidDetails = AndroidNotificationDetails(
      'daily_channel',
      '每日提醒',
      channelDescription: '每日定时提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,  // 每天重复
    );
  }
  
  /// 每周定时通知
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday,  // 1 = 周一, 7 = 周日
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = _nextInstanceOfWeekday(weekday, hour, minute);
    
    const androidDetails = AndroidNotificationDetails(
      'weekly_channel',
      '每周提醒',
      channelDescription: '每周定时提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
  
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }
  
  /// 周期性通知（简单重复）
  Future<void> showPeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'periodic_channel',
      '周期通知',
      channelDescription: '定期重复的通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.periodicallyShow(
      id,
      title,
      body,
      interval,  // RepeatInterval.hourly / daily / weekly
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
```

## 通知管理

```dart
class NotificationService {
  // ... 其他代码 ...
  
  /// 取消指定通知
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
  
  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
  
  /// 获取待处理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
  
  /// 获取已显示的活跃通知（Android 仅支持 API 23+）
  Future<List<ActiveNotification>?> getActiveNotifications() async {
    return await _plugin.getActiveNotifications();
  }
}
```

## 带操作按钮的通知

```dart
class NotificationService {
  // ... 其他代码 ...
  
  /// 显示带操作按钮的通知
  Future<void> showNotificationWithActions({
    required int id,
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'action_channel',
      '操作通知',
      channelDescription: '带操作按钮的通知',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        const AndroidNotificationAction(
          'mark_done',
          '完成',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          '稍后提醒',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'dismiss',
          '忽略',
          cancelNotification: true,
        ),
      ],
    );
    
    final iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'task_category',
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _plugin.show(id, title, body, details);
  }
}
```

## 完整示例：提醒应用

```dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderApp extends StatefulWidget {
  const ReminderApp({super.key});

  @override
  State<ReminderApp> createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  final _notificationService = NotificationService();
  final List<Reminder> _reminders = [];
  
  @override
  void initState() {
    super.initState();
    _init();
  }
  
  Future<void> _init() async {
    await _notificationService.init();
    await _notificationService.requestPermission();
    await _loadPendingReminders();
  }
  
  Future<void> _loadPendingReminders() async {
    final pending = await _notificationService.getPendingNotifications();
    // 从 pending 中恢复提醒列表
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _cancelAllReminders,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return ListTile(
            leading: const Icon(Icons.alarm),
            title: Text(reminder.title),
            subtitle: Text(reminder.formattedTime),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _cancelReminder(reminder),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showAddReminderDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddReminderSheet(
        onAdd: _addReminder,
      ),
    );
  }
  
  Future<void> _addReminder(String title, DateTime dateTime) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    await _notificationService.scheduleNotificationAt(
      id: id,
      title: title,
      body: '是时候：$title',
      dateTime: dateTime,
      payload: '/reminder/$id',
    );
    
    setState(() {
      _reminders.add(Reminder(
        id: id,
        title: title,
        dateTime: dateTime,
      ));
    });
  }
  
  Future<void> _cancelReminder(Reminder reminder) async {
    await _notificationService.cancelNotification(reminder.id);
    setState(() {
      _reminders.remove(reminder);
    });
  }
  
  Future<void> _cancelAllReminders() async {
    await _notificationService.cancelAllNotifications();
    setState(() {
      _reminders.clear();
    });
  }
}

class Reminder {
  final int id;
  final String title;
  final DateTime dateTime;
  
  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
  });
  
  String get formattedTime {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class AddReminderSheet extends StatefulWidget {
  final Function(String title, DateTime dateTime) onAdd;
  
  const AddReminderSheet({super.key, required this.onAdd});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _titleController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '提醒内容',
              hintText: '输入提醒内容',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${_selectedDateTime.month}/${_selectedDateTime.day}'),
                  onPressed: _selectDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text('${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}'),
                  onPressed: _selectTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('添加提醒'),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }
  
  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }
  
  void _submit() {
    if (_titleController.text.isEmpty) return;
    
    widget.onAdd(_titleController.text, _selectedDateTime);
    Navigator.pop(context);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
```

## 最佳实践

::: tip 开发建议
1. **请求权限** - 在显示通知前先请求权限
2. **合理使用通道** - Android 8+ 需要为不同类型的通知创建不同通道
3. **不要滥用** - 过多的通知会让用户关闭权限
4. **提供价值** - 通知应该对用户有价值
5. **允许取消** - 让用户能够管理和取消通知
:::

::: warning 常见问题
- **通道 ID 一致性** - Android 通知需要通道名称保持一致
- **iOS 权限** - 需要在使用前请求权限
- **真机测试** - 部分功能需要在真机上测试
- **Android 12+** - 精确闹钟需要额外权限
:::

## 参考资源

- [flutter_local_notifications 官方文档](https://pub.dev/packages/flutter_local_notifications)
- [Android 通知最佳实践](https://developer.android.com/develop/ui/views/notifications)
- [iOS 用户通知](https://developer.apple.com/documentation/usernotifications)
