# Flutter 版本管理

在 Flutter 开发中，版本管理是确保项目兼容性和功能稳定性的关键操作。不同项目可能需要不同的 Flutter 版本，团队协作时也需要统一版本环境。

本文将详细介绍两种版本管理方案：
1. **FVM（推荐）** - 专业的 Flutter 版本管理工具
2. **原生命令** - 使用 Flutter 自带命令和 Git 切换版本

## 为什么需要版本管理？

```
场景1：老项目使用 Flutter 3.10，新项目需要 Flutter 3.19 的新特性
场景2：团队成员 Flutter 版本不一致，导致构建结果不同
场景3：需要测试应用在不同 Flutter 版本下的兼容性
场景4：升级 Flutter 后项目出问题，需要快速回退
```

## 方案一：FVM（推荐）

FVM（Flutter Version Manager）是专门为 Flutter 设计的版本管理工具，支持多版本共存和快速切换，避免污染全局环境。

### 安装 FVM

根据操作系统选择安装方式：

::: code-group

```bash [macOS (Homebrew)]
# 添加 FVM tap
brew tap leoafarias/fvm

# 安装 FVM
brew install fvm
```

```bash [Windows (Chocolatey)]
choco install fvm
```

```bash [Windows (Scoop)]
scoop install fvm
```

```bash [Linux / 其他]
# 使用 Dart pub 全局安装
dart pub global activate fvm

# 确保 ~/.pub-cache/bin 在 PATH 中
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

:::

### 验证安装

```bash
fvm --version
# 输出示例：3.0.16
```

### 查看可用版本

```bash
# 查看远程可用的 Flutter 版本
fvm releases

# 查看已安装的版本
fvm list

# 查看当前使用的版本
fvm current
```

### 安装指定版本

```bash
# 安装稳定版的特定版本
fvm install 3.19.0

# 安装最新稳定版
fvm install stable

# 安装 beta 版本
fvm install beta

# 安装 dev 版本
fvm install dev

# 安装 master 分支
fvm install master
```

### 项目级版本管理

为当前项目设置 Flutter 版本（推荐做法）：

```bash
# 进入项目目录
cd my_flutter_project

# 设置项目使用的 Flutter 版本
fvm use 3.19.0

# 如果版本未安装，添加 --force 自动安装
fvm use 3.19.0 --force
```

执行后，FVM 会在项目目录下：
1. 创建 `.fvm` 文件夹，包含指向 SDK 的符号链接
2. 创建 `.fvmrc` 文件，记录版本信息

```
my_flutter_project/
├── .fvm/
│   ├── flutter_sdk -> /Users/xxx/fvm/versions/3.19.0
│   └── fvm_config.json
├── .fvmrc
├── lib/
└── pubspec.yaml
```

::: tip 版本控制
建议将 `.fvmrc` 文件提交到 Git，但将 `.fvm/` 添加到 `.gitignore`：

```gitignore
# .gitignore
.fvm/flutter_sdk
```

这样团队成员 clone 项目后，只需运行 `fvm install` 即可自动安装正确版本。
:::

### 全局版本设置

设置系统默认使用的 Flutter 版本：

```bash
# 设置全局默认版本
fvm global 3.19.0

# 取消全局设置
fvm global --unlink
```

### 在项目中使用 FVM

使用 FVM 管理的项目，有两种方式运行 Flutter 命令：

**方式一：使用 fvm flutter 前缀**

```bash
# 运行项目
fvm flutter run

# 获取依赖
fvm flutter pub get

# 构建 APK
fvm flutter build apk

# 运行测试
fvm flutter test
```

**方式二：配置 IDE 使用项目 SDK 路径**

配置后可以直接使用 `flutter` 命令。

### IDE 配置

#### VS Code

在项目根目录创建 `.vscode/settings.json`：

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  // 如果需要在搜索结果中排除 .fvm 目录
  "search.exclude": {
    "**/.fvm": true
  },
  // 文件监视排除
  "files.watcherExclude": {
    "**/.fvm": true
  }
}
```

#### Android Studio / IntelliJ IDEA

1. 打开 **Preferences** (macOS) 或 **Settings** (Windows/Linux)
2. 导航到 **Languages & Frameworks > Flutter**
3. 将 **Flutter SDK path** 设置为项目中的 `.fvm/flutter_sdk` 绝对路径
4. 点击 **Apply** 并重启 IDE

### 常用命令速查

```bash
# 版本管理
fvm releases              # 查看远程可用版本
fvm list                  # 查看本地已安装版本
fvm install <version>     # 安装指定版本
fvm remove <version>      # 删除指定版本

# 版本切换
fvm use <version>         # 项目级版本设置
fvm global <version>      # 全局版本设置
fvm current               # 查看当前使用版本

# 项目命令
fvm flutter <command>     # 使用项目版本执行 flutter 命令
fvm dart <command>        # 使用项目版本执行 dart 命令

# 其他
fvm doctor                # 检查 FVM 配置
fvm flavor                # 管理项目 flavor（高级功能）
```

### FVM 配置文件

FVM 支持通过配置文件自定义行为，在用户目录创建 `.fvmrc`：

```json
{
  "flutter": "3.19.0",
  "flavors": {
    "development": "beta",
    "production": "stable"
  }
}
```

---

## 方案二：原生命令

若不想安装额外工具，可通过 Flutter 自带的 `channel` 命令和 Git 手动切换版本。

### Flutter 通道（Channel）

Flutter 有四个发布通道：

| 通道 | 说明 | 更新频率 | 稳定性 |
|------|------|----------|--------|
| stable | 稳定版 | 每季度 | ⭐⭐⭐⭐⭐ |
| beta | 测试版 | 每月 | ⭐⭐⭐⭐ |
| dev | 开发版 | 每周 | ⭐⭐⭐ |
| master | 最新代码 | 每天 | ⭐⭐ |

### 通道操作

```bash
# 查看当前通道
flutter channel

# 切换到稳定版通道
flutter channel stable

# 切换到 beta 通道
flutter channel beta

# 升级到当前通道的最新版本
flutter upgrade
```

### 切换到指定版本

如需切换到特定版本号（如 3.16.9），需要使用 Git：

```bash
# 1. 进入 Flutter SDK 目录
cd $(dirname $(which flutter))/../..
# 或者直接进入你的 Flutter 安装目录
# cd ~/development/flutter

# 2. 获取所有版本标签
git fetch --tags

# 3. 查看可用版本
git tag | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | tail -20

# 4. 切换到指定版本
git checkout 3.19.0

# 5. 重新初始化 Flutter
flutter doctor
```

### 回退到上一个版本

```bash
# 进入 Flutter SDK 目录
cd $(dirname $(which flutter))/../..

# 查看最近的版本切换历史
git reflog | head -10

# 回退到上一个状态
git checkout -

# 或者指定某个版本
git checkout 3.16.9

# 重新运行 doctor
flutter doctor
```

### 降级 Flutter

```bash
# 如果只是想降级一个小版本
flutter downgrade

# 如果需要降级到特定版本，使用 git checkout
git checkout <version>
flutter doctor
```

::: warning 注意事项
使用原生命令切换版本会直接修改全局 Flutter SDK，可能影响其他项目。建议：
1. 切换前记录当前版本：`flutter --version`
2. 切换后运行 `flutter doctor` 确保环境正常
3. 运行 `flutter pub get` 更新项目依赖
:::

---

## 版本查询

### 查看当前版本

```bash
flutter --version

# 输出示例：
# Flutter 3.19.0 • channel stable • https://github.com/flutter/flutter.git
# Framework • revision a363e89 (3 weeks ago) • 2024-01-11 16:00:00 -0800
# Engine • revision 4cd837fc
# Tools • Dart 3.3.0 • DevTools 2.28.0
```

### 查看可用版本

**方式一：FVM（推荐）**
```bash
fvm releases
```

**方式二：Flutter GitHub Releases**

访问 [Flutter GitHub Releases](https://github.com/flutter/flutter/releases) 查看所有发布版本。

**方式三：Git 标签**
```bash
cd $(dirname $(which flutter))/../..
git tag | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -30
```

### 常用版本参考

| 版本 | 发布日期 | Dart 版本 | 重要特性 |
|------|----------|-----------|----------|
| 3.19.0 | 2024-02 | 3.3.0 | Impeller iOS 默认、Widget 预览 |
| 3.16.0 | 2023-11 | 3.2.0 | Material 3 默认、Impeller 改进 |
| 3.13.0 | 2023-08 | 3.1.0 | 2D 滚动、更快编译 |
| 3.10.0 | 2023-05 | 3.0.0 | Dart 3、Records、Patterns |
| 3.7.0 | 2023-01 | 2.19.0 | iOS 改进、Material 3 组件 |

---

## 升级后的注意事项

### 1. 更新项目依赖

```bash
# 更新 pubspec.lock
flutter pub get

# 升级依赖包到最新兼容版本
flutter pub upgrade

# 查看可升级的包
flutter pub outdated
```

### 2. 检查依赖兼容性

升级 Flutter 后，部分第三方包可能不兼容。检查 `pubspec.yaml` 中的版本约束：

```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  # 确保依赖包支持新版本
  provider: ^6.1.0
```

### 3. 运行测试

```bash
# 运行单元测试
flutter test

# 检查代码问题
flutter analyze
```

### 4. 清理构建缓存

如果遇到奇怪的构建问题：

```bash
# 清理 Flutter 构建缓存
flutter clean

# 删除 pub 缓存（可选）
flutter pub cache clean

# 重新获取依赖
flutter pub get
```

---

## 团队协作最佳实践

### 1. 使用 FVM 统一版本

```bash
# 项目负责人设置版本
fvm use 3.19.0

# 提交 .fvmrc 到仓库
git add .fvmrc
git commit -m "chore: set flutter version to 3.19.0"
```

### 2. 在 README 中说明

```markdown
## 环境要求

- Flutter 3.19.0（推荐使用 FVM 管理）

### 使用 FVM 设置环境

\```bash
# 安装 FVM（如未安装）
brew install fvm

# 安装项目指定的 Flutter 版本
fvm install

# 获取依赖
fvm flutter pub get
\```
```

### 3. CI/CD 配置

在 GitHub Actions 中使用 FVM：

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install FVM
        run: |
          dart pub global activate fvm
          echo "$HOME/.pub-cache/bin" >> $GITHUB_PATH
      
      - name: Install Flutter
        run: fvm install
      
      - name: Get dependencies
        run: fvm flutter pub get
      
      - name: Run tests
        run: fvm flutter test
      
      - name: Build APK
        run: fvm flutter build apk
```

---

## 方案对比

| 特性 | FVM | 原生命令 |
|------|-----|----------|
| 多版本共存 | ✅ 支持 | ❌ 不支持 |
| 项目级版本 | ✅ 支持 | ❌ 不支持 |
| 版本切换速度 | ⚡ 秒级 | 🐢 分钟级 |
| 环境隔离 | ✅ 完全隔离 | ❌ 会污染全局 |
| 团队协作 | ✅ 友好 | ⚠️ 需手动同步 |
| 学习成本 | 低 | 中 |
| 额外依赖 | 需安装 FVM | 无 |
| 推荐场景 | 多项目开发、团队协作 | 单项目、临时切换 |

## 推荐方案

- **日常开发**：使用 FVM，简单高效，项目隔离
- **CI/CD**：使用 FVM 或指定版本的 Flutter Action
- **临时测试**：原生命令即可
- **团队项目**：强烈推荐 FVM + `.fvmrc` 版本锁定

## 常见问题

### Q1: FVM 安装后命令找不到？

确保 FVM 的 bin 目录在 PATH 中：

```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
export PATH="$PATH":"$HOME/.pub-cache/bin"

# 重新加载配置
source ~/.zshrc
```

### Q2: fvm use 后 flutter 命令还是旧版本？

这是正常的。FVM 的项目级版本需要通过以下方式使用：
1. 使用 `fvm flutter` 代替 `flutter`
2. 或配置 IDE 使用 `.fvm/flutter_sdk` 路径

### Q3: 切换版本后构建失败？

```bash
# 清理并重新构建
flutter clean
flutter pub get
flutter build apk
```

### Q4: 如何删除不用的 Flutter 版本？

```bash
# FVM 方式
fvm remove 3.10.0

# 查看 FVM 缓存位置
fvm doctor
# 手动删除：~/fvm/versions/<version>
```

## 相关资源

- [FVM 官方文档](https://fvm.app/)
- [FVM GitHub](https://github.com/leoafarias/fvm)
- [Flutter 版本发布](https://docs.flutter.dev/release/archive)
- [Flutter GitHub Releases](https://github.com/flutter/flutter/releases)
