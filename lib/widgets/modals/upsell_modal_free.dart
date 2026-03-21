import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../system/app_button.dart';

const _kPkgIndividual = 'individual';
const _kPkgTrial      = 'trial';
const _kPkgFamiliar   = 'familiar';

class UpsellModalFree extends StatefulWidget {
  const UpsellModalFree({super.key});

  @override
  State<UpsellModalFree> createState() => _UpsellModalFreeState();
}

class _UpsellModalFreeState extends State<UpsellModalFree> {
  bool _selectedIndividual = true;
  bool _freeTrial = false;

  bool _loadingOfferings = true;
  Package? _pkgIndividual;
  Package? _pkgTrial;
  Package? _pkgFamiliar;

  bool _promoLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      // DEBUG — pégame en el chat lo que aparece en Terminal
      debugPrint('=== OFFERINGS current: $current ===');
      if (current != null) {
        for (final p in current.availablePackages) {
          debugPrint('Package identifier: "${p.identifier}" | precio: ${p.storeProduct.priceString}');
        }
      }

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

      debugPrint('ind: $ind | trial: $trial | fam: $fam');

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
    if (_selectedIndividual) {
      return _freeTrial ? _pkgTrial : _pkgIndividual;
    }
    return _pkgFamiliar;
  }

  String _price(Package? pkg) =>
      pkg?.storeProduct.priceString ?? '—';

  Future<void> _handlePurchase() async {
    final pkg = _activePackage;
    if (pkg == null) return;
    final subProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    final success = await subProvider.purchasePackage(pkg);
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _redeemPromo() async {
    setState(() => _promoLoading = true);
    try {
      if (Platform.isIOS) {
        await Purchases.presentCodeRedemptionSheet();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El código se aplica durante el pago'),
            ),
          );
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _promoLoading = false);
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

          if (_loadingOfferings)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: Color(0xFFE1002D)),
            )
          else ...[
            // ── Plan Individual ──────────────────────────────────────────
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
                      left: 8, top: 16, right: 16, bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RadioDot(selected: _selectedIndividual),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isEnglish
                                        ? "Individual Plan"
                                        : "Plan Individual",
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
                                    _selectedIndividual
                                        ? _price(_freeTrial
                                            ? _pkgTrial
                                            : _pkgIndividual)
                                        : _price(_pkgIndividual),
                                    key: ValueKey('ind_$_freeTrial'),
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
                            Text(
                              isEnglish ? "Monthly" : "Mensual",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.14,
                                color: const Color(0xFF444444),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_pkgTrial != null)
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
                                    onTap: () => setState(
                                        () => _freeTrial = !_freeTrial),
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

            // ── Plan Familiar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedIndividual = false;
                  _freeTrial = false;
                }),
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
                      left: 8, top: 16, right: 16, bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RadioDot(selected: !_selectedIndividual),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isEnglish
                                        ? "Family Plan"
                                        : "Plan Familiar",
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
                                  _price(_pkgFamiliar),
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isEnglish ? "Monthly" : "Mensual",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.14,
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                                Text(
                                  isEnglish
                                      ? "Up to 3 people"
                                      : "Hasta 3 personas",
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

            // ── Botón código de promoción ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: Center(
                child: OutlinedButton(
                  onPressed: _promoLoading ? null : _redeemPromo,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF70F3D),
                    side: const BorderSide(
                        color: Color(0xFFF70F3D), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _promoLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE1002D),
                          ),
                        )
                      : Text(
                          isEnglish
                              ? "I have a promo code"
                              : "Tengo un código de promoción",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 16 / 14,
                            color: const Color(0xFFF70F3D),
                          ),
                        ),
                ),
              ),
            ),

            // ── CTA Suscribirse ──────────────────────────────────────────
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: subProvider.isPurchasing
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFE1002D)))
                  : AppButton(
                      label: isEnglish ? "Subscribe" : "Suscribirme",
                      onPressed:
                          _activePackage != null ? _handlePurchase : null,
                    ),
            ),
          ],

          SizedBox(height: 13 + bottomPadding),
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE20000), width: 2),
        ),
        child: selected
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
    );
  }
}