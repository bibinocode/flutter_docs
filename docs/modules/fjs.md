# FJS - JavaScript 执行引擎

`fjs` 是 Flutter Candies 团队开发的高性能 JavaScript 运行时，基于 Rust 构建，使用 QuickJS 引擎。它允许你在 Flutter 应用中执行 JavaScript 代码。

## 🤔 为什么需要在 Flutter 中执行 JavaScript？

这是一个很好的问题！在了解 API 之前，先弄清楚**使用场景**更重要：

### 场景一：动态化/热更新

```
┌─────────────────────────────────────────────────────┐
│                    你的 Flutter App                   │
├─────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐                 │
│  │   核心功能   │    │   动态模块   │ ← JS 脚本      │
│  │  (Dart 编写) │    │  (JS 编写)   │   可远程下发   │
│  └─────────────┘    └─────────────┘                 │
└─────────────────────────────────────────────────────┘
```

**问题**：App Store 审核周期长，紧急修复需要重新发版  
**方案**：把部分业务逻辑用 JS 编写，服务器下发更新，无需发版

```dart
// 从服务器获取最新的业务逻辑
final jsCode = await fetchLatestLogic();

// 执行 JS 脚本
final result = await engine.eval(JsCode.code(jsCode));
```

### 场景二：爬虫/网页解析

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   目标网站    │ ──→  │   FJS 执行   │ ──→  │   结构化数据  │
│  (含 JS 逻辑) │      │   网站 JS    │      │   (Dart 对象) │
└──────────────┘      └──────────────┘      └──────────────┘
```

**真实案例**：[Mikan Flutter](https://github.com/iota9star/mikan_flutter) 动漫订阅客户端

```dart
// 某些网站的数据需要执行 JS 才能获取
final html = await dio.get('https://example.com/anime');

// 执行网站的解密/解析脚本
final data = await engine.eval(JsCode.code('''
  ${websiteDecryptScript}
  decrypt("${html.data}")
'''));
```

### 场景三：插件系统

```
┌─────────────────────────────────────────────────────┐
│                     主应用                           │
├─────────────────────────────────────────────────────┤
│   ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│   │ 插件 A   │  │ 插件 B   │  │ 插件 C   │         │
│   │ (JS)     │  │ (JS)     │  │ (JS)     │         │
│   └──────────┘  └──────────┘  └──────────┘         │
│        ↑              ↑              ↑              │
│        └──────────────┴──────────────┘              │
│              用户可自行安装/卸载                      │
└─────────────────────────────────────────────────────┘
```

**场景**：类似浏览器扩展的插件系统

```dart
// 加载用户安装的插件
for (final plugin in installedPlugins) {
  await engine.declareNewModule(
    module: JsModule.code(
      module: plugin.name,
      code: plugin.code,
    ),
  );
}
```

### 场景四：规则引擎/表达式计算

```dart
// 营销活动：满减计算
final discountRule = '''
  function calculateDiscount(price, rules) {
    for (const rule of rules) {
      if (price >= rule.threshold) {
        return price - rule.discount;
      }
    }
    return price;
  }
  calculateDiscount($price, $rulesJson)
''';

final finalPrice = await engine.eval(JsCode.code(discountRule));
```

### 场景五：跨平台脚本复用

```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│    Web 端   │   │  Flutter 端  │   │   小程序    │
└──────┬──────┘   └──────┬──────┘   └──────┬──────┘
       │                 │                  │
       └─────────────────┼──────────────────┘
                         ↓
              ┌──────────────────────┐
              │   共享 JS 业务逻辑    │
              │  (加密/解密/格式化等)  │
              └──────────────────────┘
```

## 安装配置

```yaml
dependencies:
  fjs: ^2.0.1
```

## 快速开始

### 初始化引擎

```dart
import 'package:fjs/fjs.dart';

class JsEngineService {
  JsEngine? _engine;
  
  Future<void> init() async {
    // 初始化 FJS 库
    await LibFjs.init();
    
    // 创建运行时 (可选择内置模块)
    final runtime = await JsAsyncRuntime.withOptions(
      builtin: JsBuiltinOptions(
        console: true,    // console.log 等
        fetch: true,      // fetch API
        timers: true,     // setTimeout/setInterval
        json: true,       // JSON 解析
      ),
    );
    
    // 创建上下文
    final context = await JsAsyncContext.from(runtime);
    
    // 创建引擎
    _engine = JsEngine(context);
    
    // 初始化 (带桥接函数)
    await _engine!.init(bridge: _handleBridgeCall);
  }
  
  // Dart-JS 桥接：JS 可以调用 Dart 功能
  Future<JsResult> _handleBridgeCall(JsValue jsValue) async {
    final data = jsValue.value;
    
    if (data is Map) {
      switch (data['action']) {
        case 'getDeviceInfo':
          return JsResult.ok(JsValue.from({
            'platform': Platform.operatingSystem,
            'version': Platform.operatingSystemVersion,
          }));
        
        case 'showToast':
          Fluttertoast.showToast(msg: data['message']);
          return JsResult.ok(JsValue.bool(true));
        
        case 'httpGet':
          final response = await Dio().get(data['url']);
          return JsResult.ok(JsValue.from(response.data));
      }
    }
    
    return JsResult.ok(JsValue.none());
  }
  
  Future<void> dispose() async {
    await _engine?.dispose();
  }
}
```

### 执行 JavaScript 代码

```dart
// 简单计算
final result = await engine.eval(JsCode.code('1 + 2 * 3'));
print(result.value); // 7

// 执行函数
final code = '''
  function greet(name) {
    return `Hello, ${name}!`;
  }
  greet('Flutter')
''';
final greeting = await engine.eval(JsCode.code(code));
print(greeting.value); // "Hello, Flutter!"

// 异步代码
final asyncCode = '''
  async function fetchData() {
    const response = await fetch('https://api.example.com/data');
    return response.json();
  }
  await fetchData()
''';
final data = await engine.eval(JsCode.code(asyncCode));
```

## ES6 模块系统

### 声明模块

```dart
// 声明一个工具模块
await engine.declareNewModule(
  module: JsModule.code(
    module: 'utils',
    code: '''
      export const formatPrice = (price) => {
        return '¥' + price.toFixed(2);
      };
      
      export const formatDate = (timestamp) => {
        const date = new Date(timestamp);
        return date.toLocaleDateString('zh-CN');
      };
      
      export const debounce = (fn, delay) => {
        let timer = null;
        return (...args) => {
          clearTimeout(timer);
          timer = setTimeout(() => fn(...args), delay);
        };
      };
    ''',
  ),
);

// 声明一个 API 模块
await engine.declareNewModule(
  module: JsModule.code(
    module: 'api',
    code: '''
      export async function getUser(id) {
        const response = await fetch(`https://api.example.com/users/${id}`);
        return response.json();
      }
      
      export async function getPosts(userId) {
        const response = await fetch(`https://api.example.com/users/${userId}/posts`);
        return response.json();
      }
    ''',
  ),
);
```

### 使用模块

```dart
final result = await engine.eval(JsCode.code('''
  import { formatPrice, formatDate } from 'utils';
  import { getUser } from 'api';
  
  const user = await getUser(123);
  const formattedPrice = formatPrice(user.balance);
  const formattedDate = formatDate(user.createdAt);
  
  ({ 
    name: user.name, 
    balance: formattedPrice,
    joinDate: formattedDate 
  })
'''));

print(result.value); 
// {name: "张三", balance: "¥1234.56", joinDate: "2024/1/15"}
```

## Dart-JS 双向通信

### JS 调用 Dart

```dart
// Dart 端：设置桥接处理器
await engine.init(bridge: (jsValue) async {
  final data = jsValue.value as Map;
  
  switch (data['method']) {
    case 'storage.get':
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(data['key']);
      return JsResult.ok(JsValue.from(value));
    
    case 'storage.set':
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(data['key'], data['value']);
      return JsResult.ok(JsValue.bool(true));
    
    case 'navigate':
      Navigator.of(context).pushNamed(data['route']);
      return JsResult.ok(JsValue.bool(true));
    
    default:
      return JsResult.err(JsError('Unknown method: ${data['method']}'));
  }
});

// JS 端：调用 Dart 功能
final code = '''
  // 读取存储
  const token = await fjs.bridge_call({ 
    method: 'storage.get', 
    key: 'auth_token' 
  });
  
  // 写入存储
  await fjs.bridge_call({ 
    method: 'storage.set', 
    key: 'last_visit',
    value: new Date().toISOString()
  });
  
  // 页面跳转
  await fjs.bridge_call({ 
    method: 'navigate', 
    route: '/profile' 
  });
''';

await engine.eval(JsCode.code(code));
```

## 实战示例：动态表单验证

```dart
class DynamicFormValidator {
  final JsEngine engine;
  
  DynamicFormValidator(this.engine);
  
  /// 从服务器加载验证规则
  Future<void> loadRules(String rulesJs) async {
    await engine.declareNewModule(
      module: JsModule.code(
        module: 'validators',
        code: rulesJs,
      ),
    );
  }
  
  /// 验证表单
  Future<Map<String, String?>> validate(Map<String, dynamic> formData) async {
    final result = await engine.eval(JsCode.code('''
      import { validateForm } from 'validators';
      validateForm(${jsonEncode(formData)})
    '''));
    
    return Map<String, String?>.from(result.value);
  }
}

// 服务器下发的验证规则 (可动态更新)
final rulesJs = '''
  export function validateForm(data) {
    const errors = {};
    
    // 手机号验证
    if (!data.phone) {
      errors.phone = '请输入手机号';
    } else if (!/^1[3-9]\\d{9}\$/.test(data.phone)) {
      errors.phone = '手机号格式不正确';
    }
    
    // 邮箱验证
    if (data.email && !/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+\$/.test(data.email)) {
      errors.email = '邮箱格式不正确';
    }
    
    // 密码强度
    if (!data.password) {
      errors.password = '请输入密码';
    } else if (data.password.length < 8) {
      errors.password = '密码至少8位';
    } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)/.test(data.password)) {
      errors.password = '密码需包含大小写字母和数字';
    }
    
    return errors;
  }
''';

// 使用
final validator = DynamicFormValidator(engine);
await validator.loadRules(rulesJs);

final errors = await validator.validate({
  'phone': '13800138000',
  'email': 'test@example.com',
  'password': 'Abc12345',
});

print(errors); // {}  全部验证通过
```

## 实战示例：插件系统

```dart
class PluginManager {
  final JsEngine engine;
  final List<String> _loadedPlugins = [];
  
  PluginManager(this.engine);
  
  /// 安装插件
  Future<void> installPlugin({
    required String name,
    required String code,
  }) async {
    await engine.declareNewModule(
      module: JsModule.code(module: name, code: code),
    );
    _loadedPlugins.add(name);
  }
  
  /// 卸载插件
  Future<void> uninstallPlugin(String name) async {
    // 注意：需要重新创建引擎来完全卸载
    _loadedPlugins.remove(name);
  }
  
  /// 调用插件方法
  Future<dynamic> callPlugin(String name, String method, [List<dynamic>? args]) async {
    final argsJson = args != null ? jsonEncode(args) : '[]';
    
    final result = await engine.eval(JsCode.code('''
      import { $method } from '$name';
      $method(...$argsJson)
    '''));
    
    return result.value;
  }
}

// 示例：图片处理插件
final imagePlugin = '''
  export function resize(url, width, height) {
    // 返回处理后的 URL
    return `\${url}?w=\${width}&h=\${height}`;
  }
  
  export function thumbnail(url) {
    return resize(url, 200, 200);
  }
  
  export function compress(url, quality = 80) {
    return `\${url}?q=\${quality}`;
  }
''';

// 使用
final plugins = PluginManager(engine);
await plugins.installPlugin(name: 'image', code: imagePlugin);

final thumbUrl = await plugins.callPlugin(
  'image', 
  'thumbnail', 
  ['https://example.com/photo.jpg'],
);
print(thumbUrl); // https://example.com/photo.jpg?w=200&h=200
```

## 内置模块预设

```dart
// 精简版：console, timers, buffer, util, json
final runtime = await JsAsyncRuntime.withOptions(
  builtin: JsBuiltinOptions.essential(),
);

// Web 兼容：console, timers, fetch, url, crypto, streamWeb, navigator
final runtime = await JsAsyncRuntime.withOptions(
  builtin: JsBuiltinOptions.web(),
);

// Node.js 兼容：大部分 Node.js 模块
final runtime = await JsAsyncRuntime.withOptions(
  builtin: JsBuiltinOptions.node(),
);

// 全部模块
final runtime = await JsAsyncRuntime.withOptions(
  builtin: JsBuiltinOptions.all(),
);
```

### 可用内置模块

| 模块 | 说明 |
|------|------|
| `console` | console.log/warn/error 等 |
| `timers` | setTimeout/setInterval/setImmediate |
| `fetch` | HTTP 请求 Fetch API |
| `url` | URL 解析 |
| `crypto` | 加密函数 (hash/HMAC/随机数) |
| `json` | JSON 解析序列化 |
| `buffer` | 二进制数据处理 |
| `fs` | 文件系统 (Node.js 兼容) |
| `path` | 路径处理 |
| `events` | EventEmitter |
| `zlib` | 压缩/解压 (gzip/deflate) |

## 内存管理

```dart
// 设置内存限制
await runtime.setMemoryLimit(50 * 1024 * 1024); // 50MB
await runtime.setGcThreshold(10 * 1024 * 1024);  // 10MB 触发 GC

// 查看内存使用
final usage = await runtime.memoryUsage();
print('内存使用: ${usage.summary()}');

// 手动触发垃圾回收
await runtime.runGc();
```

## 错误处理

```dart
try {
  final result = await engine.eval(JsCode.code('''
    throw new Error('Something went wrong');
  '''));
} on JsError catch (e) {
  print('JS 错误: ${e.code()} - $e');
  // 可以获取错误堆栈等详细信息
}
```

## 性能优化建议

::: tip 最佳实践
1. **复用引擎** - 创建一次，多次使用，避免重复初始化
2. **设置内存限制** - 防止 JS 代码占用过多内存
3. **使用模块缓存** - 常用脚本声明为模块，避免重复解析
4. **批量操作** - 多个操作合并在一次 eval 中执行
5. **及时释放** - 不用时调用 `engine.dispose()`
:::

::: warning 注意事项
- FJS 是**同步阻塞**执行，长时间 JS 运算会阻塞 UI
- 复杂计算考虑使用 `compute()` 在 Isolate 中运行
- 不要在 JS 中存储敏感信息，脚本可能被反编译
- 远程加载的 JS 代码需要做好安全校验
:::

## 适用场景总结

| 场景 | 推荐度 | 说明 |
|------|--------|------|
| 热更新/动态化 | ⭐⭐⭐⭐⭐ | 核心应用场景 |
| 爬虫/网页解析 | ⭐⭐⭐⭐⭐ | 执行网站 JS 脚本 |
| 插件系统 | ⭐⭐⭐⭐ | 用户可安装扩展 |
| 规则引擎 | ⭐⭐⭐⭐ | 复杂业务规则配置 |
| 跨平台脚本复用 | ⭐⭐⭐⭐ | Web/移动端共享逻辑 |
| 游戏脚本 | ⭐⭐⭐ | 游戏逻辑热更新 |
| 简单计算 | ⭐⭐ | 杀鸡用牛刀，不推荐 |

---

## 🔧 技术实现方案（DIY 指南）

如果你对底层实现感兴趣，想用 **Rust** 或 **Go** 自己实现一个类似的 JS 引擎，这部分内容会帮助你理解核心架构。

### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter / Dart 层                       │
├─────────────────────────────────────────────────────────────┤
│   JsEngine API  │  JsValue  │  JsModule  │  JsResult        │
├─────────────────────────────────────────────────────────────┤
│                    FFI Bridge 层                             │
│            (flutter_rust_bridge / cgo)                       │
├─────────────────────────────────────────────────────────────┤
│                   Rust / Go 胶水层                           │
│     ┌─────────────────────────────────────────────────┐     │
│     │  Runtime 管理  │  Context 管理  │  Bridge 回调   │     │
│     └─────────────────────────────────────────────────┘     │
├─────────────────────────────────────────────────────────────┤
│                   QuickJS C 引擎                             │
│     ┌─────────────────────────────────────────────────┐     │
│     │  Parser  │  Bytecode  │  GC  │  Builtin Modules │     │
│     └─────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### 为什么选择 QuickJS？

| 引擎 | 大小 | 特点 | 适用场景 |
|------|------|------|---------|
| **QuickJS** | ~700KB | 轻量、ES2020+、快速启动 | 嵌入式、移动端 ✅ |
| V8 | ~30MB | 高性能、JIT | 服务端、浏览器 |
| JavaScriptCore | 系统自带 | iOS 原生、仅 Apple | iOS 专用 |
| Hermes | ~3MB | React Native 优化 | RN 专用 |

QuickJS 的优势：
- 纯 C 实现，易于跨平台编译
- 支持 ES2020+ 语法（async/await、BigInt、可选链等）
- 内置字节码编译，可预编译提升启动速度
- 内存占用极小，适合移动端

### Rust 实现方案

#### 核心依赖

```toml
# Cargo.toml
[dependencies]
rquickjs = { version = "0.6", features = ["full-async", "parallel"] }
tokio = { version = "1", features = ["full"] }

[build-dependencies]
flutter_rust_bridge_codegen = "2"
```

#### 关键组件实现

**1. Runtime 和 Context 管理**

```rust
use rquickjs::{AsyncRuntime, AsyncContext, Module, Promise};
use std::sync::Arc;
use tokio::sync::Mutex;

pub struct JsRuntime {
    runtime: Arc<AsyncRuntime>,
}

impl JsRuntime {
    pub async fn new() -> Result<Self, JsError> {
        let runtime = AsyncRuntime::new()?;
        
        // 设置内存限制
        runtime.set_memory_limit(50 * 1024 * 1024); // 50MB
        
        Ok(Self {
            runtime: Arc::new(runtime),
        })
    }
    
    pub async fn create_context(&self) -> Result<JsContext, JsError> {
        let context = AsyncContext::full(&self.runtime).await?;
        Ok(JsContext { context })
    }
}

pub struct JsContext {
    context: AsyncContext,
}

impl JsContext {
    pub async fn eval(&self, code: &str) -> Result<JsValue, JsError> {
        self.context.with(|ctx| {
            let result = ctx.eval::<rquickjs::Value, _>(code)?;
            Ok(convert_to_js_value(result))
        }).await
    }
    
    pub async fn eval_module(&self, name: &str, code: &str) -> Result<JsValue, JsError> {
        self.context.with(|ctx| {
            // 编译并执行模块
            let module = Module::declare(ctx.clone(), name, code)?;
            let (module, promise) = module.eval()?;
            
            // 等待模块加载完成
            if let Some(promise) = promise {
                promise.into_future::<()>().await?;
            }
            
            Ok(JsValue::Undefined)
        }).await
    }
}
```

**2. 值类型转换**

```rust
#[derive(Debug, Clone)]
pub enum JsValue {
    Undefined,
    Null,
    Bool(bool),
    Int(i64),
    Float(f64),
    String(String),
    Array(Vec<JsValue>),
    Object(HashMap<String, JsValue>),
}

fn convert_to_js_value(value: rquickjs::Value) -> JsValue {
    match value.type_of() {
        rquickjs::Type::Undefined => JsValue::Undefined,
        rquickjs::Type::Null => JsValue::Null,
        rquickjs::Type::Bool => JsValue::Bool(value.as_bool().unwrap()),
        rquickjs::Type::Int => JsValue::Int(value.as_int().unwrap() as i64),
        rquickjs::Type::Float => JsValue::Float(value.as_float().unwrap()),
        rquickjs::Type::String => {
            JsValue::String(value.as_string().unwrap().to_string().unwrap())
        }
        rquickjs::Type::Array => {
            let arr = value.as_array().unwrap();
            let items: Vec<JsValue> = arr
                .iter()
                .map(|v| convert_to_js_value(v.unwrap()))
                .collect();
            JsValue::Array(items)
        }
        rquickjs::Type::Object => {
            let obj = value.as_object().unwrap();
            let mut map = HashMap::new();
            for result in obj.props::<String, rquickjs::Value>() {
                let (key, val) = result.unwrap();
                map.insert(key, convert_to_js_value(val));
            }
            JsValue::Object(map)
        }
        _ => JsValue::Undefined,
    }
}
```

**3. Dart-JS 桥接**

```rust
use std::future::Future;
use std::pin::Pin;

type BridgeCallback = Box<
    dyn Fn(JsValue) -> Pin<Box<dyn Future<Output = Result<JsValue, JsError>> + Send>>
        + Send
        + Sync,
>;

impl JsContext {
    pub async fn init_bridge(&self, callback: BridgeCallback) -> Result<(), JsError> {
        self.context.with(|ctx| {
            // 注册全局 fjs 对象
            let global = ctx.globals();
            let fjs = rquickjs::Object::new(ctx.clone())?;
            
            // 注册 bridge_call 方法
            fjs.set("bridge_call", rquickjs::Function::new(ctx.clone(), move |args: rquickjs::Value| {
                let js_value = convert_to_js_value(args);
                
                // 调用 Dart 回调
                let result = callback(js_value);
                
                // 返回 Promise
                // ...
            }))?;
            
            global.set("fjs", fjs)?;
            Ok(())
        }).await
    }
}
```

**4. 内置模块注册 (以 console 为例)**

```rust
pub fn register_console(ctx: &rquickjs::Ctx) -> Result<(), JsError> {
    let global = ctx.globals();
    let console = rquickjs::Object::new(ctx.clone())?;
    
    console.set("log", rquickjs::Function::new(ctx.clone(), |args: rquickjs::Rest<rquickjs::Value>| {
        let output: Vec<String> = args.0
            .iter()
            .map(|v| format_value(v))
            .collect();
        println!("[JS] {}", output.join(" "));
    }))?;
    
    console.set("error", rquickjs::Function::new(ctx.clone(), |args: rquickjs::Rest<rquickjs::Value>| {
        let output: Vec<String> = args.0
            .iter()
            .map(|v| format_value(v))
            .collect();
        eprintln!("[JS ERROR] {}", output.join(" "));
    }))?;
    
    global.set("console", console)?;
    Ok(())
}
```

#### Flutter Rust Bridge 集成

```rust
// lib.rs - 暴露给 Dart 的 API
#[flutter_rust_bridge::frb(sync)]
pub fn init_library() {
    // 初始化
}

#[flutter_rust_bridge::frb]
pub async fn create_runtime() -> Result<JsRuntimeHandle, JsError> {
    let runtime = JsRuntime::new().await?;
    Ok(JsRuntimeHandle::new(runtime))
}

#[flutter_rust_bridge::frb]
pub async fn eval_code(
    context: &JsContextHandle,
    code: String,
) -> Result<JsValue, JsError> {
    context.inner().eval(&code).await
}
```

### Go 实现方案

如果你更熟悉 Go，也可以用 Go 实现：

#### 核心依赖

```go
// go.mod
module github.com/example/gojs

go 1.21

require (
    github.com/aspect-build/aspect-cli v0.0.0 // quickjs bindings
    // 或者使用 goja (纯 Go 实现的 JS 引擎)
    github.com/nicholasmccalls/goja v1.0.0
)
```

#### 使用 goja (纯 Go JS 引擎)

```go
package jsengine

import (
    "github.com/nicholasmccalls/goja"
    "sync"
)

type JsEngine struct {
    vm    *goja.Runtime
    mutex sync.Mutex
}

func NewEngine() *JsEngine {
    vm := goja.New()
    
    // 注册 console
    console := vm.NewObject()
    console.Set("log", func(call goja.FunctionCall) goja.Value {
        args := make([]interface{}, len(call.Arguments))
        for i, arg := range call.Arguments {
            args[i] = arg.Export()
        }
        fmt.Println(args...)
        return goja.Undefined()
    })
    vm.Set("console", console)
    
    return &JsEngine{vm: vm}
}

func (e *JsEngine) Eval(code string) (interface{}, error) {
    e.mutex.Lock()
    defer e.mutex.Unlock()
    
    result, err := e.vm.RunString(code)
    if err != nil {
        return nil, err
    }
    
    return result.Export(), nil
}

func (e *JsEngine) RegisterBridge(name string, fn func(args []interface{}) interface{}) {
    e.vm.Set(name, func(call goja.FunctionCall) goja.Value {
        args := make([]interface{}, len(call.Arguments))
        for i, arg := range call.Arguments {
            args[i] = arg.Export()
        }
        result := fn(args)
        return e.vm.ToValue(result)
    })
}
```

#### 使用 cgo 绑定 QuickJS

```go
package quickjs

/*
#cgo CFLAGS: -I${SRCDIR}/quickjs
#cgo LDFLAGS: -L${SRCDIR}/quickjs -lquickjs -lm -lpthread

#include "quickjs.h"
#include <stdlib.h>

// 包装函数
JSRuntime* create_runtime() {
    return JS_NewRuntime();
}

JSContext* create_context(JSRuntime* rt) {
    return JS_NewContext(rt);
}

JSValue eval_code(JSContext* ctx, const char* code, const char* filename) {
    return JS_Eval(ctx, code, strlen(code), filename, JS_EVAL_TYPE_GLOBAL);
}
*/
import "C"
import (
    "unsafe"
    "runtime"
)

type Runtime struct {
    rt *C.JSRuntime
}

type Context struct {
    ctx *C.JSContext
}

func NewRuntime() *Runtime {
    rt := C.create_runtime()
    r := &Runtime{rt: rt}
    
    runtime.SetFinalizer(r, func(r *Runtime) {
        C.JS_FreeRuntime(r.rt)
    })
    
    return r
}

func (r *Runtime) NewContext() *Context {
    ctx := C.create_context(r.rt)
    c := &Context{ctx: ctx}
    
    runtime.SetFinalizer(c, func(c *Context) {
        C.JS_FreeContext(c.ctx)
    })
    
    return c
}

func (c *Context) Eval(code string) (interface{}, error) {
    cCode := C.CString(code)
    defer C.free(unsafe.Pointer(cCode))
    
    cFilename := C.CString("<eval>")
    defer C.free(unsafe.Pointer(cFilename))
    
    result := C.eval_code(c.ctx, cCode, cFilename)
    
    // 检查异常
    if C.JS_IsException(result) != 0 {
        return nil, extractError(c.ctx)
    }
    
    return convertValue(c.ctx, result), nil
}
```

#### Go 与 Flutter 集成 (使用 go_flutter)

```go
// plugin.go
package main

import (
    "github.com/nicholasmccalls/goja"
    flutter "github.com/nicholasmccalls/go-flutter"
)

type JsEnginePlugin struct {
    engines map[int]*JsEngine
    nextId  int
}

func (p *JsEnginePlugin) InitPlugin(messenger flutter.BinaryMessenger) error {
    channel := flutter.NewMethodChannel(messenger, "com.example/jsengine", flutter.StandardMethodCodec{})
    
    channel.HandleFunc("createEngine", func(args interface{}) (interface{}, error) {
        engine := NewEngine()
        id := p.nextId
        p.engines[id] = engine
        p.nextId++
        return id, nil
    })
    
    channel.HandleFunc("eval", func(args interface{}) (interface{}, error) {
        params := args.(map[interface{}]interface{})
        engineId := params["engineId"].(int)
        code := params["code"].(string)
        
        engine := p.engines[engineId]
        return engine.Eval(code)
    })
    
    return nil
}
```

### 核心技术点总结

| 技术点 | Rust 方案 | Go 方案 |
|--------|----------|---------|
| QuickJS 绑定 | rquickjs crate | cgo 或 goja |
| FFI 生成 | flutter_rust_bridge | go_flutter / gomobile |
| 异步支持 | tokio + async/await | goroutine + channel |
| 内存管理 | 自动 (Rust 所有权) | GC + runtime.SetFinalizer |
| 跨平台编译 | cargo + cross | gomobile / xgo |

### 推荐学习资源

::: info 相关项目和文档
**Rust 方向：**
- [rquickjs](https://github.com/nicholasmccalls/rquickjs) - QuickJS 的 Rust 绑定
- [flutter_rust_bridge](https://github.com/nicholasmccalls/flutter_rust_bridge) - Flutter FFI 代码生成器
- [AWS LLRT](https://github.com/awslabs/llrt) - AWS 的轻量级 JS 运行时，内置模块可参考

**Go 方向：**
- [goja](https://github.com/nicholasmccalls/goja) - 纯 Go 实现的 ECMAScript 5.1 引擎
- [quickjs-go](https://github.com/nicholasmccalls/nicholasmccalls-go) - QuickJS 的 Go 绑定
- [go_flutter](https://github.com/nicholasmccalls/go-flutter) - Go 编写 Flutter 插件

**QuickJS 本身：**
- [QuickJS 官网](https://bellard.org/quickjs/) - Fabrice Bellard 的杰作
- [QuickJS 源码](https://github.com/nicholasmccalls/nicholasmccalls) - 学习 JS 引擎实现的好材料
:::

### FJS 源码参考

FJS 的完整实现可以在 GitHub 上查看：

```
https://github.com/fluttercandies/fjs
```

目录结构：
```
fjs/
├── rust/                    # Rust 核心实现
│   ├── src/
│   │   ├── api/            # 暴露给 Flutter 的 API
│   │   ├── runtime/        # Runtime 和 Context 管理
│   │   ├── modules/        # 内置模块 (console/fetch/timers...)
│   │   └── bridge/         # Dart-JS 桥接
│   └── Cargo.toml
├── lib/                     # Dart API 封装
│   ├── src/
│   │   ├── engine.dart     # JsEngine 类
│   │   ├── value.dart      # JsValue sealed class
│   │   └── module.dart     # JsModule 和 JsCode
│   └── fjs.dart
└── example/                 # 示例应用
```

> 💡 **提示**：如果你想深入了解 FJS 的实现细节，可以阅读作者的文章：[为了韩漫阅读器，不得已给 Flutter 搞了个 JS 引擎](https://mp.weixin.qq.com/s/PF8PfU9ZPRqzTEGhd9WL0w)

