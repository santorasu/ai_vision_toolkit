import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

import '../../../data/repositories/scan_history_repository.dart';

enum PoseStatus { idle, loading, success, error }

class PoseState {
  final PoseStatus status;
  final List<Pose> poses;
  final File? imageFile;
  final Size imageSize;
  final String errorMessage;

  const PoseState({
    this.status = PoseStatus.idle,
    this.poses = const [],
    this.imageFile,
    this.imageSize = Size.zero,
    this.errorMessage = '',
  });

  PoseState copyWith({
    PoseStatus? status,
    List<Pose>? poses,
    File? imageFile,
    Size? imageSize,
    String? errorMessage,
  }) {
    return PoseState(
      status: status ?? this.status,
      poses: poses ?? this.poses,
      imageFile: imageFile ?? this.imageFile,
      imageSize: imageSize ?? this.imageSize,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PoseDetectionNotifier extends Notifier<PoseState> {
  final _picker = ImagePicker();
  final _repo = ScanHistoryRepository();
  final _detector = PoseDetector(options: PoseDetectorOptions());

  @override
  PoseState build() => const PoseState();

  Future<void> pickAndDetect(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      final imageFile = File(picked.path);
      state = state.copyWith(
        status: PoseStatus.loading,
        imageFile: imageFile,
        poses: [],
      );

      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final imageSize = Size(
        frameInfo.image.width.toDouble(),
        frameInfo.image.height.toDouble(),
      );

      final inputImage = InputImage.fromFilePath(picked.path);
      final poses = await _detector.processImage(inputImage);

      state = state.copyWith(
        status: PoseStatus.success,
        poses: poses,
        imageSize: imageSize,
      );

      if (poses.isNotEmpty) {
        final landmarkCount = poses.first.landmarks.length;
        await _repo.add(
          type: 'pose',
          result:
              'Detected ${poses.length} pose(s) with $landmarkCount landmarks each',
          imagePath: picked.path,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PoseStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const PoseState();
}

final poseDetectionProvider =
    NotifierProvider<PoseDetectionNotifier, PoseState>(
      PoseDetectionNotifier.new,
    );
