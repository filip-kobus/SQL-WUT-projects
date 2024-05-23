/*
Filip Kobus 331703
Z7, grupa wtorkowa

Stworzyć 3 tabele opisane w pliku Excel

I trigery
*/



---------------------------------------------------------------------------
--TWORZE TABELE
---------------------------------------------------------------------------


--Tworze tabele TOWAR
IF NOT EXISTS (
	SELECT 1
		FROM sysobjects o
		WHERE (OBJECTPROPERTY(o.[id],'IsUserTable') = 1)
		AND o.[name] = 'TOWAR'
)
BEGIN
	CREATE TABLE dbo.TOWAR (
		Nazwa_tow VARCHAR(100),
		ID_TOW INT PRIMARY KEY,
		LICZBA_ZAK INT,
		LICZBA_DOSTEPNYCH INT
	)
END
GO


--Tworze tabele ZAKUPY
IF NOT EXISTS (
	SELECT 1
		FROM sysobjects o
		WHERE (OBJECTPROPERTY(o.[id],'IsUserTable') = 1)
		AND o.[name] = 'ZAKUPY'
)
BEGIN
	CREATE TABLE dbo.ZAKUPY (
		ID_ZAKUP INT PRIMARY KEY,
		ID_TOW INT,
		ilosc INT,
		FOREIGN KEY (ID_TOW) REFERENCES TOWAR(ID_TOW)
	)
END
GO

--Tworze tabele WYD_Z_MAG
IF NOT EXISTS (
	SELECT 1
		FROM sysobjects o
		WHERE (OBJECTPROPERTY(o.[id],'IsUserTable') = 1)
		AND o.[name] = 'WYD_Z_MAG'
)
BEGIN
	CREATE TABLE dbo.WYD_Z_MAG (
		ID_WYD INT PRIMARY KEY,
		ID_TOW INT,
		ilosc INT,
		FOREIGN KEY (ID_TOW) REFERENCES TOWAR(ID_TOW)
	)
END
GO


---------------------------------------------------------------------------
--TWORZE TRIGGERY
---------------------------------------------------------------------------


--1. Triggery do towaru
-- Tworzê trigger na tabele TOWAR, który po insercie ustawia LICZBA_ZAK i LICZBA_DOSTEPNYCH na 0
CREATE TRIGGER dbo.trg_AfterInsert_TOWAR
ON TOWAR
AFTER INSERT
AS
BEGIN
    UPDATE dbo.TOWAR
    SET LICZBA_ZAK = 0, 
        LICZBA_DOSTEPNYCH = 0
    WHERE ID_TOW IN (SELECT ID_TOW FROM inserted);
END;
GO

-- Tworze trigger na tabele TOWAR, który przy aktualizacji sprawdza, czy LICZBA_DOSTEPNYCH jest nieujemna
-- i czy LICZBA_DOSTEPNYCH jest wiêksza od LICZBA_ZAK
CREATE TRIGGER dbo.trg_AfterUpdate_TOWAR
ON TOWAR
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE LICZBA_DOSTEPNYCH < 0 OR LICZBA_DOSTEPNYCH > LICZBA_ZAK
    )
    BEGIN
        PRINT 'LICZBA_DOSTEPNYCH nie mo¿e byæ ujemna lub wiêksza od LICZBA_ZAK';
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        UPDATE t
        SET t.Nazwa_tow = i.Nazwa_tow,
            t.LICZBA_ZAK = i.LICZBA_ZAK,
            t.LICZBA_DOSTEPNYCH = i.LICZBA_DOSTEPNYCH
        FROM dbo.TOWAR t
        INNER JOIN inserted i ON t.ID_TOW = i.ID_TOW;
    END;
END;
GO


-- 2. Triggery do Zakupów
CREATE TRIGGER dbo.trg_AfterInsert_ZAKUPY
ON ZAKUPY
AFTER INSERT
AS
BEGIN
	UPDATE TOWAR
	SET LICZBA_ZAK = LICZBA_ZAK
		+ ISNULL((SELECT SUM(ilosc) FROM inserted WHERE TOWAR.ID_TOW=inserted.ID_TOW), 0)
	
	UPDATE TOWAR
	SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH
		+ ISNULL((SELECT SUM(ilosc) FROM inserted WHERE TOWAR.ID_TOW=inserted.ID_TOW), 0)
END;


CREATE TRIGGER dbo.trg_AfterUpdate_ZAKUPY
ON ZAKUPY
AFTER UPDATE
AS
BEGIN
	--Jedyna mo¿liwa kolejnoœæ operacji, inaczej za³¹czy siê trigger zabezpieczaj¹cy
	UPDATE TOWAR
    SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH
		- ISNULL((SELECT SUM(ilosc) FROM deleted WHERE TOWAR.ID_TOW=deleted.ID_TOW), 0)

    UPDATE TOWAR
    SET LICZBA_ZAK = LICZBA_ZAK
		- ISNULL((SELECT SUM(ilosc) FROM deleted WHERE TOWAR.ID_TOW=deleted.ID_TOW), 0)

	UPDATE TOWAR
    SET LICZBA_ZAK = LICZBA_ZAK
		+ ISNULL((SELECT SUM(ilosc) FROM inserted WHERE TOWAR.ID_TOW=inserted.ID_TOW), 0)

    UPDATE TOWAR
    SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH
		+ ISNULL((SELECT SUM(ilosc) FROM inserted WHERE TOWAR.ID_TOW=inserted.ID_TOW), 0)
END;
GO


CREATE TRIGGER dbo.trg_AfterDelete_ZAKUPY
ON ZAKUPY
AFTER DELETE
AS
BEGIN
    UPDATE TOWAR
    SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH
		- ISNULL((SELECT SUM(ilosc) FROM deleted WHERE TOWAR.ID_TOW=deleted.ID_TOW), 0)
	
	UPDATE TOWAR
    SET LICZBA_ZAK = LICZBA_ZAK
		- ISNULL((SELECT SUM(ilosc) FROM deleted WHERE TOWAR.ID_TOW=deleted.ID_TOW), 0)
END;
GO

-- 3. Triggery do WYD_Z_MAG
CREATE TRIGGER dbo.trg_AfterInsert_WYDZ_MAG
ON WYD_Z_MAG
AFTER INSERT
AS
BEGIN
    UPDATE TOWAR
    SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH
		- ISNULL((SELECT SUM(ilosc) FROM inserted WHERE TOWAR.ID_TOW=inserted.ID_TOW), 0)
END;
GO

CREATE TRIGGER dbo.trg_AfterUpdate_WYDZ_MAG
ON WYD_Z_MAG
AFTER UPDATE
AS
BEGIN
    UPDATE TOWAR
    SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH
		+ ISNULL((SELECT SUM(ilosc) FROM deleted WHERE TOWAR.ID_TOW=deleted.ID_TOW), 0)
		- ISNULL((SELECT SUM(ilosc) FROM inserted WHERE TOWAR.ID_TOW=inserted.ID_TOW), 0)
END;
GO

CREATE TRIGGER dbo.trg_AfterDelete_WYDZ_MAG
ON WYD_Z_MAG
AFTER DELETE
AS
BEGIN
    UPDATE TOWAR
    SET LICZBA_DOSTEPNYCH = LICZBA_DOSTEPNYCH
		+ ISNULL((SELECT SUM(ilosc) FROM deleted WHERE TOWAR.ID_TOW=deleted.ID_TOW), 0)
END;
GO


---------------------------------------------------------------------------
--SPRAWDZAM POPRAWNOŒÆ TRIGGERÓW
---------------------------------------------------------------------------

/*Najpierw musze usunac wydane z magazynu, dopiero potem zakupy, inaczej aktywuje sie trigger*/

-- to nic nie zmienia ale mozna wykorzystaæ do czyszczenia tabel
DELETE FROM WYD_Z_MAG;
DELETE FROM ZAKUPY


INSERT INTO TOWAR (ID_TOW, Nazwa_tow)
VALUES 
    (1, 'Kaszanka'),
    (2, 'Kie³basa'),
    (3, 'Boczek'),
    (4, 'Antrykot'),
    (5, 'Pasztet');

INSERT INTO ZAKUPY (ID_ZAKUP, ID_TOW, ilosc)
VALUES 
    (1, 1, 10),
    (2, 1, 2),
    (3, 1, 3),
    (4, 4, 2),
    (5, 5, 12),
    (6, 5, 8);

INSERT INTO WYD_Z_MAG(ID_WYD, ID_TOW, ilosc)
VALUES 
    (1, 1, 6),
    (2, 1, 2),
    (3, 4, 1),
    (4, 4, 1),
    (5, 5, 4),
    (6, 5, 3);

/*
TOW1: kupiono 15 sztuk, wydano 8, zosta³o 7
TOW4: kupiono 2 sztuki, wydano 2, zosta³o 0
TOW5: kupiono 20 sztuk, wydano 7, zosta³o 13

Nazwa_Towaru              ID_TOW      LICZBA_ZAK  LICZBA_DOSTEPNYCH
------------------------- ----------- ----------- -----------------
Kaszanka                  1           15          7
Kie³basa                  2           0           0
Boczek                    3           0           0
Antrykot                  4           2           0
Pasztet                   5           20          13
*/


INSERT INTO ZAKUPY (ID_ZAKUP, ID_TOW, ilosc)
VALUES 
    (7, 1, 3),
	(8, 5, 8);


/*
Towar 1 zwiêksza siê o 3
Towar 5 zwiêksza siê o 8

Nazwa_Towaru              ID_TOW      LICZBA_ZAK  LICZBA_DOSTEPNYCH
------------------------- ----------- ----------- -----------------
Kaszanka                  1           18          10
Kie³basa                  2           0           0
Boczek                    3           0           0
Antrykot                  4           2           0
Pasztet                   5           28          21
*/


DELETE FROM ZAKUPY
WHERE ID_TOW = 5 AND ilosc = 8

/*
Poniewa¿ by³y dwa zakupy towaru 5 po 8 sztuk
Usuniêto z tabeli towar 16 pasztetów

Nazwa_Towaru              ID_TOW      LICZBA_ZAK  LICZBA_DOSTEPNYCH
------------------------- ----------- ----------- -----------------
Kaszanka                  1           18          10
Kie³basa                  2           0           0
Boczek                    3           0           0
Antrykot                  4           2           0
Pasztet                   5           12          5
*/


UPDATE ZAKUPY
SET ilosc = 1
WHERE ID_TOW = 1 AND ilosc < 10;

/*
Zmieniono 3 wiersze dla ID_TOW = 1
z ilosc 2 -> 1
z ilosc 3 -> 1
z ilosc 3 -> 1
wiêc liczba dostêpnych i zakupionych kaszanek zmniejsza siê o 5

Nazwa_Towaru              ID_TOW      LICZBA_ZAK  LICZBA_DOSTEPNYCH
------------------------- ----------- ----------- -----------------
Kaszanka                  1           13          5
Kie³basa                  2           0           0
Boczek                    3           0           0
Antrykot                  4           2           0
Pasztet                   5           12          5
*/


INSERT INTO WYD_Z_MAG(ID_WYD, ID_TOW, ilosc)
VALUES 
    (7, 1, 3),
	(8, 5, 2);

/*
Wydano 2 pasztety i 3 kaszanki

Nazwa_Towaru              ID_TOW      LICZBA_ZAK  LICZBA_DOSTEPNYCH
------------------------- ----------- ----------- -----------------
Kaszanka                  1           13          2
Kie³basa                  2           0           0
Boczek                    3           0           0
Antrykot                  4           2           0
Pasztet                   5           12          3
*/


DELETE FROM WYD_Z_MAG
WHERE ID_TOW = 4

/*
Usun¹³em wydanie z magazynu antrykotów, wiêc teraz wszystkie zakupione s¹ dostêpne

Nazwa_Towaru              ID_TOW      LICZBA_ZAK  LICZBA_DOSTEPNYCH
------------------------- ----------- ----------- -----------------
Kaszanka                  1           13          2
Kie³basa                  2           0           0
Boczek                    3           0           0
Antrykot                  4           2           2
Pasztet                   5           12          3
*/


UPDATE WYD_Z_MAG
SET ilosc = 2
WHERE ID_TOW = 5

/*
Poniewa¿ s¹ 3 wydania kaszanki, a ka¿dy z nich zmieni³em na 2
to liczba wydanych kaszanek wynosi 6

Nazwa_Towaru              ID_TOW      LICZBA_ZAK  LICZBA_DOSTEPNYCH
------------------------- ----------- ----------- -----------------
Kaszanka                  1           13          2
Kie³basa                  2           0           0
Boczek                    3           0           0
Antrykot                  4           2           2
Pasztet                   5           12          6
*/


INSERT INTO WYD_Z_MAG(ID_WYD, ID_TOW, ilosc)
VALUES 
    (9, 1, 3);

/*
Poniewa¿ dostêpne s¹ tylko 2 kaszanki, nie mogê wydaæ 3

LICZBA_DOSTEPNYCH nie mo¿e byæ ujemna lub wiêksza od LICZBA_ZAK
Msg 3609, Level 16, State 1, Procedure trg_AfterInsert_WYDZ_MAG, Line 6
The transaction ended in the trigger. The batch has been aborted.
*/
