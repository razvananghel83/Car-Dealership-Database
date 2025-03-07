CREATE TABLE C##MYUSER.INFO_TRANSPORT(

    COD_TRANSPORT NUMBER( 7 ) PRIMARY KEY,
    TOTAL NUMBER( 10 )
);
COMMIT;

CREATE OR REPLACE TRIGGER valoare_transport
AFTER DELETE OR UPDATE OR INSERT OF pret ON C##MYUSER.MASINA
FOR EACH ROW
DECLARE 
    v_valoare NUMBER;
BEGIN
    IF DELETING THEN
    
        UPDATE C##MYUSER.info_transport T
        SET T.total = NVL(T.total, 0) - :OLD.pret
        WHERE T.cod_transport = :OLD.cod_transport;
        
        IF SQL%ROWCOUNT = 0 THEN
        
            SELECT SUM(M.pret)
            INTO v_valoare
            FROM C##MYUSER.MASINA M
            WHERE M.cod_transport = :OLD.cod_transport;
            
            INSERT INTO C##MYUSER.info_transport(cod_transport, total)
            VALUES(:OLD.cod_transport, v_valoare);
            
        END IF;

    ELSIF UPDATING THEN

        UPDATE C##MYUSER.info_transport T
        SET T.total = NVL(T.total, 0) + :NEW.pret - :OLD.pret
        WHERE T.cod_transport = :OLD.cod_transport;
        
        IF SQL%ROWCOUNT = 0 THEN
        
            SELECT SUM(M.pret)
            INTO v_valoare
            FROM C##MYUSER.MASINA M
            WHERE M.cod_transport = :NEW.cod_transport;
            
            INSERT INTO C##MYUSER.info_transport(cod_transport, total)
            VALUES(:NEW.cod_transport, v_valoare);
        END IF;

    ELSIF INSERTING THEN
    
        UPDATE C##MYUSER.info_transport T
        SET T.total = NVL(T.total, 0) + :NEW.pret
        WHERE T.cod_transport = :NEW.cod_transport;
        
        IF SQL%ROWCOUNT = 0 THEN
        
            SELECT SUM(M.pret)
            INTO v_valoare
            FROM C##MYUSER.MASINA M
            WHERE M.cod_transport = :NEW.cod_transport;
            
            INSERT INTO C##MYUSER.info_transport(cod_transport, total)
            VALUES(:NEW.cod_transport, v_valoare);
            
        END IF;
    END IF;
END;
/

-- Testare
-- UPDATE:
-- Update, nu exista inregistrare pentru transportul respectiv in INFO_TRANSPORT
UPDATE C##MYUSER.MASINA M    
SET M.PRET = M.pret + 2000
WHERE M.COD_MASINA = 32474;
COMMIT;

SELECT M.COD_MASINA, M.MARCA, M.MODEL, M.PRET, M.COD_TRANSPORT
       FROM C##MYUSER.MASINA M WHERE M.COD_TRANSPORT = 3794333;
       
-- Update, exista inregistrare pentru transportul respectiv in INFO_TRANSPORT
UPDATE C##MYUSER.MASINA M    
SET M.PRET = M.PRET - 2000
WHERE M.COD_MASINA = 32474;
COMMIT;



-- INSERT, nu exista inregistrare pentru transportul respectiv in INFO_TRANSPORT
INSERT INTO C##MYUSER.MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, 
            nr_kilometrii, caroserie, combustibil, putere, capacitate_cilindrica, cod_transport )
VALUES( 'F7YCFFJH3FT985347', 12500, 'Volkswagen', 'Tiguan', 2018, 6, 120000, 'SUV', 'Benzină', 
150, 1496, 3794339 );

-- INSERT, exista inregistrare pentru transportul respectiv in INFO_TRANSPORT
INSERT INTO C##MYUSER.MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, 
            nr_kilometrii, caroserie, combustibil, putere, capacitate_cilindrica, cod_transport )
VALUES( 'F7YCFFJH3FT985347', 19500, 'Renault', 'Arkana', 2020, 6, 83000, 'SUV', 'Benzină', 
150, 1398, 3794339 );

SELECT M.COD_MASINA, M.MARCA, M.MODEL, M.PRET, M.COD_TRANSPORT
       FROM C##MYUSER.MASINA M WHERE M.COD_TRANSPORT = 3794339;

-- DELETE, exista inregistrare pentru transportul respectiv in INFO_TRANSPORT
DELETE FROM C##MYUSER.MASINA M
WHERE M.COD_MASINA = 32490;

DELETE FROM C##MYUSER.MASINA M
WHERE M.COD_MASINA = 32491;

SELECT M.COD_MASINA, M.MARCA, M.MODEL, M.PRET, M.COD_TRANSPORT
       FROM C##MYUSER.MASINA M WHERE M.COD_TRANSPORT = 3794339;
COMMIT;

-- DELETE, nu exista inregistrare pentru transportul respectiv in INFO_TRANSPORT
DELETE FROM C##MYUSER.MASINA M
WHERE M.COD_MASINA = 32480;

SELECT M.COD_MASINA, M.MARCA, M.MODEL, M.PRET, M.COD_TRANSPORT
       FROM C##MYUSER.MASINA M WHERE M.COD_TRANSPORT = 3794335;
ROLLBACK;

