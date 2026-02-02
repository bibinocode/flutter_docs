#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

content = """# 微信登录与分享

Flutter 中集成微信登录和分享功能，同样使用 fluwx 插件。本章介绍微信授权登录和内容分享的完整实现。

## 安装与配置

配置与[微信支付](./wechatpay)相同，请参考该章节完成基础配置。

## 微信登录

### 初始化

```dart
import 'package:fluwx/fluwx.dart';

class WechatAuthService {
  static final Fluwx _fluwx = Fluwx();
  
  /// 初始化微信 SDK
  static Future<void> init() async {
    await _fluwx.registerApi(
      appId: 'wx你的AppID',
      universalLink: 'https://你的域名/app/',
    );
  }
  
  /// 检查微信是否安装
  static Future<bool> isInstalled() async {
    return await _fluwx.isWeChatInstalled;
  }
}
```

### 发起授权登录

```dart
class WechatAuthService {
  static final Fluwx _fluwx = Fluwx();
  
  /// 发起微信授权登录
  static Future<bool> login({String? state}) async {
    return await _fluwx.authBy(
      which: NormalAuth(
        scope: 'snsapi_userinfo',
        state: state ?? 'flutter_wechat_login',
      ),
    );
  }
}
```

### 监听授权结果

```dart
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Fluwx _fluwx = Fluwx();
  StreamSubscription? _authSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listenAuthResult();
  }
  
  void _listenAuthResult() {
    _authSubscription = _fluwx.authEventStream.listen((response) async {
      if (response.errCode == 0 && response.code != null) {
        // 授权成功，获取到 code
        await _handleAuthCode(response.code!);
      } else if (response.errCode == -4) {
        _showMessage('用户拒绝授权');
      } else if (response.errCode == -2) {
        _showMessage('用户取消');
      } else {
        _showMessage('授权失败: \\${response.errStr}');
      }
      setState(() => _isLoading = false);
    });
  }
  
  Future<void> _handleAuthCode(String code) async {
    try {
      // 将 code 发送到服务端换取用户信息
      final response = await http.post(
        Uri.parse('https://your-server.com/api/wechat/login'),
        body: {'code': code},
      );
      
      final data = jsonDecode(response.body);
      if (data['success']) {
        // 登录成功，保存用户信息
        await _saveUserInfo(data['user']);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage('登录失败: \\${data['message']}');
      }
    } catch (e) {
      _showMessage('登录失败: \\$e');
    }
  }
  
  Future<void> _handleWechatLogin() async {
    if (!await _fluwx.isWeChatInstalled) {
      _showMessage('请先安装微信');
      return;
    }
    
    setState(() => _isLoading = true);
    await WechatAuthService.login();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleWechatLogin,
              icon: _isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Image.asset('assets/wechat_icon.png', width: 24),
              label: Text('微信登录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF07C160),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 服务端处理

```javascript
// Node.js 服务端
const axios = require('axios');

app.post('/api/wechat/login', async (req, res) => {
  const { code } = req.body;
  
  try {
    // 1. 用 code 换取 access_token
    const tokenRes = await axios.get('https://api.weixin.qq.com/sns/oauth2/access_token', {
      params: {
        appid: WECHAT_APP_ID,
        secret: WECHAT_APP_SECRET,
        code: code,
        grant_type: 'authorization_code',
      },
    });
    
    const { access_token, openid, unionid } = tokenRes.data;
    
    // 2. 获取用户信息
    const userRes = await axios.get('https://api.weixin.qq.com/sns/userinfo', {
      params: {
        access_token,
        openid,
      },
    });
    
    const wechatUser = userRes.data;
    
    // 3. 查找或创建用户
    let user = await User.findOne({ where: { wechatOpenid: openid } });
    
    if (!user) {
      user = await User.create({
        wechatOpenid: openid,
        wechatUnionid: unionid,
        nickname: wechatUser.nickname,
        avatar: wechatUser.headimgurl,
      });
    }
    
    // 4. 生成登录凭证
    const token = generateJWT(user);
    
    res.json({
      success: true,
      user: {
        id: user.id,
        nickname: user.nickname,
        avatar: user.avatar,
      },
      token,
    });
  } catch (error) {
    res.json({ success: false, message: error.message });
  }
});
```

## 微信分享

### 分享类型

| 类型 | 说明 | 目标 |
|------|------|------|
| 聊天 | 分享到好友/群聊 | WeChatScene.session |
| 朋友圈 | 分享到朋友圈 | WeChatScene.timeline |
| 收藏 | 添加到收藏 | WeChatScene.favorite |

### 分享文本

```dart
class WechatShareService {
  static final Fluwx _fluwx = Fluwx();
  
  /// 分享文本
  static Future<bool> shareText(String text, {WeChatScene scene = WeChatScene.session}) async {
    return await _fluwx.share(WeChatShareTextModel(
      text,
      scene: scene,
    ));
  }
}
```

### 分享图片

```dart
/// 分享图片
static Future<bool> shareImage({
  required String imagePath,
  String? title,
  String? description,
  WeChatScene scene = WeChatScene.session,
}) async {
  WeChatImage image;
  
  if (imagePath.startsWith('http')) {
    image = WeChatImage.network(imagePath);
  } else if (imagePath.startsWith('assets/')) {
    image = WeChatImage.asset(imagePath);
  } else {
    image = WeChatImage.file(File(imagePath));
  }
  
  return await _fluwx.share(WeChatShareImageModel(
    image,
    title: title,
    description: description,
    scene: scene,
  ));
}
```

### 分享网页链接

```dart
/// 分享网页
static Future<bool> shareWebPage({
  required String url,
  required String title,
  String? description,
  String? thumbnail,
  WeChatScene scene = WeChatScene.session,
}) async {
  return await _fluwx.share(WeChatShareWebPageModel(
    url,
    title: title,
    description: description ?? '',
    thumbnail: thumbnail != null ? WeChatImage.network(thumbnail) : null,
    scene: scene,
  ));
}
```

### 分享小程序卡片

```dart
/// 分享小程序
static Future<bool> shareMiniProgram({
  required String webPageUrl,
  required String userName,  // 小程序原始 ID，如 gh_xxx
  required String path,      // 小程序页面路径
  required String title,
  String? description,
  String? thumbnail,
  WXMiniProgramType miniProgramType = WXMiniProgramType.release,
}) async {
  return await _fluwx.share(WeChatShareMiniProgramModel(
    webPageUrl: webPageUrl,
    userName: userName,
    path: path,
    title: title,
    description: description ?? '',
    thumbnail: thumbnail != null ? WeChatImage.network(thumbnail) : null,
    miniProgramType: miniProgramType,
  ));
}
```

### 分享音乐

```dart
/// 分享音乐
static Future<bool> shareMusic({
  required String musicUrl,
  required String title,
  String? description,
  String? thumbnail,
  WeChatScene scene = WeChatScene.session,
}) async {
  return await _fluwx.share(WeChatShareMusicModel(
    musicUrl: musicUrl,
    title: title,
    description: description ?? '',
    thumbnail: thumbnail != null ? WeChatImage.network(thumbnail) : null,
    scene: scene,
  ));
}
```

### 分享视频

```dart
/// 分享视频
static Future<bool> shareVideo({
  required String videoUrl,
  required String title,
  String? description,
  String? thumbnail,
  WeChatScene scene = WeChatScene.session,
}) async {
  return await _fluwx.share(WeChatShareVideoModel(
    videoUrl: videoUrl,
    title: title,
    description: description ?? '',
    thumbnail: thumbnail != null ? WeChatImage.network(thumbnail) : null,
    scene: scene,
  ));
}
```

## 完整分享组件

```dart
class ShareSheet extends StatelessWidget {
  final String title;
  final String description;
  final String url;
  final String? thumbnail;
  
  const ShareSheet({
    required this.title,
    required this.description,
    required this.url,
    this.thumbnail,
  });
  
  void _share(BuildContext context, WeChatScene scene) async {
    final success = await WechatShareService.shareWebPage(
      url: url,
      title: title,
      description: description,
      thumbnail: thumbnail,
      scene: scene,
    );
    
    Navigator.pop(context);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('分享到', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareButton(
                icon: 'assets/wechat.png',
                label: '微信好友',
                onTap: () => _share(context, WeChatScene.session),
              ),
              _ShareButton(
                icon: 'assets/moments.png',
                label: '朋友圈',
                onTap: () => _share(context, WeChatScene.timeline),
              ),
              _ShareButton(
                icon: 'assets/favorite.png',
                label: '收藏',
                onTap: () => _share(context, WeChatScene.favorite),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(icon, width: 50, height: 50),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// 使用
void showShareSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => ShareSheet(
      title: '精彩文章',
      description: '这是一篇很棒的文章，快来看看吧！',
      url: 'https://example.com/article/123',
      thumbnail: 'https://example.com/thumb.jpg',
    ),
  );
}
```

## 监听分享结果

```dart
StreamSubscription? _shareSubscription;

@override
void initState() {
  super.initState();
  _shareSubscription = _fluwx.shareEventStream.listen((response) {
    if (response.errCode == 0) {
      _showMessage('分享成功');
    } else if (response.errCode == -2) {
      _showMessage('用户取消分享');
    } else {
      _showMessage('分享失败');
    }
  });
}

@override
void dispose() {
  _shareSubscription?.cancel();
  super.dispose();
}
```

## 注意事项

::: warning 注意
1. **分享到朋友圈** 只支持网页、图片、文本类型
2. **图片大小** 缩略图不能超过 32KB
3. **文本长度** 标题最多 512 字节，描述最多 1KB
4. **小程序分享** 需要小程序与 App 关联
:::

## 常见问题

### Q: 分享后无回调

检查项：
- iOS Universal Links 是否正确配置
- Android WXEntryActivity 是否创建
- 微信开放平台是否配置回调域名

### Q: 分享图片失败

可能原因：
- 图片太大（建议压缩到 500KB 以内）
- 网络图片无法访问
- 本地文件路径错误

## 官方文档

- [微信开放平台](https://open.weixin.qq.com/)
- [微信登录开发指南](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html)
- [fluwx 文档](https://pub.dev/packages/fluwx)
"""

with open('/Users/ab/Desktop/go/flutter_tutorial/docs/modules/payment/wechat-login-share.md', 'w', encoding='utf-8') as f:
    f.write(content)

print('Wechat login & share doc created!')
