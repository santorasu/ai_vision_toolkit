import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import '../../history/viewmodel/history_provider.dart';

enum ObjectDetectionStatus { idle, loading, success, error }

class ObjectDetectionState {
  final ObjectDetectionStatus status;
  final File? imageFile;
  final List<DetectedObject> objects;
  final String errorMessage;
  final ui.Size? imageSize;

  ObjectDetectionState({
    this.status = ObjectDetectionStatus.idle,
    this.imageFile,
    this.objects = const [],
    this.errorMessage = '',
    this.imageSize,
  });

  ObjectDetectionState copyWith({
    ObjectDetectionStatus? status,
    File? imageFile,
    List<DetectedObject>? objects,
    String? errorMessage,
    ui.Size? imageSize,
  }) {
    return ObjectDetectionState(
      status: status ?? this.status,
      imageFile: imageFile ?? this.imageFile,
      objects: objects ?? this.objects,
      errorMessage: errorMessage ?? this.errorMessage,
      imageSize: imageSize ?? this.imageSize,
    );
  }
}

class ObjectDetectionNotifier extends Notifier<ObjectDetectionState> {
  final ImagePicker _picker = ImagePicker();
  late final ObjectDetector _objectDetector;

  @override
  ObjectDetectionState build() {
    _objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );

    ref.onDispose(() {
      _objectDetector.close();
    });

    return ObjectDetectionState();
  }

  Future<void> scanFromSource(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        state = state.copyWith(
          status: ObjectDetectionStatus.loading,
          imageFile: File(pickedFile.path),
          objects: [],
        );
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      state = state.copyWith(
        status: ObjectDetectionStatus.error,
        errorMessage: 'Failed to pick image: $e',
      );
    }
  }

  Future<void> _processImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      final ui.Size size = ui.Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      final inputImage = InputImage.fromFile(file);
      final objects = await _objectDetector.processImage(inputImage);

      state = state.copyWith(
        status: ObjectDetectionStatus.success,
        objects: objects,
        imageSize: size,
      );

      if (objects.isNotEmpty) {
        final objectNames = objects
            .expand((o) => o.labels)
            .map((l) => l.text)
            .toSet()
            .join(", ");

        ref
            .read(historyProvider.notifier)
            .save(
              'object',
              'Detected: ${objects.length} object(s)\nLabels: ${objectNames.isEmpty ? 'Unknown' : objectNames}',
            );
      }
    } catch (e) {
      state = state.copyWith(
        status: ObjectDetectionStatus.error,
        errorMessage: 'Failed to process image: $e',
      );
    }
  }

  void reset() {
    state = ObjectDetectionState();
  }
}

final objectDetectionProvider =
    NotifierProvider<ObjectDetectionNotifier, ObjectDetectionState>(
      ObjectDetectionNotifier.new,
    );
