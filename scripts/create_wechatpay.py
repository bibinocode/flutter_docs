#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

content = """# 微信支付

Flutter 中集成微信支付需要使用微信 SDK，可以通过 fluwx 插件实现。本章介绍如何在 Flutter 应用中接入微信支付功能。

## 安装

```yaml
dependencies:
  fluwx: ^4.5.5
```

```bash
flutter pub add fluwx
```

## 平台配置

### Android 配置

**android/app/build.gradle**

```groovy
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

**android/app/src/main/AndroidManifest.xml**

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    
    <queries>
        <package android:name="com.tencent.mm" />
    </queries>
    
    <application>
        <activity
            android:name=".wxapi.WXPayEntryActivity"
            android:exported="true"
            android:launchMode="singleTop" />
    </application>
</manifest>
```

**创建 WXPayEntryActivity**

```kotlin
// android/app/src/main/kotlin/你的包名/wxapi/WXPayEntryActivity.kt
package 你的包名.wxapi

import io.flutter.embedding.android.FlutterActivity

class WXPayEntryActivity : FlutterActivity()
```

### iOS 配置

**ios/Runner/Info.plist**

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>weixin</string>
    <string>weixinULAPI</string>
    <string>weixinURLParamsAPI</string>
</array>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wx你的AppID</string>
        </array>
    </dict>
</array>
```

**配置 Universal Links（iOS 9+）**

在 Apple Developer 后台配置 Associated Domains，添加：
```
applinks:你的域名
```

## 初始化

```dart
import 'package:fluwx/fluwx.dart';

class WechatService {
  static final Fluwx _fluwx = Fluwx();
  
  static Future<void> init() async {
    await _fluwx.registerApi(
      appId: 'wx你的AppID',
      universalLink: 'https://你的域名/app/', // iOS 必需
    );
  }
  
  static Future<bool> isInstalled() async {
    return await _fluwx.isWeChatInstalled;
  }
}
```

## 发起支付

```dart
class WechatPayService {
  static final Fluwx _fluwx = Fluwx();
  
  /// 发起微信支付
  /// 参数由服务端返回
  static Future<bool> pay({
    required String appId,
    required String partnerId,
    required String prepayId,
    required String nonceStr,
    required String timeStamp,
    required String sign,
  }) async {
    return await _fluwx.pay(
      which: Payment(
        appId: appId,
        partnerId: partnerId,
        prepayId: prepayId,
        packageValue: 'Sign=WXPay',
        nonceStr: nonceStr,
        timestamp: int.parse(timeStamp),
        sign: sign,
      ),
    );
  }
}
```

## 监听支付结果

```dart
class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final Fluwx _fluwx = Fluwx();
  StreamSubscription? _paySubscription;

  @override
  void initState() {
    super.initState();
    _listenPayResult();
  }
  
  void _listenPayResult() {
    _paySubscription = _fluwx.payEventStream.listen((response) {
      if (response.errCode == 0) {
        _showMessage('支付成功');
        _verifyPayment();
      } else if (response.errCode == -2) {
        _showMessage('用户取消支付');
      } else {
        _showMessage('支付失败: \\${response.errStr}');
      }
    });
  }

  @override
  void dispose() {
    _paySubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _handleWechatPay() async {
    // 1. 检查微信是否安装
    if (!await _fluwx.isWeChatInstalled) {
      _showMessage('请先安装微信');
      return;
    }
    
    try {
      // 2. 从服务端获取支付参数
      final params = await _createOrder();
      
      // 3. 调起微信支付
      await WechatPayService.pay(
        appId: params['appid'],
        partnerId: params['partnerid'],
        prepayId: params['prepayid'],
        nonceStr: params['noncestr'],
        timeStamp: params['timestamp'],
        sign: params['sign'],
      );
    } catch (e) {
      _showMessage('支付失败: \\$e');
    }
  }
  
  Future<Map<String, dynamic>> _createOrder() async {
    final response = await http.post(
      Uri.parse('https://your-server.com/api/wechat/pay/create'),
      body: {
        'amount': '1', // 单位：分
        'description': '测试商品',
        'out_trade_no': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    return jsonDecode(response.body);
  }
  
  Future<void> _verifyPayment() async {
    // 服务端验证支付结果
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('微信支付')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _handleWechatPay,
          icon: Icon(Icons.payment),
          label: Text('微信支付'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF07C160),
          ),
        ),
      ),
    );
  }
}
```

## 服务端实现

### 统一下单（Node.js）

```javascript
const crypto = require('crypto');
const axios = require('axios');

class WechatPayService {
  constructor(config) {
    this.appId = config.appId;
    this.mchId = config.mchId;
    this.apiKey = config.apiKey;
    this.notifyUrl = config.notifyUrl;
  }
  
  async createOrder(params) {
    const nonceStr = this.generateNonceStr();
    const timeStamp = Math.floor(Date.now() / 1000).toString();
    
    const data = {
      appid: this.appId,
      mch_id: this.mchId,
      nonce_str: nonceStr,
      body: params.description,
      out_trade_no: params.outTradeNo,
      total_fee: params.amount,
      spbill_create_ip: params.clientIp || '127.0.0.1',
      notify_url: this.notifyUrl,
      trade_type: 'APP',
    };
    
    // 签名
    data.sign = this.sign(data);
    
    // 调用统一下单接口
    const xml = this.toXml(data);
    const response = await axios.post(
      'https://api.mch.weixin.qq.com/pay/unifiedorder',
      xml,
      { headers: { 'Content-Type': 'text/xml' } }
    );
    
    const result = this.parseXml(response.data);
    
    if (result.return_code !== 'SUCCESS') {
      throw new Error(result.return_msg);
    }
    
    // 返回 App 支付参数
    const payParams = {
      appid: this.appId,
      partnerid: this.mchId,
      prepayid: result.prepay_id,
      package: 'Sign=WXPay',
      noncestr: nonceStr,
      timestamp: timeStamp,
    };
    payParams.sign = this.sign(payParams);
    
    return payParams;
  }
  
  sign(params) {
    const keys = Object.keys(params).sort();
    const signStr = keys
      .filter(k => params[k] && k !== 'sign')
      .map(k => `\\${k}=\\${params[k]}`)
      .join('&') + `&key=\\${this.apiKey}`;
    
    return crypto
      .createHash('md5')
      .update(signStr)
      .digest('hex')
      .toUpperCase();
  }
  
  generateNonceStr(length = 32) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let str = '';
    for (let i = 0; i < length; i++) {
      str += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return str;
  }
}
```

### 支付通知

```javascript
app.post('/api/wechat/pay/notify', async (req, res) => {
  const data = parseXml(req.body);
  
  // 1. 验证签名
  const isValid = wechatPay.verifySign(data);
  if (!isValid) {
    return res.send(toXml({ return_code: 'FAIL', return_msg: '签名验证失败' }));
  }
  
  // 2. 处理支付结果
  if (data.result_code === 'SUCCESS') {
    const outTradeNo = data.out_trade_no;
    const transactionId = data.transaction_id;
    const totalFee = data.total_fee;
    
    // 3. 更新订单状态
    await updateOrderStatus(outTradeNo, 'paid', transactionId);
  }
  
  res.send(toXml({ return_code: 'SUCCESS', return_msg: 'OK' }));
});
```

## 常见错误码

| 错误码 | 说明 | 解决方案 |
|--------|------|----------|
| -1 | 通用错误 | 检查参数和签名 |
| -2 | 用户取消 | 正常流程 |
| -3 | 发送失败 | 检查网络 |
| -4 | 授权被拒绝 | 检查权限配置 |
| -5 | 不支持 | 微信版本过低 |

## 注意事项

::: warning 安全提醒
1. 所有签名操作必须在服务端完成
2. API 密钥不能暴露在客户端
3. 支付结果以服务端通知为准
4. 做好订单幂等处理
:::

## 官方文档

- [微信支付开发文档](https://pay.weixin.qq.com/wiki/doc/api/index.html)
- [微信支付 V3 API](https://pay.weixin.qq.com/wiki/doc/apiv3/index.shtml)
- [fluwx 插件](https://pub.dev/packages/fluwx)
"""

with open('/Users/ab/Desktop/go/flutter_tutorial/docs/modules/payment/wechatpay.md', 'w', encoding='utf-8') as f:
    f.write(content)

print('Wechat pay doc created!')
