# HerEchoes — Home Screen Specification (v2)

This document defines the official structure, layering, layout rules, and behavior of the Home screen.

This file is the single source of truth for Home implementation.

No visual behavior should be implemented outside what is defined here.

---

# 1. Purpose of Home Screen

The Home screen is an engagement surface, not the primary reading interface.

It introduces emotional tone and invites exploration.

The large background woman image:

• is purely decorative  
• is NOT connected to the historical dataset  
• does NOT represent any Daily Echo entry

All real historical data appears in:

• Daily Echo  
• Show All  
• Favorites

---

# 2. Layer Architecture (Z-Index Order)

From back to front:

1. Decorative Home Woman Image
2. Top Gradient Overlay (370px)
3. Header
4. Upgrade Banner
5. Suggestions Title
6. Suggestions Carousel
7. Floating Tab Bar

The Floating Tab Bar must always render above Home content.

---

# 3. Decorative Home Woman Image

Purpose: emotional engagement.

Behavior:

• Full device width (100%)  
• Height: auto (natural image ratio)  
• Aligned to top of screen  
• May extend behind status bar  
• Randomly selected from 5 predefined images

Important:

These images are not part of the JSON dataset.

They are stored separately.

No tint overlay in production.

---

# 4. Top Gradient Overlay

Height: 370px  
Width: 100% of device

Position:

The bottom of the gradient aligns exactly with the beginning of the structured content (where the Upgrade Banner starts).

Gradient:

Bottom:
#F5F5F5 at 100% opacity

Top:
#F5F5F5 at 0% opacity

Purpose:

Create smooth visual transition from decorative image into structured UI.

---

# 5. Header

Height: 48px  
Width: 100%  
Horizontal padding: 16px

Left element:

App logo (SVG)  
Accent color: #F70F3D

Right element:

Phosphor icon  
Name: sliders-horizontal  
Size: 28px  
Color: #F70F3D

Header sits visually above gradient and background image.

---

# 6. Upgrade Banner

Position:

Below the gradient zone.

Spacing:

24px above Suggestions Title.

Horizontal margins:

24px left and right.

Height:

80px.

Behavior:

FREE user:
→ show "Inspírate diariamente"

PRO Individual:
→ show family upgrade banner

PRO Family:
→ banner hidden

The banner visually floats above the decorative background.

---

# 7. Suggestions Title

Text:

Spanish:
"Sugerencias de hoy"

English:
"Today's suggestions"

Typography:

Font: Gloock  
Size: 18px  
Line height: 140%  
Letter spacing: -1%  
Color: #404040

Spacing:

24px above carousel.  
Aligned to screen content margin (not centered).

---

# 8. Suggestions Carousel

Type:

Horizontal scroll.

Position:

Begins 24px above the Floating Tab Bar top edge.

Behavior:

• Snap per card  
• Magnetic stopping  
• Infinite loop illusion

Spacing:

Left margin before first card: 16px  
Space between cards: 8px

---

# 9. Mini Card Specifications

Size:

156px × 156px

Corner radius:

Superellipse (60% squircle)

Image behavior:

• Fills width  
• Top-aligned  
• May use negative top offset for face framing

Gradient overlay inside card:

Height: 62px  
Bottom-aligned  
Black 80% → transparent

Text padding:

Left: 8px  
Right: 8px  
Bottom: 8px

Title:

Font: Gloock  
Size: 14px  
Line height: 140%  
Letter spacing: -1%  
Single line  
Ellipsis

Subtitle:

Font: Inter  
Size: 11px  
Line height: 140%  
White at 90% opacity

---

# 10. Floating Tab Bar (Critical)

The Floating Tab Bar is NOT attached to the OS bottom.

It floats independently.

Rules:

• Bottom spacing from device bottom: 24px  
• Width: 300px (centered horizontally)  
• Height: 61px  
• Rounded container  
• Elevated (shadow)  
• Independent from safe area

It must remain visible at all times.

The Home carousel visually intersects behind it.

---

# 11. Layout Anchoring Rule

The carousel and content must visually overlap behind the Floating Tab Bar.

However:

The first card must remain fully visible above it.

The Tab Bar never blocks card interaction.

---

# 12. Android Medium Rule

For Android Medium devices:

• Decorative image aligns to left  
• Maximum width: 396px  
• Gradient remains 100% width

This preserves visual composition.

---

# 13. Language System

Detect device primary language.

Spanish → load Spanish labels.  
Otherwise → default to English.

Profession field mapping:

English:
pro-tag01_en

Spanish:
pro-tag01_es

---

# 14. Implementation Constraints

Do NOT:

• Connect decorative image to dataset  
• Attach Tab Bar to Scaffold bottomNavigationBar  
• Use system TabBar

The Floating Tab Bar must be custom implemented.

---

# END OF SPEC

---## Structural Rule Clarification

The 264px measurement refers to real structural layout space from the device bottom.

It is NOT a visual mask or overlay trick.

The layout must be constructed bottom-up:

1. FloatingTabBar
2. Content zone
3. Decorative background
4. Gradient overlay

Never construct from decorative layer downward.

---

## Structural Rule Clarification

The 264px measurement refers to real structural layout space from the device bottom.

It is NOT a visual mask or overlay trick.

The layout must be constructed bottom-up:

1. FloatingTabBar
2. Content zone
3. Decorative background
4. Gradient overlay

Never construct from decorative layer downward.