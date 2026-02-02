# Apple 登录集成

Apple 登录（Sign in with Apple）是 iOS 应用的必备功能。如果你的应用提供了第三方社交登录（如 Google、Facebook），Apple 要求必须同时提供 Apple 登录选项。本章详解如何在 Flutter 中集成 Apple 登录。

## 概述

```
┌─────────────────────────────────────────────────────────────────┐
│                  Apple 登录流程                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│   │   用户   │───▶│  Flutter │───▶│  Apple   │───▶│   后端   │ │
│   │  点击    │    │   App    │    │  Server  │    │  验证    │ │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│                                                                 │
│   1. 点击登录按钮                                                │
│   2. 唤起 Apple 原生登录界面                                     │
│   3. 用户授权，返回凭证                                          │
│   4. 后端验证 Token，创建会话                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Apple 登录特点

| 特性 | 说明 |
|------|------|
| 隐私保护 | 用户可选择隐藏真实邮箱 |
| 安全性高 | 支持 Face ID / Touch ID |
| 跨平台 | iOS、macOS、Android、Web |
| 必须集成 | 有第三方登录时 iOS 强制要求 |

## 准备工作

### 前置条件

- ✅ 已付费的 Apple Developer 账号
- ✅ 在 Apple Developer Portal 注册了 Bundle ID
- ✅ iOS 13+ 真机或模拟器
- ✅ Xcode 已配置 Sign In with Apple Capability

### Apple Developer 后台配置

#### 1. 注册 App ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → 点击 **+**
4. 填写应用描述和 Bundle ID
5. 勾选 **Sign in with Apple**
6. 保存变更

#### 2. 创建 Service ID（Web/Android 需要）

如果需要支持 Web 端或 Android 端：

1. 进入 **Identifiers** → **Service IDs**
2. 注册一个唯一名称的服务
3. 勾选 **Sign in with Apple**
4. 配置重定向 URI（Redirect URIs）

## 安装配置

### 添加依赖

```yaml
# pubspec.yaml
dependencies:
  sign_in_with_apple: ^7.0.1
```

```bash
flutter pub get
```

### iOS 配置 (Xcode)

1. 打开 `ios/Runner.xcworkspace`
2. 选择项目 Target → **Signing & Capabilities**
3. 点击 **+ Capability**
4. 搜索并添加 **Sign in with Apple**

```xml
<!-- ios/Runner/Runner.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

### Android 配置

Android 需要通过 Web 重定向方式实现：

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity
    android:name="com.aboutyou.dart_packages.sign_in_with_apple.SignInWithAppleCallback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="signinwithapple" />
        <data android:path="callback" />
    </intent-filter>
</activity>
```

## 基础实现

### 简单登录

```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  /// 执行 Apple 登录
  Future<AuthorizationCredentialAppleID?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      print('用户ID: ${credential.userIdentifier}');
      print('邮箱: ${credential.email}');
      print('姓名: ${credential.givenName} ${credential.familyName}');
      print('授权码: ${credential.authorizationCode}');
      print('身份令牌: ${credential.identityToken}');
      
      return credential;
    } on SignInWithAppleAuthorizationException catch (e) {
      print('Apple 登录错误: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('未知错误: $e');
      return null;
    }
  }
  
  /// 检查是否可用
  Future<bool> isAvailable() async {
    return await SignInWithApple.isAvailable();
  }
}
```

### 登录按钮 UI

```dart
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  
  const AppleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SignInWithApple.isAvailable(),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }
        
        return SignInWithAppleButton(
          style: SignInWithAppleButtonStyle.black,
          type: SignInWithAppleButtonType.signIn,
          onPressed: () => _handleSignIn(context),
        );
      },
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // 发送凭证到后端验证
      await _verifyWithBackend(credential);
      
      onSuccess?.call();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // 用户取消登录
        return;
      }
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<void> _verifyWithBackend(AuthorizationCredentialAppleID credential) async {
    // 将凭证发送到后端验证
    // final response = await api.verifyAppleCredential(
    //   authorizationCode: credential.authorizationCode,
    //   identityToken: credential.identityToken,
    //   email: credential.email,
    //   fullName: '${credential.givenName} ${credential.familyName}',
    // );
  }
}
```

## 完整示例

### 登录页面

```dart
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const FlutterLogo(size: 100),
              const SizedBox(height: 48),
              
              // 标题
              Text(
                '欢迎回来',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '请选择登录方式',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              
              // Apple 登录按钮
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _buildAppleSignInButton(),
              
              const SizedBox(height: 16),
              
              // 其他登录方式
              OutlinedButton.icon(
                onPressed: () {
                  // Google 登录
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('使用 Google 登录'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleSignInButton() {
    return FutureBuilder<bool>(
      future: SignInWithApple.isAvailable(),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }
        
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: SignInWithAppleButton(
            style: SignInWithAppleButtonStyle.black,
            type: SignInWithAppleButtonType.signIn,
            onPressed: _handleAppleSignIn,
          ),
        );
      },
    );
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // 保存用户信息（仅首次登录返回）
      await _saveUserInfo(credential);
      
      // 后端验证
      final success = await _authenticateWithBackend(credential);
      
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        _showError('登录失败: ${e.message}');
      }
    } catch (e) {
      _showError('登录失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUserInfo(AuthorizationCredentialAppleID credential) async {
    // Apple 只在首次登录时返回邮箱和姓名
    // 必须立即保存！
    if (credential.email != null) {
      // 保存到本地或发送到后端
      // await prefs.setString('apple_email', credential.email!);
    }
    
    if (credential.givenName != null || credential.familyName != null) {
      final fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      // await prefs.setString('apple_name', fullName);
    }
  }

  Future<bool> _authenticateWithBackend(AuthorizationCredentialAppleID credential) async {
    // 发送到后端验证
    // final response = await authApi.appleSignIn(
    //   authorizationCode: credential.authorizationCode,
    //   identityToken: credential.identityToken,
    //   userIdentifier: credential.userIdentifier,
    // );
    // return response.success;
    return true;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

## 凭证详解

### 返回的凭证信息

```dart
class AppleCredentialInfo {
  /// 解析 Apple 返回的凭证
  static void parseCredential(AuthorizationCredentialAppleID credential) {
    // 用户唯一标识符（始终返回）
    final userIdentifier = credential.userIdentifier;
    
    // 授权码（用于后端换取 Token）
    final authorizationCode = credential.authorizationCode;
    
    // 身份令牌（JWT 格式，包含用户信息）
    final identityToken = credential.identityToken;
    
    // 邮箱（仅首次登录返回）
    final email = credential.email;
    
    // 姓名（仅首次登录返回）
    final givenName = credential.givenName;
    final familyName = credential.familyName;
    
    // 用户真实状态
    final state = credential.state;
  }
  
  /// 解析 Identity Token (JWT)
  static Map<String, dynamic>? parseIdentityToken(String? token) {
    if (token == null) return null;
    
    final parts = token.split('.');
    if (parts.length != 3) return null;
    
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    
    return json.decode(decoded) as Map<String, dynamic>;
  }
}
```

### 重要提醒

::: warning 邮箱和姓名只返回一次
Apple 出于隐私保护，**仅在用户首次授权时**返回邮箱和姓名。之后的登录只会返回 `userIdentifier`。

**务必在首次登录时保存这些信息！**
:::

```dart
class AppleUserStorage {
  static const _keyEmail = 'apple_user_email';
  static const _keyName = 'apple_user_name';
  static const _keyUserId = 'apple_user_id';
  
  final SharedPreferences _prefs;
  
  AppleUserStorage(this._prefs);
  
  /// 保存用户信息（首次登录时调用）
  Future<void> saveUserInfo(AuthorizationCredentialAppleID credential) async {
    await _prefs.setString(_keyUserId, credential.userIdentifier ?? '');
    
    // 只有首次登录时这些值才不为空
    if (credential.email != null) {
      await _prefs.setString(_keyEmail, credential.email!);
    }
    
    final name = _buildFullName(credential.givenName, credential.familyName);
    if (name.isNotEmpty) {
      await _prefs.setString(_keyName, name);
    }
  }
  
  /// 获取保存的用户信息
  AppleUserInfo? getUserInfo() {
    final userId = _prefs.getString(_keyUserId);
    if (userId == null || userId.isEmpty) return null;
    
    return AppleUserInfo(
      userId: userId,
      email: _prefs.getString(_keyEmail),
      name: _prefs.getString(_keyName),
    );
  }
  
  String _buildFullName(String? givenName, String? familyName) {
    return '${givenName ?? ''} ${familyName ?? ''}'.trim();
  }
}

class AppleUserInfo {
  final String userId;
  final String? email;
  final String? name;
  
  AppleUserInfo({required this.userId, this.email, this.name});
}
```

## 后端验证

### 为什么需要后端验证？

客户端获取的凭证可能被伪造，必须在服务器端验证：

1. 将 `authorizationCode` 发送到后端
2. 后端向 Apple 服务器换取 Access Token
3. 验证 `identityToken` 的签名
4. 创建或验证用户会话

### 后端验证流程（Node.js 示例）

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

// Apple 公钥客户端
const client = jwksClient({
  jwksUri: 'https://appleid.apple.com/auth/keys'
});

async function verifyAppleToken(identityToken) {
  // 解码 Token 头部获取 kid
  const decoded = jwt.decode(identityToken, { complete: true });
  const kid = decoded.header.kid;
  
  // 获取对应的公钥
  const key = await client.getSigningKey(kid);
  const publicKey = key.getPublicKey();
  
  // 验证 Token
  const verified = jwt.verify(identityToken, publicKey, {
    algorithms: ['RS256'],
    issuer: 'https://appleid.apple.com',
    audience: 'com.your.app.bundleid'
  });
  
  return verified;
}

// 使用 authorizationCode 换取 Token
async function exchangeCodeForToken(authorizationCode) {
  const response = await fetch('https://appleid.apple.com/auth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      client_id: 'com.your.app.bundleid',
      client_secret: generateClientSecret(), // 需要生成
      code: authorizationCode,
      grant_type: 'authorization_code'
    })
  });
  
  return response.json();
}
```

### Firebase 集成

如果使用 Firebase，验证过程会简化很多：

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAppleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signInWithApple() async {
    // 获取 Apple 凭证
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    
    // 创建 Firebase 凭证
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    
    // Firebase 登录
    final userCredential = await _auth.signInWithCredential(oauthCredential);
    
    // 更新用户显示名称（仅首次）
    if (appleCredential.givenName != null) {
      await userCredential.user?.updateDisplayName(
        '${appleCredential.givenName} ${appleCredential.familyName}'
      );
    }
    
    return userCredential.user;
  }
}
```

## 错误处理

```dart
class AppleSignInErrorHandler {
  static String getErrorMessage(SignInWithAppleAuthorizationException e) {
    switch (e.code) {
      case AuthorizationErrorCode.canceled:
        return '用户取消了登录';
      case AuthorizationErrorCode.failed:
        return '登录失败，请重试';
      case AuthorizationErrorCode.invalidResponse:
        return '无效的响应';
      case AuthorizationErrorCode.notHandled:
        return '请求未处理';
      case AuthorizationErrorCode.notInteractive:
        return '非交互式请求失败';
      case AuthorizationErrorCode.unknown:
      default:
        return '未知错误: ${e.message}';
    }
  }
}
```

## 最佳实践

::: tip 开发建议
1. **必须保存首次返回的信息** - 邮箱和姓名只返回一次
2. **服务器端验证** - 不要只在客户端验证 Token
3. **处理用户取消** - canceled 错误不需要显示提示
4. **真机测试** - 模拟器行为可能与真机不同
5. **提供备选方案** - 如果 Apple 登录不可用，显示其他选项
:::

::: warning 常见问题
- **付费账号要求**：必须使用付费的 Apple Developer 账号
- **Capability 配置**：确保在 Xcode 中正确添加了 Sign in with Apple
- **Bundle ID 匹配**：后端验证时 audience 必须与 Bundle ID 一致
- **非首次登录无邮箱**：这是 Apple 的设计，不是 Bug
:::

## 参考资源

- [sign_in_with_apple 官方文档](https://pub.dev/packages/sign_in_with_apple)
- [Apple Sign In 官方指南](https://developer.apple.com/sign-in-with-apple/)
- [Firebase Apple 登录](https://firebase.google.com/docs/auth/ios/apple)
