DROP TABLE IF EXISTS mitarbeiter_zwinger CASCADE;
DROP TABLE IF EXISTS tierverlauf CASCADE;
DROP TABLE IF EXISTS tierart_beduerfnis CASCADE;
DROP TABLE IF EXISTS tier_beduerfnis CASCADE;
DROP TABLE IF EXISTS beduerfnis CASCADE;
DROP TABLE IF EXISTS tier_krankheit CASCADE;
DROP TABLE IF EXISTS krankheit CASCADE;
DROP TABLE IF EXISTS adoptionvisit CASCADE;
DROP TABLE IF EXISTS adoption CASCADE;
DROP TABLE IF EXISTS unterbringung CASCADE;
DROP TABLE IF EXISTS pflegestation CASCADE;
DROP TABLE IF EXISTS zwinger CASCADE;
DROP TABLE IF EXISTS quarantaenestation CASCADE;
DROP TABLE IF EXISTS platz CASCADE;
DROP TABLE IF EXISTS abteilung CASCADE;
DROP TABLE IF EXISTS tier CASCADE;
DROP TABLE IF EXISTS pflegekraft CASCADE;
DROP TABLE IF EXISTS bewerber CASCADE;
DROP TABLE IF EXISTS mitarbeiter CASCADE;
DROP TABLE IF EXISTS tierart CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS tierheim CASCADE;

DROP TYPE IF EXISTS tier_groesse;
DROP TYPE IF EXISTS platz_typ;
DROP TYPE IF EXISTS tier_geschlecht;
DROP TYPE IF EXISTS tier_status;

CREATE TYPE tier_groesse AS ENUM ('klein','mittel','gross');
CREATE TYPE platz_typ AS ENUM ('zwinger','quarantaene');
CREATE TYPE tier_geschlecht AS ENUM ('m','w','u');
CREATE TYPE tier_status AS ENUM ('im_heim','in_pflege','adoptiert','in_quarantaene');

CREATE TABLE tierheim (
  tierheim_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  adresse TEXT
);

CREATE TABLE person (
  person_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  telefon TEXT
);

CREATE TABLE tierart (
  tierart_id SERIAL PRIMARY KEY,
  bezeichnung TEXT UNIQUE NOT NULL,
  groesse tier_groesse NOT NULL
);

CREATE TABLE mitarbeiter (
  person_id INTEGER PRIMARY KEY REFERENCES person(person_id) ON DELETE CASCADE,
  spezialisiert_tierart_id INTEGER REFERENCES tierart(tierart_id) ON DELETE SET NULL,
  anzahl_betreuter_zwinger INTEGER NOT NULL DEFAULT 0 CHECK (anzahl_betreuter_zwinger >= 0)
);

CREATE TABLE bewerber (
  person_id INTEGER PRIMARY KEY REFERENCES person(person_id) ON DELETE CASCADE,
  anschrift TEXT
);

CREATE TABLE pflegekraft (
  person_id INTEGER PRIMARY KEY REFERENCES person(person_id) ON DELETE CASCADE,
  anzahl_tiere INTEGER NOT NULL DEFAULT 0 CHECK (anzahl_tiere >= 0)
);

CREATE TABLE tier (
  tier_id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  geburtsdatum DATE,
  geschlecht tier_geschlecht NOT NULL DEFAULT 'u',
  tierart_id INTEGER NOT NULL REFERENCES tierart(tierart_id) ON DELETE RESTRICT,
  aktuell_status tier_status NOT NULL DEFAULT 'im_heim'
);

CREATE TABLE abteilung (
  abteilung_id SERIAL PRIMARY KEY,
  bezeichnung TEXT NOT NULL,	
  anzahl_zwinger INTEGER NOT NULL DEFAULT 0 CHECK (anzahl_zwinger >= 0),
  tierart_id INTEGER NOT NULL REFERENCES tierart(tierart_id) ON DELETE RESTRICT
);

CREATE TABLE platz (
  platz_id SERIAL PRIMARY KEY,
  typ platz_typ NOT NULL,
  kapazitaet INTEGER NOT NULL CHECK (kapazitaet > 0),
  abteilung_id INTEGER REFERENCES abteilung(abteilung_id) ON DELETE SET NULL
);

CREATE TABLE zwinger (
  platz_id INTEGER PRIMARY KEY REFERENCES platz(platz_id) ON DELETE CASCADE,
  zwinger_nr TEXT
);

CREATE TABLE quarantaenestation (
  platz_id INTEGER PRIMARY KEY REFERENCES platz(platz_id) ON DELETE CASCADE,
  station_nr TEXT
);

CREATE TABLE pflegestation (
  pflegestation_id SERIAL PRIMARY KEY,
  kapazitaet INTEGER NOT NULL CHECK (kapazitaet > 0),
  aktuelle_belegung INTEGER NOT NULL DEFAULT 0 CHECK (aktuelle_belegung >= 0),
  abteilung_id INTEGER REFERENCES abteilung(abteilung_id) ON DELETE SET NULL,
  pflegekraft_id INTEGER REFERENCES pflegekraft(person_id) ON DELETE SET NULL,
  CHECK (aktuelle_belegung <= kapazitaet)
);

CREATE TABLE unterbringung (
  unterbringung_id SERIAL PRIMARY KEY,
  tier_id INTEGER NOT NULL REFERENCES tier(tier_id) ON DELETE CASCADE,
  tierheim_id INTEGER REFERENCES tierheim(tierheim_id) ON DELETE SET NULL,
  platz_id INTEGER REFERENCES platz(platz_id) ON DELETE SET NULL,
  pflegestation_id INTEGER REFERENCES pflegestation(pflegestation_id) ON DELETE SET NULL,
  start_datum DATE NOT NULL,
  end_datum DATE,
  bemerkung TEXT,
  CHECK (end_datum IS NULL OR start_datum <= end_datum),
  CHECK (platz_id IS NOT NULL OR pflegestation_id IS NOT NULL)
);

CREATE TABLE adoption (
  adoption_id SERIAL PRIMARY KEY,
  tier_id INTEGER NOT NULL REFERENCES tier(tier_id) ON DELETE RESTRICT,
  bewerber_id INTEGER NOT NULL REFERENCES bewerber(person_id) ON DELETE RESTRICT,
  mitarbeiter_id INTEGER REFERENCES mitarbeiter(person_id) ON DELETE SET NULL,
  datum_adoption DATE NOT NULL,
  datum_rueckgabe DATE,
  rueckgabe_grund TEXT,
  CHECK (datum_rueckgabe IS NULL OR datum_rueckgabe >= datum_adoption)
);

CREATE TABLE adoptionvisit (
  visit_id SERIAL PRIMARY KEY,
  adoption_id INTEGER NOT NULL REFERENCES adoption(adoption_id) ON DELETE CASCADE,
  mitarbeiter_id INTEGER REFERENCES mitarbeiter(person_id) ON DELETE SET NULL,
  visit_datum DATE NOT NULL,
  bemerkung TEXT,
  ergebnis TEXT
);

CREATE TABLE krankheit (
  krankheit_id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  ansteckend BOOLEAN NOT NULL DEFAULT FALSE,
  freilauf_erlaubt BOOLEAN NOT NULL DEFAULT TRUE,
  beschreibung TEXT
);

CREATE TABLE tier_krankheit (
  tier_id INTEGER NOT NULL REFERENCES tier(tier_id) ON DELETE CASCADE,
  krankheit_id INTEGER NOT NULL REFERENCES krankheit(krankheit_id) ON DELETE CASCADE,
  diagnose_datum DATE NOT NULL,
  geheilt BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (tier_id, krankheit_id, diagnose_datum)
);

CREATE TABLE beduerfnis (
  beduerfnis_id SERIAL PRIMARY KEY,
  beschreibung TEXT NOT NULL,
  art TEXT,
  wert TEXT
);

CREATE TABLE tier_beduerfnis (
  tier_id INTEGER NOT NULL REFERENCES tier(tier_id) ON DELETE CASCADE,
  beduerfnis_id INTEGER NOT NULL REFERENCES beduerfnis(beduerfnis_id) ON DELETE CASCADE,
  PRIMARY KEY (tier_id, beduerfnis_id)
);

CREATE TABLE tierart_beduerfnis (
  tierart_id INTEGER NOT NULL REFERENCES tierart(tierart_id) ON DELETE CASCADE,
  beduerfnis_id INTEGER NOT NULL REFERENCES beduerfnis(beduerfnis_id) ON DELETE CASCADE,
  PRIMARY KEY (tierart_id, beduerfnis_id)
);

CREATE TABLE tierverlauf (
  verlauf_id SERIAL PRIMARY KEY,
  tier_id INTEGER NOT NULL REFERENCES tier(tier_id) ON DELETE CASCADE,
  person_id INTEGER NOT NULL REFERENCES person(person_id) ON DELETE RESTRICT,
  rolle TEXT NOT NULL,
  start_datum DATE,
  end_datum DATE,
  bemerkung TEXT,
  CHECK (end_datum IS NULL OR start_datum <= end_datum)
);

CREATE TABLE mitarbeiter_zwinger (
  mitarbeiter_id INTEGER NOT NULL REFERENCES mitarbeiter(person_id) ON DELETE CASCADE,
  platz_id INTEGER NOT NULL REFERENCES platz(platz_id) ON DELETE CASCADE,
  PRIMARY KEY (mitarbeiter_id, platz_id)
);

INSERT INTO tierheim (name, adresse) VALUES
('Tierschutz Musterdorf', 'Musterweg 1, 12345 Musterdorf');

INSERT INTO person (name, email, telefon) VALUES
('Anna Müller', 'anna.mueller@example.com', '040111222'),
('Bernd Schmidt', 'bernd.schmidt@example.com', '0170555111'),
('Clara Bauer', 'clara.bauer@example.com', '0170222333'),
('Dieter Lange', 'dieter.lange@example.com', '0171444555'),
('Eva König', 'eva.koenig@example.com', '0172333444'),
('Frank Meier', 'frank.meier@example.com', '0173666777'),
('Greta Vogel', 'greta.vogel@example.com', '0174888999'),
('Hanna Kurz', 'hanna.kurz@example.com', '0175000111'),
('Ivan Petrov', 'ivan.petrov@example.com', '0176222000'),
('Julia Kramer', 'julia.kramer@example.com', '0177333000');

INSERT INTO tierart (bezeichnung, groesse) VALUES
('Hund','gross'),
('Katze','mittel'),
('Kaninchen','klein'),
('Meerschweinchen','klein');

INSERT INTO mitarbeiter (person_id, spezialisiert_tierart_id, anzahl_betreuter_zwinger) VALUES
((SELECT person_id FROM person WHERE email='anna.mueller@example.com' LIMIT 1), (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 4),
((SELECT person_id FROM person WHERE email='dieter.lange@example.com' LIMIT 1), (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 2),
((SELECT person_id FROM person WHERE email='frank.meier@example.com' LIMIT 1), (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1), 3);

INSERT INTO bewerber (person_id, anschrift) VALUES
((SELECT person_id FROM person WHERE email='bernd.schmidt@example.com' LIMIT 1), 'Adlerstraße 5, 20095 Hamburg'),
((SELECT person_id FROM person WHERE email='eva.koenig@example.com' LIMIT 1), 'Birkenweg 7, 20095 Hamburg');

INSERT INTO pflegekraft (person_id, anzahl_tiere) VALUES
((SELECT person_id FROM person WHERE email='clara.bauer@example.com' LIMIT 1), 3),
((SELECT person_id FROM person WHERE email='greta.vogel@example.com' LIMIT 1), 1);

INSERT INTO tier (name, geburtsdatum, geschlecht, tierart_id, aktuell_status) VALUES
('Bello', '2019-04-12', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Poldi', '2018-01-01', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Luna', '2020-09-05', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'in_pflege'),
('Rocky', '2021-06-20', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'adoptiert'),
('Kira', '2022-03-11', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Otis', '2023-10-23', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Molly', '2024-02-14', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Miez', '2021-09-01', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 'in_pflege'),
('Whiskers', '2020-12-12', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 'im_heim'),
('Susi', '2019-07-07', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 'adoptiert'),
('Hoppel', '2022-02-10', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1), 'adoptiert'),
('Floppy', '2021-11-05', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1), 'im_heim'),
('Poppy', '2023-04-01', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1), 'im_heim'),
('Pip', '2024-01-10', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Meerschweinchen' LIMIT 1), 'im_heim'),
('Squeak', '2023-06-30', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Meerschweinchen' LIMIT 1), 'im_heim'),
('Rex', '2017-05-05', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Nala', '2022-08-12', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 'im_heim'),
('Gizmo', '2020-03-03', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1), 'im_heim'),
('Bella', '2016-10-10', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'in_pflege'),
('Charlie', '2015-02-02', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Schnuffi', '2020-08-08', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1), 'in_pflege'),
('Tiger', '2018-11-11', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 'im_heim'),
('Lilly', '2023-09-09', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Meerschweinchen' LIMIT 1), 'im_heim'),
('Buddy', '2021-04-04', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'im_heim'),
('Flo', '2019-06-06', 'w', (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 'im_heim'),
('Hugo', '2014-01-01', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), 'in_pflege'),
('Milo', '2013-05-15', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1), 'adoptiert'),
('Nemo', '2022-12-20', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Meerschweinchen' LIMIT 1), 'im_heim'),
('Keks', '2024-03-03', 'm', (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1), 'im_heim');

INSERT INTO abteilung (bezeichnung, anzahl_zwinger, tierart_id) VALUES
('Hunde-Abteilung A', 5, (SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1)),
('Katzen-Abteilung A', 4, (SELECT tierart_id FROM tierart WHERE bezeichnung='Katze' LIMIT 1)),
('Kaninchen-Abteilung A', 3, (SELECT tierart_id FROM tierart WHERE bezeichnung='Kaninchen' LIMIT 1)),
('Kleinsaeuger-Abteilung A', 2, (SELECT tierart_id FROM tierart WHERE bezeichnung='Meerschweinchen' LIMIT 1));

INSERT INTO platz (typ, kapazitaet, abteilung_id) VALUES
('zwinger', 2, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1)),
('zwinger', 3, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1)),
('zwinger', 2, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1)),
('zwinger', 1, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1)),
('quarantaene', 1, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1)),
('zwinger', 3, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1)),
('zwinger', 2, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1)),
('zwinger', 1, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1)),
('quarantaene', 1, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1)),
('zwinger', 4, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kaninchen-Abteilung A' LIMIT 1)),
('zwinger', 2, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kaninchen-Abteilung A' LIMIT 1)),
('zwinger', 2, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kaninchen-Abteilung A' LIMIT 1)),
('zwinger', 5, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kleinsaeuger-Abteilung A' LIMIT 1)),
('zwinger', 3, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kleinsaeuger-Abteilung A' LIMIT 1));

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'H-Z1' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1) ORDER BY platz_id LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'H-Z2' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 1 LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'H-Z3' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 2 LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'H-Z4' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 3 LIMIT 1;

INSERT INTO quarantaenestation (platz_id, station_nr)
SELECT platz_id, 'H-Q1' FROM platz WHERE typ='quarantaene' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1) LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'K-Z1' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1) ORDER BY platz_id LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'K-Z2' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 1 LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'K-Z3' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 2 LIMIT 1;

INSERT INTO quarantaenestation (platz_id, station_nr)
SELECT platz_id, 'K-Q1' FROM platz WHERE typ='quarantaene' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1) LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'Ka-Z1' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kaninchen-Abteilung A' LIMIT 1) ORDER BY platz_id LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'Ka-Z2' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kaninchen-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 1 LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'Ka-Z3' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kaninchen-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 2 LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'KS-Z1' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kleinsaeuger-Abteilung A' LIMIT 1) ORDER BY platz_id LIMIT 1;

INSERT INTO zwinger (platz_id, zwinger_nr)
SELECT platz_id, 'KS-Z2' FROM platz WHERE typ='zwinger' AND abteilung_id=(SELECT abteilung_id FROM abteilung WHERE bezeichnung='Kleinsaeuger-Abteilung A' LIMIT 1) ORDER BY platz_id OFFSET 1 LIMIT 1;

INSERT INTO pflegestation (kapazitaet, aktuelle_belegung, abteilung_id, pflegekraft_id) VALUES
(3, 1, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Katzen-Abteilung A' LIMIT 1), (SELECT person_id FROM pflegekraft WHERE person_id=(SELECT person_id FROM person WHERE email='clara.bauer@example.com' LIMIT 1))),
(4, 2, (SELECT abteilung_id FROM abteilung WHERE bezeichnung='Hunde-Abteilung A' LIMIT 1), (SELECT person_id FROM pflegekraft WHERE person_id=(SELECT person_id FROM person WHERE email='greta.vogel@example.com' LIMIT 1)));

INSERT INTO krankheit (name, ansteckend, freilauf_erlaubt, beschreibung) VALUES
('Parvovirose', TRUE, FALSE, 'schwere Infektion'),
('Hautpilz', TRUE, FALSE, 'ansteckend'),
('Herzwurm', FALSE, FALSE, 'parasitaere Erkrankung');

INSERT INTO beduerfnis (beschreibung, art, wert) VALUES
('Benötigt Einzelhaltung', 'Verhalten', 'Einzel'),
('Benötigt grosser Auslauf', 'Platz', 'Gross'),
('Nicht verträglich mit Katzen', 'Sozial', 'KeineKatzen');

INSERT INTO unterbringung (tier_id, tierheim_id, platz_id, start_datum, end_datum, bemerkung) VALUES
((SELECT tier_id FROM tier WHERE name='Bello' LIMIT 1), (SELECT tierheim_id FROM tierheim LIMIT 1), (SELECT platz_id FROM zwinger WHERE zwinger_nr='H-Z1' LIMIT 1), '2025-08-01', NULL, 'Neuaufnahme'),
((SELECT tier_id FROM tier WHERE name='Hoppel' LIMIT 1), (SELECT tierheim_id FROM tierheim LIMIT 1), (SELECT platz_id FROM zwinger WHERE zwinger_nr='Ka-Z1' LIMIT 1), '2025-01-05', '2025-02-20', 'Vermittelt');

INSERT INTO unterbringung (tier_id, tierheim_id, pflegestation_id, start_datum, end_datum, bemerkung) VALUES
((SELECT tier_id FROM tier WHERE name='Miez' LIMIT 1), (SELECT tierheim_id FROM tierheim LIMIT 1), (SELECT pflegestation_id FROM pflegestation LIMIT 1), '2025-07-15', NULL, 'Pflegestelle');

INSERT INTO adoption (tier_id, bewerber_id, mitarbeiter_id, datum_adoption) VALUES
((SELECT tier_id FROM tier WHERE name='Hoppel' LIMIT 1), (SELECT person_id FROM bewerber WHERE person_id=(SELECT person_id FROM person WHERE email='eva.koenig@example.com' LIMIT 1) LIMIT 1), (SELECT person_id FROM mitarbeiter WHERE person_id=(SELECT person_id FROM person WHERE email='anna.mueller@example.com' LIMIT 1) LIMIT 1), '2025-02-20'),
((SELECT tier_id FROM tier WHERE name='Susi' LIMIT 1), (SELECT person_id FROM bewerber WHERE person_id=(SELECT person_id FROM person WHERE email='bernd.schmidt@example.com' LIMIT 1) LIMIT 1), (SELECT person_id FROM mitarbeiter WHERE person_id=(SELECT person_id FROM person WHERE email='dieter.lange@example.com' LIMIT 1) LIMIT 1), '2024-11-10');

UPDATE adoption SET datum_rueckgabe='2025-05-10', rueckgabe_grund='Nicht vereinbar' WHERE tier_id=(SELECT tier_id FROM tier WHERE name='Hoppel' LIMIT 1);

INSERT INTO adoptionvisit (adoption_id, mitarbeiter_id, visit_datum, bemerkung, ergebnis) VALUES
((SELECT adoption_id FROM adoption WHERE tier_id=(SELECT tier_id FROM tier WHERE name='Hoppel' LIMIT 1) LIMIT 1), (SELECT person_id FROM mitarbeiter WHERE person_id=(SELECT person_id FROM person WHERE email='anna.mueller@example.com' LIMIT 1) LIMIT 1), '2025-03-05', 'Erster Besuch', 'ok');

INSERT INTO tier_krankheit (tier_id, krankheit_id, diagnose_datum, geheilt) VALUES
((SELECT tier_id FROM tier WHERE name='Bello' LIMIT 1), (SELECT krankheit_id FROM krankheit WHERE name='Parvovirose' LIMIT 1), '2025-08-05', FALSE),
((SELECT tier_id FROM tier WHERE name='Miez' LIMIT 1), (SELECT krankheit_id FROM krankheit WHERE name='Hautpilz' LIMIT 1), '2025-07-10', FALSE);

INSERT INTO tier_beduerfnis (tier_id, beduerfnis_id) VALUES
((SELECT tier_id FROM tier WHERE name='Bello' LIMIT 1), (SELECT beduerfnis_id FROM beduerfnis WHERE beschreibung='Benötigt Einzelhaltung' LIMIT 1)),
((SELECT tier_id FROM tier WHERE name='Poldi' LIMIT 1), (SELECT beduerfnis_id FROM beduerfnis WHERE beschreibung='Benötigt grosser Auslauf' LIMIT 1));

INSERT INTO tierart_beduerfnis (tierart_id, beduerfnis_id) VALUES
((SELECT tierart_id FROM tierart WHERE bezeichnung='Hund' LIMIT 1), (SELECT beduerfnis_id FROM beduerfnis WHERE beschreibung='Benötigt grosser Auslauf' LIMIT 1));

INSERT INTO tierverlauf (tier_id, person_id, rolle, start_datum, end_datum, bemerkung) VALUES
((SELECT tier_id FROM tier WHERE name='Hoppel' LIMIT 1), (SELECT person_id FROM person WHERE email='eva.koenig@example.com' LIMIT 1), 'adoption', '2025-02-20', '2025-05-10', 'zurueckgegeben');

INSERT INTO mitarbeiter_zwinger (mitarbeiter_id, platz_id) VALUES
((SELECT person_id FROM mitarbeiter WHERE person_id=(SELECT person_id FROM person WHERE email='anna.mueller@example.com' LIMIT 1) LIMIT 1), (SELECT platz_id FROM zwinger WHERE zwinger_nr='H-Z1' LIMIT 1));


-- Anfrage 1:
-- Alle Tiere, die aktuell in einem Zwinger untergebracht sind,
-- inklusive Zwingernummer, Platzkapazität und zugehöriger Abteilung.
CREATE VIEW anfrage_1 AS 
SELECT 
    t.name AS tier_name,
    z.zwinger_nr,
    p.kapazitaet AS platz_kapazitaet,
    a.bezeichnung AS abteilung
FROM tier t
JOIN unterbringung u ON u.tier_id = t.tier_id
JOIN platz p ON p.platz_id = u.platz_id
JOIN zwinger z ON z.platz_id = p.platz_id
JOIN abteilung a ON a.abteilung_id = p.abteilung_id
WHERE t.aktuell_status = 'im_heim'
  AND p.typ = 'zwinger'
  AND (u.end_datum IS NULL OR u.end_datum >= CURRENT_DATE);
  
  
-- Anfrage 2:
-- Alle Bewerber mit der Anzahl der Tiere, die sie aktuell adoptiert haben
-- (d.h. Adoptionen ohne Rückgabedatum).
CREATE VIEW anfrage_2 AS
SELECT
    b.person_id AS bewerber_id,
    p.name AS bewerber_name,
    COUNT(a.tier_id) AS anzahl_tiere
FROM bewerber b
JOIN person p       ON p.person_id = b.person_id
JOIN adoption a     ON a.bewerber_id = b.person_id
WHERE a.datum_rueckgabe IS NULL
GROUP BY b.person_id, p.name;


-- Anfrage 3:
-- Alle Tiere, die sich aktuell im Tierheim befinden (Status = im_heim).
CREATE VIEW anfrage_3 AS
SELECT *
FROM tier
WHERE aktuell_status = 'im_heim';


-- Anfrage 4:
-- Alle Tiere, die seit mehr als 180 Tagen ununterbrochen untergebracht sind
-- (Langzeitaufenthalte).
CREATE VIEW anfrage_4 AS
SELECT
    t.tier_id,
    t.name,
    u.start_datum,
    u.platz_id,
    u.pflegestation_id
FROM tier t
JOIN unterbringung u ON u.tier_id = t.tier_id
WHERE
    u.end_datum IS NULL
    AND CURRENT_DATE - u.start_datum > 180;


-- Anfrage 5:
-- Alle Tiere mit ihren Krankheiten, inklusive Diagnosedatum und Heilungsstatus.
CREATE VIEW anfrage_5 AS
SELECT
    t.tier_id,
    t.name AS tiername,
    k.name AS krankheitsname,
    tk.diagnose_datum,
    tk.geheilt
FROM tier t
JOIN tier_krankheit tk ON tk.tier_id = t.tier_id
JOIN krankheit k       ON k.krankheit_id = tk.krankheit_id;


-- Anfrage 6:
-- Alle Pflegekräfte mit ihren Pflegestationen und der aktuellen Anzahl
-- der dort betreuten Tiere.
CREATE VIEW anfrage_6 AS
SELECT
    pk.person_id AS pflegekraft_id,
    p.name AS pflegekraft_name,
    ps.pflegestation_id,
    COUNT(u.tier_id) AS anzahl_tiere
FROM pflegekraft pk
JOIN person p            ON p.person_id = pk.person_id
LEFT JOIN pflegestation ps
       ON ps.pflegekraft_id = pk.person_id
LEFT JOIN unterbringung u
       ON u.pflegestation_id = ps.pflegestation_id
      AND u.end_datum IS NULL
GROUP BY pk.person_id, p.name, ps.pflegestation_id;


-- Anfrage 7:
-- Alle Tiere, die aktuell an einer ansteckenden Krankheit leiden
-- und deshalb keinen Freilauf haben dürfen.
CREATE VIEW anfrage_7 AS
SELECT
    t.tier_id,
    t.name AS tiername,
    k.name AS krankheit,
    k.freilauf_erlaubt
FROM tier t
JOIN tier_krankheit tk ON tk.tier_id = t.tier_id
JOIN krankheit k       ON k.krankheit_id = tk.krankheit_id
WHERE
    tk.geheilt = FALSE
    AND k.ansteckend = TRUE;


-- Anfrage 8:
-- Alle Unterbringungen von Tieren, die im aktuellen Kalenderjahr begonnen haben.
CREATE VIEW anfrage_8 AS
SELECT
    t.tier_id,
    t.name,
    u.start_datum,
    u.platz_id,
    u.pflegestation_id
FROM unterbringung u
JOIN tier t ON t.tier_id = u.tier_id
WHERE EXTRACT(YEAR FROM u.start_datum) = EXTRACT(YEAR FROM CURRENT_DATE);


-- Anfrage 9:
-- Alle Tiere, deren Tierart das Bedürfnis
-- "Benötigt grosser Auslauf" zugeordnet hat.
CREATE VIEW anfrage_9 AS
SELECT
    t.tier_id,
    t.name AS tiername,
    ta.bezeichnung AS tierart
FROM tier t
JOIN tierart ta             ON ta.tierart_id = t.tierart_id
JOIN tierart_beduerfnis tb  ON tb.tierart_id = ta.tierart_id
JOIN beduerfnis b           ON b.beduerfnis_id = tb.beduerfnis_id
WHERE b.beschreibung = 'Benötigt grosser Auslauf';


-- Anfrage 10:
-- Alle Adoptionen mit Adoptionsdatum, Tier, Bewerber
-- sowie dem zuständigen Mitarbeiter (falls vorhanden).
CREATE VIEW anfrage_10 AS
SELECT
    t.tier_id,
    t.name AS tiername,
    a.datum_adoption,
    pb.name AS bewerber_name,
    pm.name AS mitarbeiter_name
FROM adoption a
JOIN tier t ON t.tier_id = a.tier_id
JOIN bewerber b ON b.person_id = a.bewerber_id
JOIN person pb ON pb.person_id = b.person_id
LEFT JOIN mitarbeiter m ON m.person_id = a.mitarbeiter_id
LEFT JOIN person pm ON pm.person_id = m.person_id;


-- Anfrage 11:
-- Alle Tiere, die in den letzten 30 Tagen adoptiert wurden.
CREATE VIEW anfrage_11 AS
SELECT
    t.tier_id,
    t.name AS tiername,
    a.datum_adoption
FROM adoption a
JOIN tier t ON t.tier_id = a.tier_id
WHERE a.datum_adoption >= CURRENT_DATE - INTERVAL '30 days';


-- Anfrage 12:
-- Der vollständige Verlauf aller Tiere (Tierverlauf),
-- inklusive Rolle und Zeitraum.
CREATE VIEW anfrage_12 AS
SELECT
    t.tier_id,
    t.name AS tiername,
    tv.rolle,
    tv.start_datum,
    tv.end_datum
FROM tier t
JOIN tierverlauf tv ON tv.tier_id = t.tier_id;


-- Anfrage 13:
-- Alle Tiere, die bereits adoptiert wurden,
-- sich aber aktuell wieder im Tierheim befinden.
CREATE VIEW anfrage_13  AS
SELECT DISTINCT
    t.tier_id,
    t.name AS tiername
FROM tier t
JOIN adoption a ON a.tier_id = t.tier_id
WHERE t.aktuell_status = 'im_heim';


-- Anfrage 14:
-- Kontaktdaten aller Bewerber inklusive Adresse.
CREATE VIEW anfrage_14 AS
SELECT p.name, p.email, p.telefon , b.anschrift
FROM person p
JOIN bewerber b ON p.person_id = b.person_id;


-- Anfrage 15:
-- Alle Tiere mit dem Bedürfnis "Benötigt Einzelhaltung",
-- die aktuell in einem Zwinger mit mehr als einem Platz untergebracht sind
-- (Regelverletzung).
CREATE VIEW anfrage_15 AS
SELECT t.name, t.tier_id,t.tierart_id
FROM tier t 
JOIN tier_beduerfnis tb ON t.tier_id = tb.tier_id
JOIN beduerfnis b ON tb.beduerfnis_id = b.beduerfnis_id
JOIN unterbringung u ON t.tier_id = u.tier_id
JOIN platz p ON p.platz_id = u.platz_id
WHERE b.beschreibung = 'Benötigt Einzelhaltung' AND p.typ = 'zwinger' AND p.kapazitaet > 1;


-- Anfrage 16:
-- Alle Mitarbeiter mit ihrer spezialisierten Tierart
-- und der Anzahl der von ihnen betreuten Zwinger.
CREATE VIEW	anfrage_16 AS
SELECT name, bezeichnung AS spezialisierten_tierart, anzahl_betreuter_zwinger
FROM mitarbeiter m
JOIN person p ON m.person_id = p.person_id
JOIN tierart t ON t.tierart_id = m.spezialisiert_tierart_id;


-- Anfrage 17:
-- Alle Tiere, die in einer Pflegestation untergebracht sind,
-- inklusive zuständiger Pflegekraft und Abteilung.
CREATE VIEW anfrage_17 AS
SELECT t.tier_id, t.name AS tiername, pers.name AS pflegekraft, a.abteilung_id, a.bezeichnung AS abteilung
FROM unterbringung u
JOIN tier t ON u.tier_id = t.tier_id
JOIN pflegestation ps ON u.pflegestation_id = ps.pflegestation_id
JOIN pflegekraft pk ON ps.pflegekraft_id = pk.person_id
JOIN person pers ON pk.person_id = pers.person_id
LEFT JOIN abteilung a ON ps.abteilung_id = a.abteilung_id;


-- Anfrage 18:
-- Alle Bewerber mit der Anzahl der von ihnen zurückgegebenen Tiere.
CREATE VIEW anfrage_18 AS
SELECT p.name, b.anschrift, COUNT(*) AS AnzahlRueckgaben
FROM bewerber b
JOIN person p ON b.person_id = p.person_id
JOIN adoption a ON a.bewerber_id = b.person_id
WHERE a.datum_rueckgabe IS NOT NULL
GROUP BY p.name, b.anschrift;


-- Anfrage 19:
-- Alle Tiere, die mehr als eine unterschiedliche Krankheit hatten oder haben.
CREATE VIEW anfrage_19 AS
SELECT t.name, COUNT(DISTINCT k.krankheit_id) AS verschiedene_krankheiten
FROM tier t
JOIN tier_krankheit tk ON tk.tier_id = t.tier_id
JOIN krankheit k ON k.krankheit_id = tk.krankheit_id
GROUP BY t.name
HAVING COUNT(DISTINCT k.krankheit_id) > 1;


-- Anfrage 20:
-- Alle Tiere, die aktuell in einer Quarantänestation untergebracht sind,
-- inklusive Stationsnummer und Abteilung.
CREATE VIEW anfrage_20 AS
SELECT	t.tier_id,	t.name AS tiername,	q.station_nr AS stationsnummer,a.bezeichnung AS abteilung
FROM unterbringung u
JOIN tier t ON u.tier_id = t.tier_id
JOIN platz pl ON u.platz_id = pl.platz_id
JOIN quarantaenestation q ON pl.platz_id = q.platz_id
LEFT JOIN abteilung a ON pl.abteilung_id = a.abteilung_id
WHERE u.platz_id IS NOT NULL
  AND pl.typ = 'quarantaene';


-- Anfrage 21:
-- Alle Tiere mit ihren individuellen Bedürfnissen,
-- bei denen das Bedürfnis "Benötigt Einzelhaltung" gilt.
CREATE VIEW anfrage_21 AS
SELECT t.name AS tiername , t.tier_id, b.beschreibung 
FROM tier t 
JOIN tier_beduerfnis tb ON tb.tier_id = t.tier_id 
JOIN beduerfnis b ON b.beduerfnis_id = tb.beduerfnis_id 
WHERE b.beschreibung = 'Benötigt Einzelhaltung';


-- Anfrage 22:
-- Alle Adoptionen, bei denen ein Tier zurückgegeben wurde,
-- inklusive Rückgabedatum und Rückgabegrund.
CREATE VIEW anfrage_22 AS
SELECT t.name AS tiername, p.name AS bewerber, a.datum_adoption, a.datum_rueckgabe, a.rueckgabe_grund
FROM adoption a
JOIN tier t ON t.tier_id = a.tier_id
JOIN bewerber b ON b.person_id = a.bewerber_id
JOIN person p ON p.person_id = b.person_id
WHERE a.datum_rueckgabe IS NOT NULL;


-- Anfrage 23:
-- Die jeweils letzte Unterbringung jedes Tieres
-- (aktuellste Unterbringung pro Tier).
CREATE VIEW anfrage_23 AS
SELECT t.tier_id, t.name AS tiername, u.start_datum, u.end_datum, u.bemerkung, p.typ AS unterbringung
FROM tier t
JOIN unterbringung u ON u.tier_id = t.tier_id
JOIN platz p ON p.platz_id = u.platz_id
WHERE u.start_datum = (
    SELECT MAX(u2.start_datum)
    FROM unterbringung u2
    WHERE u2.tier_id = t.tier_id
);


-- Anfrage 24:
-- Alle Tiere der Tierart "Hund" mit ihren Stammdaten.
CREATE VIEW anfrage_24 AS 
SELECT t.tier_id, t.name, t.geburtsdatum, t.geschlecht, t.aktuell_status, ta.bezeichnung AS tierart
FROM tier t
JOIN tierart ta ON ta.tierart_id = t.tierart_id
WHERE ta.bezeichnung = 'Hund';


-- Anfrage 25:
-- Alle Tiere, deren Tierart das Bedürfnis
-- "Benötigt grosser Auslauf" hat und die aktuell im Tierheim sind.
CREATE VIEW anfrage_25 AS
SELECT t.tier_id, t.name, ta.bezeichnung AS tierart, t.aktuell_status
FROM tier t
JOIN tierart ta ON ta.tierart_id = t.tierart_id
JOIN tierart_beduerfnis tab ON tab.tierart_id = ta.tierart_id
JOIN beduerfnis b ON b.beduerfnis_id = tab.beduerfnis_id
WHERE b.beschreibung = 'Benötigt grosser Auslauf' AND t.aktuell_status = 'im_heim';