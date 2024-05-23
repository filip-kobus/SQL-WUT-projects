/* 
** Filip Kobus 331703 (05.03.2024)

Treść zadania:
Utworzyć tabelki z:
	5 województw z czego jedno bez miast

	12 miast w tym 2 miasta bez mieszkańców i 2 miasta (inne) bez firm
	14 osób, 3 z nich nigdy nie pracowały, 2 kiedyś pracowały a obecnie nie mają aktualnego etatu
	8 firm z czego 2 bez pracowników (bez etatów)

	18 etatów minimum (3 osoby aby miały więcej niż 1 etat)

*/
go

IF OBJECT_id('etaty') IS NOT NULL
BEGIN
	DROP TABLE etaty
END
GO

IF OBJECT_id('firmy') IS NOT NULL
BEGIN
	DROP TABLE firmy
END
GO

IF OBJECT_id('osoby') IS NOT NULL
BEGIN
	DROP TABLE osoby
END
GO

IF OBJECT_id('miasta') IS NOT NULL
BEGIN
	DROP TABLE miasta
END
GO

IF OBJECT_id('woj') IS NOT NULL
BEGIN
	DROP TABLE woj
END

GO
CREATE TABLE dbo.woj
(	kod_woj NCHAR(10) NOT NULL CONSTRAINT PK_woj PRIMARY KEY
,	nazwa NVARCHAR(100) NOT NULL
)

GO
CREATE TABLE dbo.miasta
(	id_miasta INT NOT NULL idENTITY /* samonumerujaca kolumna */
		CONSTRAINT PK_miasta PRIMARY KEY
,	kod_woj NCHAR(10) NOT NULL CONSTRAINT FK_woj__miasta FOREIGN KEY
		REFERENCES woj(kod_woj)
,	nazwa NVARCHAR(100) NOT NULL
)
GO

CREATE TABLE dbo.osoby
(	id_osoby INT NOT NULL idENTITY /* samonumerująca */ CONSTRAINT PK_OS PRIMARY KEY
,	id_miasta INT NOT NULL CONSTRAINT FK_osoby__miasta 
		FOREIGN KEY REFERENCES miasta(id_miasta)
,	[IMIĘ] nvarchar(100) NOT NULL
,	NAZWISKO nvarchar(100) NOT NULL
)
GO

CREATE TABLE dbo.firmy
(	nazwa_skr NCHAR(10) NOT NULL CONSTRAINT PK_firmy PRIMARY KEY,
	id_miasta INT NOT NULL CONSTRAINT FK_firmy__miasta 
		FOREIGN KEY REFERENCES miasta(id_miasta),
	nazwa NVARCHAR(100) NOT NULL,
	kod_pocztowy NVARCHAR(10) NOT NULL,
	ulica NVARCHAR(100) NOT NULL
)
GO

CREATE TABLE dbo.etaty
(	id_osoby INT NOT NULL CONSTRAINT FK_etaty_osoby
		FOREIGN KEY REFERENCES osoby(id_osoby),
	id_firmy NCHAR(10) NOT NULL CONSTRAINT FK_etaty_firmy
		FOREIGN KEY REFERENCES firmy(nazwa_skr),
	stanowisko NVARCHAR(100) NOT NULL,
	pensja INT NOT NULL,
	od DATE NOT NULL,
	do DATE,
	id_ETATU INT NOT NULL idENTITY CONSTRAINT PK_etaty PRIMARY KEY
)
GO
/*
wstawianie 
INSERT INTO nazwaTabeli (lista_kol) VALUES (lista_wa) */

INSERT INTO woj (kod_woj, nazwa) VALUES (N'MAZ',N'MAZOWIECKIE')
INSERT INTO woj (kod_woj, nazwa) VALUES (N'POM',N'POMORSKIE')
INSERT INTO woj (kod_woj, nazwa) VALUES (N'LUB', N'LUBELSKIE')
INSERT INTO woj (kod_woj, nazwa) VALUES (N'POD', N'PODLASKIE')
INSERT INTO woj (kod_woj, nazwa) VALUES (N'ŚWI', N'ŚWIĘTOKRZYSKIE')

--Deklaruję id miast
DECLARE @id_wes INT, @id_wa INT, @id_gd INT, @id_sz INT
DECLARE @id_lub INT, @id_che INT, @id_bia INT, @id_su INT
DECLARE @id_sie INT, @id_rad INT, @id_sl INT, @id_zam INT

--Deklaruję id osób
DECLARE @id_os1 INT, @id_os2 INT, @id_os3 INT, @id_os4 INT, @id_os5 INT
DECLARE @id_os6 INT, @id_os7 INT, @id_os8 INT, @id_os9 INT, @id_os10 INT
DECLARE @id_os11 INT, @id_os12 INT, @id_os13 INT, @id_os14 INT

-- Deklaruję id firm
DECLARE @id_firma1 NCHAR(10), @id_firma2 NCHAR(10), @id_firma3 NCHAR(10), @id_firma4 NCHAR(10)
DECLARE @id_firma5 NCHAR(10), @id_firma6 NCHAR(10), @id_firma7 NCHAR(10), @id_firma8 NCHAR(10)

SET @id_firma1 = 'TFIR'
SET @id_firma2 = 'BFHI'
SET @id_firma3 = 'QDYN'
SET @id_firma4 = 'OSYN'
SET @id_firma5 = 'AWAV'
SET @id_firma6 = 'NXSY'
SET @id_firma7 = 'GLED'
SET @id_firma8 = 'IVTS'

DECLARE @NewEtatid INT

--Uzupełniam tabelę miasta
INSERT INTO miasta (kod_woj, nazwa) VALUES (N'MAZ', N'Wesoła')
SET @id_wes = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'MAZ', N'Warszawa')
SET @id_wa = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'POM', N'Gdynia')
SET @id_gd = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'POM', N'Szczecin')
SET @id_sz = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'LUB', N'Lublin')
SET @id_lub = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'LUB', N'Chełm')
SET @id_che = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'POD', N'Białystok')
SET @id_bia = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'POD', N'Suwałki')
SET @id_su = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'MAZ', N'Siedlce')
SET @id_sie = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'MAZ', N'Radom')
SET @id_rad = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'POM', N'Słupsk')
SET @id_sl = SCOPE_idENTITY()

INSERT INTO miasta (kod_woj, nazwa) VALUES (N'LUB', N'Zamość')
SET @id_zam = SCOPE_idENTITY()


--Uzupełniam tabelę osoby
INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_bia, N'Jan', N'Kowalski');
SET @id_os1 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_che, N'Anna', N'Nowak');
SET @id_os2 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_lub, N'Michał', N'Wiśniewski');
SET @id_os3 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_gd, N'Katarzyna', N'Kowalczyk');
SET @id_os4 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_rad, N'Marek', N'Wójcik');
SET @id_os5 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_sie, N'Magdalena', N'Kamińska');
SET @id_os6 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_sl, N'Piotr', N'Nowakowski');
SET @id_os7 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_su, N'Marta', N'Ornafa');
SET @id_os8 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_sz, N'Jakub', N'Piotrowski');
SET @id_os9 = SCOPE_idENTITY();

--kiedyś pracowali

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_wa, N'Agnieszka', N'Rabczyk');
SET @id_os10 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_lub, N'Marcin', N'Kochalski');
SET @id_os11 = SCOPE_idENTITY();

--nigdy nie pracowali

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_sie, N'Karolina', N'Gwaiazdowski');
SET @id_os12 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_gd, N'Michał', N'Gierczak');
SET @id_os13 = SCOPE_idENTITY();

INSERT INTO osoby (id_miasta, [imię], [nazwisko]) VALUES (@id_rad, N'Mateusz', N'Kucharczyk');
SET @id_os14 = SCOPE_idENTITY();


--Uzupełniam tabelę firmy

INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma1, @id_bia, N'TechnoSoft Solutions', N'90-199', N'Poziomkowa')

INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma2, @id_che, N'BrightHorizon Innovations', N'91-200', N'Malinowa')

INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma3, @id_gd, N'Quantum Dynamics', N'92-201', N'Wiśniowa')

INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma4, @id_su, N'Optimum Synergy Group', N'93-202', N'Jabłonkowa')

INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma5, @id_zam, N'AlphaWave Technologies', N'94-203', N'Żurawinowa')

INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma6, @id_wes, N'Nexus Systems Inc.', N'95-204', N'Brzozowa')

--firmy bez pracowników:
INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma7, @id_rad, N'GlobalEdge Enterprises', N'96-205', N'Lipowa')

INSERT INTO firmy(nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES (@id_firma8, @id_sz, N'Innovatech Solutions', N'97-206', N'Sosnowa')

--Uzupełniam etaty

-- osoby mające więcej niż jeden etat
INSERT INTO dbo.etaty (id_osoby, id_firmy, stanowisko, pensja, od, do)
VALUES (@id_os1, @id_firma1, N'Dyrektor', 8000, CONVERT(datetime,'20140101',112), NULL) -- NULL ponieważ etat nadal trwa

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os1, @id_firma1, N'Administrator Sieci LAN', 4200, CONVERT(datetime,'20140215',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os1, @id_firma1, N'Manager', 6000, CONVERT(datetime,'20140320',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os2, @id_firma2, N'Programista', 5000, CONVERT(datetime,'20140410',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os2, @id_firma3, N'Analityk Biznesowy', 4500, CONVERT(datetime,'20140505',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os2, @id_firma3, N'Administrator Sieci WAN', 4300, CONVERT(datetime,'20140620',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os2, @id_firma1, N'Dyrektor ds. Personalnych', 8700, CONVERT(datetime,'20140715',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os3, @id_firma3, N'Analityk Systemu Komputerowego', 4900, CONVERT(datetime,'20140810',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os3, @id_firma3, N'Asystent', 3500, CONVERT(datetime,'20140905',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os3, @id_firma2, N'Dyrektor ds. Produkcji', 9100, CONVERT(datetime,'20141001',112), NULL)

-- osoby mające jeden etat
INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os4, @id_firma5, N'Asystent Zarządu', 3800, CONVERT(datetime,'20150115',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os5, @id_firma6, N'Automatyk', 5200, CONVERT(datetime,'20150220',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os6, @id_firma4, N'Dyrektor ds. Administracyjnych', 8000, CONVERT(datetime,'20150310',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os7, @id_firma4, N'Dyrektor ds. Badań i Rozwoju', 8500, CONVERT(datetime,'20150405',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os8, @id_firma5, N'Dyrektor ds. Dystrybucji i Logistyki', 8200, CONVERT(datetime,'20150520',112), NULL)

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os9, @id_firma6, N'Dyrektor ds. Finansowych', 9000, CONVERT(datetime,'20150615',112), NULL)

--Kiedyś pracowali

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os10, @id_firma5, N'Dyrektor ds. Informatyki', 8800, CONVERT(datetime,'20160701',112), CONVERT(datetime,'20170914',112))

INSERT INTO etaty (id_osoby, id_firmy, stanowisko, pensja, od, do) 
VALUES (@id_os11, @id_firma4, N'Dyrektor ds. Marketingu', 8600, CONVERT(datetime,'20160810',112), CONVERT(datetime,'20190101',112))



-- ////////////////////////////////////////////////
-- Wypisanie tabelek

SELECT woj.* FROM woj

/*
kod_woj    nazwa
---------- ----------------------------------------------------------------------------------------------------
LUB        LUBELSKIE
MAZ        MAZOWIECKIE
POD        PODLASKIE
POM        POMORSKIE
ŚWI        ŚWIĘTOKRZYSKIE
*/

SELECT miasta.* FROM miasta

/*
id_miasta   kod_woj    nazwa
----------- ---------- ----------------------------------------------------------------------------------------------------
1           MAZ        Wesoła
2           MAZ        Warszawa
3           POM        Gdynia
4           POM        Szczecin
5           LUB        Lublin
6           LUB        Chełm
7           POD        Białystok
8           POD        Suwałki
9           MAZ        Siedlce
10          MAZ        Radom
11          POM        Słupsk
12          LUB        Zamość
*/

SELECT osoby.* FROM osoby 

/*
id_osoby    id_miasta   IMIĘ                                                                                                 NAZWISKO
----------- ----------- ---------------------------------------------------------------------------------------------------- ----------------------------------------------------------------------------------------------------
1           7           Jan                                                                                                  Kowalski
2           6           Anna                                                                                                 Nowak
3           5           Michał                                                                                               Wiśniewski
4           3           Katarzyna                                                                                            Kowalczyk
5           10          Marek                                                                                                Wójcik
6           9           Magdalena                                                                                            Kamińska
7           11          Piotr                                                                                                Nowakowski
8           8           Marta                                                                                                Ornafa
9           4           Jakub                                                                                                Piotrowski
10          2           Agnieszka                                                                                            Rabczyk
11          5           Marcin                                                                                               Kochalski
12          9           Karolina                                                                                             Gwaiazdowski
13          3           Michał                                                                                               Gierczak
14          10          Mateusz                                                                                              Kucharczyk
*/

SELECT firmy.* FROM firmy

/*
nazwa_skr  id_miasta   nazwa                                                                                                kod_pocztowy ulica
---------- ----------- ---------------------------------------------------------------------------------------------------- ------------ ----------------------------------------------------------------------------------------------------
AWAV       12          AlphaWave Technologies                                                                               94-203       Żurawinowa
BFHI       6           BrightHorizon Innovations                                                                            91-200       Malinowa
GLED       10          GlobalEdge Enterprises                                                                               96-205       Lipowa
IVTS       4           Innovatech Solutions                                                                                 97-206       Sosnowa
NXSY       1           Nexus Systems Inc.                                                                                   95-204       Brzozowa
OSYN       8           Optimum Synergy Group                                                                                93-202       Jabłonkowa
QDYN       3           Quantum Dynamics                                                                                     92-201       Wiśniowa
TFIR       7           TechnoSoft Solutions                                                                                 90-199       Poziomkowa
*/

SELECT etaty.* FROM etaty

/*
id_osoby    id_firmy   stanowisko                                                                                           pensja      od         do         id_ETATU
----------- ---------- ---------------------------------------------------------------------------------------------------- ----------- ---------- ---------- -----------
1           TFIR       Dyrektor                                                                                             8000        2014-01-01 NULL       1
1           TFIR       Administrator Sieci LAN                                                                              4200        2014-02-15 NULL       2
1           TFIR       Manager                                                                                              6000        2014-03-20 NULL       3
2           BFHI       Programista                                                                                          5000        2014-04-10 NULL       4
2           QDYN       Analityk Biznesowy                                                                                   4500        2014-05-05 NULL       5
2           QDYN       Administrator Sieci WAN                                                                              4300        2014-06-20 NULL       6
2           TFIR       Dyrektor ds. Personalnych                                                                            8700        2014-07-15 NULL       7
3           QDYN       Analityk Systemu Komputerowego                                                                       4900        2014-08-10 NULL       8
3           QDYN       Asystent                                                                                             3500        2014-09-05 NULL       9
3           BFHI       Dyrektor ds. Produkcji                                                                               9100        2014-10-01 NULL       10
4           AWAV       Asystent Zarządu                                                                                     3800        2015-01-15 NULL       11
5           NXSY       Automatyk                                                                                            5200        2015-02-20 NULL       12
6           OSYN       Dyrektor ds. Administracyjnych                                                                       8000        2015-03-10 NULL       13
7           OSYN       Dyrektor ds. Badań i Rozwoju                                                                         8500        2015-04-05 NULL       14
8           AWAV       Dyrektor ds. Dystrybucji i Logistyki                                                                 8200        2015-05-20 NULL       15
9           NXSY       Dyrektor ds. Finansowych                                                                             9000        2015-06-15 NULL       16
10          AWAV       Dyrektor ds. Informatyki                                                                             8800        2016-07-01 2017-09-14 17
11          OSYN       Dyrektor ds. Marketingu                                                                              8600        2016-08-10 2019-01-01 18
*/