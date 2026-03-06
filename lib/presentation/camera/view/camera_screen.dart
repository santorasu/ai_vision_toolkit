import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../../core/constansts/color_manger.dart';
import '../viewmodel/camera_provider.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          if (state.isInitialized && state.controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: state.controller!.value.previewSize?.height ?? 1,
                  height: state.controller!.value.previewSize?.width ?? 1,
                  child: CameraPreview(state.controller!),
                ),
              ),
            ),

          // If no permission or not init
          if (!state.isInitialized && state.hasPermission == true)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (state.hasPermission == false)
            Center(
              child: Text(
                'Camera Permission Required',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),

          // 2. Detection Result Overlay
          if (state.detectionResult != null)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: _buildResultOverlay(
                state.currentMode,
                state.detectionResult,
              ),
            ),

          // 3. Bottom Controls Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay(CameraDetectionMode mode, dynamic result) {
    if (result == null) return const SizedBox.shrink();

    String displayText = '';

    switch (mode) {
      case CameraDetectionMode.text:
        if (result is! RecognizedText) return const SizedBox.shrink();
        final text = result;
        displayText = text.text.replaceAll('\n', ' ');
        if (displayText.length > 100) {
          displayText = '${displayText.substring(0, 100)}...';
        }
        if (displayText.isEmpty) displayText = 'No text detected';
        break;
      case CameraDetectionMode.face:
        if (result is! List<Face>) return const SizedBox.shrink();
        final faces = result;
        displayText = '${faces.length} Face(s) detected';
        break;
      case CameraDetectionMode.barcode:
        if (result is! List<Barcode>) return const SizedBox.shrink();
        final barcodes = result;
        if (barcodes.isNotEmpty) {
          displayText = barcodes.first.displayValue ?? 'Unknown Barcode';
        } else {
          displayText = 'Scanning for Barcode...';
        }
        break;
      case CameraDetectionMode.label:
        if (result is! List<ImageLabel>) return const SizedBox.shrink();
        final labels = result;
        if (labels.isNotEmpty) {
          displayText = labels
              .map(
                (e) =>
                    '${e.label} (${(e.confidence * 100).toStringAsFixed(0)}%)',
              )
              .take(3)
              .join('\n');
        } else {
          displayText = 'No confident labels detected';
        }
        break;
      case CameraDetectionMode.object:
        if (result is! List<DetectedObject>) return const SizedBox.shrink();
        final objects = result;
        if (objects.isNotEmpty && objects.first.labels.isNotEmpty) {
          displayText =
              '${objects.length} Object(s): ${objects.first.labels.first.text}';
        } else {
          displayText = '${objects.length} Object(s) detected';
        }
        break;
      case CameraDetectionMode.none:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    CameraState state,
    CameraNotifier notifier,
  ) {
    final modes = [
      {
        'mode': CameraDetectionMode.none,
        'label': 'Off',
        'icon': Icons.visibility_off_rounded,
      },
      {
        'mode': CameraDetectionMode.text,
        'label': 'Text',
        'icon': Icons.text_fields_rounded,
      },
      {
        'mode': CameraDetectionMode.barcode,
        'label': 'Barcode',
        'icon': Icons.qr_code_scanner_rounded,
      },
      {
        'mode': CameraDetectionMode.face,
        'label': 'Face',
        'icon': Icons.face_retouching_natural,
      },
      {
        'mode': CameraDetectionMode.label,
        'label': 'Label',
        'icon': Icons.label_rounded,
      },
      {
        'mode': CameraDetectionMode.object,
        'label': 'Object',
        'icon': Icons.category_rounded,
      },
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        16,
        12,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Live Detection Modes',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: modes.map((m) {
                final mode = m['mode'] as CameraDetectionMode;
                final isSelected = state.currentMode == mode;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(m['label'] as String),
                    selected: isSelected,
                    onSelected: (_) => notifier.setMode(mode),
                    avatar: Icon(
                      m['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white54,
                      size: 18,
                    ),
                    selectedColor: ColorManager.primary,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? ColorManager.primary
                            : Colors.transparent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
