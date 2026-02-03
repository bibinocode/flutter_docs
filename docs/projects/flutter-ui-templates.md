# Best-Flutter-UI-Templates - UI 模板集合

## 项目概览

| 项目信息 | 详情 |
|---------|------|
| **GitHub** | [mitesh77/Best-Flutter-UI-Templates](https://github.com/mitesh77/Best-Flutter-UI-Templates) |
| **Star** | 20k+ |
| **平台** | Android, iOS |
| **状态管理** | StatefulWidget (基础) |
| **主要功能** | 高质量 UI 模板集合 |

## 技术栈

### 核心技术
- **Flutter** + **Dart**
- **纯原生 Widget**: 无第三方 UI 库
- **自定义动画**: AnimationController
- **主题系统**: 自定义 Theme

### 项目特点
- 不依赖第三方 UI 库
- 精美的动画效果
- 良好的代码组织
- 适合 UI 学习

## 项目结构

```
lib/
├── main.dart                   # 入口文件
├── app_theme.dart              # 全局主题
├── fitness_app/                # 健身应用模板
│   ├── fitness_app_theme.dart  # 专属主题
│   ├── fitness_app_home_screen.dart
│   ├── models/                 # 数据模型
│   │   ├── tabIcon_data.dart
│   │   └── meals_list_data.dart
│   ├── components/             # 组件
│   │   ├── title_view.dart
│   │   ├── area_list_view.dart
│   │   ├── running_view.dart
│   │   ├── water_view.dart
│   │   └── workout_view.dart
│   ├── bottom_navigation_view/ # 底部导航
│   │   └── bottom_bar_view.dart
│   ├── my_diary/               # 日记模块
│   │   ├── my_diary_screen.dart
│   │   └── meals_list_view.dart
│   └── training/               # 训练模块
│       └── training_screen.dart
├── hotel_booking/              # 酒店预订模板
│   ├── hotel_app_theme.dart
│   ├── hotel_home_screen.dart
│   ├── model/
│   │   └── hotel_list_data.dart
│   └── components/
│       ├── calendar_popup_view.dart
│       └── hotel_list_view.dart
├── design_course/              # 设计课程模板
│   ├── design_course_app_theme.dart
│   ├── home_design_course.dart
│   ├── models/
│   │   └── category.dart
│   └── components/
│       ├── category_list_view.dart
│       └── popular_course_list_view.dart
└── introduction_animation/     # 引导页动画
    ├── introduction_animation_screen.dart
    └── components/
        ├── splash_view.dart
        ├── relax_view.dart
        ├── care_view.dart
        ├── mood_diary_view.dart
        └── welcome_view.dart
```

## 学习要点

### 1. 自定义主题系统

每个模板都有独立的主题配置：

```dart
class FitnessAppTheme {
  FitnessAppTheme._();
  
  // 颜色定义
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color grey = Color(0xFF3A5160);
  static const Color darkGrey = Color(0xFF313A44);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  
  // 渐变色
  static const Color nearlyDarkBlue = Color(0xFF2633C5);
  
  // 背景色
  static const Color background = Color(0xFFF2F3F8);
  
  // 文字样式
  static const TextTheme textTheme = TextTheme(
    headlineMedium: display1,
    headlineSmall: headline,
    titleLarge: title,
    titleSmall: subtitle,
    bodyMedium: body2,
    bodyLarge: body1,
    bodySmall: caption,
  );
  
  static const TextStyle display1 = TextStyle(
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );
  
  // ... 更多文字样式
}
```

### 2. 自定义动画

引导页展示了丰富的动画效果：

```dart
class IntroductionAnimationScreen extends StatefulWidget {
  @override
  _IntroductionAnimationScreenState createState() =>
      _IntroductionAnimationScreenState();
}

class _IntroductionAnimationScreenState 
    extends State<IntroductionAnimationScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    // 创建动画序列
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              // 根据动画值显示不同页面
              if (_animation.value <= 0.2)
                SplashView(animationController: _animationController),
              if (_animation.value > 0.2 && _animation.value <= 0.4)
                RelaxView(animationController: _animationController),
              if (_animation.value > 0.4 && _animation.value <= 0.6)
                CareView(animationController: _animationController),
              // ... 更多页面
            ],
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

### 3. 自定义 Wave 动画

水波纹动画效果：

```dart
class WaterView extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  const WaterView({
    this.mainScreenAnimationController, 
    this.mainScreenAnimation
  });

  @override
  _WaterViewState createState() => _WaterViewState();
}

class _WaterViewState extends State<WaterView> 
    with TickerProviderStateMixin {
  
  late AnimationController waveAnimationController;
  
  @override
  void initState() {
    super.initState();
    waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    waveAnimationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            waveAnimation: waveAnimationController,
            percentValue: 0.65,
            waveColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.2),
          ),
          child: child,
        );
      },
      child: _buildContent(),
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> waveAnimation;
  final double percentValue;
  final Color waveColor;
  
  WavePainter({
    required this.waveAnimation,
    required this.percentValue,
    required this.waveColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final waveHeight = 4.0;
    final baseHeight = size.height * (1 - percentValue);
    
    path.moveTo(0, baseHeight);
    
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        baseHeight + sin((i / size.width * 2 * pi) + 
            (waveAnimation.value * 2 * pi)) * waveHeight,
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return waveAnimation != oldDelegate.waveAnimation;
  }
}
```

### 4. 自定义底部导航栏

```dart
class BottomBarView extends StatefulWidget {
  final Function(int index)? changeIndex;
  final int? initialIndex;
  final List<TabIconData> tabIconsList;

  const BottomBarView({
    this.changeIndex,
    this.initialIndex,
    required this.tabIconsList,
  });

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> 
    with TickerProviderStateMixin {
  
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        // 底部背景
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.translationValues(
                0.0, 
                100 * (1.0 - animationController.value), 
                0.0
              ),
              child: PhysicalShape(
                color: FitnessAppTheme.white,
                elevation: 16.0,
                clipper: TabClipper(
                  radius: 38.0,
                ),
                child: _buildTabRow(),
              ),
            );
          },
        ),
        // 中间按钮
        _buildCenterButton(),
      ],
    );
  }
  
  Widget _buildCenterButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: 38 * 2.0,
        height: 38 + 62.0,
        child: Container(
          alignment: Alignment.topCenter,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: FitnessAppTheme.nearlyDarkBlue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 5. 卡片动画效果

```dart
class MealsListView extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  const MealsListView({
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  });

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView> 
    with TickerProviderStateMixin {
  
  late AnimationController animationController;
  List<MealsListData> mealsListData = MealsListData.tabIconsList;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (context, child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0, 
              30 * (1.0 - widget.mainScreenAnimation!.value), 
              0.0
            ),
            child: _buildList(),
          ),
        );
      },
    );
  }

  Widget _buildList() {
    return SizedBox(
      height: 216,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mealsListData.length,
        itemBuilder: (context, index) {
          final count = mealsListData.length;
          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Interval(
                (1 / count) * index, 
                1.0,
                curve: Curves.fastOutSlowIn,
              ),
            ),
          );
          animationController.forward();
          
          return MealView(
            mealsListData: mealsListData[index],
            animation: animation,
            animationController: animationController,
          );
        },
      ),
    );
  }
}
```

### 6. 日历选择器

```dart
class CalendarPopupView extends StatefulWidget {
  final DateTime minimumDate;
  final DateTime maximumDate;
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onApplyClick;
  final Function onCancelClick;

  const CalendarPopupView({
    required this.minimumDate,
    required this.maximumDate,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onApplyClick,
    required this.onCancelClick,
  });

  @override
  _CalendarPopupViewState createState() => _CalendarPopupViewState();
}

class _CalendarPopupViewState extends State<CalendarPopupView> 
    with TickerProviderStateMixin {
  
  late AnimationController animationController;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: animationController.value,
          duration: const Duration(milliseconds: 100),
          child: _buildContent(),
        );
      },
    );
  }
}
```

## 架构亮点

1. **模块化组织**: 每个模板独立，易于学习
2. **无依赖**: 纯 Flutter 实现，无第三方 UI 库
3. **动画丰富**: 各种自定义动画效果
4. **主题一致**: 每个模板有独立完整的主题
5. **代码清晰**: 良好的命名和结构

## 适合学习

- Flutter 基础 Widget 组合
- 自定义动画实现
- 主题系统设计
- CustomPainter 绘制
- 复杂 UI 布局技巧

## 运行项目

```bash
# 克隆项目
git clone https://github.com/mitesh77/Best-Flutter-UI-Templates.git
cd Best-Flutter-UI-Templates/best_flutter_ui_templates

# 安装依赖
flutter pub get

# 运行
flutter run
```

::: tip 学习建议
1. 从 fitness_app 开始学习整体结构
2. 研究 introduction_animation 学习复杂动画
3. 学习 CustomPainter 的使用技巧
4. 参考主题系统设计自己的主题
:::
