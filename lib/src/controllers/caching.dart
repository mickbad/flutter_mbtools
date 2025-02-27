
///
/// Gestion interne d'un cache mémoire d'une valeur T
///
class Cache<T> {
  ///
  /// Moteur de cache
  ///
  final Map<String, _CacheEntry<T>> _cache = {};

  ///
  /// Fonction de cache
  ///
  Future<T> retrieve({
    required String key,
    required Future<T> Function() retrieveValue,
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    final cacheEntry = _cache[key];

    if (cacheEntry != null && cacheEntry.isValid(maxAge)) {
      return cacheEntry.value;
    }

    final value = await retrieveValue();
    _cache[key] = _CacheEntry(value, DateTime.now());
    return value;
  }

  ///
  /// Nettoyage de la base de données
  ///
  void clear() {
    _cache.clear();
  }

  ///
  /// Nettoyage des données à partir de sa clef
  ///
  void invalidate({required String key}) {
    _cache.remove(key);
  }

  ///
  /// Netoyage des données à partir de sa clef commencant par [keyStartWith]
  ///
  void invalidateStartWith({required String keyStartWith}) {
    _cache.removeWhere((key, value) => key.startsWith(keyStartWith));
  }
}

class _CacheEntry<T> {
  _CacheEntry(this.value, this.createdAt);

  final T value;
  final DateTime createdAt;

  bool isValid(Duration maxAge) {
    return DateTime.now().difference(createdAt) <= maxAge;
  }
}

///
/// Cache spécifique pour les données Map non nullable
///
class GlobalMapCache extends Cache<Map<String, dynamic>> {
  static final GlobalMapCache _instance = GlobalMapCache._internal();

  factory GlobalMapCache() {
    return _instance;
  }

  GlobalMapCache._internal();
}


///
/// Cache spécifique pour les données Map nullable (cad peut être null)
///
class GlobalMapNullableCache extends Cache<Map<String, dynamic>?> {
  static final GlobalMapNullableCache _instance = GlobalMapNullableCache._internal();

  factory GlobalMapNullableCache() {
    return _instance;
  }

  GlobalMapNullableCache._internal();
}

///
/// Cache spécifique pour les données List<Map> non nullable
///
class GlobalListMapCache extends Cache<List<Map<String, dynamic>>> {
  static final GlobalListMapCache _instance = GlobalListMapCache._internal();

  factory GlobalListMapCache() {
    return _instance;
  }

  GlobalListMapCache._internal();
}

///
/// Cache spécifique pour les données String
///
class GlobalStringCache extends Cache<String> {
  static final GlobalStringCache _instance = GlobalStringCache._internal();

  factory GlobalStringCache() {
    return _instance;
  }

  GlobalStringCache._internal();
}

///
/// Cache spécifique pour les données String Nullable
///
class GlobalStringNullableCache extends Cache<String?> {
  static final GlobalStringNullableCache _instance = GlobalStringNullableCache._internal();

  factory GlobalStringNullableCache() {
    return _instance;
  }

  GlobalStringNullableCache._internal();
}
