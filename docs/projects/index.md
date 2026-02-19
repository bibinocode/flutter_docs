# 项目学习推荐

精选优质 Flutter 开源项目，深度分析项目架构、技术栈和值得学习的设计模式。

## 🎯 收录标准

- ⭐ Stars 数量 > 500
- 📅 近期有维护更新
- 📖 代码结构清晰，有学习价值
- 🛠️ 使用主流技术栈

## 📚 项目分类

### 完整应用

| 项目 | 简介 | 技术栈 | 难度 |
|------|------|--------|------|
| [LocalSend](./localsend) | 跨平台局域网文件传输 | Refena + Rust FFI | ⭐⭐⭐⭐ |
| [FlClash](./flclash) | 跨平台代理客户端 | Riverpod + Go Core | ⭐⭐⭐⭐⭐ |
| [AppFlowy](./appflowy) | 开源 Notion 替代品 | BLoC + Rust Backend | ⭐⭐⭐⭐⭐ |
| [PiliPala](./pilipala) | B站第三方客户端 | GetX + Hive | ⭐⭐⭐ |
| [Flutter Novel](./flutter-novel) | 小说阅读器 | Riverpod + auto_route | ⭐⭐⭐ |
| [MetaMask Mobile](./metamask-mobile) | 加密钱包深度解析 | React Native + TypeScript | ⭐⭐⭐⭐⭐ |

### UI 模板与组件

| 项目 | 简介 | 技术栈 | 难度 |
|------|------|--------|------|
| [Flutter UI Templates](./flutter-ui-templates) | 高质量 UI 模板集合 | 纯 Flutter Widget | ⭐⭐ |
| [FlutterCandies](./fluttercandies) | 糖果社区 88+ 实用包 | 多种技术 | ⭐⭐⭐ |

### FlutterCandies 精选插件

| 项目 | 简介 | 技术栈 | 难度 |
|------|------|--------|------|
| [Photo Manager](./photo-manager) | 跨平台媒体资源管理 | Platform Channel | ⭐⭐⭐ |
| [WeChat Camera Picker](./wechat-camera-picker) | 微信风格相机选择器 | camera + photo_manager | ⭐⭐⭐ |
| [WeChat Flutter](./wechat-flutter) | 仿微信 IM 应用 | Provider + GetX + 腾讯云 IM | ⭐⭐⭐⭐ |

## 📊 技术栈对比

| 项目 | 状态管理 | 后端/核心 | 存储 | 平台 |
|------|----------|-----------|------|------|
| LocalSend | Refena | Rust FFI | SharedPrefs | 全平台 |
| FlClash | Riverpod | Go (Clash) | SharedPrefs | Android/Desktop |
| AppFlowy | BLoC | Rust | SQLite | 全平台 |
| PiliPala | GetX | - | Hive | Android |
| Flutter Novel | Riverpod | - | SharedPrefs | 全平台 |
| UI Templates | setState | - | - | 全平台 |
| Photo Manager | - | Platform Channel | - | 全平台 |
| WeChat Camera | - | camera 插件 | photo_manager | 全平台 |
| WeChat Flutter | Provider + GetX | 腾讯云 IM | SharedPrefs | Android/iOS |

## 🏆 推荐学习路径

### 初学者 (1-3个月)
1. **Flutter UI Templates** - 学习基础 Widget 组合和动画
2. **FlutterCandies** - 了解优质开源包的使用

### 进阶者 (3-6个月)
1. **PiliPala** - GetX 全家桶实战
2. **LocalSend** - 跨平台应用开发

### 高级开发者 (6个月+)
1. **FlClash** - Riverpod + Go 混合开发
2. **AppFlowy** - 大型项目架构设计

## 📖 项目分析模板

每个项目分析包含：

1. **项目概述** - 功能介绍、基本信息
2. **技术栈分析** - 使用的框架、库、架构模式
3. **目录结构** - 项目组织方式
4. **学习要点** - 核心代码解析
5. **架构亮点** - 值得学习的设计
6. **运行指南** - 如何本地运行项目

## 💡 如何使用

1. 根据自己的水平选择合适的项目
2. 阅读项目分析文档，了解整体架构
3. Clone 项目到本地运行
4. 结合分析文档阅读源码
5. 尝试修改代码，理解实现原理
6. 提取可复用的模式，应用到自己的项目

## 🔗 更多资源

- [Flutter Awesome](https://flutterawesome.com/) - Flutter 项目聚合
- [It's All Widgets](https://itsallwidgets.com/) - Flutter 应用展示
- [pub.dev](https://pub.dev/) - Dart/Flutter 包仓库
- [Flutter Gallery](https://gallery.flutter.dev/) - 官方示例

::: tip 贡献指南
如果你发现了优秀的 Flutter 开源项目，欢迎提交 PR 添加到推荐列表！
:::
