#include 'protheus.ch'
#include 'topconn.ch'

// Robert Santos - 02/12/2013
// Tela para Gerenciar Negociacao Pendente de Alterar Pedido Venda
*
************************
User Function CREST162()
************************
*
Local aCores 	:= {}
Local cAlias 	:= "ZZV"
Local cFiltro 	:= "!EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK == 'S'"
Local aIndex  	:= {}

Private cCadastro 	:= "CONTROLE DE NEGOCIACAO"
Private aRotina 	:= {}
Private nMV_DNEG 	:= GETMV('MV_DNEG')  //By Roberto Oliveira 29/05/14
Private bFiltraBrw 	:= { || FilBrowse( cAlias , @aIndex , @cFiltro ) }
Private __lAltPed 	:= .T.

AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. !EMPTY(ZZV_USERA)"	,"BR_VERDE"} ) // Finalizado COM ACEITE
AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK $ 'N '"	,"BR_PINK"} ) // FALTA SER APROVADO PARA ALTERAR O PEDIDO
AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK == 'S'"	,"BR_MARROM"} ) // FALTA ENCERRAR PELO APROVADOR INTERNO COBRECOM
AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'N' ","BR_BRANCO"} ) // Finalizado REJEITADO

AAdd( aCores, {" Val(ZZV_DIASEN) < nMV_DNEG ","BR_VERMELHO"} ) // VENCIDO  //By Roberto Oliveira 29/05/14

AAdd( aCores, {" EMPTY(ZZV_DTPRIM) ","BR_AMARELO"} ) // FALTA INICIAR ATENDIMENTO
AAdd( aCores, {" !EMPTY(ZZV_DTPRIM) ","BR_AZUL"} ) // EM NEGOCIACAO

AAdd( aRotina, {"Pesquisar"     ,"AxPesqui"  ,0,1} )
AAdd( aRotina, {"Visualizar"    ,"AxVisual"  ,0,2} )
AAdd( aRotina, {"Legenda"       ,"u_REST16l" ,0,2} )
AAdd( aRotina, {"Alt. Pedido"   ,"u_CEST162a",0,4} )
AAdd( aRotina, {"Proc.Alteracao","u_CEST162e",0,4} )
AAdd( aRotina, {"Rejeitar Alt." ,"u_CEST162b",0,4} )
AAdd( aRotina, {"Imprimir"      ,"u_CEST162i",0,2} )

DBselectarea("SC5")
DBsetorder(1)

Dbselectarea("SA1")
DBsetorder(1)

Eval( bFiltraBrw )
mBrowse( 6,1,22,75,cAlias,,,,,,aCores)
EndFilBrw(cAlias,@aIndex)
Return nil
*
******************************************
User function CEST162a(cAlias, nReg, nOpc)
******************************************
*
local aA := GetArea()
if SC5->(DBSEEK(ZZV->(ZZV_FILPV + ZZV_PEDIDO)))
	MATA410()
else
	Alert("Pedido: '" + ZZV->ZZV_PEDIDO + "' Filial: '" + ZZV->ZZV_FILPV + "' não encontrado!!!")
endif
RestArea(aA)
return
*
******************************************
User Function CEST162b(cAlias, nReg, nOpc)
******************************************
*
Local cMsg := ""
cMsg += "Atenção!" + CRLF
cMsg += "    Confirma rejeitar a solicitação aprovada pelo Cliente da alteração do Pedido venda?" + CRLF

if MsgYesNo(cMsg)
	u_CEST162x(.F.,ZZV->ZZV_FILPV,ZZV->ZZV_PEDIDO,ZZV->ZZV_FILIAL)
Endif
Return nil
*
*********************************************************
User function CEST162x(lAceite, cFilPv, cPedido, cFilNeg) // FAZER A APROVACAO REJEICAO DA NEGOCIACAO (FINAL)
*********************************************************
*
Local lOk := .T.
Local cMsg, cQry
Local aAr	:= GetArea()
Local cDE	:= GETMV("MV_XLOCALC") // LOCAL DE PRODUTOS EM NEGOCIACAO
Local cPARA	:= "01" // LOCAL DO RETORNO DA NEGOCIACAO
Local aRET, cZZV_ID

ZZV->(dbselectarea("ZZV"))

If select("TZZV1") > 0
	TZZV1->(dbclosearea())
EndIf
cQry := ""
cQry += "SELECT R_E_C_N_O_ NZZV " + CRLF
cQry += "FROM " + RETSQLNAME("ZZV") + " ZZV " + CRLF
cQry += "WHERE D_E_L_E_T_ = ' ' " + CRLF
cQry += "AND ZZV_FILIAL = '" + cFilNeg + "' " + CRLF
cQry += "AND ZZV_FILPV = '" + cFilPv + "' " + CRLF
cQry += "AND ZZV_PEDIDO = '" + cPedido + "' " + CRLF
cQry += "AND ZZV_DTENCE <> '' " + CRLF // APROVADO POR REPRESENTATEN
cQry += "AND ZZV_USERA = '' " + CRLF // EM ABERTO POR APROVADORES
TcQuery cQry new alias "TZZV1"
TZZV1->(DBGOTOP())
while !TZZV1->(EOF())
	ZZV->(dbgoto(TZZV1->(NZZV)))
	ZZV->(RECLOCK("ZZV",.F.))
	ZZV->ZZV_STATUS	:= iif(lAceite,"5","6")
	ZZV->ZZV_ACEITE	:= iif(lAceite,"S","N")
	ZZV->ZZV_USERA	:= UPPER(alltrim(cUserName))
	ZZV->(MSUNLOCK())
	
	if SC6->(dbseek(ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM ))) // ATUALIZAR A NEGOCIACAO DO ITEM DO PEDIDO DE VENDA
		SC6->(RECLOCK("SC6",.F.))
		SC6->C6_XNEGOC := ZZV->ZZV_STATUS
		// SC6->C6_XQTDNEG -= ZZV->ZZV_LANCEA // By Roberto Oliveira 26/01/2015
		SC6->C6_XQTDNEG -= ZZV->ZZV_LANCES // By Roberto Oliveira 26/01/2015
		if SC6->C6_XQTDRET <= 0
			SC6->C6_XQTDRET := 0
			SC6->C6_QTDRES := 0
		EndIf
		if SC6->C6_XQTDRET <= 0 .And. SC6->C6_XQTDNEG <= 0
			SC6->C6_XQTDNEG := 0
			SC6->C6_SEMANA := ""
		endif
		SC6->(MSUNLOCK())
	endif
	TZZV1->(DBSKIP())
	
	//If ZZV->ZZV_LOCAL == cDe .and. lAceite == .F. // fazer a transferencia do material do Negociacao para Estoque
	If !lAceite // fazer a transferencia do material do Negociacao para Estoque
		cZZV_ID := ZZV->ZZV_ID
		
		// By Roberto Oliveira - 26/01/2015
		// Toda a rotina foi alterada para tratar os empenhos no próprio SDC
		aRet := u_EmpSDC(.F.,"ZZV",ZZV->ZZV_PROALT,"01",;
						PadR(ZZV->ZZV_ACONAL + STRZERO(ZZV->ZZV_METRAL,5,0),TamSX3("BE_LocalIZ")[1]),;
						ZZV->(ZZV_LANCEA * ZZV_METRAL),ZZV->ZZV_ID,If(ZZV->ZZV_ACONAL=="B",ZZV->ZZV_NUMBOB,""),.F.)
		if !aRet[1]
			MsgAlert(aRet[2], 'ERRO')
			return(.F.)	
		endif
		
		ZZV->(dbseek(xFilial("ZZV") + cZZV_ID))
		ZZV->(RECLOCK("ZZV",.F.))
		ZZV->ZZV_LOCAL := cPara
		ZZV->(MSUNLOCK())
	EndIf
EndDo
TZZV1->(dbclosearea())
RestArea(aAr)
Return
*
******************************************
User Function CEST162e(cAlias, nReg, nOpc) // MARCAR O PEDIDO DE ALTERAR PEDIDO COMO CONCLUIDO
******************************************
*
Local AAREA := GETAREA()
Local aRET

if MsgYesNo("Confirma que o pedido foi alterado conforme o negociado?")
	if SC6->(DBSEEK(ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM)))
		ZZV->(RECLOCK("ZZV",.F.))
		ZZV->ZZV_STATUS	:= "7" // PEDIDO ALTERADO
		ZZV->ZZV_ACEITE	:= "S"
		ZZV->ZZV_USERA	:= UPPER(alltrim(cUserName))
		ZZV->(MSUNLOCK())
		
		SC6->(RECLOCK("SC6",.F.))
		SC6->C6_XNEGOC	:= ZZV->ZZV_STATUS // ACEITE ALTERADO
		//SC6->C6_XQTDNEG	-= ZZV->ZZV_LANCEA // By Roberto Oliveira 26/01/2015
		SC6->C6_XQTDNEG	-= ZZV->ZZV_LANCES// By Roberto Oliveira 26/01/2015
		if SC6->C6_XQTDRET <= 0
			SC6->C6_XQTDRET := 0
			SC6->C6_QTDRES := 0
		EndIf
		if SC6->C6_XQTDRET <= 0 .And. SC6->C6_XQTDNEG <= 0
			SC6->C6_XQTDNEG := 0
			SC6->C6_SEMANA := ""
		endif
		SC6->(MSUNLOCK())
	endif
Endif
RESTAREA(AAREA)
Return
