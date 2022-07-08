#INCLUDE 'totvs.ch'
#INCLUDE 'APWEBSRV.CH'
#include 'topconn.ch'

/*	Author: Robert Santos
	Date: 04 abr 2012
	Function: Gerenciamento de clientes
*/                                                
wsservice WS_CLIENTE description "Gerenciamento de clientes"
	// entrada
	wsdata cliente as cliente_s
	
	//saida
	wsdata cliente_ret as cliente_ret_s
	
	wsmethod Incluir description "Incluir novo cliente"        
	                                                     
	// analise de credito
	wsdata cod_cliente as string
	wsdata saldo_cliente as float
	wsmethod GetSaldo description "Ver Saldo do Cliente"
	
endwsservice

// estrutura retorno do cliente
WsStruct cliente_ret_s
	WsData cErrorCode   As String
	WsData cErrorMsg   As String
	WsData A1_COD   As String optional
	WsData A1_LOJA   As String optional
EndWsStruct  
 
// entrada cliente modelo
wsstruct cliente_s
	wsdata A1_NOME as string
	wsdata A1_NREDUZ as string
	wsdata A1_END as string
	wsdata A1_ENDCOB as string
	wsdata A1_PESSOA as string
	wsdata A1_CGC as string
	wsdata A1_INSCR as string
	wsdata A1_MUN as string
	wsdata A1_EST as string
	wsdata A1_BAIRRO as string
	wsdata A1_CEP as string
	wsdata A1_PAIS as string
	wsdata A1_CONTATO as string
	wsdata A1_TEL as string
	wsdata A1_EMAIL as string
	wsdata A1_LC as float
	wsdata A1_VEND as string  
	wsdata A1_XPOTENC as float
endwsstruct

// Method incluir
wsmethod Incluir wsreceive cliente wssend cliente_ret wsservice WS_CLIENTE
 
local lok := .f.
local cmsg := "Processo não iniciado"
local amata030 := {} 
local amata := {}

local cA1_CODPAIS, cA1_PAIS, cA1_CODMUN, ca1_cod, cA1_loja, cA1_TEL, cA1_DDD, aRet
local nhdl

private lmserroauto := .f.        

// validar cliente existente
dbselectarea("SA1")
SA1->( dbsetorder(3) )
if !(SA1->( dbseek(xfilial("SA1")+trim(::cliente:A1_CGC)) ))
	cA1_CODPAIS := posicione( "CCH", 2, xfilial("CCH")+trim(::cliente:A1_PAIS), "CCH_CODIGO") // tratar codigo do pais
	cA1_PAIS := posicione( "SYA", 2, xfilial("SYA")+trim(::cliente:A1_PAIS), "YA_CODGI")  
	cA1_CODMUN := getcodmun( ::cliente:A1_MUN, ::cliente:A1_EST )
	                        
	aRet := GtCodigo(alltrim(::cliente:A1_CGC)) // getsxenum("SA1","A1_COD") // buscar codigo do cliente
	ca1_cod		:= aRet[1]
	ca1_loja	:= aRet[2]
	
	cA1_TEL := replace(replace(alltrim(::cliente:A1_TEL),"(",""),")","")
	CA1_TEL := REPLACE(CA1_TEL,"-","")
	if len(cA1_TEL) >= 10 // POSSUI DDD
		cA1_DDD := Substr(cA1_TEL,1,2)
		cA1_TEL := Substr(cA1_TEL,3,len(cA1_TEL) - 2)
	else
		cA1_DDD := ""
	endif
	
	aadd( amata030, { { "A1_FILIAL", xfilial("SA1") , nil }			, {posicione("SX3", 2, "A1_FILIAL", "X3_ORDEM")} } ) // popular novo cliente 
	if aRet[3] == .F. // É INCLUSAO DUM CLIENTE FILIAL ?????
		aadd( amata030, { { "A1_COD", ca1_cod 	, nil }	  			, {posicione("SX3", 2, "A1_COD", "X3_ORDEM")} } )		
	endif                                                                                                                   
	aadd( amata030, { { "A1_LOJA", cA1_loja , nil }					, {posicione("SX3", 2, "A1_LOJA", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_NOME", ::cliente:A1_NOME, nil }			, {posicione("SX3", 2, "A1_NOME", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_NREDUZ", ::cliente:A1_NREDUZ, nil }		, {posicione("SX3", 2, "A1_NREDUZ", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_END", ::cliente:A1_END, nil }			, {posicione("SX3", 2, "A1_END", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_ENDCOB", ::cliente:A1_ENDCOB, nil }		, {posicione("SX3", 2, "A1_ENDCOB", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_CGC", ::cliente:A1_CGC, nil }			, {posicione("SX3", 2, "A1_CGC", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_INSCR", ::cliente:A1_INSCR, nil }		, {posicione("SX3", 2, "A1_INSCR", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_COD_MUN", cA1_CODMUN , nil }			, {posicione("SX3", 2, "A1_COD_MUN", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_EST", ::cliente:A1_EST, nil }			, {posicione("SX3", 2, "A1_EST", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_BAIRRO", ::cliente:A1_BAIRRO, nil }		, {posicione("SX3", 2, "A1_BAIRRO", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_CEP", ::cliente:A1_CEP, nil }			, {posicione("SX3", 2, "A1_CEP", "X3_ORDEM")} } )
	//aadd( amata030, { { "A1_CODPAIS", cA1_CODPAIS , nil }			, {posicione("SX3", 2, "A1_CODPAIS", "X3_ORDEM")} } )
	//aadd( amata030, { { "A1_PAIS", cA1_PAIS , nil }				, {posicione("SX3", 2, "A1_PAIS", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_CONTATO", ::cliente:A1_CONTATO, nil }	, {posicione("SX3", 2, "A1_CONTATO", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_DDD", cA1_DDD , nil }					, {posicione("SX3", 2, "A1_TEL", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_TEL", cA1_TEL , nil }					, {posicione("SX3", 2, "A1_TEL", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_EMAIL", ::cliente:A1_EMAIL, nil }		, {posicione("SX3", 2, "A1_EMAIL", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_LC", ::cliente:A1_LC, nil }		 		, {posicione("SX3", 2, "A1_LC", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_RISCO", "E", nil }						, {posicione("SX3", 2, "A1_RISCO", "X3_ORDEM")} } )     
	aadd( amata030, { { "A1_PESSOA", ::cliente:A1_PESSOA , nil }	, {posicione("SX3", 2, "A1_PESSOA", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_TIPO", "F" , nil }						, {posicione("SX3", 2, "A1_TIPO", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_SETOR", "R" , nil }						, {posicione("SX3", 2, "A1_SETOR", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_MSBLQL", "1" , nil }					, {posicione("SX3", 2, "A1_MSBLQL", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_SEGMENT", "99" , nil }					, {posicione("SX3", 2, "A1_SEGMENT", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_REVIS", "2" , nil }			 			, {posicione("SX3", 2, "A1_REVIS", "X3_ORDEM")} } )
	aadd( amata030, { { "A1_XPOTENC", ::cliente:A1_XPOTENC , nil }			 			, {posicione("SX3", 2, "A1_XPOTENC", "X3_ORDEM")} } )
	//aadd( amata030, { { "A1_VEND", ::cliente:A1_VEND , nil }		, {posicione("SX3", 2, "A1_VEND", "X3_ORDEM")} } )     
	     
	// ordenar com SX3
	amata030 := aSort( amata030 , , , {|x,y| x[2,1] < y[2,1] })
	
	// formar nova passagem de dados
	for i:=1 to len(amata030)
		aadd( amata, amata030[i,1] )
	next     
	
	// ajustar sx3
	ajustasx3(1)
	
	// efetuar inclusao
	begin transaction
	mata030( amata )
	if lmserroauto
		// tratar excessao  
		// rollbacksx8()
		
		disarmtransaction()
		lok := .f.
		makedir("\system\cobrecom_execauto\")
		mostraerro("\system\cobrecom_execauto\","cliente.txt")   
		
		// ler arquivo de log
		nhdl := ft_fuse("\system\cobrecom_execauto\cliente.txt")
		cmsg := "Erro!"
		if nhdl > 0     
			cmsg := ""
			while !ft_feof()
				cmsg += ft_freadln()+CRLF 
				ft_fskip()
			enddo      
		endif          
		ft_fuse()
		
	else 
		// tratar sucesso 
		// confirmsx8()
		
		// reenviar informacoes para o banco
		dbselectarea("SA1")
		dbsetorder(1)
		SA1->( dbseek(xfilial("SA1") + ca1_cod + cA1_loja) )
		SA1->( reclock("SA1",.f.) )
		SA1->A1_CODPAIS := cA1_CODPAIS
		SA1->A1_PAIS := cA1_PAIS   
		iif( !empty(::cliente:A1_VEND), SA1->A1_VEND := ::cliente:A1_VEND, )
		SA1->( msunlock() )
		
		lok := .t.
		cmsg := "Cliente cadastrado!"
		
		// retornar codigo gerado
		cliente_ret:a1_cod	:= ca1_cod
		cliente_ret:a1_loja	:= cA1_loja
		
		// enviar wf da inclusao
		u_cwf01( ca1_cod , cA1_loja )
		
	endif  
	end transaction  
	
	// restaurar sx3
	ajustasx3(2) 
else 
	lok := .f.
	cmsg := "Cliente já cadastrado!"+CRLF+CRLF+"Código/ Loja:"+SA1->(A1_COD)+"/"+SA1->A1_LOJA+" - "+trim(SA1->A1_NOME)
endif

// retorno
if lok
	cliente_ret:cerrorcode := "00"
else
	cliente_ret:cerrorcode := "01"
endif  
cliente_ret:cerrormsg := cmsg

return .t.
        
// retornar codigo do municipio
static function getcodmun( ccodmun, cest ) 

local cqry, nqry, caux
local cret := ""

// codigo do municipio   
caux := lower( ccodmun )
caux := replace( caux , "ã")
caux := replace( caux , "õ")

caux := replace( caux , "á")
caux := replace( caux , "é")
caux := replace( caux , "í")
caux := replace( caux , "ó")
caux := replace( caux , "ú")

caux := replace( caux , "à")
caux := replace( caux , "è")
caux := replace( caux , "ì")
caux := replace( caux , "ò")
caux := replace( caux , "ù") 

caux := replace( caux , "ä")
caux := replace( caux , "ë")
caux := replace( caux , "ï")
caux := replace( caux , "ö")
caux := replace( caux , "ü")

cqry := "select CC2_CODMUN from "+retsqlname("CC2")+" where CC2_EST = '"+upper(cest)+"' and CC2_MUN = '"+upper(caux)+"' and D_E_L_E_T_ = '' and CC2_FILIAL = '"+xfilial("CC2")+"'"
makedir("system\cobrecom_sql\")
memowrite("system\cobrecom_sql\cc2.sql", cqry)
iif( select("QRY")>0, QRY->(dbclosearea()),  )
tcquery cqry new alias "QRY"
count to nqry
if nqry > 0  
	QRY->( dbgotop() )
	cret := QRY->CC2_CODMUN
endif   
QRY->(dbclosearea())

return cret     

// ajustar sx3
// 1- altera
// 2- restaura
static function ajustasx3( nopc )

dbselectarea("SX3")
SX3->( dbsetorder(2) )             

// desbloquear campos
if nopc == 1
	SX3->( dbseek( "A1_CODPAIS" ) )
	SX3->(reclock("SX3",.F.))
	SX3->X3_OBRIGAT := ""
	SX3->( msunlock() ) 
	
	SX3->( dbseek( "A1_PAIS" ) )
	SX3->(reclock("SX3",.F.))
	SX3->X3_OBRIGAT := ""
	SX3->( msunlock() )	
elseif nopc == 2
	SX3->( dbseek( "A1_CODPAIS" ) )
	SX3->(reclock("SX3",.F.))
	SX3->X3_OBRIGAT := "€"
	SX3->( msunlock() ) 
	
	SX3->( dbseek( "A1_PAIS" ) )
	SX3->(reclock("SX3",.F.))
	SX3->X3_OBRIGAT := "€"
	SX3->( msunlock() )
endif

return
              
// retornar saldo do cliente enviar A1_COD+A1_LOJA
wsmethod GetSaldo wsreceive cod_cliente wssend saldo_cliente wsservice WS_CLIENTE

local saldo := sldCliente( cod_cliente , ddatabase , 1 /*moeda*/, .t. /*verificar titulos em aberto*/ ) // saldo a ser retornado    

::saldo_cliente := saldo

return .t.
                                

static function GtCodigo(cA1_CGC) // buscar codigo do cliente

local cQry, nQry
local aRet := {"","",.F.} // codigo loja
local lInclui := .F.

if len(cA1_CGC) == 14
	iif(select("TPSA1") > 0,TPSA1->(dbclosearea()),)
	cQry := "SELECT ISNULL(MAX(A1_COD),'') A1_COD, ISNULL(MAX(A1_LOJA),'') A1_LOJA  FROM " + RetSQLName("SA1") + " WHERE D_E_L_E_T_ = ' ' AND SUBSTRING(A1_CGC,1,8) = '" + Substr(cA1_CGC,1,8) + "' "
	tcquery cqry new alias "TPSA1"
	TPSA1->(dbgotop())
	if !EMPTY(TPSA1->(A1_COD))
		aRet[1] := TPSA1->A1_COD
		aRet[2] := Soma1(TPSA1->A1_LOJA)
	else
		lInclui := .T.
	endif
	TPSA1->(dbclosearea())	 
else
	lInclui := .T.
endif

if lInclui
	aRet[1] := getsxenum("SA1","A1_COD")
	aRet[2] := "01"
	RollbackSx8()
endif
aRet[3] := lInclui

return aRet