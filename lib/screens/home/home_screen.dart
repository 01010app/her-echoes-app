import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/favorites_provider.dart';
import '../../widgets/navigation/floating_tab_bar.dart';
import '../../widgets/cards/home_mini_card.dart';
import '../../widgets/system/app_header.dart';
import '../../widgets/home/upsell_banner.dart';
import '../../widgets/modals/upsell_modal_free.dart';
import '../../widgets/modals/upsell_modal_pro.dart';

import '../card_detail/card_detail_screen.dart';
import '../daily_echo/daily_echo_screen.dart';
import '../show_all/show_all_screen.dart';
import '../favorites/favorites_screen.dart';
import '../settings/settings_screen.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> suggestions;
  final List<Map<String, dynamic>> allWomen;
  final List<Map<String, dynamic>> todaysWomen;
  final List<Map<String, dynamic>> wildcards;

  const HomeScreen({
    super.key,
    required this.suggestions,
    required this.allWomen,
    required this.todaysWomen,
    this.wildcards = const [],
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool hasSettingsNotification = false;

  // ── Claves SharedPreferences que generan notificación en el ícono ──
  // Agregar aquí cualquier nueva clave booleana que signifique "hay algo pendiente"
  static const List<String> _notificationKeys = [
    'settings_has_card_issue',
    'settings_has_new_terms',
  ];

  final List<String> _homeImages = [
    'assets/images/home/home01.webp',
    'assets/images/home/home02.webp',
    'assets/images/home/home03.webp',
    'assets/images/home/home04.webp',
    'assets/images/home/home05.webp',
  ];

  int _currentImageIndex = 0;
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _homeImages.length;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSettingsNotification();
      _checkWeeklyProUpsell();
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkSettingsNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAny = _notificationKeys.any((k) => prefs.getBool(k) == true);
    if (mounted) setState(() => hasSettingsNotification = hasAny);
  }

  Future<void> _checkWeeklyProUpsell() async {
    final isPro = context.read<SubscriptionProvider>().isPro;
    if (!isPro) return;
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt('pro_upsell_last_shown') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneWeekMs = 7 * 24 * 60 * 60 * 1000;
    if (now - lastShown >= oneWeekMs) {
      await prefs.setInt('pro_upsell_last_shown', now);
      if (mounted) _showProUpsell();
    }
  }

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

  void _showProUpsell() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => UpsellModalPro(
        currentHomeImage: _homeImages[_currentImageIndex],
      ),
    );
  }

  void onTabSelected(int index) {
    setState(() => currentIndex = index);
  }

  Future<void> onSettingsTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    // Al volver de Settings re-chequea por si cambió algo
    _checkSettingsNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildCurrentScreen(),
          AppHeader(
            hasNotification: hasSettingsNotification,
            onSettingsTap: onSettingsTap,
          ),
          FloatingTabBar(
            currentIndex: currentIndex,
            onTabSelected: onTabSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return Padding(
          padding: const EdgeInsets.only(top: 106),
          child: DailyEchoScreen(
            todaysWomen: widget.todaysWomen,
            wildcards: widget.wildcards,
          ),
        );
      case 2:
        return LayoutBuilder(
          builder: (context, constraints) {
            const headerBottom = 48.0 + 56.0;
            final tabBarTop = constraints.maxHeight - 24 - 61;
            return Padding(
              padding: EdgeInsets.only(
                top: headerBottom,
                bottom: constraints.maxHeight - tabBarTop + 24,
              ),
              child: ShowAllScreen(
                allWomen: widget.allWomen,
                wildcards: widget.wildcards,
              ),
            );
          },
        );
      case 3:
        return FavoritesScreen(
          onNavigateToDaily: () => setState(() => currentIndex = 1),
        );
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isEnglish = context.watch<LanguageProvider>().isEnglish;
        final isPro = context.watch<SubscriptionProvider>().isPro;
        final screenHeight = constraints.maxHeight;
        final tabBarTop = screenHeight - 24 - 61;
        final carouselTop = tabBarTop - 24 - 156;
        final bannerTop = carouselTop - 24 - 18 - 24 - 80;
        final titleTop = bannerTop + 80 + 24;

        return Stack(
          children: [

            // 1. FONDO
            Container(color: const Color(0xFFF5F5F5)),

            // 2. IMAGEN DECORATIVA
            Positioned(
              bottom: 265,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1200),
                child: Image.asset(
                  _homeImages[_currentImageIndex],
                  key: ValueKey(_currentImageIndex),
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // 3. DEGRADADO
            Positioned(
              bottom: 265,
              left: 0,
              right: 0,
              height: 370,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFFF5F5F5), Color(0x00F5F5F5)],
                    ),
                  ),
                ),
              ),
            ),

            // 4. TÍTULO
            Positioned(
              top: titleTop,
              left: 24,
              right: 24,
              child: Text(
                isEnglish ? "Today's suggestions" : "Sugerencias de hoy",
                style: GoogleFonts.gloock(
                  fontSize: 18,
                  height: 1.4,
                  color: const Color(0xFF404040),
                ),
              ),
            ),

            // 5. BANNER UPSELL
            Positioned(
              top: bannerTop,
              left: 24,
              right: 24,
              child: isPro
                  ? UpsellBanner(
                      title: isEnglish
                          ? "Inspiration for your family"
                          : "Inspiración para tu familia",
                      subtitle: isEnglish
                          ? "Give a daily dose of inspiration to 2 more people with the Family Plan."
                          : "Regala una dosis diaria de inspiración a 2 personas más de tu familia con el Plan familiar.",
                      icon: PhosphorIcons.usersThree,
                      onTap: _showProUpsell,
                    )
                  : UpsellBanner(
                      title: isEnglish
                          ? "Get inspired daily"
                          : "Inspírate diariamente",
                      subtitle: isEnglish
                          ? "Unlock hundreds of inspiring stories every day with the PRO Plan."
                          : "Desbloquea y accede a cientos de historias de inspiración todos los días con el Plan PRO.",
                      icon: PhosphorIcons.crownSimple,
                      onTap: _showUpsell,
                    ),
            ),

            // 6. CARRUSEL
            Positioned(
              top: carouselTop,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 156,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  itemCount: widget.suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final woman = widget.suggestions[index];
                    final rawId = (woman['image_card_ID'] ?? '').toString();
                    final imageUrl = rawId.startsWith('http')
                        ? rawId
                        : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
                    final isContentPro = woman['is_free'] != "VERDADERO";
                    final blocked = isContentPro && !isPro;
                    final isWildcard = woman['_is_wildcard'] == true;

                    return HomeMiniCard(
                      fullName: woman['full_name'] ?? '',
                      profession: isEnglish
                          ? woman['pro-tag01_en'] ?? ''
                          : woman['pro-tag01_es'] ?? '',
                      imagePath: imageUrl,
                      isPro: blocked,
                      isWildcard: isWildcard,
                      woman: woman,
                      onTap: () {
                        if (blocked) {
                          _showUpsell();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardDetailScreen(woman: woman),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}