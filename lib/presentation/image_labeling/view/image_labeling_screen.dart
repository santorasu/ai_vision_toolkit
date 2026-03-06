import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../viewmodel/image_labeling_provider.dart';

class ImageLabelingScreen extends ConsumerWidget {
  const ImageLabelingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageLabelingProvider);
    final notifier = ref.read(imageLabelingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.imageLabeling),
        actions: [
          if (state.status == LabelStatus.success)
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
              height: 220.h,
              color: Colors.black,
              child: Image.file(state.imageFile!, fit: BoxFit.contain),
            ),
          Expanded(child: _buildBody(context, state)),
          _buildBottomBar(context, notifier, state.status),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, LabelState state) {
    switch (state.status) {
      case LabelStatus.idle:
        return EmptyStateWidget(
          icon: Icons.label_rounded,
          title: AppString.imageLabeling,
          subtitle: AppString.tapToSelectImage,
        );
      case LabelStatus.loading:
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
      case LabelStatus.error:
        return Center(child: Text(state.errorMessage));
      case LabelStatus.success:
        if (state.labels.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.label_off_rounded,
            title: AppString.noLabelsFound,
            subtitle: 'Try with a clearer image',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppString.imageLabels,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...state.labels.map((label) => _buildLabelTile(context, label)),
          ],
        );
    }
  }

  Widget _buildLabelTile(BuildContext context, label) {
    final confidence = label.confidence as double;
    final pct = (confidence * 100).toStringAsFixed(0);
    final color = confidence > 0.8
        ? ColorManager.successColor
        : confidence > 0.6
        ? ColorManager.warningColor
        : ColorManager.infoColor;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.label as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: ColorManager.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ImageLabelingNotifier notifier,
    LabelStatus status,
  ) {
    if (status == LabelStatus.loading) return const SizedBox.shrink();
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
              onPressed: () => notifier.pickAndLabel(ImageSource.gallery),
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
              onPressed: () => notifier.pickAndLabel(ImageSource.camera),
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
