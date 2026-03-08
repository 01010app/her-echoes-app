import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/navigation/floating_tab_bar.dart';
import '../../widgets/cards/home_mini_card.dart';
import '../../widgets/system/app_header.dart';

import '../card_detail/card_detail_screen.dart';
import '../daily_echo/daily_echo_screen.dart';
import '../show_all/show_all_screen.dart';
import '../favorites/favorites_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> suggestions;
  final List<Map<String, dynamic>> allWomen;
  final List<Map<String, dynamic>> todaysWomen;

  const HomeScreen({
    super.key,
    required this.suggestions,
    required this.allWomen,
    required this.todaysWomen,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool hasSettingsNotification = true;

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
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  void onTabSelected(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onSettingsTap() {
    setState(() {
      hasSettingsNotification = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
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
        return LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 106,
                bottom: 0,
              ),
              child: DailyEchoScreen(todaysWomen: widget.todaysWomen),
            );
          },
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
              child: ShowAllScreen(allWomen: widget.allWomen),
            );
          },
        );
      case 3:
        return const FavoritesScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final tabBarTop = screenHeight - 24 - 61;
        final carouselTop = tabBarTop - 24 - 156;
        final titleTop = carouselTop - 24 - 18;

        return Stack(
          children: [

            // 1. FONDO
            Container(color: const Color(0xFFF5F5F5)),

            // 2. IMAGEN DECORATIVA con crossfade
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

            // 3. DEGRADADO 370px
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
                      colors: [
                        Color(0xFFF5F5F5),
                        Color(0x00F5F5F5),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. TÍTULO
            Positioned(
              top: titleTop,
              left: 16,
              right: 16,
              child: Text(
                "Sugerencias de hoy",
                style: GoogleFonts.gloock(
                  fontSize: 18,
                  height: 1.4,
                  color: const Color(0xFF404040),
                ),
              ),
            ),

            // 5. CARRUSEL
            Positioned(
              top: carouselTop,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 156,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  itemCount: widget.suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final woman = widget.suggestions[index];
                    final rawId = (woman['image_card_ID'] ?? '').toString();
                    final imageUrl = rawId.startsWith('http')
                        ? rawId
                        : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";

                    return HomeMiniCard(
                      fullName: woman['full_name'] ?? '',
                      profession: woman['pro-tag01_en'] ?? '',
                      imagePath: imageUrl,
                      isPro: woman['is_free'] != "VERDADERO",
                      onTap: () {
                        final isFree = woman['is_free'] == "VERDADERO";
                        if (isFree) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardDetailScreen(woman: woman),
                            ),
                          );
                        } else {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => Container(
                              padding: const EdgeInsets.all(32),
                              child: const Text(
                                "Upsell modal — próximamente",
                                style: TextStyle(fontSize: 18),
                              ),
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