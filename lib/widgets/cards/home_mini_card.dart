import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/subscription_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shapes.dart';
import 'pro_badge.dart';

class HomeMiniCard extends StatelessWidget {
  final String fullName;
  final String profession;
  final String imagePath;
  final bool isPro;
  final VoidCallback onTap;
  final Map<String, dynamic>? woman;

  const HomeMiniCard({
    super.key,
    required this.fullName,
    required this.profession,
    required this.imagePath,
    required this.onTap,
    this.isPro = false,
    this.woman,
  });

  @override
  Widget build(BuildContext context) {
    final userIsPro = context.watch<SubscriptionProvider>().isPro;
    final showProBadge = isPro && !userIsPro;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final womanId = woman?['woman_id']?.toString() ?? '';
    final isFav = womanId.isNotEmpty ? favoritesProvider.isFavorite(womanId) : false;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        shape: AppShapes.card,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 156,
          height: 156,
          child: Stack(
            children: [

              /// IMAGE
              Positioned(
                top: -24,
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),

              /// GRADIENT
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 62,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.8),
                        Color.fromRGBO(0, 0, 0, 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              /// TEXT
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: -0.14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      profession,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.textSecondary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              /// PRO BADGE — solo si FREE
              if (showProBadge)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: ProBadge(),
                ),

              /// FAVORITE BUTTON — solo si usuario PRO
              if (userIsPro && woman != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => favoritesProvider.toggle(woman!),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isFav
                            ? const Color(0xFFF70F3D)
                            : Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav
                            ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                            : PhosphorIcons.heart(PhosphorIconsStyle.regular),
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}