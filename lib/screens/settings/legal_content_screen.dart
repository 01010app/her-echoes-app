import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────
// Modelo de sección legal
// ─────────────────────────────────────────────
class _LegalSection {
  final String heading;
  final String body;
  const _LegalSection({required this.heading, required this.body});
}

// ─────────────────────────────────────────────
// Contenido legal embebido (sin red, sin WebView)
// ─────────────────────────────────────────────
class _LegalContent {
  static const _privacyEs = [
    _LegalSection(
      heading: '1. Responsable del tratamiento',
      body:
          'Her Echoes es desarrollado por Héctor Astete. Para cualquier consulta relacionada con privacidad puedes escribir a: herechoes.info@callmehector.cl',
    ),
    _LegalSection(
      heading: '2. Datos que recopilamos',
      body:
          'Her Echoes puede recopilar los siguientes datos de forma opcional: nombre elegido por el usuario al registrarse, preferencias de idioma y moneda almacenadas localmente en el dispositivo, y favoritos guardados localmente.\n\nNo recopilamos datos de localización, contactos, ni información sensible. Los datos de pago son procesados directamente por App Store, Google Play o el proveedor de pagos correspondiente y nunca son almacenados por Her Echoes.',
    ),
    _LegalSection(
      heading: '3. Uso de la información',
      body:
          'Los datos recopilados se usan exclusivamente para personalizar la experiencia dentro de la app. Her Echoes no vende, cede ni comercializa datos personales a terceros.',
    ),
    _LegalSection(
      heading: '4. Almacenamiento',
      body:
          'Las preferencias y favoritos se almacenan localmente en el dispositivo del usuario. No se almacena información personal en servidores propios de Her Echoes.',
    ),
    _LegalSection(
      heading: '5. Servicios de terceros',
      body:
          'La app utiliza servicios de terceros como Google Fonts y GitHub para recursos visuales. Plataformas como App Store o Google Play pueden recopilar datos técnicos conforme a sus propias políticas de privacidad.',
    ),
    _LegalSection(
      heading: '6. Derechos del usuario',
      body:
          'El usuario puede eliminar sus datos locales en cualquier momento desinstalando la aplicación. Para solicitudes relacionadas con datos, escríbenos a herechoes.info@callmehector.cl',
    ),
    _LegalSection(
      heading: '7. Cambios en esta política',
      body:
          'Esta política puede actualizarse para reflejar cambios en la aplicación o en la normativa vigente. Los cambios relevantes serán notificados dentro de la app.',
    ),
  ];

  static const _privacyEn = [
    _LegalSection(
      heading: '1. Data Controller',
      body:
          'Her Echoes is developed by Héctor Astete. For any privacy-related inquiries, please contact: herechoes.info@callmehector.cl',
    ),
    _LegalSection(
      heading: '2. Data We Collect',
      body:
          'Her Echoes may optionally collect the following data: the name chosen by the user during registration, language and currency preferences stored locally on the device, and locally saved favorites.\n\nWe do not collect location data, contacts, or sensitive information. Payment data is processed directly by the App Store, Google Play, or the corresponding payment provider and is never stored by Her Echoes.',
    ),
    _LegalSection(
      heading: '3. Use of Information',
      body:
          'Collected data is used exclusively to personalize the in-app experience. Her Echoes does not sell, transfer, or commercialize personal data to third parties.',
    ),
    _LegalSection(
      heading: '4. Storage',
      body:
          'Preferences and favorites are stored locally on the user\'s device. No personal information is stored on Her Echoes\' own servers.',
    ),
    _LegalSection(
      heading: '5. Third-Party Services',
      body:
          'The app uses third-party services such as Google Fonts and GitHub for visual resources. Platforms such as the App Store or Google Play may collect technical data in accordance with their own privacy policies.',
    ),
    _LegalSection(
      heading: '6. User Rights',
      body:
          'Users can delete their local data at any time by uninstalling the application. For data-related requests, contact us at herechoes.info@callmehector.cl',
    ),
    _LegalSection(
      heading: '7. Changes to This Policy',
      body:
          'This policy may be updated to reflect changes in the application or applicable regulations. Significant changes will be notified within the app.',
    ),
  ];

  static const _termsEs = [
    _LegalSection(
      heading: '1. Aceptación de los términos',
      body:
          'Al descargar o utilizar Her Echoes, aceptas estos Términos y Condiciones en su totalidad. Si no estás de acuerdo con alguno de ellos, debes dejar de utilizar la aplicación.',
    ),
    _LegalSection(
      heading: '2. Descripción del servicio',
      body:
          'Her Echoes es una aplicación móvil que ofrece contenido histórico y biográfico sobre mujeres relevantes de la historia universal. El contenido se presenta con fines informativos, educativos y culturales.',
    ),
    _LegalSection(
      heading: '3. Planes y suscripciones',
      body:
          'Her Echoes ofrece acceso gratuito limitado y planes de suscripción PRO de pago. Los planes PRO se renuevan automáticamente salvo que el usuario cancele antes del fin del período vigente.\n\nLos precios se muestran en la moneda local detectada según el dispositivo del usuario. El cobro se realiza a través de la plataforma de pago correspondiente (App Store o Google Play).\n\nEl usuario puede cancelar su suscripción en cualquier momento desde los ajustes de su cuenta de App Store o Google Play. La cancelación tendrá efecto al término del período ya pagado, sin reembolso por el tiempo restante.',
    ),
    _LegalSection(
      heading: '4. Códigos de promoción',
      body:
          'Her Echoes puede emitir códigos de descuento con condiciones específicas de validez, porcentaje de descuento y duración. Los códigos son de uso personal, no transferibles y están sujetos a las condiciones indicadas en el momento de su emisión.',
    ),
    _LegalSection(
      heading: '5. Propiedad intelectual',
      body:
          'Todo el contenido disponible en la aplicación, incluyendo textos, diseño, estructura, logotipos y marca Her Echoes, es propiedad del desarrollador o se utiliza con las debidas licencias. Queda prohibida su reproducción total o parcial sin autorización expresa.',
    ),
    _LegalSection(
      heading: '6. Limitación de responsabilidad',
      body:
          'Her Echoes procura que la información histórica sea precisa y verificada mediante fuentes de referencia. Sin embargo, no garantiza la ausencia total de errores o inexactitudes en el contenido. El uso de la información es responsabilidad del usuario.',
    ),
    _LegalSection(
      heading: '7. Modificaciones',
      body:
          'Her Echoes puede actualizar estos términos en cualquier momento. Los cambios relevantes serán notificados dentro de la aplicación. Se recomienda revisar esta sección periódicamente.',
    ),
    _LegalSection(
      heading: '8. Contacto',
      body:
          'Para consultas sobre estos términos puedes escribirnos a: herechoes.info@callmehector.cl',
    ),
  ];

  static const _termsEn = [
    _LegalSection(
      heading: '1. Acceptance of Terms',
      body:
          'By downloading or using Her Echoes, you agree to these Terms and Conditions in full. If you disagree with any part of them, you must stop using the application.',
    ),
    _LegalSection(
      heading: '2. Description of Service',
      body:
          'Her Echoes is a mobile application offering historical and biographical content about notable women in universal history. The content is presented for informational, educational, and cultural purposes.',
    ),
    _LegalSection(
      heading: '3. Plans and Subscriptions',
      body:
          'Her Echoes offers limited free access and paid PRO subscription plans. PRO plans renew automatically unless the user cancels before the end of the current period.\n\nPrices are shown in the local currency detected by the user\'s device. Charges are processed through the corresponding payment platform (App Store or Google Play).\n\nUsers may cancel their subscription at any time from their App Store or Google Play account settings. Cancellation takes effect at the end of the already-paid period, with no refund for remaining time.',
    ),
    _LegalSection(
      heading: '4. Promotional Codes',
      body:
          'Her Echoes may issue discount codes with specific validity conditions, discount percentages, and duration. Codes are for personal use only, non-transferable, and subject to the conditions stated at the time of issuance.',
    ),
    _LegalSection(
      heading: '5. Intellectual Property',
      body:
          'All content available in the application, including text, design, structure, logos, and the Her Echoes brand, is the property of the developer or used under appropriate licenses. Reproduction in whole or in part without express authorization is prohibited.',
    ),
    _LegalSection(
      heading: '6. Limitation of Liability',
      body:
          'Her Echoes strives to ensure historical information is accurate and verified through reference sources. However, it does not guarantee the complete absence of errors or inaccuracies in the content. Use of the information is the user\'s responsibility.',
    ),
    _LegalSection(
      heading: '7. Modifications',
      body:
          'Her Echoes may update these terms at any time. Significant changes will be notified within the application. Periodic review of this section is recommended.',
    ),
    _LegalSection(
      heading: '8. Contact',
      body:
          'For questions about these terms, please contact us at: herechoes.info@callmehector.cl',
    ),
  ];

  static List<_LegalSection> get(String contentKey, String language) {
    if (contentKey == 'privacy') {
      return language == 'en' ? _privacyEn : _privacyEs;
    } else {
      return language == 'en' ? _termsEn : _termsEs;
    }
  }

  static String title(String contentKey, String language) {
    if (contentKey == 'privacy') {
      return language == 'en' ? 'Privacy Policy' : 'Política de Privacidad';
    } else {
      return language == 'en' ? 'Terms & Conditions' : 'Términos y Condiciones';
    }
  }

  static String subtitle(String contentKey, String language) {
    return language == 'en' ? 'Last updated: March 2026' : 'Última actualización: marzo 2026';
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class LegalContentScreen extends StatelessWidget {
  final String contentKey; // 'privacy' | 'terms'
  final String language;   // 'en' | 'es'

  const LegalContentScreen({
    super.key,
    required this.contentKey,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding    = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEnglish     = context.watch<LanguageProvider>().isEnglish;
    final lang          = isEnglish ? 'en' : 'es';

    final sections = _LegalContent.get(contentKey, lang);
    final title    = _LegalContent.title(contentKey, lang);
    final subtitle = _LegalContent.subtitle(contentKey, lang);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──
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
                        color: AppColors.background, shape: BoxShape.circle),
                    child: Center(
                      child: PhosphorIcon(
                          PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                          size: 20,
                          color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          letterSpacing: -0.5,
                          color: const Color(0xFF404040)),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 32, 24, bottomPadding + 48),
              children: [
                // Título grande
                Text(
                  title,
                  style: GoogleFonts.gloock(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(color: Color(0xFFE0E0E0), height: 1),
                const SizedBox(height: 32),

                // Secciones
                ...sections.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.heading.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.08 * 11,
                              color: const Color(0xFFE1002D),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            s.body,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.65,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
