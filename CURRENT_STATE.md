# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-12 (sesión 7)

---

## Stack y Reglas de Arquitectura

- **Base width:** 393px (iPhone 15 Pro)
- **Fonts:** Google Fonts — Inter (UI), Gloock (títulos/nombres)
- **Icons:** Phosphor — SIEMPRE `PhosphorIcon(PhosphorIcons.name(style))`, NUNCA `Icon(...)`
- **Background scaffolds:** SIEMPRE `Color(0xFFF5F5F5)` / `AppColors.background` — NUNCA blanco
- **Accent:** `#F70F3D` / `Color(0xFFE1002D)`
- **State management:** Provider
- **Persistencia:** SharedPreferences (favoritos aún en memoria; onboarding_done ✅ conectado)
- **NUNCA refactorizar layouts que funcionan**
- **Spinners:** SIEMPRE `CircularProgressIndicator(color: Color(0xFFE1002D))`
- **Cursor en TextFields:** SIEMPRE `Color(0xFFF70F3D)`
- **Botones CTA:** SIEMPRE `AppButton` — NUNCA `ElevatedButton` / `OutlinedButton`
- **Botones CTA posición:** SIEMPRE `bottom: bottomPadding + 16`
- **Tabs (ej. Biografía/Legado):** SIEMPRE `Material + InkWell`, NUNCA `GestureDetector` solo

---

## Widget Sistema: `AppButton`
**Ruta:** `lib/widgets/system/app_button.dart`
```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;  // null → gris #949494, siempre hay ripple
  final bool isOutlined;          // default: false
  final double? width;            // default: double.infinity
}
```

- Rojo sólido `#E1002D` cuando enabled, gris `#949494` cuando null
- `isOutlined: true` → borde rojo, fondo transparente
- `onTap: () => onPressed?.call()` — ripple siempre activo aunque onPressed sea null
- elevation: 2 con shadowColor rojo 25% cuando enabled
- height: 52

**Reglas de import por ubicación:**
```
lib/screens/*/         → '../../widgets/system/app_button.dart'
lib/widgets/modals/    → '../system/app_button.dart'
lib/widgets/*/         → '../system/app_button.dart'
```

---

## Estructura de Archivos
```
lib/
├── core/
│   ├── favorites_provider.dart
│   ├── language_provider.dart
│   ├── subscription_provider.dart
│   └── theme/
│       └── app_colors.dart
├── screens/
│   ├── card_detail/
│   │   └── card_detail_screen.dart       ✅ sesión 7: idioma tags/quote/bio
│   ├── favorites/
│   │   └── favorites_screen.dart
│   ├── login/
│   │   ├── login_screen.dart             ✅ sesión 7: wildcards propagado
│   │   ├── onboarding_screen.dart        ✅ sesión 7: wildcards propagado
│   │   ├── email_login_screen.dart       ✅ sesión 7: wildcards propagado
│   │   ├── forgot_password_screen.dart
│   │   └── onboarding_name_screen.dart   ✅ sesión 7: wildcards propagado
│   ├── payment/
│   │   ├── plan_type.dart                ✅ sesión 7: enum PlanType separado
│   │   ├── payment_screen.dart
│   │   ├── plan_selection_screen.dart
│   │   ├── add_card_screen.dart
│   │   ├── payment_method_screen.dart
│   │   └── plan_detail_screen.dart
│   ├── home/
│   │   └── home_screen.dart              ✅ sesión 7: wildcards + isWildcard en carrusel
│   ├── daily_echo/
│   │   └── daily_echo_screen.dart        ✅ sesión 7: wildcards primero, badge Especial
│   └── settings/
│       ├── settings_screen.dart
│       ├── legal_content_screen.dart
│       ├── notifications_screen.dart
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/
│   │   ├── home_mini_card.dart           ✅ sesión 7: isWildcard + WildcardBadge
│   │   ├── pro_badge.dart
│   │   └── wildcard_badge.dart           ✅ sesión 7: NUEVO
│   ├── modals/
│   │   ├── upsell_modal_free.dart
│   │   └── upsell_modal_pro.dart
│   ├── navigation/
│   │   └── floating_tab_bar.dart
│   ├── system/
│   │   └── app_button.dart
│   └── settings/
│       ├── settings_divider.dart
│       ├── settings_list_container.dart
│       ├── settings_list_item.dart
│       └── settings_section_title.dart
└── services/
    └── daily_suggestions_engine.dart     ✅ sesión 7: parámetro wildcards agregado

assets/
├── data/
│   ├── her_echoes.json
│   └── wildcard.json                     ✅ sesión 7: NUEVO (array vacío por defecto)
├── images/
│   ├── home/
│   ├── system/
│   │   ├── login/
│   │   │   ├── logo-white.svg
│   │   │   ├── icon_Apple.svg
│   │   │   ├── icon_Google-color.svg
│   │   │   └── icon_email.svg
│   │   └── bg-pattern.png
│   └── onboarding/
│       ├── 01en.png / 01es.png
│       ├── 02en.png / 02es.png
│       ├── 03en.png / 03es.png
│       └── 04en.png / 04es.png
└── content/
    └── legal_content.json
```

**pubspec.yaml assets declarados:**
```yaml
assets:
  - assets/data/her_echoes.json
  - assets/data/wildcard.json
  - assets/images/home/
  - assets/images/system/
  - assets/images/system/login/
  - assets/content/legal_content.json
  - assets/images/system/bg-pattern.png
  - assets/images/onboarding/
```

---

## Wildcard — Sistema completo (sesión 7)

### Concepto
- JSON separado `assets/data/wildcard.json` — mismo formato que `her_echoes.json` pero sin `event_date`
- Cuando el array tiene entradas → aparece en posición 0 del carrusel Home y al inicio de Daily Echo
- Cuando está vacío `[]` → no se muestra en ningún lado
- Las wildcards se marcan internamente con `_is_wildcard: true` al procesarlas

### Badge `WildcardBadge`
**Ruta:** `lib/widgets/cards/wildcard_badge.dart`
- Fondo: `Color(0xFF28A52A).withOpacity(0.85)`
- Ícono: `PhosphorIcons.shootingStar(PhosphorIconsStyle.fill)`, size 12, blanco
- Texto: "Especial" (ES) / "Special" (EN), Inter medium 10px, blanco
- Posición en HomeMiniCard: esquina superior **izquierda** (top:8, left:8)
- Posición en DailyEchoScreen: esquina superior **izquierda** (top:16, left:16)
- Se muestra **siempre**, sea usuario FREE o PRO

### Propagación de wildcards (cadena completa)
```
main.dart
  loadJson() → carga wildcard.json → List<Map> wildcards
  DailySuggestionsEngine.generateSuggestions(wildcards: wildcards)
  → LoginScreen(wildcards: wildcards)
    → HomeScreen(wildcards: wildcards)           ← vía "Continuar como invitado"
    → EmailLoginScreen(wildcards: wildcards)
      → OnboardingNameScreen(wildcards: wildcards)
        → HomeScreen(wildcards: wildcards)
  → OnboardingScreen(wildcards: wildcards)       ← primera vez
    → LoginScreen(wildcards: wildcards)
```

### DailySuggestionsEngine
- Nuevo parámetro: `List<Map<String, dynamic>> wildcards = const []`
- Wildcards se insertan en posición 0 con `_is_wildcard: true`
- Luego: hasta 3 mujeres del día + hasta 7 relacionadas por tag

### HomeMiniCard
- Nuevo parámetro: `bool isWildcard = false`
- Si `isWildcard`: muestra `WildcardBadge` en top-left
- Si `isWildcard`: NO muestra botón favorito (aunque usuario sea PRO)
- PRO badge y favorito siguen en top-right como antes

### DailyEchoScreen
- Nuevo parámetro: `List<Map<String, dynamic>> wildcards = const []`
- Wildcards van primero en el stack de cards
- Badge Especial en top-left de cada wildcard card
- PRO badge en top-right solo si NO es wildcard

---

## Flujo de Navegación Completo
```
main.dart
├── FutureBuilder → SharedPreferences.getBool('onboarding_done')
│   ├── false (primera vez) → OnboardingScreen
│   │   └── "Comencemos" → LoginScreen (marca onboarding_done: true)
│   └── true → LoginScreen
│       ├── "Continuar como invitado/a" → HomeScreen (pushReplacement)
│       ├── "Continuar con Apple" → TODO (solo iOS)
│       ├── "Continuar con Google" → TODO
│       └── "Continuar con Email" → EmailLoginScreen
│           ├── "¿Olvidaste tu password?" → ForgotPasswordScreen
│           │   └── Submit → estado success → "Volver a Login" → pop
│           └── Submit → OnboardingNameScreen
│               └── Submit → HomeScreen (pushAndRemoveUntil)
```

---

## Estado por Pantalla

### `main.dart` ✅ sesión 7
- Carga `her_echoes.json` + `wildcard.json` en paralelo en `loadJson()`
- `wildcards` propagado a `LoginScreen` y `OnboardingScreen`
- `DailySuggestionsEngine.generateSuggestions(wildcards: wildcards)`

---

### `onboarding_screen.dart` ✅ sesión 7
- Parámetros: `allWomen`, `todaysWomen`, `suggestions`, `wildcards` (optional, default `[]`)
- `_finish()` pasa `wildcards` a `LoginScreen`
- 4 slides con `PageView`, dots animados
- Idioma: `LanguageProvider`

---

### `login_screen.dart` ✅ sesión 7
- Parámetros: `allWomen`, `todaysWomen`, `suggestions`, `wildcards` (optional, default `[]`)
- `_goHome()` y `_goEmail()` propagan `wildcards`

---

### `email_login_screen.dart` ✅ sesión 7
- Parámetros: `allWomen`, `todaysWomen`, `suggestions`, `wildcards` (optional, default `[]`)
- `_submit()` propaga `wildcards` a `OnboardingNameScreen`

---

### `onboarding_name_screen.dart` ✅ sesión 7
- Parámetros: `allWomen`, `todaysWomen`, `suggestions`, `email`, `wildcards` (optional, default `[]`)
- `_submit()` propaga `wildcards` a `HomeScreen`
- ⚠️ PENDIENTE: migrar `ElevatedButton` a `AppButton`
- ⚠️ PENDIENTE: guardar nombre en SharedPreferences

---

### `home_screen.dart` ✅ sesión 7
- Parámetros: `suggestions`, `allWomen`, `todaysWomen`, `wildcards` (optional, default `[]`)
- `DailyEchoScreen` recibe `wildcards`
- Carrusel: detecta `_is_wildcard: true` → pasa `isWildcard: true` a `HomeMiniCard`
- Carrusel: `profession` ahora respeta idioma (`pro-tag01_en` vs `pro-tag01_es`)

---

### `daily_echo_screen.dart` ✅ sesión 7
- Parámetros: `todaysWomen`, `wildcards` (optional, default `[]`)
- Wildcards al frente del stack con badge Especial top-left
- PRO badge solo en cards no-wildcard

---

### `card_detail_screen.dart` ✅ sesión 7
- Tags, quote y bio respetan idioma (`LanguageProvider`)
- ⚠️ CONOCIDO: `short_bio_es` vacío en varios registros del JSON — problema de datos, no de código

---

### `home_mini_card.dart` ✅ sesión 7
- Nuevo parámetro `isWildcard`
- `WildcardBadge` top-left cuando `isWildcard: true`
- Favorito oculto en wildcards

---

### `wildcard_badge.dart` ✅ sesión 7 NUEVO
- Fondo `#28A52A` al 85%
- Ícono `shootingStarFill`, texto "Especial"/"Special"

---

### `daily_suggestions_engine.dart` ✅ sesión 7
- Parámetro `wildcards` agregado
- Wildcards en posición 0 marcadas con `_is_wildcard: true`

---

### Pantallas sin cambios sesión 7
- `favorites_screen.dart` ✅
- `upsell_modal_free.dart` ✅
- `upsell_modal_pro.dart` ✅
- `plan_selection_screen.dart` ✅
- `add_card_screen.dart` ✅
- `payment_method_screen.dart` ✅
- `floating_tab_bar.dart` ✅
- `settings_screen.dart` y sub-pantallas ✅

---

## URL Patrón Imágenes GitHub
```
https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
```

---

## Git Tags
```bash
git tag v1.0-pre-language
git tag v1.1-payment-ui
git tag v1.2-onboarding-wildcard   # ← agregar al cerrar sesión 7
```

---

## Pendientes

### Alta prioridad
- [ ] `onboarding_name_screen.dart` → migrar `ElevatedButton` a `AppButton`
- [ ] Guardar nombre usuario en SharedPreferences
- [ ] Persistencia favoritos con SharedPreferences
- [ ] `legal_content.json`: reemplazar lorem ipsum con contenido real
- [ ] Conectar `PaymentScreen` / `PaymentMethodScreen` con RevenueCat

### Media prioridad
- [ ] Apple Sign In: configuración Xcode + Apple Developer Console
- [ ] Google Sign In: Firebase/GoogleSignIn package + config nativa
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Share sheet real (actualmente `onPressed: () {}`)
- [ ] Toggle "Recordarme 3 días" → notificaciones locales reales
- [ ] Detección moneda por locale (actualmente hardcoded CLP)
- [ ] Cancelar suscripción → conectar RevenueCat
- [ ] `short_bio_es` vacío en varios registros del JSON — completar datos

### Antes de producción
- [ ] Eliminar sección Dev/Debug de `settings_screen.dart`
- [ ] Verificar que las 118 imágenes en GitHub cargan correctamente
- [ ] Estados error tarjeta (rechazada/expirada/bloqueada)
- [ ] Cambio de plan: confirmar flujo downgrade
- [ ] `pro-tag01_es` / `pro-tag02_es` en card detail y carrusel — verificar datos JSON completos