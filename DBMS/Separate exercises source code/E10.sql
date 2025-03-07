CREATE OR REPLACE TRIGGER delete_protection
BEFORE DELETE OR UPDATE OF cod_reprezentanta ON C##MYUSER.SERVICE
BEGIN

    IF DELETING THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nu se pot șterge linii ale tabelului SERVICE!');
    ELSIF UPDATING THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nu se pot realiza actualizări asupra coloanei cod_reprezentanta în tabelul SERVICE!');
    END IF;
    
END;
/

DELETE FROM C##MYUSER.SERVICE S
WHERE S.cod_service = 103;

UPDATE C##MYUSER.SERVICE S
SET S.cod_reprezentanta= 900
WHERE S.cod_service = 102;