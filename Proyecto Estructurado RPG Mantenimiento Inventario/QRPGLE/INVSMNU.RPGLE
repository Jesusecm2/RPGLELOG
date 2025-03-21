**FREE





    Dcl-F INVSERVMNU WORKSTN Sfile(SFLDta:Rrn) InfDS(fileinfo);

    Dcl-S Rrn          Zoned(4:0) Inz;


    Dcl-DS FILEINFO;
      FUNKEY         Char(1)    Pos(369);
    End-DS;


    WRITE HEADER;

    WRITE INVMUSER;

    EXFMT INVMUSER;

    DOW FUNKEY <> F03;

    ENDDO;

    *INLR=*ON;
