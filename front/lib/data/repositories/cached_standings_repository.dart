import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/memory_cache.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:ice_line_tracker/data/repositories/cache_keys.dart';
import 'package:ice_line_tracker/data/repositories/cache_ttl_policy.dart';
import 'package:ice_line_tracker/data/repositories/standings_repository.dart';

class CachedStandingsRepository {
  CachedStandingsRepository({
    required StandingsRepository remote,
    required HiveJsonCache diskCache,
    MemoryCache<String, Object?>? memoryCache,
  })  : _remote = remote,
        _diskCache = diskCache,
        _memoryCache = memoryCache ?? MemoryCache<String, Object?>();

  final StandingsRepository _remote;
  final HiveJsonCache _diskCache;
  final MemoryCache<String, Object?> _memoryCache;

  Future<NhlStandingsResponse> getStandingsNow({
    bool forceRefresh = false,
  }) async {
    const key = CacheKeys.standingsNow;
    const ttl = CacheTtlPolicy.futureGames;
    final nowUtc = DateTime.now().toUtc();
    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory is NhlStandingsResponse) return memory;

      final cached = _diskCache.readDataWithTtl<NhlStandingsResponse>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: (json) {
          if (json is! Map) {
            throw const FormatException('Invalid cache payload');
          }
          return NhlStandingsResponse.fromJson(Map<String, Object?>.from(json));
        },
      );
      if (cached != null) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final fresh = await _remote.getStandingsNow();
    _memoryCache.set(key, fresh, ttl: ttl);
    await _diskCache.write(key: key, value: fresh.toJson(), nowUtc: nowUtc);
    return fresh;
  }

  Future<NhlStandingsResponse> getStandingsByDate(
    String yyyyMmDd, {
    bool forceRefresh = false,
  }) async {
    final key = CacheKeys.standingsByDate(yyyyMmDd);
    final ttl = CacheTtlPolicy.forDate(yyyyMmDd: yyyyMmDd);
    final nowUtc = DateTime.now().toUtc();
    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory is NhlStandingsResponse) return memory;

      final cached = _diskCache.readDataWithTtl<NhlStandingsResponse>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: (json) {
          if (json is! Map) {
            throw const FormatException('Invalid cache payload');
          }
          return NhlStandingsResponse.fromJson(Map<String, Object?>.from(json));
        },
      );
      if (cached != null) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final fresh = await _remote.getStandingsByDate(yyyyMmDd);
    _memoryCache.set(key, fresh, ttl: ttl);
    await _diskCache.write(key: key, value: fresh.toJson(), nowUtc: nowUtc);
    return fresh;
  }
}
