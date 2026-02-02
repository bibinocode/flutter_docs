# AnimatedFractionallySizedBox

`AnimatedFractionallySizedBox` 是一个隐式动画组件，可以平滑地动画改变子组件相对于父组件的宽高比例。

## 基本用法

```dart
class FractionallySizedBoxDemo extends StatefulWidget {
  const FractionallySizedBoxDemo({super.key});

  @override
  State<FractionallySizedBoxDemo> createState() => _FractionallySizedBoxDemoState();
}

class _FractionallySizedBoxDemoState extends State<FractionallySizedBoxDemo> {
  double _widthFactor = 0.5;
  double _heightFactor = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              widthFactor: _widthFactor,
              heightFactor: _heightFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '动态尺寸',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _widthFactor = 0.3;
                    _heightFactor = 0.3;
                  });
                },
                child: const Text('小'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _widthFactor = 0.6;
                    _heightFactor = 0.6;
                  });
                },
                child: const Text('中'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _widthFactor = 0.9;
                    _heightFactor = 0.9;
                  });
                },
                child: const Text('大'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

## 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `widthFactor` | `double?` | 子组件宽度占父组件的比例 (0.0 - 1.0) |
| `heightFactor` | `double?` | 子组件高度占父组件的比例 (0.0 - 1.0) |
| `alignment` | `AlignmentGeometry` | 子组件在父组件中的对齐方式 |
| `duration` | `Duration` | 动画持续时间 |
| `curve` | `Curve` | 动画曲线 |

## 响应式图片画廊

```dart
class ResponsiveGallery extends StatefulWidget {
  const ResponsiveGallery({super.key});

  @override
  State<ResponsiveGallery> createState() => _ResponsiveGalleryState();
}

class _ResponsiveGalleryState extends State<ResponsiveGallery> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final isExpanded = _expandedIndex == index;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          child: Container(
            color: Colors.grey[300],
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              widthFactor: isExpanded ? 1.0 : 0.8,
              heightFactor: isExpanded ? 1.0 : 0.8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.primaries[index % Colors.primaries.length],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 加载进度指示器

```dart
class LoadingIndicator extends StatefulWidget {
  final double progress; // 0.0 - 1.0

  const LoadingIndicator({
    super.key,
    required this.progress,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          widthFactor: widget.progress,
          heightFactor: 1.0,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlue],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

// 使用示例
class ProgressDemo extends StatefulWidget {
  const ProgressDemo({super.key});

  @override
  State<ProgressDemo> createState() => _ProgressDemoState();
}

class _ProgressDemoState extends State<ProgressDemo> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: LoadingIndicator(progress: _progress),
        ),
        const SizedBox(height: 16),
        Text('${(_progress * 100).toInt()}%'),
        const SizedBox(height: 16),
        Slider(
          value: _progress,
          onChanged: (value) {
            setState(() {
              _progress = value;
            });
          },
        ),
      ],
    );
  }
}
```

## 对齐动画

```dart
class AlignmentDemo extends StatefulWidget {
  const AlignmentDemo({super.key});

  @override
  State<AlignmentDemo> createState() => _AlignmentDemoState();
}

class _AlignmentDemoState extends State<AlignmentDemo> {
  Alignment _alignment = Alignment.center;

  final List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              widthFactor: 0.3,
              heightFactor: 0.3,
              alignment: _alignment,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _alignments.map((alignment) {
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  _alignment = alignment;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _alignment == alignment
                    ? Colors.purple
                    : Colors.grey,
              ),
              child: Text(_getAlignmentName(alignment)),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getAlignmentName(Alignment alignment) {
    if (alignment == Alignment.topLeft) return '左上';
    if (alignment == Alignment.topCenter) return '上中';
    if (alignment == Alignment.topRight) return '右上';
    if (alignment == Alignment.centerLeft) return '左中';
    if (alignment == Alignment.center) return '中心';
    if (alignment == Alignment.centerRight) return '右中';
    if (alignment == Alignment.bottomLeft) return '左下';
    if (alignment == Alignment.bottomCenter) return '下中';
    if (alignment == Alignment.bottomRight) return '右下';
    return '';
  }
}
```

## 注意事项

::: tip 使用场景
- 响应式布局中的尺寸变化
- 进度指示器
- 图片画廊的展开/收起效果
- 自适应卡片布局
:::

::: warning 性能提示
- `widthFactor` 和 `heightFactor` 的值应在 0.0 到 1.0 之间
- 如果设置为 `null`，子组件将使用其自身的尺寸
- 避免频繁改变 factor 值，可能导致性能问题
:::
