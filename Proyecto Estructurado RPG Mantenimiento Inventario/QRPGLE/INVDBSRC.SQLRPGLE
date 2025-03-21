**FREE
    ctl-opt NOMAIN;

    dcl-ds USER ExtName('USUARIOS') Qualified;
    end-ds;
    dcl-ds REGUSER ExtName('SECUUSER') Qualified;
    end-ds;
    dcl-ds REGUSERC ExtName('SECUUSER') Qualified;
    end-ds;
    dcl-ds USERC ExtName('USUARIOS') Qualified;
    end-ds;



    dcl-proc GETUSERPNMR EXPORT;
     dcl-pi *n ;
        PUSER like(USER);
        SUCC int(5);
     end-pi;
        Exec Sql Set Option Commit = *None, NamIng = *Sys,
     Datfmt = *ISO, CloSqlCsr = *EndActGrp;
     SUCC = 0;
     USER = PUSER;
     CLEAR USERC;
     EXEC SQL SELECT * INTO :USERC FROM USUARIOS
     WHERE USERNAME= :USER.USERNAME LIMIT 1;

     IF USERC.USERNAME<>*BLANKS;
      IF USERC.LOGGER = '0';
         IF USERC.BLOQUEADO = '0';
            USERC.INTENTOS+=1;
            IF USERC.PASS = USER.PASS;
                USER = USERC;
                PUSER = USERC;
                EXEC SQL UPDATE USUARIOS SET LOGGER='1'
                ,ACTIVE='1',INTENTOS=0
                WHERE IDUSR = :USERC.IDUSR;
                IF SQLCODE = 0;
                SUCC=1;
                ENDIF;
            ELSE;
                IF USERC.INTENTOS<>3;
                EXEC SQL UPDATE USUARIOS SET INTENTOS=:USERC.INTENTOS
                WHERE IDUSR = :USERC.IDUSR;

                ELSE;
                EXEC SQL UPDATE USUARIOS SET BLOQUEADO='1'
                WHERE IDUSR = :USERC.IDUSR;
                ENDIF;
            ENDIF;
        ELSE;
        USER.BLOQUEADO = USERC.BLOQUEADO;
        PUSER = USER;
        ENDIF;
        ELSE;
        USER.LOGGER= '1';
        PUSER=USER;
     ENDIF;
     ELSE;
     PUSER = *BLANKS;
     ENDIF;
    end-proc;

    dcl-proc VALIDLOG  EXPORT;
        dcl-pi *n;
            PUSER LIKE(USER);
            logind zoned(1:0);
        end-pi;
        CLEAR USERC;
         USER = PUSER;
         EXEC SQL SELECT * INTO :USERC FROM USUARIOS
         WHERE USERNAME= :USER.USERNAME LIMIT 1;
         IF USERC.LOGGER='1';
         logind=0;
         ELSE;
         logind=1;
         ENDIF;


    end-proc;

    dcl-proc GETSECUR  EXPORT;
        dcl-pi *n;
            PUSER LIKE(USER);
            PREGUSER LIKE(REGUSER);
        end-pi;
         USER = PUSER;
        CLEAR USERC;
        EXEC SQL SELECT * INTO :USERC FROM USUARIOS
         WHERE USERNAME= TRIM(:USER.USERNAME)LIMIT 1;
         //AND EMAIL = TRIM(:USER.EMAIL) LIMIT 1;

         PUSER = USERC;
        IF USERC.BLOQUEADO<>'1';

        IF SQLCODE=0;
        EXEC SQL SELECT * INTO :REGUSER
        FROM SECUUSER
        WHERE IDUSR= :USERC.IDUSR LIMIT 1;
        PREGUSER = REGUSER;

        ENDIF;
        ENDIF;
    end-proc;

    dcl-proc VALIDSECUR EXPORT;
        dcl-pi *n ;
         PREGUSER LIKE(REGUSER);
         SUCCESS INT(5);
        end-pi;
        CLEAR USERC;
        SUCCESS=0;
        REGUSER = PREGUSER;
        IF REGUSER.IDUSR<>0;
            EXEC SQL
            SELECT * INTO :REGUSERC
            FROM SECUUSER WHERE
            IDUSR = :REGUSER.IDUSR;
            SELECT;
             WHEN REGUSER.PGN1=*BLANKS;
                IF
                REGUSER.RPN2=REGUSERC.RPN2 AND
                REGUSER.RPN3=REGUSERC.RPN3;
                SUCCESS = 1;
                ENDIF;
             WHEN REGUSER.PGN2=*BLANKS;
                IF
                REGUSER.RPN1=REGUSERC.RPN1 AND
                REGUSER.RPN3=REGUSERC.RPN3;
                SUCCESS = 1;
                ENDIF;
             WHEN REGUSER.PGN3=*BLANKS;
                IF
                REGUSER.RPN1=REGUSERC.RPN1 AND
                REGUSER.RPN2=REGUSERC.RPN2;
                SUCCESS = 1;
                ENDIF;
            ENDSL;
            IF SUCCESS=0;
            EXEC SQL SELECT * INTO :USERC FROM USUARIOS
            WHERE IDUSR= :REGUSER.IDUSR LIMIT 1;
            IF SQLCODE = 0;
            USERC.INTENTOS = USERC.INTENTOS+1;
            EXEC SQL UPDATE USUARIOS SET INTENTOS=:USERC.INTENTOS
            WHERE IDUSR = :USERC.IDUSR;
            IF USERC.INTENTOS = 3;
                EXEC SQL UPDATE USUARIOS SET BLOQUEADO='1'
                WHERE IDUSR = :USERC.IDUSR;
            ENDIF;

            ENDIF;
            ENDIF;
        ENDIF;
    end-proc;

    dcl-proc CHANGEPASSWORD EXPORT;

        dcl-pi *n ;
         PUSER LIKE(USER);
        end-pi;
      USER = PUSER;
      IF USER.IDUSR<>0;
        EXEC SQL
        UPDATE USUARIOS SET PASS=:USER.PASS
        WHERE IDUSR = :USER.IDUSR;
      ENDIF;

    end-proc;


