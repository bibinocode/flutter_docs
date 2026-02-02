# SharedPreferences

SharedPreferences 是 Flutter 官方提供的轻量级键值对存储插件，适合存储简单的配置数据，如用户设置、登录状态等。

## 安装

```yaml
dependencies:
  shared_preferences: ^2.5.4
```

```bash
flutter pub add shared_preferences
```

## 支持的数据类型

- `int` - 整数
- `double` - 浮点数
- `bool` - 布尔值
- `String` - 字符串
- `List<String>` - 字符串列表

::: warning 注意
SharedPreferences 不适合存储大量数据或敏感信息。数据可能异步写入磁盘，不保证立即持久化。
:::

## 三种 API 对比

从 2.3.0 版本开始，SharedPreferences 提供三种 API：

| API | 特点 | 适用场景 |
|-----|------|----------|
| `SharedPreferences` | 同步读取（有缓存） | 旧版 API，将来会废弃 |
| `SharedPreferencesAsync` | 异步读取（无缓存） | 多 Isolate、多引擎场景 |
| `SharedPreferencesWithCache` | 同步读取 + 白名单 | 新项目推荐 |

---

## SharedPreferences（经典 API）

### 基本使用

```dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  // 获取实例（异步，会加载所有数据到缓存）
  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }
  
  // 写入数据
  static Future<void> saveUserSettings() async {
    final prefs = await _prefs;
    
    // 保存整数
    await prefs.setInt('counter', 10);
    
    // 保存布尔值
    await prefs.setBool('darkMode', true);
    
    // 保存浮点数
    await prefs.setDouble('fontSize', 16.5);
    
    // 保存字符串
    await prefs.setString('username', 'Flutter');
    
    // 保存字符串列表
    await prefs.setStringList('tags', ['Dart', 'Flutter', 'Mobile']);
  }
  
  // 读取数据（同步，从缓存读取）
  static Future<void> loadUserSettings() async {
    final prefs = await _prefs;
    
    // 读取整数，不存在返回 null
    final int? counter = prefs.getInt('counter');
    
    // 读取布尔值
    final bool? darkMode = prefs.getBool('darkMode');
    
    // 读取浮点数
    final double? fontSize = prefs.getDouble('fontSize');
    
    // 读取字符串
    final String? username = prefs.getString('username');
    
    // 读取字符串列表
    final List<String>? tags = prefs.getStringList('tags');
    
    print('Counter: $counter');
    print('Dark Mode: $darkMode');
    print('Font Size: $fontSize');
    print('Username: $username');
    print('Tags: $tags');
  }
  
  // 删除数据
  static Future<void> removeData() async {
    final prefs = await _prefs;
    
    // 删除单个键
    await prefs.remove('counter');
    
    // 清空所有数据
    await prefs.clear();
  }
  
  // 检查键是否存在
  static Future<bool> hasKey(String key) async {
    final prefs = await _prefs;
    return prefs.containsKey(key);
  }
  
  // 获取所有键
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _prefs;
    return prefs.getKeys();
  }
}
```

### 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  double _fontSize = 16.0;
  String _language = 'zh';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _language = prefs.getString('language') ?? 'zh';
    });
  }
  
  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _darkMode = value);
  }
  
  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', value);
    setState(() => _fontSize = value);
  }
  
  Future<void> _saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    setState(() => _language = value);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('启用深色主题'),
            value: _darkMode,
            onChanged: _saveDarkMode,
          ),
          ListTile(
            title: const Text('字体大小'),
            subtitle: Text('${_fontSize.toInt()} px'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                onChanged: _saveFontSize,
              ),
            ),
          ),
          ListTile(
            title: const Text('语言'),
            subtitle: Text(_language == 'zh' ? '中文' : 'English'),
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'zh', child: Text('中文')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) _saveLanguage(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## SharedPreferencesAsync（新版异步 API）

无缓存，每次读取都从原生存储获取最新数据。适合多 Isolate 或多引擎场景。

```dart
import 'package:shared_preferences/shared_preferences.dart';

class AsyncPrefsService {
  final _asyncPrefs = SharedPreferencesAsync();
  
  // 写入数据
  Future<void> saveData() async {
    await _asyncPrefs.setBool('notifications', true);
    await _asyncPrefs.setString('token', 'abc123');
    await _asyncPrefs.setInt('loginCount', 5);
    await _asyncPrefs.setDouble('rating', 4.5);
    await _asyncPrefs.setStringList('favorites', ['item1', 'item2']);
  }
  
  // 读取数据（异步）
  Future<void> loadData() async {
    final notifications = await _asyncPrefs.getBool('notifications');
    final token = await _asyncPrefs.getString('token');
    final loginCount = await _asyncPrefs.getInt('loginCount');
    final rating = await _asyncPrefs.getDouble('rating');
    final favorites = await _asyncPrefs.getStringList('favorites');
    
    print('Notifications: $notifications');
    print('Token: $token');
    print('Login Count: $loginCount');
    print('Rating: $rating');
    print('Favorites: $favorites');
  }
  
  // 删除数据
  Future<void> removeData() async {
    await _asyncPrefs.remove('token');
  }
  
  // 清空指定键（使用白名单）
  Future<void> clearWithAllowList() async {
    await _asyncPrefs.clear(
      allowList: {'notifications', 'token'}, // 只清除这些键
    );
  }
  
  // 获取所有键
  Future<Set<String>> getAllKeys() async {
    return await _asyncPrefs.getKeys();
  }
}
```

---

## SharedPreferencesWithCache（推荐）

结合缓存和白名单，适合新项目使用。

```dart
import 'package:shared_preferences/shared_preferences.dart';

class CachedPrefsService {
  static SharedPreferencesWithCache? _prefsWithCache;
  
  // 初始化（在 main 中调用）
  static Future<void> init() async {
    _prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        // 白名单：只有这些键可以被使用
        allowList: <String>{
          'darkMode',
          'fontSize',
          'language',
          'username',
          'token',
        },
      ),
    );
  }
  
  static SharedPreferencesWithCache get prefs {
    if (_prefsWithCache == null) {
      throw StateError('SharedPreferencesWithCache not initialized');
    }
    return _prefsWithCache!;
  }
  
  // 写入（异步）
  static Future<void> setDarkMode(bool value) async {
    await prefs.setBool('darkMode', value);
  }
  
  // 读取（同步，从缓存）
  static bool getDarkMode() {
    return prefs.getBool('darkMode') ?? false;
  }
  
  static Future<void> setUsername(String value) async {
    await prefs.setString('username', value);
  }
  
  static String? getUsername() {
    return prefs.getString('username');
  }
  
  // 删除
  static Future<void> removeToken() async {
    await prefs.remove('token');
  }
  
  // 清空所有（白名单内的键）
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}

// 使用
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化
  await CachedPrefsService.init();
  
  // 读取（同步）
  final darkMode = CachedPrefsService.getDarkMode();
  print('Dark mode: $darkMode');
  
  // 写入
  await CachedPrefsService.setDarkMode(true);
  
  runApp(MyApp());
}
```

---

## 存储复杂数据

SharedPreferences 只支持基本类型，存储复杂对象需要序列化。

### 存储 JSON 对象

```dart
import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );
}

class UserPrefs {
  static const _userKey = 'current_user';
  
  // 保存用户
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);
  }
  
  // 读取用户
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    if (jsonString == null) return null;
    
    final json = jsonDecode(jsonString);
    return User.fromJson(json);
  }
  
  // 删除用户
  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
```

### 存储对象列表

```dart
class CartPrefs {
  static const _cartKey = 'cart_items';
  
  static Future<void> saveCartItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_cartKey, jsonList);
  }
  
  static Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_cartKey) ?? [];
    return jsonList
        .map((e) => CartItem.fromJson(jsonDecode(e)))
        .toList();
  }
}
```

---

## 封装工具类

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences? _prefs;
  
  /// 初始化（在 main 中调用）
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('Storage not initialized. Call Storage.init() first.');
    }
    return _prefs!;
  }
  
  // ===== 基本类型 =====
  
  static Future<bool> setInt(String key, int value) {
    return _instance.setInt(key, value);
  }
  
  static int? getInt(String key) {
    return _instance.getInt(key);
  }
  
  static Future<bool> setBool(String key, bool value) {
    return _instance.setBool(key, value);
  }
  
  static bool? getBool(String key) {
    return _instance.getBool(key);
  }
  
  static Future<bool> setDouble(String key, double value) {
    return _instance.setDouble(key, value);
  }
  
  static double? getDouble(String key) {
    return _instance.getDouble(key);
  }
  
  static Future<bool> setString(String key, String value) {
    return _instance.setString(key, value);
  }
  
  static String? getString(String key) {
    return _instance.getString(key);
  }
  
  static Future<bool> setStringList(String key, List<String> value) {
    return _instance.setStringList(key, value);
  }
  
  static List<String>? getStringList(String key) {
    return _instance.getStringList(key);
  }
  
  // ===== JSON 对象 =====
  
  static Future<bool> setJson(String key, Map<String, dynamic> value) {
    return _instance.setString(key, jsonEncode(value));
  }
  
  static Map<String, dynamic>? getJson(String key) {
    final str = _instance.getString(key);
    if (str == null) return null;
    return jsonDecode(str);
  }
  
  // ===== 泛型对象 =====
  
  static Future<bool> setObject<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson,
  ) {
    return _instance.setString(key, jsonEncode(toJson(value)));
  }
  
  static T? getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final str = _instance.getString(key);
    if (str == null) return null;
    return fromJson(jsonDecode(str));
  }
  
  // ===== 其他操作 =====
  
  static Future<bool> remove(String key) {
    return _instance.remove(key);
  }
  
  static Future<bool> clear() {
    return _instance.clear();
  }
  
  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }
  
  static Set<String> getKeys() {
    return _instance.getKeys();
  }
  
  /// 重新加载（多进程场景）
  static Future<void> reload() {
    return _instance.reload();
  }
}

// 使用示例
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  
  // 基本类型
  await Storage.setBool('isLoggedIn', true);
  final isLoggedIn = Storage.getBool('isLoggedIn') ?? false;
  
  // JSON 对象
  await Storage.setJson('config', {'theme': 'dark', 'lang': 'zh'});
  final config = Storage.getJson('config');
  
  // 自定义对象
  await Storage.setObject('user', user, (u) => u.toJson());
  final user = Storage.getObject('user', User.fromJson);
  
  runApp(MyApp());
}
```

---

## 平台存储位置

| 平台 | SharedPreferences | SharedPreferencesAsync |
|------|-------------------|----------------------|
| Android | SharedPreferences | DataStore 或 SharedPreferences |
| iOS | NSUserDefaults | NSUserDefaults |
| macOS | NSUserDefaults | NSUserDefaults |
| Linux | XDG_DATA_HOME 目录 | XDG_DATA_HOME 目录 |
| Windows | AppData/Roaming 目录 | AppData/Roaming 目录 |
| Web | LocalStorage | LocalStorage |

---

## 最佳实践

1. **在 main 中初始化** - 避免每次使用都等待
2. **使用常量定义 Key** - 避免拼写错误
3. **封装业务相关方法** - 提高可维护性
4. **不存储敏感数据** - 使用 flutter_secure_storage 存储密码、token
5. **新项目使用 WithCache** - 更好的 API 设计

```dart
// 定义 Key 常量
class StorageKeys {
  static const darkMode = 'dark_mode';
  static const fontSize = 'font_size';
  static const language = 'language';
  static const token = 'auth_token';
  static const user = 'current_user';
}
```

## 相关资源

- [shared_preferences 官方文档](https://pub.dev/packages/shared_preferences)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - 安全存储敏感数据
