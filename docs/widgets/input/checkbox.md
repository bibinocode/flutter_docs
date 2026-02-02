# Checkbox

`Checkbox` 是 Flutter 中的复选框组件，用于让用户在两个或三个状态之间进行选择。它是表单中最常用的输入组件之一，通常用于同意条款、多选列表、设置开关等场景。

## 基本用法

```dart
bool _isChecked = false;

Checkbox(
  value: _isChecked,
  onChanged: (bool? newValue) {
    setState(() {
      _isChecked = newValue!;
    });
  },
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `value` | `bool?` | 必需 | 复选框当前值，`true` 选中，`false` 未选中，`null` 为中间态 |
| `onChanged` | `ValueChanged<bool?>?` | 必需 | 值改变时的回调，设为 `null` 禁用复选框 |
| `tristate` | `bool` | `false` | 是否启用三态模式（选中/未选中/中间态） |
| `activeColor` | `Color?` | 主题色 | 选中状态时的填充颜色 |
| `checkColor` | `Color?` | `Colors.white` | 选中时勾号的颜色 |
| `focusColor` | `Color?` | - | 获得焦点时的颜色 |
| `hoverColor` | `Color?` | - | 鼠标悬停时的颜色 |
| `splashRadius` | `double?` | - | 点击时水波纹的半径 |
| `materialTapTargetSize` | `MaterialTapTargetSize?` | - | 点击区域大小 |
| `visualDensity` | `VisualDensity?` | - | 视觉密度，影响组件大小 |
| `focusNode` | `FocusNode?` | - | 焦点控制节点 |
| `autofocus` | `bool` | `false` | 是否自动获取焦点 |
| `shape` | `OutlinedBorder?` | - | 复选框的形状 |
| `side` | `BorderSide?` | - | 未选中时边框样式 |
| `isError` | `bool` | `false` | 是否显示错误状态 |

## 使用场景

### 1. 基础复选框

最简单的复选框用法，用于二选一场景：

```dart
class BasicCheckboxDemo extends StatefulWidget {
  const BasicCheckboxDemo({super.key});

  @override
  State<BasicCheckboxDemo> createState() => _BasicCheckboxDemoState();
}

class _BasicCheckboxDemoState extends State<BasicCheckboxDemo> {
  bool _agreeTerms = false;
  bool _subscribeNews = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 基础用法
        Row(
          children: [
            Checkbox(
              value: _agreeTerms,
              onChanged: (bool? value) {
                setState(() {
                  _agreeTerms = value ?? false;
                });
              },
            ),
            const Text('我同意用户协议和隐私政策'),
          ],
        ),
        
        // 带自定义颜色
        Row(
          children: [
            Checkbox(
              value: _subscribeNews,
              activeColor: Colors.green,
              checkColor: Colors.yellow,
              onChanged: (bool? value) {
                setState(() {
                  _subscribeNews = value ?? false;
                });
              },
            ),
            const Text('订阅新闻邮件'),
          ],
        ),
        
        // 禁用状态
        Row(
          children: [
            Checkbox(
              value: true,
              onChanged: null, // 设为 null 禁用
            ),
            const Text('已锁定选项（禁用）'),
          ],
        ),
      ],
    );
  }
}
```

### 2. 三态复选框

当需要表示"全选"、"部分选中"、"全不选"三种状态时使用：

```dart
class TristateCheckboxDemo extends StatefulWidget {
  const TristateCheckboxDemo({super.key});

  @override
  State<TristateCheckboxDemo> createState() => _TristateCheckboxDemoState();
}

class _TristateCheckboxDemoState extends State<TristateCheckboxDemo> {
  // null 表示中间态（部分选中）
  bool? _parentValue = false;
  List<bool> _childValues = [false, false, false];

  void _updateParentValue() {
    final allTrue = _childValues.every((v) => v);
    final allFalse = _childValues.every((v) => !v);
    
    setState(() {
      if (allTrue) {
        _parentValue = true;
      } else if (allFalse) {
        _parentValue = false;
      } else {
        _parentValue = null; // 中间态
      }
    });
  }

  void _onParentChanged(bool? value) {
    setState(() {
      // 三态循环：false -> true -> null -> false
      if (_parentValue == null) {
        _parentValue = false;
        _childValues = [false, false, false];
      } else if (_parentValue == false) {
        _parentValue = true;
        _childValues = [true, true, true];
      } else {
        _parentValue = false;
        _childValues = [false, false, false];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 父级三态复选框
        Row(
          children: [
            Checkbox(
              tristate: true, // 启用三态
              value: _parentValue,
              onChanged: _onParentChanged,
            ),
            const Text('全选水果', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        
        // 子级复选框
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(
            children: [
              _buildChildCheckbox(0, '🍎 苹果'),
              _buildChildCheckbox(1, '🍌 香蕉'),
              _buildChildCheckbox(2, '🍊 橙子'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChildCheckbox(int index, String label) {
    return Row(
      children: [
        Checkbox(
          value: _childValues[index],
          onChanged: (bool? value) {
            setState(() {
              _childValues[index] = value ?? false;
            });
            _updateParentValue();
          },
        ),
        Text(label),
      ],
    );
  }
}
```

### 3. CheckboxListTile

带标题和副标题的复选框列表项，适合设置页面：

```dart
class CheckboxListTileDemo extends StatefulWidget {
  const CheckboxListTileDemo({super.key});

  @override
  State<CheckboxListTileDemo> createState() => _CheckboxListTileDemoState();
}

class _CheckboxListTileDemoState extends State<CheckboxListTileDemo> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _autoUpdate = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 基础用法
        CheckboxListTile(
          title: const Text('推送通知'),
          subtitle: const Text('接收应用推送消息'),
          value: _notifications,
          onChanged: (bool? value) {
            setState(() {
              _notifications = value ?? false;
            });
          },
        ),
        
        const Divider(height: 1),
        
        // 带图标
        CheckboxListTile(
          secondary: const Icon(Icons.dark_mode),
          title: const Text('深色模式'),
          subtitle: const Text('使用深色主题'),
          value: _darkMode,
          onChanged: (bool? value) {
            setState(() {
              _darkMode = value ?? false;
            });
          },
        ),
        
        const Divider(height: 1),
        
        // 自定义样式
        CheckboxListTile(
          secondary: const Icon(Icons.system_update),
          title: const Text('自动更新'),
          subtitle: const Text('在 Wi-Fi 环境下自动更新应用'),
          value: _autoUpdate,
          activeColor: Colors.green,
          checkColor: Colors.white,
          controlAffinity: ListTileControlAffinity.leading, // 复选框在前
          onChanged: (bool? value) {
            setState(() {
              _autoUpdate = value ?? false;
            });
          },
        ),
        
        const Divider(height: 1),
        
        // 禁用状态
        CheckboxListTile(
          title: const Text('高级设置'),
          subtitle: const Text('需要管理员权限'),
          value: false,
          onChanged: null, // 禁用
          enabled: false,
        ),
      ],
    );
  }
}
```

### 4. 表单中使用

在 Form 表单中集成复选框验证：

```dart
class FormCheckboxDemo extends StatefulWidget {
  const FormCheckboxDemo({super.key});

  @override
  State<FormCheckboxDemo> createState() => _FormCheckboxDemoState();
}

class _FormCheckboxDemoState extends State<FormCheckboxDemo> {
  final _formKey = GlobalKey<FormState>();
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '注册协议',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // 使用 FormField 包装 Checkbox 进行验证
          FormField<bool>(
            initialValue: _agreeTerms,
            validator: (value) {
              if (value != true) {
                return '请同意用户服务协议';
              }
              return null;
            },
            builder: (FormFieldState<bool> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: state.value ?? false,
                        isError: state.hasError,
                        onChanged: (bool? value) {
                          state.didChange(value);
                          setState(() {
                            _agreeTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final newValue = !(state.value ?? false);
                            state.didChange(newValue);
                            setState(() {
                              _agreeTerms = newValue;
                            });
                          },
                          child: const Text('我已阅读并同意《用户服务协议》'),
                        ),
                      ),
                    ],
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          // 第二个协议
          FormField<bool>(
            initialValue: _agreePrivacy,
            validator: (value) {
              if (value != true) {
                return '请同意隐私政策';
              }
              return null;
            },
            builder: (FormFieldState<bool> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: state.value ?? false,
                        isError: state.hasError,
                        onChanged: (bool? value) {
                          state.didChange(value);
                          setState(() {
                            _agreePrivacy = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('我已阅读并同意《隐私政策》'),
                      ),
                    ],
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('验证通过，提交表单')),
                );
              }
            },
            child: const Text('注册'),
          ),
        ],
      ),
    );
  }
}
```

### 5. 全选/取消全选

实现列表的全选功能：

```dart
class SelectAllCheckboxDemo extends StatefulWidget {
  const SelectAllCheckboxDemo({super.key});

  @override
  State<SelectAllCheckboxDemo> createState() => _SelectAllCheckboxDemoState();
}

class _SelectAllCheckboxDemoState extends State<SelectAllCheckboxDemo> {
  final List<Map<String, dynamic>> _items = [
    {'id': 1, 'name': '文件1.pdf', 'selected': false},
    {'id': 2, 'name': '文件2.doc', 'selected': false},
    {'id': 3, 'name': '文件3.xlsx', 'selected': false},
    {'id': 4, 'name': '文件4.ppt', 'selected': false},
    {'id': 5, 'name': '文件5.txt', 'selected': false},
  ];

  bool? get _selectAllValue {
    final selectedCount = _items.where((item) => item['selected']).length;
    if (selectedCount == 0) return false;
    if (selectedCount == _items.length) return true;
    return null; // 部分选中
  }

  int get _selectedCount => _items.where((item) => item['selected']).length;

  void _onSelectAllChanged(bool? value) {
    setState(() {
      final newValue = value ?? false;
      for (var item in _items) {
        item['selected'] = newValue;
      }
    });
  }

  void _onItemChanged(int index, bool? value) {
    setState(() {
      _items[index]['selected'] = value ?? false;
    });
  }

  void _deleteSelected() {
    setState(() {
      _items.removeWhere((item) => item['selected']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已删除 $_selectedCount 个文件')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部操作栏
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Row(
            children: [
              Checkbox(
                tristate: true,
                value: _selectAllValue,
                onChanged: _onSelectAllChanged,
              ),
              Text(
                _selectedCount > 0
                    ? '已选择 $_selectedCount 项'
                    : '全选',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_selectedCount > 0)
                TextButton.icon(
                  onPressed: _deleteSelected,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('删除', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
        
        // 文件列表
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return CheckboxListTile(
                secondary: const Icon(Icons.insert_drive_file),
                title: Text(item['name']),
                value: item['selected'],
                onChanged: (value) => _onItemChanged(index, value),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 样式自定义

### 自定义主题

```dart
// 在 MaterialApp 中全局定义
MaterialApp(
  theme: ThemeData(
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.purple;
        }
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: Colors.purple, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      splashRadius: 20,
      visualDensity: VisualDensity.compact,
    ),
  ),
);
```

### 自定义形状和边框

```dart
Checkbox(
  value: _isChecked,
  onChanged: (value) {
    setState(() => _isChecked = value ?? false);
  },
  // 圆形复选框
  shape: const CircleBorder(),
  // 自定义边框
  side: BorderSide(
    color: _isChecked ? Colors.blue : Colors.grey,
    width: 2,
  ),
  activeColor: Colors.blue,
  checkColor: Colors.white,
)
```

### 使用 Transform 调整大小

```dart
// Checkbox 没有 size 属性，可以用 Transform 缩放
Transform.scale(
  scale: 1.5, // 放大 1.5 倍
  child: Checkbox(
    value: _isChecked,
    onChanged: (value) {
      setState(() => _isChecked = value ?? false);
    },
  ),
)
```

### 自定义复选框组件

```dart
class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 24,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: value ? activeColor : inactiveColor,
            width: 2,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: size - 6,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
```

## 最佳实践

### 1. 提供清晰的标签

```dart
// ✅ 好的做法：使用 Row 或 CheckboxListTile 提供标签
Row(
  children: [
    Checkbox(value: _value, onChanged: _onChanged),
    GestureDetector(
      onTap: () => _onChanged(!_value),
      child: const Text('同意服务条款'),
    ),
  ],
)

// ❌ 避免：孤立的 Checkbox 没有标签
Checkbox(value: _value, onChanged: _onChanged)
```

### 2. 点击区域包含标签文字

```dart
// ✅ 好的做法：整行可点击
CheckboxListTile(
  title: const Text('启用通知'),
  value: _value,
  onChanged: _onChanged,
)

// 或使用 InkWell 包裹
InkWell(
  onTap: () => _onChanged(!_value),
  child: Row(
    children: [
      Checkbox(value: _value, onChanged: _onChanged),
      const Text('启用通知'),
    ],
  ),
)
```

### 3. 正确处理三态逻辑

```dart
// ✅ 正确的三态处理
void _onParentChanged(bool? value) {
  if (value == null) {
    // 从中间态变为 false
    _setAllChildren(false);
  } else if (value) {
    // 全选
    _setAllChildren(true);
  } else {
    // 取消全选
    _setAllChildren(false);
  }
}
```

### 4. 无障碍支持

```dart
Checkbox(
  value: _value,
  onChanged: _onChanged,
  // 提供语义标签
  semanticLabel: '同意用户协议',
)

// 使用 Semantics 包装
Semantics(
  label: '选择文件：report.pdf',
  checked: _isSelected,
  child: Checkbox(
    value: _isSelected,
    onChanged: _onChanged,
  ),
)
```

### 5. 禁用状态的视觉反馈

```dart
// 禁用时给出原因
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Checkbox(
          value: _premiumFeature,
          onChanged: _isPremiumUser ? _onChanged : null,
        ),
        Text(
          '高级功能',
          style: TextStyle(
            color: _isPremiumUser ? null : Colors.grey,
          ),
        ),
      ],
    ),
    if (!_isPremiumUser)
      const Padding(
        padding: EdgeInsets.only(left: 40),
        child: Text(
          '升级到高级版本解锁此功能',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
  ],
)
```

## 注意事项

1. **状态管理**：Checkbox 是无状态组件，需要外部管理状态并通过 `value` 传入
2. **空安全**：`onChanged` 回调参数是 `bool?`，处理时注意空值
3. **性能优化**：在长列表中使用时，考虑使用 `ListView.builder` 懒加载
4. **三态模式**：必须设置 `tristate: true` 才能使用 `null` 值
5. **触摸区域**：默认触摸区域较小，建议使用 `CheckboxListTile` 或扩大点击区域

## 相关组件

- [Switch](./switch.md) - 开关组件，用于二选一
- [Radio](./radio.md) - 单选按钮，用于多选一
- [CheckboxListTile](./checkboxlisttile.md) - 带标题的复选框列表项
- [ToggleButtons](../buttons/togglebuttons.md) - 切换按钮组
- [ChoiceChip](../material/choicechip.md) - 选择芯片

## 官方文档

- [Checkbox 类](https://api.flutter.dev/flutter/material/Checkbox-class.html)
- [CheckboxListTile 类](https://api.flutter.dev/flutter/material/CheckboxListTile-class.html)
- [CheckboxThemeData 类](https://api.flutter.dev/flutter/material/CheckboxThemeData-class.html)
- [Material Design Checkbox 规范](https://m3.material.io/components/checkbox/overview)
