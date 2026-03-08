# DATA_MODEL_SPEC.md

HerEchoes — Data Model Specification

This document defines the data structures used in the HerEchoes application.

It explains how historical data is stored, how it is filtered, and how it is consumed by the UI.

The goal is to ensure consistent data handling across the app and avoid ambiguity when implementing features.

---

# 1. Primary Data Source

The main historical dataset is stored locally.

Location:

assets/data/her_echoes.json

This JSON file contains all historical entries displayed in the app.

Each entry represents a **woman connected to a specific day of the year**.

---

# 2. Data Pipeline

The application follows this pipeline:

Load JSON database  
↓  
Parse entries into objects  
↓  
Filter by current month and day  
↓  
Generate todaysWomen dataset  
↓  
Render cards in UI

The dataset `todaysWomen` is the primary data source used by the Home and Daily Echo screens.

---

# 3. Core Entity

The main data entity is:

Woman

Each JSON entry represents one Woman object.

Example structure:

{
"id": "001",
"full_name": "Marie Curie",
"pro-tag01_en": "Physicist",
"pro-tag01_es": "Física",
"pro-tag02_en": "Chemist",
"pro-tag02_es": "Química",
"month": 11,
"day": 7,
"image_card_ID": "marie_curie",
"bio_en": "...",
"bio_es": "...",
"legacy_en": "...",
"legacy_es": "...",
"birth_date": "1867",
"birth_place": "Warsaw, Poland",
"death_date": "1934",
"death_place": "Passy, France",
"is_pro": false
}

---

# 4. Required Fields

The following fields are mandatory.

id  
full_name  
month  
day  
image_card_ID

Without these fields the entry cannot render properly in the app.

---

# 5. Localization Fields

HerEchoes supports multiple languages.

Currently supported languages:

English  
Spanish

Language-dependent fields:

pro-tag01_en  
pro-tag01_es  
pro-tag02_en  
pro-tag02_es

bio_en  
bio_es

legacy_en  
legacy_es

The app selects which field to display based on the user's language.

---

# 6. Date System

The app organizes historical entries by calendar day.

Fields used:

month  
day

Example:

month: 3  
day: 4

This entry will appear on:

March 4.

The filtering rule is:

if entry.month == today.month AND entry.day == today.day  
→ include entry in todaysWomen.

---

# 7. Image System

Images are referenced through:

image_card_ID

Example:

"image_card_ID": "marie_curie"

The app resolves the corresponding image asset.

Recommended path structure:

assets/images/cards/

Example file:

assets/images/cards/marie_curie.webp

Image format:

webp

This format ensures efficient mobile performance.

---

# 8. PRO Content Flag

Some entries may be restricted to PRO users.

Field:

is_pro

Possible values:

true  
false

Behavior:

is_pro: false  
→ visible to all users

is_pro: true  
→ locked for FREE users

If a FREE user taps a PRO entry:

open Paywall modal.

---

# 9. Derived Dataset: todaysWomen

This dataset is created dynamically after filtering the JSON file.

Structure:

todaysWomen = [Woman, Woman, Woman]

This dataset is used by:

Home carousel  
Daily Echo screen  
Show All screen

---

# 10. Favorites Data

Favorites are stored locally on the device.

Suggested structure:

favorites = [id, id, id]

Each favorite references the id of a Woman entry.

Example:

favorites = ["001", "023", "117"]

When rendering Favorites screen:

filter dataset by ids contained in favorites.

---

# 11. Subscription Data

User subscription status determines content access.

Possible values:

FREE  
PRO_INDIVIDUAL  
PRO_FAMILY

Behavior:

FREE  
→ locked cards remain inaccessible

PRO_INDIVIDUAL  
→ full card access

PRO_FAMILY  
→ full card access + no upgrade banners

---

# 12. Settings Data

User preferences may include:

language  
notifications_enabled  
dark_mode_enabled

Example structure:

{
"language": "en",
"notifications_enabled": true,
"dark_mode_enabled": false
}

These values are stored locally.

---

# 13. Data Validation Rules

Entries should follow these rules:

full_name must not be empty.

month must be between:

1 and 12.

day must be between:

1 and 31.

bio and legacy fields should contain readable text.

image_card_ID must match an existing asset.

---

# 14. Performance Considerations

The dataset should remain lightweight.

Recommended limits:

< 1MB JSON file.

Images should be optimized.

Recommended image size:

under 200KB.

---

# 15. Future Data Extensions

Possible future fields may include:

quote_en  
quote_es

occupation_category

historical_period

external_references

These fields must remain optional to maintain backward compatibility.

---

# 16. Development Rule

The JSON database is the **single source of truth** for historical entries.

UI components must not hardcode historical data.

All content must come from the data model.

Any schema changes must update this document.