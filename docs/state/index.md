# 状态管理

状态管理是 Flutter 开发中最核心的概念之一。本模块将深入讲解各种状态管理方案的原理、使用方法和最佳实践。

## 为什么需要状态管理？

在构建 Flutter 应用时，我们会面临一个根本性的问题：**数据如何在 Widget 之间流动和共享？**

考虑一个简单的场景：用户在设置页面切换了深色模式，整个 App 的所有页面都需要立即响应这个变化。如果没有合适的状态管理方案，你可能需要：

1. 在每个页面手动传递主题数据
2. 使用某种全局变量（很危险）
3. 通过回调函数层层传递（回调地狱）

状态管理就是为了优雅地解决这类问题而存在的。

## 什么是"状态"？

在 Flutter 中，**状态（State）是指在应用运行期间可能发生变化的数据**。根据作用范围，我们可以把状态分为两类：

### 临时状态（Ephemeral State）

也叫 **局部状态** 或 **UI 状态**，指只在单个 Widget 内部使用的状态。

```dart
// 示例：PageView 的当前页面索引
class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;  // 临时状态：只有这个 Widget 关心

  @override
  Widget build(BuildContext context) {
    return PageView(
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: [...],
    );
  }
}
```

**临时状态的特点：**
- 只在一个 Widget 内部使用
- 不需要被其他 Widget 访问
- 用户离开页面后可以丢失
- 使用 `setState()` 管理即可

**常见例子：**
- 表单输入的当前值
- 动画的当前进度
- PageView/TabBar 的当前选中项
- 一个列表项是否被展开

### 应用状态（App State）

也叫 **共享状态** 或 **全局状态**，指多个 Widget 需要共享的状态。

```dart
// 示例：用户登录信息（多个页面都需要）
class UserInfo {
  final String id;
  final String name;
  final String avatar;
  final bool isVip;
  
  UserInfo({required this.id, required this.name, required this.avatar, this.isVip = false});
}

// 这个数据需要在以下地方使用：
// - 首页顶部的用户头像
// - 个人中心页面
// - 设置页面
// - 评论区的用户标识
// - VIP 专属功能的权限判断
// - ...
```

**应用状态的特点：**
- 需要在多个 Widget 间共享
- 需要在多个页面间保持
- 可能需要持久化存储
- 需要专门的状态管理方案

**常见例子：**
- 用户登录信息
- 购物车数据
- 通知/消息列表
- App 主题设置
- 多语言设置
- 已读/未读状态

## 如何选择状态类型？

这里有一个简单的判断流程：

```
这个状态需要被其他 Widget 使用吗？
    │
    ├── 否 → 临时状态，使用 setState
    │
    └── 是 → 应用状态，需要状态管理方案
                │
                ├── 只是父子 Widget 间传递？ → Provider / InheritedWidget
                │
                ├── 需要跨越多层 Widget？ → Provider / Riverpod / GetX
                │
                └── 复杂业务逻辑、大型团队？ → Bloc / Riverpod
```

## 状态管理的核心问题

所有状态管理方案都在解决以下几个核心问题：

### 1. 状态存储在哪里？

```dart
// 方案 A：存在 Widget 内部
class _MyState extends State<MyWidget> {
  int count = 0;  // 状态和 UI 耦合
}

// 方案 B：存在独立的类中
class CounterStore {
  int count = 0;  // 状态与 UI 分离
}
```

### 2. 状态如何传递给 Widget？

```dart
// 方案 A：构造函数传递（Prop Drilling）
class GrandChild extends StatelessWidget {
  final int count;  // 需要一层层传下来
  GrandChild({required this.count});
}

// 方案 B：通过某种机制"注入"
class GrandChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterStore>().count;  // 直接获取
  }
}
```

### 3. 状态变化时如何通知 Widget 更新？

```dart
// 方案 A：手动调用 setState
void increment() {
  setState(() {
    count++;
  });
}

// 方案 B：自动通知（响应式）
void increment() {
  count++;  // 自动触发依赖这个值的 Widget 重建
}
```

### 4. 如何控制更新范围？

```dart
// 问题：父 Widget 更新会导致所有子 Widget 重建
class Parent extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count'),      // 只有这个需要更新
        ExpensiveWidget(),   // 不需要更新，但也会重建！
        AnotherWidget(),     // 不需要更新，但也会重建！
      ],
    );
  }
}

// 解决：精确控制更新范围
class Parent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<Counter>(   // 只有 Consumer 内部会更新
          builder: (_, counter, __) => Text('${counter.count}'),
        ),
        ExpensiveWidget(),   // 不会重建
        AnotherWidget(),     // 不会重建
      ],
    );
  }
}
```

## 本模块内容

本模块将详细讲解以下状态管理方案：

| 章节 | 内容 | 难度 | 适用场景 |
|-----|------|-----|---------|
| [setState 详解](./01-setstate) | Flutter 内置方案 | ⭐ | 临时状态、小型应用 |
| [Provider 详解](./02-provider) | 官方推荐入门方案 | ⭐⭐ | 中小型应用 |
| [Riverpod 详解](./03-riverpod) | Provider 进化版 | ⭐⭐⭐ | 中大型应用 |
| [GetX 详解](./04-getx) | 轻量级全家桶 | ⭐⭐ | 快速开发 |
| [Bloc 详解](./05-bloc) | 企业级方案 | ⭐⭐⭐⭐ | 大型应用、团队协作 |
| [方案对比与选择](./06-comparison) | 综合对比分析 | - | 技术选型参考 |

## 学习建议

1. **先掌握 setState**：理解 Flutter 的重建机制是理解所有状态管理方案的基础
2. **从 Provider 入手**：语法简单，概念清晰，是学习其他方案的桥梁
3. **根据项目选择**：没有"最好"的方案，只有"最适合"的方案
4. **动手实践**：每种方案都用一个小项目练习，感受它们的差异

## 下一步

让我们从最基础的 [setState 详解](./01-setstate) 开始，深入理解 Flutter 的状态更新机制。
