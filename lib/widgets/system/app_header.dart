import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback? onSettingsTap;

  const AppHeader({
    super.key,
    required this.hasNotification,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 92,
              height: 30,
              child: SvgPicture.asset(
                'assets/images/system/logo.svg',
                fit: BoxFit.contain,
              ),
            ),
            GestureDetector(
              onTap: onSettingsTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.slidersHorizontal(),
                    size: 28.0,
                    color: AppColors.accent,
                  ),
                  if (hasNotification)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}