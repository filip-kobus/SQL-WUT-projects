/*
Filip Kobus 331703
Z5.1

Pokaza� MAX pensj� w kazej z firm ale tylko w tych w kt�rych �rednia pensja (AVG) jest
pomi�dzy A_MIN a A_MAX - prosz� sobie wybra�
*/

DECLARE @A_MIN int = 5000
DECLARE @A_MAX int = 7000

SELECT LEFT(f.nazwa, 30) as Nazwa_Firmy, MAX(e.pensja) as Max_Pensja
FROM etaty e
JOIN firmy f ON f.nazwa_skr = e.id_firmy
GROUP BY f.nazwa
HAVING AVG(e.pensja) BETWEEN @A_MIN AND @A_MAX

/*
Nazwa_Firmy                    Max_Pensja
------------------------------ -----------
AlphaWave Technologies         8800
TechnoSoft Solutions           8700
*/

/*
Z5.2
Prosz� pokaza� kt�ra osoba ma najwi�cej etat�w w bazie
Wymaga zapytania z grupowaniem i szukania po wyniku
*/

SELECT LEFT(o.IMI�, 20) as Imie, LEFT(o.NAZWISKO, 20) as Nazwisko, COUNT(o.id_osoby) AS Liczba_Etat�w
FROM etaty e
JOIN osoby o ON o.id_osoby = e.id_osoby
GROUP BY o.IMI�, o.NAZWISKO
HAVING COUNT(o.id_osoby) = (
	SELECT MAX(L_Etatow)
	FROM (
		SELECT COUNT(e1.id_osoby) AS L_Etatow
		FROM etaty e1
		GROUP BY e1.id_osoby
	) maxEtatow
)

/*
Imie                 Nazwisko             Liczba_Etat�w
-------------------- -------------------- -------------
Anna                 Nowak                4
*/

/*
Z5.3

Prosz� doda� tabel�
CECHY (idc nchar(4) not null constraint PK_CECHY, opis nvarchar(100) not null)

Wpisac rekordy
N, Najlepszy
NZ, Najwi�ksze zarobki
SK, Super koledzy
�P, �atwe pieni�dze
SA, Super Zesp�
K, Kierownicze

i jeszcze ze 3

I stworzy� tabele ETATY_CECHY (id_etatu, idc)
obydwa jako klucze obce do tabel ETATY orac CECHY a klucz g�owny jako para id_etatu, idc

Stworzy� zapytanie pokazuj�ce etaty maj�ce cechy SK, �P, NZ  - wszystkie trzy musz� mie�
Oraz etaty maj�ce wszystkie powy�sze (+ WW + OC) lub mniej
posortowa� w kolejno�ci od etat�w maj�cych najwi�cej wybranych cech
*/

IF NOT EXISTS (
	SELECT 1
		FROM sysobjects o
		WHERE (OBJECTPROPERTY(o.[id],'IsUserTable') = 1)
		AND o.[name] = 'Cechy'
)
BEGIN
	CREATE TABLE dbo.Cechy (
    idc nchar(4) not null CONSTRAINT PK_Cechy PRIMARY KEY,
	opis nvarchar(100) not null
	)
END
GO

/*
INSERT INTO Cechy (idc, opis) VALUES (N'N',N'Najlepszy')
INSERT INTO Cechy (idc, opis) VALUES (N'NZ',N'Najwi�ksze zarobki')
INSERT INTO Cechy (idc, opis) VALUES (N'SK',N'Super koledzy')
INSERT INTO Cechy (idc, opis) VALUES (N'�P',N'�atwe pieni�dze')
INSERT INTO Cechy (idc, opis) VALUES (N'SA',N'Super zesp�')
INSERT INTO Cechy (idc, opis) VALUES (N'K',N'Kierownicze')
INSERT INTO Cechy (idc, opis) VALUES (N'OC',N'Owocowe czwartki')
INSERT INTO Cechy (idc, opis) VALUES (N'WW',N'Warzywne wtorki')
INSERT INTO Cechy (idc, opis) VALUES (N'PZP',N'Pi�tki z pupilem')
*/

IF NOT EXISTS (
	SELECT 1
		FROM sysobjects o
		WHERE (OBJECTPROPERTY(o.[id],'IsUserTable') = 1)
		AND o.[name] = 'Etaty_Cechy'
)

BEGIN
	CREATE TABLE dbo.Etaty_Cechy (
    idc nchar(4) not null CONSTRAINT FK_Cechy FOREIGN KEY
		REFERENCES cechy(idc),
	id_etatu int not null CONSTRAINT FK_Etaty FOREIGN KEY
		REFERENCES etaty(id_etatu),
	PRIMARY KEY (id_etatu, idc)
	)
	
END
GO

/*
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (1, N'N')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (2, N'SK')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (3, N'NZ')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (4, N'K')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (5, N'SA')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (6, N'OC')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (7, N'WW')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (8, N'�P')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (9, N'K')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (10, N'PZP')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (11, N'NZ')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (12, N'K')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (13, N'N')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (14, N'�P')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (15, N'SA')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (16, N'SK')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (17, N'OC')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (18, N'WW')
---------------------------------------------------------
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (1, N'�P')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (1, N'SK')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (1, N'NZ')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (1, N'OC')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (1, N'WW')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (2, N'�P')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (3, N'SK')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (2, N'NZ')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (3, N'OC')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (3, N'WW')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (4, N'�P')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (5, N'SK')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (5, N'NZ')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (5, N'OC')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (5, N'WW')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (6, N'�P')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (7, N'SK')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (7, N'NZ')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (7, N'OC')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (8, N'WW')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (18, N'�P')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (17, N'SK')
INSERT INTO Etaty_Cechy (id_etatu, idc) VALUES (9, N'NZ')
*/

SELECT e.id_ETATU, LEFT(e.stanowisko, 35) as Stanowisko
FROM etaty e
JOIN Etaty_Cechy ec ON ec.id_etatu = e.id_ETATU
WHERE ec.idc IN ('SK', '�P', 'NZ')
GROUP BY e.id_ETATU, e.stanowisko
HAVING COUNT(DISTINCT ec.idc) = 3

/*
id_ETATU    Stanowisko
----------- -----------------------------------
1           Dyrektor
2           Administrator Sieci LAN
*/

SELECT e.id_ETATU, LEFT(e.stanowisko, 35) as Stanowisko, COUNT(ec.idc) as liczba_cech
FROM etaty e
JOIN Etaty_Cechy ec ON ec.id_etatu = e.id_ETATU
WHERE ec.idc IN ('SK', '�P', 'NZ', 'WW', 'OC')
GROUP BY e.id_ETATU, e.stanowisko
ORDER BY COUNT(ec.idc) DESC

/*
id_ETATU    Stanowisko                          liczba_cech
----------- ----------------------------------- -----------
1           Dyrektor                            5
3           Manager                             4
7           Dyrektor ds. Personalnych           4
5           Analityk Biznesowy                  4
2           Administrator Sieci LAN             3
8           Analityk Systemu Komputerowego      2
6           Administrator Sieci WAN             2
17          Dyrektor ds. Informatyki            2
18          Dyrektor ds. Marketingu             2
9           Asystent                            1
11          Asystent Zarz�du                    1
14          Dyrektor ds. Bada� i Rozwoju        1
16          Dyrektor ds. Finansowych            1
4           Programista                         1
*/