import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../config.dart';
import 'laplacian_blur.dart';

class PreparedImageResult {
  final File file;
  final int width;
  final int height;
  final int bytesSize;
  final ImageQualityAssessment qualityAssessment;

  const PreparedImageResult({
    required this.file,
    required this.width,
    required this.height,
    required this.bytesSize,
    required this.qualityAssessment,
  });
}

class ImageUtils {
  ImageUtils._();

  /// Loads image, applies optional rotation, checks quality, resizes so max side <= targetMaxSide,
  /// compresses to JPEG, and writes to a cache file.
  static Future<PreparedImageResult> prepareImageForPrediction({
    required String sourcePath,
    int? maxDimension,
    bool isDataSaver = false,
    int rotateDegrees = 0,
  }) async {
    final rawBytes = await File(sourcePath).readAsBytes();
    img.Image? decoded = img.decodeImage(rawBytes);

    if (decoded == null) {
      throw Exception('Failed to decode image from path: $sourcePath');
    }

    // Rotate if requested
    if (rotateDegrees != 0) {
      decoded = img.copyRotate(decoded, angle: rotateDegrees);
    }

    // Run quality assessment on decoded image before final resize
    final quality = ImageQualityChecker.assess(decoded);

    final targetMax = maxDimension ??
        (isDataSaver ? AppConfig.maxImageSideDataSaver : AppConfig.maxImageSidePixels);

    img.Image resized = decoded;
    if (decoded.width > targetMax || decoded.height > targetMax) {
      if (decoded.width >= decoded.height) {
        resized = img.copyResize(decoded, width: targetMax);
      } else {
        resized = img.copyResize(decoded, height: targetMax);
      }
    }

    final qualityLevel = isDataSaver ? 75 : 85;
    final Uint8List jpegBytes = Uint8List.fromList(img.encodeJpg(resized, quality: qualityLevel));

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetFile = File('${tempDir.path}/cropdoc_prep_$timestamp.jpg');
    await targetFile.writeAsBytes(jpegBytes);

    return PreparedImageResult(
      file: targetFile,
      width: resized.width,
      height: resized.height,
      bytesSize: jpegBytes.length,
      qualityAssessment: quality,
    );
  }

  /// Creates a persistent thumbnail image file for local history storage
  static Future<String> saveHistoryThumbnail(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return imagePath;

      final thumb = img.copyResize(decoded, width: 240, height: 240);
      final thumbBytes = img.encodeJpg(thumb, quality: 80);

      final appDocDir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory('${appDocDir.path}/thumbnails');
      if (!thumbDir.existsSync()) {
        thumbDir.createSync(recursive: true);
      }

      final fileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final thumbFile = File('${thumbDir.path}/$fileName');
      await thumbFile.writeAsBytes(thumbBytes);
      return thumbFile.path;
    } catch (_) {
      return imagePath;
    }
  }
}
