# COMPONENT_HIERARCHY.md

HerEchoes — UI Component Hierarchy

This document defines the structural hierarchy of UI components used in the HerEchoes Flutter application.

The goal is to ensure that all UI elements are built using **reusable and predictable component structures**.

This file acts as a blueprint for developers and AI systems generating Flutter code.

---

# 1. Architecture Philosophy

HerEchoes UI is built using **composable components**.

Each screen is constructed from reusable building blocks.

Hierarchy pattern:

Screen  
↓  
Section  
↓  
Component  
↓  
Subcomponent  
↓  
Primitive UI element

This approach ensures:

• consistency  
• maintainability  
• predictable layouts  
• reusable widgets

---

# 2. Root App Structure

The main app structure follows this hierarchy.

App
↓
MainNavigation
↓
Screens

Screens:

HomeScreen  
DailyEchoScreen  
ShowAllScreen  
FavoritesScreen  
CardDetailScreen

The floating TabBar remains visible across the first four screens.

---

# 3. Home Screen Component Tree

HomeScreen

↓

HomeHeader

↓

HomeHeroSection

↓

HomeGradientOverlay

↓

UpgradeBanner

↓

SuggestionsTitle

↓

SuggestionsCarousel

↓

HomeMiniCard

---

# 4. Home Mini Card Component

HomeMiniCard is the smallest card component.

Structure:

HomeMiniCard

↓

CardContainer

↓

BackgroundImage

↓

GradientOverlay

↓

CardTextContainer

↓

TitleText

↓

SubtitleText

Optional:

ProBadge

Interaction:

tap → navigate to CardDetailView

---

# 5. Daily Echo Screen Component Tree

DailyEchoScreen

↓

DailyEchoHeader

↓

VerticalCardPager

↓

DailyEchoCard

DailyEchoCard structure:

CardContainer

↓

BackgroundImage

↓

GradientOverlay

↓

CardContent

↓

ProfessionTags

↓

TitleText

↓

QuoteText

Interaction:

vertical swipe → next card

tap → open CardDetailView

---

# 6. Show All Screen Component Tree

ShowAllScreen

↓

ScreenHeader

↓

CardList

↓

ShowAllCard

ShowAllCard structure:

CardContainer

↓

BackgroundImage

↓

GradientOverlay

↓

TitleText

↓

ProBadge (optional)

Interaction:

tap → open CardDetailView

---

# 7. Favorites Screen Component Tree

FavoritesScreen

↓

ScreenHeader

↓

FavoritesGrid

↓

FavoriteCard

FavoriteCard structure:

CardContainer

↓

BackgroundImage

↓

FavoriteIcon

↓

TitleOverlay (optional)

Interaction:

tap → open CardDetailView

tap favorite icon → remove from favorites

---

# 8. Card Detail Screen Component Tree

CardDetailScreen

↓

HeroImageSection

↓

CardTitleBlock

↓

ProfessionTags

↓

FullName

↓

ContentTabs

Tabs:

BiographyTab  
LegacyTab

BiographyTab structure:

BiographyText  
BirthInformation  
DeathInformation  
HistoricalNotes

LegacyTab structure:

ImpactText  
Achievements  
HistoricalRelevance

---

# 9. Floating Tab Bar Component

FloatingTabBar

↓

TabBarContainer

↓

TabButton (x4)

Tab buttons:

HomeTab  
DailyEchoTab  
ShowAllTab  
FavoritesTab

TabButton structure:

TabButtonContainer

↓

Icon

↓

Label

States:

Active  
Inactive

---

# 10. Shared Card Subcomponents

Cards share reusable building blocks.

Common elements:

CardContainer  
BackgroundImage  
GradientOverlay  
CardTextContainer  
TitleText  
SubtitleText  
ProBadge

These elements should be implemented as reusable widgets.

---

# 11. Design System Dependencies

All components must use the centralized design system.

Location:

lib/core/theme/

Key files:

app_theme.dart  
app_colors.dart  
app_text_styles.dart  
app_shapes.dart

Spacing values should follow:

LAYOUT_GRID_SYSTEM.md

Animations should follow:

ANIMATION_SYSTEM.md

---

# 12. Navigation Flow

The navigation hierarchy follows this structure.

HomeMiniCard
↓
DailyEchoCard
↓
ShowAllCard
↓
FavoriteCard
↓
CardDetailScreen

All card variants open the same detail view.

---

# 13. Implementation Recommendation (Flutter)

Recommended widget organization:

lib/

core/
theme/

widgets/

cards/
home_mini_card.dart
daily_echo_card.dart
show_all_card.dart
favorite_card.dart

navigation/
floating_tab_bar.dart

sections/
home_hero_section.dart
suggestions_carousel.dart

screens/
home_screen.dart
daily_echo_screen.dart
show_all_screen.dart
favorites_screen.dart
card_detail_screen.dart

---

# 14. Development Rule

Every visual element should be built using reusable components.

Avoid creating one-off UI widgets that duplicate logic.

If two screens share visual behavior, extract a reusable component.

This ensures long-term maintainability of the HerEchoes interface.