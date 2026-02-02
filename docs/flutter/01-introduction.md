# Flutter 入门

<script setup>
import DartPad from '../.vitepress/components/DartPad.vue'
import FeatureCard from '../.vitepress/components/FeatureCard.vue'
</script>

## 什么是 Flutter？

Flutter 是 Google 开发的开源 UI 框架，用于从单一代码库构建跨平台应用。

<div class="feature-grid">
  <FeatureCard
    title="🚀 高性能"
    description="直接编译为原生代码，不需要 JavaScript 桥接"
  />
  <FeatureCard
    title="🎨 精美 UI"
    description="内置丰富的 Material 和 Cupertino 组件"
  />
  <FeatureCard
    title="⚡ 热重载"
    description="毫秒级的代码变更预览，提升开发效率"
  />
  <FeatureCard
    title="📱 跨平台"
    description="iOS、Android、Web、桌面端，一套代码全覆盖"
  />
</div>

<style>
.feature-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin: 24px 0;
}
@media (max-width: 640px) {
  .feature-grid {
    grid-template-columns: 1fr;
  }
}
</style>

## Flutter vs 其他跨平台方案

| 框架 | 渲染方式 | 开发语言 | 性能 | 学习曲线 |
|------|---------|---------|------|---------|
| **Flutter** | 自绘引擎 (Skia/Impeller) | Dart | ⭐⭐⭐⭐⭐ | 中等 |
| React Native | 原生组件桥接 | JavaScript | ⭐⭐⭐⭐ | 低（前端友好）|
| Uni-app | WebView + 原生 | Vue.js | ⭐⭐⭐ | 低 |
| 原生开发 | 平台原生 | Swift/Kotlin | ⭐⭐⭐⭐⭐ | 高 |

### 为什么选择 Flutter？

1. **一致的 UI 体验** - 自绘引擎确保在所有平台上外观一致
2. **出色的性能** - 60fps 流畅动画，无 JS 桥接开销
3. **丰富的生态** - pub.dev 上有超过 40,000+ 个包
4. **活跃的社区** - Google 官方支持，社区活跃
5. **企业级应用** - 阿里、腾讯、字节等大厂都在使用

## 开发环境搭建

### 1. 安装 Flutter SDK

::: code-group

```bash [macOS]
# 使用 Homebrew 安装
brew install --cask flutter

# 或手动下载
# https://docs.flutter.dev/get-started/install/macos
```

```bash [Windows]
# 使用 Chocolatey 安装
choco install flutter

# 或手动下载
# https://docs.flutter.dev/get-started/install/windows
```

```bash [Linux]
# 使用 Snap 安装
sudo snap install flutter --classic

# 或手动下载
# https://docs.flutter.dev/get-started/install/linux
```

:::

### 2. 配置环境变量

```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
export PATH="$PATH:[flutter 安装路径]/flutter/bin"

# 国内镜像（可选，加速下载）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

### 3. 检查安装状态

```bash
flutter doctor
```

你应该看到类似的输出：

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] VS Code (version x.x.x)
[✓] Connected device (2 available)
```

### 4. 安装 IDE 插件

推荐使用 VS Code 或 Android Studio：

**VS Code 插件：**
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets

## 创建第一个项目

```bash
# 创建新项目
flutter create my_first_app

# 进入项目目录
cd my_first_app

# 运行项目
flutter run
```

## 项目结构

```
my_first_app/
├── android/          # Android 原生代码
├── ios/              # iOS 原生代码
├── lib/              # Dart 代码（主要开发目录）
│   └── main.dart     # 应用入口文件
├── test/             # 测试文件
├── web/              # Web 平台配置
├── pubspec.yaml      # 项目配置和依赖
└── README.md
```

## Hello Flutter

让我们看看最简单的 Flutter 应用：

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello Flutter'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
```

### 代码解析

| 代码 | 说明 |
|------|------|
| `import 'package:flutter/material.dart'` | 导入 Material Design 组件库 |
| `runApp()` | 启动 Flutter 应用的入口函数 |
| `MaterialApp` | 应用的根 Widget，提供 Material Design 样式 |
| `Scaffold` | 页面脚手架，提供 AppBar、Body 等结构 |
| `AppBar` | 顶部导航栏 |
| `Center` | 居中布局 Widget |
| `Text` | 文本显示 Widget |

## Widget 的概念

在 Flutter 中，**一切皆 Widget**。Widget 是描述 UI 元素的不可变配置。

### Widget 的类型

```dart
// 1. StatelessWidget - 无状态组件
class MyText extends StatelessWidget {
  final String text;
  
  const MyText({super.key, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

// 2. StatefulWidget - 有状态组件
class MyCounter extends StatefulWidget {
  const MyCounter({super.key});
  
  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  int _count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
```

### 何时使用 StatefulWidget？

| 场景 | 推荐 |
|------|------|
| 只展示数据，不会变化 | StatelessWidget |
| 有用户交互，需要更新 UI | StatefulWidget |
| 需要监听动画、控制器 | StatefulWidget |
| 只接收父组件传递的数据 | StatelessWidget |

## 常用 Widget 一览

### 布局 Widget

```dart
// Row - 水平排列
Row(
  children: [Text('A'), Text('B'), Text('C')],
)

// Column - 垂直排列
Column(
  children: [Text('1'), Text('2'), Text('3')],
)

// Stack - 层叠布局
Stack(
  children: [
    Container(color: Colors.red),
    Positioned(top: 10, left: 10, child: Text('Overlay')),
  ],
)

// Container - 容器（类似 div）
Container(
  width: 100,
  height: 100,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Box'),
)
```

### 交互 Widget

```dart
// 按钮
ElevatedButton(onPressed: () {}, child: Text('Elevated'))
FilledButton(onPressed: () {}, child: Text('Filled'))
TextButton(onPressed: () {}, child: Text('Text'))
OutlinedButton(onPressed: () {}, child: Text('Outlined'))

// 输入框
TextField(
  decoration: InputDecoration(labelText: 'Username'),
  onChanged: (value) => print(value),
)

// 手势检测
GestureDetector(
  onTap: () => print('Tapped!'),
  child: Container(child: Text('Tap me')),
)
```

## 在线体验

下面是一个完整的计数器应用示例，你可以直接在浏览器中运行：

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My First App'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button:'),
            Text(
              '$_count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

::: tip 在线运行
你可以将上述代码复制到 [DartPad](https://dartpad.dev) 在线运行和修改。
:::

## 热重载

Flutter 最强大的特性之一是**热重载 (Hot Reload)**。

- **热重载 (`r`)** - 保持状态，只更新 UI
- **热重启 (`R`)** - 重启应用，状态重置

```bash
# 在终端中运行时
# 按 r 热重载
# 按 R 热重启
# 按 q 退出
```

::: tip 开发技巧
保存文件时 VS Code 会自动触发热重载，让你立即看到代码变更效果。
:::

## 下一步

现在你已经创建了第一个 Flutter 应用！接下来学习：

- [Widget 基础](/flutter/02-widgets) - 深入理解 Widget 机制
- [布局系统](/flutter/03-layout) - 掌握 Flutter 的布局方式
- [状态管理](/flutter/10-state-management) - 管理应用状态

::: info 学习资源
- [Flutter 官方文档](https://docs.flutter.dev)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
:::
