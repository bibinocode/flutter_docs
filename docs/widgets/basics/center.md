# Center

`Center` 是 Flutter 中最常用的布局组件之一，用于将子组件在其父组件中居中显示。它是 `Align` 组件的简化版本，默认使用 `Alignment.center`。

## 基本用法

```dart
Center(
  child: Text('居中显示的文本'),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| child | Widget? | null | 要居中显示的子组件 |
| widthFactor | double? | null | 宽度因子，Center 宽度 = 子组件宽度 × widthFactor |
| heightFactor | double? | null | 高度因子，Center 高度 = 子组件高度 × heightFactor |

## 使用场景

### 1. 基础居中

```dart
Center(
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
    child: Text('居中盒子'),
  ),
)
```

### 2. 使用 Factor 控制大小

```dart
Center(
  widthFactor: 2.0,  // 宽度是子组件的 2 倍
  heightFactor: 1.5, // 高度是子组件的 1.5 倍
  child: Container(
    width: 100,
    height: 100,
    color: Colors.red,
  ),
)
```

### 3. 加载指示器居中

```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(),
      SizedBox(height: 16),
      Text('加载中...'),
    ],
  ),
)
```

### 4. 空状态页面

```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.inbox, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text(
        '暂无数据',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
      SizedBox(height: 8),
      TextButton(
        onPressed: () {},
        child: Text('点击刷新'),
      ),
    ],
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class CenterDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Center 示例')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '我在中间',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center(
                widthFactor: 1.5,
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.green,
                  alignment: Alignment.center,
                  child: Text('widthFactor: 1.5'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 原理解析

`Center` 继承自 `Align`，源码实现：

```dart
class Center extends Align {
  const Center({
    Key? key, 
    double? widthFactor, 
    double? heightFactor, 
    Widget? child,
  }) : super(
    key: key, 
    widthFactor: widthFactor, 
    heightFactor: heightFactor, 
    child: child,
  );
}
```

## 最佳实践

1. **简单居中用 Center**：比 `Align(alignment: Alignment.center)` 更简洁
2. **需要偏移时用 Align**：Center 只能居中，无法偏移
3. **注意约束传递**：Center 会向子组件传递松约束
4. **与 Expanded 配合**：在 Row/Column 中居中某个区域的内容

## 相关组件

- [Align](https://api.flutter-io.cn/flutter/widgets/Align-class.html) - 更灵活的对齐组件
- [Container](./container.md) - 可通过 alignment 属性居中
- [Stack](../layout/stack.md) - 堆叠布局中的定位

## 官方文档

- [Center API](https://api.flutter-io.cn/flutter/widgets/Center-class.html)
