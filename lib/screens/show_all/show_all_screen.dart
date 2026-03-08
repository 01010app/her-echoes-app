import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import '../card_detail/card_detail_screen.dart';

class ShowAllScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allWomen;

  const ShowAllScreen({
    super.key,
    required this.allWomen,
  });

  @override
  State<ShowAllScreen> createState() => _ShowAllScreenState();
}

class _ShowAllScreenState extends State<ShowAllScreen> {
  int _focusedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final women = widget.allWomen
        .where((w) => (w['image_card_ID'] ?? '').toString().isNotEmpty)
        .toList();

    final titles = women.map((w) => '').toList();

    final images = List.generate(women.length, (index) {
      final w = women[index];
      final rawId = (w['image_card_ID'] ?? '').toString();
      final imageUrl = rawId.startsWith('http')
          ? rawId
          : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
      final isPro = w['is_free'] != "VERDADERO";
      final isFocused = index == _focusedIndex;

      return Stack(
        fit: StackFit.expand,
        children: [

          // IMAGEN
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // GRADIENTE
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

          // NOMBRE
          Positioned(
            left: 24,
            right: 24,
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

          // PRO BADGE
          if (isPro)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      );
    });

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: VerticalCardPager(
          titles: titles,
          images: images.toList(),
          textStyle: const TextStyle(fontSize: 0),
          onPageChanged: (page) {
            setState(() {
              _focusedIndex = (page ?? 0).round();
            });
          },
          onSelectedItem: (index) {
            final woman = women[index];
            final isPro = woman['is_free'] != "VERDADERO";
            if (isPro) {
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