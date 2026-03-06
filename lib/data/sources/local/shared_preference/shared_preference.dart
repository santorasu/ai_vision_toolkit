import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreference data management utility.
/// All methods are static for easy access throughout the app.
class SharedPreferenceData {
  SharedPreferenceData._();

  // ===== ONBOARDING TOKEN =====
  static Future<void> setRegisterToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('onboarding_token', "$token");
  }

  static Future<String?> getRegisterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('onboarding_token');
  }

  static Future<void> removeRegisterToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('onboarding_token');
  }

  // ===== AUTH TOKEN =====
  static Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', "$token");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
  }

  // ===== FIRST TIME =====
  static Future<void> firstTimeSet(bool? value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('first', value ?? false);
  }

  static Future<bool?> firstTimeGet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first');
  }

  static Future<void> firstTimeRemove() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('first');
  }

  // ===== RESET TOKEN =====
  static Future<void> setResetToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('reset_token', "$token");
  }

  static Future<String?> getResetToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reset_token');
  }

  static Future<void> removeResetToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('reset_token');
  }

  // ===== FCM TOKEN =====
  static Future<void> setFcmToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fcm_token', "$token");
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  static Future<void> removeFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('fcm_token');
  }

  // ===== ROLE =====
  static Future<void> setRole(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('role', "$role");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> removeRole() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('role');
  }

  // ===== EMAIL =====
  static Future<void> setEmailId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', id ?? "");
  }

  static Future<String?> getEmailId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<void> removeEmailId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
  }

  // ===== NOTIFICATION =====
  static Future<void> setHasUnreadNotifications(bool hasUnread) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('has_unread', hasUnread);
  }

  static Future<bool> getHasUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_unread') ?? false;
  }

  static Future<void> setLastNotificationCheckTime(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_check_time', timestamp);
  }

  static Future<String?> getLastNotificationCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_check_time');
  }

  // ===== CLEAR ALL =====
  /// Clears all stored preferences. Useful for logout.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Clears only auth-related data (for logout without clearing settings)
  static Future<void> clearAuthData() async {
    await removeToken();
    await removeEmailId();
    await removeRole();
    await removeFcmToken();
  }
}
