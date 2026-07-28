import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import 'package:provider/provider.dart';

import '../../core/subscription_provider.dart';
import '../../core/language_provider.dart';
import '../../widgets/cards/pro_badge.dart';
import '../../widgets/cards/wildcard_badge.dart';
import '../../widgets/filters/filter_chips_bar.dart';
import '../../widgets/modals/upsell_modal_free.dart';
import '../card_detail/card_detail_screen.dart';

class ShowAllScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allWomen;
  final List<Map<String, dynamic>> wildcards;
  final Set<String> todaysFreeIds;

  const ShowAllScreen({
    super.key,
    required this.allWomen,
    required this.todaysFreeIds,
    this.wildcards = const [],
  });

  @override
  State<ShowAllScreen> createState() => _ShowAllScreenState();
}

class _ShowAllScreenState extends State<ShowAllScreen> {
  int _focusedIndex = 0;
  static const int _pageSize = 30;
  int _loadedCount = _pageSize;

  static const String _kAllFilter = '_ALL_';
  String _selectedFilter = _kAllFilter;

  void _showUpsell(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const UpsellModalFree(),
    );
  }

  bool _isBlocked(Map<String, dynamic> w, bool userIsPro) {
    if (userIsPro) return false;
    if (w['_is_wildcard'] == true) return false;
    final id = (w['woman_id'] ?? '').toString();
    return !widget.todaysFreeIds.contains(id);
  }

  String _primaryTag(Map<String, dynamic> w, bool isEnglish) {
    final tag = isEnglish ? w['pro-tag01_en'] : w['pro-tag01_es'];
    return (tag ?? '').toString().trim();
  }

  // Overrides manuales: usar cuando la heurística de "primera palabra"
  // no basta (ej. la categoría real no es la primera palabra del tag,
  // o dos tags con primera palabra distinta deberían agruparse igual).
  // Clave = tag completo en minúsculas, Valor = categoría final.
  static const Map<String, String> _categoryOverrides = {
    'ex presidenta de chile': 'Líder',
    'chilean president': 'Leader',
    // 'poeta y escritora': 'Escritora',
    // 'escritora y poeta': 'Escritora',
  };

  /// Normaliza un tag crudo (ej. "Activista por los derechos civiles")
  /// a su categoría base (ej. "Activista"), agrupando variantes del
  /// mismo tag bajo un solo filtro.
  String _normalizeCategory(String rawTag) {
    if (rawTag.isEmpty) return rawTag;
    final lower = rawTag.toLowerCase();
    if (_categoryOverrides.containsKey(lower)) {
      return _categoryOverrides[lower]!;
    }
    final firstWord = rawTag.trim().split(RegExp(r'\s+')).first;
    return firstWord;
  }

  List<String> _buildFilters(
      List<Map<String, dynamic>> allWomenSource, bool isEnglish) {
    final tags = <String>{};
    for (final w in allWomenSource) {
      final rawTag = _primaryTag(w, isEnglish);
      if (rawTag.isEmpty) continue;
      tags.add(_normalizeCategory(rawTag));
    }
    final sorted = tags.toList()..sort();
    return [_kAllFilter, ...sorted];
  }

  String _filterLabel(String filter, bool isEnglish) {
    if (filter == _kAllFilter) return isEnglish ? 'ALL' : 'TODAS';
    return filter.toUpperCase();
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      _focusedIndex = 0;
      _loadedCount = _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userIsPro = context.watch<SubscriptionProvider>().isPro;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    // 1. Mujer(es) del día desbloqueadas — van primero
    final todayFreeWomen = widget.allWomen
        .where((w) =>
            widget.todaysFreeIds.contains((w['woman_id'] ?? '').toString()) &&
            (w['image_card_ID'] ?? '').toString().isNotEmpty)
        .toList();

    // 2. Wildcards — van inmediatamente después
    final wildcardItems = widget.wildcards
        .map((w) => {...w, '_is_wildcard': true})
        .toList();

    // 3. El resto — todas las demás mujeres bloqueadas
    final restWomen = widget.allWomen
        .where((w) =>
            !widget.todaysFreeIds.contains((w['woman_id'] ?? '').toString()) &&
            (w['image_card_ID'] ?? '').toString().isNotEmpty)
        .toList();

    final combinedWomen = [...todayFreeWomen, ...wildcardItems, ...restWomen];

    // Filtros disponibles: se calculan sobre el dataset completo, no sobre
    // el ya filtrado, para que las categorías nunca desaparezcan al filtrar.
    final filters = _buildFilters(combinedWomen, isEnglish);

    // Aplica el filtro seleccionado (TODAS = sin filtro)
    final allWomen = _selectedFilter == _kAllFilter
        ? combinedWomen
        : combinedWomen
            .where((w) =>
                _normalizeCategory(_primaryTag(w, isEnglish)) ==
                _selectedFilter)
            .toList();

    final women = allWomen.take(_loadedCount).toList();
    final titles = women.map((w) => '').toList();

    final images = List.generate(women.length, (index) {
      final w = women[index];
      final rawId = (w['image_card_ID'] ?? '').toString();
      final imageUrl = rawId.startsWith('http')
          ? rawId
          : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
      final isWildcard = w['_is_wildcard'] == true;
      final blocked = _isBlocked(w, userIsPro);
      final isFocused = index == _focusedIndex;

      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheWidth: 400,
              errorBuilder: (_, __, ___) => Image.network(
                'https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/not_found.webp',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 16,
            bottom: 16,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: GoogleFonts.gloock(
                color: Colors.white,
                fontSize: isFocused ? 28.0 : 16.0,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              child: Text(
                (w['full_name'] ?? '') as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (isWildcard)
            const Positioned(
              top: 16,
              left: 16,
              child: WildcardBadge(),
            ),
          if (blocked)
            const Positioned(
              top: 16,
              right: 16,
              child: ProBadge(),
            ),
        ],
      );
    });

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // 8px de separación desde la línea del header
          const SizedBox(height: 8),
          FilterChipsBar(
            filters: filters,
            filterLabelBuilder: (f) => _filterLabel(f, isEnglish),
            selected: _selectedFilter,
            onSelected: _onFilterSelected,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 0),
              child: VerticalCardPager(
                // key fuerza reconstrucción del pager al cambiar de filtro,
                // reseteando el scroll/focus al primer resultado
                key: ValueKey(_selectedFilter),
                titles: titles,
                images: images.toList(),
                textStyle: const TextStyle(fontSize: 0),
                onPageChanged: (page) {
                  final index = (page ?? 0).round();
                  setState(() => _focusedIndex = index);
                  if (index >= _loadedCount - 8 &&
                      _loadedCount < allWomen.length) {
                    setState(() {
                      _loadedCount = (_loadedCount + _pageSize)
                          .clamp(0, allWomen.length);
                    });
                  }
                },
                onSelectedItem: (index) {
                  final woman = women[index];
                  final blocked = _isBlocked(woman, userIsPro);
                  if (blocked) {
                    _showUpsell(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardDetailScreen(woman: woman),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}