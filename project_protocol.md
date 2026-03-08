# Her Echoes – Project Protocol

## Project Vision

Her Echoes is a curated, structured, year-long database highlighting 3 women per day.
The goal is to create a reliable, scalable, non-hallucinated, historically respectful database
that feeds a Flutter application.

This is not a dynamic user-generated platform.
This is a curated knowledge project.

---

## Core Principles

1. Excel is the single source of truth.
2. Columns are frozen unless versioned.
3. No data is ever invented.
4. If information cannot be verified, it remains blank.
5. JSON is a derived technical artifact, not the master.
6. SQLite will only be introduced once schema is fully stable.
7. Weekly Git commits are mandatory for database updates.
8. Structure integrity is more important than speed.

---

## Development Philosophy

- Validate design early with real data.
- Avoid premature architecture complexity.
- Optimize for clarity, not cleverness.
- Maintain portability to other AI systems.

---

## AI Collaboration Rules

Any AI assisting this project must:

- Respect column structure exactly.
- Never generate fictional historical data.
- Explicitly flag uncertainty.
- Follow database_rules.md and daily_workflow.md.

Daily Echo architecture

Cards displayed using card_stack_widget
Swipe direction: vertical

Card structure:
- portrait image
- gradient overlay
- pro tags
- name
- quote

FREE users:
see all cards but only first unlocked


## HOME SCREEN PROTOCOL

The Home screen is independent from the Daily Echo cards.

Home shows:

• Random background portrait of a woman
• Upsell banner depending on subscription state
• Horizontal list of suggested women cards
• Bottom navigation bar

Important distinction:

Home portraits are NOT the same as Daily Echo women.

They are purely decorative inspiration images.

Source of images:
Google Drive

Drive/Mi Unidad/Images/Home

5 images available.

Behavior:
Each time the user opens Home, one image is selected randomly.

These images are not tied to any historical figure or JSON entry.

They are only visual inspiration.

---

## SUBSCRIPTION STATES

The Home screen behaves differently depending on subscription status.

States supported:

FREE
PRO Individual
PRO Family

---

### FREE USER

Home displays:

• Upsell banner: "Inspírate diariamente"
• Banner opens subscription modal

User can see suggested women but locked content remains locked.

---

### PRO INDIVIDUAL

Home displays:

• Upsell banner: "Inspiración para tu familia"
• Banner offers upgrade to Family plan

---

### PRO FAMILY

Home displays:

• No banner
• Full access


## SHOW ALL SCREEN PROTOCOL

The Show All tab allows users to browse the full list of women in the dataset.

Widget used:
vertical_card_pager

Cards appear in a vertical stacked scroll layout.

Card design is identical to Daily Echo cards.

---

### Access rules

PRO users:
• Full access to all cards
• Can tap any card to open Detail View

FREE users:
• Can see all cards visually
• Cards are marked with PRO lock badge
• Detail view is blocked

Tap behavior:

FREE user taps locked card
→ open subscription modal

PRO user taps card
→ open Detail View


## WOMAN CARD PROTOCOL

All content cards in the app represent one woman from the dataset.

Cards are reused in multiple places:

• Daily Echo
• Home carousel
• Show All list
• Favorites

Each card references a single dataset object.

---

### Image Source

Cards use the field:

image_card_ID

Example:

https://drive.google.com/uc?export=view&id=1QopNPnT_qlKOqdWeQopE0M7yicwcEnS8

The same image is reused in:

• Daily Echo cards
• Home mini carousel cards
• Show All cards
• Detail View header image

Images are hosted in Google Drive and served via public view links.

---

### Card Content

Each card displays:

image_card_ID (background image)
full_name
pro-tag01_en
pro-tag02_en

Optional overlay:

PRO badge if content is locked

---

### Detail View

The Detail View has two tabs:

Biography
Legacy

Switching tabs updates the lower content section.

Header image remains fixed.
