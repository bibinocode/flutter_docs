# FittedBox

`FittedBox` 是 Flutter 中用于缩放并定位子组件以适应父容器的组件。它会根据指定的 `fit` 模式自动调整子组件的大小，使其在父容器约束范围内以最佳方式显示，非常适合图片缩放、文字自适应等场景。

## 基本用法

```dart
FittedBox(
  fit: BoxFit.contain,
  child: Text(
    'Hello Flutter',
    style: TextStyle(fontSize: 100),
  ),
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| fit | BoxFit | BoxFit.contain | 子组件如何适应父容器 |
| alignment | Alignment | Alignment.center | 子组件在父容器中的对齐方式 |
| clipBehavior | Clip | Clip.none | 子组件超出边界时的裁剪行为 |
| child | Widget? | null | 要缩放的子组件 |

## BoxFit 缩放模式

| 值 | 说明 |
|-----|------|
| fill | 拉伸填充整个父容器，可能改变宽高比 |
| contain | 保持宽高比，尽可能大地填充父容器，可能留有空白 |
| cover | 保持宽高比，完全覆盖父容器，可能裁剪部分内容 |
| fitWidth | 保持宽高比，宽度填满父容器 |
| fitHeight | 保持宽高比，高度填满父容器 |
| none | 不缩放，保持原始大小，可能超出边界 |
| scaleDown | 仅当子组件超出时缩小，否则保持原始大小 |

## 使用场景

### 1. 图片缩放

```dart
Container(
  width: 200,
  height: 150,
  color: Colors.grey[200],
  child: FittedBox(
    fit: BoxFit.cover,
    clipBehavior: Clip.hardEdge,
    child: Image.network(
      'https://picsum.photos/400/300',
    ),
  ),
)
```

### 2. 文字自适应

```dart
Container(
  width: 100,
  height: 40,
  child: FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      '这是一段很长的文字会自动缩小',
      style: TextStyle(fontSize: 20),
    ),
  ),
)
```

### 3. 图标缩放

```dart
Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(16),
  ),
  child: FittedBox(
    fit: BoxFit.contain,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Icon(
        Icons.flutter_dash,
        color: Colors.white,
      ),
    ),
  ),
)
```

### 4. 自适应按钮文字

```dart
SizedBox(
  width: 80,
  child: ElevatedButton(
    onPressed: () {},
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text('确认提交订单'),
    ),
  ),
)
```

### 5. 数字显示自适应

```dart
Container(
  width: 60,
  height: 60,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: FittedBox(
    fit: BoxFit.scaleDown,
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        '99999',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';

class FittedBoxDemo extends StatefulWidget {
  @override
  State<FittedBoxDemo> createState() => _FittedBoxDemoState();
}

class _FittedBoxDemoState extends State<FittedBoxDemo> {
  BoxFit _fit = BoxFit.contain;
  double _containerWidth = 200;
  double _containerHeight = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FittedBox - 响应式 Logo')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 控制面板
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BoxFit 模式:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BoxFit.values.map((fit) => ChoiceChip(
                        label: Text(fit.name),
                        selected: _fit == fit,
                        onSelected: (_) => setState(() => _fit = fit),
                      )).toList(),
                    ),
                    SizedBox(height: 16),
                    Text('容器宽度: ${_containerWidth.toInt()}'),
                    Slider(
                      value: _containerWidth,
                      min: 80,
                      max: 300,
                      onChanged: (v) => setState(() => _containerWidth = v),
                    ),
                    Text('容器高度: ${_containerHeight.toInt()}'),
                    Slider(
                      value: _containerHeight,
                      min: 40,
                      max: 200,
                      onChanged: (v) => setState(() => _containerHeight = v),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // 响应式 Logo 预览
            Text('响应式 Logo 效果:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Center(
              child: Container(
                width: _containerWidth,
                height: _containerHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: _fit,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlutterLogo(size: 48),
                        SizedBox(width: 12),
                        Text(
                          'Flutter',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),

            // BoxFit 效果对比
            Text('BoxFit 效果对比:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildComparisonGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: BoxFit.values.map((fit) => Column(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FittedBox(
              fit: fit,
              clipBehavior: Clip.hardEdge,
              child: Container(
                width: 150,
                height: 100,
                color: Colors.blue.withOpacity(0.3),
                child: Center(
                  child: Icon(Icons.image, size: 40, color: Colors.blue),
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(fit.name, style: TextStyle(fontSize: 12)),
        ],
      )).toList(),
    );
  }
}
```

## 最佳实践

### BoxFit 效果对比

| BoxFit | 特点 | 适用场景 |
|--------|------|----------|
| contain | 完整显示，可能留白 | Logo、图标、需要完整展示的内容 |
| cover | 填满容器，可能裁剪 | 背景图、封面图 |
| fill | 拉伸填满，会变形 | 不关注比例的装饰元素 |
| fitWidth | 宽度优先 | 横幅、宽图 |
| fitHeight | 高度优先 | 竖图、侧边栏图 |
| scaleDown | 只缩不放 | 自适应文字、避免放大模糊 |
| none | 原始尺寸 | 需要精确控制的场景 |

### 使用建议

1. **文字自适应**：使用 `BoxFit.scaleDown`，避免文字被放大而模糊
2. **图片适配**：根据需求选择 `contain`（完整显示）或 `cover`（填满裁剪）
3. **配合 clipBehavior**：当使用 `cover` 或 `none` 时，设置 `clipBehavior: Clip.hardEdge` 防止溢出
4. **响应式布局**：`FittedBox` 非常适合在不同屏幕尺寸下保持内容比例
5. **避免无限约束**：`FittedBox` 的父组件需要提供有限的约束，否则无法正确计算缩放

### 常见问题

```dart
// ❌ 错误：在无约束的 Column 中使用
Column(
  children: [
    FittedBox(child: Text('文字')),  // 可能无法正确缩放
  ],
)

// ✅ 正确：提供明确的约束
Column(
  children: [
    SizedBox(
      width: 100,
      child: FittedBox(child: Text('文字')),
    ),
  ],
)
```

## 相关组件

- [AspectRatio](aspectratio.md) - 按指定宽高比约束子组件
- [OverflowBox](overflowbox.md) - 允许子组件超出父容器边界
- [SizedOverflowBox](sizedoverflowbox.md) - 指定尺寸但允许子组件溢出
