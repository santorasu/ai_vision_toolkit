import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../viewmodel/color_detection_provider.dart';

class ColorDetectionScreen extends ConsumerWidget {
  const ColorDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(colorDetectionProvider);
    final notifier = ref.read(colorDetectionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.colorDetection),
        actions: [
          if (state.status == ColorDetectionStatus.success)
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

  Widget _buildBody(BuildContext context, ColorDetectionState state) {
    switch (state.status) {
      case ColorDetectionStatus.idle:
        return EmptyStateWidget(
          icon: Icons.color_lens_rounded,
          title: AppString.colorDetection,
          subtitle: AppString.tapToSelectImage,
        );
      case ColorDetectionStatus.loading:
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
      case ColorDetectionStatus.error:
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
      case ColorDetectionStatus.success:
        if (state.palette == null || state.palette!.colors.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.format_color_reset_rounded,
            title: AppString.noColorFound,
            subtitle: 'Try a different image',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDominantColorCard(context, state.palette!),
            const SizedBox(height: 24),
            Text(
              AppString.colorPalette,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPaletteGrid(context, state.palette!),
          ],
        );
    }
  }

  Widget _buildDominantColorCard(
    BuildContext context,
    PaletteGenerator palette,
  ) {
    final dominant = palette.dominantColor?.color ?? palette.colors.first;
    final hex = _colorToHex(dominant);
    final intensity = dominant.computeLuminance();

    return Container(
      decoration: BoxDecoration(
        color: dominant,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: ColorManager.shadowColor,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.primaryColor,
                style: TextStyle(
                  color: intensity > 0.5 ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.copy_rounded,
                  color: intensity > 0.5 ? Colors.black54 : Colors.white70,
                  size: 20,
                ),
                onPressed: () => _copyToClipboard(context, hex),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hex,
            style: TextStyle(
              color: intensity > 0.5 ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28.sp,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            // ignore: deprecated_member_use
            'RGB(${dominant.red}, ${dominant.green}, ${dominant.blue})',
            style: TextStyle(
              color: intensity > 0.5 ? Colors.black54 : Colors.white70,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteGrid(BuildContext context, PaletteGenerator palette) {
    // Collect all unique colors
    final colors = palette.colors.take(8).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        final hex = _colorToHex(color);
        return GestureDetector(
          onTap: () => _copyToClipboard(context, hex),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorManager.borderColor, width: 0.5),
              boxShadow: const [
                BoxShadow(
                  color: ColorManager.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied $text to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _colorToHex(Color color) {
    // ignore: deprecated_member_use
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Widget _buildBottomBar(
    BuildContext context,
    ColorDetectionNotifier notifier,
    ColorDetectionStatus status,
  ) {
    if (status == ColorDetectionStatus.loading) return const SizedBox.shrink();
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
              onPressed: () => notifier.pickImage(ImageSource.gallery),
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
              onPressed: () => notifier.pickImage(ImageSource.camera),
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
