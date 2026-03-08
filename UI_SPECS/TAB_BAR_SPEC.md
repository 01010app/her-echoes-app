# TAB_BAR_SPEC.md

HerEchoes — Floating Tab Bar Specification

This document defines the design and behavior of the floating tab bar used across the HerEchoes app.

The tab bar is a custom component and is **independent from the OS tab bar**.

---

# 1. Component Overview

The HerEchoes tab bar is a **floating navigation container** that provides access to the four main sections of the app:

• Home  
• Daily Echo  
• Show All  
• Favorites

The component floats above the screen content and is visually separated from the system UI.

---

# 2. Container Dimensions

Width:

300px

Height:

61px

Background color:

#FFFFFF

Corner radius:

20px

Corner smoothing:

60% squircle

---

# 3. Container Position

The tab bar floats above the bottom of the screen.

Distance from bottom edge:

24px

Important:

This distance is measured from the **screen edge**, not the OS tab bar.

The component may visually overlap the OS tab bar area.

---

# 4. Container Shadow

Shadow specification equivalent to CSS:

box-shadow:
rgba(50, 50, 93, 0.25) 0px 30px 60px -12px,
rgba(0, 0, 0, 0.3) 0px 18px 36px -18px;

Purpose:

Create a floating effect separating the tab bar from the content background.

---

# 5. Internal Layout

The tab bar contains **four navigation buttons**.

Buttons:

Home  
Daily Echo  
Show All  
Favorites

Spanish labels:

Home  
Daily echo  
Show all  
Favoritos

Each button has identical dimensions.

Button size:

72px width  
49px height

The four buttons together create the total width of the container.

---

# 6. Button Structure

Each button contains two elements stacked vertically:

1. Icon
2. Label

Layout:

Icon  
↓  
1px gap  
↓  
Text label

Both elements are horizontally centered.

---

# 7. Icon Specification

Icon library:

Phosphor

Icon size:

28px × 28px

Icons used:

Home → house  
Daily Echo → calendar  
Show All → stack or cards icon  
Favorites → heart

---

# 8. Label Typography

Font:

Inter

Weight:

Medium

Font size:

10px

Line height:

12px

Alignment:

Centered

---

# 9. Button States

Buttons have two states:

Active  
Inactive

---

# 10. Active State

Background color:

#F70F3D

Icon color:

#FFFFFF

Text color:

#FFFFFF

Corner radius:

16px

Corner smoothing:

60% squircle

Internal vertical padding:

4px top  
4px bottom

---

# 11. Inactive State

Background color:

#FFFFFF

Icon color:

#BBBBBB

Text color:

#BBBBBB

No background highlight.

---

# 12. Interaction Behavior

When a tab is pressed:

• The selected button transitions to **Active state**
• The previous active button returns to **Inactive state**
• The app navigates to the corresponding screen

Navigation mapping:

Home → Home screen  
Daily Echo → Daily Echo screen  
Show All → Show All screen  
Favorites → Favorites screen

---

# 13. Layout Behavior

The tab bar must remain **fixed and floating** across the entire app.

It should remain visible while navigating between the four main screens.

Screens displayed above the tab bar include:

Home  
Daily Echo  
Show All  
Favorites

The tab bar should **not appear** on:

Card Detail view (CARD)

The detail view takes full screen control.

---

# 14. Design System Dependencies

The tab bar uses the centralized design system.

Location:

lib/core/theme/

Key dependencies:

app_colors.dart  
app_text_styles.dart  
app_shapes.dart

Accent color:

#F70F3D

Primary neutral color:

#6D6D6D