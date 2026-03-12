class DailySuggestionsEngine {
  static List<Map<String, dynamic>> generateSuggestions({
    required List<Map<String, dynamic>> todaysWomen,
    required List<Map<String, dynamic>> fullDataset,
    required String locale,
    List<Map<String, dynamic>> wildcards = const [],
  }) {
    // Wildcard al frente, marcada
    final List<Map<String, dynamic>> wildcardItems = wildcards
        .map((w) => {...w, '_is_wildcard': true})
        .toList();

    // Paso 1: hasta 3 mujeres del día
    final List<Map<String, dynamic>> topToday =
        todaysWomen.take(3).toList();

    // Paso 2: tags base
    final Set<String> baseTags = {};
    for (var woman in topToday) {
      final tag1 = locale == 'es'
          ? woman["pro-tag01_es"]
          : woman["pro-tag01_en"];
      final tag2 = locale == 'es'
          ? woman["pro-tag02_es"]
          : woman["pro-tag02_en"];
      if (tag1 != null && tag1.toString().isNotEmpty) baseTags.add(tag1.toString());
      if (tag2 != null && tag2.toString().isNotEmpty) baseTags.add(tag2.toString());
    }

    // Paso 3: relacionadas por tag
    List<Map<String, dynamic>> related = fullDataset.where((woman) {
      final tag1 = locale == 'es'
          ? woman["pro-tag01_es"]
          : woman["pro-tag01_en"];
      final tag2 = locale == 'es'
          ? woman["pro-tag02_es"]
          : woman["pro-tag02_en"];
      return (tag1 != null && baseTags.contains(tag1.toString())) ||
             (tag2 != null && baseTags.contains(tag2.toString()));
    }).toList();

    // Paso 4: sin duplicados del día
    related.removeWhere((woman) =>
        topToday.any((today) => today["woman_id"] == woman["woman_id"]));

    // Paso 5: orden alfabético estable
    related.sort((a, b) =>
        a["full_name"].toString().compareTo(b["full_name"].toString()));

    // Paso 6: hasta 7 relacionadas
    final List<Map<String, dynamic>> topRelated = related.take(7).toList();

    // Paso 7: fallback si no alcanza 7
    if (topRelated.length < 7) {
      final remaining = fullDataset
          .where((woman) =>
              !topToday.any((t) => t["woman_id"] == woman["woman_id"]) &&
              !topRelated.any((r) => r["woman_id"] == woman["woman_id"]))
          .take(7 - topRelated.length)
          .toList();
      topRelated.addAll(remaining);
    }

    return [...wildcardItems, ...topToday, ...topRelated];
  }
}