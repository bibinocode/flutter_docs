# 生物识别

生物识别（Biometrics）是移动应用中常见的身份验证方式，包括指纹识别（Touch ID / Fingerprint）和面容识别（Face ID / Face Unlock）。本章介绍如何使用 `local_auth` 包在 Flutter 中实现生物识别认证。

## 概述

### 为什么使用生物识别？

| 优势 | 说明 |
|------|------|
| 🔒 **安全性高** | 生物特征独一无二，难以伪造 |
| ⚡ **便捷快速** | 一触即验，无需记忆密码 |
| 🎯 **用户体验** | 减少输入，提升使用流畅度 |
| 🛡️ **二次验证** | 可作为敏感操作的额外保护 |

### 应用场景

- 🔓 **应用解锁** - 替代 PIN 码或图案
- 💳 **支付确认** - 移动支付二次验证
- 🔐 **敏感操作** - 查看隐私数据、修改密码
- 📱 **自动登录** - 配合 Keychain/Keystore 实现免密登录
- 🗄️ **数据保护** - 访问加密文件或笔记

## 安装配置

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  local_auth: ^2.2.0
```

```bash
flutter pub get
```

### Android 配置

#### 1. 添加权限

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- 生物识别权限 -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <!-- 兼容旧版指纹 API (Android 6-9) -->
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

#### 2. 配置 MainActivity

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
package com.example.your_app

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    // 使用 FlutterFragmentActivity 而非 FlutterActivity
    // 这是 local_auth 在 Android 上正常工作的必要条件
}
```

::: warning 重要
必须将 `FlutterActivity` 改为 `FlutterFragmentActivity`，否则生物识别对话框无法正常显示。
:::

### iOS 配置

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- 面容识别使用说明 -->
    <key>NSFaceIDUsageDescription</key>
    <string>需要使用面容识别来验证您的身份</string>
</dict>
```

## 基础使用

### 初始化与能力检测

```dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// 检查设备是否支持生物识别
  Future<bool> isDeviceSupported() async {
    return await _auth.isDeviceSupported();
  }

  /// 检查是否可以进行生物识别认证
  /// (设备支持 + 用户已注册生物特征)
  Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics;
  }

  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }
  
  /// 获取生物识别类型的描述
  String getBiometricTypeDescription(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return '面容识别';
      case BiometricType.fingerprint:
        return '指纹识别';
      case BiometricType.iris:
        return '虹膜识别';
      case BiometricType.strong:
        return '强生物识别';
      case BiometricType.weak:
        return '弱生物识别';
    }
  }
}
```

### 执行生物识别认证

```dart
class BiometricService {
  // ... 前面的代码 ...

  /// 执行生物识别认证
  Future<BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      // 先检查能力
      final canAuth = await canCheckBiometrics();
      final isSupported = await isDeviceSupported();
      
      if (!canAuth || !isSupported) {
        return BiometricResult(
          success: false,
          error: BiometricError.notAvailable,
          message: '设备不支持生物识别或未设置',
        );
      }

      // 执行认证
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,         // App 切到后台后保持认证状态
          biometricOnly: biometricOnly,  // 是否仅允许生物识别（不允许 PIN）
          sensitiveTransaction: true,    // 标记为敏感操作
          useErrorDialogs: true,         // 使用系统错误对话框
        ),
      );

      return BiometricResult(
        success: authenticated,
        error: authenticated ? null : BiometricError.failed,
        message: authenticated ? '认证成功' : '认证失败',
      );
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    }
  }

  /// 处理平台异常
  BiometricResult _handlePlatformException(PlatformException e) {
    BiometricError error;
    String message;

    switch (e.code) {
      case 'NotAvailable':
        error = BiometricError.notAvailable;
        message = '生物识别不可用';
        break;
      case 'NotEnrolled':
        error = BiometricError.notEnrolled;
        message = '未注册生物特征，请先在系统设置中添加';
        break;
      case 'LockedOut':
        error = BiometricError.lockedOut;
        message = '尝试次数过多，请稍后再试';
        break;
      case 'PermanentlyLockedOut':
        error = BiometricError.permanentlyLockedOut;
        message = '生物识别已被锁定，请使用密码解锁';
        break;
      case 'PasscodeNotSet':
        error = BiometricError.passcodeNotSet;
        message = '设备未设置密码';
        break;
      default:
        error = BiometricError.unknown;
        message = e.message ?? '认证失败';
    }

    return BiometricResult(
      success: false,
      error: error,
      message: message,
    );
  }

  /// 取消认证
  Future<void> cancelAuthentication() async {
    await _auth.stopAuthentication();
  }
}

/// 生物识别结果
class BiometricResult {
  final bool success;
  final BiometricError? error;
  final String message;

  BiometricResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// 生物识别错误类型
enum BiometricError {
  notAvailable,       // 设备不支持
  notEnrolled,        // 未注册生物特征
  lockedOut,          // 临时锁定
  permanentlyLockedOut, // 永久锁定
  passcodeNotSet,     // 未设置密码
  failed,             // 认证失败
  unknown,            // 未知错误
}
```

## 完整示例

### 生物识别登录页面

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});

  @override
  State<BiometricLoginPage> createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  final _biometricService = BiometricService();
  
  bool _isLoading = false;
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    final isSupported = await _biometricService.isDeviceSupported();
    final available = await _biometricService.getAvailableBiometrics();

    setState(() {
      _biometricAvailable = canCheck && isSupported;
      _availableBiometrics = available;
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    final result = await _biometricService.authenticate(
      reason: '请验证身份以登录应用',
    );

    setState(() {
      _isLoading = false;
      _statusMessage = result.message;
    });

    if (result.success) {
      // 认证成功，跳转到主页
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // 处理错误
      _handleAuthError(result.error);
    }
  }

  void _handleAuthError(BiometricError? error) {
    if (error == null) return;

    switch (error) {
      case BiometricError.notEnrolled:
        _showEnrollmentDialog();
        break;
      case BiometricError.lockedOut:
        _showLockedOutDialog(temporary: true);
        break;
      case BiometricError.permanentlyLockedOut:
        _showLockedOutDialog(temporary: false);
        break;
      case BiometricError.passcodeNotSet:
        _showPasscodeRequiredDialog();
        break;
      default:
        // 显示通用错误提示
        break;
    }
  }

  void _showEnrollmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未设置生物识别'),
        content: const Text('请先在系统设置中添加指纹或面容'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 可以引导用户去系统设置
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  void _showLockedOutDialog({required bool temporary}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(temporary ? '暂时锁定' : '已被锁定'),
        content: Text(
          temporary
              ? '尝试次数过多，请稍后再试'
              : '生物识别已被锁定，请使用设备密码解锁后重试',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPasscodeRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要设备密码'),
        content: const Text('请先为设备设置密码，才能使用生物识别'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              
              // 标题
              const Text(
                '欢迎回来',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '使用生物识别快速登录',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              
              // 可用的生物识别类型
              if (_availableBiometrics.isNotEmpty)
                Wrap(
                  spacing: 16,
                  children: _availableBiometrics.map((type) {
                    return Chip(
                      avatar: Icon(
                        _getBiometricIcon(type),
                        size: 18,
                      ),
                      label: Text(_biometricService.getBiometricTypeDescription(type)),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              
              // 认证按钮
              if (_biometricAvailable)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _authenticate,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(_isLoading ? '验证中...' : '生物识别登录'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                const Text(
                  '此设备不支持生物识别',
                  style: TextStyle(color: Colors.red),
                ),
              
              const SizedBox(height: 16),
              
              // 状态消息
              if (_statusMessage.isNotEmpty)
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('成功')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // 备用登录方式
              TextButton(
                onPressed: () {
                  // 跳转到密码登录页
                },
                child: const Text('使用密码登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      default:
        return Icons.security;
    }
  }
}
```

### 敏感操作二次验证

```dart
class SecureActionWidget extends StatelessWidget {
  final Widget child;
  final String reason;
  final VoidCallback onAuthenticated;
  final VoidCallback? onFailed;

  const SecureActionWidget({
    super.key,
    required this.child,
    required this.reason,
    required this.onAuthenticated,
    this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _performSecureAction(context),
      child: child,
    );
  }

  Future<void> _performSecureAction(BuildContext context) async {
    final biometricService = BiometricService();
    
    final result = await biometricService.authenticate(
      reason: reason,
      biometricOnly: true,  // 仅允许生物识别
    );

    if (result.success) {
      onAuthenticated();
    } else {
      onFailed?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    }
  }
}

// 使用示例
SecureActionWidget(
  reason: '请验证身份以查看银行卡信息',
  onAuthenticated: () {
    // 显示敏感信息
    _showBankCardDetails();
  },
  child: const ListTile(
    leading: Icon(Icons.credit_card),
    title: Text('银行卡信息'),
    subtitle: Text('点击验证后查看'),
    trailing: Icon(Icons.lock),
  ),
)
```

## 与安全存储结合

### 配合 flutter_secure_storage 实现免密登录

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureAuthService {
  final _biometricService = BiometricService();
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _tokenKey = 'auth_token';
  static const _biometricEnabledKey = 'biometric_enabled';

  /// 启用生物识别登录
  Future<bool> enableBiometricLogin(String token) async {
    // 先验证一次生物识别
    final result = await _biometricService.authenticate(
      reason: '验证身份以启用生物识别登录',
    );

    if (result.success) {
      // 安全存储 token
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      return true;
    }
    return false;
  }

  /// 禁用生物识别登录
  Future<void> disableBiometricLogin() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
  }

  /// 检查是否启用了生物识别登录
  Future<bool> isBiometricLoginEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  /// 使用生物识别登录
  Future<String?> biometricLogin() async {
    final enabled = await isBiometricLoginEnabled();
    if (!enabled) return null;

    final result = await _biometricService.authenticate(
      reason: '验证身份以登录',
    );

    if (result.success) {
      // 获取存储的 token
      return await _secureStorage.read(key: _tokenKey);
    }
    return null;
  }
}
```

## 平台差异

### iOS 特性

| 特性 | 说明 |
|------|------|
| **Face ID** | iPhone X 及以上支持 |
| **Touch ID** | iPhone 5s - iPhone 8/SE 支持 |
| **Keychain 集成** | 可配合 Keychain 安全存储 |
| **Fallback** | 系统自动提供密码作为备选 |

### Android 特性

| 特性 | 说明 |
|------|------|
| **BiometricPrompt** | Android 9+ 统一 API |
| **指纹** | 大多数设备支持 |
| **面容** | 部分高端设备支持 |
| **虹膜** | 极少数设备支持（如三星部分机型） |
| **强/弱识别** | Android 11+ 区分安全等级 |

```dart
// 检查具体支持的类型
Future<void> checkBiometricTypes() async {
  final types = await BiometricService().getAvailableBiometrics();
  
  for (final type in types) {
    switch (type) {
      case BiometricType.face:
        print('支持面容识别 (Face ID/Face Unlock)');
        break;
      case BiometricType.fingerprint:
        print('支持指纹识别 (Touch ID/Fingerprint)');
        break;
      case BiometricType.iris:
        print('支持虹膜识别');
        break;
      case BiometricType.strong:
        print('支持强生物识别 (满足 Android Class 3)');
        break;
      case BiometricType.weak:
        print('支持弱生物识别 (满足 Android Class 2)');
        break;
    }
  }
}
```

## 最佳实践

::: tip 开发建议
1. **提供备选方案** - 始终提供 PIN 或密码作为备选
2. **优雅降级** - 设备不支持时要有替代方案
3. **明确说明** - 告诉用户为什么需要验证
4. **减少打扰** - 不要过于频繁地请求验证
5. **安全存储** - 敏感数据配合安全存储使用
:::

::: warning 安全注意
- 生物识别只是身份验证的一种方式，不能替代加密
- 不要仅依赖生物识别保护高度敏感数据
- 配合 Token 有效期管理，定期要求重新验证
- 考虑 `biometricOnly: false` 允许 PIN 作为后备
:::

## 常见问题

### Q: Android 上弹不出认证对话框？

确保 `MainActivity` 继承自 `FlutterFragmentActivity`：

```kotlin
class MainActivity: FlutterFragmentActivity() {
    // 不是 FlutterActivity
}
```

### Q: iOS 上没有 Face ID 提示？

确保在 `Info.plist` 中添加了 `NSFaceIDUsageDescription`。

### Q: 如何处理用户取消认证？

用户取消时 `authenticate()` 返回 `false`，但不会抛出异常：

```dart
final result = await _auth.authenticate(localizedReason: '...');
if (!result) {
  // 用户取消或认证失败
}
```

### Q: stickyAuth 有什么作用？

`stickyAuth: true` 表示当 App 切到后台时保持认证状态。如果设为 `false`，切换 App 后返回需要重新认证。

## 参考资源

- [local_auth 官方文档](https://pub.dev/packages/local_auth)
- [Apple Face ID 设计指南](https://developer.apple.com/design/human-interface-guidelines/face-id)
- [Android BiometricPrompt](https://developer.android.com/training/sign-in/biometric-auth)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
