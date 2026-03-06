import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/result_action_bar.dart';
import '../viewmodel/document_scanner_provider.dart';

class DocumentScannerScreen extends ConsumerWidget {
  const DocumentScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentScannerProvider);
    final notifier = ref.read(documentScannerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.documentScanner),
        actions: [
          if (state.status == DocStatus.success)
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
              height: 200.h,
              color: Colors.black,
              child: Image.file(state.imageFile!, fit: BoxFit.contain),
            ),
          Expanded(child: _buildBody(context, state)),
          _buildBottomBar(context, notifier, state),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DocState state) {
    switch (state.status) {
      case DocStatus.idle:
        return EmptyStateWidget(
          icon: Icons.document_scanner_rounded,
          title: AppString.documentScanner,
          subtitle: 'Capture or pick a document to extract its text',
        );
      case DocStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Scanning document...'),
            ],
          ),
        );
      case DocStatus.error:
        return Center(child: Text(state.errorMessage));
      case DocStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppString.extractedContent,
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
                      color: ColorManager.infoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.extractedText.split('\n').length} lines',
                      style: TextStyle(
                        color: ColorManager.infoColor,
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
                  ? const Center(child: Text(AppString.noDocumentFound))
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
                        child: SelectableText(
                          state.extractedText,
                          style: TextStyle(fontSize: 13.sp, height: 1.7),
                        ),
                      ),
                    ),
            ),
            if (state.extractedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ResultActionBar(text: state.extractedText),
              ),
          ],
        );
    }
  }

  Widget _buildBottomBar(
    BuildContext context,
    DocumentScannerNotifier notifier,
    DocState state,
  ) {
    if (state.status == DocStatus.loading) return const SizedBox.shrink();
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
              onPressed: () => notifier.scanDocument(ImageSource.gallery),
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
              onPressed: () => notifier.scanDocument(ImageSource.camera),
              icon: const Icon(Icons.document_scanner_rounded),
              label: const Text('Scan Doc'),
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
