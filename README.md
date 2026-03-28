# Tierheim‑Datenbank (PostgreSQL)

Datenbankprojekt für ein Tierheim mit vollständiger Modellierung und Test‑Queries.

## Inhalte
- Klassendiagramm (UML)
- Relationsmodell
- DDL‑Skript zur Datenbankdefinition
- 25 SQL‑Anfragen (einfach bis komplex) zur Validierung

## Technologien
- PostgreSQL
- SQL
- Datenmodellierung (UML, Relationen)
- DDL (CREATE TABLE, Keys, Beziehungen)

## Setup (PostgreSQL)
1. Datenbank erstellen:
   ```
   createdb tierheim_db
   ```
2. DDL ausführen:
   ```
   psql -d tierheim_db -f sql/schema.sql
   ```
3. Queries testen:
   ```
   psql -d tierheim_db -f sql/queries.sql
   ```

## Inhaltliche Schwerpunkte
- Beziehungen und Schlüsseldefinitionen (PK/FK, ON DELETE Regeln)
- Konsistenz durch Constraints und Checks
- Validierung über 25 Test‑Queries (Views)

## Beispiel‑Queries (Auszug)
```sql
-- Tiere aktuell im Heim + Zwinger + Kapazität + Abteilung
SELECT 
    t.name AS tier_name,
    z.zwinger_nr,
    p.kapazitaet,
    a.bezeichnung AS abteilung
FROM tier t
JOIN unterbringung u ON u.tier_id = t.tier_id
JOIN platz p ON p.platz_id = u.platz_id
JOIN zwinger z ON z.platz_id = p.platz_id
JOIN abteilung a ON a.abteilung_id = p.abteilung_id
WHERE t.aktuell_status = 'im_heim'
  AND p.typ = 'zwinger'
  AND (u.end_datum IS NULL OR u.end_datum >= CURRENT_DATE);

-- Bewerber mit Anzahl aktuell adoptierter Tiere
SELECT
    b.person_id AS bewerber_id,
    p.name AS bewerber_name,
    COUNT(a.tier_id) AS anzahl_tiere
FROM bewerber b
JOIN person p       ON p.person_id = b.person_id
JOIN adoption a     ON a.bewerber_id = b.person_id
WHERE a.datum_rueckgabe IS NULL
GROUP BY b.person_id, p.name;

-- Tiere mit Krankheiten (inkl. Diagnose + Heilung)
SELECT
    t.name AS tiername,
    k.name AS krankheitsname,
    tk.diagnose_datum,
    tk.geheilt
FROM tier t
JOIN tier_krankheit tk ON tk.tier_id = t.tier_id
JOIN krankheit k       ON k.krankheit_id = tk.krankheit_id;

-- Tiere aktuell in Quarantänestation
SELECT
    t.name AS tiername,
    q.station_nr,
    a.bezeichnung AS abteilung
FROM unterbringung u
JOIN tier t ON u.tier_id = t.tier_id
JOIN platz pl ON u.platz_id = pl.platz_id
JOIN quarantaenestation q ON pl.platz_id = q.platz_id
LEFT JOIN abteilung a ON pl.abteilung_id = a.abteilung_id
WHERE pl.typ = 'quarantaene';

-- Rückgaben inkl. Grund
SELECT
    t.name AS tiername,
    p.name AS bewerber,
    a.datum_adoption,
    a.datum_rueckgabe,
    a.rueckgabe_grund
FROM adoption a
JOIN tier t ON t.tier_id = a.tier_id
JOIN bewerber b ON b.person_id = a.bewerber_id
JOIN person p ON p.person_id = b.person_id
WHERE a.datum_rueckgabe IS NOT NULL;
```
