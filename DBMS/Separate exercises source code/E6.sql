-- 6
-- coduri de masina; tipul vectorului parametru
CREATE OR REPLACE TYPE v_coduri_masina AS VARRAY(100) OF NUMBER;
-- un vector de numere care va retine numar de comenzi pentru fiecare masina; tipul vectorului returnat
CREATE OR REPLACE TYPE v_numbers AS VARRAY(100) OF NUMBER; 
-- tip pentru tabelul imbricat de coduri_comanda; va fi folosit pentru a determina in cate comenzi apare o masina
CREATE OR REPLACE TYPE t_coduri_comenzi AS TABLE OF NUMBER; 



CREATE OR REPLACE FUNCTION f6( p_masini IN v_coduri_masina )
RETURN v_numbers AS

    TYPE t_cod_vanzari IS TABLE OF NUMBER INDEX BY PLS_INTEGER; -- index by table ( cod_masina, nr_vanzari )
    v_index_by_table t_cod_vanzari;

    nr_vanzari v_numbers := v_numbers();   -- de cate ori a fost vanduta fiecare masina
    v_comenzi t_coduri_comenzi; -- vector cu codurile comenzilor in care apare o masina
    v_serie_sasiu VARCHAR2( 17 );
    
    no_data_found EXCEPTION;
    v_nr_masini_gasite NUMBER;
    
BEGIN

    -- pentru fiecare cod_masina din parametru, trebuie determinata seria de sasiu aferenta
    -- apoi, pentru seria de sasiu trebuie rulata cererea
    -- seria de sasiu apare de mai multe ori in tabel deoarece o masina poate fi vanduta de mai multe ori
    FOR i IN 1 .. p_masini.COUNT LOOP
    
        BEGIN
        
            SELECT COUNT(*)
            INTO v_nr_masini_gasite
            FROM C##MYUSER.MASINA M
            WHERE M.COD_MASINA = p_masini(i);

            IF v_nr_masini_gasite = 0 THEN
                RAISE no_data_found;
            END IF;

            SELECT M.SERIE_SASIU 
                   INTO v_serie_sasiu
                   FROM C##MYUSER.MASINA M
                   WHERE M.COD_MASINA = p_masini(i);
                   
        EXCEPTION
            WHEN no_data_found THEN
                DBMS_OUTPUT.PUT_LINE('Masina cu codul ' || p_masini(i) || ' nu exista!');
                CONTINUE;
        END;
        
        -- golesc tabelul imbricat pentru fiecare masina
        v_comenzi := t_coduri_comenzi();
        
        SELECT NVL( M.COD_COMANDA, 0 )
               BULK COLLECT INTO v_comenzi
               FROM C##MYUSER.MASINA M
               WHERE M.SERIE_SASIU = v_serie_sasiu
               AND M.COD_COMANDA NOT LIKE 0;

        v_index_by_table(i) := v_comenzi.COUNT;
        DBMS_OUTPUT.PUT_LINE( 'Masina cu codul ' || p_masini( i ) || ' are seria de sariu ' 
        || v_serie_sasiu || ' si apare de ' || v_index_by_table( i ) || ' ori.' );
        
    END LOOP;

    -- Acum fiecare masina are asociat numarul sau de vanzari in v_index_by_table
    -- Voi lua valorile din aceasta colectie si le voi pune intr-un varray
    FOR i IN 1..v_index_by_table.COUNT LOOP
        nr_vanzari.EXTEND;
        nr_vanzari(i) := v_index_by_table(i);
    END LOOP;
    
    RETURN nr_vanzari;
END;

-- exemplu de apel:
DECLARE
    v_input_coduri v_coduri_masina := v_coduri_masina( 32459, 32460, 32461, 32488, 32467, 1 );
    v_output_nr_vanzari v_numbers;
BEGIN
    v_output_nr_vanzari := f6( v_input_coduri );
END;