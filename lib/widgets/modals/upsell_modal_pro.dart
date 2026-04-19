import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../screens/payment/plan_selection_screen.dart';
import '../system/app_button.dart';

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
  bool _loadingOfferings = true;
  bool _restoring = false;
  Package? _pkgFamiliar;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        setState(() {
          _pkgFamiliar = current.availablePackages
              .where((p) => p.identifier == 'familiar')
              .firstOrNull;
        });
      }
    } catch (e) {
      debugPrint('UpsellModalPro _loadOfferings error: $e');
    } finally {
      if (mounted) setState(() => _loadingOfferings = false);
    }
  }

  Future<void> _handleRestore() async {
    final isEnglish = context.read<LanguageProvider>().isEnglish;
    setState(() => _restoring = true);
    try {
      final subProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      final success = await subProvider.restorePurchases();
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEnglish
              ? 'No active subscription found.'
              : 'No se encontró una suscripción activa.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        final isEnglish = context.read<LanguageProvider>().isEnglish;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEnglish
              ? 'Could not restore purchases. Please try again.'
              : 'No se pudieron restaurar las compras. Inténtalo nuevamente.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final familiarPrice = _pkgFamiliar?.storeProduct.priceString ?? '—';

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

          if (_loadingOfferings)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: Color(0xFFE1002D)),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F5),
                  border: Border.all(
                    color: const Color(0xFFF70F3D),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
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
                              color: const Color(0xFF1B1B1B),
                            ),
                          ),
                        ),
                        Text(
                          familiarPrice,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            color: const Color(0xFFE20000),
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
                            height: 1.0,
                            color: const Color(0xFF222222),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              label: isEnglish ? "Upgrade your Plan" : "Actualiza tu Plan",
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlanSelectionScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _restoring ? null : _handleRestore,
            child: _restoring
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFE1002D)),
                  )
                : Text(
                    isEnglish ? "Restore purchases" : "Restaurar compras",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE1002D),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          // ── Links legales exigidos por Apple (Guideline 3.1.2c) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _launchUrl(
                    'https://callmehector.cl/apps/herechoes/terminos.html'),
                child: Text(
                  isEnglish ? 'Terms of Use' : 'Términos de uso',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                      decoration: TextDecoration.underline),
                ),
              ),
              Text('  ·  ',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF888888))),
              GestureDetector(
                onTap: () => _launchUrl(
                    'https://callmehector.cl/apps/herechoes/privacidad.html'),
                child: Text(
                  isEnglish ? 'Privacy Policy' : 'Política de privacidad',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 + bottomPadding),
        ],
      ),
    );
  }
}
