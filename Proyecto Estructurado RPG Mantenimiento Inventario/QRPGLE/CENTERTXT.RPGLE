**free

    CTL-OPT BNDDIR('JESUSECM21/INVSERVICE');
    Dcl-F invmain WORKSTN InfDS(fileinfo);

    Dcl-S Rrn          Zoned(4:0) Inz;

    dcl-s sqlint int(10) ;
    dcl-s sqllng char(2);


    dcl-s PADDING INT(10);
    dcl-s START INT(10);
    dcl-s TextC char(200);
    dcl-s textP char(200);
    Dcl-DS FILEINFO;
        FUNKEY         Char(1)    Pos(369);
    End-DS;

        dcl-pr centrartxt extproc('CNTXT');
            *n char(200);
            *n int(10);
        end-pr;

    dcl-pr getMessage extproc('GETMESSAGE') ;
        *N CHAR(200);
        *n int(10);
        *n char(2);
    end-pr;







    //TextC = %Trim(Text);
    //Text = *Blanks;
    //Len = %Len(%trim(TextC));
    //Start = ((40 - Len) / 2) + 1;
    //%subst(Text:Start:Len) = %subst(TextC:1:Len);


    TITLETXT = 'SISTEMA';
    START = 15;
    textP = TITLETXT;
    centrartxt(textP:START);
    TITLETXT = textP;
    TITLEWDW = 'INICIAR SESION';
    sqlint = 3;
    sqllng= 'ES';
    getMessage(textP:sqlint:sqllng);
    START = 19;
    centrartxt(textP:START);
    OUUSER= textP;


   // %subst(Text:Start:PADDING) = %subst(TextC:1:PADDING);
    write LOGINWDWB;
    write LOGINWDW;
    exfmt LOGINWDW;

    *inlr=*on;
