import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/favorites_provider.dart';
import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../widgets/system/app_button.dart';
import '../card_detail/card_detail_screen.dart';
import '../../widgets/modals/upsell_modal_free.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onNavigateToDaily;

  const FavoritesScreen({super.key, this.onNavigateToDaily});

  void _showUpsell(BuildContext context) {
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

  void _showRemoveConfirmation(BuildContext context, Map<String, dynamic> woman, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (_) {
        final isEnglish = context.read<LanguageProvider>().isEnglish;
        return AlertDialog(
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
                isEnglish ? "Remove from Favorites?" : "¿Quitar de Favoritas?",
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
                    ? "This woman will be removed from your favorites list."
                    : "Esta mujer será eliminada de tu lista de favoritas.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF777777),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: isEnglish ? "Yes, remove" : "Sí, quitar",
                onPressed: () {
                  provider.toggle(woman);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  isEnglish ? "Cancel" : "Cancelar",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;
    final favoritesProvider = context.read<FavoritesProvider>();
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final isPro = context.watch<SubscriptionProvider>().isPro;

    final topPadding = 104.0 + 16.0;
    final bottomPadding = 85.0 + MediaQuery.of(context).padding.bottom;

    final descStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: -0.4,
      color: const Color(0xFF404040),
    );

    // Usuario FREE
    if (!isPro) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding,
            bottom: bottomPadding,
            left: 32,
            right: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish
                    ? "This feature is only available for users with a PRO Plan."
                    : "Esta función está disponible solo para usuarios con un Plan PRO contratado.",
                textAlign: TextAlign.center,
                style: descStyle,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: isEnglish ? "Subscribe" : "Suscríbete",
                onPressed: () => _showUpsell(context),
              ),
            ],
          ),
        ),
      );
    }

    // Usuario PRO sin favoritos
    if (favorites.isEmpty) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding,
            bottom: bottomPadding,
            left: 32,
            right: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEnglish
                    ? "The cards of the women you add as Favorites will appear here."
                    : "Aquí aparecerán las tarjetas de las mujeres a las que agregues como Favoritas.",
                textAlign: TextAlign.center,
                style: descStyle,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: isEnglish
                    ? "Visit today's inspiring woman"
                    : "Visitar la mujer inspiradora de hoy",
                onPressed: () => onNavigateToDaily?.call(),
              ),
            ],
          ),
        ),
      );
    }

    // Usuario PRO con favoritos → grid
    final headerHeight = MediaQuery.of(context).padding.top + 60.0;

    return Stack(
      children: [
        Container(
          color: const Color(0xFFF5F5F5),
          child: GridView.builder(
            padding: EdgeInsets.only(
              top: topPadding,
              bottom: bottomPadding,
              left: 16,
              right: 16,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 160 / 280,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final woman = favorites[index];
              return _FavoriteCard(
                woman: woman,
                isEnglish: isEnglish,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardDetailScreen(woman: woman),
                    ),
                  );
                },
                onRemove: () => _showRemoveConfirmation(context, woman, favoritesProvider),
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: Container(color: Colors.white),
        ),
      ],
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> woman;
  final bool isEnglish;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.woman,
    required this.isEnglish,
    required this.onTap,
    required this.onRemove,
  });

  String get imageUrl {
    final rawId = (woman['image_card_ID'] ?? '').toString();
    if (rawId.startsWith('http')) return rawId;
    return "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
  }

  @override
  Widget build(BuildContext context) {
    final tag = isEnglish
        ? (woman['pro-tag01_en'] ?? '')
        : (woman['pro-tag01_es'] ?? woman['pro-tag01_en'] ?? '');

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE0E0E0),
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIcons.user(PhosphorIconsStyle.light),
                    size: 48,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 160,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.80),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    woman['full_name'] ?? '',
                    style: GoogleFonts.gloock(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tag.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      tag,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF70F3D),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.heart(PhosphorIconsStyle.fill),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}