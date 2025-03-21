
**FREE
       CTL-OPT OPTION(*SRCSTMT : *NODEBUGIO) DatFmt( *ISO );
       Dcl-Ds PERSONAS ExtName('PERSONAS') Alias Qualified;
       End-Ds;


       DCL-S GENDERS CHAR(1);
       DCL-S VALID ZONED(1:0) INZ(0);
       DCL-S DATESAVE DATE;
       DCL-DS DATECHARDS;
        DAYC CHAR (2);
        MOTC CHAR (2);
        YEAC CHAR (4);
       END-DS;
       DCL-S LIKESQL CHAR(30);
       DCL-S  IN20              IND         INZ('0');
       DCL-S  IN21              IND         INZ('0');
       dcl-s completefield char(25) inz('Debes completar el campo ');
       dcl-s DATESAVEC char(10);
       DCL-F PERCRUDDDS WORKSTN SFILE(VIEWSFL:RRN1) INFDS(INFDATA);

       DCL-S RRN1 ZONED(7:0);
       DCL-C ENTER  CONST(X'F1');
       DCL-C F3   CONST(X'33');
       DCL-C F7   CONST(X'37');
       DCL-C AVPAG    CONST(X'F5');
       DCL-C REPAG       CONST(X'F4');
       DCL-DS INFDATA;
       inputkey             CHAR(1) POS(369);
       END-DS;

      Exec Sql Set Option Commit = *None, NamIng = *Sys,
           Datfmt = *ISO, CloSqlCsr = *endmod,DLYPRP=*YES;
     DOW inputkey<> F7 and OPCBTN <> 03;

       EXSR MAINDSPF;
       select;
         when (OPCBTN=1);
              EXSR SFLMAIN;
         when (OPCBTN=2);
              CLEAR PERSONFORM;
              *IN80=*OFF;
              EXSR SAVEDSPF;
         when (OPCBTN=3);
         when (OPCBTN=4);
         other;
           // handle other conditions
       endsl;

     ENDDO;

       *INLR=*ON;

  BEGSR SFLMAIN;
      EXSR INSFL;
      EXSR INSQL;
      EXSR FIRSTREG;
      EXSR REGFILE;
      EXSR DISPSFL;
    DOW inputkey <> F3;
      IN20='0';
      IN21='0';
      exsr SELEC;
      IF inputkey = AVPAG;
        EXSR SUBAVPAG;
        EXSR DISPSFL;
        ITER;
      ENDIF;
      IF inputkey = REPAG;
        EXSR SUBREPAG;
        EXSR DISPSFL;
        ITER;
      ENDIF;
      IF inputkey = ENTER;
      EXSR CLOSESQL;
      EXSR CLEARSFL;
      EXSR INSFL;
      EXSR INSQL;
      EXSR FIRSTREG;
      EXSR REGFILE;
      EXSR DISPSFL;
      ITER;
      ENDIF;
      //IF inputkey <> ENTER and inputkey<>repag and
      //inputkey <>avpag AND INPUTKEY <> F3;
      EXSR CLOSESQL;
      EXSR CLEARSFL;
      EXSR INSFL;
      EXSR INSQL;
      EXSR FIRSTREG;
      EXSR REGFILE;
      EXSR DISPSFL;
      //ENDIF;
      ENDDO;
    EXSR CLOSESQL;
  ENDSR;

    BEGSR SELEC;

    READC VIEWSFL;
    DOW NOT %EOF();
      IF FOPC <> ' ';
            IDHID = SFLID;
            NAMEP = SFLNAME;
            SURNAP = SFLSNAME;
            LOCATP = SFLLOCA;
            DAYC  = %subst(SFLDATE :9 :2 );
            DAYP = %DEC(dayc:2:0);
            MOTC = %SUBST(SFLDATE :6:2);
            MESP = %DEC(MOTC:5:2);
            YEAC = %SUBST(SFLDATE:1:4);
            AGEP = %DEC(YEAC:4:0);
            IF SFLSEX = 'M';
             GENDERP = 1;
            ENDIF;
            IF SFLSEX='F';
             GENDERP = 2;
            ENDIF;
        select;
          when (FOPC = '1');
            *IN80=*OFF;
            EXSR SAVEDSPF;
          when (FOPC = '2');
            *IN80=*ON;
            EXSR SAVEDSPF;
          other;
            // handle other conditions
        endsl;
        ENDIF;
      READC VIEWSFL;
    ENDDO;

    ENDSR;
   BEGSR MAINDSPF;
      BTNINFO = 'F7=Salir';
       WRITE BLACKREC;
       WRITE HEADER;
       WRITE FOOTER;
       EXFMT MAIN;
   ENDSR;

   BEGSR INSFL;
   //************LIMPIAMOS EL SFL
    *IN01=*ON;
    *IN02=*ON;
    *IN05=*ON;
    //WRITE WDW1;
    //WRITE FOOT;
    WRITE VIEWSFLCTL;
    //*IN03 = *ON;
    *IN05 = *OFF;
       //*IN01=*ON;
       //*IN02=*ON;
       //*IN03=*ON;
       //EXSR CLEARSFL;
       //WRITE HEADER;
       //WRITE VIEWSFLCTL;
   ENDSR;

    BEGSR FIRSTREG;
    *IN06 = *OFF;
      RRN1 = 0;
    EXEC SQL FETCH NEXT FROM PERC1 INTO :PERSONAS;
    ENDSR;

    BEGSR CLEARSFL;
      *IN05 = *ON;
      write VIEWSFLCTL;
      *IN05 = *OFF;
    ENDSR;

   BEGSR SUBAVPAG;

    IF *IN06 = *OFF;
    EXSR CLEARSFL;
    EXSR FetchFirstReg;
    EXSR REGFILE;
    ENDIF;


   ENDSR;

   BEGSR SUBREPAG;
      IF NOT IN20;
        EXSR FetchRegKey;
      IF NOT IN21;
        EXSR CLEARSFL;
        EXSR REGFILE;
      ENDIF;
      ENDIF;
    ENDSR;

   BEGSR DISPSFL;
   %SUBARR(*IN:01:02) = *ON;
    BTNINFO = 'F3=Volver';
    IF MSGERROR <> *BLANKS;
    EXSR EXERR;
    ELSE;
    EXSR EXERRC;
    ENDIF;
    BTNINFO = '1-Actualizar';
    WRITE FOOTER;
    EXFMT VIEWSFLCTL;
    CLEAR VIEWSFL;
    //CLEAR VIEWSFLCTL;
   ENDSR;

  BEGSR FETCHREGKEY;
    IN20 = *ON;
    IF RRN1 <> 0;
      RRN1 += 05;
    ELSE;
      RRN1 = 06;
    ENDIF;

    RRN1 *= -1;
    EXEC SQL FETCH RELATIVE :RRN1 FROM PERC1 INTO :PERSONAS ;

    IF SQLCOD = 100;
      IN21 = *ON;
      RRN1 = 0;
      EXEC SQL FETCH FIRST FROM PERC1 INTO :PERSONAS ;
      EXEC SQL FETCH RELATIVE +6 FROM PERC1 INTO :PERSONAS;
    ELSE;
      IN21 = *OFF;
    ENDIF;
    RRN1=0;
  ENDSR;


   BEGSR SAVEDSPF;
       ACCEPT = 0;
       DOW ACCEPT<>2;

              WRITE BLACKREC;
              BTNINFO = 'F3=Atrás';
              WRITE FOOTER;
              WRITE HEADER;
              EXFMT PERSONFORM;
              EXSR EXERRC;
              IF ACCEPT=1;
                MSGERROR = *BLANKS;
                MONITOR;
                DAYC = %EDITC(DAYP:'X');
                MOTC = %EDITC(MESP:'X');
                YEAC =  %EDITC(AGEP:'X');
                DATESAVEC = YEAC+'-'+MOTC+'-'+DAYC;
                DATESAVE = %date(DATESAVEC:*ISO);
                ON-ERROR;
                MSGERROR = 'No se pudo utilizar esta fecha';
                VALID = 1;
                ENDMON;


                IF GENDERP = 1;
                    GENDERS = 'M';
                    ELSE;
                    GENDERS = 'F';
                ENDIF;
                IF *IN80=*ON;
                leave;
                ENDIF;
                //****************VALIDAMOS
                IF NAMEP = *BLANKS OR SURNAP=*BLANKS OR LOCATP=*BLANKS;
                IF LOCATP = *BLANKS;
                MSGERROR = completefield+'Dirección';
                ENDIF;
                IF GENDERP=0;
                MSGERROR = completefield+'Sexo';
                ENDIF;
                IF SURNAP = *BLANKS;
                MSGERROR = completefield+'Apellido';
                ENDIF;
                IF NAMEP = *BLANKS;
                MSGERROR = completefield+'Nombre';
                ENDIF;
                VALID = 1;
                ENDIF;

                IF VALID = 1;
                EXSR EXERR;
                ITER;
                ENDIF;

                IF IDHID <> 0;
                EXEC SQL
                UPDATE PERSONAS SET NOMBRE=:NAMEP,APELLIDO=:SURNAP,
                FECHAN=:DATESAVE,
                SEXO=:GENDERS,DIRECCION=:LOCATP WHERE IDPER = :IDHID;
                ELSE;
                EXEC SQL
                INSERT INTO PERSONAS(NOMBRE,APELLIDO,FECHAN,SEXO,DIRECCION)
                VALUES
                (:NAMEP,:SURNAP,:DATESAVE,:GENDERS,:LOCATP);
                ENDIF;
                IF SQLCODE = 0;
                *IN40 = *OFF;
                WINMSG = 'Su registro o actualización ha sido +
                          completada';
                EXFMT WINDOWMSG;
                IF IDHID <>0;
                LEAVE;
                ENDIF;
                CLEAR PERSONFORM;
                ENDIF;

              ENDIF;

       ENDDO;
   ENDSR;

   BEGSR EXERR;
    *IN60=*on;
    *IN61=*OFF;
   ENDSR;

      BEGSR EXERRC;
    *IN60=*ON;
    *IN61=*ON;
    MSGERROR=*BLANKS;
   ENDSR;


    begsr MOVEFIELD;
      //CLEAR VIEWSFL;
      FOPC = ' ';
      SFLID = PERSONAS.IDPER;
      SFLNAME = PERSONAS.NOMBRE;
      SFLSNAME= PERSONAS.APELLIDO;
      SFLSEX = PERSONAS.SEXO;
      SFLDATE = %char(PERSONAS.FECHAN:*ISO);
      SFLLOCA = PERSONAS.DIRECCION;
    endsr;

    BEGSR FetchFirstReg;
      *IN06 = *OFF;
      RRN1 = 0;
      EXSR FETCHSQL;
    ENDSR;


      BEGSR INSQL;

       LIKESQL = %TRIM(BUSCAR)+'%';
       EXEC SQL
       DECLARE PERC1 DYNAMIC SCROLL CURSOR FOR
       SELECT * FROM PERSONAS WHERE NOMBRE LIKE TRIM(:LIKESQL);



       EXEC SQL
       OPEN PERC1;
       RRN1 = 0;
       *IN06=*OFF;
      ENDSR;


      //************************************BEGSR REG FILE
       BEGSR REGFILE;
       //EXSR FETCHSQL;
       DOW SQLCODE=0;

        RRN1+=1;
        EXSR MOVEFIELD;
        WRITE VIEWSFL;
        IF RRN1 >5;
            //*IN06=*ON;
            LEAVE;
        ENDIF;
        EXSR FETCHSQL;
        ENDDO;
        //*****************VALIDAMOS SER EL ULTIMO REG
        EXSR FETCHSQL;
        IF RRN1 = 0 AND SQLCODE = 100;
        //WRITE VIEWSFL;
        RRN1+=1;
        WRITE VIEWSFL;
        ENDIF;
        //*IN01=*OFF;
        //*IN03=*OFF;
        IF SQLCODE=100;
        RRN1+=1;

        *IN06=*ON;
        ELSE;
        *IN06=*OFF;
          EXEC SQL FETCH PRIOR FROM PERC1 INTO :PERSONAS ;
        ENDIF;
        //*******FALTA VALIDAR QUE EL ARCHIVO ESTE VACÍO O REGISTROS
       ENDSR;
      //*********************************ENDSR

    //******************************FETHCSQL
   BEGSR FETCHSQL;
       EXEC SQL
       FETCH NEXT FROM PERC1 INTO :PERSONAS;
   ENDSR;

  //*******************************CIERRA CURSOR
   BEGSR CLOSESQL;
       EXEC SQL
       CLOSE PERC1;
   ENDSR;
