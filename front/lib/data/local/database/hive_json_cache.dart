import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveJsonCache {
  HiveJsonCache(this._box);

  final Box<String> _box;

  static const int version = 1;

  static Future<HiveJsonCache> open({String boxName = 'cache_v1'}) async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(boxName);
    return HiveJsonCache(box);
  }

  Future<void> write({
    required String key,
    required Object value,
    required DateTime nowUtc,
  }) async {
    final payload = <String, Object?>{
      'v': version,
      'ts': nowUtc.toUtc().toIso8601String(),
      'data': value,
    };
    await _box.put(key, jsonEncode(payload));
  }

  T? readDataWithTtl<T>({
    required String key,
    required Duration ttl,
    required T Function(Object? json) fromJson,
    required DateTime nowUtc,
  }) {
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final ts = decoded['ts'];
      if (ts is! String) return null;

      final updatedAt = DateTime.tryParse(ts)?.toUtc();
      if (updatedAt == null) return null;

      if (nowUtc.toUtc().difference(updatedAt) > ttl) {
        return null;
      }

      return fromJson(decoded['data']);
    } on FormatException {
      return null;
    }
  }

  Future<void> delete(String key) => _box.delete(key);
}
