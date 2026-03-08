# PROJECT_MAP.md

## Project
HerEchoes

Flutter mobile app that displays women in history associated with the current day of the year.

Example:

March 4 → women connected to March 4 events

---

# Core Concept

The app loads a local historical dataset and filters it by today's date.

Pipeline:

JSON database
↓
Load dataset
↓
Filter by month/day
↓
Generate todaysWomen
↓
Render UI cards

`todaysWomen` is the main dataset used by the UI.

---

# Repository Structure

Target structure (after theme refactor):

lib/

core/
theme/
app_theme.dart
app_colors.dart
app_text_styles.dart
app_shapes.dart

widgets/
woman_card_widget.dart

screens/
home/
show_all/
favorites/

models/

services/

utils/

main.dart

---

# Key Directories

## lib/core

Core infrastructure shared across the entire app.

core/
theme/

Contains the design system.

---

## lib/widgets

Reusable UI components.

Main component:

woman_card_widget.dart

Displays:

- background image
- gradient overlay
- profession tags
- woman's name
- optional PRO badge

This widget is reused across screens.

---

## lib/screens

Application screens.

Planned structure:

screens/

home/
show_all/
favorites/

### Home

Displays:

todaysWomen

Planned UI:

- horizontal carousel
- featured cards

---

### Show All

Displays the full list for the current day.

---

### Favorites

User saved women.

Future feature.

---

## lib/models

Data models representing database entries.

Expected model:

Woman

Example fields:

full_name
pro-tag01_en
pro-tag02_en
image_card_ID
month
day

---

## lib/services

Responsible for loading and transforming data.

Expected responsibilities:

Load JSON database
Filter by date
Return todaysWomen

---

## lib/utils

Utility helpers.

Possible future uses:

- date helpers
- tag formatting
- image helpers

---

# Data Source

Local JSON database:

assets/data/her_echoes.json

Each entry represents a historical woman.

Example fields:

full_name
pro-tag01_en
pro-tag02_en
image_card_ID
month
day

---

# Data Flow

her_echoes.json
↓
Database Loader
↓
Filter by current date
↓
todaysWomen
↓
UI
↓
WomanCardWidget

---

# Design System

Location:

lib/core/theme/

Files:

app_theme.dart
app_colors.dart
app_text_styles.dart
app_shapes.dart

---

## Typography

Body:

Inter

Titles:

Gloock

---

## Colors

Accent:

#F70F3D

Background:

#F5F5F5

---

## Icons

Phosphor

---

## Shapes

Squircle-style corners implemented with:

superellipse_shape

---

# Core UI Component

Main reusable widget:

WomanCardWidget

Displays:

background image
gradient overlay
profession tags
woman name
PRO badge

This component will be reused in:

Home
Show All
Favorites

---

# Current Development Stage

Next milestone:

Render todaysWomen on the Home screen

Steps:

1. Load JSON
2. Generate todaysWomen
3. Render cards using WomanCardWidget

---

# Planned Features

### Home Carousel

Horizontal scroll of today's women.

---

### Show All Screen

Full list view for the current day.

---

### Favorites System

Users can save women.

Future persistence options:

local storage
cloud sync

---

# Development Rules

Follow these rules when modifying the project:

- never break working features
- prefer small changes
- avoid unnecessary refactoring
- explain exactly where to edit files
- assume the developer is not an expert programmer

---

# Immediate Refactor

Before adding new features:

Move:

lib/theme/

To:

lib/core/theme/

Then update imports.

Example:

Before:

import '../core/theme/app_colors.dart';

After:

import '../core/theme/app_colors.dart';

Then run:

flutter clean
flutter pub get
flutter run

Do not change working logic.

---

# Development Workflow

Before making architectural decisions, review:

project_protocol.md
database_rules.md
daily_workflow.md
CURRENT_STATE.md
ARCHITECTURE.md
dev_roadmap.md

These files define the project's constraints and roadmap.

---

# Security Reminder

After debugging or public testing:

Set the GitHub repository back to private.


## Navigation

lib/widgets/navigation/
floating_tab_bar.dart

FloatingTabBar is a custom floating component.
It must never be attached to Scaffold.bottomNavigationBar.


---

Home
├── Header
├── Suggestions Section
│    ├── Title (Gloock)
│    ├── Carousel (156px height)
│    ├── HomeMiniCard (156x156)
│
└── FloatingTabBar

Pendiente:
Daily Suggestions Engine (data layer)