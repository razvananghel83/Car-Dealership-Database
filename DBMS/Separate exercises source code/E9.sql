--9) Se dau un transportator si o reprezentanta. Sa se afiseze pentru fiecare masina livrata de acel 
--transportator la acea reprezentanta importatorul care a adus-o in tara. 


CREATE OR REPLACE PROCEDURE F9( p_cod_reprezentanta C##MYUSER.REPREZENTANTA.cod_reprezentanta%TYPE,
                                p_cod_transportator C##MYUSER.TRANSPORTATOR.cod_transportator%TYPE )
AS
    CURSOR MASINI IS
        SELECT M.cod_masina, M.marca, M.model,
               T.cod_transportator, TR.nume AS nume_transportator, 
               R.nume AS nume_reprezentanta, I.cod_importator, I.nume AS nume_importator
        FROM C##MYUSER.MASINA M
        JOIN C##MYUSER.TRANSPORT T ON T.cod_transport = M.cod_transport
        JOIN C##MYUSER.REPREZENTANTA R ON T.cod_reprezentanta = R.cod_reprezentanta
        JOIN C##MYUSER.TRANSPORTATOR TR ON T.cod_transportator = TR.cod_transportator
        JOIN C##MYUSER.CONTRACT C ON C.cod_transportator = TR.cod_transportator
        JOIN C##MYUSER.IMPORTATOR I ON C.cod_importator = I.cod_importator
        WHERE R.cod_reprezentanta = p_cod_reprezentanta
        AND TR.cod_transportator = p_cod_transportator
        AND UPPER( TRIM( M.marca ) ) = UPPER( TRIM( I.marca ) );


    -- Variabile pentru a verifica daca reprezentanta si transportatorul exista
    v_nume_reprezentanta VARCHAR2(50);
    v_nume_transportator VARCHAR2(50);


    -- variabile pentru a verifica daca cursorul gaseste date, voi folosi prefixul ts pentru test
    ts_cod_masina C##MYUSER.MASINA.cod_masina%TYPE;
    ts_marca C##MYUSER.MASINA.marca%TYPE;
    ts_model C##MYUSER.MASINA.model%TYPE;
    ts_cod_transportator C##MYUSER.TRANSPORTATOR.cod_transportator%TYPE;
    ts_nume_transportator C##MYUSER.TRANSPORTATOR.nume%TYPE;
    ts_nume_reprezentanta C##MYUSER.REPREZENTANTA.nume%TYPE;
    ts_cod_importator C##MYUSER.IMPORTATOR.cod_importator%TYPE;
    ts_nume_importator C##MYUSER.IMPORTATOR.nume%TYPE;


    -- Exceptii    
    e_nu_exista_reprezentanta EXCEPTION;
    e_nu_exista_transportator EXCEPTION;
    e_nu_exista_masini EXCEPTION;
    
BEGIN

    BEGIN
    
        SELECT R.nume
        INTO v_nume_reprezentanta
        FROM C##MYUSER.REPREZENTANTA R
        WHERE R.cod_reprezentanta = p_cod_reprezentanta;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE e_nu_exista_reprezentanta;
    END;


    BEGIN
    
        SELECT T.nume
        INTO v_nume_transportator
        FROM C##MYUSER.TRANSPORTATOR T
        WHERE T.cod_transportator = p_cod_transportator;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE e_nu_exista_transportator;
    END;


    OPEN MASINI;
        LOOP
            FETCH MASINI INTO ts_cod_masina, ts_marca, ts_model,
                              ts_cod_transportator, ts_nume_transportator, 
                              ts_nume_reprezentanta, ts_cod_importator, ts_nume_importator;
            IF MASINI%FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Transportatorul ' || v_nume_transportator 
                || ' a livrat la reprezentanta ' || v_nume_reprezentanta || CHR( 10 ) );
                
                CLOSE MASINI;
                
                FOR v_masina IN MASINI LOOP
                    DBMS_OUTPUT.PUT_LINE( 'Masina cu codul ' || v_masina.cod_masina || ' ' || v_masina.marca || ' ' || v_masina.model);
                    DBMS_OUTPUT.PUT_LINE( 'A fost livrata de transportatorul: ' || v_masina.cod_transportator || ' ' || v_masina.nume_transportator);
                    DBMS_OUTPUT.PUT_LINE( 'Importatorul ei este ' || v_masina.nume_importator || ' cu codul ' || v_masina.cod_importator || CHR( 10 ) );
                END LOOP;
                
                EXIT;
            
            ELSE 
                RAISE e_nu_exista_masini;
                CLOSE MASINI;
                EXIT;
            END IF;
            
        END LOOP;


EXCEPTION
    WHEN e_nu_exista_reprezentanta THEN
        DBMS_OUTPUT.PUT_LINE( 'Eroare: Reprezentanta nu exista!' || CHR( 10 ) );
    WHEN e_nu_exista_transportator THEN
        DBMS_OUTPUT.PUT_LINE( 'Eroare: Transportatorul nu exista!' || CHR( 10 )  );
    WHEN e_nu_exista_masini THEN
        DBMS_OUTPUT.PUT_LINE( 'Eroare: Transportatorul dat nu a livrat masini la reprezentanta data.' || CHR( 10 )  );
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( 'Alta eroare!' || CHR( 10 ) );
END;



BEGIN
        DBMS_OUTPUT.PUT_LINE( 'Primul apel, exista masini in cursor:');
        F9( 488, 4773 ); -- exista masini in cursor
        
        DBMS_OUTPUT.PUT_LINE( 'Al doilea apel, nu exista masini in cursor:');
        F9( 488, 4776 ); -- nu exista masini in cursor
        
        DBMS_OUTPUT.PUT_LINE( 'Al treilea apel, nu exista reprezentanta:');
        F9( 389, 4771 ); -- nu exista reprezentanta
        
        DBMS_OUTPUT.PUT_LINE( 'Al patrulea apel, nu exista transportatorul:');
        F9( 490, 5826 ); -- nu exista transportatorul
END;
/
