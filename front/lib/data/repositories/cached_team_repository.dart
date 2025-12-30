import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/memory_cache.dart';
import 'package:ice_line_tracker/data/repositories/cache_keys.dart';
import 'package:ice_line_tracker/data/repositories/cache_ttl_policy.dart';
import 'package:ice_line_tracker/data/repositories/team_repository.dart';

class CachedTeamRepository {
  CachedTeamRepository({
    required TeamRepository remote,
    required HiveJsonCache diskCache,
    MemoryCache<String, Object?>? memoryCache,
  }) : _remote = remote,
       _diskCache = diskCache,
       _memoryCache = memoryCache ?? MemoryCache<String, Object?>();

  final TeamRepository _remote;
  final HiveJsonCache _diskCache;
  final MemoryCache<String, Object?> _memoryCache;

  Future<Object?> getRosterCurrent(
    String teamAbbrev, {
    bool forceRefresh = false,
  }) async {
    final key = CacheKeys.rosterCurrent(teamAbbrev);
    const ttl = CacheTtlPolicy.futureGames;
    final nowUtc = DateTime.now().toUtc();

    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory != null) return memory;

      final cached = _diskCache.readDataWithTtl<Object?>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: _normalizeTopLevelJson,
      );
      if (cached != null) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final fresh = await _remote.getRosterCurrent(teamAbbrev);
    if (fresh != null) {
      _memoryCache.set(key, fresh, ttl: ttl);
      await _diskCache.write(key: key, value: fresh, nowUtc: nowUtc);
    }
    return fresh;
  }

  Future<Object?> getClubScheduleSeasonNow(
    String teamAbbrev, {
    bool forceRefresh = false,
  }) async {
    final key = CacheKeys.clubScheduleSeasonNow(teamAbbrev);
    const ttl = CacheTtlPolicy.futureGames;
    final nowUtc = DateTime.now().toUtc();

    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory != null) return memory;

      final cached = _diskCache.readDataWithTtl<Object?>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: _normalizeTopLevelJson,
      );
      if (cached != null) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final fresh = await _remote.getClubScheduleSeasonNow(teamAbbrev);
    if (fresh != null) {
      _memoryCache.set(key, fresh, ttl: ttl);
      await _diskCache.write(key: key, value: fresh, nowUtc: nowUtc);
    }
    return fresh;
  }

  Future<Object?> getClubStatsNow(
    String teamAbbrev, {
    bool forceRefresh = false,
  }) async {
    final key = CacheKeys.clubStatsNow(teamAbbrev);
    const ttl = CacheTtlPolicy.futureGames;
    final nowUtc = DateTime.now().toUtc();

    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory != null) return memory;

      final cached = _diskCache.readDataWithTtl<Object?>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: _normalizeTopLevelJson,
      );
      if (cached != null) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final fresh = await _remote.getClubStatsNow(teamAbbrev);
    if (fresh != null) {
      _memoryCache.set(key, fresh, ttl: ttl);
      await _diskCache.write(key: key, value: fresh, nowUtc: nowUtc);
    }
    return fresh;
  }
}

Object? _normalizeTopLevelJson(Object? json) {
  if (json is Map) return Map<String, Object?>.from(json);
  if (json is List) return List<Object?>.from(json);
  return json;
}
