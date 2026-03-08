# HerEchoes — Development Roadmap

This roadmap defines the planned development phases for the HerEchoes app.

The goal is to develop the app **incrementally without breaking working features**.

---

# Phase 1 — Core Engine (Completed)

Goal: build the data engine of the app.

Completed systems:

* JSON database
* JSON loading from assets
* date filtering
* `todaysWomen` generation
* FREE vs PRO access logic

Data source:

```id="data_source_json"
assets/data/her_echoes.json
```

---

# Phase 2 — Core UI System (Completed)

Goal: create reusable UI components and design system.

Completed components:

Reusable card:

```id="woman_card_widget_location"
lib/widgets/woman_card_widget.dart
```

Design system:

```id="theme_system_location"
lib/theme/
```

Files:

```id="theme_files"
app_theme.dart
app_colors.dart
app_text_styles.dart
app_shapes.dart
```

Design rules:

Typography:

* Body → Inter
* Titles → Gloock

Icons:

* Phosphor

Accent color:

```id="accent_color"
#F70F3D
```

Background:

```id="background_color"
#F5F5F5
```

Shapes:

* Squircle-style corners using `superellipse_shape`

---

# Phase 3 — Home Screen (Current Phase)

Goal: display the daily content.

Tasks:

1. Render `todaysWomen` on the Home screen
2. Display cards using `WomanCardWidget`
3. Implement horizontal **Home carousel**

Expected UI:

```id="home_ui_structure"
Home Screen
   ↓
Horizontal carousel
   ↓
WomanCardWidget
```

---

# Phase 4 — Content Navigation

Goal: allow users to explore more entries.

Screens:

Show All:

Displays all women from the database.

Favorites:

Allows users to save women.

Planned screens:

```id="planned_screens"
Home
Daily Echo
Show All
Favorites
```

---

# Phase 5 — User Features

Goal: add user interaction systems.

Features:

* Favorites system
* local persistence
* onboarding
* user settings

---

# Phase 6 — Monetization

Goal: introduce the subscription model.

Features:

* PRO subscription
* unlock premium content
* payment integration

---

# Phase 7 — Backend Migration (Future)

Goal: move from local JSON to remote database.

Possible options:

* Supabase
* Firebase
* custom API

Advantages:

* dynamic content updates
* analytics
* content management

---

# Phase 8 — Growth Features

Future systems:

* push notifications
* editorial content
* achievements
* sharing features

---

# Development Philosophy

The project follows these principles:

* incremental development
* never break working features
* prefer reusable widgets
* keep architecture simple
* centralize styling
* maintain clear documentation

---

# Current Priority

Current milestone:

```id="current_milestone"
Render todaysWomen in Home carousel
using WomanCardWidget
```

This transforms the app from **prototype → usable product**.

---

# Repository

GitHub:

https://github.com/01010app/her-echoes-app

The repository may temporarily be public during debugging but should return to **private** afterward.



---
# DEVELOPMENT ROADMAP — HerEchoes

---

# Phase 1 — Architecture Foundation

✔ Simulator standardized (393px width)
✔ FloatingTabBar custom implementation
✔ Base layout philosophy defined
✔ HOME_UI_SPEC v2 updated

---

# Phase 2 — Home Structural Build (NEXT)

1. Build structural content block above TabBar
2. Reserve structural 264px bottom zone
3. Anchor gradient correctly (370px)
4. Insert decorative background after structure exists

---

# Phase 3 — Component Separation

- Create HomeScreen independent
- Create SuggestionsCarousel component
- Move data loading out of main.dart
- Enforce PROJECT_ARCHITECTURE separation

---

# Phase 4 — Data Logic

- Implement:
    - 3 women of the day
    - Up to 7 related suggestions
    - Tag-based matching
    - Language detection
    - Randomization
    - Max 10 items total

---

# Phase 5 — Carousel System

- Infinite illusion
- Magnetic snap
- Exact 156x156 sizing
- 16px left margin
- 8px spacing
- Pixel-perfect alignment on 393 base

---

# Long-Term

- Breakpoint system (optional)
- Tablet behavior
- Android Medium rules

---


## 🔴 PRIORIDAD ACTUAL — Daily Suggestions Engine

Objetivo:
Construir algoritmo definitivo para el carrusel Home.

Reglas:
1. Obtener mujeres cuyo event_date == hoy.
2. Tomar las primeras 3.
3. Buscar hasta 7 adicionales:
  - Coincidencia por pro-tag01_en / pro-tag01_es
  - Según idioma activo.
4. Eliminar duplicados.
5. Orden estable.
6. Pasar lista final al carrusel.

Estado:
🔧 Diseño definido.
❌ No implementado aún.