# Flutter Widget 爬虫

从 Flutter 官方 API 文档爬取 Widget 信息，并使用 Deepseek API 翻译为中文。

## 安装依赖

```bash
cd scripts/widget_crawler
pip install -r requirements.txt
```

## 使用方法

### 爬取所有 Widget

```bash
python crawler.py
```

### 爬取指定分类

```bash
python crawler.py -c basics
python crawler.py -c layout
python crawler.py -c animation
```

### 爬取单个 Widget

```bash
python crawler.py -w Container
python crawler.py -w ListView
```

### 指定输出目录

```bash
python crawler.py -o ../docs/widgets
```

## Widget 分类

- `basics` - 基础组件
- `layout` - 布局组件
- `scrolling` - 滚动组件
- `buttons` - 按钮组件
- `input` - 输入组件
- `dialogs` - 对话框组件
- `navigation` - 导航组件
- `material` - Material 组件
- `cupertino` - Cupertino 组件
- `animation` - 动画组件
- `painting` - 绘制组件
- `async` - 异步组件
- `gesture` - 手势组件
- `accessibility` - 无障碍组件

## 输出格式

每个 Widget 生成一个 Markdown 文件，包含：

- 简介（已翻译为中文）
- 继承关系
- 构造函数
- 常用属性
- 官方文档链接
- 示例代码

## 配置

翻译 API 配置在 `crawler.py` 文件顶部：

```python
DEEPSEEK_API_URL = "https://yunwu.ai/v1/chat/completions"
DEEPSEEK_API_KEY = "your-api-key"
```

## 注意事项

1. 爬取速度较慢，每个 Widget 需要等待 0.5 秒以避免请求过快
2. 翻译 API 有调用限制，大量爬取时注意配额
3. 部分 Widget 可能找不到文档，会自动跳过
