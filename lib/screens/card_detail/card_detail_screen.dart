import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';

class CardDetailScreen extends StatefulWidget {
  final Map<String, dynamic> woman;

  const CardDetailScreen({
    super.key,
    required this.woman,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController();
  double _imageHeight = 520;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _imageHeight = (520 - offset).clamp(320.0, 520.0);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get imageUrl {
    final rawId = (widget.woman['image_card_ID'] ?? '').toString();
    if (rawId.startsWith('http')) return rawId;
    return "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
  }

  bool get isEnglish => true;

  @override
  Widget build(BuildContext context) {
    final w = widget.woman;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // FIXED: HERO
          _buildHero(w),

          // GAP solo cuando no está colapsada
          if (_imageHeight > 320) const SizedBox(height: 16),

          // FIXED: TABS
          _buildTabs(),

          // SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedTab == 0
                      ? _buildBiography(w)
                      : _buildLegacy(w),
                  _buildBottomActions(context),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(Map<String, dynamic> w) {
    return Stack(
      children: [

        // IMAGE
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _imageHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: _imageHeight <= 320
                ? BorderRadius.zero
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),

        // GRADIENT
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _imageHeight,
          child: ClipRRect(
            borderRadius: _imageHeight <= 320
                ? BorderRadius.zero
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // TEXT ON IMAGE
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  w['pro-tag01_en'] ?? '',
                  w['pro-tag02_en'] ?? '',
                ].where((t) => t.isNotEmpty).join(' • '),
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (w['full_name'] ?? '') as String,
                style: GoogleFonts.gloock(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        // BACK BUTTON
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                size: 18,
                color: AppColors.accent,
              ),
            ),
          ),
        ),

        // MENU BUTTON
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: GestureDetector(
            onTap: () => _showMenu(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                size: 18,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final isCollapsed = _imageHeight <= 320;
    return Container(
      height: 45,
      margin: EdgeInsets.only(
        left: isCollapsed ? 0 : 16,
        right: isCollapsed ? 0 : 16,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: isCollapsed
            ? BorderRadius.zero
            : BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab(isEnglish ? "Biography" : "Biografía", 0),
          const SizedBox(width: 4),
          _buildTab(isEnglish ? "Legacy" : "Legado", 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != index) {
            setState(() => _selectedTab = index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 37,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
                letterSpacing: 0,
                color: isSelected
                    ? const Color(0xFFE1002D)
                    : const Color(0xFF6D6D6D),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventBlock(Map<String, dynamic> w) {
    final now = DateTime.now();
    final months = isEnglish
        ? ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
        : ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    final dateStr = "${months[now.month - 1]} ${now.day}, ${now.year}";
    final pastDate = w['past_date']?.toString() ?? '';
    final label = isEnglish
        ? "On $dateStr, $pastDate"
        : "En $dateStr, $pastDate";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.calendarDots(PhosphorIconsStyle.regular),
            size: 24,
            color: const Color(0xFFAB5666),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: const Color(0xFFAB5666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (isEnglish
                      ? w['on_this_date_en']
                      : w['on_this_date_es']) ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: const Color(0xFFAB5666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioTag({
    required IconData icon,
    required String date,
    required String place,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TAG con fondo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF4F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFFAB5666)),
              const SizedBox(width: 6),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: const Color(0xFFAB5666),
                ),
              ),
            ],
          ),
        ),

        // LUGAR fuera del tag
        if (place.isNotEmpty)
          Text(
            place,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: const Color(0xFF555555),
            ),
          ),
      ],
    );
  }

  Widget _buildBiography(Map<String, dynamic> w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 16),

          // EVENT BLOCK
          if ((w['on_this_date_en'] ?? '').isNotEmpty)
            _buildEventBlock(w),

          // BIRTH
          if ((w['birth_date'] ?? '').isNotEmpty)
            _buildBioTag(
              icon: PhosphorIcons.baby(PhosphorIconsStyle.regular),
              date: w['birth_date'] as String,
              place: w['birth_place'] as String? ?? '',
            ),

          const SizedBox(height: 8),

          // BIO TEXT
          ..._parseBlocks(
            isEnglish ? w['bio_en'] ?? '' : w['bio_es'] ?? '',
          ),

          const SizedBox(height: 8),

          // DEATH
          _buildBioTag(
            icon: PhosphorIcons.skull(PhosphorIconsStyle.regular),
            date: (w['death_date'] ?? '').toString().isNotEmpty
                ? w['death_date'] as String
                : (isEnglish ? 'Still alive' : 'Aún con vida'),
            place: w['death_place'] as String? ?? '',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegacy(Map<String, dynamic> w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 16),

          // QUOTE BLOCK
          if ((w['quote_text_en'] ?? '').isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF4F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.quotes(PhosphorIconsStyle.bold),
                    size: 16,
                    color: const Color(0xFFAB5666),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      (isEnglish
                          ? w['quote_text_en']
                          : w['quote_text_es']) ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: const Color(0xFFAB5666),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // LEGACY TEXT
          ..._parseBlocks(
            isEnglish ? w['legacy_en'] ?? '' : w['legacy_es'] ?? '',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _parseBlocks(String raw) {
    final widgets = <Widget>[];
    int cursor = 0;

    while (cursor < raw.length) {
      if (raw.startsWith('[S]', cursor)) {
        cursor += 3;
        final end = raw.indexOf(RegExp(r'\[S\]|\[P\]'), cursor);
        final text = (end == -1
                ? raw.substring(cursor)
                : raw.substring(cursor, end))
            .trim();
        if (text.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ));
        }
        cursor = end == -1 ? raw.length : end;
      } else if (raw.startsWith('[P]', cursor)) {
        cursor += 3;
        final end = raw.indexOf(RegExp(r'\[S\]|\[P\]'), cursor);
        final text = (end == -1
                ? raw.substring(cursor)
                : raw.substring(cursor, end))
            .trim();
        if (text.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF404040),
                height: 1.6,
              ),
            ),
          ));
        }
        cursor = end == -1 ? raw.length : end;
      } else {
        cursor++;
      }
    }

    return widgets;
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE1002D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                isEnglish ? "Share" : "Compartir",
                style: GoogleFonts.inter(
                  color: const Color(0xFFE1002D),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1002D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                isEnglish ? "Add to Favorites" : "Añadir a Favoritos",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              PhosphorIcons.heart(PhosphorIconsStyle.regular),
              isEnglish ? "Add to Favorites" : "Añadir a Favoritos",
              () {},
            ),
            _buildMenuItem(
              PhosphorIcons.shareFat(PhosphorIconsStyle.regular),
              isEnglish ? "Share with friends" : "Compartir con amigos",
              () {},
            ),
            _buildMenuItem(
              PhosphorIcons.warning(PhosphorIconsStyle.regular),
              isEnglish ? "Report issue" : "Reportar problema",
              () {},
              subtitle: isEnglish
                  ? "Incorrect info, copyright, deceased?"
                  : "¿Info incorrecta, copyright, fallecida?",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A1A1A)),
      title: Text(label, style: GoogleFonts.inter(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF999999),
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}