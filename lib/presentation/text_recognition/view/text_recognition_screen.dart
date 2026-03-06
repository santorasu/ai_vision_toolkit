import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/result_action_bar.dart';
import '../viewmodel/text_recognition_provider.dart';

class TextRecognitionScreen extends ConsumerWidget {
  const TextRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(textRecognitionProvider);
    final notifier = ref.read(textRecognitionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.textRecognition),
        actions: [
          if (state.status == OcrStatus.success)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: notifier.reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview
          if (state.imageFile != null)
            Container(
              width: double.infinity,
              height: 220.h,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: FileImage(state.imageFile!),
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // Result Area
          Expanded(child: _buildBody(context, state, notifier)),

          // Action buttons at bottom
          _buildBottomBar(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OcrState state,
    TextRecognitionNotifier notifier,
  ) {
    switch (state.status) {
      case OcrStatus.idle:
        return EmptyStateWidget(
          icon: Icons.text_fields_rounded,
          title: 'Text Recognition',
          subtitle: AppString.tapToSelectImage,
        );
      case OcrStatus.loading:
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
      case OcrStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: ColorManager.errorColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  AppString.error,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      case OcrStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppString.extractedText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.extractedText.length} chars',
                      style: TextStyle(
                        color: ColorManager.successColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.extractedText.isEmpty
                  ? const Center(child: Text(AppString.noTextFound))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E2E)
                              : const Color(0xFFF8F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorManager.borderColor),
                        ),
                        child: Text(
                          state.extractedText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.6,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ResultActionBar(
                text: state.extractedText,
                onSave: state.extractedText.isNotEmpty
                    ? () {
                        notifier.saveToHistory();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(AppString.saved),
                            backgroundColor: ColorManager.successColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildBottomBar(
    BuildContext context,
    OcrState state,
    TextRecognitionNotifier notifier,
  ) {
    if (state.status == OcrStatus.loading) return const SizedBox.shrink();

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
              onPressed: () => notifier.pickAndRecognize(ImageSource.gallery),
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
              onPressed: () => notifier.pickAndRecognize(ImageSource.camera),
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
