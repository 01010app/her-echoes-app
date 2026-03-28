import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';

class LegalContentScreen extends StatefulWidget {
  final String contentKey;
  final String language;

  const LegalContentScreen({
    super.key,
    required this.contentKey,
    required this.language,
  });

  @override
  State<LegalContentScreen> createState() => _LegalContentScreenState();
}

class _LegalContentScreenState extends State<LegalContentScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _openUrl();
  }

  Future<void> _openUrl() async {
    final url = widget.contentKey == 'terms'
        ? 'https://callmehector.cl/apps/herechoes/terminos.html'
        : 'https://callmehector.cl/apps/herechoes/privacidad.html';

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    String headerTitle = '';
    if (widget.contentKey == 'terms') {
      headerTitle = isEnglish ? 'Terms & Conditions' : 'Términos y Condiciones';
    } else if (widget.contentKey == 'privacy') {
      headerTitle = isEnglish ? 'Privacy Policy' : 'Política de Privacidad';
    }

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
                        color: AppColors.background, shape: BoxShape.circle),
                    child: Center(
                      child: PhosphorIcon(
                          PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                          size: 20,
                          color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      headerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: -0.5,
                          color: const Color(0xFF404040)),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator(color: Color(0xFFE1002D))
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
