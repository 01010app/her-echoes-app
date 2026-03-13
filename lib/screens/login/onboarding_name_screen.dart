import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../../core/theme/app_colors.dart';
import '../../widgets/system/app_button.dart';
import '../home/home_screen.dart';

class OnboardingNameScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allWomen;
  final List<Map<String, dynamic>> todaysWomen;
  final List<Map<String, dynamic>> suggestions;
  final List<Map<String, dynamic>> wildcards;
  final String email;

  const OnboardingNameScreen({
    super.key,
    required this.allWomen,
    required this.todaysWomen,
    required this.suggestions,
    required this.email,
    this.wildcards = const [],
  });

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final _nameController = TextEditingController();

  bool get _isSpanish => Platform.localeName.toLowerCase().startsWith('es');
  bool get _isValid => _nameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          allWomen: widget.allWomen,
          todaysWomen: widget.todaysWomen,
          suggestions: widget.suggestions,
          wildcards: widget.wildcards,
        ),
      ),
      (route) => false,
    );
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
                      _isSpanish
                          ? "¿Cómo te llamamos?"
                          : "What should we call you?",
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
                      Text(
                        _isSpanish ? "Nombre" : "Name",
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
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          cursorColor: const Color(0xFFF70F3D),
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            hintText: _isSpanish
                                ? "Escribe tu nombre"
                                : "Enter your name",
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
                    label: _isSpanish ? "Continuar" : "Continue",
                    onPressed: _isValid ? _submit : null,
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