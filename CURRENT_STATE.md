# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-13 (sesión 9 — completa)

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
  final VoidCallback? onPressed;  // null → gris #949494, siempre hay ripple
  final bool isOutlined;          // default: false
  final double? width;            // default: double.infinity
}
```

- Rojo sólido `#E1002D` cuando enabled, gris `#949494` cuando null
- `isOutlined: true` → borde rojo, fondo transparente
- elevation: 2 con shadowColor rojo 25% cuando enabled
- height: 52

**Reglas de import por ubicación:**
```
lib/screens/*/         → '../../widgets/system/app_button.dart'
lib/widgets/modals/    → '../system/app_button.dart'
lib/widgets/*/         → '../system/app_button.dart'
```

---

## Dependencias activas (pubspec.yaml)
```yaml
path_provider: ^2.1.4              ✅ sesión 9
share_plus: ^12.0.0                ✅
http: ^1.2.1                       ✅
google_fonts: ^6.2.1               ✅ (usa Lora para e-card)
shared_preferences: ^2.2.2         ✅
flutter_local_notifications: ^18.0.1  ✅ sesión 9
timezone: ^0.9.4                   ✅ sesión 9
```

---

## Estructura de Archivos
```
lib/
├── core/
│   ├── favorites_provider.dart           ✅ sesión 9: persistencia SharedPreferences
│   ├── language_provider.dart
│   ├── subscription_provider.dart
│   └── theme/
│       └── app_colors.dart
├── screens/
│   ├── card_detail/
│   │   └── card_detail_screen.dart       ✅ sesión 9: e-card share
│   ├── favorites/
│   │   └── favorites_screen.dart         ✅ sesión 9: Icons.person → PhosphorIcon
│   ├── login/
│   │   ├── login_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── email_login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── onboarding_name_screen.dart   ✅ usa AppButton, guarda user_name
│   ├── payment/
│   │   ├── plan_type.dart
│   │   ├── payment_screen.dart
│   │   ├── plan_selection_screen.dart
│   │   ├── add_card_screen.dart          ✅ sesión 9: errores tarjeta, PhosphorIcon
│   │   ├── payment_method_screen.dart    ✅ sesión 9: cancelar baja isPro
│   │   └── plan_detail_screen.dart
│   ├── home/
│   │   └── home_screen.dart              ✅ sesión 9: punto rojo Settings dinámico
│   ├── daily_echo/
│   │   └── daily_echo_screen.dart
│   ├── show_all/
│   │   └── show_all_screen.dart          ✅ sesión 8
│   └── settings/
│       ├── settings_screen.dart          ✅ sesión 9: perfil, punto rojo items, versión en scroll
│       ├── legal_content_screen.dart
│       ├── notifications_screen.dart     ✅ sesión 9: notificaciones locales 9AM
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/
│   │   ├── home_mini_card.dart
│   │   ├── pro_badge.dart
│   │   └── wildcard_badge.dart
│   ├── modals/
│   │   ├── upsell_modal_free.dart
│   │   └── upsell_modal_pro.dart
│   ├── navigation/
│   │   └── floating_tab_bar.dart
│   ├── system/
│   │   └── app_button.dart
│   └── settings/
│       ├── settings_divider.dart
│       ├── settings_list_container.dart
│       ├── settings_list_item.dart       ✅ sesión 9: parámetro hasNotification
│       └── settings_section_title.dart
└── services/
    └── daily_suggestions_engine.dart

assets/
├── data/
│   ├── her_echoes.json
│   └── wildcard.json
├── images/
│   ├── home/
│   ├── system/login/
│   └── onboarding/
└── content/
    └── legal_content.json
```

---

## Wildcard — Sistema completo (sesiones 7-8-9)

### Panel Admin Web ✅ EN PRODUCCIÓN
- URL: `https://callmehector.cl/apps/herechoes/wildcard.php`
- Token GitHub `herechoes-wildcard` expira **Apr 11 2026** — ⚠️ renovar antes

### Badge `WildcardBadge`
- Fondo: `Color(0xFF28A52A).withOpacity(0.85)`
- Ícono: `PhosphorIcons.shootingStar(PhosphorIconsStyle.fill)`, size 12, blanco
- Texto: "Especial" (ES) / "Special" (EN)
- Se muestra siempre, FREE y PRO

---

## E-Card / Share ✅ sesión 9
- Widget `_ShareECard` en `card_detail_screen.dart`
- Imagen 1080×1080px, captura con `RepaintBoundary` → PNG → `XFile`
- ✅ Dispositivo real: sheet nativo (WhatsApp, Instagram, etc.)
- ⚠️ Simulator: solo "Guardar como archivo" — normal, NO es bug

---

## Estados de error tarjeta ✅ sesión 9
| Número | Error |
|---|---|
| `4000 0000 0000 0002` | Rechazada |
| `4000 0000 0000 9995` | Sin fondos |
| Cualquier + fecha `00/00` | Expirada |
| Cualquier + CVV `000` | CVV inválido |
| Cualquier otro | ✅ Éxito |

---

## Notificaciones locales ✅ sesión 9
- Paquete: `flutter_local_notifications: ^18.0.1` + `timezone: ^0.9.4`
- `AppDelegate.swift` actualizado con `FlutterLocalNotificationsPlugin`
- Toggle en Settings → Preferences → Notificaciones
- Notificación diaria a las **9:00 AM** (hora local)
- Persiste estado en SharedPreferences key `notifications_enabled`
- ✅ Pide permiso al activar
- ⚠️ En Simulator no llegan — en dispositivo real sí

---

## Sistema de Notificación en ícono Settings ✅ sesión 9

### Claves SharedPreferences que activan el punto rojo:
```dart
'settings_has_card_issue'  // true → punto rojo en "Medio de pago"
'settings_has_new_terms'   // true → punto rojo en "Términos y Condiciones"
```

### Para activar desde código:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('settings_has_card_issue', true);
```

### Para nuevos T&C (sin backend):
En `settings_screen.dart` cambiar:
```dart
static const bool _hasNewTerms = false; // → true para activar
```

### Comportamiento:
- `home_screen.dart` chequea las claves al iniciar y al volver de Settings
- El punto rojo en el ícono de tuerca desaparece automáticamente al salir de Settings

---

## Flujo de Navegación
```
main.dart
├── Descarga wildcard.json desde GitHub → fallback asset local
├── FutureBuilder → onboarding_done
│   ├── false → OnboardingScreen → LoginScreen
│   └── true → LoginScreen
│       ├── "Invitado/a" → HomeScreen
│       └── "Email" → EmailLoginScreen → OnboardingNameScreen → HomeScreen
```

---

## URLs
```
Imágenes: https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
Wildcard JSON: https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
Panel admin: https://callmehector.cl/apps/herechoes/wildcard.php
Tutorial dev: herechoes-tutorial.html (en servidor junto a wildcard.php)
```

---

## Git Tags
```
v1.0-pre-language        ✅
v1.1-payment-ui          ✅
v1.2-onboarding-wildcard ✅
v1.3-wildcard-admin      ✅
v1.4-share-favorites     ✅
v1.5-notifications       ✅ sesión 9
```

---

## Pendientes

### Alta prioridad
- [ ] `legal_content.json`: reemplazar lorem ipsum con contenido real
- [ ] Conectar `PaymentScreen` / `PaymentMethodScreen` con RevenueCat
- [ ] Cancelar suscripción → conectar RevenueCat (UI lista)
- [ ] ⚠️ Token GitHub expira **Apr 11 2026** — renovar

### Media prioridad
- [ ] Apple Sign In: Xcode + Apple Developer Console
- [ ] Google Sign In: Firebase + config nativa
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Flujo Plan Familiar: invitación por email (requiere backend)
- [ ] Detección moneda por locale (hardcoded CLP)
- [ ] Avatar Settings → foto real con auth (Apple/Google devuelven photoURL)
- [ ] `short_bio_es` vacío en varios registros JSON — completar

### Antes de producción
- [ ] Eliminar sección Dev/Debug de `settings_screen.dart`
- [ ] Verificar 118 imágenes en GitHub cargan correctamente
- [ ] Cambio de plan: flujo downgrade
- [ ] Subir imagen real de wildcard y probar en dispositivo

---

## Next Development Focus (sesión 10)
1. RevenueCat — integración real de suscripciones
2. Apple Sign In / Google Sign In
3. Detección moneda por locale