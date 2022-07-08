#include "totvs.ch"
#include "rwmake.ch"
#include 'topconn.ch'
#include "tbiconn.ch"'

/*/{Protheus.doc} budgetManager
@author bolognesi
@since 06/04/2016
@version 2.0
@example
oBudget := CbcbudgetManager():newCbcbudgetManager()
@description Classe responsavel pelas rotinas de associações entre 
as reservas no portal (ZP4) e os orçamentos (SCJ/SCK)
,esta classe herda dos metodos da classe SigaArea
/*/
class CbcbudgetManager FROM SigaArea
	data lOk
	data lTemRes
	data oSql
	data oBase

	method newCbcbudgetManager() constructor
	method getOk()
	method TemRes()
	method budgetReserve() 
	method budgetFilter()
	method budgetValid()
	method budgetResAll()
	method budgetExcel()
	method budgetToOrder()  
	method budgetOk()
	method defDtEntrega()
	method thisIsRes()
	method killBudget()
	method clrNumRes()
	method vldOrder()
	method backArea()
	method saveArea()	
	method vldQuotation()
	method vldItemQuotation()

endclass

/*/{Protheus.doc} newCbcbudgetManager
@author bolognesi
@since 31/03/2016 
@version 2.0
@example
oBudget := CbcbudgetManager():newCbcbudgetManager()
@description Construtor da classe 
/*/
method newCbcbudgetManager() class CbcbudgetManager
	::lOk 		:= .F.
	::lTemRes	:= .F.
	::oSql 		:= SqlUtil():newSqlUtil()
	::oBase 	:= ManBaseDados():newManBaseDados()
	_Super:newSigaArea()
return

/*/{Protheus.doc} getOk
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Obtem o valor da propriedade "lOk" responsavel
por guardar um logico a respeito das execuções dos metodos
desta classe 
/*/
method getOk()	class CbcbudgetManager
return ::lOk

/*/{Protheus.doc} saveArea
@author bolognesi
@since 07/04/2016
@version 1.0
@param aArea, array, Areas a serem preservadas
@type method
@description Classe de proxy para chamar o metodo herdado
da classe SigaArea, estes metodos são necessario pois apenas pode
utillar metodos de classes superiores(Herdado) dentro do corpo do metodos
da classe filha e não em funções,
/*/
method saveArea(aArea)	class CbcbudgetManager
	_Super:saveArea(aArea)	
return	

/*/{Protheus.doc} backArea
@author bolognesi
@since 07/04/2016
@version 1.0
@type method
/*/

method backArea()	class CbcbudgetManager
	_Super:backArea()
return

/*/{Protheus.doc} TemRes
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Obtem o conteudo da propriedade que defini se apos obter as reservas na função static getReserv(oSelf)
o produto contem alguma reserva mesmo que valores e quantidades não estejam iguais
/*/
method TemRes()	class CbcbudgetManager
return ::lTemRes

/*/{Protheus.doc} vldQuotation
@author bolognesi
@since 01/06/2017
@version undefined
@param cQuotationId, characters, ID da quotation
@param cErrorMessage, characters, Recebido por referencia, devolver msg de erro
@type method
@description Realiza as validações do orçamento do portal
utilizando o mesmos critérios do m410liok (validar todos os itens)
/*/
method vldQuotation(cQuotationId, cErrorMessage) class CbcbudgetManager
	local lRet 		:= .T.
	cErrorMessage 	:= ''
return(lRet)


/*/{Protheus.doc} vldItemQuotation
@author bolognesi
@since 20/03/2019
@version 1.0
@param oItem, object, descricao
@param cError, characters, descricao
@description Validação de linha tempo de digitação
/*/
method vldItemQuotation(oItem, cError) class CbcBudgetManager
	local lOk 		:= .T.
	vldMinBob(oItem, @cError, @lOk)
return(lOk)


/*/{Protheus.doc} vldOrder
@author bolognesi
@since 07/04/2016
@version 1.0
@type method
@description Metodo utilizado para permitir ou não a alteração
de determinados campos no SC6, quando o item estiver relacionado com
uma reserva não pode alterar SX3 WHEN DOS CAMPOS: ]
(C6->(C6_PRODUTO, C6_QTDVEN, C6_ACONDIC, C6_LANCES,C6_METRAGE,C6_DESCRI))
/*/
method vldOrder() class CbcbudgetManager
	Local lRet 		:= .T.
	Local cReserv	:= ""

	If !GDDeleted(n, aHeader, aCols)
		cReserv := GDFieldGet("C6_ZZNRRES",n, .F. , aHeader, aCols)
		If !Empty(cReserv) 	
			lRet := .F.
		EndIf
	EndIf
	If !lRet
		u_AutoAlert("Item do Pedido com Reserva no Portal. Não pode ser Alterado")
	EndIf
	::lOk := lRet
return

/*/{Protheus.doc} budgetFilter
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Metodo que realiza o filtro para consulta padrão ("RESPOR") associada ao campo "CK_ZZNRRES"
permite selecionar as reservas que poderam ser associadas ao cliente do orçamento em questão 
/*/
method budgetFilter() class CbcbudgetManager
	Local lRet
	Local nI := 0

	::saveArea({'TMP1'})	

	If Empty(TMP1->(CK_PRODUTO))
		lRet := (ZP4->(ZP4_STATUS) == '1' .AND. ZP4->(ZP4_CODCLI) == M->(CJ_CLIENTE) .AND. ZP4->(ZP4_LOJCLI) == M->(CJ_LOJA ))
	Else
		lRet := (ZP4->(ZP4_STATUS) == '1' .AND. ZP4->(ZP4_CODCLI) == M->(CJ_CLIENTE) .AND. ZP4->(ZP4_LOJCLI) == M->(CJ_LOJA );
		.AND. Alltrim(ZP4->(ZP4_CODPRO)) == Alltrim(TMP1->(CK_PRODUTO)) )
	EndIf

	If lRet
		TMP1->(DbGoTop())
		While TMP1->(!Eof())
			If  ZP4->(ZP4_CODIGO) == TMP1->(CK_ZZNRRES) //.And. !TMP1->(CK_FLAG)  
				lRet := .F.		
				exit
			EndIf
			TMP1->(DbSkip())
		EndDo
	EndIf

	::backarea()
	::lOk := lRet 
Return 

/*/{Protheus.doc} killBudget
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Metodo utilizada para cancelar as reservas de orçamentos que tenha sido (Excluidos/Cancelados)
a chamada deste metodo ocorre atraves dos PE (MT415EXC() e M415CANC()) ambos no fonte PE_MATA415.PRW
/*/
method killBudget() class CbcbudgetManager
	Local oCancRes 
	Local oService  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()

	DbSelectArea("TMP1")
	TMP1->(DbGoTop())

	While TMP1->(!Eof())
		If !Empty(TMP1->(CK_ZZNRRES))
			oService:undoConfirm(xFilial("ZP4"), TMP1->(CK_ZZNRRES), .T. )
		EndIf
		TMP1->(DbSkip())
	EndDo

return

/*/{Protheus.doc} budgetOk
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Metodo com a regra da validação final (TudoOk) do orçamento (Inclusão/Alteração)
a chamada deste metodo ocorre atraves do PE A415TdOk() que encontra-se no fonte (CDFAT21.PRW)
este metodo define a reserva no portal como Aguardando, seguindo a logica de expirar por tempo.
/*/
method budgetOk() class CbcbudgetManager
	Local lRet 		:= .T.
	Local qtdRes	:= 0
	Local qtdSem	:= 0
	Local oService  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()

	DbSelectArea("TMP1")
	TMP1->(DbGoTop())

	While TMP1->(!Eof())

		If !Empty(TMP1->(CK_ZZNRRES)) 	

			If TMP1->(CK_FLAG)
				oService:undoConfirm(xFilial("ZP4"), TMP1->(CK_ZZNRRES), .T. )
			ElseIf Expire()
				lRet := .F.
				MessageBox("[AVISO] - Item: " + TMP1->(CK_ITEM) + " esta com a reserva Nro: " +  TMP1->(CK_ZZNRRES) + ", expirada por favor verifique!" , "Aviso", 48) 
			Else
				oService:setConfirmed( xFilial("ZP4") , TMP1->(CK_ZZNRRES))
			EndIf

			If !TMP1->(CK_FLAG)
				qtdRes++
			EndIf
		Else
			If !TMP1->(CK_FLAG)
				qtdSem++
			EndIf

		EndIf
		TMP1->(DbSkip())
	EndDo                 
	If qtdRes > 0 .And. qtdSem > 0
		MessageBox("[AVISO] - Em orçamentos com itens de reservas, não podem conter itens para produzir ", "Aviso", 48)
		lRet := .F.
	Else
		//Definir a data de entrega, para um orçamento
		::defDtEntrega()
	Endif 

	::lOk := lRet
return

/*/{Protheus.doc} defDtEntrega
@author bolognesi
@since 15/08/2016
@version 2.0
@type method
@description Metodo para definir no orçamento(somente orçamento de reservas) qual a data de entrega
os outros orçamentos permanecem como eram, utiliza as variaveis M->CJ_
/*/
method defDtEntrega() class CbcbudgetManager
	if ::thisIsRes('TMP1')
		_Super:saveArea({'SCK','SCJ'})
		if Inclui
			M->CJ_ENTREG := DataValida(DaySum(Date(), GetNewPar('MV_PRENRES', 1)), .T.)
		ElseIf Altera
			M->CJ_ENTREG := Posicione("SCJ",1,xFilial("SCJ")+ M->(CJ_NUM + CJ_CLIENTE + CJ_LOJA),"CJ_ENTREG") 
		EndIf
		_Super:backArea()

		//Definir a data de entrega para todos os itens
		_Super:saveArea({'TMP1'})
		DbSelectArea("TMP1")
		TMP1->(DbGoTop())
		While TMP1->(!Eof())
			RecLock("TMP1",.F.)
			TMP1->(CK_ENTREG) := M->(CJ_ENTREG)
			TMP1->(MsUnLock())
			TMP1->(DbSkip())
		EndDo                 
		_Super:backArea()		
	EndIf
return(self)

/*/{Protheus.doc} clrNumRes
@author bolognesi
@since 17/08/2016
@version 2.0
@type method
@description Devido a query da classe OppBalanceService Victor Hugo que 
utilizar left join com orçamento tendo como chave numero da reserva do orçamento 
quando excluir um Pedido deve eliminar tambem o campo CK_ZZNRRES do Orçamento Correspondente
para evitar que a query duplique os valores mostrados 
/*/
method clrNumRes(cNumItem) class CbcbudgetManager
	Local cNum 
	Local cItem
	Default cNumItem 	:= " " 

	if !empty(cNumItem)
		cNumItem 	:= Padr(cNumItem,TamSx3("CK_NUM")[1] + TamSx3("CK_ITEM")[1])
		cNum		:= Left(cNumItem,TamSx3("CK_NUM")[1]) 
		cItem 		:= Right(cNumItem,TamSx3("CK_ITEM")[1])

		_Super:saveArea({'SCJ', 'SCK'})
		//CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO
		::oBase:setOrd("SCK",1)
		::oBase:addKey({cNum , cItem })
		::oBase:addCpoVlr('CK_ZZNRRES','')
		::oBase:updTable()	
		_Super:backArea()
	endif
return


/*/{Protheus.doc} thisIsRes
@author bolognesi
@since 15/08/2016
@version 2.0
@example oBudget := CbcbudgetManager():newCbcbudgetManager():thisIsRes(cFrom, cNumDoc)
@type method
@description Metodo que percorre os itens de um orçamento, e retorna se este orçamento é um Orçamento de
reserva ou um orçamento Normal (.T. = Reserva, .F. = Normal), funciona para TMP01 e tambem direto SCK bastando
informar cFrom(TMP1 ou SCK), e quando for SCK informar o numero do Orçamento
/*/
method thisIsRes(cFrom, cNumDoc) class CbcbudgetManager 
	Local lRet 		:= .F.
	Local qtdRes	:= 0
	Local qtdSem	:= 0
	Local nI		:= 0
	Default cNumDoc	:= ""
	cNumDoc 		:= Padr(cNumDoc,TamSx3("CK_NUM")[1] )

	If cFrom == 'SCK'
		_Super:saveArea({'SCJ', 'SCK'})
		DbSelectArea("SCK")
		//CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO
		SCK->(dbsetorder(1))
		SCK->(DbSeek(xFilial("SCK") + cNumDoc ,.F.))

		While SCK->CK_FILIAL == xFilial("SCK") .And. SCK->CK_NUM == cNumDoc .And. SCK->(!Eof())
			If !Empty(SCK->(CK_ZZNRRES)) 	
				qtdRes++
			Else
				qtdSem++
			EndIf
			SCK->(DbSkip())
		EndDo
		_Super:backArea()
	ElseIf cFrom == 'SC6'
		_Super:saveArea({'SC5', 'SC6'})
		DbSelectArea("SC6")
		//C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO
		SC6->(dbsetorder(1))
		SC6->(DbSeek(xFilial("SC6") + cNumDoc ,.F.))

		While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cNumDoc .And. SC6->(!Eof())
			If !Empty(SC6->(C6_ZZNRRES)) 	
				qtdRes++
			Else
				qtdSem++
			EndIf
			SC6->(DbSkip())
		EndDo
		_Super:backArea()
	ElseIf cFrom == 'TMP1'
		_Super:saveArea({'TMP1'})
		DbSelectArea("TMP1")
		TMP1->(DbGoTop())
		While TMP1->(!Eof())
			If !Empty(TMP1->(CK_ZZNRRES)) 	
				If !TMP1->(CK_FLAG)
					qtdRes++
				EndIf
			Else
				If !TMP1->(CK_FLAG)
					qtdSem++
				EndIf
			EndIf
			TMP1->(DbSkip())
		EndDo                 
		_Super:backArea()
	ElseIf cFrom == 'ACOLS'
		For nI:= 1 to Len(aCols)
			//If !GDDeleted(nI)
			If !Empty(GDFieldGet("C6_ZZNRRES",nI)) 	
				qtdRes++
			Else
				qtdSem++
			EndIf
			//EndIf
		Next
	EndIf

	If qtdRes > 0
		lRet := .T.
	Endif 
return lRet

/*/{Protheus.doc} budgetToOrder
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Metodo responsavel por persistir as informçãoes do numero de reserva do campo Ck_ZZNRRES para C6_ZZNRRES
chamada deste metodo ocorre atraves do ponto de entrada MTA416PV() localizado no fonte (CDFAT21.PRW) na chamada MTA416PV
os campos CJ_ENTREGA x C5_ENTREG já são transportados porem alterados pela função AvalPrz() . 
/*/
method budgetToOrder() class CbcbudgetManager
	Local nI	:= 0
	Local nOrc	:= ""
	For nI:= 1 To Len(_aCols)
		IF !GDDeleted(nI, _aHeader, _aCols)
			nOrc := GDFieldGet("C6_NUMORC",nI, .F. , _aHeader, _aCols)
			If nOrc == SCK->(CK_NUM+CK_ITEM) 	
				GdFieldPut("C6_ZZNRRES"	,SCK->(CK_ZZNRRES), nI, _aHeader, _aCols, .F.)
			EndIf
		EndIf
	Next nI
return

/*/{Protheus.doc} budgetValid
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Metodo utilizado na validação de Usuario do campo  Ck_ZZNRRES
/*/
method budgetValid() class CbcbudgetManager
	//Local atmpArea	
	Local nAtuItem	
	Local lRepeat	:= .F.
	Local lRet		:= .T.

	::saveArea({'TMP1'})
	If  !Empty(M->(CK_ZZNRRES))	

		If M->(CK_ZZNRRES) <> TMP1->(CK_ZZNRRES)  		
			nAtuItem := TMP1->(CK_ITEM)
			DbSelectArea("TMP1")
			TMP1->(DbGoTop())
			While TMP1->(!Eof())
				If TMP1->(CK_ITEM) <> nAtuItem .And. M->(CK_ZZNRRES) == TMP1->(CK_ZZNRRES) 
					lRepeat := .T.			
				EndIf	
				TMP1->(DbSkip())
			EndDo
			::backarea()	

			If !lRepeat
				DbSelectArea("ZP4")
				ZP4->(DbSetOrder(1)) 
				If ZP4->( DbSeek(xFilial("ZP4") + M->(CK_ZZNRRES),.F.)  )
					If ZP4->(ZP4_CODCLI+ZP4_LOJCLI) == M->(CJ_CLIENTE + CJ_LOJA) .And. ZP4->(ZP4_STATUS) == '1'
						ResBudget()
						lRet := .T.
					Else
						lRet := .F.
					EndIf
				Else
					lRet := .F.

				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf	

		If !lRet
			TMP1->(recLock("TMP1", .F.))
			TMP1->(CK_ZZNRRES) := Space( TamSx3("CK_ZZNRRES")[1] )
			TMP1->(MSUnlock())		
			MessageBox("[AVISO] Numero reserva: " + M->(CK_ZZNRRES) + " não pode ser associada ao item, utilize F3","Aviso",48)
		EndIf
	EndIf

	::backarea()
	::lOk := lRet
return 


/*/{Protheus.doc} budgetReserve
@author bolognesi
@since 06/04/2016
@version 2.0
@type method
@description Realiza a reserva e chamado pelo Consulta padrão especifica ("RESERV")
sua finalidade e chamar a consulta padrão "RESPOR", e tratar o que foi selecionado
preenchendo a linha do item do orçamento
/*/
method budgetReserve() class CbcbudgetManager
	If Conpad1(,,,"RESPOR")
		ResBudget()
	EndIf
return    

/*/{Protheus.doc} budgetExcel
@author bolognesi
@since 06/04/2016
@version 2.0
@type function
@description Metodo chamado apos a importação do orçamento vindo da planilha excel na função(ValMemo)
no fonte (CDFAT21.PRW), este metodo percorre as linhas dos itens (TMP1), buscando reservas compativeis e associando
lembrando que a linha da reserva deve ser identica a linha da planilha, divergências serão alertadas 
/*/
method budgetExcel()  class CbcbudgetManager	
	Local aRes		:= {}
	Local lDel		:= .F.
	local aMsg		:= {}

	::saveArea({'TMP1'})

	If MsgYesNo("Gostaria de associar as reservas aos itens?","Reservas do Portal")

		DbSelectarea("TMP1")
		TMP1->(DbGoTop())
		While TMP1->(!EOF())
			If !TMP1->(CK_FLAG)
				lDel		:= .F.
				aRes := getReserv(self)

				If Len(aRes) == 1
					ZP4->(dbgoto(aRes[1,1]))
					ResBudget()
				Else
					If ::TemRes()
						AAdd(aMsg, "* ITEM: " +cValToChar(TMP1->(CK_ITEM)) + " COM DIVERGÊNCIA ENTRE RESERVAS E PLANILHA ")
						lDel := .T.
					EndIf
				EndIf

				TMP1->(recLock("TMP1", .F.))
				TMP1->(CK_FLAG) := lDel
				TMP1->(MSUnlock())
			EndIf
			TMP1->(DbSkip())
		EndDo

		If !Empty(aMsg)
			AAdd(aMsg, "  ")
			AAdd(aMsg, "  ")
			AAdd(aMsg, "VERIFIQUE OS ITENS MENCIONADOS COM A OPÇÃO F3 NA LINHA ")
			showMsg(aMsg)
		Else
			MessageBox("[OK] - Itens com reservas foram associados", "Reservas Portal", 64)	
		EndIf

		oGetDad:Refresh()

	EndIf

	::backarea()

return

/*/{Protheus.doc} budgetResAll
@author bolognesi
@since 06/04/2016
@version undefined
@type method
@description Não utilizada, mas tem a intensão de ao ser chamada buscar todas as reservas
de um cliente e preencher todos os itens (ao contrario de selecionar um a um pelo F3)
em reunião decidimos deixar em standBy esta funcionalidade 
/*/
method budgetResAll()	class CbcbudgetManager
	If showMsg({'Associar todas a reservas do cliente ao orçamento'})
		//ResBudget()
	EndIf
return


static function vldMinBob(oItem, cError, lOk)
	local nMaxRolo  := 0 
	local cAcondic  := ''
	local aColors	:= {}
	local nX		:= 0
	local oQuotSrv	:= nil
	local cCodProd	:= ''
	local nMetrage	:= 0
	local nMinBob   := 0
	
	if (cAcondic := oItem:getIdPackage()) == 'B'
		aColors 	:= oItem:getColors()
		for nX := 1 To Len(aColors)
			oQuotSrv 		:= CbcQuotationService():newCbcQuotationService()
			cCodProd 		:= oQuotSrv:getProductCode('','',oItem, aColors[nX]:getColorId())
			nMetrage		:= (aColors[nX]:getTotal() / aColors[nX]:getQuantity() )
			FreeObj(oQuotSrv)
			if (nMaxRolo := u_getMaxMetrage(cCodProd, 'R')) > 0
				nMinBob := (nMaxRolo + 1)
                if nMetrage < nMinBob
					cError := 'Metragem (' + cValToChar(nMetrage) + ') menor que o minimo (' + cValToChar(nMinBob) + ') para bobina'
				    lOk := .F.
					exit
				endif
			endif
		next nX 
	endif
return nil




/*/{Protheus.doc} BudgetMngr
//FUNÇÃO PRINCIPAL.
@author bolognesi
@since 06/04/2016
@version 2.0
@param cOper, characters, Sendo:('RES', 'VALID', 'FILTER', 'ALL', 'EXL', 'ORD','KILL','VALC6')
@description centralizar as chamadas que vem do sistema, em alguns pontos (Validação de usuario para campo)
Consulta padrão e especifica, não tem espaço para instanciar a classe desta forma centralizo nesta função
/*/
User Function BudgetMngr(cOper)
	Local oBudget
	Default cOper 	:= ""
	//TODO Verificar alertas do ZZNRRES
	If !Empty(cOper) 
		oBudget := CbcbudgetManager():newCbcbudgetManager()
		oBudget:saveArea({'TMP1','SCK','SCJ'})	
		If cOper == 'RES'
			//UTILIZADO NA CONSULTA PADRÂO ESPECIFICA "RESERV"
			oBudget:budgetReserve() 
		ElseIf cOper == 'VALID'
			//UTILIZADO NA VALIDAÇÂO DE USUARIOS DO CAMPO CK_ZZNRRES
			oBudget:budgetValid()
		ElseIf cOper == 'FILTER'
			//UTILIZADO NA CONSULTA PADRÂO "RESPOR", 
			oBudget:budgetFilter() 
		ElseIf cOper == 'ALL'
			//UTILIZADO PARA ASSOCIAR TODAS AS RESERVAS DE UM CLIENTE
			//oBudget:budgetResAll()
		ElseIf cOper == 'EXL'
			//UTILIZADO PARA ASSOCIAR AS RESERVAS IMPORTADAS DO EXEL
			oBudget:budgetExcel()
			//UTILIZADO PELO PONTO DE ENTRADA MTA416PV() ORÇAMENTO PARA PEDIDO NO FONTE CDFAT21
		ElseIf cOPer == 'ORD'
			oBudget:budgetToOrder()
			//UTILIZADO NA EXCLUSÂO E CANCELAMENTO DO ORÇAMENTO
		ElseIf cOPer == 'KILL'
			oBudget:killBudget()
			//UTILIZADO SX3 WHEN DOS CAMPOS (C6->(C6_PRODUTO, C6_QTDVEN, C6_ACONDIC, C6_LANCES,C6_METRAGE,C6_DESCRI))
		ElseIf cOper == 'VALC6' 
			oBudget:vldOrder()
		EndIf
		oBudget:backarea()
	EndIf

return oBudget:lOk

/*/{Protheus.doc} Expire
@author bolognesi
@since 06/04/2016
@version 2.0
@type  function
@description Função apra verificar se uma reserva esta expirada, utilizado no
tudo ok do orçamento
/*/
static function Expire()
	Local lRet 	:= .T.

	If Select( "HasExp") > 0
		HasExp->(dbcloseArea())
		FErase( "HasExp" + GetDbExtension())
	End If

	cQuery 	:= " SELECT ZP4_CODIGO AS RESERVA "
	cQuery 	+= " FROM " + RETSQLNAME("ZP4")  + " ZP4"
	cQuery	+= " WHERE GETDATE() >= CAST(  (CAST(ZP4_DTVAL AS VARCHAR) + ' ' + ZP4_HRVAL) AS DATETIME) "
	cQuery 	+= " AND ZP4_CODIGO = '" + TMP1->(CK_ZZNRRES) + "' "
	cQuery	+= " AND ZP4_STATUS IN ('1') "
	cQuery  += " AND ZP4.D_E_L_E_T_	<>	'*' " 

	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "HasExp"
	DbSelectArea("HasExp")
	HasExp->(DbGotop())
	lRet := !HasExp->(Eof())

	If Select( "HasExp") > 0
		HasExp->(dbcloseArea())
		FErase( "HasExp" + GetDbExtension())
	End If	

return lRet 

/*/{Protheus.doc} StatusRes
@author bolognesi
@since 06/04/2016
@version 2.0
@param nReserva, numeric, Numero da reserva no ZP4
@param cStsBusca, characters, Criterio de filtro busca reserva com este numero
@param cStatus, characters, Valor para alteração ao localizar o criterio de busca atribui este valor
@type function
@description Função para alterar o campo ZP4_STATUS, de acordo com o parametro de busca
/*/
static function StatusRes(nReserva, cStsBusca, cStatus)
	//TODO ver se ainda precisa desta static
	DbSelectArea("ZP4")
	ZP4->(DbSetOrder(1)) 
	If ZP4->( DbSeek(xFilial("ZP4") + nReserva,.F.)  )
		If ZP4->(ZP4_STATUS) == cStsBusca
			ZP4->(recLock("ZP4", .F.))
			ZP4->(ZP4_STATUS) := cStatus
			ZP4->(MSUnlock())			
		EndIf
	EndIf
return

/*/{Protheus.doc} getReserv
@author bolognesi
@since 06/04/2016
@version undefined
@param oSelf, object, Instancia do objeto que fez a chamada
@type function
@description Obtem as reservas, e verifica se estão totalmente identicas
ao procurado  (Quantidade e Localização)  
/*/
static function getReserv(oSelf)
	Local cQuery	:= ""
	Local aReserv	:= {}
	Local lAcond	:= (!Empty(TMP1->(CK_ACONDIC)) .And. TMP1->(CK_METRAGE) > 0)
	Local cAcond	:= TMP1->(CK_ACONDIC)+StrZero(TMP1->(CK_METRAGE),5)
	oSelf:lTemRes 	:= .F.

	If Select( "RES") > 0
		RES->(dbcloseArea())
		FErase( "RES" + GetDbExtension())
	End If

	cQuery 	:= " SELECT ZP4.R_E_C_N_O_  AS RECNRO, 
	cQuery	+= " ZP4_TOTAL				AS QTD,"
	cQuery  += " ZP4_LOCALI				AS LOCALI"	
	cQuery 	+= " FROM " + RETSQLNAME("ZP4")  + " ZP4"
	cQuery	+= " WHERE "
	cQuery	+= " ZP4.ZP4_STATUS = '1' "
	cQuery	+= " AND ZP4.ZP4_CODCLI = '" +  M->(CJ_CLIENTE)   	+"' "
	cQuery 	+= " AND ZP4.ZP4_LOJCLI = '" +  M->(CJ_LOJA) 	 	+"' "
	cQuery 	+= " AND ZP4.ZP4_CODPRO = '" +  TMP1->(CK_PRODUTO) 	+"' "  	
	cQuery  += " AND ZP4.D_E_L_E_T_	<>	'*' "

	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "RES"

	DbSelectArea("RES")
	RES->(DbGotop())

	If RES->(!Eof())
		oSelf:lTemRes := .T.
	EndIf

	While RES->(!Eof())

		If lAcond  

			If   RES->(QTD) == TMP1->(CK_QTDVEN) .And. Alltrim(RES->(LOCALI)) == Alltrim(cAcond)  

				AAdd(aReserv, {RES->(RECNRO), RES->(QTD)} )

			EndIf

		Else

			If   RES->(QTD) == TMP1->(CK_QTDVEN)

				AAdd(aReserv, {RES->(RECNRO), RES->(QTD)} )

			EndIf

		EndIf

		RES->(DbSkip())
	EndDo

	If Select( "RES") > 0
		RES->(dbcloseArea())
		FErase( "RES" + GetDbExtension())
	End If

return aReserv

/*/{Protheus.doc} ResBudget
@author bolognesi
@since 06/04/2016
@version 2.0
@type function
@description Função obtem as informações da reserva e 
preenche os campos na linha do item do orçamento, dispara os gatilhos e validações
/*/
Static function ResBudget()
	Local cAcondic	:= ""
	Local cMetrage	:= "" 

	// Val(Substr(cAddress,2,Len(cAddress)-1))
	cAcondic := Substr(ZP4->(ZP4_LOCALI),1,1) 
	cMetrage := Val(Substr(ZP4->(ZP4_LOCALI),2,5))

	dbSelectArea("TMP1")
	TMP1->(recLock("TMP1", .F.))
	TMP1->(CK_ZZNRRES)	:= ZP4->(ZP4_CODIGO)
	TMP1->(CK_PRODUTO) 	:= ZP4->(ZP4_CODPRO) 
	TMP1->(CK_QTDVEN)	:= ZP4->(ZP4_TOTAL)
	TMP1->(CK_ACONDIC)	:= cAcondic 
	TMP1->(CK_LANCES)	:= ZP4->(ZP4_QUANT)
	TMP1->(CK_METRAGE)	:= cMetrage
	TMP1->(MSUnlock()) 	

	oGetDad:Refresh()

	A093Prod(.T.,TMP1->(CK_PRODUTO),TMP1->(CK_PRODUTO),.T.) 
	A415Prod(TMP1->(CK_PRODUTO))

	If ExistTrigger("CK_PRODUTO")
		RunTrigger(2,nBrLin,,,"CK_PRODUTO")
	EndIf
	If ExistTrigger("CK_QTDVEN")
		RunTrigger(2,nBrLin,,,"CK_QTDVEN")
	EndIf

	M->(CK_QTDVEN) := TMP1->(CK_QTDVEN) 
	A415QtdVen()   
	oGetDad:Refresh()
return

/*/{Protheus.doc} showMsg
@author bolognesi
@since 06/04/2016
@version 2.0
@param aMsg, array, Array com as mensagens
@type function
@description Exibir mensagens durante as execuções
/*/
Static Function showMsg(aMsg)
	Local aTit			:="Reservas do Portal"
	Local aBut			:={}
	Private nOpc		:= 0

	AAdd(aBut, {1,.T.,{|| nOpc := 1, FechaBatch() }})
	AAdd(aBut, {2,.T.,{|| FechaBatch() }})
	FormBatch(aTit, aMsg, aBut )	
return (nOpc == 1)

/*/{Protheus.doc} vldAdd

@author bolognesi
@since 06/04/2016
@version 1.0
@param oSelf, object, Instancia do objeto principal
@type function
@description Contem uma chamda para cada uma das validações de campos
envolvidas na inclusão do orçamento.
/*/
Static Function vldAdd(oSelf)
	Local lRet := .F.
	//Produto
	//U_VlPrSCK() .And. A093PROD() .AND. A415PROD()
	//Quantidade Vendida
	//U_CDFATV01(1,"OR") .And. Positivo() .and. a415QtdVen()
	//Acondicionamento
	//Pertence("RBCTML ",M->CK_ACONDIC) .And. U_CDFATV02(1,"OR")   
	//Lances
	//U_CDFATV01(2,"OR")
	//Metragem
	//U_CDFATV01(3,"OR") .And. U_CDFATV02(2,"OR")
return lRet
