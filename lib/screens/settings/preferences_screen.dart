import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/settings/settings_list_container.dart';
import '../../widgets/settings/settings_divider.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(height: topPadding, color: Colors.white),
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      isEnglish ? "Preferences" : "Preferencias",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: -0.5,
                        color: const Color(0xFF404040),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SettingsListContainer(
                children: [
                  _PreferencesItem(
                    label: isEnglish ? "Notifications" : "Notificaciones",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  const SettingsDivider(),
                  _PreferencesItem(
                    label: isEnglish ? "Language" : "Idioma",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PreferencesItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: -0.5,
                  color: const Color(0xFF404040),
                ),
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              size: 20,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}