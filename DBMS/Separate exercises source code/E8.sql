-- 8) Pentru un service dat ca parametru, sa se determine adresa sa in format VARCHAR2( 250 ),
-- folosind un subprogram stocat independent de tip functie

CREATE OR REPLACE FUNCTION f8( p_cod_service IN C##MYUSER.SERVICE.cod_service%TYPE )
RETURN VARCHAR2 AS

    v_strada C##MYUSER.ADRESA.strada%TYPE;
    v_numar C##MYUSER.ADRESA.numar%TYPE;
    v_localitate C##MYUSER.ADRESA.localitate%TYPE;
    v_judet C##MYUSER.ADRESA.judet%TYPE;
    
    v_rezultat VARCHAR2(250);
BEGIN

    BEGIN
        SELECT A.strada, A.numar, A.localitate, A.judet
        INTO v_strada, v_numar, v_localitate, v_judet
        FROM C##MYUSER.SERVICE S
        JOIN C##MYUSER.REPREZENTANTA R ON R.cod_reprezentanta = S.cod_reprezentanta
        JOIN C##MYUSER.ADRESA A ON A.cod_adresa = R.cod_adresa
        WHERE S.cod_service = p_cod_service;

        IF INSTR( v_localitate, 'Sector' ) = 0 THEN
                v_rezultat := 'Strada ' || v_strada || ', numarul ' || v_numar || ', localitatea ' 
                    || v_localitate || ', judetul ' || v_judet;
            ELSE
               v_rezultat := 'Strada ' || v_strada || ', numarul ' || v_numar || ', ' 
                    || v_localitate || ', ' || v_judet;
        END IF;
        
                    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE( 'Codul de service ' || p_cod_service || ' nu exista!' || CHR(10) );
            RETURN NULL;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE( 'Exista mai multe inregistrari pentru codul de service ' 
            || p_cod_service || CHR(10) );
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE( 'Alta eroare!' || CHR(10) );
            RETURN NULL;
    END;
    
    RETURN v_rezultat;
    
END;

-- BLOC COMPLET
-- Am rulat blocul de mai jos pentru a permite modificarea tabelului SERVICE
DECLARE
    c_name VARCHAR2( 30 );
BEGIN

    -- sterg intai toate constrangerile pentru coloana e-mail, care, deoarece este UNIQUE NOT NULL, 
    -- va deveni noua cheie primara
    -- de asemenea, sterg toate constrangerile coloanei cod_service, pentru a putea insera coduri identice
    -- astfel, voi ajunge la exceptia TOO_MANY_ROWS
    FOR c IN (SELECT constraint_name 
          FROM all_cons_columns 
          WHERE (column_name = 'EMAIL' OR column_name = 'COD_SERVICE') 
          AND table_name = 'SERVICE' 
          AND owner = 'C##MYUSER') LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE DROP CONSTRAINT ' || c.constraint_name;
    END LOOP;

    -- execute immediate permite efectuarea comenzilor LDD in PL/SQL prin SQL dinamic ( se ruleaza la runtime )
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE ADD CONSTRAINT email_pk PRIMARY KEY (email)';
    
    -- insert into nu are nevoie de SQL dinamic
    INSERT INTO C##MYUSER.SERVICE ( cod_service, cod_reprezentanta, email, telefon )
    VALUES( 101, 487, 'service.clona@service.ro', '0296453785' );

    DBMS_OUTPUT.PUT_LINE( 'Cazul 1: service-ul exista si are o singura inregistrare:' );
    rezultat := f8( 104 );
    DBMS_OUTPUT.PUT_LINE( rezultat || CHR(10) );
    
    DBMS_OUTPUT.PUT_LINE( 'Cazul 2: service-ul nu exista:' );
    rezultat := f8( 90 );
    
    DBMS_OUTPUT.PUT_LINE( 'Cazul 3: service-ul exista si are mai multe inregistrari:' );
    rezultat := f8( 101 );
        
    -- acum voi sterge din tabel service-ul inserat anterior
    DELETE FROM C##MYUSER.SERVICE S
    WHERE S.email LIKE 'service.clona@service.ro';
    
    -- Drop primary key constraint
    SELECT constraint_name INTO c_name
    FROM all_constraints
    WHERE table_name = 'SERVICE' AND owner = 'C##MYUSER' AND constraint_type = 'P';
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE DROP CONSTRAINT ' || c_name;
    
    -- Definesc din nou constrangerile initiale pentru tabela SERVICE
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE MODIFY (email VARCHAR2(30) UNIQUE NOT NULL)';
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE ADD CONSTRAINT service_cod_service_pk PRIMARY KEY (cod_service)';
    
END;
/

-- BLOCUL MARE IMPARTIT IN DOUA BLOCURI
BEGIN
    -- sterg intai toate constrangerile pentru coloana e-mail, care, deoarece este UNIQUE NOT NULL, 
    -- va deveni noua cheie primara
    -- de asemenea, sterg toate constrangerile coloanei cod_service, pentru a putea insera coduri identice
    -- astfel, voi ajunge la exceptia TOO_MANY_ROWS
    FOR c IN (SELECT constraint_name 
          FROM all_cons_columns 
          WHERE (column_name = 'EMAIL' OR column_name = 'COD_SERVICE') 
          AND table_name = 'SERVICE' 
          AND owner = 'C##MYUSER') LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE DROP CONSTRAINT ' || c.constraint_name;
    END LOOP;

-- execute immediate permite efectuarea comenzilor LDD in PL/SQL prin SQL dinamic ( se ruleaza la runtime )
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE ADD CONSTRAINT email_pk PRIMARY KEY (email)';
    
    -- insert into nu are nevoie de SQL dinamic
    INSERT INTO C##MYUSER.SERVICE ( cod_service, cod_reprezentanta, email, telefon )
    VALUES( 101, 487, 'service.clona@service.ro', '0296453785' );

END;
/


-- bloc pentru restaurarea structurii tabelului SERVICE este:
DECLARE
    c_name VARCHAR2( 30 );
    rezultat VARCHAR( 250 ) := NULL;
BEGIN
    
    DBMS_OUTPUT.PUT_LINE( 'Cazul 1: service-ul exista si are o singura inregistrare:' );
    rezultat := f8( 104 );
    DBMS_OUTPUT.PUT_LINE( rezultat || CHR(10) );
    
    DBMS_OUTPUT.PUT_LINE( 'Cazul 2: service-ul nu exista:' );
    rezultat := f8( 90 );
    
    DBMS_OUTPUT.PUT_LINE( 'Cazul 3: service-ul exista si are mai multe inregistrari:' );
    rezultat := f8( 101 );
        
    -- acum voi sterge din tabel service-ul inserat anterior
    DELETE FROM C##MYUSER.SERVICE S
    WHERE S.email LIKE 'service.clona@service.ro';
    
    -- Drop primary key constraint
    SELECT constraint_name INTO c_name
    FROM all_constraints
    WHERE table_name = 'SERVICE' AND owner = 'C##MYUSER' AND constraint_type = 'P';
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE DROP CONSTRAINT ' || c_name;
    
    -- Definesc din nou constrangerile initiale pentru tabela SERVICE
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE MODIFY (email VARCHAR2(30) UNIQUE NOT NULL)';
    EXECUTE IMMEDIATE 'ALTER TABLE C##MYUSER.SERVICE ADD CONSTRAINT service_cod_service_pk PRIMARY KEY (cod_service)';
    
END;
/


