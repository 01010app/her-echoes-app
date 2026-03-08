import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Text(
          "Favorites Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}