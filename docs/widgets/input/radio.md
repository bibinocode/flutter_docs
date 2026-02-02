# Radio

`Radio` 是 Flutter 中的 Material Design 单选按钮组件，用于让用户在一组互斥的选项中选择一个。单选按钮通常成组使用，通过共享同一个 `groupValue` 来实现单选逻辑，常见于性别选择、配送方式、支付方式等场景。

## 基本用法

```dart
String? _selectedValue = 'option1';

Radio<String>(
  value: 'option1',
  groupValue: _selectedValue,
  onChanged: (String? value) {
    setState(() {
      _selectedValue = value;
    });
  },
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `value` | `T` | 必需 | 此单选按钮代表的值 |
| `groupValue` | `T?` | 必需 | 当前选中组的值，与 `value` 相等时表示选中 |
| `onChanged` | `ValueChanged<T?>?` | 必需 | 选中状态改变时的回调，设为 `null` 禁用单选按钮 |
| `activeColor` | `Color?` | 主题色 | 选中状态时的填充颜色 |
| `fillColor` | `WidgetStateProperty<Color?>?` | - | 根据状态设置填充颜色 |
| `focusColor` | `Color?` | - | 获得焦点时的颜色 |
| `hoverColor` | `Color?` | - | 鼠标悬停时的颜色 |
| `overlayColor` | `WidgetStateProperty<Color?>?` | - | 高亮覆盖层颜色（点击、悬停、焦点时） |
| `splashRadius` | `double?` | - | 点击时水波纹的半径 |
| `materialTapTargetSize` | `MaterialTapTargetSize?` | - | 点击区域大小 |
| `visualDensity` | `VisualDensity?` | - | 视觉密度，影响组件大小 |
| `focusNode` | `FocusNode?` | - | 焦点控制节点 |
| `autofocus` | `bool` | `false` | 是否自动获取焦点 |
| `toggleable` | `bool` | `false` | 是否允许点击已选中项来取消选择 |

## 使用场景

### 1. 基础单选组

最常见的单选按钮组用法，用于互斥选择：

```dart
class BasicRadioDemo extends StatefulWidget {
  const BasicRadioDemo({super.key});

  @override
  State<BasicRadioDemo> createState() => _BasicRadioDemoState();
}

class _BasicRadioDemoState extends State<BasicRadioDemo> {
  String? _selectedFruit = 'apple';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择水果:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // 选项 1
        Row(
          children: [
            Radio<String>(
              value: 'apple',
              groupValue: _selectedFruit,
              onChanged: (String? value) {
                setState(() {
                  _selectedFruit = value;
                });
              },
            ),
            const Text('🍎 苹果'),
          ],
        ),
        
        // 选项 2
        Row(
          children: [
            Radio<String>(
              value: 'banana',
              groupValue: _selectedFruit,
              onChanged: (String? value) {
                setState(() {
                  _selectedFruit = value;
                });
              },
            ),
            const Text('🍌 香蕉'),
          ],
        ),
        
        // 选项 3
        Row(
          children: [
            Radio<String>(
              value: 'orange',
              groupValue: _selectedFruit,
              onChanged: (String? value) {
                setState(() {
                  _selectedFruit = value;
                });
              },
            ),
            const Text('🍊 橙子'),
          ],
        ),
        
        // 禁用选项
        Row(
          children: [
            Radio<String>(
              value: 'grape',
              groupValue: _selectedFruit,
              onChanged: null, // 禁用
            ),
            const Text('🍇 葡萄（缺货）', 
              style: TextStyle(color: Colors.grey)),
          ],
        ),
        
        const SizedBox(height: 16),
        Text('已选择: $_selectedFruit'),
      ],
    );
  }
}
```

### 2. RadioListTile

带标题和副标题的单选列表项，适合设置页面：

```dart
class RadioListTileDemo extends StatefulWidget {
  const RadioListTileDemo({super.key});

  @override
  State<RadioListTileDemo> createState() => _RadioListTileDemoState();
}

class _RadioListTileDemoState extends State<RadioListTileDemo> {
  String? _selectedPayment = 'alipay';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('选择支付方式', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        
        // 支付宝
        RadioListTile<String>(
          title: const Text('支付宝'),
          subtitle: const Text('推荐使用'),
          secondary: const Icon(Icons.account_balance_wallet, 
            color: Colors.blue),
          value: 'alipay',
          groupValue: _selectedPayment,
          onChanged: (String? value) {
            setState(() {
              _selectedPayment = value;
            });
          },
        ),
        
        const Divider(height: 1),
        
        // 微信支付
        RadioListTile<String>(
          title: const Text('微信支付'),
          subtitle: const Text('支持红包'),
          secondary: const Icon(Icons.chat, color: Colors.green),
          value: 'wechat',
          groupValue: _selectedPayment,
          onChanged: (String? value) {
            setState(() {
              _selectedPayment = value;
            });
          },
        ),
        
        const Divider(height: 1),
        
        // 银行卡
        RadioListTile<String>(
          title: const Text('银行卡支付'),
          subtitle: const Text('支持信用卡'),
          secondary: const Icon(Icons.credit_card, color: Colors.orange),
          value: 'card',
          groupValue: _selectedPayment,
          onChanged: (String? value) {
            setState(() {
              _selectedPayment = value;
            });
          },
        ),
        
        const Divider(height: 1),
        
        // 货到付款（禁用）
        RadioListTile<String>(
          title: const Text('货到付款'),
          subtitle: const Text('暂不支持'),
          secondary: const Icon(Icons.local_shipping, color: Colors.grey),
          value: 'cod',
          groupValue: _selectedPayment,
          onChanged: null, // 禁用
        ),
      ],
    );
  }
}
```

### 3. 自定义样式

自定义单选按钮的颜色和外观：

```dart
class CustomRadioDemo extends StatefulWidget {
  const CustomRadioDemo({super.key});

  @override
  State<CustomRadioDemo> createState() => _CustomRadioDemoState();
}

class _CustomRadioDemoState extends State<CustomRadioDemo> {
  String? _selectedTheme = 'light';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择主题:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // 自定义颜色
        Row(
          children: [
            Radio<String>(
              value: 'light',
              groupValue: _selectedTheme,
              activeColor: Colors.amber,
              onChanged: (String? value) {
                setState(() {
                  _selectedTheme = value;
                });
              },
            ),
            const Icon(Icons.light_mode, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('浅色模式'),
          ],
        ),
        
        // 使用 fillColor 根据状态设置颜色
        Row(
          children: [
            Radio<String>(
              value: 'dark',
              groupValue: _selectedTheme,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.indigo;
                }
                return Colors.grey;
              }),
              onChanged: (String? value) {
                setState(() {
                  _selectedTheme = value;
                });
              },
            ),
            const Icon(Icons.dark_mode, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('深色模式'),
          ],
        ),
        
        // 自定义水波纹和悬停颜色
        Row(
          children: [
            Radio<String>(
              value: 'system',
              groupValue: _selectedTheme,
              activeColor: Colors.teal,
              splashRadius: 24,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.teal.withOpacity(0.3);
                }
                if (states.contains(WidgetState.hovered)) {
                  return Colors.teal.withOpacity(0.1);
                }
                return null;
              }),
              onChanged: (String? value) {
                setState(() {
                  _selectedTheme = value;
                });
              },
            ),
            const Icon(Icons.settings_system_daydream, color: Colors.teal),
            const SizedBox(width: 8),
            const Text('跟随系统'),
          ],
        ),
        
        const SizedBox(height: 16),
        Text('当前主题: $_selectedTheme'),
      ],
    );
  }
}
```

### 4. 枚举选择

使用枚举类型作为单选按钮的值，类型安全：

```dart
// 定义枚举
enum ShippingMethod {
  standard('标准配送', '3-5个工作日', 0),
  express('快递配送', '1-2个工作日', 10),
  sameDay('当日达', '今日送达', 20),
  pickup('门店自取', '随时可取', 0);

  const ShippingMethod(this.label, this.description, this.price);
  
  final String label;
  final String description;
  final int price;
}

class EnumRadioDemo extends StatefulWidget {
  const EnumRadioDemo({super.key});

  @override
  State<EnumRadioDemo> createState() => _EnumRadioDemoState();
}

class _EnumRadioDemoState extends State<EnumRadioDemo> {
  ShippingMethod _selectedMethod = ShippingMethod.standard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择配送方式', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // 遍历枚举生成单选项
        ...ShippingMethod.values.map((method) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<ShippingMethod>(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(method.label),
                  Text(
                    method.price > 0 ? '¥${method.price}' : '免费',
                    style: TextStyle(
                      color: method.price > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: Text(method.description),
              value: method,
              groupValue: _selectedMethod,
              onChanged: (ShippingMethod? value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          );
        }),
        
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('配送费用:'),
              Text(
                '¥${_selectedMethod.price}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

## 完整示例

### 性别选择

```dart
import 'package:flutter/material.dart';

enum Gender { male, female, other }

class GenderSelectionDemo extends StatefulWidget {
  const GenderSelectionDemo({super.key});

  @override
  State<GenderSelectionDemo> createState() => _GenderSelectionDemoState();
}

class _GenderSelectionDemoState extends State<GenderSelectionDemo> {
  Gender? _selectedGender;

  String get _genderText {
    switch (_selectedGender) {
      case Gender.male:
        return '男';
      case Gender.female:
        return '女';
      case Gender.other:
        return '其他';
      case null:
        return '未选择';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('性别选择')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请选择您的性别',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 横向排列的单选按钮
            Row(
              children: [
                Expanded(
                  child: RadioListTile<Gender>(
                    title: const Text('男'),
                    value: Gender.male,
                    groupValue: _selectedGender,
                    onChanged: (Gender? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<Gender>(
                    title: const Text('女'),
                    value: Gender.female,
                    groupValue: _selectedGender,
                    onChanged: (Gender? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<Gender>(
                    title: const Text('其他'),
                    value: Gender.other,
                    groupValue: _selectedGender,
                    onChanged: (Gender? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // 显示选择结果
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '已选择: $_genderText',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            const Spacer(),
            
            // 提交按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedGender != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('提交成功，性别: $_genderText')),
                        );
                      }
                    : null,
                child: const Text('确认'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 配送方式选择

```dart
import 'package:flutter/material.dart';

class DeliveryOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final double price;
  final bool available;

  const DeliveryOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    this.available = true,
  });
}

class DeliverySelectionDemo extends StatefulWidget {
  const DeliverySelectionDemo({super.key});

  @override
  State<DeliverySelectionDemo> createState() => _DeliverySelectionDemoState();
}

class _DeliverySelectionDemoState extends State<DeliverySelectionDemo> {
  final List<DeliveryOption> _options = const [
    DeliveryOption(
      id: 'standard',
      name: '标准配送',
      description: '预计 3-5 个工作日送达',
      icon: Icons.local_shipping,
      price: 0,
    ),
    DeliveryOption(
      id: 'express',
      name: '加急配送',
      description: '预计 1-2 个工作日送达',
      icon: Icons.flight,
      price: 15,
    ),
    DeliveryOption(
      id: 'sameday',
      name: '当日达',
      description: '今日 20:00 前送达',
      icon: Icons.rocket_launch,
      price: 30,
    ),
    DeliveryOption(
      id: 'pickup',
      name: '门店自取',
      description: '到店自取，免运费',
      icon: Icons.store,
      price: 0,
    ),
    DeliveryOption(
      id: 'scheduled',
      name: '预约配送',
      description: '选择您方便的时间',
      icon: Icons.schedule,
      price: 10,
      available: false, // 暂不可用
    ),
  ];

  String? _selectedId = 'standard';

  DeliveryOption? get _selectedOption {
    try {
      return _options.firstWhere((opt) => opt.id == _selectedId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配送方式')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = option.id == _selectedId;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: option.available
                        ? () {
                            setState(() {
                              _selectedId = option.id;
                            });
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // 单选按钮
                          Radio<String>(
                            value: option.id,
                            groupValue: _selectedId,
                            onChanged: option.available
                                ? (String? value) {
                                    setState(() {
                                      _selectedId = value;
                                    });
                                  }
                                : null,
                          ),
                          
                          // 图标
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: option.available
                                  ? Colors.blue.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              option.icon,
                              color: option.available
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // 文字内容
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      option.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: option.available
                                            ? null
                                            : Colors.grey,
                                      ),
                                    ),
                                    if (!option.available)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '暂不可用',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 价格
                          Text(
                            option.price > 0 ? '¥${option.price.toInt()}' : '免费',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: option.available
                                  ? (option.price > 0 ? Colors.red : Colors.green)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 底部确认栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '配送费用',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _selectedOption?.price == 0
                            ? '免费'
                            : '¥${_selectedOption?.price.toInt() ?? 0}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已选择: ${_selectedOption?.name}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('确认'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 最佳实践

1. **使用类型参数**：始终为 `Radio<T>` 指定类型参数，确保类型安全
2. **共享 groupValue**：同一组单选按钮必须共享相同的 `groupValue`
3. **搭配文字标签**：单独的 Radio 缺乏可访问性，应搭配 Text 或使用 RadioListTile
4. **合理设置默认值**：根据业务场景预设合理的默认选项
5. **使用枚举类型**：优先使用枚举作为 value 类型，代码更清晰、类型更安全
6. **禁用不可用选项**：将 `onChanged` 设为 `null` 来禁用选项，而不是隐藏
7. **提供视觉反馈**：选中状态应有明显的视觉区分
8. **控制单选组大小**：选项过多时考虑使用下拉菜单替代

## 相关组件

- [RadioListTile](https://api.flutter.dev/flutter/material/RadioListTile-class.html)：带标题的单选列表项
- [Checkbox](checkbox.md)：复选框，用于多选场景
- [Switch](switch.md)：开关，用于开/关切换
- [DropdownButton](../buttons/dropdownbutton.md)：下拉选择，选项较多时使用
- [SegmentedButton](../buttons/segmentedbutton.md)：分段按钮，类似单选但样式不同

## 官方文档

- [Radio API](https://api.flutter.dev/flutter/material/Radio-class.html)
- [RadioListTile API](https://api.flutter.dev/flutter/material/RadioListTile-class.html)

