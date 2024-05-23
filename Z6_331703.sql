-- Filip Kobus 331703 (25.04.24)

/*
Z6.1 Npisaæ procedurê, która
wyszuka firmy z województwa o kodzie @kod_woj (parametr proc)
w których nie pracowa³a osoba o nazwisko
@nazwisko nvarchar(100) - kolejny parametr

Wykonaæ testy i uzasadnic poprawnoœæ
*/

IF NOT EXISTS 
( SELECT 1 FROM sysobjects o
	WHERE	(o.[name] = 'find_woj')
	AND		(OBJECTPROPERTY(o.[ID], N'IsProcedure')=1)
) 
BEGIN
	DECLARE @sql nvarchar(1000)
	SET @sql = 'CREATE PROCEDURE dbo.find_woj AS SELECT ''find_woj'' AS nazwa_proc'
	EXEC sp_sqlexec @sql
END

GO
ALTER PROCEDURE dbo.find_woj(@kod_woj nchar(10), @nazwisko nvarchar(100))
AS
SELECT LEFT(f.nazwa, 30) as nazwa_firmy, LEFT(w.nazwa, 20) as województwo
	FROM firmy f
	JOIN miasta m ON (f.id_miasta = m.id_miasta)
	JOIN woj w ON (w.kod_woj = m.kod_woj)
	WHERE NOT EXISTS (
		SELECT 1
			FROM etaty e1
			JOIN osoby o1 ON o1.id_osoby = e1.id_osoby
			WHERE e1.id_firmy = f.nazwa_skr
			AND o1.NAZWISKO LIKE(@nazwisko)
	)
	AND w.kod_woj = @kod_woj
GO

/*
P1
Nie pracuje w Podlaskim:

EXEC find_woj 'POD', 'Ornafa'
GO

nazwa_firmy                    województwo
------------------------------ --------------------
Optimum Synergy Group          PODLASKIE
TechnoSoft Solutions           PODLASKIE
*/

/*
P2
Pracuje w jednej firmie w podlskim:

EXEC find_woj 'POD', 'Nowak'
GO

nazwa_firmy                    województwo
------------------------------ --------------------
Optimum Synergy Group          PODLASKIE
*/

/*
P3
Pracuje w drugiej firmie w podlaskim:

EXEC find_woj 'POD', 'Kamiñska'
GO

nazwa_firmy                    województwo
------------------------------ --------------------
TechnoSoft Solutions           PODLASKIE
*/


--Sprawdzam w jakich województwach znajduj¹ siê firmy osób na dane nazwisko
/*
SELECT DISTINCT LEFT(o.NAZWISKO, 20), m.kod_woj, LEFT(f.nazwa, 30) as nazwa_firmy
FROM etaty e 
JOIN firmy f on f.nazwa_skr = e.id_firmy 
JOIN osoby o on o.id_osoby = e.id_osoby 
JOIN miasta m on m.id_miasta = f.id_miasta 
*/


/*
Z6.2
Napisaæ funkcjê, która dla parametrów
Nazwa z WOJ, nazwa z miasta, ulica z OSOBY
stworzy napis( W:(nazwa z woj);M:(nazwa z miasta),UL:(ulica z osoby)

Napisaæ funkcjê, która dla parametrów
id_osoby, imie, nazwisko
stworzy napis( ID:(id_oosby);OS:1sza_lit_im;20lit_nazwiska)
napis max 30 znaków
do konwertowania int na napis STR(54.6, 4,0) -- 4 cyfry zero po kropce
*/

--dodajê kolumnê ulica w tabeli osoby:
/*
ALTER TABLE OSOBY ADD ULICA NVARCHAR(30) NOT NULL DEFAULT N'Pl. Politechniki'
*/

--Zmieniam nazwy ulic u niektórych osób:
/*
UPDATE osoby
SET ULICA = N'Poziomkowa'
WHERE id_osoby = 1

UPDATE osoby
SET ULICA = N'Lipowa'
WHERE id_osoby = 4

UPDATE osoby
SET ULICA = N'Akacjowa'
WHERE id_osoby = 7

UPDATE osoby
SET ULICA = N'Brzozowa'
WHERE id_osoby = 10
*/

ALTER FUNCTION dbo.WypiszAdres(@n_woj NVARCHAR(30), @n_miasta NVARCHAR(30), @ulica NVARCHAR(30))
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @napis nvarchar(100);
	SET @napis = 'W:' + @n_woj + '; M:' + @n_miasta + '; UL:' + @ulica;
	RETURN @napis
END
GO


ALTER FUNCTION dbo.WypiszDane(@id_osoby INT, @imie_osoby NVARCHAR(20), @nazwisko_osoby NVARCHAR(20))
RETURNS nvarchar(30)
AS
BEGIN
	DECLARE @napis nvarchar(30);
	--przyjmujê ¿e id_osoby nie bêdzie d³u¿sze ni¿ 2 cyfry
	SET @napis = 'ID:' + STR(@id_osoby, 2, 0) + ' OS:' + LEFT(@imie_osoby, 1) + '. '+ LEFT(@nazwisko_osoby, 20);
	RETURN @napis;
END
GO

-- Test funkcji dbo.WypiszAdres
SELECT dbo.WypiszAdres('Mazowieckie', 'Warszawa', 'Aleje Jerozolimskie 100') AS WypisanyAdres;

/*
WypisanyAdres
----------------------------------------------------------------------------------------------------
W:Mazowieckie; M:Warszawa; UL:Aleje Jerozolimskie 100
*/

-- Test funkcji dbo.WypiszDane
SELECT dbo.WypiszDane(12, 'Jan', 'Kowalski') AS WypisaneDane;
/*
WypisaneDane
------------------------------
ID:12 OS:J. Kowalski
*/

/*
Z 6.3
wykorzystaæ obie funkcje w procedure pokazuj¹cej dane osobowe
w 2 kolumnach (funkcje z 6.2)
a parametrem nazwa województwa zamieszkania oosby
*/

IF NOT EXISTS 
( SELECT 1 FROM sysobjects o
	WHERE	(o.[name] = 'wypisz_osobe')
	AND		(OBJECTPROPERTY(o.[ID], N'IsProcedure')=1)
)

BEGIN
	DECLARE @sql nvarchar(1000)
	SET @sql = 'CREATE PROCEDURE dbo.wypisz_osobe AS SELECT ''wypisz_osobe'' AS nazwa_proc'
	EXEC sp_sqlexec @sql
END

GO
ALTER PROCEDURE dbo.wypisz_osobe(@nazwa_wojewodztwa_zamieszkania_osoby nvarchar(100))
AS
SELECT dbo.WypiszDane(o.id_osoby, o.IMIÊ, o.NAZWISKO) as Dane, dbo.WypiszAdres(w.nazwa, m.nazwa, o.ULICA) as Adres
	FROM osoby o
	JOIN miasta m ON m.id_miasta = o.id_miasta
	JOIN woj w ON w.kod_woj = m.kod_woj
	WHERE w.nazwa LIKE(@nazwa_wojewodztwa_zamieszkania_osoby)
GO

EXEC wypisz_osobe N'Mazowieckie'

/*
Dane                           Adres
------------------------------ -----------------------------------------------
ID: 5 OS:M. Wójcik             W:MAZOWIECKIE; M:Radom; UL:Pl. Politechniki
ID: 6 OS:M. Kamiñska           W:MAZOWIECKIE; M:Siedlce; UL:Pl. Politechniki
ID:10 OS:A. Rabczyk            W:MAZOWIECKIE; M:Warszawa; UL:Brzozowa
ID:12 OS:K. Gwaiazdowski       W:MAZOWIECKIE; M:Siedlce; UL:Pl. Politechniki
ID:14 OS:M. Kucharczyk         W:MAZOWIECKIE; M:Radom; UL:Pl. Politechniki
*/