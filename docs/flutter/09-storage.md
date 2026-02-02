# 数据持久化

Flutter 提供多种数据存储方案，从简单的键值对到复杂的关系型数据库。本章将详细介绍各种存储方案的使用。

## SharedPreferences（轻量存储）

适用于存储简单的键值对数据，如用户设置、登录状态等。

### 安装

```yaml
dependencies:
  shared_preferences: ^2.2.2
```

### 基本使用

```dart
import 'package:shared_preferences/shared_preferences.dart';

// 存储数据
Future&lt;void&gt; saveData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // 存储不同类型
  await prefs.setString('username', 'Alice');
  await prefs.setInt('age', 25);
  await prefs.setDouble('height', 1.68);
  await prefs.setBool('isLoggedIn', true);
  await prefs.setStringList('tags', ['flutter', 'dart']);
}

// 读取数据
Future&lt;void&gt; loadData() async {
  final prefs = await SharedPreferences.getInstance();
  
  final username = prefs.getString('username');  // Alice 或 null
  final age = prefs.getInt('age') ?? 0;  // 提供默认值
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
}

// 删除数据
Future&lt;void&gt; removeData() async {
  final prefs = await SharedPreferences.getInstance();
  
  await prefs.remove('username');  // 删除单个
  await prefs.clear();  // 清空所有
}
```

### 封装服务

```dart
class PreferencesService {
  static SharedPreferences? _prefs;
  
  static Future&lt;void&gt; init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized');
    }
    return _prefs!;
  }
  
  // 用户设置
  static const _keyThemeMode = 'theme_mode';
  static const _keyLanguage = 'language';
  static const _keyNotifications = 'notifications_enabled';
  
  ThemeMode get themeMode {
    final value = instance.getString(_keyThemeMode);
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }
  
  set themeMode(ThemeMode mode) {
    instance.setString(_keyThemeMode, mode.name);
  }
  
  String get language => instance.getString(_keyLanguage) ?? 'zh';
  set language(String value) => instance.setString(_keyLanguage, value);
  
  bool get notificationsEnabled =>
      instance.getBool(_keyNotifications) ?? true;
  set notificationsEnabled(bool value) =>
      instance.setBool(_keyNotifications, value);
}

// 初始化（在 main.dart）
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.init();
  runApp(MyApp());
}
```

## 文件存储

### path_provider

```yaml
dependencies:
  path_provider: ^2.1.2
```

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  // 获取应用文档目录
  Future&lt;Directory&gt; get _documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }
  
  // 获取临时目录
  Future&lt;Directory&gt; get _tempDirectory async {
    return await getTemporaryDirectory();
  }
  
  // 获取缓存目录
  Future&lt;Directory&gt; get _cacheDirectory async {
    return await getApplicationCacheDirectory();
  }
  
  // 写入文本文件
  Future&lt;File&gt; writeTextFile(String filename, String content) async {
    final dir = await _documentsDirectory;
    final file = File('${dir.path}/$filename');
    return file.writeAsString(content);
  }
  
  // 读取文本文件
  Future&lt;String&gt; readTextFile(String filename) async {
    final dir = await _documentsDirectory;
    final file = File('${dir.path}/$filename');
    
    if (await file.exists()) {
      return file.readAsString();
    }
    throw FileNotFoundException(filename);
  }
  
  // 写入 JSON
  Future&lt;void&gt; writeJson(String filename, Map&lt;String, dynamic&gt; data) async {
    final jsonStr = jsonEncode(data);
    await writeTextFile(filename, jsonStr);
  }
  
  // 读取 JSON
  Future&lt;Map&lt;String, dynamic&gt;&gt; readJson(String filename) async {
    final content = await readTextFile(filename);
    return jsonDecode(content);
  }
  
  // 删除文件
  Future&lt;void&gt; deleteFile(String filename) async {
    final dir = await _documentsDirectory;
    final file = File('${dir.path}/$filename');
    
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  // 列出所有文件
  Future&lt;List&lt;FileSystemEntity&gt;&gt; listFiles() async {
    final dir = await _documentsDirectory;
    return dir.list().toList();
  }
}
```

### 存储复杂对象

```dart
class UserDataService {
  final FileService _fileService;
  static const _filename = 'user_data.json';
  
  UserDataService(this._fileService);
  
  Future&lt;void&gt; saveUserProfile(UserProfile profile) async {
    await _fileService.writeJson(_filename, profile.toJson());
  }
  
  Future&lt;UserProfile?&gt; loadUserProfile() async {
    try {
      final json = await _fileService.readJson(_filename);
      return UserProfile.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
```

## SQLite 数据库

### sqflite 包

```yaml
dependencies:
  sqflite: ^2.3.2
  path: ^1.8.3
```

### 数据库辅助类

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const _databaseName = 'app_database.db';
  static const _databaseVersion = 1;
  
  Future&lt;Database&gt; get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future&lt;Database&gt; _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future&lt;void&gt; _onCreate(Database db, int version) async {
    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        avatar_url TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // 创建文章表
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        is_published INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // 创建索引
    await db.execute('CREATE INDEX idx_posts_user_id ON posts (user_id)');
  }
  
  Future&lt;void&gt; _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 版本 2 的迁移
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
    }
    if (oldVersion < 3) {
      // 版本 3 的迁移
      // ...
    }
  }
}
```

### CRUD 操作

```dart
class UserDao {
  final DatabaseHelper _dbHelper;
  
  UserDao(this._dbHelper);
  
  // 插入
  Future&lt;int&gt; insert(User user) async {
    final db = await _dbHelper.database;
    return db.insert('users', user.toMap());
  }
  
  // 批量插入
  Future&lt;void&gt; insertAll(List&lt;User&gt; users) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    
    for (final user in users) {
      batch.insert('users', user.toMap());
    }
    
    await batch.commit(noResult: true);
  }
  
  // 查询所有
  Future&lt;List&lt;User&gt;&gt; getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((map) => User.fromMap(map)).toList();
  }
  
  // 条件查询
  Future&lt;User?&gt; getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  // 分页查询
  Future&lt;List&lt;User&gt;&gt; getPage(int page, int pageSize) async {
    final db = await _dbHelper.database;
    final offset = (page - 1) * pageSize;
    
    final maps = await db.query(
      'users',
      orderBy: 'created_at DESC',
      limit: pageSize,
      offset: offset,
    );
    
    return maps.map((map) => User.fromMap(map)).toList();
  }
  
  // 搜索
  Future&lt;List&lt;User&gt;&gt; search(String keyword) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    
    return maps.map((map) => User.fromMap(map)).toList();
  }
  
  // 更新
  Future&lt;int&gt; update(User user) async {
    final db = await _dbHelper.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
  
  // 删除
  Future&lt;int&gt; delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // 计数
  Future&lt;int&gt; count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
```

### 复杂查询

```dart
class PostDao {
  final DatabaseHelper _dbHelper;
  
  PostDao(this._dbHelper);
  
  // 联表查询
  Future&lt;List&lt;PostWithUser&gt;&gt; getPostsWithUser() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT 
        posts.*,
        users.name as user_name,
        users.avatar_url as user_avatar
      FROM posts
      INNER JOIN users ON posts.user_id = users.id
      ORDER BY posts.created_at DESC
    ''');
    
    return maps.map((map) => PostWithUser.fromMap(map)).toList();
  }
  
  // 聚合查询
  Future&lt;Map&lt;int, int&gt;&gt; getPostCountByUser() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT user_id, COUNT(*) as post_count
      FROM posts
      GROUP BY user_id
    ''');
    
    return Map.fromEntries(
      maps.map((m) => MapEntry(m['user_id'] as int, m['post_count'] as int)),
    );
  }
  
  // 事务
  Future&lt;void&gt; transferPost(int postId, int fromUserId, int toUserId) async {
    final db = await _dbHelper.database;
    
    await db.transaction((txn) async {
      // 检查文章是否属于原用户
      final post = await txn.query(
        'posts',
        where: 'id = ? AND user_id = ?',
        whereArgs: [postId, fromUserId],
      );
      
      if (post.isEmpty) {
        throw Exception('文章不存在或不属于该用户');
      }
      
      // 更新文章所有者
      await txn.update(
        'posts',
        {'user_id': toUserId},
        where: 'id = ?',
        whereArgs: [postId],
      );
    });
  }
}
```

## Drift（SQLite ORM）

Drift 是一个强类型的 SQLite ORM，提供编译时安全检查。

### 安装

```yaml
dependencies:
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.20

dev_dependencies:
  drift_dev: ^2.15.0
  build_runner: ^2.4.8
```

### 定义表

```dart
import 'package:drift/drift.dart';

part 'database.g.dart';

// 定义用户表
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get email => text().unique()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 定义文章表
class Posts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 数据库类
@DriftDatabase(tables: [Users, Posts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // 迁移逻辑
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

### 类型安全的 CRUD

```dart
// 扩展数据库类添加方法
extension UserQueries on AppDatabase {
  // 获取所有用户
  Future&lt;List&lt;User&gt;&gt; getAllUsers() {
    return select(users).get();
  }
  
  // 监听用户变化
  Stream&lt;List&lt;User&gt;&gt; watchAllUsers() {
    return select(users).watch();
  }
  
  // 插入用户
  Future&lt;int&gt; insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }
  
  // 更新用户
  Future&lt;bool&gt; updateUser(User user) {
    return update(users).replace(user);
  }
  
  // 删除用户
  Future&lt;int&gt; deleteUser(int id) {
    return (delete(users)..where((t) => t.id.equals(id))).go();
  }
  
  // 条件查询
  Future&lt;User?&gt; getUserByEmail(String email) {
    return (select(users)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }
  
  // 联表查询
  Future&lt;List&lt;(User, Post)&gt;&gt; getUsersWithPosts() {
    final query = select(users).join([
      innerJoin(posts, posts.userId.equalsExp(users.id)),
    ]);
    
    return query.map((row) {
      return (row.readTable(users), row.readTable(posts));
    }).get();
  }
}
```

## Hive（高性能 NoSQL）

Hive 是一个轻量级的键值数据库，性能优秀。

### 安装

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

### 初始化

```dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // 注册适配器
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PostAdapter());
  
  // 打开 Box
  await Hive.openBox&lt;User&gt;('users');
  await Hive.openBox('settings');
  
  runApp(MyApp());
}
```

### 定义模型

```dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String name;
  
  @HiveField(2)
  late String email;
  
  @HiveField(3)
  String? avatarUrl;
  
  @HiveField(4)
  late DateTime createdAt;
}

// 运行生成命令
// dart run build_runner build
```

### CRUD 操作

```dart
class UserRepository {
  Box&lt;User&gt; get _box => Hive.box&lt;User&gt;('users');
  
  // 添加
  Future&lt;void&gt; add(User user) async {
    await _box.put(user.id, user);
  }
  
  // 获取
  User? get(String id) {
    return _box.get(id);
  }
  
  // 获取所有
  List&lt;User&gt; getAll() {
    return _box.values.toList();
  }
  
  // 更新
  Future&lt;void&gt; update(User user) async {
    await user.save();  // HiveObject 的方法
  }
  
  // 删除
  Future&lt;void&gt; delete(String id) async {
    await _box.delete(id);
  }
  
  // 清空
  Future&lt;void&gt; clear() async {
    await _box.clear();
  }
  
  // 监听变化
  Stream&lt;BoxEvent&gt; watch({String? key}) {
    return _box.watch(key: key);
  }
  
  // 监听所有变化
  ValueListenable&lt;Box&lt;User&gt;&gt; listenable() {
    return _box.listenable();
  }
}
```

### 在 Widget 中使用

```dart
class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box&lt;User&gt;('users').listenable(),
      builder: (context, Box&lt;User&gt; box, _) {
        final users = box.values.toList();
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => user.delete(),
              ),
            );
          },
        );
      },
    );
  }
}
```

## 安全存储

### flutter_secure_storage

用于存储敏感数据，如 Token、密码等。

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  // Token 管理
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  
  Future&lt;void&gt; saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }
  
  Future&lt;String?&gt; getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }
  
  Future&lt;String?&gt; getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }
  
  Future&lt;void&gt; clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }
  
  // 通用方法
  Future&lt;void&gt; write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  Future&lt;String?&gt; read(String key) async {
    return _storage.read(key: key);
  }
  
  Future&lt;void&gt; delete(String key) async {
    await _storage.delete(key: key);
  }
  
  Future&lt;void&gt; deleteAll() async {
    await _storage.deleteAll();
  }
}
```

## 数据同步策略

### 离线优先模式

```dart
class SyncService {
  final UserRepository _localRepo;
  final UserApiService _apiService;
  final ConnectivityService _connectivity;
  
  SyncService(this._localRepo, this._apiService, this._connectivity);
  
  // 获取用户（离线优先）
  Future&lt;List&lt;User&gt;&gt; getUsers({bool forceRefresh = false}) async {
    // 先返回本地数据
    final localUsers = await _localRepo.getAll();
    
    if (!forceRefresh && localUsers.isNotEmpty) {
      // 后台同步
      _syncInBackground();
      return localUsers;
    }
    
    // 尝试从网络获取
    if (await _connectivity.isConnected) {
      try {
        final remoteUsers = await _apiService.fetchUsers();
        await _localRepo.saveAll(remoteUsers);
        return remoteUsers;
      } catch (e) {
        // 网络失败，返回本地数据
        return localUsers;
      }
    }
    
    return localUsers;
  }
  
  Future&lt;void&gt; _syncInBackground() async {
    if (!await _connectivity.isConnected) return;
    
    try {
      final remoteUsers = await _apiService.fetchUsers();
      await _localRepo.saveAll(remoteUsers);
    } catch (e) {
      // 静默失败
    }
  }
  
  // 创建用户（离线队列）
  Future&lt;void&gt; createUser(User user) async {
    // 先保存到本地
    user.syncStatus = SyncStatus.pending;
    await _localRepo.save(user);
    
    // 尝试同步到服务器
    await _trySyncUser(user);
  }
  
  Future&lt;void&gt; _trySyncUser(User user) async {
    if (!await _connectivity.isConnected) return;
    
    try {
      final remoteUser = await _apiService.createUser(user);
      user.syncStatus = SyncStatus.synced;
      user.id = remoteUser.id;
      await _localRepo.save(user);
    } catch (e) {
      // 保持 pending 状态，等待下次同步
    }
  }
  
  // 同步所有待处理数据
  Future&lt;void&gt; syncPendingData() async {
    if (!await _connectivity.isConnected) return;
    
    final pendingUsers = await _localRepo.getPending();
    
    for (final user in pendingUsers) {
      await _trySyncUser(user);
    }
  }
}
```

## 最佳实践

### 1. 选择合适的存储方案

```dart
// 简单配置 -> SharedPreferences
// 敏感数据 -> flutter_secure_storage
// 结构化数据 -> SQLite (sqflite/drift)
// 高性能键值 -> Hive
// 文件数据 -> path_provider + File
```

### 2. 封装数据层

```dart
// 抽象接口
abstract class DataSource&lt;T&gt; {
  Future&lt;T?&gt; get(String id);
  Future&lt;List&lt;T&gt;&gt; getAll();
  Future&lt;void&gt; save(T item);
  Future&lt;void&gt; delete(String id);
}

// 本地实现
class LocalUserDataSource implements DataSource&lt;User&gt; {
  // 使用 SQLite 或 Hive
}

// 远程实现
class RemoteUserDataSource implements DataSource&lt;User&gt; {
  // 使用 API
}

// Repository 组合
class UserRepository {
  final DataSource&lt;User&gt; _local;
  final DataSource&lt;User&gt; _remote;
  
  // 实现数据同步逻辑
}
```

### 3. 数据库迁移

```dart
// 版本管理
class DatabaseMigration {
  static Future&lt;void&gt; migrate(Database db, int from, int to) async {
    for (var version = from + 1; version <= to; version++) {
      await _runMigration(db, version);
    }
  }
  
  static Future&lt;void&gt; _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
        break;
      case 3:
        await db.execute('CREATE INDEX idx_users_email ON users (email)');
        break;
    }
  }
}
```

## 下一步

掌握数据持久化后，下一章我们将学习 [平台集成](./10-platform)，实现与原生平台的交互。
