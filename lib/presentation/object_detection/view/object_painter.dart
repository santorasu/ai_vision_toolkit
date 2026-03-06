import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ObjectPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final Size imageSize;
  final Color boundingBoxColor;

  ObjectPainter(
    this.objects,
    this.imageSize, {
    this.boundingBoxColor = const Color(0xFFAD1457), // Muted Pink/Red
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (objects.isEmpty) return;

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = boundingBoxColor;

    final Paint backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = boundingBoxColor;

    for (final detectedObject in objects) {
      final rect = detectedObject.boundingBox;

      final left = rect.left * scaleX;
      final top = rect.top * scaleY;
      final right = rect.right * scaleX;
      final bottom = rect.bottom * scaleY;

      final mappedRect = Rect.fromLTRB(left, top, right, bottom);
      final rrect = RRect.fromRectAndRadius(
        mappedRect,
        const Radius.circular(8),
      );

      canvas.drawRRect(rrect, paint);

      if (detectedObject.labels.isNotEmpty) {
        final label = detectedObject.labels.first;
        final text =
            '${label.text} ${(label.confidence * 100).toStringAsFixed(0)}%';

        final textSpan = TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        final bgRect = Rect.fromLTWH(
          left,
          top - 24,
          textPainter.width + 12,
          24,
        );

        canvas.drawRect(bgRect, backgroundPaint);
        textPainter.paint(canvas, Offset(left + 6, top - 20));
      } else {
        final textSpan = const TextSpan(
          text: 'Object',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final bgRect = Rect.fromLTWH(
          left,
          top - 24,
          textPainter.width + 12,
          24,
        );
        canvas.drawRect(bgRect, backgroundPaint);
        textPainter.paint(canvas, Offset(left + 6, top - 20));
      }
    }
  }

  @override
  bool shouldRepaint(covariant ObjectPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.objects != objects;
  }
}
