# Text

`Text` 是 Flutter 中最基础的文本显示组件，用于展示单一样式的文本字符串。

## 基本用法

```dart
Text('Hello, Flutter!')
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `data` | `String` | 要显示的文本内容（必需） |
| `style` | `TextStyle?` | 文本样式 |
| `textAlign` | `TextAlign?` | 文本对齐方式 |
| `textDirection` | `TextDirection?` | 文本方向（从左到右或从右到左） |
| `softWrap` | `bool?` | 是否自动换行 |
| `overflow` | `TextOverflow?` | 溢出处理方式 |
| `maxLines` | `int?` | 最大显示行数 |
| `textScaler` | `TextScaler?` | 文本缩放比例 |
| `semanticsLabel` | `String?` | 无障碍标签 |

## TextStyle 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `fontSize` | `double?` | 字体大小 |
| `fontWeight` | `FontWeight?` | 字体粗细 |
| `fontStyle` | `FontStyle?` | 字体样式（normal/italic） |
| `color` | `Color?` | 文字颜色 |
| `backgroundColor` | `Color?` | 背景颜色 |
| `letterSpacing` | `double?` | 字母间距 |
| `wordSpacing` | `double?` | 单词间距 |
| `height` | `double?` | 行高倍数 |
| `decoration` | `TextDecoration?` | 装饰线（下划线、删除线等） |
| `shadows` | `List&lt;Shadow&gt;?` | 文字阴影 |
| `fontFamily` | `String?` | 字体 |

## 使用场景

### 1. 基础文本显示

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // 普通文本
    Text('普通文本'),
    
    // 带样式的文本
    Text(
      '粗体蓝色文本',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ),
    
    // 斜体带下划线
    Text(
      '斜体下划线文本',
      style: TextStyle(
        fontStyle: FontStyle.italic,
        decoration: TextDecoration.underline,
        decorationColor: Colors.red,
        decorationStyle: TextDecorationStyle.wavy,
      ),
    ),
  ],
)
```

### 2. 文本溢出处理

```dart
Container(
  width: 200,
  child: Column(
    children: [
      // 省略号
      Text(
        '这是一段很长很长的文本，超出部分会用省略号显示',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      
      // 渐变消失
      Text(
        '这是一段很长很长的文本，超出部分会渐变消失',
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      
      // 裁剪
      Text(
        '这是一段很长很长的文本，超出部分会被裁剪',
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    ],
  ),
)
```

### 3. 文本对齐

```dart
Container(
  width: 300,
  child: Column(
    children: [
      Text('左对齐（默认）', textAlign: TextAlign.left),
      Text('居中对齐', textAlign: TextAlign.center),
      Text('右对齐', textAlign: TextAlign.right),
      Text('两端对齐：这是一段较长的文本用于演示两端对齐效果', 
           textAlign: TextAlign.justify),
    ],
  ),
)
```

### 4. 使用主题样式

```dart
Column(
  children: [
    // 使用 Material 3 预设样式
    Text(
      'Display Large',
      style: Theme.of(context).textTheme.displayLarge,
    ),
    Text(
      'Headline Medium',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
    Text(
      'Title Large',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    Text(
      'Body Medium',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    Text(
      'Label Small',
      style: Theme.of(context).textTheme.labelSmall,
    ),
  ],
)
```

### 5. 自定义字体

```dart
// 1. 在 pubspec.yaml 中添加字体
// fonts:
//   - family: CustomFont
//     fonts:
//       - asset: fonts/CustomFont-Regular.ttf
//       - asset: fonts/CustomFont-Bold.ttf
//         weight: 700

// 2. 使用自定义字体
Text(
  '使用自定义字体',
  style: TextStyle(
    fontFamily: 'CustomFont',
    fontSize: 24,
  ),
)
```

### 6. 文字阴影和渐变

```dart
// 带阴影的文字
Text(
  '带阴影的文字',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.3),
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  ),
)

// 渐变文字
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    colors: [Colors.blue, Colors.purple, Colors.pink],
  ).createShader(bounds),
  child: Text(
    '渐变文字效果',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white, // 必须设置为白色
    ),
  ),
)
```

## Text vs RichText

| 特性 | Text | RichText |
|------|------|----------|
| 使用场景 | 单一样式文本 | 多样式混合文本 |
| 性能 | 更高 | 略低 |
| 灵活性 | 较低 | 高 |
| 默认继承主题 | 是 | 否 |

```dart
// 需要多样式时使用 RichText 或 Text.rich
Text.rich(
  TextSpan(
    text: '你好，',
    style: TextStyle(color: Colors.black),
    children: [
      TextSpan(
        text: 'Flutter',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      TextSpan(text: '！'),
    ],
  ),
)
```

## 最佳实践

1. **使用主题样式**: 优先使用 `Theme.of(context).textTheme` 保持一致性
2. **处理溢出**: 对于动态内容，始终设置 `maxLines` 和 `overflow`
3. **无障碍**: 对于图标文字，提供 `semanticsLabel`
4. **性能**: 避免在 `TextStyle` 中创建不必要的对象
5. **国际化**: 使用 `textDirection` 支持 RTL 语言

## 相关组件

- [RichText](./richtext) - 多样式文本
- [SelectableText](./selectabletext) - 可选择文本
- [DefaultTextStyle](./defaulttextstyle) - 默认文本样式

## 官方文档

- [Text API](https://api.flutter.dev/flutter/widgets/Text-class.html)
- [TextStyle API](https://api.flutter.dev/flutter/painting/TextStyle-class.html)
- [Material Typography](https://m3.material.io/styles/typography)
