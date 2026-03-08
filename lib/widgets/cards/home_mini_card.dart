import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shapes.dart';

class HomeMiniCard extends StatelessWidget {
  final String fullName;
  final String profession;
  final String imagePath;
  final bool isPro;
  final VoidCallback onTap;

  const HomeMiniCard({
    super.key,
    required this.fullName,
    required this.profession,
    required this.imagePath,
    required this.onTap,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
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

              /// PRO BADGE
              if (isPro)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "PRO",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
