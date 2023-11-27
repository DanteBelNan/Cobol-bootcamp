      IDENTIFICATION DIVISION.
      PROGRAM-ID. N02COND.
      DATA DIVISION.
          WORKING-STORAGE SECTION.
              01 numero PIC 9(2).
      PROCEDURE DIVISION.
          MOVE 50 TO numero.
          IF numero > 50
          DISPLAY "El número es mayor que 50"
          ELSE IF numero < 50
          DISPLAY "El número es menor que 50"
          ELSE
          DISPLAY "El número es igual a 50"
          END-IF.
      STOP RUN.
