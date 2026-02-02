# Flutter 从零到一 - 项目概览

这是一个面向前端开发者的 Flutter 系统学习项目，包含文档站点和示例 App。

## 项目结构

```
flutter_tutorial/
├── docs/                         # VitePress 文档站点
│   ├── .vitepress/
│   │   ├── config.ts            # 站点配置
│   │   ├── theme/               # 自定义主题
│   │   └── components/          # Vue 组件
│   ├── dart/                    # Dart 教程
│   ├── flutter/                 # Flutter 教程
│   ├── widgets/                 # Widget 大全
│   └── index.md                 # 首页
│
├── flutter_demo/                 # Flutter 示例 App
│   ├── lib/
│   │   ├── app/
│   │   │   ├── router/          # 路由配置
│   │   │   └── theme/           # 主题配置
│   │   ├── features/            # 功能模块
│   │   │   ├── 01_basics/       # 基础组件
│   │   │   ├── 02_layout/       # 布局组件
│   │   │   ├── 03_scrolling/    # 滚动组件
│   │   │   ├── 04_forms/        # 表单输入
│   │   │   ├── 05_navigation/   # 导航路由
│   │   │   ├── 06_state_riverpod/  # Riverpod
│   │   │   ├── 07_state_getx/   # GetX
│   │   │   ├── 08_network/      # 网络请求
│   │   │   ├── 09_storage/      # 数据存储
│   │   │   ├── 10_animation/    # 动画效果
│   │   │   ├── 11_gesture/      # 手势交互
│   │   │   ├── 12_permission/   # 权限管理
│   │   │   ├── 13_platform/     # 平台适配
│   │   │   ├── 14_testing/      # 测试
│   │   │   └── 15_advanced/     # 高级主题
│   │   └── shared/              # 共享组件
│   └── pubspec.yaml             # 依赖配置
│
└── scripts/                      # 工具脚本
    └── widget_crawler/          # Widget 爬虫
```

## 快速开始

### 运行文档站点

```bash
cd docs
npm install
npm run docs:dev
```

访问 http://localhost:5173

### 运行 Flutter Demo

```bash
cd flutter_demo
flutter pub get
flutter run
```

### 使用 Widget 爬虫

```bash
cd scripts/widget_crawler
pip install -r requirements.txt
python crawler.py
```

## 技术栈

### 文档站点
- VitePress - 静态站点生成器
- Vue 3 - 组件开发
- TypeScript - 类型安全

### Flutter Demo
- Flutter 3.x - UI 框架
- Material 3 - 设计语言
- go_router - 声明式路由
- Riverpod - 状态管理
- GetX - 状态管理（对比）
- Dio - 网络请求
- Hive - 本地存储

## 功能模块

| 模块 | 说明 | 状态 |
|------|------|------|
| 基础组件 | Text, Image, Button, Icon | ✅ 完成 |
| 布局组件 | Row, Column, Stack, Flex | ✅ 完成 |
| 滚动组件 | ListView, GridView | 📝 占位 |
| 表单输入 | TextField, Form | 📝 占位 |
| 导航路由 | Navigator, go_router | 📝 占位 |
| Riverpod | 状态管理演示 | ✅ 完成 |
| GetX | 状态管理演示 | ✅ 完成 |
| 网络请求 | Dio, REST API | ✅ 完成 |
| 数据存储 | SharedPreferences, Hive | ✅ 完成 |
| 动画效果 | 隐式/显式动画 | ✅ 完成 |
| 手势交互 | GestureDetector | ✅ 完成 |
| 权限管理 | permission_handler | ✅ 完成 |
| 平台适配 | 多平台支持 | ✅ 完成 |
| 测试 | 单元/Widget/集成测试 | ✅ 完成 |
| 高级主题 | CustomPaint, Isolate | ✅ 完成 |

## 部署

### 文档站点部署 (Vercel)

```bash
# 构建
npm run docs:build

# 输出目录: docs/.vitepress/dist
```

### Flutter Web 部署

```bash
# 构建
flutter build web

# 输出目录: build/web
```

## 配置

### Deepseek 翻译 API

```python
# scripts/widget_crawler/crawler.py
# 从环境变量读取
DEEPSEEK_API_URL = os.getenv("DEEPSEEK_API_URL")
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")
```

### 域名配置

- 文档站点: flutter.kmod.cn
- 示例 App: demo.flutter.kmod.cn

## 下一步

1. 完善各模块的具体示例代码
2. 运行 Widget 爬虫生成 Widget 文档
3. 编写 Dart/Flutter 教程内容
4. 部署到线上环境

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可

MIT License
