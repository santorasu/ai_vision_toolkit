import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../widgets/empty_state_widget.dart';
import '../viewmodel/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh list when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.scanHistoryTitle),
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => _showClearDialog(context, notifier),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: notifier.search,
              decoration: InputDecoration(
                hintText: AppString.searchHistory,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          notifier.search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ColorManager.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ColorManager.borderColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Count badge
          if (state.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    '${state.items.length} result${state.items.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

          Expanded(
            child: state.items.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.history_rounded,
                    title: AppString.noHistory,
                    subtitle: AppString.noHistorySubtitle,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _buildHistoryCard(context, item, notifier);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    item,
    HistoryNotifier notifier,
  ) {
    final typeInfo = _getTypeInfo(item.type as String);

    return Dismissible(
      key: Key(item.id as String),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ColorManager.errorColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => notifier.delete(item.id as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorManager.borderColor, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: ColorManager.shadowColor,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: typeInfo['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeInfo['icon'], color: typeInfo['color'], size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeInfo['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeInfo['label'],
                          style: TextStyle(
                            color: typeInfo['color'],
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM d, h:mm a',
                        ).format(item.createdAt as DateTime),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (item.result as String).replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getTypeInfo(String type) {
    switch (type) {
      case 'ocr':
        return {
          'icon': Icons.text_fields_rounded,
          'label': 'OCR',
          'color': const Color(0xFF3D5AFE),
        };
      case 'face':
        return {
          'icon': Icons.face_retouching_natural,
          'label': 'Face',
          'color': const Color(0xFFE91E63),
        };
      case 'barcode':
        return {
          'icon': Icons.qr_code_rounded,
          'label': 'Barcode',
          'color': const Color(0xFF00897B),
        };
      case 'label':
        return {
          'icon': Icons.label_rounded,
          'label': 'Labels',
          'color': const Color(0xFFFF6D00),
        };
      case 'pose':
        return {
          'icon': Icons.accessibility_new_rounded,
          'label': 'Pose',
          'color': const Color(0xFF6200EA),
        };
      case 'document':
        return {
          'icon': Icons.document_scanner_rounded,
          'label': 'Document',
          'color': const Color(0xFF0097A7),
        };
      default:
        return {
          'icon': Icons.history_rounded,
          'label': type,
          'color': ColorManager.primary,
        };
    }
  }

  Future<void> _showClearDialog(
    BuildContext context,
    HistoryNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(AppString.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppString.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppString.delete,
              style: TextStyle(color: ColorManager.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      notifier.clearAll();
    }
  }
}
