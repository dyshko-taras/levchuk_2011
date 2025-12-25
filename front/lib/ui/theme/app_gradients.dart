import 'package:flutter/material.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';

class AppGradients {
  const AppGradients._();

  static const LinearGradient bottomNav = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundWhite,
      Color(0xFFCBCBCB),
    ],
  );
}
