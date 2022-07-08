#include 'totvs.ch'
#include 'topconn.ch'

/*
Robert Santos
07.08.2013
Ao término de atualizar o orcamento
*/
user function MA415END

// ** Personalizacao WEB ** INICIO
local lOk := ( paramIxb[1] == 1 )
local nOpc := iif(paramIxb[2]==1,3,iif(paramIxb[2]==2,4,5))
local aArea := GetArea()    
local cC5_NUM := ""   
local cMsg := ""
local lAltera := .T.
   
local aButton := {}
local nxOpc := 0
			  
// ** Personalizacao WEB ** FIM


// ** Personalizacao WEB ** INICIO
if lOk .and. !empty(SCJ->CJ_XZZJID)
	if l415Auto .and. (nOpc == 3 .or. nOpc == 4) // Apenas para Batch e operaçoes de atualizacao e tem nro orcamento WEB
		CheckStatus( @cC5_NUM ) // Validar status de orçamentos WEB
		If nOpc == 4//Quando a alteração vem do portal 
			dbselectarea("ZZJ")
			dbsetorder(1)
			If ZZJ->(dbseek(xFilial("ZZJ")+SCJ->CJ_XZZJID))
				ZZJ->(reclock("ZZJ",.f.))
		    	ZZJ->(ZZJ_STATUS) := "B"
		    	ZZJ->(MSUNLOCK())
			EndIf
		Else
			AtuZZJ( nopc , cC5_NUM) // Atualizar tabela temporaria WEB
		EndIf   
	else	
		
		//Verifica se orçamento foi alterado F. não alterou e .T. alterou
		If lOrcAlterou //HOUVE ALTERAÇÂO #### Variavel publica declarada cdfat21.prw função AtuPortal()
			aadd( aButton ,  "Negociar" )
			aadd( aButton ,  "Reprovar" )
			
			cMsg := "Selecionar opção de status do orçamento." + CRLF
			cMsg += "    Negociar: Manter como bloqueado (em negociação)" + CRLF
			cMsg += "    Reprovar: Reprovado em definitivo Cobrecom" + CRLF
			
			nxOpc := Aviso("Análise do Orçamento" , cMsg , aButton )
			do case
				case nxOpc == 1
					SCJ->(RECLOCK("SCJ"), .F.)
					SCJ->(CJ_STATUS) := "F"
					SCJ->(MSUNLOCK())
				case nxOpc == 2
					SCJ->(RECLOCK("SCJ"), .F.)
					SCJ->(CJ_STATUS) := "C"
					SCJ->(MSUNLOCK())
			endcase
			AtuZZJ( nopc , cC5_NUM) // Atualizar tabela temporaria WEB
		Else //NÂO HOUVE ALTERAÇÂO ####
			aadd( aButton ,  "Negociar" )
			aadd( aButton ,  "Aprovar" )
			aadd( aButton ,  "Reprovar" )
			
			cMsg := "Selecionar opção de status do orçamento." + CRLF
			cMsg += "    Negociar: Manter como bloqueado (em negociação)" + CRLF
			cMsg += "    Aprovar: Aprovado pela Cobrecom" + CRLF
			cMsg += "    Reprovar: Reprovado em definitivo Cobrecom" + CRLF
			
			nxOpc := Aviso("Análise do Orçamento" , cMsg , aButton )
			do case
				case nxOpc == 1
					SCJ->(RECLOCK("SCJ"), .F.)
					SCJ->(CJ_STATUS) := "F"
					SCJ->(MSUNLOCK())
				case nxOpc == 2       
					SCJ->(RECLOCK("SCJ"), .F.)
					SCJ->(CJ_STATUS) := "A"
					SCJ->(MSUNLOCK())
				case nxOpc == 3
					SCJ->(RECLOCK("SCJ"), .F.)
					SCJ->(CJ_STATUS) := "C"
					SCJ->(MSUNLOCK())
			endcase
			AtuZZJ( nopc , cC5_NUM) // Atualizar tabela temporaria WEB	
		EndIf
	
	EndIf
		
EndIf

RestArea(aArea)
// ** Personalizacao WEB ** FIM

return .t.

// DOCUMENTACAO:
//---------------
// Alterar status conforme regras para orçamentos WEB
// Sendo elas:
// 1- Todos os itens tem que possuir estoque imediato informado pelo vendedor e ter estoque atual
// 2- Validar se os descontos oferecidos são superiores à:
//  a) carta de desconto + desconto de carta na manga (MV_DESCESP)
// Em sendo aprovado é executada rotina para gerar Pedido de vendas automaticamente
// Enviar e-mail para o Representante e para o Faturamento de que gerou pedido de vendas    
//
// Retornar nro do pedido de venda
static function CheckStatus( cC5_NUM )

local lBloq := .f.
local nGerente, cDescAd, cCarta, cDescMax, cqry, nqry
private aheadc6 := {} 
private aHeadD4 := {} 

// montar aheaders
monta01()

dbselectarea("SZX")
SZX->(dbsetorder(2)) 

dbselectarea("SCK")
SCK->(dbsetorder(1))     

dbselectarea("DA1")
DA1->(dbsetorder(1))   

if SZX->(dbseek(xFilial("SZX")+SCJ->CJ_TABELA)) // buscar carta de desconto
	cCarta := alltrim(SZX->ZX_COD)
	cQry := " select isnull(Max(ZY_DESCONT),'') ZY_DESCONT from "+retsqlname("SZY")+CRLF
	cQry += " where D_E_L_E_T_ = ' ' "+CRLF
	cQry += " and ZY_CODIGO = '"+cCarta+"' "+CRLF
	cQry += " and ZY_FILIAL = '"+xFilial("SZY")+"' "+CRLF
	if select("TMP_ROBERT")>0
   		TMP_ROBERT->(dbclosearea())
	endif
	tcquery cqry new alias "TMP_ROBERT"
	count to nqry
	if nqry > 0
		TMP_ROBERT->(dbgotop())
		cDescMax := TMP_ROBERT->(ZY_DESCONT)
	endif
	TMP_ROBERT->(dbclosearea())
else  
	cCarta := ""
	cDescMax := ""
endif

// valores de desconto limite
nGerente := GetMv("MV_DESCESP") // do gerente
cDescAd := U_CalcAdic( SCJ->CJ_TABELA , SCJ->CJ_VEND1 ,"",.F.) // desconto adicional Carta de descontos

// Coletar informacoes
while SCK->(CK_FILIAL+CK_NUM) == SCJ->(CJ_FILIAL+CJ_NUM) .and. !SCK->(EOF()) .and. !lBloq
	
	if SCK->CK_STSITE == "2" // a Produzir
		lBloq := .t.
	else
		// Consultar saldo disponivel
		lBloq := GtSaldo(SCK->CK_PRODUTO, SCK->CK_ACONDIC, SCK->CK_METRAGE, SCK->CK_LANCES, SCJ->CJ_XFILVEN )
	endif
	
	if !lBloq // proxima validacao ?
		lBloq := VerDscto( cDescMax , cDescAd , nGerente , SCK->CK_PRCVEN, SCJ->CJ_TABELA, SCK->CK_PRODUTO ) // Validar desconto dado no item. Tem q ser inferior a carta, adicional da carta + carta na manga		
	endif
	
	SCK->(dbskip())
enddo

if !lbloq
	// Converter em pedido de vendas
	// ConvPed()
	
	// Enviar e-mail do pedido de vendas
else
	// Marcar como bloqueado
	SCJ->(reclock("SCJ",.f.))
	SCJ->CJ_STATUS := "F"
	SCJ->(msunlock())
endif

return

// Pegar saldo atual do produto e validar se tem condicoes de atender
static function GtSaldo(cB1_COD, cAcond, nMetrag, nLance, cXFil )

local lFalhou := .f.
local cQry, nQry
local cLocaliz := cAcond + strzero(nMetrag,5,0)

if cAcond == "B" // para bobinas
	cQry := " select Sum(ZE_QUANT) SALDO "
	cQry += " from "+retsqlname("SZE")+" ZE"
	cQry += " where D_E_L_E_T_ = ' ' "+CRLF
	cQry += " and ZE_STATUS = 'T' "+CRLF
	cQry += " and ZE_QUANT > 0 "+CRLF
	cQry += " and ZE_PRODUTO = '" + alltrim(cB1_COD) + "' "+CRLF    
	cQry += " and ZE_FILIAL = '"+cXFil+"' "+CRLF
else // para demais
	cQry := " select Sum(BF_QUANT-BF_EMPENHO) SALDO "+CRLF
	cQry += " from "+retsqlname("SBF")+" BF "+CRLF
	cQry += " where D_E_L_E_T_ = ' ' "+CRLF
	cQry += " and BF_FILIAL = '"+cXFil+"' "+CRLF
	cQry += " and BF_QUANT-BF_EMPENHO > 0 "+CRLF
	cQry += " and BF_PRODUTO = '"+alltrim(cB1_COD)+"' "+CRLF
	cQry += " and BF_LOCALIZ = '"+cLocaliz+"' "+CRLF
	cQry += " and BF_LOCAL = '01' "+CRLF
	cQry += " and SUBSTRING(BF_LOCALIZ,1,1) <> 'B' "+CRLF
endif

if select("TMP_ROBERT")>0
	TMP_ROBERT->(dbclosearea())
endif
tcquery cqry new alias "TMP_ROBERT"
count to nqry
if nqry > 0
	TMP_ROBERT->(dbgotop())
	lFalhou := TMP_ROBERT->(SALDO) < (nMetrag*nLance)
endif
TMP_ROBERT->(dbclosearea())

return lFalhou

// validar desconto dado no item
static function VerDscto( cDescMax , cDescAd , nGerente , nCK_PRCVEN, cCJ_TABELA, cCK_PRODUTO )

local lFalhou := .f.
local nPrcVen, nDesc, aDesc, i, j

if DA1->(dbseek(xFilial("DA1")+cCj_TABELA+cCK_PRODUTO))
	nPrcVen := DA1->DA1_PRCVEN
else 
	nPrcVen := 0
endif

if nPrcVen > 0
	if !empty(cDescMax) // retirar desconto maximo permitido da carta de desconto
		aDesc := StrToArray( alltrim(cDescMax), "+" )
		for i := 1 to len(aDesc)
			if !empty(aDesc[i])
				nDesc := Val( aDesc[i] )
				nPrcVen := nPrcVen - ( (nPrcVen*nDesc)/100 ) // abater desconto definido pelo gerente
			endif
		next
	endif 
	
	if !empty(cDescAd) // Retirar desconto adicional (caso houver)  
		aDesc := StrToArray( alltrim(cDescAd), "+" )
		for i := 1 to len(aDesc)
			if !empty(aDesc[i])
				nDesc := Val( aDesc[i] )
				nPrcVen := nPrcVen - ( (nPrcVen*nDesc)/100 ) // abater desconto definido pelo gerente
			endif
		next
	endif
	
	nPrcVen := nPrcVen - ( (nPrcVen*nGerente)/100 ) // abater desconto definido pelo gerente
	
	lFalhou := nCK_PRCVEN < nPrcVen // Preco de venda menor que o preco com descontos permitidos
else 
	lFalhou := .t. // sem tabela de preco !
endif

return lFalhou

// Atualizar status da tabela ZZJ
static function AtuZZJ(nOpc, cC5_NUM)

local cQry, nQry

dbselectarea("ZZJ")
dbsetorder(1)
if ZZJ->(dbseek(xFilial("ZZJ")+SCJ->CJ_XZZJID))
	if nOpc <= 4
		// atualizar status do temporario
		ZZJ->(reclock("ZZJ",.f.))
		ZZJ->ZZJ_CJNUM := SCJ->CJ_NUM
		do case
			case SCJ->CJ_STATUS == "A"
				ZZJ->ZZJ_STATUS := "A" // APROVADO
			case SCJ->CJ_STATUS == "B"
				ZZJ->ZZJ_STATUS := "A" // APROVADO
			case SCJ->CJ_STATUS == "C"
				ZZJ->ZZJ_STATUS := "R" // REJEITADO
			case SCJ->CJ_STATUS == "F"
			     If nOpc == 3
			     	ZZJ->ZZJ_STATUS := "B" // INCLUSÂO ORÇAMENTO STATUS NORMAL
			     Else
			     	ZZJ->ZZJ_STATUS := "F" // INCLUSÂO ORÇAMENTO STATUS NORMAL
			     EndIf
			case SCJ->CJ_STATUS == "D"
				ZZJ->ZZJ_STATUS := "B" // BLOQUEADO
		endcase
		
		if !empty(cC5_NUM)
			ZZJ->ZZJ_C5NUM := cC5_NUM
		endif    
		
		ZZJ->ZZJ_MSGAPR := ALLTRIM(SCJ->CJ_OBSAPR)                    
		
		ZZJ->(msunlock())
	elseif nopc == 5
		cQry := "delete "+RETSQLNAME("ZZK")+" where D_E_L_E_T_ = ' ' AND ZZK_ID = '"+ZZJ->ZZJ_ID+"' "
		TcSqlExec(cQry)
		cQry := "delete "+RETSQLNAME("ZZJ")+" where D_E_L_E_T_ = ' ' AND ZZJ_CJNUM = '"+SCJ->CJ_NUM+"' "
		TcSqlExec(cQry)
	endif
endif

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

static function ConvPed()
/*
	// METODO I - MA416PROC
	// configurar parametros para exportacao automatica
	MV_PAR01 := SCJ->CJ_NUM
	MV_PAR02 := SCJ->CJ_NUM
	MV_PAR03 := SCJ->CJ_EMISSAO
	MV_PAR04 := SCJ->CJ_EMISSAO
	MV_PAR05 := 1 // liberar pedido de venda

	// rotina automatica protheus
	Ma416Proc()
	
	
	// METODO II - MATA416
	aAux1 := {}     
	NI := 1         
	CCJ_NUM := SCJ->CJ_NUM
	aadd( aaux1, { { "CJ_NUM", SCJ->CJ_NUM , nil } , {posicione("SX3", 2, "CJ_NUM", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_CLIENTE", SCJ->CJ_CLIENTE , nil } , {posicione("SX3", 2, "CJ_CLIENTE", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_LOJA", SCJ->CJ_LOJA , nil } , {posicione("SX3", 2, "CJ_LOJA", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_TABELA", SCJ->CJ_TABELA , nil } , {posicione("SX3", 2, "CJ_TABELA", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_TRANSP", SCJ->CJ_TRANSP , nil } , {posicione("SX3", 2, "CJ_TRANSP", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_VEND1", SCJ->CJ_VEND1 , nil } , {posicione("SX3", 2, "CJ_VEND1", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_CONDPAG", SCJ->CJ_CONDPAG , nil } , {posicione("SX3", 2, "CJ_CONDPAG", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_TPFRETE", SCJ->CJ_TPFRETE , nil } , {posicione("SX3", 2, "CJ_TPFRETE", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_ENDENT1", SCJ->CJ_ENDENT1 , nil } , {posicione("SX3", 2, "CJ_ENDENT1", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_OBSAPR", SCJ->CJ_OBSAPR , nil } , {posicione("SX3", 2, "CJ_OBSAPR", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_OBSREPR", SCJ->CJ_OBSREPR , nil } , {posicione("SX3", 2, "CJ_OBSREPR", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_XZZJID", SCJ->CJ_XZZJID , nil } , {posicione("SX3", 2, "CJ_XZZJID", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_XFILVEN", SCJ->CJ_XFILVEN , nil } , {posicione("SX3", 2, "CJ_XFILVEN", "X3_ORDEM")} } )

	// ordenar com SX3
	aaux1 := aSort( aaux1 , , , {|x,y| x[2,1] < y[2,1] })	
	// formar cabecalho ordem
	aCabec := {}
	for ni:=1 to len(aaux1)
		aadd( aCabec , aaux1[ni,1] )
	next 
	
	SCK->(dbseek(xFilial("SCK")+SCJ->CJ_NUM))
	aItens := {}
	while SCK->(CK_FILIAL+CK_NUM) == SCJ->(CJ_FILIAL+CJ_NUM) .and. !SCK->(EOF())
		aAux1 := {}
		aadd( aaux1, { { "CK_NUM", SCK->CK_NUM , nil } , {posicione("SX3", 2, "CK_NUM", "X3_ORDEM")} } ) 
  		aadd( aaux1, { { "CK_PRODUTO", SCK->CK_PRODUTO , nil } , {posicione("SX3", 2, "CK_PRODUTO", "X3_ORDEM")} } )  
  		aadd( aaux1, { { "CK_PRCVEN", SCK->CK_PRCVEN , nil } , {posicione("SX3", 2, "CK_PRCVEN", "X3_ORDEM")} } )  
  		aadd( aaux1, { { "CK_LANCES", SCK->CK_LANCES , nil } , {posicione("SX3", 2, "CK_LANCE", "X3_ORDEM")} } )  
  		aadd( aaux1, { { "CK_METRAGE", SCK->CK_METRAGE , nil } , {posicione("SX3", 2, "CK_METRAGE", "X3_ORDEM")} } )  
  		aadd( aaux1, { { "CK_QTDVEN", (SCK->(CK_QTDVEN)) , nil } , {posicione("SX3", 2, "CK_QTDVEN", "X3_ORDEM")} } )  
  		aadd( aaux1, { { "CK_VALOR", SCK->CK_VALOR , nil } , {posicione("SX3", 2, "CK_VALOR", "X3_ORDEM")} } )  
  		aadd( aaux1, { { "CK_ACONDIC", SCK->CK_ACONDIC , nil } , {posicione("SX3", 2, "CK_ACONDIC", "X3_ORDEM")} } )  
  		aadd( aaux1, { { "CK_TES", SCK->CK_TES , nil } , {posicione("SX3", 2, "CK_TES", "X3_ORDEM")} } )  
					 
		// ordenar com SX3
		aaux1 := aSort( aaux1 , , , {|x,y| x[2,1] < y[2,1] })
		
  		aItem := {}  
		for ni:=1 to len(aaux1)
			aadd( aItem , aaux1[ni,1] )
		next 
		aAdd(aItens, aItem )
	
		SCK->(dbskip())
	enddo
	
	MATA416(aCabec,aItens)
	
	// STATUS ORCAMENTO A=Aberto;B=Aprovado;C=Cancelado;D=Noo Orþado
	SCJ->(dbseek(xfilial("SCJ")+CCJ_NUM))
	if (SCJ->CJ_STATUS = "B") // se estiver baixado finalizado
		cqry := "select isnull(max(C6_NUM),'') C6_NUM from "+retsqlname("SC6")+" where C6_NUMORC like '"+SCJ->CJ_NUM+"%' and D_E_L_E_T_ = ' ' "
		iif( select("TMP_ROBERT")>0, TMP_ROBERT->(dbclosearea()), )
		tcquery cqry new alias "TMP_ROBERT"
		count to nqry
		if nqry>0
			TMP_ROBERT->(dbgotop())
			cC5_NUM := TMP_ROBERT->C6_NUM
		endif		
		TMP_ROBERT->(dbclosearea())   
	endif
	*/
return