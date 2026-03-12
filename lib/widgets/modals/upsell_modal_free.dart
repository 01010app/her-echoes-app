import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../screens/payment/plan_type.dart';
import '../../screens/payment/add_card_screen.dart';
import '../system/app_button.dart';

class UpsellModalFree extends StatefulWidget {
  const UpsellModalFree({super.key});

  @override
  State<UpsellModalFree> createState() => _UpsellModalFreeState();
}

class _UpsellModalFreeState extends State<UpsellModalFree> {
  bool _selectedIndividual = true;
  bool _freeTrial = false;

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final individualPrice = _freeTrial ? "16.800" : "9.900";
    final individualMonthly = _freeTrial ? "(CLP 1.400/mes)" : "(CLP 825/mes)";

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              isEnglish
                  ? "Choose your Plan and get inspired daily"
                  : "Elige tu Plan e inspírate diariamente",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.11,
                letterSpacing: -0.5,
                color: const Color(0xFF404040),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              isEnglish
                  ? "Discover and share the legacy of hundreds of women, save your Favorites, and more without limits."
                  : "Descubre y comparte todo el legado de cientos de mujeres, guarda tus Favoritas, etc. sin restricciones.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.286,
                color: const Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndividual = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: _selectedIndividual
                      ? const Color(0xFFFFF3F5)
                      : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedIndividual
                        ? const Color(0xFFE1002D)
                        : const Color(0xFFDFDFDF),
                    width: _selectedIndividual ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE20000),
                            width: 2,
                          ),
                        ),
                        child: _selectedIndividual
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE1002D),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isEnglish ? "Individual Plan" : "Plan Individual",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                    letterSpacing: -0.2,
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  "CLP $individualPrice",
                                  key: ValueKey(individualPrice),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.0,
                                    color: const Color(0xFFE1002D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEnglish ? "Annual" : "Anual",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.14,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  individualMonthly,
                                  key: ValueKey(individualMonthly),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.14,
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isEnglish
                                      ? "With 7-day free trial"
                                      : "Con prueba gratuita de 7 días",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    letterSpacing: -0.5,
                                    color: const Color(0xFF434343),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _freeTrial = !_freeTrial),
                                child: PhosphorIcon(
                                  _freeTrial
                                      ? PhosphorIcons.toggleRight(
                                          PhosphorIconsStyle.fill)
                                      : PhosphorIcons.toggleLeft(
                                          PhosphorIconsStyle.fill),
                                  size: 36,
                                  color: _freeTrial
                                      ? const Color(0xFFF70F3D)
                                      : const Color(0xFF949494),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndividual = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: !_selectedIndividual
                      ? const Color(0xFFFFF3F5)
                      : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: !_selectedIndividual
                        ? const Color(0xFFE1002D)
                        : const Color(0xFFDFDFDF),
                    width: !_selectedIndividual ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 16,
                  right: 16,
                  bottom: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE20000),
                            width: 2,
                          ),
                        ),
                        child: !_selectedIndividual
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE1002D),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isEnglish ? "Family Plan" : "Plan Familiar",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                    letterSpacing: -0.2,
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                              ),
                              Text(
                                "CLP 16.500",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEnglish ? "Annual" : "Anual",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.14,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                              Text(
                                isEnglish ? "Up to 3 people" : "Hasta 3 personas",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.14,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              label: isEnglish ? "Subscribe" : "Suscribirse",
              onPressed: () {
                final priceToPass = _selectedIndividual
                    ? "CLP ${_freeTrial ? '16.800' : '9.900'}"
                    : "CLP 16.500";
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCardScreen(
                      selectedPlan: _selectedIndividual
                          ? PlanType.individual
                          : PlanType.family,
                      freeTrial: _selectedIndividual ? _freeTrial : false,
                      planPrice: priceToPass,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 13 + bottomPadding),
        ],
      ),
    );
  }
}