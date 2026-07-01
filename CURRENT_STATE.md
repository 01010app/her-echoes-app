# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-05-19 (sesión 26)

---

## GitHub — Identidad y Configuración ✅ sesión 25

### Cuenta activa para este proyecto
- **GitHub account:** `01010app`
- **Email GitHub:** `01010dev.app@gmail.com`
- **Git global config (Mac):**
```bash
git config --global user.name "01010app"
git config --global user.email "01010dev.app@gmail.com"
```

### ⚠️ Segunda cuenta — NO usar para este proyecto
- **GitHub account:** `ValarDisghulis`
- **Email:** `hector@callmehector.cl`
- **Uso:** solo para trabajo/organización Meedika. No tiene repos propios.
- **Importante:** si el git config global apunta a este email, los commits aparecen como "ghost" en 01010app.

### Repositorio
- **URL:** `https://github.com/01010app/her-echoes-app.git`
- **Visibilidad:** Public
- **Branch:** `main`

### Verificar identidad antes de cada sesión
```bash
git config --global user.name
git config --global user.email
# Debe mostrar: 01010app / 01010dev.app@gmail.com
```

---

## Ubicación del proyecto
```
~/herechoes/
```
⚠️ NO está en `~/hector-studio/apps/` — está directamente en el home.

---

## Stack y Reglas de Arquitectura

- **Base width:** 393px (iPhone 15 Pro)
- **Fonts:** Google Fonts — Inter (UI), Gloock (títulos/nombres), Lora (e-card quote/nombre)
- **Icons:** Phosphor — SIEMPRE `PhosphorIcon(PhosphorIcons.name(style))`, NUNCA `Icon(...)`
- **Background scaffolds:** SIEMPRE `Color(0xFFF5F5F5)` / `AppColors.background` — NUNCA blanco
- **Accent:** `#F70F3D` / `Color(0xFFE1002D)`
- **State management:** Provider
- **Persistencia:** SharedPreferences — onboarding_done ✅, user_name ✅, favorites ✅, notifications_enabled ✅, settings_has_card_issue ✅, settings_has_new_terms ✅, currency_override ✅
- **NUNCA refactorizar layouts que funcionan**
- **Spinners:** SIEMPRE `CircularProgressIndicator(color: Color(0xFFE1002D))`
- **Cursor en TextFields:** SIEMPRE `Color(0xFFF70F3D)`
- **Botones CTA:** SIEMPRE `AppButton` — NUNCA `ElevatedButton` / `OutlinedButton`
- **Botones CTA posición:** SIEMPRE `bottom: bottomPadding + 16`
- **Tabs (ej. Biografía/Legado):** SIEMPRE `Material + InkWell`, NUNCA `GestureDetector` solo
- **Precios IAP:** SIEMPRE desde `storeProduct.priceString` de RevenueCat — NUNCA hardcodeados ni desde CurrencyProvider
- **Periodicidad IAP:** SIEMPRE desde `storeProduct.subscriptionPeriod` de RevenueCat — NUNCA hardcodeada
- **Pantallas de compra:** SIEMPRE incluir botón "Restaurar compras" Y links Términos/Privacidad — exigido por Apple (Guideline 3.1.2c)
- **Android vs iOS:** Usar `Platform.isAndroid` para ajustes específicos de plataforma
- **Términos y Privacidad dentro de la app:** En `legal_content_screen` usar `WebViewWidget` (webview_flutter). En modales y pantallas de compra usar `url_launcher` con `LaunchMode.inAppWebView` — NUNCA `LaunchMode.externalApplication` en contexto de Apple sandbox
- **Pantalla de suscripción:** NUNCA usar toggle para trial — el trial es una tarjeta separada independiente
- **Links legales en TODOS los flujos de compra:** `upsell_modal_free`, `upsell_modal_pro` y `plan_selection_screen` SIEMPRE deben tener links visibles a Términos y Privacidad

---

## Bundle ID ✅ sesión 13
`cl.callmehector.herechoes`
- Registrado en Apple Developer
- Configurado en Xcode → Runner → Signing & Capabilities
- Team: Héctor Astete (7H4G6LP6K5)

---

## Versiones ✅ sesión 26

| Versión | Build | Estado | Fecha |
|---------|-------|--------|-------|
| 1.0.0 | 13 | ✅ Live en App Store | mayo 2026 |
| 1.0.1 | 14 | ✅ Aprobado y Live en App Store | mayo 2026 |

**pubspec.yaml actual:** `version: 1.0.1+15`
**Próximo build:** incrementar a `1.0.2+16`

### ⚠️ Regla crítica para nuevos builds
Cuando una versión YA está aprobada en App Store, Apple NO acepta nuevos builds con el mismo número de versión marketing. Se debe incrementar AMBOS:
- **Versión marketing:** 1.0.1 → 1.0.2 (en pubspec.yaml: parte antes del +)
- **Build number:** +15 → +16 (en pubspec.yaml: parte después del +)

Si solo subes el build number sin cambiar la versión marketing, Apple rechaza con:
`"The train version X.X.X is closed for new build submissions"`

---

## Dependencias activas (pubspec.yaml)
```yaml
cupertino_icons: ^1.0.8
google_fonts: ^6.2.1
phosphor_flutter: ^2.0.1
superellipse_shape: ^0.2.0
flutter_svg: ^2.0.7
vertical_card_pager: ^1.6.3
card_stack_widget: ^0.1.6
provider: ^6.1.2
shared_preferences: ^2.2.2
http: ^1.2.1
share_plus: ^12.0.0
path_provider: ^2.1.4
flutter_local_notifications: ^18.0.1
timezone: ^0.9.4
url_launcher: ^6.3.1
purchases_flutter: ^9.14.0
sign_in_with_apple: ^7.0.1
firebase_core: ^4.5.0
google_sign_in: ^6.2.1
webview_flutter: ^4.13.1
package_info_plus: ^9.0.1   ← agregado sesión 26
```

---

## Servicios nuevos — sesión 26

### UpdateService (`lib/services/update_service.dart`)
- Consulta iTunes API con bundle ID `cl.callmehector.herechoes`
- Compara versión instalada vs App Store usando `package_info_plus`
- Si hay versión nueva → muestra dialog con botón "Actualizar ahora"
- Botón abre App Store directo (App ID: `6760677188`)
- Solo se ejecuta en iOS
- Llamado desde `home_screen.dart` en `addPostFrameCallback`
- Emoji del dialog: 🚀

### Integración en home_screen.dart
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _checkSettingsNotification();
  _checkWeeklyProUpsell();
  final isEnglish = context.read<LanguageProvider>().isEnglish;
  UpdateService.checkAndPrompt(context, isEnglish: isEnglish);
});
```

---

## Estructura de Archivos
```
lib/
├── core/
│   ├── favorites_provider.dart
│   ├── language_provider.dart
│   ├── currency_provider.dart      ⚠️ YA NO se usa para precios de IAP
│   ├── subscription_provider.dart  ✅ RevenueCat real
│   └── theme/app_colors.dart
├── screens/
│   ├── card_detail/card_detail_screen.dart
│   ├── favorites/favorites_screen.dart
│   ├── login/
│   │   ├── login_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── email_login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── onboarding_name_screen.dart
│   ├── payment/
│   │   ├── plan_type.dart
│   │   ├── plan_selection_screen.dart
│   │   ├── plan_detail_screen.dart
│   │   ├── add_card_screen.dart        ⚠️ ya no se usa
│   │   ├── payment_screen.dart         ⚠️ ya no se usa
│   │   └── payment_method_screen.dart  ⚠️ ya no se usa
│   ├── home/home_screen.dart           ✅ UpdateService integrado sesión 26
│   ├── daily_echo/daily_echo_screen.dart
│   ├── show_all/show_all_screen.dart
│   └── settings/
│       ├── settings_screen.dart
│       ├── legal_content_screen.dart
│       ├── notifications_screen.dart
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/home_mini_card.dart, pro_badge.dart, wildcard_badge.dart
│   ├── modals/
│   │   ├── upsell_modal_free.dart
│   │   └── upsell_modal_pro.dart
│   ├── navigation/floating_tab_bar.dart
│   ├── system/app_button.dart
│   └── settings/settings_divider, container, item, section_title
└── services/
    ├── daily_suggestions_engine.dart
    └── update_service.dart             ✅ nuevo sesión 26
```

---

## Android — Estructura de archivos crítica
```
android/app/src/main/kotlin/
├── cl/callmehector/herechoes/
│   └── MainActivity.kt   ✅ package correcto — usar este
└── com/example/herechoes/
    └── MainActivity.kt   ⚠️ legacy — NO eliminar pero ignorar
```

---

## Android — Ajustes de diseño específicos
- **card_detail_screen.dart:** iOS padding `fromLTRB(24,24,24,0)` / Android `fromLTRB(16,16,16,24)`
- **floating_tab_bar.dart:** iOS `bottom: 24` / Android gestos `bottom: 24` / Android HyperOS `bottom: viewPadding.bottom + 8`

---

## Modelo de Negocio IAP

### Productos ACTIVOS (anuales)
| Nombre | Product ID iOS | Product ID Android | Precio USD |
|---|---|---|---|
| Individual Anual | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual` | $8.99 |
| Trial Anual | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual` | $12.99 |
| Familiar Anual | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual` | $14.99 |

---

## RevenueCat
- **API Key iOS:** `appl_KDuVwOmljiRmgUegeqjadtfAjRA`
- **API Key Android:** `goog_chSzVTtDJfNcfIfRHepJqITjste`
- Entitlement: `pro`, Offering: `default`

---

## Google Play Console
- App: `cl.callmehector.herechoes`
- Prueba cerrada Alpha: build 13 ✅
- Testers: 12 aceptados ✅ — contador: 11 días (necesita 14 días corridos)
- Acceso producción: disponible ~21 mayo 2026

---

## Firebase — SHA registradas
1. SHA-256 keystore subida: `ee:ed:33:...`
2. SHA-256 firma Google Play: `62:db:13:...`

---

## Android — Debugging WiFi
```bash
~/Library/Android/sdk/platform-tools/adb pair IP:PUERTO CODIGO
~/Library/Android/sdk/platform-tools/adb connect IP:PUERTO
flutter run --device-id IP:PUERTO
```
**Redmi A2:** Android 13, armeabi-v7a

---

## URLs
```
Imágenes:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
Wildcard:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
Panel admin: https://callmehector.cl/apps/herechoes/wildcard.php
Privacidad:  https://callmehector.cl/apps/herechoes/privacidad.html
Términos:    https://callmehector.cl/apps/herechoes/terminos.html
App Store:   App ID 6760677188
```

---

## Keystores
- **Producción Android:** `~/herechoes-release.jks`, alias: `herechoes`
- `android/key.properties` configurado y en `.gitignore` ✅

---

## Git Tags
```
v3.3-firebase-sha-fix            ✅
v3.4-legal-links-nav-fix         ✅
v3.5-android-nav-fix             ✅ build 13 — versión App Store aprobada
```

---

## Historial de rechazos Apple
- Build 5: metadata issues
- Build 10: RevenueCat production key faltante
- Build 11: video con device frame, logo-pro con texto pequeño
- Build 12: IAP unresponsive
- Build 13: ✅ APROBADO — legal screen interno, links en modales
- Build 14: ✅ APROBADO — en distribución

---

## Pendientes

### URGENTE
- [ ] Esperar 14 días de prueba cerrada Google Play (~21 mayo 2026) → solicitar acceso producción
- [ ] Subir nuevo build con UpdateService (1.0.2+16) cuando haya más cambios acumulados

### Media prioridad
- [ ] Completar JSON julio → diciembre
- [ ] Push notifications (Firebase Cloud Messaging) — postergado
- [ ] Show All — agregar selector de meses
- [ ] Show All — márgenes laterales
- [ ] Migrar her_echoes.json a carga remota desde GitHub (evitar builds por contenido)
- [ ] Verificación de desarrolladores Android (plazo: septiembre 2026)