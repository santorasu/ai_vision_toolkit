import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../viewmodel/object_detection_provider.dart';
import 'object_painter.dart';

class ObjectDetectionScreen extends ConsumerWidget {
  const ObjectDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(objectDetectionProvider);
    final notifier = ref.read(objectDetectionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.objectDetection),
        actions: [
          if (state.status == ObjectDetectionStatus.success)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: notifier.reset,
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.imageFile != null)
            Container(
              width: double.infinity,
              height: 300.h,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(state.imageFile!, fit: BoxFit.contain),
                  if (state.status == ObjectDetectionStatus.success &&
                      state.imageSize != null)
                    CustomPaint(
                      painter: ObjectPainter(state.objects, state.imageSize!),
                    ),
                ],
              ),
            ),
          Expanded(child: _buildBody(context, state)),
          _buildBottomBar(context, notifier, state.status),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ObjectDetectionState state) {
    switch (state.status) {
      case ObjectDetectionStatus.idle:
        return EmptyStateWidget(
          icon: Icons.category_rounded,
          title: AppString.objectDetection,
          subtitle: AppString.tapToSelectImage,
        );
      case ObjectDetectionStatus.loading:
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
      case ObjectDetectionStatus.error:
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
      case ObjectDetectionStatus.success:
        if (state.objects.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.highlight_off_rounded,
            title: AppString.noObjectsFound,
            subtitle: 'Try a different image',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.objects.length,
          itemBuilder: (context, index) {
            final obj = state.objects[index];
            final labels = obj.labels
                .map(
                  (e) =>
                      '${e.text} (${(e.confidence * 100).toStringAsFixed(0)}%)',
                )
                .join(', ');
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E2E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorManager.borderColor, width: 0.5),
                boxShadow: const [
                  BoxShadow(
                    color: ColorManager.shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAD1457).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: Color(0xFFAD1457),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Object ${obj.trackingId ?? (index + 1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(labels.isEmpty ? 'Unknown Object' : labels),
              ),
            );
          },
        );
    }
  }

  Widget _buildBottomBar(
    BuildContext context,
    ObjectDetectionNotifier notifier,
    ObjectDetectionStatus status,
  ) {
    if (status == ObjectDetectionStatus.loading) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: ColorManager.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => notifier.scanFromSource(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text(AppString.gallery),
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
              onPressed: () => notifier.scanFromSource(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text(AppString.camera),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
