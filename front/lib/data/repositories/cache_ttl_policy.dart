class CacheTtlPolicy {
  const CacheTtlPolicy._();

  static const Duration historical = Duration(days: 7);
  static const Duration currentGame = Duration(minutes: 15);
  static const Duration futureGames = Duration(hours: 1);

  static Duration forDate({
    required String yyyyMmDd,
    DateTime? nowUtc,
  }) {
    final now = nowUtc ?? DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return futureGames;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return futureGames;

    final date = DateTime.utc(year, month, day);
    if (date.isBefore(today)) return historical;
    if (date.isAtSameMomentAs(today)) return currentGame;
    return futureGames;
  }
}
