import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/currency_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/settings/settings_list_container.dart';
import '../../widgets/settings/settings_divider.dart';
import '../../widgets/settings/settings_section_title.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang       = context.watch<LanguageProvider>();
    final currency   = context.watch<CurrencyProvider>();
    final topPadding = MediaQuery.of(context).padding.top;
    final isEnglish  = lang.isEnglish;

    const currencies = [
      {'code': 'CLP', 'label': 'CLP — Peso chileno'},
      {'code': 'USD', 'label': 'USD — US Dollar'},
      {'code': 'EUR', 'label': 'EUR — Euro'},
      {'code': 'MXN', 'label': 'MXN — Peso mexicano'},
      {'code': 'ARS', 'label': 'ARS — Peso argentino'},
    ];

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
                      isEnglish ? "Language & Currency" : "Idioma y Moneda",
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
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Idioma ───────────────────────────────
                  SettingsSectionTitle(
                    title: isEnglish ? "Language" : "Idioma",
                  ),
                  SettingsListContainer(
                    children: [
                      _ToggleRow(
                        label: "English",
                        active: lang.isEnglish,
                        onTap: () => lang.setEnglish(true),
                      ),
                      const SettingsDivider(),
                      _ToggleRow(
                        label: "Español",
                        active: !lang.isEnglish,
                        onTap: () => lang.setEnglish(false),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Moneda ───────────────────────────────
                  SettingsSectionTitle(
                    title: isEnglish ? "Currency" : "Moneda",
                  ),
                  SettingsListContainer(
                    children: [
                      for (int i = 0; i < currencies.length; i++) ...[
                        if (i > 0) const SettingsDivider(),
                        _SelectRow(
                          label: currencies[i]['label']!,
                          selected: currency.currency == currencies[i]['code'],
                          onTap: () => currency.setCurrency(currencies[i]['code']!),
                        ),
                      ],
                      const SettingsDivider(),
                      // Opción auto
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 14, bottom: 14, right: 16),
                        child: GestureDetector(
                          onTap: () => currency.resetToAuto(),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isEnglish
                                      ? "Auto-detect from device"
                                      : "Detectar automáticamente",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.accent),
                                ),
                              ),
                              PhosphorIcon(
                                PhosphorIcons.arrowsClockwise(
                                    PhosphorIconsStyle.bold),
                                size: 18,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleRow({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w500,
                    height: 1.5, letterSpacing: -0.5,
                    color: const Color(0xFF404040))),
          ),
          GestureDetector(
            onTap: onTap,
            child: PhosphorIcon(
              active
                  ? PhosphorIcons.toggleRight(PhosphorIconsStyle.fill)
                  : PhosphorIcons.toggleLeft(PhosphorIconsStyle.fill),
              size: 36,
              color: active
                  ? const Color(0xFFF70F3D)
                  : const Color(0xFF949494),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 14, right: 16),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFFE1002D)
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFFE1002D),
                            shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: const Color(0xFF404040))),
            ),
          ],
        ),
      ),
    );
  }
}