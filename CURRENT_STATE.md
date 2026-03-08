# HerEchoes — CURRENT STATE
Last Updated: March 8, 2026 — Post Settings Expansion + Detail System Stabilized

---

# CORE ARCHITECTURE

Base Layout:
- Base width: 393px (iPhone 15 Pro simulator reference)
- No proportional scaling for larger devices

Navigation:
- Custom FloatingTabBar (NOT Flutter BottomNavigationBar)
- Managed inside HomeScreen (StatefulWidget)
- 4 tabs:
  0 → Home
  1 → Daily Echo
  2 → Show All
  3 → Favorites
- Settings opened via Navigator.push (separate screen)
- When Settings opens → header + tab bar hidden automatically

Theme:
lib/core/theme/
- app_colors.dart
- app_text_styles.dart
- app_shapes.dart
- app_theme.dart

Accent: #F70F3D
Background: #F5F5F5

Icons:
Phosphor 2.x
Rule:
Use:
PhosphorIcon(PhosphorIcons.iconName(style))
Never use:
Icon(PhosphorIcons.iconName)

---

# DATA SYSTEM

Database:
assets/data/her_echoes.json
Entries: 131

Important fields:
- woman_id
- full_name
- event_date (MM/DD)
- past_date
- birth_date
- birth_place
- death_date
- death_place
- is_free ("VERDADERO" = FREE, any other value = PRO)
- pro-tag01_en
- pro-tag02_en
- on_this_date_en / es
- bio_en / es
- legacy_en / es
- quote_text_en / es
- image_card_ID

---

# IMAGE LOADING SYSTEM (GitHub RAW)

Images are NOT stored in Flutter assets.

They are loaded from GitHub:

https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/{image_card_ID}.webp

Rules:

- image_card_ID can be:
  - simple ID (e.g. morgan_01)
  - full http URL
- Always verify:
  rawId.startsWith('http')

If NOT http:
construct GitHub RAW URL dynamically.

This system is production architecture.
Do not move images into assets.

---

# DAILY SUGGESTIONS ENGINE (IMPLEMENTED)

Location:
lib/services/daily_suggestions_engine.dart

Input:
- todaysWomen
- fullDataset
- locale (en / es)

Logic:
- 3 women of the day
- + up to 7 related by pro-tag01 (language dependent)
- Remove duplicates using woman_id
- Max output: 10 cards
- Works on Map<String, dynamic> (no model class)

This is fully implemented.

---

# SCREENS STATUS

---

## HOME

File:
lib/screens/home/home_screen.dart

Features:
- Background decorative image crossfade every 5s
- Real device date using DateTime.now()
- Generates todaysWomen dynamically
- Calls DailySuggestionsEngine
- Horizontal ListView carousel
- 16px left padding
- 8px gap between cards
- Uses HomeMiniCard (156x156)

HomeMiniCard:
lib/widgets/cards/home_mini_card.dart
- BorderRadius 16px
- PRO badge if woman['is_free'] != "VERDADERO"

---

## DAILY ECHO

File:
lib/screens/daily_echo/daily_echo_screen.dart

Uses:
- card_stack_widget

Rules:
- Only women with non-empty image_card_ID
- FREE → opens CardDetailScreen
- PRO → upsell placeholder modal
- Transparent background
- 32px border radius
- Quote styled with accent ❝

---

## SHOW ALL

File:
lib/screens/show_all/show_all_screen.dart

Uses:
- vertical_card_pager

Features:
- Full dataset (filtered by image_card_ID not empty)
- Focused card text: 28px
- Unfocused: 16px
- FREE → detail
- PRO → upsell placeholder

---

## FAVORITES

File:
lib/screens/favorites/favorites_screen.dart

UI implemented.
Persistence logic NOT implemented yet.

---

## CARD DETAIL SCREEN (STABLE)

File:
lib/screens/card_detail/card_detail_screen.dart

Architecture:

Top:
- Hero image (collapsible)
  Initial height: 520px
  Min height: 320px
  >320px → borderRadius 32px bottom corners
  ≤320px → radius 0px (full bleed)

Gradient:
- Black 85% bottom → transparent mid

Overlay:
- Tags
- Name (Gloock 32px white)
- Back button (bold arrow)
- Menu ··· (bold)

Tabs:
- Biography
- Legacy

Behavior:
>320px:
- 16px horizontal margin
- borderRadius 16px
  ≤320px:
- no margin
- radius 0px
- attached to image

Biography Tab:
- "On this day" section
- Birth tag (baby icon)
- Death tag (skull icon)
- If no death_date → "Still alive" / "Aún con vida"
- Place displayed outside tag

Legacy Tab:
- Quote section (PhosphorIcons.quotes(.bold))
- Share button
- Add to Favorites button

Buttons:
- Share → outlined red
- Add to Favorites → filled red

Menu bottom sheet:
- Add to Favorites
- Share with friends
- Report issue
- Report includes subtitle

---

# SETTINGS SYSTEM (PHASE 3)

Folder:
lib/screens/settings/

Screens:
- settings_screen.dart
- preferences_screen.dart
- notifications_screen.dart
- language_screen.dart
- legal_content_screen.dart

Widgets:
lib/widgets/settings/
- settings_section_title.dart
- settings_list_container.dart
- settings_list_item.dart
- settings_divider.dart

Rules:
- White container
- BorderRadius 16px
- 1 physical pixel border
- Manual press animation (no ripple)

---

# LANGUAGE SYSTEM (CURRENT STATE)

language_screen.dart:

- Local bool _isEnglish
- Default: false (Español active)
- Radio-style toggle
- Uses Phosphor toggleLeft/toggleRight(.fill)

Current limitations:

- Language NOT global
- NOT persisted
- LegalContentScreen hardcoded
- Some screens still hardcoded English
- isEnglish hardcoded true in some areas

This is the next architectural focus.

---

# LEGAL CONTENT SYSTEM

File:
assets/content/legal_content.json

Structure:
{
"terms": {
"es": {...},
"en": {...}
},
"about": {...}
}

ContentService:
- Loads JSON
- Returns decoded Map

LegalContentScreen:
- Receives contentKey + language
- Renders dynamic blocks
- Supports h2 and p

Language currently hardcoded.

---

# SUBSCRIPTION STATE

Currently placeholder logic only.

FREE:
- Some cards locked
- Upsell modal placeholder

PRO:
- Full access

Real subscription logic NOT implemented.

---

# KNOWN PENDING ITEMS

- Global language system (Provider or InheritedWidget)
- Persist language selection
- Connect language to:
  - Home
  - Detail
  - Settings
  - LegalContentScreen
- Implement Favorites storage
- Implement real Share sheet
- Implement subscription logic
- Implement real upsell modal
- Connect subscription state to banner logic

---

# CRITICAL RULES

- Do NOT refactor working layout.
- Do NOT change UI without checking UI_SPECS.
- Base width always 393px.
- FloatingTabBar built before decorative layers.
- 264px bottom space rule is structural.
- Never calculate layout using screenHeight percentages for decorative positioning.

---

# NEXT DEVELOPMENT FOCUS

Primary:
→ Implement GLOBAL language system.

Goals:
- Replace local _isEnglish
- Create centralized language state
- Make entire app reactive to language change
- No layout changes
- No UI refactor
- Architecture only

Secondary:
- Language persistence
- Clean hardcoded strings

---

END OF CURRENT STATE SNAPSHOT