# Her Echoes – Daily Workflow

## Daily Target

3 new women per day.

---

## Daily Process

1. Research and verify sources.
2. Add entries to Excel master file.
3. Validate:
    - No column shifts
    - No duplicates
    - No empty critical fields
    - No formatting inconsistencies
4. Save Excel file.
5. At end of session:
   git add .
   git commit -m "Add entries for YYYY-MM-DD"
   git push

---

## Weekly Process

- Review week entries.
- Scan for consistency.
- Commit with:
  "Weekly validation – Month Week X"

---

## App Testing Flow (When Needed)

1. Convert Excel → JSON.
2. Replace JSON inside assets.
3. Run app.
4. Validate UI against real data.

JSON is disposable.
Excel is permanent.

---

## Emergency Recovery

If corruption occurs:

- Revert to previous Git commit.
- Never manually reconstruct from memory.
- Never rewrite history without version tracking.

---

## Migration Readiness

If switching AI or tools:

Provide:
- project_protocol.md
- database_rules.md
- daily_workflow.md
- Latest Excel file

The system must resume without loss of structure.


## HOME SCREEN WORKFLOW

1. User opens Home tab
2. App randomly selects one portrait from Home images folder
3. App checks subscription state

Subscription state determines banner behavior.

FREE
→ show "Inspírate diariamente" banner
→ tap opens subscription modal

PRO Individual
→ show "Inspiración para tu familia" banner
→ tap opens family upgrade modal

PRO Family
→ banner hidden

Suggested women cards load below banner.


## SHOW ALL WORKFLOW

1. User opens Show All tab

2. App loads full dataset from JSON

3. vertical_card_pager displays all cards

4. App checks subscription state

FREE user:
• cards appear locked
• tap triggers subscription modal

PRO user:
• cards fully interactive
• tap opens Detail View


## CARD INTERACTION WORKFLOW

When a user taps a card:

Step 1
Check subscription state.

If PRO
→ open Detail View.

If FREE
→ check if card is locked.

Unlocked card
→ open Detail View.

Locked card
→ open Subscription Modal.

---

## DETAIL VIEW WORKFLOW

Detail view loads data from the card object.

Displayed sections:

Header Image
Tags
Full Name

Tab Navigation:
Biography
Legacy

---

Biography Tab shows:

Event date
Historical event
Birth date
Birth place
Bio text paragraphs
Death date
Death place

---

Legacy Tab shows:

Quote
Legacy description
Share button
Add to Favorites button


---

### Si se retoma el trabajo:

1. No modificar layout.
2. No modificar estilos.
3. Implementar motor Daily Suggestions Engine.
4. Validar:
   - 3 + hasta 7
   - Sin duplicados
   - Orden consistente