# ConstrainedBox

`ConstrainedBox` 是 Flutter 中用于为子组件添加额外约束的组件。它可以设置子组件的最小/最大宽度和高度，控制子组件的尺寸范围，非常适合创建响应式布局和限制组件尺寸。

## 基本用法

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 200,
    minHeight: 50,
    maxHeight: 100,
  ),
  child: Container(
    color: Colors.blue,
    child: Text('受约束的容器'),
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| constraints | BoxConstraints | 必需 | 对子组件施加的约束 |
| child | Widget? | null | 子组件 |

## BoxConstraints 详解

BoxConstraints 用于描述盒子模型的约束条件，包含以下属性：

| 属性 | 类型 | 说明 |
|------|------|------|
| minWidth | double | 最小宽度，默认 0.0 |
| maxWidth | double | 最大宽度，默认 double.infinity |
| minHeight | double | 最小高度，默认 0.0 |
| maxHeight | double | 最大高度，默认 double.infinity |

### 便捷构造函数

```dart
// 宽松约束：最小为 0，最大为指定值
BoxConstraints.loose(Size size)
// 等价于 BoxConstraints(maxWidth: size.width, maxHeight: size.height)

// 紧约束：强制固定尺寸
BoxConstraints.tight(Size size)
// 等价于 BoxConstraints(
//   minWidth: size.width, maxWidth: size.width,
//   minHeight: size.height, maxHeight: size.height,
// )

// 扩展约束：尽可能占满可用空间
BoxConstraints.expand({double? width, double? height})
// 不指定参数时，宽高都会尽可能大
```

### BoxConstraints 示例

```dart
// 宽松约束 - 最大 200x200，可以更小
BoxConstraints.loose(Size(200, 200))

// 紧约束 - 固定 100x100
BoxConstraints.tight(Size(100, 100))

// 扩展约束 - 宽度固定 200，高度尽可能大
BoxConstraints.expand(width: 200)

// 只限制宽度
BoxConstraints(minWidth: 100, maxWidth: 300)

// 只限制高度
BoxConstraints(minHeight: 50, maxHeight: 150)
```

## 使用场景

### 1. 设置最小尺寸

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 200,
    minHeight: 100,
  ),
  child: Container(
    color: Colors.blue,
    child: Text('即使内容少，也保持最小尺寸'),
  ),
)
```

### 2. 限制最大尺寸

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: 400,
    maxHeight: 300,
  ),
  child: Image.network(
    'https://example.com/large-image.jpg',
    fit: BoxFit.contain,
  ),
)
```

### 3. 按钮最小宽度

```dart
ConstrainedBox(
  constraints: BoxConstraints(minWidth: 120),
  child: ElevatedButton(
    onPressed: () {},
    child: Text('OK'),  // 短文本也有足够宽度
  ),
)
```

### 4. 图片最大高度

```dart
ConstrainedBox(
  constraints: BoxConstraints(maxHeight: 200),
  child: Image.network(
    'https://example.com/photo.jpg',
    width: double.infinity,
    fit: BoxFit.cover,
  ),
)
```

### 5. 输入框最大宽度

```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 400),
    child: TextField(
      decoration: InputDecoration(
        labelText: '邮箱',
        border: OutlineInputBorder(),
      ),
    ),
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class ConstrainedBoxDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ConstrainedBox 示例')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('响应式卡片（最小高度 150）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // 响应式卡片 - 设置最小高度
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 150),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.article, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '卡片标题',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text('这是一个响应式卡片，即使内容很少，也会保持最小高度 150 像素。'),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            Text('限制最大宽度的按钮组', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // 限制最大宽度的按钮
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('登录'),
                      ),
                    ),
                    SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text('注册'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            Text('图片最大高度限制', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // 图片最大高度
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 180),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://picsum.photos/800/600',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            SizedBox(height: 24),
            Text('使用 BoxConstraints.expand', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // 使用 expand 填充可用空间
            Container(
              height: 120,
              child: ConstrainedBox(
                constraints: BoxConstraints.expand(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '填充整个可用空间',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
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

## ConstrainedBox vs SizedBox

| 特性 | ConstrainedBox | SizedBox |
|------|----------------|----------|
| 约束类型 | 范围约束（最小/最大） | 固定尺寸约束 |
| 灵活性 | 高，可设置范围 | 低，只能设置固定值 |
| 使用场景 | 限制范围、响应式布局 | 固定尺寸、间距 |
| 代码简洁度 | 较复杂 | 简洁 |

```dart
// SizedBox - 固定 100x100
SizedBox(width: 100, height: 100, child: child)

// ConstrainedBox - 等价写法
ConstrainedBox(
  constraints: BoxConstraints.tight(Size(100, 100)),
  child: child,
)

// ConstrainedBox - 范围约束（SizedBox 无法实现）
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 200,
  ),
  child: child,
)
```

## 最佳实践

1. **优先使用 SizedBox**：固定尺寸时，SizedBox 更简洁
2. **合理设置约束**：避免设置相互矛盾的约束（如 minWidth > maxWidth）
3. **注意父级约束**：ConstrainedBox 的约束会与父级约束合并
4. **响应式布局**：配合 LayoutBuilder 根据屏幕尺寸动态调整
5. **调试约束问题**：使用 Flutter Inspector 查看组件的实际约束

## 相关组件

- [SizedBox](./sizedbox.md) - 固定尺寸盒子
- [UnconstrainedBox](./unconstrainedbox.md) - 取消父级约束
- [LimitedBox](./limitedbox.md) - 在无约束环境下限制尺寸

## 官方文档

- [ConstrainedBox API](https://api.flutter-io.cn/flutter/widgets/ConstrainedBox-class.html)
- [BoxConstraints API](https://api.flutter-io.cn/flutter/rendering/BoxConstraints-class.html)
