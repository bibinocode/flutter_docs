# Flutter 新闻爬虫

自动抓取 Flutter 官方博客、版本发布和热门包更新信息。

## 功能

- 📝 抓取 Flutter 官方博客 (Medium RSS)
- 🚀 获取 Flutter GitHub Releases
- 📦 监控 pub.dev 热门包更新

## 安装依赖

```bash
pip install -r requirements.txt
```

## 使用方法

### 基础使用

```bash
python news_crawler.py
```

### 指定输出路径

```bash
python news_crawler.py -o ../../docs/news/index.md -j ../../docs/news/data.json
```

### 跳过特定来源

```bash
# 只抓取版本发布
python news_crawler.py --no-blog --no-packages

# 只抓取博客
python news_crawler.py --no-releases --no-packages
```

## 定时任务配置

### macOS/Linux (cron)

```bash
# 每天早上8点执行
0 8 * * * cd /path/to/scripts/news_crawler && python news_crawler.py
```

### GitHub Actions

```yaml
name: Update Flutter News

on:
  schedule:
    - cron: '0 0 * * *'  # 每天 UTC 0点执行
  workflow_dispatch:

jobs:
  update-news:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          cd scripts/news_crawler
          pip install -r requirements.txt
      
      - name: Run crawler
        run: |
          cd scripts/news_crawler
          python news_crawler.py
      
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add docs/news/
          git diff --staged --quiet || git commit -m "Update Flutter news"
          git push
```

## 输出格式

### Markdown 文件

生成的 Markdown 文件包含：

- 版本发布列表（最新5个）
- 官方博客文章（最新8篇）
- 热门包更新（最近7天）
- 相关资源链接

### JSON 文件

```json
{
  "updated_at": "2024-01-01T12:00:00",
  "items": [
    {
      "title": "Flutter 3.19 发布",
      "url": "https://...",
      "date": "2024-01-01",
      "source": "GitHub Releases",
      "summary": "...",
      "category": "release"
    }
  ]
}
```

## 自定义

### 修改热门包列表

编辑 `news_crawler.py` 中的 `POPULAR_PACKAGES` 列表：

```python
POPULAR_PACKAGES = [
    "provider", "riverpod", "bloc", 
    # 添加你关注的包...
]
```

### 修改抓取数量

调整 `fetch_*` 函数中的数量限制：

```python
# 博客文章数量
for item in items[:10]:  # 修改这个数字

# 版本数量
params={"per_page": 10}  # 修改这个数字
```
