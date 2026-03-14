# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-14 (sesión 10)

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

- height: 52, rojo `#E1002D` enabled, gris `#949494` null
- `isOutlined: true` → borde rojo, fondo transparente

**Reglas de import:**
```
lib/screens/*/         → '../../widgets/system/app_button.dart'
lib/widgets/modals/    → '../system/app_button.dart'
lib/widgets/*/         → '../system/app_button.dart'
```

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
│   │   ├── add_card_screen.dart               ✅ sesión 10: campo cupón completo
│   │   ├── payment_method_screen.dart         ✅ sesión 10: banner recordatorio cupón
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
├── images/home/, system/, onboarding/, cards/
└── content/legal_content.json
```

---

## Sistema de Cupones ✅ sesión 10

### Servidor
- `coupons.json` — `https://callmehector.cl/apps/herechoes/coupons.json`
- `coupons.php` — `https://callmehector.cl/apps/herechoes/coupons.php`

### Estructura cupón
```json
{
  "code": "INFLUENCER2026",
  "type": "percent",
  "value": 30,
  "trial_months": 1,
  "max_uses": 100,
  "uses": 0,
  "valid_from": "2026-03-14",
  "valid_until": "2026-12-31",
  "active": true
}
```
- `type`: `"percent"` o `"fixed"`
- `value`: porcentaje (30) o monto CLP (3000)
- `trial_months`: meses con descuento
- `max_uses`: límite de usos, `null` = ilimitado
- `valid_until`: fecha límite, `null` = indefinido

### API
- GET `coupons.php?code=CODIGO` → `{valid, type, value, code, trial_months}`
- POST `coupons.php` con `{password, code}` → registra uso

### Cupones activos
| Código | Tipo | Valor | Meses | Max usos |
|---|---|---|---|---|
| INFLUENCER2026 | percent | 30% | 1 | 100 |
| REGALO100 | percent | 100% | 1 | 1 |
| DESCUENTO3000 | fixed | CLP 3.000 | 3 | ilimitado |

### UI en app
- Campo "Código de promoción" en `add_card_screen.dart`
- Validación en tiempo real contra servidor
- Resumen con subtotal, descuento, total y aviso amarillo de duración
- Banner verde recordatorio en `payment_method_screen.dart`

---

## Wildcard
- Panel admin: `https://callmehector.cl/apps/herechoes/wildcard.php`
- ⚠️ Token GitHub `herechoes-wildcard` expira **Apr 11 2026** — renovar antes
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

## Flujo de Navegación
```
main.dart
├── Descarga wildcard.json desde GitHub → fallback asset local
├── onboarding_done
│   ├── false → OnboardingScreen → LoginScreen
│   └── true → LoginScreen
│       ├── "Invitado/a" → HomeScreen
│       └── "Email" → EmailLoginScreen → OnboardingNameScreen → HomeScreen
```

---

## URLs
```
Imágenes cards:  https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
Wildcard JSON:   https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
Panel admin:     https://callmehector.cl/apps/herechoes/wildcard.php
Cupones API:     https://callmehector.cl/apps/herechoes/coupons.php
Tutorial dev:    https://callmehector.cl/apps/herechoes/herechoes-tutorial.html
```

---

## Git Tags
```
v1.0-pre-language        ✅
v1.1-payment-ui          ✅
v1.2-onboarding-wildcard ✅
v1.3-wildcard-admin      ✅
v1.4-share-favorites     ✅
v1.5-notifications       ✅
v1.6-coupons             ✅ sesión 10
v1.7-coupon-reminder     ✅ sesión 10
```

---

## Pendientes

### Alta prioridad
- [ ] ⚠️ Token GitHub expira **Apr 11 2026** — renovar
- [ ] `legal_content.json`: reemplazar lorem ipsum con contenido real
- [ ] RevenueCat — integración real suscripciones
- [ ] Cancelar suscripción → RevenueCat (UI lista)

### Media prioridad
- [ ] Apple Sign In: Xcode + Apple Developer Console
- [ ] Google Sign In: Firebase + config nativa
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Flujo Plan Familiar: invitación por email (requiere backend)
- [ ] Detección moneda por locale (hardcoded CLP)
- [ ] Avatar Settings → foto real con auth
- [ ] `short_bio_es` vacío en varios registros JSON

### Antes de producción
- [ ] Eliminar sección Dev/Debug de `settings_screen.dart`
- [ ] Verificar 118 imágenes en GitHub
- [ ] Flujo downgrade de plan
- [ ] Subir imagen real de wildcard y probar en dispositivo

---

## Next Development Focus (sesión 11)
1. RevenueCat — integración real suscripciones
2. Apple Sign In
3. Detección moneda por locale