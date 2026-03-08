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


## IMAGE SOURCES

Two different image systems exist.

### Daily Echo portraits

Stored in Google Drive.

Each historical figure entry contains:

image_url

Example:

https://drive.google.com/uc?export=view&id=<FILE_ID>

These images are linked to the JSON dataset.

---

### Home screen portraits

Stored in:

Drive/Mi Unidad/Images/Home

These are NOT linked to the JSON dataset.

They are purely decorative.

App will randomly select one of the available images each time the Home screen loads.

Expected number of images: 5

Format: webp


## SHOW ALL DATA RULES

Show All uses the same dataset as Daily Echo.

Source:
assets/data/her_echoes.json

Each entry contains:

id
full_name
event_date
pro-tag01_en
pro-tag02_en
quote_en
country
birth_year
death_year
image_url

The dataset is shared between:

Daily Echo
Show All
Favorites
Detail View

---

## CARD LOCK LOGIC

Access is determined by subscription state.

FREE users:
card marked with PRO badge

PRO users:
full access


## DATASET STRUCTURE

The main dataset is stored in:

assets/data/her_echoes.json

Each record represents one historical woman.

Example structure:

{
"id": 182,
"full_name": "Mary Sherman Morgan",
"event_date": "03/01",
"pro-tag01_en": "Rocket Scientist",
"pro-tag02_en": "Fuel Innovator",
"quote_text_en": "...",
"bio_en": "...",
"legacy_en": "...",
"birth_date": "1921",
"death_date": "2004",
"birth_place": "Ray, North Dakota",
"death_place": "Huntington Beach, California",
"image_card_ID": "https://drive.google.com/uc?export=view&id=XXXX"
}

---

## IMAGE RULE

image_card_ID is the canonical image reference.

This image is reused across the entire application.

No separate image field is used for thumbnails.

The same image is rendered in different sizes depending on UI component.
