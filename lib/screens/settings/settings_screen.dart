import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/settings/settings_section_title.dart';
import '../../widgets/settings/settings_list_container.dart';
import '../../widgets/settings/settings_list_item.dart';
import '../../widgets/settings/settings_divider.dart';
import 'legal_content_screen.dart';
import 'preferences_screen.dart';
import '../payment/payment_screen.dart';
import '../payment/plan_detail_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final isPro = context.watch<SubscriptionProvider>().isPro;

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
                      isEnglish ? "Settings" : "Configuración",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      SettingsSectionTitle(
                        title: isEnglish ? "System Settings" : "Configuración del sistema",
                      ),

                      SettingsListContainer(
                        children: [
                          SettingsListItem(
                            icon: PhosphorIcons.slidersHorizontal,
                            label: isEnglish ? "Preferences" : "Preferencias",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PreferencesScreen(),
                              ),
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsListItem(
                            icon: PhosphorIcons.creditCard,
                            label: isEnglish ? "Payment method" : "Medio de pago",
                            description: isEnglish ? "12 days remaining" : "12 días restantes",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      SettingsSectionTitle(
                        title: isEnglish ? "About Us" : "Nosotros",
                      ),

                      SettingsListContainer(
                        children: [
                          SettingsListItem(
                            icon: PhosphorIcons.userFocus,
                            label: isEnglish ? "About Us" : "Acerca de Nosotros",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LegalContentScreen(
                                  contentKey: "about",
                                  language: isEnglish ? "en" : "es",
                                ),
                              ),
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsListItem(
                            icon: PhosphorIcons.fileText,
                            label: isEnglish ? "Terms & Conditions" : "Términos y Condiciones",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LegalContentScreen(
                                  contentKey: "terms",
                                  language: isEnglish ? "en" : "es",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      SettingsSectionTitle(
                        title: isEnglish ? "Plan Details" : "Detalle Plan",
                      ),

                      SettingsListContainer(
                        children: [
                          SettingsListItem(
                            icon: PhosphorIcons.file,
                            label: isEnglish ? "Individual Plan" : "Plan Individual",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlanDetailScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ===== DEBUG =====
                      SettingsSectionTitle(title: "Dev / Debug"),

                      SettingsListContainer(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, bottom: 16, right: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Modo PRO",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                      letterSpacing: -0.5,
                                      color: const Color(0xFF404040),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context
                                      .read<SubscriptionProvider>()
                                      .setIsPro(!isPro),
                                  child: PhosphorIcon(
                                    isPro
                                        ? PhosphorIcons.toggleRight(
                                            PhosphorIconsStyle.fill)
                                        : PhosphorIcons.toggleLeft(
                                            PhosphorIconsStyle.fill),
                                    size: 36,
                                    color: isPro
                                        ? const Color(0xFFF70F3D)
                                        : const Color(0xFF949494),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // ===== /DEBUG =====

                      const SizedBox(height: 32),

                      SettingsListContainer(
                        children: [
                          SettingsListItem(
                            label: isEnglish ? "Delete Account" : "Eliminar App",
                            showChevron: false,
                            isError: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24 + bottomPadding,
                  child: Center(
                    child: Text(
                      "Version 1.0.0",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: -0.5,
                        color: const Color(0xFF787575),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}