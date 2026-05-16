import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import 'package:provider/provider.dart';

import '../../core/subscription_provider.dart';
import '../../widgets/cards/pro_badge.dart';
import '../../widgets/cards/wildcard_badge.dart';
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

  @override
  Widget build(BuildContext context) {
    final userIsPro = context.watch<SubscriptionProvider>().isPro;

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

    final allWomen = [...todayFreeWomen, ...wildcardItems, ...restWomen];
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
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 0),
        child: VerticalCardPager(
          titles: titles,
          images: images.toList(),
          textStyle: const TextStyle(fontSize: 0),
          onPageChanged: (page) {
            final index = (page ?? 0).round();
            setState(() => _focusedIndex = index);
            if (index >= _loadedCount - 8 && _loadedCount < allWomen.length) {
              setState(() {
                _loadedCount =
                    (_loadedCount + _pageSize).clamp(0, allWomen.length);
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
    );
  }
}