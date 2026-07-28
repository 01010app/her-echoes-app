# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-07-01 (sesión 27)

---

## 🔴 SESIÓN 27 — Bug crítico de fechas, duplicados fantasma, y fix permanente de versionado Xcode

### Contexto del bug original
El 1 de julio de 2026, la app mostraba SOLO contenido bloqueado (PRO) para todos los usuarios FREE, sin ninguna mujer libre ese día. Root cause: **el filtro de fecha en `main.dart` armaba la clave del día en formato DD/MM, pero el dataset real usa MM/DD**. Como nunca hacía match, `todaysWomen` quedaba vacío y el motor de sugerencias caía a un fallback aleatorio sin garantía de contenido libre.

### Fix aplicado en `lib/main.dart`
```dart
// ANTES (incorrecto — generaba DD/MM):
final todayKey = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}";

// AHORA (correcto — coincide con el formato real del dataset MM/DD):
final todayKey = "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
```
⚠️ **Este fix es definitivo y no debe revertirse.** El dataset completo usa MM/DD como formato canónico (confirmado por auditoría exhaustiva, ver abajo).

### ⚠️ Descubrimiento mayor: el dataset tenía fechas mezcladas en 2 formatos
Auditoría completa de las 520 entradas de `her_echoes.json` reveló que un bloque completo (~mayo-junio) estaba cargado en DD/MM mientras el resto (marzo, abril, julio) estaba en MM/DD. Esto significaba que decenas de mujeres NUNCA aparecían en su día real correcto.

**Metodología de corrección (no repetir a mano — usar scripts):**
1. Se extrajo la fecha real de cada entrada desde el texto `on_this_date_en` (fechas completas con mes en inglés + año, validadas contra `past_date`).
2. Se usó la posición secuencial del archivo (ordenado cronológicamente desde 1 de marzo) como respaldo cuando el texto no traía fecha explícita.
3. Solo se corrigió cuando había evidencia de alta confianza — nunca se adivinó.

**Resultado: 108 entradas corregidas de DD/MM → MM/DD.** El dataset completo (`assets/data/her_echoes.json`) ya está normalizado y pusheado a GitHub.

### Duplicados fantasma encontrados y eliminados
El proceso de auditoría destapó registros duplicados (mismo `woman_id`, mismo evento real, fecha mal cargada dos veces):

| Mujer | Acción | Detalle |
|---|---|---|
| George Sand | ✅ Eliminado 1 duplicado | 3 copias → 2 legítimas (nacimiento 07/01, muerte 14/05) |
| Amy Johnson | ✅ Eliminado 1 duplicado | Copia fantasma en 07/07 con fecha incorrecta |
| Sally Ride | ✅ Eliminado 1 duplicado | Copia en 13/06 con fecha errónea (evento real: 18 junio 1983) |
| Queen Victoria | ✅ Eliminado 1 duplicado | Redundancia exacta, mismo día 24/05 |
| Emmy Noether | ✅ Eliminado 1 duplicado | Copia con fecha mal puesta (25/05), se conservó la correcta (23/03) |
| Barbara McClintock | ✅ **Reemplazada, no eliminada** | Tenía 2 copias en días distintos (04/08 y 06/02) sin forma de saber cuál estaba mal. Se conservó la de 06/02 (fuente Nobel Prize) y **la entrada de 04/08 fue reemplazada por Betty Ford** (verificada con fuentes reales: Britannica, White House Historical Association) para no dejar ningún día con menos de 3 mujeres. |

⚠️ **Regla aprendida (crítica):** nunca borrar un registro sin verificar antes cuántas entradas quedan ese día — cada día debe tener mínimo 3 (1 VERDADERO + 2 FALSO como mínimo deseable). Si al borrar un duplicado un día queda con menos de 3, hay que **reemplazar** el registro completo por una mujer nueva verificada, no solo borrar.

### Nuevo registro agregado: Betty Ford
- `woman_id: betty_ford_01`, `event_date: 04/08`, `image_card_ID: ford_betty_01`
- Primera dama de EE.UU., pionera en visibilizar el cáncer de mama, fundadora del Betty Ford Center
- Fuentes: Britannica, White House Historical Association
- Imagen ya subida a `images/cards/ford_betty_01.webp`

### Pendiente de próxima sesión
Solo se auditó formato de fecha con alta confianza (texto + posición). **No se revisó exhaustivamente el resto del dataset en busca de MÁS duplicados fantasma más allá de los 6 casos encontrados** (la auditoría de duplicados se hizo por `woman_id` + `past_date` repetido, cubre todo el archivo, pero vale la pena una segunda pasada si aparecen más síntomas raros).

---

## 🔴 SESIÓN 27 — Bug de versionado Xcode (CAUSA RAÍZ RESUELTA DE FORMA PERMANENTE)

### El problema recurrente
Cada vez que se subía un build nuevo, cambiar `pubspec.yaml` no tenía efecto real — Apple seguía rechazando o mostrando el build number/versión antigua. Esto pasó de nuevo en sesión 27 y quedó resuelto de raíz.

### Causa real
En algún momento anterior, alguien escribió a mano en Xcode (o editó directo el proyecto) los valores de versión, **hardcodeándolos como números fijos** en vez de dejar que Flutter los inyecte automáticamente desde `pubspec.yaml`. Esto rompía el pipeline normal de versionado de Flutter.

Archivos afectados:
- `ios/Runner.xcodeproj/project.pbxproj` → `CURRENT_PROJECT_VERSION = 13;` y `MARKETING_VERSION = 1.0;` (fijos, en 9 líneas distintas — 3 build configs × 2 targets + variantes)
- `ios/Runner/Info.plist` → `CFBundleVersion` tenía `<string>14</string>` fijo (mientras `CFBundleShortVersionString` sí usaba la variable correctamente)

### Fix aplicado (PERMANENTE — no debería volver a pasar)
```bash
# En project.pbxproj — reemplazar valores fijos por variables (con comillas, obligatorio por el formato pbxproj):
sed -i '' 's/CURRENT_PROJECT_VERSION = 13;/CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";/g' ios/Runner.xcodeproj/project.pbxproj
sed -i '' 's/MARKETING_VERSION = 1.0;/MARKETING_VERSION = "$(FLUTTER_BUILD_NAME)";/g' ios/Runner.xcodeproj/project.pbxproj

# En Info.plist — igual, reemplazar el número fijo:
sed -i '' 's/<string>14<\/string>/<string>$(FLUTTER_BUILD_NUMBER)<\/string>/' ios/Runner/Info.plist
```

**Validación después del fix:**
```bash
plutil -lint ios/Runner/Info.plist                    # debe decir OK
xcodebuild -list -project ios/Runner.xcodeproj         # debe listar targets sin error
```

✅ Con este fix, de ahora en adelante **solo se debe tocar `pubspec.yaml`** para cambiar de versión. Nunca más hay que editar Xcode manualmente para esto. Si en el futuro este bug reaparece (por ejemplo si alguien vuelve a hardcodear un valor en Xcode UI), repetir exactamente este mismo procedimiento.

⚠️ Si `sed` falla o corrompe `project.pbxproj` (formato JSON-like sensible a sintaxis), usar `git checkout ios/Runner.xcodeproj/project.pbxproj` para revertir antes de reintentar, y SIEMPRE usar comillas alrededor de `$(VARIABLE)` en reemplazos de pbxproj.

---

## GitHub — Identidad y Configuración ✅ sesión 25

### Cuenta activa para este proyecto
- **GitHub account:** `01010app`
- **Email GitHub:** `01010dev.app@gmail.com`
- **Git global config (Mac):**
```bash
git config --global user.name "01010app"
git config --global user.email "01010dev.app@gmail.com"
```

### ⚠️ Segunda cuenta — NO usar para este proyecto
- **GitHub account:** `ValarDisghulis`
- **Email:** `hector@callmehector.cl`
- **Uso:** solo para trabajo/organización Meedika. No tiene repos propios.
- **Importante:** si el git config global apunta a este email, los commits aparecen como "ghost" en 01010app.

### Repositorio
- **URL:** `https://github.com/01010app/her-echoes-app.git`
- **Visibilidad:** Public
- **Branch:** `main`

### Verificar identidad antes de cada sesión
```bash
git config --global user.name
git config --global user.email
# Debe mostrar: 01010app / 01010dev.app@gmail.com
```

### ⚠️ Regla aprendida sesión 27 — no dejar imágenes/commits sin subir
En sesión 27 se encontraron ~100 imágenes locales (`images/cards/`) sin subir a GitHub desde hacía ~1 mes, causando cards rotas/borrosas en producción para todo el contenido nuevo. **Hacer `git push` con frecuencia, no acumular cambios locales por semanas.**

---

## Ubicación del proyecto
```
~/herechoes/
```
⚠️ NO está en `~/hector-studio/apps/` — está directamente en el home.

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
- **`event_date` en her_echoes.json:** SIEMPRE formato **MM/DD** (ej. "07/01" = 1 de julio). Confirmado y normalizado en sesión 27 tras auditoría completa. `main.dart` genera la clave del día en este mismo formato — si algún script o carga futura usa DD/MM, romperá el filtro diario.
- **Versionado iOS:** SIEMPRE editar SOLO `pubspec.yaml` (`version: X.X.X+N`). NUNCA tocar `CURRENT_PROJECT_VERSION`, `MARKETING_VERSION` en Xcode ni `CFBundleVersion` en Info.plist a mano — deben quedar siempre como variables `$(FLUTTER_BUILD_NUMBER)` / `$(FLUTTER_BUILD_NAME)` (fix permanente aplicado sesión 27).

---

## Bundle ID ✅ sesión 13
`cl.callmehector.herechoes`
- Registrado en Apple Developer
- Configurado en Xcode → Runner → Signing & Capabilities
- Team: Héctor Astete (7H4G6LP6K5)

---

## Versiones ✅ sesión 27

| Versión | Build | Estado | Fecha |
|---------|-------|--------|-------|
| 1.0.0 | 13 | ✅ Live en App Store | mayo 2026 |
| 1.0.1 | 14 | ✅ Aprobado y Live en App Store | mayo 2026 |
| 1.0.2 | 16 | 🟡 Enviado a revisión | 1 julio 2026 |

**pubspec.yaml actual:** `version: 1.0.2+16`

### Contenido del build 1.0.2 (16)
- Fix crítico: filtro de fecha diario (MM/DD)
- 108 correcciones de formato de fecha en el dataset
- 6 duplicados fantasma eliminados/reemplazados
- Nuevo registro: Betty Ford (04/08)
- ~100 imágenes nuevas subidas a GitHub (`images/cards/`)
- Botón del modal de actualización corregido (`AppButton` en vez de `ElevatedButton`)
- Fix permanente de versionado Xcode (ver sección arriba)

### ⚠️ Regla crítica para nuevos builds
Cuando una versión YA está aprobada en App Store, Apple NO acepta nuevos builds con el mismo número de versión marketing. Se debe incrementar AMBOS:
- **Versión marketing:** ej. 1.0.1 → 1.0.2 (en pubspec.yaml: parte antes del +)
- **Build number:** ej. +15 → +16 (en pubspec.yaml: parte después del +)

Si solo subes el build number sin cambiar la versión marketing, Apple rechaza con:
`"The train version X.X.X is closed for new build submissions"`

**Verificar SIEMPRE antes de `flutter build ipa`** que el log final de "App Settings Validation" muestre el Version Number y Build Number correctos — si no coinciden con pubspec.yaml, hay un valor hardcodeado en Xcode (ver sección de fix permanente arriba).

---

## Dependencias activas (pubspec.yaml)
```yaml
cupertino_icons: ^1.0.8
google_fonts: ^6.2.1
phosphor_flutter: ^2.0.1
superellipse_shape: ^0.2.0
flutter_svg: ^2.0.7
vertical_card_pager: ^1.6.3
card_stack_widget: ^0.1.6
provider: ^6.1.2
shared_preferences: ^2.2.2
http: ^1.2.1
share_plus: ^12.0.0
path_provider: ^2.1.4
flutter_local_notifications: ^18.0.1
timezone: ^0.9.4
url_launcher: ^6.3.1
purchases_flutter: ^9.14.0
sign_in_with_apple: ^7.0.1
firebase_core: ^4.5.0
google_sign_in: ^6.2.1
webview_flutter: ^4.13.1
package_info_plus: ^9.0.1   ← agregado sesión 26
```

---

## Servicios — UpdateService (`lib/services/update_service.dart`)
- Consulta iTunes API con bundle ID `cl.callmehector.herechoes`
- Compara versión instalada vs App Store usando `package_info_plus`
- Si hay versión nueva → muestra dialog con botón "Actualizar ahora"
- Botón abre App Store directo (App ID: `6760677188`)
- Solo se ejecuta en iOS (⚠️ pendiente: no cubre Android, ver Pendientes)
- Llamado desde `home_screen.dart` en `addPostFrameCallback`
- Emoji del dialog: 🚀
- ✅ sesión 27: botón corregido a `AppButton` (antes usaba `ElevatedButton`, violaba regla de arquitectura)

### Integración en home_screen.dart
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _checkSettingsNotification();
  _checkWeeklyProUpsell();
  final isEnglish = context.read<LanguageProvider>().isEnglish;
  UpdateService.checkAndPrompt(context, isEnglish: isEnglish);
});
```

---

## Estructura de Archivos
```
lib/
├── core/
│   ├── favorites_provider.dart
│   ├── language_provider.dart
│   ├── currency_provider.dart      ⚠️ YA NO se usa para precios de IAP
│   ├── subscription_provider.dart  ✅ RevenueCat real
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
│   │   ├── plan_selection_screen.dart
│   │   ├── plan_detail_screen.dart
│   │   ├── add_card_screen.dart        ⚠️ ya no se usa
│   │   ├── payment_screen.dart         ⚠️ ya no se usa
│   │   └── payment_method_screen.dart  ⚠️ ya no se usa
│   ├── home/home_screen.dart           ✅ UpdateService integrado sesión 26
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
│   ├── modals/
│   │   ├── upsell_modal_free.dart
│   │   └── upsell_modal_pro.dart
│   ├── navigation/floating_tab_bar.dart
│   ├── system/app_button.dart
│   └── settings/settings_divider, container, item, section_title
├── services/
│   ├── daily_suggestions_engine.dart   ⚠️ NO filtra fecha — recibe todaysWomen ya filtrado
│   └── update_service.dart
└── main.dart                            ✅ AQUÍ vive el filtro real de event_date (sesión 27)
```

⚠️ **Nota de arquitectura descubierta en sesión 27:** el filtro por fecha del día NO está en `daily_suggestions_engine.dart` (que solo arma sugerencias a partir de una lista ya filtrada) ni en `content_service.dart` (que solo carga `legal_content.json`). Vive directo en `main.dart`, dentro de `_MyAppState.build()`, calculando `todayKey` y filtrando `allWomen`.

---

## Android — Estructura de archivos crítica
```
android/app/src/main/kotlin/
├── cl/callmehector/herechoes/
│   └── MainActivity.kt   ✅ package correcto — usar este
└── com/example/herechoes/
    └── MainActivity.kt   ⚠️ legacy — NO eliminar pero ignorar
```

---

## Android — Ajustes de diseño específicos
- **card_detail_screen.dart:** iOS padding `fromLTRB(24,24,24,0)` / Android `fromLTRB(16,16,16,24)`
- **floating_tab_bar.dart:** iOS `bottom: 24` / Android gestos `bottom: 24` / Android HyperOS `bottom: viewPadding.bottom + 8`

---

## Modelo de Negocio IAP

### Productos ACTIVOS (anuales)
| Nombre | Product ID iOS | Product ID Android | Precio USD |
|---|---|---|---|
| Individual Anual | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual` | $8.99 |
| Trial Anual | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual` | $12.99 |
| Familiar Anual | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual` | $14.99 |

---

## RevenueCat
- **API Key iOS:** `appl_KDuVwOmljiRmgUegeqjadtfAjRA`
- **API Key Android:** `goog_chSzVTtDJfNcfIfRHepJqITjste`
- Entitlement: `pro`, Offering: `default`

---

## Google Play Console
- App: `cl.callmehector.herechoes`
- Prueba cerrada Alpha: build 13 ✅
- Testers: 12 aceptados ✅ — contador: 11 días (necesita 14 días corridos)
- Acceso producción: disponible ~21 mayo 2026 (verificar estado actual, no confirmado en sesión 27)

---

## Firebase — SHA registradas
1. SHA-256 keystore subida: `ee:ed:33:...`
2. SHA-256 firma Google Play: `62:db:13:...`

---

## Android — Debugging WiFi
```bash
~/Library/Android/sdk/platform-tools/adb pair IP:PUERTO CODIGO
~/Library/Android/sdk/platform-tools/adb connect IP:PUERTO
flutter run --device-id IP:PUERTO
```
**Redmi A2:** Android 13, armeabi-v7a

---

## URLs
```
Imágenes:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
Wildcard:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
Panel admin: https://callmehector.cl/apps/herechoes/wildcard.php
Privacidad:  https://callmehector.cl/apps/herechoes/privacidad.html
Términos:    https://callmehector.cl/apps/herechoes/terminos.html
App Store:   App ID 6760677188
```

---

## Keystores
- **Producción Android:** `~/herechoes-release.jks`, alias: `herechoes`
- `android/key.properties` configurado y en `.gitignore` ✅

---

## Git Tags
```
v3.3-firebase-sha-fix            ✅
v3.4-legal-links-nav-fix         ✅
v3.5-android-nav-fix             ✅ build 13 — versión App Store aprobada
```

---

## Historial de rechazos/envíos Apple
- Build 5: metadata issues
- Build 10: RevenueCat production key faltante
- Build 11: video con device frame, logo-pro con texto pequeño
- Build 12: IAP unresponsive
- Build 13: ✅ APROBADO — legal screen interno, links en modales
- Build 14: ✅ APROBADO — en distribución
- Build 16 (v1.0.2): 🟡 Enviado a revisión 1 julio 2026 — primer intento falló por versión marketing sin incrementar (error 409 "train version closed"), corregido y reenviado

---

## Pendientes

### URGENTE
- [ ] Confirmar aprobación del build 1.0.2 (16) en App Store Connect
- [ ] Verificar estado actual de prueba cerrada Google Play (última info de sesión 26 indicaba ~21 mayo 2026, no confirmado desde entonces)

### Media prioridad
- [ ] Completar JSON julio → diciembre
- [ ] Segunda pasada de auditoría de duplicados fantasma en todo el dataset (solo se encontraron 6 casos por síntoma, podría haber más)
- [ ] UpdateService: agregar soporte Android (actualmente `if (!Platform.isIOS) return;` bloquea todo el flujo en Android)
- [ ] Push notifications (Firebase Cloud Messaging) — postergado
- [ ] Show All — agregar selector de meses
- [ ] Show All — márgenes laterales
- [ ] Migrar her_echoes.json a carga remota desde GitHub (evitar builds por contenido) — **más urgente ahora**, ya que cada corrección de dato (como la de hoy) requiere build + revisión de Apple
- [ ] Verificación de desarrolladores Android (plazo: septiembre 2026)
- [ ] Launch image de iOS sigue en placeholder default (warning no bloqueante en cada build, pendiente de reemplazar)


---

## 🃏 WILDCARD — Historial de personajes

- **Activo hasta 2026-07-22:** Jewel — respaldado en `wildcard_archive/jewel_20260722.json`
- **Activo desde 2026-07-22:** [pendiente — nombre nueva mujer]

### Cómo restaurar un wildcard anterior
```bash
cp wildcard_archive/[archivo].json assets/data/wildcard.json
git add assets/data/wildcard.json
git commit -m "content: restore wildcard → [nombre]"
git push origin main
```