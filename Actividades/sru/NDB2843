       IDENTIFICATION DIVISION.
       PROGRAM-ID. NDB2843.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OUTFILE    ASSIGN  TO OUTFILE
                             FILE STATUS IS WS-OUTFILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  OUTFILE
            RECORDING MODE IS F
            BLOCK CONTAINS 0 RECORDS
            RECORD CONTAINS  87 CHARACTERS.
       01  REG-OUTFILE.
           COPY NDB2008.


       WORKING-STORAGE SECTION.
       01 WS-OUTFILE-STATUS PIC X(02).

       01 WS-VARIABLES.
           05 WS-CONTADOR          PIC 9(02) VALUE 0.
           05 WS-FILE-READ         PIC 9(02).
           05 WS-JOB               PIC X(08).
           05 WS-TOTAL-SALARY      PIC S9(7)V9(2) USAGE COMP-3.
           05 WS-PROMEDIO          PIC S9(7)V9(2) USAGE COMP-3.
           05 WS-PROMEDIO-RF       PIC $.$$$.$$9,99.
       01 WS-HEADER.
           10 HDR1           PIC X(40).
           10 HDR2         PIC X(44).
       01 WS-FOOTER.
           10 FTR1         PIC X(54) VALUE SPACES.
           10 FTR2         PIC X(9).
           10 FTR3         PIC $.$$$.$$9,99.





      ******************************************************************
      *                      SQL SECTION                               *
      ******************************************************************

           EXEC SQL INCLUDE SQLCA END-EXEC.

           EXEC SQL INCLUDE NEGEMP2 END-EXEC.


      ******************************************************************
      *                      PROCEDURE                                 *
      ******************************************************************

       PROCEDURE DIVISION.

           PERFORM 1000-INICIO
              THRU 1000-INICIO-EXIT

           PERFORM 2000-PROCESO
              THRU 2000-PROCESO-EXIT

           PERFORM 3000-FINAL

           .

       1000-INICIO.
           OPEN OUTPUT OUTFILE

           EVALUATE WS-OUTFILE-STATUS
               WHEN "00"
                  CONTINUE
               WHEN "10"
                  DISPLAY "EL ARCHIVO ESTA VACIO"
               WHEN OTHER
                  DISPLAY "EL ERROR ES: " WS-OUTFILE-STATUS
           END-EVALUATE

           MOVE ZEROS TO WS-CONTADOR
           MOVE 'CLERK' TO WS-JOB
           MOVE 0 TO WS-TOTAL-SALARY
           .

       1000-INICIO-EXIT.
           EXIT.


       2000-PROCESO.
           EXEC SQL
           DECLARE CUR-EMP CURSOR FOR
              SELECT EMPNO,
                     FIRSTNME,
                     LASTNAME,
                     WORKDEPT,
                     PHONENO,
                     BIRTHDATE,
                     JOB,
                     SALARY,
                     BONUS
                FROM NEOSB43.EMP
                WHERE JOB = :WS-JOB
           END-EXEC

           EXEC SQL OPEN CUR-EMP END-EXEC.

           PERFORM 2200-HEADER
               THRU 2200-HEADER-EXIT

           PERFORM 2100-LECTURA
               THRU 2100-LECTURA-EXIT
               UNTIL SQLCODE IS EQUAL TO 100

           .
       2000-PROCESO-EXIT.
           EXIT.

       2100-LECTURA.
           EXEC SQL
               FETCH CUR-EMP
               INTO :DCLEMP-EMPNO,
                    :DCLEMP-FIRSTNME,
                    :DCLEMP-LASTNAME,
                    :DCLEMP-WORKDEPT,
                    :DCLEMP-PHONENO,
                    :DCLEMP-BIRTHDATE,
                    :DCLEMP-JOB,
                    :DCLEMP-SALARY,
                    :DCLEMP-BONUS
           END-EXEC.


           EVALUATE SQLCODE
                  WHEN ZEROES
                      ADD 1 TO WS-CONTADOR
                      ADD DCLEMP-SALARY TO WS-TOTAL-SALARY
                      PERFORM 2300-MOVE-Y-WRITE
                           THRU 2300-MOVE-Y-WRITE-EXIT
                  WHEN +100
                       PERFORM 3000-FINAL
                  WHEN -305
                      ADD 1 TO WS-CONTADOR
                      ADD DCLEMP-SALARY TO WS-TOTAL-SALARY
                      PERFORM 2300-MOVE-Y-WRITE
                           THRU 2300-MOVE-Y-WRITE-EXIT

                  WHEN OTHER
                      DISPLAY "HUBO UN ERROR.... SQLCODE: " SQLCODE
                      PERFORM 3000-FINAL
           END-EVALUATE
           .
       2100-LECTURA-EXIT.
           EXIT.

       2200-HEADER.
           MOVE 'EMPNO |FIRSTNAME   |LASTNAME       |DPT|' TO HDR1
           MOVE 'PHNE|JOB     |BIRTHDATE |SALARY       |BONUS' TO HDR2


           WRITE REG-OUTFILE FROM WS-HEADER
                
           
           .
       2200-HEADER-EXIT.
           EXIT.

       2400-FOOTER.
           MOVE 'PROMEDIO:' TO FTR2
           MOVE WS-PROMEDIO-RF TO FTR3
           WRITE REG-OUTFILE FROM WS-FOOTER
           .
       2400-FOOTER-EXIT.
           EXIT.
           
       2300-MOVE-Y-WRITE.
           MOVE DCLEMP-EMPNO TO NDB-EMPNO
           MOVE DCLEMP-FIRSTNME TO NDB-FIRSTNME
           MOVE DCLEMP-LASTNAME TO NDB-LASTNAME
           MOVE DCLEMP-WORKDEPT TO NDB-WORKDEPT
           MOVE DCLEMP-PHONENO TO NDB-PHONENO
           MOVE DCLEMP-BIRTHDATE TO NDB-BIRTHDATE
           MOVE DCLEMP-JOB TO NDB-JOB
           MOVE DCLEMP-SALARY IN DCLEMP TO NDB-SALARY
           MOVE DCLEMP-BONUS IN DCLEMP TO NDB-BONUS
           WRITE REG-OUTFILE.
       2300-MOVE-Y-WRITE-EXIT.
           EXIT.
       3000-FINAL.
           EXEC SQL
               CLOSE CUR-DEPT
           END-EXEC.
           DIVIDE WS-TOTAL-SALARY BY WS-CONTADOR GIVING WS-PROMEDIO
           MOVE WS-PROMEDIO TO WS-PROMEDIO-RF
           PERFORM 2400-FOOTER
               THRU 2400-FOOTER-EXIT
           .
           STOP RUN.