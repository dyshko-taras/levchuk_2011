import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/memory_cache.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/data/repositories/cache_keys.dart';
import 'package:ice_line_tracker/data/repositories/cache_ttl_policy.dart';
import 'package:ice_line_tracker/data/repositories/schedule_repository.dart';

class CachedScheduleRepository {
  CachedScheduleRepository({
    required ScheduleRepository remote,
    required HiveJsonCache diskCache,
    MemoryCache<String, Object?>? memoryCache,
  })  : _remote = remote,
        _diskCache = diskCache,
        _memoryCache = memoryCache ?? MemoryCache<String, Object?>();

  final ScheduleRepository _remote;
  final HiveJsonCache _diskCache;
  final MemoryCache<String, Object?> _memoryCache;

  Future<NhlScheduleResponse> getScheduleNow({
    bool forceRefresh = false,
  }) async {
    const key = CacheKeys.scheduleNow;
    const ttl = CacheTtlPolicy.currentGame;
    final nowUtc = DateTime.now().toUtc();
    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory is NhlScheduleResponse) return memory;

      final cached = _diskCache.readDataWithTtl<NhlScheduleResponse>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: (json) {
          if (json is! Map) {
            throw const FormatException('Invalid cache payload');
          }
          return NhlScheduleResponse.fromJson(Map<String, Object?>.from(json));
        },
      );
      if (cached != null) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final fresh = await _remote.getScheduleNow();
    _memoryCache.set(key, fresh, ttl: ttl);
    await _diskCache.write(key: key, value: fresh.toJson(), nowUtc: nowUtc);
    return fresh;
  }

  Future<NhlScheduleResponse> getScheduleByDate(
    String yyyyMmDd, {
    bool forceRefresh = false,
  }) async {
    final key = CacheKeys.scheduleByDate(yyyyMmDd);
    final ttl = CacheTtlPolicy.forDate(yyyyMmDd: yyyyMmDd);
    final nowUtc = DateTime.now().toUtc();
    if (!forceRefresh) {
      final memory = _memoryCache.get(key);
      if (memory is NhlScheduleResponse) return memory;

      final cached = _diskCache.readDataWithTtl<NhlScheduleResponse>(
        key: key,
        ttl: ttl,
        nowUtc: nowUtc,
        fromJson: (json) {
          if (json is! Map) {
            throw const FormatException('Invalid cache payload');
          }
          return NhlScheduleResponse.fromJson(Map<String, Object?>.from(json));
        },
      );
      if (cached != null) {
        _memoryCache.set(key, cached, ttl: ttl);
        return cached;
      }
    }

    final fresh = await _remote.getScheduleByDate(yyyyMmDd);
    _memoryCache.set(key, fresh, ttl: ttl);
    await _diskCache.write(key: key, value: fresh.toJson(), nowUtc: nowUtc);
    return fresh;
  }
}
