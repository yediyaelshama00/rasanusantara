class RegionMapper {
  static String fromProvince(String value) {
    final province = value.toLowerCase();
    if (_containsAny(province, ['aceh', 'sumatera', 'riau', 'jambi', 'bengkulu', 'lampung', 'bangka'])) return 'Sumatera';
    if (_containsAny(province, ['jakarta', 'jawa', 'banten', 'yogyakarta'])) return 'Jawa';
    if (_containsAny(province, ['kalimantan'])) return 'Kalimantan';
    if (_containsAny(province, ['sulawesi', 'gorontalo'])) return 'Sulawesi';
    if (_containsAny(province, ['bali', 'nusa tenggara'])) return 'Bali & Nusa Tenggara';
    if (_containsAny(province, ['maluku'])) return 'Maluku';
    if (_containsAny(province, ['papua'])) return 'Papua';
    return 'Jawa';
  }

  static bool _containsAny(String source, List<String> keys) {
    for (final key in keys) {
      if (source.contains(key)) return true;
    }
    return false;
  }
}
