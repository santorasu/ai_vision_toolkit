import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';

class ResultActionBar extends StatelessWidget {
  final String text;
  final VoidCallback? onSave;

  const ResultActionBar({super.key, required this.text, this.onSave});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppString.copied),
        backgroundColor: ColorManager.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareText() async {
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.copy_rounded,
            label: AppString.copy,
            color: ColorManager.infoColor,
            onTap: () => _copyToClipboard(context),
          ),
          _divider(),
          _ActionButton(
            icon: Icons.share_rounded,
            label: AppString.share,
            color: ColorManager.successColor,
            onTap: _shareText,
          ),
          if (onSave != null) ...[
            _divider(),
            _ActionButton(
              icon: Icons.bookmark_add_rounded,
              label: AppString.save,
              color: ColorManager.warningColor,
              onTap: onSave!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: ColorManager.borderColor);
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
