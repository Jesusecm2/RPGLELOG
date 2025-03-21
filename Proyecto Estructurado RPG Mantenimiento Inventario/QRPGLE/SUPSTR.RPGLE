**FREE
     CTL-OPT NOMAIN ;
        dcl-s TXTC char(200);
        dcl-s PADDING int(10);
        dcl-s START INT(10);
        dcl-proc CNTXT export;
            dcl-pi *n ;
                dcl-parm TXT char(200);
                dcl-parm Fsize int(10);
            end-pi;
            TXTC = %Trim(TXT);
            TXT = *Blanks;
            PADDING = %Len(%trim(TXTC));
            Start = ((Fsize - PADDING) / 2) + 1;
            %subst(TXT:Start:PADDING) = %subst(TXTC:1:PADDING);
        end-proc;





