import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/providers/favorites_provider.dart';
import 'package:ice_line_tracker/providers/home_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:provider/provider.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    required this.game,
    this.enableNavigation = true,
    this.onTap,
    super.key,
  });

  final NhlScheduledGame game;
  final bool enableNavigation;
  final VoidCallback? onTap;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    final home = context.read<HomeProvider>();
    final details = context.select<HomeProvider, HomeGameDetails?>(
      (p) => p.detailsForGame(game.id),
    );
    if (details == null) {
      unawaited(home.ensureGameDetails(game.id));
    }

    final status = gameStatusForGame(game);
    final statusLabel = _statusLabel(game, status, details);
    final scoreLabel = _scoreLabel(game, status);
    final subLabel = _hintLabel(status, details);

    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavoriteGame(game.id);
    final alertsEnabled =
        favorites.getGameAlertEnabled(game.id, GameAlertType.goals) ||
        favorites.getGameAlertEnabled(game.id, GameAlertType.final_);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            onTap ??
            (enableNavigation
                ? () => Navigator.of(context).pushNamed(
                    AppRoutes.gameCenter,
                    arguments: game,
                  )
                : null),
        borderRadius: AppRadius.md,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGray,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TeamColumn(
                    logoUrl: game.awayTeam.logo,
                    abbrev: game.awayTeam.abbrev,
                    name: game.awayTeam.commonName.defaultName,
                    alignEnd: false,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          scoreLabel,
                          style: AppFonts.displayLarge.copyWith(
                            color: AppColors.textBlack,
                          ),
                        ),
                        Gaps.hSm,
                        _StatusChip(
                          label: statusLabel,
                          color: _statusColor(status),
                        ),
                        Gaps.hSm,
                        Text(
                          _shotsLabel(details),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  _TeamColumn(
                    logoUrl: game.homeTeam.logo,
                    abbrev: game.homeTeam.abbrev,
                    name: game.homeTeam.commonName.defaultName,
                    alignEnd: true,
                  ),
                ],
              ),
              const Divider(
                height: AppSpacing.xl,
                color: AppColors.borderGray,
              ),
              if (subLabel != null) ...[
                Gaps.hMd,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subLabel,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    _ActionButtonRow(
                      alertsEnabled: alertsEnabled,
                      favoriteEnabled: isFavorite,
                      onToggleAlerts: () => unawaited(
                        _toggleAlerts(favorites, game.id, alertsEnabled),
                      ),
                      onToggleFavorite: () =>
                          unawaited(favorites.toggleFavoriteGame(game.id)),
                    ),
                  ],
                ),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: _ActionButtonRow(
                    alertsEnabled: alertsEnabled,
                    favoriteEnabled: isFavorite,
                    onToggleAlerts: () => unawaited(
                      _toggleAlerts(favorites, game.id, alertsEnabled),
                    ),
                    onToggleFavorite: () =>
                        unawaited(favorites.toggleFavoriteGame(game.id)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleAlerts(
    FavoritesProvider favorites,
    int gameId,
    bool currentlyEnabled,
  ) async {
    final next = !currentlyEnabled;
    await favorites.setGameAlertEnabled(
      gameId,
      GameAlertType.goals,
      enabled: next,
    );
    await favorites.setGameAlertEnabled(
      gameId,
      GameAlertType.final_,
      enabled: next,
    );
  }

  static Color _statusColor(GameStatus status) => switch (status) {
    GameStatus.live => AppColors.primaryRed,
    GameStatus.upcoming => AppColors.scheduledGreen,
    GameStatus.final_ => AppColors.liveCyan,
    GameStatus.postponed => AppColors.postponedOrange,
  };

  static String _scoreLabel(NhlScheduledGame game, GameStatus status) {
    final a = game.awayTeam.score;
    final h = game.homeTeam.score;
    if (status == GameStatus.upcoming || a == null || h == null) {
      return '—  —';
    }
    return '$a – $h';
  }

  static String _shotsLabel(HomeGameDetails? details) {
    final away = details?.awaySog;
    final home = details?.homeSog;
    if (away == null || home == null) return 'Shots: —';
    return 'Shots: $away – $home';
  }

  static String _statusLabel(
    NhlScheduledGame game,
    GameStatus status,
    HomeGameDetails? details,
  ) {
    if (status == GameStatus.final_) return AppStrings.final_;
    if (status == GameStatus.postponed) return AppStrings.gameStatusPostponed;

    if (status == GameStatus.upcoming) {
      final dt = DateTime.tryParse(game.startTimeUTC)?.toLocal();
      if (dt == null) return AppStrings.gameStatusScheduled;
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return 'Scheduled\n$hour:$minute $amPm';
    }

    final periodText = _periodLabel(details);
    final timeRemaining = details?.timeRemaining;
    if (periodText == null || timeRemaining == null) {
      return AppStrings.gameStatusLive;
    }
    return '$periodText • $timeRemaining';
  }

  static String? _hintLabel(GameStatus status, HomeGameDetails? details) {
    return switch (status) {
      GameStatus.live when details?.inIntermission ?? false => 'Intermission',
      GameStatus.live => 'Live',
      _ => null,
    };
  }

  static String? _periodLabel(HomeGameDetails? details) {
    final number = details?.periodNumber;
    final type = details?.periodType?.toUpperCase();
    if (number == null) return null;

    if (type == 'OT') return 'OT';
    if (type == 'SO') return 'SO';

    return switch (number) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      _ => '${number}th',
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppFonts.captionSemibold.copyWith(color: Colors.white),
        textAlign: .center,
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.logoUrl,
    required this.abbrev,
    required this.name,
    required this.alignEnd,
  });

  final String logoUrl;
  final String abbrev;
  final String name;
  final bool alignEnd;

  static const double _logoSize = 72;

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          SvgPicture.network(
            logoUrl,
            width: _logoSize,
            height: _logoSize,
            placeholderBuilder: (context) => const SizedBox(
              width: _logoSize,
              height: _logoSize,
            ),
          ),
          Gaps.hXs,
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          ),
        ],
      ),
    );
  }
}

class _ActionButtonRow extends StatelessWidget {
  const _ActionButtonRow({
    required this.alertsEnabled,
    required this.favoriteEnabled,
    required this.onToggleAlerts,
    required this.onToggleFavorite,
  });

  final bool alertsEnabled;
  final bool favoriteEnabled;
  final VoidCallback onToggleAlerts;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconTileButton(
          iconPath: AppIcons.heartOutline,
          isActive: alertsEnabled,
          tooltip: AppStrings.toggleNotifications,
          onTap: onToggleAlerts,
        ),
        Gaps.wSm,
        _IconTileButton(
          iconPath: favoriteEnabled
              ? AppIcons.starFilled
              : AppIcons.starOutline,
          isActive: favoriteEnabled,
          tooltip: AppStrings.toggleFavorite,
          onTap: onToggleFavorite,
        ),
      ],
    );
  }
}

class _IconTileButton extends StatelessWidget {
  const _IconTileButton({
    required this.iconPath,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  final String iconPath;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  static const double _size = 44;
  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const double _iconSize = AppSizes.iconSm;

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? AppColors.textBlack : Colors.black54;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.borderGray,
        borderRadius: AppRadius.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.md,
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              borderRadius: AppRadius.md,
              border: Border.all(color: _borderColor, width: _borderWidth),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: _iconSize,
                height: _iconSize,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum GameStatus { live, upcoming, final_, postponed }

GameStatus gameStatusForGame(NhlScheduledGame game) {
  final state = game.gameState.toUpperCase();
  final scheduleState = game.gameScheduleState.toUpperCase();

  if (scheduleState == 'PPD' || scheduleState == 'PST') {
    return GameStatus.postponed;
  }

  if (state == 'OFF' || state == 'FINAL') return GameStatus.final_;
  if (state == 'FUT' || state == 'PRE') return GameStatus.upcoming;

  return GameStatus.live;
}
