#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os

# 支付宝支付文档
alipay_content = """# 支付宝支付

Flutter 中集成支付宝支付，可以使用官方 SDK 或第三方封装插件。本章介绍如何在 Flutter 应用中接入支付宝支付功能。

## 方案选择

| 方案 | 说明 | 推荐场景 |
|------|------|----------|
| tobias | 第三方封装插件 | 快速集成 |
| 原生 SDK + Platform Channel | 官方 SDK | 定制需求高 |

## 使用 tobias 插件

### 安装

```yaml
dependencies:
  tobias: ^3.0.0
```

```bash
flutter pub add tobias
```

### Android 配置

**android/app/build.gradle**

```groovy
android {
    defaultConfig {
        minSdkVersion 19
    }
}
```

**android/app/src/main/AndroidManifest.xml**

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        <activity
            android:name="com.jarvan.tobias.ALiPayActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="你的URLScheme" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### iOS 配置

**ios/Runner/Info.plist**

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>alipay</string>
    <string>alipays</string>
</array>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>你的URLScheme</string>
        </array>
    </dict>
</array>
```

## 基础用法

### 发起支付

```dart
import 'package:tobias/tobias.dart';

class AlipayService {
  /// 发起支付宝支付
  /// [orderInfo] 服务端生成的签名后的订单信息
  static Future<AlipayResult> pay(String orderInfo) async {
    try {
      final result = await Tobias.pay(orderInfo);
      return AlipayResult.fromMap(result);
    } catch (e) {
      return AlipayResult(
        resultStatus: '-1',
        memo: '支付异常: $e',
      );
    }
  }
  
  /// 检查支付宝是否安装
  static Future<bool> isInstalled() async {
    return await Tobias.isAliPayInstalled();
  }
}

class AlipayResult {
  final String resultStatus;
  final String? result;
  final String? memo;
  
  AlipayResult({
    required this.resultStatus,
    this.result,
    this.memo,
  });
  
  factory AlipayResult.fromMap(Map<String, dynamic> map) {
    return AlipayResult(
      resultStatus: map['resultStatus'] ?? '',
      result: map['result'],
      memo: map['memo'],
    );
  }
  
  bool get isSuccess => resultStatus == '9000';
  bool get isProcessing => resultStatus == '8000';
  bool get isCancelled => resultStatus == '6001';
  bool get isFailed => resultStatus == '4000';
  
  String get message {
    switch (resultStatus) {
      case '9000': return '支付成功';
      case '8000': return '正在处理中';
      case '6001': return '用户取消支付';
      case '6002': return '网络连接出错';
      case '4000': return '支付失败';
      default: return memo ?? '未知错误';
    }
  }
}
```

### 完整支付流程

```dart
class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  Future<void> _handleAlipay() async {
    // 1. 检查支付宝是否安装
    final isInstalled = await AlipayService.isInstalled();
    if (!isInstalled) {
      _showMessage('请先安装支付宝');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // 2. 从服务端获取订单信息
      final orderInfo = await _createOrder();
      
      // 3. 调起支付宝支付
      final result = await AlipayService.pay(orderInfo);
      
      // 4. 处理支付结果
      if (result.isSuccess) {
        _showMessage('支付成功');
        // 5. 向服务端确认支付结果
        await _verifyPayment();
      } else if (result.isCancelled) {
        _showMessage('已取消支付');
      } else {
        _showMessage(result.message);
      }
    } catch (e) {
      _showMessage('支付失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<String> _createOrder() async {
    // 调用服务端接口创建订单，返回签名后的订单字符串
    final response = await http.post(
      Uri.parse('https://your-server.com/api/alipay/create'),
      body: {
        'amount': '0.01',
        'subject': '测试商品',
        'out_trade_no': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    final data = jsonDecode(response.body);
    return data['order_info'];
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
      appBar: AppBar(title: Text('支付')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleAlipay,
          child: _isLoading
              ? CircularProgressIndicator()
              : Text('支付宝支付'),
        ),
      ),
    );
  }
}
```

## 服务端签名

::: warning 重要
订单签名必须在服务端完成，切勿在客户端暴露私钥！
:::

### Node.js 示例

```javascript
const crypto = require('crypto');

function createAlipayOrder(params) {
  const bizContent = {
    out_trade_no: params.outTradeNo,
    total_amount: params.amount,
    subject: params.subject,
    product_code: 'QUICK_MSECURITY_PAY',
  };
  
  const data = {
    app_id: 'YOUR_APP_ID',
    method: 'alipay.trade.app.pay',
    charset: 'utf-8',
    sign_type: 'RSA2',
    timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
    version: '1.0',
    notify_url: 'https://your-server.com/api/alipay/notify',
    biz_content: JSON.stringify(bizContent),
  };
  
  // 排序并拼接参数
  const sortedKeys = Object.keys(data).sort();
  const signStr = sortedKeys.map(k => `${k}=${data[k]}`).join('&');
  
  // RSA2 签名
  const sign = crypto
    .createSign('RSA-SHA256')
    .update(signStr, 'utf8')
    .sign(privateKey, 'base64');
  
  data.sign = encodeURIComponent(sign);
  
  // 返回订单字符串
  return Object.keys(data).map(k => `${k}=${data[k]}`).join('&');
}
```

## 异步通知处理

```javascript
// 支付宝异步通知
app.post('/api/alipay/notify', async (req, res) => {
  const params = req.body;
  
  // 1. 验证签名
  const isValid = verifyAlipaySign(params);
  if (!isValid) {
    return res.send('fail');
  }
  
  // 2. 验证通知数据
  if (params.trade_status === 'TRADE_SUCCESS') {
    const outTradeNo = params.out_trade_no;
    const tradeNo = params.trade_no;
    const amount = params.total_amount;
    
    // 3. 更新订单状态
    await updateOrderStatus(outTradeNo, 'paid', tradeNo);
  }
  
  res.send('success');
});
```

## 常见问题

### Q: 支付后返回 6001 用户取消

可能原因：
- 用户主动取消
- URL Scheme 配置错误
- 支付宝版本过低

### Q: 签名验证失败

检查项：
- 私钥格式是否正确（PKCS8）
- 字符编码是否为 UTF-8
- 参数排序是否正确

## 官方文档

- [支付宝开放平台](https://open.alipay.com/)
- [App支付接入文档](https://opendocs.alipay.com/open/204/105297)
- [tobias 插件](https://pub.dev/packages/tobias)
"""

# 创建目录
os.makedirs('/Users/ab/Desktop/go/flutter_tutorial/docs/modules/payment', exist_ok=True)

# 写入文件
with open('/Users/ab/Desktop/go/flutter_tutorial/docs/modules/payment/alipay.md', 'w', encoding='utf-8') as f:
    f.write(alipay_content)

print('Alipay doc created!')
