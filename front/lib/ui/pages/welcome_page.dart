import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_images.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/providers/prefs_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void _onGetStartedPressed() {
    unawaited(_getStarted());
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PrefsProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _WelcomeHero(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.x2l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.welcomeDefaultDateLabel,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DatePresetSegmented(
                        value: prefs.draftDefaultDatePreset,
                        onChanged: prefs.setDraftDefaultDatePreset,
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.welcomePushAlertsLabel,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Switch.adaptive(
                            value: prefs.draftPushAlertsEnabled,
                            onChanged: prefs.saving
                                ? null
                                : (v) => prefs.setDraftPushAlertsEnabled(
                                      enabled: v,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppStrings.welcomePushAlertsHelper,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: prefs.saving ? null : _onGetStartedPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.lg,
                            ),
                            textStyle: AppFonts.heading2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          child: prefs.saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(AppStrings.getStarted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getStarted() async {
    final prefs = context.read<PrefsProvider>();
    await prefs.completeWelcome();

    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final heroHeight = (height * 0.52).clamp(320.0, 520.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.welcomeHero,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.15),
                    AppColors.backgroundWhite.withValues(alpha: 0.85),
                    AppColors.backgroundWhite,
                  ],
                  stops: const [0, 0.55, 0.82, 1],
                ),
              ),
            ),
          ),
          Align(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: AppFonts.heading1.copyWith(
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.welcomeDescription,
                    textAlign: TextAlign.center,
                    style: AppFonts.bodyLarge.copyWith(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textBlack.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePresetSegmented extends StatelessWidget {
  const _DatePresetSegmented({
    required this.value,
    required this.onChanged,
  });

  final DefaultDatePreset value;
  final ValueChanged<DefaultDatePreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: AppRadius.lg,
        border: Border.all(color: const Color(0x33000000), width: 0.66),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: AppStrings.today,
            isSelected: value == DefaultDatePreset.today,
            onTap: () => onChanged(DefaultDatePreset.today),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lgValue),
              bottomLeft: Radius.circular(AppRadius.lgValue),
            ),
          ),
          _SegmentButton(
            label: AppStrings.yesterday,
            isSelected: value == DefaultDatePreset.yesterday,
            onTap: () => onChanged(DefaultDatePreset.yesterday),
          ),
          _SegmentButton(
            label: AppStrings.tomorrow,
            isSelected: value == DefaultDatePreset.tomorrow,
            onTap: () => onChanged(DefaultDatePreset.tomorrow),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(AppRadius.lgValue),
              bottomRight: Radius.circular(AppRadius.lgValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.borderRadius,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryRed : Colors.transparent,
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  label,
                  style: AppFonts.heading2.copyWith(
                    fontSize: 21,
                    color: isSelected ? Colors.white : AppColors.textBlack,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
