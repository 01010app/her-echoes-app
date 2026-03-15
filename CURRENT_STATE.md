# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-14 (sesión 11)

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
│   ├── currency_provider.dart            ✅ sesión 11: detección + selector manual
│   ├── pricing.dart                      ✅ sesión 11: tabla de precios por moneda
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
│   │   ├── plan_selection_screen.dart         ✅ sesión 11: precios dinámicos por moneda
│   │   ├── add_card_screen.dart               ✅ campo cupón completo
│   │   ├── payment_method_screen.dart         ✅ banner recordatorio cupón
│   │   └── plan_detail_screen.dart
│   ├── home/home_screen.dart                  ✅ punto rojo Settings dinámico
│   ├── daily_echo/daily_echo_screen.dart
│   ├── show_all/show_all_screen.dart
│   └── settings/
│       ├── settings_screen.dart               ✅ sesión 11: Dev/Debug eliminado
│       ├── legal_content_screen.dart
│       ├── notifications_screen.dart          ✅ notificaciones locales 9AM
│       ├── language_screen.dart               ✅ sesión 11: idioma + moneda unificados
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
└── content/legal_content.json              ✅ sesión 11: contenido real ES/EN para App Store
```

---

## Sistema de Moneda ✅ sesión 11

### `lib/core/currency_provider.dart`
- Detección automática por `Platform.localeName`
- Override manual persistido en SharedPreferences key `currency_override`
- `resetToAuto()` — elimina override y vuelve a detección automática

### Monedas soportadas
| Código | Nombre | Individual | Trial | Familiar |
|---|---|---|---|---|
| CLP | Peso chileno | 9.900 | 16.800 | 16.500 |
| USD | US Dollar | 10 | 17 | 17 |
| EUR | Euro | 9 | 15 | 15 |
| MXN | Peso mexicano | 199 | 349 | 329 |
| ARS | Peso argentino | 9.900 | 16.800 | 16.500 |

### Detección automática por locale
- `CL` → CLP, `MX` → MXN, `AR` → ARS
- `ES/FR/DE/IT/PT` → EUR
- Default → USD

### Selector manual
- Settings → Preferencias → Idioma y Moneda
- Botón "Detectar automáticamente" para resetear

---

## Sistema de Cupones ✅ sesión 10

### Servidor
- `coupons.json` — `https://callmehector.cl/apps/herechoes/coupons.json`
- `coupons.php` — `https://callmehector.cl/apps/herechoes/coupons.php`

### Cupones activos
| Código | Tipo | Valor | Meses | Max usos |
|---|---|---|---|---|
| INFLUENCER2026 | percent | 30% | 1 | 100 |
| REGALO100 | percent | 100% | 1 | 1 |
| DESCUENTO3000 | fixed | CLP 3.000 | 3 | ilimitado |

---

## Wildcard
- Panel admin: `https://callmehector.cl/apps/herechoes/wildcard.php`
- ⚠️ Token GitHub `herechoes-wildcard` expira **Apr 11 2026** — renovar antes

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
await prefs.setBool('settings_has_card_issue', true);
await prefs.setBool('settings_has_new_terms', true);
static const bool _hasNewTerms = false; // → true en settings_screen.dart
```

---

## Contacto oficial
- Email: `herechoes.info@callmehector.cl`

---

## URLs
```
Imágenes:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
Wildcard:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
Panel admin: https://callmehector.cl/apps/herechoes/wildcard.php
Cupones:     https://callmehector.cl/apps/herechoes/coupons.php
Tutorial:    https://callmehector.cl/apps/herechoes/herechoes-tutorial.html
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
v1.6-coupons             ✅
v1.7-coupon-reminder     ✅
v1.8-currency            ✅ sesión 11
```

---

## Pendientes

### Alta prioridad
- [ ] ⚠️ Token GitHub expira **Apr 11 2026** — renovar
- [ ] RevenueCat — integración real suscripciones (espera aprobación Apple Developer)
- [ ] Apple Sign In (espera aprobación Apple Developer)
- [ ] Cancelar suscripción → conectar RevenueCat (UI lista)

### Media prioridad
- [ ] Google Sign In: Firebase + config nativa
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Flujo Plan Familiar: invitación por email (requiere backend)
- [ ] Avatar Settings → foto real con auth
- [ ] `short_bio_es` vacío en varios registros JSON

### Antes de producción
- [ ] Verificar 118 imágenes en GitHub
- [ ] Flujo downgrade de plan
- [ ] Subir imagen real de wildcard y probar en dispositivo
- [ ] Precios ARS actualizados (actualmente igual a CLP — ajustar a valores reales)

---

## Next Development Focus (sesión 12)
1. RevenueCat — cuando llegue aprobación Apple Developer
2. Google Sign In
3. Ajustar precios ARS a valores reales