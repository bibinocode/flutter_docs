# Slider

`Slider` 是 Material Design 风格的滑块组件，允许用户通过拖动滑块在一定范围内选择一个值。它常用于音量控制、亮度调节、价格筛选等需要连续数值输入的场景。

## 基本用法

```dart
double _value = 50.0;

Slider(
  value: _value,
  min: 0.0,
  max: 100.0,
  onChanged: (double newValue) {
    setState(() {
      _value = newValue;
    });
  },
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| value | double | 必需 | 滑块当前值 |
| onChanged | ValueChanged\<double\>? | 必需 | 值改变时的回调，为 null 时禁用滑块 |
| onChangeStart | ValueChanged\<double\>? | - | 开始拖动时的回调 |
| onChangeEnd | ValueChanged\<double\>? | - | 结束拖动时的回调 |
| min | double | 0.0 | 最小值 |
| max | double | 1.0 | 最大值 |
| divisions | int? | - | 刻度数量，设置后滑块会吸附到刻度 |
| label | String? | - | 拖动时显示的标签文本 |
| activeColor | Color? | 主题色 | 已选择部分的轨道颜色 |
| inactiveColor | Color? | - | 未选择部分的轨道颜色 |
| thumbColor | Color? | - | 滑块颜色 |
| overlayColor | WidgetStateProperty\<Color?\>? | - | 滑块周围的水波纹颜色 |
| secondaryActiveColor | Color? | - | 第二进度条颜色（如缓冲进度） |
| secondaryTrackValue | double? | - | 第二进度条的值 |
| mouseCursor | MouseCursor? | - | 鼠标悬停时的光标样式 |
| semanticFormatterCallback | SemanticFormatterCallback? | - | 无障碍语义格式化回调 |
| focusNode | FocusNode? | - | 焦点控制节点 |
| autofocus | bool | false | 是否自动获取焦点 |
| allowedInteraction | SliderInteraction? | - | 允许的交互方式（tapAndSlide/tapOnly/slideOnly/slideThumb） |

## 使用场景示例

### 1. 音量控制

```dart
class VolumeSliderDemo extends StatefulWidget {
  const VolumeSliderDemo({super.key});

  @override
  State<VolumeSliderDemo> createState() => _VolumeSliderDemoState();
}

class _VolumeSliderDemoState extends State<VolumeSliderDemo> {
  double _volume = 50.0;

  IconData _getVolumeIcon() {
    if (_volume == 0) return Icons.volume_off;
    if (_volume < 30) return Icons.volume_mute;
    if (_volume < 70) return Icons.volume_down;
    return Icons.volume_up;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_getVolumeIcon(), size: 28),
        Expanded(
          child: Slider(
            value: _volume,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() => _volume = value);
            },
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '${_volume.toInt()}%',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
```

### 2. 亮度调节

```dart
class BrightnessSliderDemo extends StatefulWidget {
  const BrightnessSliderDemo({super.key});

  @override
  State<BrightnessSliderDemo> createState() => _BrightnessSliderDemoState();
}

class _BrightnessSliderDemoState extends State<BrightnessSliderDemo> {
  double _brightness = 0.7;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.black.withValues(alpha: 1 - _brightness),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _brightness > 0.5 ? Icons.brightness_high : Icons.brightness_low,
            color: Colors.amber,
            size: 48,
          ),
          const SizedBox(height: 16),
          Slider(
            value: _brightness,
            min: 0.1,
            max: 1.0,
            activeColor: Colors.amber,
            inactiveColor: Colors.amber.shade100,
            onChanged: (value) {
              setState(() => _brightness = value);
            },
          ),
          Text(
            '亮度: ${(_brightness * 100).toInt()}%',
            style: TextStyle(
              color: _brightness > 0.5 ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. 带刻度滑块

```dart
class DivisionsSliderDemo extends StatefulWidget {
  const DivisionsSliderDemo({super.key});

  @override
  State<DivisionsSliderDemo> createState() => _DivisionsSliderDemoState();
}

class _DivisionsSliderDemoState extends State<DivisionsSliderDemo> {
  double _rating = 3.0;
  double _temperature = 20.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 评分滑块（1-5 分）
        const Text('评分', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _rating,
          min: 1,
          max: 5,
          divisions: 4,
          label: '${_rating.toInt()} 星',
          onChanged: (value) {
            setState(() => _rating = value);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // 温度滑块（16-30 度）
        const Text('空调温度', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _temperature,
          min: 16,
          max: 30,
          divisions: 14,
          label: '${_temperature.toInt()}°C',
          activeColor: _temperature < 22
              ? Colors.blue
              : (_temperature < 26 ? Colors.green : Colors.orange),
          onChanged: (value) {
            setState(() => _temperature = value);
          },
        ),
        Text(
          '${_temperature.toInt()}°C',
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}
```

### 4. 带缓冲进度的滑块（secondaryTrackValue）

```dart
class BufferedSliderDemo extends StatefulWidget {
  const BufferedSliderDemo({super.key});

  @override
  State<BufferedSliderDemo> createState() => _BufferedSliderDemoState();
}

class _BufferedSliderDemoState extends State<BufferedSliderDemo> {
  double _playProgress = 30.0;
  double _bufferProgress = 60.0;

  String _formatDuration(double seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.music_note, size: 64, color: Colors.deepPurple),
        const SizedBox(height: 8),
        const Text('正在播放的歌曲', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        Slider(
          value: _playProgress,
          secondaryTrackValue: _bufferProgress,
          min: 0,
          max: 240,
          activeColor: Colors.deepPurple,
          secondaryActiveColor: Colors.deepPurple.shade200,
          inactiveColor: Colors.grey.shade300,
          onChanged: (value) {
            setState(() => _playProgress = value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_playProgress)),
              Text(_formatDuration(240)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '已缓冲: ${(_bufferProgress / 240 * 100).toInt()}%',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
```

### 5. 自定义样式

```dart
class CustomStyledSliderDemo extends StatefulWidget {
  const CustomStyledSliderDemo({super.key});

  @override
  State<CustomStyledSliderDemo> createState() => _CustomStyledSliderDemoState();
}

class _CustomStyledSliderDemoState extends State<CustomStyledSliderDemo> {
  double _value1 = 50.0;
  double _value2 = 30.0;
  double _value3 = 70.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 渐变色效果
        const Text('自定义颜色'),
        Slider(
          value: _value1,
          min: 0,
          max: 100,
          activeColor: Colors.teal,
          inactiveColor: Colors.teal.shade100,
          thumbColor: Colors.teal.shade700,
          onChanged: (value) {
            setState(() => _value1 = value);
          },
        ),
        const SizedBox(height: 24),
        // 使用 SliderTheme 自定义
        const Text('SliderTheme 自定义'),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: Colors.pink,
            inactiveTrackColor: Colors.pink.shade100,
            thumbColor: Colors.pinkAccent,
            overlayColor: Colors.pink.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _value2,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() => _value2 = value);
            },
          ),
        ),
        const SizedBox(height: 24),
        // 矩形滑块
        const Text('矩形滑块'),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
            trackShape: const RectangularSliderTrackShape(),
            activeTrackColor: Colors.indigo,
            inactiveTrackColor: Colors.indigo.shade100,
          ),
          child: Slider(
            value: _value3,
            min: 0,
            max: 100,
            divisions: 10,
            label: '${_value3.toInt()}',
            onChanged: (value) {
              setState(() => _value3 = value);
            },
          ),
        ),
      ],
    );
  }
}
```

## RangeSlider 简介

`RangeSlider` 允许用户选择一个值范围，而不是单个值。它有两个滑块，分别表示范围的起始和结束。

```dart
class RangeSliderDemo extends StatefulWidget {
  const RangeSliderDemo({super.key});

  @override
  State<RangeSliderDemo> createState() => _RangeSliderDemoState();
}

class _RangeSliderDemoState extends State<RangeSliderDemo> {
  RangeValues _ageRange = const RangeValues(18, 35);
  RangeValues _priceRange = const RangeValues(100, 500);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 年龄范围选择
        const Text('年龄范围', style: TextStyle(fontWeight: FontWeight.bold)),
        RangeSlider(
          values: _ageRange,
          min: 0,
          max: 100,
          divisions: 100,
          labels: RangeLabels(
            '${_ageRange.start.toInt()} 岁',
            '${_ageRange.end.toInt()} 岁',
          ),
          onChanged: (values) {
            setState(() => _ageRange = values);
          },
        ),
        Text('${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} 岁'),
        const SizedBox(height: 32),
        // 价格范围选择
        const Text('价格范围', style: TextStyle(fontWeight: FontWeight.bold)),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 1000,
          divisions: 20,
          labels: RangeLabels(
            '¥${_priceRange.start.toInt()}',
            '¥${_priceRange.end.toInt()}',
          ),
          activeColor: Colors.green,
          onChanged: (values) {
            setState(() => _priceRange = values);
          },
        ),
        Text('¥${_priceRange.start.toInt()} - ¥${_priceRange.end.toInt()}'),
      ],
    );
  }
}
```

## 完整示例：价格筛选器

```dart
import 'package:flutter/material.dart';

class PriceFilterDemo extends StatefulWidget {
  const PriceFilterDemo({super.key});

  @override
  State<PriceFilterDemo> createState() => _PriceFilterDemoState();
}

class _PriceFilterDemoState extends State<PriceFilterDemo> {
  RangeValues _priceRange = const RangeValues(200, 800);
  final double _minPrice = 0;
  final double _maxPrice = 1000;
  bool _includeShipping = true;
  String _selectedSort = '价格从低到高';

  // 模拟商品数据
  final List<Map<String, dynamic>> _allProducts = [
    {'name': '无线蓝牙耳机', 'price': 299, 'image': Icons.headphones},
    {'name': '智能手表', 'price': 599, 'image': Icons.watch},
    {'name': '便携充电宝', 'price': 129, 'image': Icons.battery_charging_full},
    {'name': '机械键盘', 'price': 459, 'image': Icons.keyboard},
    {'name': '显示器支架', 'price': 189, 'image': Icons.desktop_windows},
    {'name': '降噪耳机', 'price': 899, 'image': Icons.headset},
    {'name': 'USB 扩展坞', 'price': 259, 'image': Icons.usb},
    {'name': '鼠标垫', 'price': 79, 'image': Icons.mouse},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _allProducts.where((product) {
      final price = product['price'] as int;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // 排序
    if (_selectedSort == '价格从低到高') {
      filtered.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else {
      filtered.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('价格筛选器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 当前筛选条件显示
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Chip(
                  label: Text(
                    '¥${_priceRange.start.toInt()} - ¥${_priceRange.end.toInt()}',
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _priceRange = RangeValues(_minPrice, _maxPrice);
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text('共 ${_filteredProducts.length} 件商品'),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedSort,
                  underline: const SizedBox(),
                  items: ['价格从低到高', '价格从高到低']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedSort = value!);
                  },
                ),
              ],
            ),
          ),
          // 商品列表
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('没有找到符合条件的商品'),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                product['image'] as IconData,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                product['name'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '¥${product['price']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '价格筛选',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _priceRange = RangeValues(_minPrice, _maxPrice);
                          });
                        },
                        child: const Text('重置'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 价格范围滑块
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${_priceRange.start.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '¥${_priceRange.end.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: 20,
                    labels: RangeLabels(
                      '¥${_priceRange.start.toInt()}',
                      '¥${_priceRange.end.toInt()}',
                    ),
                    onChanged: (values) {
                      setModalState(() => _priceRange = values);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('¥${_minPrice.toInt()}'),
                      Text('¥${_maxPrice.toInt()}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 快速选择按钮
                  const Text('快速选择', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickSelectChip('¥0-200', 0, 200, setModalState),
                      _buildQuickSelectChip('¥200-500', 200, 500, setModalState),
                      _buildQuickSelectChip('¥500-800', 500, 800, setModalState),
                      _buildQuickSelectChip('¥800+', 800, 1000, setModalState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 其他选项
                  SwitchListTile(
                    title: const Text('包含运费'),
                    value: _includeShipping,
                    onChanged: (value) {
                      setModalState(() => _includeShipping = value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),
                  // 确认按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); // 更新主页面
                        Navigator.pop(context);
                      },
                      child: Text(
                        '查看 ${_filteredProducts.length} 件商品',
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickSelectChip(
    String label,
    double start,
    double end,
    StateSetter setModalState,
  ) {
    final isSelected =
        _priceRange.start == start && _priceRange.end == end;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _priceRange = RangeValues(start, end);
        });
      },
    );
  }
}
```

## 最佳实践

1. **合理设置范围**：根据实际业务场景设置合适的 min 和 max 值，避免范围过大或过小
2. **使用 divisions**：对于需要精确选择的场景，设置 divisions 让用户更容易选择特定值
3. **显示当前值**：通过 label 或额外的 Text 组件显示当前选中的值，提升用户体验
4. **提供视觉反馈**：使用 onChangeStart 和 onChangeEnd 在拖动开始和结束时提供反馈
5. **无障碍支持**：使用 semanticFormatterCallback 为屏幕阅读器提供有意义的值描述
6. **避免频繁更新**：如果 onChanged 中有耗时操作，考虑使用 onChangeEnd 代替
7. **自定义样式**：使用 SliderTheme 统一应用内滑块的样式风格
8. **范围选择**：需要选择范围时使用 RangeSlider，比两个独立的 Slider 更直观

```dart
// 无障碍示例
Slider(
  value: _value,
  min: 0,
  max: 100,
  semanticFormatterCallback: (value) {
    return '${value.toInt()} 百分比';
  },
  onChanged: (value) {
    setState(() => _value = value);
  },
)
```

## 相关组件

- [RangeSlider](https://api.flutter.dev/flutter/material/RangeSlider-class.html)：范围选择滑块
- [CupertinoSlider](../cupertino/cupertinoslider.md)：iOS 风格滑块

## 官方文档

- [Slider API](https://api.flutter.dev/flutter/material/Slider-class.html)
- [RangeSlider API](https://api.flutter.dev/flutter/material/RangeSlider-class.html)
- [SliderTheme API](https://api.flutter.dev/flutter/material/SliderTheme-class.html)
