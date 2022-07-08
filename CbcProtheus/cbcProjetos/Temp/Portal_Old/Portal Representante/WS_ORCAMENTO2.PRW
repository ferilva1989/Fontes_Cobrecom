#INCLUDE 'totvs.ch'
#INCLUDE 'APWEBSRV.CH'
#include 'topconn.ch'

/*	Author: Robert Santos
	Date: 05 abr 2012
	Function: Gerenciamento de orçamentos
*/                                                
wsservice WS_ORCAMENTO2 description "Gerenciamento de Orçamentos - Controlador Microsiga"
// entrada
wsdata orcamento as orcamento_s

//saida
wsdata orcamento_ret as orcamento_ret_s2
wsdata orcamento_incluir_ret as orcamento_incluir_ret_s

// entrada para metodo aprovar
wsdata orc_aprovar as orc_aprovar_s
wsdata orc_aprv_ret as orc_aprv_ret_s

wsmethod Incluir description "Incluir novo Orçamento"
wsmethod Excluir description "Excluir Orçamento"
wsmethod Alterar description "Alterar Orçamento"
wsmethod Aprovar description "Aprovar orçamento em Pedido de Venda"

wsdata cCJ_NUM as string
wsdata cCJ_STSITE as string
wsmethod AprovarStatus description "Aprovar o Orçamento para Aprovado (somente status)"

wsdata cmessage as string
wsdata cacao as string
wsdata cpara as string
wsdata laprov as boolean
wsdata ca1_cod as string
wsdata ca1_loja as string
wsmethod WF_mod1 description "Enviar WF com Mensagem e Ação"      

wsmethod AtualizarStatus description "Verificar e atualizar status do orcamento para web"

wsdata ZZKJ as ZZKJ_s
wsmethod GravarZZKJ description "Gravar tabela temporária" 

wsdata cZZJ_ID as string
wsmethod AprovarZZKJ description "Enviar ZZJ e ZZK em SCJ e SCK"

wsdata CA as CA_S
wsmethod ClienteAceite description "Alterar Status do cliente"

endwsservice      

wsstruct CA_S
	wsdata cZZJ_ID as string
	wsdata cSTATUS as string
	wsdata cObs as string
endwsstruct

wsstruct ZZKJ_S    
	wsdata nOpc as float
	wsdata ZZJ as ZZJ_s optional
	wsdata ZZK as array of ZZK_s optional
endwsstruct                     

wsstruct ZZJ_s
	wsdata ZZJ_FILIAL as string optional
    wsdata ZZJ_ID as string optional
    wsdata ZZJ_CLIENT as string optional
    wsdata ZZJ_LOJA as string optional
    wsdata ZZJ_TABELA as string optional
    wsdata ZZJ_TRANSP as string optional
    wsdata ZZJ_VEND1 as string optional
    wsdata ZZJ_CONDPG as string optional
    wsdata ZZJ_TPFRETE as string optional
    wsdata ZZJ_ENDENT as string optional
    wsdata ZZJ_MSGAPR as string optional
    wsdata ZZJ_MSGREP as string optional
    wsdata ZZJ_TOTAL as float optional
    wsdata ZZJ_FILORI as string optional
    wsdata ZZJ_PROC as string optional
    wsdata ZZJ_DATA as date optional
    wsdata ZZJ_ENDCOB as string optional
    
    wsdata ZZJ_MENPCP as string optional
    wsdata ZZJ_PEDCLI as string optional
    wsdata ZZJ_MENNOT as string optional
endwsstruct

wsstruct ZZK_s
    wsdata ZZK_FILIAL as string optional
    wsdata ZZK_ID as string optional
    wsdata ZZK_COD as string optional
    wsdata ZZK_QTDVEN as float optional
    wsdata ZZK_PRCVEN as float optional
    wsdata ZZK_LANCES as float optional
    wsdata ZZK_METRAG as float optional
    wsdata ZZK_VALOR as float optional
    wsdata ZZK_COMIS as float optional
    wsdata ZZK_ACONDI as string optional
    wsdata ZZK_DESCDG as string optional
    wsdata ZZK_ZEROCM as string optional
    wsdata ZZK_STATUS as string optional
    wsdata ZZK_TES as string optional
endwsstruct

// estrutura de aprovar orcamento
wsstruct orc_aprovar_s   
	wsdata CJ_NUM as string
	wsdata CJ_CLIENTE as string
	wsdata CJ_LOJA as string
	wsdata LIBERAR as boolean 
	wsdata itemef as string // items de entrega futura para nao tornar pedido venda
endwsstruct        

wsstruct orc_aprv_ret_s
	wsdata CERRORCODE as string
	wsdata CERRORMSG as string
	wsdata C6_NUM as string optional
endwsstruct

// estrutura retorno
WsStruct orcamento_ret_s2
	WsData cErrorCode   As String
	WsData cErrorMsg   As String
EndWsStruct     

wsstruct orcamento_incluir_ret_s
	wsdata cErrorCode as string
	wsdata cErrorMsg as string
	wsdata CJ_NUM as string optional
	wsdata C5_NUM as string optional
	wsdata CJ_STATUS as string optional
endwsstruct
 
// entrada modelo
wsstruct orcamento_s
	WSDATA SCJ	AS SCABEC
	WSDATA SCK	AS SITENS
endwsstruct


// Method incluir
wsmethod Incluir wsreceive orcamento wssend orcamento_incluir_ret wsservice WS_ORCAMENTO2
 
local lok := .f.
local cmsg := "Processo não iniciado"
local nhdl := 0      
local acabec := {}
local aitens := {}   
local ccj_num := getsxenum("SCJ", "CJ_NUM")

private lmserroauto := .f.

// voltar
rollbacksx8()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preencher Cabecalho                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
acabec  := U_CONVCABEC(::orcamento:SCJ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preencher itens                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aitens	:=	U_CONVITENS(::orcamento:SCK)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONTEMPLA INCLUIR PEDIDO DE VENDA                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
acabec := U_ORDEMSX3(acabec,"SCJ")
              
// efetuar inclusao
begin transaction 

mata415( acabec , aitens, 3 ) // OPC 3 = INCLUIR
if lmserroauto
	// tratar excessao
	disarmtransaction() 
	lok := .f.
	makedir("\system\cobrecom_execauto\")
	mostraerro("\system\cobrecom_execauto\","orcamento.txt")   
	
	// ler arquivo de log
	nhdl := ft_fuse("\system\cobrecom_execauto\orcamento.txt")
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
	// reenviar informacoes do banco
	lok := .t.
	cmsg := "Orçamento cadastrado!"	
endif  
end transaction

// retorno
if lok
	orcamento_incluir_ret:cerrorcode := "00"    
	orcamento_incluir_ret:CJ_NUM := trim(ccj_num)
else
	orcamento_incluir_ret:cerrorcode := "01"   
	orcamento_incluir_ret:CJ_NUM := ""
endif  
orcamento_incluir_ret:cerrormsg := cmsg

return .t.    


// Method incluir
wsmethod Alterar wsreceive orcamento, ccj_num wssend orcamento_incluir_ret wsservice WS_ORCAMENTO2
 
local lok := .f.
local cmsg := "Processo não iniciado"
local nhdl := 0
local acabec := {}   
local aaux := {}
local aitens := {}
local ni := 0

private lmserroauto := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preencher Cabecalho                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
acabec  := U_CONVCABEC(::orcamento:SCJ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preencher itens                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aitens	:=	U_CONVITENS(::orcamento:SCK)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONTEMPLA INCLUIR PEDIDO DE VENDA                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
acabec := U_ORDEMSX3(acabec,"SCJ")
                                        
// adicionar numero para alterar
aadd( aaux, {"CJ_NUM", ::ccj_num , nil })
for ni := 1 to len(acabec)
	aadd( aaux, acabec[ni] )
next 
acabec := aaux 

dbselectarea("SCJ")
SCJ->(dbsetorder(1))
if SCJ->( dbseek(xfilial("SCJ")+::ccj_num ) )    

	// validar alteracao
	if SCJ->CJ_STATUS == "B" .and. SCJ->CJ_STSITE == "1" // aprovado (com itens para gerar)
		// verficar baixa parcial
		SCJ->( reclock("SCJ", .F. ))
		SCJ->CJ_STATUS := "A"
		SCJ->( msunlock() )
	endif 

endif

// efetuar inclusao
begin transaction

mata415( acabec , aitens, 4 ) // OPC 4 = ALTERAR
if lmserroauto
	// tratar excessao
	disarmtransaction()
	lok := .f.
	makedir("\system\cobrecom_execauto\")
	mostraerro("\system\cobrecom_execauto\","orcamento.txt")
	
	// ler arquivo de log
	nhdl := ft_fuse("\system\cobrecom_execauto\orcamento.txt")
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
	// reenviar informacoes do banco
	lok := .t.
	cmsg := "Orçamento alterado!"
endif
end transaction

// retorno
if lok
	orcamento_incluir_ret:cerrorcode := "00"
else
	orcamento_incluir_ret:cerrorcode := "01"
endif
orcamento_incluir_ret:cerrormsg := cmsg     
orcamento_incluir_ret:CJ_NUM := ::ccj_num

return .t.

// Method Excluir
wsmethod Excluir wsreceive ccj_num wssend orcamento_ret wsservice WS_ORCAMENTO2

local lok := .f.
local cmsg := "Processo não iniciado"
local nhdl := 0

local acabec := {}
local aitens := {}  

local ltempv := .f.

private lmserroauto := .f.

// posicionar orcamento e itens
dbselectarea("SCJ")
SCJ->( dbsetorder(1) )
if SCJ->( dbseek(xfilial("SCJ")+::ccj_num) ) 
	
	// preencher cabecalho
	aadd( acabec, { "CJ_NUM"		, SCJ->CJ_NUM		, nil } )
	aadd( acabec, { "CJ_CLIENTE"	, SCJ->CJ_CLIENTE	, nil } )
	aadd( acabec, { "CJ_LOJA"		, SCJ->CJ_LOJA		, nil } )
	aadd( acabec, { "CJ_TABELA"		, SCJ->CJ_TABELA	, nil } )
	aadd( acabec, { "CJ_CONDPAG"	, SCJ->CJ_CONDPAG	, nil } )
	aadd( acabec, { "CJ_TPFRETE"	, SCJ->CJ_TPFRETE	, nil } )
	
	dbselectarea("SCK")
	SCK->( dbsetorder(1) ) 
	SCK->( dbseek(xfilial("SCK")+SCJ->(CJ_NUM)) )
	while( SCK->(CK_NUM)==SCJ->(CJ_NUM) .and. !(SCK->(eof())) )
	
		aaux := {}
		aadd( aaux, { "CK_ITEM"		, SCK->CK_ITEM		, nil } )
		aadd( aaux, { "CK_PRODUTO"	, SCK->CK_PRODUTO	, nil } )
		aadd( aaux, { "CK_QTDVEN"	, SCK->CK_QTDVEN	, nil } )
		aadd( aaux, { "CK_PRCVEN"	, SCK->CK_PRCVEN	, nil } )
		aadd( aaux, { "CK_VALOR"	, SCK->CK_VALOR		, nil } )
		aadd( aaux, { "CK_TES"		, SCK->CK_TES		, nil } )
		aadd( aaux, { "CK_ACONDIC"	, SCK->CK_ACONDIC	, nil } )
		aadd( aaux, { "CK_LANCES"	, SCK->CK_LANCES	, nil } )
		aadd( aaux, { "CK_METRAGE"	, SCK->CK_METRAGE	, nil } )
		aadd( aitens, aaux ) 
		
		// verificar se gerou PV
		if( !empty(SCK->CK_NUMPV) )
			ltempv := .t.
			cmsg := "ORÇAMENTO POSSUI ITEM COM PEDIDO DE VENDA! NÃO PODE SER EXCLUÍDO!"
		endif

		SCK->( dbskip() )
	enddo
	
	// ordernar cabecalho
	acabec := U_ORDEMSX3( acabec , "SCJ" )
endif     

// verificacao   
if !ltempv // verificar que nao tem pedido de venda gerado
	if( empty(acabec) .or. empty(aitens) )
		cmsg := "ORCAMENTO NAO ENCONTRADO '"+::ccj_num+"' "
	else
		// efetuar exclusao
		begin transaction

		mata415( acabec , aitens, 5 ) // OPC 5 = excluir
		if lmserroauto
			// tratar excessao
			disarmtransaction()
			lok := .f.
			makedir("\system\cobrecom_execauto\")
			mostraerro("\system\cobrecom_execauto\","orcamento.txt")
			
			// ler arquivo de log
			nhdl := ft_fuse("\system\cobrecom_execauto\orcamento.txt")
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
			// reenviar informacoes do banco
			lok := .t.
			cmsg := "Orçamento '"+::ccj_num+"' Excluído!"
		endif
		end transaction
	endif   
endif

// retorno
if lok
	orcamento_ret:cerrorcode := "00"
else
	orcamento_ret:cerrorcode := "01"
endif
orcamento_ret:cerrormsg := cmsg

return .t.


// Metodo de aprovacao
wsmethod Aprovar wsreceive orc_aprovar wssend orc_aprv_ret wsservice WS_ORCAMENTO2

local lok := .f.
local cmsg := "Processo não iniciado" 
local cqry, nqry 
local citemef := trim(::orc_aprovar:itemef )

private aheadc6 := {} 
private aHeadD4 := {} 

// montar aheaders
monta01()

// abrir orcamento                                           
dbselectarea("SCJ")
SCJ->(dbsetorder(1)) //CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA                                                                                                                             

dbselectarea("SCK")
SCK->( dbsetorder(1) ) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_ 

if( SCJ->(dbseek(xfilial("SCJ")+orc_aprovar:CJ_NUM+orc_aprovar:CJ_CLIENTE+orc_aprovar:CJ_LOJA)) )
	
	// validar bloqueios
	if SCJ->CJ_XBL2 == "S"
		lok := .f.
		cmsg := "Bloqueado por condição financeira do cliente!"
	else
		// verificar status do orcamento
		if SCJ->CJ_STATUS $ "A,B"//A=Aberto;B=Aprovado;C=Cancelado;D=Noo Orþado
		
			// marcar itens para nao aprovar
			if( !empty(citemef) )
				CKSinal( citemef , .t. , '')
			endif
			
			// configurar parametros para exportacao automatica
			MV_PAR01 := SCJ->CJ_NUM
			MV_PAR02 := SCJ->CJ_NUM
			
			MV_PAR03 := SCJ->CJ_EMISSAO
			MV_PAR04 := SCJ->CJ_EMISSAO
			
			if orc_aprovar:LIBERAR
				MV_PAR05 := 1 // liberar pedido de venda
			else
				MV_PAR05 := 2 // nao liberar pedido de venda
			endif
			// rotina automatica protheus
			Ma416Proc()
			
			// STATUS ORCAMENTO A=Aberto;B=Aprovado;C=Cancelado;D=Noo Orþado
			SCJ->(dbseek(xfilial("SCJ")+orc_aprovar:CJ_NUM+orc_aprovar:CJ_CLIENTE+orc_aprovar:CJ_LOJA))
			if (SCJ->CJ_STATUS $ "A,B")
				lok := .t.
				cmsg := "Orçamento Aprovado!"
				
				// resgatar numero do pedido gerado
				cqry := "select max(C6_NUM) C6_NUM from "+retsqlname("SC6")+" where C6_NUMORC like '"+SCJ->CJ_NUM+"%' and D_E_L_E_T_ = ''"
				iif( select("QRY")>0, QRY->(dbclosearea()), )
				tcquery cqry new alias "QRY"
				count to nqry
				if nqry>0
					QRY->(dbgotop())
					orc_aprv_ret:c6_num := QRY->C6_NUM
				else
					lok := .f.
					cmsg := "Não pode gerar pedido!"
				endif      
				
				// retirar sinal dos itens do orcamento
				CKSinal( citemef , .f., QRY->C6_NUM )
				
				QRY->(dbclosearea())   
				
				// atualizar o status do orcamento
				SCK->( dbseek(xfilial("SCK")+SCJ->(CJ_NUM) ) )
				laux := .f.
				while !SCK->(eof()) .and. SCK->CK_NUM == SCJ->CJ_NUM
					if( empty(SCK->CK_NUMPV) )
						laux := .t. // possui item em aberto
						exit
					endif
					SCK->( dbskip() )
				enddo
				
				SCJ->( reclock("SCJ", .F. ))
				SCJ->CJ_XBL1 := "N"       
				
				if laux
					SCJ->CJ_STSITE := "5" // possui item em aberto manter bloqueado
				else
					SCJ->CJ_STSITE := "1" // totalmente liberado
				endif
				
				SCJ->( msunlock() )               
				
				// realizar através do site chamada do método para enviar e-mail para o faturamento usar o numero acima gerado
			else
				lok := .f.
				cmsg := "Orçamento não pode ser aprovado!"  
				
				CKSinal( citemef , .f., '' )
			endif
		else
			// retornar status do orcamento invalido
			lok := .f.
			do case
				case SCJ->CJ_STATUS == "C"
					cmsg := "Orçamento Cancelado!"
				case SCJ->CJ_STATUS == "D"
					cmsg := "Não Orçado!"
				otherwise
					cmsg := "Status inválido!"
			endcase
		endif
	endif
else
	lok := .f.
	cmsg := "Orçamento não localizado!"
endif

 
// retorno
if lok
	orc_aprv_ret:cerrorcode := "00"
else
	orc_aprv_ret:cerrorcode := "01"
endif  
orc_aprv_ret:cerrormsg := cmsg

return .t.   

// marcar item de pv
static function cksinal( citem, lmarcar, cc6_num )

if lmarcar
	cquery := " update "+retsqlname("SCK")+" set D_E_L_E_T_ = '*' " 
	cquery += " where CK_NUM = '"+SCJ->CJ_NUM+"' and CK_ITEM in ("+citem+") and D_E_L_E_T_ = '' "
else                                                                                                                          
	cquery := " update "+retsqlname("SCK")+" set D_E_L_E_T_ = '' "
	cquery += " where CK_NUM = '"+SCJ->CJ_NUM+"' and CK_ITEM in ("+citem+") and D_E_L_E_T_ = '*' "
endif
tcsqlexec( cquery )
/*
local aitem := strtoarray(citem, ";")
local ni := 0

dbselectarea("SCK")
SCK->( dbsetorder(1) )
for ni := 1 to len(aitem)
	if SCK->( dbseek(xfilial("SCK")+SCJ->(CJ_NUM)+aitem[ni]) ) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
		if lmarcar .and. Empty(SCK->CK_NUMPV)
			SCK->( reclock("SCK",.f.) )
			SCK->CK_NUMPV := "999999"
			SCK->( msunlock() )  
			
			CONOUT("MARCOU!! ITEM="+aitem[ni])
		else
			if alltrim(SCK->CK_NUMPV) == "999999"
				SCK->( reclock("SCK",.f.) )
				SCK->CK_NUMPV := ""
				SCK->( msunlock() )
			endif
		endif
	endif
next
*/
return

// montador de aheader auxiliar
static function monta01()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader do SC6                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC6",.T.)
While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
	If (  ((X3Uso(SX3->X3_USADO) .And. ;
			!( Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDEMP"  .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDENT") .And.;
			cNivel >= SX3->X3_NIVEL) .Or.;
			Trim(SX3->X3_CAMPO)=="C6_NUMORC" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_NUMOP"  .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_ITEMOP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OPC" )	
		Aadd(aHeadC6,{TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			If(Trim(SX3->X3_CAMPO)=="C6_NUMORC",".F.",SX3->X3_VALID),;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader do SD4                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SD4")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SD4" )
	If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		Aadd(aHeadD4,{ Trim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT })
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo    

return

// method
wsmethod AprovarStatus wsreceive cCJ_NUM, cCJ_STSITE wssend orc_aprv_ret wsservice WS_ORCAMENTO2
          
local lok := .f.
local cmsg := "NAO INICIADO"
local lcj_xbl2 := .f.

dbselectarea("SCJ")
SCJ->(dbsetorder(1))
if( SCJ->( dbseek(xfilial("SCJ")+::cCJ_NUM) ) )
	
	lcj_xbl2 := SCJ->CJ_XBL2 == "S"
	
	SCJ->( reclock("SCJ",.f.) )    
	
	if !lcj_xbl2 // validar que nao esta bloqueado com o financeiro
		SCJ->CJ_STSITE := ::cCJ_STSITE // marcar orcamento aprovado (enviado = 1)
	endif      
	
	SCJ->CJ_XBL1 := "N"
	SCJ->( msunlock() )         
	
	if !lcj_xbl2 // validar que nao esta bloqueado com o financeiro
		lok := .t.
		cmsg := ::cCJ_NUM+" aprovado!"
	else      
		lok := .f.
		cmsg := "Desbloqueado por gerente! Mas bloqueado pelo financeiro, verificar Limite de crédito/ Risco do cliente."
	endif
	
else
	cmsg := ::cCJ_NUM+" não encontroado!"
endif

// retorno
if lok
	orc_aprv_ret:cerrorcode := "00"
else
	orc_aprv_ret:cerrorcode := "01"
endif  
orc_aprv_ret:cerrormsg := cmsg
orc_aprv_ret:C6_NUM := ""

return .t.        

// method
wsmethod WF_mod1 wsreceive cCJ_NUM, cmessage, cacao, cpara, laprov, ca1_cod, ca1_loja wssend orc_aprv_ret wsservice WS_ORCAMENTO2
          
local lok	:= .f.
local cmsg	:= "NAO INICIADO" 
    
// verificar se manda só para o aprovador de parametro
if ::laprov
	::cpara := alltrim(lower(getmv("MV_CLIAPRV")))
endif

// enviar wf
u_cwf03( ::cCJ_NUM, ::cmessage, ::cacao, ::cpara, ::ca1_cod, ::ca1_loja )

// retorno
if lok
	orc_aprv_ret:cerrorcode := "00"
else
	orc_aprv_ret:cerrorcode := "01"
endif  
orc_aprv_ret:cerrormsg := cmsg
orc_aprv_ret:C6_NUM := ""

return .t.       


// method
wsmethod AtualizarStatus wsreceive cCJ_NUM wssend orcamento_incluir_ret wsservice WS_ORCAMENTO2
          
local lok	:= .f.
local cmsg	:= "NAO INICIADO"
local cqry	:= " SELECT COUNT(CK_VALOR) CK_VALOR FROM "+retsqlname("SCK")+" CK WHERE CK.D_E_L_E_T_ = '' AND CK_NUM  = '"+::cCJ_NUM+"' AND CK_NUMPV = '' "
local nqry	:= 0      
local cStatus := "5" //bloq

iif( select("QRY")>0 , QRY->(dbclosearea()),  )
tcquery cqry new alias "QRY"
count to nqry
if nqry > 0                          
	QRY->(dbgotop())   
	if QRY->(CK_VALOR) == 0
		cstatus := "1" // aprovado
	endif         
	
	cqry := " update "+retsqlname("SCJ")+" set CJ_STSITE = '"+cStatus+"' where CK.D_E_L_E_T_ = '' AND CK_NUM  = '"+::cCJ_NUM+"' AND CK_NUMPV = '' "
	tcsqlexec(cqry)
	
	QRY->(dbclosearea())      
	
	lok := .t.
	cmsg := "OK"
	
else
	cmsg := "ORCAMENTO NAO ENCONTRADO"
endif

// retorno
if lok
	orcamento_incluir_ret:cerrorcode := "00"
else
	orcamento_incluir_ret:cerrorcode := "01"
endif  
orcamento_incluir_ret:cerrormsg := cmsg
orcamento_incluir_ret:CJ_NUM := ::cCJ_NUM

return .t.


// method
wsmethod GravarZZKJ wsreceive ZZKJ wssend orcamento_incluir_ret wsservice WS_ORCAMENTO2

local lok	:= .t.
local cmsg	:= "INICIADO"
local cZZJ_ID := ""   
local cCJ_NUM := ""

dbselectarea("ZZJ")
ZZJ->(dbsetorder(1))	//ZZJ_FILIAL, ZZJ_ID, R_E_C_N_O_, D_E_L_E_T_

dbselectarea("ZZK")
ZZK->(dbsetorder(1))	//ZZK_FILIAL, ZZK_ID, R_E_C_N_O_, D_E_L_E_T_

dbselectarea("SCJ")
SCJ->(dbsetorder(1))	//CJ_FILIAL, CJ_NUM, CJ_CLIENTE, CJ_LOJA, R_E_C_N_O_, D_E_L_E_T_

dbselectarea("SCK")
SCK->(dbsetorder(1))	//CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_

//Valores nOpc:
// 3 => Inclusão
// 4 => Alteração
// 5 => Exclusão

if ::ZZKJ:nOpc == 4 .or. ::ZZKJ:nOpc == 5	//Alteração ou Exclusão
	if ZZJ->(dbseek(xFilial("ZZJ")+::ZZKJ:ZZJ:ZZJ_ID))  
		cZZJ_ID := ZZJ->ZZJ_ID  
		cCJ_NUM := ZZJ->ZZJ_CJNUM
		if !empty(ZZJ->ZZJ_C5NUM)
			lOk := .f.
			cMsg := "[AVISO] Não pode alterar/excluir já gerou o Pedido: ["+ZZJ->ZZJ_C5NUM+"]. Contate o Departamento de Vendas-Cobrecom."
		elseif empty(::ZZKJ:ZZJ:ZZJ_ID)
			lOk := .f.
			cMsg := "[ERRO] ID inválido. Comunique o Departamento de TI-Cobrecom."
		endif
	else
		lOk := .f.
		cMsg := "[ERRO] Arquivo ZZJ não encontrado. Comunique o Departamento de TI-Cobrecom."
	endif
endif
	
     //Utilizado para sempre que alterar na tabela ZZJ e tiver um SCJ relacionado tantar trava-lo pois pode estar sendo editado 
     //internamente pelo departamento de vendas
		If SCJ->(dbseek(xFilial("SCJ")+ZZJ->ZZJ_CJNUM)) .and. !SCJ->(rlock())
			lOk := .f.
			cMsg := "[AVISO] Não foi possível atualizar o registro. Favor tente mais tarde."	   
	    EndIF
	

if lOk
	//Inicia Transação
	BeginTran()
	do case
		case ::ZZKJ:nOpc == 3 .or. ::ZZKJ:nOpc == 4		//Inclusão ou Alteração
			if empty(::ZZKJ:ZZJ:ZZJ_ID)
				cZZJ_ID := GetSXENum("ZZJ","ZZJ_ID")	//Obtem e trava próximo ID
				ConfirmSX8()							//Grava ID (evitar utilização do mesmo número)
				::ZZKJ:nOpc := 3
				::ZZKJ:ZZJ:ZZJ_ID := cZZJ_ID
			else
				::ZZKJ:nOpc := 4
				cZZJ_ID := ::ZZKJ:ZZJ:ZZJ_ID
			endif
			
			if ::ZZKJ:nOpc == 4		//Alteração
				//Verifica se conseguiu travar o registro em ZZJ
				if  ZZJ->(dbseek(xFilial("ZZJ")+::ZZKJ:ZZJ:ZZJ_ID)) .and. ZZJ->(rlock())	//Posicionou antes no DBSeek
					//cQry := "delete "+retsqlname("ZZJ")+" where ZZJ_ID = '"+cZZJ_ID+"' "
					ZZJ->(dbDelete())
					//cQry := "delete "+retsqlname("ZZK")+" where ZZK_ID = '"+cZZJ_ID+"' "
					if ZZK->(dbseek(xFilial("ZZK")+ cZZJ_ID))
						while  ZZK->ZZK_ID == cZZJ_ID .and. !(ZZK->(eof()))
							if  ZZK->(rlock())
						 		ZZK->(dbDelete())
						  		ZZK->(msunlock())
						   		ZZK->(DbSkip())
						    else
						    	lOk := .f.
						    	cMsg := "[ERRO] Não conseguiu deletar ZZK. Comunique o Departamento de TI-Cobrecom."
						     	exit
						    endif
						enddo
					else
						lOk := .f.
				    	cMsg := "[ERRO] Não encontrou ZZK para deletar. Comunique o Departamento de TI-Cobrecom."
					endif
					//Destrava ZZJ
					ZZJ->(msunlock())
				else
					lOk := .f.
			    	cMsg := "[AVISO] Não foi possível fazer a alteração. Favor tente mais tarde."	//Não conseguiu travar ZZJ
				endif
			endif
			
			if lOk	//Inclusão ou Alteração (Se Alteração, deletou os registros anteriores para fazer uma nova inclusão)
				reclock("ZZJ", .t.)
				ZZJ->ZZJ_FILIAL		:= ::ZZKJ:ZZJ:ZZJ_FILIAL
				ZZJ->ZZJ_ID			:= cZZJ_ID
				ZZJ->ZZJ_CLIENT		:= ::ZZKJ:ZZJ:ZZJ_CLIENT
				ZZJ->ZZJ_LOJA		:= ::ZZKJ:ZZJ:ZZJ_LOJA
				ZZJ->ZZJ_TABELA		:= ::ZZKJ:ZZJ:ZZJ_TABELA
				ZZJ->ZZJ_TRANSP		:= ::ZZKJ:ZZJ:ZZJ_TRANSP
				ZZJ->ZZJ_VEND1		:= ::ZZKJ:ZZJ:ZZJ_VEND1
				ZZJ->ZZJ_CONDPG		:= ::ZZKJ:ZZJ:ZZJ_CONDPG
				ZZJ->ZZJ_TPFRETE	:= ::ZZKJ:ZZJ:ZZJ_TPFRETE
				ZZJ->ZZJ_ENDENT		:= ::ZZKJ:ZZJ:ZZJ_ENDENT
				ZZJ->ZZJ_MSGAPR		:= ::ZZKJ:ZZJ:ZZJ_MSGAPR
				ZZJ->ZZJ_MSGREP		:= ::ZZKJ:ZZJ:ZZJ_MSGREP
				ZZJ->ZZJ_TOTAL		:= ::ZZKJ:ZZJ:ZZJ_TOTAL
				ZZJ->ZZJ_FILORI		:= ::ZZKJ:ZZJ:ZZJ_FILORI
				ZZJ->ZZJ_PROC		:= ::ZZKJ:ZZJ:ZZJ_PROC
				ZZJ->ZZJ_DATA		:= ::ZZKJ:ZZJ:ZZJ_DATA
				ZZJ->ZZJ_STATUS		:= "F"	//FALTA ATUALIZAR COM ERP     
				ZZJ->ZZJ_ENDCOB		:= ::ZZKJ:ZZJ:ZZJ_ENDCOB
				ZZJ->ZZJ_MENPCP		:= ::ZZKJ:ZZJ:ZZJ_MENPCP
				ZZJ->ZZJ_PEDCLI		:= ::ZZKJ:ZZJ:ZZJ_PEDCLI
				ZZJ->ZZJ_MENNOT		:= ::ZZKJ:ZZJ:ZZJ_MENNOT
				if !empty(cCJ_NUM)
					ZZJ->ZZJ_CJNUM	:= cCJ_NUM
				endif                    
				for i:=1 to len(::ZZKJ:ZZK)
					reclock("ZZK", .t.)
					ZZK->ZZK_FILIAL	:= ::ZZKJ:ZZK[i]:ZZK_FILIAL
					ZZK->ZZK_ID		:= cZZJ_ID
					ZZK->ZZK_COD	:= ::ZZKJ:ZZK[i]:ZZK_COD
					ZZK->ZZK_QTDVEN	:= ::ZZKJ:ZZK[i]:ZZK_QTDVEN
					ZZK->ZZK_PRCVEN	:= ::ZZKJ:ZZK[i]:ZZK_PRCVEN
					ZZK->ZZK_LANCES	:= ::ZZKJ:ZZK[i]:ZZK_LANCES
					ZZK->ZZK_METRAG	:= ::ZZKJ:ZZK[i]:ZZK_METRAG
					ZZK->ZZK_VALOR	:= ::ZZKJ:ZZK[i]:ZZK_VALOR
					ZZK->ZZK_COMIS	:= ::ZZKJ:ZZK[i]:ZZK_COMIS
					ZZK->ZZK_ACONDI	:= ::ZZKJ:ZZK[i]:ZZK_ACONDI
					ZZK->ZZK_DESCDG	:= ::ZZKJ:ZZK[i]:ZZK_DESCDG
					ZZK->ZZK_ZEROCM	:= ::ZZKJ:ZZK[i]:ZZK_ZEROCM
					ZZK->ZZK_STATUS	:= ::ZZKJ:ZZK[i]:ZZK_STATUS
					ZZK->ZZK_TES	:= ::ZZKJ:ZZK[i]:ZZK_TES
                    ZZK->(msunlock())
				next
				//Destrava ZZJ
				ZZJ->(msunlock())
				//Destravar SCJ
				SCJ->(msunlock())
			endif
			
		case ::ZZKJ:nOpc == 5	//Exclusão
			if ZZJ->(dbseek(xFilial("ZZJ")+::ZZKJ:ZZJ:ZZJ_ID))
				//Verifica se conseguiu travar o registro em ZZJ
				if  ZZJ->(rlock())
					//Verifica se existe Orçamento no Protheus
					if !empty(ZZJ->ZZJ_CJNUM)
						//Pesquisa SCJ
						if SCJ->(dbseek(xFilial("SCJ")+ZZJ->ZZJ_CJNUM))
							//Verifica se conseguiu travar o registro em SCJ
							if SCJ->(rlock())
								//cQry := "delete "+retsqlname("SCJ")+" where CJ_NUM = '"+ZZJ->ZZJ_CJNUM+"' "
								SCJ->(dbDelete())
						        //cQry := "delete "+retsqlname("SCK")+" where CK_NUM = '"+ZZJ->ZZJ_CJNUM+"' "
						        if SCK->(dbseek(xFilial("SCK")+ ZZJ->ZZJ_CJNUM))
							     	while SCK->CK_NUM == ZZJ->ZZJ_CJNUM .and. !(SCK->(eof()))
							     		if  SCK->(rlock())
							     			SCK->(dbDelete())
							     			SCK->(msunlock())
							     			SCK->(DbSkip())
							     		else
							     			lOk := .f.
									    	cMsg := "[ERRO] Não conseguiu deletar SCK. Comunique o Departamento de TI-Cobrecom."
							     			exit
							     		endif
							 		enddo 	
								else
									lOk := .f.
							    	cMsg := "[ERRO] Não encontrou SCK para deletar. Comunique o Departamento de TI-Cobrecom."
								endif
								//Destrava SCJ
								SCJ->(msunlock())
							else
								lOk := .f.
						    	cMsg := "[AVISO] Não foi possível fazer a exclusão. Favor tente mais tarde."	//Não conseguiu travar SCJ
							endif
						else
							lOk := .f.
							cMsg := "[ERRO] Não encontrou encontrou SCJ para deletar. Comunique o Departamento de TI-Cobrecom."
						endif
					endif
					if lOk
						//cQry := "delete "+retsqlname("ZZJ")+" where ZZJ_ID = '"+cZZJ_ID+"' "
						ZZJ->(dbdelete())
						//cQry := "delete "+retsqlname("ZZK")+" where ZZK_ID = '"+cZZJ_ID+"' "
						if ZZK->(dbseek(xFilial("ZZK")+ cZZJ_ID))
							while ZZK->ZZK_ID == cZZJ_ID .and. !(ZZK->(eof()))
						 		if  ZZK->(rlock())
						  			ZZK->(dbDelete())
						    		ZZK->(msunlock())
						     		ZZK->(DbSkip())
						    	else
						    		lOk := .f.
							    	cMsg := "[ERRO] Não conseguiu deletar ZZK. Comunique o Departamento de TI-Cobrecom."
						     		exit
						     	endif
						    enddo 	
						else
							lOk := .f.
					    	cMsg := "[ERRO] Não encontrou ZZK para deletar. Comunique o Departamento de TI-Cobrecom."
						endif
					endif
					//Destrava ZZJ
					ZZJ->(msunlock())
				else
					lOk := .f.
					cMsg := "[AVISO] Não foi possível fazer a exclusão. Favor tente mais tarde."	//Não conseguiu travar ZZJ
				endif
			else
				lOk := .f.
				cMsg := "[ERRO] Não encontrou Orçamento(ZZJ) para excluir. Comunique o Departamento de TI-Cobrecom."
			endif
	endcase
endif
// retorno
if lok
	cMsg := "Orçamento atualizado com sucesso!"
	//ZZJ->(__DBPack()) Exemplos para deletar fisicamente
	//ZZK->(__DBPack())
	EndTran()
	orcamento_incluir_ret:cerrorcode := "00"
else
	DisarmTransaction()
	orcamento_incluir_ret:cerrorcode := "01"
endif
MsUnlockAll()
orcamento_incluir_ret:cerrormsg := cmsg
orcamento_incluir_ret:CJ_NUM := cZZJ_ID

return .t.


wsmethod AprovarZZKJ wsreceive cZZJ_ID wssend orcamento_incluir_ret wsservice WS_ORCAMENTO2  

local aRet := {}   
local nOpc
local cCJ_NUM := ""
local cMsg := "" 
local cC5_NUM := ""    

local la1_opened := .f.
local la3_opened := .f.

dbselectarea("ZZJ")
ZZJ->(dbsetorder(1))
if ZZJ->(DBSEEK(XFILIAL("ZZJ")+::cZZJ_ID))	
	
	If ZZJ->(rlock())
		if EMPTY(ZZJ->ZZJ_CJNUM) 
			nOpc := 3
		else         
			nOpc := 4
		endif
		
		aret := u_xrot0003(::cZZJ_ID, nOpc )
		if aret[1]  
			ZZJ->(DBSEEK(XFILIAL("ZZJ")+::cZZJ_ID))
			cCJ_NUM := aret[2]
			cC5_NUM := alltrim(ZZJ->ZZJ_C5NUM)
			cMsg := "Orçamento: '" + cCJ_NUM + "' atualizado com sucesso." 
	
			dbselectarea("SCJ")
			SCJ->( dbsetorder(1) )
			if( SCJ->( dbseek(xfilial("SCJ") + cCJ_NUM) ) )			
				dbselectarea("SA1")
				SA1->( dbsetorder(1) )
				la1_opened := SA1->(dbseek(xfilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA)))
				
				dbselectarea("SA3")
				SA3->( dbsetorder(1) )
				la3_opened :=  SA3->(dbseek(xfilial("SA3")+SCJ->(CJ_VEND1)))
				
				dbselectarea("SCK")
				SCK->( dbsetorder(1) ) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
				SCK->(dbseek(xfilial("SCK")+SCJ->(CJ_NUM)))
				
				u_cwf04(la1_opened,la3_opened) // enviar e-mail do orcamento alterado   
				// cMsg += " Enviado e-mail para o Faturamento!"
	   		endif   
	   		
			/*
			aMailRet := u_xMailOrder(cC5_NUM)
			if aMailRet[1]   
				cMsg += CRLF + "Enviado e-mail para faturamento!"   
			endif
			*/
		else 
			cMsg := aret[2]
		endif
	Else
	
	aret := {.f., "[AVISO] Não foi possível fazer a alteração. Por favor tente mais tarde."}
	
	EndIf			
else  
	aret := {.f., "ID NAO ENCONTRADO!"}
endif

// retorno
if aret[1]
	orcamento_incluir_ret:cerrorcode := "00"
else
	orcamento_incluir_ret:cerrorcode := "01"
endif
orcamento_incluir_ret:cerrormsg := cMsg
orcamento_incluir_ret:CJ_NUM := cCJ_NUM
orcamento_incluir_ret:C5_NUM := cC5_NUM
orcamento_incluir_ret:CJ_STATUS := aret[3]

return .t.


wsmethod ClienteAceite wsreceive CA wssend orcamento_incluir_ret wsservice WS_ORCAMENTO2  

local aRet := {}   
local nOpc
local cCJ_NUM := ""
local cMsg := "" 
local cC5_NUM := ""

dbselectarea("ZZJ")
ZZJ->(dbsetorder(1))

dbselectarea("SCJ")
SCJ->(dbsetorder(1))
if ZZJ->(DBSEEK(XFILIAL("ZZJ")+::CA:cZZJ_ID))
	if SCJ->(DBSEEK(XFILIAL("SCJ") + ZZJ->ZZJ_CJNUM))
		
		SCJ->(RECLOCK("SCJ",.F.))
		SCJ->CJ_STATUS := iif(::CA:cSTATUS=="G","A",::CA:cSTATUS)
		SCJ->CJ_OBSREPR += ::CA:cObs
		SCJ->(MSUNLOCK())
		
		ZZJ->(RECLOCK("ZZJ",.F.))
		ZZJ->ZZJ_STATUS := ::CA:cSTATUS
		ZZJ->(MSUNLOCK())
		
		aret := {.T., "OK!"}
	else
		aret := {.f., "ORCAMENTO NAO ENCONTRADO!"}
	endif
else  
	aret := {.f., "ID NAO ENCONTRADO!"}
endif

// retorno
if aret[1]
	orcamento_incluir_ret:cerrorcode := "00"
else
	orcamento_incluir_ret:cerrorcode := "01"
endif
orcamento_incluir_ret:cerrormsg := aRet[2]
orcamento_incluir_ret:CJ_NUM := ""
orcamento_incluir_ret:C5_NUM := ""
orcamento_incluir_ret:CJ_STATUS := ""

return .t.