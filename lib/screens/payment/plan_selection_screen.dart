import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/language_provider.dart';
import '../../core/currency_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/system/app_button.dart';
import 'plan_type.dart';

export 'plan_type.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  PlanType _selected = PlanType.individual;
  bool _freeTrial = true;
  bool _loading = false;

  Future<void> _handlePurchase() async {
    setState(() => _loading = true);
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) throw Exception('No offerings');

      Package? package;
      if (_selected == PlanType.individual && _freeTrial) {
        package = current.availablePackages
            .firstWhere((p) => p.identifier == 'trial',
                orElse: () => current.availablePackages.first);
      } else if (_selected == PlanType.individual) {
        package = current.availablePackages
            .firstWhere((p) => p.identifier == 'individual',
                orElse: () => current.availablePackages.first);
      } else {
        package = current.availablePackages
            .firstWhere((p) => p.identifier == 'familiar',
                orElse: () => current.availablePackages.first);
      }

      final subProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      final success = await subProvider.purchasePackage(package);

      if (success && mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding    = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish     = context.watch<LanguageProvider>().isEnglish;
    final pricing       = context.watch<CurrencyProvider>().pricing;

    final individualPrice = _freeTrial
        ? pricing.format(pricing.individualTrial)
        : pricing.format(pricing.individualAnnual);
    final familyPrice = pricing.format(pricing.familyAnnual);

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
                      isEnglish ? "Subscribe to a Plan" : "Suscríbete a un Plan",
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                      left: 16, right: 16, top: 24,
                      bottom: bottomPadding + 100),
                  child: Column(
                    children: [
                      _PlanCard(
                        selected: _selected == PlanType.individual,
                        title: isEnglish ? "Individual Plan" : "Plan Individual",
                        price: individualPrice,
                        periodicity: isEnglish ? "Monthly" : "Mensual",
                        trailLabel: isEnglish
                            ? "With 7-day free trial"
                            : "Con prueba gratuita de 7 días",
                        showTrialToggle: true,
                        trialEnabled: _freeTrial,
                        onTrialToggle: (val) =>
                            setState(() => _freeTrial = val),
                        onTap: () =>
                            setState(() => _selected = PlanType.individual),
                      ),
                      const SizedBox(height: 12),
                      _PlanCard(
                        selected: _selected == PlanType.family,
                        title: isEnglish ? "Family Plan" : "Plan Familiar",
                        price: familyPrice,
                        periodicity: isEnglish ? "Monthly" : "Mensual",
                        onTap: () =>
                            setState(() => _selected = PlanType.family),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: bottomPadding + 16,
                  left: 24, right: 24,
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE1002D)))
                      : AppButton(
                          label: isEnglish ? "Subscribe" : "Suscribirme",
                          onPressed: _handlePurchase,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final String periodicity;
  final String? trailLabel;
  final bool showTrialToggle;
  final bool trialEnabled;
  final ValueChanged<bool>? onTrialToggle;
  final VoidCallback onTap;

  const _PlanCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.periodicity,
    this.trailLabel,
    this.showTrialToggle = false,
    this.trialEnabled = false,
    this.onTrialToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFE1002D) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.only(
            left: 8, top: 16, right: 16, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFE1002D)
                        : const Color(0xFFCCCCCC),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                              color: Color(0xFFE1002D),
                              shape: BoxShape.circle),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(title,
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w500,
                                height: 1.0, letterSpacing: -0.2,
                                color: const Color(0xFF444444))),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(price,
                            key: ValueKey(price),
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                height: 1.23,
                                color: const Color(0xFF222222))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(periodicity,
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w400,
                              height: 1.14,
                              color: const Color(0xFF444444))),
                    ],
                  ),
                  if (showTrialToggle && trailLabel != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(trailLabel!,
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w500,
                                  height: 1.5, letterSpacing: -0.5,
                                  color: const Color(0xFF434343))),
                        ),
                        GestureDetector(
                          onTap: () => onTrialToggle?.call(!trialEnabled),
                          child: PhosphorIcon(
                            trialEnabled
                                ? PhosphorIcons.toggleRight(
                                    PhosphorIconsStyle.fill)
                                : PhosphorIcons.toggleLeft(
                                    PhosphorIconsStyle.fill),
                            size: 36,
                            color: trialEnabled
                                ? const Color(0xFFF70F3D)
                                : const Color(0xFF949494),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}