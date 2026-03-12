import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/language_provider.dart';
import '../../widgets/system/app_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allWomen;
  final List<Map<String, dynamic>> todaysWomen;
  final List<Map<String, dynamic>> suggestions;
  final List<Map<String, dynamic>> wildcards;

  const OnboardingScreen({
    super.key,
    required this.allWomen,
    required this.todaysWomen,
    required this.suggestions,
    this.wildcards = const [],
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          allWomen: widget.allWomen,
          todaysWomen: widget.todaysWomen,
          suggestions: widget.suggestions,
          wildcards: widget.wildcards,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    final slides = _buildSlides(isEnglish);
    final isLast = _currentPage == slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: topPadding),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _SlidePage(slide: slides[i]),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFE1002D)
                      : const Color(0xFFE1002D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isLast ? 1.0 : 0.0,
              child: AppButton(
                label: isEnglish ? "Let's go" : "Comencemos",
                onPressed: isLast ? _finish : null,
              ),
            ),
          ),

          SizedBox(height: bottomPadding + 16),
        ],
      ),
    );
  }

  List<_SlideData> _buildSlides(bool isEnglish) {
    return [
      _SlideData(
        title: isEnglish ? "Daily suggestions" : "Sugerencias diarias",
        imagePath: isEnglish
            ? 'assets/images/onboarding/01en.png'
            : 'assets/images/onboarding/01es.png',
        descriptionParts: isEnglish
            ? [
                const TextSpan(text: "Get suggestions to discover new stories every day in "),
                TextSpan(
                  text: "Home",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: "."),
              ]
            : [
                const TextSpan(text: "Obtén sugerencias para descubrir nuevas historias todos los días en el "),
                TextSpan(
                  text: "Home",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: "."),
              ],
      ),
      _SlideData(
        title: isEnglish ? "Curated content" : "Contenido curado",
        imagePath: isEnglish
            ? 'assets/images/onboarding/02en.png'
            : 'assets/images/onboarding/02es.png',
        descriptionParts: isEnglish
            ? [
                const TextSpan(text: "Every day at least 3 women's legacies in "),
                TextSpan(
                  text: "Daily Echo",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: "."),
              ]
            : [
                const TextSpan(text: "Todos los días al menos 3 legados de mujeres en "),
                TextSpan(
                  text: "Eco diario",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: "."),
              ],
      ),
      _SlideData(
        title: isEnglish ? "Hundreds of stories" : "Cientos de historias",
        imagePath: isEnglish
            ? 'assets/images/onboarding/03en.png'
            : 'assets/images/onboarding/03es.png',
        descriptionParts: isEnglish
            ? [
                const TextSpan(text: "Access hundreds of different stories, all together in "),
                TextSpan(
                  text: "See all",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: "."),
              ]
            : [
                const TextSpan(text: "Accede a cientos de diferentes historias, todas juntas en "),
                TextSpan(
                  text: "Ver todas",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: "."),
              ],
      ),
      _SlideData(
        title: isEnglish ? "Remember and share" : "Recuerda y comparte",
        imagePath: isEnglish
            ? 'assets/images/onboarding/04en.png'
            : 'assets/images/onboarding/04es.png',
        descriptionParts: isEnglish
            ? [
                const TextSpan(text: "Save the "),
                TextSpan(
                  text: "Favorite",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: " stories that touch your heart and share them."),
              ]
            : [
                const TextSpan(text: "Guarda las historias "),
                TextSpan(
                  text: "Favoritas",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                  ),
                ),
                const TextSpan(text: " que te toquen el corazón y compártelas."),
              ],
      ),
    ];
  }
}

class _SlideData {
  final String title;
  final String imagePath;
  final List<TextSpan> descriptionParts;

  const _SlideData({
    required this.title,
    required this.imagePath,
    required this.descriptionParts,
  });
}

class _SlidePage extends StatelessWidget {
  final _SlideData slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.5,
              color: const Color(0xFFE20000),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 280,
            height: 285,
            child: Image.asset(
              slide.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: -0.4,
                color: const Color(0xFF444444),
              ),
              children: slide.descriptionParts,
            ),
          ),
        ],
      ),
    );
  }
}