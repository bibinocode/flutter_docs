# 主题配色生成器

Flutter 应用的主题配色直接影响用户体验。本章介绍如何使用在线工具生成美观、符合无障碍标准的 `ColorScheme`，以及 Material 3 配色系统的使用方法。

## 为什么需要配色生成器？

与其在应用启动时使用 `ColorScheme.fromSeed()` 动态计算配色，不如直接使用预先生成并经过人工微调的静态 `ColorScheme`：

| 方式 | 优点 | 缺点 |
|------|------|------|
| `fromSeed()` 动态生成 | 简单快捷 | 启动时计算、无法微调 |
| 静态预生成 | 可微调、启动快 | 需要使用工具生成 |

## 配色工具对比

### Material Theme Builder（推荐）

**官方地址**: https://material-foundation.github.io/material-theme-builder/

**优点**:
- ✅ 界面美观，交互体验出色
- ✅ 取色器稳健好用
- ✅ 支持图片导入提取颜色
- ✅ 完全符合无障碍对比度标准
- ✅ 生成三种对比度级别（低/中/高）
- ✅ 直接导出 Dart 文件

**缺点**:
- ⚠️ 仅生成 `ColorScheme`，不含完整 `ThemeData`

### FlexColorScheme Playground

**官方地址**: https://docs.flexcolorscheme.com/

**优点**:
- ✅ 功能最强大的主题配置工具
- ✅ 精细控制表层颜色、混合度
- ✅ 内置数十种高质量预设配色
- ✅ 实时代码预览

**缺点**:
- ⚠️ 需要配合 `flex_color_scheme` 包使用
- ⚠️ 学习曲线较陡

### Flutter Theme Generator

**官方地址**: https://theme.ionicerrrrscode.com/

**优点**:
- ✅ 支持图片取色
- ✅ 生成完整 `ThemeData`
- ✅ 支持导出 Dart 文件

**缺点**:
- ⚠️ 部分颜色组合对比度不达标
- ⚠️ 高对比度版本效果不稳定

### Appainter

**官方地址**: https://appainter.dev/

**缺点**:
- ❌ 界面卡顿，Bug 较多
- ❌ 取色器难用
- ❌ 不支持图片取色
- ❌ 仅支持 JSON 导出

## Material Theme Builder 使用指南

### 基本使用流程

1. 访问 https://material-foundation.github.io/material-theme-builder/
2. 选择或自定义主色调
3. （可选）从图片中提取颜色
4. 预览生成的配色方案
5. 下载 Dart 文件

### 导出的文件结构

下载的 ZIP 包含以下文件：

```
material-theme/
├── theme.dart          # 主题入口
├── color_schemes.g.dart # ColorScheme 定义
└── util.dart           # 工具函数
```

### 集成到项目

#### 方式一：直接使用生成的 ColorScheme

```dart
// lib/theme/color_schemes.dart
import 'package:flutter/material.dart';

class AppColorSchemes {
  // 浅色主题 - 普通对比度
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff7c580d),
    surfaceTint: Color(0xff7c580d),
    onPrimary: Color(0xffffffff),
    primaryContainer: Color(0xffffdeab),
    onPrimaryContainer: Color(0xff271900),
    secondary: Color(0xff6d5c3f),
    onSecondary: Color(0xffffffff),
    secondaryContainer: Color(0xfff8dfbb),
    onSecondaryContainer: Color(0xff261904),
    tertiary: Color(0xff4e6544),
    onTertiary: Color(0xffffffff),
    tertiaryContainer: Color(0xffd0ebc1),
    onTertiaryContainer: Color(0xff0c2006),
    error: Color(0xffba1a1a),
    onError: Color(0xffffffff),
    errorContainer: Color(0xffffdad6),
    onErrorContainer: Color(0xff410002),
    surface: Color(0xfffff8f3),
    onSurface: Color(0xff1f1b16),
    onSurfaceVariant: Color(0xff4e4539),
    outline: Color(0xff807567),
    outlineVariant: Color(0xffd2c4b4),
    shadow: Color(0xff000000),
    scrim: Color(0xff000000),
    inverseSurface: Color(0xff35302a),
    inversePrimary: Color(0xfff0c078),
  );

  // 深色主题 - 普通对比度
  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xfff0c078),
    surfaceTint: Color(0xfff0c078),
    onPrimary: Color(0xff422c00),
    primaryContainer: Color(0xff5f4100),
    onPrimaryContainer: Color(0xffffdeab),
    secondary: Color(0xffdbc3a1),
    onSecondary: Color(0xff3c2e15),
    secondaryContainer: Color(0xff54442a),
    onSecondaryContainer: Color(0xfff8dfbb),
    tertiary: Color(0xffb4cfa6),
    onTertiary: Color(0xff213619),
    tertiaryContainer: Color(0xff374d2e),
    onTertiaryContainer: Color(0xffd0ebc1),
    error: Color(0xffffb4ab),
    onError: Color(0xff690005),
    errorContainer: Color(0xff93000a),
    onErrorContainer: Color(0xffffdad6),
    surface: Color(0xff17130e),
    onSurface: Color(0xffebe1d9),
    onSurfaceVariant: Color(0xffd2c4b4),
    outline: Color(0xff9b8f80),
    outlineVariant: Color(0xff4e4539),
    shadow: Color(0xff000000),
    scrim: Color(0xff000000),
    inverseSurface: Color(0xffebe1d9),
    inversePrimary: Color(0xff7c580d),
  );

  // 浅色主题 - 高对比度
  static const lightHighContrastScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xff2e1e00),
    // ... 其他颜色
  );

  // 深色主题 - 高对比度
  static const darkHighContrastScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xfffffaf6),
    // ... 其他颜色
  );
}
```

#### 方式二：在 ThemeData 中使用

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.lightScheme,
      // 可以继续自定义其他主题属性
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.darkScheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

#### 方式三：应用到 MaterialApp

```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
```

## FlexColorScheme 使用

### 安装

```yaml
dependencies:
  flex_color_scheme: ^7.3.1
```

### 使用预设主题

```dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 使用预设的配色方案
      theme: FlexThemeData.light(
        scheme: FlexScheme.mandyRed,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.mandyRed,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
```

### 自定义配色

```dart
// 完全自定义的配色方案
final FlexSchemeColor customColors = FlexSchemeColor.from(
  primary: const Color(0xFF6750A4),
  secondary: const Color(0xFF625B71),
  tertiary: const Color(0xFF7D5260),
);

// 应用自定义配色
theme: FlexThemeData.light(
  colors: customColors,
  useMaterial3: true,
),
```

## Material 3 色彩系统

### 色彩角色

Material 3 定义了完整的色彩角色系统：

```
┌─────────────────────────────────────────────────────────────────┐
│                  Material 3 色彩角色                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Primary（主色）          用于关键组件（FAB、按钮等）              │
│  ├─ primary             主色                                    │
│  ├─ onPrimary           主色上的前景色                           │
│  ├─ primaryContainer    主色容器                                │
│  └─ onPrimaryContainer  主色容器上的前景色                       │
│                                                                 │
│  Secondary（次要色）      用于次要组件                            │
│  ├─ secondary           次要色                                  │
│  ├─ onSecondary         次要色上的前景色                         │
│  └─ ...                                                        │
│                                                                 │
│  Tertiary（第三色）       用于强调和平衡                          │
│                                                                 │
│  Error（错误色）          用于错误状态                            │
│                                                                 │
│  Surface（表面色）        用于背景                               │
│  ├─ surface             表面色                                  │
│  ├─ onSurface           表面色上的前景色                         │
│  ├─ surfaceVariant      表面变体                                │
│  └─ onSurfaceVariant    表面变体上的前景色                       │
│                                                                 │
│  Outline（轮廓色）        用于边框和分隔线                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 在代码中使用

```dart
class ColorUsageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // 主色按钮
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () {},
          child: const Text('主要操作'),
        ),
        
        // 次要按钮
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.secondary,
            side: BorderSide(color: colorScheme.outline),
          ),
          onPressed: () {},
          child: const Text('次要操作'),
        ),
        
        // 卡片背景
        Card(
          color: colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '卡片内容',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        
        // 错误提示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '错误信息',
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
        ),
      ],
    );
  }
}
```

## 动态主题切换

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ColorScheme _lightScheme = AppColorSchemes.lightScheme;
  ColorScheme _darkScheme = AppColorSchemes.darkScheme;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _lightScheme,
  );
  
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _darkScheme,
  );
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void setColorScheme({
    ColorScheme? light,
    ColorScheme? dark,
  }) {
    if (light != null) _lightScheme = light;
    if (dark != null) _darkScheme = dark;
    notifyListeners();
  }
}

// 使用
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
```

## 最佳实践

::: tip 配色建议
1. **使用官方工具** - Material Theme Builder 生成的配色最规范
2. **检查对比度** - 确保文字可读性，符合 WCAG 标准
3. **测试两种模式** - 同时测试浅色和深色主题
4. **保持一致性** - 整个应用使用统一的色彩角色
5. **预生成配色** - 不要在运行时动态计算
:::

::: warning 常见问题
- 避免使用纯黑 `#000000` 或纯白 `#FFFFFF` 作为背景
- 高对比度模式需要单独测试
- 不同设备的色彩显示可能有差异
:::

## 参考资源

- [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/)
- [FlexColorScheme Playground](https://docs.flexcolorscheme.com/)
- [Material 3 色彩系统](https://m3.material.io/styles/color/system/how-the-system-works)
- [色彩角色详解](https://m3.material.io/styles/color/roles)
