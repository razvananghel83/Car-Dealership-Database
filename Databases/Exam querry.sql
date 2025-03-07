--numele clientilor care au lansat cele mai multe comenzi

SELECT CL1.NUME
       FROM CLIENT CL1
       JOIN COMANDA C ON CL1.COD_CLIENT = C.COD_CLIENT
       GROUP BY CL1.COD_CLIENT, CL1.NUME
       HAVING COUNT( C.COD_COMANDA ) = (
              SELECT MAX( NR_COMENZI )
                     FROM (
                         SELECT COUNT( C.COD_COMANDA ) AS NR_COMENZI
                                FROM COMANDA C
                                GROUP BY C.COD_CLIENT
                    )
       );
