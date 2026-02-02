# 功能模块

本篇章介绍 Flutter 应用开发中常用的功能模块实现，包括屏幕适配、网络请求、数据存储、权限管理等实用功能。

## 📚 章节目录

### 🖥️ 界面适配

- [屏幕适配](./adaptation.md) - flutter_screenutil 与 MediaQuery 适配方案

### 🌐 网络与数据

- 网络请求 - Dio 封装与拦截器（即将推出）
- 数据持久化 - SharedPreferences 与 Hive（即将推出）
- 数据库操作 - SQLite 与 Drift（即将推出）

### 🔐 安全与权限

- 权限管理 - permission_handler 使用（即将推出）
- 生物识别 - 指纹与面容识别（即将推出）

### 📱 设备功能

- 相机与相册 - image_picker 使用（即将推出）
- 文件选择 - file_picker 使用（即将推出）
- 地理位置 - geolocator 使用（即将推出）

### 🔔 消息推送

- 本地通知 - flutter_local_notifications（即将推出）
- 远程推送 - Firebase Cloud Messaging（即将推出）

### 🎨 UI 增强

- 图片加载 - cached_network_image（即将推出）
- 下拉刷新 - pull_to_refresh（即将推出）
- 骨架屏 - shimmer 加载效果（即将推出）

### 🛠️ 工具集成

- 日志管理 - logger 使用（即将推出）
- 崩溃收集 - Sentry 集成（即将推出）
- 应用更新 - 版本检查与升级（即将推出）

## 学习建议

1. **按需学习**：根据项目需求选择相关模块
2. **动手实践**：每个模块都有完整示例，建议边学边练
3. **深入源码**：了解第三方库的实现原理
4. **关注更新**：定期检查依赖包的版本更新

## 开发环境

本篇章示例基于以下环境：

```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"
```

建议使用最新稳定版 Flutter SDK 进行开发。
