# BottomSheet 底部面板

`BottomSheet` 是 Material Design 中的底部面板组件，从屏幕底部向上滑出，用于展示附加内容、操作选项或表单。它是移动端常用的交互模式，可以在不离开当前页面的情况下提供更多功能。

## showModalBottomSheet vs showBottomSheet

Flutter 提供两种显示底部面板的方式：

| 特性 | showModalBottomSheet | showBottomSheet |
|------|---------------------|-----------------|
| 类型 | 模态（Modal） | 持久（Persistent） |
| 背景遮罩 | 有半透明遮罩 | 无遮罩 |
| 点击外部 | 关闭面板 | 不关闭 |
| 返回值 | `Future<T?>` | `PersistentBottomSheetController` |
| 使用场景 | 临时操作、选择器 | 需要持续显示的内容 |
| 调用方式 | 任意位置调用 | 需要 `Scaffold` 的 `ScaffoldState` |

## 常用属性

### showModalBottomSheet 参数

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `context` | `BuildContext` | 必填 | 上下文 |
| `builder` | `WidgetBuilder` | 必填 | 构建底部面板内容 |
| `backgroundColor` | `Color?` | - | 背景颜色 |
| `elevation` | `double?` | - | 阴影高度 |
| `shape` | `ShapeBorder?` | - | 形状（常用于圆角） |
| `clipBehavior` | `Clip?` | - | 裁剪行为 |
| `barrierColor` | `Color?` | - | 遮罩颜色 |
| `isScrollControlled` | `bool` | `false` | 是否支持全屏滚动 |
| `isDismissible` | `bool` | `true` | 点击外部是否可关闭 |
| `enableDrag` | `bool` | `true` | 是否支持拖动关闭 |
| `showDragHandle` | `bool` | `false` | 是否显示拖动手柄 |
| `useSafeArea` | `bool` | `false` | 是否使用安全区域 |
| `constraints` | `BoxConstraints?` | - | 大小约束 |

### BottomSheet 组件属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `onClosing` | `VoidCallback` | 关闭时的回调 |
| `builder` | `WidgetBuilder` | 内容构建器 |
| `enableDrag` | `bool` | 是否允许拖动 |
| `onDragStart` | `BottomSheetDragStartHandler?` | 拖动开始回调 |
| `onDragEnd` | `BottomSheetDragEndHandler?` | 拖动结束回调 |
| `animationController` | `AnimationController?` | 动画控制器 |

## 使用场景代码示例

### 1. 模态底部面板

最常用的底部面板形式，显示临时操作或选项：

```dart
import 'package:flutter/material.dart';

class ModalBottomSheetDemo extends StatelessWidget {
  const ModalBottomSheetDemo({super.key});

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('分享'),
                onTap: () {
                  Navigator.pop(context, '分享');
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('复制链接'),
                onTap: () {
                  Navigator.pop(context, '复制链接');
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑'),
                onTap: () {
                  Navigator.pop(context, '编辑');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context, '删除');
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择了: $value')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模态底部面板')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showModalBottomSheet(context),
          child: const Text('显示底部面板'),
        ),
      ),
    );
  }
}
```

### 2. 持久底部面板

持久显示在屏幕底部，不会阻挡用户与页面其他部分的交互：

```dart
import 'package:flutter/material.dart';

class PersistentBottomSheetDemo extends StatefulWidget {
  const PersistentBottomSheetDemo({super.key});

  @override
  State<PersistentBottomSheetDemo> createState() =>
      _PersistentBottomSheetDemoState();
}

class _PersistentBottomSheetDemoState extends State<PersistentBottomSheetDemo> {
  PersistentBottomSheetController? _controller;
  bool _isSheetOpen = false;

  void _toggleBottomSheet() {
    if (_isSheetOpen) {
      _controller?.close();
    } else {
      _controller = showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '这是持久底部面板',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _controller?.close(),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      _controller?.closed.then((_) {
        if (mounted) {
          setState(() => _isSheetOpen = false);
        }
      });

      setState(() => _isSheetOpen = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('持久底部面板')),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleBottomSheet,
          child: Text(_isSheetOpen ? '关闭底部面板' : '显示底部面板'),
        ),
      ),
    );
  }
}
```

### 3. 可滚动内容

当内容较多时，设置 `isScrollControlled: true` 支持滚动：

```dart
import 'package:flutter/material.dart';

class ScrollableBottomSheetDemo extends StatelessWidget {
  const ScrollableBottomSheetDemo({super.key});

  void _showScrollableSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 关键：启用滚动控制
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,  // 初始高度为屏幕的 50%
          minChildSize: 0.25,     // 最小高度为屏幕的 25%
          maxChildSize: 0.9,      // 最大高度为屏幕的 90%
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ListView.builder(
                controller: scrollController,
                itemCount: 30,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('列表项 ${index + 1}'),
                    subtitle: Text('这是第 ${index + 1} 个项目的描述'),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('可滚动底部面板')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showScrollableSheet(context),
          child: const Text('显示可滚动面板'),
        ),
      ),
    );
  }
}
```

### 4. DraggableScrollableSheet 高级用法

支持拖动调整高度的可滚动面板：

```dart
import 'package:flutter/material.dart';

class DraggableSheetDemo extends StatelessWidget {
  const DraggableSheetDemo({super.key});

  void _showDraggableSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.95,
          snap: true, // 启用吸附效果
          snapSizes: const [0.4, 0.7, 0.95], // 吸附位置
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 拖动手柄
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 标题
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '拖动调整高度',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 内容列表
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 50,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.article),
                          title: Text('项目 ${index + 1}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DraggableScrollableSheet')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showDraggableSheet(context),
          child: const Text('显示可拖动面板'),
        ),
      ),
    );
  }
}
```

### 5. 带圆角的底部面板

自定义圆角和样式的底部面板：

```dart
import 'package:flutter/material.dart';

class StyledBottomSheetDemo extends StatelessWidget {
  const StyledBottomSheetDemo({super.key});

  void _showStyledSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true, // 显示系统拖动手柄
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                '选择主题',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeOption(context, '浅色模式', Icons.light_mode, Colors.orange),
              _buildThemeOption(context, '深色模式', Icons.dark_mode, Colors.indigo),
              _buildThemeOption(context, '跟随系统', Icons.settings_suggest, Colors.grey),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('带圆角的底部面板')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showStyledSheet(context),
          child: const Text('显示样式化面板'),
        ),
      ),
    );
  }
}
```

## 高度控制和自适应

### 固定高度

```dart
showModalBottomSheet(
  context: context,
  builder: (context) {
    return SizedBox(
      height: 300, // 固定高度
      child: const Center(child: Text('固定高度 300')),
    );
  },
);
```

### 自适应内容高度

```dart
showModalBottomSheet(
  context: context,
  builder: (context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 关键：自适应高度
      children: [
        ListTile(title: Text('选项 1')),
        ListTile(title: Text('选项 2')),
        ListTile(title: Text('选项 3')),
        SizedBox(height: MediaQuery.of(context).padding.bottom), // 安全区域
      ],
    );
  },
);
```

### 限制最大高度

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.8, // 最大 80% 屏幕高度
  ),
  builder: (context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 20,
      itemBuilder: (context, index) => ListTile(title: Text('项目 $index')),
    );
  },
);
```

### 带键盘的表单

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true, // 必须设为 true
  builder: (context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // 键盘高度适配
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '输入内容',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  },
);
```

## 最佳实践

### 1. 选择合适的类型

```dart
// ✅ 临时操作使用模态底部面板
void showOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) => OptionsSheet(),
  );
}

// ✅ 需要持续显示使用持久底部面板
void showPlayer() {
  showBottomSheet(
    context: context,
    builder: (context) => MusicPlayerSheet(),
  );
}
```

### 2. 提供明确的关闭方式

```dart
showModalBottomSheet(
  context: context,
  isDismissible: true, // 允许点击外部关闭
  enableDrag: true,    // 允许下拉关闭
  showDragHandle: true, // 显示拖动手柄，提示可拖动
  builder: (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 提供关闭按钮
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // 内容...
      ],
    );
  },
);
```

### 3. 处理返回值

```dart
Future<void> selectColor() async {
  final Color? selectedColor = await showModalBottomSheet<Color>(
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.red),
            title: const Text('红色'),
            onTap: () => Navigator.pop(context, Colors.red),
          ),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.blue),
            title: const Text('蓝色'),
            onTap: () => Navigator.pop(context, Colors.blue),
          ),
        ],
      );
    },
  );
  
  if (selectedColor != null) {
    // 处理选择的颜色
  }
}
```

### 4. 统一样式封装

```dart
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    showDragHandle: true,
    builder: builder,
  );
}
```

### 5. 避免过度使用

```dart
// ❌ 避免在底部面板中嵌套复杂导航
showModalBottomSheet(
  builder: (context) => Navigator(...), // 不推荐
);

// ✅ 复杂流程应该使用新页面
Navigator.push(context, MaterialPageRoute(builder: (_) => ComplexPage()));
```

### 6. 无障碍支持

```dart
showModalBottomSheet(
  context: context,
  builder: (context) {
    return Semantics(
      label: '选项菜单',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: '分享内容',
            child: ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享'),
              onTap: () {},
            ),
          ),
          // 更多选项...
        ],
      ),
    );
  },
);
```

## 相关组件

- [Scaffold](./scaffold.md) - 底部面板的容器
- [ModalBarrier](./modalbarrier.md) - 模态遮罩层
- [ListView](../scrolling/listview.md) - 可滚动列表
- [DraggableScrollableSheet](../scrolling/draggablescrollablesheet.md) - 可拖动滚动面板

## 官方文档

- [BottomSheet API](https://api.flutter.dev/flutter/material/BottomSheet-class.html)
- [showModalBottomSheet](https://api.flutter.dev/flutter/material/showModalBottomSheet.html)
- [showBottomSheet](https://api.flutter.dev/flutter/material/ScaffoldState/showBottomSheet.html)
- [DraggableScrollableSheet](https://api.flutter.dev/flutter/widgets/DraggableScrollableSheet-class.html)
- [Material Design Bottom Sheets](https://m3.material.io/components/bottom-sheets/overview)
