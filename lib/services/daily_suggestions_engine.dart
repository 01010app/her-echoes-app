class DailySuggestionsEngine {
  static List<Map<String, dynamic>> generateSuggestions({
    required List<Map<String, dynamic>> todaysWomen,
    required List<Map<String, dynamic>> fullDataset,
    required String locale,
  }) {
    // Paso 1: Tomar hasta 3 mujeres del día
    final List<Map<String, dynamic>> topToday =
        todaysWomen.take(3).toList();

    // Paso 2: Obtener TODOS los tags base (pro-tag01 y pro-tag02)
    final Set<String> baseTags = {};

    for (var woman in topToday) {
      final tag1 = locale == 'es'
          ? woman["pro-tag01_es"]
          : woman["pro-tag01_en"];

      final tag2 = locale == 'es'
          ? woman["pro-tag02_es"]
          : woman["pro-tag02_en"];

      if (tag1 != null && tag1.toString().isNotEmpty) {
        baseTags.add(tag1.toString());
      }

      if (tag2 != null && tag2.toString().isNotEmpty) {
        baseTags.add(tag2.toString());
      }
    }

    // Paso 3: Buscar relacionadas por cualquiera de los dos tags
    List<Map<String, dynamic>> related =
        fullDataset.where((woman) {
      final tag1 = locale == 'es'
          ? woman["pro-tag01_es"]
          : woman["pro-tag01_en"];

      final tag2 = locale == 'es'
          ? woman["pro-tag02_es"]
          : woman["pro-tag02_en"];

      final matchesTag1 =
          tag1 != null && baseTags.contains(tag1.toString());

      final matchesTag2 =
          tag2 != null && baseTags.contains(tag2.toString());

      return matchesTag1 || matchesTag2;
    }).toList();

    // Paso 4: Eliminar duplicados (no repetir las del día)
    related.removeWhere((woman) =>
        topToday.any((today) =>
            today["woman_id"] == woman["woman_id"]));

    // Paso 5: Orden alfabético estable
    related.sort((a, b) =>
        a["full_name"]
            .toString()
            .compareTo(b["full_name"].toString()));

    // Paso 6: Tomar hasta 7 relacionadas
    final List<Map<String, dynamic>> topRelated =
        related.take(7).toList();

    // Paso 7: Fallback si no alcanza 7
    if (topRelated.length < 7) {
      final remaining = fullDataset
          .where((woman) =>
              !topToday.any((t) =>
                  t["woman_id"] == woman["woman_id"]) &&
              !topRelated.any((r) =>
                  r["woman_id"] == woman["woman_id"]))
          .take(7 - topRelated.length)
          .toList();

      topRelated.addAll(remaining);
    }

    return [...topToday, ...topRelated];
  }
}