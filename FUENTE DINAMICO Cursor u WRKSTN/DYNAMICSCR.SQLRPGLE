**FREE

    Dcl-F PERCRUMDDS WORKSTN Sfile(VIEWSFL:Rrn)  InfDS(FILEINFO);

    Dcl-S Rrn          Zoned(4:0) Inz;



    Dcl-DS WkStnInd;
      ProcessSCF     Ind        Pos(21);
      ReprintScf     Ind        Pos(22);
      Error          Ind        Pos(25);
      PageDown       Ind        Pos(30);
      PageUp         Ind        Pos(31);
      SflEnd         Ind        Pos(40);
      SflBegin       Ind        Pos(41);
      NoRecord       Ind        Pos(60);
      SflDspCtl      Ind        Pos(85);
      SflClr         Ind        Pos(75);
      SflDsp         Ind        Pos(95);
    End-DS;

    Dcl-DS FILEINFO;
      FUNKEY         Char(1)    Pos(369);
    End-DS;

    Dcl-C F01        X'31';
    Dcl-C F02        X'32';
    Dcl-C F03        X'33';
    Dcl-C F04        X'34';
    Dcl-C F05        X'35';
    Dcl-C F06        X'36';
    Dcl-C F07        X'37';
    Dcl-C F08        X'38';
    Dcl-C F09        X'39';
    Dcl-C F10        X'3A';
    Dcl-C F11        X'3B';
    Dcl-C F12        X'3C';
    Dcl-C F13        X'B1';
    Dcl-C F14        X'B2';
    Dcl-C F15        X'B3';
    Dcl-C F16        X'B4';
    Dcl-C F17        X'B5';
    Dcl-C F18        X'B6';
    Dcl-C F19        X'B7';
    Dcl-C F20        X'B8';
    Dcl-C F21        X'B9';
    Dcl-C F22        X'BA';
    Dcl-C F24        X'BC';
    Dcl-C ENTER      X'F1';
    Dcl-C HELP       X'F3';
    Dcl-C PRINT      X'F6';

    Dcl-S Rrn          Zoned(4:0) Inz;
    dcl-s RELATIVE zoned(4:0);

    Dcl-DS WkStnInd;
      ProcessSCF     Ind        Pos(21);
      ReprintScf     Ind        Pos(22);
      Error          Ind        Pos(25);
      PageDown       Ind        Pos(30);
      PageUp         Ind        Pos(31);
      SflEnd         Ind        Pos(40);
      SflBegin       Ind        Pos(41);
      NoRecord       Ind        Pos(60);
      SflDspCtl      Ind        Pos(85);
      SflClr         Ind        Pos(75);
      SflDsp         Ind        Pos(95);
    End-DS;

    Dcl-DS FILEINFO;
      FUNKEY         Char(1)    Pos(369);
    End-DS;
    Dcl-Ds PERSONAS ExtName('PERSONAS') Alias Qualified;
    End-Ds;

    EXEC SQL
      DECLARE C1 DYNAMIC SCROLL CURSOR FOR
        SELECT * FROM PERSONAS;
    EXEC SQL
      OPEN C1;

    EXEC SQL
      FETCH NEXT FROM C1 INTO :PERSONAS;

    Dow SQLSTATE = '00000';

      EXEC SQL
          FETCH NEXT FROM C1 INTO :PERSONAS;
    ENDDO;

    EXEC SQL
      CLOSE C1;


      BEGSR FETCHFIRST;
        EXEC SQL FETCH FIRST FROM PERC1 INTO :PERSONAS;
        *IN06=*OFF;
      ENDSR;

      //*********************************************************************
      //NEXT: obtiene la siguiente fila
      //*********************************************************************
      BEGSR FETCHNEXT;
        EXEC SQL FETCH NEXT FROM PERC1 INTO : PERSONAS;
      ENDSR;

      //*********************************************************************
      //RELATIVE: Obtiene el registro relativo desde el registro anterior +-
      //*********************************************************************
      BEGSR FETCHRELATIVE;
        EXEC SQL FETCH RELATIVE :REL PERC1 INTO :PERSONAS;
      ENDSR;

      //*********************************************************************
      //PRIOR: Obtiene el registro anterior
      //*********************************************************************
      BEGSR FETCHPRIOR;
        EXEC SQL FETCH PRIOR PERC1 INTO :PERSONAS;
      ENDSR;
      //**********************************************************************
      //LAST: Obtiene el ultimo registro de la fila
      //**********************************************************************
      begsr FETCHLAST;
        EXEC SQL FETCH LAST PERC1 INTO :PERSONAS;
      ENDSR;

