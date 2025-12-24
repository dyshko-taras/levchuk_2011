import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xs = 3.3;
  static const double sm = 6.6;
  static const double md = 9.9;
  static const double lg = 13.2;
  static const double xl = 16.5;
  static const double x2l = 31.68;
}

class Insets {
  const Insets._();

  static const EdgeInsets allXs = EdgeInsets.all(AppSpacing.xs);
  static const EdgeInsets allSm = EdgeInsets.all(AppSpacing.sm);
  static const EdgeInsets allMd = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets allLg = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets allXl = EdgeInsets.all(AppSpacing.xl);

  static const EdgeInsets hSm = EdgeInsets.symmetric(horizontal: AppSpacing.sm);
  static const EdgeInsets hMd = EdgeInsets.symmetric(horizontal: AppSpacing.md);
  static const EdgeInsets hLg = EdgeInsets.symmetric(horizontal: AppSpacing.lg);
  static const EdgeInsets hXl = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

  static const EdgeInsets vSm = EdgeInsets.symmetric(vertical: AppSpacing.sm);
  static const EdgeInsets vMd = EdgeInsets.symmetric(vertical: AppSpacing.md);
  static const EdgeInsets vLg = EdgeInsets.symmetric(vertical: AppSpacing.lg);
  static const EdgeInsets vXl = EdgeInsets.symmetric(vertical: AppSpacing.xl);
}

class Gaps {
  const Gaps._();

  static const SizedBox hXs = SizedBox(height: AppSpacing.xs);
  static const SizedBox hSm = SizedBox(height: AppSpacing.sm);
  static const SizedBox hMd = SizedBox(height: AppSpacing.md);
  static const SizedBox hLg = SizedBox(height: AppSpacing.lg);
  static const SizedBox hXl = SizedBox(height: AppSpacing.xl);
  static const SizedBox h2Xl = SizedBox(height: AppSpacing.x2l);

  static const SizedBox wXs = SizedBox(width: AppSpacing.xs);
  static const SizedBox wSm = SizedBox(width: AppSpacing.sm);
  static const SizedBox wMd = SizedBox(width: AppSpacing.md);
  static const SizedBox wLg = SizedBox(width: AppSpacing.lg);
  static const SizedBox wXl = SizedBox(width: AppSpacing.xl);
  static const SizedBox w2Xl = SizedBox(width: AppSpacing.x2l);
}

extension NumSpaceExtension on num {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}
