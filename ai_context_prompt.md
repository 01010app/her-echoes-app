# HerEchoes — AI Dev Context

You are helping develop a Flutter mobile app called **HerEchoes**.

Repository:

https://github.com/01010app/her-echoes-app

Before answering any question, read these files from the repository:

1. project_protocol.md
2. database_rules.md
3. daily_workflow.md
4. CURRENT_STATE.md
5. ARCHITECTURE.md
6. dev_roadmap.md

These documents define the project's architecture and workflow.

---

# App Concept

HerEchoes displays **women in history associated with the current day of the year**.

Example:

March 4 → women connected to March 4 events.

---

# Data Source

The database currently lives in:

```
assets/data/her_echoes.json
```

Each entry contains fields like:

* full_name
* pro-tag01_en
* pro-tag02_en
* image_card_ID
* month
* day

---

# Current Data Pipeline

```
JSON
 ↓
Load database
 ↓
Filter by today's date
 ↓
Generate todaysWomen
 ↓
Render UI cards
```

`todaysWomen` is the primary dataset used by the UI.

---

# Core UI Component

Main reusable widget:

```
lib/widgets/woman_card_widget.dart
```

The card displays:

* background image
* gradient overlay
* profession tags
* woman's name
* optional PRO badge

This widget will be reused across multiple screens.

---

# Design System

The app uses a centralized design system.

Location:

```
lib/theme/
```

Files:

```
app_theme.dart
app_colors.dart
app_text_styles.dart
app_shapes.dart
```

Typography:

Body → **Inter**

Titles → **Gloock**

Icons:

```
Phosphor
```

Accent color:

```
#F70F3D
```

Background:

```
#F5F5F5
```

Shapes:

Squircle-style corners implemented with:

```
superellipse_shape
```

---

# Current Development Goal

Next step:

Render `todaysWomen` on the Home screen using `WomanCardWidget`.

Then implement:

* Home carousel
* Show All screen
* Favorites system

---

# Development Rules

Work incrementally.

Rules:

* never break working features
* prefer small changes
* explain exactly where to edit files
* assume the developer is **not an expert programmer**
* avoid unnecessary refactoring

---

# Important Note

Remind the developer to set the GitHub repository **back to private** after debugging.


---

# Immediate Task (First Step)

Before implementing new features, perform a small project structure improvement.

Goal: prepare the project for multiple screens and scalable architecture.

Refactor the project structure as follows:

Current:

lib/theme/

Target:

lib/core/theme/

Steps:

1. Move the entire `lib/theme` folder to:

lib/core/theme/

2. Update all imports referencing theme files.

Example:

Before:

import '../core/theme/app_colors.dart';

After:

import '../core/theme/app_colors.dart';

3. Run:

flutter clean
flutter pub get
flutter run

Do this refactor **before adding Home carousel or new screens**.

Do not modify working logic.
Only adjust folder structure and imports.

---

# UI Specification Awareness (Important)

This project contains a dedicated UI documentation system located at:

UI_SPECS/

These documents define the official UI architecture and behavior of the app.

Examples include


7. PROJECT_MAP.md
8. All files inside the folder:

UI_SPECS/

This folder contains the official UI and product specifications.

Important:
Before proposing UI changes, architecture changes, or feature implementations, always review the UI_SPECS documentation to ensure consistency with the existing design system.


---

# Documentation Consistency Rule

The folder `UI_SPECS/` contains the official documentation for:

• UI architecture  
• layout system  
• animation system  
• cards system  
• settings UI  
• paywall logic  
• data model

Before implementing new features, always check if the change affects any existing specification.

If during development you detect that a feature requires updating the documentation, you must:

1. Explicitly point out which document should be updated.
2. Suggest the updated section content.
3. Wait for confirmation before modifying the implementation if the change affects core architecture.

The documentation should remain the single source of truth for the product structure.



---

# CURRENT DEV CONTEXT (Important)

The project recently introduced a new image loading system.

Historical card images are NOT stored in Flutter assets.

Instead they are stored in the GitHub repository and loaded via network URLs.

Repository structure now includes:

images/
cards/
earhart_01.webp
hurston_01.webp
balch_01.webp
etc.

Images are served using GitHub raw URLs:

https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/{image_card_ID}_01.webp

Example:

https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/earhart_01.webp

The JSON database still contains:

image_card_ID

Example:

"image_card_ID": "earhart"

The UI constructs the URL dynamically:

https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${image_card_ID}_01.webp

The app recently introduced a new widget:

lib/widgets/cards/home_mini_card.dart

This widget replaced the previous:

WomanCardWidget

Temporary testing code currently exists inside:

lib/main.dart

Example usage:

HomeMiniCard(
fullName: woman.fullName,
profession: woman.proTag01En,
imagePath:
"https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/${woman.imageCardID}_01.webp",
isPro: false,
onTap: () {},
)

The goal of the current development session is:

1. Load images correctly from GitHub.
2. Replace the temporary column layout with the proper Home carousel.
3. Ensure cards render correctly using HomeMiniCard.

Important:

The developer is not an expert programmer.

Always give:

• minimal instructions  
• exact file edits  
• step-by-step actions

Avoid large explanations.

Never refactor working code unless necessary.


---

# Critical Context Rules

Base layout width: 393px.

All layout math must assume base width = 393.
Do not scale UI proportionally for larger devices.

The iPhone 15 Pro simulator must be used for layout validation.

FloatingTabBar must always be built before decorative layers.

The 264px bottom rule is structural space, not overlay space.

Decorative image must be layered AFTER structural content is defined.

Never attempt to calculate layout using screenHeight percentages for decorative positioning.


---

## CONTEXTO CRÍTICO ACTUAL

Estamos trabajando en la Home.

Estado:
- Layout estructural correcto.
- UI casi final.
- Falta lógica de datos del carrusel.

El carrusel debe mostrar:
- 3 mujeres del día.
- + 7 adicionales relacionadas por pro-tag01 (idioma dependiente).

Este es el punto exacto donde continuar.
No rehacer layout.
No rehacer estilos.
Trabajar únicamente en la lógica del motor de sugerencias.

---

---

# SESSION CONTINUITY PROTOCOL (CRITICAL)

This project uses a persistent architectural memory system.

At the end of every development chat session, the assistant MUST:

1. Summarize all structural, architectural, UI, logic, and data changes introduced.
2. Update CURRENT_STATE.md to reflect the exact new project state.
3. Confirm that no changes conflict with UI_SPECS documentation.
4. Clearly list:
    - New files created
    - Files modified
    - Architectural decisions made
    - Rules introduced or changed
5. Ensure the project is left in a compilable state.
6. Leave a clearly defined "Next Development Focus" section in CURRENT_STATE.md.

When a new chat session begins, the assistant MUST:

1. Read:
    - project_protocol.md
    - daily_workflow.md
    - CURRENT_STATE.md
    - ARCHITECTURE.md
    - dev_roadmap.md
    - All relevant UI_SPECS documents
2. Use CURRENT_STATE.md as the single source of architectural truth.
3. Never assume missing context.
4. Never hallucinate undocumented features.
5. Never rewrite working architecture unless explicitly instructed.

If architectural memory is inconsistent, the assistant must ask for clarification before proceeding.