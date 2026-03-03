# Her Echoes – Database Rules

## Source of Truth

The master database lives in:

/database/her_echoes-DB-2_cleaned.xlsx

No other file overrides it.

---

## Column Policy

- Column names are frozen.
- Column order is frozen.
- No column is renamed without creating a new schema version.
- If structure changes, a v2 file must be created.

---

## Data Integrity Rules

For each new entry:

- No critical field left blank (e.g. name, category, date relevance).
- No duplicated person.
- No speculative achievements.
- No invented quotes.
- Dates must be verified.
- If data is uncertain → leave blank and flag.

---

## Formatting Consistency

- Same capitalization style across entries.
- Same category taxonomy.
- Same date format.
- No mixed languages within structured fields.

---

## Versioning Rule

Every meaningful database update must be committed:

Example:
git commit -m "Update March entries – Week 2"

Weekly commits minimum.