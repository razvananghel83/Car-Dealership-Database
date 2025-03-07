CREATE OR REPLACE PROCEDURE F7 AS

    CURSOR cursor_transporturi IS
        SELECT cod_transport, cod_reprezentanta
        FROM C##MYUSER.transport
        ORDER BY cod_transport;
    
    -- cursor parametrizat, dependent de cursor_tranporturi
    CURSOR cursor_adresa( p_cod_reprezentanta C##MYUSER.reprezentanta.cod_reprezentanta%TYPE ) IS
        SELECT A.localitate, A.judet, A.strada, A.numar
        FROM C##MYUSER.adresa A
        JOIN C##MYUSER.reprezentanta R ON R.cod_adresa = A.cod_adresa
        WHERE R.cod_reprezentanta = p_cod_reprezentanta;

    v_cod_transport C##MYUSER.transport.cod_transport%TYPE;
    v_cod_reprezentanta C##MYUSER.transport.cod_reprezentanta%TYPE;
    
    v_localitate C##MYUSER.adresa.localitate%TYPE;
    v_judet C##MYUSER.adresa.judet%TYPE;
    v_strada C##MYUSER.adresa.strada%TYPE;
    v_numar C##MYUSER.adresa.numar%TYPE;
    
BEGIN

    -- Ciclu cursor pentru a parcurge toate transporturile
    FOR transport IN cursor_transporturi LOOP
    
        v_cod_transport := transport.cod_transport;
        v_cod_reprezentanta := transport.cod_reprezentanta;

        -- Cursor parametrizat clasic, dependent de celalalt pentru a determina adresa unui transport
        OPEN cursor_adresa( v_cod_reprezentanta );
        FETCH cursor_adresa INTO v_localitate, v_judet, v_strada, v_numar;

        IF cursor_adresa%FOUND THEN
            IF INSTR( v_localitate, 'Sector' ) = 0 THEN
                DBMS_OUTPUT.PUT_LINE( 'Transportul ' || v_cod_transport || ' are adresa: strada ' || v_strada 
                || ', numarul ' || v_numar || ', localitatea ' || v_localitate || ', judetul ' || v_judet );
            ELSE
                DBMS_OUTPUT.PUT_LINE( 'Transportul ' || v_cod_transport || ' are adresa: strada ' || v_strada 
                || ', numarul ' || v_numar || ', ' || v_localitate || ', ' || v_judet );
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE( 'Adresa transportului ' || v_cod_transport || ' nu a fost gasita!' );
        END IF;
        
        CLOSE cursor_adresa;
    END LOOP;
END;
/

BEGIN
    F7();
END;
/
