INSERT INTO epizoda (
    id_pacijenta,
    epizoda_vrsta_id,
    datum_od,
    datum_do,
    proknjizeno,
    skladiste_grupa,
    skladiste,
    kreirano_datum,
    kreirano_korisnik,
    izmjena_datum,
    izmjena_korisnik
) VALUES (
    174342,         -- id pacijenta
    3,              -- epizoda_vrsta_id
    CURDATE(),      -- datum_od
    NULL,           -- datum_do (otvorena epizoda)
    0,              -- proknjizeno
    1110,           -- skladiste_grupa
    11109,          -- skladiste
    NOW(),          -- kreirano_datum
    1,              -- kreirano_korisnik (stavi pravog ako želiš)
    NOW(),          -- izmjena_datum
    1               -- izmjena_korisnik
);

INSERT INTO krevet_detalji (
    id,
    id_kreveta,
    id_pacijenta,
    krevet_status_id,
    datum_od,
    datum_do,
    skladiste_grupa,
    skladiste,
    id_epizode
) VALUES (
    174342,        -- id (isti kao id epizode radi konzistentnosti)
    560,           -- id_kreveta
    174342,        -- id pacijenta
    2,             -- krevet_status_id
    NOW(),         -- datum_od
    NULL,          -- datum_do (aktivan)
    1110,          -- skladiste_grupa
    11109,         -- skladiste
    174342         -- id_epizode
);

