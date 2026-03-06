import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../data/repositories/scan_history_repository.dart';

enum OcrStatus { idle, loading, success, error }

class OcrState {
  final OcrStatus status;
  final String extractedText;
  final File? imageFile;
  final String errorMessage;

  const OcrState({
    this.status = OcrStatus.idle,
    this.extractedText = '',
    this.imageFile,
    this.errorMessage = '',
  });

  OcrState copyWith({
    OcrStatus? status,
    String? extractedText,
    File? imageFile,
    String? errorMessage,
  }) {
    return OcrState(
      status: status ?? this.status,
      extractedText: extractedText ?? this.extractedText,
      imageFile: imageFile ?? this.imageFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TextRecognitionNotifier extends Notifier<OcrState> {
  final _picker = ImagePicker();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _repo = ScanHistoryRepository();

  @override
  OcrState build() => const OcrState();

  Future<void> pickAndRecognize(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      state = state.copyWith(
        status: OcrStatus.loading,
        imageFile: File(picked.path),
        extractedText: '',
      );

      final inputImage = InputImage.fromFilePath(picked.path);
      final result = await _recognizer.processImage(inputImage);
      final text = result.text.trim();

      state = state.copyWith(
        status: OcrStatus.success,
        extractedText: text.isEmpty ? '' : text,
      );
    } catch (e) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> saveToHistory() async {
    if (state.extractedText.isNotEmpty) {
      await _repo.add(
        type: 'ocr',
        result: state.extractedText,
        imagePath: state.imageFile?.path,
      );
    }
  }

  void reset() => state = const OcrState();
}

final textRecognitionProvider =
    NotifierProvider<TextRecognitionNotifier, OcrState>(
      TextRecognitionNotifier.new,
    );
