import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_shapes.dart';

class WomanCardWidget extends StatelessWidget {
  final Map<String, dynamic> woman;
  final bool locked;

  const WomanCardWidget({
    super.key,
    required this.woman,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final String rawId = (woman["image_card_ID"] ?? "").toString();
    final String imageUrl = rawId.startsWith("http") ? rawId : "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        shape: AppShapes.card,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 420,
          child: Stack(
            children: [

              /// background image
              if (imageUrl.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),

              /// gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              /// text content
              Positioned(
                bottom: 28,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// tags
                    Text(
                      "${woman["pro-tag01_en"]} • ${woman["pro-tag02_en"]}",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// name
                    Text(
                      woman["full_name"],
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 34,
                        letterSpacing: -0.32,
                      ),
                    ),
                  ],
                ),
              ),

              /// PRO lock badge
              if (locked)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "PRO",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
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