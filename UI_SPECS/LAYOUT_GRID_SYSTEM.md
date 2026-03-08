# LAYOUT_GRID_SYSTEM.md

HerEchoes — Layout & Spacing System

This document defines the spacing rules, layout grid and alignment principles used across the HerEchoes interface.

The purpose of this document is to ensure **consistent spacing and visual rhythm across the entire application**.

All UI components must follow this system.

---

# 1. Base Grid Unit

The HerEchoes interface is built using an **8px spacing grid**.

Base unit:

8px

All spacing, margins and padding should preferably be multiples of this unit.

Examples:

8px  
16px  
24px  
32px  
40px

This creates visual consistency across screens.

---

# 2. Core Spacing Values

The most frequently used spacing values in the app are:

8px  
16px  
24px

Meaning:

8px → micro spacing  
16px → component spacing  
24px → section spacing

---

# 3. Screen Horizontal Margins

Standard screen margin:

16px

Used in:

Headers  
Text blocks  
Content sections  
Cards (when not full-width)

Example:

Screen edge  
↓  
16px margin  
↓  
Content

---

# 4. Section Vertical Spacing

Major vertical separation between sections:

24px

Examples:

Distance between carousel and title  
Distance between title and banner  
Distance between components on screen

---

# 5. Micro Spacing

Small internal spacing inside components.

Standard value:

8px

Used in:

Card text padding  
Icon spacing  
Internal component padding

---

# 6. Component Internal Padding

Typical padding values inside components:

Small components:

8px

Medium components:

12px

Large components:

16px

Example:

Mini cards text container uses:

8px padding

---

# 7. Floating Components

Floating UI elements maintain a consistent spacing rule.

Example:

Floating tab bar distance from screen bottom:

24px

This ensures floating components visually separate from the screen edge.

---

# 8. Card Spacing

Spacing between cards:

8px

Used in:

Home carousel  
Favorites grid  
Card lists

---

# 9. Carousel Start Offset

Horizontal carousels start with a left margin:

16px

This aligns the carousel with the global screen margin.

---

# 10. Content Alignment

Content should align to the same vertical rhythm.

Key alignment anchors:

Header baseline  
Section titles  
Card edges  
Screen margins

Avoid misaligned elements that break the layout rhythm.

---

# 11. Safe Areas

UI elements must respect device safe areas.

Important areas:

Top safe area → status bar / notch  
Bottom safe area → gesture area

Floating elements may visually overlap the safe area if required by the design.

Example:

Floating tab bar partially overlaps the bottom OS navigation area.

---

# 12. Responsive Behavior

Layouts must adapt to different screen sizes while preserving spacing relationships.

Key rules:

Maintain horizontal margins  
Maintain card spacing  
Maintain section spacing

Images and cards may scale but spacing rhythm should remain consistent.

---

# 13. Design System Dependency

Spacing values should be centralized in the design system.

Recommended implementation:

lib/core/core/theme/app_spacing.dart

Example constants:

spacingXS = 8  
spacingS = 16  
spacingM = 24  
spacingL = 32

This prevents hard-coded spacing values across widgets.