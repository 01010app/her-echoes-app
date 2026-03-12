import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/system/app_button.dart';
import 'plan_type.dart';
import 'plan_selection_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  final PlanType planType;
  final String cardLast4;
  final String cardHolder;
  final String cardExpiry;

  const PaymentMethodScreen({
    super.key,
    required this.planType,
    required this.cardLast4,
    required this.cardHolder,
    required this.cardExpiry,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Center(
                    child: Text(
                      isEnglish ? "Payment method" : "Medio de pago",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF404040),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 44),

              ],
            ),
          ),

          Expanded(
            child: PaymentMethodBody(
              isEnglish: isEnglish,
              planType: planType,
              cardLast4: cardLast4,
              cardHolder: cardHolder,
              cardExpiry: cardExpiry,
              bottomPadding: bottomPadding,
            ),
          ),

        ],
      ),
    );
  }
}

class PaymentMethodBody extends StatelessWidget {
  final bool isEnglish;
  final PlanType planType;
  final String cardLast4;
  final String cardHolder;
  final String cardExpiry;
  final double bottomPadding;

  const PaymentMethodBody({
    super.key,
    required this.isEnglish,
    this.planType = PlanType.individual,
    this.cardLast4 = "0000",
    this.cardHolder = "CARD HOLDER",
    this.cardExpiry = "01/30",
    this.bottomPadding = 0,
  });

  String get _planName => planType == PlanType.individual
      ? (isEnglish ? "Individual Plan" : "Plan Individual")
      : (isEnglish ? "Family Plan" : "Plan Familiar");

  String get _planPrice =>
      planType == PlanType.individual ? "CLP 9.900" : "CLP 16.500";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: bottomPadding + 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? "Contracted Plan" : "Plan contratado",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        letterSpacing: -0.5,
                        color: const Color(0xFF6C6868),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _planName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                            letterSpacing: -0.2,
                            color: const Color(0xFF404040),
                          ),
                        ),
                        Text(
                          _planPrice,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 16 / 13,
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
                          isEnglish ? "Periodicity" : "Periodicidad",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 16 / 14,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        Text(
                          isEnglish ? "Annual" : "Anual",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 16 / 14,
                            color: const Color(0xFF222222),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PlanSelectionScreen()),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: const Color(0xFFE1002D).withOpacity(0.12),
                        highlightColor: const Color(0xFFE1002D).withOpacity(0.06),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE1002D)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            isEnglish ? "Change Plan" : "Cambiar de Plan",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE1002D),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEnglish ? "Payment methods" : "Medios de pago",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: -0.5,
                  color: const Color(0xFF404040),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "VISA",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Visa •••• $cardLast4",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            "${isEnglish ? "Expires" : "Vence"} $cardExpiry",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isEnglish ? "Main" : "Principal",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: bottomPadding + 40,
          left: 24,
          right: 24,
          child: AppButton(
            label: isEnglish ? "Cancel subscription" : "Cancelar suscripción",
            onPressed: () => _showCancelDialog(context),
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.warning(PhosphorIconsStyle.fill),
                  color: const Color(0xFFF70F3D),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEnglish ? "Cancel subscription?" : "¿Cancelar suscripción?",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEnglish
                  ? "You will lose access to PRO features at the end of your billing period."
                  : "Perderás acceso a las funciones PRO al final de tu período de facturación.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF777777),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: isEnglish ? "Keep subscription" : "Mantener suscripción",
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // TODO: conectar cancelación real con RevenueCat
              },
              child: Text(
                isEnglish ? "Yes, cancel" : "Sí, cancelar",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}