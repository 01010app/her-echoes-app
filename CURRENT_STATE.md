# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-04-18 (sesión 23)

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
vertical_card_pager: (ver pubspec) ✅ usado en show_all_screen
webview_flutter: ^4.13.1         ✅ sesión 21: para mostrar términos y privacidad dentro de la app
```

**versión actual pubspec:** `version: 1.0.0+13`
**CURRENT_PROJECT_VERSION en pbxproj:** `13`

⚠️ Para incrementar build number iOS en el futuro:
```bash
python3 -c "
f = open('ios/Runner.xcodeproj/project.pbxproj', 'r', encoding='utf-8')
content = f.read()
f.close()
content = content.replace('CURRENT_PROJECT_VERSION = N;', 'CURRENT_PROJECT_VERSION = N+1;')
f = open('ios/Runner.xcodeproj/project.pbxproj', 'w', encoding='utf-8')
f.write(content)
f.close()
print('Listo')
"
```
Reemplazar N y N+1 con los números correspondientes. Luego verificar con:
```bash
unzip -p build/ios/ipa/*.ipa "Payload/Runner.app/Info.plist" | plutil -convert xml1 - -o - | grep -A1 CFBundleVersion
```
El mensaje "Build Number" del output de flutter build es MENTIRA — siempre verificar dentro del IPA.

---

## Estructura de Archivos
```
lib/
├── core/
│   ├── favorites_provider.dart
│   ├── language_provider.dart
│   ├── currency_provider.dart      ⚠️ YA NO se usa para precios de IAP
│   ├── subscription_provider.dart  ✅ sesión 13: RevenueCat real
│   └── theme/app_colors.dart
├── screens/
│   ├── card_detail/card_detail_screen.dart
│   │                               ✅ sesión 18: _buildBottomActions corregido para Android
│   │                               ✅ sesión 19: mailto Android fix (LaunchMode.externalApplication)
│   ├── favorites/favorites_screen.dart
│   ├── login/
│   │   ├── login_screen.dart       ✅ sesión 17: links terms.html y privacy.html funcionales
│   │   ├── onboarding_screen.dart
│   │   ├── email_login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── onboarding_name_screen.dart
│   ├── payment/
│   │   ├── plan_type.dart          ✅ sesión 21: agregado PlanType.trial (antes solo individual y family)
│   │   ├── plan_selection_screen.dart  ✅ sesión 21: rediseñado — 3 tarjetas separadas sin toggle
│   │   │                               ✅ sesión 23: links Términos y Privacidad visibles (3.1.2c)
│   │   ├── add_card_screen.dart        ⚠️ ya no se usa
│   │   ├── payment_screen.dart         ⚠️ ya no se usa
│   │   ├── payment_method_screen.dart  ⚠️ ya no se usa
│   │   └── plan_detail_screen.dart     ✅ sesión 16
│   ├── home/home_screen.dart
│   ├── daily_echo/daily_echo_screen.dart
│   ├── show_all/show_all_screen.dart   ✅ sesión 18: lazy loading (30 items, +30 al acercarse al final)
│   │                                   ✅ sesión 18: cacheWidth: 400 para reducir memoria Android
│   └── settings/
│       ├── settings_screen.dart
│       ├── legal_content_screen.dart   ✅ sesión 21: reescrito con WebViewWidget
│       ├── notifications_screen.dart   ✅ sesión 19: toggle fix (MIUI siempre retorna true en Android)
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/home_mini_card.dart, pro_badge.dart, wildcard_badge.dart
│   ├── modals/
│   │   ├── upsell_modal_free.dart  ✅ sesión 21: rediseñado — 3 tarjetas sin toggle, trial separado
│   │   │                           ✅ sesión 23: links Términos y Privacidad agregados (3.1.2c)
│   │   └── upsell_modal_pro.dart   ✅ sesión 16: precios desde RevenueCat
│   │                               ✅ sesión 23: links Términos y Privacidad agregados (3.1.2c)
│   ├── navigation/floating_tab_bar.dart
│   │                               ✅ sesión 23: fix Android nav bar con viewPadding.bottom
│   │                               (soluciona barra semitransparente en Xiaomi HyperOS)
│   ├── system/app_button.dart      — height fijo 52px; wrappear con SizedBox(48) en Android
│   └── settings/settings_divider, container, item, section_title
└── services/daily_suggestions_engine.dart
```

---

## Android — Estructura de archivos crítica ✅ sesión 18
```
android/app/src/main/kotlin/
├── cl/callmehector/herechoes/
│   └── MainActivity.kt   ✅ package cl.callmehector.herechoes (CORRECTO — usar este)
└── com/example/herechoes/
    └── MainActivity.kt   ⚠️ archivo legacy con package incorrecto — NO eliminar pero ignorar
```
El `build.gradle.kts` usa `applicationId = "cl.callmehector.herechoes"`.
Flutter toma el MainActivity de `cl/callmehector/herechoes/`.

---

## Android — Ajustes de diseño específicos ✅
- **card_detail_screen.dart `_buildBottomActions`:**
  - iOS: padding `fromLTRB(24, 24, 24, 0)`, botones height 52px
  - Android: padding `fromLTRB(16, 16, 16, 24)`, botones en `SizedBox(height: 48)`
  - ✅ Verificado en Redmi sesión 19

- **floating_tab_bar.dart — bottom offset:**
  - iOS: siempre `bottom: 24`
  - Android con gestos (navBarHeight ≈ 0): `bottom: 24`
  - Android con barra física/semitransparente (HyperOS, MIUI): `bottom: viewPadding.bottom + 8`
  - ✅ Fix sesión 23 — soluciona Xiaomi 14 Note y similares

---

## Modelo de Negocio IAP ✅ sesión 20

### Productos ACTIVOS (anuales)
| Nombre | Product ID iOS | Product ID Android | Precio USD | Duración | Trial |
|---|---|---|---|---|---|
| Individual Anual | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual` | $8.99 | 1 año | No |
| Trial Anual | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual` | $12.99 | 1 año | 7 días gratis |
| Familiar Anual | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual` | $14.99 | 1 año | No |

⚠️ Los Product IDs Android son distintos a iOS (más cortos). Normal — RevenueCat los mapea por separado.

### Productos RETIRADOS (mensuales)
| Nombre | Product ID | Estado App Store Connect |
|---|---|---|
| Individual Mensual | `cl.callmehector.herechoes.individual` | DEVELOPER_ACTION_NEEDED — retirados, Apple notificado |
| Familiar Mensual | `cl.callmehector.herechoes.familiar` | DEVELOPER_ACTION_NEEDED — retirados, Apple notificado |
| Trial Mensual | `cl.callmehector.herechoes.trial` | DEVELOPER_ACTION_NEEDED — retirados, Apple notificado |

✅ Apple fue notificado en la respuesta al rechazo 2.1(b) — explicamos que fueron reemplazados por anuales.

---

## Historial de rechazos Apple

### Build 5 — rechazado 9 abril 2026
- Guideline 2.1(b): botón suscribir no respondía + productos mensuales retirados
- Guideline 2.3.2: imágenes promocionales iguales al ícono
- Guideline 3.1.2(c): links Términos/Privacidad no funcionaban (abrían Safari en sandbox)

### Build 10 — rechazado (revisado 14 abril 2026, iPad Air M2)
- Guideline 2.1(b): ✅ resuelto con respuesta explicando retiro de mensuales
- Guideline 2.3.2: ✅ resuelto eliminando imágenes promocionales
- Guideline 3.1.2(c): links presentes en plan_selection_screen pero FALTABAN en upsell_modal_free y upsell_modal_pro

### Build 12 — rechazado 18 abril 2026 (iPad Air M2)
- Guideline 3.1.2(c): links aún no visibles en el modal que Apple revisó (upsell_modal_free)

### Build 13 — enviado a revisión 18 abril 2026 ⏳
- ✅ Links Términos y Privacidad agregados en upsell_modal_free y upsell_modal_pro
- ✅ Fix Android nav bar (floating_tab_bar)

---

## App Store Connect — Estado actual

### Build iOS
| Build | Fecha | Estado |
|---|---|---|
| 1.0.0 (1) | 18-03-2026 | Rechazado — Guideline 2.1(b) |
| 1.0.0 (5) | 05-04-2026 | ❌ Rechazado — Guidelines 2.1(b), 2.3.2, 3.1.2(c) |
| 1.0.0 (10) | 11-04-2026 | ❌ Rechazado — Guideline 3.1.2(c) |
| 1.0.0 (12) | 17-04-2026 | ❌ Rechazado — Guideline 3.1.2(c) |
| 1.0.0 (13) | 18-04-2026 | ⏳ En revisión |

### Metadatos App Store Connect ✅
- Imágenes promocionales: eliminadas de los 3 productos anuales ✅
- EULA: configurada como "Contrato de licencia estándar de Apple" ✅
- Links Términos y Privacidad: en descripción y campo EULA ✅
- Encryption compliance: "Ninguno de los algoritmos mencionados" ✅
- Productos anuales incluidos en el envío: ✅

### Sandbox Tester
- Email: `valar.disghulis@gmail.com` — País: Chile

### Internal Testers TestFlight
- `1.61803haz@gmail.com`
- `hector@callmehector.cl`

---

## RevenueCat ✅ COMPLETAMENTE CONFIGURADO (sesión 20)

### iOS ✅
- **API Key iOS:** `appl_KDuVwOmljiRmgUegeqjadtfAjRA`
- Entitlement: `pro`, Offering: `default`

### Android ✅
- **API Key Android:** `goog_chSzVTtDJfNcfIfRHepJqITjste`
- **App Play Store:** `HerEchoes (Play Store)` — package `cl.callmehector.herechoes`
- **Estado credentials:** ✅ Valid credentials

### Packages (offering: default) ✅
| Identifier | Producto iOS | Producto Android |
|---|---|---|
| `individual` | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual:individual-annual-p1y` |
| `trial` | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual:trial-annual-p1y` |
| `familiar` | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual:familiar-annual-p1y` |

---

## Google Play Console ✅

### Estado general
- App: **Her Echoes** — `cl.callmehector.herechoes`
- Categoría: Educación
- Ficha Play Store: ✅ configurada
- Cuenta de comercio Google Payments: ✅ configurada

### Prueba interna
- Canal: **Activo**
- Última versión: **9 (1.0.0)**

### Prueba cerrada Alpha
- Canal: **Activo**
- Build 11 (1.0.0): ✅ Publicado — disponible para testers desde 12 abr 2026
- ⚠️ Google Sign-In: fix incluido en build 11 — pendiente confirmación de testers

### Estado acceso a producción
- Testers que aceptaron: **4 de 13** (necesitan 12)
- Días de prueba: ~6 días (necesitan 14)
- ⚠️ Hay que contactar a los 9 testers restantes para que acepten la invitación

### Historial AABs
| versionCode | Estado |
|---|---|
| 1-3 | Bug MainActivity (com.example) |
| 4 | Fix MainActivity + lazy loading + button fix |
| 5-7 | Saltados |
| 8 | Fix notifications + mailto + RevenueCat API key |
| 9 | En prueba interna |
| 10 | Saltado (build number iOS conflicto) |
| 11 | ✅ En prueba cerrada Alpha — incluye SHA-256 firma de Google Play |
| 13 | ✅ En prueba cerrada Alpha — fix nav bar HyperOS/MIUI |

### Tester interno
- Email: `01010.herechoes@gmail.com`

### Testers prueba cerrada
- 13 testers en Lista testers 001
- 4 testers han aceptado participar
- Requiere: 12 testers activos + 14 días para solicitar acceso a producción

---

## 🔴 BUG CRÍTICO: Google Sign-In no funciona en Android

### Causa raíz (descubierta sesión 22)
Firebase necesita el SHA-256 del **certificado de firma de Google Play**. Este SHA es DISTINTO al SHA-256 del keystore local de subida.

### Los dos SHA-256
| Certificado | SHA-256 | Rol |
|---|---|---|
| Clave de firma de aplicación (Google Play) | `62:DB:13:B5:EB:32:22:CF:8A:6F:A1:2D:9D:7C:AC:32:D1:CE:00:F1:93:BF:6B:72:6F:EF:C4:17:8C:27:AF:2E` | ✅ Registrado en Firebase |
| Clave de subida (keystore local) | `EE:ED:33:63:D9:1E:50:6B:96:5D:2A:8A:62:C2:3D:4D:F7:19:E8:E6:43:79:C7:28:55:38:EC:44:F9:01:8B:54` | ✅ Registrado en Firebase |

### Estado
- ✅ Ambos SHA registrados en Firebase Console
- ✅ google-services.json actualizado
- ✅ Build 11 publicado en prueba cerrada
- ⏳ Pendiente confirmación de testers que funciona

---

## Firebase — Huellas SHA registradas ✅
En Firebase Console → HerEchoes → Configuración → HerEchoes Android:
1. `ee:ed:33:63:d9:1e:50:6b:96:5d:2a:8a:62:c2:3d:4d:f7:19:e8:e6:43:79:c7:28:55:38:ec:44:f9:01:8b:54` — SHA-256 keystore de subida
2. `62:db:13:b5:eb:32:22:cf:8a:6f:a1:2d:9d:7c:ac:32:d1:ce:00:f1:93:bf:6b:72:6f:ef:c4:17:8c:27:af:2e` — SHA-256 firma de Google Play ✅

---

## Android — Debugging WiFi
```bash
~/Library/Android/sdk/platform-tools/adb pair IP:PUERTO CODIGO
~/Library/Android/sdk/platform-tools/adb connect IP:PUERTO
flutter run --device-id IP:PUERTO
~/Library/Android/sdk/platform-tools/adb -s IP:PUERTO logcat | grep -E "FATAL|Flutter|Exception"
```
**Redmi A2:** Android 13 (API 33), armeabi-v7a, IP típica: 192.168.1.166

---

## her_echoes.json
- Cargado desde **assets locales** — cualquier cambio requiere nuevo build
- Total: 365 entradas ✅ sesión 21
- Cobertura: marzo → 30 de junio ✅
- ⚠️ Pendiente: completar julio → diciembre
- ⚠️ Pendiente: migrar a carga remota desde GitHub (para evitar builds por cada actualización de contenido)

---

## Imágenes en GitHub ✅
URL: `https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp`

### Imágenes subidas sesión 21 (34):
abbagnato, bachmann, baker_02, baxter_02, carter_03, colvin, cornaro, desai, donohoe, dorio,
dunbar, hajiwon, horne_02, kidman, kristeva, larmore, massari, mcaleese, mcdormand, mink,
murray, ning, randall, robertson, ruge, saldana, satir, sheinbaum, soraya, sotomayor,
tunney, willard, yingluck, ziegesar

### Imágenes subidas sesiones anteriores:
(sesión 19: baker, barnes, bath, bening, blau, bondfield, bourgeois, bourkewhite, coleman_02,
drabble, jackson, jolie, keller_02, klum, lenglen, mahler, marshall, menzel, montessori,
quatro, swenson, washington, west)
(sesión 20: apgar, bahlsen, bernhard, bhardwaj, bjork, blavatsky, brooks, burney, forrester,
garland, gore, graf, hamilton_02, hantuchova, hunt, loving, malone, mcdaniel, mozart, oates,
owens, portman, reuben, sayers, sissi, tyler, venus, yourcenar)

---

## Wildcard ✅
- Cargado desde GitHub en tiempo real
- Token `herechoes-wildcard`: **SIN fecha de expiración** ✅

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
- **Producción Android:** `~/herechoes-release.jks`, alias: `herechoes`
- `android/key.properties` configurado y en `.gitignore` ✅
- **SHA-1 debug:** `3B:41:83:A1:3E:9F:35:6C:09:FF:7B:06:7D:31:45:93:2E:67:23:3F`

---

## Git Tags
```
v2.6-iap-annual-fix              ✅
v2.7-json-fix                    ✅
v2.8-login-links-fix             ✅
v2.9-android-legal-fixes         ✅
v3.0-android-revenuecat-setup    ✅ sesión 19
v3.1-android-revenuecat-complete ✅ sesión 20
v3.2-apple-review-fixes          ✅ sesión 22
v3.3-firebase-sha-fix            ✅ sesión 22 — ⚠️ apunta al SHA de subida solamente, fix incompleto
v3.4-legal-links-nav-fix         ✅ sesión 23 — links legales en modales + fix Android nav bar
v3.5-android-nav-fix             ✅ sesión 24 — fix floating_tab_bar Android nav bar
```

---

## Pendientes

### URGENTE
- [ ] Confirmar que Apple aprueba build 13 (links legales en modales)
- [ ] Contactar 2 testers Android restantes para que acepten invitación prueba cerrada
- [ ] Confirmar que Google Sign-In funciona en build 11 (pedir a tester que pruebe)

### Media prioridad
- [ ] Completar requisitos prueba cerrada: 12 testers activos + 14 días
- [ ] Verificación de desarrolladores Android (plazo: septiembre 2026)
- [ ] Crear imagen promocional 1024x1024px para suscripciones
- [ ] Show All — márgenes laterales
- [ ] Migrar her_echoes.json a carga remota desde GitHub
- [ ] Completar JSON julio → diciembre