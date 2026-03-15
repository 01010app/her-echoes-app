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
import '../../widgets/system/app_button.dart';
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

  Future<void> _showDeleteDialog(BuildContext context, bool isEnglish) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F3), shape: BoxShape.circle),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.trash(PhosphorIconsStyle.fill),
                  color: const Color(0xFFF70F3D), size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEnglish ? "Delete account?" : "¿Eliminar cuenta?",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A), height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              isEnglish
                  ? "All your data will be permanently deleted, including favorites and preferences. This action cannot be undone."
                  : "Se eliminarán permanentemente todos tus datos, incluyendo favoritos y preferencias. Esta acción no se puede deshacer.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF777777), height: 1.5),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: isEnglish ? "Cancel" : "Cancelar",
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                isEnglish ? "Yes, delete my account" : "Sí, eliminar mi cuenta",
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: const Color(0xFFE1002D)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding    = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish     = context.watch<LanguageProvider>().isEnglish;
    final isPro         = context.watch<SubscriptionProvider>().isPro;
    final hasCardIssue  = isPro && false;

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
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.background, shape: BoxShape.circle),
                    child: Center(
                      child: PhosphorIcon(
                          PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                          size: 20, color: AppColors.accent),
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
                          fontSize: 18, fontWeight: FontWeight.w600,
                          height: 1.5, letterSpacing: -0.5,
                          color: const Color(0xFF404040)),
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
                                width: 44, height: 44,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFFFE5EA),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    _userName.trim().substring(0, 1).toUpperCase(),
                                    style: GoogleFonts.inter(
                                        fontSize: 18, fontWeight: FontWeight.w600,
                                        color: AppColors.accent),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(_userName,
                                  style: GoogleFonts.inter(
                                      fontSize: 16, fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A))),
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
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const PreferencesScreen())),
                      ),
                      const SettingsDivider(),
                      SettingsListItem(
                        icon: PhosphorIcons.creditCard,
                        label: isEnglish ? "Payment method" : "Medio de pago",
                        hasNotification: hasCardIssue,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => PaymentScreen())),
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
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => LegalContentScreen(
                                    contentKey: "about",
                                    language: isEnglish ? "en" : "es"))),
                      ),
                      const SettingsDivider(),
                      SettingsListItem(
                        icon: PhosphorIcons.fileText,
                        label: isEnglish
                            ? "Terms & Conditions"
                            : "Términos y Condiciones",
                        hasNotification: _hasNewTerms,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => LegalContentScreen(
                                    contentKey: "terms",
                                    language: isEnglish ? "en" : "es"))),
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
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const PlanDetailScreen())),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SettingsListContainer(
                    children: [
                      SettingsListItem(
                        label: isEnglish ? "Delete Account" : "Eliminar cuenta",
                        showChevron: false,
                        isError: true,
                        onTap: () => _showDeleteDialog(context, isEnglish),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      "Version 1.0.0",
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w400,
                          height: 1.5, letterSpacing: -0.5,
                          color: const Color(0xFF787575)),
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