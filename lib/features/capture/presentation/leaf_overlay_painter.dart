import 'package:flutter/material.dart';

class LeafOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color guideColor;

  const LeafOverlayPainter({
    required this.overlayColor,
    required this.guideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Cutout path
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height * 0.45);
    final guideWidth = size.width * 0.72;
    final guideHeight = size.height * 0.50;

    // Stylized leaf shape path for the guide cutout
    final leafPath = Path();
    final top = Offset(center.dx, center.dy - guideHeight / 2);
    final bottom = Offset(center.dx, center.dy + guideHeight / 2);
    final leftControl = Offset(center.dx - guideWidth * 0.65, center.dy - guideHeight * 0.1);
    final rightControl = Offset(center.dx + guideWidth * 0.65, center.dy + guideHeight * 0.1);

    leafPath.moveTo(top.dx, top.dy);
    leafPath.cubicTo(
      leftControl.dx,
      top.dy + guideHeight * 0.25,
      leftControl.dx,
      bottom.dy - guideHeight * 0.2,
      bottom.dx,
      bottom.dy,
    );
    leafPath.cubicTo(
      rightControl.dx,
      bottom.dy - guideHeight * 0.2,
      rightControl.dx,
      top.dy + guideHeight * 0.25,
      top.dx,
      top.dy,
    );
    leafPath.close();

    // Subtract leaf from background overlay
    final combinedPath = Path.combine(PathOperation.difference, path, leafPath);
    canvas.drawPath(combinedPath, backgroundPaint);

    // Draw dashed/solid guide outline
    final strokePaint = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(leafPath, strokePaint);

    // Subtle corner markers or center alignment notch
    final notchPaint = Paint()
      ..color = guideColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx, center.dy - 12),
      Offset(center.dx, center.dy + 12),
      notchPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 12, center.dy),
      Offset(center.dx + 12, center.dy),
      notchPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
