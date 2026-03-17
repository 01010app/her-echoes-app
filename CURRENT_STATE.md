# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-16 (sesión 13)

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

## Bundle ID ✅ sesión 13
`cl.callmehector.herechoes`
- Registrado en Apple Developer (Certificates, Identifiers & Profiles)
- Configurado en Xcode → Runner → Signing & Capabilities
- Team: Héctor Astete

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
url_launcher: ^6.3.1
purchases_flutter: ^9.14.0        ✅ sesión 13
```

---

## Estructura de Archivos
```
lib/
├── core/
│   ├── favorites_provider.dart
│   ├── language_provider.dart
│   ├── currency_provider.dart
│   ├── subscription_provider.dart     ✅ sesión 13: RevenueCat real
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
│   │   ├── payment_screen.dart
│   │   ├── plan_selection_screen.dart  ✅ sesión 13: compra real RevenueCat
│   │   ├── add_card_screen.dart        ⚠️ ya no se usa para compra real
│   │   ├── payment_method_screen.dart
│   │   └── plan_detail_screen.dart
│   ├── home/home_screen.dart
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
│   ├── modals/upsell_modal_free.dart, upsell_modal_pro.dart
│   ├── navigation/floating_tab_bar.dart
│   ├── system/app_button.dart
│   └── settings/settings_divider, container, item, section_title
└── services/daily_suggestions_engine.dart

assets/
├── data/her_echoes.json
├── data/wildcard.json
├── images/home/, system/, onboarding/
├── images/cards/                       ⚠️ 22.7MB local — pendiente resolver
└── content/legal_content.json
```

---

## RevenueCat ✅ sesión 13

### Credenciales
- Proyecto RC: HerEchoes
- **API Key iOS producción:** `appl_KDuVwOmljiRmgUegeqjadtfAjRA`
- Entitlement: `pro`
- Offering: `default`

### Productos App Store Connect
| Nombre | Product ID | Precio CLP | En familia |
|---|---|---|---|
| Individual Mensual | `cl.callmehector.herechoes.individual` | $9.990 | No |
| Familiar Mensual | `cl.callmehector.herechoes.familiar` | $17.990 | Sí |
| Trial Mensual | `cl.callmehector.herechoes.trial` | $17.990 | No |

### Packages RevenueCat (offering: default)
| Identifier | Producto conectado |
|---|---|
| `individual` | Individual Mensual |
| `familiar` | Familiar Mensual |
| `trial` | Trial Mensual |

### Cómo funciona la compra
1. `plan_selection_screen.dart` llama `Purchases.getOfferings()`
2. Selecciona el package según plan elegido (`individual`, `trial`, `familiar`)
3. Llama `subscriptionProvider.purchasePackage(package)`
4. RevenueCat → Apple sheet nativo → confirma compra
5. `subscription_provider.dart` verifica entitlement `pro` y actualiza `isPro`
6. Navega de vuelta al inicio si éxito

### In-App Purchase Key
- Key ID: `ZL6S5CVZY3`
- Issuer ID: `0736adc9-024c-4b51-8881-73c9815df30f`
- Archivo .p8: descargado y subido a RevenueCat ✅

---

## App Store Connect ✅ sesión 13
- App creada: **HerEchoes**
- Bundle ID: `cl.callmehector.herechoes`
- Grupo suscripciones: **HerEchoes Pro**
- 3 suscripciones configuradas con idioma ES y precios CLP base

---

## Sistema de Moneda ✅

### Monedas soportadas
| Código | Individual | Trial | Familiar |
|---|---|---|---|
| CLP | 9.900 | 16.800 | 16.500 |
| USD | 10 | 17 | 17 |
| EUR | 9 | 15 | 15 |
| MXN | 199 | 349 | 329 |
| ARS | 8.990 | 14.990 | 13.990 |

⚠️ Los precios reales en App Store Connect son $9.990 CLP / $17.990 CLP (tiers de Apple). Los precios en CurrencyProvider son referenciales para mostrar en UI antes de que RevenueCat retorne el precio real.

---

## Sistema de Cupones ✅
- `coupons.json` — `https://callmehector.cl/apps/herechoes/coupons.json`
- `coupons.php` — `https://callmehector.cl/apps/herechoes/coupons.php`

| Código | Tipo | Valor | Meses | Max usos |
|---|---|---|---|---|
| INFLUENCER2026 | percent | 30% | 1 | 100 |
| REGALO100 | percent | 100% | 1 | 1 |
| DESCUENTO3000 | fixed | CLP 3.000 | 3 | ilimitado |

---

## Nota sobre woman_id duplicados
`wangari_maathai_01` aparece en dos fechas distintas (nacimiento y Nobel).
- Funciona correctamente
- En favoritos: al guardar una, ambas aparecen como favoritas — comportamiento aceptado

---

## Wildcard
- Panel admin: `https://callmehector.cl/apps/herechoes/wildcard.php`
- ⚠️ Token GitHub `herechoes-wildcard` expira **Apr 11 2026** — renovar antes

---

## E-Card / Share ✅
- `_ShareECard` 1080×1080px en `card_detail_screen.dart`
- ✅ Dispositivo real: sheet nativo — ⚠️ Simulator: solo "Guardar"

---

## Notificaciones locales ✅
- Diaria 9:00 AM — key `notifications_enabled`
- `AppDelegate.swift` actualizado
- ⚠️ Solo funciona en dispositivo real

---

## Eliminar cuenta ✅
- Dialog confirmación en Settings
- Limpia todo SharedPreferences con `prefs.clear()`
- Vuelve al inicio (onboarding)

---

## Reportar problema ✅
- Botón en menú de `card_detail_screen.dart`
- Email: `herechoes.info@callmehector.cl`
- ⚠️ En Simulator no abre nada — en dispositivo real abre Mail/Gmail

---

## Sistema punto rojo Settings ✅
```dart
await prefs.setBool('settings_has_card_issue', true);
await prefs.setBool('settings_has_new_terms', true);
static const bool _hasNewTerms = false; // → true en settings_screen.dart
```

---

## Estados error tarjeta (simulados, AddCardScreen)
| Número | Error |
|---|---|
| `4000 0000 0000 0002` | Rechazada |
| `4000 0000 0000 9995` | Sin fondos |
| Cualquier + `00/00` | Expirada |
| Cualquier + CVV `000` | CVV inválido |

---

## URLs
```
Imágenes:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
Wildcard:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
Panel admin: https://callmehector.cl/apps/herechoes/wildcard.php
Cupones:     https://callmehector.cl/apps/herechoes/coupons.php
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
v1.8-currency            ✅
v1.9-cleanup             ✅
v2.0-revenuecat          ⬜ pendiente hacer después de esta sesión
```

---

## Pendientes

### Alta prioridad
- [ ] ⚠️ Token GitHub expira **Apr 11 2026** — renovar
- [ ] Apple Sign In (cuenta Apple Developer activa ✅)
- [ ] Probar compra real con Sandbox en dispositivo físico
- [ ] Cancelar suscripción → conectar RevenueCat (UI lista)

### Media prioridad
- [ ] Google Sign In: Firebase + config nativa
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Flujo Plan Familiar: invitación por email
- [ ] Avatar Settings → foto real con auth
- [ ] `short_bio_es` vacío en varios registros JSON
- [ ] Resolver imágenes locales (22.7MB) — evaluar si eliminar carpeta local y usar solo GitHub

### Antes de producción
- [ ] Subir binario a App Store Connect (primer build)
- [ ] AppIcon configurado
- [ ] Privacy Nutrition Labels en App Store Connect
- [ ] Verificar imágenes GitHub cargan en dispositivo real
- [ ] Flujo downgrade de plan
- [ ] Bundle ID en Xcode ✅ ya configurado

---

## Next Development Focus (sesión 14)
1. Apple Sign In
2. Probar compra Sandbox en dispositivo real
3. Evaluar y resolver carpeta images/cards local (22.7MB)