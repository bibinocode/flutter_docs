# Flutter Photo Manager

Flutter 媒体资源管理插件，提供设备相册的抽象 API。

## 📋 项目概述

| 项目信息 | 详情 |
|---------|------|
| 🔗 GitHub | [fluttercandies/flutter_photo_manager](https://github.com/fluttercandies/flutter_photo_manager) |
| 📦 pub.dev | [photo_manager](https://pub.dev/packages/photo_manager) |
| ⭐ Stars | 600+ |
| 📅 最后更新 | 活跃维护中 |
| 📄 协议 | Apache 2.0 |
| 🎯 定位 | 跨平台媒体资源管理核心库 |

## 🛠️ 技术栈

### 支持平台

| 平台 | 支持 |
|------|------|
| Android | ✅ |
| iOS | ✅ |
| macOS | ✅ |
| OpenHarmony | ✅ |

### 技术特点

- **无 UI 集成** - 纯 API 抽象，不绑定任何 UI
- **Platform Channel** - 原生平台桥接
- **权限管理** - 统一的权限请求 API
- **资源操作** - 增删改查完整支持
- **缓存管理** - 智能的缩略图缓存

### 核心概念

```dart
// Asset (资源) - 单个图片/视频/音频
AssetEntity asset;

// Path (路径/相册) - 资源集合
AssetPathEntity path;

// Filter (过滤器) - 资源筛选条件
PMFilter filter;
```

## 📁 项目结构

```
lib/
├── photo_manager.dart        # 主入口
├── platform_utils.dart       # 平台工具
└── src/
    ├── filter/
    │   ├── base_filter.dart      # 过滤器基类
    │   └── path_filter.dart      # 路径过滤器
    ├── internal/
    │   ├── constants.dart        # 常量定义
    │   ├── editor.dart           # 资源编辑器
    │   ├── enums.dart            # 枚举定义
    │   ├── plugin.dart           # 平台插件
    │   └── progress_handler.dart # 进度处理
    ├── managers/
    │   ├── notify_manager.dart   # 通知管理器
    │   └── photo_manager.dart    # 主管理器
    ├── types/
    │   ├── cancel_token.dart     # 取消令牌
    │   ├── entity.dart           # 实体定义
    │   ├── thumbnail.dart        # 缩略图
    │   └── types.dart            # 类型定义
    └── utils/
        └── convert_utils.dart    # 转换工具

android/
└── src/main/kotlin/com/fluttercandies/photo_manager/
    ├── PhotoManagerPlugin.kt         # 插件入口
    ├── constant/
    │   ├── AssetType.kt              # 资源类型
    │   └── Methods.kt                # 方法常量
    ├── core/
    │   ├── PhotoManager.kt           # 核心管理
    │   ├── PhotoManagerPlugin.kt     # 方法处理
    │   ├── PhotoManagerDeleteManager.kt  # 删除管理
    │   ├── PhotoManagerWriteManager.kt   # 写入管理
    │   ├── PhotoManagerFavoriteManager.kt # 收藏管理
    │   ├── PhotoManagerNotifyChannel.kt  # 通知通道
    │   ├── entity/
    │   │   ├── AssetEntity.kt        # 资源实体
    │   │   ├── AssetPathEntity.kt    # 路径实体
    │   │   └── filter/
    │   │       └── FilterOption.kt   # 过滤选项
    │   └── utils/
    │       ├── ConvertUtils.kt       # 转换工具
    │       ├── DBUtils.kt            # 数据库工具
    │       ├── AndroidQDBUtils.kt    # Android Q+ 工具
    │       └── MediaStoreUtils.kt    # MediaStore 工具
    ├── permission/
    │   └── PermissionsUtils.kt       # 权限工具
    ├── thumb/
    │   └── ThumbnailUtil.kt          # 缩略图工具
    └── util/
        ├── LogUtils.kt               # 日志工具
        └── ResultHandler.kt          # 结果处理

darwin/photo_manager/Sources/photo_manager/
├── PMPlugin.m                # iOS/macOS 插件入口
├── PMNotificationManager.m   # 通知管理
├── PMProgressHandler.m       # 进度处理
├── PMConverter.m             # 转换器
├── PMResultHandler.m         # 结果处理
└── core/
    ├── PMManager.h/m         # 核心管理
    ├── PMAssetEntity.h/m     # 资源实体
    ├── PMAssetPathEntity.h/m # 路径实体
    ├── PMConvertUtils.h/m    # 转换工具
    └── PMFileHelper.h/m      # 文件助手
```

## 📝 学习要点

### 1. 统一的权限管理

```dart
/// 请求权限
final PermissionState ps = await PhotoManager.requestPermissionExtend();

/// 权限状态
enum PermissionState {
  /// Android: 无权限，iOS: PHAuthorizationStatusNotDetermined
  notDetermined,
  
  /// Android: 有权限，iOS: PHAuthorizationStatusAuthorized
  authorized,
  
  /// iOS 14+: PHAuthorizationStatusLimited
  limited,
  
  /// Android: 拒绝，iOS: PHAuthorizationStatusDenied
  denied,
  
  /// iOS: PHAuthorizationStatusRestricted
  restricted,
}

/// 检查权限并处理
if (!ps.hasAccess) {
  // 无权限，提示用户
  return;
}

if (ps == PermissionState.limited) {
  // iOS 限制访问，可能需要特殊处理
}

/// iOS 呈现有限访问 UI
await PhotoManager.presentLimited();
```

### 2. 获取相册列表

```dart
/// 获取所有相册
final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
  type: RequestType.all,      // 类型: all, image, video, audio
  hasAll: true,               // 是否包含 "所有照片" 相册
  onlyAll: false,             // 仅返回 "所有照片"
  filterOption: FilterOptionGroup(),
);

/// 遍历相册
for (final path in paths) {
  print('相册名: ${path.name}');
  print('资源数量: ${path.assetCount}');
  print('是否是全部: ${path.isAll}');
}

/// 过滤选项
final filter = FilterOptionGroup(
  imageOption: FilterOption(
    sizeConstraint: SizeConstraint(
      minWidth: 100,
      maxWidth: 10000,
      minHeight: 100,
      maxHeight: 10000,
      ignoreSize: false,
    ),
    needTitle: true,
  ),
  videoOption: FilterOption(
    durationConstraint: DurationConstraint(
      min: Duration.zero,
      max: Duration(minutes: 10),
    ),
  ),
  createTimeCond: DateTimeCond(
    min: DateTime(2020, 1, 1),
    max: DateTime.now(),
  ),
  orders: [
    OrderOption(type: OrderOptionType.createDate, asc: false),
  ],
);

final paths = await PhotoManager.getAssetPathList(
  filterOption: filter,
);
```

### 3. 获取资源列表

```dart
/// 分页获取资源
final List<AssetEntity> assets = await path.getAssetListPaged(
  page: 0,      // 页码，从 0 开始
  size: 50,     // 每页数量
);

/// 范围获取资源
final List<AssetEntity> assets = await path.getAssetListRange(
  start: 0,
  end: 100,
);

/// 获取全局资源列表（不通过相册）
final List<AssetEntity> assets = await PhotoManager.getAssetListPaged(
  page: 0,
  pageCount: 50,
  type: RequestType.image,
  filterOption: filter,
);
```

### 4. 资源实体操作

```dart
/// AssetEntity 属性
final AssetEntity asset;

asset.id;           // 资源 ID
asset.title;        // 标题
asset.type;         // 类型: image, video, audio
asset.width;        // 宽度
asset.height;       // 高度
asset.duration;     // 时长（视频/音频）
asset.createDateTime;   // 创建时间
asset.modifiedDateTime; // 修改时间
asset.mimeType;     // MIME 类型
asset.latitude;     // GPS 纬度
asset.longitude;    // GPS 经度

/// 获取文件
final File? file = await asset.file;              // 压缩版
final File? origin = await asset.originFile;      // 原始文件

/// 获取缩略图
final Uint8List? thumb = await asset.thumbnailData;

/// 自定义缩略图
final Uint8List? thumb = await asset.thumbnailDataWithSize(
  ThumbnailSize(200, 200),
  format: ThumbnailFormat.jpeg,
  quality: 90,
);

/// 检查是否本地可用（iCloud）
final bool isLocal = await asset.isLocallyAvailable();

/// Live Photo
if (asset.type == AssetType.image) {
  // 获取视频部分
  final File? videoFile = await asset.fileWithSubtype;
  final String? mediaUrl = await asset.getMediaUrl();
}
```

### 5. 保存媒体

```dart
/// 保存图片（从字节）
final AssetEntity? asset = await PhotoManager.editor.saveImage(
  imageBytes,
  title: 'my_image.jpg',
  desc: 'description',
  relativePath: 'Pictures/MyApp',  // 相对路径
);

/// 保存图片（从文件）
final AssetEntity? asset = await PhotoManager.editor.saveImageWithPath(
  '/path/to/image.jpg',
  title: 'my_image.jpg',
);

/// 保存视频
final AssetEntity? asset = await PhotoManager.editor.saveVideo(
  File('/path/to/video.mp4'),
  title: 'my_video.mp4',
);

/// iOS: 保存 Live Photo
final AssetEntity? asset = await PhotoManager.editor.darwin.saveLivePhoto(
  imageFile: imageFile,
  videoFile: videoFile,
  title: 'live_photo',
);
```

### 6. 删除资源

```dart
/// 删除资源（需要用户确认，Android 11+）
final List<String> result = await PhotoManager.editor.deleteWithIds(
  [asset.id],
);

/// 移动到回收站（Android 11+）
final List<String> result = await PhotoManager.editor.android.moveToTrash(
  [asset.id],
);
```

### 7. 变更监听

```dart
/// 添加变更回调
void _onChange(MethodCall call) {
  // call.method: 'change'
  // call.arguments: { 'type': 'insert'|'delete'|'update', ... }
  print('相册变更: ${call.arguments}');
  // 重新加载数据
  loadAssets();
}

PhotoManager.addChangeCallback(_onChange);
PhotoManager.startChangeNotify();

/// 停止监听
@override
void dispose() {
  PhotoManager.stopChangeNotify();
  PhotoManager.removeChangeCallback(_onChange);
  super.dispose();
}
```

### 8. 缓存管理

```dart
/// 清除缩略图缓存
await PhotoManager.clearFileCache();

/// 释放内存缓存
PhotoManager.releaseCache();

/// 设置日志
PhotoManager.setLog(true);
```

## ✨ 架构亮点

### 1. Platform Channel 设计

```kotlin
// Android 端方法常量定义
class Methods {
    companion object {
        // 无需权限的方法
        const val log = "log"
        const val openSetting = "openSetting"
        const val clearFileCache = "clearFileCache"
        
        fun isNotNeedPermissionMethod(method: String): Boolean {
            return method in arrayOf(log, openSetting, ...)
        }
        
        // 权限相关
        const val requestPermissionExtend = "requestPermissionExtend"
        const val presentLimited = "presentLimited"
        
        // 资源操作
        const val getAssetPathList = "getAssetPathList"
        const val getAssetListPaged = "getAssetListPaged"
        const val getAssetCount = "getAssetCount"
        
        // 编辑操作
        const val saveImage = "saveImage"
        const val saveVideo = "saveVideo"
        const val deleteWithIds = "deleteWithIds"
        // ...
    }
}
```

### 2. Android 版本适配

```kotlin
// 根据 Android 版本使用不同的数据库工具
private val dbUtils: IDBUtils
    get() {
        return if (useOldApi || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) 
            DBUtils 
        else 
            AndroidQDBUtils
    }

// Android 11+ 删除需要用户确认
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
    val uris = ids.map { photoManager.getUri(it) }
    deleteManager.deleteInApi30(uris, resultHandler)
} else if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
    deleteManager.deleteJustInApi29(idUriMap, resultHandler)
} else {
    deleteManager.deleteInApi28(ids)
}
```

### 3. iOS Photos Framework 封装

```objc
// PMManager.m
@implementation PMManager

- (void)getAssetPathList:(int)type 
                  hasAll:(BOOL)hasAll 
                 onlyAll:(BOOL)onlyAll 
           filterOption:(PMFilterOptionGroup *)option 
         pathFilterOption:(PMPathFilterOption *)pathFilterOption
                   block:(void(^)(NSArray<PMAssetPathEntity *> *))block {
    
    PHFetchOptions *options = [self getAssetFetchOptions:type filterOption:option];
    
    if (onlyAll) {
        // 只返回 "所有照片"
        PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
        PMAssetPathEntity *all = [PMAssetPathEntity entityWithId:PM_ALL_ID 
                                                            name:@"All Photos" 
                                                      assetCount:result.count];
        block(@[all]);
        return;
    }
    
    // 获取所有相册
    NSMutableArray *array = [NSMutableArray array];
    
    // Smart Albums
    PHFetchResult *smartAlbums = [PHAssetCollection 
        fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
        subtype:PHAssetCollectionSubtypeAny
        options:nil];
    
    // User Albums
    PHFetchResult *userAlbums = [PHAssetCollection 
        fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
        subtype:PHAssetCollectionSubtypeAny
        options:nil];
    
    // 处理结果...
    block(array);
}

@end
```

### 4. 进度处理（iCloud 下载）

```dart
/// PMProgressHandler - iCloud 下载进度
class PMProgressHandler {
  final _streamController = StreamController<PMProgressState>.broadcast();
  
  Stream<PMProgressState> get stream => _streamController.stream;
  
  void _onProgress(MethodCall call) {
    final progress = call.arguments['progress'] as double;
    final state = PMProgressState(progress: progress);
    _streamController.add(state);
  }
}

/// 使用示例
final handler = PMProgressHandler();
handler.stream.listen((state) {
  print('下载进度: ${state.progress * 100}%');
});

final file = await asset.loadFile(
  isOriginal: true,
  progressHandler: handler,
);
```

## 🚀 运行指南

### 安装

```yaml
dependencies:
  photo_manager: ^3.0.0
```

### 平台配置

#### iOS (Info.plist)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择照片和视频</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存照片到相册</string>
```

#### macOS (*.entitlements)
```xml
<key>com.apple.security.assets.pictures.read-write</key>
<true/>
<key>com.apple.security.assets.movies.read-write</key>
<true/>
<key>com.apple.security.assets.music.read-write</key>
<true/>
```

#### Android (AndroidManifest.xml)
```xml
<!-- 基础权限 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="29"/>

<!-- Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>

<!-- 可选: 访问媒体位置 -->
<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION"/>
```

### 基础使用

```dart
import 'package:photo_manager/photo_manager.dart';

// 请求权限
final PermissionState ps = await PhotoManager.requestPermissionExtend();
if (!ps.hasAccess) return;

// 获取相册
final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
  onlyAll: true,
);

if (paths.isEmpty) return;

// 获取资源
final AssetPathEntity path = paths.first;
final List<AssetEntity> assets = await path.getAssetListPaged(
  page: 0,
  size: 50,
);

// 显示缩略图
for (final asset in assets) {
  final thumb = await asset.thumbnailDataWithSize(
    ThumbnailSize(200, 200),
  );
  // 使用 Image.memory(thumb!) 显示
}
```

## 💡 配合使用

### 图片显示
```yaml
dependencies:
  photo_manager_image_provider: ^2.0.0
```

```dart
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

Image(
  image: AssetEntityImageProvider(
    asset,
    isOriginal: false,
    thumbnailSize: ThumbnailSize(200, 200),
  ),
)
```

### 相册选择器
```yaml
dependencies:
  wechat_assets_picker: ^9.0.0
```

### 相机选择器
```yaml
dependencies:
  wechat_camera_picker: ^4.0.0
```

## ⚠️ 注意事项

::: warning Android 版本差异
- Android 10 (API 29): Scoped Storage，但可以用 `requestLegacyExternalStorage`
- Android 11+ (API 30+): 强制 Scoped Storage，删除需要用户确认
- Android 13+ (API 33+): 细分媒体权限（图片/视频/音频）
:::

::: tip 性能优化
- 使用分页加载避免一次加载过多资源
- 缩略图比原图更适合列表显示
- 注意清理不需要的缓存
:::

::: info 与其他插件的关系
`photo_manager` 是 `wechat_assets_picker` 和 `wechat_camera_picker` 的基础依赖，
理解它有助于更好地使用上层插件。
:::
