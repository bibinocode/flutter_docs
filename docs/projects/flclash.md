# FlClash - 跨平台代理客户端

## 项目概览

| 项目信息 | 详情 |
|---------|------|
| **GitHub** | [chen08209/FlClash](https://github.com/chen08209/FlClash) |
| **Star** | 15k+ |
| **平台** | Android, Windows, macOS, Linux |
| **状态管理** | Riverpod (with code generation) |
| **主要功能** | Clash.Meta 代理客户端 |

## 技术栈

### 核心技术
- **Flutter** + **Dart**
- **Go** (Clash.Meta 核心)
- **状态管理**: Riverpod + freezed
- **本地存储**: SharedPreferences
- **平台通道**: Method Channel (Kotlin/Swift)

### 依赖包
```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # 状态管理
  riverpod_annotation: ^2.3.5   # Riverpod 代码生成
  freezed_annotation: ^2.4.1    # 不可变模型
  dio: ^5.4.3                   # 网络请求
  window_manager: ^0.3.9        # 桌面窗口管理
  tray_manager: ^0.2.3          # 系统托盘
  protocol_handler: ^0.1.6      # URL Scheme
  
dev_dependencies:
  riverpod_generator: ^2.4.0    # Riverpod 生成器
  freezed: ^2.5.2               # Freezed 生成器
  build_runner: ^2.4.9          # 代码生成
```

## 项目结构

```
lib/
├── core/                       # 核心功能
│   ├── clash/                 # Clash 核心封装
│   ├── helper/                # 辅助类
│   └── plugin/                # 平台插件
├── manager/                    # 管理器
│   ├── core_manager.dart      # 核心管理
│   ├── vpn_manager.dart       # VPN 管理
│   ├── window_manager.dart    # 窗口管理
│   └── tray_manager.dart      # 托盘管理
├── models/                     # 数据模型
│   ├── profile.dart           # 配置模型
│   ├── config.dart            # 设置模型
│   └── proxy.dart             # 代理模型
├── pages/                      # 页面
│   ├── home/                  # 主页
│   ├── profiles/              # 配置管理
│   ├── proxies/               # 代理列表
│   ├── logs/                  # 日志页面
│   └── settings/              # 设置页面
├── plugins/                    # 平台插件
│   └── vpn/                   # VPN 插件
├── providers/                  # Riverpod Providers
│   ├── app_provider.dart      # 应用状态
│   ├── config_provider.dart   # 配置状态
│   └── proxy_provider.dart    # 代理状态
├── views/                      # 视图组件
│   └── widgets/               # 通用组件
└── main.dart                  # 入口文件
```

## 学习要点

### 1. Riverpod 代码生成

FlClash 使用 Riverpod 的代码生成模式，让状态管理更加类型安全：

```dart
// 使用 @riverpod 注解自动生成 Provider
@riverpod
class ProxyGroups extends _$ProxyGroups {
  @override
  List<ProxyGroup> build() => [];
  
  void update(List<ProxyGroup> groups) {
    state = groups;
  }
  
  void selectProxy(String groupName, String proxyName) {
    state = state.map((group) {
      if (group.name == groupName) {
        return group.copyWith(now: proxyName);
      }
      return group;
    }).toList();
  }
}

// 生成的代码会创建 proxyGroupsProvider
// 使用方式
final groups = ref.watch(proxyGroupsProvider);
ref.read(proxyGroupsProvider.notifier).selectProxy('Proxy', 'HK-01');
```

### 2. Freezed 不可变模型

```dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String label,
    required String url,
    @Default(0) int lastUpdate,
    @Default(Duration.zero) Duration autoUpdateDuration,
  }) = _Profile;
  
  factory Profile.fromJson(Map<String, dynamic> json) => 
      _$ProfileFromJson(json);
}

// 使用 copyWith 更新
final updated = profile.copyWith(label: 'New Name');
```

### 3. Manager 模式

FlClash 使用 Manager 模式封装核心功能：

```dart
class VpnManager {
  static VpnManager? _instance;
  static VpnManager get instance => _instance ??= VpnManager._();
  
  VpnManager._();
  
  bool _isRunning = false;
  bool get isRunning => _isRunning;
  
  Future<void> start() async {
    if (_isRunning) return;
    
    // 调用平台通道启动 VPN
    await _channel.invokeMethod('startVpn', {
      'fd': await _createTunFd(),
      'config': _generateConfig(),
    });
    
    _isRunning = true;
  }
  
  Future<void> stop() async {
    if (!_isRunning) return;
    await _channel.invokeMethod('stopVpn');
    _isRunning = false;
  }
}

// Core Manager - 管理 Clash 核心
class CoreManager {
  final _core = ClashCore();
  
  Future<void> init(String homeDir) async {
    await _core.init(homeDir);
  }
  
  Future<void> applyConfig(String path) async {
    await _core.setConfig(path);
  }
  
  Stream<Traffic> trafficStream() => _core.trafficStream();
}
```

### 4. 平台通道 (Kotlin)

```kotlin
// Android VPN Service
class VpnService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null
    
    fun start(config: VpnConfig): Int {
        val builder = Builder()
            .addAddress(config.address, config.prefixLength)
            .addDnsServer(config.dns)
            .addRoute("0.0.0.0", 0)
            .setSession("FlClash")
            .setMtu(config.mtu)
        
        config.allowedApps.forEach { app ->
            builder.addAllowedApplication(app)
        }
        
        vpnInterface = builder.establish()
        return vpnInterface?.fd ?: -1
    }
}
```

### 5. 状态持久化

```dart
@riverpod
class AppConfig extends _$AppConfig {
  @override
  Future<Config> build() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('config');
    if (json != null) {
      return Config.fromJson(jsonDecode(json));
    }
    return Config.defaultConfig();
  }
  
  Future<void> update(Config config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('config', jsonEncode(config.toJson()));
    state = AsyncData(config);
  }
}
```

### 6. 桌面端适配

```dart
class WindowManager {
  static Future<void> init() async {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(380, 700),
      minimumSize: Size(350, 500),
      center: true,
      title: 'FlClash',
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

// 系统托盘
class TrayManager {
  final _trayManager = tray.TrayManager.instance;
  
  Future<void> init() async {
    await _trayManager.setIcon('assets/icon.png');
    
    Menu menu = Menu(items: [
      MenuItem(key: 'show', label: '显示'),
      MenuItem.separator(),
      MenuItem(key: 'exit', label: '退出'),
    ]);
    
    await _trayManager.setContextMenu(menu);
    _trayManager.addListener(TrayListener());
  }
}
```

## 架构亮点

1. **Go 核心集成**: 复用成熟的 Clash.Meta 核心
2. **代码生成**: Riverpod + Freezed 减少样板代码
3. **Manager 模式**: 清晰的职责划分
4. **多平台 VPN**: Android VPN Service, macOS/Windows TUN
5. **系统托盘**: 完整的桌面端体验

## 适合学习

- Riverpod 高级用法和代码生成
- Flutter + Go 混合开发
- VPN 客户端开发
- 桌面端系统集成
- 平台通道深入使用

## 运行项目

```bash
# 克隆项目
git clone https://github.com/chen08209/FlClash.git
cd FlClash

# 生成代码
flutter pub get
dart run build_runner build

# Android 需要签名
# 桌面端可直接运行
flutter run -d macos
```

::: warning 注意事项
1. Android 版本需要配置签名
2. macOS 需要配置 Network Extension
3. Windows 需要管理员权限运行 TUN
:::

::: tip 学习建议
1. 先理解 Riverpod 代码生成模式
2. 研究 Clash 配置文件格式
3. 学习各平台 VPN 实现差异
:::
