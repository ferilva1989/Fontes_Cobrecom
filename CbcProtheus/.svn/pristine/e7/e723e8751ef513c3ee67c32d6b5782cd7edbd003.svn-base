#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'


WSSTRUCT sCABEC
WSDATA CAMPOS AS ARRAY OF sCAMPO
ENDWSSTRUCT

WSSTRUCT sCAMPO
WSDATA NOMECAMPO AS STRING
WSDATA CONTEUDO  AS STRING
WSDATA TIPOVAL   AS STRING  // C=CARACTER , N=NUMERICO , L=LOGICO , D = DATA
ENDWSSTRUCT

WSSTRUCT sITENS
WSDATA LINHAS AS ARRAY OF sLINHA
ENDWSSTRUCT

WSSTRUCT sLINHA
WSDATA CAMPOS AS ARRAY OF sCAMPO
ENDWSSTRUCT

/********************************************************************
* Funcao que retorna array de CABEC para ser usado no sigaauto
*
*/

USER FUNCTION CONVCABEC( oEstru , cTab )
LOCAL f:= 1
LOCAL xConteudo := ""
LOCAL aRet := {}

aOCabec := oEstru:CAMPOS

FOR F:= 1 TO LEN( aOCabec )
	
	//    CONOUT( aOCabec[F]:NOMECAMPO + " -> "+ aOCabec[F]:CONTEUDO)
	
	xConteudo := Nil
	IF aOCabec[F]:TIPOVAL = "D"
		xConteudo := CTOD(aOCabec[F]:CONTEUDO)
	ELSEIF aOCabec[F]:TIPOVAL = "N"
		xConteudo := aOCabec[F]:CONTEUDO
		xConteudo := REPLACE(xConteudo, ".","")  // tira os pontos (milhares)
		xConteudo := REPLACE(xConteudo, ",",".")  // converte de virgula pra ponto
		xConteudo := VAL( xConteudo )
	ELSEIF aOCabec[F]:TIPOVAL = "C"
		xConteudo := aOCabec[F]:CONTEUDO
	ELSEIF aOCabec[F]:TIPOVAL = "L"
		xConteudo := IF( SUBS( aOCabec[F]:CONTEUDO ,1,1) = "T", .t., .F. )
	ENDIF
	
	IF xConteudo <> Nil
		AADD( aRet ,  { aOCabec[F]:NOMECAMPO , xConteudo , Nil } )
	ENDIF
NEXT

CONOUT("=====RECEBIDA ESTRUTURA=======")
for f := 1 to len( aRet )
	if valtype( aRet[f][2] ) = "C"
		cValor := aRet[f][2]
	elseif valtype( aRet[f][2] ) = "N"
		cValor := str( aRet[f][2] )
	elseif valtype( aRet[f][2] ) = "D"
		cValor := DTOC( aRet[f][2] )
	ELSE
		cValor := ""
	ENDIF
	
	CONOUT("->"+aRet[f][1]+" = " + cValor )
Next

CONOUT("===== FIMESTRUTURA =======")

IF !EMPTY( cTab )
	aRet := U_ORDEMSX3( aRet , cTab)
ENDIF


RETURN aRet


/********************************************************************
* Funcao que retorna array de ITENS para ser usado no sigaauto
*
*/
USER FUNCTION CONVITENS( oEstruArray )
LOCAL aRetArray := {}

aLinhas := oEstruArray:LINHAS

FOR F:= 1 TO LEN( aLinhas )
	
	aItem := U_CONVCABEC( aLinhas[f] )
	AADD( aRetArray , ACLONE( aItem ) )  
	
NEXT


RETURN aRetArray

/*********************************************************************************
* Funcao que coloca o array que será enviado ao SIGAAUTO na ordem do SX3.
* para evitar problemas...
*
*/
USER FUNCTION ORDEMSX3( aTab , cTab)
LOCAL aNewTab := {}
LOCAL lOk := .F.
LOCAL f := 0
LOCAL nPos := 0

IF !EMPTY( cTab )
	
	cTab := LEFT(UPPER(cTab) ,3 )
	SX3->(DBSETORDER(1))
	SX3->(DBSEEK( cTab , .t. ) )
	
	DO WHILE !SX3->(EOF())  .AND. ( SX3->X3_ARQUIVO = cTab )
		
		//	nPos := ASCAN( aTab , { |x| ALLTRIM(UPPER(x[1])) == ALLTRIM(UPPER(SX3->X3_CAMPO)) } )
		nPos := ASCAN( aTab , { |x|  mFill(x, SX3->X3_CAMPO)} )
		if nPos <> 0
			AADD( aNewTab , aTab[ nPos ] )  	// ADICIONA NO ARRAY QUE SERA RETORNADO
			ADEL( aTab    , nPos )
		Endif
		SX3->(DBSKIP())
	ENDDO
	
	// ADICIONA O QUE SOBRAR
	FOR nF:= 1 TO LEN( aTab )
		If(ValType(aTab[nf] )  =="A")      
			//AADD( aNewTab , aTab[n f ] )
		EndIf
	NEXT
ELSE
	aNewTab := ACLONE( aTab )
ENDIF
RETURN aCLONE( aNewTab )

Static Function mFill(aFill, cCampo)
Local lRet:= .F.
If(ValType(aFill)   =="A")
	If  (ALLTRIM(UPPER(aFill[1]) ) == ALLTRIM(UPPER(cCampo)) )
		lRet:=.T.
	EndIf
EndIf
Return lRet


USER FUNCTION TXTLOG( cArqLog )
LOCAL cTexto := ""

nHandle := FOPEN( cArqLog )
cBuffer := ""
DO WHILE FREAD( nHandle , @cBuffer , 1024 ) > 0
	cTexto += cBuffer
	cBuffer := ""
ENDDO

RETURN cTexto




USER FUNCTION SETCAMPO( aCmp , cCampo , cConteudo )
//conout( aCmp[1] )
nPos := ASCAN( aCmp , { |x| ALLTRIM(UPPER(x[1])) == ALLTRIM(UPPER(cCampo)) } )

IF ( nPos == 0 )
	AADD( aCmp , { cCampo , cConteudo , Nil } )
ELSE
	aCmp[nPos][2] := cConteudo
ENDIF

RETURN aCLONE( aCMP )


USER FUNCTION GETCAMPO( aCmp , cCampo  )

nPos := ASCAN( aCmp , { |x| ALLTRIM(UPPER(x[1])) == ALLTRIM(UPPER(cCampo)) } )

IF ( nPos == 0 )
	xConteudo := Nil
ELSE
	xConteudo := aCmp[nPos][2]
ENDIF

RETURN xConteudo

/*************************************************************************************************
* Funcao que verifica se o IDS refere-se a uma empresa/filial... e troca a empresa/filial aberta
*
*/


USER FUNCTION IDSFIL(cIDS)
LOCAL cAlias  := alias()
LOCAL nRegSM0 := SM0->(RECNO())

cEAnterior := cEmpAnt
cFAnterior := cFilAnt

//CONOUT("cIDS->" + cIDS)

IF SM0->(DBSEEK(left( cIDS , 4) , .F. ) )
	//CONOUT("ACHO EMPRESA OK...")
	IF cEmpAnt+cFilAnt <> LEFT( cIDS , 4 )  // TIVER QUE TROCAR DE EMPRESA
		
		nRegSM0 := sm0->(recno())
		
		DBCLOSEALL()
		RpcClearEnv()
		OpenSM0()
		sm0->(dbgoto(nRegSM0))
		RpcSetType(3)
		RpcSetEnv(FWCodEmp(), FWCodFil(),,,,, {})
		
		//conout("MUDANÇA DA EMPRESA DE "+cEAnterior+"/"+cFAnterior+" PARA "+cEmpAnt+"/"+cFilAnt )
	ENDIF
ELSE
	//CONOUT("NAO ACHOU EMPRESA ...")
	//SM0->(DBGOTO( nRegSM0 ) )
	SM0->(DBGOTOP())
	DBCLOSEALL()
	RpcClearEnv()
	OpenSM0()
	RpcSetType(3)
	RpcSetEnv(FWCodEmp(), FWCodFil(),,,,, {})
	//conout("FWCodEmp() "+ FWCodEmp())
	//conout("FWCodFil() "+ FWCodFil())
	
ENDIF

DBSELECTAREA( cAlias )

RETURN
