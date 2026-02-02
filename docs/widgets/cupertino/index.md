# Cupertino 组件

Cupertino 组件是 Flutter 提供的 iOS 风格组件库，遵循 Apple 的 Human Interface Guidelines (HIG)，用于构建具有原生 iOS 外观的应用。

## 设计理念

iOS 设计强调：

- **清晰**: 文本清晰可读，图标精确
- **遵从**: 流畅的动画和界面突出内容
- **深度**: 视觉层次和真实感增强理解

## 组件分类

### 应用结构

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoApp](./cupertinoapp) | iOS 风格应用根组件 | 应用入口 |
| [CupertinoPageScaffold](./cupertinopagescaffold) | iOS 页面脚手架 | 页面结构 |
| [CupertinoTabScaffold](./cupertinotabscaffold) | 标签页脚手架 | 标签页布局 |

### 导航组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoNavigationBar](./cupertinonavigationbar) | iOS 导航栏 | 页面顶部导航 |
| [CupertinoSliverNavigationBar](./cupertinoslidernavigationbar) | 可折叠导航栏 | 大标题样式 |
| [CupertinoTabBar](./cupertinotabbar) | iOS 底部标签栏 | 主页面切换 |

### 按钮组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoButton](./cupertinobutton) | iOS 风格按钮 | 用户操作 |
| [CupertinoSegmentedControl](./cupertinosegmentedcontrol) | 分段控制器 | 选项切换 |
| [CupertinoSlidingSegmentedControl](./cupertinoslidsegmentedcontrol) | 滑动分段控制器 | 选项切换（推荐） |

### 输入组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoTextField](./cupertinotextfield) | iOS 风格输入框 | 文本输入 |
| [CupertinoSearchTextField](./cupertnosearchtextfield) | iOS 搜索框 | 搜索功能 |
| [CupertinoSwitch](./cupertinoswitch) | iOS 开关 | 二元切换 |
| [CupertinoSlider](./cupertinoslider) | iOS 滑块 | 数值调节 |
| [CupertinoCheckbox](./cupertinocheckbox) | iOS 复选框 | 多选操作 |
| [CupertinoRadio](./cupertinoradio) | iOS 单选按钮 | 单选操作 |

### 选择器组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoPicker](./cupertinopicker) | iOS 滚轮选择器 | 列表选择 |
| [CupertinoDatePicker](./cupertinodatepicker) | iOS 日期选择器 | 日期选择 |
| [CupertinoTimerPicker](./cupertinotimerpicker) | iOS 时间选择器 | 时长选择 |

### 对话框组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoAlertDialog](./cupertinoalertdialog) | iOS 警告对话框 | 重要提示 |
| [CupertinoActionSheet](./cupertinoactionsheet) | iOS 操作表单 | 操作选项 |
| [CupertinoPopupSurface](./cupertinopopupsurface) | iOS 弹出层 | 自定义弹出 |
| [CupertinoContextMenu](./cupertinocontextmenu) | iOS 上下文菜单 | 长按操作 |

### 列表组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoListSection](./cupertinolistsection) | iOS 列表分组 | 设置列表 |
| [CupertinoListTile](./cupertinolisttile) | iOS 列表项 | 列表内容 |
| [CupertinoFormSection](./cupertinoformsection) | iOS 表单分组 | 表单布局 |
| [CupertinoFormRow](./cupertinoformrow) | iOS 表单行 | 表单项 |

### 反馈组件

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| [CupertinoActivityIndicator](./cupertinoactivityindicator) | iOS 加载指示器 | 加载状态 |
| [CupertinoScrollbar](./cupertinoscrollbar) | iOS 滚动条 | 滚动指示 |

## 主题配置

```dart
CupertinoApp(
  theme: CupertinoThemeData(
    // 主色调
    primaryColor: CupertinoColors.systemBlue,
    // 主要对比色（用于导航栏按钮等）
    primaryContrastingColor: CupertinoColors.white,
    // 脚手架背景色
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    // 导航栏背景色
    barBackgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
    // 文字样式
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.label,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
    ),
    // 亮度模式
    brightness: Brightness.light,
  ),
)
```

## 动态颜色

Cupertino 组件支持 iOS 的动态颜色系统：

```dart
// 系统颜色会自动适应深色/浅色模式
Container(
  color: CupertinoColors.systemBackground,
  child: Text(
    '动态颜色文本',
    style: TextStyle(
      color: CupertinoColors.label,
    ),
  ),
)

// 自定义动态颜色
final myColor = CupertinoDynamicColor.withBrightness(
  color: Colors.blue,      // 浅色模式
  darkColor: Colors.cyan,  // 深色模式
);

// 获取当前模式的颜色
final resolvedColor = CupertinoDynamicColor.resolve(
  myColor, 
  context,
);
```

## Material vs Cupertino

| 特性 | Material | Cupertino |
|------|----------|-----------|
| 设计语言 | Material Design | Human Interface Guidelines |
| 适用平台 | Android 为主 | iOS 为主 |
| 导航样式 | AppBar | NavigationBar + 大标题 |
| 按钮样式 | 凸起/填充 | 无边框/透明 |
| 对话框 | 居中弹出 | 底部弹出 |
| 选择器 | 下拉/对话框 | 滚轮选择 |
| 开关 | 扁平化 | 圆润滑块 |

## 平台自适应

在实际开发中，通常需要根据平台显示不同风格：

```dart
import 'dart:io' show Platform;

Widget buildAdaptiveButton({
  required VoidCallback onPressed,
  required String text,
}) {
  if (Platform.isIOS) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(text),
  );
}

// 或使用 flutter_platform_widgets 包
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

PlatformElevatedButton(
  onPressed: () {},
  child: Text('自适应按钮'),
)
```

## 设计资源

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Flutter Cupertino Widgets](https://docs.flutter.dev/ui/widgets/cupertino)
- [iOS Design Resources](https://developer.apple.com/design/resources/)

