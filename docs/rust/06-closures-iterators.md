# 第 6 章：闭包与迭代器

> 闭包（Closure）和迭代器（Iterator）是 Rust 中函数式编程的两大基石。如果你来自 Dart/Flutter 世界，你一定对 `(x) => x + 1`、`.map()`、`.where()` 这些操作非常熟悉。Rust 的闭包和迭代器在表面上与 Dart 相似，但在底层实现上却有本质区别——Rust 的闭包与所有权系统深度集成，迭代器则是真正的"零成本抽象"（zero-cost abstraction），编译后的性能与手写循环完全一致。本章将带你从语法到原理，全面掌握 Rust 的闭包与迭代器。

---

## 6.1 闭包语法

### 什么是闭包？

闭包是一种可以捕获其定义环境中变量的匿名函数。在大多数现代语言中，闭包几乎无处不在。

```
闭包 vs 普通函数：

┌─────────────────────────────────────────────────────────┐
│                     普通函数 (fn)                        │
├─────────────────────────────────────────────────────────┤
│ - 有名字                                                │
│ - 不能捕获外部变量                                       │
│ - 使用 fn 关键字定义                                     │
│ - 参数和返回值类型必须显式标注                             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                     闭包 (Closure)                       │
├─────────────────────────────────────────────────────────┤
│ - 通常匿名                                              │
│ - 可以捕获外部变量                                       │
│ - 使用 |参数| 语法定义                                   │
│ - 参数和返回值类型可以推断                                │
└─────────────────────────────────────────────────────────┘
```

### Rust 闭包基本语法

Rust 闭包使用竖线 `|` 包围参数，而非圆括号：

```rust
// 文件: src/closure_syntax.rs

fn main() {
    // 最简形式：单表达式闭包
    let add_one = |x| x + 1;
    println!("{}", add_one(5)); // 6

    // 多参数闭包
    let add = |a, b| a + b;
    println!("{}", add(3, 4)); // 7

    // 无参数闭包
    let greet = || println!("你好，Rust！");
    greet(); // 你好，Rust！

    // 多行闭包（使用花括号）
    let complex = |x: i32| {
        let doubled = x * 2;
        let result = doubled + 10;
        result // 最后一个表达式作为返回值
    };
    println!("{}", complex(5)); // 20
}
```

### 类型推断与显式标注

Rust 闭包的一个重要特性是类型推断——编译器通常可以根据上下文推断参数和返回值类型：

```rust
// 文件: src/closure_types.rs

fn main() {
    // 编译器自动推断类型
    let add_one = |x| x + 1;
    let result = add_one(5); // 编译器推断 x: i32, 返回 i32

    // 显式标注类型（有时为了清晰性或解决歧义）
    let add_one_explicit = |x: i32| -> i32 { x + 1 };

    // 注意：闭包的类型一旦推断确定，就不能再用于其他类型
    let print_it = |x| println!("{}", x);
    print_it(42);       // 推断 x: i32
    // print_it("hello"); // 编译错误！x 已被推断为 i32

    // 对比：普通函数必须显式标注
    fn add_one_fn(x: i32) -> i32 {
        x + 1
    }
}
```

### Dart vs Rust 闭包语法对比

```
闭包语法对比：

┌──────────────────┬────────────────────────────────┐
│      特性         │    Dart         │    Rust       │
├──────────────────┼────────────────────────────────┤
│ 箭头语法          │ (x) => x + 1   │ |x| x + 1    │
│ 块语法            │ (x) { ... }    │ |x| { ... }   │
│ 无参数            │ () => 42       │ || 42         │
│ 多参数            │ (a, b) => a+b  │ |a, b| a + b  │
│ 类型标注          │ (int x) => x+1 │ |x: i32| x+1  │
│ 返回类型          │ 自动/手动       │ 自动/手动      │
│ 赋值给变量        │ var f = ...    │ let f = ...    │
└──────────────────┴────────────────────────────────┘
```

```dart
// Dart: 闭包语法
// 文件: lib/closure_syntax.dart

void main() {
  // 箭头语法（单表达式）
  var addOne = (int x) => x + 1;
  print(addOne(5)); // 6

  // 块语法（多行）
  var complex = (int x) {
    var doubled = x * 2;
    var result = doubled + 10;
    return result;
  };
  print(complex(5)); // 20

  // 无参数闭包
  var greet = () => print('你好，Dart！');
  greet();

  // 闭包作为参数
  var numbers = [1, 2, 3, 4, 5];
  var doubled = numbers.map((x) => x * 2).toList();
  print(doubled); // [2, 4, 6, 8, 10]
}
```

```rust
// Rust: 等价的闭包用法
// 文件: src/closure_comparison.rs

fn main() {
    // 单表达式闭包
    let add_one = |x: i32| x + 1;
    println!("{}", add_one(5)); // 6

    // 多行闭包
    let complex = |x: i32| {
        let doubled = x * 2;
        let result = doubled + 10;
        result
    };
    println!("{}", complex(5)); // 20

    // 无参数闭包
    let greet = || println!("你好，Rust！");
    greet();

    // 闭包作为参数
    let numbers = vec![1, 2, 3, 4, 5];
    let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
    println!("{:?}", doubled); // [2, 4, 6, 8, 10]
}
```

### 闭包作为函数参数

```rust
// 文件: src/closure_as_param.rs

// 接受闭包作为参数的函数
fn apply_twice<F: Fn(i32) -> i32>(f: F, x: i32) -> i32 {
    f(f(x))
}

// 也可以用 impl Fn 语法（更简洁）
fn apply_once(f: impl Fn(i32) -> i32, x: i32) -> i32 {
    f(x)
}

fn main() {
    let double = |x| x * 2;
    let add_three = |x| x + 3;

    println!("{}", apply_twice(double, 5));    // 20  (5*2=10, 10*2=20)
    println!("{}", apply_twice(add_three, 5)); // 11  (5+3=8, 8+3=11)
    println!("{}", apply_once(|x| x * x, 4)); // 16
}
```

---

## 6.2 闭包捕获环境

### 闭包如何捕获变量？

闭包最强大的能力是可以捕获定义时所在环境中的变量。Rust 的闭包会根据使用方式自动选择最高效的捕获方式：

```
闭包捕获方式（从限制最少到最多）：

┌─────────────────────────────────────────────────────────────┐
│  捕获方式        │ 对应 Trait  │ 说明                        │
├─────────────────────────────────────────────────────────────┤
│  不可变借用 (&T) │ Fn         │ 只读访问捕获的变量            │
│  可变借用 (&mut T)│ FnMut      │ 可修改捕获的变量             │
│  取得所有权 (T)  │ FnOnce     │ 消耗捕获的变量，只能调用一次   │
└─────────────────────────────────────────────────────────────┘

Trait 继承关系：

    FnOnce          ← 所有闭包都实现了 FnOnce
      ^
      |
    FnMut           ← 不消耗变量的闭包也实现 FnMut
      ^
      |
     Fn              ← 不修改变量的闭包也实现 Fn
```

### Fn —— 不可变借用捕获

```rust
// 文件: src/closure_fn.rs

fn main() {
    let name = String::from("Flutter 开发者");
    let greeting_length = name.len();

    // 这个闭包只读引用了 name，实现 Fn trait
    let greet = || {
        println!("你好，{}！你的名字有 {} 个字节", name, greeting_length);
    };

    greet();  // 可以多次调用
    greet();  // 没问题——只是不可变借用

    // name 仍然可用！
    println!("name 仍然有效: {}", name);
}
```

### FnMut —— 可变借用捕获

```rust
// 文件: src/closure_fnmut.rs

fn main() {
    let mut count = 0;

    // 这个闭包修改了 count，实现 FnMut trait
    let mut increment = || {
        count += 1;
        println!("计数: {}", count);
    };

    increment(); // 计数: 1
    increment(); // 计数: 2
    increment(); // 计数: 3

    // 注意：闭包存在期间，不能再借用 count
    // println!("{}", count); // 若在 increment 仍活跃时，会编译错误
    drop(increment); // 显式丢弃闭包，释放可变借用

    println!("最终计数: {}", count); // 现在可以了：最终计数: 3
}
```

### FnOnce —— 取得所有权

```rust
// 文件: src/closure_fnonce.rs

fn main() {
    let message = String::from("一次性消息");

    // 这个闭包消耗了 message（move），只实现 FnOnce
    let consume = || {
        let moved = message; // message 的所有权转移到闭包内部的 moved
        println!("消耗: {}", moved);
        // moved 在闭包结束时被 drop
    };

    consume(); // 消耗: 一次性消息
    // consume(); // 编译错误！FnOnce 只能调用一次
    // println!("{}", message); // 编译错误！message 已被 move
}
```

### Dart 闭包捕获对比

```dart
// Dart: 闭包始终通过引用捕获变量
// 文件: lib/closure_capture.dart

void main() {
  var count = 0;

  // Dart 闭包捕获的是变量本身（引用），不是值
  var increment = () {
    count++;
    print('计数: $count');
  };

  increment(); // 计数: 1
  increment(); // 计数: 2

  // Dart 中闭包和外部代码看到的是同一个变量
  print('外部 count: $count'); // 外部 count: 2

  // Dart 没有 Fn/FnMut/FnOnce 的区分
  // 所有闭包都可以自由读写捕获的变量
  // 所有闭包都可以多次调用
  // GC 负责管理闭包和被捕获变量的生命周期
}
```

```
Dart vs Rust 闭包捕获的本质区别：

Dart（GC 管理）：
    闭包 ──引用──> 变量 ──引用──> 堆对象
                    ^
    外部代码 ──引用──┘

    - 闭包和外部代码共享同一个变量
    - GC 追踪所有引用，自动回收
    - 没有"捕获方式"的区分

Rust（所有权系统管理）：
    情况 1 (Fn)：     闭包 ──&T────> 变量（不可变借用）
    情况 2 (FnMut)：  闭包 ──&mut T─> 变量（可变借用，独占）
    情况 3 (FnOnce)： 闭包 ──T─────> 变量（所有权转移）

    - 编译器根据闭包体内的用法自动选择
    - 始终选择限制最少（最灵活）的方式
    - 编译时保证内存安全，无 GC
```

### 闭包 Trait 在函数签名中的使用

```rust
// 文件: src/closure_traits_usage.rs

// 只需要读取：使用 Fn
fn call_twice<F: Fn()>(f: F) {
    f();
    f();
}

// 需要修改状态：使用 FnMut
fn call_with_mutation<F: FnMut()>(mut f: F) {
    f();
    f();
}

// 可能消耗值：使用 FnOnce
fn call_once<F: FnOnce() -> String>(f: F) -> String {
    f() // 只调用一次
}

fn main() {
    let name = String::from("Rust");
    call_twice(|| println!("你好, {}!", name));

    let mut total = 0;
    call_with_mutation(|| {
        total += 10;
        println!("total = {}", total);
    });

    let data = String::from("重要数据");
    let result = call_once(|| {
        // data 被 move 进来
        format!("处理: {}", data)
    });
    println!("{}", result); // 处理: 重要数据
}
```

---

## 6.3 闭包与所有权

### move 关键字

有时候我们需要强制闭包获取捕获变量的所有权，即使闭包体内只是读取。这时需要使用 `move` 关键字：

```rust
// 文件: src/closure_move.rs

fn main() {
    let name = String::from("Flutter");

    // 不加 move：闭包借用 name
    let greet = || println!("你好, {}", name);
    greet();
    println!("name 仍可用: {}", name); // OK

    // 加 move：闭包取得 name 的所有权
    let name2 = String::from("Rust");
    let greet_move = move || println!("你好, {}", name2);
    greet_move();
    // println!("{}", name2); // 编译错误！name2 已被 move 进闭包
}
```

### 什么时候必须用 move？

```
何时需要 move 闭包？

┌──────────────────────────────────────────────────────────────┐
│ 场景 1：闭包的生命周期超过被捕获变量的作用域                     │
│                                                              │
│   fn create_greeter() -> impl Fn() {                        │
│       let name = String::from("World");                     │
│       move || println!("Hello, {}!", name)                  │
│       // 如果不用 move，name 在函数结束时被释放                │
│       // 返回的闭包就有一个悬垂引用——编译错误                   │
│   }                                                          │
├──────────────────────────────────────────────────────────────┤
│ 场景 2：将闭包发送到另一个线程                                  │
│                                                              │
│   let data = vec![1, 2, 3];                                 │
│   std::thread::spawn(move || {                              │
│       println!("{:?}", data);                               │
│       // 另一个线程需要拥有 data 的所有权                      │
│       // 原线程可能在新线程之前结束                             │
│   });                                                        │
├──────────────────────────────────────────────────────────────┤
│ 场景 3：显式表达所有权转移的意图                                │
│                                                              │
│   let config = load_config();                               │
│   let handler = move || process(config);                    │
│   // 明确表示 handler 独占 config                             │
└──────────────────────────────────────────────────────────────┘
```

### 线程中的 move 闭包

```rust
// 文件: src/closure_thread.rs
use std::thread;

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    // 必须使用 move，因为新线程可能比 main 线程活得更久
    let handle = thread::spawn(move || {
        let sum: i32 = numbers.iter().sum();
        println!("另一个线程中的求和: {}", sum);
        sum
    });

    // println!("{:?}", numbers); // 编译错误！numbers 已 move 到新线程

    let result = handle.join().unwrap();
    println!("线程返回: {}", result); // 线程返回: 15
}
```

### move 与 Copy 类型

```rust
// 文件: src/closure_move_copy.rs

fn main() {
    let x = 42; // i32 实现了 Copy trait

    // 即使使用 move，Copy 类型是复制而非移动
    let add_x = move || println!("x = {}", x);
    add_x();

    // x 仍然可用！因为 i32 是 Copy 的
    println!("x 仍可用: {}", x); // 42

    // 但 String 不是 Copy 的
    let s = String::from("hello");
    let print_s = move || println!("s = {}", s);
    print_s();
    // println!("{}", s); // 编译错误！String 不是 Copy 的，已被 move
}
```

### Dart 对比：闭包与线程

```dart
// Dart: Isolate 中无法直接共享闭包捕获的变量
// 文件: lib/closure_isolate.dart

import 'dart:isolate';

void main() async {
  var numbers = [1, 2, 3, 4, 5];

  // Dart Isolate 不共享内存，数据会被复制（或通过 SendPort 传递）
  // 这与 Rust 的 move 闭包概念不同
  final result = await Isolate.run(() {
    // numbers 被自动复制到新的 Isolate
    return numbers.reduce((a, b) => a + b);
  });

  print('Isolate 结果: $result'); // 15
  print('原始 numbers 仍可用: $numbers'); // [1, 2, 3, 4, 5]
}
```

---

## 6.4 迭代器 Trait

### Iterator Trait 定义

Rust 的迭代器基于 `Iterator` trait，这是标准库中最重要的 trait 之一：

```rust
// 标准库中的定义（简化版）
pub trait Iterator {
    type Item; // 关联类型：迭代器产出的元素类型

    fn next(&mut self) -> Option<Self::Item>;
    // 还有很多默认方法：map, filter, fold 等...
}
```

```
Iterator trait 的核心：

    ┌──────────────────────────────────────────────┐
    │           Iterator trait                     │
    │                                              │
    │   type Item;          // 产出什么类型的元素    │
    │                                              │
    │   fn next(&mut self)  // 获取下一个元素        │
    │       -> Option<Item> // Some(值) 或 None     │
    │                                              │
    │   ┌──────────────────────────────┐           │
    │   │ 调用 next() 的结果：          │           │
    │   │                              │           │
    │   │ Some(1) → Some(2) → Some(3)  │           │
    │   │      → None (迭代结束)        │           │
    │   └──────────────────────────────┘           │
    └──────────────────────────────────────────────┘
```

### 基本使用

```rust
// 文件: src/iterator_basic.rs

fn main() {
    let numbers = vec![10, 20, 30];

    // 方式 1：使用 for 循环（自动调用 into_iter）
    for n in &numbers {
        println!("{}", n);
    }

    // 方式 2：手动调用 next
    let mut iter = numbers.iter();
    assert_eq!(iter.next(), Some(&10));
    assert_eq!(iter.next(), Some(&20));
    assert_eq!(iter.next(), Some(&30));
    assert_eq!(iter.next(), None); // 迭代结束

    // 方式 3：三种迭代器方法
    let v = vec![String::from("a"), String::from("b")];

    // iter()     → 产生 &T（不可变引用）
    for s in v.iter() {
        println!("借用: {}", s);
    }
    // v 仍然可用

    // iter_mut() → 产生 &mut T（可变引用）
    let mut v2 = vec![1, 2, 3];
    for n in v2.iter_mut() {
        *n *= 2; // 原地修改
    }
    println!("{:?}", v2); // [2, 4, 6]

    // into_iter() → 产生 T（获取所有权）
    let v3 = vec![String::from("x"), String::from("y")];
    for s in v3.into_iter() {
        println!("拥有: {}", s);
    }
    // v3 不再可用——所有元素的所有权已被消耗
}
```

```
三种迭代方法对比：

┌─────────────┬──────────────┬──────────────────────────────┐
│   方法       │  产出类型     │  原集合状态                    │
├─────────────┼──────────────┼──────────────────────────────┤
│ .iter()     │  &T          │  不受影响，可继续使用            │
│ .iter_mut() │  &mut T      │  元素可被修改                   │
│ .into_iter()│  T           │  集合被消耗，不可再使用           │
└─────────────┴──────────────┴──────────────────────────────┘

for item in &collection     等价于  collection.iter()
for item in &mut collection 等价于  collection.iter_mut()
for item in collection      等价于  collection.into_iter()
```

### Dart Iterable 对比

```dart
// Dart: Iterable 和 Iterator
// 文件: lib/iterator_basic.dart

void main() {
  var numbers = [10, 20, 30];

  // Dart 的 for-in 循环
  for (var n in numbers) {
    print(n);
  }

  // Dart 手动使用 Iterator
  var iter = numbers.iterator;
  while (iter.moveNext()) {
    print(iter.current); // Dart 用 current 获取当前值
  }

  // Dart 没有 iter/iter_mut/into_iter 的区分
  // 所有迭代都是通过引用，GC 管理生命周期
  // 不存在"消耗集合"的概念
}
```

```
Dart Iterator vs Rust Iterator：

┌─────────────────────┬──────────────────────────────────┐
│       Dart           │           Rust                   │
├─────────────────────┼──────────────────────────────────┤
│ iter.moveNext()     │ iter.next()                      │
│ 返回 bool           │ 返回 Option<Item>                 │
│ iter.current 获取值  │ next() 直接返回值                  │
│ 无所有权概念         │ iter/iter_mut/into_iter 三种模式   │
│ 惰性（Iterable）     │ 惰性（Iterator adaptor）          │
│ GC 管理              │ 编译时所有权检查                   │
└─────────────────────┴──────────────────────────────────┘
```

---

## 6.5 迭代器适配器

迭代器适配器（Iterator Adaptor）是对迭代器进行变换的方法，它们返回一个新的迭代器。**适配器是惰性的**——它们不会立即执行，只有在消费者（如 `collect`）被调用时才会真正计算。

### map —— 映射变换

```rust
// 文件: src/iterator_map.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    // map: 对每个元素应用一个函数
    let doubled: Vec<i32> = numbers.iter()
        .map(|&x| x * 2)
        .collect();
    println!("{:?}", doubled); // [2, 4, 6, 8, 10]

    // 链式调用多个 map
    let result: Vec<String> = numbers.iter()
        .map(|&x| x * 3)
        .map(|x| format!("值: {}", x))
        .collect();
    println!("{:?}", result); // ["值: 3", "值: 6", "值: 9", "值: 12", "值: 15"]
}
```

```dart
// Dart 等价写法
var numbers = [1, 2, 3, 4, 5];
var doubled = numbers.map((x) => x * 2).toList();
// Dart 用 .toList() 对应 Rust 的 .collect()
```

### filter —— 过滤

```rust
// 文件: src/iterator_filter.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // filter: 保留满足条件的元素
    let evens: Vec<&i32> = numbers.iter()
        .filter(|&&x| x % 2 == 0)
        .collect();
    println!("偶数: {:?}", evens); // [2, 4, 6, 8, 10]

    // filter + map 组合
    let even_squares: Vec<i32> = numbers.iter()
        .filter(|&&x| x % 2 == 0)
        .map(|&x| x * x)
        .collect();
    println!("偶数的平方: {:?}", even_squares); // [4, 16, 36, 64, 100]

    // filter_map: 同时过滤和映射（更高效）
    let parsed: Vec<i32> = vec!["1", "two", "3", "四", "5"]
        .iter()
        .filter_map(|s| s.parse::<i32>().ok())
        .collect();
    println!("成功解析: {:?}", parsed); // [1, 3, 5]
}
```

```dart
// Dart 等价写法
var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
var evens = numbers.where((x) => x % 2 == 0).toList();
// Dart 用 .where() 对应 Rust 的 .filter()
```

### flat_map —— 展平映射

```rust
// 文件: src/iterator_flatmap.rs

fn main() {
    let sentences = vec!["hello world", "rust is great"];

    // flat_map: 将每个元素映射为一个迭代器，然后展平
    let words: Vec<&str> = sentences.iter()
        .flat_map(|s| s.split_whitespace())
        .collect();
    println!("{:?}", words); // ["hello", "world", "rust", "is", "great"]

    // 等价于 Dart 的 expand
    let nested = vec![vec![1, 2], vec![3, 4], vec![5]];
    let flat: Vec<&i32> = nested.iter()
        .flat_map(|v| v.iter())
        .collect();
    println!("{:?}", flat); // [1, 2, 3, 4, 5]
}
```

### enumerate —— 带索引迭代

```rust
// 文件: src/iterator_enumerate.rs

fn main() {
    let fruits = vec!["苹果", "香蕉", "橙子"];

    // enumerate: 产出 (索引, 值) 元组
    for (i, fruit) in fruits.iter().enumerate() {
        println!("{}: {}", i, fruit);
    }
    // 0: 苹果
    // 1: 香蕉
    // 2: 橙子

    // 与 Dart 的 asMap 或 indexed 对比
    // Dart: fruits.asMap().forEach((i, fruit) => print('$i: $fruit'));
}
```

### zip —— 配对合并

```rust
// 文件: src/iterator_zip.rs

fn main() {
    let names = vec!["Alice", "Bob", "Charlie"];
    let scores = vec![95, 87, 92];

    // zip: 将两个迭代器配对
    let results: Vec<(&str, &i32)> = names.iter()
        .copied()
        .zip(scores.iter())
        .collect();
    println!("{:?}", results);
    // [("Alice", 95), ("Bob", 87), ("Charlie", 92)]

    // 长度不同时，以较短的为准
    let a = vec![1, 2, 3, 4, 5];
    let b = vec!["a", "b", "c"];
    let zipped: Vec<_> = a.iter().zip(b.iter()).collect();
    println!("{:?}", zipped); // [(1, "a"), (2, "b"), (3, "c")]
}
```

### take、skip 和 chain

```rust
// 文件: src/iterator_take_skip_chain.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // take: 只取前 N 个元素
    let first_three: Vec<&i32> = numbers.iter().take(3).collect();
    println!("前三个: {:?}", first_three); // [1, 2, 3]

    // skip: 跳过前 N 个元素
    let after_skip: Vec<&i32> = numbers.iter().skip(7).collect();
    println!("跳过7个: {:?}", after_skip); // [8, 9, 10]

    // take_while / skip_while: 按条件取/跳过
    let taken: Vec<&i32> = numbers.iter()
        .take_while(|&&x| x < 5)
        .collect();
    println!("取到 <5: {:?}", taken); // [1, 2, 3, 4]

    // chain: 连接两个迭代器
    let a = vec![1, 2, 3];
    let b = vec![4, 5, 6];
    let combined: Vec<&i32> = a.iter().chain(b.iter()).collect();
    println!("连接: {:?}", combined); // [1, 2, 3, 4, 5, 6]
}
```

### peekable —— 可窥视迭代器

```rust
// 文件: src/iterator_peekable.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];
    let mut iter = numbers.iter().peekable();

    // peek: 查看下一个元素但不消费它
    assert_eq!(iter.peek(), Some(&&1));
    assert_eq!(iter.peek(), Some(&&1)); // 再次 peek 仍然是同一个
    assert_eq!(iter.next(), Some(&1));  // next 才会消费
    assert_eq!(iter.peek(), Some(&&2)); // 现在 peek 是下一个了

    // 实际应用：简单的词法分析器
    let input = "123+456";
    let mut chars = input.chars().peekable();
    let mut tokens: Vec<String> = Vec::new();

    while let Some(&c) = chars.peek() {
        if c.is_ascii_digit() {
            let mut number = String::new();
            while let Some(&d) = chars.peek() {
                if d.is_ascii_digit() {
                    number.push(d);
                    chars.next();
                } else {
                    break;
                }
            }
            tokens.push(number);
        } else {
            tokens.push(c.to_string());
            chars.next();
        }
    }
    println!("Tokens: {:?}", tokens); // ["123", "+", "456"]
}
```

```
常用迭代器适配器速查表：

┌──────────────┬──────────────────────────────────────────────┐
│   Rust        │   说明                     │  Dart 等价      │
├──────────────┼──────────────────────────────────────────────┤
│ .map()       │ 对每个元素应用函数           │ .map()          │
│ .filter()    │ 保留满足条件的元素           │ .where()        │
│ .flat_map()  │ 映射并展平                  │ .expand()       │
│ .enumerate() │ 附带索引                    │ .asMap()        │
│ .zip()       │ 配对两个迭代器              │ (需手动实现)     │
│ .take(n)     │ 取前 n 个                   │ .take(n)        │
│ .skip(n)     │ 跳过前 n 个                 │ .skip(n)        │
│ .chain()     │ 连接两个迭代器              │ .followedBy()   │
│ .peekable()  │ 可窥视下一个元素            │ (无直接对应)     │
│ .take_while()│ 按条件取                    │ .takeWhile()    │
│ .skip_while()│ 按条件跳过                  │ .skipWhile()    │
│ .inspect()   │ 调试用：查看每个元素         │ (无直接对应)     │
│ .rev()       │ 反转迭代方向                │ .reversed       │
│ .cloned()    │ 将 &T 转为 T (Clone)        │ (无需要)        │
│ .copied()    │ 将 &T 转为 T (Copy)         │ (无需要)        │
└──────────────┴──────────────────────────────────────────────┘
```

---

## 6.6 消费者适配器

消费者适配器（Consuming Adaptor）会消费迭代器并产出一个最终值。调用消费者后，迭代器就不能再使用了。

### collect —— 收集为集合

```rust
// 文件: src/iterator_collect.rs
use std::collections::{HashMap, HashSet};

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    // collect 为 Vec
    let doubled: Vec<i32> = numbers.iter().map(|&x| x * 2).collect();
    println!("{:?}", doubled); // [2, 4, 6, 8, 10]

    // collect 为 HashSet
    let unique: HashSet<i32> = vec![1, 2, 2, 3, 3, 3].into_iter().collect();
    println!("{:?}", unique); // {1, 2, 3}（顺序不确定）

    // collect 为 HashMap
    let pairs: HashMap<&str, i32> = vec![("苹果", 3), ("香蕉", 5), ("橙子", 2)]
        .into_iter()
        .collect();
    println!("{:?}", pairs); // {"苹果": 3, "香蕉": 5, "橙子": 2}

    // collect 为 String
    let greeting: String = vec!['你', '好', '世', '界'].into_iter().collect();
    println!("{}", greeting); // 你好世界

    // collect 处理 Result：如果任何一个失败，整体失败
    let results: Result<Vec<i32>, _> = vec!["1", "2", "three", "4"]
        .iter()
        .map(|s| s.parse::<i32>())
        .collect();
    println!("{:?}", results); // Err(ParseIntError)

    let results_ok: Result<Vec<i32>, _> = vec!["1", "2", "3", "4"]
        .iter()
        .map(|s| s.parse::<i32>())
        .collect();
    println!("{:?}", results_ok); // Ok([1, 2, 3, 4])
}
```

### fold —— 折叠（reduce）

```rust
// 文件: src/iterator_fold.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    // fold: 带初始值的累积操作
    let sum = numbers.iter().fold(0, |acc, &x| acc + x);
    println!("求和: {}", sum); // 15

    // fold 构建字符串
    let sentence = vec!["Rust", "真的", "很棒"];
    let combined = sentence.iter()
        .fold(String::new(), |mut acc, &word| {
            if !acc.is_empty() {
                acc.push(' ');
            }
            acc.push_str(word);
            acc
        });
    println!("{}", combined); // Rust 真的 很棒

    // reduce: 类似 fold，但用第一个元素作为初始值
    let product = numbers.iter().copied().reduce(|a, b| a * b);
    println!("乘积: {:?}", product); // Some(120)

    // Dart 对比：
    // numbers.fold(0, (acc, x) => acc + x);
    // numbers.reduce((a, b) => a * b);
}
```

### sum、any、all、find、count

```rust
// 文件: src/iterator_consumers.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // sum: 求和（需要类型标注）
    let total: i32 = numbers.iter().sum();
    println!("总和: {}", total); // 55

    // any: 是否有任何一个元素满足条件
    let has_even = numbers.iter().any(|&x| x % 2 == 0);
    println!("有偶数: {}", has_even); // true

    // all: 是否所有元素都满足条件
    let all_positive = numbers.iter().all(|&x| x > 0);
    println!("全部为正: {}", all_positive); // true

    // find: 找到第一个满足条件的元素
    let first_gt_5 = numbers.iter().find(|&&x| x > 5);
    println!("第一个 >5: {:?}", first_gt_5); // Some(6)

    // position: 找到第一个满足条件的元素的索引
    let pos = numbers.iter().position(|&x| x == 7);
    println!("7 的位置: {:?}", pos); // Some(6)

    // count: 计算元素个数
    let even_count = numbers.iter().filter(|&&x| x % 2 == 0).count();
    println!("偶数个数: {}", even_count); // 5

    // max / min
    let max = numbers.iter().max();
    let min = numbers.iter().min();
    println!("最大: {:?}, 最小: {:?}", max, min); // Some(10), Some(1)

    // max_by_key / min_by_key: 按提取的 key 比较
    let words = vec!["hello", "hi", "hey", "howdy"];
    let longest = words.iter().max_by_key(|s| s.len());
    println!("最长的词: {:?}", longest); // Some("howdy")
}
```

```
适配器 vs 消费者 —— 惰性 vs 即时：

    适配器（懒的，返回新迭代器）：

    [1,2,3,4,5].iter()
        .map(|x| x*2)       ← 不执行，返回 Map 迭代器
        .filter(|x| x>4)    ← 不执行，返回 Filter 迭代器
        ;                   ← 什么都没发生！编译器会警告

    消费者（立即执行，返回具体值）：

    [1,2,3,4,5].iter()
        .map(|x| x*2)       ← 组装管道
        .filter(|x| x>&4)   ← 组装管道
        .collect::<Vec<_>>() ← 触发！从后往前拉取数据
                             ← 返回 [6, 8, 10]

    数据流动方向（拉取模式）：

    collect ← filter ← map ← iter
    "给我"  ← "给我" ← "给我" ← [1]
             "不要"  ← "给我" ← [2] (2*2=4, 4 不 >4)
             "要！"  ← "给我" ← [3] (3*2=6, 6 > 4) → 存入结果
```

---

## 6.7 自定义迭代器

### 为自定义类型实现 Iterator

```rust
// 文件: src/custom_iterator.rs

// 自定义一个计数器
struct Counter {
    start: u32,
    end: u32,
    current: u32,
}

impl Counter {
    fn new(start: u32, end: u32) -> Self {
        Counter { start, end, current: start }
    }
}

// 实现 Iterator trait
impl Iterator for Counter {
    type Item = u32; // 迭代产出的类型

    fn next(&mut self) -> Option<Self::Item> {
        if self.current < self.end {
            let value = self.current;
            self.current += 1;
            Some(value)
        } else {
            None // 迭代结束
        }
    }
}

fn main() {
    // 使用自定义迭代器
    let counter = Counter::new(1, 6);
    let values: Vec<u32> = counter.collect();
    println!("{:?}", values); // [1, 2, 3, 4, 5]

    // 自定义迭代器自动获得所有适配器方法！
    let sum: u32 = Counter::new(1, 11)
        .filter(|x| x % 2 == 0)
        .sum();
    println!("1-10 偶数之和: {}", sum); // 30

    // 组合自定义迭代器
    let pairs: Vec<(u32, u32)> = Counter::new(1, 4)
        .zip(Counter::new(10, 13))
        .collect();
    println!("{:?}", pairs); // [(1, 10), (2, 11), (3, 12)]
}
```

### 斐波那契迭代器

```rust
// 文件: src/fibonacci_iterator.rs

struct Fibonacci {
    a: u64,
    b: u64,
}

impl Fibonacci {
    fn new() -> Self {
        Fibonacci { a: 0, b: 1 }
    }
}

impl Iterator for Fibonacci {
    type Item = u64;

    fn next(&mut self) -> Option<Self::Item> {
        let result = self.a;
        let new_b = self.a + self.b;
        self.a = self.b;
        self.b = new_b;
        Some(result) // 无限迭代器——永远返回 Some
    }
}

fn main() {
    // 无限迭代器 + take = 安全获取有限数量
    let fibs: Vec<u64> = Fibonacci::new().take(10).collect();
    println!("前10个斐波那契数: {:?}", fibs);
    // [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

    // 找到第一个超过1000的斐波那契数
    let big = Fibonacci::new().find(|&x| x > 1000);
    println!("第一个 >1000 的斐波那契数: {:?}", big); // Some(1597)

    // 所有小于100的斐波那契数之和
    let sum: u64 = Fibonacci::new().take_while(|&x| x < 100).sum();
    println!("小于100的斐波那契数之和: {}", sum); // 232
}
```

### IntoIterator Trait

`IntoIterator` 允许任何类型通过 `for` 循环来迭代：

```rust
// 文件: src/into_iterator.rs

struct TaskList {
    tasks: Vec<String>,
}

impl TaskList {
    fn new() -> Self {
        TaskList { tasks: Vec::new() }
    }

    fn add(&mut self, task: &str) {
        self.tasks.push(task.to_string());
    }
}

// 实现 IntoIterator，使 TaskList 可以用于 for 循环
impl IntoIterator for TaskList {
    type Item = String;
    type IntoIter = std::vec::IntoIter<String>;

    fn into_iter(self) -> Self::IntoIter {
        self.tasks.into_iter() // 消耗 TaskList，返回所有任务
    }
}

// 为引用也实现 IntoIterator
impl<'a> IntoIterator for &'a TaskList {
    type Item = &'a String;
    type IntoIter = std::slice::Iter<'a, String>;

    fn into_iter(self) -> Self::IntoIter {
        self.tasks.iter()
    }
}

fn main() {
    let mut list = TaskList::new();
    list.add("学习 Rust 闭包");
    list.add("学习 Rust 迭代器");
    list.add("构建 Flutter FFI 桥接");

    // 通过引用迭代（不消耗）
    for task in &list {
        println!("待办: {}", task);
    }

    // 消耗迭代
    for task in list {
        println!("完成: {}", task);
    }
    // list 已被消耗，不可再使用
}
```

### Dart 对比：自定义 Iterable

```dart
// Dart: 自定义 Iterable
// 文件: lib/custom_iterable.dart

class Counter extends Iterable<int> {
  final int start;
  final int end;

  Counter(this.start, this.end);

  @override
  Iterator<int> get iterator => _CounterIterator(start, end);
}

class _CounterIterator implements Iterator<int> {
  final int end;
  int _current;
  bool _started = false;

  _CounterIterator(int start, this.end) : _current = start;

  @override
  int get current => _current;

  @override
  bool moveNext() {
    if (!_started) {
      _started = true;
      return _current < end;
    }
    _current++;
    return _current < end;
  }
}

void main() {
  var counter = Counter(1, 6);
  print(counter.toList()); // [1, 2, 3, 4, 5]

  // Dart 的 Iterable 也支持链式调用
  var sum = Counter(1, 11).where((x) => x % 2 == 0).reduce((a, b) => a + b);
  print('偶数之和: $sum'); // 30
}
```

---

## 6.8 惰性求值与性能

### 惰性求值的本质

Rust 迭代器的一个核心特性是**惰性求值（Lazy Evaluation）**——适配器方法不会立即执行，直到消费者方法被调用。这和 Dart 的 `Iterable` 行为一致，但 Rust 在编译时就将整个迭代器链优化掉了。

```rust
// 文件: src/lazy_evaluation.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    // 这行代码什么都不做！编译器会发出警告
    numbers.iter().map(|x| {
        println!("处理: {}", x); // 这行永远不会被执行
        x * 2
    });
    // warning: unused `Map` that must be used
    // iterators are lazy and do nothing unless consumed

    println!("--- 分隔线 ---");

    // 只有消费者触发时才会执行
    let result: Vec<_> = numbers.iter().map(|x| {
        println!("处理: {}", x); // 现在会执行了
        x * 2
    }).collect();
    // 输出：
    // 处理: 1
    // 处理: 2
    // 处理: 3
    // 处理: 4
    // 处理: 5

    println!("{:?}", result); // [2, 4, 6, 8, 10]
}
```

### 惰性求值的优势：短路

```rust
// 文件: src/lazy_short_circuit.rs

fn main() {
    let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // find 在找到第一个匹配时就停止
    // 不需要处理所有 10 个元素
    let result = numbers.iter()
        .map(|x| {
            println!("检查: {}", x);
            x * 2
        })
        .find(|&x| x > 6);

    println!("结果: {:?}", result);
    // 输出：
    // 检查: 1  (1*2=2, 不满足 >6)
    // 检查: 2  (2*2=4, 不满足 >6)
    // 检查: 3  (3*2=6, 不满足 >6)
    // 检查: 4  (4*2=8, 满足 >6, 停止！)
    // 结果: Some(8)
    // 注意：5-10 根本没有被处理
}
```

```
惰性求值 vs 急切求值的执行流程：

急切求值（如果 Rust 不是惰性的话）：

    步骤 1: map 处理所有 10 个元素 → 创建中间数组 [2,4,6,8,10,12,14,16,18,20]
    步骤 2: find 在中间数组中查找 → Some(8)

    总计：10 次 map + 分配临时数组 + 10 次比较

惰性求值（Rust 实际行为）：

    元素 1: map(1)=2  → find: 2>6? 否 → 继续
    元素 2: map(2)=4  → find: 4>6? 否 → 继续
    元素 3: map(3)=6  → find: 6>6? 否 → 继续
    元素 4: map(4)=8  → find: 8>6? 是 → 返回 Some(8)
    元素 5-10: == 完全跳过 ==

    总计：4 次 map + 4 次比较 + 零额外分配
```

### 零成本抽象

Rust 的迭代器是"零成本抽象"（Zero-Cost Abstraction）的典范。编译后的代码与手写的命令式循环性能完全一致。

```rust
// 文件: src/zero_cost.rs

// 方式 1：使用迭代器（函数式风格）
fn sum_of_squares_iter(numbers: &[i32]) -> i32 {
    numbers.iter()
        .filter(|&&x| x % 2 == 0)
        .map(|&x| x * x)
        .sum()
}

// 方式 2：使用手写循环（命令式风格）
fn sum_of_squares_loop(numbers: &[i32]) -> i32 {
    let mut sum = 0;
    for &x in numbers {
        if x % 2 == 0 {
            sum += x * x;
        }
    }
    sum
}

fn main() {
    let numbers: Vec<i32> = (1..=1000).collect();

    let r1 = sum_of_squares_iter(&numbers);
    let r2 = sum_of_squares_loop(&numbers);

    assert_eq!(r1, r2);
    println!("迭代器版本 = {}", r1);
    println!("手写循环版本 = {}", r2);
    // 两者结果一致，编译后的机器码也几乎一致
}
```

```
零成本抽象——编译后的效果：

源代码（高级抽象）：
    numbers.iter()
        .filter(|&&x| x % 2 == 0)
        .map(|&x| x * x)
        .sum()

编译器优化后（等价伪代码）：
    let mut sum = 0;
    let mut i = 0;
    while i < numbers.len() {
        let x = numbers[i];
        if x % 2 == 0 {
            sum += x * x;
        }
        i += 1;
    }
    sum

    ┌──────────────────────────────────────┐
    │       零成本 ≠ 零代码                 │
    │                                      │
    │  零成本 = 你手动编写等价代码           │
    │  不可能比这更快                       │
    │                                      │
    │  抽象的使用者不需要为抽象「额外」付费   │
    └──────────────────────────────────────┘
```

### 迭代器 vs 循环：何时用哪个？

```
选择指南：

┌─────────────────────┬─────────────────────────────────┐
│ 使用迭代器            │ 使用手写循环                     │
├─────────────────────┼─────────────────────────────────┤
│ 数据变换管道          │ 需要复杂的控制流                 │
│ (map/filter/fold)    │ (多层 break/continue)           │
│                     │                                 │
│ 链式操作             │ 需要同时修改多个状态              │
│ (.map().filter())    │                                 │
│                     │                                 │
│ 更声明式、可读性强    │ 需要索引操作多个集合              │
│                     │                                 │
│ 性能与循环一致        │ 性能与迭代器一致                  │
│ (零成本抽象)         │ (只是风格不同)                    │
└─────────────────────┴─────────────────────────────────┘

黄金法则：优先使用迭代器，除非迭代器让代码更难读
```

### Dart 性能对比

```dart
// Dart 的 Iterable 也是惰性的，但...
// 文件: lib/dart_perf.dart

void main() {
  var numbers = List.generate(1000000, (i) => i);

  // Dart: Iterable 方法是惰性的
  // 但最终会被 JIT/AOT 编译优化
  // 不过 GC 压力、装箱拆箱等开销是不可避免的
  var result = numbers
      .where((x) => x % 2 == 0)
      .map((x) => x * x)
      .reduce((a, b) => a + b);

  print(result);

  // Rust 的优势：
  // 1. 编译时完全内联，无虚函数调用
  // 2. 无 GC 暂停
  // 3. 无装箱拆箱开销
  // 4. LLVM 可以进一步向量化 (SIMD) 优化
}
```

---

## 6.9 练习题

### 练习 1：基础闭包

编写一个函数 `create_multiplier`，它接受一个 `i32` 参数并返回一个闭包，该闭包将输入值乘以给定的乘数。

```rust
// 练习 1：补全代码
fn create_multiplier(factor: i32) -> impl Fn(i32) -> i32 {
    // 在此编写代码
    todo!()
}

fn main() {
    let double = create_multiplier(2);
    let triple = create_multiplier(3);
    assert_eq!(double(5), 10);
    assert_eq!(triple(5), 15);
    println!("练习 1 通过！");
}
```

<details>
<summary>查看答案</summary>

```rust
fn create_multiplier(factor: i32) -> impl Fn(i32) -> i32 {
    move |x| x * factor
}

fn main() {
    let double = create_multiplier(2);
    let triple = create_multiplier(3);
    assert_eq!(double(5), 10);
    assert_eq!(triple(5), 15);
    println!("练习 1 通过！");
}
```

**解析**：`factor` 是 `i32`（Copy 类型），`move` 关键字将其复制进闭包。返回类型使用 `impl Fn(i32) -> i32` 因为闭包只读捕获了 `factor`。

</details>

### 练习 2：FnMut 闭包

编写一个函数 `create_accumulator`，返回一个闭包，每次调用时将传入的值累加到内部状态。

```rust
// 练习 2：补全代码
fn create_accumulator(initial: i32) -> impl FnMut(i32) -> i32 {
    // 在此编写代码
    todo!()
}

fn main() {
    let mut acc = create_accumulator(0);
    assert_eq!(acc(5), 5);
    assert_eq!(acc(3), 8);
    assert_eq!(acc(2), 10);
    println!("练习 2 通过！");
}
```

<details>
<summary>查看答案</summary>

```rust
fn create_accumulator(initial: i32) -> impl FnMut(i32) -> i32 {
    let mut total = initial;
    move |x| {
        total += x;
        total
    }
}

fn main() {
    let mut acc = create_accumulator(0);
    assert_eq!(acc(5), 5);
    assert_eq!(acc(3), 8);
    assert_eq!(acc(2), 10);
    println!("练习 2 通过！");
}
```

**解析**：闭包需要修改 `total`，所以实现 `FnMut`。`move` 将 `total` 移入闭包使其成为闭包内部状态。

</details>

### 练习 3：迭代器链

使用迭代器方法完成以下需求：给定一个字符串 Vec，找出所有长度大于 3 的字符串，将它们转为大写，然后用逗号拼接。

```rust
// 练习 3：补全代码
fn process_strings(strings: Vec<&str>) -> String {
    // 在此编写代码，使用迭代器方法
    todo!()
}

fn main() {
    let words = vec!["hi", "hello", "hey", "rust", "go", "flutter"];
    let result = process_strings(words);
    assert_eq!(result, "HELLO,RUST,FLUTTER");
    println!("练习 3 通过！");
}
```

<details>
<summary>查看答案</summary>

```rust
fn process_strings(strings: Vec<&str>) -> String {
    strings.iter()
        .filter(|s| s.len() > 3)
        .map(|s| s.to_uppercase())
        .collect::<Vec<String>>()
        .join(",")
}

fn main() {
    let words = vec!["hi", "hello", "hey", "rust", "go", "flutter"];
    let result = process_strings(words);
    assert_eq!(result, "HELLO,RUST,FLUTTER");
    println!("练习 3 通过！");
}
```

**解析**：`filter` 筛选长度 > 3 的，`map` 转大写，`collect` 为 `Vec<String>` 后用 `join` 拼接。

</details>

### 练习 4：自定义迭代器

实现一个 `RangeStep` 迭代器，从 `start` 到 `end`（不含），步长为 `step`。

```rust
// 练习 4：补全代码
struct RangeStep {
    current: i32,
    end: i32,
    step: i32,
}

impl RangeStep {
    fn new(start: i32, end: i32, step: i32) -> Self {
        RangeStep { current: start, end, step }
    }
}

impl Iterator for RangeStep {
    type Item = i32;

    fn next(&mut self) -> Option<Self::Item> {
        // 在此编写代码
        todo!()
    }
}

fn main() {
    let values: Vec<i32> = RangeStep::new(0, 10, 3).collect();
    assert_eq!(values, vec![0, 3, 6, 9]);
    println!("练习 4 通过！");
}
```

<details>
<summary>查看答案</summary>

```rust
struct RangeStep {
    current: i32,
    end: i32,
    step: i32,
}

impl RangeStep {
    fn new(start: i32, end: i32, step: i32) -> Self {
        RangeStep { current: start, end, step }
    }
}

impl Iterator for RangeStep {
    type Item = i32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.current < self.end {
            let value = self.current;
            self.current += self.step;
            Some(value)
        } else {
            None
        }
    }
}

fn main() {
    let values: Vec<i32> = RangeStep::new(0, 10, 3).collect();
    assert_eq!(values, vec![0, 3, 6, 9]);
    println!("练习 4 通过！");
}
```

**解析**：每次 `next()` 返回当前值并将 `current` 增加 `step`，当 `current >= end` 时返回 `None`。

</details>

### 练习 5：fold 实现统计

使用 `fold` 对一组数字计算平均值和标准差（简化版：先算平均）。

```rust
// 练习 5：补全代码
fn statistics(numbers: &[f64]) -> (f64, f64) {
    // 返回 (平均值, 最大值)
    // 使用 fold 或其他迭代器方法
    todo!()
}

fn main() {
    let data = vec![2.0, 4.0, 6.0, 8.0, 10.0];
    let (avg, max) = statistics(&data);
    assert!((avg - 6.0).abs() < f64::EPSILON);
    assert!((max - 10.0).abs() < f64::EPSILON);
    println!("练习 5 通过！平均值: {}, 最大值: {}", avg, max);
}
```

<details>
<summary>查看答案</summary>

```rust
fn statistics(numbers: &[f64]) -> (f64, f64) {
    let (sum, count, max) = numbers.iter().fold(
        (0.0_f64, 0_usize, f64::NEG_INFINITY),
        |(sum, count, max), &x| {
            (sum + x, count + 1, if x > max { x } else { max })
        },
    );
    (sum / count as f64, max)
}

fn main() {
    let data = vec![2.0, 4.0, 6.0, 8.0, 10.0];
    let (avg, max) = statistics(&data);
    assert!((avg - 6.0).abs() < f64::EPSILON);
    assert!((max - 10.0).abs() < f64::EPSILON);
    println!("练习 5 通过！平均值: {}, 最大值: {}", avg, max);
}
```

**解析**：`fold` 使用三元组 `(sum, count, max)` 作为累积器，一次遍历同时计算总和、计数和最大值。

</details>

### 练习 6：闭包作为策略模式

实现一个简单的文本处理器，接受不同的闭包策略来处理文本。

```rust
// 练习 6：补全代码
struct TextProcessor {
    text: String,
}

impl TextProcessor {
    fn new(text: &str) -> Self {
        TextProcessor { text: text.to_string() }
    }

    // 应用一组变换（闭包）到文本上
    fn apply_transforms(&self, transforms: Vec<Box<dyn Fn(&str) -> String>>) -> String {
        // 在此编写代码
        todo!()
    }
}

fn main() {
    let processor = TextProcessor::new("  Hello, Rust World!  ");
    let result = processor.apply_transforms(vec![
        Box::new(|s: &str| s.trim().to_string()),
        Box::new(|s: &str| s.to_lowercase()),
        Box::new(|s: &str| s.replace("rust", "RUST")),
    ]);
    assert_eq!(result, "hello, RUST world!");
    println!("练习 6 通过！结果: {}", result);
}
```

<details>
<summary>查看答案</summary>

```rust
struct TextProcessor {
    text: String,
}

impl TextProcessor {
    fn new(text: &str) -> Self {
        TextProcessor { text: text.to_string() }
    }

    fn apply_transforms(&self, transforms: Vec<Box<dyn Fn(&str) -> String>>) -> String {
        transforms.iter().fold(self.text.clone(), |current, transform| {
            transform(&current)
        })
    }
}

fn main() {
    let processor = TextProcessor::new("  Hello, Rust World!  ");
    let result = processor.apply_transforms(vec![
        Box::new(|s: &str| s.trim().to_string()),
        Box::new(|s: &str| s.to_lowercase()),
        Box::new(|s: &str| s.replace("rust", "RUST")),
    ]);
    assert_eq!(result, "hello, RUST world!");
    println!("练习 6 通过！结果: {}", result);
}
```

**解析**：`fold` 以初始文本为起点，依次应用每个变换闭包。`Box<dyn Fn>` 用于存储不同类型的闭包（trait object）。

</details>

### 练习 7：enumerate + filter_map 组合

找出一个字符串向量中所有包含 "rust" (不区分大小写) 的元素，返回它们的 `(索引, 值)` 对。

```rust
// 练习 7：补全代码
fn find_rust_mentions(items: &[&str]) -> Vec<(usize, String)> {
    // 在此编写代码
    todo!()
}

fn main() {
    let items = vec!["Hello", "Rust is great", "Flutter", "I love rust", "Go"];
    let result = find_rust_mentions(&items);
    assert_eq!(result, vec![
        (1, "Rust is great".to_string()),
        (3, "I love rust".to_string()),
    ]);
    println!("练习 7 通过！");
}
```

<details>
<summary>查看答案</summary>

```rust
fn find_rust_mentions(items: &[&str]) -> Vec<(usize, String)> {
    items.iter()
        .enumerate()
        .filter(|(_, s)| s.to_lowercase().contains("rust"))
        .map(|(i, s)| (i, s.to_string()))
        .collect()
}

fn main() {
    let items = vec!["Hello", "Rust is great", "Flutter", "I love rust", "Go"];
    let result = find_rust_mentions(&items);
    assert_eq!(result, vec![
        (1, "Rust is great".to_string()),
        (3, "I love rust".to_string()),
    ]);
    println!("练习 7 通过！");
}
```

**解析**：`enumerate` 附加索引，`filter` 按条件筛选，`map` 转换为所需格式。

</details>

### 练习 8：分组统计

统计一个字符串中每个字符出现的次数（使用迭代器方法）。

```rust
// 练习 8：补全代码
use std::collections::HashMap;

fn char_frequency(text: &str) -> HashMap<char, usize> {
    // 在此编写代码
    todo!()
}

fn main() {
    let freq = char_frequency("hello");
    assert_eq!(freq[&'h'], 1);
    assert_eq!(freq[&'e'], 1);
    assert_eq!(freq[&'l'], 2);
    assert_eq!(freq[&'o'], 1);
    println!("练习 8 通过！频率: {:?}", freq);
}
```

<details>
<summary>查看答案</summary>

```rust
use std::collections::HashMap;

fn char_frequency(text: &str) -> HashMap<char, usize> {
    text.chars().fold(HashMap::new(), |mut map, c| {
        *map.entry(c).or_insert(0) += 1;
        map
    })
}

fn main() {
    let freq = char_frequency("hello");
    assert_eq!(freq[&'h'], 1);
    assert_eq!(freq[&'e'], 1);
    assert_eq!(freq[&'l'], 2);
    assert_eq!(freq[&'o'], 1);
    println!("练习 8 通过！频率: {:?}", freq);
}
```

**解析**：`fold` 使用 `HashMap` 作为累积器，`entry` API 用于高效插入或更新计数。

</details>

### 练习 9：窗口迭代

使用 `windows` 方法计算一个数组的移动平均线（每 3 个元素取平均）。

```rust
// 练习 9：补全代码
fn moving_average(data: &[f64], window_size: usize) -> Vec<f64> {
    // 在此编写代码
    todo!()
}

fn main() {
    let data = vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
    let result = moving_average(&data, 3);
    assert_eq!(result.len(), 4);
    assert!((result[0] - 2.0).abs() < f64::EPSILON); // (1+2+3)/3
    assert!((result[1] - 3.0).abs() < f64::EPSILON); // (2+3+4)/3
    assert!((result[2] - 4.0).abs() < f64::EPSILON); // (3+4+5)/3
    assert!((result[3] - 5.0).abs() < f64::EPSILON); // (4+5+6)/3
    println!("练习 9 通过！移动平均: {:?}", result);
}
```

<details>
<summary>查看答案</summary>

```rust
fn moving_average(data: &[f64], window_size: usize) -> Vec<f64> {
    data.windows(window_size)
        .map(|window| {
            let sum: f64 = window.iter().sum();
            sum / window_size as f64
        })
        .collect()
}

fn main() {
    let data = vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
    let result = moving_average(&data, 3);
    assert_eq!(result.len(), 4);
    assert!((result[0] - 2.0).abs() < f64::EPSILON);
    assert!((result[1] - 3.0).abs() < f64::EPSILON);
    assert!((result[2] - 4.0).abs() < f64::EPSILON);
    assert!((result[3] - 5.0).abs() < f64::EPSILON);
    println!("练习 9 通过！移动平均: {:?}", result);
}
```

**解析**：`windows(n)` 是切片方法，产生所有长度为 `n` 的连续子切片，每个窗口求和再除以窗口大小。

</details>

### 练习 10：综合挑战—— Flutter Widget 树模拟

模拟一个简单的 Widget 树结构，使用闭包和迭代器来遍历和变换。

```rust
// 练习 10：补全代码

#[derive(Debug, Clone)]
struct Widget {
    name: String,
    width: f64,
    height: f64,
    children: Vec<Widget>,
}

impl Widget {
    fn new(name: &str, width: f64, height: f64) -> Self {
        Widget {
            name: name.to_string(),
            width,
            height,
            children: Vec::new(),
        }
    }

    fn with_child(mut self, child: Widget) -> Self {
        self.children.push(child);
        self
    }

    // 任务 a: 使用闭包递归统计所有 Widget 总数（包括自身）
    fn count_all(&self) -> usize {
        todo!()
    }

    // 任务 b: 使用迭代器找到面积最大的 Widget 名称
    fn largest_area_name(&self) -> String {
        todo!()
    }

    // 任务 c: 收集所有 Widget 的名称为一个 Vec（深度优先）
    fn all_names(&self) -> Vec<String> {
        todo!()
    }
}

fn main() {
    let tree = Widget::new("Column", 400.0, 800.0)
        .with_child(
            Widget::new("Row", 400.0, 100.0)
                .with_child(Widget::new("Icon", 50.0, 50.0))
                .with_child(Widget::new("Text", 200.0, 30.0))
        )
        .with_child(Widget::new("Image", 400.0, 300.0))
        .with_child(Widget::new("Button", 150.0, 50.0));

    assert_eq!(tree.count_all(), 6);
    assert_eq!(tree.largest_area_name(), "Column");
    assert_eq!(tree.all_names(), vec![
        "Column", "Row", "Icon", "Text", "Image", "Button"
    ]);
    println!("练习 10 通过！Widget 树遍历完成");
}
```

<details>
<summary>查看答案</summary>

```rust
#[derive(Debug, Clone)]
struct Widget {
    name: String,
    width: f64,
    height: f64,
    children: Vec<Widget>,
}

impl Widget {
    fn new(name: &str, width: f64, height: f64) -> Self {
        Widget {
            name: name.to_string(),
            width,
            height,
            children: Vec::new(),
        }
    }

    fn with_child(mut self, child: Widget) -> Self {
        self.children.push(child);
        self
    }

    fn count_all(&self) -> usize {
        1 + self.children.iter()
            .map(|child| child.count_all())
            .sum::<usize>()
    }

    fn largest_area_name(&self) -> String {
        let my_area = self.width * self.height;
        let child_largest = self.children.iter()
            .map(|child| {
                let name = child.largest_area_name();
                let area = child.find_area_by_name(&name);
                (name, area)
            })
            .max_by(|a, b| a.1.partial_cmp(&b.1).unwrap());

        match child_largest {
            Some((name, area)) if area > my_area => name,
            _ => self.name.clone(),
        }
    }

    fn find_area_by_name(&self, target: &str) -> f64 {
        if self.name == target {
            return self.width * self.height;
        }
        self.children.iter()
            .map(|c| c.find_area_by_name(target))
            .fold(0.0_f64, f64::max)
    }

    fn all_names(&self) -> Vec<String> {
        let mut names = vec![self.name.clone()];
        for child in &self.children {
            names.extend(child.all_names());
        }
        names
    }
}

fn main() {
    let tree = Widget::new("Column", 400.0, 800.0)
        .with_child(
            Widget::new("Row", 400.0, 100.0)
                .with_child(Widget::new("Icon", 50.0, 50.0))
                .with_child(Widget::new("Text", 200.0, 30.0))
        )
        .with_child(Widget::new("Image", 400.0, 300.0))
        .with_child(Widget::new("Button", 150.0, 50.0));

    assert_eq!(tree.count_all(), 6);
    assert_eq!(tree.largest_area_name(), "Column");
    assert_eq!(tree.all_names(), vec![
        "Column", "Row", "Icon", "Text", "Image", "Button"
    ]);
    println!("练习 10 通过！Widget 树遍历完成");
}
```

**解析**：
- `count_all` 使用递归 + `map` + `sum` 统计所有节点。
- `largest_area_name` 递归查找面积最大的 Widget。
- `all_names` 使用深度优先遍历收集所有名称，`extend` 将子树的名称追加到结果中。

</details>

---

## 本章总结

```
┌────────────────────────────────────────────────────────────────────┐
│                    第 6 章：闭包与迭代器 总结                        │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  闭包：                                                            │
│  ├─ 语法：|参数| 表达式  或  |参数| { 语句块 }                      │
│  ├─ 类型推断：编译器自动推断参数和返回值类型                          │
│  ├─ 捕获方式：Fn（不可变借用）/ FnMut（可变借用）/ FnOnce（所有权）    │
│  ├─ move 关键字：强制获取所有权（线程、返回闭包时必须）                │
│  └─ vs Dart：Dart 闭包通过引用捕获，GC 管理；Rust 编译时静态分析      │
│                                                                    │
│  迭代器：                                                          │
│  ├─ 核心：Iterator trait + next() 方法 + Option 返回值              │
│  ├─ 三种模式：iter() / iter_mut() / into_iter()                    │
│  ├─ 适配器（惰性）：map, filter, flat_map, zip, enumerate, take...  │
│  ├─ 消费者（即时）：collect, fold, sum, any, all, find, count...    │
│  ├─ 自定义：实现 Iterator trait，可选 IntoIterator                  │
│  └─ 零成本抽象：编译后与手写循环性能一致                              │
│                                                                    │
│  关键心智模型：                                                     │
│  ├─ 闭包 = 匿名函数 + 环境捕获 + 所有权规则                         │
│  ├─ 迭代器 = 惰性管道 + 拉取模式 + 零成本抽象                       │
│  └─ 组合使用 = 强大、安全、高效的数据处理                            │
│                                                                    │
│  Dart 开发者备忘：                                                  │
│  ├─ Rust |x| x+1       ←→  Dart (x) => x + 1                     │
│  ├─ Rust .filter()      ←→  Dart .where()                         │
│  ├─ Rust .flat_map()    ←→  Dart .expand()                        │
│  ├─ Rust .collect()     ←→  Dart .toList()                        │
│  └─ Rust .fold()        ←→  Dart .fold()                          │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 下一章预告

在下一章中，我们将深入探讨 Rust 的**智能指针**——`Box<T>`、`Rc<T>`、`RefCell<T>` 和 `Arc<T>`。智能指针是 Rust 所有权系统的延伸，它们让你在保持内存安全的前提下实现更灵活的数据结构（如链表、树）和共享所有权模式。如果你在 Dart 中习惯了对象引用的自由传递，那么理解智能指针将帮助你在 Rust 中找到等价的解决方案。

[下一章：第 7 章 - 智能指针 -->](/rust/07-smart-pointers)
