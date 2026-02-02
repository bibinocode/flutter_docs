# SQLite 数据库

sqflite 是 Flutter 官方推荐的 SQLite 插件，适合存储结构化数据，支持复杂查询、事务、关联关系等。

## 安装

```yaml
dependencies:
  sqflite: ^2.4.2
  path: ^1.9.0
```

```bash
flutter pub add sqflite path
```

## 支持平台

| 平台 | 支持情况 |
|------|----------|
| Android | ✅ |
| iOS | ✅ |
| macOS | ✅ |
| Linux/Windows | 使用 sqflite_common_ffi |
| Web | 使用 sqflite_common_ffi_web |

---

## 快速开始

### 打开数据库

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> openMyDatabase() async {
  // 获取数据库目录
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_app.db');
  
  // 打开数据库
  final db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // 创建表
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE,
          age INTEGER,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    },
  );
  
  return db;
}
```

### 基本 CRUD 操作

```dart
class UserDao {
  final Database db;
  
  UserDao(this.db);
  
  // 插入
  Future<int> insert(Map<String, dynamic> user) async {
    return await db.insert('users', user);
  }
  
  // 查询所有
  Future<List<Map<String, dynamic>>> getAll() async {
    return await db.query('users');
  }
  
  // 根据 ID 查询
  Future<Map<String, dynamic>?> getById(int id) async {
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
  
  // 更新
  Future<int> update(int id, Map<String, dynamic> user) async {
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // 删除
  Future<int> delete(int id) async {
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// 使用
void main() async {
  final db = await openMyDatabase();
  final userDao = UserDao(db);
  
  // 插入
  final id = await userDao.insert({
    'name': '张三',
    'email': 'zhangsan@example.com',
    'age': 25,
  });
  print('插入成功，ID: $id');
  
  // 查询
  final user = await userDao.getById(id);
  print('用户: $user');
  
  // 更新
  await userDao.update(id, {'age': 26});
  
  // 删除
  await userDao.delete(id);
}
```

---

## 数据库版本管理

```dart
final db = await openDatabase(
  path,
  version: 3, // 当前版本
  onCreate: (db, version) async {
    // 首次创建数据库
    await _createTables(db);
  },
  onUpgrade: (db, oldVersion, newVersion) async {
    // 版本升级迁移
    if (oldVersion < 2) {
      // v1 -> v2: 添加 phone 字段
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
    }
    if (oldVersion < 3) {
      // v2 -> v3: 创建新表
      await db.execute('''
        CREATE TABLE orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          total REAL,
          FOREIGN KEY (user_id) REFERENCES users(id)
        )
      ''');
    }
  },
  onDowngrade: onDatabaseDowngradeDelete, // 降级时删除重建
);

Future<void> _createTables(Database db) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE,
      age INTEGER,
      phone TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');
  
  await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      total REAL,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''');
}
```

---

## 查询方法

### query 辅助方法

```dart
// 基本查询
final users = await db.query('users');

// 条件查询
final adults = await db.query(
  'users',
  where: 'age >= ?',
  whereArgs: [18],
);

// 选择字段
final names = await db.query(
  'users',
  columns: ['id', 'name'],
);

// 排序
final sorted = await db.query(
  'users',
  orderBy: 'created_at DESC',
);

// 分页
final page1 = await db.query(
  'users',
  limit: 10,
  offset: 0,
);

// 去重
final distinctEmails = await db.query(
  'users',
  columns: ['email'],
  distinct: true,
);

// 分组
final ageGroups = await db.query(
  'users',
  columns: ['age', 'COUNT(*) as count'],
  groupBy: 'age',
  having: 'count > 1',
);

// 组合查询
final result = await db.query(
  'users',
  columns: ['id', 'name', 'age'],
  where: 'age >= ? AND name LIKE ?',
  whereArgs: [18, '%张%'],
  orderBy: 'age DESC, name ASC',
  limit: 20,
  offset: 0,
);
```

### rawQuery 原始 SQL

```dart
// 简单查询
final users = await db.rawQuery('SELECT * FROM users');

// 参数化查询（防 SQL 注入）
final user = await db.rawQuery(
  'SELECT * FROM users WHERE id = ?',
  [1],
);

// 复杂查询
final result = await db.rawQuery('''
  SELECT u.name, COUNT(o.id) as order_count, SUM(o.total) as total_amount
  FROM users u
  LEFT JOIN orders o ON u.id = o.user_id
  GROUP BY u.id
  HAVING order_count > 0
  ORDER BY total_amount DESC
''');

// 统计
final count = Sqflite.firstIntValue(
  await db.rawQuery('SELECT COUNT(*) FROM users'),
);
print('用户数: $count');
```

---

## 插入操作

```dart
// 基本插入
final id = await db.insert('users', {
  'name': '张三',
  'email': 'zhangsan@example.com',
  'age': 25,
});

// 冲突处理
await db.insert(
  'users',
  {'name': '张三', 'email': 'zhangsan@example.com'},
  conflictAlgorithm: ConflictAlgorithm.replace, // 替换已存在的
);

// ConflictAlgorithm 选项：
// - abort: 中止（默认）
// - fail: 失败
// - ignore: 忽略
// - replace: 替换
// - rollback: 回滚

// rawInsert
final id2 = await db.rawInsert(
  'INSERT INTO users(name, email, age) VALUES(?, ?, ?)',
  ['李四', 'lisi@example.com', 30],
);
```

---

## 更新操作

```dart
// 基本更新
final count = await db.update(
  'users',
  {'age': 26, 'name': '张三三'},
  where: 'id = ?',
  whereArgs: [1],
);
print('更新了 $count 条记录');

// rawUpdate
final count2 = await db.rawUpdate(
  'UPDATE users SET age = age + 1 WHERE age < ?',
  [30],
);
```

---

## 删除操作

```dart
// 基本删除
final count = await db.delete(
  'users',
  where: 'id = ?',
  whereArgs: [1],
);

// 删除所有
await db.delete('users');

// rawDelete
final count2 = await db.rawDelete(
  'DELETE FROM users WHERE age < ?',
  [18],
);
```

---

## 事务

```dart
// 基本事务
await db.transaction((txn) async {
  // 在事务中执行操作
  final userId = await txn.insert('users', {'name': '张三'});
  
  await txn.insert('orders', {
    'user_id': userId,
    'total': 99.99,
  });
  
  await txn.insert('orders', {
    'user_id': userId,
    'total': 199.99,
  });
  
  // 事务完成后自动提交
});

// 手动回滚事务
try {
  await db.transaction((txn) async {
    await txn.insert('users', {'name': '张三'});
    
    // 某些条件下回滚
    if (someCondition) {
      throw Exception('需要回滚');
    }
    
    await txn.insert('orders', {'user_id': 1, 'total': 100});
  });
} catch (e) {
  print('事务回滚: $e');
}

// 注意：事务中不要使用 db 对象，要用 txn
await db.transaction((txn) async {
  // ✅ 正确
  await txn.insert('users', {'name': '张三'});
  
  // ❌ 错误 - 会死锁！
  // await db.insert('users', {'name': '张三'});
});
```

---

## 批量操作

使用 Batch 可以显著提高批量操作的性能：

```dart
// 创建批处理
final batch = db.batch();

// 添加操作
batch.insert('users', {'name': '用户1', 'age': 20});
batch.insert('users', {'name': '用户2', 'age': 21});
batch.insert('users', {'name': '用户3', 'age': 22});
batch.update('users', {'age': 25}, where: 'name = ?', whereArgs: ['用户1']);
batch.delete('users', where: 'age < ?', whereArgs: [18]);

// 执行并获取结果
final results = await batch.commit();
print('操作结果: $results');

// 不关心结果时（性能更好）
await batch.commit(noResult: true);

// 忽略错误继续执行
await batch.commit(continueOnError: true);

// 在事务中使用批处理
await db.transaction((txn) async {
  final batch = txn.batch();
  
  for (int i = 0; i < 1000; i++) {
    batch.insert('users', {'name': '用户$i', 'age': 20 + i % 50});
  }
  
  await batch.commit(noResult: true);
});
```

---

## 模型类封装

### 定义模型

```dart
class User {
  final int? id;
  final String name;
  final String? email;
  final int age;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    this.email,
    required this.age,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 从 Map 创建
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      age: map['age'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  // 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'age': age,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // 复制并修改
  User copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, age: $age)';
}
```

### Repository 模式

```dart
class UserRepository {
  final Database db;
  static const _tableName = 'users';

  UserRepository(this.db);

  // 插入
  Future<User> insert(User user) async {
    final id = await db.insert(_tableName, user.toMap());
    return user.copyWith(id: id);
  }

  // 批量插入
  Future<void> insertAll(List<User> users) async {
    final batch = db.batch();
    for (var user in users) {
      batch.insert(_tableName, user.toMap());
    }
    await batch.commit(noResult: true);
  }

  // 查询所有
  Future<List<User>> findAll({int? limit, int? offset}) async {
    final maps = await db.query(
      _tableName,
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // 根据 ID 查询
  Future<User?> findById(int id) async {
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // 条件查询
  Future<List<User>> findByAge(int minAge, int maxAge) async {
    final maps = await db.query(
      _tableName,
      where: 'age >= ? AND age <= ?',
      whereArgs: [minAge, maxAge],
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // 搜索
  Future<List<User>> search(String keyword) async {
    final maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // 更新
  Future<int> update(User user) async {
    if (user.id == null) throw ArgumentError('User id cannot be null');
    return await db.update(
      _tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // 删除
  Future<int> delete(int id) async {
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 统计
  Future<int> count() async {
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 清空表
  Future<void> clear() async {
    await db.delete(_tableName);
  }
}
```

---

## 完整数据库管理类

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        age INTEGER,
        avatar_url TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // 订单表
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        order_no TEXT UNIQUE NOT NULL,
        total REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 订单项表
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_orders_user_id ON orders(user_id)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 迁移逻辑
    if (oldVersion < 2) {
      // v1 -> v2
    }
  }

  // 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // 删除数据库
  Future<void> deleteDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'app.db');
    await close();
    await deleteDatabase(path);
  }
}
```

---

## 支持的数据类型

| SQLite 类型 | Dart 类型 | 说明 |
|------------|-----------|------|
| INTEGER | `int` | -2^63 到 2^63-1 |
| REAL | `num` / `double` | 浮点数 |
| TEXT | `String` | 字符串 |
| BLOB | `Uint8List` | 二进制数据 |

::: warning 注意
- **DateTime** - 不是 SQLite 类型，存储为 TEXT（ISO8601）或 INTEGER（时间戳）
- **bool** - 不是 SQLite 类型，存储为 INTEGER（0/1）
:::

```dart
// DateTime 处理
await db.insert('events', {
  'name': 'Meeting',
  'event_time': DateTime.now().toIso8601String(), // 存为 TEXT
  // 或
  'timestamp': DateTime.now().millisecondsSinceEpoch, // 存为 INTEGER
});

// bool 处理
await db.insert('tasks', {
  'title': 'Task 1',
  'completed': true ? 1 : 0, // 存为 INTEGER
});
```

---

## 性能优化

### 使用索引

```sql
-- 在经常查询的字段上创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- 复合索引
CREATE INDEX idx_orders_status_date ON orders(status, created_at);
```

### 批量操作使用事务

```dart
// ❌ 慢
for (var user in users) {
  await db.insert('users', user);
}

// ✅ 快
await db.transaction((txn) async {
  for (var user in users) {
    await txn.insert('users', user);
  }
});

// ✅ 更快
final batch = db.batch();
for (var user in users) {
  batch.insert('users', user);
}
await batch.commit(noResult: true);
```

### 查询优化

```dart
// ❌ 查询所有字段
await db.query('users');

// ✅ 只查询需要的字段
await db.query('users', columns: ['id', 'name']);

// ❌ 在代码中过滤
final users = await db.query('users');
final filtered = users.where((u) => u['age'] > 18);

// ✅ 在 SQL 中过滤
await db.query('users', where: 'age > ?', whereArgs: [18]);
```

---

## 最佳实践

1. **使用参数化查询** - 防止 SQL 注入
2. **事务包裹多个操作** - 保证数据一致性
3. **批量操作用 Batch** - 提高性能
4. **创建适当索引** - 加速查询
5. **版本管理** - 正确处理迁移
6. **单例模式** - 避免多次打开数据库
7. **记得关闭** - App 退出时关闭连接

## sqflite vs 其他方案

| 特性 | sqflite | Hive | drift |
|------|---------|------|-------|
| 查询能力 | 强（SQL） | 弱 | 强（类型安全） |
| 性能 | 中 | 高 | 中 |
| 学习成本 | 中（需会SQL） | 低 | 高 |
| 类型安全 | 无 | 有 | 有 |
| 适用场景 | 关系数据 | 缓存、配置 | 复杂应用 |

## 相关资源

- [sqflite 官方文档](https://pub.dev/packages/sqflite)
- [sqflite GitHub](https://github.com/tekartik/sqflite)
- [SQL 教程](https://www.w3schools.com/sql/)
- [drift](https://pub.dev/packages/drift) - 类型安全的 SQLite 封装
