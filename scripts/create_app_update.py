#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

content = """# App 在线更新

App 在线更新是移动应用的核心功能之一，用于检测新版本并引导用户升级。本文详解 Flutter 中实现 App 更新的完整方案。

## 更新流程概览

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  启动检测   │ ──▶ │  版本比对   │ ──▶ │  下载安装   │ ──▶ │  重启应用   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │
      ▼                   ▼                   ▼
   后台接口            强制/可选           Android: APK
   返回版本            更新策略           iOS: App Store
```

## 依赖配置

```yaml
dependencies:
  # 获取应用信息
  package_info_plus: ^8.0.0
  # 网络请求
  dio: ^5.4.0
  # 文件路径
  path_provider: ^2.1.2
  # 打开文件/URL
  open_filex: ^4.4.0
  url_launcher: ^6.2.5
  # 权限管理
  permission_handler: ^11.3.0

# Android 需要安装未知来源应用权限
```

## 版本检测服务

### 服务端接口设计

```json
// GET /api/app/version?platform=android&current_version=1.0.0
{
  "code": 0,
  "data": {
    "has_update": true,
    "version": "2.0.0",
    "version_code": 20,
    "force_update": false,
    "min_support_version": "1.5.0",
    "download_url": "https://cdn.example.com/app-v2.0.0.apk",
    "app_store_url": "https://apps.apple.com/app/id123456789",
    "file_size": 45678901,
    "md5": "abc123def456...",
    "changelog": "1. 新增XX功能\\n2. 修复YY问题\\n3. 优化性能",
    "publish_time": "2024-01-15T10:00:00Z"
  }
}
```

### 版本信息模型

```dart
class AppVersionInfo {
  final bool hasUpdate;
  final String version;
  final int versionCode;
  final bool forceUpdate;
  final String? minSupportVersion;
  final String downloadUrl;
  final String? appStoreUrl;
  final int? fileSize;
  final String? md5;
  final String changelog;
  final DateTime? publishTime;

  AppVersionInfo({
    required this.hasUpdate,
    required this.version,
    required this.versionCode,
    required this.forceUpdate,
    this.minSupportVersion,
    required this.downloadUrl,
    this.appStoreUrl,
    this.fileSize,
    this.md5,
    required this.changelog,
    this.publishTime,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      hasUpdate: json['has_update'] ?? false,
      version: json['version'] ?? '',
      versionCode: json['version_code'] ?? 0,
      forceUpdate: json['force_update'] ?? false,
      minSupportVersion: json['min_support_version'],
      downloadUrl: json['download_url'] ?? '',
      appStoreUrl: json['app_store_url'],
      fileSize: json['file_size'],
      md5: json['md5'],
      changelog: json['changelog'] ?? '',
      publishTime: json['publish_time'] != null 
          ? DateTime.parse(json['publish_time']) 
          : null,
    );
  }

  /// 格式化文件大小
  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '\${fileSize}B';
    if (fileSize! < 1024 * 1024) return '\${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '\${(fileSize! / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}
```

### 版本检测服务

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._();
  factory AppUpdateService() => _instance;
  AppUpdateService._();

  final Dio _dio = Dio();
  
  /// 检查更新
  Future<AppVersionInfo?> checkUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final platform = Platform.isAndroid ? 'android' : 'ios';
      
      final response = await _dio.get(
        'https://api.example.com/app/version',
        queryParameters: {
          'platform': platform,
          'current_version': currentVersion,
        },
      );
      
      if (response.data['code'] == 0) {
        return AppVersionInfo.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('检查更新失败: \$e');
      return null;
    }
  }

  /// 比较版本号
  /// 返回: 1 表示 v1 > v2, -1 表示 v1 < v2, 0 表示相等
  int compareVersion(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
    
    for (int i = 0; i < maxLen; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }

  /// 判断是否需要强制更新
  bool needForceUpdate(AppVersionInfo info, String currentVersion) {
    if (info.forceUpdate) return true;
    
    // 如果当前版本低于最低支持版本，强制更新
    if (info.minSupportVersion != null) {
      return compareVersion(currentVersion, info.minSupportVersion!) < 0;
    }
    return false;
  }
}
```

## Android 更新实现

### 权限配置

**android/app/src/main/AndroidManifest.xml**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- 网络权限 -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- 存储权限（Android 10 以下） -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"/>
    
    <!-- 安装未知来源应用（Android 8.0+） -->
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
    
    <application
        android:requestLegacyExternalStorage="true"
        ...>
        
        <!-- FileProvider 配置 -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="\${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths"/>
        </provider>
        
    </application>
</manifest>
```

**android/app/src/main/res/xml/file_paths.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external" path="."/>
    <external-files-path name="external_files" path="."/>
    <cache-path name="cache" path="."/>
    <files-path name="files" path="."/>
</paths>
```

### 下载并安装 APK

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crypto/crypto.dart';

class AndroidUpdateManager {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  
  /// 下载进度回调
  Function(int received, int total)? onProgress;
  
  /// 下载状态回调
  Function(DownloadStatus status)? onStatusChanged;
  
  /// 下载 APK
  Future<String?> downloadApk(
    String url, {
    String? expectedMd5,
  }) async {
    try {
      onStatusChanged?.call(DownloadStatus.downloading);
      
      // 获取下载目录
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        onStatusChanged?.call(DownloadStatus.failed);
        return null;
      }
      
      final fileName = 'app_update_\${DateTime.now().millisecondsSinceEpoch}.apk';
      final savePath = '\${dir.path}/\$fileName';
      
      _cancelToken = CancelToken();
      
      await _dio.download(
        url,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total);
        },
      );
      
      // 验证 MD5
      if (expectedMd5 != null) {
        final file = File(savePath);
        final bytes = await file.readAsBytes();
        final digest = md5.convert(bytes);
        
        if (digest.toString() != expectedMd5.toLowerCase()) {
          await file.delete();
          onStatusChanged?.call(DownloadStatus.md5Error);
          return null;
        }
      }
      
      onStatusChanged?.call(DownloadStatus.completed);
      return savePath;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        onStatusChanged?.call(DownloadStatus.cancelled);
      } else {
        onStatusChanged?.call(DownloadStatus.failed);
      }
      return null;
    }
  }
  
  /// 取消下载
  void cancelDownload() {
    _cancelToken?.cancel();
  }
  
  /// 安装 APK
  Future<bool> installApk(String filePath) async {
    try {
      // 检查安装权限
      if (await Permission.requestInstallPackages.isDenied) {
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          // 引导用户开启权限
          await openAppSettings();
          return false;
        }
      }
      
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      print('安装失败: \$e');
      return false;
    }
  }
  
  /// 清理旧的安装包
  Future<void> cleanOldApks() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return;
      
      final files = dir.listSync();
      for (final file in files) {
        if (file.path.endsWith('.apk')) {
          await file.delete();
        }
      }
    } catch (e) {
      print('清理失败: \$e');
    }
  }
}

enum DownloadStatus {
  idle,
  downloading,
  completed,
  failed,
  cancelled,
  md5Error,
}
```

## iOS 更新实现

iOS 只能跳转到 App Store 更新：

```dart
import 'package:url_launcher/url_launcher.dart';

class IOSUpdateManager {
  /// 跳转到 App Store
  Future<bool> openAppStore(String appStoreUrl) async {
    final uri = Uri.parse(appStoreUrl);
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }
  
  /// 通过 App ID 跳转
  Future<bool> openAppStoreById(String appId) async {
    final url = 'https://apps.apple.com/app/id\$appId';
    return openAppStore(url);
  }
}
```

## 更新弹窗组件

### 基础更新弹窗

```dart
class UpdateDialog extends StatefulWidget {
  final AppVersionInfo versionInfo;
  final bool forceUpdate;
  final VoidCallback? onUpdate;
  final VoidCallback? onCancel;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    this.forceUpdate = false,
    this.onUpdate,
    this.onCancel,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.forceUpdate,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.system_update, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('发现新版本'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionRow(),
            SizedBox(height: 16),
            Text(
              '更新内容',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(
                  widget.versionInfo.changelog,
                  style: TextStyle(color: Colors.grey[600], height: 1.5),
                ),
              ),
            ),
            if (widget.versionInfo.fileSize != null) ...[
              SizedBox(height: 12),
              Text(
                '安装包大小: \${widget.versionInfo.fileSizeFormatted}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            if (widget.forceUpdate) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '当前版本过低，请更新后使用',
                        style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!widget.forceUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel?.call();
              },
              child: Text('稍后再说'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onUpdate?.call();
            },
            child: Text('立即更新'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('v\${widget.versionInfo.version}'),
          if (widget.versionInfo.publishTime != null) ...[
            SizedBox(width: 16),
            Text(
              _formatDate(widget.versionInfo.publishTime!),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}';
  }
}
```

### 下载进度弹窗

```dart
class DownloadProgressDialog extends StatefulWidget {
  final String downloadUrl;
  final String? md5;
  final Function(String filePath)? onDownloadComplete;

  const DownloadProgressDialog({
    super.key,
    required this.downloadUrl,
    this.md5,
    this.onDownloadComplete,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  final _updateManager = AndroidUpdateManager();
  double _progress = 0;
  String _statusText = '准备下载...';
  bool _isDownloading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    _updateManager.onProgress = (received, total) {
      if (mounted && total > 0) {
        setState(() {
          _progress = received / total;
          _statusText = '下载中 \${(received / 1024 / 1024).toStringAsFixed(1)}MB / \${(total / 1024 / 1024).toStringAsFixed(1)}MB';
        });
      }
    };

    _updateManager.onStatusChanged = (status) {
      if (!mounted) return;
      
      setState(() {
        switch (status) {
          case DownloadStatus.downloading:
            _statusText = '下载中...';
            break;
          case DownloadStatus.completed:
            _statusText = '下载完成';
            _isDownloading = false;
            break;
          case DownloadStatus.failed:
            _statusText = '下载失败，请重试';
            _isDownloading = false;
            _hasError = true;
            break;
          case DownloadStatus.cancelled:
            _statusText = '已取消';
            _isDownloading = false;
            break;
          case DownloadStatus.md5Error:
            _statusText = '文件校验失败，请重试';
            _isDownloading = false;
            _hasError = true;
            break;
          default:
            break;
        }
      });
    };

    final filePath = await _updateManager.downloadApk(
      widget.downloadUrl,
      expectedMd5: widget.md5,
    );

    if (filePath != null) {
      widget.onDownloadComplete?.call(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDownloading) {
          _updateManager.cancelDownload();
        }
        return true;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('下载更新'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                Text(
                  '\${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(_statusText),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          if (_hasError)
            TextButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isDownloading = true;
                  _progress = 0;
                });
                _startDownload();
              },
              child: Text('重试'),
            ),
          TextButton(
            onPressed: () {
              if (_isDownloading) {
                _updateManager.cancelDownload();
              }
              Navigator.of(context).pop();
            },
            child: Text(_isDownloading ? '取消' : '关闭'),
          ),
        ],
      ),
    );
  }
}
```

## 完整更新管理器

```dart
import 'dart:io';
import 'package:flutter/material.dart';

class AppUpdateManager {
  static final AppUpdateManager _instance = AppUpdateManager._();
  factory AppUpdateManager() => _instance;
  AppUpdateManager._();

  final _updateService = AppUpdateService();
  final _androidManager = AndroidUpdateManager();
  final _iosManager = IOSUpdateManager();

  /// 检查并提示更新
  Future<void> checkAndPromptUpdate(BuildContext context) async {
    final versionInfo = await _updateService.checkUpdate();
    
    if (versionInfo == null || !versionInfo.hasUpdate) {
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final forceUpdate = _updateService.needForceUpdate(
      versionInfo, 
      packageInfo.version,
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) => UpdateDialog(
        versionInfo: versionInfo,
        forceUpdate: forceUpdate,
        onUpdate: () => _handleUpdate(ctx, versionInfo),
        onCancel: () {
          // 记录用户跳过此版本
          _saveSkippedVersion(versionInfo.version);
        },
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context, AppVersionInfo info) async {
    if (Platform.isAndroid) {
      // Android: 下载并安装
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => DownloadProgressDialog(
          downloadUrl: info.downloadUrl,
          md5: info.md5,
          onDownloadComplete: (filePath) async {
            Navigator.of(ctx).pop();
            await _androidManager.installApk(filePath);
          },
        ),
      );
    } else if (Platform.isIOS) {
      // iOS: 跳转 App Store
      if (info.appStoreUrl != null) {
        await _iosManager.openAppStore(info.appStoreUrl!);
      }
    }
  }

  Future<void> _saveSkippedVersion(String version) async {
    // 保存跳过的版本，下次不再提示
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('skipped_version', version);
  }

  Future<bool> _isVersionSkipped(String version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('skipped_version') == version;
  }
}
```

## 使用示例

### 启动时检查

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 延迟检查，避免影响启动
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        AppUpdateManager().checkAndPromptUpdate(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
    );
  }
}
```

### 手动检查

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.system_update),
      title: Text('检查更新'),
      onTap: () async {
        // 显示加载
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(child: CircularProgressIndicator()),
        );

        final info = await AppUpdateService().checkUpdate();
        Navigator.of(context).pop();

        if (info?.hasUpdate == true) {
          AppUpdateManager().checkAndPromptUpdate(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已是最新版本')),
          );
        }
      },
    );
  }
}
```

## 增量更新（高级）

对于大型应用，可以考虑增量更新（差分更新）减少下载量：

```dart
/// 增量更新服务
class IncrementalUpdateService {
  /// 下载并应用差分包
  Future<String?> applyPatch(
    String patchUrl,
    String oldApkPath,
  ) async {
    // 1. 下载差分包
    final patchPath = await _downloadPatch(patchUrl);
    if (patchPath == null) return null;

    // 2. 合并生成新 APK（需要 Native 支持）
    final newApkPath = await _mergePatch(oldApkPath, patchPath);
    
    // 3. 清理差分包
    await File(patchPath).delete();
    
    return newApkPath;
  }

  Future<String?> _downloadPatch(String url) async {
    // 下载逻辑
    return null;
  }

  Future<String?> _mergePatch(String oldApk, String patch) async {
    // 需要使用 bsdiff/bspatch 算法
    // 通常通过 Platform Channel 调用 Native 代码实现
    return null;
  }
}
```

::: tip 增量更新方案
- [Google Play Core Library](https://developer.android.com/guide/playcore/in-app-updates) - Google 官方方案
- [bsdiff](http://www.daemonology.net/bsdiff/) - 二进制差分算法
- 国内应用市场 SDK（如华为、小米）也提供类似功能
:::

## 常用第三方插件

| 插件 | 说明 | 推荐 |
|------|------|------|
| [upgrader](https://pub.dev/packages/upgrader) | 自动检测 App Store/Play Store 更新 | ⭐⭐⭐⭐ |
| [in_app_update](https://pub.dev/packages/in_app_update) | Android 应用内更新（Play Store） | ⭐⭐⭐⭐ |
| [flutter_xupdate](https://pub.dev/packages/flutter_xupdate) | 完整的 Android 更新方案 | ⭐⭐⭐⭐⭐ |
| [r_upgrade](https://pub.dev/packages/r_upgrade) | 支持 Android 热更新 | ⭐⭐⭐ |

### 使用 flutter_xupdate

```yaml
dependencies:
  flutter_xupdate: ^4.0.0
```

```dart
import 'package:flutter_xupdate/flutter_xupdate.dart';

class XUpdateService {
  Future<void> init() async {
    await FlutterXUpdate.init(
      debug: true,
      isPost: false,
      isWifiOnly: false,
      isAutoMode: false,
      supportSilentInstall: false,
      enableRetry: false,
    );

    FlutterXUpdate.setErrorHandler(
      onUpdateError: (message) async {
        print('更新错误: \$message');
      },
    );
  }

  Future<void> checkUpdate() async {
    await FlutterXUpdate.checkUpdate(
      url: 'https://api.example.com/update.json',
      supportBackgroundUpdate: true,
    );
  }
}
```

## 最佳实践

::: warning 注意事项
1. **用户体验** - 非强制更新时，提供"跳过此版本"选项
2. **网络判断** - 大文件更新时提示用户使用 WiFi
3. **断点续传** - 大文件下载支持断点续传
4. **文件校验** - 下载后验证 MD5/SHA256
5. **权限引导** - Android 安装权限被拒时，友好引导用户开启
6. **回退机制** - 服务端保留旧版本，支持回滚
7. **灰度发布** - 按用户群体逐步推送更新
:::

## 相关链接

- [package_info_plus](https://pub.dev/packages/package_info_plus)
- [flutter_xupdate](https://pub.dev/packages/flutter_xupdate)
- [upgrader](https://pub.dev/packages/upgrader)
- [Android 应用内更新](https://developer.android.com/guide/playcore/in-app-updates)
"""

os.makedirs('/Users/ab/Desktop/go/flutter_tutorial/docs/modules/app-update', exist_ok=True)

with open('/Users/ab/Desktop/go/flutter_tutorial/docs/modules/app-update/index.md', 'w', encoding='utf-8') as f:
    f.write(content)

print('App update doc created!')
