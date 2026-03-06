import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing bottom navigation state
final bottomNavIndexProvider = NotifierProvider<BottomNavNotifier, int>(
  BottomNavNotifier.new,
);

/// Notifier for bottom navigation index
class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Change the current tab index
  void setIndex(int index) {
    state = index;
  }

  /// Reset to home tab
  void resetToHome() {
    state = 0;
  }
}
