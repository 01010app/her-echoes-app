# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-13 (sesión 9)

---

## Stack y Reglas de Arquitectura

- **Base width:** 393px (iPhone 15 Pro)
- **Fonts:** Google Fonts — Inter (UI), Gloock (títulos/nombres), Lora (e-card quote/nombre)
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
│   │   └── card_detail_screen.dart     ✅ sesión 9: e-card share implementado
│   ├── favorites/
│   │   └── favorites_screen.dart
│   ├── login/
│   │   ├── login_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── email_login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── onboarding_name_screen.dart   ⚠️ PENDIENTE: migrar ElevatedButton a AppButton
│   ├── payment/
│   │   ├── plan_type.dart
│   │   ├── payment_screen.dart
│   │   ├── plan_selection_screen.dart
│   │   ├── add_card_screen.dart          ⚠️ usa Icons.close (pendiente → PhosphorIcon)
│   │   ├── payment_method_screen.dart    ✅ sesión 8
│   │   └── plan_detail_screen.dart
│   ├── home/
│   │   └── home_screen.dart              ✅ sesión 8
│   ├── daily_echo/
│   │   └── daily_echo_screen.dart
│   ├── show_all/
│   │   └── show_all_screen.dart          ✅ sesión 8
│   └── settings/
│       ├── settings_screen.dart
│       ├── legal_content_screen.dart
│       ├── notifications_screen.dart
│       ├── language_screen.dart
│       └── preferences_screen.dart
├── widgets/
│   ├── cards/
│   │   ├── home_mini_card.dart
│   │   ├── pro_badge.dart
│   │   └── wildcard_badge.dart
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
    └── daily_suggestions_engine.dart

assets/
├── data/
│   ├── her_echoes.json
│   └── wildcard.json                     ✅ sesión 8
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

---

## Dependencias activas (pubspec.yaml)
```yaml
path_provider: ^2.1.x   ⚠️ DEBE estar en pubspec — usado por card_detail_screen.dart
share_plus: ^12.0.0      ✅
http: ^1.2.1             ✅
google_fonts: ^6.2.1     ✅  (usa Lora para e-card)
```
> ⚠️ Verificar que `path_provider` esté en pubspec.yaml — no aparecía en la versión subida

---

## Wildcard — Sistema completo (sesiones 7-8-9)

### Concepto
- JSON separado `assets/data/wildcard.json` — mismo formato que `her_echoes.json`
- En runtime, `main.dart` descarga `wildcard.json` desde GitHub vía HTTP
- Fallback a asset local si no hay conexión
- Cuando el array tiene entradas → aparece en posición 0 del carrusel Home, al inicio de Daily Echo, y primero en Show All
- Cuando está vacío `[]` → no se muestra en ningún lado
- Las wildcards se marcan internamente con `_is_wildcard: true`

### Panel Admin Web ✅ sesión 9 — EN PRODUCCIÓN
- URL: `https://callmehector.cl/apps/herechoes/wildcard.php`
- Password protegido
- Lee estado actual desde GitHub API
- Publica/reemplaza `wildcard.json` en GitHub vía API
- Campos alineados exactamente con `card_detail_screen.dart`
- Lógica de `wildcard_start` / `wildcard_end` para visibilidad por fechas
- Propósito: marketing con influencers (visibilidad temporal a cambio de difusión)

### Badge `WildcardBadge`
- Fondo: `Color(0xFF28A52A).withOpacity(0.85)`
- Ícono: `PhosphorIcons.shootingStar(PhosphorIconsStyle.fill)`, size 12, blanco
- Texto: "Especial" (ES) / "Special" (EN)
- Posición: esquina superior izquierda en todas las vistas
- Se muestra siempre, FREE y PRO

---

## E-Card / Share ✅ sesión 9

### Implementación en `card_detail_screen.dart`
- Widget `_ShareECard` renderiza imagen 1080×1080px offscreen
- Foto de la mujer cargada como `ui.Image` vía HTTP
- Gradiente rojo HerEchoes sobre la foto
- Badge "Especial/Special" si es wildcard
- Quote en Lora italic, nombre en Lora bold, profesión en Inter
- Logo/branding HerEchoes en esquina inferior derecha
- Se captura con `RepaintBoundary` → PNG → `XFile`
- Comparte vía `Share.shareXFiles()` con texto:
    - EN: `"Discover her story on HerEchoes 👉 https://callmehector.cl/apps/herechoes/?ref=share"`
    - ES: `"Descubre su historia en HerEchoes 👉 https://callmehector.cl/apps/herechoes/?ref=share"`

### Estado actual share
- ✅ Genera e-card PNG correctamente
- ✅ En dispositivo real: abre sheet de compartir (WhatsApp, Instagram, etc.)
- ⚠️ En Simulator iOS: solo ofrece "Guardar como archivo" — comportamiento normal del simulador, NO es un bug

---

## Flujo de Navegación Completo
```
main.dart
├── Descarga wildcard.json desde GitHub (HTTP) → fallback asset local
├── FutureBuilder → SharedPreferences.getBool('onboarding_done')
│   ├── false → OnboardingScreen
│   │   └── "Comencemos" → LoginScreen
│   └── true → LoginScreen
│       ├── "Continuar como invitado/a" → HomeScreen
│       └── "Continuar con Email" → EmailLoginScreen
│           └── Submit → OnboardingNameScreen
│               └── Submit → HomeScreen
```

---

## Estado por Pantalla

### `card_detail_screen.dart` ✅ sesión 9
- E-card share implementado
- Botón "Compartir con amigos" / "Share with friends" en la pantalla
- Botón "Compartir" / "Share" en el bottom bar
- `_isSharing` flag para evitar doble tap
- Usa `path_provider` + `share_plus`

### `add_card_screen.dart` ⚠️ sesión 9
- Funcional
- Bug menor: usa `Icons.close` en el banner del plan (pendiente → `PhosphorIcon`)

### `main.dart` ✅ sesión 8
- Descarga `wildcard.json` desde GitHub raw URL con timeout 6s

### `payment_method_screen.dart` ✅ sesión 8
- Header con botón volver agregado

### `show_all_screen.dart` ✅ sesión 8
- Wildcards en posición 0, siempre accesibles

### `home_screen.dart` ✅ sesión 8
- Pasa `wildcards` a `ShowAllScreen`

---

## URL Patrón Imágenes GitHub
```
https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${rawId}.webp
```

## URL Wildcard JSON GitHub (runtime)
```
https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json
```

---

## Git Tags
```bash
git tag v1.0-pre-language
git tag v1.1-payment-ui
git tag v1.2-onboarding-wildcard
git tag v1.3-wildcard-admin      ✅ cerrar sesión 8
git tag v1.4-share-ecard         # ← agregar al cerrar sesión 9
```

---

## Pendientes

### Alta prioridad
- [ ] Verificar `path_provider` en `pubspec.yaml` — requerido por `card_detail_screen.dart`
- [ ] `add_card_screen.dart` → reemplazar `Icons.close` por `PhosphorIcon(PhosphorIcons.x(...))`
- [ ] `onboarding_name_screen.dart` → migrar `ElevatedButton` a `AppButton`
- [ ] Guardar nombre usuario en SharedPreferences
- [ ] Persistencia favoritos con SharedPreferences
- [ ] `legal_content.json`: reemplazar lorem ipsum con contenido real
- [ ] Conectar `PaymentScreen` / `PaymentMethodScreen` con RevenueCat

### Media prioridad
- [ ] Estados de error en pago: tarjeta rechazada / expirada / sin fondos (`add_card_screen.dart`)
- [ ] Apple Sign In: configuración Xcode + Apple Developer Console
- [ ] Google Sign In: Firebase/GoogleSignIn package + config nativa
- [ ] Backend: verificar si email existe → login vs registro
- [ ] Toggle "Recordarme 3 días" → notificaciones locales reales
- [ ] Detección moneda por locale (actualmente hardcoded CLP)
- [ ] Cancelar suscripción → conectar RevenueCat
- [ ] `short_bio_es` vacío en varios registros del JSON — completar datos

### Antes de producción
- [ ] Eliminar sección Dev/Debug de `settings_screen.dart`
- [ ] Verificar que las 118 imágenes en GitHub cargan correctamente
- [ ] Cambio de plan: confirmar flujo downgrade
- [ ] Token GitHub (`herechoes-wildcard`) expira Apr 11 2026 — renovar antes
- [ ] Subir imagen real de wildcard y probar en simulador

---

## Next Development Focus (sesión 10)
1. Verificar `path_provider` en pubspec.yaml
2. Fix `Icons.close` → `PhosphorIcon` en