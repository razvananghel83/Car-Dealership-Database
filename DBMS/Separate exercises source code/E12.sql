CREATE TABLE C##MYUSER.LOG_LDD (

    utilizator VARCHAR2(30), 
    nume_bd VARCHAR2(50), 
    eveniment VARCHAR2(20), 
    nume_obiect VARCHAR2(30), 
    data DATE
); 

CREATE OR REPLACE TRIGGER trigger_ldd 
AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
    INSERT INTO C##MYUSER.LOG_LDD
    VALUES (
        SYS_CONTEXT('USERENV', 'SESSION_USER'),  
        SYS_CONTEXT('USERENV', 'DB_NAME'),       
        ORA_SYSEVENT,                            
        ORA_DICT_OBJ_NAME,                      
        SYSDATE                                 
    ); 

    DBMS_OUTPUT.PUT_LINE('A avut loc o operatie LDD de tip ' || ORA_SYSEVENT || ' pe obiectul ' || ORA_DICT_OBJ_NAME);
END;
/

CREATE TABLE C##MYUSER.TEST (
    
    DATA DATE DEFAULT SYSDATE
);
DROP TABLE C##MYUSER.TEST;
