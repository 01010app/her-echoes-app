# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-14 (sesión 10 — inicio)

---

## Stack y Reglas de Arquitectura

- **Base width:** 393px (iPhone 15 Pro)
- **Fonts:** Google Fonts — Inter (UI), Gloock (títulos/nombres), Lora (e-card quote/nombre)
- **Icons:** Phosphor — SIEMPRE `PhosphorIcon(PhosphorIcons.name(style))`, NUNCA `Icon(...)`
- **Background scaffolds:** SIEMPRE `Color(0xFFF5F5F5)` / `AppColors.background` — NUNCA blanco
- **Accent:** `#F70F3D` / `Color(0xFFE1002D)`
- **State management:** Provider
- **Persistencia:** SharedPreferences — onboarding_done ✅, user_name ✅, favorites ✅, notifications_enabled ✅, settings_has_card_issue ✅, settings_has_new_terms ✅
- **NUNCA refactorizar layouts que funcionan**
- **Spinners:** SIEMPRE `CircularProgressIndicator(color: Color(0xFFE1002D))`
- **Cursor en TextFields:** SIEMPRE `Color(0xFFF70F3D)`
- **Botones CTA:** SIEMPRE `AppButton` — NUNCA `ElevatedButton` / `OutlinedButton`
- **Botones CTA posición:** SIEMPRE `bottom: bottomPadding + 16`
- **Tabs (ej. Biografía/Legado):** SIEMPRE `Material + InkWell`, NUNCA `GestureDetector` solo

---

## Widget Sistema: `AppButton`
**Ruta:** `lib/widgets/system/app_button.dart`
```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final double? width;
}
```
- height: 52, rojo `#E1002D` enabled, gris `#949494` null
- `isOutlined: true` → borde rojo, fondo transparente

---

## Dependencias activas (pubspec.yaml)
```yaml
path_provider: ^2.1.4
share_plus: ^12.0.0
http: ^1.2.1
google_fonts: ^6.2.1
shared_preferences: ^2.2.2
flutter_local_notifications: ^18.0.1
timezone: ^0.9.4
```

---

## Estructura de Archivos
```
lib/
├── core/
│   ├── favorites_provider.dart           ✅ persistencia SharedPreferences
│   ├── language_provider.dart
│   ├── subscription_provider.dart
│   └── theme/app_colors.dart
├── screens/
│   ├── card_detail/card_detail_screen.dart    ✅ e-card share
│   ├── favorites/favorites_screen.dart        ✅
│   ├── login/
│   │   ├── login_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── email_login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── onboarding_name_screen.dart        ✅ guarda user_name
│   ├── payment/
│   │   ├── plan_type.dart
│   │   ├── payment_screen.dart
│   │   ├── plan_selection_screen.dart
│   │   ├── add_card_screen.dart               ✅ errores tarjeta ⬅ PRÓXIMO: campo cupón
│   │   ├── payment_method_screen.dart         ✅ cancelar baja isPro
│   │   └── plan_detail_screen.dart
│   ├── home/home_screen.dart                  ✅ punto rojo Settings dinámico
│   ├── daily_echo/daily_echo_screen.dart
│   ├── show_all/show_all_screen.dart
│   └── settings/
│       ├── settings_screen.dart               ✅ perfil, punto rojo, versión en scroll
│       ├── legal_content_screen.dart
│       ├── notifications_screen.dart          ✅ notificaciones locales 9AM
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/home_mini_card.dart, pro_badge.dart, wildcard_badge.dart
│   ├── modals/upsell_modal_free.dart, upsell_modal_pro.dart
│   ├── navigation/floating_tab_bar.dart
│   ├── system/app_button.dart
│   └── settings/settings_divider, container, item ✅ hasNotification, section_title
└── services/daily_suggestions_engine.dart

assets/
├── data/her_echoes.json, wildcard.json
├── images/home/, system/, onboarding/, cards/ ✅ imágenes subidas vía git
└── content/legal_content.json
```

---

## Wildcard
- Panel admin: `https://callmehector.cl/apps/herechoes/wildcard.php`
- ⚠️ Token GitHub `herechoes-wildcard` expira **Apr 11 2026**
- Tutorial dev: `herechoes-tutorial.html` — 7 secciones draggables ✅

---

## E-Card / Share ✅
- `_ShareECard` 1080×1080px en `card_detail_screen.dart`
- ✅ Dispositivo real: sheet nativo — ⚠️ Simulator: solo "Guardar"

---

## Estados error tarjeta ✅
| Número | Error |
|---|---|
| `4000 0000 0000 0002` | Rechazada |
| `4000 0000 0000 9995` | Sin fondos |
| Cualquier + `00/00` | Expirada |
| Cualquier + CVV `000` | CVV inválido |

---

## Notificaciones locales ✅
- Diaria 9:00 AM — key `notifications_enabled`
- `AppDelegate.swift` actualizado
- ⚠️ Solo funciona en dispositivo real

---

## Sistema punto rojo Settings ✅
```dart
// Activar:
await prefs.setBool('settings_has_card_issue', true);
await prefs.setBool('settings_has_new_terms', true);
// Nuevos T&C sin backend:
static const bool _hasNewTerms = false; // → true en settings_screen.dart
```

---

## Git Tags
```
v1.0 → v1.5-notifications ✅
```

---

## Pendientes

### Alta prioridad — PRÓXIMA SESIÓN
- [ ] Campo cupón de descuento en `add_card_screen.dart`
- [ ] JSON de cupones con código, % descuento, validez
- [ ] ⚠️ Token GitHub expira **Apr 11 2026**
- [ ] RevenueCat — integración real suscripciones
- [ ] `legal_content.json`: reemplazar lorem ipsum

### Media prioridad
- [ ] Apple Sign In: Xcode + Apple Developer Console
- [ ] Google Sign In: Firebase + config nativa
- [ ] Flujo Plan Familiar: invitación por email
- [ ] Detección moneda por locale (hardcoded CLP)
- [ ] Avatar Settings → foto real con auth

### Antes de producción
- [ ] Eliminar sección Dev/Debug de `settings_screen.dart`
- [ ] Verificar 118 imágenes en GitHub
- [ ] Flujo downgrade de plan

---

## Next Development Focus (sesión 10)
1. Campo código de promoción en `add_card_screen.dart`
2. JSON de cupones + lógica de validación
3. Conexión con RevenueCat