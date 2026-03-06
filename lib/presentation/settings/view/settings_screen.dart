import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../history/viewmodel/history_provider.dart';
import '../viewmodel/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final historyNotifier = ref.read(historyProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(AppString.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark
                ? const Color(0xFF6200EA)
                : const Color(0xFFFF6D00),
            title: AppString.darkMode,
            subtitle: isDark ? 'Dark mode is ON' : 'Light mode is ON',
            trailing: Switch(
              value: isDark,
              onChanged: (_) => notifier.toggleTheme(),
              activeThumbColor: ColorManager.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Data Section
          _SectionHeader(title: 'Data'),
          _SettingsTile(
            icon: Icons.delete_sweep_rounded,
            iconColor: ColorManager.errorColor,
            title: AppString.clearHistorySettings,
            subtitle: AppString.clearHistorySubtitle,
            onTap: () async {
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
                historyNotifier.clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('History cleared'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),

          // AI Features Section
          _SectionHeader(title: 'AI Features'),
          _SettingsTile(
            icon: Icons.psychology_rounded,
            iconColor: const Color(0xFF3D5AFE),
            title: AppString.aiFeaturesSubtitle,
            subtitle:
                'Text Recognition, Face Detection, Barcode Scanner, Image Labeling, Pose Detection, Document Scanner',
          ),
          const SizedBox(height: 16),

          // About Section
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_rounded,
            iconColor: ColorManager.infoColor,
            title: AppString.aboutApp,
            subtitle: AppString.appDescription,
          ),
          const SizedBox(height: 16),

          // App version
          Center(
            child: Text(
              AppString.appVersion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Built with Google ML Kit & Flutter',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10.sp),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: ColorManager.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right, color: ColorManager.textSecondary)
                : null),
      ),
    );
  }
}
