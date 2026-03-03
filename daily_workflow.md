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