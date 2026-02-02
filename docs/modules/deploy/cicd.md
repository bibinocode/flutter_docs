# CI/CD 自动化部署

持续集成与持续部署（CI/CD）可以让每次代码提交自动完成测试、构建和发布。本章以 Bitbucket Pipelines 和 Fastlane 为例，介绍如何为 Flutter 应用搭建完整的自动化发布流水线。

## 概述

```
┌─────────────────────────────────────────────────────────────────┐
│                  CI/CD 自动化流程                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   开发者           CI 服务器           应用商店                  │
│   ──────           ─────────           ────────                  │
│                                                                 │
│   ┌────────┐      ┌──────────────┐    ┌──────────┐             │
│   │ 代码   │─────▶│ 1. 代码检查  │    │ Google   │             │
│   │ 提交   │      │ 2. 运行测试  │───▶│ Play     │             │
│   └────────┘      │ 3. 构建签名  │    │ Store    │             │
│                   │ 4. 自动发布  │    └──────────┘             │
│                   └──────────────┘                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 为什么需要 CI/CD？

| 手动发布 | 自动化发布 |
|----------|------------|
| 繁琐易出错 | 一致可靠 |
| 找签名密钥 | 安全存储密钥 |
| 手动上传包 | 自动部署 |
| 耗时 | 省时 |

## 准备工作

### 所需条件

- ✅ Flutter 项目已托管在 Bitbucket
- ✅ Android 签名密钥（`.jks` 文件）
- ✅ Bitbucket 仓库管理权限
- ✅ Google Play Console 账号（发布到 Play Store）

## 第一部分：基础构建流水线

### 步骤 1：启用 Bitbucket Pipelines

1. 打开 Bitbucket 仓库
2. 进入 **仓库设置 → Pipelines → 设置**
3. 开启 Pipelines

### 步骤 2：创建配置文件

在项目根目录创建 `bitbucket-pipelines.yml`：

```yaml
# bitbucket-pipelines.yml

# 使用 Flutter Docker 镜像
image: ghcr.io/cirruslabs/flutter:3.32.7

# 定义缓存
definitions:
  caches:
    flutter: /flutter
    pub: $HOME/.pub-cache

# 浅克隆加速
clone:
  depth: 1

# 流水线定义
pipelines:
  # 默认：每次推送都执行
  default:
    - step:
        name: 分析与测试
        caches:
          - pub
        script:
          # 获取依赖
          - flutter pub get
          # 代码分析
          - flutter analyze
          # 运行测试
          - flutter test
```

### 步骤 3：提交并验证

```bash
git add bitbucket-pipelines.yml
git commit -m "添加 CI/CD 配置"
git push
```

推送后，在 Bitbucket 的 **Pipelines** 页面可以看到流水线运行。

## 第二部分：签名与构建

### 步骤 4：安全存储签名密钥

**绝不要**将签名密钥直接提交到仓库！使用 Bitbucket 的**仓库变量**安全存储。

#### 编码 Keystore 文件

```bash
# macOS/Linux
base64 -i my-upload-key.jks -o key.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("my-upload-key.jks")) | Out-File -FilePath "key.txt"
```

#### 编码 key.properties 文件

```bash
# macOS/Linux
base64 -i key.properties -o properties.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("key.properties")) | Out-File -FilePath "properties.txt"
```

#### 添加仓库变量

进入 **仓库设置 → Pipelines → 仓库变量**，添加：

| 变量名 | 值 | 保护 |
|--------|-----|------|
| `ANDROID_KEYSTORE_BASE64` | key.txt 内容 | ✅ |
| `ANDROID_KEYPROPERTIES_BASE64` | properties.txt 内容 | ✅ |

### 步骤 5：添加构建流水线

```yaml
# bitbucket-pipelines.yml

image: ghcr.io/cirruslabs/flutter:3.32.7

definitions:
  caches:
    flutter: /flutter
    pub: $HOME/.pub-cache

clone:
  depth: 1

pipelines:
  # 默认：分析和测试
  default:
    - step:
        name: 分析与测试
        caches:
          - pub
        script:
          - flutter pub get
          - flutter analyze
          - flutter test

  # 分支特定：development 分支构建签名包
  branches:
    development:
      - step:
          name: 构建签名包
          size: 2x  # 使用更大的构建容器
          caches:
            - pub
          script:
            # 清理并获取依赖
            - rm -f pubspec.lock
            - flutter pub get
            - flutter analyze
            - flutter test
            
            # 解码签名密钥
            - echo $ANDROID_KEYSTORE_BASE64 | base64 -d > android/app/keystore.jks
            
            # 解码 key.properties
            - echo $ANDROID_KEYPROPERTIES_BASE64 | base64 -d > android/key.properties
            
            # 构建签名的 AAB
            - flutter build appbundle --obfuscate --split-debug-info=./debug_info --release
            
          artifacts:
            # 保存构建产物
            - build/app/outputs/bundle/release/app-release.aab
```

### 配置说明

| 配置项 | 说明 |
|--------|------|
| `size: 2x` | 分配双倍内存，加快构建速度 |
| `base64 -d` | 将 Base64 字符串解码为文件 |
| `--obfuscate` | 代码混淆 |
| `--split-debug-info` | 分离调试符号 |
| `artifacts` | 保存产物供下载 |

## 第三部分：自动发布到 Play Store

使用 Fastlane 实现自动化发布。

### 步骤 1：获取 Google Play API 凭证

#### 创建服务账号

1. 进入 [Google Cloud Console](https://console.cloud.google.com/)
2. **IAM 与管理 → 服务账号 → 创建服务账号**
3. 命名（如 `bitbucket-ci-cd-deploys`）
4. 添加角色：**服务账号用户**

#### 创建 JSON 密钥

1. 找到刚创建的服务账号
2. 点击 **管理密钥 → 添加密钥 → 创建新密钥**
3. 选择 **JSON** 格式
4. 下载并安全保存

#### 在 Play Console 授权

1. 进入 [Google Play Console](https://play.google.com/console/)
2. **用户与权限 → 邀请新用户**
3. 输入服务账号邮箱
4. 授予 **发布经理** 权限

### 步骤 2：配置 Fastlane

#### 安装 Fastlane

```bash
# 使用 Bundler（推荐）
cd android
bundle init
echo "gem 'fastlane'" >> Gemfile
bundle install

# 初始化
bundle exec fastlane init
```

#### 配置 Appfile

```ruby
# android/fastlane/Appfile
json_key_file("./your-service-account-key.json")
package_name("com.your.app.package")
```

#### 安装 flutter_version 插件

```bash
cd android
bundle exec fastlane add_plugin flutter_version
```

#### 配置 Fastfile

```ruby
# android/fastlane/Fastfile

default_platform(:android)

platform :android do
  desc "构建并发布到 Google Play 内部测试轨道"
  lane :deploy_internal do
    # 切换到项目根目录执行 Flutter 命令
    Dir.chdir("..") do
      sh("flutter", "build", "appbundle", 
         "--obfuscate", 
         "--split-debug-info=./debug_info", 
         "-t", "lib/main_dev.dart", 
         "--release")
    end
    
    # 获取版本信息
    version_info = flutter_version()
    version_name = version_info["version_name"]
    build_number = version_info["version_code"]
    
    # 上传到 Play Store
    upload_to_play_store(
      track: 'internal',  # 内部测试轨道
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      version_name: "#{version_name}(#{build_number})"
    )
  end
  
  desc "发布到 Beta 测试轨道"
  lane :deploy_beta do
    Dir.chdir("..") do
      sh("flutter", "build", "appbundle", 
         "--obfuscate", 
         "--split-debug-info=./debug_info", 
         "--release")
    end
    
    upload_to_play_store(
      track: 'beta',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
  
  desc "发布到生产环境"
  lane :deploy_production do
    Dir.chdir("..") do
      sh("flutter", "build", "appbundle", 
         "--obfuscate", 
         "--split-debug-info=./debug_info", 
         "--release")
    end
    
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      rollout: '0.1'  # 先发布给 10% 用户
    )
  end
end
```

#### 本地测试

```bash
cd android
bundle exec fastlane deploy_internal
```

### 步骤 3：更新 .gitignore

```gitignore
# android/.gitignore
/your-service-account-key.json
/Gemfile.lock
```

### 步骤 4：更新 Bitbucket Pipelines

```yaml
# bitbucket-pipelines.yml

image: ghcr.io/cirruslabs/flutter:3.32.7

definitions:
  caches:
    flutter: /flutter
    pub: $HOME/.pub-cache

clone:
  depth: 1

pipelines:
  default:
    - step:
        name: 分析与测试
        caches:
          - pub
        script:
          - flutter pub get
          - flutter analyze
          - flutter test

  branches:
    # development 分支：自动发布到内部测试
    development:
      - step:
          name: 构建并发布到内部测试
          size: 2x
          caches:
            - pub
          script:
            # 基础设置
            - rm -f pubspec.lock
            - flutter pub get
            - flutter analyze
            
            # 恢复 Android 签名密钥
            - echo $ANDROID_KEYSTORE_BASE64 | base64 -d > android/app/keystore.jks
            - echo $ANDROID_KEYPROPERTIES_BASE64 | base64 -d > android/key.properties
            
            # 恢复 Google Play API 密钥
            - echo $GPLAY_SERVICE_ACCOUNT_KEY_BASE64 | base64 -d > android/your-service-account-key.json
            
            # 通过 Fastlane 部署
            - cd android
            - bundle install
            - bundle exec fastlane deploy_internal
            
          artifacts:
            - build/app/outputs/bundle/release/app-release.aab
    
    # main 分支：发布到 Beta
    main:
      - step:
          name: 构建并发布到 Beta
          size: 2x
          caches:
            - pub
          script:
            - rm -f pubspec.lock
            - flutter pub get
            - flutter analyze
            - flutter test
            
            - echo $ANDROID_KEYSTORE_BASE64 | base64 -d > android/app/keystore.jks
            - echo $ANDROID_KEYPROPERTIES_BASE64 | base64 -d > android/key.properties
            - echo $GPLAY_SERVICE_ACCOUNT_KEY_BASE64 | base64 -d > android/your-service-account-key.json
            
            - cd android
            - bundle install
            - bundle exec fastlane deploy_beta
```

#### 添加 Google Play API 密钥变量

```bash
# 编码 JSON 密钥
base64 -i your-service-account-key.json -o play-key.txt
```

在 Bitbucket 添加仓库变量：

| 变量名 | 值 | 保护 |
|--------|-----|------|
| `GPLAY_SERVICE_ACCOUNT_KEY_BASE64` | play-key.txt 内容 | ✅ |

## iOS 发布配置

### Fastfile 添加 iOS Lane

```ruby
# ios/fastlane/Fastfile

default_platform(:ios)

platform :ios do
  desc "发布到 TestFlight"
  lane :deploy_testflight do
    # 安装证书
    setup_ci
    
    # 匹配证书和描述文件
    match(type: "appstore", readonly: true)
    
    # 构建
    Dir.chdir("..") do
      sh("flutter", "build", "ipa", "--release")
    end
    
    # 上传到 TestFlight
    upload_to_testflight(
      ipa: "../build/ios/ipa/*.ipa",
      skip_waiting_for_build_processing: true
    )
  end
end
```

## GitHub Actions 配置

如果使用 GitHub，可以使用 GitHub Actions：

```yaml
# .github/workflows/deploy.yml

name: Deploy to Play Store

on:
  push:
    branches: [main, development]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: 设置 Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.7'
          channel: 'stable'
          cache: true
      
      - name: 安装依赖
        run: flutter pub get
      
      - name: 代码分析
        run: flutter analyze
      
      - name: 运行测试
        run: flutter test
      
      - name: 解码签名密钥
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/keystore.jks
          echo "${{ secrets.ANDROID_KEYPROPERTIES_BASE64 }}" | base64 -d > android/key.properties
      
      - name: 构建 APK
        run: flutter build appbundle --release
      
      - name: 设置 Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: android
      
      - name: 解码 Play Store 密钥
        run: |
          echo "${{ secrets.GPLAY_SERVICE_ACCOUNT_KEY_BASE64 }}" | base64 -d > android/play-store-key.json
      
      - name: 发布到 Play Store
        working-directory: android
        run: bundle exec fastlane deploy_internal
```

## 最佳实践

::: tip CI/CD 建议
1. **始终使用仓库变量** - 不要在代码中暴露密钥
2. **使用缓存** - 缓存 Flutter SDK 和依赖加速构建
3. **分支策略** - 不同分支发布到不同轨道
4. **先内部测试** - 先发布到内部测试，验证后再推进
5. **版本号管理** - 自动递增版本号
:::

::: warning 注意事项
- 首次上传必须手动在 Play Console 完成
- 确保 keystore 文件备份安全
- 定期轮换服务账号密钥
- 监控构建时间和成本
:::

## 完整工作流程

```
┌─────────────────────────────────────────────────────────────────┐
│                  推荐的发布流程                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   feature/* ──┬── development ──┬── main                        │
│               │                 │                               │
│               ▼                 ▼                               │
│         分析 + 测试        内部测试        Beta / 生产           │
│                                                                 │
│   功能开发 ───▶ 内部验证 ───▶ Beta 测试 ───▶ 正式发布           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 参考资源

- [Bitbucket Pipelines 文档](https://support.atlassian.com/bitbucket-cloud/docs/get-started-with-bitbucket-pipelines/)
- [Fastlane 官方文档](https://docs.fastlane.tools/)
- [Flutter 部署指南](https://docs.flutter.dev/deployment)
- [GitHub Actions for Flutter](https://github.com/subosito/flutter-action)
