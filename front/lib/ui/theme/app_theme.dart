import 'package:flutter/material.dart';

import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';

ThemeData appTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryRed,
    primary: AppColors.primaryRed,
    surface: AppColors.surfaceGray,
  );

  return ThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.backgroundWhite,
    fontFamily: AppFonts.familyOpenSans,
    textTheme: const TextTheme(
      displayLarge: AppFonts.displayLarge,
      titleLarge: AppFonts.heading1,
      titleMedium: AppFonts.heading2,
      titleSmall: AppFonts.heading3,
      bodyLarge: AppFonts.bodyLarge,
      bodyMedium: AppFonts.bodyRegular,
      bodySmall: AppFonts.caption,
      labelLarge: AppFonts.bodySemibold,
      labelSmall: AppFonts.captionSemibold,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundWhite,
      foregroundColor: AppColors.textBlack,
      elevation: 0,
    ),
  );
}
