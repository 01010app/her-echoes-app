import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/subscription_provider.dart';
import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cards/pro_badge.dart';
import '../../widgets/cards/wildcard_badge.dart';
import '../../widgets/modals/upsell_modal_free.dart';
import '../card_detail/card_detail_screen.dart';

class DailyEchoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> todaysWomen;
  final List<Map<String, dynamic>> wildcards;

  const DailyEchoScreen({
    super.key,
    required this.todaysWomen,
    this.wildcards = const [],
  });

  @override
  State<DailyEchoScreen> createState() => _DailyEchoScreenState();
}

class _DailyEchoScreenState extends State<DailyEchoScreen>
    with SingleTickerProviderStateMixin {

  late List<Map<String, dynamic>> _women;
  Offset _dragOffset = Offset.zero;
  late AnimationController _snapController;
  late Animation<Offset> _snapAnimation;

  static const double _dismissThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _buildWomenList();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapAnimation = AlwaysStoppedAnimation(Offset.zero);
    _snapController.addListener(() {
      setState(() => _dragOffset = _snapAnimation.value);
    });
  }

  void _buildWomenList() {
    final wildcardItems = widget.wildcards
        .map((w) => {...w, '_is_wildcard': true})
        .toList();
    final dailyItems = widget.todaysWomen
        .where((w) => (w['image_card_ID'] ?? '').toString().isNotEmpty)
        .toList();
    _women = [...wildcardItems, ...dailyItems];
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails d) {
    _snapController.stop();
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _dragOffset += d.delta);
  }

  void _onPanEnd(DragEndDetails d) {
    final dist = _dragOffset.distance;

    if (dist > _dismissThreshold) {
      final direction = _dragOffset / dist;
      final target = direction * 700;
      _snapAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: target,
      ).animate(CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOut,
      ));
      _snapController.forward(from: 0).then((_) {
        setState(() {
          final first = _women.removeAt(0);
          _women.add(first); // loop
          _dragOffset = Offset.zero;
        });
      });
    } else {
      _snapAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _snapController,
        curve: Curves.elasticOut,
      ));
      _snapController.forward(from: 0);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final userIsPro = context.watch<SubscriptionProvider>().isPro;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    if (_women.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: Text("No hay entradas para hoy")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth  = constraints.maxWidth - 32;
          final cardHeight = constraints.maxHeight - 24;
          const topOffset  = 8.0;

          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [

                // Card 3 — fondo (asoma por arriba)
                if (_women.length >= 3)
                  Positioned(
                    top: topOffset,
                    left: 16 + 12,
                    right: 16 + 12,
                    child: Transform.scale(
                      scale: 0.93,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: cardHeight,
                        child: _buildCard(
                          _women[2], cardWidth - 24, cardHeight,
                          userIsPro, isEnglish, isTop: false,
                        ),
                      ),
                    ),
                  ),

                // Card 2 — medio (asoma por arriba)
                if (_women.length >= 2)
                  Positioned(
                    top: topOffset,
                    left: 16 + 6,
                    right: 16 + 6,
                    child: Transform.scale(
                      scale: 0.96,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: cardHeight,
                        child: _buildCard(
                          _women[1], cardWidth - 12, cardHeight,
                          userIsPro, isEnglish, isTop: false,
                        ),
                      ),
                    ),
                  ),

                // Card 1 — top
                Positioned(
                  top: topOffset + 32,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onTap: () {
                      if (_dragOffset.distance > 4) return;
                      final woman = _women[0];
                      final isContentPro = woman['is_free'] != "VERDADERO";
                      final blocked = isContentPro && !userIsPro;
                      if (blocked) {
                        _showUpsell(context);
                      } else {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CardDetailScreen(woman: woman),
                        ));
                      }
                    },
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: Transform.rotate(
                        angle: _dragOffset.dx / 1200,
                        child: SizedBox(
                          height: cardHeight - 32,
                          child: _buildCard(
                            _women[0], cardWidth, cardHeight - 32,
                            userIsPro, isEnglish, isTop: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    Map<String, dynamic> w,
    double width,
    double height,
    bool userIsPro,
    bool isEnglish, {
    required bool isTop,
  }) {
    final rawId = (w['image_card_ID'] ?? '').toString();
    final imageUrl = rawId.startsWith('http')
        ? rawId
        : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
    final isContentPro = w['is_free'] != "VERDADERO";
    final isBlocked    = isContentPro && !userIsPro;
    final isWildcard   = w['_is_wildcard'] == true;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [

            // IMAGEN
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Image.network(
                  'https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/not_found.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // GRADIENTE
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // TEXTO (solo top card)
            if (isTop)
              Positioned(
                left: 24,
                right: 24,
                bottom: 122,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        isEnglish ? w['pro-tag01_en'] ?? '' : w['pro-tag01_es'] ?? '',
                        isEnglish ? w['pro-tag02_en'] ?? '' : w['pro-tag02_es'] ?? '',
                      ].where((t) => t.isNotEmpty).join(' • '),
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (w['full_name'] ?? '') as String,
                      style: GoogleFonts.gloock(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('❝  ',
                            style: TextStyle(color: AppColors.accent, fontSize: 16)),
                        Expanded(
                          child: Text(
                            (isEnglish
                                ? w['quote_text_en']
                                : w['quote_text_es'] ?? '') as String,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // WILDCARD BADGE
            if (isWildcard)
              Positioned(
                top: 16, left: 16,
                child: WildcardBadge(isEnglish: isEnglish),
              ),

            // PRO BADGE
            if (isBlocked && !isWildcard)
              const Positioned(
                top: 16, right: 16,
                child: ProBadge(),
              ),
          ],
        ),
      ),
    );
  }
}