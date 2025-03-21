**FREE

    CTL-OPT NOMAIN;
    dcl-proc getMessage export;

        dcl-pi *N ;
            dcl-parm outVAR char(200);
            dcl-parm id int(10);
            dcl-parm lang char(2);
        end-pi;
        EXEC SQL
            SELECT TEXTO into :outVAR from textos
            where IDTXT = :id and LENGUAJE= TRIM(:lang);
    end-proc;



