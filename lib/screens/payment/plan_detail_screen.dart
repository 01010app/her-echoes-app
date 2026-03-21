import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/theme/app_colors.dart';

class PlanDetailScreen extends StatelessWidget {
  const PlanDetailScreen({super.key});

  Future<void> _openAppleSubscriptions(BuildContext context) async {
    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isEnglish  = context.watch<LanguageProvider>().isEnglish;
    final sub        = context.watch<SubscriptionProvider>();
    final isPro      = sub.isPro;

    final activePackage = sub.activePackage;
    final planName      = activePackage?.storeProduct.title
        ?? (isPro
            ? (isEnglish ? "Pro Plan" : "Plan Pro")
            : (isEnglish ? "No active plan" : "Sin plan activo"));
    final planPrice  = activePackage?.storeProduct.priceString ?? "—";
    final planPeriod = isEnglish ? "Monthly" : "Mensual";

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
                      isEnglish ? "My Subscription" : "Mi Suscripción",
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
                  border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
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
                        Text(isEnglish ? "Billing" : "Periodicidad",
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w400,
                                color: const Color(0xFF222222))),
                        Text(planPeriod,
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
                        onTap: () => _openAppleSubscriptions(context),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: const Color(0xFFE1002D).withOpacity(0.12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE1002D)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            isEnglish ? "Manage Subscription" : "Gestionar Suscripción",
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: const Color(0xFFE1002D)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEnglish
                          ? "To cancel or change your plan, manage your subscription from your App Store account settings."
                          : "Para cancelar o cambiar tu plan, gestiona tu suscripción desde los ajustes de tu cuenta en App Store.",
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888), height: 1.5),
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