# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-20 (sesión 15)

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
│   │                                  ✅ sesión 15: getter activePackage agregado
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
│   │   ├── plan_selection_screen.dart  ✅ sesión 13: compra real RevenueCat
│   │   ├── add_card_screen.dart        ⚠️ ya no se usa
│   │   ├── payment_screen.dart         ⚠️ ya no se usa (eliminado de settings)
│   │   ├── payment_method_screen.dart  ⚠️ ya no se usa
│   │   └── plan_detail_screen.dart     ✅ sesión 15: muestra datos RevenueCat
│   │                                   ✅ "Gestionar Suscripción" → App Store nativo
│   ├── home/home_screen.dart
│   ├── daily_echo/daily_echo_screen.dart  ✅ sesión 15: swipe nativo sin card_stack_widget
│   │                                      ✅ loop infinito, snap back, rotación
│   ├── show_all/show_all_screen.dart      ✅ sesión 15: padding ajustado top/bottom 24px
│   └── settings/
│       ├── settings_screen.dart           ✅ sesión 15: eliminado Medio de Pago
│       │                                  ✅ agregado Política de Privacidad
│       │                                  ✅ sección Legal separada
│       ├── legal_content_screen.dart      ✅ sesión 15: fix loader infinito
│       │                                  ✅ título hardcodeado en header
│       ├── notifications_screen.dart
│       ├── language_screen.dart           ✅ sesión 15: eliminada sección Moneda
│       └── preferences_screen.dart        ✅ sesión 15: "Language & Currency" → "Idioma"
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

android/
├── app/
│   ├── build.gradle.kts               ✅ sesión 15: signing config producción
│   └── google-services.json           ✅ sesión 14: Firebase Android config
├── key.properties                     ✅ sesión 15: keystore producción (en .gitignore)
├── settings.gradle.kts                ✅ sesión 14: plugin Google Services agregado
└── build.gradle.kts

assets/
├── data/her_echoes.json
├── data/wildcard.json
├── images/home/, system/, onboarding/
├── images/cards/                      ✅ 244 imágenes en GitHub
└── content/legal_content.json
```

---

## Android ✅ sesión 15

### build.gradle.kts (android/app/)
```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "cl.callmehector.herechoes"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "cl.callmehector.herechoes"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
```

### Keystore producción ✅ sesión 15
- Archivo: `~/herechoes-release.jks`
- Alias: `herechoes`
- `android/key.properties` creado y en `.gitignore` ✅
- AAB release compilado: `build/app/outputs/bundle/release/app-release.aab` (49.8MB) ✅

---

## RevenueCat ✅ sesión 13 + 15

### Credenciales
- Proyecto RC: HerEchoes
- **API Key iOS producción:** `appl_KDuVwOmljiRmgUegeqjadtfAjRA`
- Entitlement: `pro`
- Offering: `default`
- **In-App Purchase Key (SubscriptionKey):** `ZL6S5CVZY3.p8` → ✅ subido en RevenueCat
- **App Store Connect API Key (AuthKey):** `VGAK79S3V8.p8` → ✅ subido en RevenueCat
- **Issuer ID:** `0736adc9-024c-4b51-8881-73c9815df30f`
- Estado credenciales RC: ✅ Valid credentials

### Productos App Store Connect
| Nombre | Product ID | Precio CLP | Estado |
|---|---|---|---|
| Individual Mensual | `cl.callmehector.herechoes.individual` | $9.990 | ✅ Lista para enviar |
| Familiar Mensual | `cl.callmehector.herechoes.familiar` | $17.990 | ✅ Lista para enviar |
| Trial Mensual | `cl.callmehector.herechoes.trial` | $17.990 | ✅ Lista para enviar |

### Packages RevenueCat (offering: default)
| Identifier | Producto |
|---|---|
| `individual` | Individual Mensual |
| `familiar` | Familiar Mensual |
| `trial` | Trial Mensual |

---

## Firebase ✅ sesión 13 + 14
- Proyecto: `herechoes-dca3d`
- Bundle ID iOS: `cl.callmehector.herechoes`
- Package Android: `cl.callmehector.herechoes`
- GoogleService-Info.plist en Xcode ✅ (iOS)
- google-services.json en android/app/ ✅ (Android)
- CFBundleURLTypes con REVERSED_CLIENT_ID en Info.plist ✅
- iOS deployment target: 15.0 (configurado en Podfile)

---

## Google Sign In ✅ sesión 13
- Paquete: `google_sign_in: ^6.2.1`
- Client ID iOS: `769185908716-fg9b44votu6v93t8kh2m908hs71r3t9e.apps.googleusercontent.com`
- Client ID Android: `769185908716-aom3...` ✅ sesión 14
- REVERSED_CLIENT_ID: `com.googleusercontent.apps.769185908716-fg9b44votu6v93t8kh2m908hs71r3t9e`
- Flujo probado en simulador iOS ✅
- Por ahora va directo al Home — sin backend real aún

---

## Apple Sign In ✅ sesión 13
- Paquete: `sign_in_with_apple: ^7.0.1`
- Capability agregada en Xcode ✅
- Probado en simulador ✅

---

## Certificados y Signing iOS ✅ sesión 14
- **Apple Development:** Mac Studio de Héctor (16-03-26) ✅
- **Apple Distribution:** Apple Distribution (18-03-26) ✅
- Provisioning Profile: Xcode Managed Profile (automático)
- Signing Certificate Release: Apple Distribution

---

## Dispositivos registrados ✅ sesión 14
| Nombre | UDID | Tipo |
|---|---|---|
| iPhone 12 Pro Héctor | `00008101-001E212C0284001E` | iPhone |

---

## App Store Connect ✅ sesión 15
- App creada: HerEchoes
- Bundle ID: `cl.callmehector.herechoes`
- Grupo suscripciones: HerEchoes Pro (ID: 21981953)
- 3 suscripciones en estado "Lista para enviar" ✅
- **Versión 1.0.0 enviada a revisión** ✅ — 19-03-2026 a las 0:14 AM
- Status: **Pendiente de revisión** ⏳
- Descripción, palabras clave, categorías completadas ✅
- Privacy Nutrition Labels: "No se recopilan datos" ✅
- URL Política de Privacidad: `https://callmehector.cl/apps/herechoes/privacy.html` ✅

---

## Páginas web legales ✅ sesión 15
- `https://callmehector.cl/apps/herechoes/privacidad.html` — Política de Privacidad
- `https://callmehector.cl/apps/herechoes/terminos.html` — Términos y Condiciones

---

## TestFlight ✅ sesión 14
- **Primer build subido:** versión 1.0.0 (build 1) — 18-03-2026
- Warning inofensivo: "Upload Symbols Failed" — no afecta funcionamiento

---

## AppIcon ✅ sesión 13
- Todos los tamaños configurados en Xcode
- `assets/images/system/app_icon.png` agregado

---

## Podfile iOS ✅ sesión 14
- `platform :ios, '15.0'`
- `post_install` con fix de deployment target a 15.0

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
⚠️ La sección Moneda fue eliminada de Configuración → ahora solo está Idioma

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
Privacidad:  https://callmehector.cl/apps/herechoes/privacidad.html
Términos:    https://callmehector.cl/apps/herechoes/terminos.html
```

---

## Keystores y SHA
- **Debug keystore:** `~/.android/debug.keystore`
- **SHA-1 debug:** `3B:41:83:A1:3E:9F:35:6C:09:FF:7B:06:7D:31:45:93:2E:67:23:3F`
- **SHA-256 debug:** `02:96:0E:A5:61:6A:B8:5C:45:22:5C:2F:EC:EF:93:A5:E5:C1:38:B4:D8:00:8E:9B:CA:3A:8A:19:D1:FE:B6:57`
- **Producción Android:** `~/herechoes-release.jks` ✅ sesión 15
  - Alias: `herechoes`
  - `android/key.properties` configurado y en `.gitignore` ✅

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
v2.3-android-firebase    ✅ sesión 14
v2.4-appstore-submission ✅ sesión 15
v2.5-ui-fixes            ✅ sesión 15
```

---

## Pendientes

### Alta prioridad
- [ ] ⚠️ Token GitHub expira **Apr 11 2026** — renovar
- [ ] Esperar aprobación Apple (1.0.0 en revisión) ⏳
- [ ] TestFlight → agregar tester interno → probar en iPhone 12 Pro
- [ ] Probar compra Sandbox en dispositivo físico
- [ ] Sandbox Tester → crear en App Store Connect → Users and Access → Sandbox

### Media prioridad
- [ ] Show All — márgenes laterales aún más grandes de lo deseado (padding interno de vertical_card_pager)
- [ ] Flujo downgrade de plan
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Flujo Plan Familiar: invitación por email
- [ ] Avatar Settings → foto real con auth
- [ ] `short_bio_es` vacío en varios registros JSON
- [ ] Google Sign In — guardar usuario en backend real
- [ ] Capturas de pantalla para App Store

### Android (antes de producción)
- [ ] Pagar USD$25 → crear cuenta Google Play Console
- [ ] Crear app en Google Play Console
- [ ] Subir AAB → `build/app/outputs/bundle/release/app-release.aab` (49.8MB) ✅ listo
- [ ] Configurar RevenueCat Android
- [ ] Cliente OAuth Android en producción (actualmente solo debug SHA-1)

---

## Next Development Focus (sesión 16)
1. Esperar respuesta Apple sobre revisión 1.0.0
2. Si hay rechazo → corregir y resubir build 2
3. TestFlight → agregar tester interno → instalar en iPhone 12 Pro
4. Crear Sandbox Tester y probar compra RevenueCat en dispositivo real
5. Cuando llegue el dinero → pagar Google Play Console y subir AAB