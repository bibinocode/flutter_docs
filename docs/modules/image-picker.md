# 图片选择与相机

image_picker 是 Flutter 官方提供的图片/视频选择插件，支持从相册选择或使用相机拍摄。

## 安装

```yaml
dependencies:
  image_picker: ^1.2.1
```

```bash
flutter pub add image_picker
```

## 支持平台

| 平台 | 支持情况 | 备注 |
|------|----------|------|
| Android | ✅ SDK 24+ | Android 13+ 使用 Photo Picker |
| iOS | ✅ iOS 12+ | iOS 14+ 使用 PHPicker |
| macOS | ✅ 10.14+ | 基于 file_selector |
| Linux | ✅ | 基于 file_selector |
| Windows | ✅ 10+ | 基于 file_selector |
| Web | ✅ | 支持 |

---

## 平台配置

### iOS 配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<dict>
    <!-- 相册权限 -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>我们需要访问相册以选择图片</string>
    
    <!-- 相机权限 -->
    <key>NSCameraUsageDescription</key>
    <string>我们需要访问相机以拍摄照片</string>
    
    <!-- 麦克风权限（录制视频需要） -->
    <key>NSMicrophoneUsageDescription</key>
    <string>我们需要访问麦克风以录制视频</string>
</dict>
```

::: danger 重要
即使设置了 `requestFullMetadata: false`，App Store 政策仍要求必须包含 `NSPhotoLibraryUsageDescription`。
:::

### Android 配置

无需额外配置，插件已使用 Scoped Storage，不需要添加 `android:requestLegacyExternalStorage="true"`。

---

## 基本用法

### 选择单张图片

```dart
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  
  // 从相册选择图片
  Future<XFile?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    return image;
  }
  
  // 使用相机拍照
  Future<XFile?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
    );
    return photo;
  }
}
```

### 选择多张图片

```dart
// 选择多张图片
Future<List<XFile>> pickMultipleImages() async {
  final List<XFile> images = await _picker.pickMultiImage();
  return images;
}

// 带参数选择多张
Future<List<XFile>> pickMultipleImagesWithOptions() async {
  final List<XFile> images = await _picker.pickMultiImage(
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );
  return images;
}
```

### 选择视频

```dart
// 从相册选择视频
Future<XFile?> pickVideoFromGallery() async {
  final XFile? video = await _picker.pickVideo(
    source: ImageSource.gallery,
  );
  return video;
}

// 使用相机录制视频
Future<XFile?> recordVideo() async {
  final XFile? video = await _picker.pickVideo(
    source: ImageSource.camera,
    maxDuration: const Duration(minutes: 5), // 最长5分钟
  );
  return video;
}
```

### 选择媒体文件（图片或视频）

```dart
// 选择单个媒体（图片或视频）
Future<XFile?> pickMedia() async {
  final XFile? media = await _picker.pickMedia();
  return media;
}

// 选择多个媒体
Future<List<XFile>> pickMultipleMedia() async {
  final List<XFile> medias = await _picker.pickMultipleMedia();
  return medias;
}
```

---

## 图片参数配置

### pickImage 参数详解

```dart
Future<XFile?> pickImageWithOptions() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,     // 来源：gallery 相册 / camera 相机
    maxWidth: 1920,                  // 最大宽度（像素）
    maxHeight: 1080,                 // 最大高度（像素）
    imageQuality: 85,                // 图片质量 0-100
    preferredCameraDevice: CameraDevice.rear, // 首选摄像头：rear 后置 / front 前置
    requestFullMetadata: true,       // 是否请求完整元数据
  );
  return image;
}
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `source` | `ImageSource` | 图片来源（必填） |
| `maxWidth` | `double?` | 最大宽度，超过会缩放 |
| `maxHeight` | `double?` | 最大高度，超过会缩放 |
| `imageQuality` | `int?` | 质量 0-100，仅对 JPEG 有效 |
| `preferredCameraDevice` | `CameraDevice` | 首选摄像头 |
| `requestFullMetadata` | `bool` | 是否请求完整元数据（iOS） |

::: tip 提示
设置 `requestFullMetadata: false` 可以避免在 iOS 上请求相册权限（如果只需要图片数据）。
:::

---

## XFile 使用

`XFile` 是跨平台的文件抽象类：

```dart
Future<void> handlePickedImage(XFile? image) async {
  if (image == null) {
    print('用户取消选择');
    return;
  }
  
  // 获取文件路径
  final String path = image.path;
  print('文件路径: $path');
  
  // 获取文件名
  final String name = image.name;
  print('文件名: $name');
  
  // 获取 MIME 类型
  final String? mimeType = image.mimeType;
  print('MIME 类型: $mimeType');
  
  // 读取文件字节
  final Uint8List bytes = await image.readAsBytes();
  print('文件大小: ${bytes.length} bytes');
  
  // 转换为 File 对象
  final File file = File(image.path);
  
  // 获取文件长度
  final int length = await image.length();
  print('文件长度: $length');
}
```

### 显示选中的图片

```dart
import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final XFile image;
  
  const ImageDisplay({super.key, required this.image});
  
  @override
  Widget build(BuildContext context) {
    // 方式一：使用 File
    return Image.file(
      File(image.path),
      fit: BoxFit.cover,
    );
  }
}

// 方式二：使用 MemoryImage
class ImageFromBytes extends StatelessWidget {
  final XFile image;
  
  const ImageFromBytes({super.key, required this.image});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

---

## 处理 Android 内存回收

在 Android 上，当内存不足时，系统可能会销毁 Activity。使用 `retrieveLostData()` 恢复数据：

```dart
class ImagePickerPage extends StatefulWidget {
  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _images;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    // 启动时检查是否有丢失的数据
    _retrieveLostData();
  }
  
  Future<void> _retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    
    if (response.isEmpty) {
      return;
    }
    
    if (response.files != null) {
      // 恢复文件
      setState(() {
        _images = response.files;
      });
    } else if (response.exception != null) {
      // 处理错误
      setState(() {
        _error = response.exception!.message;
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _images = [image];
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

---

## 完整示例

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDemo extends StatefulWidget {
  const ImagePickerDemo({super.key});

  @override
  State<ImagePickerDemo> createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return;
    
    if (response.files != null) {
      setState(() {
        _selectedImages.addAll(response.files!);
      });
    }
  }

  // 选择图片来源
  Future<void> _showImageSourceDialog() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  // 选择单张图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showError('选择图片失败: $e');
    }
  }

  // 选择多张图片
  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      _showError('选择图片失败: $e');
    }
  }

  // 选择视频
  Future<void> _pickVideo() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('录制视频'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? video = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(minutes: 3),
        );
        
        if (video != null) {
          _showMessage('选择了视频: ${video.name}');
        }
      } catch (e) {
        _showError('选择视频失败: $e');
      }
    }
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 清空所有图片
  void _clearImages() {
    setState(() {
      _selectedImages.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片选择器'),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearImages,
            ),
        ],
      ),
      body: Column(
        children: [
          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('添加图片'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickMultipleImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('多选图片'),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('选择视频'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 图片网格
          Expanded(
            child: _selectedImages.isEmpty
                ? const Center(
                    child: Text(
                      '暂未选择图片',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return _ImageTile(
                        image: _selectedImages[index],
                        onRemove: () => _removeImage(index),
                      );
                    },
                  ),
          ),
          
          // 底部信息
          if (_selectedImages.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Text(
                '已选择 ${_selectedImages.length} 张图片',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(image.path),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 注意事项

### 临时文件

通过相机拍摄的图片/视频保存在应用的临时缓存目录，**不是永久存储**。如需永久保存，请手动移动到其他目录。

```dart
import 'package:path_provider/path_provider.dart';

Future<File> saveImagePermanently(XFile image) async {
  // 获取永久存储目录
  final directory = await getApplicationDocumentsDirectory();
  final String newPath = '${directory.path}/${image.name}';
  
  // 复制文件
  final File newFile = await File(image.path).copy(newPath);
  return newFile;
}
```

### 桌面端相机支持

桌面端（Windows、macOS、Linux）默认不支持 `ImageSource.camera`。需要自定义实现：

```dart
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class MyCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    // 自定义拍照实现
    return null;
  }

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    // 自定义录像实现
    return null;
  }
}

void setupCameraDelegate() {
  final instance = ImagePickerPlatform.instance;
  if (instance is CameraDelegatingImagePickerPlatform) {
    instance.cameraDelegate = MyCameraDelegate();
  }
}
```

### iOS 模拟器限制

iOS 14+ 模拟器上无法选择 HEIC 格式图片，这是 Apple 的已知问题。请使用真机测试或选择非 HEIC 图片。

## 相关资源

- [image_picker 官方文档](https://pub.dev/packages/image_picker)
- [image_picker_android](https://pub.dev/packages/image_picker_android) - Android Photo Picker 配置
