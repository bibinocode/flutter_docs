"""
Flutter Widget 爬虫 - 从 api.flutter.dev 爬取 Widget 信息并使用 Deepseek 翻译

功能：
1. 爬取 Flutter 官方文档中的 Widget 类列表
2. 获取每个 Widget 的描述、构造函数、属性等信息
3. 使用 Deepseek API 翻译为中文
4. 生成 Markdown 文档
"""

import os
import json
import time
import requests
from bs4 import BeautifulSoup
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Optional

# Deepseek API 配置
DEEPSEEK_API_URL = "https://yunwu.ai/v1/chat/completions"
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")

# Flutter API 文档基础 URL
FLUTTER_API_BASE = "https://api.flutter.dev/flutter"

# Widget 分类
WIDGET_CATEGORIES = {
    "basics": {
        "name": "基础组件",
        "widgets": ["Container", "Text", "Image", "Icon", "RichText", "SelectableText"]
    },
    "layout": {
        "name": "布局组件",
        "widgets": ["Row", "Column", "Stack", "Wrap", "Flex", "Expanded", "Flexible", "Spacer", "Center", "Align", "Padding", "ConstrainedBox", "SizedBox", "AspectRatio", "FractionallySizedBox"]
    },
    "scrolling": {
        "name": "滚动组件",
        "widgets": ["ListView", "GridView", "SingleChildScrollView", "CustomScrollView", "PageView", "NestedScrollView", "Scrollbar"]
    },
    "buttons": {
        "name": "按钮组件",
        "widgets": ["ElevatedButton", "FilledButton", "TextButton", "OutlinedButton", "IconButton", "FloatingActionButton", "DropdownButton", "PopupMenuButton"]
    },
    "input": {
        "name": "输入组件",
        "widgets": ["TextField", "TextFormField", "Checkbox", "Radio", "Switch", "Slider", "DropdownButtonFormField", "DatePicker", "TimePicker"]
    },
    "dialogs": {
        "name": "对话框组件",
        "widgets": ["AlertDialog", "SimpleDialog", "Dialog", "BottomSheet", "SnackBar", "Banner"]
    },
    "navigation": {
        "name": "导航组件",
        "widgets": ["Navigator", "AppBar", "BottomNavigationBar", "NavigationBar", "NavigationRail", "TabBar", "Drawer", "BottomAppBar"]
    },
    "material": {
        "name": "Material 组件",
        "widgets": ["Scaffold", "Card", "Chip", "ListTile", "Divider", "ExpansionTile", "DataTable", "ProgressIndicator", "CircularProgressIndicator", "LinearProgressIndicator"]
    },
    "cupertino": {
        "name": "Cupertino 组件",
        "widgets": ["CupertinoApp", "CupertinoButton", "CupertinoTextField", "CupertinoSwitch", "CupertinoActivityIndicator", "CupertinoAlertDialog", "CupertinoNavigationBar"]
    },
    "animation": {
        "name": "动画组件",
        "widgets": ["AnimatedContainer", "AnimatedOpacity", "AnimatedBuilder", "AnimatedPositioned", "AnimatedSwitcher", "Hero", "FadeTransition", "SlideTransition", "ScaleTransition", "RotationTransition"]
    },
    "painting": {
        "name": "绘制组件",
        "widgets": ["CustomPaint", "ClipRect", "ClipRRect", "ClipOval", "ClipPath", "DecoratedBox", "BackdropFilter", "Transform"]
    },
    "async": {
        "name": "异步组件",
        "widgets": ["FutureBuilder", "StreamBuilder", "RefreshIndicator"]
    },
    "gesture": {
        "name": "手势组件",
        "widgets": ["GestureDetector", "InkWell", "InkResponse", "Draggable", "LongPressDraggable", "DragTarget", "Dismissible"]
    },
    "accessibility": {
        "name": "无障碍组件",
        "widgets": ["Semantics", "MergeSemantics", "ExcludeSemantics"]
    }
}


def translate_text(text: str, is_code: bool = False) -> str:
    """使用 Deepseek API 翻译文本"""
    if not text or not text.strip():
        return text
    
    if is_code:
        return text  # 代码不翻译
    
    headers = {
        "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
        "Content-Type": "application/json"
    }
    
    prompt = f"""请将以下 Flutter 文档内容翻译为中文，保持专业术语的准确性：
    - 保留代码示例中的英文
    - 类名、方法名、属性名保持英文原样
    - 使用简洁专业的技术文档风格
    
原文：
{text}

中文翻译："""
    
    data = {
        "model": "deepseek-chat",
        "messages": [
            {"role": "system", "content": "你是一位专业的 Flutter/Dart 技术文档翻译专家。"},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.3,
        "max_tokens": 2000
    }
    
    try:
        response = requests.post(DEEPSEEK_API_URL, headers=headers, json=data, timeout=60)
        response.raise_for_status()
        result = response.json()
        translated = result["choices"][0]["message"]["content"].strip()
        return translated
    except Exception as e:
        print(f"翻译失败: {e}")
        return text


def fetch_widget_info(widget_name: str, library: str = "widgets") -> Optional[Dict]:
    """从 Flutter API 文档获取 Widget 信息"""
    url = f"{FLUTTER_API_BASE}/{library}/{widget_name}-class.html"
    
    try:
        print(f"正在获取: {widget_name}")
        response = requests.get(url, timeout=30)
        
        if response.status_code == 404:
            # 尝试其他库
            for lib in ["material", "cupertino", "painting", "rendering"]:
                if lib != library:
                    alt_url = f"{FLUTTER_API_BASE}/{lib}/{widget_name}-class.html"
                    response = requests.get(alt_url, timeout=30)
                    if response.status_code == 200:
                        library = lib
                        break
        
        if response.status_code != 200:
            print(f"  未找到: {widget_name}")
            return None
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # 获取描述
        desc_section = soup.find('section', {'class': 'desc'})
        description = ""
        if desc_section:
            paragraphs = desc_section.find_all('p')
            description = '\n\n'.join([p.get_text(strip=True) for p in paragraphs[:3]])
        
        # 获取继承关系
        inheritance = []
        inheritance_section = soup.find('dt', string='Inheritance')
        if inheritance_section:
            inheritance_content = inheritance_section.find_next_sibling('dd')
            if inheritance_content:
                links = inheritance_content.find_all('a')
                inheritance = [link.get_text(strip=True) for link in links]
        
        # 获取构造函数
        constructors = []
        constructors_section = soup.find('section', {'class': 'summary'})
        if constructors_section:
            constructor_list = constructors_section.find('dl', {'class': 'constructor-summary-list'})
            if constructor_list:
                items = constructor_list.find_all('dt')
                for item in items[:5]:
                    sig = item.get_text(strip=True)
                    constructors.append(sig)
        
        # 获取属性
        properties = []
        props_section = soup.find('section', {'id': 'instance-properties'})
        if props_section:
            prop_list = props_section.find_all('dt')
            for prop in prop_list[:10]:
                prop_name = prop.find('span', {'class': 'name'})
                if prop_name:
                    properties.append(prop_name.get_text(strip=True))
        
        return {
            "name": widget_name,
            "library": library,
            "url": url,
            "description": description,
            "inheritance": inheritance,
            "constructors": constructors,
            "properties": properties
        }
        
    except Exception as e:
        print(f"  获取失败: {widget_name} - {e}")
        return None


def generate_widget_markdown(widget_info: Dict, translated_desc: str) -> str:
    """生成 Widget 的 Markdown 文档"""
    md = f"""# {widget_info['name']}

<Badge type="info" text="{widget_info['library']}" />

## 简介

{translated_desc}

## 继承关系

```
{' → '.join(widget_info.get('inheritance', ['Object']))}
```

## 构造函数

"""
    
    for constructor in widget_info.get('constructors', []):
        md += f"```dart\n{constructor}\n```\n\n"
    
    if widget_info.get('properties'):
        md += "## 常用属性\n\n"
        md += "| 属性 | 说明 |\n"
        md += "|------|------|\n"
        for prop in widget_info['properties']:
            md += f"| `{prop}` | - |\n"
    
    md += f"""
## 官方文档

[Flutter API 文档]({widget_info['url']})

## 示例代码

```dart
// TODO: 添加示例代码
```
"""
    
    return md


def crawl_all_widgets(output_dir: str = "../docs/widgets"):
    """爬取所有 Widget 并生成文档"""
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    all_widgets = []
    
    for category_id, category_info in WIDGET_CATEGORIES.items():
        print(f"\n=== 处理分类: {category_info['name']} ===")
        
        category_dir = output_path / category_id
        category_dir.mkdir(exist_ok=True)
        
        category_widgets = []
        
        for widget_name in category_info['widgets']:
            widget_info = fetch_widget_info(widget_name)
            
            if widget_info:
                # 翻译描述
                translated_desc = translate_text(widget_info['description'])
                
                # 生成 Markdown
                md_content = generate_widget_markdown(widget_info, translated_desc)
                
                # 保存文件
                md_file = category_dir / f"{widget_name.lower()}.md"
                with open(md_file, 'w', encoding='utf-8') as f:
                    f.write(md_content)
                
                print(f"  ✅ {widget_name}")
                
                category_widgets.append({
                    "name": widget_name,
                    "file": f"{category_id}/{widget_name.lower()}.md"
                })
                
                # 避免请求过快
                time.sleep(0.5)
        
        all_widgets.append({
            "category_id": category_id,
            "category_name": category_info['name'],
            "widgets": category_widgets
        })
    
    # 保存索引文件
    index_file = output_path / "index.json"
    with open(index_file, 'w', encoding='utf-8') as f:
        json.dump(all_widgets, f, ensure_ascii=False, indent=2)
    
    # 生成目录页
    generate_widgets_index(output_path, all_widgets)
    
    print(f"\n完成! 共处理 {sum(len(cat['widgets']) for cat in all_widgets)} 个 Widget")


def generate_widgets_index(output_path: Path, all_widgets: List[Dict]):
    """生成 Widget 目录首页"""
    md = """# Flutter Widget 目录

Flutter 提供了丰富的 Widget 组件库，以下是按功能分类的 Widget 列表。

## Widget 分类

"""
    
    for category in all_widgets:
        md += f"### {category['category_name']}\n\n"
        md += "| Widget | 说明 |\n"
        md += "|--------|------|\n"
        for widget in category['widgets']:
            md += f"| [{widget['name']}](./{widget['file']}) | - |\n"
        md += "\n"
    
    md += """
## 如何使用

每个 Widget 文档包含：

- **简介**: Widget 的基本介绍和用途
- **继承关系**: Widget 的类继承链
- **构造函数**: 创建 Widget 的方式
- **常用属性**: 主要配置项说明
- **示例代码**: 实际使用示例

## 贡献

如果发现文档错误或想要补充内容，欢迎提交 PR。
"""
    
    index_file = output_path / "index.md"
    with open(index_file, 'w', encoding='utf-8') as f:
        f.write(md)


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Flutter Widget 爬虫")
    parser.add_argument("--output", "-o", default="../docs/widgets", help="输出目录")
    parser.add_argument("--category", "-c", help="只爬取指定分类")
    parser.add_argument("--widget", "-w", help="只爬取指定 Widget")
    
    args = parser.parse_args()
    
    if args.widget:
        # 爬取单个 Widget
        info = fetch_widget_info(args.widget)
        if info:
            translated = translate_text(info['description'])
            md = generate_widget_markdown(info, translated)
            print(md)
    elif args.category:
        # 爬取指定分类
        if args.category in WIDGET_CATEGORIES:
            print(f"爬取分类: {WIDGET_CATEGORIES[args.category]['name']}")
            for widget in WIDGET_CATEGORIES[args.category]['widgets']:
                info = fetch_widget_info(widget)
                if info:
                    print(f"✅ {widget}")
        else:
            print(f"未知分类: {args.category}")
            print(f"可用分类: {', '.join(WIDGET_CATEGORIES.keys())}")
    else:
        # 爬取所有
        crawl_all_widgets(args.output)
