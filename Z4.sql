/*
Filip Kobus, 331703, 26.03.2024
*/

/*
Z4.1
największa pensja z etatów osób o nazwisku na (wybrać literkę) z miasta o nazwie na literkę (wybrać)
*/

SELECT LEFT(o.IMIĘ, 20) as Imię, LEFT(o.NAZWISKO, 20) as Nazwisko, e.pensja as Pensja, LEFT(m.nazwa, 20) as Miasto
FROM etaty e
JOIN osoby o ON e.id_osoby = o.id_osoby
JOIN miasta m ON m.id_miasta = o.id_miasta
WHERE e.pensja = (
    SELECT MAX(ew.pensja) 
    FROM etaty ew
    JOIN osoby ow ON ew.id_osoby = ow.id_osoby
    JOIN miasta mw ON mw.id_miasta = ow.id_miasta
    WHERE ow.nazwisko LIKE 'O%' 
    AND mw.nazwa LIKE 'S%'
)
AND o.nazwisko LIKE 'O%'
AND m.nazwa LIKE 'S%'

-- Osoba z nazwiskiem na literę O z miasta na literę S:

/*
Imię                 Nazwisko            Pensja      Miasto
-------------------- -------------------- ----------- --------------------
Marta                Ornafa               9000        Suwałki

(1 row(s) affected)
*/

-- W bazie jest jeszcze Jakub Piotrowski ze Szczecina z pensją 9000
-- Dodałem też Marcina Ochockiego z Lublina z pensją 9000
-- Magdalena Olejnik z Siedlc zarabia 8500

/*
Z4.2
policzyć największą pensję w kazdej z firm łącznie z archwiwalnymi etatami
*/

SELECT LEFT(f.nazwa, 30) AS Nazwa_firmy, e.pensja AS Najwyzsza_pensja
FROM firmy f
JOIN etaty e ON (f.nazwa_skr = e.id_firmy)
WHERE e.pensja = (
	SELECT MAX(ew.pensja)
	FROM etaty ew
	WHERE ew.id_firmy = f.nazwa_skr
)

/*
Nazwa_firmy                    Najwyzsza_pensja
------------------------------ ----------------
TechnoSoft Solutions           10000
Quantum Dynamics               4900
Optimum Synergy Group          10000
Nexus Systems Inc.             9000
BrightHorizon Innovations      9100
AlphaWave Technologies         9000

(6 row(s) affected)
*/

/*
Z4.3
znalezc województwa w których nie ma firmy z etatem o pensji większej niż X (wybrać)
*/

DECLARE @X int = 5000

SELECT LEFT(w.nazwa, 25) as Wojewodztwo
FROM woj w
WHERE NOT EXISTS
	(
		SELECT 1
		FROM etaty ew
		JOIN firmy fw ON (ew.id_firmy = fw.nazwa_skr)
		JOIN miasta mw ON (mw.id_miasta = fw.id_miasta)
		JOIN woj ww ON (ww.kod_woj = mw.kod_woj)
		WHERE ew.pensja > @X
		AND ww.nazwa = w.nazwa
	)

/*
Wojewodztwo
-------------------------
POMORSKIE
ŚWIĘTOKRZYSKIE

(2 row(s) affected)

-- W Świętokrzyskim w ogóle nie ma etatów
*/
