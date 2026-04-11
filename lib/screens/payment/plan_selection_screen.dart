import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/language_provider.dart';
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
  bool _loading = false;
  bool _restoring = false;
  bool _loadingOfferings = true;

  Package? _individualPackage;
  Package? _trialPackage;
  Package? _familiarPackage;

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
          _individualPackage = current.availablePackages
              .where((p) => p.identifier == 'individual')
              .firstOrNull;
          _trialPackage = current.availablePackages
              .where((p) => p.identifier == 'trial')
              .firstOrNull;
          _familiarPackage = current.availablePackages
              .where((p) => p.identifier == 'familiar')
              .firstOrNull;
        });
      }
    } catch (e) {
      debugPrint('loadOfferings error: $e');
    } finally {
      if (mounted) setState(() => _loadingOfferings = false);
    }
  }

  String _individualPrice() {
    if (_loadingOfferings) return '...';
    return _individualPackage?.storeProduct.priceString ?? '—';
  }

  String _individualPricePerMonth() {
    if (_loadingOfferings) return '';
    final product = _individualPackage?.storeProduct;
    if (product == null) return '';
    final annual = product.price;
    final monthly = annual / 12;
    final raw = product.priceString;
    final symbol = raw.replaceAll(RegExp(r'[\d.,\s]'), '').trim();
    return '($symbol${monthly.toStringAsFixed(0)}/mes)';
  }

  String _trialPrice() {
    if (_loadingOfferings) return '...';
    return _trialPackage?.storeProduct.priceString ?? '—';
  }

  String _familiarPrice() {
    if (_loadingOfferings) return '...';
    return _familiarPackage?.storeProduct.priceString ?? '—';
  }

  Future<void> _handlePurchase() async {
    final isEnglish = context.read<LanguageProvider>().isEnglish;
    setState(() => _loading = true);
    try {
      Package? package;
      if (_selected == PlanType.individual) {
        package = _individualPackage;
      } else if (_selected == PlanType.trial) {
        package = _trialPackage;
      } else {
        package = _familiarPackage;
      }

      if (package == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEnglish
                ? 'Plans are temporarily unavailable. Please try again later.'
                : 'Los planes no están disponibles en este momento. Inténtalo más tarde.'),
          ));
        }
        return;
      }

      final subProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      final success = await subProvider.purchasePackage(package);

      if (success && mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return;
      if (mounted) {
        final isEnglish = context.read<LanguageProvider>().isEnglish;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEnglish
              ? 'There was a problem processing your purchase. Please try again.'
              : 'Hubo un problema al procesar tu compra. Inténtalo nuevamente.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        final isEnglish = context.read<LanguageProvider>().isEnglish;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEnglish
              ? 'There was a problem processing your purchase. Please try again.'
              : 'Hubo un problema al procesar tu compra. Inténtalo nuevamente.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
        Navigator.popUntil(context, (route) => route.isFirst);
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

  @override
  Widget build(BuildContext context) {
    final topPadding    = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish     = context.watch<LanguageProvider>().isEnglish;

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
                      isEnglish ? 'Subscribe to a Plan' : 'Suscríbete a un Plan',
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
            child: _loadingOfferings
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE1002D)))
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 24,
                            bottom: bottomPadding + 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Plan Individual
                            _PlanCard(
                              selected: _selected == PlanType.individual,
                              title: isEnglish ? 'Individual Plan' : 'Plan Individual',
                              price: _individualPrice(),
                              subtitle: isEnglish ? 'Annual' : 'Anual',
                              trailing: _individualPricePerMonth(),
                              onTap: () => setState(() => _selected = PlanType.individual),
                            ),
                            const SizedBox(height: 8),
                            // Plan Familiar
                            _PlanCard(
                              selected: _selected == PlanType.family,
                              title: isEnglish ? 'Family Plan' : 'Plan Familiar',
                              price: _familiarPrice(),
                              subtitle: isEnglish ? 'Annual' : 'Anual',
                              trailing: isEnglish ? 'Up to 3 people' : 'Hasta 3 personas',
                              onTap: () => setState(() => _selected = PlanType.family),
                            ),
                            const SizedBox(height: 24),
                            // Plan Trial — separado visualmente
                            _PlanCard(
                              selected: _selected == PlanType.trial,
                              title: isEnglish ? 'Individual Trial Plan' : 'Plan Individual Trial',
                              price: _trialPrice(),
                              subtitle: isEnglish
                                  ? '7-day free trial. Then renews annually.'
                                  : '7 días de prueba gratis. Luego se renueva anualmente.',
                              onTap: () => setState(() => _selected = PlanType.trial),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: bottomPadding + 16,
                        left: 24, right: 24,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_loading)
                              const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFE1002D)),
                              )
                            else
                              AppButton(
                                label: isEnglish ? 'Subscribe' : 'Suscribirse',
                                onPressed: _handlePurchase,
                              ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _restoring ? null : _handleRestore,
                              child: _restoring
                                  ? const SizedBox(
                                      height: 20, width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFE1002D)),
                                    )
                                  : Text(
                                      isEnglish
                                          ? 'Restore purchases'
                                          : 'Restaurar compras',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFE1002D)),
                                    ),
                            ),
                          ],
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
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _PlanCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.subtitle,
    this.trailing,
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
        padding: const EdgeInsets.only(left: 8, top: 16, right: 16, bottom: 12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(subtitle,
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w400,
                                height: 1.3,
                                color: const Color(0xFF444444))),
                      ),
                      if (trailing != null && trailing!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(trailing!,
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w400,
                                  height: 1.0,
                                  color: const Color(0xFF888888))),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}