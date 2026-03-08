# PAYWALL_SPEC.md

HerEchoes — Paywall & Subscription System Specification

This document defines the paywall behavior, subscription tiers, upgrade flows, and UI patterns used for monetization in the HerEchoes app.

The goal is to ensure consistent implementation of subscription logic and upsell experiences across the app.

---

# 1. Subscription Tiers

HerEchoes supports three user tiers.

FREE  
PRO Individual  
PRO Family

---

## FREE

Access:

• Limited card access 

Behavior:

If a FREE user taps a PRO card:

open Paywall Modal.

FREE users will frequently see upgrade prompts such as:

• upgrade banner in Settings  
• PRO badge on cards  
• upgrade modal when accessing locked content

---

## PRO Individual

Access:

• Full content access  
• No locked cards

Behavior:

Users can access all cards but may still see:

• upgrade offers to PRO Family plan

The Settings banner may still show an upgrade prompt.

---

## PRO Family

Access:

• Full content access  
• No upsell prompts

Behavior:

The upgrade banner must NOT appear for PRO Family users.

PRO Family represents the highest tier.

---

# 2. Paywall Entry Points

The paywall may appear from several locations in the app.

---

## Locked Content

Trigger:

FREE user taps a PRO card.

Flow:

tap PRO card  
↓  
open paywall modal

---

## Settings Upgrade Banner

Trigger:

FREE or PRO Individual users.

Flow:

tap banner button  
↓  
open paywall modal

---

## Subscription Section (Settings → Payment)

Trigger:

User navigates to:

Settings → Pago → Plan contratado

Flow:

tap upgrade option  
↓  
open paywall modal

---

# 3. Paywall UI Layout

The paywall appears as a modal sheet or full-screen overlay.

Purpose:

Explain benefits and allow subscription purchase.

Recommended structure:

Hero message  
Feature list  
Pricing options  
Call-to-action button  
Close button

---

# 4. Paywall Content Structure

Hero title

Example:

"From daily ads to daily inspiration."

Short description

Example:

"Hundreds of inspiring stories every day without ads."

Feature highlights

Examples:

• Unlimited historical stories  
• Daily inspiration  
• No advertisements  
• Family sharing (PRO Family)

---

# 5. Plan Options

The paywall should present two plan options.

---

## Individual Plan

Access for one user.

Example pricing structure:

Annual plan  
or  
Monthly plan

Displayed information:

Plan name  
Price  
Billing frequency

Example:

Individual  
$16.800 / year

---

## Family Plan

Access for multiple users.

Example:

Up to 3 family members.

Displayed information:

Plan name  
Price  
Maximum users

Example:

Family  
$18.500 / year

---

# 6. CTA Buttons

Primary CTA

Subscribe or Upgrade

Example labels:

Subscribe  
Upgrade to PRO  
Start free trial

Button style:

Accent color

#F70F3D

Typography

Inter Semibold

---

# 7. Close Behavior

The paywall must include a close option.

Icon:

Phosphor close icon.

Behavior:

close modal  
return to previous screen

For locked content:

closing returns user to previous screen without unlocking content.

---

# 8. Trial Logic

Optional free trial:

Example:

7-day trial

Behavior:

User enters trial period.

After trial ends:

subscription billing begins automatically.

---

# 9. Upgrade Flow

Upgrade flow:

tap upgrade CTA  
↓  
confirm purchase  
↓  
payment provider  
↓  
success  
↓  
unlock PRO features

The app must immediately refresh UI state after upgrade.

---

# 10. Downgrade Flow

Downgrades occur through system subscription management.

Behavior:

User may cancel subscription through platform billing settings.

When subscription expires:

user returns to FREE tier.

---

# 11. UI Indicators for Locked Content

PRO cards must display a badge.

Badge label:

PRO

Badge icon:

Lock icon

Color:

Accent red

#F70F3D

This visually signals restricted content.

---

# 12. Upgrade Banner Logic

Visible for:

FREE users  
PRO Individual users

Hidden for:

PRO Family users

Dismiss behavior:

User may close banner temporarily.

Recommended behavior:

Banner reappears after time delay (ex: 24 hours).

---

# 13. Payment Providers

Recommended implementation:

iOS:

Apple In-App Purchases

Android:

Google Play Billing

External payment systems should be avoided when possible due to platform restrictions.

---

# 14. Analytics Events

The following events should be tracked.

Paywall opened  
Paywall closed  
Upgrade started  
Upgrade successful  
Upgrade failed

This data helps evaluate monetization performance.

---

# 15. UX Principles

Paywall should feel:

• clear  
• respectful  
• persuasive but not aggressive

Avoid:

• blocking core navigation excessively  
• repetitive popups

The goal is to encourage upgrading while maintaining a positive user experience.

---

# 16. Design System Dependencies

Paywall components should follow:

LAYOUT_GRID_SYSTEM.md  
ANIMATION_SYSTEM.md  
CARD_SYSTEM_SPEC.md

Typography:

Inter

Accent color:

#F70F3D