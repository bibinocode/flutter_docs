#!/usr/bin/env node

/**
 * Flutter Widget 文档爬取脚本
 * 从 Flutter 官方文档爬取 Widget 信息并生成 Markdown 文档
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// Widget 分类和对应的官方文档链接
const WIDGET_CATEGORIES = {
  basics: {
    name: '基础组件',
    widgets: [
      { name: 'Text', url: 'https://api.flutter.dev/flutter/widgets/Text-class.html' },
      { name: 'Image', url: 'https://api.flutter.dev/flutter/widgets/Image-class.html' },
      { name: 'Icon', url: 'https://api.flutter.dev/flutter/widgets/Icon-class.html' },
      { name: 'Container', url: 'https://api.flutter.dev/flutter/widgets/Container-class.html' },
      { name: 'Padding', url: 'https://api.flutter.dev/flutter/widgets/Padding-class.html' },
      { name: 'Center', url: 'https://api.flutter.dev/flutter/widgets/Center-class.html' },
      { name: 'SizedBox', url: 'https://api.flutter.dev/flutter/widgets/SizedBox-class.html' },
      { name: 'Expanded', url: 'https://api.flutter.dev/flutter/widgets/Expanded-class.html' },
      { name: 'Flexible', url: 'https://api.flutter.dev/flutter/widgets/Flexible-class.html' },
      { name: 'Spacer', url: 'https://api.flutter.dev/flutter/widgets/Spacer-class.html' },
    ]
  },
  layout: {
    name: '布局组件',
    widgets: [
      { name: 'Row', url: 'https://api.flutter.dev/flutter/widgets/Row-class.html' },
      { name: 'Column', url: 'https://api.flutter.dev/flutter/widgets/Column-class.html' },
      { name: 'Stack', url: 'https://api.flutter.dev/flutter/widgets/Stack-class.html' },
      { name: 'Positioned', url: 'https://api.flutter.dev/flutter/widgets/Positioned-class.html' },
      { name: 'Wrap', url: 'https://api.flutter.dev/flutter/widgets/Wrap-class.html' },
      { name: 'Flow', url: 'https://api.flutter.dev/flutter/widgets/Flow-class.html' },
      { name: 'LayoutBuilder', url: 'https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html' },
      { name: 'ConstrainedBox', url: 'https://api.flutter.dev/flutter/widgets/ConstrainedBox-class.html' },
      { name: 'AspectRatio', url: 'https://api.flutter.dev/flutter/widgets/AspectRatio-class.html' },
      { name: 'FittedBox', url: 'https://api.flutter.dev/flutter/widgets/FittedBox-class.html' },
    ]
  },
  scrolling: {
    name: '滚动组件',
    widgets: [
      { name: 'ListView', url: 'https://api.flutter.dev/flutter/widgets/ListView-class.html' },
      { name: 'GridView', url: 'https://api.flutter.dev/flutter/widgets/GridView-class.html' },
      { name: 'SingleChildScrollView', url: 'https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html' },
      { name: 'CustomScrollView', url: 'https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html' },
      { name: 'PageView', url: 'https://api.flutter.dev/flutter/widgets/PageView-class.html' },
      { name: 'RefreshIndicator', url: 'https://api.flutter.dev/flutter/material/RefreshIndicator-class.html' },
      { name: 'ReorderableListView', url: 'https://api.flutter.dev/flutter/material/ReorderableListView-class.html' },
      { name: 'Scrollbar', url: 'https://api.flutter.dev/flutter/widgets/Scrollbar-class.html' },
    ]
  },
  material: {
    name: 'Material 组件',
    widgets: [
      { name: 'Scaffold', url: 'https://api.flutter.dev/flutter/material/Scaffold-class.html' },
      { name: 'AppBar', url: 'https://api.flutter.dev/flutter/material/AppBar-class.html' },
      { name: 'BottomNavigationBar', url: 'https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html' },
      { name: 'NavigationBar', url: 'https://api.flutter.dev/flutter/material/NavigationBar-class.html' },
      { name: 'NavigationRail', url: 'https://api.flutter.dev/flutter/material/NavigationRail-class.html' },
      { name: 'Drawer', url: 'https://api.flutter.dev/flutter/material/Drawer-class.html' },
      { name: 'TabBar', url: 'https://api.flutter.dev/flutter/material/TabBar-class.html' },
      { name: 'Card', url: 'https://api.flutter.dev/flutter/material/Card-class.html' },
      { name: 'Chip', url: 'https://api.flutter.dev/flutter/material/Chip-class.html' },
      { name: 'Dialog', url: 'https://api.flutter.dev/flutter/material/Dialog-class.html' },
      { name: 'BottomSheet', url: 'https://api.flutter.dev/flutter/material/BottomSheet-class.html' },
      { name: 'SnackBar', url: 'https://api.flutter.dev/flutter/material/SnackBar-class.html' },
    ]
  },
  buttons: {
    name: '按钮组件',
    widgets: [
      { name: 'ElevatedButton', url: 'https://api.flutter.dev/flutter/material/ElevatedButton-class.html' },
      { name: 'FilledButton', url: 'https://api.flutter.dev/flutter/material/FilledButton-class.html' },
      { name: 'OutlinedButton', url: 'https://api.flutter.dev/flutter/material/OutlinedButton-class.html' },
      { name: 'TextButton', url: 'https://api.flutter.dev/flutter/material/TextButton-class.html' },
      { name: 'IconButton', url: 'https://api.flutter.dev/flutter/material/IconButton-class.html' },
      { name: 'FloatingActionButton', url: 'https://api.flutter.dev/flutter/material/FloatingActionButton-class.html' },
      { name: 'PopupMenuButton', url: 'https://api.flutter.dev/flutter/material/PopupMenuButton-class.html' },
      { name: 'DropdownButton', url: 'https://api.flutter.dev/flutter/material/DropdownButton-class.html' },
    ]
  },
  input: {
    name: '输入组件',
    widgets: [
      { name: 'TextField', url: 'https://api.flutter.dev/flutter/material/TextField-class.html' },
      { name: 'TextFormField', url: 'https://api.flutter.dev/flutter/material/TextFormField-class.html' },
      { name: 'Checkbox', url: 'https://api.flutter.dev/flutter/material/Checkbox-class.html' },
      { name: 'Radio', url: 'https://api.flutter.dev/flutter/material/Radio-class.html' },
      { name: 'Switch', url: 'https://api.flutter.dev/flutter/material/Switch-class.html' },
      { name: 'Slider', url: 'https://api.flutter.dev/flutter/material/Slider-class.html' },
      { name: 'DatePicker', url: 'https://api.flutter.dev/flutter/material/showDatePicker.html' },
      { name: 'TimePicker', url: 'https://api.flutter.dev/flutter/material/showTimePicker.html' },
    ]
  },
  animation: {
    name: '动画组件',
    widgets: [
      { name: 'AnimatedContainer', url: 'https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html' },
      { name: 'AnimatedOpacity', url: 'https://api.flutter.dev/flutter/widgets/AnimatedOpacity-class.html' },
      { name: 'AnimatedPositioned', url: 'https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html' },
      { name: 'AnimatedCrossFade', url: 'https://api.flutter.dev/flutter/widgets/AnimatedCrossFade-class.html' },
      { name: 'AnimatedSwitcher', url: 'https://api.flutter.dev/flutter/widgets/AnimatedSwitcher-class.html' },
      { name: 'Hero', url: 'https://api.flutter.dev/flutter/widgets/Hero-class.html' },
      { name: 'FadeTransition', url: 'https://api.flutter.dev/flutter/widgets/FadeTransition-class.html' },
      { name: 'ScaleTransition', url: 'https://api.flutter.dev/flutter/widgets/ScaleTransition-class.html' },
      { name: 'SlideTransition', url: 'https://api.flutter.dev/flutter/widgets/SlideTransition-class.html' },
      { name: 'RotationTransition', url: 'https://api.flutter.dev/flutter/widgets/RotationTransition-class.html' },
    ]
  },
  gesture: {
    name: '手势组件',
    widgets: [
      { name: 'GestureDetector', url: 'https://api.flutter.dev/flutter/widgets/GestureDetector-class.html' },
      { name: 'InkWell', url: 'https://api.flutter.dev/flutter/material/InkWell-class.html' },
      { name: 'Draggable', url: 'https://api.flutter.dev/flutter/widgets/Draggable-class.html' },
      { name: 'DragTarget', url: 'https://api.flutter.dev/flutter/widgets/DragTarget-class.html' },
      { name: 'Dismissible', url: 'https://api.flutter.dev/flutter/widgets/Dismissible-class.html' },
      { name: 'LongPressDraggable', url: 'https://api.flutter.dev/flutter/widgets/LongPressDraggable-class.html' },
    ]
  },
  cupertino: {
    name: 'Cupertino 组件',
    widgets: [
      { name: 'CupertinoApp', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoApp-class.html' },
      { name: 'CupertinoNavigationBar', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoNavigationBar-class.html' },
      { name: 'CupertinoTabBar', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoTabBar-class.html' },
      { name: 'CupertinoButton', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoButton-class.html' },
      { name: 'CupertinoTextField', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoTextField-class.html' },
      { name: 'CupertinoSwitch', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoSwitch-class.html' },
      { name: 'CupertinoSlider', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoSlider-class.html' },
      { name: 'CupertinoPicker', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoPicker-class.html' },
      { name: 'CupertinoActionSheet', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoActionSheet-class.html' },
      { name: 'CupertinoAlertDialog', url: 'https://api.flutter.dev/flutter/cupertino/CupertinoAlertDialog-class.html' },
    ]
  },
};

// Widget 文档模板
function generateWidgetDoc(widget, category) {
  return `# ${widget.name}

\`${widget.name}\` 是 Flutter ${category.name}之一。

## 基本用法

\`\`\`dart
${widget.name}(
  // 属性配置
)
\`\`\`

## 常用属性

| 属性 | 类型 | 说明 |
|------|------|------|
| - | - | 待补充 |

## 完整示例

\`\`\`dart
import 'package:flutter/material.dart';

class ${widget.name}Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.name} 示例')),
      body: Center(
        child: ${widget.name}(
          // TODO: 添加属性
        ),
      ),
    );
  }
}
\`\`\`

## 最佳实践

1. 待补充

## 相关组件

- 待补充

## 官方文档

- [${widget.name} API](${widget.url})
`;
}

// 生成分类索引
function generateCategoryIndex(categoryKey, category) {
  const widgetLinks = category.widgets
    .map(w => `- [${w.name}](./${w.name.toLowerCase()})`)
    .join('\n');
  
  return `# ${category.name}

本节介绍 Flutter 中常用的${category.name}。

## 组件列表

${widgetLinks}
`;
}

// 主函数
async function main() {
  const docsDir = path.join(__dirname, '../docs/widgets');
  
  console.log('🚀 开始生成 Widget 文档...\n');
  
  for (const [categoryKey, category] of Object.entries(WIDGET_CATEGORIES)) {
    const categoryDir = path.join(docsDir, categoryKey);
    
    // 创建目录
    if (!fs.existsSync(categoryDir)) {
      fs.mkdirSync(categoryDir, { recursive: true });
    }
    
    console.log(`📁 处理分类: ${category.name}`);
    
    // 生成分类索引
    const indexPath = path.join(categoryDir, 'index.md');
    fs.writeFileSync(indexPath, generateCategoryIndex(categoryKey, category));
    console.log(`  ✅ 生成索引: ${categoryKey}/index.md`);
    
    // 生成每个 Widget 的文档
    for (const widget of category.widgets) {
      const widgetPath = path.join(categoryDir, `${widget.name.toLowerCase()}.md`);
      
      // 如果文件已存在，跳过
      if (fs.existsSync(widgetPath)) {
        console.log(`  ⏭️  跳过已存在: ${widget.name.toLowerCase()}.md`);
        continue;
      }
      
      fs.writeFileSync(widgetPath, generateWidgetDoc(widget, category));
      console.log(`  ✅ 生成文档: ${widget.name.toLowerCase()}.md`);
    }
    
    console.log('');
  }
  
  // 生成主索引
  generateMainIndex(docsDir);
  
  console.log('✨ 文档生成完成！');
  console.log(`📊 共生成 ${countWidgets()} 个 Widget 文档模板`);
}

function generateMainIndex(docsDir) {
  let content = `# Widget 大全

Flutter 提供了丰富的 Widget 来构建用户界面。本文档整理了常用 Widget 的详细说明和使用示例。

## 分类导航

`;

  for (const [categoryKey, category] of Object.entries(WIDGET_CATEGORIES)) {
    content += `### [${category.name}](./${categoryKey}/)\n\n`;
    content += category.widgets.map(w => `\`${w.name}\``).join(' · ');
    content += '\n\n';
  }
  
  content += `
## 如何选择 Widget

| 需求 | 推荐 Widget |
|------|------------|
| 显示文字 | Text, RichText |
| 显示图片 | Image, FadeInImage |
| 按钮交互 | ElevatedButton, TextButton, IconButton |
| 输入文本 | TextField, TextFormField |
| 列表展示 | ListView, GridView |
| 页面布局 | Scaffold, AppBar, BottomNavigationBar |
| 弹窗提示 | Dialog, SnackBar, BottomSheet |
| 动画效果 | AnimatedContainer, Hero |

## 快速查找

按首字母查找：

`;

  // 收集所有 widget 并按字母排序
  const allWidgets = [];
  for (const category of Object.values(WIDGET_CATEGORIES)) {
    for (const widget of category.widgets) {
      allWidgets.push(widget);
    }
  }
  
  allWidgets.sort((a, b) => a.name.localeCompare(b.name));
  
  // 按首字母分组
  const grouped = {};
  for (const widget of allWidgets) {
    const letter = widget.name[0].toUpperCase();
    if (!grouped[letter]) {
      grouped[letter] = [];
    }
    grouped[letter].push(widget);
  }
  
  for (const [letter, widgets] of Object.entries(grouped).sort()) {
    content += `**${letter}**: `;
    content += widgets.map(w => `[${w.name}](./)`).join(' · ');
    content += '\n\n';
  }
  
  fs.writeFileSync(path.join(docsDir, 'index.md'), content);
  console.log('📄 生成主索引: widgets/index.md\n');
}

function countWidgets() {
  let count = 0;
  for (const category of Object.values(WIDGET_CATEGORIES)) {
    count += category.widgets.length;
  }
  return count;
}

// 运行
main().catch(console.error);
