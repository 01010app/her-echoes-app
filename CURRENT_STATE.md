# HerEchoes — Estado Actual del Proyecto
**Última actualización:** 2026-03-10 (sesión 3)

---

## Stack y Reglas de Arquitectura

- **Base width:** 393px (iPhone 15 Pro)
- **Fonts:** Google Fonts — Inter (UI), Gloock (títulos/nombres)
- **Icons:** Phosphor — SIEMPRE `PhosphorIcon(PhosphorIcons.name(style))`, NUNCA `Icon(...)`
- **Background scaffolds:** SIEMPRE `Color(0xFFF5F5F5)` / `AppColors.background` — NUNCA blanco
- **Accent:** `#F70F3D` / `Color(0xFFE1002D)`
- **State management:** Provider
- **Persistencia:** SharedPreferences (aún no conectado en favoritos)
- **NUNCA refactorizar layouts que funcionan**
- **Spinners:** SIEMPRE `CircularProgressIndicator(color: Color(0xFFE1002D))`

---

## Estructura de Archivos Relevantes

```
lib/
├── core/
│   ├── favorites_provider.dart        ✅ creado
│   ├── language_provider.dart         ✅ existente
│   ├── subscription_provider.dart     ✅ existente
│   └── theme/
│       └── app_colors.dart            ✅ existente
├── screens/
│   ├── card_detail/
│   │   └── card_detail_screen.dart    ✅ modificado (sesión 3)
│   ├── favorites/
│   │   └── favorites_screen.dart      ✅ modificado (sesión 3)
│   ├── payment/
│   │   ├── payment_screen.dart        ✅ creado (sesión 2)
│   │   ├── plan_selection_screen.dart ✅ creado (sesión 2)
│   │   ├── add_card_screen.dart       ✅ creado (sesión 2)
│   │   ├── payment_method_screen.dart ✅ modificado (sesión 3)
│   │   └── plan_detail_screen.dart    ✅ creado (sesión 3)
│   └── settings/
│       ├── settings_screen.dart       ✅ modificado (sesión 3)
│       ├── legal_content_screen.dart  ✅ modificado (sesión 3)
│       └── preferences_screen.dart    ✅ existente
├── widgets/
│   ├── cards/
│   │   └── home_mini_card.dart        ✅ modificado (sesión 1)
│   ├── modals/
│   │   └── upsell_modal_free.dart     ✅ existente
│   └── settings/
│       ├── settings_section_title.dart
│       ├── settings_list_container.dart
│       ├── settings_list_item.dart
│       └── settings_divider.dart
└── services/
    └── content_service.dart           ✅ existente
assets/
└── content/
    └── legal_content.json             ✅ existente (contenido en lorem ipsum — pendiente reemplazar)
```

---

## Estado por Pantalla

### `settings_screen.dart` ✅ COMPLETO
- Header blanco con back button (círculo rojo `AppColors.accent`)
- **Bug corregido:** `SizedBox(height: 24)` movido DENTRO del `SingleChildScrollView` (evita franja gris fija)
- Secciones: Configuración del sistema / Nosotros / Detalle Plan / Dev·Debug
- **"Pago" → "Medio de pago" / "Payment" → "Payment method"** ✅
- Navegación:
  - Preferencias → `PreferencesScreen`
  - Medio de pago → `PaymentScreen()` (sin `const`)
  - Acerca de Nosotros → `LegalContentScreen(contentKey: "about", ...)`
  - Términos y Condiciones → `LegalContentScreen(contentKey: "terms", ...)`
  - Plan Individual → `PlanDetailScreen()` ✅ nuevo
  - Dev/Debug: toggle PRO con PhosphorIcon toggle (eliminar antes de producción)
- Version 1.0.0 fijo abajo con `Positioned`

---

### `legal_content_screen.dart` ✅ COMPLETO
- Header blanco idéntico al de settings
- **Bug corregido:** `SizedBox(height: 24)` eliminado como widget fijo, movido a `padding: fromLTRB(16, 24, 16, 32)` del scroll
- **Spinner rojo:** `CircularProgressIndicator(color: Color(0xFFE1002D))`
- Lee de `assets/content/legal_content.json` vía `ContentService.loadLegalContent()`
- Estructura JSON esperada:
  ```json
  {
    "terms": { "es": { "title": "...", "content": [{"type": "h2", "text": "..."}, {"type": "p", "text": "..."}] }, "en": {...} },
    "about": { "es": {...}, "en": {...} }
  }
  ```
- Bloques soportados: `h2` (Inter 18 semibold negro) y `p` (Inter 16 regular #434343)
- **Pendiente:** reemplazar lorem ipsum con contenido real

---

### `payment_screen.dart` ✅ COMPLETO
- Header: "Medio de pago" (ES) / "Payment method" (EN)
- Estado FREE: texto centrado + CTA "Suscríbete a un Plan" → `PlanSelectionScreen`
- Estado PRO: renderiza `PaymentMethodBody` directamente (sin doble header)

---

### `plan_selection_screen.dart` ✅ COMPLETO
- `enum PlanType { individual, family }`
- Individual: CLP 9.900 / Family: CLP 16.500, ambos Anuales
- Toggle prueba gratis (solo Individual)
- CTA "Agregar medio de pago" (gris #949494) → `AddCardScreen`

---

### `add_card_screen.dart` ✅ COMPLETO
- Preview de tarjeta en vivo (gradiente oscuro, badge VISA)
- Campos: número (formato XXXX XXXX XXXX XXXX), expiración (MM/YY), titular, CVV
- CTA rojo cuando form válido, gris cuando no
- Al submit: `setIsPro(true)` + `Navigator.pushAndRemoveUntil` → `PaymentMethodScreen`

---

### `payment_method_screen.dart` ✅ COMPLETO
- Dos clases: `PaymentMethodScreen` (Scaffold completo) y `PaymentMethodBody` (sin header, para embeber en PaymentScreen PRO)
- Card "Plan contratado": bg `#E9E9E9`, border `#DFDFDF`, 16px radius, padding 16
  - Subtítulo "Plan contratado" (Inter 11 semibold #6C6868) arriba de todo
  - Nombre plan + precio en row
  - Periodicidad + Anual en row
  - Botón "Cambiar de Plan": blanco bg, borde rojo, shrinkWrap
- Sección "Medios de pago" (Inter 14 semibold #404040)
- Card tarjeta: bg blanco, 16px radius, padding 16, shadow leve
  - Badge VISA (#F0F0F0), "Visa •••• XXXX", fecha expiración, badge "Principal" verde
- **Botón "Cancelar suscripción" FIJO abajo:** `Positioned(bottom: bottomPadding + 16, ...)` — OutlinedButton borde rojo, full width 24px margen horizontal
- Dialog cancelación: icono warning rojo, CTA "Mantener suscripción" rojo, link "Sí, cancelar" gris
- TODO: conectar cancelación con RevenueCat

---

### `plan_detail_screen.dart` ✅ COMPLETO (nuevo sesión 3)
- Accesible desde Settings > Detalle Plan > Plan Individual
- Header blanco igual a settings/legal
- Solo muestra el card de "Plan contratado" (sin sección de tarjeta, sin botón cancelar)
- Lee `isPro` del `SubscriptionProvider` para mostrar nombre y precio reales
- Botón "Cambiar de Plan" navega a `PlanSelectionScreen`

---

### `favorites_screen.dart` ✅ COMPLETO
- 3 estados:
  1. **FREE:** texto upsell + CTA "Suscríbete" → `UpsellModalFree`
  2. **PRO vacío:** texto explicativo + CTA "Visitar la mujer inspiradora de hoy" → `onNavigateToDaily`
  3. **PRO con favoritos:** grid 2 columnas
- **Bug corregido:** `headerHeight = MediaQuery.of(context).padding.top + 60.0` (sin el `+ 16` que causaba franja extra)
- Grid specs: `childAspectRatio: 160/280`, 8px spacing, 32px border radius
- Overlay blanco detrás del header: `Positioned(height: headerHeight)`
- Botón corazón en cada card: **abre modal de confirmación antes de quitar** (`_showRemoveConfirmation`)
  - Modal: icono corazón rojo, título "¿Quitar de Favoritas?", CTA rojo "Sí, quitar", link gris "Cancelar"
- `topPadding = 104.0 + 16.0`, `bottomPadding = 85.0 + safeArea`

---

### `card_detail_screen.dart` ✅ COMPLETO
- Hero imagen animada 520→320px al hacer scroll
- Tabs Biografía/Legado
- Back button y menú contextual (OverlayEntry blur) en top
- Menú contextual: Añadir/quitar favorito, Compartir, Reportar
- **Botones abajo corregidos:** `padding: fromLTRB(24, 24, 24, 0)` + `SizedBox(height: padding.bottom - 11)` — botones 27px más cerca del borde
- Botón favorito: bg `#949494` si ya está en favoritos (PRO), bg rojo si no / si FREE
- Label favorito: "Añadido ♥" / "Añadir a Favoritos" / "Add to Favorites"
- Modal confirmación al AÑADIR (no al quitar desde aquí)
- Quitar desde favoritos se hace desde `favorites_screen.dart` con modal propio

---

## Bugs Corregidos Esta Sesión

| Bug | Causa | Fix |
|-----|-------|-----|
| Franja gris bajo header en Settings | `SizedBox(height:24)` fijo fuera del scroll | Mover dentro del scroll como primer hijo |
| Franja gris bajo header en LegalContent | Mismo patrón | Mismo fix |
| Header demasiado alto en Favorites grid | `headerHeight` tenía `+ 16` de más | Eliminar el `+ 16` |
| Spinner violeta en LegalContent | Sin color especificado, usa tema Material default | `color: Color(0xFFE1002D)` |
| Botones detail view 27px muy arriba | `vertical: 24` en padding + `padding.bottom + 16` en SizedBox | `fromLTRB(24,24,24,0)` + `SizedBox(height: padding.bottom - 11)` |
| Botón cancelar suscripción 8px muy arriba | `bottom: bottomPadding + 24` | `bottom: bottomPadding + 16` |
| Sin confirmación al quitar favorito | Botón corazón llamaba `toggle()` directo | Modal `_showRemoveConfirmation` con confirmación |

---

## Pendientes

### Alta prioridad
- [ ] Conectar `PaymentScreen` / `PaymentMethodScreen` con RevenueCat
- [ ] `legal_content.json`: reemplazar lorem ipsum con contenido real (ES + EN)
- [ ] Persistencia de favoritos con SharedPreferences (actualmente en memoria)

### Media prioridad
- [ ] Modal PRO upsell → conectar CTA a pantalla de pago
- [ ] Share: implementar share sheet real (actualmente `onPressed: () {}`)
- [ ] Toggle "Recordarme 3 días" en preferencias → notificaciones locales reales
- [ ] Detección de moneda por locale (actualmente hardcoded CLP)
- [ ] Persistencia de idioma
- [ ] Suscripción real: reemplazar `SubscriptionProvider` debug por RevenueCat

### Antes de producción
- [ ] Eliminar sección "Dev / Debug" con toggle PRO de `settings_screen.dart`
- [ ] Términos y Condiciones: agregar cláusula de recordatorios renovación
- [ ] Cancelar suscripción: conectar con RevenueCat (TODO marcado en código)
- [ ] Cambio de plan: confirmar flujo downgrade PRO→FREE
- [ ] Estados de error tarjeta (rechazada/expirada/bloqueada) en `add_card_screen.dart`

---

## Patrón de Header Estándar (todas las sub-pantallas)

```dart
Column(
  children: [
    Container(height: topPadding, color: Colors.white),
    Container(
      height: 48,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: Center(child: PhosphorIcon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), size: 20, color: AppColors.accent)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Center(child: Text("Título", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5, letterSpacing: -0.5, color: Color(0xFF404040))))),
          const SizedBox(width: 44),
        ],
      ),
    ),
    // ← NUNCA poner SizedBox aquí fuera
    Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32), // ← top: 24 va AQUÍ
        ...
      ),
    ),
  ],
)
```

---

## Patrón de Navegación desde Settings

```dart
// settings_screen.dart imports necesarios:
import '../payment/payment_screen.dart';
import '../payment/plan_detail_screen.dart';
import 'legal_content_screen.dart';
import 'preferences_screen.dart';

// Navegaciones:
// Medio de pago:
Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen()))  // sin const

// Detalle Plan:
Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanDetailScreen()))

// Legal:
Navigator.push(context, MaterialPageRoute(builder: (_) => LegalContentScreen(contentKey: "about", language: isEnglish ? "en" : "es")))
```
