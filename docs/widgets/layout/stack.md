# Stack

`Stack` 是 Flutter 中用于**层叠布局**的组件，允许子组件相互重叠。类似于 CSS 中的 `position: relative`，子组件可以相对于 Stack 边缘进行定位，非常适合需要元素重叠的场景。

## 基本用法

```dart
Stack(
  children: [
    Container(width: 200, height: 200, color: Colors.red),   // 底层
    Container(width: 150, height: 150, color: Colors.green), // 中层
    Container(width: 100, height: 100, color: Colors.blue),  // 顶层
  ],
)
```

## 常用属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| alignment | AlignmentGeometry | AlignmentDirectional.topStart | 未定位子组件的对齐方式 |
| textDirection | TextDirection? | null | 文本方向，影响 alignment 解析 |
| fit | StackFit | StackFit.loose | 未定位子组件的尺寸约束 |
| clipBehavior | Clip | Clip.hardEdge | 超出边界的裁剪行为 |
| children | List\<Widget\> | - | 子组件列表，后面的在上层 |

## StackFit 尺寸策略

| 值 | 说明 |
|----|------|
| `loose` | 子组件可以小于 Stack（默认） |
| `expand` | 非定位子组件扩展填满 Stack |
| `passthrough` | 传递父组件约束 |

## Alignment 对齐方式

| 值 | 说明 |
|----|------|
| `topLeft` | 左上角 |
| `topCenter` | 顶部居中 |
| `topRight` | 右上角 |
| `centerLeft` | 左侧居中 |
| `center` | 居中（默认） |
| `centerRight` | 右侧居中 |
| `bottomLeft` | 左下角 |
| `bottomCenter` | 底部居中 |
| `bottomRight` | 右下角 |

## 使用场景

### 1. 基础层叠布局

```dart
Stack(
  alignment: Alignment.center,
  children: [
    // 背景圆
    Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    ),
    // 前景图标
    Icon(Icons.person, size: 80, color: Colors.white),
  ],
)
```

### 2. 使用 Positioned 精确定位

```dart
Stack(
  children: [
    // 全屏背景
    Container(color: Colors.grey[200]),
    
    // 左上角
    Positioned(
      top: 10,
      left: 10,
      child: Text('左上角'),
    ),
    
    // 右上角
    Positioned(
      top: 10,
      right: 10,
      child: Text('右上角'),
    ),
    
    // 左下角
    Positioned(
      bottom: 10,
      left: 10,
      child: Text('左下角'),
    ),
    
    // 右下角
    Positioned(
      bottom: 10,
      right: 10,
      child: Text('右下角'),
    ),
    
    // 居中（使用 alignment 或 Center）
    Center(child: Text('居中')),
  ],
)
```

### 3. Positioned.fill 填满区域

```dart
Stack(
  children: [
    // 填满整个 Stack
    Positioned.fill(
      child: Container(color: Colors.blue),
    ),
    
    // 填满但留边距
    Positioned.fill(
      top: 20,
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(color: Colors.white),
    ),
    
    // 居中内容
    Center(child: Text('内容')),
  ],
)
```

### 4. 图片叠加文字

```dart
Stack(
  children: [
    // 背景图片
    Image.network(
      'https://picsum.photos/400/300',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
    ),
    
    // 渐变遮罩
    Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
      ),
    ),
    
    // 底部文字
    Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '标题文字',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '副标题描述信息',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    ),
  ],
)
```

### 5. 头像角标

```dart
Stack(
  children: [
    // 头像
    CircleAvatar(
      radius: 40,
      backgroundImage: NetworkImage('https://picsum.photos/100'),
    ),
    
    // 在线状态角标
    Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    ),
  ],
)

// 带数字角标
Stack(
  clipBehavior: Clip.none, // 允许溢出
  children: [
    Icon(Icons.notifications, size: 32),
    Positioned(
      right: -8,
      top: -8,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          '3',
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    ),
  ],
)
```

### 6. 浮动操作按钮

```dart
Scaffold(
  body: Stack(
    children: [
      // 主内容
      ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
      ),
      
      // 浮动按钮
      Positioned(
        right: 16,
        bottom: 16,
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
      
      // 顶部渐变遮罩（可选）
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 100,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.transparent],
            ),
          ),
        ),
      ),
    ],
  ),
)
```

### 7. 加载遮罩

```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

// 使用
LoadingOverlay(
  isLoading: true,
  child: YourContent(),
)
```

### 8. 商品卡片（图片+折扣标签+收藏按钮）

```dart
class ProductCard extends StatefulWidget {
  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 主体内容
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品图片
              Image.network(
                'https://picsum.photos/300/200',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
              // 商品信息
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '精选商品名称',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '¥99',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '¥199',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 折扣标签（左上角）
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '5折',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 收藏按钮（右上角）
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => isFavorite = !isFavorite),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          
          // 新品标签（右侧）
          Positioned(
            bottom: 80,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                '新品',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 9. IndexedStack 切换视图

```dart
class TabExample extends StatefulWidget {
  @override
  _TabExampleState createState() => _TabExampleState();
}

class _TabExampleState extends State<TabExample> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 内容区域 - 保持所有页面状态
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              HomePage(),
              SearchPage(),
              ProfilePage(),
            ],
          ),
        ),
        
        // 底部导航
        BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
          ],
        ),
      ],
    );
  }
}
```

### 10. 层叠卡片效果

```dart
Stack(
  alignment: Alignment.center,
  children: [
    // 底层卡片
    Transform.translate(
      offset: Offset(0, 20),
      child: Transform.scale(
        scale: 0.9,
        child: Container(
          width: 280,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ),
    
    // 中层卡片
    Transform.translate(
      offset: Offset(0, 10),
      child: Transform.scale(
        scale: 0.95,
        child: Container(
          width: 280,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ),
    
    // 顶层卡片
    Container(
      width: 280,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(child: Text('顶层内容')),
    ),
  ],
)
```

## Stack vs IndexedStack

| 特性 | Stack | IndexedStack |
|------|-------|--------------|
| 显示 | 所有子组件 | 仅显示指定索引 |
| 状态保持 | - | 保持所有子组件状态 |
| 用途 | 层叠布局 | 页面切换 |
| 性能 | 渲染所有 | 构建所有，渲染一个 |

## 最佳实践

1. **合理使用 Positioned**: 需要精确位置时使用
2. **clipBehavior**: 子组件超出边界时设置裁剪行为
3. **层叠顺序**: 列表中靠后的组件显示在上层
4. **性能考虑**: 避免过多层叠，影响渲染性能
5. **使用 Align**: 简单对齐可用 Align 替代 Positioned
6. **IndexedStack**: 页面切换且需保持状态时使用

## 常见问题

::: warning 尺寸问题
Stack 的尺寸由非定位子组件决定。如果所有子组件都使用 Positioned，Stack 会尽可能小。解决方法：
1. 添加一个非定位的子组件设定尺寸
2. 使用 `Positioned.fill` 的子组件不影响尺寸
3. 将 Stack 放入有约束的父容器中
:::

## 相关组件

- [Positioned](./positioned.md) - Stack 子组件定位
- [IndexedStack](./indexedstack.md) - 只显示一个子组件的 Stack
- [Align](../basics/align.md) - 单个子组件对齐

## 官方文档

- [Stack API](https://api.flutter.dev/flutter/widgets/Stack-class.html)
- [Positioned API](https://api.flutter.dev/flutter/widgets/Positioned-class.html)
- [IndexedStack API](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html)
