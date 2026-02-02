# Material 组件

Material Design 是 Google 设计的一套跨平台设计系统，Flutter 提供了完整的 Material 组件库实现。

## 设计理念

Material Design 3 (MD3) 是 Google 最新的设计规范，强调：

- **动态颜色**: 基于壁纸的个性化配色方案
- **自适应布局**: 响应不同屏幕尺寸
- **无障碍优先**: 确保所有用户都能使用

## 组件分类

### 脚手架与布局

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [Scaffold](./scaffold) | 页面脚手架 | 应用主结构 |
| [AppBar](./appbar) | 顶部应用栏 | 页面标题与操作 |
| [Drawer](./drawer) | 侧边抽屉 | 导航菜单 |
| [BottomSheet](./bottomsheet) | 底部弹出面板 | 更多选项展示 |

### 导航组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [BottomNavigationBar](./bottomnavigationbar) | 底部导航栏 | 主页面切换（3-5项） |
| [NavigationBar](./navigationbar) | M3 导航栏 | 主页面切换（推荐） |
| [NavigationRail](./navigationrail) | 侧边导航栏 | 大屏设备导航 |
| [TabBar](./tabbar) | 标签页栏 | 同级内容切换 |

### 信息展示

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [Card](./card) | 卡片 | 内容分组展示 |
| [Chip](./chip) | 标签芯片 | 筛选、选择、输入 |
| [ListTile](./listtile) | 列表项 | 列表内容展示 |
| [DataTable](./datatable) | 数据表格 | 结构化数据展示 |

### 反馈组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [Dialog](./dialog) | 对话框 | 重要提示与确认 |
| [SnackBar](./snackbar) | 底部提示条 | 轻量级反馈 |
| [ProgressIndicator](./progressindicator) | 进度指示器 | 加载状态展示 |
| [Badge](./badge) | 角标 | 通知数量提示 |

### 输入组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [TextField](./textfield) | 文本输入框 | 文本输入 |
| [Checkbox](./checkbox) | 复选框 | 多选操作 |
| [Radio](./radio) | 单选按钮 | 单选操作 |
| [Switch](./switch) | 开关 | 二元切换 |
| [Slider](./slider) | 滑块 | 数值选择 |
| [DropdownButton](./dropdownbutton) | 下拉选择 | 选项选择 |
| [DatePicker](./datepicker) | 日期选择器 | 日期选择 |
| [TimePicker](./timepicker) | 时间选择器 | 时间选择 |

### 按钮组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [ElevatedButton](./elevatedbutton) | 凸起按钮 | 主要操作 |
| [FilledButton](./filledbutton) | 填充按钮 | 强调操作 |
| [OutlinedButton](./outlinedbutton) | 轮廓按钮 | 次要操作 |
| [TextButton](./textbutton) | 文字按钮 | 最低优先级操作 |
| [IconButton](./iconbutton) | 图标按钮 | 工具栏操作 |
| [FloatingActionButton](./floatingactionbutton) | 浮动按钮 | 主要动作 |

## 主题配置

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,  // 启用 Material 3
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    // 组件主题定制
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
)
```

## Material 3 迁移指南

### 启用 Material 3

```dart
ThemeData(
  useMaterial3: true,
)
```

### 主要变化

| Material 2 | Material 3 | 说明 |
|------------|------------|------|
| `primarySwatch` | `colorScheme.fromSeed()` | 配色方案生成 |
| `ElevatedButton.styleFrom()` | 使用 `ButtonStyle` | 按钮样式 |
| 固定圆角 | 动态圆角 | 组件形状 |

## 设计资源

- [Material Design 3 官网](https://m3.material.io/)
- [Flutter Material Components](https://docs.flutter.dev/ui/widgets/material)
- [Material Theme Builder](https://m3.material.io/theme-builder)
