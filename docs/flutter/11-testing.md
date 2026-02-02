# 测试与调试

高质量的应用离不开完善的测试。本章介绍 Flutter 的测试框架、调试技巧和性能优化方法。

## 测试类型概览

Flutter 支持三种测试类型：

| 类型 | 特点 | 速度 | 信心度 |
|------|------|------|--------|
| 单元测试 | 测试单个函数/类 | 快 | 低 |
| Widget 测试 | 测试 UI 组件 | 中 | 中 |
| 集成测试 | 测试完整应用 | 慢 | 高 |

## 单元测试

### 基本设置

```yaml
dev_dependencies:
  test: ^1.24.9
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### 编写测试

```dart
// test/calculator_test.dart
import 'package:test/test.dart';
import 'package:my_app/calculator.dart';

void main() {
  group('Calculator', () {
    late Calculator calculator;
    
    setUp(() {
      calculator = Calculator();
    });
    
    tearDown(() {
      // 清理资源
    });
    
    test('加法运算', () {
      expect(calculator.add(2, 3), equals(5));
    });
    
    test('减法运算', () {
      expect(calculator.subtract(5, 3), equals(2));
    });
    
    test('除以零抛出异常', () {
      expect(
        () => calculator.divide(10, 0),
        throwsA(isA&lt;DivisionByZeroException&gt;()),
      );
    });
    
    test('乘法运算 - 多种情况', () {
      expect(calculator.multiply(2, 3), 6);
      expect(calculator.multiply(-2, 3), -6);
      expect(calculator.multiply(0, 100), 0);
    });
  });
}
```

### 常用匹配器

```dart
test('常用匹配器示例', () {
  // 相等
  expect(1 + 1, equals(2));
  expect(result, isNotNull);
  expect(list, isEmpty);
  expect(list, isNotEmpty);
  
  // 类型检查
  expect(value, isA&lt;String&gt;());
  expect(error, isA&lt;FormatException&gt;());
  
  // 集合
  expect([1, 2, 3], contains(2));
  expect([1, 2, 3], containsAll([1, 2]));
  expect({'a': 1, 'b': 2}, containsPair('a', 1));
  
  // 比较
  expect(10, greaterThan(5));
  expect(10, lessThanOrEqualTo(10));
  expect(5, inInclusiveRange(1, 10));
  
  // 字符串
  expect('hello world', contains('world'));
  expect('hello', startsWith('he'));
  expect('hello', endsWith('lo'));
  expect('hello', matches(RegExp(r'h.*o')));
  
  // 异常
  expect(() => throw Exception('error'), throwsException);
  expect(() => throw FormatException(), throwsFormatException);
  expect(
    () => throw CustomException('msg'),
    throwsA(
      predicate&lt;CustomException&gt;((e) => e.message == 'msg'),
    ),
  );
});
```

### Mock 对象

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// 生成 Mock 类
@GenerateMocks([UserRepository, HttpClient])
import 'user_service_test.mocks.dart';

void main() {
  group('UserService', () {
    late MockUserRepository mockRepository;
    late UserService userService;
    
    setUp(() {
      mockRepository = MockUserRepository();
      userService = UserService(mockRepository);
    });
    
    test('获取用户成功', () async {
      // 设置 mock 行为
      when(mockRepository.getUser('123')).thenAnswer(
        (_) async => User(id: '123', name: 'Alice'),
      );
      
      final user = await userService.getUser('123');
      
      expect(user.name, 'Alice');
      verify(mockRepository.getUser('123')).called(1);
    });
    
    test('获取用户失败', () async {
      when(mockRepository.getUser(any)).thenThrow(
        NetworkException('网络错误'),
      );
      
      expect(
        () => userService.getUser('123'),
        throwsA(isA&lt;NetworkException&gt;()),
      );
    });
    
    test('验证调用顺序', () async {
      when(mockRepository.getUser(any))
          .thenAnswer((_) async => User(id: '1', name: 'Test'));
      
      await userService.getUser('1');
      await userService.getUser('2');
      
      verifyInOrder([
        mockRepository.getUser('1'),
        mockRepository.getUser('2'),
      ]);
    });
  });
}
```

### 异步测试

```dart
test('异步操作', () async {
  final result = await asyncFunction();
  expect(result, equals(expectedValue));
});

test('Stream 测试', () async {
  final stream = numberStream();
  
  await expectLater(
    stream,
    emitsInOrder([1, 2, 3, emitsDone]),
  );
});

test('Stream 错误', () async {
  final stream = errorStream();
  
  await expectLater(
    stream,
    emitsError(isA&lt;Exception&gt;()),
  );
});

test('超时测试', () async {
  await expectLater(
    slowOperation(),
    completes,
  );
}, timeout: Timeout(Duration(seconds: 30)));
```

## Widget 测试

### 基本 Widget 测试

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/widgets/counter.dart';

void main() {
  testWidgets('Counter 初始值为 0', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CounterWidget()),
    );
    
    expect(find.text('0'), findsOneWidget);
  });
  
  testWidgets('点击加号按钮增加计数', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CounterWidget()),
    );
    
    // 找到并点击按钮
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();  // 触发重建
    
    expect(find.text('1'), findsOneWidget);
  });
  
  testWidgets('连续点击', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CounterWidget()),
    );
    
    // 多次点击
    for (int i = 0; i < 5; i++) {
      await tester.tap(find.byIcon(Icons.add));
    }
    await tester.pump();
    
    expect(find.text('5'), findsOneWidget);
  });
});
```

### Finder 查找器

```dart
testWidgets('查找 Widget', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 按类型查找
  find.byType(ElevatedButton);
  find.byType(Text);
  
  // 按文本查找
  find.text('Hello');
  find.textContaining('Hello');
  
  // 按 Key 查找
  find.byKey(Key('submit_button'));
  find.byKey(ValueKey(item.id));
  
  // 按图标查找
  find.byIcon(Icons.add);
  
  // 按 Widget 查找
  find.byWidget(myWidget);
  
  // 组合查找
  find.descendant(
    of: find.byType(Card),
    matching: find.text('Title'),
  );
  
  find.ancestor(
    of: find.text('Item'),
    matching: find.byType(ListView),
  );
  
  // 自定义查找
  find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains('error') == true,
  );
});
```

### 交互操作

```dart
testWidgets('用户交互', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 点击
  await tester.tap(find.byType(ElevatedButton));
  
  // 长按
  await tester.longPress(find.byType(ListTile));
  
  // 输入文本
  await tester.enterText(find.byType(TextField), 'Hello');
  
  // 拖拽
  await tester.drag(find.byType(Slider), Offset(100, 0));
  
  // 滚动
  await tester.fling(find.byType(ListView), Offset(0, -500), 1000);
  
  // 下拉刷新
  await tester.fling(find.byType(RefreshIndicator), Offset(0, 300), 1000);
  
  // 等待动画完成
  await tester.pumpAndSettle();
});
```

### 测试异步 Widget

```dart
testWidgets('加载状态', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: UserProfilePage(userId: '123'),
    ),
  );
  
  // 初始加载状态
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  
  // 等待异步操作完成
  await tester.pumpAndSettle();
  
  // 加载完成后显示内容
  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(find.text('Alice'), findsOneWidget);
});

testWidgets('错误状态', (tester) async {
  // 使用 Mock
  final mockService = MockUserService();
  when(mockService.getUser(any)).thenThrow(Exception('Network error'));
  
  await tester.pumpWidget(
    MaterialApp(
      home: Provider&lt;UserService&gt;.value(
        value: mockService,
        child: UserProfilePage(userId: '123'),
      ),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.text('加载失败'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);  // 重试按钮
});
```

### Golden 测试（截图测试）

```dart
testWidgets('UI 截图测试', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MyHomePage(),
    ),
  );
  
  await expectLater(
    find.byType(MyHomePage),
    matchesGoldenFile('goldens/home_page.png'),
  );
});

// 更新 Golden 文件
// flutter test --update-goldens
```

## 集成测试

### 设置

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

### 编写集成测试

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('完整用户流程测试', () {
    testWidgets('登录 -> 浏览 -> 退出', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 登录
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // 验证登录成功
      expect(find.text('首页'), findsOneWidget);
      
      // 浏览商品
      await tester.tap(find.text('商品列表'));
      await tester.pumpAndSettle();
      
      expect(find.byType(ProductCard), findsWidgets);
      
      // 退出登录
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('退出登录'));
      await tester.pumpAndSettle();
      
      // 验证返回登录页
      expect(find.byKey(Key('login_button')), findsOneWidget);
    });
  });
}
```

### 运行集成测试

```bash
# 运行集成测试
flutter test integration_test/app_test.dart

# 在真机上运行
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## 调试技巧

### 断点和日志

```dart
// 使用 debugPrint（不会被 release 模式移除）
debugPrint('Debug info: $value');

// 使用 log（更详细的日志）
import 'dart:developer';
log('Message', name: 'MyApp', error: exception);

// 条件断点
void myFunction(int value) {
  if (value > 100) {
    debugger();  // 仅在条件满足时暂停
  }
}

// 时间线事件
import 'dart:developer';
Timeline.startSync('Operation');
// ... 执行操作
Timeline.finishSync();
```

### DevTools

```dart
// 启动 DevTools
// 在 VS Code 中：View -> Command Palette -> Dart: Open DevTools

// Inspector
// - Widget 树查看
// - 属性检查
// - 布局调试

// Performance
// - 帧率监控
// - CPU 分析

// Memory
// - 内存使用
// - 泄漏检测
```

### Widget Inspector

```dart
// 在代码中高亮 Widget
debugDumpApp();  // 打印整个 Widget 树

// 检查 RenderObject
debugDumpRenderTree();

// 检查 Layer 树
debugDumpLayerTree();

// 显示性能覆盖层
MaterialApp(
  showPerformanceOverlay: true,
  ...
)

// 显示语义调试
MaterialApp(
  showSemanticsDebugger: true,
  ...
)
```

### 布局调试

```dart
// 显示布局边界
debugPaintSizeEnabled = true;

// 显示基线
debugPaintBaselinesEnabled = true;

// 显示指针点击区域
debugPaintPointersEnabled = true;

// 在 MaterialApp 中启用
MaterialApp(
  debugShowCheckedModeBanner: false,
  checkerboardRasterCacheImages: true,
  checkerboardOffscreenLayers: true,
)
```

## 性能优化

### 识别性能问题

```dart
// Profile 模式运行
// flutter run --profile

// 性能覆盖层
MaterialApp(
  showPerformanceOverlay: true,
)

// 检查构建次数
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('MyWidget build');  // 观察构建频率
    return ...;
  }
}
```

### 减少重建

```dart
// 1. 使用 const 构造函数
const Text('Hello');
const SizedBox(height: 16);
const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.star));

// 2. 拆分 Widget
// ❌ 整个列表因为一个项目更新而重建
class BadList extends StatelessWidget {
  final List&lt;Item&gt; items;
  final int selectedIndex;  // 变化频繁
  
  Widget build(context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemTile(
          item: items[index],
          selected: index == selectedIndex,
        );
      },
    );
  }
}

// ✅ 只有选中状态变化的项目重建
class GoodList extends StatelessWidget {
  final List&lt;Item&gt; items;
  
  Widget build(context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return SelectableItemTile(  // 内部管理选中状态
          item: items[index],
        );
      },
    );
  }
}

// 3. 使用 RepaintBoundary
RepaintBoundary(
  child: ComplexAnimatedWidget(),
)
```

### 列表优化

```dart
// 使用 ListView.builder 而不是 ListView
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// 添加 itemExtent 或 prototypeItem
ListView.builder(
  itemCount: 1000,
  itemExtent: 56.0,  // 固定高度，提升性能
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// 使用 AutomaticKeepAliveClientMixin
class _MyListItemState extends State&lt;MyListItem&gt;
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);  // 必须调用
    return ...;
  }
}
```

### 图片优化

```dart
// 缓存图片
Image.network(
  'https://example.com/image.jpg',
  cacheWidth: 200,  // 缩略图尺寸
  cacheHeight: 200,
)

// 使用 cached_network_image
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// 预缓存图片
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/large_image.png'), context);
}
```

### 异步优化

```dart
// 使用 compute 处理耗时操作
Future&lt;List&lt;Item&gt;&gt; parseItems(String json) async {
  return compute(_parseItems, json);
}

List&lt;Item&gt; _parseItems(String json) {
  final data = jsonDecode(json) as List;
  return data.map((e) => Item.fromJson(e)).toList();
}

// 防抖搜索
class _SearchState extends State&lt;Search&gt; {
  Timer? _debounce;
  
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

## 测试覆盖率

```bash
# 生成覆盖率报告
flutter test --coverage

# 查看报告（需要 lcov）
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 最佳实践

### 测试命名规范

```dart
// 使用描述性名称
test('当用户输入有效邮箱时_应返回 true', () {});
test('当列表为空时_应显示空状态提示', () {});
test('当网络请求失败时_应显示错误信息并提供重试按钮', () {});
```

### 测试文件组织

```
test/
├── unit/
│   ├── models/
│   │   └── user_test.dart
│   ├── services/
│   │   └── auth_service_test.dart
│   └── utils/
│       └── validators_test.dart
├── widget/
│   ├── screens/
│   │   └── login_screen_test.dart
│   └── components/
│       └── user_card_test.dart
└── integration/
    └── app_test.dart
```

### AAA 模式

```dart
test('用户登录', () async {
  // Arrange - 准备
  final authService = MockAuthService();
  when(authService.login(any, any))
      .thenAnswer((_) async => User(id: '1', name: 'Test'));
  final viewModel = LoginViewModel(authService);
  
  // Act - 执行
  await viewModel.login('test@example.com', 'password');
  
  // Assert - 断言
  expect(viewModel.user, isNotNull);
  expect(viewModel.isLoggedIn, isTrue);
  verify(authService.login('test@example.com', 'password')).called(1);
});
```

## 下一步

掌握测试与调试后，下一章我们将学习 [发布部署](./12-deployment)，将应用发布到应用商店。
