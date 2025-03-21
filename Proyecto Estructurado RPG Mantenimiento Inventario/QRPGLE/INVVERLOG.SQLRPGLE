**FREE

    dcl-s SECONDS int(5);
    Dcl-S cmd VarChar(3000);
    Dcl-S cmd1 VarChar(3000);
    dcl-ds USER ExtName('USUARIOS') Qualified;
    end-ds;

        dcl-ds USERC ExtName('USUARIOS') Qualified;
    end-ds;


    DCL-PI INVVERLOG ;
         PUSER char(5);
    END-PI;

    DCL-PR QCMDEXC EXTPGM('QCMDEXC');
        *n char(3000) options(*varsize) const;
        *n packed(15:5) const;
        dbcs char(3) const options(*nopass);
    END-PR;
        Exec Sql Set Option Commit = *None, NamIng = *Sys,
     Datfmt = *ISO, CloSqlCsr = *EndActGrp;

    EXEC SQL SELECT * INTO :USERC
    FROM USUARIOS
    WHERE IDUSR = :PUSER;

        CMD = 'DLYJOB DLY(10)';
        CMD1 = 'DLYJOB DLY(1)';

    DOW USERC.LOGGER='1';
        IF USERC.ACTIVE='1';
            SECONDS = 0;
            EXEC SQL
            UPDATE USUARIOS SET ACTIVE=0
            WHERE IDUSR = :PUSER;
            Monitor;
            qcmdexc (cmd : %len(CMD));
            ON-ERROR;
            EndMon;
        ENDIF;
        SECONDS+=1;
            Monitor;
            qcmdexc (cmd1 : %len(CMD));
            ON-ERROR;
            EndMon;
        IF SECONDS>15;
            EXEC SQL
            UPDATE USUARIOS SET LOGGER=0
            WHERE IDUSR = :PUSER;
        ENDIF;
        EXEC SQL SELECT * INTO :USERC
        FROM USUARIOS
        WHERE IDUSR = :PUSER;
    ENDDO;

    *inlr = *on;
