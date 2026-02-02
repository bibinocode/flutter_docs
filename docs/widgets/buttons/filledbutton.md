# FilledButton

`FilledButton` 是 Material Design 3 引入的填充按钮，具有实心背景色，是视觉权重最高的按钮类型，用于页面上最重要的操作。

## 基本用法

```dart
FilledButton(
  onPressed: () {
    print('按钮被点击');
  },
  child: Text('填充按钮'),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `onPressed` | `VoidCallback?` | 点击回调，为 null 时按钮禁用 |
| `onLongPress` | `VoidCallback?` | 长按回调 |
| `onHover` | `ValueChanged<bool>?` | 悬停状态变化回调 |
| `onFocusChange` | `ValueChanged<bool>?` | 焦点状态变化回调 |
| `style` | `ButtonStyle?` | 按钮样式 |
| `focusNode` | `FocusNode?` | 焦点节点 |
| `autofocus` | `bool` | 是否自动获取焦点 |
| `clipBehavior` | `Clip` | 裁剪行为 |
| `statesController` | `MaterialStatesController?` | 状态控制器 |
| `child` | `Widget?` | 子组件 |

## 按钮变体

FilledButton 提供两种变体：

| 变体 | 构造函数 | 说明 |
|------|----------|------|
| 标准填充 | `FilledButton()` | 主色背景，高强调 |
| 浅色填充 | `FilledButton.tonal()` | 次要色背景，中等强调 |

## 使用场景

### 1. 标准填充按钮 vs 浅色填充按钮

```dart
class FilledButtonVariants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 标准填充按钮 - 最高强调
        FilledButton(
          onPressed: () {},
          child: Text('确认提交'),
        ),
        SizedBox(height: 16),
        
        // 浅色填充按钮 - 中等强调
        FilledButton.tonal(
          onPressed: () {},
          child: Text('保存草稿'),
        ),
        SizedBox(height: 16),
        
        // 禁用状态
        FilledButton(
          onPressed: null,
          child: Text('禁用按钮'),
        ),
      ],
    );
  }
}
```

### 2. 带图标的按钮

```dart
class FilledButtonWithIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 使用 icon 构造函数
        FilledButton.icon(
          onPressed: () {},
          icon: Icon(Icons.send),
          label: Text('发送'),
        ),
        SizedBox(height: 16),
        
        // tonal 变体带图标
        FilledButton.tonalIcon(
          onPressed: () {},
          icon: Icon(Icons.save),
          label: Text('保存'),
        ),
        SizedBox(height: 16),
        
        // 手动组合图标
        FilledButton(
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download, size: 18),
              SizedBox(width: 8),
              Text('下载'),
            ],
          ),
        ),
      ],
    );
  }
}
```

### 3. 自定义样式

```dart
class CustomFilledButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 自定义颜色
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('成功操作'),
        ),
        SizedBox(height: 16),
        
        // 自定义形状和大小
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            minimumSize: Size(200, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text('圆角按钮'),
        ),
        SizedBox(height: 16),
        
        // 完全自定义
        FilledButton(
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.deepPurple;
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.purple.shade700;
              }
              return Colors.purple;
            }),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) return 0;
              if (states.contains(WidgetState.hovered)) return 4;
              return 2;
            }),
          ),
          child: Text('自定义按钮'),
        ),
      ],
    );
  }
}
```

### 4. 加载状态按钮

```dart
class LoadingFilledButton extends StatefulWidget {
  @override
  State<LoadingFilledButton> createState() => _LoadingFilledButtonState();
}

class _LoadingFilledButtonState extends State<LoadingFilledButton> {
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    
    // 模拟网络请求
    await Future.delayed(Duration(seconds: 2));
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: FilledButton.styleFrom(
        minimumSize: Size(150, 48),
      ),
      child: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text('提交'),
    );
  }
}
```

### 5. 按钮组对话框

```dart
class ConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '确认删除此项目？',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              '此操作不可撤销',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 次要操作 - 使用 tonal
                FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消'),
                ),
                SizedBox(width: 12),
                // 主要操作 - 危险操作用红色
                FilledButton(
                  onPressed: () {
                    // 执行删除
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('删除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class FilledButtonDemo extends StatefulWidget {
  @override
  State<FilledButtonDemo> createState() => _FilledButtonDemoState();
}

class _FilledButtonDemoState extends State<FilledButtonDemo> {
  bool _isSubscribed = false;
  bool _isLoading = false;

  Future<void> _toggleSubscription() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      _isSubscribed = !_isSubscribed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FilledButton 示例')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 按钮类型对比
            _buildSection(
              '按钮类型对比',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: Text('Filled'),
                  ),
                  FilledButton.tonal(
                    onPressed: () {},
                    child: Text('Tonal'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Elevated'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text('Outlined'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Text'),
                  ),
                ],
              ),
            ),
            
            // 带图标按钮
            _buildSection(
              '带图标按钮',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add),
                    label: Text('新建'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: Icon(Icons.edit),
                    label: Text('编辑'),
                  ),
                ],
              ),
            ),
            
            // 订阅按钮
            _buildSection(
              '订阅按钮',
              Center(
                child: _isSubscribed
                    ? FilledButton.tonal(
                        onPressed: _isLoading ? null : _toggleSubscription,
                        style: FilledButton.styleFrom(
                          minimumSize: Size(140, 48),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 18),
                                  SizedBox(width: 8),
                                  Text('已订阅'),
                                ],
                              ),
                      )
                    : FilledButton(
                        onPressed: _isLoading ? null : _toggleSubscription,
                        style: FilledButton.styleFrom(
                          minimumSize: Size(140, 48),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('订阅'),
                      ),
              ),
            ),
            
            // 尺寸变体
            _buildSection(
              '尺寸变体',
              Column(
                children: [
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 36),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: Text('小型按钮'),
                  ),
                  SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text('标准按钮'),
                  ),
                  SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('大型按钮'),
                  ),
                ],
              ),
            ),
            
            // 按钮状态
            _buildSection(
              '按钮状态',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: Text('正常'),
                  ),
                  FilledButton(
                    onPressed: null,
                    child: Text('禁用'),
                  ),
                  FilledButton.tonal(
                    onPressed: () {},
                    child: Text('Tonal'),
                  ),
                  FilledButton.tonal(
                    onPressed: null,
                    child: Text('Tonal 禁用'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
```

## 最佳实践

### 1. 选择合适的按钮类型

```dart
// ✅ 页面主要操作 - 使用 FilledButton
FilledButton(
  onPressed: _submitForm,
  child: Text('提交订单'),
)

// ✅ 次要但重要的操作 - 使用 FilledButton.tonal
FilledButton.tonal(
  onPressed: _saveDraft,
  child: Text('保存草稿'),
)

// ✅ 一般操作 - 使用 OutlinedButton 或 TextButton
TextButton(
  onPressed: _cancel,
  child: Text('取消'),
)
```

### 2. 按钮优先级搭配

```dart
// 对话框按钮：取消(低) + 确认(高)
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('取消'),
    ),
    SizedBox(width: 8),
    FilledButton(
      onPressed: _confirm,
      child: Text('确认'),
    ),
  ],
)
```

### 3. 避免过度使用

```dart
// ❌ 错误：多个高强调按钮造成视觉混乱
Row(
  children: [
    FilledButton(onPressed: () {}, child: Text('操作1')),
    FilledButton(onPressed: () {}, child: Text('操作2')),
    FilledButton(onPressed: () {}, child: Text('操作3')),
  ],
)

// ✅ 正确：分清主次
Row(
  children: [
    FilledButton(onPressed: () {}, child: Text('主要')),
    FilledButton.tonal(onPressed: () {}, child: Text('次要')),
    TextButton(onPressed: () {}, child: Text('更多')),
  ],
)
```

### 4. 全局主题配置

```dart
MaterialApp(
  theme: ThemeData(
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
)
```

## 与其他按钮对比

| 按钮类型 | 强调程度 | 适用场景 |
|----------|----------|----------|
| `FilledButton` | 最高 | 页面主要操作（提交、确认） |
| `FilledButton.tonal` | 高 | 重要但非首要操作 |
| `ElevatedButton` | 中高 | 需要突出的操作 |
| `OutlinedButton` | 中 | 次要操作 |
| `TextButton` | 低 | 辅助操作（取消、跳过） |

## 相关组件

- [ElevatedButton](./elevatedbutton.md) - 凸起按钮
- [OutlinedButton](./outlinedbutton.md) - 轮廓按钮
- [TextButton](./textbutton.md) - 文本按钮
- [IconButton](./iconbutton.md) - 图标按钮

## 官方文档

- [FilledButton API](https://api.flutter.dev/flutter/material/FilledButton-class.html)
- [Material Design 3 Buttons](https://m3.material.io/components/buttons/overview)
