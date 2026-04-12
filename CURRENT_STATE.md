# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-04-10 (sesión 21)

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
- **Pantallas de compra:** SIEMPRE incluir botón "Restaurar compras" — exigido por Apple
- **Android vs iOS:** Usar `Platform.isAndroid` para ajustes específicos de plataforma
- **Términos y Privacidad dentro de la app:** SIEMPRE usar `WebViewWidget` (webview_flutter) — NUNCA `url_launcher` con `LaunchMode.externalApplication` en pantallas legales internas, porque en sandbox de Apple Safari no está disponible y muestra "Contenido no disponible"
- **Pantalla de suscripción:** NUNCA usar toggle para trial — el trial es una tarjeta separada independiente

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

**versión actual pubspec iOS:** `version: 1.0.0+6` (build 6 generado, aún NO subido a App Store Connect)
**versión actual pubspec Android:** `version: 1.0.0+9` (versionCode Android = 9, en prueba interna)

⚠️ Antes de subir el IPA de iOS hay que incrementar a `version: 1.0.0+7`

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
│   │   │                               Individual (8px gap) Familiar (24px gap) Trial como tarjeta propia
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
│       ├── legal_content_screen.dart   ✅ sesión 21: reescrito con WebViewWidget — muestra contenido
│       │                               dentro de la app sin abrir Safari. Soluciona rechazo Apple 3.1.2(c)
│       ├── notifications_screen.dart   ✅ sesión 19: toggle fix (MIUI siempre retorna true en Android)
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/home_mini_card.dart, pro_badge.dart, wildcard_badge.dart
│   ├── modals/
│   │   ├── upsell_modal_free.dart  ✅ sesión 21: rediseñado — 3 tarjetas sin toggle, trial separado
│   │   └── upsell_modal_pro.dart   ✅ sesión 16: precios desde RevenueCat
│   ├── navigation/floating_tab_bar.dart
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
| Individual Mensual | `cl.callmehector.herechoes.individual` | DEVELOPER_ACTION_NEEDED — siguen visibles en ASC pero retirados |
| Familiar Mensual | `cl.callmehector.herechoes.familiar` | DEVELOPER_ACTION_NEEDED — siguen visibles en ASC pero retirados |
| Trial Mensual | `cl.callmehector.herechoes.trial` | DEVELOPER_ACTION_NEEDED — siguen visibles en ASC pero retirados |

⚠️ Apple buscó estos productos mensuales durante la revisión del build 5 y no los encontró funcionando.
Esto contribuyó al rechazo 2.1(b). En el próximo envío hay que responder a Apple explicando que
estos productos fueron retirados y reemplazados por los anuales.

---

## Rechazo Apple Build 5 — Análisis completo (sesión 21)

### Dispositivo de revisión
- iPad Air 11-inch (M3), iPadOS 26.4
- Fecha: 9 de abril 2026

### Guideline 2.3.2 — Imagen promocional igual al ícono
- La imagen promocional de las suscripciones en App Store Connect era igual al ícono de la app
- **Fix requerido:** Subir imagen promocional distinta al ícono en cada suscripción (1024x1024px)
- Esta imagen es OPCIONAL — si no se activa "promocionar en App Store" no bloquea la revisión
- ⚠️ Pendiente: crear y subir imagen promocional para las suscripciones anuales

### Guideline 3.1.2(c) parte 1 — Links de Términos y Privacidad no funcionan
- `legal_content_screen.dart` usaba `LaunchMode.externalApplication` (abría Safari)
- En sandbox de Apple, Safari no está disponible → pantalla mostraba "Contenido no disponible"
- **Fix aplicado sesión 21:** Reescrito con `WebViewWidget` — carga el contenido dentro de la app ✅
- Verificado: al abrir desde iPhone físico (iOS 26) sí carga la web correctamente

### Guideline 3.1.2(c) parte 2 — Toggle de prueba gratuita confuso
- El diseño anterior tenía un toggle dentro del Plan Individual para activar/desactivar el trial
- Apple dice que es confuso y puede llevar a malentendidos sobre el cargo automático
- **Fix aplicado sesión 21:** Rediseño completo — el trial es ahora una tarjeta separada ✅
  - Plan Individual (sin trial) — Anual
  - Plan Familiar — Anual — Hasta 3 personas
  - [24px de separación]
  - Plan Individual Trial — 7 días gratis, luego se renueva anualmente
- Aplicado en: `plan_selection_screen.dart` y `upsell_modal_free.dart`

### Guideline 2.1(b) — Botón "Suscribirme" no respondía
- Apple reportó que al tocar "Suscribirme" no ocurría ninguna acción
- Dispositivo: iPad Air M3, iPadOS 26.4
- Posible causa: productos con estado DEVELOPER_ACTION_NEEDED en App Store Connect
- Todos los productos (mensuales retirados + anuales activos) tienen este estado
- El estado se resetea automáticamente al incluirlos en un nuevo envío con build aprobado
- ⚠️ En el próximo envío: incluir explícitamente los 3 productos anuales en la sección
  "Compras dentro de la app y suscripciones" del envío

---

## RevenueCat ✅ COMPLETAMENTE CONFIGURADO (sesión 20)

### iOS ✅
- **API Key iOS:** `appl_KDuVwOmljiRmgUegeqjadtfAjRA`
- Entitlement: `pro`, Offering: `default`
- Estado: ✅ Valid credentials

### Android ✅
- **API Key Android:** `goog_chSzVTtDJfNcfIfRHepJqITjste`
- **App Play Store:** `HerEchoes (Play Store)` — package `cl.callmehector.herechoes`
- **Estado credentials:** ✅ Valid credentials
- **Productos:** ✅ 3 Published + entitlement `pro` cada uno
- **Offering default:** ✅ 3 packages con producto iOS y Android mapeados
- **Precios verificados en Redmi:** ✅

### Lección aprendida — "Credentials need attention"
El error NO era de propagación. La cuenta de servicio tenía permisos de **cuenta** en Google Play Console pero no estaba vinculada a la **aplicación** Her Echoes. Fix: Usuarios y permisos → cuenta de servicio → pestaña "Permisos de la aplicación" → Añadir aplicación → Her Echoes.

### Configuración Google Cloud
- **Proyecto:** HerEchoes (`herechoes-dca3d`)
- **API habilitada:** Google Play Android Developer API ✅
- **Service Account:** `revenuecat-android@herechoes-dca3d.iam.gserviceaccount.com` ✅

### Packages (offering: default) ✅
| Identifier | Producto iOS | Producto Android |
|---|---|---|
| `individual` | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual:individual-annual-p1y` |
| `trial` | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual:trial-annual-p1y` |
| `familiar` | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual:familiar-annual-p1y` |

---

## App Store Connect

### Builds iOS
| Build | Fecha | Estado |
|---|---|---|
| 1.0.0 (1) | 18-03-2026 | Rechazado — Guideline 2.1(b) |
| 1.0.0 (2) | 21-03-2026 | Finalizado |
| 1.0.0 (3) | 27-03-2026 | Finalizado |
| 1.0.0 (4) | 28-03-2026 | Finalizado |
| 1.0.0 (5) | 05-04-2026 | ❌ Rechazado — Guidelines 2.1(b), 2.3.2, 3.1.2(c) |
| 1.0.0 (6) | ⏳ Generado localmente — aún NO subido a App Store Connect |
| 1.0.0 (7) | ⏳ Pendiente — incrementar build number y generar IPA |

### Qué incluye el build 7 (próximo a subir)
- ✅ WebView para Términos y Privacidad (fix rechazo 3.1.2c)
- ✅ Pantalla de planes rediseñada sin toggle (fix rechazo 3.1.2c parte 2)
- ✅ plan_type.dart con PlanType.trial
- ✅ upsell_modal_free.dart rediseñado sin toggle
- ✅ lazy loading en Show All (30 items, +30 al scroll)
- ✅ JSON actualizado hasta 30 de junio (365 entradas)
- ✅ webview_flutter ^4.13.1 agregado al pubspec

### Sandbox Tester
- Email: `valar.disghulis@gmail.com` — País: Chile

### Internal Testers TestFlight
- `1.61803haz@gmail.com`
- `hector@callmehector.cl`

---

## Google Play Console ✅

### Estado general
- App: **Her Echoes** — `cl.callmehector.herechoes`
- Categoría: Educación
- Ficha Play Store: ✅ configurada
- Cuenta de comercio Google Payments: ✅ configurada

### Prueba interna
- Canal: **Activo**
- Última versión: **9 (1.0.0)** ✅

### Prueba cerrada Alpha
- Canal: **Activo** — versión 9 (1.0.0), última actualización 8 abr 2026
- Cambios en revisión: lanzamiento completo + 176 países + resto del mundo

### Historial AABs
| versionCode | Estado |
|---|---|
| 1-3 | Bug MainActivity (com.example) |
| 4 | Fix MainActivity + lazy loading + button fix |
| 5-7 | Saltados |
| 8 | Fix notifications + mailto + RevenueCat API key |
| 9 | ✅ En prueba interna y prueba cerrada Alpha — versión actual |

### Tester interno
- Email: `01010.herechoes@gmail.com`

### Prueba cerrada (OBLIGATORIA para producción)
- Requiere: 12 testers + 14 días activos
- Estado: ⏳ pendiente

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

---

## Imágenes en GitHub ✅
URL: `https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp`

### Imágenes subidas sesión 21 (34) — incluidas en JSON hasta jun 30:
abbagnato, bachmann, baker_02, baxter_02, carter_03, colvin, cornaro, desai, donohoe, dorio,
dunbar, hajiwon, horne_02, kidman, kristeva, larmore, massari, mcaleese, mcdormand, mink,
murray, ning, randall, robertson, ruge, saldana, satir, sheinbaum, soraya, sotomayor,
tunney, willard, yingluck, ziegesar

### Imágenes subidas sesiones anteriores — ya en JSON:
(sesión 19: baker, barnes, bath, bening, blau, bondfield, bourgeois, bourkewhite, coleman_02,
drabble, jackson, jolie, keller_02, klum, lenglen, mahler, marshall, menzel, montessori,
quatro, swenson, washington, west)
(sesión 20: apgar, bahlsen, bernhard, bhardwaj, bjork, blavatsky, brooks, burney, forrester,
garland, gore, graf, hamilton_02, hantuchova, hunt, loving, malone, mcdaniel, mozart, oates,
owens, portman, reuben, sayers, sissi, tyler, venus, yourcenar)

---

## Wildcard ✅
- Cargado desde GitHub en tiempo real
- Token `herechoes-wildcard`: **SIN fecha de expiración** ✅ (verificado sesión 21 — el CURRENT_STATE anterior estaba equivocado)

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

⚠️ Nota: las URLs reales del servidor usan `privacidad.html` y `terminos.html` (en español),
no `privacy.html` ni `terms.html`. El legal_content_screen.dart ya apunta a las URLs correctas.

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
```
⚠️ Pendiente crear tag para sesión 21 después de subir build 7

---

## Pendientes

### URGENTE — Próximos pasos inmediatos
- [ ] Incrementar build number a 7 en pubspec.yaml
- [ ] Generar IPA (`flutter build ipa`)
- [ ] Subir IPA a App Store Connect via Transporter
- [ ] En el envío: incluir los 3 productos anuales en "Compras dentro de la app y suscripciones"
- [ ] Responder a Apple en el hilo del rechazo explicando que los productos mensuales fueron retirados
- [ ] Crear tag git `v3.2-apple-review-fixes`

### Media prioridad
- [ ] Crear imagen promocional 1024x1024px para suscripciones (fix guideline 2.3.2)
- [ ] Show All — márgenes laterales
- [ ] Prueba cerrada Google Play (12 testers, 14 días)
- [ ] Sandbox Tester separado para reviewer Apple
- [ ] Migrar her_echoes.json a carga remota desde GitHub
- [ ] Completar JSON julio → diciembre

### Sesión 22 — Estado actualizado
Build iOS

Build 10 subido y enviado a revisión Apple (11 abr 2026, 21:49)
Rechazado build 10 — mismos problemas + nuevos
Fixes aplicados sin nuevo build:

Imágenes promocionales eliminadas de las 3 suscripciones anuales (Individual, Trial, Familiar)
Link Términos de uso agregado en descripción App Store: https://callmehector.cl/apps/herechoes/terminos.html
"Suscripción mensual" corregida a "Suscripción anual" en descripción
Respondido a Apple explicando retiro de planes mensuales y que imágenes promocionales son opcionales


Re-enviado a revisión (11 abr 2026, 21:49) — Pendiente de revisión

pubspec.yaml

version: 1.0.0+10 (iOS y Android)

Android — Build 10

SHA-256 del keystore de producción registrado en Firebase: EE:ED:33:63:D9:1E:50:6B:96:5D:2A:8A:62:C2:3D:4D:F7:19:E8:E6:43:79:C7:28:55:38:EC:44:F9:01:8B:54
google-services.json actualizado en el proyecto
AAB build 10 subido a Prueba cerrada Alpha — en revisión
Bug reportado: Google Sign-In en Android no funciona — modal se cierra sin autenticar. Fix aplicado: SHA-256 registrado en Firebase. Pendiente verificar si se resuelve con build 10.

Google Play — Prueba cerrada

13 testers en Lista testers 001
Enlace enviado a todos — pendiente que acepten y descarguen
Contador Panel de control: 0 testers aceptados (actualizacion puede tardar 24hrs)
Build 10 en revisión — pendiente publicación

Git

Tag v3.2-apple-review-fixes ✅
⚠️ Pendiente crear tag v3.3-firebase-sha-fix después de confirmar que Google Sign-In funciona