-- Filip Kobus 331703 (12.03.24)

/*
** Prosze wkleic do skryptu ogłoszenie
** Z2.1
** proszę dodać do tabeli firmy kolumne [data powstania] typu datetime NULL
** poustawiac wielu firmom tę danę
** UPDATE FIRMY SET [data powstania] = CONVERT(datetime, '1990130', 112) WHERE nazwa_skr = Tu_wstawiacie_jakis_id
** tak zeby minimum 50% firm miało tą daną wypełnioną
** wstawić kolumnę [ile lat ma firma] która wyliczy (virtualną) wiek firmy
**
** zrobić zapytanie
** wszystkie firmy z 2 województw (wybrać dowolne 2) które istnieję co najmniej X lat ale nie więcej jak Y lat
**
** Z2.2
** zrobić zapytania pokazujące etaty
** dane etatu, nazwisko osoby, nazwa firmy, miast gdzie mieszka osoba, miasto gdzie znajduje się firma
** województwo miasta osoby
** województwo miasta firmy
** tam gdzie osoba mieszka w innym województwie jak znajduje się firma
** jak nie ma takiej osoby to jednej lub dwo zmienićmiasto zamieszkania tak aby sie pojawiły
** UPDATE osoby SET id_miasta = xx_miasto WHERE id_osoby=Y
**
** Z2.3
** znależć miasta z województw których nazwa zaczyna się na (wybrać literkę)
*/


-- **Z2.1

/*
	Dodaję kolumnę data_powstania:
	ALTER TABLE dbo.Firmy
	ADD data_powstania date
*/

-- Uzupełniam kolumnę z rokiem powstania firmy:
UPDATE FIRMY SET [data_powstania] = CONVERT(datetime, '19900130', 112) WHERE nazwa_skr = 'AWAV'
UPDATE FIRMY SET [data_powstania] = CONVERT(datetime, '19900203', 112) WHERE nazwa_skr = 'GLED'
UPDATE FIRMY SET [data_powstania] = CONVERT(datetime, '20010111', 112) WHERE nazwa_skr = 'BFHI'
UPDATE FIRMY SET [data_powstania] = CONVERT(datetime, '20091107', 112) WHERE nazwa_skr = 'TFIR'
UPDATE FIRMY SET [data_powstania] = CONVERT(datetime, '19950311', 112) WHERE nazwa_skr = 'QDYN'
UPDATE FIRMY SET [data_powstania] = CONVERT(datetime, '19970507', 112) WHERE nazwa_skr = 'OSYN'
UPDATE FIRMY SET [data_powstania] = CONVERT(datetime, '20020202', 112) WHERE nazwa_skr = 'NXSY'

/*
	**Dodaję kolumnę wirutalną wiek firmy:
	ALTER TABLE dbo.Firmy
	ADD wiek_firmy AS DATEDIFF(YEAR, data_powstania, GETDATE());
*/

SELECT f.nazwa_skr,
LEFT(f.nazwa, 30) as nazwa,
f.kod_pocztowy,
LEFT(f.ulica, 20) as ulica,
f.wiek_firmy,
LEFT(w.nazwa, 20) as ulica
FROM firmy f
JOIN miasta m ON f.id_miasta = m.id_miasta
JOIN woj w ON w.kod_woj = m.kod_woj
WHERE
w.nazwa IN ('mazowieckie', 'pomorskie')
AND f.wiek_firmy BETWEEN 0 AND 100

/*
nazwa_skr  nazwa                          kod_pocztowy ulica                wiek_firmy  ulica
---------- ------------------------------ ------------ -------------------- ----------- --------------------
GLED       GlobalEdge Enterprises         96-205       Lipowa               34          MAZOWIECKIE
NXSY       Nexus Systems Inc.             95-204       Brzozowa             22          MAZOWIECKIE
QDYN       Quantum Dynamics               92-201       Wiśniowa             29          POMORSKIE

*/


-- **Z2.2

SELECT
LEFT(e.stanowisko, 40) as stanowisko,
LEFT(o.nazwisko, 20) as nazwisko,
LEFT(f.nazwa, 40) as [nazwa_firmy],
LEFT(m1.nazwa, 20) as miasto_pracownika,
LEFT(w1.nazwa, 20) as [woj_pracownika],
LEFT(m2.nazwa, 20) as miasto_firmy,
LEFT(w2.nazwa, 20) as [woj_fimy]
FROM etaty e
JOIN osoby o ON o.id_osoby = e.id_osoby
JOIN miasta m1 ON m1.id_miasta = o.id_miasta
JOIN firmy f ON f.nazwa_skr = e.id_firmy
JOIN miasta m2 ON m2.id_miasta = f.id_miasta
JOIN woj w1 ON w1.kod_woj = m1.kod_woj
JOIN woj w2 ON w2.kod_woj = m2.kod_woj
WHERE NOT(w1.nazwa = w2.nazwa)

/*
stanowisko                               nazwisko             nazwa_firmy                              miasto_pracownika    woj_pracownika       miasto_firmy         woj_fimy
---------------------------------------- -------------------- ---------------------------------------- -------------------- -------------------- -------------------- --------------------
Analityk Biznesowy                       Nowak                Quantum Dynamics                         Chełm                LUBELSKIE            Gdynia               POMORSKIE
Administrator Sieci WAN                  Nowak                Quantum Dynamics                         Chełm                LUBELSKIE            Gdynia               POMORSKIE
Dyrektor ds. Personalnych                Nowak                TechnoSoft Solutions                     Chełm                LUBELSKIE            Białystok            PODLASKIE
Analityk Systemu Komputerowego           Wiśniewski           Quantum Dynamics                         Lublin               LUBELSKIE            Gdynia               POMORSKIE
Asystent                                 Wiśniewski           Quantum Dynamics                         Lublin               LUBELSKIE            Gdynia               POMORSKIE
Asystent Zarządu                         Kowalczyk            AlphaWave Technologies                   Gdynia               POMORSKIE            Zamość               LUBELSKIE
Dyrektor ds. Administracyjnych           Kamińska             Optimum Synergy Group                    Siedlce              MAZOWIECKIE          Suwałki              PODLASKIE
Dyrektor ds. Badań i Rozwoju             Nowakowski           Optimum Synergy Group                    Słupsk               POMORSKIE            Suwałki              PODLASKIE
Dyrektor ds. Dystrybucji i Logistyki     Ornafa               AlphaWave Technologies                   Suwałki              PODLASKIE            Zamość               LUBELSKIE
Dyrektor ds. Finansowych                 Piotrowski           Nexus Systems Inc.                       Szczecin             POMORSKIE            Wesoła               MAZOWIECKIE
Dyrektor ds. Informatyki                 Rabczyk              AlphaWave Technologies                   Warszawa             MAZOWIECKIE          Zamość               LUBELSKIE
Dyrektor ds. Marketingu                  Kochalski            Optimum Synergy Group                    Lublin               LUBELSKIE            Suwałki              PODLASKIE

(12 row(s) affected)
*/


--**Z2.3

SELECT
LEFT(m.nazwa, 20) as miasto,
LEFT(w.nazwa, 20) as [województwo]
FROM miasta m
JOIN woj w ON w.kod_woj = m.kod_woj
WHERE w.nazwa LIKE 'P%'

/*
miasto               województwo
-------------------- --------------------
Gdynia               POMORSKIE
Szczecin             POMORSKIE
Białystok            PODLASKIE
Suwałki              PODLASKIE
Słupsk               POMORSKIE
*/
