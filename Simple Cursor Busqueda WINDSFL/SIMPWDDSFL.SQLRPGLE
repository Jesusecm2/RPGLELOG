**FREE

 Dcl-F smplwndsfl WORKSTN Sfile(SFL:RRN1) InfDS(fileinfo);
 //******************************************
 //************** KEY WORDS
 //******************************************
 Dcl-C F03        X'33';
 Dcl-C ENTER      X'F1';

 //**************END
  dcl-s Isel ind inz('0');
  Dcl-Ds PERSONAS ExtName('PERSONAS') Alias Qualified;
  End-Ds;
  dcl-s SEARCHLIKE char(30);
  Dcl-S RRN1          Zoned(4:0) Inz;

  Dcl-DS FILEINFO;
    FUNKEY         Char(1)    Pos(369);
  End-DS;


    EXSR INSUBFILE;
    EXSR MAINCURSOR;
    EXSR VIEWSUBFILE;

    *INLR=*ON;



  begsr SUBFILESEL;
    READC SFL;
    DOW NOT %EOF();
      IF CTLFLD = 1;
        DSPLY %concat(' ' : 'Su eleccion fue:' : FLD001 : *natural);
      ENDIF;
      READC SFL;
    ENDDO;
  endsr;


  BEGSR MAINCURSOR;
    EXSR OPENSIMPLECURSOR;
    EXSR BODYCURSOR;
  ENDSR;

  BEGSR INSUBFILE;
   *IN01=*ON;
   *IN02=*ON;
    EXSR CLEARSUBFILE;
  ENDSR;


  BEGSR CLEARSUBFILE;
  *IN05=*ON;
   WRITE WDWSUBFILE;
  *IN05=*OFF;
  ENDSR;

   BEGSR VIEWSUBFILE;

    DOW FUNKEY<>F03;
    IF RRN1=0;
    *IN01=*OFF;
    ENDIF;
    EXFMT WDWSUBFILE;
    IF FUNKEY = ENTER AND CSRFLD = 'SEARCH';
    EXSR INSUBFILE;
    EXSR MAINCURSOR;
    ENDIF;
    IF FUNKEY = ENTER AND CSRFLD <>'SEARCH';
      EXSR SUBFILESEL;
    ENDIF;
    ENDDO;
   ENDSR;


  BEGSR OPENSIMPLECURSOR;
    SEARCHLIKE = %TRIM(SEARCH)+'%';
    EXEC SQL
      DECLARE C1 CURSOR FOR
        SELECT * FROM PERSONAS
        WHERE NOMBRE LIKE TRIM(:SEARCHLIKE);
    EXEC SQL
      OPEN C1;
      RRN1=0;
  ENDSR;

  BEGSR BODYCURSOR;
    EXEC SQL
    FETCH NEXT FROM C1 INTO :PERSONAS;

    Dow SQLSTATE = '00000';
    RRN1+=1;

    EXSR MOVEFIELDS;
    WRITE SFL;
    EXEC SQL
    FETCH NEXT FROM C1 INTO :PERSONAS;
    ENDDO;
    SSUB = RRN1;
    IF RRN1>10;
    *IN06=*ON;
    ENDIF;
    EXEC SQL
      CLOSE C1;

  ENDSR;

  BEGSR MOVEFIELDS;
   FLD001=PERSONAS.NOMBRE;
  ENDSR;






