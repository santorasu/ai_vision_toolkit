import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider - toggled from settings screen
final themeProvider = NotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<bool> {
  static const _key = 'isDarkMode';

  @override
  bool build() {
    _loadTheme();
    return false; // default light
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}
