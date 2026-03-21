import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/content_service.dart';

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
  Map<String, dynamic>? _data;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ContentService.loadLegalContent();
      setState(() {
        _data = data[widget.contentKey];
        _loaded = true;
      });
    } catch (e) {
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isEnglish  = context.watch<LanguageProvider>().isEnglish;
    final lang       = isEnglish ? "en" : "es";
    final content    = _data?[lang];

    String headerTitle = '';
    if (widget.contentKey == 'terms') {
      headerTitle = isEnglish ? 'Terms & Conditions' : 'Términos y Condiciones';
    } else if (widget.contentKey == 'privacy') {
      headerTitle = isEnglish ? 'Privacy Policy' : 'Política de Privacidad';
    }
    final displayTitle = content?['title'] ?? headerTitle;

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
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            child: !_loaded
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE1002D)),
                  )
                : content == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            isEnglish
                                ? 'Content not available.'
                                : 'Contenido no disponible.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 15, color: const Color(0xFF888888)),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildBlocks(content),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlocks(Map<String, dynamic> content) {
    final List blocks = content['content'] ?? [];
    return blocks.map<Widget>((block) {
      switch (block['type']) {
        case 'h2':
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              block['text'],
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w600,
                  height: 1.4, letterSpacing: -0.5,
                  color: const Color(0xFF000000)),
            ),
          );
        case 'p':
        default:
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              block['text'],
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w400,
                  height: 1.6, letterSpacing: -0.5,
                  color: const Color(0xFF434343)),
            ),
          );
      }
    }).toList();
  }
}