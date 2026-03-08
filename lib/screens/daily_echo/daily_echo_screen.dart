import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:card_stack_widget/card_stack_widget.dart';
import '../../core/theme/app_colors.dart';
import '../card_detail/card_detail_screen.dart';

class DailyEchoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> todaysWomen;

  const DailyEchoScreen({
    super.key,
    required this.todaysWomen,
  });

  @override
  Widget build(BuildContext context) {
    final women = todaysWomen
        .where((w) => (w['image_card_ID'] ?? '').toString().isNotEmpty)
        .toList();

    if (women.isEmpty) {
      return const Center(child: Text("No hay entradas para hoy"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth - 32;
        final cardHeight = constraints.maxHeight - 80;

        final cardList = List.generate(women.length, (index) {
          final w = women[index];
          final rawId = (w['image_card_ID'] ?? '').toString();
          final imageUrl = rawId.startsWith('http')
              ? rawId
              : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
          final isFree = w['is_free'] == "VERDADERO";
          final isPro = !isFree;

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

                          // TAGS
                          Text(
                            [
                              w['pro-tag01_en'] ?? '',
                              w['pro-tag02_en'] ?? '',
                            ].where((t) => t.isNotEmpty).join(' • '),
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // NOMBRE
                          Text(
                            (w['full_name'] ?? '') as String,
                            style: GoogleFonts.gloock(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // QUOTE
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
                                  (w['quote_text_en'] ?? '') as String,
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

                    // PRO BADGE
                    if (isPro)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF70F3D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "PRO",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
              final isFree = woman['is_free'] == "VERDADERO";
              if (isFree) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailScreen(woman: woman),
                  ),
                );
              } else {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Container(
                    padding: const EdgeInsets.all(32),
                    child: const Text(
                      "Upsell modal — próximamente",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}