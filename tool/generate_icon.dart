import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  const int size = 512;
  final img.Image image = img.Image(width: size, height: size);

  // Background deep forest green: #1F6F43 -> (31, 111, 67)
  final img.Color bg = img.ColorRgba8(31, 111, 67, 255);
  final img.Color lime = img.ColorRgba8(168, 214, 114, 255); // #A8D672
  final img.Color white = img.ColorRgba8(247, 246, 241, 255); // #F7F6F1
  final img.Color leafDark = img.ColorRgba8(40, 140, 85, 255);

  // Fill rounded background or circular background
  img.fill(image, color: bg);

  final double cx = size / 2.0;
  final double cy = size / 2.0;

  // Draw stylized leaf shape mathematically
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final double nx = (x - cx) / (size * 0.38);
      final double ny = (y - cy) / (size * 0.38);

      // Rotate by -45 degrees
      final double rx = nx * cos(-0.785) - ny * sin(-0.785);
      final double ry = nx * sin(-0.785) + ny * cos(-0.785);

      // Oval / Leaf boundary equation
      // Leaf profile: symmetric teardrop shape
      if (rx * rx + (ry * ry * (1.2 + 0.5 * rx)) < 0.6) {
        // Vein
        if ((ry).abs() < 0.03 && rx > -0.7 && rx < 0.7) {
          image.setPixel(x, y, white);
        } else if (ry > 0) {
          image.setPixel(x, y, lime);
        } else {
          image.setPixel(x, y, leafDark);
        }
      }
    }
  }

  // Ensure assets/icons directory exists
  final dir = Directory('assets/icons');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(image));
  // ignore: avoid_print
  print('Generated assets/icons/app_icon.png');
}
