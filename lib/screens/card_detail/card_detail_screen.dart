import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/modals/upsell_modal_free.dart';
import '../../widgets/system/app_button.dart';

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
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _menuOverlay;

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
    _closeMenu();
    _scrollController.dispose();
    super.dispose();
  }

  String get imageUrl {
    final rawId = (widget.woman['image_card_ID'] ?? '').toString();
    if (rawId.startsWith('http')) return rawId;
    return "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
  }

  bool get isEnglish => context.read<LanguageProvider>().isEnglish;

  void _showUpsell() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const UpsellModalFree(),
    );
  }

  void _showFavoriteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.heart(PhosphorIconsStyle.fill),
                size: 28,
                color: const Color(0xFFF70F3D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEnglish ? "Added to Favorites!" : "¡Añadido a Favoritas!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEnglish
                  ? "You can find it in your Favorites tab."
                  : "Puedes encontrarla en tu pestaña de Favoritas.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF777777),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: isEnglish ? "Continue" : "Continuar",
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu() {
    final isPro = context.read<SubscriptionProvider>().isPro;
    final favoritesProvider = context.read<FavoritesProvider>();
    final womanId = widget.woman['woman_id']?.toString() ?? '';
    final isFav = womanId.isNotEmpty ? favoritesProvider.isFavorite(womanId) : false;

    final RenderBox button = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset pos = button.localToGlobal(Offset.zero, ancestor: overlay);

    const menuWidth = 280.0;
    final left = pos.dx + button.size.width - menuWidth;
    final top = pos.dy + button.size.height + 8;

    _menuOverlay = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeMenu,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(50, 50, 93, 0.25),
                            offset: Offset(0, 50),
                            blurRadius: 100,
                            spreadRadius: -20,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            offset: Offset(0, 30),
                            blurRadius: 60,
                            spreadRadius: -30,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _menuRow(
                              icon: isFav
                                  ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                                  : PhosphorIcons.heart(PhosphorIconsStyle.bold),
                              label: isFav
                                  ? (isEnglish ? "Added to Favorites" : "Añadido a Favoritas")
                                  : (isEnglish ? "Add to Favorites" : "Añadir a Favoritas"),
                              onTap: () {
                                _closeMenu();
                                if (isPro) {
                                  favoritesProvider.toggle(widget.woman);
                                  if (!isFav) _showFavoriteConfirmation();
                                } else {
                                  _showUpsell();
                                }
                              },
                            ),
                            _menuDivider(),
                            _menuRow(
                              icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
                              label: isEnglish ? "Share with friends" : "Compartir con amigos",
                              onTap: () { _closeMenu(); },
                            ),
                            _menuDivider(),
                            _menuRow(
                              icon: PhosphorIcons.warning(PhosphorIconsStyle.bold),
                              label: isEnglish ? "Report issue" : "Reportar problema",
                              subtitle: isEnglish
                                  ? "Incorrect info, copyright, deceased?"
                                  : "¿Info incorrecta, copyright, fallecida?",
                              onTap: () { _closeMenu(); },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _closeMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  Widget _menuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.black.withOpacity(0.16),
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(icon, size: 20, color: const Color(0xFF3C3C3C)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      height: 16 / 18,
                      letterSpacing: -0.5,
                      color: const Color(0xFF3C3C3C),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 16 / 12,
                        letterSpacing: -0.5,
                        color: const Color(0xFF5D5D5D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.woman;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHero(w),
          if (_imageHeight > 320) const SizedBox(height: 16),
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedTab == 0 ? _buildBiography(w) : _buildLegacy(w),
                  _buildBottomActions(context),
                  SizedBox(height: MediaQuery.of(context).padding.bottom - 11),
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
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  isEnglish ? w['pro-tag01_en'] : w['pro-tag01_es'],
                  isEnglish ? w['pro-tag02_en'] : w['pro-tag02_es'],
                ].where((t) => (t ?? '').toString().isNotEmpty).join(' • '),
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
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: GestureDetector(
            key: _menuKey,
            onTap: _showMenu,
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
        borderRadius: isCollapsed ? BorderRadius.zero : BorderRadius.circular(16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (_selectedTab != index) setState(() => _selectedTab = index);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFE1002D).withOpacity(0.10),
          highlightColor: const Color(0xFFE1002D).withOpacity(0.05),
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
    final label = isEnglish ? "On $dateStr, $pastDate" : "En $dateStr, $pastDate";

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
                  (isEnglish ? w['on_this_date_en'] : w['on_this_date_es']) ?? '',
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
          if ((w['on_this_date_en'] ?? '').isNotEmpty) _buildEventBlock(w),
          if ((w['birth_date'] ?? '').isNotEmpty)
            _buildBioTag(
              icon: PhosphorIcons.baby(PhosphorIconsStyle.regular),
              date: w['birth_date'] as String,
              place: w['birth_place'] as String? ?? '',
            ),
          const SizedBox(height: 8),
          ..._parseBlocks(isEnglish ? w['bio_en'] ?? '' : w['bio_es'] ?? ''),
          const SizedBox(height: 8),
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
          if ((w['quote_text_en'] ?? '').isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      (isEnglish ? w['quote_text_en'] : w['quote_text_es']) ?? '',
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
          ..._parseBlocks(isEnglish ? w['legacy_en'] ?? '' : w['legacy_es'] ?? ''),
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
        final text = (end == -1 ? raw.substring(cursor) : raw.substring(cursor, end)).trim();
        if (text.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(text, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
          ));
        }
        cursor = end == -1 ? raw.length : end;
      } else if (raw.startsWith('[P]', cursor)) {
        cursor += 3;
        final end = raw.indexOf(RegExp(r'\[S\]|\[P\]'), cursor);
        final text = (end == -1 ? raw.substring(cursor) : raw.substring(cursor, end)).trim();
        if (text.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF404040), height: 1.6)),
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
    final isPro = context.watch<SubscriptionProvider>().isPro;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final womanId = widget.woman['woman_id']?.toString() ?? '';
    final isFav = womanId.isNotEmpty ? favoritesProvider.isFavorite(womanId) : false;
    final favAdded = isPro && isFav;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: isEnglish ? "Share" : "Compartir",
              isOutlined: true,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              label: isPro
                  ? (isFav
                      ? (isEnglish ? "Added ♥" : "Añadido ♥")
                      : (isEnglish ? "Add to Favorites" : "Añadir a Favoritas"))
                  : (isEnglish ? "Add to Favorites" : "Añadir a Favoritas"),
              onPressed: favAdded
                  ? () {}
                  : () {
                      if (isPro) {
                        favoritesProvider.toggle(widget.woman);
                        if (!isFav) _showFavoriteConfirmation();
                      } else {
                        _showUpsell();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}