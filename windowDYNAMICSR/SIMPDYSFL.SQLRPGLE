**FREE

    Dcl-F smplwndsfl WORKSTN Sfile(SFL:Rrn) InfDS(fileinfo);

    Dcl-S Rrn          Zoned(4:0) Inz;
    DCL-S  SUBIR              IND         INZ('0');
    DCL-S  BAJAR              IND         INZ('0');
    Dcl-C ENTER      X'F1';
    Dcl-C F03        X'33';
    DCL-C REGC    CONST(X'F4');
    DCL-C AVC       CONST(X'F5');
    Dcl-DS FILEINFO;
      FUNKEY         Char(1)    Pos(369);
    End-DS;
    dcl-s find char(32);
    dcl-ds PERSONAS ExtName('PERSONAS') Qualified;
    end-ds;



    //**********************CICLO PRINCIPAL
    EXSR INITSFL;
    EXSR ABRIRCURSOR;
    EXSR BODYCURSOR;
    DOW FUNKEY <> F03;


     EXSR VIEWSFL;
     IF FUNKEY = AVC;
     EXSR AVPAG;
     ENDIF;
     IF FUNKEY = REGC;
     EXSR REPAG;
     ENDIF;
     IF FUNKEY = ENTER;
        EXSR CLRSFL;
        EXSR CERRARCURSOR;
        EXSR ABRIRCURSOR;
        EXSR BODYCURSOR;
     ENDIF;
    ENDDO;
    //**********************FIN CICLO PRINCIPAL
    *INLR=*ON;



    //**********************************************************
    //******************Rutinas de Pantalla*********************
    //**********************************************************
    BEGSR INITSFL;
        SSUB=6;
        MSG= 'LISTA';
       *IN01=*ON;
       *IN02=*ON;
       WRITE WINDW;
       EXSR CLRSFL;
    ENDSR;

    BEGSR CLRSFL;
        *IN05=*ON;
        WRITE WDWSUBFILE;
        *IN05=*OFF;
    ENDSR;

    BEGSR VIEWSFL;
     IF Rrn = 0;
     *IN01=*OFF;
     else;
     *IN01=*ON;
     ENDIF;
     *IN60=*ON;
     WRITE FOOTER;

     EXFMT WDWSUBFILE;
    ENDSR;

    //**********************************************************
    //******************Fin de Rutinas Pantalla*****************
    //**********************************************************

    //**********************************************************
    //******************Rutinas SQL*****************************
    //**********************************************************

    BEGSR ABRIRCURSOR;
        find =  %TRIM(SEARCH) + '%';
        EXEC SQL DECLARE C1 DYNAMIC SCROLL CURSOR FOR
         SELECT * FROM PERSONAS WHERE NOMBRE LIKE  trim(:find)
          ORDER BY IDPER;
        EXEC SQL OPEN C1;
        Rrn=0;
    ENDSR;
    BEGSR CERRARCURSOR;
        EXEC SQL CLOSE C1;
    ENDSR;

    BEGSR BODYCURSOR;
       //EXEC SQL FETCH NEXT FROM C1 INTO :PERSONAS;
        DOW SQLSTATE = '00000';
         IF RRN>5;
         *IN06=*OFF;
         BAJAR='1';
         LEAVE;
         ELSE;
         *IN06=*ON;
         BAJAR='0';
         ENDIF;
        EXEC SQL FETCH NEXT FROM C1 INTO :PERSONAS;
        IF SQLCODE=0;
        EXSR MOVERCAMPOS;
         Rrn+=1;
        WRITE SFL;
        ENDIF;
        ENDDO;
        IF SQLCODE = 100;
        BAJAR='0';
        MSG='FIN';
        ENDIF;
    ENDSR;

    BEGSR AVPAG;
        //******************colocamos el cursor paralelo a RRN
        IF BAJAr='1';
        SUBIR = '1';
        //EXEC SQL FETCH RELATIVE :RRN FROM C1 INTO :PERSONAS;
        RRN=0;
        EXSR CLRSFL;
        EXSR BODYCURSOR;
        ENDIF;
    ENDSR;

    BEGSR REPAG;
        IF SUBIR = '1';
            IF RRN <> 0;
                RRN += 7;
                ELSE;
                RRN = 6;
            ENDIF;
         //*****************recuperamos el cursor de forma negativa
            RRN*=-1;
            EXEC SQL FETCH RELATIVE :RRN FROM C1 INTO :PERSONAS ;
         //*****************SI DA ERROR NOS VAMOS AL PRIMER REGISTRO
            IF SQLCODE = 100;
                EXEC SQL FETCH BEFORE FROM C1;
                BAJAr='1';
                SUBIr='0';
                Rrn = 0;
                //EXEC SQL FETCH RELATIVE +6 FROM C1 INTO :PERSONAS;

                ELSE;
                SUBIR = '1';
            ENDIF;
            MSG= 'LISTA';
            RRN=0;
            EXSR CLRSFL;
            EXSR BODYCURSOR;
        ENDIF;
    ENDSR;

    BEGSR MOVERCAMPOS;
     FLD001=PERSONAS.NOMBRE;
    ENDSR;


