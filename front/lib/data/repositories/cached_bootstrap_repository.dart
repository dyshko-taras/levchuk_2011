import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/memory_cache.dart';
import 'package:ice_line_tracker/data/models/nhl_team.dart';
import 'package:ice_line_tracker/data/repositories/bootstrap_repository.dart';
import 'package:ice_line_tracker/data/repositories/cache_keys.dart';
import 'package:ice_line_tracker/data/repositories/cache_ttl_policy.dart';

class CachedBootstrapRepository {
  CachedBootstrapRepository({
    required BootstrapRepository remote,
    required HiveJsonCache diskCache,
    MemoryCache<String, Object?>? memoryCache,
  }) : _remote = remote,
       _diskCache = diskCache,
       _memoryCache = memoryCache ?? MemoryCache<String, Object?>();

  final BootstrapRepository _remote;
  final HiveJsonCache _diskCache;
  final MemoryCache<String, Object?> _memoryCache;

  Future<List<int>> getSeasons({bool forceRefresh = false}) async {
    const key = CacheKeys.seasons;
    const ttl = CacheTtlPolicy.historical;
    final nowUtc = DateTime.now().toUtc();
    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory is List<int>) return memory;

      final cached = _diskCache.readDataWithTtl<List<int>>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: (json) {
          if (json is! List) return <int>[];
          return json.whereType<num>().map((e) => e.toInt()).toList();
        },
      );
      if (cached != null && cached.isNotEmpty) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final seasons = await _remote.getSeasons();
    _memoryCache.set(key, seasons, ttl: ttl);
    await _diskCache.write(key: key, value: seasons, nowUtc: nowUtc);
    return seasons;
  }

  Future<List<NhlTeam>> getTeams({bool forceRefresh = false}) async {
    const key = CacheKeys.teams;
    const ttl = CacheTtlPolicy.historical;
    final nowUtc = DateTime.now().toUtc();
    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory is List<NhlTeam>) return memory;

      final cached = _diskCache.readDataWithTtl<List<NhlTeam>>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: (json) {
          if (json is! List) return <NhlTeam>[];
          final teams = <NhlTeam>[];
          for (final item in json) {
            if (item is! Map) continue;
            final m = Map<String, Object?>.from(item);
            final abbrev = (m['abbrev'] as String?) ?? '';
            if (abbrev.isEmpty) continue;
            teams.add(
              NhlTeam(
                abbrev: abbrev,
                name: (m['name'] as String?) ?? '',
                logoUrl: (m['logoUrl'] as String?) ?? '',
              ),
            );
          }
          return teams;
        },
      );
      if (cached != null && cached.isNotEmpty) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final teams = await _remote.getTeams();
    _memoryCache.set(key, teams, ttl: ttl);
    await _diskCache.write(
      key: key,
      nowUtc: nowUtc,
      value: teams
          .map(
            (t) => <String, Object?>{
              'abbrev': t.abbrev,
              'name': t.name,
              'logoUrl': t.logoUrl,
            },
          )
          .toList(),
    );
    return teams;
  }
}
