# Flutter 桌面端适配

Flutter 支持编译为 Windows、macOS 和 Linux 桌面应用。本章介绍桌面平台的特性、开发技巧和最佳实践。

## 桌面平台概览

```
┌─────────────────────────────────────────────────────────────┐
│                  Flutter 桌面平台支持                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│   │   Windows   │  │    macOS    │  │    Linux    │        │
│   ├─────────────┤  ├─────────────┤  ├─────────────┤        │
│   │ • Win32 API │  │ • Cocoa     │  │ • GTK       │        │
│   │ • .exe      │  │ • .app      │  │ • .deb/.rpm │        │
│   │ • MSIX 打包  │  │ • .dmg 打包  │  │ • Snap/Flatpak │    │
│   └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 环境配置

### Windows 开发环境

```bash
# 检查 Flutter 桌面支持
flutter doctor

# 启用 Windows 支持
flutter config --enable-windows-desktop

# 需要安装 Visual Studio 2022
# 包含 "使用 C++ 的桌面开发" 工作负载
```

### macOS 开发环境

```bash
# 启用 macOS 支持
flutter config --enable-macos-desktop

# 需要安装 Xcode
xcode-select --install
```

### Linux 开发环境

```bash
# 启用 Linux 支持
flutter config --enable-linux-desktop

# 安装依赖 (Ubuntu/Debian)
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

# 安装依赖 (Fedora)
sudo dnf install clang cmake ninja-build gtk3-devel
```

## 创建桌面项目

```bash
# 创建支持桌面的项目
flutter create --platforms=windows,macos,linux my_desktop_app

# 为现有项目添加桌面支持
flutter create --platforms=windows .
flutter create --platforms=macos .
flutter create --platforms=linux .
```

## 平台检测

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformInfo {
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
  
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  static String get operatingSystem {
    if (kIsWeb) return 'web';
    return Platform.operatingSystem;
  }
  
  static String get operatingSystemVersion {
    if (kIsWeb) return 'unknown';
    return Platform.operatingSystemVersion;
  }
}

// 使用示例
void initPlatformFeatures() {
  if (PlatformInfo.isDesktop) {
    // 桌面特定初始化
    _initWindowSize();
    _initKeyboardShortcuts();
  }
}
```

## 窗口管理

### 使用 window_manager 插件

```yaml
# pubspec.yaml
dependencies:
  window_manager: ^0.3.8
```

```dart
import 'package:window_manager/window_manager.dart';

Future<void> initWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // 隐藏原生标题栏
    title: '我的桌面应用',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

// 在 main 函数中调用
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (PlatformInfo.isDesktop) {
    await initWindow();
  }
  
  runApp(const MyApp());
}
```

### 窗口操作

```dart
class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 最小化
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => windowManager.minimize(),
        ),
        // 最大化/还原
        IconButton(
          icon: const Icon(Icons.crop_square),
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        // 关闭
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}
```

### 自定义标题栏

```dart
class CustomTitleBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  
  const CustomTitleBar({
    super.key,
    required this.title,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          // 可拖动区域
          Expanded(
            child: DragToMoveArea(
              child: Row(
                children: [
                  if (leading != null) leading!,
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 窗口控制按钮
          const WindowControls(),
        ],
      ),
    );
  }
}

// DragToMoveArea 允许通过拖动来移动窗口
class DragToMoveArea extends StatelessWidget {
  final Widget child;
  
  const DragToMoveArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) => windowManager.startDragging(),
      onDoubleTap: () async {
        if (await windowManager.isMaximized()) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      },
      child: child,
    );
  }
}
```

## 键盘快捷键

### 使用 Shortcuts 和 Actions

```dart
class DesktopShortcuts extends StatelessWidget {
  final Widget child;
  
  const DesktopShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Ctrl+S 保存
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            const SaveIntent(),
        // Ctrl+Z 撤销
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            const UndoIntent(),
        // Ctrl+Shift+Z 重做
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            const RedoIntent(),
        // Ctrl+N 新建
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            const NewDocumentIntent(),
        // Ctrl+O 打开
        const SingleActivator(LogicalKeyboardKey.keyO, control: true):
            const OpenIntent(),
        // Ctrl+Q 退出
        const SingleActivator(LogicalKeyboardKey.keyQ, control: true):
            const QuitIntent(),
        // F11 全屏
        const SingleActivator(LogicalKeyboardKey.f11):
            const ToggleFullscreenIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (intent) => _handleSave(context),
          ),
          UndoIntent: CallbackAction<UndoIntent>(
            onInvoke: (intent) => _handleUndo(context),
          ),
          RedoIntent: CallbackAction<RedoIntent>(
            onInvoke: (intent) => _handleRedo(context),
          ),
          NewDocumentIntent: CallbackAction<NewDocumentIntent>(
            onInvoke: (intent) => _handleNew(context),
          ),
          OpenIntent: CallbackAction<OpenIntent>(
            onInvoke: (intent) => _handleOpen(context),
          ),
          QuitIntent: CallbackAction<QuitIntent>(
            onInvoke: (intent) => _handleQuit(context),
          ),
          ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
            onInvoke: (intent) => _handleFullscreen(context),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  void _handleSave(BuildContext context) {
    print('保存文件');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }

  void _handleUndo(BuildContext context) => print('撤销');
  void _handleRedo(BuildContext context) => print('重做');
  void _handleNew(BuildContext context) => print('新建文档');
  void _handleOpen(BuildContext context) => print('打开文件');
  
  void _handleQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出应用吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFullscreen(BuildContext context) async {
    if (await windowManager.isFullScreen()) {
      await windowManager.setFullScreen(false);
    } else {
      await windowManager.setFullScreen(true);
    }
  }
}

// 定义 Intent
class SaveIntent extends Intent {
  const SaveIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class NewDocumentIntent extends Intent {
  const NewDocumentIntent();
}

class OpenIntent extends Intent {
  const OpenIntent();
}

class QuitIntent extends Intent {
  const QuitIntent();
}

class ToggleFullscreenIntent extends Intent {
  const ToggleFullscreenIntent();
}
```

## 菜单栏

### 系统菜单栏 (macOS)

```dart
import 'package:flutter/services.dart';

void setupMacOSMenu() {
  if (!Platform.isMacOS) return;
  
  // 使用 PlatformMenuBar
}

class MacOSMenuBar extends StatelessWidget {
  final Widget child;
  
  const MacOSMenuBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: '文件',
          menus: [
            PlatformMenuItem(
              label: '新建',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyN, meta: true),
              onSelected: () => print('新建'),
            ),
            PlatformMenuItem(
              label: '打开',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
              onSelected: () => print('打开'),
            ),
            PlatformMenuItem(
              label: '保存',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
              onSelected: () => print('保存'),
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: '退出',
                  onSelected: null,
                ),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: '编辑',
          menus: [
            PlatformMenuItem(
              label: '撤销',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
              onSelected: () => print('撤销'),
            ),
            PlatformMenuItem(
              label: '重做',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true),
              onSelected: () => print('重做'),
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(label: '剪切', onSelected: null),
                PlatformMenuItem(label: '复制', onSelected: null),
                PlatformMenuItem(label: '粘贴', onSelected: null),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: '帮助',
          menus: [
            PlatformMenuItem(
              label: '关于',
              onSelected: () => _showAboutDialog(context),
            ),
          ],
        ),
      ],
      child: child,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '我的桌面应用',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 64),
      applicationLegalese: '© 2024 My Company',
    );
  }
}
```

## 文件系统访问

### 使用 file_picker

```yaml
dependencies:
  file_picker: ^6.1.1
  path_provider: ^2.1.2
```

```dart
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileService {
  /// 选择文件
  Future<File?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// 选择多个文件
  Future<List<File>> pickMultipleFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    
    if (result != null) {
      return result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();
    }
    return [];
  }

  /// 选择目录
  Future<Directory?> pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      return Directory(path);
    }
    return null;
  }

  /// 保存文件对话框
  Future<File?> saveFile({
    required String fileName,
    required List<int> bytes,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: '保存文件',
      fileName: fileName,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    
    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(bytes);
      return file;
    }
    return null;
  }

  /// 获取应用文档目录
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取临时目录
  Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }
}
```

## 系统托盘

### 使用 tray_manager

```yaml
dependencies:
  tray_manager: ^0.2.1
```

```dart
import 'package:tray_manager/tray_manager.dart';

class SystemTrayService with TrayListener {
  static final SystemTrayService _instance = SystemTrayService._internal();
  factory SystemTrayService() => _instance;
  SystemTrayService._internal();

  Future<void> init() async {
    trayManager.addListener(this);
    
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/icons/app_icon.ico'
          : 'assets/icons/app_icon.png',
    );
    
    await trayManager.setToolTip('我的桌面应用');
    
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: 'show',
            label: '显示窗口',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'settings',
            label: '设置',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit',
            label: '退出',
          ),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    // 点击托盘图标显示窗口
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    // 右键显示菜单
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
        break;
      case 'settings':
        // 打开设置
        break;
      case 'exit':
        windowManager.close();
        break;
    }
  }

  void dispose() {
    trayManager.removeListener(this);
    trayManager.destroy();
  }
}
```

## 拖放支持

### 接收拖放文件

```dart
import 'package:desktop_drop/desktop_drop.dart';

class DropZone extends StatefulWidget {
  final void Function(List<String> files) onFilesDropped;
  
  const DropZone({
    super.key,
    required this.onFilesDropped,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) {
        setState(() => _isDragging = true);
      },
      onDragExited: (details) {
        setState(() => _isDragging = false);
      },
      onDragDone: (details) {
        setState(() => _isDragging = false);
        final files = details.files.map((f) => f.path).toList();
        widget.onFilesDropped(files);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isDragging ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: _isDragging ? Colors.blue : Colors.grey,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: _isDragging ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _isDragging ? '释放以上传文件' : '拖放文件到此处',
                style: TextStyle(
                  color: _isDragging ? Colors.blue : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 多窗口支持

```dart
import 'package:window_manager/window_manager.dart';

class MultiWindowService {
  /// 打开新窗口
  static Future<void> openNewWindow({
    required String title,
    required Size size,
    String? route,
  }) async {
    // 注意：Flutter 原生不支持多窗口
    // 需要使用平台特定代码或第三方解决方案
    
    // 方案1：使用 Process 启动新实例
    if (Platform.isWindows) {
      await Process.start(
        Platform.resolvedExecutable,
        ['--route=$route'],
        mode: ProcessStartMode.detached,
      );
    }
    
    // 方案2：使用 desktop_multi_window 插件
    // https://pub.dev/packages/desktop_multi_window
  }
}
```

## 打包发布

### Windows 打包

```bash
# 构建 Windows 应用
flutter build windows --release

# 产物在 build/windows/x64/runner/Release/

# 使用 MSIX 打包
flutter pub run msix:create
```

**msix 配置 (pubspec.yaml)：**
```yaml
msix_config:
  display_name: 我的应用
  publisher_display_name: My Company
  identity_name: com.mycompany.myapp
  msix_version: 1.0.0.0
  logo_path: assets/icons/app_icon.png
```

### macOS 打包

```bash
# 构建 macOS 应用
flutter build macos --release

# 产物在 build/macos/Build/Products/Release/

# 创建 DMG 安装包
create-dmg build/macos/Build/Products/Release/MyApp.app
```

**macOS 权限配置 (macos/Runner/DebugProfile.entitlements)：**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

### Linux 打包

```bash
# 构建 Linux 应用
flutter build linux --release

# 产物在 build/linux/x64/release/bundle/

# 创建 Debian 包
dpkg-deb --build myapp_1.0.0_amd64

# 创建 AppImage
# 使用 appimagetool
```

## 常用桌面插件

| 插件 | 功能 | 平台 |
|------|------|------|
| window_manager | 窗口管理 | Win/Mac/Linux |
| tray_manager | 系统托盘 | Win/Mac/Linux |
| desktop_drop | 文件拖放 | Win/Mac/Linux |
| file_picker | 文件选择 | 全平台 |
| path_provider | 路径管理 | 全平台 |
| url_launcher | 打开 URL | 全平台 |
| local_notifier | 本地通知 | Win/Mac/Linux |
| screen_retriever | 屏幕信息 | Win/Mac/Linux |
| hotkey_manager | 全局热键 | Win/Mac/Linux |

## 注意事项

::: tip 最佳实践
1. **适配不同屏幕尺寸** - 使用响应式布局
2. **支持键盘操作** - 提供完整的快捷键支持
3. **提供原生体验** - 使用系统菜单、托盘图标等
4. **优化启动速度** - 减少启动时的初始化工作
5. **处理窗口状态** - 记住窗口位置和大小
:::

::: warning 注意事项
- 某些插件可能只支持特定桌面平台
- macOS 应用需要代码签名才能分发
- Windows 可能需要安装 Visual C++ 运行时
- Linux 需要处理不同发行版的兼容性
:::
