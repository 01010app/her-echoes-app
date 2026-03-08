# SETTINGS_UI_SPEC.md

HerEchoes — Settings Screen Specification

This document defines the layout, structure, and behavior of the Settings system used in the HerEchoes application.

The Settings system allows users to manage preferences, billing, notifications, appearance, and app information.

---

# 1. Header

The Settings header is a reusable component shared across system configuration screens.

Height

48px

Background color

#FFFFFF

Horizontal padding

16px

---

## Header Layout

The header contains three elements aligned horizontally:

1. Back button
2. Screen title
3. Optional action button (usually hidden)

Spacing between these elements must respect an **8px internal gutter**.

---

## Back Button

Icon:

Phosphor `arrow-left`

Icon size:

20px × 20px

Icon color:

#F70F3D

Container:

Circular container

Diameter:

48px

Background color:

#F5F5F5

Shape:

Circle (no squircle)

---

## Title

Typography

Font: Inter  
Weight: Semibold  
Size: 18px  
Line height: 150%  
Letter spacing: -0.5px  
Color: #404040

Alignment:

Centered within the available header space.

---

## Optional Right Button

Reserved space:

44px

Most screens do not display this element.

Reserved to support future actions.

---

# 2. Screen Layout

Main content begins below the header.

Spacing from header to first element:

24px

Standard horizontal margin:

16px

All settings lists must respect this margin.

---

# 3. Upgrade Banner

The upgrade banner is visible only for:

FREE users  
PRO Individual users

The banner is **not shown to PRO Family users**.

---

## Banner Dimensions

Horizontal margins

16px

Top margin

24px

Height

≈ 180–181px (iPhone 14/15 reference)

Internal padding

16px

Border radius

16px

Corner smoothing

60% squircle

---

## Banner Layout

The banner is structured in **two rows**.

Row 1 → Content + Close button  
Row 2 → CTA button

---

## Row 1 Layout

Two columns.

Gap between columns:

16px

Left column:

Title + Description

Right column:

Close button

---

### Banner Title

Typography

Font: Inter  
Weight: Semibold  
Size: 22px  
Line height: 120%  
Letter spacing: -1%  
Color: #FFFFFF

---

### Banner Description

Spacing from title:

8px

Typography

Font: Inter  
Weight: Medium  
Size: 13px  
Line height: 150%  
Letter spacing: -0.5px  
Color: #FFFFFF

---

### Banner Close Button

Icon:

Phosphor `close`

Weight:

Bold

Size:

20px

Color:

#FFFFFF

Purpose:

Temporarily dismiss banner.

Recommended behavior:

Banner reappears after a time delay or after next session.

---

## Banner CTA Button

Background color

#FFFFFF

Text color

#E1002D

Typography

Font: Inter  
Weight: Semibold  
Size: 14px  
Line height: 150%  
Letter spacing: 0px

Padding

Vertical: 8px  
Horizontal: 16px

Height

37px

Border radius

12px

Corner smoothing

60% squircle

Alignment

Centered

---

# 4. Settings Sections

Settings are organized into **sections**.

A section consists of:

Section title (h3)  
List container (ul)

Spacing rules:

Section title → list

16px

Between list containers

8px

Between sections

32px

---

# 5. Section Title (h3)

Typography

Font: Inter  
Weight: Semibold  
Size: 18px  
Line height: 140%  
Letter spacing: -0.5px  
Color: #404040

---

# 6. Settings List Container (ul)

Background color

#FFFFFF

Border

0.5px solid #D6D6D6

Border radius

16px

Padding

Top: 4px  
Bottom: 4px  
Left: 16px  
Right: 0px

---

# 7. List Items (li)

Minimum height

56px

Padding

Top: 16px  
Bottom: 16px  
Right: 16px  
Left: 0px

Structure

Icon (optional)  
Text label  
Optional description  
Chevron icon

---

# 8. List Item Icons

Icon library

Phosphor

Size

24px × 24px

Color

#949494

Spacing between icon and label

8px

---

# 9. List Item Label

Typography

Font: Inter  
Weight: Medium  
Size: 16px  
Line height: 150%  
Letter spacing: -0.5px  
Color: #434343

---

# 10. List Item Chevron

Icon:

Phosphor `caret-right`

Weight:

Bold

Size

20px

Color

#F70F3D

---

# 11. Optional Description Text

Some items may show additional context text.

Example

Subscription remaining days  
Selected language

Typography

Font: Inter  
Weight: Regular  
Size: 11px  
Line height: 150%  
Letter spacing: -0.5px  
Color: #787575

Alignment

Right side

Maximum width

120px

Overflow behavior

Ellipsis truncation

---

# 12. Item Separators

Each list item displays a bottom divider.

Divider color

#D6D6D6

Thickness

0.5px

Left offset

16px

Right offset

0px

The **last item in a list has no divider**.

---

# 13. Error State

If a configuration error occurs:

Icon color

#E20000

Text color

#E20000

Chevron color

Remains #F70F3D

---

# 14. Delete App Button

The "Delete App" item behaves differently from other items.

It does not display:

Chevron  
Icon

Typography

Font: Inter  
Weight: Medium  
Size: 16px  
Line height: 150%  
Letter spacing: -0.5px  
Color: #E20000

This visually communicates a destructive action.

---

# 15. App Version Label

A version label appears at the bottom of the screen.

Position

8px above the OS tab bar

Alignment

Centered

Typography

Font: Inter  
Weight: Regular  
Size: 11px  
Line height: 150%  
Letter spacing: -0.5px  
Color: #787575

Example

Version 1.0.0

---

# 16. Hidden Admin Access

The version label may function as a hidden admin trigger.

Suggested behavior:

If the version label is tapped **20 times within 30 seconds**, the app enters:

Admin Mode  
or Debug Mode

This allows internal testing without exposing developer tools to regular users.

---

# 17. Navigation Structure

Settings navigation hierarchy.

Settings

↓

Configuración del sistema

↓

Preferencias

↓

Notificaciones  
Idioma  
Apariencia

---

# 18. Preferences Subsections

## Notifications

Option:

Recibir notificaciones

Control type

Toggle switch

---

## Language

Options

Español  
English

Control type

Toggle selector

---

## Appearance

Option

Dark Mode

Control type

Toggle switch

---

# 19. Payment Section

Pago

Subsections:

Plan contratado  
Facturación

---

## Plan contratado

Displays current plan.

Includes:

Plan name  
Short description  
Upgrade option

---

## Facturación

Items:

Medios de pago 01  
Medios de pago 02  
Agregar medio de pago  
Agregar tarjeta

---

# 20. Legal Section

Términos y Condiciones

Displays legal information text.

---

# 21. About Section

Acerca de Her Echoes

Displays information about the project and mission.

---

# 22. Development Notes

Settings must follow spacing defined in:

LAYOUT_GRID_SYSTEM.md

Animations must follow:

ANIMATION_SYSTEM.md

Icons must follow:

Phosphor icon library.

Typography must follow:

Inter font system defined in the design system.