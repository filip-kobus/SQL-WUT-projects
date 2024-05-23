--Filip Kobus 331703, 26.03.24

/*
Z3.1
pokazaæ osoby które z województwa (wybraæ)
które nigdy nie pracowa³y w firmie zawieraj¹cej w nazwie s³owo Politechnika (gdziekolwiek)
*/


SELECT LEFT(o.IMIÊ, 20) AS IMIÊ, LEFT(o.NAZWISKO, 20) AS NAZWISKO
	FROM osoby o
	JOIN miasta m ON (o.id_miasta = m.id_miasta)
	JOIN woj w ON (w.kod_woj = m.kod_woj)
	WHERE w.nazwa = 'pomorskie'
	AND NOT EXISTS 
	( SELECT 1
		FROM etaty ew
		join firmy fw ON (fw.nazwa_skr = ew.id_firmy)
		WHERE o.id_osoby = ew.id_osoby
		AND (fw.nazwa LIKE '%politechnika%')
	)

/*
IMIÊ                 NAZWISKO
-------------------- --------------------
Katarzyna            Kowalczyk
Piotr                Nowakowski
Jakub                Piotrowski
Micha³               Gierczak

(4 row(s) affected)
*/

/*
Z3.2
Pokazaæ osoby które nigdy nie mia³y etaty z pensj¹ powy¿ej (wybraæ kwotê) w firmach z województwa (wybraæ)
*/

SELECT LEFT(o.IMIÊ, 20) AS IMIÊ, LEFT(o.NAZWISKO, 20) AS NAZWISKO
	FROM osoby o
	WHERE NOT EXISTS
	(	SELECT 1
		FROM etaty ew
		JOIN firmy fw ON (fw.nazwa_skr = ew.id_firmy)
		JOIN miasta mw ON (fw.id_miasta = mw.id_miasta)
		JOIN woj ww ON (ww.kod_woj = mw.kod_woj)
		WHERE ww.nazwa = 'lubelskie'
		AND ew.id_osoby = o.id_osoby
		AND ew.pensja > 5000
	)

/*
IMIÊ                 NAZWISKO
-------------------- --------------------
Jan                  Kowalski
Anna                 Nowak
Katarzyna            Kowalczyk
Marek                Wójcik
Magdalena            Kamiñska
Piotr                Nowakowski
Jakub                Piotrowski
Marcin               Kochalski
Karolina             Gwaiazdowski
Micha³               Gierczak
Mateusz              Kucharczyk

(11 row(s) affected)
*/

/*
Z3.3
poszukaæ najmniejsz¹ pensjê w bazie i pokazaæ w jakiej firmie i jaka osoba posiada
*/

SELECT 
    LEFT(o.IMIÊ, 20) AS IMIÊ, 
    LEFT(o.NAZWISKO, 20) AS NAZWISKO, 
    LEFT(f.nazwa, 20) AS firma, 
    LEFT(e.stanowisko, 20) AS stanowisko, 
    e.pensja
FROM 
    etaty e
JOIN 
    firmy f ON (e.id_firmy = f.nazwa_skr)
JOIN 
    osoby o ON (o.id_osoby = e.id_osoby)
WHERE 
    e.pensja = (SELECT MIN(LEFT(ew.pensja, 20)) FROM etaty ew)

/*
IMIÊ                 NAZWISKO             firma                stanowisko           pensja
-------------------- -------------------- -------------------- -------------------- -----------
Micha³               Wiœniewski           Quantum Dynamics     Asystent             3500

(1 row(s) affected)
*/

/*
Z3.4
stworzyæ tabelkê XX z kolumn¹ YY nvarchar(100) not null pod warunkiem ze takowej nie ma
*/

IF NOT EXISTS (
	SELECT 1
		FROM sysobjects o
		WHERE (OBJECTPROPERTY(o.[id],'IsUserTable') = 1)
		AND o.[name] = 'XX'
)
BEGIN
	CREATE TABLE dbo.XX
	(	YY nvarchar(100) not null
	)
END
GO

/*
Z3.5
Dodaæ kolummê ZZ bit not null default 0 do tabelki XX pod warunkiem, ze w tej tabelce takiej kolumny jeszcze nie ma
*/

IF NOT EXISTS (
	SELECT 1
		FROM INFORMATION_SCHEMA.columns
		WHERE table_name = 'XX'
        AND column_name = 'ZZ')
BEGIN
	ALTER TABLE dbo.XX
	ADD ZZ bit NOT NULL
END
GO