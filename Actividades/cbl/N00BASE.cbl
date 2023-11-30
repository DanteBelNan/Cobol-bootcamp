       IDENTIFICATION DIVISION. 
       PROGRAM-ID. N00BASE.
       
       DATA DIVISION. 
       WORKING-STORAGE SECTION. 
          01 CONTADOR PIC 9(3) VALUE 1.
       PROCEDURE DIVISION.
           PERFORM 1000-INICIO
           THRU 1000-INICIO-EXIT

           PERFORM 2000-PROCESO
           THRU 2000-PROCESO-EXIT  

           PERFORM 3000-FIN
           THRU 3000-FIN-EXIT
           STOP RUN.

       1000-INICIO.
           DISPLAY "Entro al inicio"
           .
       1000-INICIO-EXIT.
           EXIT.
       2000-PROCESO.
           DISPLAY "Entro al proceso"
           .
       2000-PROCESO-EXIT.
           EXIT.
       3000-FIN.
           DISPLAY "Entro al fin"
           .
       3000-FIN-EXIT.
           EXIT.
