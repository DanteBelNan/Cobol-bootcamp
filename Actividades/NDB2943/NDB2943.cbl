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
            RECORD CONTAINS  120 CHARACTERS.
       01  REG-OUTFILE    PIC X(120).                                                 



       WORKING-STORAGE SECTION.
       01 WS-OUTFILE-STATUS PIC X(02).

       01 WS-VARIABLES.
           05 WS-CONTADOR          PIC 9(02) VALUE 0.
           05 WS-FILE-READ         PIC 9(02).
           05 WS-JOB               PIC X(08).
           05 WS-TOTAL-SALARY      PIC S9(7)V9(2) USAGE COMP-3.
           05 WS-TOTAL-SUMA-RF     PIC $.$$$.$$9,99.
       01  TOTAL.
           05 WS-TOTAL             PIC S9(7)V9(2) USAGE COMP-3.
           05 WS-TOTAL-SUMA        PIC S9(7)V9(2) USAGE COMP-3 VALUE 0.

       01 WS-HEADER.
           10 HDR1         PIC X(40).
           10 HDR2         PIC X(42).
           10 HDR3         PIC X(10).
       01 WS-FOOTER.
           10 FTR1         PIC X(41) VALUE SPACES.
           10 FTR2         PIC X(22).
           10 FTR3         PIC $.$$$.$$9,99.
       01 WS-BODY.
           10 BDY-EMPNO                  PIC X(6).
           10 BDY-PIPE1                  PIC X(1) VALUE '|'.
           10 BDY-FIRSTNME               PIC X(12).
           10 BDY-PIPE2                  PIC X(1) VALUE '|'.
           10 BDY-LASTNAME               PIC X(15).
           10 BDY-PIPE3                  PIC X(1) VALUE '|'.
           10 BDY-WORKDEPT               PIC X(3).
           10 BDY-PIPE4                  PIC X(1) VALUE '|'.
           10 BDY-PHONENO                PIC X(4).
           10 BDY-PIPE5                  PIC X(1) VALUE '|'.
           10 BDY-JOB                    PIC X(8).
           10 BDY-PIPE6                  PIC X(1) VALUE '|'.
           10 BDY-BIRTHDATE              PIC X(10).
           10 BDY-PIPE7                  PIC X(1) VALUE '|'.
           10 BDY-SALARY                 PIC $$$.$$9,99.
           10 BDY-PIPE8                  PIC X(1) VALUE '|'.
           10 BDY-BONUS                  PIC $$$.$$9,99.
           10 BDY-PIPE9                  PIC X(1) VALUE '|'.
           10 BDY-TOTAL-RF               PIC $$$.$$9,99.                




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
           MOVE 'PHNE|JOB     |BIRTHDATE |SALARY    |BONUS ' TO HDR2
           MOVE '    |TOTAL' TO HDR3


           WRITE REG-OUTFILE FROM WS-HEADER


           .
       2200-HEADER-EXIT.
           EXIT.

       2400-FOOTER.
           MOVE 'TOTAL BONUS + SALARIO:' TO FTR2
           MOVE WS-TOTAL-SUMA TO WS-TOTAL-SUMA-RF
           MOVE WS-TOTAL-SUMA-RF TO FTR3
           WRITE REG-OUTFILE FROM WS-FOOTER
           .
       2400-FOOTER-EXIT.
           EXIT.

       2300-MOVE-Y-WRITE.
           MOVE DCLEMP-EMPNO TO BDY-EMPNO
           MOVE DCLEMP-FIRSTNME TO BDY-FIRSTNME
           MOVE DCLEMP-LASTNAME TO BDY-LASTNAME
           MOVE DCLEMP-WORKDEPT TO BDY-WORKDEPT
           MOVE DCLEMP-PHONENO TO BDY-PHONENO
           MOVE DCLEMP-BIRTHDATE TO BDY-BIRTHDATE
           MOVE DCLEMP-JOB TO BDY-JOB
           MOVE DCLEMP-SALARY IN DCLEMP TO BDY-SALARY
           MOVE DCLEMP-BONUS IN DCLEMP TO BDY-BONUS
           COMPUTE WS-TOTAL = DCLEMP-SALARY + DCLEMP-BONUS
           MOVE WS-TOTAL IN TOTAL TO BDY-TOTAL-RF
           ADD WS-TOTAL TO WS-TOTAL-SUMA
           WRITE REG-OUTFILE FROM WS-BODY
      *    POR ALGUNA RAZON, NO ESCRIBE EL ULTIMO CAMPO SIN IMPORTAR
      *    QUE CAMPO SEA, NO LO ESCRIBE
           .
       2300-MOVE-Y-WRITE-EXIT.
           EXIT.
       3000-FINAL.
           EXEC SQL
               CLOSE CUR-DEPT
           END-EXEC.
           PERFORM 2400-FOOTER
               THRU 2400-FOOTER-EXIT
           .
           STOP RUN.





