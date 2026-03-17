import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import '../home/home_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allWomen;
  final List<Map<String, dynamic>> todaysWomen;
  final List<Map<String, dynamic>> suggestions;
  final List<Map<String, dynamic>> wildcards;

  const LoginScreen({
    super.key,
    required this.allWomen,
    required this.todaysWomen,
    required this.suggestions,
    this.wildcards = const [],
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _patternController;
  late bool _isSpanish;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    final locale = Platform.localeName.toLowerCase();
    _isSpanish = locale.startsWith('es');
    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _patternController.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          allWomen: widget.allWomen,
          todaysWomen: widget.todaysWomen,
          suggestions: widget.suggestions,
          wildcards: widget.wildcards,
        ),
      ),
    );
  }

  void _goEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailLoginScreen(
          allWomen: widget.allWomen,
          todaysWomen: widget.todaysWomen,
          suggestions: widget.suggestions,
          wildcards: widget.wildcards,
        ),
      ),
    );
  }

  Future<void> _signInWithApple() async {
    try {
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (mounted) _goHome();
    } catch (e) {
      print('Apple Sign In cancelado: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null && mounted) {
        _goHome();
      }
    } catch (e) {
      print('Google Sign In error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final size = MediaQuery.of(context).size;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF5072), Color(0xFFAA0022)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _patternController,
            builder: (context, child) {
              final offset = _patternController.value * 60;
              return ClipRect(
                child: Opacity(
                  opacity: 0.7,
                  child: Transform.translate(
                    offset: Offset(-offset, -offset),
                    child: SizedBox(
                      width: size.width + 60,
                      height: size.height + 60,
                      child: Image.asset(
                        'assets/images/system/bg-pattern.png',
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.none,
                        alignment: Alignment.topLeft,
                        scale: 3.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 160,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/system/login/logo-white.svg',
                height: 48,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding + 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isIOS) ...[
                  _LoginButton(
                    iconPath: 'assets/images/system/login/icon_Apple.svg',
                    label: _isSpanish
                        ? 'Continuar con Apple'
                        : 'Continue with Apple',
                    onTap: _signInWithApple,
                  ),
                  const SizedBox(height: 8),
                ],
                _LoginButton(
                  iconPath: 'assets/images/system/login/icon_Google-color.svg',
                  label: _isSpanish
                      ? 'Continuar con Google'
                      : 'Continue with Google',
                  onTap: _signInWithGoogle,
                ),
                const SizedBox(height: 8),
                _LoginButton(
                  iconPath: 'assets/images/system/login/icon_email.svg',
                  label: _isSpanish
                      ? 'Continuar con Email'
                      : 'Continue with Email',
                  onTap: _goEmail,
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                      letterSpacing: -0.4,
                      color: Colors.white.withOpacity(0.80),
                    ),
                    children: _isSpanish
                        ? const [
                            TextSpan(text: 'Al continuar estarás aceptando los '),
                            TextSpan(
                              text: 'Términos y condiciones,',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                            TextSpan(text: ' y confirmas que leíste la '),
                            TextSpan(
                              text: 'Política de privacidad,',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                            TextSpan(text: ' donde se explican las ofertas y promociones.'),
                          ]
                        : const [
                            TextSpan(text: 'By continuing you agree to our '),
                            TextSpan(
                              text: 'Terms and Conditions,',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                            TextSpan(text: ' and confirm you have read our '),
                            TextSpan(
                              text: 'Privacy Policy,',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                            TextSpan(text: ' which explains our offers and promotions.'),
                          ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _goHome,
                  child: Text(
                    _isSpanish
                        ? 'Continuar como invitado/a'
                        : 'Continue as guest',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
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

class _LoginButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _LoginButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 22, height: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.0,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}