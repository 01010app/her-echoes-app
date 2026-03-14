import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/system/app_button.dart';
import 'plan_type.dart';
import 'plan_selection_screen.dart';
import 'payment_method_screen.dart';

enum _CardError { none, declined, expired, noFunds, invalidCvv }
enum _CouponState { idle, loading, valid, invalid }

class AddCardScreen extends StatefulWidget {
  final PlanType selectedPlan;
  final bool freeTrial;
  final String? planPrice;

  const AddCardScreen({
    super.key,
    required this.selectedPlan,
    required this.freeTrial,
    this.planPrice,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController     = TextEditingController();
  final _holderController     = TextEditingController();
  final _cvvController        = TextEditingController();
  final _couponController     = TextEditingController();

  bool _showPlanBanner = true;
  bool _isLoading      = false;
  _CardError   _error             = _CardError.none;
  _CouponState _couponState       = _CouponState.idle;
  String?      _couponType;
  int?         _couponValue;
  String?      _appliedCode;
  int          _couponTrialMonths = 1;

  static const _couponsUrl =
      'https://callmehector.cl/apps/herechoes/coupons.php';

  bool get _isFormValid =>
      _cardNumberController.text.replaceAll(' ', '').length == 16 &&
      _expiryController.text.length == 5 &&
      _holderController.text.trim().isNotEmpty &&
      _cvvController.text.length >= 3;

  int get _basePrice {
    final raw = (widget.planPrice ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ??
        (widget.selectedPlan == PlanType.individual ? 9900 : 16500);
  }

  int get _discountedPrice {
    if (_couponState != _CouponState.valid) return _basePrice;
    if (_couponType == 'percent') {
      return (_basePrice * (100 - _couponValue!) / 100).round();
    }
    return (_basePrice - _couponValue!).clamp(0, _basePrice);
  }

  String _formatCLP(int amount) {
    final s = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return 'CLP ${result.toString()}';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _holderController.dispose();
    _cvvController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _validateCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _couponState = _CouponState.loading);
    try {
      final res = await http
          .get(Uri.parse('$_couponsUrl?code=$code'))
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      final data = json.decode(res.body) as Map<String, dynamic>;
      if (data['valid'] == true) {
        setState(() {
          _couponState       = _CouponState.valid;
          _couponType        = data['type'] as String;
          _couponValue       = (data['value'] as num).toInt();
          _appliedCode       = code;
          _couponTrialMonths = (data['trial_months'] as num?)?.toInt() ?? 1;
        });
      } else {
        setState(() {
          _couponState = _CouponState.invalid;
          _couponType  = null;
          _couponValue = null;
          _appliedCode = null;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _couponState = _CouponState.invalid);
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponState       = _CouponState.idle;
      _couponType        = null;
      _couponValue       = null;
      _appliedCode       = null;
      _couponTrialMonths = 1;
      _couponController.clear();
    });
  }

  Future<void> _submit(BuildContext context) async {
    setState(() { _isLoading = true; _error = _CardError.none; });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final digits = _cardNumberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text;
    final cvv    = _cvvController.text;

    _CardError error = _CardError.none;
    if (digits.startsWith('4000000000000002')) {
      error = _CardError.declined;
    } else if (expiry == '00/00' || _isExpired(expiry)) {
      error = _CardError.expired;
    } else if (digits.startsWith('4000000000009995')) {
      error = _CardError.noFunds;
    } else if (cvv == '000') {
      error = _CardError.invalidCvv;
    }

    if (error != _CardError.none) {
      setState(() { _isLoading = false; _error = error; });
      return;
    }

    if (_couponState == _CouponState.valid && _appliedCode != null) {
      try {
        await http.post(
          Uri.parse(_couponsUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'password': 'Promisedland.1974',
            'code': _appliedCode,
          }),
        );
      } catch (_) {}
    }

    setState(() => _isLoading = false);
    context.read<SubscriptionProvider>().setIsPro(true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(
          planType:   widget.selectedPlan,
          cardLast4:  digits.substring(12),
          cardHolder: _holderController.text.trim(),
          cardExpiry: _expiryController.text,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  bool _isExpired(String expiry) {
    if (expiry.length != 5) return false;
    final parts = expiry.split('/');
    if (parts.length != 2) return false;
    final month = int.tryParse(parts[0]) ?? 0;
    final year  = int.tryParse('20${parts[1]}') ?? 0;
    return DateTime(year, month + 1).isBefore(DateTime.now());
  }

  String _errorMessage(bool isEnglish) {
    switch (_error) {
      case _CardError.declined:
        return isEnglish
            ? 'Your card was declined. Please try a different card.'
            : 'Tu tarjeta fue rechazada. Intenta con otra tarjeta.';
      case _CardError.expired:
        return isEnglish
            ? 'Your card has expired. Please check the expiry date.'
            : 'Tu tarjeta está vencida. Verifica la fecha de expiración.';
      case _CardError.noFunds:
        return isEnglish
            ? 'Insufficient funds. Please try a different card.'
            : 'Fondos insuficientes. Intenta con otra tarjeta.';
      case _CardError.invalidCvv:
        return isEnglish
            ? 'Invalid CVV. Please check and try again.'
            : 'CVV inválido. Verifica e intenta nuevamente.';
      case _CardError.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding    = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish     = context.watch<LanguageProvider>().isEnglish;

    final isIndividual = widget.selectedPlan == PlanType.individual;
    final planName = isEnglish
        ? (isIndividual ? 'Individual Plan' : 'Family Plan')
        : (isIndividual ? 'Plan Individual' : 'Plan Familiar');
    final planPrice = widget.planPrice ??
        (isIndividual ? 'CLP 9.900' : 'CLP 16.500');

    final hasCoupon = _couponState == _CouponState.valid;

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
                      isEnglish ? 'Add payment method' : 'Agregar medio de pago',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Banner plan ──────────────────────────
                      if (_showPlanBanner) ...[
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFDFDFDF), width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(planName,
                                        style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                            color: const Color(0xFF404040))),
                                    const SizedBox(height: 4),
                                    Text(isEnglish ? 'Billing' : 'Periodicidad',
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            height: 1.2,
                                            color: const Color(0xFF404040))),
                                    const SizedBox(height: 10),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const PlanSelectionScreen()),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 2),
                                          child: Text(
                                            isEnglish ? 'Change Plan' : 'Cambiar de Plan',
                                            style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                                color: AppColors.accent),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(planPrice,
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          color: const Color(0xFF404040))),
                                  const SizedBox(height: 4),
                                  Text(isEnglish ? 'Annual' : 'Anual',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
                                          color: const Color(0xFF404040))),
                                ],
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showPlanBanner = false),
                                child: PhosphorIcon(
                                    PhosphorIcons.x(PhosphorIconsStyle.bold),
                                    size: 18,
                                    color: const Color(0xFF888888)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Card preview ─────────────────────────
                      _CardPreview(
                        cardNumber: _cardNumberController.text,
                        cardHolder: _holderController.text,
                        expiry: _expiryController.text,
                      ),
                      const SizedBox(height: 28),

                      // ── Banner error tarjeta ─────────────────
                      if (_error != _CardError.none) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFE1002D).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              PhosphorIcon(
                                  PhosphorIcons.warningCircle(
                                      PhosphorIconsStyle.fill),
                                  size: 20,
                                  color: const Color(0xFFE1002D)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_errorMessage(isEnglish),
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFE1002D),
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Campos tarjeta ───────────────────────
                      _FieldLabel(isEnglish ? 'Card number' : 'Número de tarjeta'),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _cardNumberController,
                        hint: isEnglish
                            ? 'Insert your credit card number'
                            : 'Ingresa el número de tu tarjeta',
                        keyboardType: TextInputType.number,
                        hasError: _error == _CardError.declined ||
                            _error == _CardError.noFunds,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
                          LengthLimitingTextInputFormatter(19),
                        ],
                        onChanged: (_) => setState(() => _error = _CardError.none),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(isEnglish ? 'Expiry date' : 'Fecha de expiración'),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _expiryController,
                        hint: 'MM/YY',
                        keyboardType: TextInputType.number,
                        hasError: _error == _CardError.expired,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ExpiryFormatter(),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        onChanged: (_) => setState(() => _error = _CardError.none),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(isEnglish ? 'Card holder' : 'Nombre en la tarjeta'),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _holderController,
                        hint: isEnglish ? 'Name on the card' : 'El nombre en la tarjeta',
                        keyboardType: TextInputType.name,
                        inputFormatters: [],
                        onChanged: (_) => setState(() => _error = _CardError.none),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('CVV'),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _cvvController,
                        hint: 'CVV',
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        hasError: _error == _CardError.invalidCvv,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        onChanged: (_) => setState(() => _error = _CardError.none),
                      ),

                      // ── Código de promoción ──────────────────
                      const SizedBox(height: 16),
                      _FieldLabel(isEnglish ? 'Promotion code' : 'Código de promoción'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: hasCoupon
                                    ? const Color(0xFFF0FFF4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _couponState == _CouponState.invalid
                                      ? const Color(0xFFE1002D).withOpacity(0.6)
                                      : hasCoupon
                                          ? const Color(0xFF27AE60).withOpacity(0.5)
                                          : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _couponController,
                                enabled: !hasCoupon,
                                textCapitalization: TextCapitalization.characters,
                                cursorColor: const Color(0xFFF70F3D),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: hasCoupon
                                      ? const Color(0xFF27AE60)
                                      : const Color(0xFF1A1A1A),
                                  letterSpacing: 1,
                                ),
                                decoration: InputDecoration(
                                  hintText: isEnglish
                                      ? 'Enter a valid discount code'
                                      : 'Un código válido de descuento',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFBBBBBB),
                                    letterSpacing: 0,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: InputBorder.none,
                                  suffixIcon: hasCoupon
                                      ? GestureDetector(
                                          onTap: _removeCoupon,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: PhosphorIcon(
                                              PhosphorIcons.x(PhosphorIconsStyle.bold),
                                              size: 18,
                                              color: const Color(0xFF27AE60),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                onChanged: (_) {
                                  if (_couponState == _CouponState.invalid) {
                                    setState(() => _couponState = _CouponState.idle);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!hasCoupon)
                            SizedBox(
                              height: 52,
                              child: _couponState == _CouponState.loading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24, height: 24,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFE1002D),
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _validateCoupon,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE1002D),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18),
                                      ),
                                      child: Text(
                                        isEnglish ? 'Apply' : 'Aplicar',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),
                        ],
                      ),

                      // ── Feedback cupón inválido ───────────────
                      if (_couponState == _CouponState.invalid) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            PhosphorIcon(
                              PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                              size: 14,
                              color: const Color(0xFFE1002D),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isEnglish
                                  ? 'Invalid or expired code'
                                  : 'Código inválido o vencido',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFFE1002D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ── Resumen precio con trial_months ───────
                      if (hasCoupon) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF888888))),
                                  Text(_formatCLP(_basePrice),
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF888888))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isEnglish
                                        ? 'Coupon ($_couponTrialMonths mo.)'
                                        : 'Cupón ($_couponTrialMonths mes${_couponTrialMonths > 1 ? "es" : ""})',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF27AE60),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    _couponType == 'percent'
                                        ? '-$_couponValue%'
                                        : '-${_formatCLP(_couponValue!)}',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF27AE60),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isEnglish
                                        ? 'Total (first $_couponTrialMonths mo.)'
                                        : 'Total (primer${_couponTrialMonths > 1 ? "os" : ""} $_couponTrialMonths mes${_couponTrialMonths > 1 ? "es" : ""})',
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A1A)),
                                  ),
                                  Text(
                                    _formatCLP(_discountedPrice),
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A1A)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // ── Aviso duración descuento ────────
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFFFD97D)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PhosphorIcon(
                                      PhosphorIcons.info(PhosphorIconsStyle.fill),
                                      size: 14,
                                      color: const Color(0xFF7A5C00),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isEnglish
                                            ? 'Discount applies for $_couponTrialMonths month${_couponTrialMonths > 1 ? "s" : ""}. From month ${_couponTrialMonths + 1} onwards, the regular price of ${_formatCLP(_basePrice)}/mo will be charged.'
                                            : 'El descuento aplica por $_couponTrialMonths mes${_couponTrialMonths > 1 ? "es" : ""}. Desde el mes ${_couponTrialMonths + 1} se reanuda el cobro normal de ${_formatCLP(_basePrice)}/mes.',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF7A5C00),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Botón CTA ────────────────────────────────
                Positioned(
                  bottom: bottomPadding + 16,
                  left: 24,
                  right: 24,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE1002D)))
                      : AppButton(
                          label: isEnglish ? 'Add card' : 'Agregar tarjeta',
                          onPressed:
                              _isFormValid ? () => _submit(context) : null,
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

// ── Widgets internos ──────────────────────────────────────────────────────────

class _CardPreview extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;
  final String expiry;

  const _CardPreview({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiry,
  });

  String get _displayNumber {
    final clean = cardNumber.replaceAll(' ', '');
    if (clean.isEmpty) return '•••• •••• •••• ••••';
    final padded = clean.padRight(16, '•');
    return '${padded.substring(0, 4)} ${padded.substring(4, 8)} ${padded.substring(8, 12)} ${padded.substring(12, 16)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const RadialGradient(
            center: Alignment(-0.6, -0.6),
            radius: 1.4,
            colors: [Color(0xFFF70F3D), Color(0xFF640000)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text('VISA',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2)),
              ],
            ),
            const Spacer(),
            Text(_displayNumber,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    height: 1.4)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    cardHolder.isEmpty ? 'CARD HOLDER' : cardHolder.toUpperCase(),
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                Text(expiry.isEmpty ? 'MM/YY' : expiry,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: const Color(0xFF555555)));
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final bool hasError;

  const _CardField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.onChanged,
    this.obscureText = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError
              ? const Color(0xFFE1002D).withOpacity(0.6)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        obscureText: obscureText,
        cursorColor: const Color(0xFFF70F3D),
        style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFBBBBBB)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}