# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-04-01 (sesión 19)

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
```

**versión actual pubspec:** `version: 1.0.0+9` (versionCode Android = 9)

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
│   │   ├── plan_type.dart
│   │   ├── plan_selection_screen.dart  ✅ sesión 16: precios desde RevenueCat
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
│       ├── legal_content_screen.dart   ✅ sesión 17: abre URL web directamente (Safari/Chrome)
│       ├── notifications_screen.dart   ✅ sesión 19: toggle fix (_requestPermission siempre retorna true en Android)
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/home_mini_card.dart, pro_badge.dart, wildcard_badge.dart
│   ├── modals/
│   │   ├── upsell_modal_free.dart  ✅ sesión 16: precios desde RevenueCat
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

## Android — Ajustes de diseño específicos ✅ sesión 18

### card_detail_screen.dart — `_buildBottomActions`
- **iOS:** padding `fromLTRB(24, 24, 24, 0)`, botones height 52px (AppButton default)
- **Android:** padding `fromLTRB(16, 16, 16, 24)`, botones wrapeados en `SizedBox(height: 48)`
- Implementado con `Platform.isAndroid` ✅
- ⚠️ PENDIENTE verificar visualmente en Redmi con AAB versionCode 9

---

## Fixes sesión 19 ✅

### 1. notifications_screen.dart — Toggle no cambiaba de estado en Android
- **Causa real:** MIUI (Redmi) reporta `false` en `requestNotificationsPermission()` aunque el usuario acepte
- **Fix:** En Android, `_requestPermission()` ahora siempre retorna `true` después de mostrar el diálogo — ignoramos el resultado de MIUI
- **También:** `setState` se mueve ANTES de `_scheduleDaily()` para que el toggle cambie visualmente aunque `zonedSchedule` falle
- **También:** Agregado `if (!mounted) return` para seguridad
- **También:** `_scheduleDaily` wrapped en try/catch

### 2. card_detail_screen.dart — "Reportar problema" no abría mail en Android
- **Causa:** Android 11+ bloquea `canLaunchUrl` con `mailto:` si no hay `<queries>` en AndroidManifest
- **Fix 1:** `launchUrl(uri, mode: LaunchMode.externalApplication)` directo sin `canLaunchUrl`
- **Fix 2:** Si falla, muestra AlertDialog con el email copiable
- **Fix 3:** Agregado en `AndroidManifest.xml`:
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="mailto" />
  </intent>
</queries>
```
- **También:** `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` en AndroidManifest

### 3. main.dart — RevenueCat Android configurado
- **Fix:** `_initRevenueCat()` ahora incluye rama `Platform.isAndroid`
- **API Key Android:** `goog_chSzVTtDJfNcfIfRHepJqITjste`
- Antes retornaba sin configurar en Android → sin esto los precios no aparecen

---

## Modelo de Negocio IAP ✅ sesión 16 + sesión 19

### Productos ACTIVOS (anuales)
| Nombre | Product ID iOS | Product ID Android | Precio USD | Duración | Trial |
|---|---|---|---|---|---|
| Individual Anual | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual` | $8.99 | 1 año | No |
| Trial Anual | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual` | $12.99 | 1 año | 7 días gratis |
| Familiar Anual | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual` | $14.99 | 1 año | No |

⚠️ **IMPORTANTE:** Los Product IDs de Android son diferentes a los de iOS (más cortos). Esto es normal — RevenueCat los mapea por separado en cada plataforma.

### Productos RETIRADOS (mensuales)
| Nombre | Product ID | Estado |
|---|---|---|
| Individual Mensual | `cl.callmehector.herechoes.individual` | Retirado |
| Familiar Mensual | `cl.callmehector.herechoes.familiar` | Retirado |
| Trial Mensual | `cl.callmehector.herechoes.trial` | Retirado |

---

## RevenueCat

### iOS ✅
- **API Key iOS:** `appl_KDuVwOmljiRmgUegeqjadtfAjRA`
- Entitlement: `pro`, Offering: `default`
- Estado: ✅ Valid credentials

### Android ⚠️ PARCIALMENTE CONFIGURADO
- **API Key Android:** `goog_chSzVTtDJfNcfIfRHepJqITjste` ✅ agregada en main.dart
- **App Play Store creada en RevenueCat:** `HerEchoes (Play Store)` ✅
- **Package name:** `cl.callmehector.herechoes` ✅
- **Service Account JSON:** subido ✅ (archivo: `herechoes-dca3d-d4b6c8a89bdb.json`)
- **Estado credentials:** ⚠️ "Credentials need attention" — falta propagación de permisos Google (24-48h)
    - ✅ Permissions to call subscriptions API
    - ⚠️ Could not validate inappproducts API permissions
    - ⚠️ Could not validate monetization API permissions
- **Productos Android en Google Play Console:** ✅ creados (ver tabla arriba)

### Qué falta para que RevenueCat Android funcione completamente:
1. ⏳ Esperar 24-48h a que Google propague los permisos de la cuenta de servicio
2. Volver a RevenueCat → HerEchoes (Play Store) → hacer click en 🔄 junto a "Credentials need attention"
3. Verificar que los 3 checks queden en verde
4. Agregar los productos Android en RevenueCat → Product catalog → Products → New product
5. Mapearlos al offering `default` igual que iOS

### Configuración Google Cloud / Google Play para RevenueCat
- **Proyecto Google Cloud:** HerEchoes (`herechoes-dca3d`)
- **API habilitada:** Google Play Android Developer API ✅
- **Service Account creada:** `revenuecat-android@herechoes-dca3d.iam.gserviceaccount.com` ✅
- **Rol asignado:** Editor ✅
- **Invitada en Google Play Console con permisos:** ✅
    - Ver datos financieros, pedidos y respuestas a encuestas de cancelación ✅
    - Gestionar pedidos y suscripciones ✅
    - Gestionar presencia en Play Store ✅

### Packages (offering: default)
| Identifier | Producto iOS | Producto Android |
|---|---|---|
| `individual` | `cl.callmehector.herechoes.individual.annual` | `cl.herechoes.individual.annual` (⚠️ pendiente mapear en RC) |
| `trial` | `cl.callmehector.herechoes.trial.annual` | `cl.herechoes.trial.annual` (⚠️ pendiente mapear en RC) |
| `familiar` | `cl.callmehector.herechoes.familiar.annual` | `cl.herechoes.familiar.annual` (⚠️ pendiente mapear en RC) |

---

## App Store Connect ✅

### Builds iOS
| Build | Fecha | Estado |
|---|---|---|
| 1.0.0 (1) | 18-03-2026 | Rechazado — Guideline 2.1(b) |
| 1.0.0 (2) | 21-03-2026 | En TestFlight |
| 1.0.0 (3) | 27-03-2026 | Finalizado |
| 1.0.0 (4) | 28-03-2026 | Finalizado |
| 1.0.0 (5) | 28-03-2026 | ⏳ En revisión Apple |

⚠️ Build 6 (iOS) está commiteado en git pero NO subido. Esperar respuesta Apple al build 5.
Si Apple rechaza build 5, subir build 6 que incluye: legal_content fix + notifications Android fix + login URLs fix.

### Sandbox Tester
- Email: `valar.disghulis@gmail.com` — País: Chile

### Internal Testers TestFlight
- `1.61803haz@gmail.com`
- `hector@callmehector.cl`

---

## Google Play Console ✅ sesión 19

### Estado general
- App: **Her Echoes** — `cl.callmehector.herechoes`
- Categoría: Educación
- Ficha Play Store: ✅ configurada

### Cuenta de comercio Google Payments ✅ sesión 19
- Perfil configurado como particular: Héctor Astete Zúñiga
- Información fiscal Chile: ✅ Aceptada (Particular, sin IVA, RUN: 147291671)
- Información fiscal USA (W-8BEN): ✅ completada
- Banco para pagos: ✅ cuenta ---- 519

### Prueba interna
- Canal: **Activo**
- Última versión subida: **9 (1.0.0)** ⏳ pendiente subir
- Versión 8 compilada y lista en `build/app/outputs/bundle/release/app-release.aab`

### Para subir AAB versionCode 9 (PRÓXIMO PASO):
```bash
# Ya está compilado — solo subir
open build/app/outputs/bundle/release/
# Arrastrar app-release.aab a:
# Google Play Console → Her Echoes → Probar y publicar → Prueba interna → Crear nueva versión
```

### Historial AABs
| versionCode | Estado |
|---|---|
| 1 | Bug MainActivity (com.example) |
| 2 | Bug MainActivity (com.example) |
| 3 | Bug MainActivity (com.example) |
| 4 | Subido — fix MainActivity + lazy loading + button fix |
| 5 | No subido (saltado) |
| 6 | No subido (saltado) |
| 7 | No subido (saltado) |
| 8 | Compilado ✅ — fix notifications toggle + mailto Android + RevenueCat Android API key |
| 9 | ⏳ pendiente subir |

⚠️ Nota: el pubspec quedó en `1.0.0+9` pero el AAB compilado es el de versionCode 9. Verificar antes de subir.

### Tester interno
- Email: `01010.herechoes@gmail.com` (Lista testers 001)
- Enlace: `https://play.google.com/apps/internaltest/4700587...`

### Prueba cerrada (OBLIGATORIA para producción)
- Requiere: 12 testers + 14 días activos
- Estado: ⏳ pendiente — esperar prueba interna funcionando

---

## Android — Debugging WiFi
```bash
# Activar: Ajustes → Opciones de desarrollador → Depuración inalámbrica
# Vincular (si es primera vez o caducó):
~/Library/Android/sdk/platform-tools/adb pair IP:PUERTO CODIGO
# Conectar:
~/Library/Android/sdk/platform-tools/adb connect IP:PUERTO
# Correr en vivo (más rápido para probar):
flutter run --device-id IP:PUERTO
# Ver logs de crash:
~/Library/Android/sdk/platform-tools/adb -s IP:PUERTO logcat | grep -E "FATAL|Flutter|Exception"
```
**Redmi A2:** Android 13 (API 33), armeabi-v7a, IP típica: 192.168.1.166

---

## her_echoes.json ✅ sesión 17
- Cargado desde **assets locales** — cualquier cambio requiere nuevo build
- Total: 263 entradas
- Cobertura: marzo, abril, casi todo mayo
- ⚠️ Pendiente: completar mayo, junio→diciembre

---

## Wildcard ✅
- Se carga desde **GitHub en tiempo real** — NO requiere nuevo build
- ⚠️ Token GitHub `herechoes-wildcard` expira **Apr 11 2026** — renovar URGENTE (quedan ~10 días)

---

## Códigos promocionales (influencers)
- Usar **Códigos promocionales de Apple** (ASC → Monetización → Códigos promocionales)
- Google Play tiene sistema equivalente
- Los códigos los genera Apple/Google (no son personalizables)
- Máximo 100 códigos por versión en Apple

---

## URLs
```
Imágenes:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
Wildcard:    https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
Panel admin: https://callmehector.cl/apps/herechoes/wildcard.php
Cupones:     https://callmehector.cl/apps/herechoes/coupons.php
Privacidad:  https://callmehector.cl/apps/herechoes/privacy.html
Términos:    https://callmehector.cl/apps/herechoes/terms.html
```

---

## Keystores y SHA
- **Producción Android:** `~/herechoes-release.jks`, alias: `herechoes`
- `android/key.properties` configurado y en `.gitignore` ✅
- **SHA-1 debug:** `3B:41:83:A1:3E:9F:35:6C:09:FF:7B:06:7D:31:45:93:2E:67:23:3F`

---

## Git Tags
```
v2.6-iap-annual-fix      ✅
v2.7-json-fix            ✅
v2.8-login-links-fix     ✅
v2.9-android-legal-fixes ✅
⚠️ Pendiente tagear sesión 19: v3.0-android-revenuecat-setup
```

---

## Pendientes

### URGENTE
- [ ] ⚠️ Token GitHub expira **Apr 11 2026** — renovar YA (quedan ~10 días)
- [ ] Esperar respuesta Apple al build 5 (iOS en revisión)
- [ ] Subir AAB versionCode 9 a Google Play Console → Prueba interna

### Mañana (después de 24-48h) — RevenueCat Android
1. Entrar a RevenueCat → Apps & providers → Configurations → HerEchoes (Play Store)
2. Hacer click en 🔄 junto a "Credentials need attention"
3. Verificar que los 3 checks queden en verde (especialmente inappproducts y monetization)
4. Si queda verde → ir a Product catalog → Products → agregar los 3 productos Android:
    - `cl.herechoes.individual.annual`
    - `cl.herechoes.trial.annual`
    - `cl.herechoes.familiar.annual`
5. Mapearlos al offering `default` con los mismos identifiers que iOS (`individual`, `trial`, `familiar`)
6. Verificar en Redmi que el modal upsell muestra precios

### Próxima sesión — Android
1. Subir AAB versionCode 9 a Google Play Console
2. Instalar en Redmi y verificar:
    - Sin crash al abrir
    - Toggle de notificaciones funciona
    - "Reportar problema" abre mail o muestra email copiable
    - Modal upsell muestra precios (requiere RevenueCat Android funcionando)
    - Diseño botones card_detail correcto
3. Completar configuración RevenueCat Android (ver pasos arriba)
4. Tagear: `git tag v3.0-android-revenuecat-setup`

### Próxima sesión — iOS
- Si Apple aprueba build 5 → publicar 🎉
- Si Apple rechaza → subir build 6 (ya commiteado en git)

### Media prioridad
- [ ] Show All — márgenes laterales
- [ ] Completar her_echoes.json (mayo→diciembre)
- [ ] Prueba cerrada Google Play (12 testers, 14 días)
- [ ] Crear Sandbox Tester separado para reviewer Apple