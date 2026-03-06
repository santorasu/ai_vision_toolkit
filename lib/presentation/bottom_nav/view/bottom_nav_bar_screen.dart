import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';
import '../../home/view/home_screen.dart';
import '../../history/view/history_screen.dart';
import '../../settings/view/settings_screen.dart';
import '../viewmodel/bottom_nav_provider.dart';

class BottomNavBarScreen extends ConsumerWidget {
  const BottomNavBarScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.grid_view_rounded),
      activeIcon: Icon(Icons.grid_view_rounded),
      label: AppString.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history_rounded),
      activeIcon: Icon(Icons.history_rounded),
      label: AppString.history,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_rounded),
      activeIcon: Icon(Icons.settings_rounded),
      label: AppString.settings,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).setIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E)
              : ColorManager.whiteColor,
          selectedItemColor: ColorManager.primary,
          unselectedItemColor: ColorManager.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          elevation: 0,
          items: _navItems,
        ),
      ),
    );
  }
}
