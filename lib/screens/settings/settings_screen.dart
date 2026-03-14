import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = '';
  // Términos: true cuando hay nuevos términos sin aceptar
  // Cambiar a true manualmente cuando publiques nuevos T&C
  static const bool _hasNewTerms = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('user_name') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final isPro = context.watch<SubscriptionProvider>().isPro;
    final hasCardIssue = isPro && false; // ← conectar con RevenueCat

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Perfil ──────────────────────────────────
                  if (_userName.isNotEmpty) ...[
                    SettingsListContainer(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 14, bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE5EA),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _userName.trim().substring(0, 1).toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _userName,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  SettingsSectionTitle(
                    title: isEnglish
                        ? "System Settings"
                        : "Configuración del sistema",
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
                        label: isEnglish
                            ? "Payment method"
                            : "Medio de pago",
                        hasNotification: hasCardIssue,
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
                        label: isEnglish
                            ? "About Us"
                            : "Acerca de Nosotros",
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
                        label: isEnglish
                            ? "Terms & Conditions"
                            : "Términos y Condiciones",
                        hasNotification: _hasNewTerms,
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
                        label: isEnglish
                            ? "Individual Plan"
                            : "Plan Individual",
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
                            left: 16, right: 16, top: 14, bottom: 14),
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

                  const SizedBox(height: 24),

                  Center(
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

                  SizedBox(height: bottomPadding + 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}