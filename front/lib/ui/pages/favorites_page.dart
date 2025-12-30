import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_images.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:ice_line_tracker/data/repositories/cached_standings_repository.dart';
import 'package:ice_line_tracker/providers/favorites_provider.dart';
import 'package:ice_line_tracker/services/notification_service.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/common/game_card.dart';
import 'package:ice_line_tracker/ui/widgets/dialogs/notifications_permission_dialog.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:provider/provider.dart';

enum _FavoritesTab { teams, games }

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  _FavoritesTab _tab = _FavoritesTab.teams;

  CachedStandingsRepository? _standingsRepo;
  Future<NhlStandingsResponse>? _standingsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = context.read<CachedStandingsRepository>();
    if (repo == _standingsRepo) return;
    _standingsRepo = repo;
    _standingsFuture = repo.getStandingsNow();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: Insets.allLg,
          child: AppSegmentedControl<_FavoritesTab>(
            value: _tab,
            onChanged: (next) => setState(() => _tab = next),
            items: const [
              AppSegmentedControlItem(
                value: _FavoritesTab.teams,
                label: AppStrings.favoritesTeams,
              ),
              AppSegmentedControlItem(
                value: _FavoritesTab.games,
                label: AppStrings.favoritesGames,
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_tab) {
            _FavoritesTab.teams => _TeamsTab(standingsFuture: _standingsFuture),
            _FavoritesTab.games => const _GamesTab(),
          },
        ),
      ],
    );
  }
}

class _TeamsTab extends StatelessWidget {
  const _TeamsTab({required this.standingsFuture});

  final Future<NhlStandingsResponse>? standingsFuture;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final teams = favorites.favoriteTeamAbbrevs.toList()..sort();

    if (teams.isEmpty) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    final future = standingsFuture;
    if (future == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<NhlStandingsResponse>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final standings = snapshot.data;
        if (standings == null) {
          return const Center(child: Text(AppStrings.splashInitFailed));
        }

        final rowsByAbbrev = <String, NhlStandingRow>{};
        for (final row in standings.standings) {
          rowsByAbbrev[row.teamAbbrev.defaultName] = row;
        }

        return ListView.separated(
          padding: Insets.allLg,
          itemCount: teams.length,
          separatorBuilder: (context, index) => Gaps.hMd,
          itemBuilder: (context, index) {
            final abbrev = teams[index];
            final row = rowsByAbbrev[abbrev];

            return _TeamFavoriteCard(
              teamAbbrev: abbrev,
              logoUrl: row?.teamLogo,
              teamName: row?.teamCommonName.defaultName ?? abbrev,
              divisionConference: row == null
                  ? AppStrings.notAvailable
                  : '${row.divisionName} / ${row.conferenceName}',
              arenaName: AppStrings.notAvailable,
            );
          },
        );
      },
    );
  }
}

class _TeamFavoriteCard extends StatelessWidget {
  const _TeamFavoriteCard({
    required this.teamAbbrev,
    required this.logoUrl,
    required this.teamName,
    required this.divisionConference,
    required this.arenaName,
  });

  final String teamAbbrev;
  final String? logoUrl;
  final String teamName;
  final String divisionConference;
  final String arenaName;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;
  static const double _logoSize = 64;

  @override
  Widget build(BuildContext context) {
    final favorites = context.read<FavoritesProvider>();

    Future<void> removeIfConfirmed() async {
      final confirmed = await _confirmRemoveFromFavorites(context);
      if (!confirmed || !context.mounted) return;
      await favorites.toggleFavoriteTeam(teamAbbrev);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          unawaited(
            Navigator.pushNamed(
              context,
              AppRoutes.team,
              arguments: teamAbbrev,
            ),
          );
        },
        onLongPress: () => unawaited(removeIfConfirmed()),
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _TeamLogo(url: logoUrl, size: _logoSize),
              Gaps.wMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: AppFonts.bodySemibold.copyWith(
                        color: AppColors.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      divisionConference,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      arenaName,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamesTab extends StatelessWidget {
  const _GamesTab();

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final games = favorites.favoriteGameIds.toList()..sort();

    if (games.isEmpty) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    return ListView.separated(
      padding: Insets.allLg,
      itemCount: games.length,
      separatorBuilder: (context, index) => Gaps.hMd,
      itemBuilder: (context, index) {
        final gameId = games[index];
        final game = favorites.getFavoriteGame(gameId);
        return _FavoriteGameCard(gameId: gameId, game: game);
      },
    );
  }
}

class _FavoriteGameCard extends StatelessWidget {
  const _FavoriteGameCard({
    required this.gameId,
    required this.game,
  });

  final int gameId;
  final NhlScheduledGame? game;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final g = game;
    final matchup = g == null
        ? AppStrings.notAvailable
        : '${g.awayTeam.abbrev} @ ${g.homeTeam.abbrev}';

    final status = g == null ? null : gameStatusForGame(g);
    final statusLabel = switch (status) {
      GameStatus.live => AppStrings.gameStatusLive,
      GameStatus.final_ => AppStrings.gameStatusFinal,
      GameStatus.upcoming => AppStrings.gameStatusScheduled,
      GameStatus.postponed => AppStrings.gameStatusPostponed,
      null => AppStrings.notAvailable,
    };
    final statusColor = switch (status) {
      GameStatus.live => AppColors.primaryRed,
      GameStatus.final_ => AppColors.liveCyan,
      GameStatus.upcoming => AppColors.scheduledGreen,
      GameStatus.postponed => AppColors.postponedOrange,
      null => AppColors.borderGray,
    };

    final dateTime = g == null
        ? AppStrings.notAvailable
        : _formatDateTimeLocal(g.startTimeUTC) ?? AppStrings.notAvailable;

    final bellFinal = favorites.getGameAlertEnabled(
      gameId,
      GameAlertType.final_,
    );

    Future<void> removeIfConfirmed() async {
      final confirmed = await _confirmRemoveFromFavorites(context);
      if (!confirmed || !context.mounted) return;
      await favorites.toggleFavoriteGame(gameId);
    }

    Future<void> share() async {
      final shareText = '$matchup\n$dateTime\n$statusLabel';
      await Clipboard.setData(ClipboardData(text: shareText));
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          unawaited(
            Navigator.pushNamed(
              context,
              AppRoutes.gameCenter,
              arguments: g ?? gameId,
            ),
          );
        },
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
          padding: Insets.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      matchup,
                      style: AppFonts.bodyBold.copyWith(
                        color: AppColors.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(label: statusLabel, color: statusColor),
                ],
              ),
              Gaps.hXs,
              Text(dateTime, style: Theme.of(context).textTheme.bodyLarge),
              Gaps.hMd,
              _NotificationToggle(
                label: AppStrings.bellFinal,
                value: bellFinal,
                onChanged: (enabled) => unawaited(
                  _onFinalAlertChanged(
                    context,
                    favorites,
                    gameId: gameId,
                    enabled: enabled,
                    game: g,
                  ),
                ),
              ),
              Gaps.hMd,
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SquareIconButton(
                      iconPath: AppIcons.delete,
                      tooltip: AppStrings.delete,
                      onPressed: () => unawaited(removeIfConfirmed()),
                    ),
                    Gaps.wSm,
                    _SquareIconButton(
                      iconPath: AppIcons.share,
                      tooltip: AppStrings.share,
                      onPressed: () => unawaited(share()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _onFinalAlertChanged(
  BuildContext context,
  FavoritesProvider favorites, {
  required int gameId,
  required bool enabled,
  required NhlScheduledGame? game,
}) async {
  if (enabled) {
    final notifications = context.read<NotificationService>();
    final ok = await notifications.ensureNotificationPermission();
    if (!ok && context.mounted) {
      await NotificationsPermissionDialog.show(context);
      return;
    }
  }

  await favorites.setGameAlertEnabled(
    gameId,
    GameAlertType.final_,
    enabled: enabled,
    game: game,
  );
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppFonts.captionSemibold.copyWith(
              color: AppColors.textBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppFonts.captionSemibold.copyWith(color: AppColors.textBlack),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.iconPath,
    required this.tooltip,
    required this.onPressed,
  });

  final String iconPath;
  final String tooltip;
  final VoidCallback onPressed;

  static const double _size = 41.25;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: AppColors.borderGray,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              colorFilter: const ColorFilter.mode(
                AppColors.textBlack,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text(AppStrings.notAvailable)),
      );
    }
    return SvgPicture.network(u, width: size, height: size);
  }
}

String? _formatDateTimeLocal(String utcIso) {
  final dt = DateTime.tryParse(utcIso)?.toLocal();
  if (dt == null) return null;

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final monthIdx = dt.month - 1;
  if (monthIdx < 0 || monthIdx >= months.length) return null;

  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return '${months[monthIdx]} ${dt.day}, $hour12:$minute $amPm';
}

Future<bool> _confirmRemoveFromFavorites(BuildContext context) async {
  final choice = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: AppColors.surfaceGray,
        insetPadding: Insets.hLg,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        child: Padding(
          padding: Insets.allLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppImages.removeFromFavoritesIllustration,
                height: 140,
                fit: BoxFit.contain,
              ),
              Gaps.hLg,
              const Text(
                AppStrings.removeFromFavoritesQuestion,
                style: AppFonts.heading2,
                textAlign: TextAlign.center,
              ),
              Gaps.hLg,
              AppSegmentedControl<bool>(
                items: const [
                  AppSegmentedControlItem(value: true, label: AppStrings.yes),
                  AppSegmentedControlItem(value: false, label: AppStrings.no),
                ],
                value: true,
                onChanged: (v) => Navigator.of(context).pop(v),
              ),
            ],
          ),
        ),
      );
    },
  );

  return choice ?? false;
}
