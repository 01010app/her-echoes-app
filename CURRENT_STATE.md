# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-04-12 (sesión 22)

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

**versión actual pubspec:** `version: 1.0.0+10`
⚠️ Antes de subir el próximo AAB hay que incrementar a `version: 1.0.0+11`

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
- ⚠️ Fix aplicado: imágenes promocionales eliminadas de las 3 suscripciones anuales

### Guideline 3.1.2(c) parte 1 — Links de Términos y Privacidad no funcionan
- `legal_content_screen.dart` usaba `LaunchMode.externalApplication` (abría Safari)
- En sandbox de Apple, Safari no está disponible → pantalla mostraba "Contenido no disponible"
- **Fix aplicado sesión 21:** Reescrito con `WebViewWidget` — carga el contenido dentro de la app ✅

### Guideline 3.1.2(c) parte 2 — Toggle de prueba gratuita confuso
- El diseño anterior tenía un toggle dentro del Plan Individual para activar/desactivar el trial
- Apple dice que es confuso y puede llevar a malentendidos sobre el cargo automático
- **Fix aplicado sesión 21:** Rediseño completo — el trial es ahora una tarjeta separada ✅

### Guideline 2.1(b) — Botón "Suscribirme" no respondía
- Posible causa: productos con estado DEVELOPER_ACTION_NEEDED en App Store Connect
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

### Packages (offering: default) ✅
| Identifier | Producto iOS | Producto Android |
|---|---|---|
| `individual` | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual:individual-annual-p1y` |
| `trial` | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual:trial-annual-p1y` |
| `familiar` | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual:familiar-annual-p1y` |

---

## App Store Connect

### Estado iOS — Build 10
- Build 10 enviado a revisión Apple: 11 abr 2026, 21:49
- Estado: ⏳ En revisión (re-enviado después de fixes sin nuevo build)
- Fixes aplicados sin nuevo build:
  - Imágenes promocionales eliminadas de las 3 suscripciones anuales
  - Link Términos de uso agregado en descripción App Store
  - "Suscripción mensual" corregida a "Suscripción anual" en descripción
  - Respondido a Apple explicando retiro de planes mensuales

### Builds iOS historial
| Build | Fecha | Estado |
|---|---|---|
| 1.0.0 (1) | 18-03-2026 | Rechazado — Guideline 2.1(b) |
| 1.0.0 (2) | 21-03-2026 | Finalizado |
| 1.0.0 (3) | 27-03-2026 | Finalizado |
| 1.0.0 (4) | 28-03-2026 | Finalizado |
| 1.0.0 (5) | 05-04-2026 | ❌ Rechazado — Guidelines 2.1(b), 2.3.2, 3.1.2(c) |
| 1.0.0 (10) | 11-04-2026 | ⏳ En revisión |

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
- Última versión: **9 (1.0.0)**

### Prueba cerrada Alpha
- Canal: **Activo**
- Build 10 (1.0.0): en revisión por Google (subido 12 abr 2026)
- ⚠️ Build 10 AÚN NO publicado — en revisión al momento de esta sesión

### Historial AABs
| versionCode | Estado |
|---|---|
| 1-3 | Bug MainActivity (com.example) |
| 4 | Fix MainActivity + lazy loading + button fix |
| 5-7 | Saltados |
| 8 | Fix notifications + mailto + RevenueCat API key |
| 9 | En prueba interna y prueba cerrada Alpha |
| 10 | En revisión — incluye google-services.json con SHA-256 keystore de subida |
| 11 | ⏳ Próximo a subir — incluye google-services.json con SHA-256 firma de Google Play |

### Tester interno
- Email: `01010.herechoes@gmail.com`

### Testers prueba cerrada
- 13 testers en Lista testers 001
- 1 tester ha aceptado participar al momento de esta sesión
- Requiere: 12 testers activos + 14 días para solicitar acceso a producción

---

## 🔴 BUG CRÍTICO: Google Sign-In no funciona en Android

### Síntoma
El modal de Google Sign-In se abre y se cierra sin autenticar. El usuario no puede loguearse con su cuenta Google en Android.

### Causa raíz (descubierta sesión 22)
Firebase necesita el SHA-256 del **certificado de firma de Google Play** (el que Google usa para re-firmar la app al distribuirla). Este SHA es DISTINTO al SHA-256 del keystore local de subida.

Google Play App Signing re-firma todos los AABs con su propio certificado antes de distribuirlos. Firebase valida el origen del request usando este SHA. Si solo está registrado el SHA del keystore de subida, Firebase rechaza los requests que vienen de la app distribuida por Google Play.

### Los dos SHA-256 que existen (Google Play Console → Integridad de la app → Firma de aplicaciones)

| Certificado | SHA-256 | Rol |
|---|---|---|
| Clave de firma de aplicación (Google Play) | `62:DB:13:B5:EB:32:22:CF:8A:6F:A1:2D:9D:7C:AC:32:D1:CE:00:F1:93:BF:6B:72:6F:EF:C4:17:8C:27:AF:2E` | El que usa Google para distribuir — **este es el que faltaba** |
| Clave de subida (keystore local) | `EE:ED:33:63:D9:1E:50:6B:96:5D:2A:8A:62:C2:3D:4D:F7:19:E8:E6:43:79:C7:28:55:38:EC:44:F9:01:8B:54` | El que registramos en sesión anterior — necesario pero no suficiente |

### Fixes aplicados en sesión 22
1. ✅ SHA-256 de firma de Google Play agregado en Firebase Console → HerEchoes → HerEchoes Android → Huellas digitales del certificado SHA
2. ✅ `google-services.json` descargado y reemplazado en `android/app/google-services.json`
3. ✅ AAB compilado exitosamente (`flutter build appbundle --release`) — 50.4MB
4. ⏳ **PENDIENTE:** Incrementar pubspec a `version: 1.0.0+11` y subir AAB build 11 a Prueba cerrada Alpha

### Plan de acción — próximos pasos inmediatos
1. Incrementar versión en pubspec.yaml: `version: 1.0.0+11`
2. Compilar nuevo AAB: `flutter build appbundle --release`
3. Subir build 11 a Google Play Console → Prueba cerrada Alpha
4. Esperar aprobación de Google (~horas)
5. Pedir a un tester que actualice la app desde Play Store y pruebe Google Sign-In
6. Si funciona → crear tag `v3.3-firebase-sha-fix` (el tag actual apunta al commit con solo el SHA de subida, pero el fix real es el build 11)

### ⚠️ Nota importante sobre el tag v3.3
El tag `v3.3-firebase-sha-fix` ya fue creado y pusheado, pero apunta al commit que solo tenía el SHA de subida registrado. El fix real (SHA de firma de Google Play) está en el commit con el nuevo google-services.json. Considerar crear `v3.4-firebase-play-signing-sha-fix` después de confirmar que funciona.

---

## Firebase — Huellas SHA registradas (estado actual) ✅
En Firebase Console → HerEchoes → Configuración → HerEchoes Android:
1. `ee:ed:33:63:d9:1e:50:6b:96:5d:2a:8a:62:c2:3d:4d:f7:19:e8:e6:43:79:c7:28:55:38:ec:44:f9:01:8b:54` — SHA-256 keystore de subida
2. `62:db:13:b5:eb:32:22:cf:8a:6f:a1:2d:9d:7c:ac:32:d1:ce:00:f1:93:bf:6b:72:6f:ef:c4:17:8c:27:af:2e` — SHA-256 firma de Google Play ✅ agregado sesión 22

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
```
⚠️ Pendiente crear tag `v3.4-firebase-play-signing-sha-fix` después de confirmar que Google Sign-In funciona con build 11

---

## Pendientes

### URGENTE — Próximo paso inmediato
- [ ] Incrementar pubspec.yaml a `version: 1.0.0+11`
- [ ] Compilar AAB: `flutter build appbundle --release`
- [ ] Subir build 11 a Google Play Console → Prueba cerrada Alpha
- [ ] Esperar aprobación Google y pedir a testers que actualicen
- [ ] Confirmar que Google Sign-In funciona
- [ ] Crear tag `v3.4-firebase-play-signing-sha-fix`

### Media prioridad
- [ ] Crear imagen promocional 1024x1024px para suscripciones (fix guideline 2.3.2)
- [ ] Show All — márgenes laterales
- [ ] Prueba cerrada Google Play (12 testers activos, 14 días)
- [ ] Sandbox Tester separado para reviewer Apple
- [ ] Migrar her_echoes.json a carga remota desde GitHub
- [ ] Completar JSON julio → diciembre