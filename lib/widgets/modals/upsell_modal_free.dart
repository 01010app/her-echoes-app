import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../system/app_button.dart';

const _kPkgIndividual = 'individual';
const _kPkgTrial      = 'trial';
const _kPkgFamiliar   = 'familiar';

enum _Plan { individual, familiar, trial }

class UpsellModalFree extends StatefulWidget {
  const UpsellModalFree({super.key});

  @override
  State<UpsellModalFree> createState() => _UpsellModalFreeState();
}

class _UpsellModalFreeState extends State<UpsellModalFree> {
  _Plan _selected = _Plan.individual;

  bool _loadingOfferings = true;
  Package? _pkgIndividual;
  Package? _pkgTrial;
  Package? _pkgFamiliar;

  bool _promoLoading = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        if (mounted) setState(() => _loadingOfferings = false);
        return;
      }
      Package? ind, trial, fam;
      for (final p in current.availablePackages) {
        if (p.identifier == _kPkgIndividual) ind   = p;
        if (p.identifier == _kPkgTrial)      trial = p;
        if (p.identifier == _kPkgFamiliar)   fam   = p;
      }
      if (mounted) {
        setState(() {
          _pkgIndividual    = ind;
          _pkgTrial         = trial;
          _pkgFamiliar      = fam;
          _loadingOfferings = false;
        });
      }
    } catch (e) {
      debugPrint('UpsellModal _loadOfferings error: $e');
      if (mounted) setState(() => _loadingOfferings = false);
    }
  }

  Package? get _activePackage {
    switch (_selected) {
      case _Plan.individual: return _pkgIndividual;
      case _Plan.familiar:   return _pkgFamiliar;
      case _Plan.trial:      return _pkgTrial;
    }
  }

  String _price(Package? pkg) => pkg?.storeProduct.priceString ?? '—';

  Future<void> _handlePurchase() async {
    final pkg = _activePackage;
    if (pkg == null) return;
    final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    final success = await subProvider.purchasePackage(pkg);
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _handleRestore() async {
    final isEnglish = context.read<LanguageProvider>().isEnglish;
    setState(() => _restoring = true);
    try {
      final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);
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

  Future<void> _redeemPromo() async {
    setState(() => _promoLoading = true);
    try {
      if (Platform.isIOS) {
        await Purchases.presentCodeRedemptionSheet();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El código se aplica durante el pago')),
          );
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _promoLoading = false);
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
    final isEnglish     = context.watch<LanguageProvider>().isEnglish;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final subProvider   = context.watch<SubscriptionProvider>();

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
              width: 36, height: 4,
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
                fontSize: 18, fontWeight: FontWeight.w600,
                height: 1.11, letterSpacing: -0.5,
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
                fontSize: 14, fontWeight: FontWeight.w400,
                height: 1.286, color: const Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_loadingOfferings)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: Color(0xFFE1002D)),
            )
          else ...[
            _PlanTile(
              selected: _selected == _Plan.individual,
              title: isEnglish ? "Individual Plan" : "Plan Individual",
              price: _price(_pkgIndividual),
              subtitle: isEnglish ? "Annual" : "Anual",
              trailing: null,
              onTap: () => setState(() => _selected = _Plan.individual),
            ),
            const SizedBox(height: 8),
            _PlanTile(
              selected: _selected == _Plan.familiar,
              title: isEnglish ? "Family Plan" : "Plan Familiar",
              price: _price(_pkgFamiliar),
              subtitle: isEnglish ? "Annual" : "Anual",
              trailing: isEnglish ? "Up to 3 people" : "Hasta 3 personas",
              onTap: () => setState(() => _selected = _Plan.familiar),
            ),
            const SizedBox(height: 24),
            _PlanTile(
              selected: _selected == _Plan.trial,
              title: isEnglish ? "Individual Trial Plan" : "Plan Individual Trial",
              price: _price(_pkgTrial),
              subtitle: isEnglish
                  ? "7-day free trial. Then renews annually."
                  : "7 días de prueba gratis. Luego se renueva anualmente.",
              trailing: null,
              onTap: () => setState(() => _selected = _Plan.trial),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: Center(
                child: OutlinedButton(
                  onPressed: _promoLoading ? null : _redeemPromo,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF70F3D),
                    side: const BorderSide(color: Color(0xFFF70F3D), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _promoLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE1002D)),
                        )
                      : Text(
                          isEnglish ? "I have a promo code" : "Tengo un código de promoción",
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            height: 16 / 14, color: const Color(0xFFF70F3D),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: subProvider.isPurchasing
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE1002D)))
                  : AppButton(
                      label: isEnglish ? "Subscribe" : "Suscribirme",
                      onPressed: _activePackage != null ? _handlePurchase : null,
                    ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _restoring ? null : _handleRestore,
              child: _restoring
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE1002D)),
                    )
                  : Text(
                      isEnglish ? "Restore purchases" : "Restaurar compras",
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500,
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
          ],
          SizedBox(height: 13 + bottomPadding),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _PlanTile({
    required this.selected,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF3F5) : const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFFE1002D) : const Color(0xFFDFDFDF),
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.only(left: 8, top: 16, right: 16, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? const Color(0xFFE1002D) : const Color(0xFFCCCCCC),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10, height: 10,
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
                                fontSize: 16, fontWeight: FontWeight.w600,
                                height: 1.0,
                                color: selected ? const Color(0xFFE1002D) : const Color(0xFF222222))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w400,
                                height: 1.3, color: const Color(0xFF444444))),
                        ),
                        if (trailing != null && trailing!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(trailing!,
                                style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w400,
                                  height: 1.0, color: const Color(0xFF888888))),
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
    );
  }
}
