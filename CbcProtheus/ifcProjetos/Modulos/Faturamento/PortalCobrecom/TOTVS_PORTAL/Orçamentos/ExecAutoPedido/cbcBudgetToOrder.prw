#include 'protheus.ch'
#include 'portalcobrecom.ch'
#define FILIAL 1
#define PEDIDO 2

/*/{Protheus.doc} cbcBudgetToOrder cbcBudgetToOrder
@author bolognesi
@since 19/12/2016
@version 1.0
@type class
@description Classe responsavel por transformar um Orçamento
em Pedido, utilizando o Execauto do Sistema
/*/
class cbcBudgetToOrder from errLog

	data oQuotation
	data aDocuments
	data oSC5
	data aSC6
	data cCodCust
	data cUnitCust
	data cDelCodCust
	data cDelUnitCust
	data cPayCond
	data cFreight
	data aItms
	data cPallet
	data cLaudo
	data dDtFat
	data dDtEnt
	data cPedCli
	data cTpEntreg
	data cObsTrans
	data cObs
	data cParcial
	data cNameUsr
	data aOthePedFil
	data nFixCommis
	data cEndEntrega1
	data cEndEntrega2
	data cMsgNota1
	data cMsgNota2
	data cRetail

	method newcbcBudgetToOrder() constructor 

	method toOrder()
	method getQuot()
	method setQuot()
	method getProductCode()
	method addDocument()
	method getNroPedPrin()
	method getEndEntrega()
	method setEndEntrega()
	method getMsgNota()
	method setMsgNota()
	method getDlvDate()
	method getDocuments()
	method getTypeOper()

endclass

/*/{Protheus.doc} newcbcBudgetToOrder
@author bolognesi
@since 19/12/2016
@version 1.0
@type method
@description Metodo construtor da classe
/*/
method newcbcBudgetToOrder() class cbcBudgetToOrder
	/* 
	//Herança classe errLog
	::getMsgLog() = Obter MsgErro  
	::setStatus(lSts, cCodMsg, cMsg) = lSts=Definir Status ( .T./ .F. ),cCodMsg=Codigo do erro e cMsg=Mensagem erro  
	::itsOk() Verifica se esta tudo Ok
	::clearStatus() = Limpar status de erro
	*/
	::newerrLog("Portal")
	::oQuotation	:= Nil
	::oSC5 		:= cbcSC5():newcbcSC5()
	::aOthePedFil	:= {}
	::aDocuments	:= {}
return

/*/{Protheus.doc} getDocuments
@author bolognesi
@since 24/05/2017
@version 1,0
@type method
@description Obtem o conteudo da propriedade aDocuments
array de objetos CbcQuotationDocument()
/*/
method getDocuments() class cbcBudgetToOrder
return(::aDocuments)


/*/{Protheus.doc} getTypeOper
@author bolognesi
@since 23/02/2018
@version 1,0
@type method
@description Obtem o tipo da operação para o campo C6_OPER
aplicando as regras internas:
1-) Quando o orçamento tem endereço de entrega utilizar o tipo de operação '03' que
tem a mesma configuração do tipo '01', porem exibe uma alerta na hora do faturamento.
/*/
method getTypeOper() class cbcBudgetToOrder
	local cType := '01'
	cType := getTpOpTes(FwFilial(), ::oQuotation:getDelAddress())
return(cType)


/*/{Protheus.doc} getQuot
@author bolognesi
@since 30/12/2016
@version 1.0
@type method
@description Retorna a propriedade oQuotation
/*/
method getQuot() class cbcBudgetToOrder
return(::oQuotation)

/*/{Protheus.doc} getDlvDate
@author bolognesi
@since 30/01/2017
@version 1.0
@type method
@description Obter a data de entrega(C5_ENTREG) de acordo com a data de faturamento (C5_DTFAT)
/*/
method getDlvDate() class cbcBudgetToOrder
	local dRet	:= date()
	ConsoleLog('Definindo data de entrega portal')
	ConsoleLog('Data de faturamento ' + cValToChar(::dDtFat) )
	if ::dDtFat > date()
		dRet := ( DataValida((::dDtFat + 2) , .T. ) ) 
		ConsoleLog('Definindo data ' + cValToChar(dRet))
	endif	
return(dRet)

/*/{Protheus.doc} getNroPedPrin
@author bolognesi
@since 05/01/2017
@version 1.0
@type method
@description A classe CbcQuotationService precisa de um numero de pedido
este metodo devolve o numero do pedido, considerando as situações de divisão
/*/
method getNroPedPrin() class cbcBudgetToOrder
	Local cNum := ""
	If Empty(::aOthePedFil)
		cNum := ::oSC5:getPvNro()
	Else
		cNum := ::aOthePedFil[PEDIDO]
	EndIF
return (cNum)

/*/{Protheus.doc} setQuot
@author bolognesi
@since 30/12/2016
@version 1.0
@param oQuot, object, descricao
@type method
@description Metodo que recebe objeto CbcQuotation
e realiza um parse de algumas propriedades para a classe local
bem como disponibiliza o objeto atraves da propriedade ::oQuotation 
/*/
method setQuot(oQuot) class cbcBudgetToOrder
	::oQuotation 	:= oQuot
	ConsoleLog('Portal data de faturamento definida: ' + cValToChar(::oQuotation:getBillingDate() ) )
	::dDtFat		:= if(Empty(::oQuotation:getBillingDate()) , Date() , Max(::oQuotation:getBillingDate(),Date()) )
	::cPallet 	:= if(::oQuotation:isPallets(),'S','N')
	::cLaudo		:= if(::oQuotation:isIssueReport(),'S','N')
	::cPedCli 	:= ::oQuotation:getCustomerSalesOrder()
	::cTpEntreg	:= ::oQuotation:getDeliveryType()
	::cObsTrans	:= ::oQuotation:getShippingMessage()
	::cParcial	:= if(::oQuotation:isPartialBilling(), 'S', 'N')
	::cCodCust 	:= ::oQuotation:getCodeCustomer()
	::cUnitCust	:= ::oQuotation:getUnitCustomer()
	::cDelCodCust	:= ::oQuotation:getDelCodeCustomer()
	::cDelUnitCust:= ::oQuotation:getDelUnitCustomer()
	::cPayCond	:= ::oQuotation:getPaymentCondition()
	::cFreight	:= ::oQuotation:getFreight()
	::aItms 		:= ::oQuotation:getItems()
	::cObs		:= ::oQuotation:getComments()
	::cNameUsr	:= ::oQuotation:getNameUser()
	::nFixCommis	:= ::oQuotation:getFixedCommission()
	::dDtEnt		:= ::oQuotation:getStoredStandardDelivery()	
	::cRetail	:= if(::oQuotation:isRetail(), 'V', 'N')
	::setEndEntrega()	
	::setMsgNota()		   
	::clearStatus()
	::oSC5:setIdPort(::oQuotation:getId())
return (self)

/*/{Protheus.doc} getProductCode
@author bolognesi
@since 30/12/2016
@version 1.0
@param oItem, object, CbcQuotationItem
@param oColor, object, CbcQuotationItemColor
@type method
@description Obtem o codigo do produto utilizando a classe
CbcQuotationService e seu metodo getProductCode
/*/
method getProductCode(oItem, oColor, cQuotationId) class cbcBudgetToOrder
	local oQuotSrv 			:= Nil 
	local cCodProd			:= ""
	default cQuotationId		:= ""
	oQuotSrv 				:= CbcQuotationService():newCbcQuotationService()
	cCodProd 				:= oQuotSrv:getProductCode(::cCodCust, ::cUnitCust, oItem, oColor:getColorId(),cQuotationId)
	FreeObj(oQuotSrv)
return(cCodProd)

/*/{Protheus.doc} getMsgNota
@author bolognesi
@since 05/06/2017
@version 1.0
@param nCmp, numeric, defini qual campo sera retornado 1=C5_MENNOTA 2=C5_X_MENNF
@type method
@description Retorna a mensagem da nota dividio em dois campo 
informando 1 como parametro retorna a primeira metade informando 2
a segunda metade
/*/
method getMsgNota(nCmp) class cbcBudgetToOrder
	local cRet 		:= ""
	default nCmp 	:= 0

	if nCmp == 1
		cRet := ::cMsgNota1
	elseif nCmp == 2
		cRet := ::cMsgNota2
	else
		cRet := (::cMsgNota1 + ::cMsgNota2 ) 
	endif

	ConsoleLog('GetMsgNota_ ' + cValToChar(nCmp) + '  ' + cRet )
return(cRet)

/*/{Protheus.doc} setMsgNota
@author bolognesi
@since 05/06/2017
@version 1.0
@type method
@description Com base no objeto oQuotation
obtem a mensagem da nota do portal em dois
campos 1=C5_MENNOTA 2=C5_X_MENNF utilizaveis ao sistema
/*/
method setMsgNota(oQuot) class cbcBudgetToOrder
	local nTam1		:= TamSx3('C5_MENNOTA')[1]
	local nTam2		:= TamSx3('C5_X_MENNF')[1]
	local cMsgNf		:= ""
	default oQuot		:= ::oQuotation
	::cMsgNota1 		:= ''
	::cMsgNota2 		:= ''
	if GetClassName(oQuot) == 'CBCQUOTATION'
		cMsgNf := oQuot:getInvoiceMessage()
		if 	!empty(cMsgNf)
			if len(cMsgNf) <= nTam1
				::cMsgNota1 := cMsgNf
			else
				::cMsgNota1 := SubStr(cMsgNf, 1, nTam1)
				::cMsgNota2 := SubStr(cMsgNf, (nTam1 + 1), nTam2)
			endif
		endif
	endif
	ConsoleLog('GetMsgNota01_ ' + ::cMsgNota1)
	ConsoleLog('GetMsgNota02_ ' + ::cMsgNota2)

return(nil)

/*/{Protheus.doc} getEndEntrega
@author bolognesi
@since 24/01/2017
@version 1.0
@param nCmp, numeric, Numero definindo campo endereço de entrega
@type method
@description Retorna o endereço de entrega dividio em dois campo 
informando 1 como parametro retorna a primeira metade informando 2
a segunda metade
/*/
method getEndEntrega(nCmp) class cbcBudgetToOrder
	local cRet 		:= ""
	default nCmp 	:= 0

	if nCmp == 1
		cRet := ::cEndEntrega1
	elseif nCmp == 2
		cRet := ::cEndEntrega2
	else
		cRet := (::cEndEntrega1 + ::cEndEntrega2 ) 
	endif

	ConsoleLog('GetEndEntrega_ ' + cValToChar(nCmp) + '  ' + cRet )
return(cRet)

/*/{Protheus.doc} setEndEntrega
@author bolognesi
@since 24/01/2017
@version 1.0
@type method
@description Com base no objeto oQuotatio
concatena informação do portal em dois
campos utilizaveis ao sistema
/*/
method setEndEntrega(oQuot) class cbcBudgetToOrder
	local cConc		:= ""
	default oQuot	:= ::oQuotation
	::cEndEntrega1 := ""
	::cEndEntrega2 := ""	
	ConsoleLog('Classe ' + GetClassName(oQuot))
	if GetClassName(oQuot) == 'CBCQUOTATION'
		if !empty(oQuot:getDelCity()	) .AND.;
		!empty(oQuot:getDelZipCode()	) .AND.;
		!empty(oQuot:getDelState()	)
			cConc += Alltrim(oQuot:getDelAddress()) + ";"
			cConc += Alltrim(oQuot:getDelNumber()) +  ";"
			cConc += Alltrim(oQuot:getDelComplement()) +  ";"
			cConc += Alltrim(oQuot:getDelCity() ) + ";"
			cConc += Alltrim(oQuot:getDelState())
			ConsoleLog('EndEntrega ' + cConc)
			::cEndEntrega1 := oQuot:getDelZipCode()
			::cEndEntrega2 := cConc 
		endif
	endif
	ConsoleLog('EndEntrega01 ' + ::cEndEntrega1)
	ConsoleLog('EndEntrega02 ' + ::cEndEntrega2)
return(self)

/*/{Protheus.doc} toOrder
@author bolognesi
@since 30/12/2016
@version 1.0
@type method
@description Metodo encarregado do processamento principal
ele defini a filial de faturamento, preparar o Header e os Itens
para o Execauto, e chama a função que realiza o execAuto, para chamar
este metodo é obrigatorio definir uma instancio do objeto CbcQuotation
atraves do metodo ::setQuot(oQuot)
/*/
method toOrder() class cbcBudgetToOrder
	local bErro		:= Nil
	local aRet		:= Nil
	local cDocPort	:= Alltrim(::oSC5:getIdPort() )
	local oSql		:= nil
	local cExist		:= ''
	local cMSg		:= ""
	local cErr		:= ""
	local cStackErr	:= ""
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr,@cErr,@cStackErr)})
	BEGIN SEQUENCE
		If ::getQuot() == Nil
			::setStatus( .F.,'CBC200' ,'Objeto oQuotation não definido utilize metodo ::setQuot(oQuot)', .F. )
		Else
			//Definir a filial de faturamento para incluir o pedido
			defFilial(self)
			//Definir o header
			setHeader(self)
			If ::itsOk()
				//Definir os itens(SC6)
				setItens(self)
				If ::itsOk()
					ConsoleLog('aHeader e aCols gerado com sucesso')
					sendExec(self)
					If ::itsOk()
						salesLib(self)
					EndIf
				EndIf
			EndIf
		EndIf
		RECOVER 
		::setStatus( .F.,'CBC205' , cErr, .F., , cStackErr  )
	END SEQUENCE
	ErrorBlock(bErro)
return (self)

/*/{Protheus.doc} addDocument
@author bolognesi
@since 29/12/2016
@version 1.0
@type method
@description Classe que relaciona Documento Portal com pedidos no sistema
/*/
method addDocument() class cbcBudgetToOrder
	local oDocument 	:= Nil
	local oOtherDocs	:= Nil  
	local aPedGer		:= {}
	local cNumDoc		:= ""
	local cFilDoc		:= FwFilial()
	local nX			:= 0

	/*Se for vazio o parametro, utiliza o numero do pedido principal da propriedade*/
	If Empty(::aOthePedFil)
		cNumDoc := ::oSC5:getPvNro()
		ConsoleLog('Adicionando documentos ao pedido ' + cNumDoc )
	Else
		cFilDoc := ::aOthePedFil[FILIAL]
		cNumDoc := ::aOthePedFil[PEDIDO]
		ConsoleLog('Apos divisão gravou somente pedido ' + cNumDoc + ' adicionando documentos.' )
	EndIf

	/*Trecho para adicionar documentos a um pedido portal*/
	//Documento principal
	oDocument			:= CbcQuotationDocument():newCbcQuotationDocument()
	oDocument:setBranchId(cFilDoc)
	oDocument:setType(QUOTATION_DOC_SALES_ORDER)
	oDocument:setId(cNumDoc )
	aadd(::aDocuments, oDocument)
	/*
	Quando o numero do documento vier do parametro significa que 
	apos divisão gerou somente pedido na outra filial
	*/
	//Adicionar o pedido quando dividido(pelas regras)
	if Empty(::aOthePedFil)
		aPedGer := hasDivid(self)
		for nX := 1 To Len(aPedGer)
			ConsoleLog('Divisão do Pedido ' + cNumDoc + ' gerou Pedido ' + Alltrim(aPedGer[nX,PEDIDO])  )
			oOtherDocs := CbcQuotationDocument():newCbcQuotationDocument()
			oOtherDocs:setBranchId(Alltrim(aPedGer[nX,FILIAL]))
			oOtherDocs:setType(QUOTATION_DOC_SALES_ORDER)
			oOtherDocs:setId(Alltrim(aPedGer[nX,PEDIDO]))
			aadd(::aDocuments, oOtherDocs)
		next nX
	endif

	ConsoleLog('Documentos adicionados' )
return (self)

/*/{Protheus.doc} defFilial
@author bolognesi
@since 30/12/2016
@version 1.0
@param oSelf, object, Estancia da classe
@param cFl,   string, Parametro opcional, quando definido
apenas muda a filial para o conteudo deste parametro.
@type function
@description Funcão para definir a filial de faturamento do cliente
com base nas regras internas. e Tambem definir o nome do usuario na 
variavel global CUSUARIO 
/*/
Static Function defFilial(oSelf, cFl)
	Local oFil		:= Nil 
	Local oRule		:= Nil 
	Local cFilFat	:= ""
	Local cCli		:= ""
	Local cLoj		:= ""

	Default cFl		:= ""

	oFil 			:= cbcFiliais():newcbcFiliais()

	If !Empty(cFl)
		oFil:setFilial(cFl)
	Else
		ConsoleLog('Definindo filial de faturamento')
		cCli 	:= Padr(oSelf:cCodCust, TamSx3('A1_COD')[1])
		cLoj	:= Padr(oSelf:cUnitCust,TamSx3('A1_LOJA')[1])
		oRule 	:= CbcIndRules():newCbcIndRules(cCli, cLoj)

		IF !oRule:lOk .And. !oRule:lVldCli
			cFilFat := FwFilial()
			ConsoleLog('Definindo filial atual, problemas - cbcBudgetToOrder():defFilial() ' +  oRule:cMsgErr)
		Else
			//Definir tambem a variavel global com nome do usuario
			CUSUARIO := '******'  + '[P]' + Upper(oSelf:cNameUsr)
			ConsoleLog('Usuário que iniciou o processo->' + Upper(oSelf:cNameUsr) )
			cFilFat := oRule:BillingBranch()
			ConsoleLog( 'Para o Cliente: [' + Alltrim(cCli) + ']' +;
			' Loja:[' + Alltrim(cLoj) + ']' +;
			' foi definido a filial  ' + FwFilName('01', cFilFat ) + ;
			' pelo motivo: ' + oRule:cMotivo )
		EndIf
		oFil:setFilial(cFilFat)
		FreeObj(oFil)
		FreeObj(oRule)
	EndIf
return(oSelf)

/*/{Protheus.doc} setHeader
@author bolognesi
@since 19/12/2016
@version 1.0
@param oSelf, object, descricao
@type function
@description Obter um array para o cabeçalho (SC5) 
no modelo do ExecAuto.
/*/
Static Function setHeader(oSelf) 
	Local aRet		:= {}
	Local cTxt		:= ""
	Local cTpCli	:= Posicione("SA1",1,xFilial("SA1")+ oSelf:cCodCust + oSelf:cUnitCust,"A1_TIPO")
	oSelf:clearStatus()
	ConsoleLog('Construindo Header')

	oSelf:oSC5:addHdr({"C5_FILIAL"	,FwFilial()})
	oSelf:oSC5:addHdr({"C5_TIPO"	,"N"})
	oSelf:oSC5:addHdr({"C5_CLIENTE"	,oSelf:cCodCust})
	oSelf:oSC5:addHdr({"C5_LOJACLI"	,oSelf:cUnitCust})

	//oSelf:oSC5:addHdr({"C5_CLIENT"	,oSelf:cDelCodCust})
	//oSelf:oSC5:addHdr({"C5_LOJAENT"	,oSelf:cDelUnitCust})

	oSelf:oSC5:addHdr({"C5_TIPOCLI"	,cTpCli})
	oSelf:oSC5:addHdr({"C5_CONDPAG"	,oSelf:cPayCond})
	oSelf:oSC5:addHdr({"C5_LAUDO"	,oSelf:cLaudo})
	oSelf:oSC5:addHdr({"C5_PALLET"	,oSelf:cPallet})
	oSelf:oSC5:addHdr({"C5_TPFRETE"	,oSelf:cFreight})

	//IMEDIATA
	if alltrim( oSelf:cTpEntreg ) == '1'
		oSelf:oSC5:addHdr({"C5_DTFAT"	, date() })
		oSelf:oSC5:addHdr({"C5_ENTREG"	, oSelf:dDtEnt}) //oSelf:getDlvDate()

		//PROGRAMADA
	elseif alltrim( oSelf:cTpEntreg ) == '2'
		oSelf:oSC5:addHdr({"C5_DTFAT"	,oSelf:dDtFat})
		oSelf:oSC5:addHdr({"C5_ENTREG"	,oSelf:dDtFat})
	endif

	//ACEITA FAT. PARCIAL
	oSelf:oSC5:addHdr({"C5_PARCIAL"	,oSelf:cParcial})

	oSelf:oSC5:addHdr({"C5_XTELENT"	,Upper(Alltrim(oSelf:cObsTrans))})

	//Mensagem da Nota Fiscal
	oSelf:oSC5:addHdr({"C5_MENNOTA"	,oSelf:getMsgNota(1)})
	oSelf:oSC5:addHdr({"C5_X_MENNF"	,oSelf:getMsgNota(2)})

	oSelf:oSC5:addHdr({"C5_OBS"		,Upper(Alltrim(oSelf:cObs))})
	oSelf:oSC5:addHdr({"C5_PEDCLI"	,Alltrim(oSelf:cPedCli)})

	//Endereço de entrega, quando digitado
	oSelf:oSC5:addHdr({"C5_ENDENT1"	,oSelf:getEndEntrega(1)})
	oSelf:oSC5:addHdr({"C5_ENDENT2"	,oSelf:getEndEntrega(2)})

	//Varejo
	oSelf:oSC5:addHdr({"C5_ZTPVEND"	,oSelf:cRetail})
	
	/*
	Relacionamento entre Numero do Documento no portal 
	e numero do pedido no sistema
	*/
	oSelf:oSC5:addHdr({"C5_DOCPORT"	, oSelf:oSC5:getIdPort()})

	//De fato cria o cabeçalho
	oSelf:oSC5:makeHeader()

	aRet := oSelf:oSC5:vldObr()
	If !aRet[1]
		cTxt += '[ERRO]-Campos obrigatorios não preenchidos' + chr(13)
		For nX := 1 To Len(aRet[2])
			cTxt += aRet[2][nX] + chr(13) 
		Next nX
		oSelf:setStatus( .F., 'CBC201', cTxt, .F.  )
	EndIf

	ConsoleLog('Fim da rotina do header')
return (Nil)

/*/{Protheus.doc} setItens
@author bolognesi
@since 19/12/2016
@version 1.0
@param oSelf, object, descricao
@type function
@description Obter um array no formato execAuto para 
os itens (SC6) do pedido
/*/
Static Function setItens(oSelf)
	local nX			:= 0
	local cProdCod	:= ""
	local nQtdVen		:= 0
	local cAcond		:= ""
	local nPrcVen		:= 0
	local cResNum		:= ""
	local oItem		:= nil
	local oQuotItm	:= nil
	local nY			:= 0
	local aColors		:= {}
	local oColor		:= nil
	local nMetrage	:= 0
	local cItmPedCli 	:= ""
	local cPedCliItm 	:= ""
	local nFixComm	:= ""
	local cIdQuot		:= oSelf:oSC5:getIdPort()
	local cTpOper		:= oSelf:getTypeOper()		

	ConsoleLog('Construindo aItens')
	ConsoleLog('ID Portal..> ' + cIdQuot  )

	oSelf:oSC5:initItem()
	//Loop ZP6
	For nX := 1 To Len(oSelf:aItms)
		oQuotItm	:= oSelf:aItms[nX]
		aColors 	:= oQuotItm:getColors()
		nQtdVen 	:= oQuotItm:getQuantity()
		cAcond		:= oQuotItm:getIdPackage()
		nPrcVen		:= oQuotItm:getAppPrice()
		cResNum		:= oQuotItm:getIdReserve()
		nFixComm	:= oQuotItm:getAppCommission()

		//Loop ZP9 (Cada ZP9 um item no SC6)
		For nY := 1 To Len(aColors)
			oColor 		 	:= aColors[nY]
			oItem 			:= cbcSC6Itens():newcbcSC6Itens()
			cProdCod 		:= oSelf:getProductCode(oQuotItm, oColor, cIdQuot)
			nMetrage		:= (oColor:getTotal() / oColor:getQuantity() )
			cPoShip			:= oColor:getPoShip()

			oItem:setCampo({"C6_FILIAL"	, FwFilial()})
			oItem:setCampo({"C6_ITEM"		, oSelf:oSC5:nextItem()})
			oItem:setCampo({"C6_PRODUTO"	, cProdCod})
			oItem:setCampo({"C6_QTDVEN"	, oColor:getTotal()})
			oItem:setCampo({"C6_ACONDIC"	, cAcond})
			oItem:setCampo({"C6_LANCES"	, oColor:getQuantity()})
			oItem:setCampo({"C6_METRAGE"	, nMetrage })
			oItem:setCampo({"C6_CLI"		, oSelf:cCodCust})
			oItem:setCampo({"C6_LOJA"		, oSelf:cUnitCust})
			oItem:setCampo({"C6_PRCVEN"	, nPrcVen})

			//Campo para disparar o gatilho do TES Inteligente
			if GetNewPar('XX_INTTES', .T. )		
				oItem:setCampo({"C6_OPER", cTpOper })
			endif

			//Quando documento portal for referente a reserva gravar o campo numero da reserva
			If !Empty(cResNum)
				oItem:setCampo({"C6_ZZNRRES"	, cResNum})
			EndIf

			ConsoleLog('COMISSAO FIXA ' + cValToChar(oSelf:nFixCommis) )
			//Comissão fixa para todos os itens
			If !Empty(oSelf:nFixCommis)
				If oSelf:nFixCommis > 0
					oItem:setCampo({"C6_COMIS1"	, oSelf:nFixCommis})
				EndIF
				//Comissão para um item
			else
				oItem:setCampo({"C6_COMIS1"	, nFixComm})
			EndIf

			//Tratamento Ordem de compra pedidos
			cItmPedCli 	:= oQuotItm:getCustomerSalesOrder()
			cPedCliItm	:= oQuotItm:getItemCustomerSalesOrder()

			if !empty(cItmPedCli)
				oItem:setCampo({"C6_PEDCLI"	, cItmPedCli})
				oItem:setCampo({"C6_ITPDCLI", cPedCliItm})
				oItem:setCampo({"C6_POSHPHU", cPoShip})

				//TODO Hawei não usa o portal se não tiver este campo
				//Hawei tem atendimento interno, não usa portal.
				//oItem:setCampo({"C6_POSHPHU", ???})
			else
				if !empty(oSelf:cPedCli)
					oItem:setCampo({"C6_PEDCLI"	, Alltrim(oSelf:cPedCli)})
				endif
			endif
			//Adiciona o item
			oSelf:oSC5:addItem(oItem)
		Next nY
	Next nX
	ConsoleLog('Finalizado aItens')
return (Nil)

/*/{Protheus.doc} sendExec
@author bolognesi
@since 21/12/2016
@version 1.0
@type function
@description Realiza o envio das informaçõe para o execauto.
/*/
Static Function sendExec(oSelf)
	local aHdr				:= oSelf:oSC5:getHeader() 
	local aItm				:= oSelf:oSC5:getItens()
	local cNrPort				:= oSelf:oSC5:getIdPort() 	
	local cNomFil				:= FwFilName('01', FwFilial() )
	local nOper				:= 3
	local aErro				:= {}
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile		:= .T.
	private lIsJobPortal		:= .T.
	private __cPedDiv			:= "" //DIV
	private INCLUI			:= .T.

	cNrPort := Alltrim(cNrPort)
	ConsoleLog('Filial: ' + cNomFil + 'Inicio da rotina de execauto para o ID portal ' + cNrPort )
	ConsoleLog('[ ID PORTAL ' + cNrPort + '] Executando o MSExecAuto Mata410')
	BEGIN TRANSACTION
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aHdr,aItm,nOper)

		//Pedido foi dividido gerou somente em 3Lagoas sem erros 
		//(cbcPedido  method closeScreen() que muda estática cNrPedDiv atribuindo filial e numero do pedido )
		If !Empty(__cPedDiv) 
			oSelf:aOthePedFil := StrTokArr(__cPedDiv,'-') 
			ConsoleLog('[ ID PORTAL ' + cNrPort + '] MsExecAuto executado com sucesso [PEDIDO Nro. ] ' + Alltrim(oSelf:aOthePedFil[2]) )
			oSelf:addDocument()
		elseIf lMsErroAuto
			DisarmTransaction()
			ConsoleLog('[ ID PORTAL ' + cNrPort + ' ] MsExecAuto com erro')
			aErro := GetAutoGrLog()
			cMSg := '[ ' + cNrPort + ' ] ' + chr(13)
			cMSg += aErro[1] + chr(13)
			If Len(aErro) > 1
				For nX := 2 To Len(aErro)
					If  'Invalido' $ aErro[nX] .OR. 'Erro' $ aErro[nX]
						cMSg += aErro[nX] + chr(13)
					EndIf
				Next nX
			EndIf 
			oSelf:setStatus( .F., 'CBC202' , cMSg, .F. )
		else
			ConsoleLog('[ ID PORTAL ' + cNrPort + '] MsExecAuto executado com sucesso [PEDIDO Nro. ] ' + Alltrim(SC5->(C5_NUM)) )
			oSelf:oSC5:setPvNro(Alltrim(SC5->(C5_NUM)))
			oSelf:addDocument()
		endif
	END TRANSACTION
return(Nil)

/*/{Protheus.doc} salesLib
@author bolognesi
@since 02/01/2017
@version 1.0
@type function
@description Realiza a liberação de vendas de um pedido
gerado pelo portal, o mesmo deve nascer já no credito.
/*/
Static Function salesLib(oSelf)  
	Local lBlqCrd 	:= .F.
	Local lBlqEst	:= .F.
	Local cNumPv	:= ""
	Local nX		:= 0
	Local oArea		:= Nil
	Local cLibPort	:= GetNewPar('MV_ZLIBPOR', .T. ) //TODO Criar o parametro  definindo se libera pedido na inclusão
	Local aOthers	:= {}
	Local cBkFil	:= FwFilial()
	Local cPedFil	:= ""

	If cLibPort
		If oSelf:getQuot() == Nil
			oSelf:setStatus( .F. ,'CBC203' ,'salesLib() -> Objeto oQuotation não definido utilize metodo ::setQuot(oQuot)', .F.  )
		Else	
			If Empty(oSelf:aOthePedFil)
				cNumPv 	:= PadR(oSelf:oSC5:getPvNro(), TamSx3('C6_NUM')[1] )
				aOthers := hasDivid(oSelf)
				cPedFil := FwFilial()
			Else
				cPedFil := oSelf:aOthePedFil[FILIAL]
				cNumPv 	:= PadR(oSelf:aOthePedFil[PEDIDO], TamSx3('C6_NUM')[1] )	
			EndIf
			AAdd(aOthers, {cPedFil, cNumPv})

			If Empty(cNumPv)
				oSelf:setStatus( .F., 'CBC204' , 'Nenhum numero atribuido para ser liberado ::salesLib()', .F. )
			Else
				//TODO trocar a filial para cada lançamento
				For nX := 1 To Len(aOthers)
					oArea 	:= SigaArea():newSigaArea()

					//Mudar a filial
					defFilial(oSelf, aOthers[nX,1])
					oArea:saveArea( {'SC6', 'SC5', 'SC9'} )
					DbSelectArea("SC6")
					//C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO
					SC6->(DbSetOrder(1))
					If SC6->(DbSeek(XFilial('SC6') + aOthers[nX,2],.F.))
						ConsoleLog('Inicio da liberação e vendas do pedido ' + aOthers[nX,2] )
						While SC6->(C6_FILIAL) == XFilial('SC6') .And. SC6->(C6_NUM) == aOthers[nX,2] .And. SC6->(!Eof())
							MaLibDoFat( SC6->(RecNo()), SC6->C6_QTDVEN, @lBlqCrd, @lBlqEst, .F., .F. )
							SC6->(MaLiberOk({SC6->(C6_NUM)},.F.))
							SC6->(DbSkip())
						EndDo
						ConsoleLog('Final da liberação e vendas do pedido ' + aOthers[nX,2] )
					EndIf	

					oArea:backArea()
				Next nX
				//Restaurar a filial inicial
				defFilial(oSelf, cBkFil) 
			EndIf
		EndIF
	EndIf
return(nil)

/*/{Protheus.doc} hasDivid
@author bolognesi
@since 02/01/2017
@version 1.0
@type function
@description Verifica se o pedido originou divisão
na outra filial, Utilizdo na liberação de vendas e 
na associação de documentos Sistema no Portal
/*/
Static Function hasDivid(oSelf)
	Local ocbcPed	:= Nil
	Local aRet		:= {}
	Local aTmp		:= {}
	Local nX			:= 0
	Local cOthFil		:= ""
	ocbcPed 			:= cbcPedido():newcbcPedido( oSelf:oSC5:getPvNro() )
	If ocbcPed <> Nil 
		If ocbcPed:checkDiv( oSelf:oSC5:getPvNro() ):lselfOk
			If !Empty(ocbcPed:cselfMsg)
				aTmp := StrToKArr(ocbcPed:cselfMsg,';')
				cOthFil := If(FwFilial() == '01', '02','01')
				For nX := 1 To Len(aTmp)
					if !empty(aTmp[nX])
						aadd(aRet,{cOthFil, PadR(aTmp[nX],TamSx3('C6_NUM')[1]) } )
					endif
				Next nX
			EndIf
		EndIf
	EndIf
	FreeObj(ocbcPed)
return(aRet)


static function getTpOpTes(cFl, cEndEntr) 
	local cType := if(empty(cEndEntr),;
	GetNewPar('XX_ZTPOPER','01'),;
	GetNewPar('XX_TPOPENT','03'))
return(cType)


/*/{Protheus.doc} HandleEr
@author bolognesi
@since 19/12/2016
@version undefined
@param oErr, object, Objeto contendo o erro
@param oSelf, object, Estancia da classe atual
@type function
/*/
Static function HandleEr(oErr,cErr,cStackErr)
	default cErr		:= ''
	default cStackErr	:= ''
	cErr := '[' + oErr:Description + ']'
	cStackErr := '-' + oErr:ERRORSTACK
	BREAK
return

/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 17/10/2016
@version 1.0
@param cMsg, characters, descricao
@type function
@description Exibir mensagens padronizadas no arquivo de logo (Console)
/*/
static function ConsoleLog(cMsg)
	if GetNewPar('XX_DBGCONN', .T. )
		ConOut("[ExecAuto-Portal - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
	endif
return

/*/{Protheus.doc} _CbcService
@author bolognesi
@since 30/01/2017
@version undefined
@type function
@description DummyFunction para indicar que o
portal esta compilado, usado em alguns ExiistBlock
/*/
user function _CbcService()
return(nil)
