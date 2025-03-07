-- Exercitiul 12

-- Cerinta 1:
-- Afișați clienții care au cumpărat mașini la un preț mai mare decât media mașinilor vândute în București.
-- Să se afișeze și adresele clienților.
-- Am utilizat:
-- a) subcereri sincronizate în care intervin cel puțin 3 tabele ( în cazul meu 4 )
-- c) funcții grup
-- e) utilizarea a cel puțin 2 funcții pe șiruri de caractere( în cazul meu 3 )


SELECT CL.COD_CLIENT,
       CL.NUME AS "NUME CLIENT",
       CONCAT( CONCAT( M1.MARCA, ' ' ), M1.MODEL ) AS MASINI,
       UPPER( AD.JUDET ) || ' ' || INITCAP( AD.LOCALITATE ) || ' ' || AD.STRADA || ' ' || TO_CHAR( AD.STRADA ) AS ADRESA
       FROM CLIENT CL
       JOIN COMANDA CO ON CL.COD_CLIENT = CO.COD_CLIENT
       JOIN MASINA M1 ON CO.COD_COMANDA = M1.COD_COMANDA
       JOIN ADRESA AD ON CL.COD_ADRESA = AD.COD_ADRESA

       WHERE M1.PRET >= (

            SELECT  AVG( ROUND( M2.PRET, 0) )
                    FROM MASINA M2
                    JOIN COMANDA CO2 ON M2.COD_COMANDA = CO2.COD_COMANDA
                    JOIN REPREZENTANTA R ON CO2.COD_REPREZENTANTA = R.COD_REPREZENTANTA
                    JOIN ADRESA AR ON R.COD_ADRESA = AR.COD_ADRESA
                    WHERE UPPER( TRIM( AR.JUDET ) ) = 'BUCUREȘTI'

      );


-- Cerința 2: Afișați reprezentanțele și totalul vânzărilor lor, folosind o subcerere nesincronizată.
-- Am utilizat:
-- b) subcerere nesincronizată în clauza FROM
-- d) ordonări
-- c) funcții grup
-- f) utilizarea a cel puțin 1 bloc de cerere (clauza WITH)

WITH CERERE AS (

    SELECT COD_REPREZENTANTA, SUM( M.PRET ) AS TOTAL_VANZARI
    FROM MASINA M
    JOIN COMANDA CO ON M.COD_COMANDA = CO.COD_COMANDA
    GROUP BY COD_REPREZENTANTA
)

SELECT R.NUME,
       V.TOTAL_VANZARI
       FROM REPREZENTANTA R
       LEFT JOIN CERERE V ON R.COD_REPREZENTANTA = V.COD_REPREZENTANTA
       ORDER BY V.TOTAL_VANZARI DESC;


-- Cerința 3:
-- Afișați reprezentanțele care au vândut mai multe mașini decât media pe țară și localitatea lor.
-- Am utilizat:
-- c) grupare cu funcții grup și subcerere nesincronizată în HAVING

SELECT R.NUME,
       AD.LOCALITATE,
       COUNT( M.COD_MASINA ) AS NUMAR_MASINI
       FROM REPREZENTANTA R
       JOIN COMANDA CO ON R.COD_REPREZENTANTA = CO.COD_REPREZENTANTA
       JOIN MASINA M ON CO.COD_COMANDA = M.COD_COMANDA
       JOIN ADRESA AD ON R.COD_ADRESA = AD.COD_ADRESA
       GROUP BY R.NUME, AD.LOCALITATE
       HAVING COUNT( M.COD_MASINA ) >= (

            SELECT AVG( NUMAR )
                   FROM (
                        SELECT COUNT( M2.COD_MASINA ) AS NUMAR
                               FROM REPREZENTANTA R2
                               JOIN COMANDA CO2 ON R2.COD_REPREZENTANTA = CO2.COD_REPREZENTANTA
                               JOIN MASINA M2 ON CO2.COD_COMANDA = M2.COD_COMANDA
                               GROUP BY R2.NUME
                        )
       );



-- Cerința 4:
-- Afișează data livrării și tipul de combustibil pentru vehiculele livrate în 2023 și 2024.
-- Tipul de combustibil va primi un cod numeric unic:
-- 'MOTORINĂ'- 1,
-- 'BENZINĂ'- 2,
-- 'HYBRID' - 3,
-- 'GPL' - 4,
-- 'ELECTRIC' - 5
--  Default - -1
--
-- Am utilizat:
-- utilizarea funcțiilor NVL și DECODE (în cadrul aceleiași cereri) ( d )
-- ordonări ( d )
-- o funcție pentru șiruri de caractere ( e )
-- 2 funcție pentru date calendaristice ( e )

SELECT M.MARCA, M.MODEL,
       NVL( TO_CHAR( T.DATA_PLECARE, 'YYYY-MM-DD' ), 'Nu există' ) AS DATA_PLECARE,
       NVL( TO_CHAR( T.DATA_SOSIRE, 'YYYY-MM-DD' ), 'Nu există' ) AS DATA_SOSIRE,
       DECODE(   UPPER( M.COMBUSTIBIL ),
                 'MOTORINĂ', 1,
                 'BENZINĂ', 2,
                 'HYBRID', 3,
                 'GPL', 4,
                 'ELECTRIC', 5,
                 -1 ) AS TIP_COMBUSTIBIL

       FROM MASINA M
       JOIN TRANSPORT T ON M.COD_TRANSPORT = T.COD_TRANSPORT
       WHERE EXTRACT( YEAR FROM T.DATA_PLECARE ) IN ( 2023, 2024 )
       ORDER BY M.MARCA, M.DATA_VANZARE DESC;


-- Cerinta 5:
-- Din masinile care au fost vândute și livrate până acum ( SYSDATE ), extrageti numarul de vanzari per reprezentanta.
-- Pentru fiecare reprezentanță, să se listeze și domeniul e-mail-ului și pentru fiecare total să se acorde un
-- calificativ.


WITH VANZARI_PER_REPREZENTANTA AS ( -- pentru masini deja livrate

    SELECT R.COD_REPREZENTANTA,
           COUNT( M.COD_MASINA ) AS NR_VANZARI
           FROM REPREZENTANTA R

           JOIN COMANDA CO ON R.COD_REPREZENTANTA = CO.COD_REPREZENTANTA
           JOIN MASINA M ON CO.COD_COMANDA = M.COD_COMANDA
           JOIN TRANSPORT T ON M.COD_TRANSPORT = T.COD_TRANSPORT

           WHERE T.DATA_SOSIRE < ( SELECT SYSDATE FROM DUAL )
           GROUP BY R.COD_REPREZENTANTA
)

SELECT R.NUME,
       SUBSTR( R.EMAIL, INSTR( R.EMAIL, '@' ) + 1 ) AS DOMENIU_EMAIL,
       CASE
           WHEN VPR.NR_VANZARI <= 2 THEN 'Reduse'
           WHEN VPR.NR_VANZARI IN ( 3, 4 ) THEN 'Medii'
           ELSE 'Ridicate'
       END AS VANZARI

       FROM REPREZENTANTA R
       JOIN VANZARI_PER_REPREZENTANTA VPR ON R.COD_REPREZENTANTA = VPR.COD_REPREZENTANTA
       ORDER BY VPR.NR_VANZARI DESC;
--numele clientilor care au lansat cele mai multe comenzi

-- Exercițiul 13

-- Cerința 1: Șterge toate transporturile care nu au sosit și mașinile incluse în ele.

DELETE FROM MASINA
WHERE COD_TRANSPORT IN (

        SELECT COD_TRANSPORT FROM TRANSPORT T
                             WHERE T.DATA_SOSIRE > SYSDATE OR T.DATA_SOSIRE IS NULL
    );

DELETE FROM TRANSPORT
WHERE DATA_SOSIRE > SYSDATE OR DATA_SOSIRE IS NULL;


-- Cerința 2: Promoție de Crăciun: pentru mașinile care sunt în stoc la reprezentanțe, să se scadă prețul cu 25%.

UPDATE MASINA
SET PRET = PRET * 0.75
WHERE COD_MASINA IN (
    SELECT M.COD_MASINA
    FROM MASINA M
    WHERE M.COD_COMANDA IS NULL
);

-- Cerința 3: O bancă s-a desființat. Să se modifice toate conturile bancare care includ în IBAN „RNCB”
-- prin înlocuirea cu „INGB”.

UPDATE REPREZENTANTA
SET CONT_BANCAR = REPLACE( CONT_BANCAR, 'RNCB', 'INGB' )
WHERE COD_REPREZENTANTA IN
      (
          SELECT R.COD_REPREZENTANTA FROM REPREZENTANTA R
          WHERE R.CONT_BANCAR LIKE '%RNCB%'
          );

UPDATE IMPORTATOR
SET CONT_BANCAR = REPLACE( CONT_BANCAR, 'RNCB', 'INGB' )
WHERE COD_IMPORTATOR IN
      (
          SELECT I.COD_IMPORTATOR FROM IMPORTATOR I
          WHERE I.CONT_BANCAR LIKE '%RNCB%'
          );

UPDATE TRANSPORTATOR
SET CONT_BANCAR = REPLACE( CONT_BANCAR, 'RNCB', 'INGB' )
WHERE COD_TRANSPORTATOR IN
      (
          SELECT T.COD_TRANSPORTATOR FROM TRANSPORTATOR T
          WHERE T.CONT_BANCAR LIKE '%RNCB%'
          );

UPDATE CLIENT
SET CONT_BANCAR = REPLACE( CONT_BANCAR, 'RNCB', 'INGB' )
WHERE COD_CLIENT IN
      (
          SELECT C.COD_CLIENT FROM CLIENT C
          WHERE C.CONT_BANCAR LIKE '%RNCB%'
          );
