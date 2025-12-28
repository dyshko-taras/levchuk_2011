import 'package:flutter/material.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';

class AppFonts {
  const AppFonts._();

  static const String familyOpenSans = 'OpenSans';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 33,
    fontWeight: FontWeight.w800,
    height: 1.3,
    color: AppColors.primaryRed,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 23.1,
    fontWeight: FontWeight.w800,
    color: AppColors.textBlack,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 18.48,
    fontWeight: FontWeight.w700,
    color: AppColors.textBlack,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 17.82,
    fontWeight: FontWeight.w600,
    color: AppColors.textBlack,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 16.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 15.84,
    fontWeight: FontWeight.w400,
    color: AppColors.textBlack,
  );

  static const TextStyle bodySemibold = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 15.84,
    fontWeight: FontWeight.w600,
    color: AppColors.textBlack,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 15.84,
    fontWeight: FontWeight.w700,
    color: AppColors.textBlack,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.textGray,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 11.88,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
  );

  static const TextStyle captionSemibold = TextStyle(
    fontFamily: familyOpenSans,
    fontSize: 11.88,
    fontWeight: FontWeight.w600,
    color: AppColors.textBlack,
  );
}
