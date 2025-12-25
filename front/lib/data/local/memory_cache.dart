class MemoryCache<K, V> {
  final Map<K, _Entry<V>> _cache = <K, _Entry<V>>{};

  V? get(K key, {DateTime? nowUtc}) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.expiresAtUtc == null) return entry.value;

    final now = nowUtc ?? DateTime.now().toUtc();
    if (now.isAfter(entry.expiresAtUtc!)) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  void set(
    K key,
    V value, {
    Duration? ttl,
    DateTime? nowUtc,
  }) {
    final now = nowUtc ?? DateTime.now().toUtc();
    final expiresAt = ttl == null ? null : now.add(ttl);
    _cache[key] = _Entry(value: value, expiresAtUtc: expiresAt);
  }

  void remove(K key) => _cache.remove(key);

  void clear() => _cache.clear();
}

class _Entry<V> {
  const _Entry({required this.value, required this.expiresAtUtc});

  final V value;
  final DateTime? expiresAtUtc;
}
