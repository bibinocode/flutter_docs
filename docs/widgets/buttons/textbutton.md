# TextButton

`TextButton` 是 Material Design 文本按钮组件，没有背景颜色和阴影，通常用于次要操作或在卡片、对话框中使用。在 Material 3 中是最低强调级别的按钮。

## 基本用法

```dart
TextButton(
  onPressed: () {
    print('按钮被点击');
  },
  child: Text('文本按钮'),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| onPressed | VoidCallback? | null | 点击回调，null 时按钮禁用 |
| onLongPress | VoidCallback? | null | 长按回调 |
| style | ButtonStyle? | null | 按钮样式 |
| focusNode | FocusNode? | null | 焦点节点 |
| autofocus | bool | false | 是否自动获取焦点 |
| clipBehavior | Clip | Clip.none | 裁剪行为 |
| child | Widget | required | 按钮内容 |

## 使用场景

### 1. 基础文本按钮

```dart
TextButton(
  onPressed: () {},
  child: Text('点击我'),
)

// 带图标
TextButton.icon(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('添加'),
)
```

### 2. 自定义样式

```dart
TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: Colors.purple,
    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  child: Text('自定义样式'),
)
```

### 3. 禁用状态

```dart
TextButton(
  onPressed: null,  // null 表示禁用
  child: Text('禁用按钮'),
)
```

### 4. 在对话框中使用

```dart
AlertDialog(
  title: Text('确认删除'),
  content: Text('确定要删除这条记录吗？'),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('取消'),
    ),
    TextButton(
      onPressed: () {
        // 执行删除
        Navigator.pop(context, true);
      },
      style: TextButton.styleFrom(foregroundColor: Colors.red),
      child: Text('删除'),
    ),
  ],
)
```

### 5. 带涟漪效果自定义

```dart
TextButton(
  onPressed: () {},
  style: ButtonStyle(
    overlayColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.1)),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.blue[700];
      }
      return Colors.blue;
    }),
  ),
  child: Text('自定义涟漪'),
)
```

## ButtonStyle 详解

```dart
TextButton(
  onPressed: () {},
  style: ButtonStyle(
    // 前景色（文字和图标颜色）
    foregroundColor: WidgetStateProperty.all(Colors.blue),
    // 背景色
    backgroundColor: WidgetStateProperty.all(Colors.transparent),
    // 覆盖层颜色（点击涟漪）
    overlayColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.1)),
    // 阴影颜色
    shadowColor: WidgetStateProperty.all(Colors.transparent),
    // 阴影高度
    elevation: WidgetStateProperty.all(0),
    // 内边距
    padding: WidgetStateProperty.all(EdgeInsets.all(16)),
    // 最小尺寸
    minimumSize: WidgetStateProperty.all(Size(64, 36)),
    // 边框形状
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    // 文字样式
    textStyle: WidgetStateProperty.all(
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
  child: Text('完全自定义'),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class TextButtonDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TextButton 示例')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基础按钮
            TextButton(
              onPressed: () {},
              child: Text('基础文本按钮'),
            ),
            SizedBox(height: 16),
            
            // 带图标按钮
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.favorite_border),
              label: Text('喜欢'),
            ),
            SizedBox(height: 16),
            
            // 自定义颜色
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
              child: Text('绿色按钮'),
            ),
            SizedBox(height: 16),
            
            // 禁用状态
            TextButton(
              onPressed: null,
              child: Text('禁用状态'),
            ),
            
            Divider(height: 32),
            
            // 在卡片中使用
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('文章标题', style: Theme.of(context).textTheme.titleMedium),
                    Text('文章摘要...'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(child: Text('分享'), onPressed: () {}),
                        TextButton(child: Text('阅读'), onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 主题配置

```dart
MaterialApp(
  theme: ThemeData(
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  ),
)
```

## 最佳实践

1. **次要操作使用**：主要操作用 ElevatedButton/FilledButton
2. **对话框按钮**：常用于 AlertDialog 的 actions
3. **卡片内按钮**：避免过多按钮，保持简洁
4. **无障碍**：确保文字大小和点击区域足够
5. **状态反馈**：加载时禁用并显示进度

## 相关组件

- [ElevatedButton](./elevatedbutton.md) - 凸起按钮
- [OutlinedButton](./outlinedbutton.md) - 轮廓按钮
- [FilledButton](./filledbutton.md) - 填充按钮 (M3)
- [IconButton](./iconbutton.md) - 图标按钮

## 官方文档

- [TextButton API](https://api.flutter-io.cn/flutter/material/TextButton-class.html)
- [Material Design Buttons](https://m3.material.io/components/buttons)
