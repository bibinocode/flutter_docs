# 图片压缩

flutter_image_compress 是一个高性能的图片压缩插件，使用原生代码（Kotlin/ObjC）实现，比纯 Dart 实现更高效。

## 安装

```yaml
dependencies:
  flutter_image_compress: ^2.4.0
```

```bash
flutter pub add flutter_image_compress
```

## 支持平台

| 平台 | 支持情况 |
|------|----------|
| Android | ✅ |
| iOS | ✅ |
| macOS | ✅ (10.15+) |
| Web | ✅ |

---

## 平台功能对比

| 功能 | Android | iOS | macOS | Web |
|------|---------|-----|-------|-----|
| `compressWithList` | ✅ | ✅ | ✅ | ✅ |
| `compressAssetImage` | ✅ | ✅ | ✅ | ✅ |
| `compressWithFile` | ✅ | ✅ | ✅ | ❌ |
| `compressAndGetFile` | ✅ | ✅ | ✅ | ❌ |
| JPEG 格式 | ✅ | ✅ | ✅ | ✅ |
| PNG 格式 | ✅ | ✅ | ✅ | ✅ |
| WebP 格式 | ✅ | ✅ | ❌ | ✅ |
| HEIC 格式 | ✅ (API 28+) | ✅ (iOS 11+) | ✅ | ❌ |
| 旋转 | ✅ | ✅ | ✅ | ❌ |
| 保留 EXIF | ✅ | ✅ | ✅ | ❌ |

---

## Web 配置

在 `web/index.html` 中添加 pica 库：

```html
<head>
  <!-- 添加 pica 压缩库 -->
  <script src="https://cdn.jsdelivr.net/npm/pica@9.0.1/dist/pica.min.js"></script>
</head>
```

## macOS 配置

需要将最低部署目标设置为 10.15：

1. 打开 Xcode 项目，选择 Runner target
2. 将 `macOS Deployment Target` 改为 `10.15`
3. 修改 `Podfile`：`platform :osx, '10.15'`

---

## 基本用法

### 压缩文件获取字节数组

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// 压缩文件，返回 Uint8List
Future<Uint8List?> compressFile(File file) async {
  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 1920,     // 最小宽度
    minHeight: 1080,    // 最小高度
    quality: 85,        // 质量 0-100
  );
  
  if (result != null) {
    print('原始大小: ${file.lengthSync()} bytes');
    print('压缩后大小: ${result.length} bytes');
  }
  
  return result;
}
```

### 压缩文件获取文件

```dart
/// 压缩文件，返回新的 File
Future<XFile?> compressAndGetFile(File file, String targetPath) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 85,
    minWidth: 1920,
    minHeight: 1080,
  );
  
  if (result != null) {
    print('原始大小: ${file.lengthSync()} bytes');
    print('压缩后大小: ${await result.length()} bytes');
  }
  
  return result;
}
```

### 压缩字节数组

```dart
/// 压缩 Uint8List
Future<Uint8List> compressList(Uint8List imageBytes) async {
  final result = await FlutterImageCompress.compressWithList(
    imageBytes,
    minWidth: 1920,
    minHeight: 1080,
    quality: 85,
  );
  
  print('原始大小: ${imageBytes.length} bytes');
  print('压缩后大小: ${result.length} bytes');
  
  return result;
}
```

### 压缩 Asset 图片

```dart
/// 压缩 assets 中的图片
Future<Uint8List?> compressAsset(String assetPath) async {
  final result = await FlutterImageCompress.compressAssetImage(
    assetPath,  // 如 'assets/images/photo.jpg'
    minWidth: 1920,
    minHeight: 1080,
    quality: 85,
  );
  
  return result;
}
```

---

## 参数详解

### minWidth 和 minHeight

这是**缩放约束**，不是目标尺寸。图片会按比例缩放，保证宽高都不小于设定值。

```dart
// 计算逻辑示例
// 原图: 4000x2000
// minWidth: 1920, minHeight: 1080

void calcScale() {
  var srcWidth = 4000.0;
  var srcHeight = 2000.0;
  var minWidth = 1920.0;
  var minHeight = 1080.0;
  
  var scaleW = srcWidth / minWidth;   // 4000 / 1920 = 2.08
  var scaleH = srcHeight / minHeight; // 2000 / 1080 = 1.85
  var scale = math.max(1.0, math.min(scaleW, scaleH)); // 1.85
  
  print('目标宽度: ${srcWidth / scale}');  // 2162
  print('目标高度: ${srcHeight / scale}'); // 1081
}
```

::: tip 提示
如果原图宽度小于 `minWidth` 或高度小于 `minHeight`，scale 为 1，即不缩放。
:::

### quality

压缩质量，范围 0-100。

- 对 **JPEG** 有效
- 对 **PNG** 在 iOS 上无效
- 建议值：80-90（兼顾质量和大小）

### format

输出格式：

```dart
enum CompressFormat {
  jpeg,  // 默认，最常用
  png,   // 无损，文件较大
  webp,  // 高压缩率，兼容性一般
  heic,  // 最高压缩率，兼容性最差
}

// 使用示例
final result = await FlutterImageCompress.compressWithFile(
  file.path,
  format: CompressFormat.webp,
  quality: 85,
);
```

### rotate

旋转角度（顺时针）：

```dart
final result = await FlutterImageCompress.compressWithFile(
  file.path,
  rotate: 90,  // 旋转 90 度
);
```

### keepExif

是否保留 EXIF 信息：

```dart
final result = await FlutterImageCompress.compressWithFile(
  file.path,
  keepExif: true,  // 保留 EXIF
);
```

::: warning 注意
- 默认值是 `false`（不保留）
- 即使设为 `true`，方向信息也不会保留
- 仅对 JPEG 有效，PNG 不支持
:::

### autoCorrectionAngle

自动校正角度（基于 EXIF）：

```dart
final result = await FlutterImageCompress.compressWithFile(
  file.path,
  autoCorrectionAngle: true,  // 自动校正
);
```

---

## 格式兼容性处理

由于不同平台对格式支持不同，建议使用 try-catch 处理：

```dart
Future<Uint8List?> compressWithFallback(String path) async {
  // 尝试使用 HEIC 格式（高压缩率）
  try {
    return await FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.heic,
      quality: 85,
    );
  } on UnsupportedError catch (e) {
    print('HEIC 不支持: $e');
    
    // 回退到 JPEG
    return await FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.jpeg,
      quality: 85,
    );
  }
}

// WebP 带回退
Future<Uint8List?> compressToWebP(String path) async {
  try {
    return await FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.webp,
      quality: 85,
    );
  } on UnsupportedError {
    return await FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.jpeg,
      quality: 85,
    );
  }
}
```

---

## 封装工具类

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressUtil {
  /// 默认压缩配置
  static const int defaultQuality = 85;
  static const int defaultMinWidth = 1920;
  static const int defaultMinHeight = 1080;

  /// 压缩文件，返回字节数组
  static Future<Uint8List?> compressFile(
    File file, {
    int quality = defaultQuality,
    int minWidth = defaultMinWidth,
    int minHeight = defaultMinHeight,
    CompressFormat format = CompressFormat.jpeg,
    int rotate = 0,
    bool keepExif = false,
  }) async {
    return await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
      rotate: rotate,
      keepExif: keepExif,
    );
  }

  /// 压缩并保存到临时目录
  static Future<File?> compressAndSave(
    File file, {
    int quality = defaultQuality,
    int minWidth = defaultMinWidth,
    int minHeight = defaultMinHeight,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(file.path);
    final ext = _getExtension(format);
    final targetPath = '${tempDir.path}/${fileName}_compressed.$ext';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
    );

    return result != null ? File(result.path) : null;
  }

  /// 压缩字节数组
  static Future<Uint8List> compressBytes(
    Uint8List bytes, {
    int quality = defaultQuality,
    int minWidth = defaultMinWidth,
    int minHeight = defaultMinHeight,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    return await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: format,
    );
  }

  /// 压缩到指定大小以下（递归压缩）
  static Future<Uint8List?> compressToMaxSize(
    File file,
    int maxSizeKB, {
    int minQuality = 30,
    int minWidth = 800,
    int minHeight = 600,
  }) async {
    int quality = 95;
    int width = defaultMinWidth;
    int height = defaultMinHeight;
    
    Uint8List? result = await compressFile(
      file,
      quality: quality,
      minWidth: width,
      minHeight: height,
    );

    while (result != null && 
           result.length > maxSizeKB * 1024 && 
           quality > minQuality) {
      // 降低质量
      quality -= 10;
      
      // 如果质量已经很低，开始缩小尺寸
      if (quality <= 50) {
        width = (width * 0.8).toInt();
        height = (height * 0.8).toInt();
        
        if (width < minWidth || height < minHeight) {
          break;
        }
      }
      
      result = await compressFile(
        file,
        quality: quality,
        minWidth: width,
        minHeight: height,
      );
    }

    return result;
  }

  /// 生成缩略图
  static Future<Uint8List?> generateThumbnail(
    File file, {
    int size = 200,
    int quality = 70,
  }) async {
    return await compressFile(
      file,
      quality: quality,
      minWidth: size,
      minHeight: size,
    );
  }

  /// 获取文件扩展名
  static String _getExtension(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return 'jpg';
      case CompressFormat.png:
        return 'png';
      case CompressFormat.webp:
        return 'webp';
      case CompressFormat.heic:
        return 'heic';
    }
  }
  
  /// 计算压缩率
  static double calculateCompressionRatio(int originalSize, int compressedSize) {
    return (1 - compressedSize / originalSize) * 100;
  }
  
  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
```

---

## 结合 image_picker 使用

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// 选择并压缩图片
  Future<File?> pickAndCompressImage({
    required ImageSource source,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    // 1. 选择图片
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      // 注意：这里不使用 image_picker 的压缩，
      // 因为 flutter_image_compress 效果更好
    );

    if (pickedFile == null) return null;

    // 2. 压缩图片
    final compressedFile = await ImageCompressUtil.compressAndSave(
      File(pickedFile.path),
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
    );

    return compressedFile;
  }

  /// 选择多张图片并压缩
  Future<List<File>> pickAndCompressMultipleImages({
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    
    if (pickedFiles.isEmpty) return [];

    final List<File> compressedFiles = [];

    for (final pickedFile in pickedFiles) {
      final compressed = await ImageCompressUtil.compressAndSave(
        File(pickedFile.path),
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );
      
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }

    return compressedFiles;
  }
}
```

---

## 完整示例

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressDemo extends StatefulWidget {
  const ImageCompressDemo({super.key});

  @override
  State<ImageCompressDemo> createState() => _ImageCompressDemoState();
}

class _ImageCompressDemoState extends State<ImageCompressDemo> {
  final ImagePicker _picker = ImagePicker();
  
  File? _originalFile;
  File? _compressedFile;
  int _originalSize = 0;
  int _compressedSize = 0;
  bool _isCompressing = false;
  
  int _quality = 85;
  CompressFormat _format = CompressFormat.jpeg;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _originalFile = File(image.path);
      _originalSize = _originalFile!.lengthSync();
      _compressedFile = null;
      _compressedSize = 0;
    });
  }

  Future<void> _compressImage() async {
    if (_originalFile == null) return;

    setState(() => _isCompressing = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final ext = _format == CompressFormat.jpeg ? 'jpg' : 
                  _format == CompressFormat.png ? 'png' : 
                  _format == CompressFormat.webp ? 'webp' : 'heic';
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final result = await FlutterImageCompress.compressAndGetFile(
        _originalFile!.absolute.path,
        targetPath,
        quality: _quality,
        minWidth: 1920,
        minHeight: 1080,
        format: _format,
      );

      if (result != null) {
        setState(() {
          _compressedFile = File(result.path);
          _compressedSize = _compressedFile!.lengthSync();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('压缩失败: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isCompressing = false);
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  double get _compressionRatio {
    if (_originalSize == 0 || _compressedSize == 0) return 0;
    return (1 - _compressedSize / _originalSize) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片压缩')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 选择图片按钮
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('选择图片'),
            ),
            
            const SizedBox(height: 16),
            
            // 原图预览
            if (_originalFile != null) ...[
              const Text('原图:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _originalFile!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Text('大小: ${_formatSize(_originalSize)}'),
              
              const SizedBox(height: 24),
              
              // 压缩参数
              const Text('压缩参数:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // 质量滑块
              Row(
                children: [
                  const Text('质量:'),
                  Expanded(
                    child: Slider(
                      value: _quality.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 9,
                      label: '$_quality',
                      onChanged: (value) {
                        setState(() => _quality = value.toInt());
                      },
                    ),
                  ),
                  Text('$_quality'),
                ],
              ),
              
              // 格式选择
              Row(
                children: [
                  const Text('格式:'),
                  const SizedBox(width: 16),
                  DropdownButton<CompressFormat>(
                    value: _format,
                    items: const [
                      DropdownMenuItem(value: CompressFormat.jpeg, child: Text('JPEG')),
                      DropdownMenuItem(value: CompressFormat.png, child: Text('PNG')),
                      DropdownMenuItem(value: CompressFormat.webp, child: Text('WebP')),
                      DropdownMenuItem(value: CompressFormat.heic, child: Text('HEIC')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _format = value);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 压缩按钮
              ElevatedButton.icon(
                onPressed: _isCompressing ? null : _compressImage,
                icon: _isCompressing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.compress),
                label: Text(_isCompressing ? '压缩中...' : '开始压缩'),
              ),
            ],
            
            // 压缩结果
            if (_compressedFile != null) ...[
              const SizedBox(height: 24),
              const Text('压缩后:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _compressedFile!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              
              // 对比信息
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _InfoRow('压缩后大小', _formatSize(_compressedSize)),
                    _InfoRow('压缩率', '${_compressionRatio.toStringAsFixed(1)}%'),
                    _InfoRow('节省空间', _formatSize(_originalSize - _compressedSize)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

---

## 常见问题

### 压缩返回 null

1. 检查文件路径是否正确
2. 检查是否有读写权限
3. 确保目标文件的父目录存在

### Android 编译错误

可能需要更新 Kotlin 版本到 1.5.21 或更高。

### Web 端不支持 compressWithFile

Web 端只支持 `compressWithList` 和 `compressAssetImage`，不支持文件操作。

## 最佳实践

1. **先选后压** - 使用 image_picker 原图，再用本插件压缩
2. **异步处理** - 压缩是耗时操作，注意 UI 状态管理
3. **格式降级** - 优先尝试高压缩格式，失败时降级到 JPEG
4. **合理参数** - 质量 80-90 通常是质量和大小的平衡点

## 相关资源

- [flutter_image_compress 官方文档](https://pub.dev/packages/flutter_image_compress)
- [image_picker](https://pub.dev/packages/image_picker) - 图片选择
- [path_provider](https://pub.dev/packages/path_provider) - 获取存储路径
