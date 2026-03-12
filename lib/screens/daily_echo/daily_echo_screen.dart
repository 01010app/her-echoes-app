import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:card_stack_widget/card_stack_widget.dart';
import 'package:provider/provider.dart';

import '../../core/subscription_provider.dart';
import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cards/pro_badge.dart';
import '../../widgets/cards/wildcard_badge.dart';
import '../../widgets/modals/upsell_modal_free.dart';
import '../card_detail/card_detail_screen.dart';

class DailyEchoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> todaysWomen;
  final List<Map<String, dynamic>> wildcards;

  const DailyEchoScreen({
    super.key,
    required this.todaysWomen,
    this.wildcards = const [],
  });

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

    // Wildcards primero, luego las del día
    final wildcardItems = wildcards
        .map((w) => {...w, '_is_wildcard': true})
        .toList();

    final dailyItems = todaysWomen
        .where((w) => (w['image_card_ID'] ?? '').toString().isNotEmpty)
        .toList();

    final women = [...wildcardItems, ...dailyItems];

    if (women.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: Text("No hay entradas para hoy")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth - 32;
          final cardHeight = constraints.maxHeight - 80;

          final cardList = List.generate(women.length, (index) {
            final w = women[index];
            final rawId = (w['image_card_ID'] ?? '').toString();
            final imageUrl = rawId.startsWith('http')
                ? rawId
                : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
            final isContentPro = w['is_free'] != "VERDADERO";
            final isBlocked = isContentPro && !userIsPro;
            final isWildcard = w['_is_wildcard'] == true;

            return CardModel(
              key: Key("$index"),
              backgroundColor: Colors.transparent,
              radius: const Radius.circular(0),
              shadowColor: Colors.transparent,
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [

                      // IMAGEN
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
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

                      // TEXTO
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 104,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [
                                isEnglish
                                    ? w['pro-tag01_en'] ?? ''
                                    : w['pro-tag01_es'] ?? '',
                                isEnglish
                                    ? w['pro-tag02_en'] ?? ''
                                    : w['pro-tag02_es'] ?? '',
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
                                Text(
                                  '❝  ',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 16,
                                  ),
                                ),
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

                      // WILDCARD BADGE — esquina superior izquierda
                      if (isWildcard)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: WildcardBadge(isEnglish: isEnglish),
                        ),

                      // PRO BADGE — esquina superior derecha
                      if (isBlocked && !isWildcard)
                        const Positioned(
                          top: 16,
                          right: 16,
                          child: ProBadge(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          });

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CardStackWidget(
              cardList: cardList,
              alignment: Alignment.center,
              positionFactor: 1.5,
              scaleFactor: 0.97,
              animateCardScale: true,
              opacityChangeOnDrag: false,
              cardDismissOrientation: CardOrientation.both,
              swipeOrientation: CardOrientation.both,
              onCardTap: (model) {
                final index = cardList.indexOf(model);
                if (index < 0) return;
                final woman = women[index];
                final isContentPro = woman['is_free'] != "VERDADERO";
                final blocked = isContentPro && !userIsPro;
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
          );
        },
      ),
    );
  }
}