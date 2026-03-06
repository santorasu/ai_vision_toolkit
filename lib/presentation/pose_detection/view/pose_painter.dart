import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;

  PosePainter({required this.poses, required this.imageSize});

  // Body connections
  static const _connections = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    [PoseLandmarkType.nose, PoseLandmarkType.leftEye],
    [PoseLandmarkType.nose, PoseLandmarkType.rightEye],
    [PoseLandmarkType.leftEye, PoseLandmarkType.leftEar],
    [PoseLandmarkType.rightEye, PoseLandmarkType.rightEar],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF6200EA).withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFEA00D9)
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      // Draw connections
      for (final connection in _connections) {
        final from = pose.landmarks[connection[0]];
        final to = pose.landmarks[connection[1]];
        if (from != null && to != null) {
          canvas.drawLine(
            Offset(from.x, from.y),
            Offset(to.x, to.y),
            linePaint,
          );
        }
      }

      // Draw dots
      for (final landmark in pose.landmarks.values) {
        canvas.drawCircle(Offset(landmark.x, landmark.y), 5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}
