# 第 4 章：Trait 与泛型编程

> Trait 是 Rust 类型系统的灵魂。如果说所有权系统保证了内存安全，那么 Trait 系统则定义了类型之间的"行为契约"——它既是 Dart 中 `abstract class` 和 `interface` 的统一替代品，又远比它们强大。结合泛型，Trait 让 Rust 实现了零成本抽象：你在编译期获得多态的灵活性，却不付出运行时的任何代价。本章将从定义、实现到高级用法，带你全面掌握 Trait 与泛型编程，并通过与 Dart/Flutter 的对比帮助你快速建立直觉。

---

## 4.1 Trait 定义与实现

### 什么是 Trait？

Trait 定义了一组类型可以实现的行为（方法签名）。你可以把它理解为：

```
Trait 与其他语言概念的对应关系：

┌────────────────────────────────────────────────────────┐
│              行为抽象的不同实现方式                       │
├──────────────┬─────────────────────────────────────────┤
│   Dart       │  abstract class / interface (隐式)      │
│   Java       │  interface                              │
│   Go         │  interface（鸭子类型，隐式实现）           │
│   Rust       │  trait（显式实现，编译期检查）             │
│   Haskell    │  type class                             │
├──────────────┼─────────────────────────────────────────┤
│   关键区别    │  Rust trait 可以为已有类型添加行为        │
│              │  (扩展方法)，Dart 需要 extension          │
└──────────────┴─────────────────────────────────────────┘
```

### 定义一个 Trait

```rust
// 文件: src/traits_basic.rs

// 定义一个 Trait：描述"可以被总结为摘要"的行为
trait Summary {
    fn summarize(&self) -> String;
}
```

对应的 Dart 写法：

```dart
// 文件: lib/traits_basic.dart

// Dart 使用 abstract class 定义接口
abstract class Summary {
  String summarize();
}
```

### 为类型实现 Trait

```rust
// 文件: src/traits_impl.rs

trait Summary {
    fn summarize(&self) -> String;
}

struct Article {
    title: String,
    author: String,
    content: String,
}

struct Tweet {
    username: String,
    text: String,
    reply: bool,
}

// 为 Article 实现 Summary
impl Summary for Article {
    fn summarize(&self) -> String {
        format!("《{}》by {} — {}", self.title, self.author, &self.content[..20])
    }
}

// 为 Tweet 实现 Summary
impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("@{}: {}", self.username, self.text)
    }
}

fn main() {
    let article = Article {
        title: String::from("Rust 入门"),
        author: String::from("张三"),
        content: String::from("Rust 是一门系统编程语言，注重安全性和性能..."),
    };

    let tweet = Tweet {
        username: String::from("rustlover"),
        text: String::from("我爱 Rust！"),
        reply: false,
    };

    println!("{}", article.summarize()); // 《Rust 入门》by 张三 — Rust 是一门系统编程语言，注重安
    println!("{}", tweet.summarize());   // @rustlover: 我爱 Rust！
}
```

对应的 Dart 写法：

```dart
// 文件: lib/traits_impl.dart

abstract class Summary {
  String summarize();
}

class Article implements Summary {
  final String title;
  final String author;
  final String content;

  Article({required this.title, required this.author, required this.content});

  @override
  String summarize() => '《$title》by $author — ${content.substring(0, 20)}';
}

class Tweet implements Summary {
  final String username;
  final String text;
  final bool reply;

  Tweet({required this.username, required this.text, required this.reply});

  @override
  String summarize() => '@$username: $text';
}
```

### 默认方法

Trait 可以提供默认实现，类型可以选择覆盖：

```rust
// 文件: src/trait_default.rs

trait Summary {
    fn summarize_author(&self) -> String;

    // 默认实现：调用了另一个方法
    fn summarize(&self) -> String {
        format!("(阅读更多来自 {} 的内容...)", self.summarize_author())
    }
}

struct Tweet {
    username: String,
    text: String,
}

// 只实现必须的方法，summarize 使用默认实现
impl Summary for Tweet {
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
    // summarize() 自动获得默认实现
}

fn main() {
    let tweet = Tweet {
        username: String::from("flutter_dev"),
        text: String::from("跨平台真棒"),
    };
    // 输出: (阅读更多来自 @flutter_dev 的内容...)
    println!("{}", tweet.summarize());
}
```

Dart 中的等价写法：

```dart
// Dart abstract class 也支持默认方法实现
abstract class Summary {
  String summarizeAuthor();

  // 默认方法（带实现的方法）
  String summarize() => '(阅读更多来自 ${summarizeAuthor()} 的内容...)';
}

class Tweet extends Summary {
  final String username;
  Tweet({required this.username});

  @override
  String summarizeAuthor() => '@$username';
  // summarize() 继承了默认实现
}
```

### Trait 与 Dart abstract class 的关键差异

```
关键差异对比：

┌─────────────────┬──────────────────────┬──────────────────────┐
│     特性         │   Rust Trait          │  Dart abstract class │
├─────────────────┼──────────────────────┼──────────────────────┤
│ 多重实现        │ ✅ 可实现任意多个      │ ✅ implements 多个   │
│ 默认方法        │ ✅ 支持               │ ✅ 支持              │
│ 字段 / 状态     │ ❌ 不能定义字段        │ ✅ 可定义字段        │
│ 为外部类型实现   │ ✅ impl Trait for T   │ ❌ 不行（用 ext）    │
│ 继承            │ ❌ 无继承概念          │ ✅ extends           │
│ 关联类型        │ ✅ type Item;         │ ❌ 不支持            │
│ 孤儿规则        │ ✅ 必须满足            │ ❌ 无此限制          │
│ 分发方式        │ 默认静态，可选动态      │ 始终动态分发          │
└─────────────────┴──────────────────────┴──────────────────────┘
```

### 孤儿规则 (Orphan Rule)

实现 trait 时，trait 或类型至少有一个在当前 crate 中定义。这防止了冲突：

```rust
// ✅ 可以：为自己的类型实现标准库 trait
impl std::fmt::Display for Article {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "《{}》", self.title)
    }
}

// ✅ 可以：为标准库类型实现自己的 trait
impl Summary for String {
    fn summarize(&self) -> String {
        format!("字符串: {}...", &self[..10])
    }
}

// ❌ 不可以：为标准库类型实现标准库 trait（两者都不在当前 crate）
// impl std::fmt::Display for Vec<i32> { ... }  // 编译错误！
```

---

## 4.2 Trait 作为参数与返回值

### impl Trait 语法（静态分发）

```rust
// 文件: src/trait_param.rs

// 参数接受任何实现了 Summary 的类型
fn notify(item: &impl Summary) {
    println!("突发新闻！{}", item.summarize());
}

// 等价的 Trait Bound 写法
fn notify_verbose<T: Summary>(item: &T) {
    println!("突发新闻！{}", item.summarize());
}
```

对应的 Dart 写法：

```dart
// 文件: lib/trait_param.dart

// Dart 直接使用抽象类型作为参数类型
void notify(Summary item) {
  print('突发新闻！${item.summarize()}');
}
```

### 多个 Trait Bound

```rust
// 文件: src/trait_bounds.rs

use std::fmt::{Display, Debug};

// 要求同时实现 Summary + Display
fn notify_detail(item: &(impl Summary + Display)) {
    println!("摘要: {}", item.summarize());
    println!("详情: {}", item);
}

// Trait Bound 写法
fn notify_detail_v2<T: Summary + Display>(item: &T) {
    println!("摘要: {}", item.summarize());
    println!("详情: {}", item);
}
```

Dart 中需要用泛型约束：

```dart
// Dart 无法直接约束多个接口，需要创建组合接口或使用 is 检查
abstract class SummaryAndDisplayable implements Summary {
  @override
  String toString(); // Object 已有，仅示意
}

// 或使用泛型约束（Dart 只支持单约束 extends）
void notifyDetail<T extends Summary>(T item) {
  print('摘要: ${item.summarize()}');
  print('详情: $item'); // 调用 toString()
}
```

### where 子句

当 Trait Bound 变得复杂时，用 `where` 子句提高可读性：

```rust
// 文件: src/where_clause.rs

// 不用 where（可读性差）
fn process<T: Summary + Clone + Display, U: Clone + Debug>(t: &T, u: &U) -> String {
    format!("{}: {:?}", t.summarize(), u)
}

// 用 where（可读性好）
fn process_v2<T, U>(t: &T, u: &U) -> String
where
    T: Summary + Clone + Display,
    U: Clone + Debug,
{
    format!("{}: {:?}", t.summarize(), u)
}
```

### 返回 impl Trait

```rust
// 文件: src/return_trait.rs

// 返回一个实现了 Summary 的类型（调用者不知道具体类型）
fn create_summarizable() -> impl Summary {
    Tweet {
        username: String::from("dev"),
        text: String::from("Rust 太棒了"),
    }
}

// 注意：只能返回一种具体类型！以下代码编译失败：
// fn create_either(switch: bool) -> impl Summary {
//     if switch {
//         Article { ... }   // 类型 A
//     } else {
//         Tweet { ... }     // 类型 B — 编译错误！
//     }
// }
// 解决方案：使用 trait 对象 Box<dyn Summary>（见 4.5 节）
```

函数参数和返回值中 trait 用法的完整图示：

```
impl Trait 使用场景总结：

┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   作为参数：fn foo(x: &impl Trait)                           │
│       ↓ 等价于                                               │
│   泛型约束：fn foo<T: Trait>(x: &T)                          │
│       ↓ 复杂时使用                                           │
│   where 子句：fn foo<T>(x: &T) where T: Trait                │
│                                                              │
│   作为返回值：fn bar() -> impl Trait                          │
│       ↓ 限制                                                 │
│   只能返回一种具体类型（编译器需要确定大小）                    │
│       ↓ 需要多种类型时                                        │
│   使用 trait 对象：fn bar() -> Box<dyn Trait>                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 4.3 常用标准库 Trait

Rust 标准库定义了大量 trait，理解它们是写好 Rust 代码的基础。以下是最常用的：

### Display 与 Debug

```rust
// 文件: src/display_debug.rs

use std::fmt;

struct Point {
    x: f64,
    y: f64,
}

// Display: 面向用户的格式化输出，用 {} 触发
impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

// Debug: 面向开发者的调试输出，用 {:?} 触发
impl fmt::Debug for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Point {{ x: {}, y: {} }}", self.x, self.y)
    }
}

fn main() {
    let p = Point { x: 3.0, y: 4.0 };
    println!("Display: {}", p);   // Display: (3.0, 4.0)
    println!("Debug: {:?}", p);   // Debug: Point { x: 3.0, y: 4.0 }
    println!("Pretty: {:#?}", p); // 美化的 Debug 输出
}
```

Dart 对比：

```dart
// Dart 只有 toString()，没有 Display/Debug 的区分
class Point {
  final double x, y;
  Point(this.x, this.y);

  @override
  String toString() => '($x, $y)'; // 唯一的字符串表示
}
```

### Clone 与 Copy

```rust
// 文件: src/clone_copy.rs

// Clone: 显式深拷贝
#[derive(Clone, Debug)]
struct Config {
    name: String,       // String 实现了 Clone 但没有 Copy
    max_retries: u32,
}

// Copy: 隐式按位拷贝（仅适用于栈上的简单类型）
#[derive(Copy, Clone, Debug)]
struct Coordinate {
    x: f64,   // f64 是 Copy 的
    y: f64,
}

fn main() {
    // Clone: 需要显式调用 .clone()
    let config1 = Config {
        name: String::from("prod"),
        max_retries: 3,
    };
    let config2 = config1.clone(); // 深拷贝
    println!("{:?}", config1);     // config1 仍然有效
    println!("{:?}", config2);

    // Copy: 赋值时自动拷贝，不发生 Move
    let coord1 = Coordinate { x: 1.0, y: 2.0 };
    let coord2 = coord1;          // 自动 Copy，不是 Move
    println!("{:?}", coord1);     // coord1 仍然有效！
    println!("{:?}", coord2);
}
```

```
Clone 与 Copy 的关系：

┌──────────────────────────────────────────────────────┐
│                    Clone (trait)                       │
│  ┌─────────────────────────────────────────────────┐ │
│  │  显式深拷贝：let b = a.clone();                  │ │
│  │  适用于：String, Vec, HashMap, 任何堆数据         │ │
│  │                                                   │ │
│  │  ┌───────────────────────────────────────────┐   │ │
│  │  │          Copy (marker trait)               │   │ │
│  │  │  隐式按位拷贝：let b = a; (a 仍然有效)     │   │ │
│  │  │  适用于：i32, f64, bool, char, 元组等      │   │ │
│  │  │  要求：所有字段都是 Copy 的                 │   │ │
│  │  │  注意：Copy 是 Clone 的子 trait             │   │ │
│  │  └───────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘

规则：
• 实现 Copy 的类型必须也实现 Clone
• 包含 String / Vec / Box 的类型不能实现 Copy
• Copy 类型赋值时不发生 Move
```

Dart 对比：

```dart
// Dart 中一切对象都是引用，没有 Copy 的概念
// 深拷贝需要手动实现
class Config {
  final String name;
  final int maxRetries;
  Config({required this.name, required this.maxRetries});

  Config clone() => Config(name: name, maxRetries: maxRetries);
}
```

### PartialEq, Eq, PartialOrd, Ord

```rust
// 文件: src/comparison_traits.rs

// PartialEq: 部分等价关系（可以判断 == 和 !=）
// Eq:        完全等价关系（PartialEq + 自反性：a == a 始终为 true）
// PartialOrd: 部分排序（可以判断 <, >, <=, >=）
// Ord:        全序（任意两个值都可以比较）

#[derive(Debug, PartialEq)]
struct Score {
    value: f64,  // f64 只实现了 PartialEq，因为 NaN != NaN
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct Level {
    value: i32,  // i32 实现了完整的 Eq + Ord
}

fn main() {
    let s1 = Score { value: 95.0 };
    let s2 = Score { value: 95.0 };
    println!("分数相等？{}", s1 == s2); // true

    let mut levels = vec![
        Level { value: 3 },
        Level { value: 1 },
        Level { value: 2 },
    ];
    levels.sort(); // Ord trait 使得 sort() 可用
    println!("{:?}", levels); // [Level { value: 1 }, Level { value: 2 }, Level { value: 3 }]
}

// 自定义 PartialEq 实现
#[derive(Debug)]
struct User {
    id: u64,
    name: String,
    email: String,
}

impl PartialEq for User {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id // 只按 id 比较，忽略 name 和 email
    }
}

impl Eq for User {} // 标记 trait，无额外方法
```

```
比较 trait 的层级关系：

        Eq (完全等价)
        │ 继承自
        ▼
    PartialEq (部分等价)        Ord (全序)
        │                       │ 继承自
        │                       ▼
        │                  PartialOrd (部分排序)
        │                       │
        └───────────────────────┘
              PartialOrd 要求 PartialEq

为什么有 "Partial"？
• f64 中的 NaN：NaN != NaN（违反自反性），所以 f64 只有 PartialEq
• f64 中的 NaN：NaN 无法与其他值比较大小，所以 f64 只有 PartialOrd
• i32 没有这些问题，所以 i32 同时实现了 Eq 和 Ord
```

### From 与 Into

```rust
// 文件: src/from_into.rs

// From<T>: 从类型 T 转换而来
// Into<U>: 转换为类型 U（自动从 From 推导）

struct Celsius(f64);
struct Fahrenheit(f64);

impl From<Celsius> for Fahrenheit {
    fn from(c: Celsius) -> Self {
        Fahrenheit(c.0 * 9.0 / 5.0 + 32.0)
    }
}

fn main() {
    let boiling = Celsius(100.0);

    // 使用 From
    let f1 = Fahrenheit::from(Celsius(100.0));

    // 使用 Into（自动从 From 推导，无需手动实现）
    let f2: Fahrenheit = boiling.into();

    // 常见用法：String::from 和 .into()
    let s1 = String::from("hello");       // From<&str> for String
    let s2: String = "hello".into();      // Into<String> for &str

    // 函数参数中的 Into
    fn greet(name: impl Into<String>) {
        let name = name.into();
        println!("你好，{}！", name);
    }
    greet("世界");                         // &str 自动转换为 String
    greet(String::from("Rust"));          // String 直接使用
}
```

Dart 对比：

```dart
// Dart 中没有 From/Into trait，通常用构造函数或工厂方法
class Fahrenheit {
  final double value;
  Fahrenheit(this.value);

  // 类似 From 的工厂构造函数
  factory Fahrenheit.fromCelsius(double celsius) {
    return Fahrenheit(celsius * 9 / 5 + 32);
  }
}
```

### Default

```rust
// 文件: src/default_trait.rs

#[derive(Debug)]
struct AppConfig {
    host: String,
    port: u16,
    debug: bool,
    max_connections: usize,
}

impl Default for AppConfig {
    fn default() -> Self {
        AppConfig {
            host: String::from("localhost"),
            port: 8080,
            debug: false,
            max_connections: 100,
        }
    }
}

fn main() {
    // 使用全部默认值
    let config1 = AppConfig::default();
    println!("{:?}", config1);

    // 部分覆盖（结构体更新语法 + Default）
    let config2 = AppConfig {
        port: 3000,
        debug: true,
        ..AppConfig::default() // 其余字段使用默认值
    };
    println!("{:?}", config2);
}
```

Dart 对比：

```dart
// Dart 使用默认参数值实现类似功能
class AppConfig {
  final String host;
  final int port;
  final bool debug;
  final int maxConnections;

  AppConfig({
    this.host = 'localhost',
    this.port = 8080,
    this.debug = false,
    this.maxConnections = 100,
  });
}
```

---

## 4.4 派生宏

### #[derive(...)] 自动实现 Trait

Rust 编译器可以自动为你的类型生成常用 trait 的实现代码：

```rust
// 文件: src/derive_example.rs

// 一行代码自动实现 5 个 trait！
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Widget {
    id: u32,
    name: String,
    width: u32,
    height: u32,
}

fn main() {
    let w1 = Widget {
        id: 1,
        name: String::from("Button"),
        width: 120,
        height: 40,
    };

    // Debug: {:?} 格式化
    println!("{:?}", w1);

    // Clone: 深拷贝
    let w2 = w1.clone();

    // PartialEq: == 比较
    println!("相等？{}", w1 == w2); // true

    // Hash: 可以作为 HashMap 的 key
    use std::collections::HashMap;
    let mut map = HashMap::new();
    map.insert(w1, "第一个组件");
}
```

### 常见可派生 Trait 一览

```
常见 #[derive] 一览表：

┌──────────────┬────────────────────────────┬───────────────────────────┐
│   Trait       │   作用                     │   要求                     │
├──────────────┼────────────────────────────┼───────────────────────────┤
│ Debug        │ {:?} 调试输出               │ 所有字段都实现 Debug       │
│ Clone        │ .clone() 深拷贝             │ 所有字段都实现 Clone       │
│ Copy         │ 赋值时自动拷贝              │ 所有字段都实现 Copy        │
│ PartialEq    │ == 和 != 比较              │ 所有字段都实现 PartialEq   │
│ Eq           │ 完全等价（标记 trait）       │ 需要 PartialEq            │
│ PartialOrd   │ <, >, <=, >= 比较          │ 需要 PartialEq            │
│ Ord          │ 全序比较，sort() 可用       │ 需要 Eq + PartialOrd      │
│ Hash         │ 可用作 HashMap key          │ 所有字段都实现 Hash        │
│ Default      │ ::default() 默认值          │ 所有字段都实现 Default     │
└──────────────┴────────────────────────────┴───────────────────────────┘
```

### 什么时候用 derive，什么时候手动实现？

```rust
// 文件: src/derive_vs_manual.rs

// 场景 1：用 derive — 标准的逐字段比较
#[derive(PartialEq)]
struct Color {
    r: u8,
    g: u8,
    b: u8,
}

// 场景 2：手动实现 — 自定义比较逻辑
struct Email(String);

impl PartialEq for Email {
    fn eq(&self, other: &Self) -> bool {
        // 邮箱比较忽略大小写
        self.0.to_lowercase() == other.0.to_lowercase()
    }
}

fn main() {
    let e1 = Email(String::from("User@Example.COM"));
    let e2 = Email(String::from("user@example.com"));
    println!("邮箱相等？{}", e1 == e2); // true
}
```

---

## 4.5 Trait 对象与动态分发

### 静态分发 vs 动态分发

```
两种多态分发方式：

┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  静态分发（impl Trait / 泛型）           动态分发（dyn Trait）     │
│  ┌──────────────────────────┐          ┌──────────────────────┐  │
│  │ fn notify(item: &impl S) │          │ fn notify(item: &dyn S)│ │
│  │                          │          │                      │  │
│  │ 编译时确定具体类型        │          │ 运行时查找方法        │  │
│  │ 编译器生成每个类型的      │          │ 通过 vtable 间接调用  │  │
│  │ 专用代码（单态化）        │          │ 只生成一份代码        │  │
│  │                          │          │                      │  │
│  │ ✅ 零运行时开销           │          │ ✅ 二进制体积更小     │  │
│  │ ✅ 可内联优化             │          │ ✅ 可存不同类型       │  │
│  │ ❌ 二进制体积更大         │          │ ❌ 有间接调用开销     │  │
│  │ ❌ 只能返回一种类型       │          │ ❌ 不能内联优化       │  │
│  └──────────────────────────┘          └──────────────────────┘  │
│                                                                  │
│  Dart 对比：                                                     │
│  Dart 始终使用动态分发（虚方法表），没有静态分发的选项              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### dyn Trait 与 Box\<dyn Trait\>

```rust
// 文件: src/dyn_trait.rs

trait Drawable {
    fn draw(&self);
    fn area(&self) -> f64;
}

struct Circle {
    radius: f64,
}

struct Rectangle {
    width: f64,
    height: f64,
}

impl Drawable for Circle {
    fn draw(&self) {
        println!("绘制圆形，半径 = {}", self.radius);
    }
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

impl Drawable for Rectangle {
    fn draw(&self) {
        println!("绘制矩形，{}x{}", self.width, self.height);
    }
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

fn main() {
    // trait 对象：在同一个 Vec 中存储不同类型
    let shapes: Vec<Box<dyn Drawable>> = vec![
        Box::new(Circle { radius: 5.0 }),
        Box::new(Rectangle { width: 10.0, height: 3.0 }),
        Box::new(Circle { radius: 2.5 }),
    ];

    for shape in &shapes {
        shape.draw();
        println!("面积: {:.2}", shape.area());
    }

    // 返回不同类型的 trait 对象
    fn create_shape(kind: &str) -> Box<dyn Drawable> {
        match kind {
            "circle" => Box::new(Circle { radius: 1.0 }),
            _ => Box::new(Rectangle { width: 2.0, height: 3.0 }),
        }
    }

    let shape = create_shape("circle");
    shape.draw();
}
```

对应的 Dart 写法（天然支持）：

```dart
// 文件: lib/dyn_trait.dart

abstract class Drawable {
  void draw();
  double area();
}

class Circle implements Drawable {
  final double radius;
  Circle(this.radius);

  @override
  void draw() => print('绘制圆形，半径 = $radius');

  @override
  double area() => 3.14159 * radius * radius;
}

class Rectangle implements Drawable {
  final double width, height;
  Rectangle(this.width, this.height);

  @override
  void draw() => print('绘制矩形，${width}x$height');

  @override
  double area() => width * height;
}

void main() {
  // Dart 天然支持多态列表，不需要 Box 包装
  List<Drawable> shapes = [
    Circle(5.0),
    Rectangle(10.0, 3.0),
    Circle(2.5),
  ];

  for (var shape in shapes) {
    shape.draw();
    print('面积: ${shape.area().toStringAsFixed(2)}');
  }
}
```

### vtable 工作原理

```
vtable（虚方法表）的工作原理：

当你使用 &dyn Drawable 时，Rust 会创建一个"胖指针"：

    &dyn Drawable  (16 字节)
    ┌─────────────────────────┐
    │  data_ptr  │  vtable_ptr │     ← 两个指针组成
    └──────┬─────┴──────┬──────┘
           │            │
           ▼            ▼
    ┌──────────┐  ┌──────────────────┐
    │ Circle   │  │ vtable for       │
    │ {        │  │ Circle: Drawable │
    │  radius: │  ├──────────────────┤
    │  5.0     │  │ draw:  0x1234    │ → Circle::draw()
    │ }        │  │ area:  0x5678    │ → Circle::area()
    └──────────┘  │ drop:  0x9abc    │ → Circle::drop()
                  │ size:  8         │
                  │ align: 8         │
                  └──────────────────┘

对比 Dart：
    Dart 对象也有类似的虚方法表机制
    但 Dart 的每个对象都自带类型信息
    Rust 只在使用 dyn Trait 时才产生间接调用
```

### 对象安全 (Object Safety)

不是所有 trait 都能用作 trait 对象。trait 必须是"对象安全"的：

```rust
// 文件: src/object_safety.rs

// ✅ 对象安全的 trait
trait Drawable {
    fn draw(&self);
}

// ❌ 不是对象安全的 trait — 有泛型方法
trait Converter {
    fn convert<T>(&self) -> T; // 泛型方法不允许
}

// ❌ 不是对象安全的 trait — 返回 Self
trait Clonable {
    fn clone_self(&self) -> Self; // 返回 Self 不允许
}

// ❌ 不是对象安全的 trait — 要求 Sized
trait Processable: Sized {
    fn process(&self);
}
```

```
对象安全规则：

Trait 要用作 dyn Trait，必须满足：
┌───────────────────────────────────────────────────┐
│ 1. 方法不能有泛型类型参数                          │
│ 2. 方法不能返回 Self                               │
│ 3. Trait 本身不能要求 Self: Sized                  │
│ 4. 方法的第一个参数必须是 &self / &mut self / self │
└───────────────────────────────────────────────────┘
```

---

## 4.6 泛型

### 泛型函数

```rust
// 文件: src/generics_fn.rs

// 泛型函数：找到切片中的最大值
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut max = &list[0];
    for item in &list[1..] {
        if item > max {
            max = item;
        }
    }
    max
}

fn main() {
    let numbers = vec![34, 50, 25, 100, 65];
    println!("最大数字: {}", largest(&numbers));  // 100

    let chars = vec!['y', 'm', 'a', 'q'];
    println!("最大字符: {}", largest(&chars));    // y
}
```

Dart 对比：

```dart
// Dart 泛型函数 — 注意：Dart 泛型在运行时被保留（reified generics）
T largest<T extends Comparable<T>>(List<T> list) {
  T max = list[0];
  for (var item in list.sublist(1)) {
    if (item.compareTo(max) > 0) {
      max = item;
    }
  }
  return max;
}

void main() {
  print(largest([34, 50, 25, 100, 65])); // 100
  print(largest(['y', 'm', 'a', 'q']));  // y
}
```

### 泛型结构体

```rust
// 文件: src/generics_struct.rs

// 类似 Flutter 中经常使用的 Result/AsyncSnapshot 模式
#[derive(Debug)]
struct ApiResponse<T> {
    data: Option<T>,
    error: Option<String>,
    status_code: u16,
}

impl<T> ApiResponse<T> {
    fn success(data: T) -> Self {
        ApiResponse {
            data: Some(data),
            error: None,
            status_code: 200,
        }
    }

    fn failure(error: String, code: u16) -> Self {
        ApiResponse {
            data: None,
            error: Some(error),
            status_code: code,
        }
    }

    fn is_ok(&self) -> bool {
        self.error.is_none()
    }
}

// 为特定类型参数添加额外方法
impl ApiResponse<String> {
    fn body_length(&self) -> usize {
        self.data.as_ref().map_or(0, |s| s.len())
    }
}

fn main() {
    let resp: ApiResponse<Vec<u32>> = ApiResponse::success(vec![1, 2, 3]);
    println!("{:?}", resp);  // data: Some([1, 2, 3])

    let err: ApiResponse<String> = ApiResponse::failure("Not Found".into(), 404);
    println!("成功？{}", err.is_ok()); // false
}
```

Dart 对比：

```dart
// 文件: lib/generics_struct.dart

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse._({this.data, this.error, required this.statusCode});

  factory ApiResponse.success(T data) =>
      ApiResponse._(data: data, statusCode: 200);

  factory ApiResponse.failure(String error, int code) =>
      ApiResponse._(error: error, statusCode: code);

  bool get isOk => error == null;
}
```

### 泛型枚举

Rust 标准库中最经典的两个泛型枚举：

```rust
// 文件: src/generics_enum.rs

// 标准库 Option<T> 的定义
enum Option<T> {
    Some(T),
    None,
}

// 标准库 Result<T, E> 的定义
enum Result<T, E> {
    Ok(T),
    Err(E),
}

// 自定义泛型枚举：二叉树
#[derive(Debug)]
enum Tree<T> {
    Leaf(T),
    Node {
        value: T,
        left: Box<Tree<T>>,
        right: Box<Tree<T>>,
    },
}

impl<T: std::fmt::Display> Tree<T> {
    fn print_inorder(&self) {
        match self {
            Tree::Leaf(v) => print!("{} ", v),
            Tree::Node { value, left, right } => {
                left.print_inorder();
                print!("{} ", value);
                right.print_inorder();
            }
        }
    }
}

fn main() {
    let tree = Tree::Node {
        value: 5,
        left: Box::new(Tree::Node {
            value: 3,
            left: Box::new(Tree::Leaf(1)),
            right: Box::new(Tree::Leaf(4)),
        }),
        right: Box::new(Tree::Leaf(8)),
    };

    tree.print_inorder(); // 1 3 4 5 8
    println!();
}
```

### 单态化 (Monomorphization) 与零成本抽象

```
Rust 泛型的编译过程 — 单态化：

源代码：
┌────────────────────────────┐
│ fn add<T: Add>(a: T, b: T) │
│   -> T { a + b }           │
│                            │
│ add(1_i32, 2_i32);         │
│ add(1.0_f64, 2.0_f64);    │
└────────────────────────────┘
           │
           │ 编译器单态化
           ▼
生成的代码：
┌────────────────────────────┐
│ // 编译器生成两个专用函数    │
│ fn add_i32(a: i32, b: i32) │
│   -> i32 { a + b }         │
│                            │
│ fn add_f64(a: f64, b: f64) │
│   -> f64 { a + b }         │
│                            │
│ add_i32(1, 2);             │
│ add_f64(1.0, 2.0);        │
└────────────────────────────┘

结果：
• 运行时没有泛型的任何开销
• 与手写每个类型的专用代码性能完全一致
• 这就是"零成本抽象"的含义

对比 Dart：
• Dart 泛型在运行时被保留（reified generics）
• 不会为每个类型生成专用代码
• 有运行时类型检查的开销
• 但换来了更小的代码体积

对比 Java：
• Java 泛型使用类型擦除（type erasure）
• 运行时不知道泛型的具体类型
• Rust 两者兼得：编译时有类型信息，运行时有专用代码
```

### 多个泛型类型参数

```rust
// 文件: src/multi_generics.rs

use std::fmt::Display;

// 多个泛型参数
struct Pair<A, B> {
    first: A,
    second: B,
}

impl<A: Display, B: Display> Pair<A, B> {
    fn show(&self) {
        println!("({}, {})", self.first, self.second);
    }
}

// 实际应用：类似 Flutter 中的 MapEntry
impl<A, B> Pair<A, B> {
    fn new(first: A, second: B) -> Self {
        Pair { first, second }
    }

    fn into_tuple(self) -> (A, B) {
        (self.first, self.second)
    }
}

fn main() {
    let pair = Pair::new("名字", 42);
    pair.show(); // (名字, 42)

    let pair2 = Pair::new(3.14, vec![1, 2, 3]);
    let (pi, nums) = pair2.into_tuple();
    println!("pi = {}, nums = {:?}", pi, nums);
}
```

---

## 4.7 Sized 与 ?Sized

### Sized Trait

`Sized` 是一个特殊的标记 trait，表示类型在编译时已知大小。几乎所有类型默认都是 `Sized` 的：

```rust
// 文件: src/sized.rs

// 以下泛型函数有一个隐含的 Sized 约束：
fn process<T>(value: T) {
    // 实际上等价于：
    // fn process<T: Sized>(value: T)
}

// 编译时已知大小的类型（Sized）：
// i32          → 4 字节
// f64          → 8 字节
// bool         → 1 字节
// (i32, f64)   → 12 字节（可能有对齐填充）
// [i32; 5]     → 20 字节
// String       → 24 字节（ptr + len + capacity）

// 编译时大小未知的类型（!Sized，又叫 DST — Dynamically Sized Types）：
// str          → 字符串切片的内容，长度不定
// [i32]        → 整数切片的内容，长度不定
// dyn Trait    → trait 对象的具体类型不定
```

### 动态大小类型 (DST)

```
Sized 与 DST（动态大小类型）：

┌──────────────────────────────────────────────────────────────┐
│                     Sized 类型                               │
│  编译时已知大小，可以直接放在栈上                              │
│                                                              │
│    i32 (4B)   String (24B)   Vec<u8> (24B)   [i32; 3] (12B) │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                    !Sized 类型 (DST)                         │
│  编译时大小未知，必须通过引用或指针访问                        │
│                                                              │
│    str          [T]          dyn Trait                        │
│    ↓            ↓            ↓                                │
│    &str (16B)   &[T] (16B)   &dyn Trait (16B)                │
│    胖指针       胖指针        胖指针                           │
│    ptr+len      ptr+len      ptr+vtable                      │
└──────────────────────────────────────────────────────────────┘

胖指针的结构：
    &str         = (指向数据的指针, 长度)        → 16 字节
    &[i32]       = (指向数据的指针, 元素个数)     → 16 字节
    &dyn Trait   = (指向数据的指针, 指向 vtable)  → 16 字节
```

### ?Sized 约束

`?Sized` 表示"可能不是 Sized 的"，放宽了默认的 Sized 要求：

```rust
// 文件: src/unsized.rs

use std::fmt::Display;

// 默认：T 必须是 Sized
fn print_sized<T: Display>(value: &T) {
    println!("{}", value);
}

// ?Sized：T 可以是 Sized 也可以是 !Sized（如 str, [i32], dyn Display）
fn print_any<T: Display + ?Sized>(value: &T) {
    println!("{}", value);
}

fn main() {
    let s = String::from("hello");

    print_sized(&s);        // ✅ String 是 Sized
    // print_sized("hello"); // ❌ 编译错误：str 不是 Sized

    print_any(&s);           // ✅ String 是 Sized
    print_any("hello");      // ✅ str 是 !Sized，但 ?Sized 允许

    // 实际应用：标准库中大量使用 ?Sized
    // fn borrow(&self) -> &T where T: ?Sized;
}

// 常见使用场景：接受 &str 或 &String
fn greet(name: &(impl AsRef<str> + ?Sized)) {
    println!("你好，{}！", name.as_ref());
}

// 更常见的写法
fn greet_v2(name: &str) {
    println!("你好，{}！", name);
}
```

### 什么时候需要 ?Sized？

```rust
// 文件: src/when_unsized.rs

// 场景 1：编写通用的包装类型
struct Wrapper<T: ?Sized> {
    // T 可以是 DST，所以必须用引用或 Box
    inner: Box<T>,
}

impl<T: ?Sized + Display> Wrapper<T> {
    fn show(&self) {
        println!("Wrapped: {}", self.inner);
    }
}

fn main() {
    // 包装一个 Sized 类型
    let w1 = Wrapper { inner: Box::new(42) };
    w1.show(); // Wrapped: 42

    // 包装一个 DST（dyn Display）
    let w2: Wrapper<dyn Display> = Wrapper { inner: Box::new("hello") };
    w2.show(); // Wrapped: hello
}
```

---

## 4.8 练习题

### 练习 1：定义和实现 Trait

定义一个 `Describable` trait，包含方法 `describe(&self) -> String`。为 `Book` 和 `Movie` 结构体实现它。

```rust
// 练习代码
struct Book {
    title: String,
    author: String,
    pages: u32,
}

struct Movie {
    title: String,
    director: String,
    duration_min: u32,
}

// 在此实现 Describable trait
```

<details>
<summary>查看答案</summary>

```rust
trait Describable {
    fn describe(&self) -> String;
}

struct Book {
    title: String,
    author: String,
    pages: u32,
}

struct Movie {
    title: String,
    director: String,
    duration_min: u32,
}

impl Describable for Book {
    fn describe(&self) -> String {
        format!(
            "书籍《{}》，作者：{}，共 {} 页",
            self.title, self.author, self.pages
        )
    }
}

impl Describable for Movie {
    fn describe(&self) -> String {
        format!(
            "电影《{}》，导演：{}，时长 {} 分钟",
            self.title, self.director, self.duration_min
        )
    }
}

fn main() {
    let book = Book {
        title: String::from("Rust 编程之道"),
        author: String::from("张三"),
        pages: 500,
    };
    let movie = Movie {
        title: String::from("黑客帝国"),
        director: String::from("沃卓斯基"),
        duration_min: 136,
    };
    println!("{}", book.describe());
    println!("{}", movie.describe());
}
```

</details>

### 练习 2：默认方法与覆盖

定义一个 `Greetable` trait，包含 `name(&self) -> &str` 和带默认实现的 `greet(&self) -> String`。为两个结构体实现它，其中一个使用默认 `greet`，另一个覆盖它。

```rust
// 练习代码
trait Greetable {
    fn name(&self) -> &str;
    // 添加带默认实现的 greet 方法
}

struct Chinese { name: String }
struct American { name: String }

// 分别实现 Greetable
```

<details>
<summary>查看答案</summary>

```rust
trait Greetable {
    fn name(&self) -> &str;

    fn greet(&self) -> String {
        format!("你好，我是 {}", self.name())
    }
}

struct Chinese {
    name: String,
}

struct American {
    name: String,
}

impl Greetable for Chinese {
    fn name(&self) -> &str {
        &self.name
    }
    // 使用默认的 greet 实现
}

impl Greetable for American {
    fn name(&self) -> &str {
        &self.name
    }

    // 覆盖默认实现
    fn greet(&self) -> String {
        format!("Hello, I'm {}", self.name())
    }
}

fn main() {
    let c = Chinese { name: String::from("李华") };
    let a = American { name: String::from("John") };
    println!("{}", c.greet()); // 你好，我是 李华
    println!("{}", a.greet()); // Hello, I'm John
}
```

</details>

### 练习 3：Trait Bound 与泛型函数

编写一个泛型函数 `print_all`，接受一个实现了 `Display` 和 `Debug` 的值的切片，分别用两种格式打印每个元素。

```rust
use std::fmt::{Display, Debug};

// 实现 print_all 函数
```

<details>
<summary>查看答案</summary>

```rust
use std::fmt::{Display, Debug};

fn print_all<T>(items: &[T])
where
    T: Display + Debug,
{
    for item in items {
        println!("Display: {}  |  Debug: {:?}", item, item);
    }
}

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];
    print_all(&numbers);
    // Display: 1  |  Debug: 1
    // Display: 2  |  Debug: 2
    // ...

    let words = vec!["hello", "world"];
    print_all(&words);
    // Display: hello  |  Debug: "hello"
    // Display: world  |  Debug: "world"
}
```

</details>

### 练习 4：实现 From trait

为 `Celsius` 和 `Fahrenheit` 类型实现互相转换。公式：`F = C * 9/5 + 32`。

```rust
struct Celsius(f64);
struct Fahrenheit(f64);

// 实现 From<Celsius> for Fahrenheit
// 实现 From<Fahrenheit> for Celsius
```

<details>
<summary>查看答案</summary>

```rust
#[derive(Debug)]
struct Celsius(f64);

#[derive(Debug)]
struct Fahrenheit(f64);

impl From<Celsius> for Fahrenheit {
    fn from(c: Celsius) -> Self {
        Fahrenheit(c.0 * 9.0 / 5.0 + 32.0)
    }
}

impl From<Fahrenheit> for Celsius {
    fn from(f: Fahrenheit) -> Self {
        Celsius((f.0 - 32.0) * 5.0 / 9.0)
    }
}

fn main() {
    let boiling_c = Celsius(100.0);
    let boiling_f: Fahrenheit = boiling_c.into();
    println!("100°C = {:?}", boiling_f); // Fahrenheit(212.0)

    let body_f = Fahrenheit(98.6);
    let body_c = Celsius::from(body_f);
    println!("98.6°F = {:?}", body_c);  // Celsius(37.0)
}
```

</details>

### 练习 5：derive 宏

为以下 `Card` 结构体添加合适的 derive 宏，使其可以打印调试信息、比较相等性、克隆、以及用作 HashMap 的 key。

```rust
// 添加合适的 #[derive(...)]
struct Card {
    suit: String,
    rank: u8,
}
```

<details>
<summary>查看答案</summary>

```rust
use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Card {
    suit: String,
    rank: u8,
}

fn main() {
    let card1 = Card {
        suit: String::from("spades"),
        rank: 14,
    };

    // Debug
    println!("{:?}", card1);

    // Clone
    let card2 = card1.clone();

    // PartialEq
    println!("相等？{}", card1 == card2);

    // Hash — 用作 HashMap key
    let mut scores: HashMap<Card, u32> = HashMap::new();
    scores.insert(card1, 100);
    println!("{:?}", scores);
}
```

</details>

### 练习 6：Trait 对象

创建一个函数 `make_sounds`，接受一个 `Vec<Box<dyn Animal>>` 并调用每个动物的 `speak` 方法。定义至少 3 种动物。

```rust
trait Animal {
    fn name(&self) -> &str;
    fn speak(&self) -> String;
}

// 定义 Dog, Cat, Duck 并实现 Animal
// 编写 make_sounds 函数
```

<details>
<summary>查看答案</summary>

```rust
trait Animal {
    fn name(&self) -> &str;
    fn speak(&self) -> String;
}

struct Dog { name: String }
struct Cat { name: String }
struct Duck { name: String }

impl Animal for Dog {
    fn name(&self) -> &str { &self.name }
    fn speak(&self) -> String { format!("{} 说：汪汪汪！", self.name) }
}

impl Animal for Cat {
    fn name(&self) -> &str { &self.name }
    fn speak(&self) -> String { format!("{} 说：喵~", self.name) }
}

impl Animal for Duck {
    fn name(&self) -> &str { &self.name }
    fn speak(&self) -> String { format!("{} 说：嘎嘎嘎！", self.name) }
}

fn make_sounds(animals: &[Box<dyn Animal>]) {
    for animal in animals {
        println!("{}", animal.speak());
    }
}

fn main() {
    let animals: Vec<Box<dyn Animal>> = vec![
        Box::new(Dog { name: String::from("旺财") }),
        Box::new(Cat { name: String::from("咪咪") }),
        Box::new(Duck { name: String::from("唐老鸭") }),
    ];

    make_sounds(&animals);
    // 旺财 说：汪汪汪！
    // 咪咪 说：喵~
    // 唐老鸭 说：嘎嘎嘎！
}
```

</details>

### 练习 7：泛型结构体

实现一个泛型的 `Stack<T>`，支持 `push`、`pop`、`peek` 和 `is_empty` 操作。

```rust
struct Stack<T> {
    elements: Vec<T>,
}

// 实现 Stack 的方法
```

<details>
<summary>查看答案</summary>

```rust
#[derive(Debug)]
struct Stack<T> {
    elements: Vec<T>,
}

impl<T> Stack<T> {
    fn new() -> Self {
        Stack { elements: Vec::new() }
    }

    fn push(&mut self, item: T) {
        self.elements.push(item);
    }

    fn pop(&mut self) -> Option<T> {
        self.elements.pop()
    }

    fn peek(&self) -> Option<&T> {
        self.elements.last()
    }

    fn is_empty(&self) -> bool {
        self.elements.is_empty()
    }

    fn size(&self) -> usize {
        self.elements.len()
    }
}

fn main() {
    let mut stack: Stack<i32> = Stack::new();
    assert!(stack.is_empty());

    stack.push(1);
    stack.push(2);
    stack.push(3);

    println!("栈顶: {:?}", stack.peek());   // Some(3)
    println!("大小: {}", stack.size());      // 3

    println!("弹出: {:?}", stack.pop());     // Some(3)
    println!("弹出: {:?}", stack.pop());     // Some(2)
    println!("大小: {}", stack.size());      // 1

    // 也可以用于其他类型
    let mut str_stack: Stack<String> = Stack::new();
    str_stack.push(String::from("hello"));
    str_stack.push(String::from("world"));
    println!("{:?}", str_stack);
}
```

</details>

### 练习 8：关联类型 vs 泛型

实现一个 `Container` trait，使用关联类型 `Item` 来定义容器中存储的元素类型。为 `NumberList` 和 `NameList` 实现它。

```rust
trait Container {
    type Item;

    fn add(&mut self, item: Self::Item);
    fn get(&self, index: usize) -> Option<&Self::Item>;
    fn size(&self) -> usize;
}

// 实现 NumberList 和 NameList
```

<details>
<summary>查看答案</summary>

```rust
trait Container {
    type Item;

    fn add(&mut self, item: Self::Item);
    fn get(&self, index: usize) -> Option<&Self::Item>;
    fn size(&self) -> usize;
}

struct NumberList {
    data: Vec<i32>,
}

struct NameList {
    data: Vec<String>,
}

impl Container for NumberList {
    type Item = i32;

    fn add(&mut self, item: i32) {
        self.data.push(item);
    }

    fn get(&self, index: usize) -> Option<&i32> {
        self.data.get(index)
    }

    fn size(&self) -> usize {
        self.data.len()
    }
}

impl Container for NameList {
    type Item = String;

    fn add(&mut self, item: String) {
        self.data.push(item);
    }

    fn get(&self, index: usize) -> Option<&String> {
        self.data.get(index)
    }

    fn size(&self) -> usize {
        self.data.len()
    }
}

fn main() {
    let mut nums = NumberList { data: vec![] };
    nums.add(10);
    nums.add(20);
    println!("第一个数字: {:?}", nums.get(0)); // Some(10)

    let mut names = NameList { data: vec![] };
    names.add(String::from("Alice"));
    names.add(String::from("Bob"));
    println!("第一个名字: {:?}", names.get(0)); // Some("Alice")
    println!("名字数量: {}", names.size());     // 2
}
```

</details>

### 练习 9：Trait 继承

定义 trait 继承链：`Printable` -> `Loggable` -> `Serializable`。`Loggable` 要求实现 `Printable`，`Serializable` 要求实现 `Loggable`。

```rust
// 定义三个 trait 并建立继承关系
// 为一个 Event 结构体实现所有三个 trait
```

<details>
<summary>查看答案</summary>

```rust
trait Printable {
    fn to_string(&self) -> String;
}

trait Loggable: Printable {
    fn log_level(&self) -> &str;

    fn log(&self) {
        println!("[{}] {}", self.log_level(), self.to_string());
    }
}

trait Serializable: Loggable {
    fn serialize(&self) -> String;
}

#[derive(Debug)]
struct Event {
    name: String,
    timestamp: u64,
    level: String,
}

impl Printable for Event {
    fn to_string(&self) -> String {
        format!("Event({} at {})", self.name, self.timestamp)
    }
}

impl Loggable for Event {
    fn log_level(&self) -> &str {
        &self.level
    }
}

impl Serializable for Event {
    fn serialize(&self) -> String {
        format!(
            r#"{{"name":"{}","timestamp":{},"level":"{}"}}"#,
            self.name, self.timestamp, self.level
        )
    }
}

// 接受任何 Serializable 的函数（自动要求 Loggable 和 Printable）
fn process(item: &dyn Serializable) {
    item.log();
    println!("序列化: {}", item.serialize());
}

fn main() {
    let event = Event {
        name: String::from("用户登录"),
        timestamp: 1700000000,
        level: String::from("INFO"),
    };

    process(&event);
    // [INFO] Event(用户登录 at 1700000000)
    // 序列化: {"name":"用户登录","timestamp":1700000000,"level":"INFO"}
}
```

</details>

### 练习 10：综合练习 -- 简易 Widget 系统

模拟 Flutter 的 Widget 系统。定义 `Widget` trait，实现 `Text`、`Button`、`Column` 组件，其中 `Column` 包含子 Widget 列表（使用 trait 对象）。实现 `render` 方法将 Widget 树渲染为缩进的文本表示。

```rust
// 提示：
// trait Widget { fn render(&self, indent: usize) -> String; }
// Column 使用 Vec<Box<dyn Widget>> 存储子组件
```

<details>
<summary>查看答案</summary>

```rust
trait Widget {
    fn render(&self, indent: usize) -> String;
}

struct Text {
    content: String,
    font_size: f64,
}

struct Button {
    label: String,
    on_pressed: String,
}

struct Column {
    children: Vec<Box<dyn Widget>>,
    spacing: f64,
}

impl Widget for Text {
    fn render(&self, indent: usize) -> String {
        let pad = " ".repeat(indent);
        format!("{}Text(\"{}\"  fontSize: {})", pad, self.content, self.font_size)
    }
}

impl Widget for Button {
    fn render(&self, indent: usize) -> String {
        let pad = " ".repeat(indent);
        format!(
            "{}Button(\n{}  label: \"{}\"\n{}  onPressed: {}\n{})",
            pad, pad, self.label, pad, self.on_pressed, pad
        )
    }
}

impl Widget for Column {
    fn render(&self, indent: usize) -> String {
        let pad = " ".repeat(indent);
        let mut result = format!("{}Column(spacing: {}) {{", pad, self.spacing);
        for child in &self.children {
            result.push_str(&format!("\n{}", child.render(indent + 2)));
        }
        result.push_str(&format!("\n{}}}", pad));
        result
    }
}

// 辅助构造函数
fn text(content: &str, font_size: f64) -> Box<dyn Widget> {
    Box::new(Text {
        content: content.to_string(),
        font_size,
    })
}

fn button(label: &str, on_pressed: &str) -> Box<dyn Widget> {
    Box::new(Button {
        label: label.to_string(),
        on_pressed: on_pressed.to_string(),
    })
}

fn column(spacing: f64, children: Vec<Box<dyn Widget>>) -> Box<dyn Widget> {
    Box::new(Column { children, spacing })
}

fn main() {
    // 构建一个类似 Flutter 的 Widget 树
    let app = column(8.0, vec![
        text("欢迎使用 Rust Flutter!", 24.0),
        text("这是一个 Widget 系统的演示", 16.0),
        column(4.0, vec![
            button("登录", "handle_login()"),
            button("注册", "handle_register()"),
        ]),
        text("版本 1.0.0", 12.0),
    ]);

    println!("{}", app.render(0));

    // 输出：
    // Column(spacing: 8) {
    //   Text("欢迎使用 Rust Flutter!"  fontSize: 24)
    //   Text("这是一个 Widget 系统的演示"  fontSize: 16)
    //   Column(spacing: 4) {
    //     Button(
    //       label: "登录"
    //       onPressed: handle_login()
    //     )
    //     Button(
    //       label: "注册"
    //       onPressed: handle_register()
    //     )
    //   }
    //   Text("版本 1.0.0"  fontSize: 12)
    // }
}
```

</details>

---

## 本章总结

```
┌──────────────────────────────────────────────────────────────────────┐
│                   第 4 章 Trait 与泛型编程 — 总结                     │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Trait = 行为契约                                                 │
│     • 类似 Dart abstract class / interface                           │
│     • 支持默认方法、不支持字段                                        │
│     • 孤儿规则保证一致性                                              │
│                                                                      │
│  2. Trait Bound = 类型约束                                           │
│     • impl Trait / T: Trait / where T: Trait                         │
│     • 可组合：T: Display + Clone + Debug                             │
│                                                                      │
│  3. 常用标准库 Trait                                                 │
│     • 输出：Display, Debug                                           │
│     • 复制：Clone, Copy                                              │
│     • 比较：PartialEq, Eq, PartialOrd, Ord                          │
│     • 转换：From, Into                                               │
│     • 默认值：Default                                                │
│                                                                      │
│  4. #[derive] 自动实现 Trait                                         │
│     • 省去手写重复代码                                                │
│     • 要求所有字段都实现对应 trait                                    │
│                                                                      │
│  5. Trait 对象 = 动态分发                                            │
│     • dyn Trait / Box<dyn Trait>                                     │
│     • 通过 vtable 实现运行时多态                                     │
│     • 需满足对象安全规则                                              │
│                                                                      │
│  6. 泛型 = 编译时多态                                                │
│     • 单态化实现零成本抽象                                            │
│     • 泛型函数、结构体、枚举                                          │
│                                                                      │
│  7. Sized 与 ?Sized                                                  │
│     • 默认所有泛型参数要求 Sized                                     │
│     • ?Sized 允许接受动态大小类型                                     │
│     • DST 必须通过胖指针访问                                         │
│                                                                      │
│  Rust vs Dart 核心区别:                                              │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │ Rust: 静态分发为主 → 零成本 → 编译时解析 → 二进制体积换性能   │  │
│  │ Dart: 动态分发为主 → 有开销 → 运行时解析 → 灵活但不够快       │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 下一章预告

在下一章 [第 5 章：错误处理](/rust/05-error-handling) 中，我们将学习 Rust 独特的错误处理方式。Rust 没有异常（exception），而是使用 `Result<T, E>` 和 `Option<T>` 枚举来显式表达可能的失败。你将学到：

- `Result<T, E>` 与 `Option<T>` 的使用
- `?` 操作符的魔法
- 自定义错误类型
- `anyhow` 和 `thiserror` 库
- 与 Dart try-catch 的对比
- 何时该 panic，何时该返回 Result
