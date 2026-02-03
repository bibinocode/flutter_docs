# FlutterCandies - Flutter 糖果社区

## 组织概览

| 组织信息 | 详情 |
|---------|------|
| **GitHub** | [FlutterCandies](https://github.com/fluttercandies) |
| **Star** | 累计 10k+ |
| **包数量** | 88+ 个实用包 |
| **成立时间** | 2019年2月14日 |
| **主要贡献** | 高质量 Flutter 插件和库 |

## 组织简介

FlutterCandies (糖果社区) 是一个由热爱 Flutter 的开发者组成的社区，致力于创建和维护高质量的 Flutter 插件和库。社区的愿景是"赋能每一位开发者，共同构建一个健康、强大、安全的 Flutter 生态系统"。

## 明星项目

### 1. extended_image ⭐ 2k+

强大的图片扩展库，支持加载状态、缓存、缩放、裁剪等功能。

```yaml
dependencies:
  extended_image: ^8.2.0
```

**主要特性：**
- 占位符和加载失败状态
- 网络图片缓存
- 图片缩放和平移
- 照片查看器
- 滑动退出页面
- 图片编辑（裁剪、旋转、翻转）

```dart
// 网络图片加载
ExtendedImage.network(
  imageUrl,
  fit: BoxFit.contain,
  cache: true,
  loadStateChanged: (ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        return const CircularProgressIndicator();
      case LoadState.completed:
        return null; // 使用默认图片
      case LoadState.failed:
        return const Icon(Icons.error);
    }
  },
)

// 图片缩放
ExtendedImage.network(
  imageUrl,
  mode: ExtendedImageMode.gesture,
  initGestureConfigHandler: (state) {
    return GestureConfig(
      minScale: 0.9,
      maxScale: 3.0,
      speed: 1.0,
      inertialSpeed: 100.0,
    );
  },
)

// 图片编辑
ExtendedImage.file(
  File(imagePath),
  mode: ExtendedImageMode.editor,
  fit: BoxFit.contain,
  extendedImageEditorKey: editorKey,
  initEditorConfigHandler: (state) {
    return EditorConfig(
      maxScale: 8.0,
      cropRectPadding: const EdgeInsets.all(20.0),
      cropAspectRatio: CropAspectRatios.ratio4_3,
    );
  },
)
```

### 2. flutter_wechat_assets_picker ⭐ 1.6k+

基于微信 UI 的图片/视频/音频选择器。

```yaml
dependencies:
  wechat_assets_picker: ^9.0.0
```

**主要特性：**
- 微信风格 UI
- 图片/视频/音频选择
- 多选支持
- 自定义主题
- 国际化支持

```dart
// 基础用法
final List<AssetEntity>? result = await AssetPicker.pickAssets(
  context,
  pickerConfig: const AssetPickerConfig(
    maxAssets: 9,
    requestType: RequestType.image,
  ),
);

// 自定义配置
final List<AssetEntity>? result = await AssetPicker.pickAssets(
  context,
  pickerConfig: AssetPickerConfig(
    maxAssets: 5,
    requestType: RequestType.common, // 图片和视频
    selectedAssets: selectedAssets,
    themeColor: Colors.blue,
    textDelegate: const AssetPickerTextDelegate(), // 自定义文案
    filterOptions: FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(
          maxWidth: 4096,
          maxHeight: 4096,
        ),
      ),
    ),
  ),
);

// 相机拍照
final AssetEntity? result = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: const CameraPickerConfig(
    enableRecording: true, // 允许录像
    maximumRecordingDuration: Duration(seconds: 30),
  ),
);
```

### 3. flutter_photo_manager ⭐ 751

图片/视频/音频管理 API，不依赖界面。

```yaml
dependencies:
  photo_manager: ^3.0.0
```

**主要特性：**
- 跨平台支持 (Android, iOS, macOS, OpenHarmony)
- 访问系统相册
- 文件 CRUD 操作
- 权限管理

```dart
// 请求权限
final PermissionState ps = await PhotoManager.requestPermissionExtend();
if (!ps.hasAccess) {
  // 没有权限
  return;
}

// 获取相册列表
final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
  type: RequestType.image,
);

// 获取照片
final List<AssetEntity> assets = await paths[0].getAssetListPaged(
  page: 0,
  size: 50,
);

// 获取文件
final File? file = await assets[0].file;

// 保存图片到相册
final AssetEntity? result = await PhotoManager.editor.saveImageWithPath(
  imagePath,
  title: 'my_image.jpg',
);
```

### 4. flutter_smart_dialog ⭐ 1.2k+

优雅的 Flutter Dialog 解决方案。

```yaml
dependencies:
  flutter_smart_dialog: ^4.9.5
```

**主要特性：**
- 无需 context
- Loading 弹窗
- Toast 提示
- 自定义弹窗
- 穿透点击

```dart
// 初始化
MaterialApp(
  builder: FlutterSmartDialog.init(),
)

// Toast
SmartDialog.showToast('This is a toast');

// Loading
SmartDialog.showLoading(msg: '加载中...');
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();

// 确认对话框
SmartDialog.show(
  builder: (context) {
    return Container(
      height: 200,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('确认删除吗？'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => SmartDialog.dismiss(),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 执行删除
                  SmartDialog.dismiss();
                },
                child: Text('确认'),
              ),
            ],
          ),
        ],
      ),
    );
  },
);

// 附着在某个 widget
SmartDialog.showAttach(
  targetContext: buttonContext,
  alignment: Alignment.bottomCenter,
  builder: (_) => Container(
    padding: EdgeInsets.all(10),
    color: Colors.white,
    child: Text('这是一个提示'),
  ),
);
```

### 5. flutter_scrollview_observer ⭐ 596

ScrollView 子组件观察器，用于检测可见元素。

```yaml
dependencies:
  scrollview_observer: ^1.19.0
```

**主要特性：**
- 监听可见元素
- 滚动到指定位置
- 聊天定位
- 视频自动播放

```dart
// 监听可见元素
ListViewObserver(
  child: ListView.builder(
    controller: scrollController,
    itemCount: 100,
    itemBuilder: (context, index) {
      return ListTile(title: Text('Item $index'));
    },
  ),
  onObserve: (resultModel) {
    // 获取当前显示的第一个和最后一个 item
    print('First: ${resultModel.firstChild?.index}');
    print('Last: ${resultModel.displayingChildModelList.last.index}');
  },
)

// 滚动到指定位置
final observerController = ListObserverController(controller: scrollController);

// 滚动到 index 50
observerController.animateTo(
  index: 50,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// 聊天场景 - 定位到未读消息
ChatScrollObserver(
  child: ListView.builder(...),
  onObserve: (resultModel) {
    // 处理未读消息定位
  },
)
```

### 6. waterfall_flow ⭐ 490

瀑布流布局组件。

```yaml
dependencies:
  waterfall_flow: ^3.0.3
```

```dart
WaterfallFlow.builder(
  gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Container(
      // 随机高度模拟瀑布流
      height: (index % 3 + 1) * 100.0,
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('$index')),
    );
  },
)
```

### 7. flutter_drawing_board ⭐ 235

Flutter 画板组件。

```yaml
dependencies:
  flutter_drawing_board: ^0.0.16
```

```dart
DrawingBoard(
  background: Container(color: Colors.white),
  showDefaultActions: true,
  showDefaultTools: true,
  onPointerDown: (details) {
    // 触摸开始
  },
  onPointerMove: (details) {
    // 触摸移动
  },
  onPointerUp: (details) {
    // 触摸结束
  },
)
```

## 其他实用包

| 包名 | Star | 功能描述 |
|-----|------|---------|
| [loading_more_list](https://github.com/fluttercandies/loading_more_list) | 200+ | 加载更多列表 |
| [extended_text](https://github.com/fluttercandies/extended_text) | 300+ | 扩展文本组件 |
| [extended_nested_scroll_view](https://github.com/fluttercandies/extended_nested_scroll_view) | 400+ | 扩展嵌套滚动视图 |
| [flutter_tilt](https://github.com/fluttercandies/flutter_tilt) | 100+ | 倾斜效果组件 |
| [ff_annotation_route](https://github.com/fluttercandies/ff_annotation_route) | 200+ | 路由注解生成 |
| [flutter-interactive-chart](https://github.com/fluttercandies/flutter-interactive-chart) | 262 | K线图表组件 |
| [fjs](https://github.com/fluttercandies/fjs) | 76 | Rust 驱动的 JS 运行时 |
| [like_button](https://github.com/fluttercandies/like_button) | 500+ | 点赞按钮组件 |

## 学习要点

### 1. 高质量开源项目特点

```dart
// 1. 完善的文档
/// A widget that provides image loading with placeholder and error handling.
/// 
/// Example:
/// ```dart
/// ExtendedImage.network(url)
/// ```
class ExtendedImage extends StatefulWidget { }

// 2. 良好的 API 设计
// 简单使用
ExtendedImage.network(url);

// 高级配置
ExtendedImage.network(
  url,
  cache: true,
  fit: BoxFit.cover,
  // ... 更多配置
);

// 3. 完善的错误处理
loadStateChanged: (state) {
  switch (state.extendedImageLoadState) {
    case LoadState.loading: return loading();
    case LoadState.completed: return null;
    case LoadState.failed: return error();
  }
}

// 4. 类型安全
class AssetPickerConfig {
  final int maxAssets;
  final RequestType requestType;
  final List<AssetEntity>? selectedAssets;
  // 使用 const 构造函数
  const AssetPickerConfig({
    this.maxAssets = 9,
    this.requestType = RequestType.common,
    this.selectedAssets,
  });
}
```

### 2. 插件开发最佳实践

```dart
// 平台通道设计
class PhotoManager {
  static const MethodChannel _channel = MethodChannel('photo_manager');
  
  static Future<PermissionState> requestPermissionExtend() async {
    final result = await _channel.invokeMethod<int>('requestPermission');
    return PermissionState.values[result!];
  }
}

// iOS (Swift)
public class PhotoManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "photo_manager",
      binaryMessenger: registrar.messenger()
    )
    let instance = PhotoManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestPermission":
      PHPhotoLibrary.requestAuthorization { status in
        result(status.rawValue)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
```

### 3. 组件封装技巧

```dart
// 配置类分离
class GestureConfig {
  final double minScale;
  final double maxScale;
  final double speed;
  
  const GestureConfig({
    this.minScale = 0.8,
    this.maxScale = 5.0,
    this.speed = 1.0,
  });
}

// Builder 模式
initGestureConfigHandler: (state) => GestureConfig(
  minScale: 0.9,
  maxScale: 3.0,
),

// 状态回调
loadStateChanged: (ExtendedImageState state) {
  // 根据状态返回不同 Widget
},
```

## 适合学习

- Flutter 插件开发
- 平台通道使用
- 图片处理技术
- 相册权限管理
- 高质量开源项目维护

## 如何参与

```bash
# 1. Fork 项目
# 2. 克隆到本地
git clone https://github.com/your-username/extended_image.git

# 3. 创建分支
git checkout -b feature/my-feature

# 4. 提交修改
git commit -m "feat: add new feature"

# 5. 推送并创建 PR
git push origin feature/my-feature
```

::: tip 社区资源
- **官网**: [fluttercandies.com](http://fluttercandies.com)
- **QQ群**: 加入 Flutter Candies 技术交流群
- **Pub**: 搜索 fluttercandies 查看所有包
:::

::: warning 注意事项
1. 使用前查看各包的最低 Flutter 版本要求
2. 部分包需要配置平台权限
3. 建议使用最新稳定版本
:::
