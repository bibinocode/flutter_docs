# LocalSend - 跨平台局域网文件传输

## 项目概览

| 项目信息 | 详情 |
|---------|------|
| **GitHub** | [localsend/localsend](https://github.com/localsend/localsend) |
| **Star** | 50k+ |
| **平台** | Android, iOS, macOS, Windows, Linux |
| **状态管理** | Refena (基于 Redux) |
| **主要功能** | 局域网文件传输、设备发现、Web共享 |

## 技术栈

### 核心技术
- **Flutter** + **Dart**
- **Rust** (FFI，用于高性能网络操作)
- **状态管理**: Refena (类 Redux 的状态管理)
- **本地存储**: SharedPreferences
- **国际化**: slang (类型安全的i18n)

### 依赖包
```yaml
dependencies:
  refena_flutter: ^1.0.0        # 状态管理
  routerino: ^0.0.6             # 路由管理
  dart_mappable: ^4.0.0         # JSON序列化
  bitsdojo_window: ^0.1.6       # 桌面窗口管理
  flutter_displaymode: ^0.6.0   # Android高刷新率
  share_handler: ^0.0.21        # 系统分享接入
  in_app_purchase: ^3.2.0       # 应用内购买
```

## 项目结构

```
app/
├── lib/
│   ├── config/                 # 配置相关
│   │   ├── init.dart          # 应用初始化
│   │   ├── refena.dart        # Refena配置
│   │   └── theme.dart         # 主题配置
│   ├── gen/                    # 生成文件
│   │   └── strings_*.g.dart   # 多语言文件
│   ├── model/                  # 数据模型
│   │   └── state/             # 状态模型
│   │       ├── network_state.dart
│   │       ├── purchase_state.dart
│   │       └── send/web/web_send_state.dart
│   ├── pages/                  # 页面
│   │   ├── home_page.dart     # 主页
│   │   ├── tabs/              # Tab页面
│   │   │   └── send_tab.dart
│   │   ├── web_send_page.dart # Web发送页
│   │   ├── language_page.dart # 语言设置
│   │   ├── donation/          # 捐赠页面
│   │   ├── about/             # 关于页面
│   │   └── debug/             # 调试页面
│   ├── provider/               # 状态提供者
│   │   ├── settings_provider.dart
│   │   ├── purchase_provider.dart
│   │   └── persistence_provider.dart
│   ├── util/                   # 工具类
│   │   └── native/
│   │       └── file_picker.dart
│   ├── widget/                 # 公共组件
│   │   ├── watcher/
│   │   │   ├── life_cycle_watcher.dart
│   │   │   ├── tray_watcher.dart
│   │   │   └── window_watcher.dart
│   │   └── rotating_widget.dart
│   └── main.dart              # 入口文件
├── common/                     # 共享代码包
│   └── lib/src/isolate/       # Isolate通信
├── rust_builder/              # Rust FFI代码
└── assets/                    # 资源文件
```

## 学习要点

### 1. Refena 状态管理

Refena 是一个类似 Redux 的状态管理库，具有强类型和可追踪性：

```dart
// 定义 Provider
final settingsProvider = ReduxProvider<SettingsService, SettingsState>((ref) {
  return SettingsService();
});

// 定义 Notifier
class SettingsService extends ReduxNotifier<SettingsState> {
  @override
  SettingsState init() => SettingsState.initial();
}

// 定义 Action
class ChangeThemeAction extends ReduxAction<SettingsService, SettingsState> {
  final ThemeMode theme;
  ChangeThemeAction(this.theme);
  
  @override
  SettingsState reduce() {
    return state.copyWith(theme: theme);
  }
}

// 使用
class MyWidget extends StatelessWidget with Refena {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    return ElevatedButton(
      onPressed: () {
        ref.redux(settingsProvider).dispatch(ChangeThemeAction(ThemeMode.dark));
      },
      child: Text('Change Theme'),
    );
  }
}
```

### 2. 生命周期监听

```dart
class LifeCycleWatcher extends StatefulWidget {
  final Widget child;
  final void Function(AppLifecycleState state) onChangedState;
  
  const LifeCycleWatcher({
    required this.child, 
    required this.onChangedState
  });

  @override
  State<LifeCycleWatcher> createState() => _LifeCycleWatcherState();
}

class _LifeCycleWatcherState extends State<LifeCycleWatcher> 
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.onChangedState(state);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

### 3. 多平台适配

```dart
// 平台检测
if (Platform.isAndroid) {
  // Android特定代码
} else if (Platform.isIOS) {
  // iOS特定代码
} else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
  // 桌面端代码
}

// 桌面窗口管理 (bitsdojo_window)
doWhenWindowReady(() {
  final win = appWindow;
  win.minSize = const Size(400, 450);
  win.size = const Size(500, 600);
  win.alignment = Alignment.center;
  win.show();
});
```

### 4. 类型安全的国际化

使用 slang 进行类型安全的多语言支持：

```dart
// 生成的代码
class TranslationsEn {
  String get appName => 'LocalSend';
  late final _TranslationsGeneralEn general = _TranslationsGeneralEn._(_root);
  // ...
}

// 使用
Text(t.general.send);
Text(t.receiveTab.title);
```

### 5. Rust FFI 集成

通过 flutter_rust_bridge 实现高性能网络操作：

```dart
// Dart 端调用 Rust 函数
final result = await api.encryptFile(path: filePath, key: secretKey);
```

### 6. 数据持久化迁移

```dart
const _latestVersion = 2;

Future<void> _runMigrations(int from) async {
  switch (from) {
    case 1:
      await _migrate2();
      await SharedPreferencesStorePlatform.instance
          .setValue('Int', 'flutter.$_version', 2);
      break;
  }
}

Future<void> _migrate2() async {
  _logger.info('Migrating to version 2');
  // 迁移逻辑
}
```

## 架构亮点

1. **模块化设计**: common 包独立，可复用
2. **Isolate 通信**: 利用 Isolate 进行后台网络发现
3. **多语言支持**: 支持 50+ 种语言
4. **跨平台一致性**: 统一的 API 抽象
5. **FOSS 友好**: 支持纯开源版本构建

## 适合学习

- 跨平台桌面/移动应用开发
- Redux 风格状态管理
- Rust FFI 集成
- 局域网通信协议
- 多语言国际化最佳实践
- 应用内购买集成

## 运行项目

```bash
# 克隆项目
git clone https://github.com/localsend/localsend.git
cd localsend

# 安装依赖
cd app
flutter pub get

# 安装 Rust (需要)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 运行
flutter run
```

::: tip 学习建议
1. 先了解 Refena 状态管理模式
2. 研究网络发现和文件传输协议
3. 学习多平台适配技巧
:::
