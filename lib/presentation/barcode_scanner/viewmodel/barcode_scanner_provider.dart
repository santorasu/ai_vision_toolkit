import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../data/repositories/scan_history_repository.dart';

enum BarcodeStatus { idle, loading, success, error }

class BarcodeState {
  final BarcodeStatus status;
  final List<Barcode> barcodes;
  final File? imageFile;
  final String errorMessage;

  const BarcodeState({
    this.status = BarcodeStatus.idle,
    this.barcodes = const [],
    this.imageFile,
    this.errorMessage = '',
  });

  BarcodeState copyWith({
    BarcodeStatus? status,
    List<Barcode>? barcodes,
    File? imageFile,
    String? errorMessage,
  }) {
    return BarcodeState(
      status: status ?? this.status,
      barcodes: barcodes ?? this.barcodes,
      imageFile: imageFile ?? this.imageFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BarcodeScannerNotifier extends Notifier<BarcodeState> {
  final _picker = ImagePicker();
  final _repo = ScanHistoryRepository();
  final _scanner = BarcodeScanner(
    formats: [
      BarcodeFormat.qrCode,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upca,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.pdf417,
    ],
  );

  @override
  BarcodeState build() => const BarcodeState();

  Future<void> scanFromSource(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;

      state = state.copyWith(
        status: BarcodeStatus.loading,
        imageFile: File(picked.path),
        barcodes: [],
      );

      final inputImage = InputImage.fromFilePath(picked.path);
      final barcodes = await _scanner.processImage(inputImage);

      state = state.copyWith(status: BarcodeStatus.success, barcodes: barcodes);

      for (final barcode in barcodes) {
        await _repo.add(
          type: 'barcode',
          result: barcode.displayValue ?? barcode.rawValue ?? 'Unknown',
          imagePath: picked.path,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: BarcodeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const BarcodeState();
}

final barcodeScannerProvider =
    NotifierProvider<BarcodeScannerNotifier, BarcodeState>(
      BarcodeScannerNotifier.new,
    );
