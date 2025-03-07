-- SECVENTE

-- lungimea maximă a id-ului entității MASINĂ este 5
CREATE SEQUENCE masina_seq
START WITH 32459
MAXVALUE 99999
INCREMENT BY 1
NOCYCLE
NOCACHE;

-- lungimea maximă a id-ului entității COMANDĂ este 8
CREATE SEQUENCE comanda_seq
START WITH 1249455
MAXVALUE 99999999
INCREMENT BY 1
NOCYCLE
NOCACHE;

-- lungimea maximă a id-ului entității CLIENT este 5
CREATE SEQUENCE client_seq
START WITH 23237
MAXVALUE 99999
INCREMENT BY 1
NOCYCLE
NOCACHE;


-- lungimea maximă a id-ului entității ADRESĂ este 5
CREATE SEQUENCE adresa_seq
START WITH 12780
MAXVALUE 99999
INCREMENT BY 1
NOCYCLE
NOCACHE;

-- lungimea maximă a id-ului entității REPREZENTANȚĂ este 3
CREATE SEQUENCE repezentanta_seq
START WITH 486
MAXVALUE 999
INCREMENT BY 1
NOCYCLE
NOCACHE;

-- lungimea maximă a id-ului entității SERVICE este 3
CREATE SEQUENCE serivice_seq
START WITH 100
MAXVALUE 999
INCREMENT BY 1
NOCYCLE
NOCACHE;

-- lungimea maximă a id-ului entității IMPORTATOR este 4
CREATE SEQUENCE importator_seq
START WITH 5814
MAXVALUE 9999
INCREMENT BY 1
NOCYCLE
NOCACHE;

-- lungimea maximă a id-ului entității TRANSPORTATOR este 4
CREATE SEQUENCE transportator_seq
START WITH 4771
MAXVALUE 9999
INCREMENT BY 1
NOCYCLE
NOCACHE;


-- lungimea maximă a id-ului entității TRANSPORT este 4
CREATE SEQUENCE transport_seq
START WITH 3794325
MAXVALUE 9999999
INCREMENT BY 1
NOCYCLE
NOCACHE;



-- TABELE
CREATE TABLE ADRESA (
    cod_adresa NUMBER( 5 ) DEFAULT adresa_seq.nextval PRIMARY KEY,
    localitate VARCHAR2( 20 ) NOT NULL CHECK( REGEXP_LIKE(localitate, '^[A-ZÎȚȘ][a-zA-Z0-9 șțăîâĂȘȚÎÂ-]*$') ),
    judet VARCHAR2( 15 ) NOT NULL CHECK( REGEXP_LIKE(judet, '^[A-Z][a-zA-Z șțăîâĂȘȚÎÂ]*$') ),
    strada VARCHAR2( 30 ) NOT NULL CHECK( REGEXP_LIKE(strada, '^[A-ZÎȚȘ][a-zA-Z ȘȚÎâîățș-]*$') ),
    numar NUMBER( 3 ) NOT NULL,

    bloc VARCHAR2( 5 ) DEFAULT NULL,
    scara VARCHAR2( 2 ) DEFAULT NULL,
    etaj NUMBER( 2 ) DEFAULT NULL,
    apartament NUMBER( 3 ) DEFAULT NULL
);


CREATE TABLE REPREZENTANTA (

    cod_reprezentanta NUMBER( 3 ) DEFAULT repezentanta_seq.nextval PRIMARY KEY,
    nume VARCHAR2( 30 ) UNIQUE NOT NULL CHECK ( REGEXP_LIKE( nume, '^[A-ZÎȚȘ][a-zA-Z0-9 ȘȚÎâîățș-]*$' ) ),
    cont_bancar VARCHAR( 24 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( cont_bancar, '^[A-Z0-9]+$') ),

    email VARCHAR2( 30 ) UNIQUE NOT NULL,
    telefon VARCHAR2( 10 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( telefon, '^0[0-9]+$' ) ),
    cod_adresa NUMBER( 5 ) NOT NULL REFERENCES ADRESA( cod_adresa )
);

CREATE TABLE SERVICE (

    cod_service NUMBER( 3 ) DEFAULT serivice_seq.nextval PRIMARY KEY,
    cod_reprezentanta NUMBER( 3 ) NOT NULL REFERENCES REPREZENTANTA( cod_reprezentanta ),
    email VARCHAR2( 30 ) UNIQUE NOT NULL,
    telefon VARCHAR2( 10 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( telefon, '^0[0-9]+$' ) )
);

CREATE TABLE IMPORTATOR (

    cod_importator NUMBER( 4 ) DEFAULT importator_seq.nextval PRIMARY KEY,
    nume VARCHAR2( 30 ) UNIQUE NOT NULL CHECK ( REGEXP_LIKE( nume, '^[A-ZÎȚȘ][a-zA-Z0-9 ȘȚÎâîățș-]*$' ) ),
    marca VARCHAR2( 20 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE(marca, '^[A-Z][a-zA-Z -]*$') ),

    cont_bancar VARCHAR( 24 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( cont_bancar, '^[A-Z0-9]+$') ),
    email VARCHAR2( 30 ) UNIQUE NOT NULL,
    telefon VARCHAR2( 10 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( telefon, '^0[0-9]+$' ) )
);

CREATE TABLE TRANSPORTATOR (

    cod_transportator NUMBER( 4 ) DEFAULT transportator_seq.nextval PRIMARY KEY,
    nume VARCHAR2( 30 ) UNIQUE NOT NULL CHECK ( REGEXP_LIKE( nume, '^[A-ZÎȚȘ][a-zA-Z0-9 ȘȚÎâîățș-]*$' ) ),
    cont_bancar VARCHAR( 24 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( cont_bancar, '^[A-Z0-9]+$') ),
    email VARCHAR2( 30 ) UNIQUE NOT NULL,
    telefon VARCHAR2( 10 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( telefon, '^0[0-9]+$' ) )
);

CREATE TABLE CONTRACT (

    cod_transportator NUMBER( 4 ) REFERENCES TRANSPORTATOR( cod_transportator ),
    cod_importator NUMBER( 4 ) REFERENCES IMPORTATOR( cod_importator ),
    PRIMARY KEY( cod_transportator, cod_importator )
);

CREATE TABLE TRANSPORT (

    cod_transport NUMBER( 7 ) DEFAULT transport_seq.nextval PRIMARY KEY,
    cod_reprezentanta NUMBER( 3 ) NOT NULL REFERENCES REPREZENTANTA( cod_reprezentanta ),
    cod_transportator NUMBER( 4 ) NOT NULL REFERENCES TRANSPORTATOR( cod_transportator ),

    data_plecare DATE DEFAULT NULL,
    data_sosire DATE DEFAULT NULL
);

CREATE TABLE CLIENT (

    cod_client NUMBER( 5 ) DEFAULT client_seq.nextval PRIMARY KEY,
    -- numele va fi în formatul: Nume Prenume1-Prenume2
    nume VARCHAR2( 30 ) NOT NULL,
    cod_adresa NUMBER( 5 ) NOT NULL REFERENCES ADRESA( cod_adresa ),

    data_nasterii DATE NOT NULL,
    cont_bancar VARCHAR( 24 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( cont_bancar, '^[A-Z0-9]+$') ),
    email VARCHAR2( 30 ) UNIQUE NOT NULL,
    telefon VARCHAR2( 10 ) UNIQUE NOT NULL CHECK( REGEXP_LIKE( telefon, '^0[0-9]+$' ) )
);

CREATE TABLE COMANDA (

    cod_comanda NUMBER( 8 ) DEFAULT comanda_seq.nextval PRIMARY KEY,
    cod_client NUMBER( 5 ) NOT NULL REFERENCES CLIENT( cod_client ),
    cod_reprezentanta NUMBER( 3 ) NOT NULL REFERENCES REPREZENTANTA( cod_reprezentanta )
);

CREATE TABLE MASINA (

    cod_masina NUMBER( 5 ) DEFAULT masina_seq.nextval PRIMARY KEY,
    serie_sasiu VARCHAR2( 17 ) NOT NULL CHECK( REGEXP_LIKE(serie_sasiu, '^[A-Z0-9]+$') ),
    pret NUMBER( 7 ) DEFAULT 0 NOT NULL,
    marca VARCHAR2( 20 ) NOT NULL CHECK( REGEXP_LIKE(marca, '^[A-Z][a-zA-Z -]*$') ),
    model varchar2( 20 ) NOT NULL CHECK( REGEXP_LIKE(model,'^[a-zA-Z0-9 -]+$' ) ),

    anul_fabricatiei NUMBER( 4 ) NOT NULL CHECK ( anul_fabricatiei > 2000 ),
    norma_poluare NUMBER( 1 ) NOT NULL CHECK( norma_poluare BETWEEN 0 AND 7 ),
    nr_kilometrii NUMBER( 7 ) NOT NULL,
    caroserie VARCHAR2( 15 ) NOT NULL, CHECK ( caroserie IN ( 'Berlină', 'Hatchback', 'Break', 'Decapotabilă', 'Coupe',
                                                             'SUV', 'Utilitară' ) ),
    combustibil VARCHAR2( 10 ) NOT NULL, CHECK ( combustibil IN ( 'Motorină', 'Benzină', 'GPL', 'Electric', 'Hybrid' ) ),
    putere NUMBER( 4 ) NOT NULL,
    capacitate_cilindrica NUMBER( 4 ) NOT NULL,
    data_vanzare DATE DEFAULT NULL,

    cod_comanda NUMBER( 8 ) DEFAULT NULL REFERENCES COMANDA( cod_comanda ),
    cod_transport NUMBER( 7 ) DEFAULT NULL REFERENCES TRANSPORT( cod_transport )

);


-- INSERARI
-- Importatori

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon )   -- MG
    VALUES( 'Quantum Auto Max', 'MG', 'RO89BTRL1064660423378420', 'quantumauto@gmail.ro', '0278456327' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon )   -- Dacia
    VALUES( 'Romcar Holdings SA', 'Dacia', 'RO64RNCB6779891571280995', 'romcarhds@dacia.ro', '0287943278' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- BMW
    VALUES( 'BMW Merger SRL', 'BMW', 'RO89BACX8202993140258288', 'mergerimport@bmw.ro', '0237379998' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Audi
    VALUES ( 'Mazuma Imports SRL', 'Audi', 'RO95RZBR7096337779152766', 'mazumaimports@romania.ro', '0235985147' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Honda
    VALUES ( 'Honda Trading', 'Honda', 'RO78CECE2030043488976256', 'hondatrading@honda.ro', '0256423056' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Subaru
    VALUES (  'Subaru Motors Trading ', 'Subaru', 'RO86INGB3771006962910725', 'subarumotorstrading@romania.ro', '0242067390' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Toyota
    VALUES ( 'Toyota Romania', 'Toyota', 'RO62BACX3773216852419517', 'relatii.clienti@toyota.ro', '0285604304' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Skoda
    VALUES ( 'Compexit Group', 'Skoda', 'RO42RNCB3352704571546788', 'complexitgroup@skoda.ro', '0274512063' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Porsche
    VALUES ( 'Porsche Romania', 'Porsche', 'RO27INGB4508326272110825', 'porscheromania@porsche.ro', '0299756025' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Mercedes
    VALUES ( 'Mercedes-Benz Romania SRL', 'Mercedes', 'RO96CECE2290238112594701', 'import.romania@mercedes.ro', '0285426018' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Hyundai
    VALUES ( 'Țiriac Auto', 'Hyundai', 'RO45BACX0111255225821108', 'hyundai@romania.ro', '0202458234' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Ford
    VALUES ( 'Cefin Auto SA', 'Ford', 'RO75INGB1531018827801352', 'cefinautosa@ford.ro', '0204562475' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Kia
    VALUES ( 'Premium Auto', 'Kia', 'RO63RNCB1263599830910089', 'premiumauto@romania.ro', '0278956240' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Renault
    VALUES ( 'Renault Commercial Roumanie', 'Renault', 'RO62CARP6567559359820225', 'renaultcommercial@romania.ro', '0255623410' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Mazda
    VALUES ( 'Mazda Romania', 'Mazda', 'RO96CECE8158201480923475', 'mazdaromania@mazda.ro', '0203645219' );

INSERT INTO IMPORTATOR( nume, marca, cont_bancar, email, telefon ) -- Volkswagen
    VALUES ( 'German Motors SRL', 'Volkswagen', 'RO74INGB8743937258105468', 'germanmotors@volkswagen.ro', '0266953415' );


-- Adrese Clienti
INSERT INTO ADRESA( localitate, judet ,strada, numar, bloc, scara, etaj, apartament )
    VALUES ( 'Turceni', 'Gorj', 'Eremia', 56, 'G', '4', 7, 130 );

INSERT INTO ADRESA( localitate, judet ,strada, numar, bloc, scara, etaj, apartament )
    VALUES ( 'Baia Mare', 'Maramureș', 'Georgescu', 201, 'B2', 'K', 4, 421 );

INSERT INTO ADRESA( localitate, judet ,strada, numar, bloc, scara, etaj, apartament )
    VALUES ( 'Deta', 'Timiș', 'Generalilor', 78, 'Turn', 8, 3, 14 );

INSERT INTO ADRESA( localitate, judet ,strada, numar, bloc, scara, etaj, apartament )
    VALUES ( 'Adjud', 'Vrancea', 'Ghioceilor', 21, 'C7', '10', 5, 29 );

INSERT INTO ADRESA( localitate, judet ,strada, numar, bloc, scara, etaj, apartament )
    VALUES ( 'Orșova', 'Mehedinți', 'Jiului', 45, 'H1', 'B', 8, 89 );

INSERT INTO ADRESA( localitate, judet ,strada, numar )
    VALUES ( 'Borsec', 'Harghita', 'Câmpului', 63  );

INSERT INTO ADRESA( localitate, judet ,strada, numar, bloc, etaj )  -- Adresa unei persoane juridice, într-o clădire de birouri
    VALUES ( 'Brăila', 'Brăila', 'Calea Călărașilor', 56, 'Sky 2' ,4 );


-- Adrese Reprezentante
INSERT INTO ADRESA( localitate, judet ,strada, numar )
    VALUES ( 'Brașov', 'Brașov', 'Dunărea', 154  );

INSERT INTO ADRESA( localitate, judet ,strada, numar )
    VALUES ( 'Sector 2', 'București', 'Șoseaua Pipera', 346 ); --pipera

INSERT INTO ADRESA( localitate, judet ,strada, numar )
    VALUES ( 'Brăila', 'Brăila', 'Șoseaua Dig Brăila-Galați', 8  );

INSERT INTO ADRESA( localitate, judet ,strada, numar )
    VALUES ( 'Galați', 'Galați', 'Verdun', 13 );

INSERT INTO ADRESA( localitate, judet ,strada, numar )
    VALUES( 'Suceava', 'Suceava', 'Siret', 79  );

INSERT INTO ADRESA( localitate, judet, strada, numar)
    VALUES( 'Sector 6', 'București', 'Preciziei', 14 );

INSERT INTO ADRESA( localitate, judet, strada, numar, bloc, scara, etaj, apartament )
    VALUES( 'Sector 3', 'București', 'Bulevardul Theodor Pallady', 375, 'B7', '3' ,4, 26 );

INSERT INTO ADRESA( localitate, judet, strada, numar, bloc, scara, etaj, apartament )
    VALUES( 'Sector 6', 'București', 'Bulevardul Iuliu Maniu', 185, 'E4', '7', 10, 98 );

INSERT INTO ADRESA( localitate, judet, strada, numar, bloc, scara, etaj, apartament )
    VALUES( 'Constanța', 'Constanța', 'Bulevardul Aurel Vlaicu', 280, 'A1', '9', 4, 11 );


-- Transportatori
INSERT INTO TRANSPORTATOR( nume, cont_bancar, email, telefon )
    VALUES( 'Transport Auto SRL', 'RO78CECE7919463267504484', 'transportauto@romania.ro', '0744756210');

INSERT INTO TRANSPORTATOR( nume, cont_bancar, email, telefon )
    VALUES( 'Auto Plus', 'RO56INGB7866400372629299', 'autoplus@transport.ro', '0775621032');

INSERT INTO TRANSPORTATOR( nume, cont_bancar, email, telefon )
    VALUES( 'Nonstop Transport', 'RO77RZBR5821134657564557', 'nonstop@transport.ro', '0755623201');

INSERT INTO TRANSPORTATOR( nume, cont_bancar, email, telefon )
    VALUES( 'Transmarian', 'RO67CARP8294958279033040', 'transmarian@romania.ro', '0756923014');

INSERT INTO TRANSPORTATOR( nume, cont_bancar, email, telefon )
    VALUES( 'Transauto', 'RO61BACX4786626493509428', 'transauto@transport.ro', '0759624107');

INSERT INTO TRANSPORTATOR( nume, cont_bancar, email, telefon )
    VALUES( 'Autos Transport', 'RO36RNCB4865342064890901', 'autostransport@romania.ro', '0767634220');


-- Reprezentanțe
INSERT INTO REPREZENTANTA( nume, cont_bancar, email, telefon, cod_adresa )
    VALUES( 'Irmex Brașov', 'RO78CECE2583709624128395', 'irmexbraila@gmail.com', '0278956241', 12787 );

INSERT INTO REPREZENTANTA( nume, cont_bancar, email, telefon, cod_adresa )
    VALUES( 'Porsche Pipera', 'RO56INGB2381146855420020', 'porschepipera@gmail.com', '0274845494', 12788 );

INSERT INTO REPREZENTANTA( nume, cont_bancar, email, telefon, cod_adresa )
    VALUES( 'Apan Motors Braila', 'RO32RZBR9052999078928219', 'apanmotorsbraila@gmail.com', '0274574875', 12789 );

INSERT INTO REPREZENTANTA( nume, cont_bancar, email, telefon, cod_adresa )
    VALUES( 'SF Tex Galați', 'RO99CARP1437667188334191', 'texgalati@gmail.com', '0296685662', 12790 );

INSERT INTO REPREZENTANTA( nume, cont_bancar, email, telefon, cod_adresa )
    VALUES( 'Toyota Suceava', 'RO87BACX3673458843344471', 'dealer.suceava@toyota.ro', '0274210336', 12791 );

INSERT INTO REPREZENTANTA( nume, cont_bancar, email, telefon, cod_adresa )
    VALUES( 'West Cars Bucharest', 'RO96RNCB8113778410952037', 'westcars@bucharest.ro', '0278485448', 12792 );


-- Service-uri
INSERT INTO SERVICE ( cod_reprezentanta, email, telefon )
    VALUES( 486, 'irmex_brasov@service.ro', '0285963241' );

INSERT INTO SERVICE ( cod_reprezentanta, email, telefon )
    VALUES( 487, 'porsche.pipera@service.ro', '0278956321' );

INSERT INTO SERVICE ( cod_reprezentanta, email, telefon )
    VALUES( 488, 'service.braila@apan.ro', '0262539578' );

INSERT INTO SERVICE ( cod_reprezentanta, email, telefon )
    VALUES( 489, 'service@sftex.ro', '0278956241' );

INSERT INTO SERVICE ( cod_reprezentanta, email, telefon )
    VALUES( 490, 'service.suceava@toyota.ro', '0299658213' );

INSERT INTO SERVICE ( cod_reprezentanta, email, telefon )
    VALUES( 491, 'service@westcars.ro', '0256958741' );


-- Clienti
INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES ( 'Popescu Marius', 12780, '8-JUN-2000', 'RO58INGB1756309559892080', 'popescumarius@gmail.ro', '0785624130' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES ( 'Ivan Ana', 12781, '6-JAN-1972', 'RO97CECE8614821566328038', 'ivan.ana@gmail.ro', '0775624130' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES ( 'Ion Daniel', 12782, '15-FEB-1999', 'RO66RZBR5137423697876983', 'iondaniel@gmail.ro', '0769324150' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES ( 'Enache Florentina', 12783, '24-SEP-2001', 'RO78CARP8593433351929808', 'florentinaenache@gmail.ro', '0778569240' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES ( 'Andronache Vasile', 12784, '3-JUN-1985', 'RO79BACX9181105387711988', 'andronachevasile@gmail.ro', '0746825012' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES ( 'Pop Ana', 12785, '17-AUG-1979', 'RO96RNCB2140271553894608', 'anapop@gmail.ro', '0778569241' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES( 'SC Triton SRL', 12786, '16-JUL-1995', 'RO64CECE2145987746321574', 'relatii.clienti@triton.com.ro', '0785452147' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES( 'Ionescu Ștefan', 12793, '27-SEP-1997', 'RO59RZBR7896123545822265', 'stefan_ionescu27@icloud.ro', '0725557485' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES( 'Georgescu Gabriel', 12794, '17-FEB-1975', 'RO84BACX7845002400006587', 'stefan_ionescu17@icloud.ro', '0749845254' );

INSERT INTO CLIENT( nume, cod_adresa, data_nasterii, cont_bancar, email, telefon )
    VALUES( 'Dragomir Teodora', 12795, '25-JUN-1972', 'RO12INGB9965774823511548', 'teodora.dragomir25@icloud.ro', '0725300848' );


-- Contracte
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4771, 5814 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4772, 5815 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4773, 5816 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4774, 5817 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4775, 5818 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4776, 5819 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4771, 5820 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4772, 5821 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4773, 5822 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4774, 5823 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4775, 5824 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4776, 5825 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4771, 5826 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4772, 5827 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4773, 5828 ) ;
INSERT INTO CONTRACT( cod_transportator, cod_importator ) VALUES( 4774, 5829 ) ;



-- Comenzi
-- Popescu Marius comanda un BMW 520d la Apan Motors Brăila în 2016
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23237, 488 );

-- Popescu Marius comanda un Mercedes E400 la SF Tex Galați în 2018 și vinde BMW 520d
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23237, 489 );

-- Popescu Marius comanda o Toyota Camry la Toyota Suceava în 2021 și vinde Mercedes E400
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23237, 490 );

-- Ivan Ana cumpara de la Sf Tex Galați un BMW 520d în 2019 și un Volkswagen Crafter
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23238, 489 );

-- Ivan Ana cumpara de la Apan Motors Brăila un BMW X3 în 2021 și vinde BMW 520d
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23238, 488 );

-- Ion Daniel cumpara de la Irmex Brașov un Ford Mondeo în 2016
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23239, 486 );

-- Ion Daniel cumpara de la Toyota Suceava o Toyota Corolla și vinde un Ford Mondeo
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23239, 490 );

-- Andronache Vasile cumpara de la Porsche Pipera un Audi S5 in 2024
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES ( 23241, 487 );

-- Enache Florentina cumpara un Ford Mondeo de la Toyota Suceava in 2023
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES ( 23240, 490 );

-- Enache Florentina cumpara un Prsche 911 Cabrio de la Porsche Pipera in 2023
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES ( 23240, 487 );

-- SC Triton SRL cumpără in 2018 3 Loganuri și un Ford Tranzit de la Irmex Brașov
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23243, 486 );

-- SC Triton SRL cumpără in 2024 2 Mazda 2 și vinde 2 Loganuri la Irmex Brașov
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23243, 486 );

-- Ionescu Ștefan cumpără un Mercedes E400 de la Toyota Suceava în 2022
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES ( 23244, 490 );

-- Georgescu Gabriel cumpără un BMW 520d de la Apan Motors Brăila în 2022
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES ( 23245, 488 );

-- Ivan Ana cumpără în 2024 un Logan de la Irmex Brașov
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES ( 23238, 486 );

-- Dragomir Teodora cumpără de la Toyota Suceava în 2022 un Kia Stinger
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23246, 490 );

-- Dragomir Teodora cumpără de la Toyota Suceava în 2023 o Honda Civic și vinde un Kia Stinger
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23246, 490 );

-- Popescu Marius cumpără de la Toyota Suceava în 2024 un Kia Stinger
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23237, 490 );

-- Popescu Marius cumpără de la Toyota Suceava în 2024 un Renault Captur și vinde un Kia Stinger
INSERT INTO COMANDA( cod_client, cod_reprezentanta ) VALUES( 23237, 490 );



-- Transporturi
INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
        VALUES ( 488, 4773, '13-JAN-2017', '23-JAN-2017' ); -- BMW 520d 2016

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
        VALUES ( 489, 4774, '5-JAN-2019', '14-JAN-2019' ); -- Mercedes E400 2018

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
        VALUES ( 490, 4771, '28-FEB-2022', '8-MAR-2022' ); -- Toyota Camry 2021

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
        VALUES ( 489, 4774, '27-MAY-2019', '3-JUN-2019' );  -- Volkswagen Crafter 2019

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES ( 488, 4773, '13-MAR-2022', '14-MAR-2022' ); -- BMW X3 2021

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES ( 487, 4773, '18-DEC-2024', '21-DEC-2024' ); -- Audi S5

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES ( 486, 4776, '18-JUL-2016', '21-JUL-2016' ); -- Ford Mondeo 2016

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES ( 490, 4771, '7-JUL-2023', '14-JUL-2023' ); -- Toyota Corolla 2023

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES ( 486, 4772, '23-JUN-2018', '26-JUN-2018' ); -- Dacia Logan 2018

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES ( 486, 4776, '12-SEP-2018', '15-SEP-2018' ); -- Ford Tranzit 2018

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES ( 486, 4773, '2-DEC-2024', '5-DEC-2024' ); -- Mazda 2 2024

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare )
    VALUES( 491, 4772, '16-NOV-2024' ); -- Skoda Octavia 2024

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator )
    VALUES( 487, 4773 ); -- Porsche 911 Cabrio

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES( 491, 4771, '23-MAR-2023', '24-MAR-2023' ); -- Kia Stinger 2022

INSERT INTO TRANSPORT( cod_reprezentanta, cod_transportator, data_plecare, data_sosire )
    VALUES( 490, 4772, '9-OCT-2024', '10-OCT-2024' ); -- Honda Civic 2024


-- Masini
-- Popescu Marius comanda un BMW 520d la Apan Motors Brăila în 2016
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( 'WBAKP9C50GD980586', 75000, 'BMW', '520d', 2016, 5, 100, 'Berlină', 'Motorină', 184, 1995, '25-OCT-2016',
           1249455, 3794325 );

-- Popescu Marius comanda un Mercedes E400 la SF Tex Galați în 2018 și vinde BMW 520d
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( '4T4BF3EK9BR182409', 75000, 'Mercedez-Benz', 'E400', 2018, 6, 100, 'Berlină', 'Benzină', 333, 3498, '12-DEC-2018',
           1249456, 3794326  );

-- Popescu Marius comanda o Toyota Camry la Toyota Suceava în 2021 și vinde Mercedes E400
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( '1C4RDJAG8EC511538', 35000, 'Toyota', 'Camry', 2021, 6, 100, 'Berlină', 'Hybrid', 218, 2487, '8-AUG-2021',
           1249457, 3794327  );

-- Ionescu Ștefan cumpără un Mercedes E400 de la Toyota Suceava în 2022
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda )
    VALUES( '4T4BF3EK9BR182409', 25000, 'Mercedez-Benz', 'E400', 2018, 6, 155879, 'Berlină', 'Benzină', 333, 3498, '15-APR-2022',
           1249467 );

-- Ivan Ana cumpara de la Sf Tex Galați un BMW 520d în 2019 și un Volkswagen Crafter
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda )
    VALUES( 'WBAKP9C50GD980586', 45000, 'BMW', '520d', 2016, 5, 80000, 'Berlină', 'Motorină', 184, 1995, '12-FEB-2019', 1249458 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( 'WVGJV3AXXEW549191', 30000, 'Volkswagen', 'Crafter', 2021, 6, 80, 'Utilitară', 'Motorină', 155, 2254, '12-FEB-2019',
           1249458, 3794328 );

-- Ivan Ana cumpara de la Apan Motors Brăila un BMW X3 și vinde un BMW 520d
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( '1GCJTCDE0A8114263', 55000, 'BMW', 'X3', 2021, 6, 100, 'SUV', 'Benzină', 245, 1998, '4-JUN-2021',
           1249459, 3794329 );

-- Georgescu Gabriel cumpără un BMW 520d de la Apan Motors Brăila în 2022
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda )
    VALUES( 'WBAKP9C50GD980586', 25000, 'BMW', '520d', 2016, 6, 100, 'Berlină', 'Motorină', 184, 1995, '23-APR-2022' , 1249468 );

-- West Cars cumpara stoc. Masinile nu au numar de comanda
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica )
    VALUES( '4A3AC84843E031749', 20000, 'MG', 'ZS', 2024, 6, 250, 'SUV', 'Benzină', 106, 1498 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica )
    VALUES( '5GTEN13L1980066EX', 23700, 'MG', '3', 2024, 6, 200, 'Hatchback', 'Hybrid', 194, 1490 );


-- Andronache Vasile cumpara de la Porsche Pipera un Audi S5 in 2024
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( 'WAUGD5440LN008570', 73000, 'Audi', 'S5', 2024, 6, 60, 'Decapotabilă', 'Benzină', 354, 2995, '7-JUL-2024',
           1249462, 3794330 );

-- Ion Daniel cumpără de la Irmex Brașov un Ford Mondeo în 2016
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( '1FABP3798FW328823', 28350, 'Ford', 'Mondeo', 2016, 5, 80, 'Hatchback', 'Motorină', 153, 1998, '31-JAN-2016',
           1249460, 3794331 );

-- Ion Daniel cumpără de la Toyota Suceava o Toyota Corolla și vinde un Ford Mondeo în 2023
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( 'JT2EL46S9R0502556', 26850, 'Toyota', 'Corolla', 2023, 6, 120, 'Break', 'Hybrid', 196, 1987, '13-JAN-2023',
           1249461, 3794332 );

-- Enache Florentina cumpără un Ford Mondeo de la Toyota Suceava in 2023
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda )
    VALUES( '1FABP3798FW328823', 10500, 'Ford', 'Mondeo', 2016, 5, 180878, 'Hatchback', 'Motorină', 153, 1998, '8-AUG-2023', 1249463 );


--14
-- SC Triton SRL cumpără in 2018 3 Loganuri și un Ford Tranzit de la Irmex Brașov
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( '3C4PFABB1DT246517', 10500, 'Dacia', 'Logan', 2018, 6, 120, 'Berlină', 'GPL', 100, 999, '7-MAY-2018',
           1249465, 3794333 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( '3C3CFFJH3FT630338', 10500, 'Dacia', 'Logan', 2018, 6, 120, 'Berlină', 'GPL', 100, 999, '7-MAY-2018',
           1249465, 3794333 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( 'ZARED33E0S6303319', 10500, 'Dacia', 'Logan', 2018, 6, 120, 'Berlină', 'GPL', 100, 999, '7-MAY-2018',
           1249465, 3794333 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
    VALUES( '1F1SG65683H726608', 25500, 'Ford', 'Tranzit', 2018, 6, 120, 'Utilitară', 'Motorină', 130, 2164, '7-MAY-2018',
           1249465, 3794334 );


-- SC Triton SRL cumpără in 2024 2 Mazda 2 și o Octavia și vinde 3 Loganuri la Irmex Brașov
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica )
    VALUES( '3C3CFFJH3FT630338', 6500, 'Dacia', 'Logan', 2018, 6, 127028, 'Berlină', 'GPL', 100, 999 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica )
      VALUES( 'ZARED33E0S6303319', 6500, 'Dacia', 'Logan', 2018, 6, 147476, 'Berlină', 'GPL', 100, 999 );

-- un Logan se vinde, 2 raman pe stoc
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda )
  VALUES( '3C4PFABB1DT246517', 5500, 'Dacia', 'Logan', 2018, 6, 220875, 'Berlină', 'GPL', 100, 999, '23-SEP-2024', 1249469 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
  VALUES( '1YVGE31C4S5423092', 23500, 'Mazda', '2', 2024, 6, 75, 'Hatchback', 'Hybrid', 91, 1496, '17-APR-2024',
         1249466, 3794335 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
  VALUES( 'JT4RN01P0N7057480', 23500, 'Mazda', '2', 2024, 6, 75, 'Hatchback', 'Hybrid', 91, 1496, '17-APR-2024',
         1249466, 3794335 );

INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
  VALUES( 'WVW7771J7YW248023', 27500, 'Skoda', 'Octavia', 2024, 6, 75, 'Hatchback', 'Motorină', 150, 1988, '17-APR-2024',
         1249466, 3794336 );

-- Enache Florentina cumpara un Porsche 911 Cabrio de la Porsche Pipera in 2023
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
  VALUES( 'WP0AB29935S175494', 225000, 'Porsche', '911 Cabriolet', 2020, 6, 75, 'Decapotabilă', 'Benzină', 450, 2981, '4-MAR-2024',
         1249464, 3794337 );


SELECT C.cod_comanda, C.cod_client, cl.nume, m.marca, m.model
       FROM COMANDA C
       join CLIENT cl on cl.cod_client = C.cod_client
       join MASINA m on m.cod_comanda = C.cod_comanda
       order by cod_comanda;

-- 25
-- Dragomir Teodora cumpără de la Toyota suceava în 2022 un Kia Stinger
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
  VALUES( 'KNADN5A32C6736025', 45000, 'Kia', 'Stinger', 2022, 6, 300, 'Hatchback', 'Benzină', 304, 2496, '24-NOV-2022',
         1249470, 3794338 );

-- Dragomir Teodora cumpără de la Toyota Suceava în 2023 o Honda Civic și vinde un Kia Stinger
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda, cod_transport )
  VALUES( '1HGCM825X3A802211', 38230, 'Honda', 'Civic', 2023, 6, 70, 'Hatchback', 'Hybrid', 184, 1993, '29-NOV-2024',
         1249471, 3794339 );

-- Popescu Marius cumpără de la Toyota Suceava în 2024 un Kia Stinger
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, cod_comanda, data_vanzare )
  VALUES( 'KNADN5A32C6736025', 28000, 'Kia', 'Stinger', 2022, 6, 36547, 'Hatchback', 'Benzină', 304, 2496, 1249472, '23-APR-2024' );


-- Popescu Marius cumpără de la Toyota Suceava în 2024 un Renault Captur și vinde un Kia Stinger
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica, data_vanzare, cod_comanda )
  VALUES( 'VF1BZB1A6BR585200', 26190, 'Renault', 'Captur', 2024, 6, 45, 'SUV', 'Hybrid', 143, 1598, '20-OCT-2024', 1249473 );

-- Kia Stinger rămâne în inventar la Toyota Suceava
INSERT INTO MASINA( serie_sasiu, pret, marca, model, anul_fabricatiei, norma_poluare, nr_kilometrii, caroserie, combustibil,
                   putere, capacitate_cilindrica )
  VALUES( 'KNADN5A32C6736025', 25000, 'Kia', 'Stinger', 2022, 6, 45875, 'Hatchback', 'Benzină', 304, 2496 );

