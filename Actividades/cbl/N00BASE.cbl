       IDENTIFICATION DIVISION. 
       PROGRAM-ID. N00BASE.
       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL. 
           SELECT INFILE  ASSIGN TO INFILED
                          FILE STATUS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD INFILE
            RECORDING MODE IS F 
            BLOCK CONTAINS 0 RECORDS 
            RECORD CONTAINS 90 CHARACTERS.
       01 REG-INFILE.
           05  OUT-DEPTNO        PIC X(03).          
           05  OUT-DEPTNAME      PIC X(36).              
           05  OUT-MGRNO         PIC X(06).            
           05  OUT-ADMRDEPT      PIC X(03).                
           05  OUT-LOCATION      PIC X(16).
           05  FILLER            PIC X(26).
       WORKING-STORAGE SECTION. 
       01 WS-VARIABLES.
           05 WS-NUMERO PIC 9.
           05 WS-MAXIMO PIC 9 VALUE 5.
           05 WS-CANT-DIS PIC 9.

       01 WS-CONTADOR PIC 9(2) VALUE 0.
       01 WS-CONTADOR2 PIC 9(2) VALUE 0.
       01 WS-FILE-STATUS.
           05 FS-OKEI  PIC XX VALUE "00".
           05 FS-EOF   PIC XX VALUE "10".
          
       PROCEDURE DIVISION.
           PERFORM 1000-INICIO
           THRU 1000-INICIO-EXIT

           PERFORM 2000-PROCESO
           THRU 2000-PROCESO-EXIT 
           UNTIL WS-FILE-STATUS = FS-EOF 

           PERFORM 3000-FIN
           THRU 3000-FIN-EXIT
           STOP RUN.

       1000-INICIO.
           DISPLAY "Entro al inicio"
           MOVE ZERO TO WS-NUMERO 
           INITIALIZE WS-NUMERO 
           MOVE ZERO TO WS-CANT-DIS 

           MOVE ZERO TO WS-CONTADOR
           MOVE ZERO TO WS-CONTADOR2

           OPEN INPUT INFILE
           EVALUATE WS-FILE-STATUS
               WHEN "00" 
                  DISPLAY "Se abrio correctamente"
               WHEN "10"
                  DISPLAY "El archivo esta vacio"
               WHEN OTHER 
                  DISPLAY "El error es: " WS-FILE-STATUS 
           END-EVALUATE 

           .
       1000-INICIO-EXIT.
           EXIT.
       2000-PROCESO.
           DISPLAY "Entro al proceso"
           PERFORM 2100-LECTURA
           THRU 2100-LECTURA-EXIT
           ADD 1 TO WS-CONTADOR2
           DISPLAY 'Datos de departamento:'
           DISPLAY OUT-DEPTNO
           DISPLAY OUT-DEPTNAME
           DISPLAY '-----------------------'
           .
       2000-PROCESO-EXIT.
           EXIT.
       
       2100-LECTURA.
           READ INFILE INTO REG-INFILE
           AT END
              MOVE "10" to WS-FILE-STATUS
           ADD 1 TO WS-CONTADOR
           .
       2100-LECTURA-EXIT.
           EXIT.
       
       3000-FIN.
           CLOSE INFILE
           DISPLAY "Entro al fin"
           .
       3000-FIN-EXIT.
           EXIT.
