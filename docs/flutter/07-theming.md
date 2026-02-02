# 主题与样式

Flutter 提供了强大的主题系统，让你能够统一管理应用的视觉风格。本章将深入讲解如何创建和使用主题。

## 主题基础

### ThemeData

`ThemeData` 是 Flutter 主题的核心类，定义了应用的所有视觉属性：

```dart
MaterialApp(
  theme: ThemeData(
    // 主色调
    primarySwatch: Colors.blue,
    
    // 或使用 ColorScheme（推荐）
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    
    // 是否使用 Material 3
    useMaterial3: true,
  ),
  home: HomePage(),
)
```

### Material 3 主题

Flutter 3.0+ 推荐使用 Material 3：

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
)
```

## ColorScheme（配色方案）

### 从种子颜色生成

```dart
// 自动生成协调的配色方案
final colorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF6750A4),  // 主色
  brightness: Brightness.light,
);

// 深色主题
final darkColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF6750A4),
  brightness: Brightness.dark,
);
```

### 自定义配色

```dart
final colorScheme = ColorScheme(
  brightness: Brightness.light,
  
  // 主色系
  primary: Color(0xFF6750A4),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFEADDFF),
  onPrimaryContainer: Color(0xFF21005D),
  
  // 次要色系
  secondary: Color(0xFF625B71),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFE8DEF8),
  onSecondaryContainer: Color(0xFF1D192B),
  
  // 第三色系
  tertiary: Color(0xFF7D5260),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFFFD8E4),
  onTertiaryContainer: Color(0xFF31111D),
  
  // 错误色系
  error: Color(0xFFB3261E),
  onError: Colors.white,
  errorContainer: Color(0xFFF9DEDC),
  onErrorContainer: Color(0xFF410E0B),
  
  // 背景和表面
  background: Color(0xFFFFFBFE),
  onBackground: Color(0xFF1C1B1F),
  surface: Color(0xFFFFFBFE),
  onSurface: Color(0xFF1C1B1F),
  
  // 轮廓和阴影
  outline: Color(0xFF79747E),
  shadow: Colors.black,
);
```

### 使用配色

```dart
// 在组件中使用
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  
  return Container(
    color: colorScheme.primaryContainer,
    child: Text(
      'Hello',
      style: TextStyle(color: colorScheme.onPrimaryContainer),
    ),
  );
}
```

## 文字主题

### TextTheme

```dart
ThemeData(
  textTheme: TextTheme(
    // Display - 大型标题
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    
    // Headline - 标题
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    
    // Title - 小标题
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    
    // Body - 正文
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    
    // Label - 标签
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  ),
)
```

### 使用文字样式

```dart
Widget build(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  
  return Column(
    children: [
      Text('大标题', style: textTheme.headlineLarge),
      Text('小标题', style: textTheme.titleMedium),
      Text('正文内容', style: textTheme.bodyMedium),
      Text('标签', style: textTheme.labelSmall),
    ],
  );
}
```

### 自定义字体

```dart
// pubspec.yaml
// flutter:
//   fonts:
//     - family: CustomFont
//       fonts:
//         - asset: fonts/CustomFont-Regular.ttf
//         - asset: fonts/CustomFont-Bold.ttf
//           weight: 700

ThemeData(
  fontFamily: 'CustomFont',
  textTheme: TextTheme(
    bodyMedium: TextStyle(fontFamily: 'CustomFont'),
  ),
)
```

## 组件主题

### 按钮主题

```dart
ThemeData(
  // ElevatedButton 主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
    ),
  ),
  
  // TextButton 主题
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  ),
  
  // OutlinedButton 主题
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.blue,
      side: BorderSide(color: Colors.blue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  
  // FilledButton 主题 (Material 3)
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  ),
)
```

### 输入框主题

```dart
ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    // 边框
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.red),
    ),
    
    // 填充
    filled: true,
    fillColor: Colors.grey[100],
    
    // 内边距
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    
    // 标签和提示
    labelStyle: TextStyle(color: Colors.grey[700]),
    hintStyle: TextStyle(color: Colors.grey[400]),
    
    // 前缀后缀图标
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
  ),
)
```

### AppBar 主题

```dart
ThemeData(
  appBarTheme: AppBarTheme(
    // 颜色
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    
    // 阴影
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    
    // 居中标题
    centerTitle: true,
    
    // 标题样式
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    
    // 图标主题
    iconTheme: IconThemeData(color: Colors.black),
    actionsIconTheme: IconThemeData(color: Colors.black),
  ),
)
```

### Card 主题

```dart
ThemeData(
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.all(8),
  ),
)
```

### 更多组件主题

```dart
ThemeData(
  // 对话框
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    elevation: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  
  // BottomSheet
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  ),
  
  // SnackBar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey[900],
    contentTextStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
  ),
  
  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[200],
    selectedColor: Colors.blue[100],
    labelStyle: TextStyle(fontSize: 14),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  ),
  
  // Divider
  dividerTheme: DividerThemeData(
    color: Colors.grey[300],
    thickness: 1,
    space: 1,
  ),
  
  // ListTile
  listTileTheme: ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
    minLeadingWidth: 24,
    iconColor: Colors.grey[600],
  ),
)
```

## 深色主题

### 配置深色主题

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  themeMode: ThemeMode.system,  // 跟随系统
  home: HomePage(),
)
```

### 动态切换主题

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State&lt;MyApp&gt; {
  ThemeMode _themeMode = ThemeMode.system;
  
  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomePage(onThemeChanged: setThemeMode),
    );
  }
}

// 主题切换 UI
class ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged&lt;ThemeMode&gt; onChanged;
  
  const ThemeSelector({
    required this.currentMode,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return SegmentedButton&lt;ThemeMode&gt;(
      segments: [
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode),
          label: Text('浅色'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text('深色'),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.settings_brightness),
          label: Text('系统'),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (Set&lt;ThemeMode&gt; modes) {
        onChanged(modes.first);
      },
    );
  }
}
```

### 检测当前主题

```dart
Widget build(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;
  
  return Icon(
    isDark ? Icons.dark_mode : Icons.light_mode,
  );
}

// 或使用 MediaQuery
final platformBrightness = MediaQuery.of(context).platformBrightness;
```

## 主题扩展（ThemeExtension）

创建自定义主题属性：

```dart
// 定义扩展
class AppColors extends ThemeExtension&lt;AppColors&gt; {
  final Color success;
  final Color warning;
  final Color info;
  
  const AppColors({
    required this.success,
    required this.warning,
    required this.info,
  });
  
  @override
  AppColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }
  
  @override
  AppColors lerp(ThemeExtension&lt;AppColors&gt;? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

// 在 ThemeData 中使用
ThemeData(
  extensions: [
    AppColors(
      success: Colors.green,
      warning: Colors.orange,
      info: Colors.blue,
    ),
  ],
)

// 在组件中使用
Widget build(BuildContext context) {
  final appColors = Theme.of(context).extension&lt;AppColors&gt;()!;
  
  return Container(
    color: appColors.success,
    child: Text('成功'),
  );
}
```

## 完整主题配置示例

```dart
// lib/theme/app_theme.dart

class AppTheme {
  // 私有构造函数
  AppTheme._();
  
  // 品牌色
  static const Color _primaryColor = Color(0xFF6366F1);
  
  // 浅色主题
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      
      // 按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      
      // Card
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      
      // 扩展
      extensions: [
        AppColors(
          success: Color(0xFF22C55E),
          warning: Color(0xFFF59E0B),
          info: Color(0xFF3B82F6),
        ),
      ],
    );
  }
  
  // 深色主题
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      
      extensions: [
        AppColors(
          success: Color(0xFF4ADE80),
          warning: Color(0xFFFBBF24),
          info: Color(0xFF60A5FA),
        ),
      ],
    );
  }
}
```

## 样式工具类

```dart
// lib/theme/app_styles.dart

class AppStyles {
  AppStyles._();
  
  // 间距
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  
  // 圆角
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 999;
  
  // 阴影
  static List&lt;BoxShadow&gt; get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static List&lt;BoxShadow&gt; get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static List&lt;BoxShadow&gt; get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  // 动画时长
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}

// 使用
Container(
  padding: EdgeInsets.all(AppStyles.spacingMd),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppStyles.radiusLg),
    boxShadow: AppStyles.shadowMd,
  ),
  child: content,
)
```

## 最佳实践

### 1. 统一使用 ColorScheme

```dart
// ❌ 不推荐：硬编码颜色
Container(color: Colors.blue)

// ✅ 推荐：使用 ColorScheme
Container(color: Theme.of(context).colorScheme.primary)
```

### 2. 避免重复定义样式

```dart
// ❌ 每处都定义样式
Text('标题', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))

// ✅ 使用 TextTheme
Text('标题', style: Theme.of(context).textTheme.headlineMedium)
```

### 3. 组织主题文件

```
lib/
  theme/
    app_theme.dart      # 主题配置
    app_colors.dart     # 颜色扩展
    app_styles.dart     # 样式常量
    app_typography.dart # 字体配置
```

### 4. 响应主题变化

```dart
// 组件会自动响应主题变化
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  
  return Container(
    color: theme.colorScheme.surface,
    child: Text(
      'Hello',
      style: theme.textTheme.bodyLarge,
    ),
  );
}
```

## 下一步

掌握主题系统后，下一章我们将学习 [网络请求](./08-networking)，连接后端服务获取数据。
