import 'package:flutter/material.dart';

import '../constansts/color_manger.dart';
import 'font_manager.dart';
import 'style_manager.dart';
import 'values_manager.dart';

ThemeData getApplicationTheme({bool isDark = false}) {
  if (isDark) {
    return _buildDarkTheme();
  }
  return _buildLightTheme();
}

ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryLight,
    primaryColorDark: ColorManager.primaryDark,
    disabledColor: ColorManager.textSecondary,
    splashColor: ColorManager.primaryDark,
    scaffoldBackgroundColor: ColorManager.background,

    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: ColorManager.primaryDark,
      error: ColorManager.errorColor,
      surface: ColorManager.whiteColor,
    ),

    cardTheme: CardThemeData(
      color: ColorManager.whiteColor,
      shadowColor: ColorManager.shadowColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColorManager.borderColor, width: 0.5),
      ),
    ),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: ColorManager.background,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorManager.primary),
      titleTextStyle: getSemiBold600Style12(
        color: ColorManager.titleText,
        fontSize: FontSize.s18,
      ),
    ),

    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      disabledColor: ColorManager.textSecondary,
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.primaryDark,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        foregroundColor: ColorManager.whiteColor,
        textStyle: getRegular400Style12(
          color: ColorManager.whiteColor,
          fontSize: FontSize.s16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p16,
          vertical: AppPadding.p12,
        ),
      ),
    ),

    textTheme: TextTheme(
      headlineLarge: getSemiBold600Style12(
        color: ColorManager.blackColor,
        fontSize: FontSize.s20,
      ),
      titleMedium: getMedium500Style12(
        color: ColorManager.blackColor,
        fontSize: FontSize.s16,
      ),
      bodyMedium: getRegular400Style12(
        color: ColorManager.blackColor,
        fontSize: FontSize.s14,
      ),
      bodySmall: getRegular400Style12(
        color: ColorManager.subtitleText,
        fontSize: FontSize.s12,
      ),
      labelLarge: getSemiBold600Style12(
        color: ColorManager.primary,
        fontSize: FontSize.s14,
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorManager.primary,
      selectionColor: ColorManager.primary.withValues(alpha: 0.1),
      selectionHandleColor: ColorManager.primary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorManager.whiteColor,
      hintStyle: getRegular400Style12(color: ColorManager.textSecondary),
      labelStyle: getMedium500Style12(color: ColorManager.blackColor),
      helperStyle: getRegular400Style12(color: ColorManager.blackColor),
      errorStyle: getRegular400Style12(color: ColorManager.errorColor),
      contentPadding: const EdgeInsets.all(AppPadding.p12),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.borderColor,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.borderColor1,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.errorColor,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.errorColor,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    ),

    iconTheme: IconThemeData(color: ColorManager.primary, size: AppSize.s24),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryLight,
    primaryColorDark: ColorManager.primaryDark,
    disabledColor: ColorManager.textSecondary,
    splashColor: ColorManager.primaryDark,
    scaffoldBackgroundColor: ColorManager.backgroundDark,

    colorScheme: const ColorScheme.dark().copyWith(
      primary: ColorManager.primary,
      secondary: ColorManager.primaryLight,
      error: ColorManager.errorColor,
      surface: ColorManager.scaffoldDark,
    ),

    cardTheme: CardThemeData(
      color: ColorManager.scaffoldDark,
      shadowColor: Colors.black54,
      elevation: AppSize.s4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),
    ),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: getSemiBold600Style12(
        color: ColorManager.whiteColor,
        fontSize: FontSize.s16,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        foregroundColor: ColorManager.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p16,
          vertical: AppPadding.p12,
        ),
      ),
    ),

    textTheme: TextTheme(
      headlineLarge: getSemiBold600Style12(
        color: Colors.white,
        fontSize: FontSize.s20,
      ),
      titleMedium: getMedium500Style12(
        color: Colors.white,
        fontSize: FontSize.s16,
      ),
      bodyMedium: getRegular400Style12(
        color: Colors.white70,
        fontSize: FontSize.s14,
      ),
      bodySmall: getRegular400Style12(
        color: Colors.white54,
        fontSize: FontSize.s12,
      ),
      labelLarge: getSemiBold600Style12(
        color: ColorManager.primaryLight,
        fontSize: FontSize.s14,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorManager.scaffoldDark,
      hintStyle: getRegular400Style12(color: Colors.white38),
      labelStyle: getMedium500Style12(color: Colors.white70),
      contentPadding: const EdgeInsets.all(AppPadding.p12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.white24,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primaryLight,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.errorColor,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.errorColor,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
    ),

    iconTheme: IconThemeData(
      color: ColorManager.primaryLight,
      size: AppSize.s24,
    ),
  );
}
