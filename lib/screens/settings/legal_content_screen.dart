import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/content_service.dart';
import '../../core/theme/app_colors.dart';

class LegalContentScreen extends StatefulWidget {
  final String contentKey; // "terms" o "about"
  final String language;   // "es" o "en"

  const LegalContentScreen({
    super.key,
    required this.contentKey,
    required this.language,
  });

  @override
  State<LegalContentScreen> createState() => _LegalContentScreenState();
}

class _LegalContentScreenState extends State<LegalContentScreen> {
  Map<String, dynamic>? _content;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ContentService.loadLegalContent();
    setState(() {
      _content = data[widget.contentKey][widget.language];
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [

          // Status bar white
          Container(
            height: topPadding,
            color: Colors.white,
          ),

          // Header
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
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFFF70F3D),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Center(
                    child: Text(
                      _content?['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

          const SizedBox(height: 24),

          Expanded(
            child: _content == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildBlocks(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlocks() {
    final List contentBlocks = _content?['content'] ?? [];

    return contentBlocks.map<Widget>((block) {
      switch (block['type']) {
        case 'h2':
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              block['text'],
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
                letterSpacing: -0.5,
                color: const Color(0xFF000000),
              ),
            ),
          );

        case 'p':
        default:
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              block['text'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.6,
                letterSpacing: -0.5,
                color: const Color(0xFF434343),
              ),
            ),
          );
      }
    }).toList();
  }
}