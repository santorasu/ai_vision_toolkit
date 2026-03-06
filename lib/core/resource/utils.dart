import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../constansts/color_manger.dart';

class Utils {
  // formatDateTime
  static String formatDateTime(DateTime date) {
    final DateFormat formatter = DateFormat(
      'yyyy-MM-dd',
    ); // Customize your format here
    return formatter.format(date);
  }

  // calculateTimeAgo
  static String calculateTimeAgo(String dateString) {
    try {
      final notificationTime = DateTime.parse(dateString);
      final difference = DateTime.now().difference(notificationTime);

      if (difference.inDays >= 3) {
        return formatDateTime(notificationTime);
      } else if (difference.inDays >= 1) {
        return '${difference.inDays} ${difference.inDays == 1 ? "day" : "days"} ago';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours} ${difference.inHours == 1 ? "hr" : "hrs"} ago';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? "min" : "mins"} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  // isOnline
  static Future<bool> isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.ethernet)) {
        return true;
      } else {
        alertOfflineActivity();
        return false;
      }
    } on PlatformException catch (e) {
      throw Exception('Could not check connectivity status: $e');
    }
  }

  // alertOfflineActivity
  static void alertOfflineActivity() {
    Fluttertoast.showToast(
      msg: "Please connect to internet",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // showErrorToast
  static Future<bool?> showErrorToast({required String message}) {
    return Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // showToast
  static void showToast({
    required String message,
    required Color backgroundColor,
    required Color textColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }

  // isTablet
  bool isTablet(BuildContext context) {
    if (MediaQuery.of(context).size.width > 600) {
      return true;
    } else {
      return false;
    }
  }

  // fullWidth
  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // fullHeight
  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Set status bar and navigation bar style based on background brightness
  static void setStatusBarStyle(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Status bar
        statusBarColor: Colors.transparent,

        // ANDROID: icon color
        statusBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,

        // IOS: text color (OPPOSITE of icon brightness)
        statusBarBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,

        // Navigation bar
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  // selectDate
  static Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ColorManager.whiteColor, // header background
              onPrimary: ColorManager.blackColor, // header text color
              onSurface: ColorManager.whiteColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorManager.whiteColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
    }
  }
}
