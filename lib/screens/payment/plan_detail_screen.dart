import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/currency_provider.dart';
import '../../core/theme/app_colors.dart';
import 'plan_selection_screen.dart';

class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isEnglish  = context.watch<LanguageProvider>().isEnglish;
    final isPro      = context.watch<SubscriptionProvider>().isPro;
    final pricing    = context.watch<CurrencyProvider>().pricing;

    final planName  = isPro
        ? (isEnglish ? "Individual Plan" : "Plan Individual")
        : (isEnglish ? "No active plan" : "Sin plan activo");
    final planPrice = isPro
        ? pricing.format(pricing.individualAnnual)
        : "—";

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
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.background, shape: BoxShape.circle),
                    child: Center(
                      child: PhosphorIcon(
                          PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                          size: 20, color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      isEnglish ? "Plan Details" : "Detalle Plan",
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600,
                          height: 1.5, letterSpacing: -0.5,
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
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFDFDFDF), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? "Contracted Plan" : "Plan contratado",
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          height: 1.4, letterSpacing: -0.5,
                          color: const Color(0xFF6C6868)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(planName,
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w500,
                                height: 1.0, letterSpacing: -0.2,
                                color: const Color(0xFF404040))),
                        Text(planPrice,
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: const Color(0xFF222222))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEnglish ? "Periodicity" : "Periodicidad",
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w400,
                                color: const Color(0xFF222222))),
                        Text(isEnglish ? "Annual" : "Anual",
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w400,
                                color: const Color(0xFF222222))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const PlanSelectionScreen())),
                        borderRadius: BorderRadius.circular(12),
                        splashColor:
                            const Color(0xFFE1002D).withOpacity(0.12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFE1002D)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            isEnglish ? "Change Plan" : "Cambiar de Plan",
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: const Color(0xFFE1002D)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}