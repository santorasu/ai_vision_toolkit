import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../data/repositories/scan_history_repository.dart';

enum DocStatus { idle, loading, success, error }

class DocState {
  final DocStatus status;
  final String extractedText;
  final File? imageFile;
  final String errorMessage;

  const DocState({
    this.status = DocStatus.idle,
    this.extractedText = '',
    this.imageFile,
    this.errorMessage = '',
  });

  DocState copyWith({
    DocStatus? status,
    String? extractedText,
    File? imageFile,
    String? errorMessage,
  }) {
    return DocState(
      status: status ?? this.status,
      extractedText: extractedText ?? this.extractedText,
      imageFile: imageFile ?? this.imageFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DocumentScannerNotifier extends Notifier<DocState> {
  final _picker = ImagePicker();
  final _repo = ScanHistoryRepository();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  DocState build() => const DocState();

  Future<void> scanDocument(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked == null) return;

      state = state.copyWith(
        status: DocStatus.loading,
        imageFile: File(picked.path),
        extractedText: '',
      );

      final inputImage = InputImage.fromFilePath(picked.path);
      final result = await _recognizer.processImage(inputImage);
      final text = result.text.trim();

      state = state.copyWith(status: DocStatus.success, extractedText: text);

      if (text.isNotEmpty) {
        await _repo.add(type: 'document', result: text, imagePath: picked.path);
      }
    } catch (e) {
      state = state.copyWith(
        status: DocStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const DocState();
}

final documentScannerProvider =
    NotifierProvider<DocumentScannerNotifier, DocState>(
      DocumentScannerNotifier.new,
    );
