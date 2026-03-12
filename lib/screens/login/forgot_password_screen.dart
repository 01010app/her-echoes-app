import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:io' show Platform;
import '../../core/theme/app_colors.dart';
import '../../widgets/system/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  bool get _isSpanish => Platform.localeName.toLowerCase().startsWith('es');
  bool get _isValid =>
      RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text.trim());

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: enviar email de recuperación via backend
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
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
                      _isSpanish ? "Recuperar password" : "Recover password",
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
            child: _submitted
                ? _buildSuccess(bottomPadding)
                : _buildForm(bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(double bottomPadding) {
    return Stack(
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
              Text(
                "Email",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: const Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 8),
              Container(
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: const Color(0xFFF70F3D),
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: _isSpanish
                        ? "Ingresa tu cuenta de Email"
                        : "Enter your Email account",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFBBBBBB),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: bottomPadding + 16,
          left: 24,
          right: 24,
          child: AppButton(
            label: _isSpanish ? "Enviar instrucciones" : "Send instructions",
            onPressed: _isValid ? _submit : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(double bottomPadding) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE1002D),
                      width: 2.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Color(0xFFE1002D),
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isSpanish
                      ? "Estarás recibiendo las instrucciones de recuperación de password en el mail que indicaste, si se encuentra en nuestros registros."
                      : "You will receive password recovery instructions at the email you provided, if it exists in our records.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF444444),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: bottomPadding + 16,
          left: 24,
          right: 24,
          child: AppButton(
            label: _isSpanish ? "Volver a Login" : "Back to Login",
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}