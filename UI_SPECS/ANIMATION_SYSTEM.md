# ANIMATION_SYSTEM.md

HerEchoes — Animation System

This document defines the animation philosophy and motion behavior used across the HerEchoes application.

Animations in HerEchoes are designed to feel:

• elegant  
• subtle  
• responsive  
• emotionally engaging

Motion should **support storytelling and discovery**, not distract from it.

The system is intentionally **dynamic and flexible**, allowing components to adapt animation timing based on context.

---

# 1. Core Animation Principles

HerEchoes animations follow four main principles.

1. Clarity  
   Animations should help the user understand interface changes.

2. Continuity  
   Elements should move in ways that feel physically coherent.

3. Subtlety  
   Animations should be smooth and elegant, never exaggerated.

4. Responsiveness  
   Animations should react immediately to user interaction.

---

# 2. Motion Personality

The motion style of HerEchoes should feel:

• soft  
• fluid  
• calm  
• organic

Transitions should avoid sharp mechanical movement.

Preferred motion curves:

easeOut  
easeInOut  
fastOutSlowIn

---

# 3. Animation Durations

Durations should stay within these ranges.

Micro interactions:

120ms – 180ms

Component transitions:

200ms – 300ms

Screen transitions:

300ms – 400ms

Large storytelling transitions:

400ms – 500ms

Animations should adapt dynamically depending on device performance.

---

# 4. Easing Curves

Recommended easing curves:

Standard UI interactions

easeOut

Screen transitions

easeInOut

Card movements and gestures

fastOutSlowIn

The goal is to create **smooth acceleration and natural deceleration**.

---

# 5. Interaction Feedback Animations

Interactive elements should provide immediate feedback.

Examples:

Buttons

• subtle scale animation  
• slight color transition

Recommended scale animation:

0.97 → 1.0

Duration:

120ms

---

# 6. Tab Bar Animations

When switching tabs:

Active button animation:

• background color transition  
• icon color change  
• subtle scale effect

Duration:

180ms

Transition style:

easeOut

Inactive buttons should transition softly without sudden jumps.

---

# 7. Carousel Animations

Home carousel behavior:

• horizontal scroll
• magnetic snapping
• smooth deceleration

Recommended interaction feel:

Similar to iOS native carousels.

Snap animation duration:

200ms – 260ms

---

# 8. Vertical Card Pager

Used in the Daily Echo screen.

Interaction:

Vertical swipe.

Animation behavior:

Cards should feel **layered and physical**.

Active card:

Moves forward in visual hierarchy.

Next cards:

Remain slightly behind with reduced scale.

Suggested effect:

• slight depth
• soft vertical motion

Avoid aggressive 3D transforms.

---

# 9. Card Opening Transition

When a card is tapped:

Mini card → expands into Card Detail view.

Transition should feel like **revealing the story behind the card**.

Recommended effect:

• image expansion
• smooth fade of background elements
• vertical content reveal

Total duration:

320ms – 420ms

---

# 10. Modal Animations

Used for:

• upgrade modal
• share modal
• settings

Recommended animation:

Slide from bottom.

Behavior:

Background fades slightly.

Modal moves upward.

Duration:

280ms – 320ms

Curve:

easeOut

---

# 11. Page Transitions

Main navigation between screens should be subtle.

Preferred transition:

Fade + slight vertical motion.

Example:

New screen fades in while moving up slightly.

Duration:

300ms

Curve:

easeInOut

---

# 12. Favorite Action Animation

When a user favorites a card:

Heart icon animation:

• scale up slightly
• return to normal size

Optional:

Soft pulse effect.

Duration:

160ms – 220ms

---

# 13. Loading Animations

Loading states should feel calm and unobtrusive.

Recommended options:

• shimmer placeholders  
• subtle fade-in for loaded images

Avoid:

spinners blocking the interface.

Content should appear progressively.

---

# 14. Performance Rules

Animations must remain smooth across devices.

Guidelines:

Prefer opacity and transform animations.

Avoid heavy layout recalculations.

Avoid large image redraws during animations.

Target frame rate:

60fps minimum.

---

# 15. Accessibility Considerations

Respect device motion preferences.

If the user has reduced motion enabled:

• reduce animation duration
• remove non-essential motion
• keep only necessary transitions

The interface should remain usable without motion effects.

---

# 16. Implementation Recommendation (Flutter)

Animations should rely on Flutter native animation tools.

Preferred tools:

AnimatedContainer  
AnimatedOpacity  
AnimatedScale  
Hero animations  
PageRouteBuilder

Avoid unnecessary custom animation frameworks.

---

# 17. Animation Philosophy Summary

HerEchoes motion should feel like:

• discovering a story
• gently revealing history
• browsing a living archive of voices

Motion should enhance the experience without ever distracting from the content.