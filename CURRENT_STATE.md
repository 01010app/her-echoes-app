# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-17 (sesión 13)

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
- Registrado en Apple Developer
- Configurado en Xcode → Runner → Signing & Capabilities
- Team: Héctor Astete (7H4G6LP6K5)

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
purchases_flutter: ^9.14.0       ✅ sesión 13
sign_in_with_apple: ^7.0.1       ✅ sesión 13
firebase_core: ^4.5.0            ✅ sesión 13
google_sign_in: ^6.2.1           ✅ sesión 13
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
│   │   ├── login_screen.dart          ✅ sesión 13: Apple + Google Sign In
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

ios/
├── Runner/
│   ├── GoogleService-Info.plist       ✅ sesión 13: Firebase config
│   └── Info.plist                     ✅ sesión 13: CFBundleURLTypes Google

assets/
├── data/her_echoes.json
├── data/wildcard.json
├── images/home/, system/, onboarding/
├── images/cards/                      ✅ 244 imágenes en GitHub
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
| Identifier | Producto |
|---|---|
| `individual` | Individual Mensual |
| `familiar` | Familiar Mensual |
| `trial` | Trial Mensual |

### In-App Purchase Key
- Key ID: `ZL6S5CVZY3`
- Issuer ID: `0736adc9-024c-4b51-8881-73c9815df30f`

---

## Firebase ✅ sesión 13
- Proyecto: `herechoes-dca3d`
- Bundle ID: `cl.callmehector.herechoes`
- GoogleService-Info.plist en Xcode ✅
- CFBundleURLTypes con REVERSED_CLIENT_ID en Info.plist ✅
- iOS deployment target: 15.0 (actualizado en Podfile)

---

## Google Sign In ✅ sesión 13
- Paquete: `google_sign_in: ^6.2.1`
- Client ID iOS: `769185908716-fg9b44votu6v93t8kh2m908hs71r3t9e.apps.googleusercontent.com`
- REVERSED_CLIENT_ID: `com.googleusercontent.apps.769185908716-fg9b44votu6v93t8kh2m908hs71r3t9e`
- Flujo probado en simulador ✅
- Por ahora va directo al Home — sin backend real aún
- ⚠️ Cliente OAuth Android pendiente (requiere SHA-1 del keystore)

---

## Apple Sign In ✅ sesión 13
- Paquete: `sign_in_with_apple: ^7.0.1`
- Capability agregada en Xcode ✅
- Probado en simulador (muestra "Inicia sesión en Configuración") ✅
- En dispositivo real muestra sheet nativo Apple

---

## App Store Connect ✅ sesión 13
- App creada: HerEchoes
- Bundle ID: `cl.callmehector.herechoes`
- Grupo suscripciones: HerEchoes Pro
- 3 suscripciones configuradas

---

## AppIcon ✅ sesión 13
- Todos los tamaños configurados en Xcode
- `assets/images/system/app_icon.png` agregado

---

## Sistema de Moneda ✅
| Código | Individual | Trial | Familiar |
|---|---|---|---|
| CLP | 9.900 | 16.800 | 16.500 |
| USD | 10 | 17 | 17 |
| EUR | 9 | 15 | 15 |
| MXN | 199 | 349 | 329 |
| ARS | 8.990 | 14.990 | 13.990 |

⚠️ Precios reales App Store: $9.990 / $17.990 CLP

---

## Sistema de Cupones ✅
- `https://callmehector.cl/apps/herechoes/coupons.php`

| Código | Tipo | Valor | Meses |
|---|---|---|---|
| INFLUENCER2026 | percent | 30% | 1 |
| REGALO100 | percent | 100% | 1 |
| DESCUENTO3000 | fixed | CLP 3.000 | 3 |

---

## Wildcard
- Panel admin: `https://callmehector.cl/apps/herechoes/wildcard.php`
- ⚠️ Token GitHub `herechoes-wildcard` expira **Apr 11 2026** — renovar

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
v2.0-revenuecat          ✅ sesión 13
v2.1-apple-signin        ✅ sesión 13
v2.2-google-signin       ✅ sesión 13
```

---

## Pendientes

### Alta prioridad
- [ ] ⚠️ Token GitHub expira **Apr 11 2026** — renovar
- [ ] Cliente OAuth Android (SHA-1 keystore pendiente)
- [ ] Probar compra real Sandbox en dispositivo físico
- [ ] Cancelar suscripción → conectar RevenueCat (UI lista)
- [ ] Android: Google Play Console + RevenueCat Android

### Media prioridad
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Flujo Plan Familiar: invitación por email
- [ ] Avatar Settings → foto real con auth
- [ ] `short_bio_es` vacío en varios registros JSON
- [ ] Google Sign In — guardar usuario en backend real

### Antes de producción iOS
- [ ] Subir primer binario a App Store Connect (TestFlight)
- [ ] Privacy Nutrition Labels en App Store Connect
- [ ] Verificar imágenes GitHub en dispositivo real
- [ ] Flujo downgrade de plan

### Antes de producción Android
- [ ] Crear app en Google Play Console
- [ ] Configurar RevenueCat Android
- [ ] Keystore de producción Android
- [ ] `google-services.json` para Android

---

## Next Development Focus (sesión 14)
1. Cliente OAuth Android + SHA-1
2. Probar compra Sandbox en dispositivo real
3. Subir primer build a TestFlight

---
## Google Sign In ✅ sesión 13
...
- ⚠️ Cliente OAuth Android pendiente
- Debug keystore SHA-256: `02:96:0E:A5:61:6A:B8:5C:45:22:5C:2F:EC:EF:93:A5:E5:C1:38:B4:D8:00:8E:9B:CA:3A:8A:19:D1:FE:B6:57`
- Debug keystore ubicación: `~/.android/debug.keystore`

---
## Next Development Focus (sesión 14)
1. Cliente OAuth Android — usar SHA-256 ya generado
2. Agregar app Android en Firebase → descargar google-services.json
3. Probar compra Sandbox en dispositivo real
4. Subir primer build a TestFlight