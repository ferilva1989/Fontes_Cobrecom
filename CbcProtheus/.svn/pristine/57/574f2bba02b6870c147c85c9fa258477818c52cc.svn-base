#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'TOPCONN.CH'

//------------------------------------------------------------------------------

WsService sw_DADOS
                                
    WSDATA IDS 			AS STRING
    WSDATA QUERY 		AS STRING 
    WSDATA TABELA       AS STRING 
    WSDATA CAMPOSX3     AS STRING
    WSDATA CAMPCALC     AS SCAMPCALC
    WSDATA FILTRO       AS STRING
    WSDATA FUNGERATRB   AS STRING        
    WSDATA LISTASX2     AS LSTSX2
    
    WSDATA RETGETQUERY 	AS LISTADADOS        
    WSDATA RETGETTRB 	AS LISTADADOS        
    WSDATA RetGetSX2    AS CAMPOSX2
    WSDATA RetGetCombo  AS sRetGetCombo                 
    WSDATA RetGetSX2LST AS LSTSX2RET
    

	WSMETHOD GETQUERY 	
	WSMETHOD GETQUERY2 	
	WSMETHOD GETQUERY3 	
	WSMETHOD GETSX2
	WSMETHOD GETCOMBOSX3
	WSMETHOD GETTRB
	WSMETHOD GETSX2LST

EndWsService       

WSSTRUCT LSTSX2
   WSDATA SX2 AS ARRAY OF sTAB
ENDWSSTRUCT                 

WSSTRUCT sTAB
   WSDATA ALIAS AS STRING
//   WSDATA TABELA AS STRING
ENDWSSTRUCT 


WSSTRUCT LSTSX2RET
   WSDATA ERRORCODE AS STRING
   WSDATA ERRORMSG  AS STRING
   WSDATA TAB		  AS ARRAY OF STRING
ENDWSSTRUCT                 


WSSTRUCT LISTADADOS
   WSDATA ERRORCODE AS STRING
   WSDATA ERRORMSG  AS STRING
   WSDATA AHEADER   AS ARRAY OF HEADER
   WSDATA ACOLS     AS ARRAY OF LINHAS
ENDWSSTRUCT 

WSSTRUCT SCAMPCALC
   WSDATA CAMPOSCALC AS ARRAY OF CMPCALC 
ENDWSSTRUCT                                

WSSTRUCT CMPCALC
   WSDATA CAMPO    AS STRING
   WSDATA TITULO   AS STRING
   WSDATA TIPO     AS STRING
   WSDATA FORMULA  AS STRING
ENDWSSTRUCT                                
                   
WSSTRUCT HEADER
    WSDATA CAMPO    AS STRING
    WSDATA NOME     AS STRING 
    WSDATA MASCARA  AS STRING   
    WSDATA TIPO     AS STRING
    WSDATA TAMANHO  AS FLOAT
    WSDATA DECIMAL  AS FLOAT 
    WSDATA VALIDAC  AS STRING
    WSDATA OBRIGAT  AS STRING 
ENDWSSTRUCT 

               
WSSTRUCT LINHAS 
	WSDATA CONTEUDO AS ARRAY OF STRING
ENDWSSTRUCT                  

WSSTRUCT CAMPOSX2
    WSDATA ERRORCODE AS STRING
    WSDATA ERRORMSG  AS STRING
    WSDATA TABELA    AS STRING
    WSDATA ARQUIVO   AS STRING 
    WSDATA MODO      AS STRING
ENDWSSTRUCT        

WSSTRUCT SRETGETCOMBO
   	WSDATA ERRORCODE AS STRING
   	WSDATA ERRORMSG  AS STRING
   	WSDATA OPCOES    AS ARRAY OF OPCOMBO  
ENDWSSTRUCT 

WSSTRUCT OPCOMBO
	WSDATA DESCRIC AS STRING
	WSDATA OPCAO   AS STRING
ENDWSSTRUCT
            

WSMETHOD GETSX2LST WSRECEIVE IDS , LISTASX2 WSSEND RetGetSX2LST WSSERVICE Sw_Dados
lOK:= .F.

U_IDSFIL(::IDS)

ChkFile("SX2")     
dbselectarea("SX2")
dbsetorder(1)

aSX2 := ::LISTASX2:SX2
                         
FOR F:= 1 TO LEN(::LISTASX2:SX2) 

	cCONTEUDO := ::LISTASX2:SX2[F]:ALIAS      
		         
	IF EMPTY(cCONTEUDO)   .OR. cCONTEUDO == NIL
&&		CONOUT("CONTEUDO VAZIO... PASSANDO PARA O PROXIMO ELEMENTO...")
		aadd(::RetGetSX2LST:TAB , " "   ) 
		LOOP
	ENDIF
		
    IF SX2->(DBSEEK( cCONTEUDO, .F. ))      

&&		CONOUT("ENCONTROU -> "+cCONTEUDO)
   	aadd(::RetGetSX2LST:TAB , SX2->X2_ARQUIVO   ) 
		
        lOK:= .T.

	ELSE

&&		CONOUT("NAO ENCONTROU -> "+cCONTEUDO)
		aadd(::RetGetSX2LST:TAB , " "   ) 

    ENDIF

NEXT

IF lOK
   ::RetGetSX2LST:ERRORCODE := "00"
   ::RetGetSX2LST:ERRORMSG  := "Encontrado "

ELSE
   ::RetGetSX2LST:ERRORCODE := "02"
   ::RetGetSX2LST:ERRORMSG  := "Nao encontrado "

ENDIF

RETURN .T.


//------------------------------------------------------------------------------
WSMETHOD GETSX2 WSRECEIVE IDS , TABELA WSSEND RetGetSX2 WSSERVICE Sw_Dados
                                                        
U_IDSFIL(::IDS)
     
ChkFile("SX2")     
dbselectarea("SX2")
dbsetorder(1)
IF DBSEEK( ::tabela )
   ::RetGetSX2:ERRORCODE := "00"
   ::RetGetSX2:ERRORMSG  := "OK"
   ::RetGetSX2:TABELA    := SX2->X2_CHAVE
   ::RetGetSX2:ARQUIVO   := SX2->X2_ARQUIVO
   ::RetGetSX2:MODO      := SX2->X2_MODO
ELSE                        
   ::RetGetSX2:ERRORCODE := "02"
   ::RetGetSX2:ERRORMSG  := "nao encontrado "
   ::RetGetSX2:TABELA    := ""
   ::RetGetSX2:ARQUIVO   := ""
   ::RetGetSX2:MODO      := ""
endif
     
     
RETURN .T.

//------------------------------------------------------------------------------
WsMethod GETQUERY  WsReceive IDS, Query WsSend RetGetQuery WsService Sw_Dados

Local lOk := .F.
Local cErrorCode := "00"
Local cErrorMsg  := "OK"

conout("IDS-> "+::IDS)
U_IDSFIL(::IDS)
	
CONOUT("getquery - inicio:"+TIME())


cQuery := ::QUERY
////CONOUT(cQuery)
cQuery := AJTABELA( cQuery )
////CONOUT( "AJUSTADA:"+cQuery )
cQuery := ChangeQuery(cQuery)
CONOUT( "CHAGEQUERY:"+cQuery )

//cqueryfile := "query001.sql"
//x:= 1
//DO WHILE FILE( cQueryfile )          
//    x++
//    cqueryfile := "query"+STRZERO(x,3)+".sql"
//ENDDO
//NH := FCREATE("GETQUERY"+SUBS(TIME(),1,2) + SUBS(TIME(),4,2) + SUBS(TIME(),7,2) +".SQL")
//FWRITE( NH, cQuery )
//FCLOSE(NH)



IF ("INSERT" $ cQuery) .or. ("UPDATE" $ cQuery)
   RETURN .F.
ENDIF

iif( select("QRY")>0, QRY->( dbclosearea()), )
TcQuery cQuery New Alias "QRY"

aHeader := {}
aCols   := {}
aTipos  := {}

ChkFile("SX3")
// =========================================================
// MONTA ARRAY DO CABECALHO DO RETORNO 
// =========================================================

FOR F:=1 TO FCOUNT() 
    
    cCampo := FIELDNAME( F ) 
  //  //CONOUT(CCAMPO)
    SX3->(DBSETORDER(2))
    IF  SX3->(DBSEEK(UPPER(ALLTRIM(cCampo)), .F. ))   // SE ACHOU CAMPO NO SX3
        IF SX3->X3_TIPO $ "CNLDM"
	        cNome 	  := SX3->X3_TITULO 
	        cMascara := SX3->X3_PICTURE 
	        cTipo    := SX3->X3_TIPO
	        nTam     := SX3->X3_TAMANHO
	        nDec     := SX3->X3_DECIMAL
	        cValidac := "" 
	        cObrigat := "" //SX3->X3_OBRIGAT
	        lAdd := .T.
	    ELSE
	        lAdd := .f.
	    ENDIF
    ELSE              
        IF (3<4) // valtype( fieldget(f) ) $ "CNLDM"
	        cNome 	 := cCampo
	        cMascara := ""
	        cTipo    := VALTYPE(fieldget(f))   //IF(VALTYPE(fieldget(f))="N", "N", "C" )
	        nTam     := IF( cTipo = "C" , LEN( FIELDGET(F) ), 0 )
	        nDec     := 0
	        cValidac := "" 
	        cObrigat := ""
	        lAdd := .T.
	    ELSE
	        lAdd := .f.
	    ENDIF             
    ENDIF
    IF lAdd                                

        AADD(ATIPOS , cTipo  )
        
		AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
			
		oTemp := aTail(  ::RetGetQuery:AHEADER )
	
	    oTemp:CAMPO    := cCampo
	    oTemp:NOME     := cNome 
	    oTemp:MASCARA  := cMascara   
	    oTemp:TIPO     := cTipo 
	    oTemp:TAMANHO  := nTam
	    oTemp:DECIMAL  := nDec
	    oTemp:VALIDAC  := cValidac
	    oTemp:OBRIGAT  := cObrigat
	Endif
NEXT


// =========================================================
// MONTA ARRAY DO CONTEUDO 
// =========================================================

dbSelectArea("QRY")
nx := 0
DO WHILE !QRY->(EOF()) 
	 
        aAux := {}                     
		// ============================        
        // CARREGA CAMPOS DA TABELA    
		// ============================        
		FOR f:= 1 to FCOUNT()
			
			cTipo := aTipos[f]  
//			//CONOUT("HORA:"+TIME()+"CTIPO="+CTIPO)
			
			cConteudo := ""
			
			IF  cTipo     = "N"
				cCONTEUDO := REPLACE(  STR( fieldget(f) ) , ".","," )
			ELSEIF  cTipo = "C"
				cCONTEUDO := u_limpatxt(fieldget(f))
			ELSEIF  cTipo = "M"
				cCONTEUDO := fieldget(f) 
			ELSEIF  cTipo  = "L"
				cCONTEUDO := IF ( fieldget(f) , "TRUE", "FALSE" )
			ELSEIF  cTipo  = "D"  
			    IF EMPTY( ALLTRIM(fieldget(f)) )
			    	cConteudo:= "01/01/1980"
			    ELSE
					cCONTEUDO :=  DTOC( STOD(fieldget(f)) )
			    ENDIF
			ENDIF			
            AADD( aAux , cConteudo )
		NEXT                        
			
		AAdd( ::RetGetQuery:ACOLS, WSClassNew( "LINHAS" ))		

		oTempLinhas := aTail(  ::RetGetQuery:ACOLS ) 		
		oTempLinhas:CONTEUDO := aAux  
		
	    
        lOk := .T.
   QRY->(DBSKIP())
ENDDO
QRY->(DBCLOSEAREA())

IF lOk 
    ::RetGetQuery:ErrorCode := cErrorCode 
    ::RetGetQuery:ErrorMSG  := "OK"
Else                               
    ::RetGetQuery:ErrorCode := "07" 
    ::RetGetQuery:ErrorMSG  := "Nao encontrado resultado."


    // dados HEADER
    // =============
 	AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
		
	oTemp := aTail(  ::RetGetQuery:AHEADER )

    oTemp:CAMPO    := ""
    oTemp:NOME     := ""
    oTemp:MASCARA  := ""
    oTemp:TIPO     := ""
    oTemp:TAMANHO  := 0
    oTemp:DECIMAL  := 0
    oTemp:VALIDAC  := ""
    oTemp:OBRIGAT  := ""

    // dados COLS 
    // =============

	AAdd( ::RetGetQuery:ACOLS, WSClassNew( "LINHAS" ))		
	oTempLinhas := aTail(  ::RetGetQuery:ACOLS ) 		
	oTempLinhas:CONTEUDO := {""}

    
ENDIF 

//CONOUT("getquery - FINAL:"+TIME())



RETURN .T.

//----------------------------------------------------------------------------------------
WsMethod GETQUERY2  WsReceive IDS, Query, CAMPCALC WsSend RetGetQuery WsService Sw_Dados

Local lOk := .F.
Local cErrorCode := "00"
Local cErrorMsg  := "OK"

//CONOUT("getquery2 - inicio:"+TIME())

cQuery := ::QUERY
////CONOUT(cQuery)
cQuery := AJTABELA( cQuery )
////CONOUT( "AJUSTADA:"+cQuery )
cQuery := ChangeQuery(cQuery)
////CONOUT( "CHAGEQUERY:"+cQuery )

NH := FCREATE("QUERY.SQL")
FWRITE( NH, cQuery )
FCLOSE(NH)

IF ("INSERT" $ cQuery) .or. ("UPDATE" $ cQuery)
   RETURN .F.
ENDIF
  
TcQuery cQuery New Alias "QRY"

aHeader := {}
aCols   := {}
aTipos  := {}

ChkFile("SX3")
// =========================================================
// MONTA ARRAY DO CABECALHO DO RETORNO 
// =========================================================

FOR F:=1 TO FCOUNT() 
    
    cCampo := FIELDNAME( F ) 
//    //CONOUT(CCAMPO)
    SX3->(DBSETORDER(2))
    IF  SX3->(DBSEEK(UPPER(ALLTRIM(cCampo)), .F. ))   // SE ACHOU CAMPO NO SX3
        IF SX3->X3_TIPO $ "CNLDM"
	        cNome 	 := SX3->X3_TITULO 
	        cMascara := SX3->X3_PICTURE 
	        cTipo    := SX3->X3_TIPO
	        nTam     := SX3->X3_TAMANHO
	        nDec     := SX3->X3_DECIMAL
	        cValidac := "" 
	        cObrigat := "" //SX3->X3_OBRIGAT
	        lAdd := .T.
	    ELSE
	        lAdd := .f.
	    ENDIF
    ELSE              
        IF (3<4) // valtype( fieldget(f) ) $ "CNLDM"
	        cNome 	 := cCampo
	        cMascara := ""
	        cTipo    := VALTYPE(fieldget(f))   //IF(VALTYPE(fieldget(f))="N", "N", "C" )
	        nTam     := IF( cTipo = "C" , LEN( FIELDGET(F) ), 0 )
	        nDec     := 0
	        cValidac := "" 
	        cObrigat := ""
	        lAdd := .T.
	    ELSE
	        lAdd := .f.
	    ENDIF             
    ENDIF
    IF lAdd                                

        AADD(ATIPOS , cTipo  )
        
		AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
			
		oTemp := aTail(  ::RetGetQuery:AHEADER )
	
	    oTemp:CAMPO    := cCampo
	    oTemp:NOME     := cNome 
	    oTemp:MASCARA  := cMascara   
	    oTemp:TIPO     := cTipo 
	    oTemp:TAMANHO  := nTam
	    oTemp:DECIMAL  := nDec
	    oTemp:VALIDAC  := cValidac
	    oTemp:OBRIGAT  := cObrigat
	Endif
NEXT

// ====================================================
// COLOCA NO AHEADER OS CAMPOS CALCULADOS              
// ====================================================
aFormulas := {}
FOR F:=1 TO LEN( ::CAMPCALC:CAMPOSCALC )

		AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
			
		oTemp := aTail(  ::RetGetQuery:AHEADER )
	
	    oTemp:CAMPO    := ::CAMPCALC:CAMPOSCALC[F]:CAMPO
	    oTemp:NOME     := ::CAMPCALC:CAMPOSCALC[F]:TITULO
	    oTemp:MASCARA  := ""
	    oTemp:TIPO     := ::CAMPCALC:CAMPOSCALC[F]:TIPO
	    oTemp:TAMANHO  := 0
	    oTemp:DECIMAL  := 0
	    oTemp:VALIDAC  := ""
	    oTemp:OBRIGAT  := ""
        
        AADD( aFormulas  , ::CAMPCALC:CAMPOSCALC[F]:FORMULA)

NEXT





// =========================================================
// MONTA ARRAY DO CONTEUDO 
// =========================================================

dbSelectArea("QRY")
nx := 0
DO WHILE !QRY->(EOF()) 
	 
        aAux := {}                     
		// ============================        
        // CARREGA CAMPOS DA TABELA    
		// ============================        
		FOR f:= 1 to FCOUNT()
			
			cTipo := aTipos[f]  
//			//CONOUT("HORA:"+TIME()+"CTIPO="+CTIPO)
			
			cConteudo := ""
			
			IF  cTipo  = "N"
				cCONTEUDO := REPLACE(  STR( fieldget(f) ) , ".","," )
			ELSEIF  cTipo = "C"
				cCONTEUDO := fieldget(f) 
			ELSEIF  cTipo = "M"
				cCONTEUDO := fieldget(f) 
			ELSEIF  cTipo  = "L"
				cCONTEUDO := IF ( fieldget(f) , "TRUE", "FALSE" )
			ELSEIF  cTipo  = "D"  
			    IF EMPTY( ALLTRIM(fieldget(f)) )
			    	cConteudo:= "01/01/1980"
			    ELSE
					cCONTEUDO :=  DTOC( STOD(fieldget(f)) )
			    ENDIF
			ENDIF			
            AADD( aAux , cConteudo )
		NEXT                        
		
		// ============================
		// CARREGA CAMPOS CALCULADOS
		// ============================
		FOR F := 1 TO LEN( aFormulas )		
		    
		    cFormula := aFormulas[f]
//		    //CONOUT( cFormula )
		    cAliasAnt := ALIAS()
		    cResultado := &cFormula
		    DBSELECTAREA(cAliasAnt)
		    
			IF  VALTYPE(cResultado)  = "N"
				cCONTEUDO := REPLACE(  STR( cResultado ) , ".","," )
			ELSEIF  VALTYPE(cResultado) = "C"
				cCONTEUDO := cResultado 
			ELSEIF  VALTYPE(cResultado) = "M"
				cCONTEUDO := cResultado 
			ELSEIF  VALTYPE(cResultado)  = "L"
				cCONTEUDO := IF ( cResultado , "TRUE", "FALSE" )
			ELSEIF  VALTYPE(cResultado)  = "D"  
			    IF EMPTY( cResultado )
			    	cConteudo:= "01/01/1980"
			    ELSE
					cCONTEUDO :=  DTOC( cResultado )
			    ENDIF
			ENDIF			
		    
		    AADD( aAux , cConteudo )
		    
		NEXT
		
			
		AAdd( ::RetGetQuery:ACOLS, WSClassNew( "LINHAS" ))		

		oTempLinhas := aTail(  ::RetGetQuery:ACOLS ) 		
		oTempLinhas:CONTEUDO := aAux  
		
	    
        lOk := .T.
   QRY->(DBSKIP())
ENDDO
QRY->(DBCLOSEAREA())

IF lOk 
    ::RetGetQuery:ErrorCode := cErrorCode 
    ::RetGetQuery:ErrorMSG  := "OK"
Else                               
    ::RetGetQuery:ErrorCode := "07" 
    ::RetGetQuery:ErrorMSG  := "Nao encontrado resultado."


    // dados HEADER
    // =============
 	AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
		
	oTemp := aTail(  ::RetGetQuery:AHEADER )

    oTemp:CAMPO    := ""
    oTemp:NOME     := ""
    oTemp:MASCARA  := ""
    oTemp:TIPO     := ""
    oTemp:TAMANHO  := 0
    oTemp:DECIMAL  := 0
    oTemp:VALIDAC  := ""
    oTemp:OBRIGAT  := ""

    // dados COLS 
    // =============

	AAdd( ::RetGetQuery:ACOLS, WSClassNew( "LINHAS" ))		
	oTempLinhas := aTail(  ::RetGetQuery:ACOLS ) 		
	oTempLinhas:CONTEUDO := {""}

    
ENDIF 

//CONOUT("getquery2 - termino:"+TIME())



RETURN .T.

//-----------------------------------------------------------------------------------------------
WsMethod GETQUERY3  WsReceive IDS, Query, CAMPCALC, FILTRO WsSend RetGetQuery WsService Sw_Dados
Local lOk := .F.
Local cErrorCode := "00"
Local cErrorMsg  := "OK"

//CONOUT(TIME())


cQuery := ::QUERY
////CONOUT(cQuery)
cQuery := AJTABELA( cQuery )
////CONOUT( "AJUSTADA:"+cQuery )
cQuery := ChangeQuery(cQuery)
////CONOUT( "CHAGEQUERY:"+cQuery )

cFiltro := ALLTRIM( ::FILTRO )
IF EMPTY( cFiltro )
   cFiltro := ".T." 
ENDIF


IF ("INSERT" $ cQuery) .or. ("UPDATE" $ cQuery)
   RETURN .F.
ENDIF
  
TcQuery cQuery New Alias "QRY"

aHeaderQry := {}
aHeaderCalc := {}
aCols   := {}
aTipos  := {}

ChkFile("SX3")
// =========================================================
// MONTA ARRAY DO CABECALHO DO RETORNO 
// =========================================================

FOR F:=1 TO FCOUNT() 
    
    cCampo := FIELDNAME( F ) 
//    //CONOUT(CCAMPO)
    SX3->(DBSETORDER(2))
    IF  SX3->(DBSEEK(UPPER(ALLTRIM(cCampo)), .F. ))   // SE ACHOU CAMPO NO SX3
        IF SX3->X3_TIPO $ "CNLDM"
	        cNome 	 := SX3->X3_TITULO 
	        cMascara := SX3->X3_PICTURE 
	        cTipo    := SX3->X3_TIPO
	        nTam     := SX3->X3_TAMANHO
	        nDec     := SX3->X3_DECIMAL
	        cValidac := "" 
	        cObrigat := "" //SX3->X3_OBRIGAT
	        lAdd := .T.
	    ELSE
	        lAdd := .f.
	    ENDIF
    ELSE              
        IF (3<4) // valtype( fieldget(f) ) $ "CNLDM"
	        cNome 	 := cCampo
	        cMascara := ""
	        cTipo    := VALTYPE(fieldget(f))   //IF(VALTYPE(fieldget(f))="N", "N", "C" )
	        nTam     := IF( cTipo = "C" , LEN( FIELDGET(F) ), 0 )
	        nDec     := 0
	        cValidac := "" 
	        cObrigat := ""
	        lAdd := .T.
	    ELSE
	        lAdd := .f.
	    ENDIF             
    ENDIF
    IF lAdd                                

        AADD(ATIPOS , cTipo  )
        
		AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
			
		oTemp := aTail(  ::RetGetQuery:AHEADER )
	
	    oTemp:CAMPO    := cCampo
	    oTemp:NOME     := cNome 
	    oTemp:MASCARA  := cMascara   
	    oTemp:TIPO     := cTipo 
	    oTemp:TAMANHO  := nTam
	    oTemp:DECIMAL  := nDec
	    oTemp:VALIDAC  := cValidac
	    oTemp:OBRIGAT  := cObrigat
        
       AADD(AHEADERQRY , cCampo )

        xVar := "x"+oTemp:CAMPO
        &xVar := ""


	Endif
NEXT

// ====================================================
// COLOCA NO AHEADER OS CAMPOS CALCULADOS              
// ====================================================
aFormulas := {}
FOR F:=1 TO LEN( ::CAMPCALC:CAMPOSCALC )

		AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
			
		oTemp := aTail(  ::RetGetQuery:AHEADER )
	
	    oTemp:CAMPO    := ::CAMPCALC:CAMPOSCALC[F]:CAMPO
	    oTemp:NOME     := ::CAMPCALC:CAMPOSCALC[F]:TITULO
	    oTemp:MASCARA  := ""
	    oTemp:TIPO     := ::CAMPCALC:CAMPOSCALC[F]:TIPO
	    oTemp:TAMANHO  := 0
	    oTemp:DECIMAL  := 0
	    oTemp:VALIDAC  := ""
	    oTemp:OBRIGAT  := ""
        
        AADD( aFormulas  , ::CAMPCALC:CAMPOSCALC[F]:FORMULA)
        
        aadd( aHeaderCALC , oTemp:CAMPO )
        
        xVar := "x"+oTemp:CAMPO
        &xVar := ""

NEXT





// =========================================================
// MONTA ARRAY DO CONTEUDO 
// =========================================================

dbSelectArea("QRY")
nx := 0
DO WHILE !QRY->(EOF()) 
	 
        aAux := {}                     
		// ============================        
        // CARREGA CAMPOS DA TABELA    
		// ============================        
		FOR f:= 1 to FCOUNT()
			
			cTipo := aTipos[f]  
//			//CONOUT("HORA:"+TIME()+"CTIPO="+CTIPO)
			
			cConteudo := ""
			
			IF  cTipo  = "N"
				cCONTEUDO := REPLACE(  STR( fieldget(f) ) , ".","," )
			ELSEIF  cTipo = "C"
				cCONTEUDO := fieldget(f) 
			ELSEIF  cTipo = "M"
				cCONTEUDO := fieldget(f) 
			ELSEIF  cTipo  = "L"
				cCONTEUDO := IF ( fieldget(f) , "TRUE", "FALSE" )
			ELSEIF  cTipo  = "D"  
			    IF EMPTY( ALLTRIM(fieldget(f)) )
			    	cConteudo:= "01/01/1980"
			    ELSE
					cCONTEUDO :=  DTOC( STOD(fieldget(f)) )
			    ENDIF
			ENDIF			
            AADD( aAux , cConteudo )

		      cVAR := "x"+ aHeaderQry[f]   
 		      &cVar := fieldget(f)
		    


		NEXT                        
		
		// ============================
		// CARREGA CAMPOS CALCULADOS
		// ============================
		FOR F := 1 TO LEN( aFormulas )		
		    
		    cFormula := aFormulas[f]
//		    //CONOUT( cFormula )
		    cAliasAnt := ALIAS()
		    cResultado := &cFormula
		    DBSELECTAREA(cAliasAnt)
		    
			IF  VALTYPE(cResultado)  = "N"
				cCONTEUDO := REPLACE(  STR( cResultado ) , ".","," )
			ELSEIF  VALTYPE(cResultado) = "C"
				cCONTEUDO := cResultado 
			ELSEIF  VALTYPE(cResultado) = "M"
				cCONTEUDO := cResultado 
			ELSEIF  VALTYPE(cResultado)  = "L"
				cCONTEUDO := IF ( cResultado , "TRUE", "FALSE" )
			ELSEIF  VALTYPE(cResultado)  = "D"  
			    IF EMPTY( cResultado )
			    	cConteudo:= "01/01/1980"
			    ELSE
					cCONTEUDO :=  DTOC( cResultado )
			    ENDIF
			ENDIF			
		    
		    AADD( aAux , cConteudo )
		    
		    
		    cVAR := "x"+ aHeadercalc[f]   
		    &cVar := cResultado
		    
		    
		    
		NEXT
		
		cAliasAnt := ALIAS() 
		//CONOUT("CFILTRO="+cFiltro)
		lEnvia := &cFiltro
		DBSELECTAREA( cAliasAnt )
		//CONOUT(LENVIA)
		IF lEnvia	                              
			AAdd( ::RetGetQuery:ACOLS, WSClassNew( "LINHAS" ))		

			oTempLinhas := aTail(  ::RetGetQuery:ACOLS ) 		
			oTempLinhas:CONTEUDO := aAux  
		ENDIF
		
	    
        lOk := .T.
   QRY->(DBSKIP())
ENDDO
QRY->(DBCLOSEAREA())

IF LEN(::RetGetQuery:ACOLS) <= 0
   lOk := .F.
ENDIF


IF lOk 
    ::RetGetQuery:ErrorCode := cErrorCode 
    ::RetGetQuery:ErrorMSG  := "OK"
Else                               
    ::RetGetQuery:ErrorCode := "07" 
    ::RetGetQuery:ErrorMSG  := "Nao encontrado resultado."


    // dados HEADER
    // =============
 	AAdd( ::RetGetQuery:AHEADER , WSClassNew( "HEADER" ))
		
	oTemp := aTail(  ::RetGetQuery:AHEADER )

    oTemp:CAMPO    := ""
    oTemp:NOME     := ""
    oTemp:MASCARA  := ""
    oTemp:TIPO     := ""
    oTemp:TAMANHO  := 0
    oTemp:DECIMAL  := 0
    oTemp:VALIDAC  := ""
    oTemp:OBRIGAT  := ""

    // dados COLS 
    // =============

	AAdd( ::RetGetQuery:ACOLS, WSClassNew( "LINHAS" ))		
	oTempLinhas := aTail(  ::RetGetQuery:ACOLS ) 		
	oTempLinhas:CONTEUDO := {""}

    
ENDIF 



//CONOUT(TIME())
RETURN .T.


//------------------------------------------------------------------------------
STATIC FUNCTION AJTABELA(cQuery)
LOCAL cNewQuery := ""

ChkFile("SX2")     
dbselectarea("SX2")
dbsetorder(1)
                  
// =====================================================
// TRATA FUNCAO TABSX2
// ====================================================
DO WHILE AT( "TABSX2(" , cQuery ) <> 0 
//   //CONOUT("query="+cQuery)
   nPosIni := AT( "TABSX2(" , cQuery )
   nPosFim := AT( ")" , SUBS( cQuery , nPosIni , LEN( cQuery ) ) )

   cTabela := SUBS(cQuery , nPosIni+7, nPosFim-2 )
   cTabela := PADR( ALLTRIM( cTabela ) , 3 , " ")
//   //CONOUT("tabela="+cTabela)
   IF SX2->( DBSEEK( cTabela ) )
      cArquivo := SX2->X2_ARQUIVO
      cNewQuery := SUBS( cQuery , 1, nPosIni-1 ) 
      cNewQuery += " "+ALLTRIM(cArquivo)
      cNewQuery += SUBS( cQuery , nPosIni+nPosFim, len( cQuery ) )
      cQuery := cNewQuery                
//      //CONOUT( cNewQuery )
   ELSE
      EXIT
   ENDIF                         
   
ENDDO
// =====================================================
// TRATA FUNCAO XFILIAL
// ====================================================
DO WHILE AT( "XFILIAL(" , cQuery ) <> 0 
//   //CONOUT("query="+cQuery)
   nPosIni := AT( "XFILIAL(" , cQuery )
   nPosFim := AT( ")" , SUBS( cQuery , nPosIni , LEN( cQuery ) ) )

   cTabela := SUBS(cQuery , nPosIni+8, nPosFim-2 )
   cTabela := PADR( ALLTRIM( cTabela ) , 3 , " ")
//   //CONOUT("tabela="+cTabela)
   IF SX2->( DBSEEK( cTabela ) )
      cArquivo := XFILIAL(cTABELA)
      cNewQuery := SUBS( cQuery , 1, nPosIni-1 ) 
      cNewQuery += " '"+cArquivo+"' "
      cNewQuery += SUBS( cQuery , nPosIni+nPosFim+1, len( cQuery ) )
      cQuery := cNewQuery                
//      //CONOUT( cNewQuery )
   ELSE
      EXIT
   ENDIF                         
   
ENDDO


RETURN cQuery                           
  
//---------------------------------------------------------------------------------------------------------------------------  TIAGO
WSMETHOD GETCOMBOSX3 WSRECEIVE IDS, CAMPOSX3 WSSEND RetGetCombo WSSERVICE Sw_Dados

ChkFile("SX3")               
DBSELECTAREA("SX3")
DBSETORDER(2)
IF DBSEEK(PADR(ALLTRIM(::CAMPOSX3),10," ") , .F.)
   cOpc := ALLTRIM( SX3->X3_CBOX )
ELSE
   cOpc := ""
ENDIF
   
aOpc := {}
cOPC := ALLTRIM(cOPC) +";" 
DO WHILE AT(";", cOpc ) <> 0 
   nPosItem := AT(";", cOpc )
   cItem := SUBS( cOpc , 1          , nPosItem-1  )
   cOpc  := SUBS( cOpc , nPosItem +1, LEN( cOpc ) )
   
   
   nPosIgual = AT( "=", cItem )
   IF nPosIgual <> 0                             
      AADD( aOpc , { SUBS( cItem , 1, nPosIgual -1 )  , SUBS( cItem , nPosIgual +1, Len(cItem) ) } )
   ENDIF
   
ENDDO

IF len( aOpc ) > 0            
   FOR F:= 1 TO LEN( aOpc )
	   AADD( ::RETGETCOMBO:OPCOES, WSClassNew( "OPCOMBO" ))
	   oTemp := aTail(  ::RETGETCOMBO:OPCOES ) 		
	   oTemp:OPCAO   := aOpc[F][1]
	   oTemp:DESCRIC := aOpc[F][2]
    NEXT
	::RETGETCOMBO:ERRORCODE := "00"
	::RETGETCOMBO:ERRORMSG  := "ok"
    
ELSE                      

	::RETGETCOMBO:ERRORCODE := "01"
	::RETGETCOMBO:ERRORMSG  := "nao encontrado"
	AADD( ::RETGETCOMBO:OPCOES, WSClassNew( "OPCOMBO" ))
	oTemp := aTail(  ::RETGETCOMBO:OPCOES ) 		
	oTemp:OPCAO   := ""
	oTemp:DESCRIC := ""

ENDIF

RETURN .T.


/*
//---------------------------------------------------------------------------------
WSMETHOD GETCOMBOSX3 WSRECEIVE IDS, CAMPOSX3 WSSEND RetGetCombo WSSERVICE Sw_Dados

ChkFile("SX3")               
DBSELECTAREA("SX3")
DBSETORDER(2)
IF DBSEEK(PADR(ALLTRIM(::CAMPOSX3),10," ") , .F.)
   cOpc := ALLTRIM( SX3->X3_CBOX )
ELSE
   cOpc := ""
ENDIF
   
aOpc := {}

DO WHILE AT(";", cOpc ) <> 0 
   nPosItem := AT(";", cOpc )
   cItem := SUBS( cOpc , 1          , nPosItem-1  )
   cOpc  := SUBS( cOpc , nPosItem +1, LEN( cOpc ) )
   
   
   nPosIgual = AT( "=", cItem )
   IF nPosIgual <> 0                             
      AADD( aOpc , { SUBS( cItem , 1, nPosIgual -1 )  , SUBS( cItem , nPosIgual +1, Len(cItem) ) } )
   ENDIF
   
ENDDO

IF len( aOpc ) > 0            
   FOR F:= 1 TO LEN( aOpc )
	   AADD( ::RETGETCOMBO:OPCOES, WSClassNew( "OPCOMBO" ))
	   oTemp := aTail(  ::RETGETCOMBO:OPCOES ) 		
	   oTemp:OPCAO   := aOpc[F][1]
	   oTemp:DESCRIC := aOpc[F][2]
    NEXT
	::RETGETCOMBO:ERRORCODE := "00"
	::RETGETCOMBO:ERRORMSG  := "ok"
    
ELSE                      

	::RETGETCOMBO:ERRORCODE := "01"
	::RETGETCOMBO:ERRORMSG  := "nao encontrado"
	AADD( ::RETGETCOMBO:OPCOES, WSClassNew( "OPCOMBO" ))
	oTemp := aTail(  ::RETGETCOMBO:OPCOES ) 		
	oTemp:OPCAO   := ""
	oTemp:DESCRIC := ""

ENDIF


RETURN .T.             
*/

//------------------------------------------------------------------------------
USER FUNCTION MEMOCAMPO( cAliasMemo , nRecno , cCampo )
LOCAL cAlias := ALIAS()
LOCAL nRegAnt:= 0

DBSELECTAREA( cAliasMemo )
nRegAnt := RECNO()
dbgoto( nRecno )  
cRet := &cCampo
DBGOTO( nRegAnt )

DBSELECTAREA( cAlias )

RETURN cRet

//------------------------------------------------------------------------------
USER FUNCTION MEMOSYP( cAliasMemo , nRecno , cCampoCodMemo)
LOCAL cAlias := ALIAS()
LOCAL nRegAnt:= 0

DBSELECTAREA( cAliasMemo )
nRegAnt := RECNO()
dbgoto( nRecno )       
cCodMem := &cCampoCodMemo
cRet := MSMM( cCodMem,,,,3 ) 
//CONOUT( "Codmemo="+cCodMem )

//CONOUT( "Conteudo="+cRet )
DBGOTO( nRegAnt )

DBSELECTAREA( cAlias )

RETURN cRet

//------------------------------------------------------------------------------
// modo de uso na formula:  "U_TXTCOMBO('AD1_STATUS' , QRY->AD1_STATUS ) "
USER FUNCTION TXTCOMBO( cCampo , cChave )
LOCAL cAlias := ALIAS()
LOCAL nRegAnt:= 0
LOCAL cRet := cChave
LOCAL aOpc := {}

ChkFile("SX3")               
DBSELECTAREA("SX3")
DBSETORDER(2)
IF DBSEEK(PADR(ALLTRIM(cCampo),10," ") , .F.)
   cOpc := ALLTRIM( SX3->X3_CBOX )
ELSE
   cOpc := ""
ENDIF
   
aOpc := {}

DO WHILE AT(";", cOpc ) <> 0 
   nPosItem := AT(";", cOpc )
   cItem := SUBS( cOpc , 1          , nPosItem-1  )
   cOpc  := SUBS( cOpc , nPosItem +1, LEN( cOpc ) )
   
   
   nPosIgual = AT( "=", cItem )
   IF nPosIgual <> 0                             
      AADD( aOpc , { SUBS( cItem , 1, nPosIgual -1 )  , SUBS( cItem , nPosIgual +1, Len(cItem) ) } )
   ENDIF
   
ENDDO

IF len( aOpc ) > 0            
   FOR F:= 1 TO LEN( aOpc )
	  IF ALLTRIM(aOpc[f][1]) == ALLTRIM(cChave)
	     cRet := aOPc[f][2]
	  EndIF
   NEXT
ENDIF



DBSELECTAREA( cAlias )

RETURN cRet



//------------------------------------------------------------------------------
//   U_SLDSA6( QRY->R_E_C_N_O_ , CTOD('01/01/08') )
user function SLDSA6( nRecnoSA6 , dDataRef )
LOCAL cAlias := ALIAS()
LOCAL cTpSaldo := "NOR"
CHKFILE("SA6")
CHKFILE("SE8")

	dbSelectArea("SA6")
	dbGoTo(nRecnoSA6)
	dbSelectArea("SE8")
	dbSetOrder( 1 )     
	//CONOUT("PASSO1") 
	//CONOUT(SE8->(INDEXKEY()) )
	//CONOUT(xFilial()+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS(dDataRef))
	DBSEEK(xFilial()+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS(dDataRef),.t.)
	IF .T.
		dbSkip( -1 )
		dDtSE8  := SE8->E8_DTSALAT
		lSldSE8 := .F. 
		nRecSE8 := SE8->(RECNO())
   	////CONOUT("PASSO2")

		While (  !Bof() .And. xFilial()==SE8->E8_FILIAL .And.;
						SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON == ;
						SE8->E8_BANCO+SE8->E8_AGENCIA+SE8->E8_CONTA .And.;
						SE8->E8_DTSALAT == dDtSE8 )
			nRecSE8 := SE8->(RECNO())
			dbSkip(-1)	
			lSldSE8 := .T.
		EndDo
		
		If ( lSldSE8 )
			If SE8->(Bof())
				dbGoTo(nRecSE8)
			Else
				dbSkip()
			Endif
		EndIf
	EndIf
	
	nValor := 0
	////CONOUT("PASSO3")
	
	While ( !Eof() .And. xFilial("SE8")==SE8->E8_FILIAL .And.;
			SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON == ;
		  	SE8->E8_BANCO+SE8->E8_AGENCIA+SE8->E8_CONTA .And.;
		   SE8->E8_DTSALAT <= dDataRef)
	   	////CONOUT("PASSO4")

			If cTpSaldo == "NOR"			//Normal
				nValor += SE8->E8_SALATUA
	   	////CONOUT("PASSO5")
			ElseIf cTpSaldo == "CON"    //Conciliado
				nValor += SE8->E8_SALRECO
			ElseIf cTpSaldo == "NCO"    //Nao Conciliado
				nValor += SE8->E8_SALATUA-SE8->E8_SALRECO
			EndIf
			dbSkip()
	Enddo
	
DBSELECTAREA( cAlias ) 
	   	////CONOUT("PASSO6")

return nValor 

                      
/******************************************************************************************
* METODO QUE RETORNA OS DADOS DE UM ARQUIVO TEMPORARIO GERADO A PARTIR DA ROTINA 
* APONTADA NO PARAMETRO. FUNGERATRB  -> DEVE SER SINTAXE ADVPL.
*
*/
                                                      
WsMethod GETTRB  WsReceive IDS, FUNGERATRB WsSend RetGetTRB WsService Sw_Dados

Local lOk := .T.
Local cErrorCode := "00"
Local cErrorMsg  := "OK"
//CONOUT("METODO GETTRB")
                       
//CONOUT( "::FUNGERATRB:"+::FUNGERATRB )
cFuncGeraTrb  :=   ::FUNGERATRB

cAliasTrb := &cFuncGeraTrb    // CHAMA FUNCAO QUE DEVERA RETORNAR UM ARQUIVO TEMPORARIO COM ALIAS ABERTO COMO "TRB"

IF SELECT(cAliasTrb) == 0 
   lOk := .F.
ENDIF


IF lOk 
	
	DBSELECTAREA(cAliasTrb)
	DBGOTOP()
	
	aHeader := {}
	aCols   := {}
	aTipos  := {}
	
	ChkFile("SX3")
	// =========================================================
	// MONTA ARRAY DO CABECALHO DO RETORNO 
	// =========================================================
	
	FOR F:=1 TO FCOUNT() 
	    
	    cCampo := FIELDNAME( F ) 
  	    CONOUT(CCAMPO)
	    SX3->(DBSETORDER(2))
	    IF  SX3->(DBSEEK(UPPER(PADR(cCampo,10)), .F. ))   // SE ACHOU CAMPO NO SX3
	        IF SX3->X3_TIPO $ "CNLDM"
		        cNome 	 := SX3->X3_TITULO 
		        cMascara := SX3->X3_PICTURE 
		        cTipo    := SX3->X3_TIPO
		        nTam     := SX3->X3_TAMANHO
		        nDec     := SX3->X3_DECIMAL
		        cValidac := "" 
		        cObrigat := "" //SX3->X3_OBRIGAT
		        lAdd := .T.
		    ELSE
		        lAdd := .f.
		    ENDIF
	    ELSE              
	        cNome 	 := cCampo
	        cMascara := ""
	        cTipo    := VALTYPE(fieldget(f))   //IF(VALTYPE(fieldget(f))="N", "N", "C" )
	        nTam     := IF( cTipo = "C" , LEN( FIELDGET(F) ), 0 )
	        nDec     := 0
	        cValidac := "" 
	        cObrigat := ""
	        lAdd := .T.
	    ENDIF
	    IF lAdd                                
	        CONOUT("CTIPO="+CTIPO)
	        AADD(ATIPOS , cTipo  )
	        
			AAdd( ::RetGetTRB:AHEADER , WSClassNew( "HEADER" ))
				
			oTemp := aTail(  ::RetGetTRB:AHEADER )
		
		    oTemp:CAMPO    := cCampo
		    oTemp:NOME     := cNome 
		    oTemp:MASCARA  := cMascara   
		    oTemp:TIPO     := cTipo 
		    oTemp:TAMANHO  := nTam
		    oTemp:DECIMAL  := nDec
		    oTemp:VALIDAC  := cValidac
		    oTemp:OBRIGAT  := cObrigat
		Endif
	NEXT
	
	// =========================================================
	// MONTA ARRAY DO CONTEUDO 
	// =========================================================
	
	dbSelectArea(cAliasTrb)
	nx := 0
	DO WHILE !EOF()
		   CONOUT("--------------")
	        aAux := {}                     
			// ============================        
	        // CARREGA CAMPOS DA TABELA    
			// ============================        
			FOR f:= 1 to FCOUNT()
				
				cTipo := aTipos[f]  
//				conout("HORA:"+TIME()+"CTIPO="+CTIPO)
				
				cConteudo := ""
				
				IF  cTipo  = "N"
					cCONTEUDO := REPLACE(  STR( fieldget(f) ) , ".","," )
				ELSEIF  cTipo = "C"
					cCONTEUDO := fieldget(f) 
				ELSEIF  cTipo = "M"
					cCONTEUDO := fieldget(f) 
				ELSEIF  cTipo  = "L"
					cCONTEUDO := IF ( fieldget(f) , "TRUE", "FALSE" )
				ELSEIF  cTipo  = "D"                
				    cCONTEUDO :=  DTOC( fieldget(f) )	
				    IF VALTYPE(fieldget(f)) = "C"
					    IF EMPTY( ALLTRIM(fieldget(f)) )
				       	cConteudo:= "01/01/1981"
				       ELSE
				      	cCONTEUDO :=  DTOC( STOD(fieldget(f)) )
				       ENDIF 
					 ELSE 
					     IF EMPTY(  fieldget(f)   )
					        cConteudo:= "01/01/1900" 
					     else
					        cCONTEUDO :=  DTOC( fieldget(f) )
					     endif
				    ENDIF
				    
				ENDIF			
				   conout(cConteudo)
	            AADD( aAux , cConteudo )
			NEXT                        
			
			AAdd( ::RetGetTRB:ACOLS, WSClassNew( "LINHAS" ))		
	
			oTempLinhas := aTail(  ::RetGetTRB:ACOLS ) 		
			oTempLinhas:CONTEUDO := aAux  

	        lOk := .T.
	   DBSKIP()
	ENDDO
	DBCLOSEAREA()

ENDIF


IF lOk 
    ::RetGetTRB:ErrorCode := cErrorCode 
    ::RetGetTRB:ErrorMSG  := "OK"
Else                               
    ::RetGetTRB:ErrorCode := "07" 
    ::RetGetTRB:ErrorMSG  := "Nao encontrado resultado."


    // dados HEADER
    // =============
 	AAdd( ::RetGetTRB:AHEADER , WSClassNew( "HEADER" ))
		
	oTemp := aTail(  ::RetGetTRB:AHEADER )

    oTemp:CAMPO    := ""
    oTemp:NOME     := ""
    oTemp:MASCARA  := ""
    oTemp:TIPO     := ""
    oTemp:TAMANHO  := 0
    oTemp:DECIMAL  := 0
    oTemp:VALIDAC  := ""
    oTemp:OBRIGAT  := ""

    // dados COLS 
    // =============

	AAdd( ::RetGetTRB:ACOLS, WSClassNew( "LINHAS" ))		
	oTempLinhas := aTail(  ::RetGetTRB:ACOLS ) 		
	oTempLinhas:CONTEUDO := {""}

ENDIF 

RETURN .T.                              


user function limpatxt( cTxt )
LOCAL cRet := ""

cRet := 	REPLACE( cTXT , '"', ' ')
cRet := 	REPLACE( cRet , "'", " ")
cRet := 	REPLACE( cRet , CHR(155), " ")
cRet := 	REPLACE( cRet , CHR(157), " ")

return cRet


