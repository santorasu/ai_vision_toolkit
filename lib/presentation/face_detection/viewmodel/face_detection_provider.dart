import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

import '../../../data/repositories/scan_history_repository.dart';

enum FaceStatus { idle, loading, success, error }

class FaceState {
  final FaceStatus status;
  final List<Face> faces;
  final File? imageFile;
  final Size imageSize;
  final String errorMessage;

  const FaceState({
    this.status = FaceStatus.idle,
    this.faces = const [],
    this.imageFile,
    this.imageSize = Size.zero,
    this.errorMessage = '',
  });

  FaceState copyWith({
    FaceStatus? status,
    List<Face>? faces,
    File? imageFile,
    Size? imageSize,
    String? errorMessage,
  }) {
    return FaceState(
      status: status ?? this.status,
      faces: faces ?? this.faces,
      imageFile: imageFile ?? this.imageFile,
      imageSize: imageSize ?? this.imageSize,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FaceDetectionNotifier extends Notifier<FaceState> {
  final _picker = ImagePicker();
  final _repo = ScanHistoryRepository();
  final _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ),
  );

  @override
  FaceState build() => const FaceState();

  Future<void> pickAndDetect(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      final imageFile = File(picked.path);
      state = state.copyWith(
        status: FaceStatus.loading,
        imageFile: imageFile,
        faces: [],
      );

      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final imageSize = Size(
        frameInfo.image.width.toDouble(),
        frameInfo.image.height.toDouble(),
      );

      final inputImage = InputImage.fromFilePath(picked.path);
      final faces = await _detector.processImage(inputImage);

      state = state.copyWith(
        status: FaceStatus.success,
        faces: faces,
        imageSize: imageSize,
      );

      if (faces.isNotEmpty) {
        await _repo.add(
          type: 'face',
          result:
              'Detected ${faces.length} face(s). ${faces.map((f) => 'Smile: ${((f.smilingProbability ?? 0) * 100).toStringAsFixed(0)}%').join(', ')}',
          imagePath: imageFile.path,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: FaceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const FaceState();
}

final faceDetectionProvider =
    NotifierProvider<FaceDetectionNotifier, FaceState>(
      FaceDetectionNotifier.new,
    );
