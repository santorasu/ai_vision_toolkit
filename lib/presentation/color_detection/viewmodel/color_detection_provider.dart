import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../history/viewmodel/history_provider.dart';

enum ColorDetectionStatus { idle, loading, success, error }

class ColorDetectionState {
  final ColorDetectionStatus status;
  final File? imageFile;
  final PaletteGenerator? palette;
  final String errorMessage;

  ColorDetectionState({
    this.status = ColorDetectionStatus.idle,
    this.imageFile,
    this.palette,
    this.errorMessage = '',
  });

  ColorDetectionState copyWith({
    ColorDetectionStatus? status,
    File? imageFile,
    PaletteGenerator? palette,
    String? errorMessage,
  }) {
    return ColorDetectionState(
      status: status ?? this.status,
      imageFile: imageFile ?? this.imageFile,
      palette: palette ?? this.palette,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ColorDetectionNotifier extends Notifier<ColorDetectionState> {
  final ImagePicker _picker = ImagePicker();

  @override
  ColorDetectionState build() {
    return ColorDetectionState();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        state = state.copyWith(
          status: ColorDetectionStatus.loading,
          imageFile: File(pickedFile.path),
        );
        await _processImage(File(pickedFile.path));
      }
    } catch (e) {
      state = state.copyWith(
        status: ColorDetectionStatus.error,
        errorMessage: 'Failed to pick image: $e',
      );
    }
  }

  Future<void> _processImage(File image) async {
    try {
      final imageProvider = FileImage(image);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 10,
      );

      state = state.copyWith(
        status: ColorDetectionStatus.success,
        palette: paletteGenerator,
      );

      if (paletteGenerator.colors.isNotEmpty) {
        final dominantColor =
            paletteGenerator.dominantColor?.color ??
            paletteGenerator.colors.first;
        final hex =
            // ignore: deprecated_member_use
            '#${dominantColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

        ref
            .read(historyProvider.notifier)
            .save('color', 'Dominant Color: $hex');
      }
    } catch (e) {
      state = state.copyWith(
        status: ColorDetectionStatus.error,
        errorMessage: 'Error extracting colors: $e',
      );
    }
  }

  void reset() {
    state = ColorDetectionState();
  }
}

final colorDetectionProvider =
    NotifierProvider<ColorDetectionNotifier, ColorDetectionState>(
      ColorDetectionNotifier.new,
    );
