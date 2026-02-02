
# CupertinoSlider

`CupertinoSlider` 是 iOS 风格的滑块组件，遵循 Apple Human Interface Guidelines 设计规范。它提供了一个可拖动的滑块控件，用于在指定范围内选择一个连续或离散的值，常用于音量、亮度等设置场景。

## 基本用法

```dart
CupertinoSlider(
  value: _currentValue,
  min: 0.0,
  max: 100.0,
  onChanged: (double value) {
    setState(() {
      _currentValue = value;
    });
  },
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `value` | `double` | 滑块的当前值，必须在 `min` 和 `max` 之间 |
| `onChanged` | `ValueChanged<double>?` | 值改变时的回调，为 `null` 时滑块禁用 |
| `onChangeStart` | `ValueChanged<double>?` | 用户开始拖动滑块时的回调 |
| `onChangeEnd` | `ValueChanged<double>?` | 用户停止拖动滑块时的回调 |
| `min` | `double` | 滑块的最小值（默认为 `0.0`） |
| `max` | `double` | 滑块的最大值（默认为 `1.0`） |
| `divisions` | `int?` | 离散分割数，设置后滑块将吸附到离散点上 |
| `activeColor` | `Color?` | 已滑过部分（活动轨道）的颜色 |
| `thumbColor` | `Color?` | 滑块圆形按钮的颜色（默认为白色） |

## 使用场景

### 1. 基本滑块

```dart
import 'package:flutter/cupertino.dart';

class BasicSliderDemo extends StatefulWidget {
  @override
  State<BasicSliderDemo> createState() => _BasicSliderDemoState();
}

class _BasicSliderDemoState extends State<BasicSliderDemo> {
  double _currentValue = 50.0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('基本滑块'),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '当前值: ${_currentValue.toStringAsFixed(1)}',
                style: TextStyle(
                  color: CupertinoColors.label,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              CupertinoSlider(
                value: _currentValue,
                min: 0.0,
                max: 100.0,
                onChanged: (double value) {
                  setState(() {
                    _currentValue = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. 音量控制

```dart
class VolumeControlDemo extends StatefulWidget {
  @override
  State<VolumeControlDemo> createState() => _VolumeControlDemoState();
}

class _VolumeControlDemoState extends State<VolumeControlDemo> {
  double _volume = 0.5;
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('音量控制'),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 音量图标
              Icon(
                _isMuted || _volume == 0
                    ? CupertinoIcons.volume_off
                    : _volume < 0.5
                        ? CupertinoIcons.volume_down
                        : CupertinoIcons.volume_up,
                size: 60,
                color: CupertinoColors.systemBlue,
              ),
              SizedBox(height: 30),
              
              // 音量百分比
              Text(
                _isMuted ? '静音' : '${(_volume * 100).toInt()}%',
                style: TextStyle(
                  color: CupertinoColors.label,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              
              // 音量滑块
              Row(
                children: [
                  Icon(
                    CupertinoIcons.volume_down,
                    color: CupertinoColors.systemGrey,
                  ),
                  Expanded(
                    child: CupertinoSlider(
                      value: _isMuted ? 0 : _volume,
                      onChanged: (double value) {
                        setState(() {
                          _volume = value;
                          _isMuted = false;
                        });
                      },
                      onChangeStart: (double value) {
                        print('开始调节音量: $value');
                      },
                      onChangeEnd: (double value) {
                        print('音量调节完成: $value');
                      },
                    ),
                  ),
                  Icon(
                    CupertinoIcons.volume_up,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // 静音按钮
              CupertinoButton(
                onPressed: () {
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                },
                child: Text(_isMuted ? '取消静音' : '静音'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3. 带刻度滑块

```dart
class DivisionsSliderDemo extends StatefulWidget {
  @override
  State<DivisionsSliderDemo> createState() => _DivisionsSliderDemoState();
}

class _DivisionsSliderDemoState extends State<DivisionsSliderDemo> {
  double _rating = 3.0;
  double _temperature = 20.0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('带刻度滑块'),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // 评分滑块 (1-5)
            _buildSection(
              title: '评分',
              value: '${_rating.toInt()} 星',
              child: Column(
                children: [
                  CupertinoSlider(
                    value: _rating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    activeColor: CupertinoColors.systemYellow,
                    onChanged: (double value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 12,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            
            // 温度滑块 (16-30°C)
            _buildSection(
              title: '温度',
              value: '${_temperature.toInt()}°C',
              child: Column(
                children: [
                  CupertinoSlider(
                    value: _temperature,
                    min: 16.0,
                    max: 30.0,
                    divisions: 14,
                    activeColor: _temperature < 22
                        ? CupertinoColors.systemBlue
                        : _temperature < 26
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemOrange,
                    onChanged: (double value) {
                      setState(() {
                        _temperature = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('16°C', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                      Text('冷', style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 12)),
                      Text('适中', style: TextStyle(color: CupertinoColors.systemGreen, fontSize: 12)),
                      Text('热', style: TextStyle(color: CupertinoColors.systemOrange, fontSize: 12)),
                      Text('30°C', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String value,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: CupertinoColors.label,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
```

### 4. 范围指示

```dart
class RangeIndicatorDemo extends StatefulWidget {
  @override
  State<RangeIndicatorDemo> createState() => _RangeIndicatorDemoState();
}

class _RangeIndicatorDemoState extends State<RangeIndicatorDemo> {
  double _progress = 0.3;
  double _minValue = 100.0;
  double _maxValue = 1000.0;
  double _currentPrice = 300.0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('范围指示'),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // 进度指示
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '下载进度',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoSlider(
                          value: _progress,
                          activeColor: CupertinoColors.systemGreen,
                          onChanged: (double value) {
                            setState(() {
                              _progress = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        width: 60,
                        child: Text(
                          '${(_progress * 100).toInt()}%',
                          style: TextStyle(
                            color: CupertinoColors.systemGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '已下载 ${(_progress * 256).toStringAsFixed(1)} MB / 256 MB',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // 价格区间选择
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '价格筛选',
                        style: TextStyle(
                          color: CupertinoColors.label,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '¥${_currentPrice.toInt()}',
                        style: TextStyle(
                          color: CupertinoColors.systemBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CupertinoSlider(
                    value: _currentPrice,
                    min: _minValue,
                    max: _maxValue,
                    activeColor: CupertinoColors.systemBlue,
                    onChanged: (double value) {
                      setState(() {
                        _currentPrice = value;
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${_minValue.toInt()}',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '¥${_maxValue.toInt()}',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 完整示例

以下是一个 iOS 风格的亮度/音量控制面板示例：

```dart
import 'package:flutter/cupertino.dart';

class BrightnessVolumeControlPanel extends StatefulWidget {
  @override
  State<BrightnessVolumeControlPanel> createState() =>
      _BrightnessVolumeControlPanelState();
}

class _BrightnessVolumeControlPanelState
    extends State<BrightnessVolumeControlPanel> {
  double _brightness = 0.7;
  double _volume = 0.5;
  double _bass = 0.5;
  double _treble = 0.5;
  bool _isNightMode = false;
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('控制面板'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            _isNightMode ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max,
          ),
          onPressed: () {
            setState(() {
              _isNightMode = !_isNightMode;
              if (_isNightMode) {
                _brightness = 0.3;
              }
            });
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // 亮度控制
            _buildControlCard(
              title: '显示',
              icon: CupertinoIcons.brightness,
              iconColor: CupertinoColors.systemYellow,
              children: [
                _buildSliderRow(
                  label: '亮度',
                  value: _brightness,
                  leadingIcon: CupertinoIcons.brightness_solid,
                  trailingIcon: CupertinoIcons.sun_max_fill,
                  activeColor: CupertinoColors.systemYellow,
                  onChanged: (value) {
                    setState(() {
                      _brightness = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '夜间模式',
                      style: TextStyle(
                        color: CupertinoColors.label,
                        fontSize: 15,
                      ),
                    ),
                    CupertinoSwitch(
                      value: _isNightMode,
                      onChanged: (value) {
                        setState(() {
                          _isNightMode = value;
                          if (value) {
                            _brightness = 0.3;
                          } else {
                            _brightness = 0.7;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // 音量控制
            _buildControlCard(
              title: '音频',
              icon: CupertinoIcons.speaker_2,
              iconColor: CupertinoColors.systemBlue,
              children: [
                _buildSliderRow(
                  label: '音量',
                  value: _isMuted ? 0 : _volume,
                  leadingIcon: CupertinoIcons.speaker_fill,
                  trailingIcon: CupertinoIcons.speaker_3_fill,
                  activeColor: CupertinoColors.systemBlue,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                      _isMuted = value == 0;
                    });
                  },
                ),
                SizedBox(height: 16),
                _buildSliderRow(
                  label: '低音',
                  value: _bass,
                  leadingIcon: CupertinoIcons.minus,
                  trailingIcon: CupertinoIcons.plus,
                  activeColor: CupertinoColors.systemIndigo,
                  onChanged: (value) {
                    setState(() {
                      _bass = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                _buildSliderRow(
                  label: '高音',
                  value: _treble,
                  leadingIcon: CupertinoIcons.minus,
                  trailingIcon: CupertinoIcons.plus,
                  activeColor: CupertinoColors.systemPurple,
                  onChanged: (value) {
                    setState(() {
                      _treble = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '静音',
                      style: TextStyle(
                        color: CupertinoColors.label,
                        fontSize: 15,
                      ),
                    ),
                    CupertinoSwitch(
                      value: _isMuted,
                      onChanged: (value) {
                        setState(() {
                          _isMuted = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // 预设值快捷按钮
            _buildControlCard(
              title: '快捷预设',
              icon: CupertinoIcons.slider_horizontal_3,
              iconColor: CupertinoColors.systemGreen,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPresetButton(
                      label: '影院',
                      icon: CupertinoIcons.film,
                      onTap: () {
                        setState(() {
                          _brightness = 0.3;
                          _volume = 0.8;
                          _bass = 0.7;
                          _treble = 0.5;
                        });
                      },
                    ),
                    _buildPresetButton(
                      label: '音乐',
                      icon: CupertinoIcons.music_note,
                      onTap: () {
                        setState(() {
                          _brightness = 0.7;
                          _volume = 0.6;
                          _bass = 0.6;
                          _treble = 0.7;
                        });
                      },
                    ),
                    _buildPresetButton(
                      label: '游戏',
                      icon: CupertinoIcons.game_controller,
                      onTap: () {
                        setState(() {
                          _brightness = 0.8;
                          _volume = 0.7;
                          _bass = 0.8;
                          _treble = 0.6;
                        });
                      },
                    ),
                    _buildPresetButton(
                      label: '夜间',
                      icon: CupertinoIcons.moon,
                      onTap: () {
                        setState(() {
                          _brightness = 0.2;
                          _volume = 0.3;
                          _bass = 0.5;
                          _treble = 0.5;
                          _isNightMode = true;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // 当前设置概览
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前设置',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow('亮度', '${(_brightness * 100).toInt()}%'),
                  _buildInfoRow('音量', _isMuted ? '静音' : '${(_volume * 100).toInt()}%'),
                  _buildInfoRow('低音', '${((_bass - 0.5) * 100).toInt()}'),
                  _buildInfoRow('高音', '${((_treble - 0.5) * 100).toInt()}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: CupertinoColors.label,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required IconData leadingIcon,
    required IconData trailingIcon,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 13,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                color: activeColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              leadingIcon,
              color: CupertinoColors.systemGrey,
              size: 18,
            ),
            Expanded(
              child: CupertinoSlider(
                value: value,
                activeColor: activeColor,
                onChanged: onChanged,
              ),
            ),
            Icon(
              trailingIcon,
              color: CupertinoColors.systemGrey,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: CupertinoColors.systemBlue,
              size: 24,
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.label,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.label,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 最佳实践

1. **提供即时反馈**：在滑动过程中实时更新显示值，让用户了解当前选择。

2. **使用合适的范围**：根据实际需求设置 `min` 和 `max`，避免使用过大或过小的范围。

3. **合理使用 divisions**：对于需要精确选择离散值的场景（如评分、温度设置），使用 `divisions` 属性。

4. **配合图标使用**：在滑块两端添加表示最小/最大的图标，提高可视化效果。

5. **利用回调函数**：
   - 使用 `onChangeStart` 记录初始值或暂停其他操作
   - 使用 `onChangeEnd` 保存最终值或执行耗时操作
   - 使用 `onChanged` 实时更新 UI

6. **颜色一致性**：`activeColor` 应与应用主题或功能语义保持一致。

7. **无障碍设计**：确保滑块有足够大的可点击区域，并提供清晰的数值显示。

8. **禁用状态**：当滑块不可用时，设置 `onChanged` 为 `null` 以显示禁用样式。

## 相关组件

- [Slider](../material/slider.md) - Material Design 风格的滑块组件
- [RangeSlider](../material/rangeslider.md) - Material Design 风格的范围滑块，可选择一个范围
- [CupertinoSwitch](./cupertinoswitch.md) - iOS 风格的开关组件
- [CupertinoPicker](./cupertinopicker.md) - iOS 风格的滚轮选择器

## 官方文档

- [CupertinoSlider API](https://api.flutter.dev/flutter/cupertino/CupertinoSlider-class.html)

