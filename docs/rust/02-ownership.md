# 第 2 章：所有权、借用与生命周期

> 所有权系统是 Rust 最独特、最强大的特性，也是 Rust 实现"无 GC 内存安全"的核心机制。如果你来自 Dart/Flutter 世界，习惯了垃圾回收器（GC）自动管理内存，那么所有权系统将彻底改变你对内存的思维方式。本章将从零开始，带你理解所有权、借用与生命周期，并通过大量代码示例和与 Dart 的对比帮助你建立正确的心智模型。

---

## 2.1 所有权是什么？

### 为什么需要所有权？

在编程语言中，内存管理是一个核心问题。不同语言采用了不同的策略：

```
内存管理策略对比：

┌──────────────────────────────────────────────────────────────┐
│                      内存管理方式                              │
├──────────────┬───────────────────┬───────────────────────────┤
│   手动管理    │    垃圾回收 (GC)   │     所有权系统             │
│   C / C++    │    Dart / Go / Java │     Rust                 │
├──────────────┼───────────────────┼───────────────────────────┤
│ malloc/free  │ 运行时自动回收      │ 编译时静态分析             │
│ 容易内存泄漏  │ 有 GC 暂停         │ 零运行时开销               │
│ 悬垂指针风险  │ 内存开销大          │ 编译时保证内存安全          │
│ 双重释放 bug  │ 无法精确控制        │ 无 GC 暂停                │
└──────────────┴───────────────────┴───────────────────────────┘

总结：
C/C++   → 快但不安全（程序员负责）
Dart/Go → 安全但有运行时开销（GC 负责）
Rust    → 又快又安全（编译器负责）
```

### Dart GC vs Rust 所有权

作为 Flutter 开发者，你已经习惯了 Dart 的垃圾回收。让我们对比两者：

```dart
// Dart: GC 自动管理内存
// 文件: lib/gc_example.dart

void main() {
  var list = [1, 2, 3]; // 在堆上分配内存
  var list2 = list;      // list2 和 list 指向同一块内存（引用共享）

  list.add(4);
  print(list2); // [1, 2, 3, 4] — 两个变量看到同一份数据

  // 函数结束后，GC 发现没有引用指向这块内存，自动回收
  // 但 GC 不知道「何时」回收，可能导致内存占用波动
}
```

```rust
// Rust: 所有权系统管理内存
// 文件: src/ownership_example.rs

fn main() {
    let list = vec![1, 2, 3]; // 在堆上分配内存，list 拥有所有权
    let list2 = list;          // 所有权从 list 转移到 list2（Move）

    // println!("{:?}", list); // 编译错误！list 已经不拥有数据了
    println!("{:?}", list2);   // [1, 2, 3] — 只有 list2 能访问

    // 函数结束时，list2 离开作用域，内存立即释放（确定性析构）
}
```

关键差异用一张图理解：

```
Dart（引用共享 + GC）：
                    ┌─────────────┐
    list  ─────────>│  [1, 2, 3]  │  堆内存
    list2 ─────────>│             │  多个变量共享同一块内存
                    └─────────────┘
                          |
                    GC 追踪引用计数
                    不确定何时回收

Rust（所有权转移）：
    第一步：let list = vec![1, 2, 3];

    list  ─────────>┌─────────────┐
                    │  [1, 2, 3]  │  堆内存
                    └─────────────┘

    第二步：let list2 = list;  (所有权 Move)

    list  ─ ─ ─ ╳   (无效，不能再使用)

    list2 ─────────>┌─────────────┐
                    │  [1, 2, 3]  │  堆内存
                    └─────────────┘

    离开作用域 → 立即释放，零成本，无 GC
```

### 栈内存 vs 堆内存

理解所有权之前，必须先理解栈和堆的区别：

```
┌──────────────────────────────────────────────────────────────┐
│                        内存布局                               │
├─────────────────────────┬────────────────────────────────────┤
│         栈 (Stack)       │          堆 (Heap)                 │
├─────────────────────────┼────────────────────────────────────┤
│ - 固定大小的数据          │ - 动态大小的数据                    │
│ - 分配/释放极快（移动指针）│ - 分配较慢（查找空闲空间）          │
│ - 自动管理（函数返回即释放）│ - 需要管理（GC 或所有权）          │
│ - 后进先出（LIFO）        │ - 无特定顺序                       │
├─────────────────────────┼────────────────────────────────────┤
│ 存放的数据：              │ 存放的数据：                        │
│ - i32, f64, bool, char  │ - String（内容）                    │
│ - 固定大小数组 [i32; 5]  │ - Vec<T>（元素）                    │
│ - 元组 (i32, f64)       │ - Box<T>（堆分配数据）               │
│ - 指针/引用（指向堆）     │ - HashMap<K, V>（键值对）           │
└─────────────────────────┴────────────────────────────────────┘

String 的内存结构：
                栈                          堆
         ┌──────────────┐           ┌───┬───┬───┬───┬───┐
    s    │ ptr ─────────────────────>│ H │ e │ l │ l │ o │
         │ len: 5       │           └───┴───┴───┴───┴───┘
         │ capacity: 5  │
         └──────────────┘
     ptr: 指向堆上数据的指针
     len: 当前字符串长度
     capacity: 已分配的堆内存容量
```

```rust
// 文件: src/stack_heap.rs

fn main() {
    // 栈上的数据 — 固定大小，Copy 语义
    let x: i32 = 42;         // 4 字节，直接存在栈上
    let y: f64 = 3.14;       // 8 字节，直接存在栈上
    let flag: bool = true;   // 1 字节，直接存在栈上

    // 堆上的数据 — 动态大小，Move 语义
    let s = String::from("Hello");  // 栈: (ptr, len, cap)  堆: 实际字符数据
    let v = vec![1, 2, 3];          // 栈: (ptr, len, cap)  堆: 实际元素数据

    // 栈上的数据复制成本低，默认 Copy
    let x2 = x; // 拷贝 4 字节，x 和 x2 独立
    println!("x = {}, x2 = {}", x, x2); // 都可以用

    // 堆上的数据复制成本高，默认 Move
    let s2 = s; // 所有权转移，不是复制堆上的数据
    // println!("{}", s); // 编译错误！s 已无效
    println!("{}", s2); // 只有 s2 有效
}
```

---

## 2.2 所有权三大规则

Rust 的所有权系统基于三条核心规则，编译器在编译时严格检查这些规则：

```
┌──────────────────────────────────────────────────────────────┐
│                    所有权三大规则                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  规则 1: 每个值有且只有一个所有者（Owner）                      │
│                                                              │
│  规则 2: 当所有者离开作用域时，值会被自动丢弃（Drop）            │
│                                                              │
│  规则 3: 赋值或传参默认转移所有权（Move），不是复制              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 规则 1：每个值有且只有一个所有者

```rust
// 文件: src/rule_one.rs

fn main() {
    // s1 是字符串 "hello" 的所有者
    let s1 = String::from("hello");

    // 所有权转移给 s2，s1 不再是所有者
    let s2 = s1;

    // 此时 "hello" 只有一个所有者：s2
    // s1 已经无效

    // 类比：你把房产证（所有权）转让给别人，你就不再是房主了
}
```

### 规则 2：所有者离开作用域，值被丢弃

```rust
// 文件: src/rule_two.rs

fn main() {
    {
        let s = String::from("hello"); // s 进入作用域
        println!("{}", s);              // 使用 s
    } // s 离开作用域，Rust 自动调用 drop(s)，释放堆内存

    // println!("{}", s); // 编译错误！s 已经不存在了
}

// 对比 Dart：
// void main() {
//     {
//         var s = "hello"; // GC 管理的对象
//     }
//     // s 在 Dart 中虽然超出了词法作用域，但内存要等 GC 回收
//     // 可能立即回收，也可能很久之后才回收
// }
```

### 规则 3：赋值转移所有权（Move 语义）

```rust
// 文件: src/rule_three.rs

fn main() {
    let s1 = String::from("hello");

    // 赋值 = 转移所有权
    let s2 = s1;
    // println!("{}", s1); // 编译错误: value borrowed here after move

    // 函数传参 = 转移所有权
    let s3 = String::from("world");
    take_ownership(s3);
    // println!("{}", s3); // 编译错误: value borrowed here after move

    // 函数返回 = 转移所有权（返回调用者）
    let s4 = give_ownership();
    println!("{}", s4); // "gift" — 所有权转移给了 s4
}

fn take_ownership(s: String) {
    println!("我拿到了: {}", s);
} // s 离开作用域，"world" 被释放

fn give_ownership() -> String {
    let s = String::from("gift");
    s // 返回值，所有权转移给调用者
}
```

用图示理解 Move 过程：

```
let s1 = String::from("hello");

  栈                堆
┌────────────┐   ┌───────────┐
│ s1         │   │           │
│  ptr ──────────>│ "hello"   │
│  len: 5    │   │           │
│  cap: 5    │   └───────────┘
└────────────┘

let s2 = s1;  // Move: 栈数据复制，堆数据不复制

  栈                堆
┌────────────┐
│ s1 (无效)  │      ╳ (不指向任何东西)
│  ptr ──╳   │
│  len: 5    │
│  cap: 5    │
└────────────┘
┌────────────┐   ┌───────────┐
│ s2         │   │           │
│  ptr ──────────>│ "hello"   │
│  len: 5    │   │           │
│  cap: 5    │   └───────────┘
└────────────┘

为什么不是浅拷贝？
如果两个变量都指向同一块堆内存，当两个变量都离开作用域时，
Rust 会尝试释放同一块内存两次 —— 这就是"双重释放"错误（Double Free）。
Move 语义使旧变量无效，确保只有一个变量负责释放内存。
```

---

## 2.3 Move 语义与 Copy 语义

### Move 语义（默认行为）

在堆上分配内存的类型默认使用 Move 语义：

```rust
// 文件: src/move_semantics.rs

fn main() {
    // String — Move
    let s1 = String::from("hello");
    let s2 = s1; // s1 被 move，不再可用

    // Vec — Move
    let v1 = vec![1, 2, 3];
    let v2 = v1; // v1 被 move，不再可用

    // 自定义结构体（默认 Move）
    let p1 = Person { name: String::from("Alice"), age: 30 };
    let p2 = p1; // p1 被 move，不再可用

    // Box — Move
    let b1 = Box::new(42);
    let b2 = b1; // b1 被 move，不再可用

    println!("s2 = {}", s2);
    println!("v2 = {:?}", v2);
    println!("p2 = {:?}", p2);
    println!("b2 = {}", b2);
}

#[derive(Debug)]
struct Person {
    name: String,
    age: u32,
}
```

### Copy 语义（栈上小数据）

实现了 `Copy` trait 的类型在赋值时会自动按位复制，原变量仍然可用：

```rust
// 文件: src/copy_semantics.rs

fn main() {
    // 整数 — Copy
    let x: i32 = 42;
    let y = x;    // 复制 4 字节，x 仍然可用
    println!("x = {}, y = {}", x, y); // 都有效

    // 浮点数 — Copy
    let a: f64 = 3.14;
    let b = a;
    println!("a = {}, b = {}", a, b);

    // 布尔 — Copy
    let flag = true;
    let flag2 = flag;
    println!("flag = {}, flag2 = {}", flag, flag2);

    // 字符 — Copy
    let ch = 'A';
    let ch2 = ch;
    println!("ch = {}, ch2 = {}", ch, ch2);

    // 元组（所有元素都是 Copy 的）— Copy
    let tup = (1, 2.0, true);
    let tup2 = tup;
    println!("tup = {:?}, tup2 = {:?}", tup, tup2);

    // 固定大小数组（元素是 Copy 的）— Copy
    let arr = [1, 2, 3];
    let arr2 = arr;
    println!("arr = {:?}, arr2 = {:?}", arr, arr2);

    // 引用 — Copy（复制的是引用本身，不是数据）
    let s = String::from("hello");
    let r1 = &s;
    let r2 = r1; // 复制引用，两个引用都有效
    println!("r1 = {}, r2 = {}", r1, r2);
}
```

完整的 Copy 类型列表：

```
┌──────────────────────────────────────────────────────────────┐
│                     Copy 类型一览                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  整数:    i8, i16, i32, i64, i128, isize                     │
│          u8, u16, u32, u64, u128, usize                      │
│                                                              │
│  浮点:    f32, f64                                            │
│                                                              │
│  布尔:    bool                                                │
│                                                              │
│  字符:    char                                                │
│                                                              │
│  元组:    (T1, T2, ...) 当且仅当所有 Ti 都是 Copy              │
│          (i32, f64)       -- Copy                            │
│          (i32, String)    -- 不是 Copy（String 不是 Copy）     │
│                                                              │
│  数组:    [T; N] 当且仅当 T 是 Copy                           │
│          [i32; 5]         -- Copy                            │
│          [String; 3]      -- 不是 Copy                       │
│                                                              │
│  引用:    &T              -- Copy（复制引用本身）               │
│          &mut T           -- 不是 Copy（独占性）               │
│                                                              │
│  不是 Copy 的类型:                                            │
│  String, Vec<T>, Box<T>, HashMap<K,V>, 包含非 Copy 字段的结构体│
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Clone：显式深拷贝

当你确实需要复制堆上的数据时，使用 `clone()` 方法：

```rust
// 文件: src/clone_example.rs

fn main() {
    // Clone String — 深拷贝堆上的字符数据
    let s1 = String::from("hello");
    let s2 = s1.clone(); // 在堆上创建 "hello" 的副本
    println!("s1 = {}, s2 = {}", s1, s2); // 两者都有效

    // Clone Vec — 深拷贝所有元素
    let v1 = vec![1, 2, 3];
    let v2 = v1.clone();
    println!("v1 = {:?}, v2 = {:?}", v1, v2);

    // Clone 自定义结构体
    let p1 = Person {
        name: String::from("Alice"),
        age: 30,
    };
    let p2 = p1.clone();
    println!("p1 = {:?}, p2 = {:?}", p1, p2);
}

#[derive(Debug, Clone)]
struct Person {
    name: String,
    age: u32,
}
```

Clone 的内存示意：

```
s1.clone() 的过程：

  栈                 堆
┌────────────┐    ┌───────────┐
│ s1         │    │           │
│  ptr ──────────>│ "hello"   │  原始数据
│  len: 5    │    │           │
│  cap: 5    │    └───────────┘
└────────────┘
                     clone()
┌────────────┐    ┌───────────┐
│ s2         │    │           │
│  ptr ──────────>│ "hello"   │  完整副本（新的堆内存）
│  len: 5    │    │           │
│  cap: 5    │    └───────────┘
└────────────┘

s1 和 s2 各自拥有独立的堆内存，互不影响
```

### 何时用 Copy vs Clone？

```rust
// 文件: src/copy_vs_clone.rs

// 用 Copy：小的、栈上的、按位复制就行的
#[derive(Debug, Clone, Copy)]
struct Point {
    x: f64,
    y: f64,
}

// 用 Clone（不能 Copy）：包含堆数据的
#[derive(Debug, Clone)]
struct User {
    name: String,  // String 不是 Copy，所以 User 也不能是 Copy
    age: u32,
}

fn main() {
    // Point 是 Copy 的，赋值自动复制
    let p1 = Point { x: 1.0, y: 2.0 };
    let p2 = p1; // 自动 Copy
    println!("p1 = {:?}, p2 = {:?}", p1, p2); // 都可以

    // User 不是 Copy 的，赋值会 Move
    let u1 = User { name: String::from("Alice"), age: 30 };
    let u2 = u1.clone(); // 必须显式 clone
    println!("u1 = {:?}, u2 = {:?}", u1, u2);

    // 如果不 clone，u1 就会被 move
    let u3 = User { name: String::from("Bob"), age: 25 };
    let u4 = u3; // Move
    // println!("{:?}", u3); // 编译错误！u3 已被 move
    println!("{:?}", u4);
}
```

> **规则总结**：如果一个类型的所有字段都实现了 `Copy`，你可以给它加 `#[derive(Copy, Clone)]`。如果它包含 `String`、`Vec` 等堆数据类型，则只能 `Clone`，不能 `Copy`。

---

## 2.4 引用与借用

每次使用数据都要转移所有权太不方便了。Rust 提供了**引用（Reference）**机制，让你在不获取所有权的情况下使用数据。这叫**借用（Borrowing）**。

### 不可变引用：`&T`

```rust
// 文件: src/immutable_ref.rs

fn main() {
    let s = String::from("hello");

    // 创建不可变引用，不转移所有权
    let len = calculate_length(&s);
    println!("'{}' 的长度是 {}", s, len); // s 仍然可用！

    // 可以同时创建多个不可变引用
    let r1 = &s;
    let r2 = &s;
    let r3 = &s;
    println!("{}, {}, {}", r1, r2, r3); // 完全合法
}

// 参数是 &String —— 借用 String，不获取所有权
fn calculate_length(s: &String) -> usize {
    s.len()
} // s 离开作用域，但它只是一个引用，不拥有数据，所以什么都不会被释放
```

引用的内存模型：

```
let s = String::from("hello");
let r = &s;

  栈                         堆
┌────────────┐
│ r          │
│  ptr ──────────┐
└────────────┘   │
┌────────────┐   │
│ s          │<──┘
│  ptr ──────────────>┌───────────┐
│  len: 5    │        │ "hello"   │
│  cap: 5    │        └───────────┘
└────────────┘

r 指向 s（不是指向堆数据），s 拥有 "hello" 的所有权
r 只是「借用」了 s 的数据访问权
```

### 可变引用：`&mut T`

```rust
// 文件: src/mutable_ref.rs

fn main() {
    let mut s = String::from("hello"); // 变量必须是 mut 的

    change(&mut s); // 传入可变引用

    println!("{}", s); // "hello, world"
}

fn change(s: &mut String) {
    s.push_str(", world"); // 通过可变引用修改数据
}
```

### 借用规则（核心！）

Rust 强制执行以下借用规则，这些规则在编译时检查：

```
┌──────────────────────────────────────────────────────────────┐
│                      借用规则                                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  规则 1: 在任意时刻，你可以拥有以下两者之一（但不能同时）：      │
│         - 一个可变引用（&mut T）                               │
│         - 任意数量的不可变引用（&T）                            │
│                                                              │
│  规则 2: 引用必须始终有效（不能悬垂）                           │
│                                                              │
│  简记：要么 1 个写者，要么 N 个读者，不能同时读写               │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

```rust
// 文件: src/borrow_rules.rs

fn main() {
    let mut s = String::from("hello");

    // 合法：多个不可变引用
    let r1 = &s;
    let r2 = &s;
    println!("{} and {}", r1, r2);
    // r1 和 r2 在这里最后一次使用，之后不再活跃（NLL: Non-Lexical Lifetimes）

    // 合法：r1 和 r2 已不再使用，可以创建可变引用
    let r3 = &mut s;
    r3.push_str(", world");
    println!("{}", r3);

    // 非法：不可变引用和可变引用不能同时存在
    // let r4 = &s;
    // let r5 = &mut s;
    // println!("{}, {}", r4, r5); // 编译错误！
}
```

```rust
// 文件: src/borrow_rules_detail.rs

fn main() {
    let mut data = vec![1, 2, 3];

    // 示例 1：不能同时有可变和不可变引用
    // let first = &data[0]; // 不可变借用
    // data.push(4);         // 可变借用（push 需要 &mut self）
    // println!("{}", first); // 编译错误！first 仍然活跃

    // 为什么？因为 push 可能导致 Vec 重新分配内存（扩容），
    // 这会使 first 指向已释放的内存 —— 悬垂指针！

    // 正确做法：先用完不可变引用，再修改
    let first = data[0]; // 复制值（i32 是 Copy 的）
    data.push(4);
    println!("first = {}, data = {:?}", first, data);

    // 示例 2：不能同时有两个可变引用
    // let r1 = &mut data;
    // let r2 = &mut data; // 编译错误！同一时间只能有一个 &mut
    // r1.push(5);
    // r2.push(6);

    // 正确做法：分开使用
    {
        let r1 = &mut data;
        r1.push(5);
    } // r1 离开作用域
    {
        let r2 = &mut data;
        r2.push(6);
    } // r2 离开作用域

    println!("{:?}", data); // [1, 2, 3, 4, 5, 6]
}
```

### 为什么这些规则可以防止数据竞争？

```
数据竞争的三个条件（必须同时满足）：
1. 两个或更多指针同时访问同一数据
2. 至少有一个指针在写入
3. 没有同步机制

Rust 的借用规则直接消除了条件 1+2 的组合：
- 如果有写入（&mut T），则只能有一个指针 → 不满足条件 1
- 如果有多个指针（&T），则都是只读 → 不满足条件 2

因此，数据竞争在编译时就被消除了！

┌────────────────────────────────────┐
│ &T + &T + &T    ── 多个读者 ── OK  │
│ &mut T          ── 唯一写者 ── OK  │
│ &T + &mut T     ── 读写冲突 ── 拒绝│
│ &mut T + &mut T ── 写写冲突 ── 拒绝│
└────────────────────────────────────┘
```

### 引用的实际应用场景

```rust
// 文件: src/borrow_practical.rs

// 场景 1：函数只需要读取数据，用 &T
fn print_info(name: &str, scores: &[i32]) {
    let avg: f64 = scores.iter().sum::<i32>() as f64 / scores.len() as f64;
    println!("{} 的平均分: {:.1}", name, avg);
}

// 场景 2：函数需要修改数据，用 &mut T
fn add_score(scores: &mut Vec<i32>, score: i32) {
    scores.push(score);
}

// 场景 3：函数需要获取所有权（例如存储数据或在线程间传递）
fn store_name(storage: &mut Vec<String>, name: String) {
    storage.push(name); // name 的所有权被转移进 Vec
}

fn main() {
    let name = String::from("Alice");
    let mut scores = vec![85, 92, 78];

    // 借用 name 和 scores，不转移所有权
    print_info(&name, &scores);

    // 可变借用 scores，添加新成绩
    add_score(&mut scores, 95);

    print_info(&name, &scores);

    // 转移 name 的所有权到 storage
    let mut storage = Vec::new();
    store_name(&mut storage, name);
    // println!("{}", name); // 编译错误！name 已被 move
    println!("storage: {:?}", storage);
}
```

---

## 2.5 切片类型

切片（Slice）是对集合中一段连续元素的引用，它不拥有数据，属于借用的一种形式。

### 字符串切片 `&str`

```rust
// 文件: src/string_slice.rs

fn main() {
    let s = String::from("hello world");

    // 字符串切片: &str
    let hello = &s[0..5];   // "hello"
    let world = &s[6..11];  // "world"

    // 简写语法
    let hello2 = &s[..5];   // 从头开始: 等同于 &s[0..5]
    let world2 = &s[6..];   // 到末尾: 等同于 &s[6..11]
    let full = &s[..];      // 完整切片: 等同于 &s[0..11]

    println!("{} {}", hello, world);
    println!("{} {} {}", hello2, world2, full);
}
```

切片的内存模型：

```
let s = String::from("hello world");
let hello = &s[0..5];
let world = &s[6..11];

  栈                           堆
┌──────────────┐
│ s            │          ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
│  ptr ────────────────── │ h │ e │ l │ l │ o │   │ w │ o │ r │ l │ d │
│  len: 11     │          └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
│  cap: 11     │            ^                       ^
└──────────────┘            |                       |
                            |                       |
┌──────────────┐            |  ┌──────────────┐     |
│ hello        │            |  │ world        │     |
│  ptr ────────────────────┘   │  ptr ────────────────┘
│  len: 5      │               │  len: 5      │
└──────────────┘               └──────────────┘

切片本质：一个指针 + 一个长度
不拥有数据，只是堆数据的一个「视图」
```

### `&str` vs `String`

```rust
// 文件: src/str_vs_string.rs

fn main() {
    // String: 拥有所有权，可以修改，堆上分配
    let mut owned = String::from("hello");
    owned.push_str(" world");

    // &str: 借用，不可修改，指向某处的字符串数据
    let slice: &str = &owned[..5]; // 指向 String 的切片
    let literal: &str = "hello";   // 字符串字面量，也是 &str（指向二进制数据段）

    // 函数参数推荐使用 &str，因为它更通用
    // &String 可以自动转换为 &str（Deref 强制转换）
    print_greeting(&owned);    // &String → &str（自动转换）
    print_greeting(literal);   // &str → &str（直接传入）
    print_greeting(slice);     // &str → &str（直接传入）
}

// 推荐：参数用 &str 而不是 &String
fn print_greeting(s: &str) {
    println!("Hello, {}!", s);
}
```

### 数组/Vec 切片 `&[T]`

```rust
// 文件: src/array_slice.rs

fn main() {
    // 数组切片
    let arr = [1, 2, 3, 4, 5];
    let slice1: &[i32] = &arr[1..4]; // [2, 3, 4]
    println!("数组切片: {:?}", slice1);

    // Vec 切片
    let vec = vec![10, 20, 30, 40, 50];
    let slice2: &[i32] = &vec[..3];   // [10, 20, 30]
    let slice3: &[i32] = &vec[2..];   // [30, 40, 50]
    let slice4: &[i32] = &vec[..];    // [10, 20, 30, 40, 50]
    println!("Vec 切片: {:?}, {:?}, {:?}", slice2, slice3, slice4);

    // 切片作为函数参数 — 通用接口
    let sum1 = sum_slice(&arr);      // 数组 → &[i32]
    let sum2 = sum_slice(&vec);      // Vec → &[i32]
    let sum3 = sum_slice(&vec[1..4]);// 部分切片 → &[i32]
    println!("sum1={}, sum2={}, sum3={}", sum1, sum2, sum3);
}

// 接受任何整数切片
fn sum_slice(numbers: &[i32]) -> i32 {
    let mut total = 0;
    for &n in numbers {
        total += n;
    }
    total
}
```

### 可变切片 `&mut [T]`

```rust
// 文件: src/mut_slice.rs

fn main() {
    let mut data = vec![5, 3, 1, 4, 2];

    // 可变切片：可以通过切片修改数据
    let slice = &mut data[..];
    sort_slice(slice);
    println!("排序后: {:?}", data); // [1, 2, 3, 4, 5]

    // 只对部分元素排序
    let mut data2 = vec![5, 3, 1, 4, 2];
    sort_slice(&mut data2[1..4]); // 只排序索引 1, 2, 3
    println!("部分排序: {:?}", data2); // [5, 1, 3, 4, 2]
}

fn sort_slice(slice: &mut [i32]) {
    slice.sort();
}
```

### 用切片实现安全的字符串处理

```rust
// 文件: src/safe_string.rs

// 返回第一个单词（切片保证了安全性）
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();

    for (i, &byte) in bytes.iter().enumerate() {
        if byte == b' ' {
            return &s[..i];
        }
    }

    s // 没有空格，整个字符串就是一个单词
}

fn main() {
    let sentence = String::from("hello world foo bar");
    let word = first_word(&sentence);
    println!("第一个单词: {}", word); // "hello"

    // 切片确保了引用的有效性
    // 如果我们在 word 存活期间修改 sentence，编译器会报错：
    // sentence.clear(); // 编译错误！sentence 被 word 不可变借用了
    // println!("{}", word);

    // 字符串字面量也可以
    let literal_word = first_word("nice to meet you");
    println!("字面量第一个单词: {}", literal_word); // "nice"
}
```

---

## 2.6 生命周期

### 为什么需要生命周期？

生命周期（Lifetime）是 Rust 编译器用来确保所有引用都有效的机制。生命周期标注不改变引用的实际存活时间，只是帮助编译器理解多个引用之间的关系。

```rust
// 文件: src/dangling_ref.rs

// 悬垂引用（Dangling Reference）问题：
// 引用指向的数据已经被释放

// fn dangle() -> &String {    // 编译错误！
//     let s = String::from("hello");
//     &s  // 返回 s 的引用
// }   // s 离开作用域被释放，引用指向了无效内存！

// 正确做法 1：返回所有权
fn no_dangle() -> String {
    let s = String::from("hello");
    s // 返回所有权，不是引用
}

fn main() {
    let result = no_dangle();
    println!("{}", result);

    // 悬垂引用的直观理解：
    // let r;
    // {
    //     let x = 5;
    //     r = &x;     // r 引用了 x
    // }               // x 被释放
    // println!("{}", r); // r 指向了已释放的内存 → 悬垂引用！
    //                    // Rust 编译器拒绝编译这段代码
}
```

```
悬垂引用图示：

正常引用：             悬垂引用（Rust 禁止）：
┌───┐   ┌───────┐     ┌───┐   ┌ ─ ─ ─ ┐
│ r │──>│ data  │     │ r │──>  已释放    ← 危险！
└───┘   └───────┘     └───┘   └ ─ ─ ─ ┘
r 指向有效数据          r 指向已释放的内存
```

### 生命周期标注语法

当函数接收多个引用并返回引用时，编译器需要知道返回的引用与哪个输入参数的生命周期相关联。这就需要生命周期标注。

```rust
// 文件: src/lifetime_syntax.rs

// 生命周期标注：用 'a 表示
// 含义：返回值的引用与输入参数的引用有相同的生命周期

// 不标注生命周期 — 编译器不知道返回值的引用关联哪个参数
// fn longest(x: &str, y: &str) -> &str {  // 编译错误！
//     if x.len() > y.len() { x } else { y }
// }

// 标注生命周期 — 告诉编译器：返回值至少和 x、y 中较短的那个活一样久
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

fn main() {
    let string1 = String::from("long string");

    {
        let string2 = String::from("xyz");
        let result = longest(string1.as_str(), string2.as_str());
        println!("最长的字符串: {}", result); // 合法：result 在 string2 作用域内使用
    }

    // 下面的代码会编译错误：
    // let result;
    // {
    //     let string2 = String::from("xyz");
    //     result = longest(string1.as_str(), string2.as_str());
    // } // string2 被释放
    // println!("{}", result); // result 可能引用了已释放的 string2 → 编译错误
}
```

生命周期标注的含义：

```
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str

解读：
- <'a> : 声明一个生命周期参数 'a
- x: &'a str : x 的引用至少活 'a 这么久
- y: &'a str : y 的引用至少活 'a 这么久
- -> &'a str : 返回值的引用至少活 'a 这么久

实际效果：
'a 的实际长度 = min(x 的生命周期, y 的生命周期)
即返回值的引用不能比任何一个输入参数活得更久

┌──────── string1 的生命周期 ─────────────────────────────┐
│  ┌──── string2 的生命周期 ────────┐                      |
│  │                                │                      │
│  │  'a = min(string1, string2)    │                      │
│  │  = string2 的生命周期           │                      │
│  │                                │                      │
│  │  result 必须在此范围内使用      │                      │
│  └────────────────────────────────┘                      │
└─────────────────────────────────────────────────────────┘
```

### 生命周期省略规则（Lifetime Elision Rules）

大多数情况下，编译器可以自动推断生命周期，不需要手动标注。编译器按照三条规则尝试推断：

```
┌──────────────────────────────────────────────────────────────┐
│                   生命周期省略三规则                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  规则 1（输入生命周期）:                                       │
│    每个引用参数获得各自的生命周期参数                            │
│    fn foo(x: &str)         → fn foo<'a>(x: &'a str)         │
│    fn foo(x: &str, y: &str)→ fn foo<'a, 'b>(x: &'a str,    │
│                                              y: &'b str)    │
│                                                              │
│  规则 2（输出生命周期）:                                       │
│    如果只有一个输入生命周期参数，它会赋予所有输出引用             │
│    fn foo(x: &str) -> &str → fn foo<'a>(x: &'a str)         │
│                                           -> &'a str        │
│                                                              │
│  规则 3（方法的输出生命周期）:                                  │
│    如果第一个参数是 &self 或 &mut self，                       │
│    self 的生命周期会赋予所有输出引用                            │
│    fn method(&self, x: &str) -> &str                        │
│    → fn method<'a, 'b>(&'a self, x: &'b str) -> &'a str    │
│                                                              │
│  如果三条规则都无法推断，编译器报错，要求手动标注                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

```rust
// 文件: src/lifetime_elision.rs

// 案例 1 — 编译器可以自动推断，不需要标注
// 规则 1 + 规则 2 生效
fn first_word(s: &str) -> &str {
    // 编译器推断为: fn first_word<'a>(s: &'a str) -> &'a str
    let bytes = s.as_bytes();
    for (i, &byte) in bytes.iter().enumerate() {
        if byte == b' ' {
            return &s[..i];
        }
    }
    s
}

// 案例 2 — 编译器可以自动推断（规则 3）
struct Parser {
    content: String,
}

impl Parser {
    // 规则 3 生效: &self 的生命周期赋予返回值
    fn get_content(&self) -> &str {
        // 编译器推断为: fn get_content<'a>(&'a self) -> &'a str
        &self.content
    }
}

// 案例 3 — 编译器无法推断，必须手动标注
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    // 两个输入引用，编译器不知道返回值跟哪个关联
    // 必须显式标注
    if x.len() > y.len() { x } else { y }
}

fn main() {
    let s = String::from("hello world");
    let word = first_word(&s);
    println!("{}", word);

    let parser = Parser { content: String::from("some content") };
    let content = parser.get_content();
    println!("{}", content);

    let result = longest("abc", "abcdef");
    println!("{}", result);
}
```

### 结构体中的生命周期

当结构体包含引用字段时，必须标注生命周期：

```rust
// 文件: src/lifetime_struct.rs

// 包含引用的结构体必须标注生命周期
// 含义：ImportantExcerpt 实例不能比它引用的数据活得更久
#[derive(Debug)]
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
    // 规则 3: &self 的生命周期赋予返回值，无需额外标注
    fn level(&self) -> i32 {
        3
    }

    // 规则 3: 返回值的生命周期来自 &self
    fn announce_and_return(&self, announcement: &str) -> &str {
        println!("注意: {}", announcement);
        self.part
    }
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence;

    {
        let i = novel.split('.').next().expect("找不到 '.'");
        first_sentence = ImportantExcerpt { part: i };
    }
    // first_sentence 仍然有效，因为 novel（数据源）还活着
    println!("{:?}", first_sentence);

    // 错误示例（无法编译）：
    // let excerpt;
    // {
    //     let temp = String::from("temporary data");
    //     excerpt = ImportantExcerpt { part: &temp };
    // } // temp 被释放
    // println!("{:?}", excerpt); // excerpt.part 引用了已释放的 temp！
}
```

### `'static` 生命周期

`'static` 表示引用的数据在整个程序运行期间都有效：

```rust
// 文件: src/lifetime_static.rs

fn main() {
    // 字符串字面量的类型是 &'static str
    // 因为它们被嵌入到程序的二进制文件中，程序运行期间一直存在
    let s: &'static str = "I have a static lifetime";
    println!("{}", s);

    // 'static 还可以用作 trait bound，表示类型不包含非 'static 的引用
    // 这在异步编程和线程中很常见
    // fn spawn<F: FnOnce() + Send + 'static>(f: F) { ... }

    // 注意：不要滥用 'static
    // 大多数情况下，如果编译器要求 'static，说明你的设计可能需要调整
    // 而不是简单地加上 'static
}

// 返回 'static 引用的函数
fn get_greeting() -> &'static str {
    "Hello, World!" // 字符串字面量是 'static 的
}
```

### 综合示例：多层生命周期

```rust
// 文件: src/lifetime_advanced.rs

use std::fmt::Display;

// 同时使用泛型、trait bound 和生命周期
fn longest_with_announcement<'a, T>(
    x: &'a str,
    y: &'a str,
    ann: T,
) -> &'a str
where
    T: Display,
{
    println!("公告: {}", ann);
    if x.len() > y.len() { x } else { y }
}

// 多个生命周期参数
#[derive(Debug)]
struct Context<'a, 'b> {
    title: &'a str,
    body: &'b str,
}

impl<'a, 'b> Context<'a, 'b> {
    fn new(title: &'a str, body: &'b str) -> Self {
        Context { title, body }
    }

    fn summary(&self) -> String {
        format!("[{}] {}", self.title, &self.body[..20.min(self.body.len())])
    }
}

fn main() {
    let result = longest_with_announcement("hello", "world!!!", "对比字符串长度");
    println!("较长的: {}", result);

    let title = String::from("Rust 学习");
    let body = String::from("所有权是 Rust 的核心特性，让你在编译时保证内存安全。");
    let ctx = Context::new(&title, &body);
    println!("{:?}", ctx);
    println!("摘要: {}", ctx.summary());
}
```

---

## 2.7 所有权与 Dart 对比总结

### 完整对比表

| 特性 | Dart | Rust |
|------|------|------|
| **内存管理方式** | 垃圾回收（GC） | 所有权系统（编译时） |
| **内存释放时机** | 不确定（GC 决定） | 确定（离开作用域即释放） |
| **赋值语义** | 引用共享（对象类型） | Move（非 Copy 类型） |
| **多重引用** | 多个变量共享同一对象 | 严格的借用规则 |
| **可变性** | 默认可变 | 默认不可变（需 `mut`） |
| **空值** | `null` / `null safety` | `Option<T>`（无 null） |
| **运行时开销** | GC 暂停、内存追踪 | 零运行时开销 |
| **学习曲线** | 低（熟悉的 GC 模型） | 高（需重新理解内存） |
| **深拷贝** | 手动实现 / 无标准方式 | `Clone` trait |
| **浅拷贝** | 默认行为（引用共享） | `Copy` trait（仅限小类型） |
| **数据竞争** | 单线程 Isolate 规避 | 编译时杜绝 |
| **内存泄漏** | 可能（循环引用等） | 极少（`Rc` 循环引用除外） |

### Dart 开发者的心智模型转换

```
┌──────────────────────────────────────────────────────────────┐
│              Dart 思维 → Rust 思维                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Dart: var a = obj; var b = a;                               │
│  → a 和 b 指向同一个对象，都能读写                             │
│                                                              │
│  Rust: let a = obj; let b = a;                               │
│  → 所有权从 a 转移到 b，a 不再能使用                           │
│  → 如果需要两个都用: let b = a.clone();                       │
│  → 如果只需要读: let b = &a;                                  │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Dart: void process(List<int> list) { list.add(42); }        │
│  → 直接修改原始 list（引用传递）                               │
│                                                              │
│  Rust: fn process(list: &mut Vec<i32>) { list.push(42); }    │
│  → 必须显式声明可变借用 &mut                                   │
│  → 编译器确保同一时间没有其他人在读 list                        │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Dart: String getName() { var s = "hello"; return s; }       │
│  → GC 追踪引用，s 不会被过早释放                               │
│                                                              │
│  Rust: fn get_name() -> String { let s = String::from("hi");│
│         s }  // 返回所有权，不是引用                           │
│  → 不能返回 &s，因为 s 在函数结束时会被释放                     │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 常见陷阱与解决方案

```rust
// 文件: src/common_pitfalls.rs

fn main() {
    // 陷阱 1: 用了值之后又想用 —— Move 后使用
    let name = String::from("Alice");
    greet(name);
    // println!("{}", name); // 编译错误！name 已被 move
    // 解决：传引用
    let name2 = String::from("Bob");
    greet_borrow(&name2);
    println!("仍然可用: {}", name2); // OK

    // 陷阱 2: 循环中的所有权
    let names = vec![
        String::from("Alice"),
        String::from("Bob"),
        String::from("Charlie"),
    ];
    // for name in names { ... } // 这会 move names 中的每个元素
    // println!("{:?}", names);   // 编译错误！names 已被 move
    // 解决：迭代引用
    for name in &names {
        println!("Hello, {}!", name);
    }
    println!("names 仍然可用: {:?}", names); // OK

    // 陷阱 3: 在匹配中的所有权
    let opt = Some(String::from("hello"));
    // match opt {
    //     Some(s) => println!("{}", s), // 这会 move s
    //     None => {},
    // }
    // println!("{:?}", opt); // 编译错误！
    // 解决：使用 ref 或 as_ref()
    match opt.as_ref() {
        Some(s) => println!("{}", s), // s 是 &String
        None => {},
    }
    println!("{:?}", opt); // OK

    // 陷阱 4: 方法调用可能消耗所有权
    let v = vec![1, 2, 3];
    // let iter = v.into_iter(); // into_iter() 消耗 v 的所有权！
    // println!("{:?}", v);      // 编译错误！
    // 解决：使用 iter() 借用迭代
    let sum: i32 = v.iter().sum();
    println!("v = {:?}, sum = {}", v, sum); // OK

    // 陷阱 5: 闭包捕获所有权
    let data = String::from("重要数据");
    // let closure = move || println!("{}", data); // move 闭包获取所有权
    // println!("{}", data); // 编译错误！
    // 解决：不用 move，或 clone 之后 move
    let data_clone = data.clone();
    let closure = move || println!("{}", data_clone);
    closure();
    println!("data 仍然可用: {}", data); // OK
}

fn greet(name: String) {
    println!("Hello, {}!", name);
}

fn greet_borrow(name: &str) {
    println!("Hello, {}!", name);
}
```

---

## 2.8 练习题

> 以下 10 道练习涵盖本章所有核心概念。每道题给出编译报错的代码，你需要修复它使程序正确编译和运行。

### 练习 1：修复 Move 错误

```rust
// 文件: exercises/ownership/ex01.rs
// 任务: 修复编译错误，使程序打印出两个变量的值

fn main() {
    let s1 = String::from("hello");
    let s2 = s1;

    // TODO: 修复下面这行，让两个 println 都能工作
    println!("s1 = {}, s2 = {}", s1, s2);
}

// 提示: 使用 clone() 或改变赋值方式

// === 参考答案 ===
// fn main() {
//     let s1 = String::from("hello");
//     let s2 = s1.clone(); // 使用 clone 创建副本
//     println!("s1 = {}, s2 = {}", s1, s2);
// }
```

### 练习 2：函数所有权

```rust
// 文件: exercises/ownership/ex02.rs
// 任务: 修复代码，使 main 中的 name 在调用 greet 后仍然可用

fn greet(name: String) {
    println!("Hello, {}!", name);
}

fn main() {
    let name = String::from("Rustacean");
    greet(name);

    // TODO: 修复，让下面这行能编译通过
    println!("name is: {}", name);
}

// 提示: 修改 greet 函数的参数类型为借用

// === 参考答案 ===
// fn greet(name: &str) {   // 改为借用
//     println!("Hello, {}!", name);
// }
//
// fn main() {
//     let name = String::from("Rustacean");
//     greet(&name);  // 传入引用
//     println!("name is: {}", name); // name 仍然可用
// }
```

### 练习 3：可变引用规则

```rust
// 文件: exercises/ownership/ex03.rs
// 任务: 修复代码中的借用冲突

fn main() {
    let mut s = String::from("hello");

    let r1 = &s;
    let r2 = &mut s;

    // TODO: 修复，使不可变引用和可变引用不冲突
    println!("{}, {}", r1, r2);
}

// 提示: 确保不可变引用使用完毕后再创建可变引用

// === 参考答案 ===
// fn main() {
//     let mut s = String::from("hello");
//
//     let r1 = &s;
//     println!("{}", r1); // r1 使用完毕
//
//     let r2 = &mut s;     // 现在可以创建可变引用了
//     r2.push_str(", world");
//     println!("{}", r2);
// }
```

### 练习 4：悬垂引用

```rust
// 文件: exercises/ownership/ex04.rs
// 任务: 修复悬垂引用错误

fn longest_word() -> &str {
    let s = String::from("hello world");
    let words: Vec<&str> = s.split(' ').collect();
    words[0]
}

fn main() {
    let word = longest_word();
    println!("{}", word);
}

// 提示: 函数不能返回局部变量的引用，需要返回拥有所有权的值

// === 参考答案 ===
// fn longest_word() -> String {  // 返回 String 而不是 &str
//     let s = String::from("hello world");
//     let words: Vec<&str> = s.split(' ').collect();
//     words[0].to_string()  // 转换为 String 返回
// }
//
// fn main() {
//     let word = longest_word();
//     println!("{}", word);
// }
```

### 练习 5：切片与所有权

```rust
// 文件: exercises/ownership/ex05.rs
// 任务: 修复切片使用中的借用冲突

fn main() {
    let mut s = String::from("hello world");

    let word = first_word(&s);
    s.clear(); // 清空字符串
    println!("第一个单词是: {}", word);
}

fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();
    for (i, &byte) in bytes.iter().enumerate() {
        if byte == b' ' {
            return &s[..i];
        }
    }
    s
}

// 提示: word 持有 s 的不可变引用，clear() 需要可变引用

// === 参考答案 ===
// fn main() {
//     let mut s = String::from("hello world");
//
//     let word = first_word(&s).to_string(); // 复制为独立 String
//     s.clear();
//     println!("第一个单词是: {}", word); // word 独立于 s
// }
```

### 练习 6：结构体中的所有权

```rust
// 文件: exercises/ownership/ex06.rs
// 任务: 修复结构体中引用的生命周期问题

struct Excerpt {
    content: &str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first = novel.split('.').next().expect("找不到 '.'");
    let excerpt = Excerpt { content: first };
    println!("摘要: {}", excerpt.content);
}

// 提示: 结构体中的引用需要生命周期标注

// === 参考答案 ===
// struct Excerpt<'a> {
//     content: &'a str,
// }
//
// fn main() {
//     let novel = String::from("Call me Ishmael. Some years ago...");
//     let first = novel.split('.').next().expect("找不到 '.'");
//     let excerpt = Excerpt { content: first };
//     println!("摘要: {}", excerpt.content);
// }
```

### 练习 7：生命周期标注

```rust
// 文件: exercises/ownership/ex07.rs
// 任务: 添加正确的生命周期标注

fn pick_longer(x: &str, y: &str) -> &str {
    if x.len() >= y.len() {
        x
    } else {
        y
    }
}

fn main() {
    let a = String::from("hello");
    let result;
    {
        let b = String::from("hi");
        result = pick_longer(&a, &b);
        println!("较长的: {}", result);
    }
}

// 提示: 函数返回引用时，如果有多个引用参数，需要显式标注生命周期

// === 参考答案 ===
// fn pick_longer<'a>(x: &'a str, y: &'a str) -> &'a str {
//     if x.len() >= y.len() {
//         x
//     } else {
//         y
//     }
// }
//
// fn main() {
//     let a = String::from("hello");
//     let result;
//     {
//         let b = String::from("hi");
//         result = pick_longer(&a, &b);
//         println!("较长的: {}", result);
//         // result 必须在 b 的作用域内使用
//     }
// }
```

### 练习 8：Vec 与所有权

```rust
// 文件: exercises/ownership/ex08.rs
// 任务: 修复 Vec 迭代中的所有权问题

fn sum_and_print(numbers: Vec<i32>) -> i32 {
    let sum: i32 = numbers.iter().sum();
    sum
}

fn main() {
    let nums = vec![1, 2, 3, 4, 5];

    let total = sum_and_print(nums);
    println!("总和: {}", total);

    // TODO: 修复，让下面这行也能工作
    println!("原始数据: {:?}", nums);
}

// 提示: 函数参数改为借用，避免获取所有权

// === 参考答案 ===
// fn sum_and_print(numbers: &[i32]) -> i32 {
//     let sum: i32 = numbers.iter().sum();
//     sum
// }
//
// fn main() {
//     let nums = vec![1, 2, 3, 4, 5];
//     let total = sum_and_print(&nums);
//     println!("总和: {}", total);
//     println!("原始数据: {:?}", nums);
// }
```

### 练习 9：综合 -- 实现安全的缓存结构

```rust
// 文件: exercises/ownership/ex09.rs
// 任务: 补全代码，使结构体正确使用生命周期和借用

struct Cache {
    query: ???,
    result: ???,
}

impl Cache {
    fn new(query: ???) -> Cache {
        let result = Self::compute(query);
        Cache { query, result }
    }

    fn compute(query: &str) -> String {
        format!("结果: {}", query.to_uppercase())
    }

    fn get_result(&self) -> &str {
        &self.result
    }
}

fn main() {
    let search = String::from("rust ownership");
    let cache = Cache::new(&search);
    println!("查询: {}", cache.query);
    println!("结果: {}", cache.get_result());
}

// 提示: query 是借用（需要生命周期），result 拥有所有权

// === 参考答案 ===
// struct Cache<'a> {
//     query: &'a str,
//     result: String,
// }
//
// impl<'a> Cache<'a> {
//     fn new(query: &'a str) -> Cache<'a> {
//         let result = Self::compute(query);
//         Cache { query, result }
//     }
//
//     fn compute(query: &str) -> String {
//         format!("结果: {}", query.to_uppercase())
//     }
//
//     fn get_result(&self) -> &str {
//         &self.result
//     }
// }
//
// fn main() {
//     let search = String::from("rust ownership");
//     let cache = Cache::new(&search);
//     println!("查询: {}", cache.query);
//     println!("结果: {}", cache.get_result());
// }
```

### 练习 10：综合 -- 文本分析器

```rust
// 文件: exercises/ownership/ex10.rs
// 任务: 实现一个文本分析器，正确处理所有权和借用

// 要求:
// 1. TextAnalyzer 借用原始文本（使用生命周期）
// 2. word_count() 返回单词数量
// 3. unique_words() 返回去重后的单词列表（拥有所有权）
// 4. longest_word() 返回最长单词的切片引用
// 5. contains() 检查是否包含某个单词

struct TextAnalyzer<'a> {
    text: &'a str,
}

impl<'a> TextAnalyzer<'a> {
    fn new(text: &'a str) -> Self {
        TextAnalyzer { text }
    }

    fn word_count(&self) -> usize {
        // TODO: 实现
        todo!()
    }

    fn unique_words(&self) -> Vec<String> {
        // TODO: 实现（返回拥有所有权的 String 列表）
        todo!()
    }

    fn longest_word(&self) -> &'a str {
        // TODO: 实现（返回原文本的切片）
        todo!()
    }

    fn contains(&self, word: &str) -> bool {
        // TODO: 实现
        todo!()
    }
}

fn main() {
    let text = String::from("the quick brown fox jumps over the lazy dog");
    let analyzer = TextAnalyzer::new(&text);

    println!("单词数: {}", analyzer.word_count());
    println!("去重单词: {:?}", analyzer.unique_words());
    println!("最长单词: {}", analyzer.longest_word());
    println!("包含 fox: {}", analyzer.contains("fox"));
    println!("包含 cat: {}", analyzer.contains("cat"));

    // text 在这里仍然可用
    println!("原始文本: {}", text);
}

// === 参考答案 ===
// use std::collections::HashSet;
//
// struct TextAnalyzer<'a> {
//     text: &'a str,
// }
//
// impl<'a> TextAnalyzer<'a> {
//     fn new(text: &'a str) -> Self {
//         TextAnalyzer { text }
//     }
//
//     fn word_count(&self) -> usize {
//         self.text.split_whitespace().count()
//     }
//
//     fn unique_words(&self) -> Vec<String> {
//         let mut seen = HashSet::new();
//         self.text
//             .split_whitespace()
//             .filter(|w| seen.insert(*w))
//             .map(|w| w.to_string())
//             .collect()
//     }
//
//     fn longest_word(&self) -> &'a str {
//         self.text
//             .split_whitespace()
//             .max_by_key(|w| w.len())
//             .unwrap_or("")
//     }
//
//     fn contains(&self, word: &str) -> bool {
//         self.text.split_whitespace().any(|w| w == word)
//     }
// }
//
// fn main() {
//     let text = String::from("the quick brown fox jumps over the lazy dog");
//     let analyzer = TextAnalyzer::new(&text);
//
//     println!("单词数: {}", analyzer.word_count());        // 9
//     println!("去重单词: {:?}", analyzer.unique_words());   // 8 个唯一单词
//     println!("最长单词: {}", analyzer.longest_word());     // "jumps"
//     println!("包含 fox: {}", analyzer.contains("fox"));   // true
//     println!("包含 cat: {}", analyzer.contains("cat"));   // false
//     println!("原始文本: {}", text);
// }
```

---

## 本章总结

```
┌──────────────────────────────────────────────────────────────┐
│                  第 2 章知识点速查                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  所有权三规则：                                               │
│  1. 每个值只有一个 Owner                                      │
│  2. Owner 离开作用域 → 值被 Drop                              │
│  3. 赋值/传参 = 转移所有权（Move）                             │
│                                                              │
│  Copy vs Move：                                              │
│  - Copy: i32, f64, bool, char 等栈上小类型 → 自动复制         │
│  - Move: String, Vec, Box 等堆上类型 → 转移所有权             │
│  - Clone: 显式深拷贝 → .clone()                              │
│                                                              │
│  借用规则：                                                   │
│  - &T: 不可变引用，可以有多个，只读                            │
│  - &mut T: 可变引用，同一时间只能有一个                        │
│  - 不可变引用和可变引用不能同时存在                            │
│                                                              │
│  切片：                                                      │
│  - &str: 字符串切片（借用 String 或字面量）                    │
│  - &[T]: 数组/Vec 切片（数据的"视图"）                        │
│  - 不拥有数据，只是引用的一种                                  │
│                                                              │
│  生命周期：                                                   │
│  - 'a: 生命周期参数，表示引用的有效范围                        │
│  - 三条省略规则让大多数情况不需要手动标注                       │
│  - 结构体中的引用必须标注生命周期                              │
│  - 'static: 程序运行全程有效的引用                            │
│                                                              │
│  Dart 开发者记忆法：                                          │
│  Dart: 变量 = 标签贴在对象上，多个标签共享一个对象              │
│  Rust: 变量 = 所有权证书，一个证书对应一个对象                  │
│        借用 = 临时借阅证，看完要还                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

> **下一章预告**：[第 3 章：结构体、枚举与模式匹配](/rust/03-structs-enums) -- 学习如何用结构体和枚举组织数据，掌握 Rust 强大的模式匹配系统，理解 `Option<T>` 和 `Result<T, E>` 的设计哲学。
