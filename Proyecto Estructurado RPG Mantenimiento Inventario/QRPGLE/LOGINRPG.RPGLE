**free

    CTL-OPT BNDDIR('JESUSECM21/INVSERVICE');
    Dcl-F LOGIN WORKSTN InfDS(fileinfo);
    dcl-s qt char(1) inz('''');
    dcl-s sqlint int(10) ;
    dcl-s sqllng char(2);
    dcl-s START INT(10);
    dcl-s textP char(200);
    dcl-s IDUSR int(5);
    dcl-s PREGUNTA int(5);
    dcl-ds USER ExtName('USUARIOS') Qualified;
    end-ds;
    dcl-ds REGSEC ExtName('SECUUSER') Qualified;
    end-ds;
    dcl-s flag int(5);

    //************************************ALEATORIO
    dcl-pr CEERAN0 extPROC('CEERAN0');
        *n INT(10);
        *n FLOAT(8);
        *n CHAR(12) OPTIONS(*omit);
    end-pr;
    dcl-s result int(5);
    dcl-s RANGE int(5);
    dcl-s RANGEMAX int(5) INZ(3);
    dcl-s RANGEMIN int(5) INZ(1);
    dcl-s SEEDIN int(10);
    dcl-s SEEDOU FLOAT(8);
    dcl-s FEEDBACK char(12);
    //************************************FIN ALEATORIO
    Dcl-S cmd VarChar(3000);
    Dcl-C F03        X'33';
    Dcl-DS FILEINFO;
        FUNKEY         Char(1)    Pos(369);
    End-DS;
        dcl-pr centrartxt extproc('CNTXT');
            *n char(200);
            *n int(10);
        end-pr;
        dcl-pr VALIDSECUR extproc('VALIDSECUR');
         *N LIKE(REGSEC);
         *N INT(5);
        end-pr;

    dcl-pr CHANGEPASSWORD extproc('CHANGEPASSWORD');
        *n LIKE(USER);
    end-pr;

    dcl-pr getMessage extproc('GETMESSAGE') ;
        *N CHAR(200);
        *n int(10);
        *n char(2);
    end-pr;

    dcl-pr GETUSERPNMR extproc('GETUSERPNMR') ;
        *n LIKE(USER);
        *N int(5);
    end-pr;



    dcl-pr invverlog extpgm('invverlog');
        *N LIKE(USER);
    end-pr;

    DCL-PR QCMDEXC EXTPGM('QCMDEXC');
        *n char(3000) options(*varsize) const;
        *n packed(15:5) const;
        dbcs char(3) const options(*nopass);
    END-PR;

    dcl-pr GETSECUR extproc('GETSECUR');
        *n like(user);
        *n like(REGSEC);
    end-pr;



    //qcmdexc (cmd : %len(CMD));
    dcl-s cmd1 char(50);
    //cmd = 'CALL PGM(JESUSECM21/INVVERLOG) PARM('+USER+')';
    //QSYS/SBMJOB CMD(CALL PGM(JESUSECM21/INVVERLOG))


    DOW FUNKEY <> F03 AND OPCBTN<>3;
    CLEAR LOGINWDW;
    exsr INICIALIZAR;
    write header;
    write LOGINWDWB;
    write LOGINWDW;
    exfmt LOGINWDW;

    IF OPCBTN = 2;
        EXSR RECUPERARCLAVE;
    ENDIF;

    IF OPCBTN = 1;
        USER.USERNAME=INPUSER;
        USER.PASS=INPASS;

        GETUSERPNMR(USER:flag);
        IF FLAG = 1;
            DSPLY 'ENTRAR';
            IDUSR=USER.IDUSR;
            cmd =
'QSYS/SBMJOB CMD(CALL PGM(JESUSECM21/INVVERLOG)'
+' PARM('+qt+%EDITC(IDUSR:'X') +qt+'))';
        cmd1 ='PARM('+qt+%EDITC(IDUSR:'X') +qt+'))';
            dsply cmd1;
                 monitor;
                 qcmdexc (cmd : %len(CMD));
                 on-error;
                 dsply 'error';
                 endmon;
            ELSE;
            IF USER.USERNAME=*BLANKS;
            MSGTEXT = 'US/CON INCORRECTA';
            ENDIF;
            IF USER.BLOQUEADO='1';
                MSGTEXT = 'USUARIO BLOQUEADO';
            ENDIF;
            IF USER.LOGGER='1';
            MSGTEXT = 'USUARIO ACTIVO';
            ENDIF;
        ENDIF;
    ENDIF;
    ENDDO;
    *inlr=*on;

      BEGSR INICIALIZAR;
        //********SE OBTIENE LOS TEXTOS***************/
        sqllng='ES';
        sqlint=1;
        getMessage(textP:sqlint:sqllng);
        TITLEWDW = textP;
        //********
        sqlint=2;
        getMessage(textP:sqlint:sqllng);
        START=15;
        centrartxt(textP:START);
        TITLETXT = textP;
        //*********
        START=19;
        sqlint=3;
        getMessage(textP:sqlint:sqllng);
        centrartxt(textP:START);
        OUUSER = textP;

        sqlint=4;
        getMessage(textP:sqlint:sqllng);
        centrartxt(textP:START);
        OUPASS = textP;

      ENDSR;


    BEGSR RECUPERARCLAVE;
    CLEAR RECUPWDW;
    DOW OPCBTN <> 2;
        //Ttitulo
        sqlint=9;
        getMessage(textP:sqlint:sqllng);
        START=15;
        centrartxt(textP:START);
        TITLETXT = textP;
        //EMAIL
        sqlint=8;
        getMessage(textP:sqlint:sqllng);
        START=19;
        centrartxt(textP:START);
        OUEMAIL = textP;
        //user
        START=19;
        sqlint=3;
        getMessage(textP:sqlint:sqllng);
        centrartxt(textP:START);
        OUUSER = textP;
       WRITE HEADER;
       WRITE LOGINWDWB;
       WRITE RECUPWDW;
       EXFMT RECUPWDW;

       IF OPCBTN = 1;
       clear USER;
       USER.EMAIL = %TRIM(INEMAIL);
       USER.USERNAME = %TRIM(INPUSER);
        GETSECUR(USER:REGSEC);
        IF REGSEC.PGN1 <> *BLANKS ;
            exsr viewpreg;
        ELSE;
        MSGTEXT = 'NO ENCONTRADO';
        endif;
        IF USER.BLOQUEADO='1';
        MSGTEXT = 'USUARIO BLOQUEADO';
        ENDIF;
       ENDIF;
    ENDDO;
    ENDSR;


    begsr GETPREG;
     DOW PREGUNTA = result;
     range = (RANGEMAX - RANGEMIN) + 1;
     CEERAN0( SEEDIN : SEEDOU : *omit );
     result = %int(SEEDOU * range) + RANGEMIN;
     ENDDO;
     pregunta=result;
    endsr;

    begsr viewpreg;
        //********Primera pregunta
        CLEAR PREGWDW;
        sqlint=10;
        getMessage(textP:sqlint:sqllng);
        START=15;
        centrartxt(textP:START);
        TITLETXT = textP;
        exsr getpreg;

       select;
         when (pregunta=1);
            OUPREG=REGSEC.PGN1;
         WHEN (pregunta=2);
            OUPREG = REGSEC.PGN2;
         when (pregunta=3);
            OUPREG = REGSEC.PGN3;
       endsl;
       EXSR GETPREG;
        select;
        when (pregunta=1);
          OUPREG1 = REGSEC.PGN1;
        WHEN (pregunta=2);
           OUPREG1 = REGSEC.PGN2;
        when (pregunta=3);
          OUPREG1 = REGSEC.PGN3;
       endsl;


       WRITE PREGWDW;
       EXFMT PREGWDW;
       EXSR CONFIGPREG;
        VALIDSECUR(REGSEC:flag);
        if flag=1;
            EXSR changepass;
        endif;
    endsr;

    begsr changepass;
    CLEAR CHANGWDW;
    FLAG = 0;
        sqlint=10;
        getMessage(textP:sqlint:sqllng);
        START=15;
        centrartxt(textP:START);
        TITLETXT = textP;
        sqlint=11;
        getMessage(textP:sqlint:sqllng);
        START=19;
        centrartxt(textP:START);
        OUPASS = textP;
        sqlint=12;
        getMessage(textP:sqlint:sqllng);
        centrartxt(textP:START);
        OUPASS1 = textP;
    DOW flag = 0 AND OPCBTN<>2;

        WRITE CHANGWDW;
        EXFMT CHANGWDW;
        IF INPASS=INPASS1;
            IF %len(INPASS)>5;
            USER.PASS=INPASS;
            CHANGEPASSWORD(USER);
            flag = 1;
            MSGTEXT= *BLANKS;
            CLEAR USER;
            ELSE;
            MSGTEXT = 'DEBE SER MAYOR A 5';
            ENDIF;
            ELSE;
            MSGTEXT = 'CONTRASENA NO IGUAL';
        ENDIF;
    ENDDO;
    endsr;

    BEGSR CONFIGPREG;
        IF OUPREG = REGSEC.PGN1;
        REGSEC.RPN1=INPPREG;
            IF OUPREG1 = REGSEC.PGN2;
                REGSEC.RPN2=INPREG1;
                REGSEC.PGN3=*BLANKS;
            ELSE;
                REGSEC.RPN3=INPREG1;
                REGSEC.PGN2=*BLANKS;
            ENDIF;
        ENDIF;

        IF OUPREG = REGSEC.PGN2;
        REGSEC.RPN2=INPPREG;
            IF OUPREG1 = REGSEC.PGN1;
                REGSEC.RPN1=INPREG1;
                REGSEC.PGN3=*BLANKS;
            ELSE;
                REGSEC.RPN3=INPREG1;
                REGSEC.PGN1=*BLANKS;
            ENDIF;
        ENDIF;
        IF OUPREG = REGSEC.PGN3;
        REGSEC.RPN3=INPPREG;
            IF OUPREG1 = REGSEC.PGN1;
                REGSEC.RPN1=INPREG1;
                REGSEC.PGN2=*BLANKS;
            ELSE;
                REGSEC.RPN2=INPREG1;
                REGSEC.PGN1=*BLANKS;
            ENDIF;
        ENDIF;

    ENDSR;
