#include "totvs.ch"
#include "rwmake.ch"
#include 'topconn.ch'
#include "tbiconn.ch"

static ADM_ZP1 := GetNewPar('XX_ADMZP1', '000001')

/*/{Protheus.doc} CbcInternalReserves
(long_description)
@author bolognesi
@since 22/03/2016
@version 1.0
@example
( local oReserve := CbcInternalReserves():newCbcInternalReserves() )
@description Classe responsavel pelos controles internos em um pedido 
de venda que contenha itens de reservas feitas pelo portal
/*/
class CbcInternalReserves 

	data oOrderItem
	data cErrorMsg
	data oArea
	data lOk

	method newCbcInternalReserves() constructor 
	method getErrorMsg()
	method setErrorMsg()
	method getOrderItem()
	method isAuto()	
	method killOrder()
	method orderOk()
	method creditRelease()
	method clearRes()

endclass

/*/{Protheus.doc} new
//Metodo construtor
@author bolognesi
@since 22/03/2016 
@version 1.0
@description Contrutor da classe
/*/
method newCbcInternalReserves(nRecno, nC9Rec) class CbcInternalReserves
	Default nRecno	:= 0
	Default nC9Rec 	:= 0

	::oArea := SigaArea():newSigaArea()

	If nRecno > 0 .And. nC9Rec > 0 
		::oOrderItem := CbcOrderItem():newCbcOrderItem(nRecno, nC9Rec)
	EndIf

return self

method getOrderItem() class CbcInternalReserves
return ::oOrderItem

method getErrorMsg() class CbcInternalReserves
return ::cErrorMsg

method setErrorMsg(ErrorMsg) class CbcInternalReserves
	::cErrorMsg := ErrorMsg
return

method isAuto() class CbcInternalReserves
return  _SetAutoMode() .Or. IsBlind()


/*/{Protheus.doc} killOrder
@author bolognesi
@since 01/08/2016
@version 2.0
@type method
@description Metodo utilizada para cancelar as reservas de pedidos que tenha sido (Excluidos/Cancelados)
a chamada deste metodo ocorre atraves dos PE (MT410TOK) ambos no fonte M410LIOK.PRW, existem duas formar de fazer:
oReserve cancela a reserva estornando os empenhos, oService define como Aguardando e cancela reserva pelo schedule
oService possibilita que uma reserva seja retirada de um (pedido/orçamento) e se ainda valida, incluida em um novo
oReserve já cancela mesmo que reserva ainda na validade.
(LEO/ROB) - 24/03/14 - 09h57 Verificar se o cancelamento é de um pedido: 
1-) Já liberado credito (campo c6_semana semana preenchido com 'ZP4')
1.a) Neste caso não pode mudar status da reserva no portal, pois responsabilidade
de expiração/estorno neste caso é do sistema existente de reservas(interno)
no portal mudar o status para cancelada a reserva, considerando que o sistema cancela a reserva  
2-) Não liberado credito nenhuma vez (campo c6_semana diferente de 'ZP4')
2.a) Neste caso ao cancelar pedido deve-se mudar o status da reserva no portal
pois a responsabilidade em cancelar reserva ainda esta com schedule do portal
/*/
method killOrder(_aHeader, _aCols) class CbcInternalReserves
	local oCancRes 
	local oBudget 	:= CbcbudgetManager():newCbcbudgetManager()
	local oService  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local cNrRes	:= ""
	local cSemana	:= ""

	::oArea:saveArea( {'SC6', 'SC5'} )
	DbSelectArea("SC6")
	DbSetOrder(1) 
	For nI:= 1 to Len(_aCols)
		cNrRes 	:= GDFieldGet("C6_ZZNRRES"	,nI, .F. , _aHeader, _aCols)
		cSemana	:= GDFieldGet("C6_SEMANA"	,nI, .F. , _aHeader, _aCols)
		If !Empty(cNrRes )  
			if  Alltrim(cSemana) $ 'ZP4'  
				oService:undoConfirm(xFilial("SC6"), GDFieldGet("C6_ZZNRRES",nI, .F. , _aHeader, _aCols), .T. )
				oService:cancelReserve(ADM_ZP1,xFilial("SC6"), GDFieldGet("C6_ZZNRRES",nI, .F. , _aHeader, _aCols))
			else	
				oService:undoConfirm(xFilial("SC6"), GDFieldGet("C6_ZZNRRES",nI, .F. , _aHeader, _aCols), .T. )
			endif
			oBudget:clrNumRes(GDFieldGet("C6_NUMORC",nI, .F. , _aHeader, _aCols))
		EndIf
	Next nI
	::oArea:backArea()
	FreeObj(oService)

return(self)

/*/{Protheus.doc} orderOk
@author bolognesi
@since 01/08/2016
@version 1.0
@type method
@description Metodo com a regra da validação final (TudoOk) do pedido (Inclusão/Alteração/Deleção)
a chamada deste metodo ocorre atraves do PE MT410TOK() que encontra-se no fonte (M410LIOK.PRW)
este metodo é utilizado para percorrer os itens do pedido e caso a linha esteja deletada e o campo 
de reserva preenchido deve ser cancelada a reserva no portal.
(LEO/ROB) - 24/03/14 - 09h57 Diferenciar o tratamento quando liberado credito semana ZP4 o sistema
existente tem responsabilidade em estornar a reserva, no portal apenas muda status para cancelado
do contrario o portal é responsavel em expirar a reserva.
/*/
method orderOk(_aHeader, _aCols) class CbcInternalReserves
	Local lRet 			:= .T.
	Local qtdRes		:= 0
	Local qtdSem		:= 0
	Local nI			:= 0
	Local oBudget 		:= CbcbudgetManager():newCbcbudgetManager()
	Local oService  	:= CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local cNrRes		:= ""
	local cSemana		:= ""
	Default _aHeader	:= {}
	Default _aCols		:= {}

	::oArea:saveArea( {'SC6', 'SC5'} )

	DbSelectArea("SC6")
	DbSetOrder(1) 
	For nI:= 1 to Len(_aCols)
		cNrRes 	:= GDFieldGet("C6_ZZNRRES"	,nI, .F. , _aHeader, _aCols)
		cSemana	:= GDFieldGet("C6_SEMANA"	,nI, .F. , _aHeader, _aCols)

		If !Empty(cNrRes)	
			If GDDeleted(nI, _aHeader, _aCols)
				
				if Alltrim(cSemana) $ 'ZP4'  
					oService:cancelReserve(ADM_ZP1,xFilial("SC6"), GDFieldGet("C6_ZZNRRES",nI, .F. , _aHeader, _aCols))
				else	
					oService:undoConfirm(xFilial("SC6"), GDFieldGet("C6_ZZNRRES",nI, .F. , _aHeader, _aCols), .T. )
				endif
				oBudget:clrNumRes(GDFieldGet("C6_NUMORC",nI, .F. , _aHeader, _aCols))

			Else
				qtdRes++
			EndIf
		Else
			If !GDDeleted(nI, _aHeader, _aCols)
				qtdSem++
			EndIf
		EndIf
	Next
	/* If qtdRes > 0 .And. qtdSem > 0
		MessageBox("[AVISO] - Em pedidos com itens de reservas, não podem conter itens para produzir ", "Aviso", 48)
		lRet := .F.
	Endif */

	::oArea:backArea()
	FreeObj(oService)
	::lOk := lRet
return

/*/{Protheus.doc} creditRelease
//Receptar a chamada liberação de crédito
@author bolognesi
@since 23/03/2016
@version undefined
@description metodo é chamado pelo PE MTA440C9 que ocorre
na liberação de credito, (Cada item liberado chama o PE) 
/*/
method creditRelease() class CbcInternalReserves
	::oArea:saveArea( {'SC6', 'SC5', 'SC9', 'SB2', 'SBF', 'SDC', 'SZR', 'SZE'} )	

	if  ::getOrderItem():isReserve()

		if  !updRes(self)

			if !::isAuto()
				MessageBox('[ERRO] ' +  ::getErrorMsg(), 'Aviso', 48)
				//TODO manda e-mail do erro
			EndIf

		endIf

	endIf
	::oArea:backArea()
return

/*/{Protheus.doc} clearRes
@author Roberto/Leonardo
@since 14/04/2016
@version 1.0
@type method
@description Esta função é utilizada para limpar todas as reservas, especificamente
quando estas reservas tem origem SDC = (Foi liberado Estoque para alterar o pedido)
mas este alteração não estorna a reserva apenas muda sua origem para "SDC" (Liberação com reserva)
Esta foi criada para quando o pedido segue o seu caminho Estoque liberado e tudo pronto, mas 
alguem precisa alterar o pedido, para isso utiliza-se o coneito de liberação de estoque mantendo a reserva
apos a alteração do pedido confirma neste momento cancela todas as liberações da vez anterior
e cria nova, lembrando que um pedido de reserva somente pode-se (Incluir ou Deletar Itens) 
Este metodo tambem deve ser chamado apos a exclusão do pedido
/*/
method clearRes(_cDocto) class CbcInternalReserves
	Default _cDocto  := ::getOrderItem():getNumero()
	//TODO TRATAR PADR
	SDC->(DbOrderNickName("SDCPED")) //DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
	SDC->(DbSeek(xFilial("SDC")+_cDocto,.F.))
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == _cDocto .And. SDC->(!Eof())
		If SDC->DC_ORIGEM # "SDC"
			SDC->(DbSkip())
			Loop
		EndIf

		// Localizar saldo no SBF
		SBF->(DbSetOrder(1))  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		SBF->(DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.))

		If SBF->(!Eof()) .And. SBF->BF_EMPENHO >= SDC->DC_QUANT
			RecLock("SBF",.F.) // Gravo o BF_RESERVA para garantir a quantidade
			SBF->BF_EMPENHO -= SDC->DC_QUANT
			MsUnLock()
		EndIf

		DbSelectArea("SB2")
		DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
		If DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.)
			RecLock("SB2",.F.)
			SB2->B2_RESERVA := SB2->B2_RESERVA - SDC->DC_QUANT
			MsUnLock()
		EndIf

		SDC->(RecLock("SDC",.F.))
		SDC->(DbDelete())
		SDC->(MsUnLock())
		SDC->(DbSkip())
	EndDo


	SC6->(DbSetOrder(1))

	SZR->(DbSetOrder(2)) // ZR_FILIAL+ZR_PEDIDO+ZR_ITEMPV
	SZR->(DbSeek(xFilial("SZR") + _cDocto,.F.))
	Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_PEDIDO == _cDocto .And. SZR->(!Eof())
		If SC6->(!DbSeek(xFilial("SC6")+SZR->ZR_PEDIDO+SZR->ZR_ITEMPV,.F.))
			SZR->(RecLock("SZR",.F.))
			SZR->(DbDelete())
			SZR->(MsUnLock())
		EndIf
		SZR->(DbSkip())
	EndDo

	SZE->(dbsetorder(2)) //ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
	SZE->(DbSeek(xFilial("SZE") + _cDocto,.F.))
	Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == _cDocto .And. SZE->(!Eof())
		If SC6->(!DbSeek(xFilial("SC6")+SZE->(ZE_PEDIDO+ZE_ITEM),.F.))
			SZE->(RecLock("SZE",.F.))
			SZE->ZE_STATUS := "T"
			SZE->ZE_RESERVA := "      "
			SZE->(MsUnLock())
		EndIf
		SZE->(DbSkip())
	EndDo


return (.T.)

Static Function updRes(oSelf) 
	Local nX		:= 0
	Local aNroBob	:= {}
	Local aRet		:= {}
	Local aRetBob	:= {}
	Local lOk		:= .T.
	Local cMsg		:= ""
	Local lSzr		:= .F.
	Local Prod		:= oSelf:getOrderItem():getProduto()
	Local Locali	:= oSelf:getOrderItem():getEnd()
	Local QtdEmp	:= oSelf:getOrderItem():getQtdEmp()
	Local Reserva	:= oSelf:getOrderItem():getReserva()
	Local Pedido	:= oSelf:getOrderItem():getNumero()
	Local Item		:= oSelf:getOrderItem():getItem()
	Local QtdVen	:= oSelf:getOrderItem():getQtdVen()
	Local nRecno	:= oSelf:getOrderItem():getRecno()
	Local oSC6		:= oSelf:getOrderItem():getUpdTab()
	Local C9Seq		:= oSelf:getOrderItem():getC9Seq()
	Local cLocal	:= oSelf:getOrderItem():getLocal()
	Local lFirst	:= oSelf:getOrderItem():isFirstTime()

	oSelf:clearRes()

	If oSelf:getOrderItem():getAcondic() == 'B'
		aNroBob := oSelf:getOrderItem():getNroBob()

		if !Empty(aNroBob)	
			If lFirst
				BeginTran()
				for nX := 1 To Len(aNroBob)
					AAdd(aRet , U_EmpSDC(.F.,'ZP4', Prod , '01', Locali, QtdEmp, Reserva, aNroBob[nX], .T., nX) )

					If aRet[nX,1]
						lSzr := u_GraveSZR(aNroBob[nX],Pedido,Item, .T.)	
					Endif

					if !aRet[nX,1]  
						lOk :=  .F.
						cMsg := aRet[nX,2]
						DisarmTransaction()
						Exit
					ElseIf !lSzr
						lOk :=  .F.
						cMsg := 'PROBLEMAS PARA GERAR NOVO SZR'
						DisarmTransaction()
						Exit
					endIf
				next nX
				EndTran()
			Else
				If Len(aNroBob) > 0
					If !U_CDLibEst("L",Prod, QtdEmp, cLocal, Locali, Pedido, Item, C9Seq,.F.,"","P")
						lOk :=  .F.
						cMsg := 'PROBLEMAS LIBERAÇÂO DE ESTOQUE BOBINAS'
					EndIf
				EndIf
			EndIf
		else
			lOk :=  .F.
			cMsg :='VERIFICAR PEDIDOS SEM DE RESERVA, SEM BOBINAS RESERVADAS'
		endif
		//TRATAMENTO PARA ROLOS
	Else

		If lFirst
			BeginTran()

			AAdd(aRet, U_EmpSDC(.F.,'ZP4', Prod , '01', Locali, QtdEmp, Reserva, '', .T. ,1))

			If aRet[1,1]

				If U_CDLibEst("L",Prod, QtdEmp, cLocal, Locali, Pedido, Item, C9Seq,.F.,"","P")	

					oSC6:addCpoVlr("C6_SEMANA", "ZP4")
					oSC6:addCpoVlr("C6_QTDRES", QtdVen)	

					If !oSC6:updTable(nRecno) 
						lOk 	:=  .F.
						cMsg	:= "[AVISO] - Atualização, Operação não realizada"
						DisarmTransaction()
					Endif

				Else
					lOk :=  .F.
					cMsg := 'PROBLEMAS LIBERAÇÂO DE ESTOQUE ROLOS'
					DisarmTransaction()
				EndIf
			Else
				lOk :=  .F.
				cMsg := aRet[1,2]
				DisarmTransaction()
			EndIf
			EndTran()

		Else

			If !U_CDLibEst("L",Prod, QtdEmp, cLocal, Locali, Pedido, Item, C9Seq,.F.,"","P")
				lOk :=  .F.
				cMsg := 'PROBLEMAS LIBERAÇÂO DE ESTOQUE ROLOS APOS PRIMEIRA LIBERAÇÂO'
			EndIf
		EndIf

	Endif

	if !lOk
		oSelf:setErrorMsg(cMsg)
	endIf

return lOk
