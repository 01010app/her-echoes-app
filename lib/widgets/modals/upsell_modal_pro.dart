import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

class UpsellModalPro extends StatefulWidget {
  final String currentHomeImage;

  const UpsellModalPro({
    super.key,
    required this.currentHomeImage,
  });

  @override
  State<UpsellModalPro> createState() => _UpsellModalProState();
}

class _UpsellModalProState extends State<UpsellModalPro> {
  bool _remindMe = true;

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const currency = 'CLP';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // DRAG HANDLE
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // TÍTULO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isEnglish
                  ? "A daily dose of inspiration for your family"
                  : "Una dosis de inspiración diaria a tu familia",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.25,
                letterSpacing: -0.5,
                color: const Color(0xFF767676),
              ),
            ),
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isEnglish
                  ? "(You currently have an Individual Plan)."
                  : "(Actualmente tienes un Plan Individual).",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: -0.5,
                color: const Color(0xFF222222),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // PLAN FAMILIAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F5),
                border: Border.all(
                  color: const Color(0xFFF70F3D),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        isEnglish ? "Family" : "Familiar",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          color: const Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currency,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          color: const Color(0xFFE20000),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          "16.500",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            letterSpacing: -0.2,
                            color: const Color(0xFFE20000),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          "($currency 1.375/mes)",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                            color: const Color(0xFF1B1B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEnglish ? "Annual billing" : "Anual",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                            color: const Color(0xFF222222),
                          ),
                        ),
                      ),
                      Text(
                        isEnglish ? "Up to 3 people" : "Hasta 3 personas",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          color: const Color(0xFF1B1B1B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: navegar a pantalla de pago
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE1002D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Text(
                  isEnglish ? "Upgrade your Plan" : "Actualiza tu Plan",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // TOGGLE RECORDAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEnglish
                        ? "Remind me 3 days before renewal"
                        : "Recordarme 3 días antes de la renovación",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: const Color(0xFF434343),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _remindMe = !_remindMe),
                  child: PhosphorIcon(
                    _remindMe
                        ? PhosphorIcons.toggleRight(PhosphorIconsStyle.fill)
                        : PhosphorIcons.toggleLeft(PhosphorIconsStyle.fill),
                    size: 36,
                    color: _remindMe
                        ? const Color(0xFFF70F3D)
                        : const Color(0xFF949494),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8 + bottomPadding),
        ],
      ),
    );
  }
}