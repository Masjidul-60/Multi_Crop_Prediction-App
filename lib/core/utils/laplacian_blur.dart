import 'package:image/image.dart' as img;

class ImageQualityAssessment {
  final bool isTooDark;
  final bool isTooBlurry;
  final double brightnessScore;
  final double blurScore;

  const ImageQualityAssessment({
    required this.isTooDark,
    required this.isTooBlurry,
    required this.brightnessScore,
    required this.blurScore,
  });

  bool get hasWarning => isTooDark || isTooBlurry;
}

class ImageQualityChecker {
  ImageQualityChecker._();

  /// Analyzes an image byte array to assess blur and lighting quality.
  /// Runs on downscaled grayscale thumbnail for near-instant execution.
  static ImageQualityAssessment assess(img.Image originalImage) {
    // Downscale for instant processing
    final thumbnail = img.copyResize(originalImage, width: 120, height: 120);
    final grayscale = img.grayscale(thumbnail);

    final int width = grayscale.width;
    final int height = grayscale.height;
    final int totalPixels = width * height;

    double totalBrightness = 0.0;
    final List<double> laplacianValues = [];

    // Laplacian kernel:
    // [ 0,  1,  0 ]
    // [ 1, -4,  1 ]
    // [ 0,  1,  0 ]
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final center = grayscale.getPixel(x, y).r;
        final top = grayscale.getPixel(x, y - 1).r;
        final bottom = grayscale.getPixel(x, y + 1).r;
        final left = grayscale.getPixel(x - 1, y).r;
        final right = grayscale.getPixel(x + 1, y).r;

        totalBrightness += center;

        final double laplacian = (top + bottom + left + right - 4 * center).toDouble();
        laplacianValues.add(laplacian);
      }
    }

    final double avgBrightness = totalBrightness / (totalPixels > 0 ? totalPixels : 1);

    // Compute Laplacian variance
    double meanLaplacian = 0.0;
    if (laplacianValues.isNotEmpty) {
      meanLaplacian = laplacianValues.reduce((a, b) => a + b) / laplacianValues.length;
    }

    double varianceSum = 0.0;
    for (final val in laplacianValues) {
      final diff = val - meanLaplacian;
      varianceSum += diff * diff;
    }
    final double laplacianVariance = laplacianValues.isNotEmpty
        ? varianceSum / laplacianValues.length
        : 100.0;

    // Thresholds:
    // avgBrightness < 45 on 0..255 scale is considered underexposed/too dark
    // laplacianVariance < 45 on downscaled natural leaf image is considered blurry
    final bool isTooDark = avgBrightness < 45.0;
    final bool isTooBlurry = laplacianVariance < 45.0;

    return ImageQualityAssessment(
      isTooDark: isTooDark,
      isTooBlurry: isTooBlurry,
      brightnessScore: avgBrightness,
      blurScore: laplacianVariance,
    );
  }
}
