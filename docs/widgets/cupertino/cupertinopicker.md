# CupertinoPicker

`CupertinoPicker` 是 iOS 风格的滚轮选择器，使用经典的 iOS 滚动轮样式，让用户从一组选项中进行选择。它模拟了 iOS 原生的 UIPickerView，支持滚动惯性、放大镜效果和自定义外观。

## 基本用法

```dart
CupertinoPicker(
  itemExtent: 32.0, // 每项高度
  onSelectedItemChanged: (int index) {
    print('选择了第 $index 项');
  },
  children: List<Widget>.generate(10, (index) {
    return Center(child: Text('选项 $index'));
  }),
)
```

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `itemExtent` | `double` | 每个子项的高度（必需） |
| `onSelectedItemChanged` | `ValueChanged<int>?` | 选中项变化回调 |
| `children` | `List<Widget>` | 子组件列表 |
| `scrollController` | `FixedExtentScrollController?` | 滚动控制器 |
| `diameterRatio` | `double` | 圆柱直径与视口高度比（默认1.07） |
| `backgroundColor` | `Color?` | 背景颜色 |
| `offAxisFraction` | `double` | 偏轴系数，控制倾斜效果（默认0.0） |
| `useMagnifier` | `bool` | 是否使用放大镜效果（默认false） |
| `magnification` | `double` | 放大倍率（默认1.0） |
| `squeeze` | `double` | 压缩系数，控制子项紧凑程度（默认1.45） |
| `selectionOverlay` | `Widget?` | 选中项覆盖层（默认CupertinoPickerDefaultSelectionOverlay） |

## 使用场景

### 1. 基础单选列表

```dart
class BasicPickerDemo extends StatefulWidget {
  @override
  State<BasicPickerDemo> createState() => _BasicPickerDemoState();
}

class _BasicPickerDemoState extends State<BasicPickerDemo> {
  int _selectedIndex = 0;
  final List<String> _items = ['苹果', '香蕉', '橙子', '葡萄', '西瓜', '草莓'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('选中: ${_items[_selectedIndex]}'),
        SizedBox(height: 20),
        Container(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: _items.map((item) {
              return Center(
                child: Text(item, style: TextStyle(fontSize: 18)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
```

### 2. 配合 showCupertinoModalPopup 底部弹出

```dart
class ModalPickerDemo extends StatefulWidget {
  @override
  State<ModalPickerDemo> createState() => _ModalPickerDemoState();
}

class _ModalPickerDemoState extends State<ModalPickerDemo> {
  String _selectedFruit = '苹果';
  final List<String> _fruits = ['苹果', '香蕉', '橙子', '葡萄', '西瓜', '草莓', '芒果', '菠萝'];

  void _showPicker() {
    int tempIndex = _fruits.indexOf(_selectedFruit);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            // 顶部操作栏
            Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => _selectedFruit = _fruits[tempIndex]);
                      Navigator.pop(context);
                    },
                    child: Text('确定'),
                  ),
                ],
              ),
            ),
            // 选择器
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: tempIndex,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  tempIndex = index;
                },
                children: _fruits.map((fruit) {
                  return Center(
                    child: Text(fruit, style: TextStyle(fontSize: 20)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('选择水果'),
      ),
      child: Center(
        child: CupertinoButton(
          onPressed: _showPicker,
          child: Text('当前选择: $_selectedFruit'),
        ),
      ),
    );
  }
}
```

## 完整示例：省市区三级联动选择器

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 省市区数据模型
class Region {
  final String name;
  final List<Region>? children;

  Region({required this.name, this.children});
}

class RegionPickerDemo extends StatefulWidget {
  @override
  State<RegionPickerDemo> createState() => _RegionPickerDemoState();
}

class _RegionPickerDemoState extends State<RegionPickerDemo> {
  // 模拟省市区数据
  final List<Region> _provinces = [
    Region(
      name: '北京市',
      children: [
        Region(
          name: '北京市',
          children: [
            Region(name: '东城区'),
            Region(name: '西城区'),
            Region(name: '朝阳区'),
            Region(name: '丰台区'),
            Region(name: '海淀区'),
            Region(name: '石景山区'),
          ],
        ),
      ],
    ),
    Region(
      name: '广东省',
      children: [
        Region(
          name: '广州市',
          children: [
            Region(name: '天河区'),
            Region(name: '越秀区'),
            Region(name: '海珠区'),
            Region(name: '白云区'),
            Region(name: '番禺区'),
          ],
        ),
        Region(
          name: '深圳市',
          children: [
            Region(name: '福田区'),
            Region(name: '罗湖区'),
            Region(name: '南山区'),
            Region(name: '宝安区'),
            Region(name: '龙岗区'),
          ],
        ),
        Region(
          name: '东莞市',
          children: [
            Region(name: '莞城街道'),
            Region(name: '南城街道'),
            Region(name: '东城街道'),
            Region(name: '万江街道'),
          ],
        ),
      ],
    ),
    Region(
      name: '浙江省',
      children: [
        Region(
          name: '杭州市',
          children: [
            Region(name: '上城区'),
            Region(name: '下城区'),
            Region(name: '西湖区'),
            Region(name: '滨江区'),
            Region(name: '余杭区'),
          ],
        ),
        Region(
          name: '宁波市',
          children: [
            Region(name: '海曙区'),
            Region(name: '江北区'),
            Region(name: '北仑区'),
            Region(name: '镇海区'),
          ],
        ),
      ],
    ),
  ];

  int _provinceIndex = 0;
  int _cityIndex = 0;
  int _districtIndex = 0;

  String _selectedRegion = '';

  List<Region> get _cities => _provinces[_provinceIndex].children ?? [];
  List<Region> get _districts => _cities.isNotEmpty 
      ? (_cities[_cityIndex].children ?? []) 
      : [];

  void _showRegionPicker() {
    // 临时变量保存选择状态
    int tempProvinceIndex = _provinceIndex;
    int tempCityIndex = _cityIndex;
    int tempDistrictIndex = _districtIndex;

    // 创建控制器
    final provinceController = FixedExtentScrollController(initialItem: tempProvinceIndex);
    final cityController = FixedExtentScrollController(initialItem: tempCityIndex);
    final districtController = FixedExtentScrollController(initialItem: tempDistrictIndex);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // 获取当前的市和区列表
            List<Region> cities = _provinces[tempProvinceIndex].children ?? [];
            List<Region> districts = cities.isNotEmpty 
                ? (cities[tempCityIndex].children ?? []) 
                : [];

            return Container(
              height: 350,
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: Column(
                children: [
                  // 顶部操作栏
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.separator.resolveFrom(context),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          child: Text('取消', style: TextStyle(color: CupertinoColors.destructiveRed)),
                        ),
                        Text(
                          '选择地区',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _provinceIndex = tempProvinceIndex;
                              _cityIndex = tempCityIndex;
                              _districtIndex = tempDistrictIndex;
                              
                              String province = _provinces[_provinceIndex].name;
                              String city = _cities.isNotEmpty ? _cities[_cityIndex].name : '';
                              String district = _districts.isNotEmpty ? _districts[_districtIndex].name : '';
                              _selectedRegion = '$province $city $district';
                            });
                            Navigator.pop(context);
                          },
                          child: Text('确定'),
                        ),
                      ],
                    ),
                  ),
                  // 三列选择器
                  Expanded(
                    child: Row(
                      children: [
                        // 省份选择器
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: provinceController,
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempProvinceIndex = index;
                                tempCityIndex = 0;
                                tempDistrictIndex = 0;
                                // 重置市和区的滚动位置
                                cityController.jumpToItem(0);
                                districtController.jumpToItem(0);
                              });
                            },
                            children: _provinces.map((province) {
                              return Center(
                                child: Text(
                                  province.name,
                                  style: TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // 城市选择器
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: cityController,
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempCityIndex = index;
                                tempDistrictIndex = 0;
                                districtController.jumpToItem(0);
                              });
                            },
                            children: cities.isEmpty
                                ? [Center(child: Text('-'))]
                                : cities.map((city) {
                                    return Center(
                                      child: Text(
                                        city.name,
                                        style: TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),
                        // 区县选择器
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: districtController,
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              tempDistrictIndex = index;
                            },
                            children: districts.isEmpty
                                ? [Center(child: Text('-'))]
                                : districts.map((district) {
                                    return Center(
                                      child: Text(
                                        district.name,
                                        style: TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('省市区选择器'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedRegion.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    '已选择: $_selectedRegion',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              CupertinoButton.filled(
                onPressed: _showRegionPicker,
                child: Text('选择地区'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 主函数
void main() {
  runApp(CupertinoApp(
    theme: CupertinoThemeData(
      brightness: Brightness.light,
    ),
    home: RegionPickerDemo(),
  ));
}
```

## 自定义样式示例

```dart
class CustomStylePickerDemo extends StatelessWidget {
  final List<String> items = List.generate(20, (i) => '选项 ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: CupertinoPicker(
        itemExtent: 50,
        diameterRatio: 1.5, // 更大的圆柱直径
        squeeze: 1.2, // 更紧凑的子项
        useMagnifier: true, // 启用放大镜效果
        magnification: 1.2, // 放大倍率
        offAxisFraction: 0.2, // 轻微倾斜
        backgroundColor: CupertinoColors.systemGroupedBackground,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: CupertinoColors.activeBlue, width: 2),
              bottom: BorderSide(color: CupertinoColors.activeBlue, width: 2),
            ),
          ),
        ),
        onSelectedItemChanged: (index) {
          print('选择了: ${items[index]}');
        },
        children: items.map((item) {
          return Center(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

## 最佳实践

1. **设置合适的 itemExtent** - 根据内容调整每项高度，通常 32-50 之间，确保文字清晰可读
2. **使用 FixedExtentScrollController** - 需要控制初始位置或程序化滚动时使用控制器
3. **配合 showCupertinoModalPopup** - 在 iOS 风格应用中，通常从底部弹出选择器
4. **联动选择时注意重置** - 上级选项变化时，重置下级选项的索引和滚动位置
5. **使用 StatefulBuilder** - 在 Modal 中使用 StatefulBuilder 管理临时状态
6. **避免过多选项** - 选项过多时考虑分组或搜索功能
7. **提供默认选中项** - 使用 scrollController 设置初始选中位置
8. **保持一致的视觉风格** - 在 iOS 风格应用中统一使用 Cupertino 组件
9. **处理空列表情况** - 联动选择时，子列表可能为空，需要显示占位内容
10. **优化滚动体验** - 合理设置 squeeze 和 diameterRatio 提升滚动手感

## 相关组件

- [ListWheelScrollView](../scrolling/listwheelscrollview.md) - 更底层的滚轮滚动视图
- [CupertinoDatePicker](./cupertinodatepicker.md) - iOS 风格日期选择器
- [CupertinoTimerPicker](./cupertinotiimerpicker.md) - iOS 风格计时器选择器
- [CupertinoActionSheet](./cupertinoactionsheet.md) - iOS 风格操作表单

## 官方文档

- [CupertinoPicker API](https://api.flutter.dev/flutter/cupertino/CupertinoPicker-class.html)
- [FixedExtentScrollController API](https://api.flutter.dev/flutter/widgets/FixedExtentScrollController-class.html)
