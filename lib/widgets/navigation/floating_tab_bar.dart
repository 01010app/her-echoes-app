import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';

class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const FloatingTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Center(
        child: Container(
          width: 300,
          height: 61,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TabButton(
                label: isEnglish ? "Home" : "Inicio",
                icon: PhosphorIcons.house,
                index: 0,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
              _TabButton(
                label: isEnglish ? "Daily echo" : "Eco diario",
                icon: PhosphorIcons.calendarBlank,
                index: 1,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
              _TabButton(
                label: isEnglish ? "Show all" : "Ver todas",
                icon: PhosphorIcons.cardsThree,
                index: 2,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
              _TabButton(
                label: isEnglish ? "Favorites" : "Favoritos",
                icon: PhosphorIcons.heart,
                index: 3,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final PhosphorIconData Function([PhosphorIconsStyle]) icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex == index;
    final Color contentColor =
        isActive ? AppColors.navActiveContent : AppColors.navRestContent;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 72,
        height: 49,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.navActiveBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(icon(), size: 28, color: contentColor),
            const SizedBox(height: 1),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                height: 1.1,
                letterSpacing: -0.4,
                fontWeight: FontWeight.w500,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}