import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final File imageFile;

  FacePainter({
    required this.faces,
    required this.imageSize,
    required this.imageFile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFE91E63);

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: ' Face ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            background: Paint()..color = const Color(0xFFE91E63),
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}
