import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MaskPainter extends CustomPainter {
  final ui.Image image;
  final ui.Image maskImage;

  MaskPainter(this.image, this.maskImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = ui.FilterQuality.high;

    // Draw original image with aspect ratio preservation
    double scale = min(size.width / image.width, size.height / image.height);
    double drawWidth = image.width * scale;
    double drawHeight = image.height * scale;

    Rect destRect = Rect.fromLTWH(
      (size.width - drawWidth) / 2,
      (size.height - drawHeight) / 2,
      drawWidth,
      drawHeight,
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destRect,
      paint,
    );

    // Draw mask image over it
    canvas.drawImageRect(
      maskImage,
      Rect.fromLTWH(
        0,
        0,
        maskImage.width.toDouble(),
        maskImage.height.toDouble(),
      ),
      destRect,
      paint,
    );

    // Draw a subtle border around the detection area if mask is present
    final borderPaint = Paint()
      ..color = const Color(0xFFFF1493).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(destRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MaskPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.maskImage != maskImage;
}
