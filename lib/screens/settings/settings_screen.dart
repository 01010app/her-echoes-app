import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/settings/settings_section_title.dart';
import '../../widgets/settings/settings_list_container.dart';
import '../../widgets/settings/settings_list_item.dart';
import '../../widgets/settings/settings_divider.dart';
import 'legal_content_screen.dart';
import 'preferences_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [

          // STATUS BAR WHITE
          Container(
            height: topPadding,
            color: Colors.white,
          ),

          // HEADER
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
                        PhosphorIcons.arrowLeft(
                          PhosphorIconsStyle.bold,
                        ),
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
                      "Settings",
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

          const SizedBox(height: 24),

          Expanded(
            child: Stack(
              children: [

                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ===== CONFIGURACIÓN DEL SISTEMA =====
                      const SettingsSectionTitle(
                        title: "Configuración del sistema",
                      ),

                      SettingsListContainer(
                        children: [
                          SettingsListItem(
                            icon: PhosphorIcons.gear,
                            label: "Preferencias",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PreferencesScreen(),
                              ),
                            ),
                          ),

                          const SettingsDivider(),

                          SettingsListItem(
                            icon: PhosphorIcons.creditCard,
                            label: "Pago",
                            description: "12 days remaining",
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ===== NOSOTROS =====
                      const SettingsSectionTitle(
                        title: "Nosotros",
                      ),

                      SettingsListContainer(
                        children: [
                          SettingsListItem(
                            icon: PhosphorIcons.userFocus,
                            label: "Acerca de Nosotros",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LegalContentScreen(
                                    contentKey: "about",
                                    language: "es",
                                  ),
                                ),
                              );
                            },
                          ),

                          const SettingsDivider(),

                          SettingsListItem(
                            icon: PhosphorIcons.fileText,
                            label: "Términos y Condiciones",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LegalContentScreen(
                                    contentKey: "terms",
                                    language: "es",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ===== DETALLE PLAN =====
                      const SettingsSectionTitle(
                        title: "Detalle Plan",
                      ),

                      SettingsListContainer(
                        children: [
                          SettingsListItem(
                            icon: PhosphorIcons.file,
                            label: "Plan Individual",
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ===== ELIMINAR APP =====
                      SettingsListContainer(
                        children: const [
                          SettingsListItem(
                            label: "Eliminar App",
                            showChevron: false,
                            isError: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                // VERSION FIXED
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