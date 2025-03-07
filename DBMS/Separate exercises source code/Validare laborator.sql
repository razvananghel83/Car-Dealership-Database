-- coduri de masina; tipul vectorului parametru
CREATE OR REPLACE TYPE v_coduri_masina AS VARRAY(100) OF NUMBER;
-- un vector de numere care va retine numar de comenzi pentru fiecare masina; tipul vectorului returnat
CREATE OR REPLACE TYPE v_numbers AS VARRAY(100) OF NUMBER; 
-- tip pentru tabelul imbricat de coduri_comanda; va fi folosit pentru a determina in cate comenzi apare o masina
CREATE OR REPLACE TYPE t_coduri_comenzi AS TABLE OF NUMBER; 

-- 2 exceptii proprii si sa le declansez

CREATE OR REPLACE FUNCTION f6( p_masini IN v_coduri_masina )
RETURN v_numbers AS

    TYPE t_cod_vanzari IS TABLE OF NUMBER INDEX BY PLS_INTEGER; -- index by table ( cod_masina, nr_vanzari )
    v_index_by_table t_cod_vanzari;

    nr_vanzari v_numbers := v_numbers();   -- de cate ori a fost vanduta fiecare masina
    v_comenzi t_coduri_comenzi; -- vector cu codurile comenzilor in care apare o masina
    v_serie_sasiu VARCHAR2( 17 );
    
    no_data_found EXCEPTION;
    v_nr_masini_gasite NUMBER := 0;
    
    e_nu_exista_masina EXCEPTION;
    e_masina_nevanduta EXCEPTION;

BEGIN
    FOR i IN 1 .. p_masini.COUNT LOOP
        BEGIN
            SELECT COUNT(*)
            INTO v_nr_masini_gasite
            FROM C##MYUSER.MASINA M
            WHERE M.COD_MASINA = p_masini(i);
            
            IF v_nr_masini_gasite = 0 THEN
                RAISE e_nu_exista_masina;
            END IF;
            
            SELECT M.SERIE_SASIU
            INTO v_serie_sasiu
            FROM C##MYUSER.MASINA M
            WHERE M.COD_MASINA = p_masini(i);
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_serie_sasiu := NULL;
            WHEN e_nu_exista_masina THEN
                RAISE_APPLICATION_ERROR(-20003, 'Nu exista masina cu codul ' || p_masini(i));
        END;

        BEGIN
            v_comenzi := t_coduri_comenzi();
            
            IF v_serie_sasiu IS NOT NULL THEN
                SELECT NVL(M.COD_COMANDA, 0)
                BULK COLLECT INTO v_comenzi
                FROM C##MYUSER.MASINA M
                WHERE M.SERIE_SASIU = v_serie_sasiu
                AND M.COD_COMANDA <> 0;
            END IF;
    
            v_index_by_table(i) := v_comenzi.COUNT;
            
            IF v_index_by_table(i) = 0 THEN
                RAISE e_masina_nevanduta;
            END IF;
            
            DBMS_OUTPUT.PUT_LINE('Masina cu codul ' || p_masini(i) || ' are seria ' 
            || v_serie_sasiu || ' si apare de ' || v_index_by_table(i) || ' ori.');
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_index_by_table(i) := 0;
            WHEN e_masina_nevanduta THEN
                RAISE_APPLICATION_ERROR(-20004, 
                'Masina nu a fost vanduta macar o data: ' || p_masini(i));
        END; 
    END LOOP;

    FOR i IN 1..v_index_by_table.COUNT LOOP
        nr_vanzari.EXTEND;
        nr_vanzari(i) := v_index_by_table(i);
    END LOOP;
    
    RETURN nr_vanzari;
END;
/

-- exemplu de apel:
DECLARE
    -- 32467
    v_input_coduri v_coduri_masina := v_coduri_masina( 32459, 32460, 32461, 32488, 32467, 1 );
    v_output_nr_vanzari v_numbers;
BEGIN
    v_output_nr_vanzari := f6( v_input_coduri );
END;
