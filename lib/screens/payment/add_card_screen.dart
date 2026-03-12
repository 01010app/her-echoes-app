import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/system/app_button.dart';
import 'plan_type.dart';
import 'plan_selection_screen.dart';
import 'payment_method_screen.dart';

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
  final _expiryController = TextEditingController();
  final _holderController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _showPlanBanner = true;

  bool get _isFormValid =>
      _cardNumberController.text.replaceAll(' ', '').length == 16 &&
      _expiryController.text.length == 5 &&
      _holderController.text.trim().isNotEmpty &&
      _cvvController.text.length >= 3;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _holderController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<SubscriptionProvider>().setIsPro(true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(
          planType: widget.selectedPlan,
          cardLast4: _cardNumberController.text
              .replaceAll(' ', '')
              .substring(12),
          cardHolder: _holderController.text.trim(),
          cardExpiry: _expiryController.text,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    final isIndividual = widget.selectedPlan == PlanType.individual;
    final planName = isEnglish
        ? (isIndividual ? "Individual Plan" : "Family Plan")
        : (isIndividual ? "Plan Individual" : "Plan Familiar");
    final planPrice = widget.planPrice ??
        (isIndividual ? "CLP 9.900" : "CLP 16.500");

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
                      isEnglish ? "Add payment method" : "Agregar medio de pago",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: -0.5,
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24,
                    bottom: bottomPadding + 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showPlanBanner) ...[
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E9E9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFDFDFDF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      planName,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        color: const Color(0xFF404040),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isEnglish ? "Billing" : "Peridiocidad",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        color: const Color(0xFF404040),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PlanSelectionScreen(),
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 2),
                                          child: Text(
                                            isEnglish
                                                ? "Change Plan"
                                                : "Cambiar de Plan",
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              height: 1.2,
                                              color: AppColors.accent,
                                            ),
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
                                  Text(
                                    planPrice,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                      color: const Color(0xFF404040),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isEnglish ? "Annual" : "Anual",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                      color: const Color(0xFF404040),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showPlanBanner = false),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      _CardPreview(
                        cardNumber: _cardNumberController.text,
                        cardHolder: _holderController.text,
                        expiry: _expiryController.text,
                      ),
                      const SizedBox(height: 28),
                      _FieldLabel(
                          isEnglish ? "Card number" : "Número de tarjeta"),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _cardNumberController,
                        hint: isEnglish
                            ? "Insert your credit card number"
                            : "Ingresa el número de tu tarjeta",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
                          LengthLimitingTextInputFormatter(19),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          isEnglish ? "Expiry date" : "Fecha de expiración"),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _expiryController,
                        hint: "MM/YY",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ExpiryFormatter(),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          isEnglish ? "Card holder" : "Nombre en la tarjeta"),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _holderController,
                        hint: isEnglish
                            ? "Name on the card"
                            : "El nombre en la tarjeta",
                        keyboardType: TextInputType.name,
                        inputFormatters: [],
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel("CVV"),
                      const SizedBox(height: 8),
                      _CardField(
                        controller: _cvvController,
                        hint: "CVV",
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: bottomPadding + 16,
                  left: 24,
                  right: 24,
                  child: AppButton(
                    label: isEnglish ? "Add card" : "Agregar tarjeta",
                    onPressed: _isFormValid ? () => _submit(context) : null,
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
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  "VISA",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _displayNumber,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                height: 1.4,
              ),
            ),
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
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  expiry.isEmpty ? 'MM/YY' : expiry,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
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
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: const Color(0xFF555555),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;
  final bool obscureText;

  const _CardField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          color: const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFBBBBBB),
          ),
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
      selection: TextSelection.collapsed(offset: string.length),
    );
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
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}