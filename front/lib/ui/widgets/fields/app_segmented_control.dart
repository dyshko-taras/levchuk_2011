import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/theme/app_gradients.dart';

class AppSegmentedControlItem<T> {
  const AppSegmentedControlItem({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
  }) : assert(
         items.length >= 2 && items.length <= 5,
         'items.length must be between 2 and 5',
       );

  final List<AppSegmentedControlItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);

  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  static const double _segmentPaddingV = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final isScrollable = items.length > 3;

    return Container(
      height: AppSizes.segmentedControlHeight,
      decoration: BoxDecoration(
        gradient: AppGradients.segmentedControl,
        borderRadius: AppRadius.md,
        border: Border.all(color: _borderColor, width: _borderWidth),
        boxShadow: const [
          BoxShadow(
            color: _shadowColor,
            offset: Offset(0, _shadowOffsetY),
            blurRadius: _shadowBlurRadius,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.md,
        child: isScrollable
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildSegments(expand: false),
                ),
              )
            : Row(children: _buildSegments(expand: true)),
      ),
    );
  }

  List<Widget> _buildSegments({required bool expand}) {
    final widgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = item.value == value;
      final radius = _borderRadiusForIndex(i);

      final segment = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(item.value),
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryRed : Colors.transparent,
              borderRadius: radius,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: _segmentPaddingV),
              child: Center(
                child: Text(
                  item.label,
                  style: AppFonts.bodySemibold.copyWith(
                    color: isSelected ? Colors.white : AppColors.textBlack,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      widgets.add(
        expand
            ? Expanded(child: segment)
            : SizedBox(
                width: AppSizes.segmentedControlMinSegmentWidth,
                child: segment,
              ),
      );
    }

    return widgets;
  }

  BorderRadius _borderRadiusForIndex(int index) {
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.mdValue),
        bottomLeft: Radius.circular(AppRadius.mdValue),
      );
    }
    if (index == items.length - 1) {
      return const BorderRadius.only(
        topRight: Radius.circular(AppRadius.mdValue),
        bottomRight: Radius.circular(AppRadius.mdValue),
      );
    }
    return BorderRadius.zero;
  }
}
