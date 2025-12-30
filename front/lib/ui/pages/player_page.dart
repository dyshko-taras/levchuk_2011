import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/player_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  int? _playerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)?.settings.arguments;
    final playerId = switch (arg) {
      int() => arg,
      _ => null,
    };
    if (playerId == null || playerId == _playerId) return;
    _playerId = playerId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<PlayerProvider>().loadNow(playerId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerId = _playerId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(AppStrings.playerTitle),
      ),
      body: Padding(
        padding: Insets.allLg,
        child: playerId == null
            ? const Center(child: Text(AppStrings.notAvailable))
            : Consumer<PlayerProvider>(
                builder: (context, provider, _) {
                  final state = provider.landingState;

                  if (state.isLoading && state.valueOrNull == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.hasError && state.valueOrNull == null) {
                    return const Center(
                      child: Text(AppStrings.splashInitFailed),
                    );
                  }

                  final landing = state.valueOrNull;
                  final name = _playerName(landing);
                  final details = _playerDetails(landing);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PlayerHeaderCard(
                        name: name ?? AppStrings.playerTitle,
                        subtitle: details,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        AppStrings.notAvailable,
                        style: AppFonts.bodyRegular,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _PlayerHeaderCard extends StatelessWidget {
  const _PlayerHeaderCard({
    required this.name,
    required this.subtitle,
  });

  final String name;
  final String? subtitle;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: Insets.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppFonts.heading2.copyWith(color: AppColors.textBlack),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppFonts.bodyRegular,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String? _playerName(Object? landing) {
  if (landing is! Map) return null;
  final m = landing.cast<String, Object?>();
  final firstNameMap = m['firstName'];
  final first = (firstNameMap is Map)
      ? (Map<String, Object?>.from(firstNameMap)['default'] as String?)
      : null;
  final lastNameMap = m['lastName'];
  final last = (lastNameMap is Map)
      ? (Map<String, Object?>.from(lastNameMap)['default'] as String?)
      : null;
  final name = [first, last].whereType<String>().join(' ').trim();
  return name.isEmpty ? null : name;
}

String? _playerDetails(Object? landing) {
  if (landing is! Map) return null;
  final m = landing.cast<String, Object?>();

  final sweaterNumber = m['sweaterNumber'];
  final number = sweaterNumber is num ? sweaterNumber.toInt() : null;
  final position = m['position'] as String?;

  final parts = <String>[
    if (number != null) '#$number',
    if (position != null && position.trim().isNotEmpty) position,
  ];
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}
