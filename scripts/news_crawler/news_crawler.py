"""
Flutter 新闻爬虫 - 从 Flutter 官方博客和其他资源获取最新动态

功能：
1. 抓取 Flutter 官方博客 (通过 RSS)
2. 抓取 Flutter GitHub Releases
3. 抓取 pub.dev 热门包更新
4. 生成 Markdown 格式的新闻页面

使用方法：
    python news_crawler.py
    python news_crawler.py --output ../docs/news/latest.md
"""

import os
import json
import time
import requests
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass, asdict
from html import unescape
import re

# 配置
FLUTTER_BLOG_RSS = "https://medium.com/feed/flutter"
FLUTTER_RELEASES_API = "https://api.github.com/repos/flutter/flutter/releases"
PUB_DEV_API = "https://pub.dev/api/packages"

# Deepseek API 配置（用于翻译）
DEEPSEEK_API_URL = "https://yunwu.ai/v1/chat/completions"
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")

# 标题翻译映射（常用词汇）
TITLE_TRANSLATIONS = {
    # 常见开头
    "What's new in": "新特性：",
    "Announcing": "发布公告：",
    "Introducing": "介绍：",
    "Meet the": "认识",
    "Building": "构建",
    "The Top Ten Highlights from": "十大亮点：",
    
    # 常见短语
    "Rich and dynamic user interfaces with Flutter and generative UI": "使用 Flutter 和生成式 UI 构建丰富的动态用户界面",
    "Prompt engineering as infrastructure": "作为基础设施的提示工程",
    "Flutter developer's thoughts": "Flutter 开发者的思考",
    "Flutter Extension for Gemini CLI": "Gemini CLI 的 Flutter 扩展",
    "Building the future of apps": "构建应用的未来",
    "Jaime's build context:": "Jaime 的构建日记：",
    "A Flutter developer's thoughts about Antigravity": "一位 Flutter 开发者对 Antigravity 的思考",
    
    # 单词翻译
    "Tips": "技巧",
    " in ": "中的",
    " and ": "和",
    " with ": "与",
    " for ": "的",
    " from ": "来自",
    " the ": "",
    
    # 版本发布
    "beta": "测试版",
    "stable": "稳定版",
    "(预发布)": "（预发布）",
}

# 热门包列表
POPULAR_PACKAGES = [
    "provider", "riverpod", "bloc", "get", "dio",
    "flutter_hooks", "go_router", "freezed", "json_serializable",
    "hive", "drift", "firebase_core", "firebase_auth",
    "flutter_localizations", "intl", "cached_network_image",
    "flutter_svg", "shimmer", "animations", "flutter_animate"
]


@dataclass
class NewsItem:
    """新闻条目"""
    title: str
    url: str
    date: str
    source: str
    summary: str = ""
    category: str = "general"
    

def clean_html(html_text: str) -> str:
    """清理 HTML 标签"""
    # 移除 HTML 标签
    clean = re.sub(r'<[^>]+>', '', html_text)
    # 处理 HTML 实体
    clean = unescape(clean)
    # 移除多余空白
    clean = re.sub(r'\s+', ' ', clean).strip()
    return clean


def translate_title(title: str) -> str:
    """翻译新闻标题为中文"""
    # 检查是否已经是中文
    chinese_chars = sum(1 for c in title if '\u4e00' <= c <= '\u9fff')
    if chinese_chars > len(title) * 0.3:  # 超过30%是中文字符
        return title
    
    # 使用 API 翻译
    try:
        headers = {
            "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
            "Content-Type": "application/json"
        }
        
        prompt = f"""请将以下 Flutter 技术新闻标题翻译为简洁的中文：

标题：{title}

要求：
1. 翻译要简洁明了、通顺自然
2. 保留版本号如 3.38、3.35 等
3. 保留专有名词如 Flutter、Dart、Gemini、CLI、Impeller、Firebase 等
4. 人名保留英文（如 Jaime）
5. 只返回翻译结果，不要其他内容

中文标题："""
        
        data = {
            "model": "deepseek-chat",
            "messages": [
                {"role": "system", "content": "你是一位专业的 Flutter/Dart 技术翻译。"},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.1,
            "max_tokens": 100
        }
        
        response = requests.post(
            DEEPSEEK_API_URL, 
            headers=headers, 
            json=data, 
            timeout=30
        )
        response.raise_for_status()
        result = response.json()
        translated = result["choices"][0]["message"]["content"].strip()
        # 移除可能的引号
        translated = translated.strip('"\'')
        print(f"    翻译: {title[:40]}... → {translated}")
        time.sleep(0.3)  # 避免请求过快
        return translated
    except Exception as e:
        print(f"    翻译失败: {e}")
        # 回退到简单映射替换
        translated = title
        for en, zh in TITLE_TRANSLATIONS.items():
            translated = translated.replace(en, zh)
        return translated


def fetch_flutter_blog() -> List[NewsItem]:
    """获取 Flutter 官方博客文章"""
    news = []
    
    try:
        print("正在获取 Flutter 博客...")
        headers = {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
        }
        response = requests.get(FLUTTER_BLOG_RSS, headers=headers, timeout=30)
        response.raise_for_status()
        
        # 解析 RSS
        root = ET.fromstring(response.content)
        channel = root.find('channel')
        
        if channel is None:
            print("  无法解析 RSS")
            return news
        
        items = channel.findall('item')
        print(f"  找到 {len(items)} 篇文章")
        
        for item in items[:10]:  # 只取最近10篇
            title_elem = item.find('title')
            link_elem = item.find('link')
            pub_date_elem = item.find('pubDate')
            description_elem = item.find('description')
            
            if title_elem is None or link_elem is None:
                continue
                
            title = clean_html(title_elem.text or "")
            # 翻译标题
            translated_title = translate_title(title)
            url = link_elem.text or ""
            
            # 解析日期
            date_str = ""
            if pub_date_elem is not None and pub_date_elem.text:
                try:
                    # RSS 日期格式: Wed, 15 May 2024 12:00:00 GMT
                    dt = datetime.strptime(
                        pub_date_elem.text.strip()[:25], 
                        "%a, %d %b %Y %H:%M:%S"
                    )
                    date_str = dt.strftime("%Y-%m-%d")
                except:
                    date_str = datetime.now().strftime("%Y-%m-%d")
            
            # 获取摘要
            summary = ""
            if description_elem is not None and description_elem.text:
                summary = clean_html(description_elem.text)[:200] + "..."
            
            news.append(NewsItem(
                title=translated_title,
                url=url,
                date=date_str,
                source="Flutter Blog",
                summary=summary,
                category="blog"
            ))
        
        print(f"  ✅ 获取到 {len(news)} 条博客文章")
        
    except Exception as e:
        print(f"  ❌ 获取博客失败: {e}")
    
    return news


def fetch_flutter_releases() -> List[NewsItem]:
    """获取 Flutter 版本发布信息"""
    news = []
    
    try:
        print("正在获取 Flutter Releases...")
        headers = {
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "Flutter-News-Crawler"
        }
        response = requests.get(
            FLUTTER_RELEASES_API,
            headers=headers,
            params={"per_page": 10},
            timeout=30
        )
        response.raise_for_status()
        
        releases = response.json()
        print(f"  找到 {len(releases)} 个版本")
        
        for release in releases:
            tag_name = release.get("tag_name", "")
            name = release.get("name", tag_name)
            url = release.get("html_url", "")
            published_at = release.get("published_at", "")
            body = release.get("body", "")
            prerelease = release.get("prerelease", False)
            
            # 解析日期
            date_str = ""
            if published_at:
                try:
                    dt = datetime.fromisoformat(published_at.replace("Z", "+00:00"))
                    date_str = dt.strftime("%Y-%m-%d")
                except:
                    date_str = datetime.now().strftime("%Y-%m-%d")
            
            # 标题（翻译版本名称中的月份等）
            if prerelease:
                title = f"Flutter {name}（预发布版）"
            else:
                title = f"Flutter {name}"
            # 翻译标题中的日期格式
            title = title.replace("January", "1月").replace("February", "2月")
            title = title.replace("March", "3月").replace("April", "4月")
            title = title.replace("May", "5月").replace("June", "6月")
            title = title.replace("July", "7月").replace("August", "8月")
            title = title.replace("September", "9月").replace("October", "10月")
            title = title.replace("November", "11月").replace("December", "12月")
            title = title.replace("beta", "测试版").replace("stable", "稳定版")
            
            # 摘要
            summary = clean_html(body)[:200] + "..." if body else "查看发布说明了解详情"
            
            news.append(NewsItem(
                title=title,
                url=url,
                date=date_str,
                source="GitHub Releases",
                summary=summary,
                category="release"
            ))
        
        print(f"  ✅ 获取到 {len(news)} 个版本")
        
    except Exception as e:
        print(f"  ❌ 获取发布信息失败: {e}")
    
    return news


def fetch_package_updates() -> List[NewsItem]:
    """获取热门包更新信息"""
    news = []
    
    print("正在获取热门包更新...")
    
    for package_name in POPULAR_PACKAGES[:10]:
        try:
            response = requests.get(
                f"{PUB_DEV_API}/{package_name}",
                timeout=10
            )
            
            if response.status_code != 200:
                continue
                
            data = response.json()
            latest = data.get("latest", {})
            
            version = latest.get("version", "")
            published = latest.get("published", "")
            pubspec = latest.get("pubspec", {})
            description = pubspec.get("description", "")
            
            # 检查是否是最近7天内更新
            if published:
                try:
                    dt = datetime.fromisoformat(published.replace("Z", "+00:00"))
                    if datetime.now(dt.tzinfo) - dt > timedelta(days=7):
                        continue
                    date_str = dt.strftime("%Y-%m-%d")
                except:
                    continue
            else:
                continue
            
            news.append(NewsItem(
                title=f"{package_name} {version} 发布",
                url=f"https://pub.dev/packages/{package_name}",
                date=date_str,
                source="pub.dev",
                summary=description[:150] + "..." if len(description) > 150 else description,
                category="package"
            ))
            
            # 避免请求过快
            time.sleep(0.2)
            
        except Exception as e:
            print(f"  获取 {package_name} 失败: {e}")
    
    print(f"  ✅ 获取到 {len(news)} 个包更新")
    return news


def generate_markdown(news_items: List[NewsItem], output_path: str):
    """生成 Markdown 格式的新闻页面"""
    
    # 按日期排序
    news_items.sort(key=lambda x: x.date, reverse=True)
    
    # 按分类分组
    releases = [n for n in news_items if n.category == "release"]
    blogs = [n for n in news_items if n.category == "blog"]
    packages = [n for n in news_items if n.category == "package"]
    
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    
    md = f"""---
title: Flutter 最新动态
description: Flutter 官方博客、版本发布和热门包更新
---

# Flutter 最新动态

> 📅 最后更新: {now}

本页面自动抓取 Flutter 官方博客、GitHub Releases 和 pub.dev 热门包更新，帮助您及时了解 Flutter 生态的最新动态。

## 🚀 版本发布

"""
    
    if releases:
        for item in releases[:5]:
            md += f"""### [{item.title}]({item.url})

<Badge type="info" text="{item.date}" /> <Badge type="tip" text="{item.source}" />

{item.summary}

---

"""
    else:
        md += "*暂无最新版本信息*\n\n"
    
    md += """## 📝 官方博客

"""
    
    if blogs:
        for item in blogs[:8]:
            md += f"""### [{item.title}]({item.url})

<Badge type="info" text="{item.date}" />

{item.summary}

---

"""
    else:
        md += "*暂无最新博客文章*\n\n"
    
    md += """## 📦 热门包更新

最近7天内更新的热门 Flutter 包：

| 包名 | 说明 | 更新日期 |
|------|------|----------|
"""
    
    if packages:
        for item in packages:
            title = item.title.replace("|", "\\|")
            summary = item.summary[:50].replace("|", "\\|") + "..."
            md += f"| [{title}]({item.url}) | {summary} | {item.date} |\n"
    else:
        md += "| *暂无更新* | - | - |\n"
    
    md += """

## 📚 更多资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Flutter GitHub](https://github.com/flutter/flutter)
- [pub.dev](https://pub.dev/)
- [Flutter 社区](https://flutter.dev/community)

## 🔔 订阅更新

- 关注 [Flutter 官方 Twitter](https://twitter.com/flutterdev)
- 订阅 [Flutter YouTube 频道](https://www.youtube.com/flutterdev)
- 加入 [Flutter Discord](https://discord.gg/N7Yshp4)

---

<small>本页面内容自动生成，如有遗漏请访问官方渠道获取最新信息。</small>
"""
    
    # 写入文件
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(md)
    
    print(f"\n✅ 新闻页面已生成: {output_path}")


def save_json(news_items: List[NewsItem], output_path: str):
    """保存为 JSON 格式"""
    data = {
        "updated_at": datetime.now().isoformat(),
        "items": [asdict(item) for item in news_items]
    }
    
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ JSON 数据已保存: {output_path}")


def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Flutter 新闻爬虫")
    parser.add_argument(
        "--output", "-o",
        default="../../docs/news/index.md",
        help="输出 Markdown 文件路径"
    )
    parser.add_argument(
        "--json", "-j",
        default="../../docs/news/data.json",
        help="输出 JSON 文件路径"
    )
    parser.add_argument(
        "--no-blog",
        action="store_true",
        help="跳过博客抓取"
    )
    parser.add_argument(
        "--no-releases",
        action="store_true",
        help="跳过版本抓取"
    )
    parser.add_argument(
        "--no-packages",
        action="store_true",
        help="跳过包更新抓取"
    )
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("Flutter 新闻爬虫")
    print("=" * 50)
    
    all_news: List[NewsItem] = []
    
    # 获取各类新闻
    if not args.no_blog:
        all_news.extend(fetch_flutter_blog())
    
    if not args.no_releases:
        all_news.extend(fetch_flutter_releases())
    
    if not args.no_packages:
        all_news.extend(fetch_package_updates())
    
    if not all_news:
        print("\n⚠️ 未获取到任何新闻")
        return
    
    print(f"\n总计获取 {len(all_news)} 条新闻")
    
    # 生成输出
    generate_markdown(all_news, args.output)
    save_json(all_news, args.json)
    
    print("\n完成!")


if __name__ == "__main__":
    main()
