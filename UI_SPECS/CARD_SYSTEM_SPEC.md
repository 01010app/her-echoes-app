# CARD_SYSTEM_SPEC.md

HerEchoes — Card System Specification

This document defines the complete card system used across the HerEchoes app.

Cards are the primary UI component of the product.  
Different screens use different card variants, but they all belong to the same system.

The goal of this document is to prevent re-explaining card behavior in future development sessions.

---

# 1. Card System Overview

HerEchoes uses five card variants.

Each variant is optimized for a specific screen and interaction model.

Card variants:

1. Home Mini Card
2. Daily Echo Card
3. Show All Card
4. Favorites Card
5. Card Detail View

All cards represent a woman entry from the historical database.

The only exception is the decorative woman image used in the Home screen background.

---

# 2. Shared Data Source

Cards use data from the database located at:

assets/data/her_echoes.json

Primary fields used by cards:

full_name  
pro-tag01_en  
pro-tag01_es  
pro-tag02_en  
pro-tag02_es  
image_card_ID  
month  
day  
bio_en  
bio_es  
birth_date  
birth_place  
death_date  
death_place

Language selection determines which tag and biography fields are displayed.

---

# 3. Card Access Logic (FREE vs PRO)

Cards may be FREE or PRO.

Behavior for FREE users:

tap free card → open card detail  
tap PRO card → open upgrade modal

Behavior for PRO users:

tap any card → open card detail

This logic applies to all card variants across the app.

---

# 4. Card Variant: Home Mini Card

Screen:

Home

Purpose:

Show quick suggestions of women related to the current day.

Layout:

Horizontal carousel.

Card size:

156 × 156 px

Corner radius:

16 px  
60% squircle corners

Card structure:

background image  
bottom gradient overlay  
title (full_name)  
subtitle (pro-tag01 depending on language)  
optional PRO badge

Gradient overlay:

height: 62 px  
bottom: black at 80% opacity  
top: black at 0% opacity

Text layout:

Title

Font: Gloock  
Size: 14 px  
Line height: 140%  
Color: #FFFFFF  
Single line with ellipsis truncation

Subtitle

Font: Inter  
Size: 11 px  
Line height: 160%  
Color: #FFFFFF at 90% opacity

Interaction:

tap → open CARD_DETAIL

If card is PRO and user is FREE:

tap → open upgrade modal

---

# 5. Card Variant: Daily Echo Card

Screen:

Daily Echo

Purpose:

Display the main inspirational story of the day.

This is the largest card format in the application.

Layout:

Vertical card pager.

Implementation reference:

vertical_card_pager (Flutter package)

Visual structure:

large background image  
rounded corners  
bottom gradient overlay  
profession tags  
full_name  
quote text

Cards appear stacked visually:

active card in front  
next cards behind

Interaction:

vertical swipe → navigate between cards  
tap → open CARD_DETAIL

---

# 6. Card Variant: Show All Card

Screen:

Show All

Purpose:

Allow browsing all women related to the selected day.

Layout:

Vertical scroll list.

Card structure:

background image  
gradient overlay  
full_name  
optional PRO badge

These cards are simpler than Daily Echo cards and optimized for list browsing.

Interaction:

tap → open CARD_DETAIL

---

# 7. Card Variant: Favorites Card

Screen:

Favorites

Purpose:

Display women saved by the user.

Layout:

Two-column grid.

Structure:

image  
rounded corners  
favorite icon in top-right corner

Interaction:

tap card → open CARD_DETAIL  
tap favorite icon → remove from favorites

---

# 8. Card Detail View (CARD)

Screen:

Card Detail View

This is the final screen when opening any card.

All card variants navigate to this view.

---

# Card Detail Layout

Top section:

hero image  
rounded corners  
profession tags  
full_name

Middle section:

tab switcher

Tabs:

Biography  
Legacy

Biography tab contains:

biography text  
birth information  
death information  
historical notes

Legacy tab contains:

impact  
achievements  
historical relevance

---

# Card Detail Actions

Bottom actions:

Share  
Add to Favorites

Behavior:

Share → opens the device share sheet

Add to Favorites → stores entry locally and updates the Favorites screen.

---

# Navigation Flow

Cards across the app follow the same navigation rule.

Home Mini Card  
↓  
Daily Echo Card  
↓  
Show All Card  
↓  
Favorites Card  
↓  
CARD DETAIL VIEW

All variants lead to the same destination.

---

# 9. Image System

Card images are referenced using:

image_card_ID

Images are stored in the project assets.

Recommended format:

webp

Images must be optimized for mobile performance.

---

# 10. Design System Dependencies

Cards rely on the centralized design system located at:

lib/core/theme/

Files:

app_theme.dart  
app_colors.dart  
app_text_styles.dart  
app_shapes.dart

Typography:

Titles → Gloock  
Body → Inter

Icons:

Phosphor

Accent color:

#F70F3D

Background color:

#F5F5F5

---

# 11. Reusable Components

The Flutter project should implement cards using reusable widgets.

Recommended widget structure:

lib/widgets/

Examples:

home_mini_card.dart  
daily_echo_card.dart  
show_all_card.dart  
favorites_card.dart  
card_detail_view.dart

These widgets should reuse shared components whenever possible.

---

# 12. Important Development Rule

Cards must be implemented as reusable components.

Avoid duplicating layout logic across screens.

All card variants should share:

image handling  
gradient overlays  
typography styles  
badge logic  
navigation logic

This ensures visual consistency across the entire app.