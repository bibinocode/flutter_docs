# Chip

`Chip` 是 Flutter Material Design 中的紧凑型元素，用于表示属性、输入、过滤或操作。Chip 系列组件是用户界面中常见的标签元素，适用于展示标签、分类筛选、多选操作等场景。

## 组件介绍

Chip 组件家族提供了多种变体，每种都针对特定的交互模式进行了优化。它们外观相似但行为不同，可以根据具体需求选择合适的类型。

## Chip 变体

| 组件 | 用途 | 交互特性 | 典型场景 |
|------|------|----------|----------|
| `Chip` | 基础标签 | 只读显示，可选删除 | 展示属性、标签 |
| `InputChip` | 输入标签 | 可选择、可删除、可点击 | 用户输入的标签、联系人选择 |
| `FilterChip` | 筛选标签 | 切换选中状态（多选） | 过滤条件、多选筛选 |
| `ChoiceChip` | 选择标签 | 互斥选择（单选） | 单选选项、分类切换 |
| `ActionChip` | 动作标签 | 触发动作 | 快捷操作、建议操作 |

## 常用属性

### Chip 基础属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `label` | `Widget` | 必填 | 标签内容，通常是 Text |
| `avatar` | `Widget?` | null | 左侧头像或图标 |
| `deleteIcon` | `Widget?` | null | 删除图标 |
| `onDeleted` | `VoidCallback?` | null | 删除回调，设置后显示删除图标 |
| `labelStyle` | `TextStyle?` | null | 标签文本样式 |
| `labelPadding` | `EdgeInsetsGeometry?` | null | 标签内边距 |
| `backgroundColor` | `Color?` | null | 背景颜色 |
| `padding` | `EdgeInsetsGeometry?` | null | 整体内边距 |
| `side` | `BorderSide?` | null | 边框样式 |
| `shape` | `OutlinedBorder?` | null | 形状 |
| `elevation` | `double?` | null | 阴影高度 |
| `shadowColor` | `Color?` | null | 阴影颜色 |

### 可选择类 Chip 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `selected` | `bool` | 是否选中 |
| `onSelected` | `ValueChanged<bool>?` | 选中状态变化回调 |
| `selectedColor` | `Color?` | 选中时的背景色 |
| `checkmarkColor` | `Color?` | 选中标记的颜色 |
| `showCheckmark` | `bool` | 是否显示选中标记 |

## 基础用法

### 基础标签

最简单的 Chip，用于展示信息：

```dart
Chip(
  label: Text('Flutter'),
)

// 带头像的标签
Chip(
  avatar: CircleAvatar(
    backgroundColor: Colors.blue,
    child: Text('F'),
  ),
  label: Text('Flutter'),
)

// 带删除按钮的标签
Chip(
  label: Text('可删除标签'),
  onDeleted: () {
    print('标签被删除');
  },
)
```

### 输入标签（InputChip）

用于表示用户输入的信息，如联系人、标签等：

```dart
InputChip(
  avatar: CircleAvatar(
    backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
  ),
  label: Text('张三'),
  onDeleted: () {
    print('移除联系人');
  },
  onPressed: () {
    print('点击查看详情');
  },
)

// 可选择的输入标签
InputChip(
  label: Text('重要'),
  selected: isSelected,
  onSelected: (bool value) {
    setState(() {
      isSelected = value;
    });
  },
  onDeleted: () {
    // 删除标签
  },
)
```

### 筛选标签（FilterChip）

用于多选筛选场景：

```dart
class FilterChipDemo extends StatefulWidget {
  @override
  State<FilterChipDemo> createState() => _FilterChipDemoState();
}

class _FilterChipDemoState extends State<FilterChipDemo> {
  final List<String> _filters = ['全部', '美食', '旅行', '科技', '娱乐'];
  final Set<String> _selectedFilters = {'全部'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _filters.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: _selectedFilters.contains(filter),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedFilters.add(filter);
              } else {
                _selectedFilters.remove(filter);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
```

### 选择标签（ChoiceChip）

用于单选场景，同一组中只能选择一个：

```dart
class ChoiceChipDemo extends StatefulWidget {
  @override
  State<ChoiceChipDemo> createState() => _ChoiceChipDemoState();
}

class _ChoiceChipDemoState extends State<ChoiceChipDemo> {
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  String _selectedSize = 'M';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _sizes.map((size) {
        return ChoiceChip(
          label: Text(size),
          selected: _selectedSize == size,
          onSelected: (bool selected) {
            if (selected) {
              setState(() {
                _selectedSize = size;
              });
            }
          },
        );
      }).toList(),
    );
  }
}
```

### 动作标签（ActionChip）

用于触发特定动作：

```dart
ActionChip(
  avatar: Icon(Icons.share, size: 18),
  label: Text('分享'),
  onPressed: () {
    // 执行分享操作
    print('分享内容');
  },
)

// 一组动作标签
Wrap(
  spacing: 8,
  children: [
    ActionChip(
      avatar: Icon(Icons.call, size: 18),
      label: Text('拨打电话'),
      onPressed: () {},
    ),
    ActionChip(
      avatar: Icon(Icons.message, size: 18),
      label: Text('发送消息'),
      onPressed: () {},
    ),
    ActionChip(
      avatar: Icon(Icons.directions, size: 18),
      label: Text('导航'),
      onPressed: () {},
    ),
  ],
)
```

## 完整示例：标签选择器

```dart
import 'package:flutter/material.dart';

class TagSelectorDemo extends StatefulWidget {
  const TagSelectorDemo({super.key});

  @override
  State<TagSelectorDemo> createState() => _TagSelectorDemoState();
}

class _TagSelectorDemoState extends State<TagSelectorDemo> {
  // 用户添加的标签
  final List<String> _userTags = ['Flutter', 'Dart'];
  
  // 可选的分类标签
  final List<String> _categories = ['前端', '后端', '移动端', 'AI', '数据库'];
  final Set<String> _selectedCategories = {};
  
  // 尺寸选择
  final List<String> _sizes = ['小', '中', '大'];
  String _selectedSize = '中';
  
  final TextEditingController _tagController = TextEditingController();

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_userTags.contains(tag)) {
      setState(() {
        _userTags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _userTags.remove(tag);
    });
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chip 标签选择器'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 基础标签展示
            _buildSection(
              title: '基础标签 (Chip)',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Chip(label: Text('只读标签')),
                  Chip(
                    avatar: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text('F', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    label: const Text('带头像'),
                  ),
                  Chip(
                    label: const Text('自定义样式'),
                    backgroundColor: Colors.amber.shade100,
                    side: BorderSide(color: Colors.amber.shade700),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 2. 输入标签（可添加删除）
            _buildSection(
              title: '输入标签 (InputChip)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 输入框
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: '输入标签名称',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: _addTag,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => _addTag(_tagController.text),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 标签列表
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _userTags.map((tag) {
                      return InputChip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('点击了标签: $tag')),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 3. 筛选标签（多选）
            _buildSection(
              title: '筛选标签 (FilterChip) - 多选',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '已选择: ${_selectedCategories.isEmpty ? "无" : _selectedCategories.join(", ")}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 4. 选择标签（单选）
            _buildSection(
              title: '选择标签 (ChoiceChip) - 单选',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sizes.map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _selectedSize == size,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _selectedSize = size;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前尺寸: $_selectedSize',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 5. 动作标签
            _buildSection(
              title: '动作标签 (ActionChip)',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.refresh, size: 18),
                    label: const Text('刷新'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('刷新中...')),
                      );
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.copy, size: 18),
                    label: const Text('复制'),
                    onPressed: () {},
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.share, size: 18),
                    label: const Text('分享'),
                    onPressed: () {},
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.download, size: 18),
                    label: const Text('下载'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
```

## Material 3 样式

Flutter 3.x 默认支持 Material 3 设计，Chip 组件会自动应用新的样式：

```dart
// 使用 Material 3 主题
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
  ),
  home: ChipDemo(),
)

// Material 3 Chip 自定义
FilterChip(
  label: const Text('Material 3'),
  selected: true,
  showCheckmark: true,
  checkmarkColor: Colors.white,
  // M3 风格的圆角
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  onSelected: (value) {},
)

// 使用 ChipTheme 统一配置
Theme(
  data: Theme.of(context).copyWith(
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      labelStyle: const TextStyle(fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: const StadiumBorder(),
    ),
  ),
  child: Wrap(
    spacing: 8,
    children: [
      FilterChip(label: Text('标签1'), selected: false, onSelected: (_) {}),
      FilterChip(label: Text('标签2'), selected: true, onSelected: (_) {}),
    ],
  ),
)
```

## 最佳实践

### 1. 选择合适的 Chip 类型

```dart
// ✅ 正确：根据用途选择
FilterChip(...)    // 多选筛选
ChoiceChip(...)    // 单选
ActionChip(...)    // 触发动作
InputChip(...)     // 用户输入

// ❌ 错误：用 Chip 模拟选择行为
GestureDetector(
  onTap: () {},
  child: Chip(...),  // 应该用专门的变体
)
```

### 2. 提供清晰的视觉反馈

```dart
// ✅ 选中状态有明显区分
FilterChip(
  label: Text('选项'),
  selected: isSelected,
  selectedColor: Theme.of(context).colorScheme.primaryContainer,
  checkmarkColor: Theme.of(context).colorScheme.primary,
  onSelected: (value) {},
)
```

### 3. 合理使用删除功能

```dart
// ✅ 只在用户添加的内容上提供删除
InputChip(
  label: Text(userInput),
  onDeleted: () => removeTag(userInput),
)

// ❌ 不要在固定选项上添加删除
FilterChip(
  label: Text('固定分类'),
  onDeleted: () {},  // 不合适
  onSelected: (value) {},
)
```

### 4. 使用 Wrap 布局

```dart
// ✅ 使用 Wrap 让标签自动换行
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: chips,
)

// ❌ 避免使用 Row 导致溢出
Row(
  children: chips,  // 可能溢出
)
```

### 5. 保持标签简洁

```dart
// ✅ 简短的标签文本
Chip(label: Text('Flutter'))

// ❌ 避免过长的文本
Chip(label: Text('这是一个非常非常长的标签文本'))
```

### 6. 无障碍支持

```dart
// ✅ 提供语义化信息
Semantics(
  label: '筛选标签：Flutter，当前已选中',
  child: FilterChip(
    label: Text('Flutter'),
    selected: true,
    onSelected: (value) {},
  ),
)
```

## 相关组件

- [Container](../basics/container.md) - 基础容器组件
- [Wrap](../layout/wrap.md) - 自动换行布局
- [Card](./card.md) - 卡片组件
- [Badge](./badge.md) - 徽章组件
- [ListTile](./listtile.md) - 列表项组件

## 官方文档

- [Chip API](https://api.flutter.dev/flutter/material/Chip-class.html)
- [InputChip API](https://api.flutter.dev/flutter/material/InputChip-class.html)
- [FilterChip API](https://api.flutter.dev/flutter/material/FilterChip-class.html)
- [ChoiceChip API](https://api.flutter.dev/flutter/material/ChoiceChip-class.html)
- [ActionChip API](https://api.flutter.dev/flutter/material/ActionChip-class.html)
- [Material Design Chips](https://m3.material.io/components/chips)
