--
-- PostgreSQL database dump
--

\restrict 9roXoMDgTDjYYPcdfeq6yGgcccZlyISMk7PzIp0mY2ztQUO8Jyt4F8dgo0vCHWb

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-12-18 16:45:34

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 908 (class 1247 OID 17276)
-- Name: platz_typ; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.platz_typ AS ENUM (
    'zwinger',
    'quarantaene'
);


ALTER TYPE public.platz_typ OWNER TO postgres;

--
-- TOC entry 911 (class 1247 OID 17282)
-- Name: tier_geschlecht; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tier_geschlecht AS ENUM (
    'm',
    'w',
    'u'
);


ALTER TYPE public.tier_geschlecht OWNER TO postgres;

--
-- TOC entry 905 (class 1247 OID 17268)
-- Name: tier_groesse; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tier_groesse AS ENUM (
    'klein',
    'mittel',
    'gross'
);


ALTER TYPE public.tier_groesse OWNER TO postgres;

--
-- TOC entry 914 (class 1247 OID 17290)
-- Name: tier_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tier_status AS ENUM (
    'im_heim',
    'in_pflege',
    'adoptiert',
    'in_quarantaene'
);


ALTER TYPE public.tier_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 229 (class 1259 OID 17388)
-- Name: abteilung; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.abteilung (
    abteilung_id integer NOT NULL,
    bezeichnung text NOT NULL,
    anzahl_zwinger integer DEFAULT 0 NOT NULL,
    tierart_id integer NOT NULL,
    CONSTRAINT abteilung_anzahl_zwinger_check CHECK ((anzahl_zwinger >= 0))
);


ALTER TABLE public.abteilung OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17387)
-- Name: abteilung_abteilung_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.abteilung_abteilung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.abteilung_abteilung_id_seq OWNER TO postgres;

--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 228
-- Name: abteilung_abteilung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.abteilung_abteilung_id_seq OWNED BY public.abteilung.abteilung_id;


--
-- TOC entry 239 (class 1259 OID 17493)
-- Name: adoption; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adoption (
    adoption_id integer NOT NULL,
    tier_id integer NOT NULL,
    bewerber_id integer NOT NULL,
    mitarbeiter_id integer,
    datum_adoption date NOT NULL,
    datum_rueckgabe date,
    rueckgabe_grund text,
    CONSTRAINT adoption_check CHECK (((datum_rueckgabe IS NULL) OR (datum_rueckgabe >= datum_adoption)))
);


ALTER TABLE public.adoption OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17492)
-- Name: adoption_adoption_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adoption_adoption_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adoption_adoption_id_seq OWNER TO postgres;

--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 238
-- Name: adoption_adoption_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adoption_adoption_id_seq OWNED BY public.adoption.adoption_id;


--
-- TOC entry 241 (class 1259 OID 17518)
-- Name: adoptionvisit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adoptionvisit (
    visit_id integer NOT NULL,
    adoption_id integer NOT NULL,
    mitarbeiter_id integer,
    visit_datum date NOT NULL,
    bemerkung text,
    ergebnis text
);


ALTER TABLE public.adoptionvisit OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17517)
-- Name: adoptionvisit_visit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adoptionvisit_visit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adoptionvisit_visit_id_seq OWNER TO postgres;

--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 240
-- Name: adoptionvisit_visit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adoptionvisit_visit_id_seq OWNED BY public.adoptionvisit.visit_id;


--
-- TOC entry 231 (class 1259 OID 17404)
-- Name: platz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.platz (
    platz_id integer NOT NULL,
    typ public.platz_typ NOT NULL,
    kapazitaet integer NOT NULL,
    abteilung_id integer,
    CONSTRAINT platz_kapazitaet_check CHECK ((kapazitaet > 0))
);


ALTER TABLE public.platz OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17372)
-- Name: tier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tier (
    tier_id integer NOT NULL,
    name text NOT NULL,
    geburtsdatum date,
    geschlecht public.tier_geschlecht DEFAULT 'u'::public.tier_geschlecht NOT NULL,
    tierart_id integer NOT NULL,
    aktuell_status public.tier_status DEFAULT 'im_heim'::public.tier_status NOT NULL
);


ALTER TABLE public.tier OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 17462)
-- Name: unterbringung; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unterbringung (
    unterbringung_id integer NOT NULL,
    tier_id integer NOT NULL,
    tierheim_id integer,
    platz_id integer,
    pflegestation_id integer,
    start_datum date NOT NULL,
    end_datum date,
    bemerkung text,
    CONSTRAINT unterbringung_check CHECK (((end_datum IS NULL) OR (start_datum <= end_datum))),
    CONSTRAINT unterbringung_check1 CHECK (((platz_id IS NOT NULL) OR (pflegestation_id IS NOT NULL)))
);


ALTER TABLE public.unterbringung OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17416)
-- Name: zwinger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zwinger (
    platz_id integer NOT NULL,
    zwinger_nr text
);


ALTER TABLE public.zwinger OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 17639)
-- Name: anfrage_1; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_1 AS
 SELECT t.name AS tier_name,
    z.zwinger_nr,
    p.kapazitaet AS platz_kapazitaet,
    a.bezeichnung AS abteilung
   FROM ((((public.tier t
     JOIN public.unterbringung u ON ((u.tier_id = t.tier_id)))
     JOIN public.platz p ON ((p.platz_id = u.platz_id)))
     JOIN public.zwinger z ON ((z.platz_id = p.platz_id)))
     JOIN public.abteilung a ON ((a.abteilung_id = p.abteilung_id)))
  WHERE ((t.aktuell_status = 'im_heim'::public.tier_status) AND (p.typ = 'zwinger'::public.platz_typ) AND ((u.end_datum IS NULL) OR (u.end_datum >= CURRENT_DATE)));


ALTER VIEW public.anfrage_1 OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17347)
-- Name: bewerber; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bewerber (
    person_id integer NOT NULL,
    anschrift text
);


ALTER TABLE public.bewerber OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17330)
-- Name: mitarbeiter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mitarbeiter (
    person_id integer NOT NULL,
    spezialisiert_tierart_id integer,
    anzahl_betreuter_zwinger integer DEFAULT 0 NOT NULL,
    CONSTRAINT mitarbeiter_anzahl_betreuter_zwinger_check CHECK ((anzahl_betreuter_zwinger >= 0))
);


ALTER TABLE public.mitarbeiter OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17309)
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    person_id integer NOT NULL,
    name text NOT NULL,
    email text,
    telefon text
);


ALTER TABLE public.person OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 17679)
-- Name: anfrage_10; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_10 AS
 SELECT t.tier_id,
    t.name AS tiername,
    a.datum_adoption,
    pb.name AS bewerber_name,
    pm.name AS mitarbeiter_name
   FROM (((((public.adoption a
     JOIN public.tier t ON ((t.tier_id = a.tier_id)))
     JOIN public.bewerber b ON ((b.person_id = a.bewerber_id)))
     JOIN public.person pb ON ((pb.person_id = b.person_id)))
     LEFT JOIN public.mitarbeiter m ON ((m.person_id = a.mitarbeiter_id)))
     LEFT JOIN public.person pm ON ((pm.person_id = m.person_id)));


ALTER VIEW public.anfrage_10 OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 17684)
-- Name: anfrage_11; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_11 AS
 SELECT t.tier_id,
    t.name AS tiername,
    a.datum_adoption
   FROM (public.adoption a
     JOIN public.tier t ON ((t.tier_id = a.tier_id)))
  WHERE (a.datum_adoption >= (CURRENT_DATE - '30 days'::interval));


ALTER VIEW public.anfrage_11 OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 17605)
-- Name: tierverlauf; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tierverlauf (
    verlauf_id integer NOT NULL,
    tier_id integer NOT NULL,
    person_id integer NOT NULL,
    rolle text NOT NULL,
    start_datum date,
    end_datum date,
    bemerkung text,
    CONSTRAINT tierverlauf_check CHECK (((end_datum IS NULL) OR (start_datum <= end_datum)))
);


ALTER TABLE public.tierverlauf OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 17688)
-- Name: anfrage_12; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_12 AS
 SELECT t.tier_id,
    t.name AS tiername,
    tv.rolle,
    tv.start_datum,
    tv.end_datum
   FROM (public.tier t
     JOIN public.tierverlauf tv ON ((tv.tier_id = t.tier_id)));


ALTER VIEW public.anfrage_12 OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 17692)
-- Name: anfrage_13; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_13 AS
 SELECT DISTINCT t.tier_id,
    t.name AS tiername
   FROM (public.tier t
     JOIN public.adoption a ON ((a.tier_id = t.tier_id)))
  WHERE (t.aktuell_status = 'im_heim'::public.tier_status);


ALTER VIEW public.anfrage_13 OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 17696)
-- Name: anfrage_14; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_14 AS
 SELECT p.name,
    p.email,
    p.telefon,
    b.anschrift
   FROM (public.person p
     JOIN public.bewerber b ON ((p.person_id = b.person_id)));


ALTER VIEW public.anfrage_14 OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 17566)
-- Name: beduerfnis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.beduerfnis (
    beduerfnis_id integer NOT NULL,
    beschreibung text NOT NULL,
    art text,
    wert text
);


ALTER TABLE public.beduerfnis OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 17574)
-- Name: tier_beduerfnis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tier_beduerfnis (
    tier_id integer NOT NULL,
    beduerfnis_id integer NOT NULL
);


ALTER TABLE public.tier_beduerfnis OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 17700)
-- Name: anfrage_15; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_15 AS
 SELECT t.name,
    t.tier_id,
    t.tierart_id
   FROM ((((public.tier t
     JOIN public.tier_beduerfnis tb ON ((t.tier_id = tb.tier_id)))
     JOIN public.beduerfnis b ON ((tb.beduerfnis_id = b.beduerfnis_id)))
     JOIN public.unterbringung u ON ((t.tier_id = u.tier_id)))
     JOIN public.platz p ON ((p.platz_id = u.platz_id)))
  WHERE ((b.beschreibung = 'Benötigt Einzelhaltung'::text) AND (p.typ = 'zwinger'::public.platz_typ) AND (p.kapazitaet > 1));


ALTER VIEW public.anfrage_15 OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17320)
-- Name: tierart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tierart (
    tierart_id integer NOT NULL,
    bezeichnung text NOT NULL,
    groesse public.tier_groesse NOT NULL
);


ALTER TABLE public.tierart OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 17705)
-- Name: anfrage_16; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_16 AS
 SELECT p.name,
    t.bezeichnung AS spezialisierten_tierart,
    m.anzahl_betreuter_zwinger
   FROM ((public.mitarbeiter m
     JOIN public.person p ON ((m.person_id = p.person_id)))
     JOIN public.tierart t ON ((t.tierart_id = m.spezialisiert_tierart_id)));


ALTER VIEW public.anfrage_16 OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17359)
-- Name: pflegekraft; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pflegekraft (
    person_id integer NOT NULL,
    anzahl_tiere integer DEFAULT 0 NOT NULL,
    CONSTRAINT pflegekraft_anzahl_tiere_check CHECK ((anzahl_tiere >= 0))
);


ALTER TABLE public.pflegekraft OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17441)
-- Name: pflegestation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pflegestation (
    pflegestation_id integer NOT NULL,
    kapazitaet integer NOT NULL,
    aktuelle_belegung integer DEFAULT 0 NOT NULL,
    abteilung_id integer,
    pflegekraft_id integer,
    CONSTRAINT pflegestation_aktuelle_belegung_check CHECK ((aktuelle_belegung >= 0)),
    CONSTRAINT pflegestation_check CHECK ((aktuelle_belegung <= kapazitaet)),
    CONSTRAINT pflegestation_kapazitaet_check CHECK ((kapazitaet > 0))
);


ALTER TABLE public.pflegestation OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 17709)
-- Name: anfrage_17; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_17 AS
 SELECT t.tier_id,
    t.name AS tiername,
    pers.name AS pflegekraft,
    a.abteilung_id,
    a.bezeichnung AS abteilung
   FROM (((((public.unterbringung u
     JOIN public.tier t ON ((u.tier_id = t.tier_id)))
     JOIN public.pflegestation ps ON ((u.pflegestation_id = ps.pflegestation_id)))
     JOIN public.pflegekraft pk ON ((ps.pflegekraft_id = pk.person_id)))
     JOIN public.person pers ON ((pk.person_id = pers.person_id)))
     LEFT JOIN public.abteilung a ON ((ps.abteilung_id = a.abteilung_id)));


ALTER VIEW public.anfrage_17 OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 17714)
-- Name: anfrage_18; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_18 AS
 SELECT p.name,
    b.anschrift,
    count(*) AS anzahlrueckgaben
   FROM ((public.bewerber b
     JOIN public.person p ON ((b.person_id = p.person_id)))
     JOIN public.adoption a ON ((a.bewerber_id = b.person_id)))
  WHERE (a.datum_rueckgabe IS NOT NULL)
  GROUP BY p.name, b.anschrift;


ALTER VIEW public.anfrage_18 OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 17537)
-- Name: krankheit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.krankheit (
    krankheit_id integer NOT NULL,
    name text NOT NULL,
    ansteckend boolean DEFAULT false NOT NULL,
    freilauf_erlaubt boolean DEFAULT true NOT NULL,
    beschreibung text
);


ALTER TABLE public.krankheit OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 17549)
-- Name: tier_krankheit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tier_krankheit (
    tier_id integer NOT NULL,
    krankheit_id integer NOT NULL,
    diagnose_datum date NOT NULL,
    geheilt boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tier_krankheit OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 17719)
-- Name: anfrage_19; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_19 AS
 SELECT t.name,
    count(DISTINCT k.krankheit_id) AS verschiedene_krankheiten
   FROM ((public.tier t
     JOIN public.tier_krankheit tk ON ((tk.tier_id = t.tier_id)))
     JOIN public.krankheit k ON ((k.krankheit_id = tk.krankheit_id)))
  GROUP BY t.name
 HAVING (count(DISTINCT k.krankheit_id) > 1);


ALTER VIEW public.anfrage_19 OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 17644)
-- Name: anfrage_2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_2 AS
 SELECT b.person_id AS bewerber_id,
    p.name AS bewerber_name,
    count(a.tier_id) AS anzahl_tiere
   FROM ((public.bewerber b
     JOIN public.person p ON ((p.person_id = b.person_id)))
     JOIN public.adoption a ON ((a.bewerber_id = b.person_id)))
  WHERE (a.datum_rueckgabe IS NULL)
  GROUP BY b.person_id, p.name;


ALTER VIEW public.anfrage_2 OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17428)
-- Name: quarantaenestation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quarantaenestation (
    platz_id integer NOT NULL,
    station_nr text
);


ALTER TABLE public.quarantaenestation OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 17724)
-- Name: anfrage_20; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_20 AS
 SELECT t.tier_id,
    t.name AS tiername,
    q.station_nr AS stationsnummer,
    a.bezeichnung AS abteilung
   FROM ((((public.unterbringung u
     JOIN public.tier t ON ((u.tier_id = t.tier_id)))
     JOIN public.platz pl ON ((u.platz_id = pl.platz_id)))
     JOIN public.quarantaenestation q ON ((pl.platz_id = q.platz_id)))
     LEFT JOIN public.abteilung a ON ((pl.abteilung_id = a.abteilung_id)))
  WHERE ((u.platz_id IS NOT NULL) AND (pl.typ = 'quarantaene'::public.platz_typ));


ALTER VIEW public.anfrage_20 OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 17729)
-- Name: anfrage_21; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_21 AS
 SELECT t.name AS tiername,
    t.tier_id,
    b.beschreibung
   FROM ((public.tier t
     JOIN public.tier_beduerfnis tb ON ((tb.tier_id = t.tier_id)))
     JOIN public.beduerfnis b ON ((b.beduerfnis_id = tb.beduerfnis_id)))
  WHERE (b.beschreibung = 'Benötigt Einzelhaltung'::text);


ALTER VIEW public.anfrage_21 OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 17733)
-- Name: anfrage_22; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_22 AS
 SELECT t.name AS tiername,
    p.name AS bewerber,
    a.datum_adoption,
    a.datum_rueckgabe,
    a.rueckgabe_grund
   FROM (((public.adoption a
     JOIN public.tier t ON ((t.tier_id = a.tier_id)))
     JOIN public.bewerber b ON ((b.person_id = a.bewerber_id)))
     JOIN public.person p ON ((p.person_id = b.person_id)))
  WHERE (a.datum_rueckgabe IS NOT NULL);


ALTER VIEW public.anfrage_22 OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 17738)
-- Name: anfrage_23; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_23 AS
 SELECT t.tier_id,
    t.name AS tiername,
    u.start_datum,
    u.end_datum,
    u.bemerkung,
    p.typ AS unterbringung
   FROM ((public.tier t
     JOIN public.unterbringung u ON ((u.tier_id = t.tier_id)))
     JOIN public.platz p ON ((p.platz_id = u.platz_id)))
  WHERE (u.start_datum = ( SELECT max(u2.start_datum) AS max
           FROM public.unterbringung u2
          WHERE (u2.tier_id = t.tier_id)));


ALTER VIEW public.anfrage_23 OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 17743)
-- Name: anfrage_24; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_24 AS
 SELECT t.tier_id,
    t.name,
    t.geburtsdatum,
    t.geschlecht,
    t.aktuell_status,
    ta.bezeichnung AS tierart
   FROM (public.tier t
     JOIN public.tierart ta ON ((ta.tierart_id = t.tierart_id)))
  WHERE (ta.bezeichnung = 'Hund'::text);


ALTER VIEW public.anfrage_24 OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 17589)
-- Name: tierart_beduerfnis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tierart_beduerfnis (
    tierart_id integer NOT NULL,
    beduerfnis_id integer NOT NULL
);


ALTER TABLE public.tierart_beduerfnis OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 17747)
-- Name: anfrage_25; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_25 AS
 SELECT t.tier_id,
    t.name,
    ta.bezeichnung AS tierart,
    t.aktuell_status
   FROM (((public.tier t
     JOIN public.tierart ta ON ((ta.tierart_id = t.tierart_id)))
     JOIN public.tierart_beduerfnis tab ON ((tab.tierart_id = ta.tierart_id)))
     JOIN public.beduerfnis b ON ((b.beduerfnis_id = tab.beduerfnis_id)))
  WHERE ((b.beschreibung = 'Benötigt grosser Auslauf'::text) AND (t.aktuell_status = 'im_heim'::public.tier_status));


ALTER VIEW public.anfrage_25 OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 17649)
-- Name: anfrage_3; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_3 AS
 SELECT tier_id,
    name,
    geburtsdatum,
    geschlecht,
    tierart_id,
    aktuell_status
   FROM public.tier
  WHERE (aktuell_status = 'im_heim'::public.tier_status);


ALTER VIEW public.anfrage_3 OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 17653)
-- Name: anfrage_4; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_4 AS
 SELECT t.tier_id,
    t.name,
    u.start_datum,
    u.platz_id,
    u.pflegestation_id
   FROM (public.tier t
     JOIN public.unterbringung u ON ((u.tier_id = t.tier_id)))
  WHERE ((u.end_datum IS NULL) AND ((CURRENT_DATE - u.start_datum) > 180));


ALTER VIEW public.anfrage_4 OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 17657)
-- Name: anfrage_5; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_5 AS
 SELECT t.tier_id,
    t.name AS tiername,
    k.name AS krankheitsname,
    tk.diagnose_datum,
    tk.geheilt
   FROM ((public.tier t
     JOIN public.tier_krankheit tk ON ((tk.tier_id = t.tier_id)))
     JOIN public.krankheit k ON ((k.krankheit_id = tk.krankheit_id)));


ALTER VIEW public.anfrage_5 OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 17661)
-- Name: anfrage_6; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_6 AS
 SELECT pk.person_id AS pflegekraft_id,
    p.name AS pflegekraft_name,
    ps.pflegestation_id,
    count(u.tier_id) AS anzahl_tiere
   FROM (((public.pflegekraft pk
     JOIN public.person p ON ((p.person_id = pk.person_id)))
     LEFT JOIN public.pflegestation ps ON ((ps.pflegekraft_id = pk.person_id)))
     LEFT JOIN public.unterbringung u ON (((u.pflegestation_id = ps.pflegestation_id) AND (u.end_datum IS NULL))))
  GROUP BY pk.person_id, p.name, ps.pflegestation_id;


ALTER VIEW public.anfrage_6 OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 17666)
-- Name: anfrage_7; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_7 AS
 SELECT t.tier_id,
    t.name AS tiername,
    k.name AS krankheit,
    k.freilauf_erlaubt
   FROM ((public.tier t
     JOIN public.tier_krankheit tk ON ((tk.tier_id = t.tier_id)))
     JOIN public.krankheit k ON ((k.krankheit_id = tk.krankheit_id)))
  WHERE ((tk.geheilt = false) AND (k.ansteckend = true));


ALTER VIEW public.anfrage_7 OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 17670)
-- Name: anfrage_8; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_8 AS
 SELECT t.tier_id,
    t.name,
    u.start_datum,
    u.platz_id,
    u.pflegestation_id
   FROM (public.unterbringung u
     JOIN public.tier t ON ((t.tier_id = u.tier_id)))
  WHERE (EXTRACT(year FROM u.start_datum) = EXTRACT(year FROM CURRENT_DATE));


ALTER VIEW public.anfrage_8 OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 17674)
-- Name: anfrage_9; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.anfrage_9 AS
 SELECT t.tier_id,
    t.name AS tiername,
    ta.bezeichnung AS tierart
   FROM (((public.tier t
     JOIN public.tierart ta ON ((ta.tierart_id = t.tierart_id)))
     JOIN public.tierart_beduerfnis tb ON ((tb.tierart_id = ta.tierart_id)))
     JOIN public.beduerfnis b ON ((b.beduerfnis_id = tb.beduerfnis_id)))
  WHERE (b.beschreibung = 'Benötigt grosser Auslauf'::text);


ALTER VIEW public.anfrage_9 OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 17565)
-- Name: beduerfnis_beduerfnis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.beduerfnis_beduerfnis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.beduerfnis_beduerfnis_id_seq OWNER TO postgres;

--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 245
-- Name: beduerfnis_beduerfnis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.beduerfnis_beduerfnis_id_seq OWNED BY public.beduerfnis.beduerfnis_id;


--
-- TOC entry 242 (class 1259 OID 17536)
-- Name: krankheit_krankheit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.krankheit_krankheit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.krankheit_krankheit_id_seq OWNER TO postgres;

--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 242
-- Name: krankheit_krankheit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.krankheit_krankheit_id_seq OWNED BY public.krankheit.krankheit_id;


--
-- TOC entry 251 (class 1259 OID 17624)
-- Name: mitarbeiter_zwinger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mitarbeiter_zwinger (
    mitarbeiter_id integer NOT NULL,
    platz_id integer NOT NULL
);


ALTER TABLE public.mitarbeiter_zwinger OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17308)
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_person_id_seq OWNER TO postgres;

--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 219
-- Name: person_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_person_id_seq OWNED BY public.person.person_id;


--
-- TOC entry 234 (class 1259 OID 17440)
-- Name: pflegestation_pflegestation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pflegestation_pflegestation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pflegestation_pflegestation_id_seq OWNER TO postgres;

--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 234
-- Name: pflegestation_pflegestation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pflegestation_pflegestation_id_seq OWNED BY public.pflegestation.pflegestation_id;


--
-- TOC entry 230 (class 1259 OID 17403)
-- Name: platz_platz_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.platz_platz_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.platz_platz_id_seq OWNER TO postgres;

--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 230
-- Name: platz_platz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.platz_platz_id_seq OWNED BY public.platz.platz_id;


--
-- TOC entry 226 (class 1259 OID 17371)
-- Name: tier_tier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tier_tier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tier_tier_id_seq OWNER TO postgres;

--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 226
-- Name: tier_tier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tier_tier_id_seq OWNED BY public.tier.tier_id;


--
-- TOC entry 221 (class 1259 OID 17319)
-- Name: tierart_tierart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tierart_tierart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tierart_tierart_id_seq OWNER TO postgres;

--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 221
-- Name: tierart_tierart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tierart_tierart_id_seq OWNED BY public.tierart.tierart_id;


--
-- TOC entry 218 (class 1259 OID 17300)
-- Name: tierheim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tierheim (
    tierheim_id integer NOT NULL,
    name text NOT NULL,
    adresse text
);


ALTER TABLE public.tierheim OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17299)
-- Name: tierheim_tierheim_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tierheim_tierheim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tierheim_tierheim_id_seq OWNER TO postgres;

--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 217
-- Name: tierheim_tierheim_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tierheim_tierheim_id_seq OWNED BY public.tierheim.tierheim_id;


--
-- TOC entry 249 (class 1259 OID 17604)
-- Name: tierverlauf_verlauf_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tierverlauf_verlauf_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tierverlauf_verlauf_id_seq OWNER TO postgres;

--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 249
-- Name: tierverlauf_verlauf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tierverlauf_verlauf_id_seq OWNED BY public.tierverlauf.verlauf_id;


--
-- TOC entry 236 (class 1259 OID 17461)
-- Name: unterbringung_unterbringung_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unterbringung_unterbringung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.unterbringung_unterbringung_id_seq OWNER TO postgres;

--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 236
-- Name: unterbringung_unterbringung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.unterbringung_unterbringung_id_seq OWNED BY public.unterbringung.unterbringung_id;


--
-- TOC entry 4958 (class 2604 OID 17391)
-- Name: abteilung abteilung_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abteilung ALTER COLUMN abteilung_id SET DEFAULT nextval('public.abteilung_abteilung_id_seq'::regclass);


--
-- TOC entry 4964 (class 2604 OID 17496)
-- Name: adoption adoption_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption ALTER COLUMN adoption_id SET DEFAULT nextval('public.adoption_adoption_id_seq'::regclass);


--
-- TOC entry 4965 (class 2604 OID 17521)
-- Name: adoptionvisit visit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoptionvisit ALTER COLUMN visit_id SET DEFAULT nextval('public.adoptionvisit_visit_id_seq'::regclass);


--
-- TOC entry 4970 (class 2604 OID 17569)
-- Name: beduerfnis beduerfnis_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beduerfnis ALTER COLUMN beduerfnis_id SET DEFAULT nextval('public.beduerfnis_beduerfnis_id_seq'::regclass);


--
-- TOC entry 4966 (class 2604 OID 17540)
-- Name: krankheit krankheit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.krankheit ALTER COLUMN krankheit_id SET DEFAULT nextval('public.krankheit_krankheit_id_seq'::regclass);


--
-- TOC entry 4951 (class 2604 OID 17312)
-- Name: person person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person ALTER COLUMN person_id SET DEFAULT nextval('public.person_person_id_seq'::regclass);


--
-- TOC entry 4961 (class 2604 OID 17444)
-- Name: pflegestation pflegestation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pflegestation ALTER COLUMN pflegestation_id SET DEFAULT nextval('public.pflegestation_pflegestation_id_seq'::regclass);


--
-- TOC entry 4960 (class 2604 OID 17407)
-- Name: platz platz_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platz ALTER COLUMN platz_id SET DEFAULT nextval('public.platz_platz_id_seq'::regclass);


--
-- TOC entry 4955 (class 2604 OID 17375)
-- Name: tier tier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier ALTER COLUMN tier_id SET DEFAULT nextval('public.tier_tier_id_seq'::regclass);


--
-- TOC entry 4952 (class 2604 OID 17323)
-- Name: tierart tierart_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierart ALTER COLUMN tierart_id SET DEFAULT nextval('public.tierart_tierart_id_seq'::regclass);


--
-- TOC entry 4950 (class 2604 OID 17303)
-- Name: tierheim tierheim_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierheim ALTER COLUMN tierheim_id SET DEFAULT nextval('public.tierheim_tierheim_id_seq'::regclass);


--
-- TOC entry 4971 (class 2604 OID 17608)
-- Name: tierverlauf verlauf_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierverlauf ALTER COLUMN verlauf_id SET DEFAULT nextval('public.tierverlauf_verlauf_id_seq'::regclass);


--
-- TOC entry 4963 (class 2604 OID 17465)
-- Name: unterbringung unterbringung_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unterbringung ALTER COLUMN unterbringung_id SET DEFAULT nextval('public.unterbringung_unterbringung_id_seq'::regclass);


--
-- TOC entry 5245 (class 0 OID 17388)
-- Dependencies: 229
-- Data for Name: abteilung; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.abteilung (abteilung_id, bezeichnung, anzahl_zwinger, tierart_id) FROM stdin;
1	Hunde-Abteilung A	5	1
2	Katzen-Abteilung A	4	2
3	Kaninchen-Abteilung A	3	3
4	Kleinsaeuger-Abteilung A	2	4
\.


--
-- TOC entry 5255 (class 0 OID 17493)
-- Dependencies: 239
-- Data for Name: adoption; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adoption (adoption_id, tier_id, bewerber_id, mitarbeiter_id, datum_adoption, datum_rueckgabe, rueckgabe_grund) FROM stdin;
2	10	2	4	2024-11-10	\N	\N
1	11	5	1	2025-02-20	2025-05-10	Nicht vereinbar
\.


--
-- TOC entry 5257 (class 0 OID 17518)
-- Dependencies: 241
-- Data for Name: adoptionvisit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adoptionvisit (visit_id, adoption_id, mitarbeiter_id, visit_datum, bemerkung, ergebnis) FROM stdin;
1	1	1	2025-03-05	Erster Besuch	ok
\.


--
-- TOC entry 5262 (class 0 OID 17566)
-- Dependencies: 246
-- Data for Name: beduerfnis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.beduerfnis (beduerfnis_id, beschreibung, art, wert) FROM stdin;
1	Benötigt Einzelhaltung	Verhalten	Einzel
2	Benötigt grosser Auslauf	Platz	Gross
3	Nicht verträglich mit Katzen	Sozial	KeineKatzen
\.


--
-- TOC entry 5240 (class 0 OID 17347)
-- Dependencies: 224
-- Data for Name: bewerber; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bewerber (person_id, anschrift) FROM stdin;
2	Adlerstraße 5, 20095 Hamburg
5	Birkenweg 7, 20095 Hamburg
\.


--
-- TOC entry 5259 (class 0 OID 17537)
-- Dependencies: 243
-- Data for Name: krankheit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.krankheit (krankheit_id, name, ansteckend, freilauf_erlaubt, beschreibung) FROM stdin;
1	Parvovirose	t	f	schwere Infektion
2	Hautpilz	t	f	ansteckend
3	Herzwurm	f	f	parasitaere Erkrankung
\.


--
-- TOC entry 5239 (class 0 OID 17330)
-- Dependencies: 223
-- Data for Name: mitarbeiter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mitarbeiter (person_id, spezialisiert_tierart_id, anzahl_betreuter_zwinger) FROM stdin;
1	1	4
4	2	2
6	3	3
\.


--
-- TOC entry 5267 (class 0 OID 17624)
-- Dependencies: 251
-- Data for Name: mitarbeiter_zwinger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mitarbeiter_zwinger (mitarbeiter_id, platz_id) FROM stdin;
1	1
\.


--
-- TOC entry 5236 (class 0 OID 17309)
-- Dependencies: 220
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (person_id, name, email, telefon) FROM stdin;
1	Anna Müller	anna.mueller@example.com	040111222
2	Bernd Schmidt	bernd.schmidt@example.com	0170555111
3	Clara Bauer	clara.bauer@example.com	0170222333
4	Dieter Lange	dieter.lange@example.com	0171444555
5	Eva König	eva.koenig@example.com	0172333444
6	Frank Meier	frank.meier@example.com	0173666777
7	Greta Vogel	greta.vogel@example.com	0174888999
8	Hanna Kurz	hanna.kurz@example.com	0175000111
9	Ivan Petrov	ivan.petrov@example.com	0176222000
10	Julia Kramer	julia.kramer@example.com	0177333000
\.


--
-- TOC entry 5241 (class 0 OID 17359)
-- Dependencies: 225
-- Data for Name: pflegekraft; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pflegekraft (person_id, anzahl_tiere) FROM stdin;
3	3
7	1
\.


--
-- TOC entry 5251 (class 0 OID 17441)
-- Dependencies: 235
-- Data for Name: pflegestation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pflegestation (pflegestation_id, kapazitaet, aktuelle_belegung, abteilung_id, pflegekraft_id) FROM stdin;
1	3	1	2	3
2	4	2	1	7
\.


--
-- TOC entry 5247 (class 0 OID 17404)
-- Dependencies: 231
-- Data for Name: platz; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.platz (platz_id, typ, kapazitaet, abteilung_id) FROM stdin;
1	zwinger	2	1
2	zwinger	3	1
3	zwinger	2	1
4	zwinger	1	1
5	quarantaene	1	1
6	zwinger	3	2
7	zwinger	2	2
8	zwinger	1	2
9	quarantaene	1	2
10	zwinger	4	3
11	zwinger	2	3
12	zwinger	2	3
13	zwinger	5	4
14	zwinger	3	4
\.


--
-- TOC entry 5249 (class 0 OID 17428)
-- Dependencies: 233
-- Data for Name: quarantaenestation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quarantaenestation (platz_id, station_nr) FROM stdin;
5	H-Q1
9	K-Q1
\.


--
-- TOC entry 5243 (class 0 OID 17372)
-- Dependencies: 227
-- Data for Name: tier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tier (tier_id, name, geburtsdatum, geschlecht, tierart_id, aktuell_status) FROM stdin;
1	Bello	2019-04-12	m	1	im_heim
2	Poldi	2018-01-01	m	1	im_heim
3	Luna	2020-09-05	w	1	in_pflege
4	Rocky	2021-06-20	m	1	adoptiert
5	Kira	2022-03-11	w	1	im_heim
6	Otis	2023-10-23	m	1	im_heim
7	Molly	2024-02-14	w	1	im_heim
8	Miez	2021-09-01	w	2	in_pflege
9	Whiskers	2020-12-12	m	2	im_heim
10	Susi	2019-07-07	w	2	adoptiert
11	Hoppel	2022-02-10	m	3	adoptiert
12	Floppy	2021-11-05	w	3	im_heim
13	Poppy	2023-04-01	w	3	im_heim
14	Pip	2024-01-10	m	4	im_heim
15	Squeak	2023-06-30	w	4	im_heim
16	Rex	2017-05-05	m	1	im_heim
17	Nala	2022-08-12	w	2	im_heim
18	Gizmo	2020-03-03	m	3	im_heim
19	Bella	2016-10-10	w	1	in_pflege
20	Charlie	2015-02-02	m	1	im_heim
21	Schnuffi	2020-08-08	m	3	in_pflege
22	Tiger	2018-11-11	m	2	im_heim
23	Lilly	2023-09-09	w	4	im_heim
24	Buddy	2021-04-04	m	1	im_heim
25	Flo	2019-06-06	w	2	im_heim
26	Hugo	2014-01-01	m	1	in_pflege
27	Milo	2013-05-15	m	2	adoptiert
28	Nemo	2022-12-20	m	4	im_heim
29	Keks	2024-03-03	m	3	im_heim
\.


--
-- TOC entry 5263 (class 0 OID 17574)
-- Dependencies: 247
-- Data for Name: tier_beduerfnis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tier_beduerfnis (tier_id, beduerfnis_id) FROM stdin;
1	1
2	2
\.


--
-- TOC entry 5260 (class 0 OID 17549)
-- Dependencies: 244
-- Data for Name: tier_krankheit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tier_krankheit (tier_id, krankheit_id, diagnose_datum, geheilt) FROM stdin;
1	1	2025-08-05	f
8	2	2025-07-10	f
\.


--
-- TOC entry 5238 (class 0 OID 17320)
-- Dependencies: 222
-- Data for Name: tierart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tierart (tierart_id, bezeichnung, groesse) FROM stdin;
1	Hund	gross
2	Katze	mittel
3	Kaninchen	klein
4	Meerschweinchen	klein
\.


--
-- TOC entry 5264 (class 0 OID 17589)
-- Dependencies: 248
-- Data for Name: tierart_beduerfnis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tierart_beduerfnis (tierart_id, beduerfnis_id) FROM stdin;
1	2
\.


--
-- TOC entry 5234 (class 0 OID 17300)
-- Dependencies: 218
-- Data for Name: tierheim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tierheim (tierheim_id, name, adresse) FROM stdin;
1	Tierschutz Musterdorf	Musterweg 1, 12345 Musterdorf
\.


--
-- TOC entry 5266 (class 0 OID 17605)
-- Dependencies: 250
-- Data for Name: tierverlauf; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tierverlauf (verlauf_id, tier_id, person_id, rolle, start_datum, end_datum, bemerkung) FROM stdin;
1	11	5	adoption	2025-02-20	2025-05-10	zurueckgegeben
\.


--
-- TOC entry 5253 (class 0 OID 17462)
-- Dependencies: 237
-- Data for Name: unterbringung; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.unterbringung (unterbringung_id, tier_id, tierheim_id, platz_id, pflegestation_id, start_datum, end_datum, bemerkung) FROM stdin;
1	1	1	1	\N	2025-08-01	\N	Neuaufnahme
2	11	1	10	\N	2025-01-05	2025-02-20	Vermittelt
3	8	1	\N	1	2025-07-15	\N	Pflegestelle
\.


--
-- TOC entry 5248 (class 0 OID 17416)
-- Dependencies: 232
-- Data for Name: zwinger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zwinger (platz_id, zwinger_nr) FROM stdin;
1	H-Z1
2	H-Z2
3	H-Z3
4	H-Z4
6	K-Z1
7	K-Z2
8	K-Z3
10	Ka-Z1
11	Ka-Z2
12	Ka-Z3
13	KS-Z1
14	KS-Z2
\.


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 228
-- Name: abteilung_abteilung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.abteilung_abteilung_id_seq', 4, true);


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 238
-- Name: adoption_adoption_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adoption_adoption_id_seq', 2, true);


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 240
-- Name: adoptionvisit_visit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adoptionvisit_visit_id_seq', 1, true);


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 245
-- Name: beduerfnis_beduerfnis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.beduerfnis_beduerfnis_id_seq', 3, true);


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 242
-- Name: krankheit_krankheit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.krankheit_krankheit_id_seq', 3, true);


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 219
-- Name: person_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_person_id_seq', 10, true);


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 234
-- Name: pflegestation_pflegestation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pflegestation_pflegestation_id_seq', 2, true);


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 230
-- Name: platz_platz_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.platz_platz_id_seq', 14, true);


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 226
-- Name: tier_tier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tier_tier_id_seq', 29, true);


--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 221
-- Name: tierart_tierart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tierart_tierart_id_seq', 4, true);


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 217
-- Name: tierheim_tierheim_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tierheim_tierheim_id_seq', 1, true);


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 249
-- Name: tierverlauf_verlauf_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tierverlauf_verlauf_id_seq', 1, true);


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 236
-- Name: unterbringung_unterbringung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unterbringung_unterbringung_id_seq', 3, true);


--
-- TOC entry 5002 (class 2606 OID 17397)
-- Name: abteilung abteilung_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abteilung
    ADD CONSTRAINT abteilung_pkey PRIMARY KEY (abteilung_id);


--
-- TOC entry 5014 (class 2606 OID 17501)
-- Name: adoption adoption_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_pkey PRIMARY KEY (adoption_id);


--
-- TOC entry 5016 (class 2606 OID 17525)
-- Name: adoptionvisit adoptionvisit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoptionvisit
    ADD CONSTRAINT adoptionvisit_pkey PRIMARY KEY (visit_id);


--
-- TOC entry 5024 (class 2606 OID 17573)
-- Name: beduerfnis beduerfnis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beduerfnis
    ADD CONSTRAINT beduerfnis_pkey PRIMARY KEY (beduerfnis_id);


--
-- TOC entry 4996 (class 2606 OID 17353)
-- Name: bewerber bewerber_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bewerber
    ADD CONSTRAINT bewerber_pkey PRIMARY KEY (person_id);


--
-- TOC entry 5018 (class 2606 OID 17548)
-- Name: krankheit krankheit_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.krankheit
    ADD CONSTRAINT krankheit_name_key UNIQUE (name);


--
-- TOC entry 5020 (class 2606 OID 17546)
-- Name: krankheit krankheit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.krankheit
    ADD CONSTRAINT krankheit_pkey PRIMARY KEY (krankheit_id);


--
-- TOC entry 4994 (class 2606 OID 17336)
-- Name: mitarbeiter mitarbeiter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mitarbeiter
    ADD CONSTRAINT mitarbeiter_pkey PRIMARY KEY (person_id);


--
-- TOC entry 5032 (class 2606 OID 17628)
-- Name: mitarbeiter_zwinger mitarbeiter_zwinger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mitarbeiter_zwinger
    ADD CONSTRAINT mitarbeiter_zwinger_pkey PRIMARY KEY (mitarbeiter_id, platz_id);


--
-- TOC entry 4986 (class 2606 OID 17318)
-- Name: person person_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_email_key UNIQUE (email);


--
-- TOC entry 4988 (class 2606 OID 17316)
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- TOC entry 4998 (class 2606 OID 17365)
-- Name: pflegekraft pflegekraft_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pflegekraft
    ADD CONSTRAINT pflegekraft_pkey PRIMARY KEY (person_id);


--
-- TOC entry 5010 (class 2606 OID 17450)
-- Name: pflegestation pflegestation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pflegestation
    ADD CONSTRAINT pflegestation_pkey PRIMARY KEY (pflegestation_id);


--
-- TOC entry 5004 (class 2606 OID 17410)
-- Name: platz platz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platz
    ADD CONSTRAINT platz_pkey PRIMARY KEY (platz_id);


--
-- TOC entry 5008 (class 2606 OID 17434)
-- Name: quarantaenestation quarantaenestation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quarantaenestation
    ADD CONSTRAINT quarantaenestation_pkey PRIMARY KEY (platz_id);


--
-- TOC entry 5026 (class 2606 OID 17578)
-- Name: tier_beduerfnis tier_beduerfnis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_beduerfnis
    ADD CONSTRAINT tier_beduerfnis_pkey PRIMARY KEY (tier_id, beduerfnis_id);


--
-- TOC entry 5022 (class 2606 OID 17554)
-- Name: tier_krankheit tier_krankheit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_krankheit
    ADD CONSTRAINT tier_krankheit_pkey PRIMARY KEY (tier_id, krankheit_id, diagnose_datum);


--
-- TOC entry 5000 (class 2606 OID 17381)
-- Name: tier tier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier
    ADD CONSTRAINT tier_pkey PRIMARY KEY (tier_id);


--
-- TOC entry 5028 (class 2606 OID 17593)
-- Name: tierart_beduerfnis tierart_beduerfnis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierart_beduerfnis
    ADD CONSTRAINT tierart_beduerfnis_pkey PRIMARY KEY (tierart_id, beduerfnis_id);


--
-- TOC entry 4990 (class 2606 OID 17329)
-- Name: tierart tierart_bezeichnung_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierart
    ADD CONSTRAINT tierart_bezeichnung_key UNIQUE (bezeichnung);


--
-- TOC entry 4992 (class 2606 OID 17327)
-- Name: tierart tierart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierart
    ADD CONSTRAINT tierart_pkey PRIMARY KEY (tierart_id);


--
-- TOC entry 4984 (class 2606 OID 17307)
-- Name: tierheim tierheim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierheim
    ADD CONSTRAINT tierheim_pkey PRIMARY KEY (tierheim_id);


--
-- TOC entry 5030 (class 2606 OID 17613)
-- Name: tierverlauf tierverlauf_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierverlauf
    ADD CONSTRAINT tierverlauf_pkey PRIMARY KEY (verlauf_id);


--
-- TOC entry 5012 (class 2606 OID 17471)
-- Name: unterbringung unterbringung_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unterbringung
    ADD CONSTRAINT unterbringung_pkey PRIMARY KEY (unterbringung_id);


--
-- TOC entry 5006 (class 2606 OID 17422)
-- Name: zwinger zwinger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zwinger
    ADD CONSTRAINT zwinger_pkey PRIMARY KEY (platz_id);


--
-- TOC entry 5038 (class 2606 OID 17398)
-- Name: abteilung abteilung_tierart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abteilung
    ADD CONSTRAINT abteilung_tierart_id_fkey FOREIGN KEY (tierart_id) REFERENCES public.tierart(tierart_id) ON DELETE RESTRICT;


--
-- TOC entry 5048 (class 2606 OID 17507)
-- Name: adoption adoption_bewerber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_bewerber_id_fkey FOREIGN KEY (bewerber_id) REFERENCES public.bewerber(person_id) ON DELETE RESTRICT;


--
-- TOC entry 5049 (class 2606 OID 17512)
-- Name: adoption adoption_mitarbeiter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_mitarbeiter_id_fkey FOREIGN KEY (mitarbeiter_id) REFERENCES public.mitarbeiter(person_id) ON DELETE SET NULL;


--
-- TOC entry 5050 (class 2606 OID 17502)
-- Name: adoption adoption_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoption
    ADD CONSTRAINT adoption_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tier(tier_id) ON DELETE RESTRICT;


--
-- TOC entry 5051 (class 2606 OID 17526)
-- Name: adoptionvisit adoptionvisit_adoption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoptionvisit
    ADD CONSTRAINT adoptionvisit_adoption_id_fkey FOREIGN KEY (adoption_id) REFERENCES public.adoption(adoption_id) ON DELETE CASCADE;


--
-- TOC entry 5052 (class 2606 OID 17531)
-- Name: adoptionvisit adoptionvisit_mitarbeiter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adoptionvisit
    ADD CONSTRAINT adoptionvisit_mitarbeiter_id_fkey FOREIGN KEY (mitarbeiter_id) REFERENCES public.mitarbeiter(person_id) ON DELETE SET NULL;


--
-- TOC entry 5035 (class 2606 OID 17354)
-- Name: bewerber bewerber_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bewerber
    ADD CONSTRAINT bewerber_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE CASCADE;


--
-- TOC entry 5033 (class 2606 OID 17337)
-- Name: mitarbeiter mitarbeiter_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mitarbeiter
    ADD CONSTRAINT mitarbeiter_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE CASCADE;


--
-- TOC entry 5034 (class 2606 OID 17342)
-- Name: mitarbeiter mitarbeiter_spezialisiert_tierart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mitarbeiter
    ADD CONSTRAINT mitarbeiter_spezialisiert_tierart_id_fkey FOREIGN KEY (spezialisiert_tierart_id) REFERENCES public.tierart(tierart_id) ON DELETE SET NULL;


--
-- TOC entry 5061 (class 2606 OID 17629)
-- Name: mitarbeiter_zwinger mitarbeiter_zwinger_mitarbeiter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mitarbeiter_zwinger
    ADD CONSTRAINT mitarbeiter_zwinger_mitarbeiter_id_fkey FOREIGN KEY (mitarbeiter_id) REFERENCES public.mitarbeiter(person_id) ON DELETE CASCADE;


--
-- TOC entry 5062 (class 2606 OID 17634)
-- Name: mitarbeiter_zwinger mitarbeiter_zwinger_platz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mitarbeiter_zwinger
    ADD CONSTRAINT mitarbeiter_zwinger_platz_id_fkey FOREIGN KEY (platz_id) REFERENCES public.platz(platz_id) ON DELETE CASCADE;


--
-- TOC entry 5036 (class 2606 OID 17366)
-- Name: pflegekraft pflegekraft_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pflegekraft
    ADD CONSTRAINT pflegekraft_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE CASCADE;


--
-- TOC entry 5042 (class 2606 OID 17451)
-- Name: pflegestation pflegestation_abteilung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pflegestation
    ADD CONSTRAINT pflegestation_abteilung_id_fkey FOREIGN KEY (abteilung_id) REFERENCES public.abteilung(abteilung_id) ON DELETE SET NULL;


--
-- TOC entry 5043 (class 2606 OID 17456)
-- Name: pflegestation pflegestation_pflegekraft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pflegestation
    ADD CONSTRAINT pflegestation_pflegekraft_id_fkey FOREIGN KEY (pflegekraft_id) REFERENCES public.pflegekraft(person_id) ON DELETE SET NULL;


--
-- TOC entry 5039 (class 2606 OID 17411)
-- Name: platz platz_abteilung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platz
    ADD CONSTRAINT platz_abteilung_id_fkey FOREIGN KEY (abteilung_id) REFERENCES public.abteilung(abteilung_id) ON DELETE SET NULL;


--
-- TOC entry 5041 (class 2606 OID 17435)
-- Name: quarantaenestation quarantaenestation_platz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quarantaenestation
    ADD CONSTRAINT quarantaenestation_platz_id_fkey FOREIGN KEY (platz_id) REFERENCES public.platz(platz_id) ON DELETE CASCADE;


--
-- TOC entry 5055 (class 2606 OID 17584)
-- Name: tier_beduerfnis tier_beduerfnis_beduerfnis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_beduerfnis
    ADD CONSTRAINT tier_beduerfnis_beduerfnis_id_fkey FOREIGN KEY (beduerfnis_id) REFERENCES public.beduerfnis(beduerfnis_id) ON DELETE CASCADE;


--
-- TOC entry 5056 (class 2606 OID 17579)
-- Name: tier_beduerfnis tier_beduerfnis_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_beduerfnis
    ADD CONSTRAINT tier_beduerfnis_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tier(tier_id) ON DELETE CASCADE;


--
-- TOC entry 5053 (class 2606 OID 17560)
-- Name: tier_krankheit tier_krankheit_krankheit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_krankheit
    ADD CONSTRAINT tier_krankheit_krankheit_id_fkey FOREIGN KEY (krankheit_id) REFERENCES public.krankheit(krankheit_id) ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 17555)
-- Name: tier_krankheit tier_krankheit_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_krankheit
    ADD CONSTRAINT tier_krankheit_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tier(tier_id) ON DELETE CASCADE;


--
-- TOC entry 5037 (class 2606 OID 17382)
-- Name: tier tier_tierart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier
    ADD CONSTRAINT tier_tierart_id_fkey FOREIGN KEY (tierart_id) REFERENCES public.tierart(tierart_id) ON DELETE RESTRICT;


--
-- TOC entry 5057 (class 2606 OID 17599)
-- Name: tierart_beduerfnis tierart_beduerfnis_beduerfnis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierart_beduerfnis
    ADD CONSTRAINT tierart_beduerfnis_beduerfnis_id_fkey FOREIGN KEY (beduerfnis_id) REFERENCES public.beduerfnis(beduerfnis_id) ON DELETE CASCADE;


--
-- TOC entry 5058 (class 2606 OID 17594)
-- Name: tierart_beduerfnis tierart_beduerfnis_tierart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierart_beduerfnis
    ADD CONSTRAINT tierart_beduerfnis_tierart_id_fkey FOREIGN KEY (tierart_id) REFERENCES public.tierart(tierart_id) ON DELETE CASCADE;


--
-- TOC entry 5059 (class 2606 OID 17619)
-- Name: tierverlauf tierverlauf_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierverlauf
    ADD CONSTRAINT tierverlauf_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE RESTRICT;


--
-- TOC entry 5060 (class 2606 OID 17614)
-- Name: tierverlauf tierverlauf_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tierverlauf
    ADD CONSTRAINT tierverlauf_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tier(tier_id) ON DELETE CASCADE;


--
-- TOC entry 5044 (class 2606 OID 17487)
-- Name: unterbringung unterbringung_pflegestation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unterbringung
    ADD CONSTRAINT unterbringung_pflegestation_id_fkey FOREIGN KEY (pflegestation_id) REFERENCES public.pflegestation(pflegestation_id) ON DELETE SET NULL;


--
-- TOC entry 5045 (class 2606 OID 17482)
-- Name: unterbringung unterbringung_platz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unterbringung
    ADD CONSTRAINT unterbringung_platz_id_fkey FOREIGN KEY (platz_id) REFERENCES public.platz(platz_id) ON DELETE SET NULL;


--
-- TOC entry 5046 (class 2606 OID 17472)
-- Name: unterbringung unterbringung_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unterbringung
    ADD CONSTRAINT unterbringung_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tier(tier_id) ON DELETE CASCADE;


--
-- TOC entry 5047 (class 2606 OID 17477)
-- Name: unterbringung unterbringung_tierheim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unterbringung
    ADD CONSTRAINT unterbringung_tierheim_id_fkey FOREIGN KEY (tierheim_id) REFERENCES public.tierheim(tierheim_id) ON DELETE SET NULL;


--
-- TOC entry 5040 (class 2606 OID 17423)
-- Name: zwinger zwinger_platz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zwinger
    ADD CONSTRAINT zwinger_platz_id_fkey FOREIGN KEY (platz_id) REFERENCES public.platz(platz_id) ON DELETE CASCADE;


-- Completed on 2025-12-18 16:45:35

--
-- PostgreSQL database dump complete
--

\unrestrict 9roXoMDgTDjYYPcdfeq6yGgcccZlyISMk7PzIp0mY2ztQUO8Jyt4F8dgo0vCHWb

