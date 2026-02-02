# Widget 大全

Flutter 提供了丰富的 Widget 来构建用户界面。本文档整理了 **200+** 常用 Widget 的详细说明和使用示例，帮助你快速找到合适的组件。

> 📚 数据来源: [Flutter Widgets 官方目录](https://api.flutter-io.cn/flutter/widgets/) | [Material 组件库](https://m3.material.io/components)

## 分类导航

### 📦 [基础组件](./basics/)

构建界面的基础砖块：

| 组件 | 说明 |
|------|------|
| [Text](./basics/text.md) | 显示文本 |
| [Image](./basics/image.md) | 显示图片 |
| [Icon](./basics/icon.md) | Material 图标 |
| [Container](./basics/container.md) | 通用容器 |
| [Padding](./basics/padding.md) | 添加内边距 |
| [Center](./basics/center.md) | 居中子组件 |
| [SizedBox](./basics/sizedbox.md) | 固定尺寸盒子 |
| [Expanded](./basics/expanded.md) | 弹性扩展 |
| [Flexible](./basics/flexible.md) | 弹性控制 |
| [Spacer](./basics/spacer.md) | 弹性空间 |

### 📐 [布局组件](./layout/)

灵活的布局系统：

| 组件 | 说明 |
|------|------|
| [Row](./layout/row.md) | 水平布局 |
| [Column](./layout/column.md) | 垂直布局 |
| [Stack](./layout/stack.md) | 层叠布局 |
| [Positioned](./layout/positioned.md) | Stack 中定位 |
| [Wrap](./layout/wrap.md) | 自动换行布局 |
| [Flow](./layout/flow.md) | 流式自定义布局 |
| [LayoutBuilder](./layout/layoutbuilder.md) | 响应式布局 |
| [ConstrainedBox](./layout/constrainedbox.md) | 约束盒子 |
| [AspectRatio](./layout/aspectratio.md) | 宽高比 |
| [FittedBox](./layout/fittedbox.md) | 缩放适应 |

### 📜 [滚动组件](./scrolling/)

处理可滚动内容：

| 组件 | 说明 |
|------|------|
| [ListView](./scrolling/listview.md) | 列表视图 |
| [GridView](./scrolling/gridview.md) | 网格视图 |
| [SingleChildScrollView](./scrolling/singlechildscrollview.md) | 单子组件滚动 |
| [CustomScrollView](./scrolling/customscrollview.md) | 自定义 Sliver 滚动 |
| [PageView](./scrolling/pageview.md) | 页面滚动 |
| [RefreshIndicator](./scrolling/refreshindicator.md) | 下拉刷新 |
| [ReorderableListView](./scrolling/reorderablelistview.md) | 可排序列表 |
| [Scrollbar](./scrolling/scrollbar.md) | 滚动条 |

### 🎨 [Material 组件](./material/)

Material Design 设计系统：

| 组件 | 说明 |
|------|------|
| [Scaffold](./material/scaffold.md) | 页面脚手架 |
| [AppBar](./material/appbar.md) | 顶部导航栏 |
| [NavigationBar](./material/navigationbar.md) | 底部导航栏 (M3) |
| [BottomNavigationBar](./material/bottomnavigationbar.md) | 底部导航栏 |
| [NavigationRail](./material/navigationrail.md) | 侧边导航栏 |
| [Drawer](./material/drawer.md) | 抽屉菜单 |
| [TabBar](./material/tabbar.md) | 选项卡 |
| [Card](./material/card.md) | 卡片 |
| [Chip](./material/chip.md) | 标签芯片 |
| [ListTile](./material/listtile.md) | 列表项 |
| [Dialog](./material/dialog.md) | 对话框 |
| [BottomSheet](./material/bottomsheet.md) | 底部面板 |
| [SnackBar](./material/snackbar.md) | 消息提示 |

### 🔘 [按钮组件](./buttons/)

交互操作入口：

| 组件 | 说明 |
|------|------|
| [ElevatedButton](./buttons/elevatedbutton.md) | 凸起按钮 |
| [FilledButton](./buttons/filledbutton.md) | 填充按钮 (M3) |
| [OutlinedButton](./buttons/outlinedbutton.md) | 轮廓按钮 |
| [TextButton](./buttons/textbutton.md) | 文本按钮 |
| [IconButton](./buttons/iconbutton.md) | 图标按钮 |
| [FloatingActionButton](./buttons/floatingactionbutton.md) | 浮动操作按钮 |
| [PopupMenuButton](./buttons/popupmenubutton.md) | 弹出菜单按钮 |
| [DropdownButton](./buttons/dropdownbutton.md) | 下拉按钮 |

### ✏️ [输入组件](./input/)

用户输入控件：

| 组件 | 说明 |
|------|------|
| [TextField](./input/textfield.md) | 文本输入框 |
| [TextFormField](./input/textformfield.md) | 表单文本输入 |
| [Checkbox](./input/checkbox.md) | 复选框 |
| [Radio](./input/radio.md) | 单选按钮 |
| [Switch](./input/switch.md) | 开关 |
| [Slider](./input/slider.md) | 滑块 |
| [DatePicker](./input/datepicker.md) | 日期选择器 |
| [TimePicker](./input/timepicker.md) | 时间选择器 |

### ✨ [动画组件](./animation/)

隐式和显式动画：

| 组件 | 说明 |
|------|------|
| [AnimatedContainer](./animation/animatedcontainer.md) | 隐式容器动画 |
| [AnimatedOpacity](./animation/animatedopacity.md) | 隐式透明度动画 |
| [AnimatedPositioned](./animation/animatedpositioned.md) | 隐式位置动画 |
| [AnimatedCrossFade](./animation/animatedcrossfade.md) | 交叉淡入淡出 |
| [AnimatedSwitcher](./animation/animatedswitcher.md) | 通用切换动画 |
| [Hero](./animation/hero.md) | 共享元素动画 |
| [FadeTransition](./animation/fadetransition.md) | 显式淡入淡出 |
| [ScaleTransition](./animation/scaletransition.md) | 显式缩放 |
| [SlideTransition](./animation/slidetransition.md) | 显式滑动 |
| [RotationTransition](./animation/rotationtransition.md) | 显式旋转 |

### 👆 [手势组件](./gesture/)

触摸和手势识别：

| 组件 | 说明 |
|------|------|
| [GestureDetector](./gesture/gesturedetector.md) | 手势检测器 |
| [InkWell](./gesture/inkwell.md) | 带涟漪效果 |
| [Draggable](./gesture/draggable.md) | 可拖拽组件 |
| [DragTarget](./gesture/dragtarget.md) | 拖拽目标 |
| [Dismissible](./gesture/dismissible.md) | 滑动删除 |
| [LongPressDraggable](./gesture/longpressdraggable.md) | 长按拖拽 |

### 🍎 [Cupertino 组件](./cupertino/)

iOS 风格组件：

| 组件 | 说明 |
|------|------|
| [CupertinoApp](./cupertino/cupertinoapp.md) | iOS 应用 |
| [CupertinoNavigationBar](./cupertino/cupertinonavigationbar.md) | iOS 导航栏 |
| [CupertinoTabBar](./cupertino/cupertinotabbar.md) | iOS 标签栏 |
| [CupertinoButton](./cupertino/cupertinobutton.md) | iOS 按钮 |
| [CupertinoTextField](./cupertino/cupertinotextfield.md) | iOS 输入框 |
| [CupertinoSwitch](./cupertino/cupertinoswitch.md) | iOS 开关 |
| [CupertinoSlider](./cupertino/cupertinoslider.md) | iOS 滑块 |
| [CupertinoPicker](./cupertino/cupertinopicker.md) | iOS 选择器 |
| [CupertinoDatePicker](./cupertino/cupertinodatepicker.md) | iOS 日期选择 |
| [CupertinoActionSheet](./cupertino/cupertinoactionsheet.md) | iOS 操作表单 |
| [CupertinoAlertDialog](./cupertino/cupertinoalertdialog.md) | iOS 对话框 |


## 🧭 如何选择 Widget

| 需求 | 推荐 Widget |
|------|------------|
| 显示文字 | `Text`, `RichText`, `SelectableText` |
| 显示图片 | `Image`, `FadeInImage`, `CachedNetworkImage` |
| 按钮交互 | `ElevatedButton`, `TextButton`, `IconButton` |
| 输入文本 | `TextField`, `TextFormField` |
| 列表展示 | `ListView`, `ListView.builder` |
| 网格展示 | `GridView`, `GridView.builder` |
| 页面布局 | `Scaffold`, `AppBar`, `NavigationBar` |
| 弹窗提示 | `showDialog`, `SnackBar`, `showModalBottomSheet` |
| 动画效果 | `AnimatedContainer`, `Hero`, `AnimationController` |
| iOS 风格 | `CupertinoApp`, `CupertinoButton`, `CupertinoSwitch` |

## 🔍 快速查找

按首字母查找常用 Widget：

**A**: [AnimatedContainer](./animation/animatedcontainer.md) · [AnimatedCrossFade](./animation/animatedcrossfade.md) · [AnimatedOpacity](./animation/animatedopacity.md) · [AnimatedPositioned](./animation/animatedpositioned.md) · [AnimatedSwitcher](./animation/animatedswitcher.md) · [AppBar](./material/appbar.md) · [AspectRatio](./layout/aspectratio.md)

**B**: [BottomNavigationBar](./material/bottomnavigationbar.md) · [BottomSheet](./material/bottomsheet.md)

**C**: [Card](./material/card.md) · [Center](./basics/center.md) · [Checkbox](./input/checkbox.md) · [Chip](./material/chip.md) · [Column](./layout/column.md) · [ConstrainedBox](./layout/constrainedbox.md) · [Container](./basics/container.md) · [CupertinoButton](./cupertino/cupertinobutton.md) · [CupertinoSwitch](./cupertino/cupertinoswitch.md) · [CustomScrollView](./scrolling/customscrollview.md)

**D**: [DatePicker](./input/datepicker.md) · [Dialog](./material/dialog.md) · [Dismissible](./gesture/dismissible.md) · [Draggable](./gesture/draggable.md) · [Drawer](./material/drawer.md) · [DropdownButton](./buttons/dropdownbutton.md)

**E**: [ElevatedButton](./buttons/elevatedbutton.md) · [Expanded](./basics/expanded.md)

**F**: [FadeTransition](./animation/fadetransition.md) · [FilledButton](./buttons/filledbutton.md) · [FittedBox](./layout/fittedbox.md) · [Flexible](./basics/flexible.md) · [FloatingActionButton](./buttons/floatingactionbutton.md) · [Flow](./layout/flow.md)

**G**: [GestureDetector](./gesture/gesturedetector.md) · [GridView](./scrolling/gridview.md)

**H**: [Hero](./animation/hero.md)

**I**: [Icon](./basics/icon.md) · [IconButton](./buttons/iconbutton.md) · [Image](./basics/image.md) · [InkWell](./gesture/inkwell.md)

**L**: [LayoutBuilder](./layout/layoutbuilder.md) · [ListView](./scrolling/listview.md) · [ListTile](./material/listtile.md)

**N**: [NavigationBar](./material/navigationbar.md) · [NavigationRail](./material/navigationrail.md)

**O**: [OutlinedButton](./buttons/outlinedbutton.md)

**P**: [Padding](./basics/padding.md) · [PageView](./scrolling/pageview.md) · [Positioned](./layout/positioned.md)

**R**: [Radio](./input/radio.md) · [RefreshIndicator](./scrolling/refreshindicator.md) · [RotationTransition](./animation/rotationtransition.md) · [Row](./layout/row.md)

**S**: [Scaffold](./material/scaffold.md) · [ScaleTransition](./animation/scaletransition.md) · [SingleChildScrollView](./scrolling/singlechildscrollview.md) · [SizedBox](./basics/sizedbox.md) · [Slider](./input/slider.md) · [SlideTransition](./animation/slidetransition.md) · [SnackBar](./material/snackbar.md) · [Spacer](./basics/spacer.md) · [Stack](./layout/stack.md) · [Switch](./input/switch.md)

**T**: [TabBar](./material/tabbar.md) · [Text](./basics/text.md) · [TextButton](./buttons/textbutton.md) · [TextField](./input/textfield.md) · [TextFormField](./input/textformfield.md)

**W**: [Wrap](./layout/wrap.md)

## 📖 学习资源

- [Flutter Widget 目录](https://docs.flutter.cn/reference/widgets) - 官方 Widget 索引
- [Flutter API 文档](https://api.flutter-io.cn/flutter/widgets/) - 详细 API 参考
- [Material Design 3](https://m3.material.io/components) - Material 组件规范
- [每周 Widget 视频](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG) - 官方视频教程
