import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_gradients.dart';

enum MainTab {
  home,
  standings,
  compare,
  favorites,
  predictions,
}

class MainShellPage extends StatefulWidget {
  const MainShellPage({
    required this.initialTab,
    super.key,
  });

  final MainTab initialTab;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late MainTab _tab;
  late int _navIndex;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _navIndex = _tabToIndex(_tab) ?? 0;
  }

  int? _tabToIndex(MainTab tab) {
    return switch (tab) {
      MainTab.standings => 0,
      MainTab.compare => 1,
      MainTab.favorites => 2,
      MainTab.predictions => 3,
      MainTab.home => 4,
    };
  }

  @override
  Widget build(BuildContext context) {
    const tabs = <_TabSpec>[
      _TabSpec(
        iconPath: AppIcons.navStandings,
        tab: MainTab.standings,
      ),
      _TabSpec(
        iconPath: AppIcons.navCompare,
        tab: MainTab.compare,
      ),
      _TabSpec(
        iconPath: AppIcons.navFavorites,
        tab: MainTab.favorites,
      ),
      _TabSpec(
        iconPath: AppIcons.navPredictions,
        tab: MainTab.predictions,
      ),
      _TabSpec(
        iconPath: AppIcons.navHome,
        tab: MainTab.home,
      ),
    ];

    final activeLabel = switch (_tab) {
      MainTab.home => AppStrings.navHome,
      MainTab.standings => AppStrings.navStandings,
      MainTab.compare => AppStrings.navCompare,
      MainTab.favorites => AppStrings.navFavorites,
      MainTab.predictions => AppStrings.navPredictions,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(activeLabel),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings),
            tooltip: AppStrings.openSettings,
          ),
        ],
      ),
      body: Center(child: Text(activeLabel)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.lg,
        ),
        child: Container(
          height: AppSizes.bottomNavHeight,
          decoration: BoxDecoration(
            gradient: AppGradients.bottomNav,
            borderRadius: BorderRadius.circular(AppRadius.bottomNavValue),
            border: Border.all(
              color: const Color(0x33000000),
              width: 0.66,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 1.32),
                blurRadius: 1.32,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.bottomNavValue),
            child: AnimatedBottomNavigationBar.builder(
              itemCount: tabs.length,
              tabBuilder: (index, isActive) {
                final iconColor = isActive
                    ? AppColors.textBlack
                    : Colors.black54;

                return Center(
                  child: Material(
                    color: AppColors.borderGray,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: const Color(0x33000000),
                    child: SizedBox(
                      width: AppSizes.bottomNavItemDiameter,
                      height: AppSizes.bottomNavItemDiameter,
                      child: Center(
                        child: SvgPicture.asset(
                          tabs[index].iconPath,
                          width: AppSizes.iconSm,
                          height: AppSizes.iconSm,
                          colorFilter:
                              ColorFilter.mode(iconColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                );
              },
              activeIndex: _navIndex,
              onTap: (index) {
                setState(() {
                  _navIndex = index;
                  _tab = tabs[index].tab;
                });
              },
              height: AppSizes.bottomNavHeight,
              gapLocation: GapLocation.none,
              backgroundColor: Colors.transparent,
              elevation: 0,
              splashColor: Colors.transparent,
              splashRadius: 0,
              scaleFactor: 0,
              safeAreaValues: const SafeAreaValues(
                left: false,
                top: false,
                right: false,
                bottom: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.iconPath,
    required this.tab,
  });

  final String iconPath;
  final MainTab tab;
}
