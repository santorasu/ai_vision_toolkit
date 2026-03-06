import 'package:flutter/material.dart';
import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';

class PermissionDeniedWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PermissionDeniedWidget({
    super.key,
    this.message = AppString.permissionDeniedMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorManager.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.no_photography_outlined,
                size: 40,
                color: ColorManager.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Permission Required',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppString.retry),
            ),
          ],
        ),
      ),
    );
  }
}
