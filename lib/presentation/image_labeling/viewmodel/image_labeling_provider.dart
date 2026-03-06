import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../data/repositories/scan_history_repository.dart';

enum LabelStatus { idle, loading, success, error }

class LabelState {
  final LabelStatus status;
  final List<ImageLabel> labels;
  final File? imageFile;
  final String errorMessage;

  const LabelState({
    this.status = LabelStatus.idle,
    this.labels = const [],
    this.imageFile,
    this.errorMessage = '',
  });

  LabelState copyWith({
    LabelStatus? status,
    List<ImageLabel>? labels,
    File? imageFile,
    String? errorMessage,
  }) {
    return LabelState(
      status: status ?? this.status,
      labels: labels ?? this.labels,
      imageFile: imageFile ?? this.imageFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ImageLabelingNotifier extends Notifier<LabelState> {
  final _picker = ImagePicker();
  final _repo = ScanHistoryRepository();
  final _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  @override
  LabelState build() => const LabelState();

  Future<void> pickAndLabel(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      state = state.copyWith(
        status: LabelStatus.loading,
        imageFile: File(picked.path),
        labels: [],
      );

      final inputImage = InputImage.fromFilePath(picked.path);
      final labels = await _labeler.processImage(inputImage);
      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      state = state.copyWith(status: LabelStatus.success, labels: labels);

      if (labels.isNotEmpty) {
        final result = labels
            .take(5)
            .map(
              (l) => '${l.label}: ${(l.confidence * 100).toStringAsFixed(0)}%',
            )
            .join(', ');
        await _repo.add(type: 'label', result: result, imagePath: picked.path);
      }
    } catch (e) {
      state = state.copyWith(
        status: LabelStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const LabelState();
}

final imageLabelingProvider =
    NotifierProvider<ImageLabelingNotifier, LabelState>(
      ImageLabelingNotifier.new,
    );
