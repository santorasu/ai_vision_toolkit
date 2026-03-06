import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../viewmodel/face_detection_provider.dart';
import 'face_painter.dart';

class FaceDetectionScreen extends ConsumerWidget {
  const FaceDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faceDetectionProvider);
    final notifier = ref.read(faceDetectionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.faceDetection),
        actions: [
          if (state.status == FaceStatus.success)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: notifier.reset,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(context, state)),
          _buildBottomBar(context, notifier, state.status),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, FaceState state) {
    switch (state.status) {
      case FaceStatus.idle:
        return EmptyStateWidget(
          icon: Icons.face_retouching_natural,
          title: AppString.faceDetection,
          subtitle: AppString.tapToSelectImage,
        );
      case FaceStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(AppString.processing),
            ],
          ),
        );
      case FaceStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: ColorManager.errorColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(state.errorMessage, textAlign: TextAlign.center),
            ],
          ),
        );
      case FaceStatus.success:
        return SingleChildScrollView(
          child: Column(
            children: [
              // Image with face overlay
              if (state.imageFile != null)
                Container(
                  height: 300.h,
                  width: double.infinity,
                  color: Colors.black,
                  child: state.faces.isEmpty
                      ? Image.file(state.imageFile!, fit: BoxFit.contain)
                      : CustomPaint(
                          painter: FacePainter(
                            faces: state.faces,
                            imageSize: state.imageSize,
                            imageFile: state.imageFile!,
                          ),
                          child: Image.file(
                            state.imageFile!,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),

              // Results
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: state.faces.isEmpty
                                ? ColorManager.warningColor.withValues(
                                    alpha: 0.1,
                                  )
                                : ColorManager.successColor.withValues(
                                    alpha: 0.1,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            state.faces.isEmpty
                                ? AppString.noFaceFound
                                : '${state.faces.length} Face(s) Detected',
                            style: TextStyle(
                              color: state.faces.isEmpty
                                  ? ColorManager.warningColor
                                  : ColorManager.successColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...state.faces.asMap().entries.map(
                      (entry) =>
                          _buildFaceCard(context, entry.key, entry.value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildFaceCard(BuildContext context, int index, face) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Face ${index + 1}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 12),
          if (face.smilingProbability != null)
            _buildAttribute(
              context,
              '😊 Smile',
              '${((face.smilingProbability!) * 100).toStringAsFixed(0)}%',
              face.smilingProbability!,
            ),
          if (face.leftEyeOpenProbability != null)
            _buildAttribute(
              context,
              '👁 Left Eye',
              '${((face.leftEyeOpenProbability!) * 100).toStringAsFixed(0)}%',
              face.leftEyeOpenProbability!,
            ),
          if (face.rightEyeOpenProbability != null)
            _buildAttribute(
              context,
              '👁 Right Eye',
              '${((face.rightEyeOpenProbability!) * 100).toStringAsFixed(0)}%',
              face.rightEyeOpenProbability!,
            ),
          if (face.headEulerAngleY != null)
            _buildSimpleAttribute(
              context,
              '↔ Head Tilt Y',
              '${face.headEulerAngleY!.toStringAsFixed(1)}°',
            ),
          if (face.headEulerAngleZ != null)
            _buildSimpleAttribute(
              context,
              '↕ Head Roll Z',
              '${face.headEulerAngleZ!.toStringAsFixed(1)}°',
            ),
        ],
      ),
    );
  }

  Widget _buildAttribute(
    BuildContext context,
    String label,
    String value,
    double prob,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prob,
              backgroundColor: ColorManager.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                prob > 0.6
                    ? ColorManager.successColor
                    : ColorManager.warningColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAttribute(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    FaceDetectionNotifier notifier,
    FaceStatus status,
  ) {
    if (status == FaceStatus.loading) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: ColorManager.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => notifier.pickAndDetect(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => notifier.pickAndDetect(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
