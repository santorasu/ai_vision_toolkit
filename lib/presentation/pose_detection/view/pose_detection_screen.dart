import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../viewmodel/pose_detection_provider.dart';
import 'pose_painter.dart';

class PoseDetectionScreen extends ConsumerWidget {
  const PoseDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(poseDetectionProvider);
    final notifier = ref.read(poseDetectionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.poseDetection),
        actions: [
          if (state.status == PoseStatus.success)
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

  Widget _buildBody(BuildContext context, PoseState state) {
    switch (state.status) {
      case PoseStatus.idle:
        return EmptyStateWidget(
          icon: Icons.accessibility_new_rounded,
          title: AppString.poseDetection,
          subtitle: AppString.tapToSelectImage,
        );
      case PoseStatus.loading:
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
      case PoseStatus.error:
        return Center(child: Text(state.errorMessage));
      case PoseStatus.success:
        return Column(
          children: [
            // Image with pose overlay
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: state.imageFile == null
                    ? const SizedBox()
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: state.imageSize.width,
                          height: state.imageSize.height,
                          child: Stack(
                            children: [
                              Image.file(state.imageFile!),
                              if (state.poses.isNotEmpty)
                                CustomPaint(
                                  size: state.imageSize,
                                  painter: PosePainter(
                                    poses: state.poses,
                                    imageSize: state.imageSize,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // Stats bar
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: state.poses.isEmpty
                    ? const Center(child: Text(AppString.noPoseFound))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _stat(context, '${state.poses.length}', 'Poses'),
                          _divider(),
                          _stat(
                            context,
                            '${state.poses.isNotEmpty ? state.poses.first.landmarks.length : 0}',
                            'Landmarks',
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
    }
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6200EA),
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: ColorManager.borderColor);

  Widget _buildBottomBar(
    BuildContext context,
    PoseDetectionNotifier notifier,
    PoseStatus status,
  ) {
    if (status == PoseStatus.loading) return const SizedBox.shrink();
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
