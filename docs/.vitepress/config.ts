import { defineConfig } from 'vitepress'

// Flutter教程文档站点配置
export default defineConfig({
  // 站点元数据
  title: 'Flutter 从零到一',
  description: '面向前端工程师的 Flutter 系统学习指南，从 Dart 基础到完整 App 开发',
  lang: 'zh-CN',
  
  // 部署配置 - GitHub Pages 子路径
  base: '/flutter_docs/',
  
  // 忽略死链接（开发阶段）
  ignoreDeadLinks: true,
  
  // 主题配置
  themeConfig: {
    // Logo
    logo: '/logo.svg',
    siteTitle: 'Flutter 从零到一',
    
    // 导航栏
    nav: [
      { text: '首页', link: '/' },
      { text: 'Dart 基础', link: '/dart/01-introduction' },
      { text: 'Flutter 教程', link: '/flutter/01-introduction' },
      { text: '状态管理', link: '/state/' },
      { text: 'Widget 大全', link: '/widgets/' },
      { text: '功能模块', link: '/modules/' },
      { text: '项目推荐', link: '/projects/' },
      { text: '📢 最新动态', link: '/news/' },
      { text: '🔗 Web3 全栈', link: '/web3/' },
      { text: '🦀 Rust 实战', link: '/rust/' },
    ],
    
    // 侧边栏
    sidebar: {
      // Dart 基础教程
      '/dart/': [
        {
          text: 'Dart 语言基础',
          collapsed: false,
          items: [
            { text: '语言简介', link: '/dart/01-introduction' },
            { text: '变量与数据类型', link: '/dart/02-variables' },
            { text: '函数与闭包', link: '/dart/03-functions' },
            { text: '类与对象', link: '/dart/04-classes' },
            { text: '异步编程', link: '/dart/05-async' },
          ]
        },
        {
          text: 'Dart 进阶特性',
          collapsed: false,
          items: [
            { text: '集合详解', link: '/dart/06-collections' },
            { text: '空安全', link: '/dart/07-null-safety' },
            { text: '泛型详解', link: '/dart/08-generics' },
            { text: '异常处理', link: '/dart/09-exceptions' },
            { text: '扩展方法', link: '/dart/10-extensions' },
            { text: 'Mixin与继承', link: '/dart/11-mixins' },
            { text: '模式匹配', link: '/dart/12-patterns' },
          ]
        }
      ],
      
      // Flutter 教程
      '/flutter/': [
        {
          text: 'Flutter 入门',
          collapsed: false,
          items: [
            { text: 'Flutter 简介', link: '/flutter/01-introduction' },
            { text: 'Widget 基础', link: '/flutter/02-widgets' },
            { text: '布局系统', link: '/flutter/03-layout' },
            { text: '状态管理基础', link: '/flutter/04-state' },
          ]
        },
        {
          text: 'Flutter 进阶',
          collapsed: false,
          items: [
            { text: '路由与导航', link: '/flutter/05-navigation' },
            { text: '动画系统', link: '/flutter/06-animation' },
            { text: '主题与样式', link: '/flutter/07-theming' },
            { text: '网络请求', link: '/flutter/08-networking' },
            { text: '数据持久化', link: '/flutter/09-storage' },
            { text: '平台集成', link: '/flutter/10-platform' },
          ]
        },
        {
          text: 'Flutter 实战',
          collapsed: false,
          items: [
            { text: '测试与调试', link: '/flutter/11-testing' },
            { text: '发布部署', link: '/flutter/12-deployment' },
          ]
        },
        {
          text: 'Flutter 核心概念',
          collapsed: false,
          items: [
            { text: '生命周期', link: '/flutter/lifecycle' },
          ]
        },
      ],
      
      // 状态管理专题
      '/state/': [
        {
          text: '状态管理',
          collapsed: false,
          items: [
            { text: '状态管理概述', link: '/state/' },
            { text: 'setState 详解', link: '/state/01-setstate' },
            { text: 'Provider 详解', link: '/state/02-provider' },
            { text: 'Riverpod 详解', link: '/state/03-riverpod' },
            { text: 'GetX 详解', link: '/state/04-getx' },
            { text: 'GetX 架构实战', link: '/state/getx-architecture' },
            { text: 'Bloc 详解', link: '/state/05-bloc' },
            { text: '方案对比与选择', link: '/state/06-comparison' },
          ]
        }
      ],
      
      // Widget 大全
      '/widgets/': [
        {
          text: 'Widget 概览',
          items: [
            { text: 'Widget 索引', link: '/widgets/' },
          ]
        },
        {
          text: '基础组件',
          collapsed: false,
          items: [
            { text: 'Text 文本', link: '/widgets/basics/text' },
            { text: 'Image 图片', link: '/widgets/basics/image' },
            { text: 'Icon 图标', link: '/widgets/basics/icon' },
            { text: 'Container 容器', link: '/widgets/basics/container' },
            { text: 'Padding 内边距', link: '/widgets/basics/padding' },
            { text: 'Center 居中', link: '/widgets/basics/center' },
            { text: 'SizedBox 固定尺寸', link: '/widgets/basics/sizedbox' },
            { text: 'Expanded 扩展', link: '/widgets/basics/expanded' },
          ]
        },
        {
          text: '布局组件',
          collapsed: true,
          items: [
            { text: 'Row 行布局', link: '/widgets/layout/row' },
            { text: 'Column 列布局', link: '/widgets/layout/column' },
            { text: 'Stack 层叠', link: '/widgets/layout/stack' },
            { text: 'Wrap 流式', link: '/widgets/layout/wrap' },
            { text: 'LayoutBuilder', link: '/widgets/layout/layoutbuilder' },
            { text: 'AspectRatio 宽高比', link: '/widgets/layout/aspectratio' },
          ]
        },
        {
          text: '滚动组件',
          collapsed: true,
          items: [
            { text: 'ListView 列表', link: '/widgets/scrolling/listview' },
            { text: 'GridView 网格', link: '/widgets/scrolling/gridview' },
            { text: 'PageView 分页', link: '/widgets/scrolling/pageview' },
            { text: 'CustomScrollView', link: '/widgets/scrolling/customscrollview' },
            { text: 'RefreshIndicator', link: '/widgets/scrolling/refreshindicator' },
            { text: 'NestedScrollView', link: '/widgets/scrolling/nestedscrollview' },
            { text: 'SliverList/SliverGrid', link: '/widgets/scrolling/sliverlist' },
          ]
        },
        {
          text: 'Material 组件',
          collapsed: true,
          items: [
            { text: 'Material 概览', link: '/widgets/material/' },
            { text: 'Scaffold 脚手架', link: '/widgets/material/scaffold' },
            { text: 'AppBar 应用栏', link: '/widgets/material/appbar' },
            { text: 'SliverAppBar', link: '/widgets/material/sliverappbar' },
            { text: 'BottomNavigationBar', link: '/widgets/material/bottomnavigationbar' },
            { text: 'NavigationBar', link: '/widgets/material/navigationbar' },
            { text: 'NavigationRail', link: '/widgets/material/navigationrail' },
            { text: 'Drawer 抽屉', link: '/widgets/material/drawer' },
            { text: 'TabBar 选项卡', link: '/widgets/material/tabbar' },
            { text: 'Card 卡片', link: '/widgets/material/card' },
            { text: 'Chip 芯片', link: '/widgets/material/chip' },
            { text: 'ListTile 列表项', link: '/widgets/material/listtile' },
            { text: 'Dialog 对话框', link: '/widgets/material/dialog' },
            { text: 'BottomSheet 底部面板', link: '/widgets/material/bottomsheet' },
            { text: 'SnackBar 消息条', link: '/widgets/material/snackbar' },
            { text: 'ElevatedButton', link: '/widgets/material/elevatedbutton' },
            { text: 'TextField 输入框', link: '/widgets/material/textfield' },
          ]
        },
        {
          text: '按钮组件',
          collapsed: true,
          items: [
            { text: 'ElevatedButton', link: '/widgets/buttons/elevatedbutton' },
            { text: 'FilledButton', link: '/widgets/buttons/filledbutton' },
            { text: 'OutlinedButton', link: '/widgets/buttons/outlinedbutton' },
            { text: 'TextButton', link: '/widgets/buttons/textbutton' },
            { text: 'IconButton', link: '/widgets/buttons/iconbutton' },
            { text: 'FloatingActionButton', link: '/widgets/buttons/floatingactionbutton' },
          ]
        },
        {
          text: '输入组件',
          collapsed: true,
          items: [
            { text: 'TextField 输入框', link: '/widgets/input/textfield' },
            { text: 'Checkbox 复选框', link: '/widgets/input/checkbox' },
            { text: 'Radio 单选框', link: '/widgets/input/radio' },
            { text: 'Switch 开关', link: '/widgets/input/switch' },
            { text: 'Slider 滑块', link: '/widgets/input/slider' },
          ]
        },
        {
          text: '动画组件',
          collapsed: true,
          items: [
            { text: '动画概览', link: '/widgets/animation/' },
            { text: 'AnimatedContainer', link: '/widgets/animation/animatedcontainer' },
            { text: 'AnimatedOpacity', link: '/widgets/animation/animatedopacity' },
            { text: 'AnimatedPadding', link: '/widgets/animation/animatedpadding' },
            { text: 'AnimatedDefaultTextStyle', link: '/widgets/animation/animateddefaulttextstyle' },
            { text: 'AnimatedCrossFade', link: '/widgets/animation/animatedcrossfade' },
            { text: 'AnimatedSwitcher', link: '/widgets/animation/animatedswitcher' },
            { text: 'AnimatedPositioned', link: '/widgets/animation/animatedpositioned' },
            { text: 'AnimatedPhysicalModel', link: '/widgets/animation/animatedphysicalmodel' },
            { text: 'AnimatedList', link: '/widgets/animation/animatedlist' },
            { text: 'AnimatedIcon', link: '/widgets/animation/animatedicon' },
            { text: 'AnimatedBuilder', link: '/widgets/animation/animatedbuilder' },
            { text: 'TweenAnimationBuilder', link: '/widgets/animation/tweenanimationbuilder' },
            { text: 'AnimatedFractionallySizedBox', link: '/widgets/animation/animatedfractionallysizedbox' },
            { text: 'AnimatedModalBarrier', link: '/widgets/animation/animatedmodalbarrier' },
            { text: 'AnimatedSlide', link: '/widgets/animation/animatedslide' },
            { text: 'AnimatedRotation', link: '/widgets/animation/animatedrotation' },
            { text: 'Hero', link: '/widgets/animation/hero' },
            { text: 'FadeTransition', link: '/widgets/animation/fadetransition' },
            { text: 'SlideTransition', link: '/widgets/animation/slidetransition' },
            { text: 'ScaleTransition', link: '/widgets/animation/scaletransition' },
            { text: 'RotationTransition', link: '/widgets/animation/rotationtransition' },
          ]
        },
        {
          text: '手势组件',
          collapsed: true,
          items: [
            { text: 'GestureDetector', link: '/widgets/gesture/gesturedetector' },
            { text: 'InkWell', link: '/widgets/gesture/inkwell' },
            { text: 'Draggable', link: '/widgets/gesture/draggable' },
            { text: 'Dismissible', link: '/widgets/gesture/dismissible' },
          ]
        },
        {
          text: 'Cupertino 组件',
          collapsed: true,
          items: [
            { text: 'Cupertino 概览', link: '/widgets/cupertino/' },
            { text: 'CupertinoApp', link: '/widgets/cupertino/cupertinoapp' },
            { text: 'CupertinoNavigationBar', link: '/widgets/cupertino/cupertinonavigationbar' },
            { text: 'CupertinoTabBar', link: '/widgets/cupertino/cupertinotabbar' },
            { text: 'CupertinoButton', link: '/widgets/cupertino/cupertinobutton' },
            { text: 'CupertinoTextField', link: '/widgets/cupertino/cupertinotextfield' },
            { text: 'CupertinoSwitch', link: '/widgets/cupertino/cupertinoswitch' },
            { text: 'CupertinoSlider', link: '/widgets/cupertino/cupertinoslider' },
            { text: 'CupertinoPicker', link: '/widgets/cupertino/cupertinopicker' },
            { text: 'CupertinoDatePicker', link: '/widgets/cupertino/cupertinodatepicker' },
            { text: 'CupertinoActionSheet', link: '/widgets/cupertino/cupertinoactionsheet' },
            { text: 'CupertinoAlertDialog', link: '/widgets/cupertino/cupertinoalertdialog' },
          ]
        },
        {
          text: '裁剪组件',
          collapsed: true,
          items: [
            { text: 'Clip 系列', link: '/widgets/clip/' },
          ]
        },
      ],
      
      // Web3 全栈开发
      '/web3/': [
        {
          text: 'GO + Flutter Web3 从零到一',
          collapsed: false,
          items: [
            { text: '📋 教学大纲总览', link: '/web3/' },
            { text: '🚀 零基础入门指南', link: '/web3/00-getting-started' },
          ]
        },
        {
          text: '第一模块：区块链基础与密码学',
          collapsed: false,
          items: [
            { text: '第1章 区块链核心原理', link: '/web3/01-blockchain-fundamentals' },
            { text: '第2章 密码学与钱包原理', link: '/web3/02-cryptography' },
            { text: '第3章 以太坊架构与多链生态', link: '/web3/03-ethereum-multichain' },
          ]
        },
        {
          text: '第二模块：Go 后端开发',
          collapsed: false,
          items: [
            { text: '第4章 Go 语言核心精通', link: '/web3/04-go-core' },
            { text: '第5章 Go-Ethereum 链上交互', link: '/web3/05-go-ethereum' },
            { text: '第9章 Go 后端微服务架构', link: '/web3/09-go-microservices' },
            { text: '第10章 数据存储与高可用', link: '/web3/10-go-storage' },
          ]
        },
        {
          text: '第三模块：智能合约开发',
          collapsed: false,
          items: [
            { text: '第6章 Solidity 智能合约开发', link: '/web3/06-solidity-fundamentals' },
            { text: '第11章 DeFi 协议 Uniswap V3/V4', link: '/web3/11-defi-uniswap' },
            { text: '第12章 合约安全与审计', link: '/web3/12-contract-security' },
            { text: '第13章 Solana 合约开发 (Rust)', link: '/web3/13-solana-rust' },
          ]
        },
        {
          text: '第四模块：Flutter DApp 前端',
          collapsed: false,
          items: [
            { text: '第7章 Flutter DApp 前端开发', link: '/web3/07-flutter-web3' },
            { text: '第8章 Web3 前端交互基础', link: '/web3/08-web3-frontend-basics' },
            { text: '第14章 Flutter 钱包深度开发', link: '/web3/14-flutter-wallet' },
            { text: '第15章 DApp 浏览器与 DeFi 交互', link: '/web3/15-flutter-dapp-browser' },
            { text: '第16章 状态管理与工程化', link: '/web3/16-flutter-engineering' },
          ]
        },
        {
          text: '第五模块：综合实战项目',
          collapsed: true,
          items: [
            { text: '后续章节持续更新中...', link: '/web3/#第五模块-综合实战项目与部署上线-6-周' },
          ]
        },
      ],
      
      // Rust + Flutter 实战专栏
      '/rust/': [
        {
          text: 'Rust + Flutter 实战专栏',
          collapsed: false,
          items: [
            { text: '📋 课程大纲总览', link: '/rust/' },
          ]
        },
        {
          text: '第一模块：Rust 语言基础',
          collapsed: false,
          items: [
            { text: '第1章 环境搭建与基础语法', link: '/rust/01-basics' },
            { text: '第2章 所有权、借用与生命周期', link: '/rust/02-ownership' },
            { text: '第3章 结构体、枚举与模式匹配', link: '/rust/03-compound-types' },
          ]
        },
        {
          text: '第二模块：Rust 高级特性',
          collapsed: false,
          items: [
            { text: '第4章 Trait 与泛型编程', link: '/rust/04-traits-generics' },
            { text: '第5章 错误处理与集合类型', link: '/rust/05-error-handling' },
            { text: '第6章 闭包与迭代器', link: '/rust/06-closures-iterators' },
          ]
        },
        {
          text: '第三模块：Rust 系统编程',
          collapsed: false,
          items: [
            { text: '第7章 智能指针与内存管理', link: '/rust/07-smart-pointers' },
            { text: '第8章 多线程与并发编程', link: '/rust/08-concurrency' },
            { text: '第9章 异步编程与 Tokio', link: '/rust/09-async' },
          ]
        },
        {
          text: '第四模块：Flutter Rust Bridge',
          collapsed: false,
          items: [
            { text: '第10章 FRB 基础与项目搭建', link: '/rust/10-flutter-rust-bridge' },
            { text: '第11章 类型映射与跨语言调用', link: '/rust/11-type-bindning' },
            { text: '第12章 异步、流与高级特性', link: '/rust/12-async-stream' },
          ]
        },
        {
          text: '第五模块：综合实战项目',
          collapsed: false,
          items: [
            { text: '第13章 热更新系统', link: '/rust/13-hot-reload' },
            { text: '第14章 音视频播放器', link: '/rust/14-media-player' },
          ]
        },
      ],

      // 新闻动态
      '/news/': [
        {
          text: 'Flutter 动态',
          items: [
            { text: '最新动态', link: '/news/' },
          ]
        }
      ],
      
      // 功能模块
      '/modules/': [
        {
          text: '功能模块',
          items: [
            { text: '功能模块概述', link: '/modules/' },
          ]
        },
        {
          text: '开发适配',
          collapsed: false,
          items: [
            { text: '屏幕适配', link: '/modules/adaptation' },
            { text: 'Flutter 版本管理', link: '/modules/version-management' },
          ]
        },
        {
          text: '用户认证',
          collapsed: true,
          items: [
            { text: 'Apple 登录', link: '/modules/auth/apple-signin' },
            { text: '生物识别', link: '/modules/biometric/biometric' },
          ]
        },
        {
          text: '主题定制',
          collapsed: true,
          items: [
            { text: '主题色生成器', link: '/modules/theme/color-generator' },
          ]
        },
        {
          text: '性能优化',
          collapsed: true,
          items: [
            { text: '感知性能优化', link: '/modules/performance/perceived-performance' },
          ]
        },
        {
          text: '网络请求',
          collapsed: true,
          items: [
            { text: 'http 包', link: '/modules/network/http' },
            { text: 'Dio 详解', link: '/modules/network/dio' },
            { text: 'Mock 数据', link: '/modules/network/mock' },
          ]
        },
        {
          text: '数据存储',
          collapsed: true,
          items: [
            { text: 'SharedPreferences', link: '/modules/storage/shared-prefs' },
            { text: 'Hive 数据库', link: '/modules/storage/hive' },
            { text: 'SQLite', link: '/modules/storage/sqlite' },
          ]
        },
        {
          text: '消息通知',
          collapsed: true,
          items: [
            { text: '本地通知', link: '/modules/notification/local-notification' },
          ]
        },
        {
          text: '权限管理',
          collapsed: true,
          items: [
            { text: 'permission_handler', link: '/modules/permission' },
          ]
        },
        {
          text: '图片与相机',
          collapsed: true,
          items: [
            { text: '图片选择', link: '/modules/image-picker' },
            { text: '图片压缩', link: '/modules/image-compress' },
          ]
        },
        {
          text: 'JavaScript 引擎',
          collapsed: true,
          items: [
            { text: 'FJS 执行引擎', link: '/modules/fjs' },
          ]
        },
        {
          text: '部署发布',
          collapsed: true,
          items: [
            { text: 'CI/CD 自动化', link: '/modules/deploy/cicd' },
          ]
        },
        {
          text: '平台适配',
          collapsed: true,
          items: [
            { text: 'Web 适配', link: '/modules/platform/web' },
            { text: '桌面端适配', link: '/modules/platform/desktop' },
            { text: '响应式布局', link: '/modules/platform/responsive' },
            { text: 'Platform Channel', link: '/modules/platform/channel' },
            { text: '鸿蒙适配', link: '/modules/platform/harmonyos' },
          ]
        },
        {
          text: '绘图',
          collapsed: true,
          items: [
            { text: 'Canvas 绘图', link: '/modules/drawing/' },
          ]
        },
        {
          text: '传感器',
          collapsed: true,
          items: [
            { text: '设备传感器', link: '/modules/sensor/' },
          ]
        },
        {
          text: '支付集成',
          collapsed: true,
          items: [
            { text: '支付宝支付', link: '/modules/payment/alipay' },
            { text: '微信支付', link: '/modules/payment/wechatpay' },
            { text: '微信登录与分享', link: '/modules/payment/wechat-login-share' },
          ]
        },
        {
          text: '热更新',
          collapsed: true,
          items: [
            { text: '热更新方案', link: '/modules/hotupdate/' },
          ]
        },
        {
          text: 'App 更新',
          collapsed: true,
          items: [
            { text: '在线更新', link: '/modules/app-update/' },
          ]
        }
      ],
      
      // 项目推荐
      '/projects/': [
        {
          text: '项目学习推荐',
          items: [
            { text: '推荐概览', link: '/projects/' },
          ]
        },
        {
          text: '完整应用',
          collapsed: false,
          items: [
            { text: 'LocalSend - 跨平台文件传输', link: '/projects/localsend' },
            { text: 'FlClash - 代理客户端', link: '/projects/flclash' },
            { text: 'AppFlowy - Notion 替代品', link: '/projects/appflowy' },
            { text: 'PiliPala - B站客户端', link: '/projects/pilipala' },
            { text: 'Flutter Novel - 小说阅读器', link: '/projects/flutter-novel' },
          ]
        },
        {
          text: 'UI 模板与组件',
          collapsed: false,
          items: [
            { text: 'Flutter UI Templates', link: '/projects/flutter-ui-templates' },
            { text: 'FlutterCandies 糖果社区', link: '/projects/fluttercandies' },
          ]
        },
        {
          text: 'FlutterCandies 插件',
          collapsed: false,
          items: [
            { text: 'Photo Manager - 媒体资源管理', link: '/projects/photo-manager' },
            { text: 'WeChat Camera Picker - 微信相机', link: '/projects/wechat-camera-picker' },
            { text: 'WeChat Flutter - 仿微信应用', link: '/projects/wechat-flutter' },
          ]
        },
      ],
      
      // 生态系统
      '/ecosystem/': [
        {
          text: '生态系统',
          items: [
            { text: '生态概览', link: '/ecosystem/' },
            { text: '常用包推荐', link: '/ecosystem/packages' },
            { text: '架构模式', link: '/ecosystem/architecture' },
            { text: '最佳实践', link: '/ecosystem/best-practices' },
            { text: '性能优化', link: '/ecosystem/performance' },
          ]
        }
      ]
    },
    
    // 社交链接
    socialLinks: [
      { icon: 'github', link: 'https://github.com/bibinocode/flutter_docs' }
    ],
    
    // 页脚
    footer: {
      message: '基于 Flutter/Dart 官方文档翻译，遵循 CC BY 4.0 协议',
      copyright: 'Copyright © 2024-present Flutter 从零到一'
    },
    
    // 搜索
    search: {
      provider: 'local',
      options: {
        locales: {
          root: {
            translations: {
              button: {
                buttonText: '搜索文档',
                buttonAriaLabel: '搜索文档'
              },
              modal: {
                noResultsText: '无法找到相关结果',
                resetButtonTitle: '清除查询条件',
                footer: {
                  selectText: '选择',
                  navigateText: '切换'
                }
              }
            }
          }
        }
      }
    },
    
    // 文章大纲
    outline: {
      level: [2, 3],
      label: '本页目录'
    },
    
    // 上下页
    docFooter: {
      prev: '上一篇',
      next: '下一篇'
    },
    
    // 最后更新时间
    lastUpdated: {
      text: '最后更新于',
      formatOptions: {
        dateStyle: 'short',
        timeStyle: 'short'
      }
    },
    
    // 编辑链接
    editLink: {
      pattern: 'https://github.com/bibinocode/flutter_docs/edit/main/docs/:path',
      text: '在 GitHub 上编辑此页'
    }
  },
  
  // Markdown 配置
  markdown: {
    lineNumbers: true,
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    }
  },
  
  // Head 标签
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#0553B1' }],
    ['meta', { name: 'og:type', content: 'website' }],
    ['meta', { name: 'og:title', content: 'Flutter 从零到一' }],
    ['meta', { name: 'og:description', content: '面向前端工程师的 Flutter 系统学习指南' }],
    ['meta', { name: 'og:site_name', content: 'Flutter 从零到一' }],
  ],
  
  // 站点地图
  sitemap: {
    hostname: 'https://flutter.kmod.cn'
  },
  
  // 最后更新时间
  lastUpdated: true
})
