# HerEchoes — Architecture

This document defines the real and current architecture of the HerEchoes Flutter application.

It must reflect the actual implemented structure.

---

# Core Concept

HerEchoes displays women in history associated with the current day of the year.

The canonical dataset is:

assets/data/her_echoes.json

Each day contains exactly 3 official women entries.

These 3 entries are the base unit of the system.

---

# Data Source

Primary dataset:

assets/data/her_echoes.json

Each record represents one woman and includes:

- event_date (format: "MM/DD")
- past_date
- woman_id
- full_name
- pro-tag01_en
- pro-tag02_en
- pro-tag01_es
- pro-tag02_es
- quote_text_en
- quote_text_es
- bio_en
- bio_es
- legacy_en
- legacy_es
- image_card_ID
- is_free
- source_01
- source_02

event_date is the canonical filter key.

---

# Core Screen Architecture

The app has 4 main screens.

---

## 1️⃣ Home

Displays 10 suggestions.

Composition:
- 3 official women of the day (from JSON)
- + 7 related women matched by:
  - pro-tag01
  - or pro-tag02
  - depending on active app language (es / en)

Data source:
DailySuggestionsEngine

UI:
- Horizontal carousel
- HomeMiniCard (156px height)

Tap behavior:
→ Opens Detail View

---

## 2️⃣ Daily Echo

Displays exactly 3 official women of the day.

Source:
her_echoes.json

UI:
card_stack_widget

Tap behavior:
→ Opens Detail View

This screen represents the canonical daily content.

---

## 3️⃣ Show All

Displays the entire dataset.

Future scale:
~1200 entries (3 per day × 365)

Current:
March dataset (~90 entries)

UI:
vertical_card_pager

Tap behavior:
→ Opens Detail View

---

## 4️⃣ Favorites

Displays user liked entries.

UI:
Grid layout

Tap behavior:
→ Opens Detail View

---

# Detail View

Single source of truth for full content display.

Sections:

Header Image
Tags
Full Name

Tabs:
- Biography
- Legacy

Used by:
Home
Daily Echo
Show All
Favorites

---

# Data Flow

her_echoes.json
↓
Load dataset
↓
Filter by event_date (MM/DD)
↓
Generate todaysWomen (3 entries)
↓
DailySuggestionsEngine expands:
3 official
+ up to 7 related
↓
UI renders cards
↓
Detail View

---

# Card Lock Logic

Access is determined by subscription state.

FREE users:
- Some cards locked
- PRO badge displayed

PRO users:
- Full access

---

# Image System

All historical portraits are stored in:

images/cards/

image_card_ID is the canonical reference.

Image URL is dynamically constructed:

https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/{image_card_ID}_01.webp

Google Drive is no longer used for portraits.

---

# Architectural Rules

- Exactly 3 official women per day.
- Home never creates new daily entries.
- Home only expands using related tags.
- Daily Echo is canonical daily source.
- All cards navigate to Detail View.
- Do not modify layout when implementing data logic.

---

# Development Reminder

Before modifying architecture, review:

- project_protocol.md
- daily_workflow.md
- database_rules.md
- CURRENT_STATE.md
- ARCHITECTURE.md

Architecture must remain aligned with real implementation.