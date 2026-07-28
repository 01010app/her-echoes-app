import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(height: topPadding, color: Colors.white),
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.background, shape: BoxShape.circle),
                    child: Center(
                      child: PhosphorIcon(
                          PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                          size: 20,
                          color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      isEnglish ? "About Us" : "Acerca de Nosotros",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: -0.5,
                          color: const Color(0xFF404040)),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    isEnglish ? "Our Mission" : "Misión",
                    style: GoogleFonts.gloock(
                      fontSize: 24,
                      color: const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEnglish ? _missionEn : _missionEs,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.7,
                      color: const Color(0xFF404040),
                    ),
                  ),
                  SizedBox(height: bottomPadding + 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String _missionEs = '''
Her Echoes existe para dar voz y visibilidad a cientos de historias de mujeres que han dejado huella en distintas áreas: ciencia, arte, deporte, activismo, e incluso social y política.

No promovemos ninguna ideología política, religiosa ni de ningún otro tipo. Algunas de las mujeres presentadas participaron o participan activamente en política y pueden representar posturas de izquierda, derecha, o incluso comunismo u otras corrientes. Su inclusión no es un respaldo a esas ideas, ni a ninguna postura moral por las que las mujeres puedan ser reconocidas; sino más bien un reconocimiento a su esfuerzo, trayectoria y contribución en su campo, o a aportes específicos a la sociedad.

Nuestro criterio de selección se basa en el impacto real de cada mujer en su área, no en su postura política, religiosa o personal.

Creemos que cada persona, sea hombre o mujer, tiene el derecho de elegir su propio camino y tener sus propias ideas, y muchas veces esas ideas van a contrastar con las de otras personas. Parte del respeto por las creencias de cada uno radica también en la capacidad de reconocer el mérito y el legado. Por eso, si te encuentras con la historia de una mujer que no comparte tus mismas ideas o conceptos morales, te invitamos a darte el tiempo de conocer un poco de su historia. Seguro encontrarás algo que te llame la atención. Y siempre contarás con distintas historias nuevas para descubrir cada día.
''';

const String _missionEn = '''
Her Echoes exists to give voice and visibility to hundreds of stories of women who have left their mark across different fields: science, art, sports, activism, and even social and political life.

We do not promote any political, religious, or other ideology. Some of the women featured were or are actively involved in politics and may represent left-wing, right-wing, or even communist views, among other stances. Their inclusion is not an endorsement of those ideas, nor of any moral stance for which these women may be recognized, it is a recognition of their effort, career, and contribution to their field, or of their specific contributions to society.

Our selection criteria is based on each woman's real impact in her field, not on her political, religious, or personal views.

We believe every person, man or woman, has the right to choose their own path and hold their own ideas — and those ideas will often differ from other people's. Part of respecting each person's beliefs also means being able to recognize merit and legacy. So if you come across the story of a woman who doesn't share your own ideas or moral views, we invite you to take a moment to learn a bit about her story. You're likely to find something that catches your attention. And you'll always have new stories to discover, every day.
''';