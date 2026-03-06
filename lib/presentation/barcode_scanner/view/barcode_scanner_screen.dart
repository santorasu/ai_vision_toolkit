import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/result_action_bar.dart';
import '../viewmodel/barcode_scanner_provider.dart';

class BarcodeScannerScreen extends ConsumerWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(barcodeScannerProvider);
    final notifier = ref.read(barcodeScannerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.barcodeScanner),
        actions: [
          if (state.status == BarcodeStatus.success)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: notifier.reset,
            ),
        ],
      ),
      body: Column(
        children: [
          // Preview
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

  Widget _buildBody(BuildContext context, BarcodeState state) {
    switch (state.status) {
      case BarcodeStatus.idle:
        return EmptyStateWidget(
          icon: Icons.qr_code_scanner_rounded,
          title: AppString.barcodeScanner,
          subtitle: AppString.tapToSelectImage,
        );
      case BarcodeStatus.loading:
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
      case BarcodeStatus.error:
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
      case BarcodeStatus.success:
        if (state.barcodes.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.qr_code_2_rounded,
            title: AppString.noBarcodeFound,
            subtitle: 'Try with a clearer image',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.barcodes.length,
          itemBuilder: (context, index) =>
              _buildBarcodeCard(context, state.barcodes[index], index),
        );
    }
  }

  Widget _buildBarcodeCard(BuildContext context, barcode, int index) {
    final displayValue = barcode.displayValue ?? barcode.rawValue ?? 'Unknown';
    final isUrl =
        displayValue.startsWith('http') || displayValue.startsWith('https');
    final typeLabel = _barcodeTypeLabel(barcode.format.index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        typeLabel,
                        style: const TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isUrl)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.infoColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'URL',
                          style: TextStyle(
                            color: ColorManager.infoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  displayValue,
                  style: TextStyle(fontSize: 14.sp, height: 1.5),
                ),
                if (isUrl) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: displayValue),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('URL copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: const Text(AppString.openUrl),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ResultActionBar(text: displayValue),
          ),
        ],
      ),
    );
  }

  String _barcodeTypeLabel(int format) {
    const labels = {
      0: 'Unknown',
      1: 'Code 128',
      2: 'Code 39',
      4: 'Code 93',
      8: 'Codabar',
      16: 'Data Matrix',
      32: 'EAN-13',
      64: 'EAN-8',
      128: 'ITF',
      256: 'QR Code',
      512: 'UPC-A',
      1024: 'UPC-E',
      2048: 'PDF-417',
      4096: 'Aztec',
    };
    return labels[format] ?? 'Barcode';
  }

  Widget _buildBottomBar(
    BuildContext context,
    BarcodeScannerNotifier notifier,
    BarcodeStatus status,
  ) {
    if (status == BarcodeStatus.loading) return const SizedBox.shrink();
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
              onPressed: () => notifier.scanFromSource(ImageSource.gallery),
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
              onPressed: () => notifier.scanFromSource(ImageSource.camera),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan'),
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
