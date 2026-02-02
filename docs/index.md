---
layout: home

hero:
  name: "Flutter 从零到一"
  text: "面向前端工程师的系统学习指南"
  tagline: 从 Dart 基础到完整 App 开发，一站式掌握跨平台开发。配套聚合Demo项目，边学边练，代码即用。
  image:
    src: /hero-flutter.svg
    alt: Flutter
  actions:
    - theme: brand
      text: 🚀 开始学习
      link: /dart/01-introduction
    - theme: alt
      text: Widget 大全
      link: /widgets/
    - theme: alt
      text: GitHub
      link: https://github.com/bibinocode/flutter_docs

features:
  - icon: 🎯
    title: Dart 语言基础
    details: 从变量、函数到异步编程，对比 JavaScript/TypeScript 快速掌握 Dart 语法，为 Flutter 开发打下坚实基础
    link: /dart/01-introduction
  - icon: 📱
    title: Flutter 核心教程
    details: Widget 体系、布局系统、状态管理、导航路由、动画效果，系统学习 Flutter 开发全流程
    link: /flutter/01-setup
  - icon: 📦
    title: Widget 组件大全
    details: 800+ 官方 Widget 中文文档，包含功能说明、属性详解、代码示例和使用场景，一站式查阅
    link: /widgets/
  - icon: 🔧
    title: 功能模块实战
    details: 网络请求、数据存储、权限管理、平台适配，每个模块配套可运行的 Demo 代码
    link: /modules/
  - icon: 🔄
    title: 状态管理对比
    details: Riverpod vs GetX vs Provider vs Bloc，同一功能多种实现，理解各方案优劣
    link: /state/
  - icon: 💳
    title: 支付与热更新
    details: 支付宝/微信支付集成、微信登录分享、Shorebird/Fair热更新、App在线升级方案
    link: /modules/payment/alipay
---

<script setup>
import { VPTeamMembers } from 'vitepress/theme'
</script>

<style>
:root {
  --vp-home-hero-name-color: transparent;
  --vp-home-hero-name-background: linear-gradient(135deg, #0553B1 0%, #13B9FD 100%);
}

.dark {
  --vp-home-hero-name-background: linear-gradient(135deg, #13B9FD 0%, #0553B1 100%);
}
</style>

## 📚 学习路线图

<div class="learning-path">

### 第一阶段：Dart 语言基础（2-3 天）

| 章节 | 内容 | 对标前端 |
|------|------|---------|
| 变量与类型 | var、final、const、类型系统 | let、const、TypeScript |
| 函数 | 箭头函数、可选参数、闭包 | ES6 函数、解构 |
| 类与对象 | 构造函数、继承、Mixin | ES6 Class、装饰器 |
| 异步编程 | Future、async/await、Stream | Promise、async/await |
| 空安全 | 可空类型、断言、级联 | TypeScript 可选链 |

### 第二阶段：Flutter 入门（3-5 天）

| 章节 | 内容 | 核心知识点 |
|------|------|-----------|
| 环境搭建 | SDK 安装、IDE 配置、模拟器 | flutter doctor |
| Widget 基础 | 声明式 UI、组合优于继承 | StatelessWidget |
| 状态管理 | 组件状态、生命周期 | StatefulWidget、setState |
| 布局系统 | 约束传递、盒模型 | Row、Column、Stack |

### 第三阶段：进阶开发（1-2 周）

| 模块 | 内容 | 技术栈 |
|------|------|--------|
| 导航路由 | 声明式路由、深度链接 | go_router |
| 状态管理 | 全局状态、依赖注入 | Riverpod、GetX |
| 网络请求 | RESTful API、拦截器 | Dio |
| 数据存储 | 本地缓存、数据库 | Hive、SQLite |
| 动画效果 | 隐式/显式动画、Hero | AnimationController |

### 第四阶段：实战与部署（持续）

| 模块 | 内容 |
|------|------|
| 聚合 Demo | 15 个功能模块实战 |
| 多平台发布 | iOS、Android、Web、桌面 |
| 性能优化 | DevTools、内存分析 |

</div>

## 🎯 特色功能

<div class="features-grid">
  <div class="feature-item">
    <div class="feature-icon">🎮</div>
    <div class="feature-content">
      <h4>DartPad 在线运行</h4>
      <p>基础代码直接在文档中运行，无需本地环境，即学即练</p>
    </div>
  </div>
  <div class="feature-item">
    <div class="feature-icon">📱</div>
    <div class="feature-content">
      <h4>Flutter Web 实时预览</h4>
      <p>复杂 Demo 通过 Flutter Web 嵌入，真实运行效果一目了然</p>
    </div>
  </div>
  <div class="feature-item">
    <div class="feature-icon">📖</div>
    <div class="feature-content">
      <h4>800+ Widget 中文文档</h4>
      <p>自动爬取官方 API 并翻译，属性、示例、场景一应俱全</p>
    </div>
  </div>
  <div class="feature-item">
    <div class="feature-icon">💻</div>
    <div class="feature-content">
      <h4>源码可直接复用</h4>
      <p>聚合 App 按模块组织代码，需要时直接 Copy 到自己项目</p>
    </div>
  </div>
</div>

## 🔗 快速链接

<div class="quick-links">
  <a href="/dart/01-introduction" class="quick-link">
    <span class="icon">🎯</span>
    <span class="text">Dart 入门</span>
  </a>
  <a href="/flutter/01-setup" class="quick-link">
    <span class="icon">📱</span>
    <span class="text">Flutter 教程</span>
  </a>
  <a href="/widgets/" class="quick-link">
    <span class="icon">📦</span>
    <span class="text">Widget 大全</span>
  </a>
  <a href="/modules/" class="quick-link">
    <span class="icon">🔧</span>
    <span class="text">功能模块</span>
  </a>
  <a href="/state/04-getx" class="quick-link">
    <span class="icon">⚡</span>
    <span class="text">GetX 教程</span>
  </a>
  <a href="https://github.com/bibinocode/flutter_docs" class="quick-link" target="_blank">
    <span class="icon">📂</span>
    <span class="text">GitHub</span>
  </a>
</div>

<style>
.learning-path {
  margin: 2rem 0;
}

.learning-path h3 {
  color: var(--vp-c-brand-1);
  border-bottom: 2px solid var(--vp-c-brand-soft);
  padding-bottom: 0.5rem;
  margin-top: 2rem;
}

.learning-path table {
  margin: 1rem 0;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
  margin: 2rem 0;
}

@media (max-width: 768px) {
  .features-grid {
    grid-template-columns: 1fr;
  }
}

.feature-item {
  display: flex;
  gap: 1rem;
  padding: 1.25rem;
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  transition: all 0.3s ease;
}

.feature-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
  border-color: var(--vp-c-brand-soft);
}

.dark .feature-item:hover {
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.4);
}

.feature-icon {
  font-size: 2rem;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--vp-c-brand-soft);
  border-radius: 12px;
  flex-shrink: 0;
}

.feature-content h4 {
  margin: 0 0 0.5rem;
  font-size: 1rem;
  font-weight: 600;
}

.feature-content p {
  margin: 0;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.5;
}

.quick-links {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin: 2rem 0;
}

.quick-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  text-decoration: none;
  color: var(--vp-c-text-1);
  font-weight: 500;
  transition: all 0.2s ease;
}

.quick-link:hover {
  background: var(--vp-c-brand-soft);
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.quick-link .icon {
  font-size: 1.2rem;
}

.quick-link .text {
  font-size: 0.9rem;
}
</style>
