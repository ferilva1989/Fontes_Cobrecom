#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcOpportunityBalanceWs

Web Service de Manutenção do Estoque de Oportunidades do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsService CbcOpportunityBalanceWs description "Web Service de Manutenção do Estoque de Oportunidades do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcopportunitybalancews.apw"
	
	wsData requestProductPropertyList as WsCbcRequestProductPropertyList
	wsData responseProductPropertyList as WsCbcResponseProductPropertyList
	wsData requestEntityList as WsCbcRequestReservesEntityList
	wsData responseEntityList as WsCbcResponseReservesEntityList
	wsData requestBalances as WsCbcRequestOpportunityBalances
	wsData responseBalances as WsCbcResponseOpportunityBalances
	wsData requestCreateReserve as WsCbcRequestCreateOpportunityBalanceReserve
	wsData responseCreateReserve as WsCbcResponseCreateOpportunityBalanceReserve
	wsData requestReserves as WsCbcRequestOpportunityBalanceReserves
	wsData responseReserves as WsCbcResponseOpportunityBalanceReserves			
	wsData requestReserveById as WsCbcRequestOpportunityBalanceReserveById
	wsData responseReserveById as WsCbcResponseOpportunityBalanceReserveById
	wsData requestCancelReserve as WsCbcRequestOpportunityBalanceCancelReserve
	wsData responseCancelReserve as WsCbcResponseOpportunityBalanceCancelReserve
	
	wsMethod getProductPropertyList description "Retorna a Lista de Valores das Propriedades dos Produtos"
	wsMethod getEntityList description "Retorna a Lista de Clientes, Vendedores ou Usuários das Reservas"
	wsMethod findBalances description "Retorna os Saldos do Estoque de Oportunidades"
	wsMethod interest description "Manifestação de interesse no Estoque de Oportunidades"
	wsMethod reserve description "Reserva de Produtos do Estoque de Oportunidades"
	wsMethod findReserveById description "Retorna uma Reserva do Estoque de Oportunidades pelo ID"
	wsMethod findReserves description "Retorna as Reservas do Estoque de Oportunidades"
	wsMethod cancelReserve description "Cancelamento de uma Reserva do Estoque de Oportunidades"	
	
endWsService


/*/{Protheus.doc} getProductPropertyList

Retorna a Lista de Valores das Propriedades dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getProductPropertyList wsReceive requestProductPropertyList wsSend responseProductPropertyList wsService CbcOpportunityBalanceWs

	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oSrvProd	:= CbcProductService():newCbcProductService()
	local aValues	:= oSrvProd:getProperties(::requestProductPropertyList:property)	
	
	if (Len(aValues) > 0)
		oSrvProd:setWsArray(@aValues)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso" 
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"   		 
	endIf
	
	::responseProductPropertyList:status := oStatus
	::responseProductPropertyList:values := aValues
	
return .T.


/*/{Protheus.doc} getEntityList

Retorna a Lista de Clientes, Vendedores ou Usuários das Reservas
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getEntityList wsReceive requestEntityList wsSend responseEntityList wsService CbcOpportunityBalanceWs

	local aValues	:= {}
	local cUserId	:= ::requestEntityList:userId
	local cEntity	:= AllTrim(Lower(::requestEntityList:entity))
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oUtils	:= LibUtilsObj():newLibUtilsObj()	
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser		:= oSrvUser:findById(cUserId)		
	
	if oUtils:isNull(oUser)
		oStatus:success := .F.
		oStatus:message := "Usuário inválido" 
	else	
		aValues := getEntityValues(oUser, cEntity)
		if (Len(aValues) > 0)
			oStatus:success := .T.
			oStatus:message := "Dados fornecidos com sucesso" 
		else
			oStatus:success := .F.
			oStatus:message := "Nenhum registro encontrado"   		 
		endIf
	endIf	
	
	::responseEntityList:status := oStatus
	::responseEntityList:values := aValues
	
return .T.

/**
 * Carrega as Entidades conforme o tipo solicitado
 */
static function getEntityValues(oUser, cEntity)
	
	local aValues	:= {} 
	local cQuery	:= ""
	local cGroup	:= ""
	local oWsObj    := nil
	local oEntity	:= nil
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oSql		:= LibSqlObj():newLibSqlObj()  
	
	if (cEntity == "customer")
		cQuery := " SELECT DISTINCT ZP4_CODCLI+ZP4_LOJCLI [ID], A1_NOME [VALUE] "
		cQuery += " FROM %ZP4.SQLNAME% "
		cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  		%SA1.XFILIAL% AND A1_COD = ZP4_CODCLI AND A1_LOJA = ZP4_LOJCLI AND %SA1.NOTDEL% "
		cQuery += " WHERE %ZP4.NOTDEL% "
		if oUser:isSeller()
			cQuery += " AND A1_VEND = '"+oUser:getSeller():getId()+"' "
		endIf 	
		cQuery += " ORDER BY 2 " 
	elseIf (cEntity == "seller")
		cQuery := " SELECT DISTINCT [ID], [VALUE] "
		cQuery += " FROM ( "
		cQuery += "  	SELECT DISTINCT A3_COD [ID], A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP4.SQLNAME% "
		cQuery += " 		INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  			%SA1.XFILIAL% AND A1_COD = ZP4_CODCLI AND A1_LOJA = ZP4_LOJCLI AND %SA1.NOTDEL% "
		cQuery += " 		INNER JOIN %SA3.SQLNAME% ON "
		cQuery += "  			%SA3.XFILIAL% AND A3_COD = A1_VEND AND %SA3.NOTDEL% "
		cQuery += " 	WHERE %ZP4.NOTDEL% AND A1_VEND != ' ' "
		cQuery += "		UNION ALL "
		cQuery += "  	SELECT DISTINCT A3_COD [ID], A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP4.SQLNAME% "
		cQuery += " 		INNER JOIN %ZP1.SQLNAME% ON "
		cQuery += "  			%ZP1.XFILIAL% AND ZP1_CODIGO = ZP4_CODUSR AND %ZP1.NOTDEL% "
		cQuery += " 		INNER JOIN %SA3.SQLNAME% ON "
		cQuery += "  			%SA3.XFILIAL% AND A3_COD = ZP1_CODVEN AND %SA3.NOTDEL% "
		cQuery += " 	WHERE %ZP4.NOTDEL% AND ZP1_CODVEN != ' ' ) AS QRY "
		cQuery += " ORDER BY 2 " 
	elseIf (cEntity == "user")
		cQuery := " SELECT DISTINCT ZP4_CODUSR [ID], ZP1_NOME [VALUE] "
		cQuery += " FROM %ZP4.SQLNAME% "
		cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
		cQuery += "  		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP4_CODUSR AND %ZP1.NOTDEL% "
		cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  		%SA1.XFILIAL% AND A1_COD = ZP4_CODCLI AND A1_LOJA = ZP4_LOJCLI AND %SA1.NOTDEL% "
		cQuery += " WHERE %ZP4.NOTDEL% " 	
		if oUser:isSeller()
			cQuery += " AND A1_VEND = '"+oUser:getSeller():getId()+"' "
		endIf
		cQuery += " ORDER BY 2 "
	endIf
	
	if Empty(cQuery)
		return {} 
	endIf
	
	oSql:newAlias(cQuery) 
	
	while oSql:notIsEof()
		
		oWsObj       := WsClassNew("WsCbcGenericObject")
		oWsObj:id    := oSql:getValue("ID")
		
		if (cEntity == "user")
			oEntity := oSrvUser:findById(oWsObj:id)
			cGroup	:= oSrvUser:getGroupDescription(oEntity:getGroup())
			oWsObj:value := AllTrim(Capital(oEntity:getName()))
			if (oEntity:isProspect() .or. oEntity:isCustomer())
				oWsObj:value += " ("+cGroup+" - "+AllTrim(Capital(oEntity:getCustomer():getName()))+")"
			else
				oWsObj:value += " ("+cGroup+")"
			endIf	
		else
			oWsObj:value := oSql:getValue("AllTrim(Capital(VALUE))")
		endIf	
		
		aAdd(aValues, oWsObj) 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aValues


/*/{Protheus.doc} findBalances

Retorna os Saldos do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findBalances wsReceive requestBalances wsSend responseBalances wsService CbcOpportunityBalanceWs
	
	local aBalances := {}  
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestBalances
	local oCustomer := CbcCustomer():newCbcCustomer()
	local oService	:= CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	
	oCustomer:setCode(oRequest:customerCode)
	oCustomer:setUnit(oRequest:customerUnit) 
	oCustomer:setProspect(oRequest:customerIsProspect)
	
	aBalances := oService:findBalances(oRequest:userId, oRequest:productName, oRequest:productColor, oRequest:productBitola, oCustomer)		
	
	if (Len(aBalances) > 0)
		oStatus:success := .T.
		oStatus:message := "Saldos fornecidos com sucesso" 
		oService:setWsArray(@aBalances)
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum saldo encontrado"   		 
	endIf
	
	::responseBalances:status 	:= oStatus
	::responseBalances:balances := aBalances 
	
return .T.


/*/{Protheus.doc} interest

Manifestação de interesse no Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod interest wsReceive requestCreateReserve wsSend responseCreateReserve wsService CbcOpportunityBalanceWs
	 
	procReserve("interest", @::requestCreateReserve, @::responseCreateReserve)

return .T.


/*/{Protheus.doc} reserve

Reserva de Produtos do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod reserve wsReceive requestCreateReserve wsSend responseCreateReserve wsService CbcOpportunityBalanceWs
	
	procReserve("reserve", @::requestCreateReserve, @::responseCreateReserve)

return .T.

/**
 * Processamento do Interesse ou Reserva de Produtos
 */
static function procReserve(cType, oRequest, oResponse)
	
	local lOk		   := .F. 
	local cSuccessMsg  := "" 
	local cReserveId   := "" 
	local oEvent	   := nil
	local oStatus      := WsClassNew("WsCbcResponseStatus")
	local oBranch	   := CbcBranch():newCbcBranch(oRequest:branch)
	local oCustomer	   := CbcCustomer():newCbcCustomer() 
	local oBalance	   := CbcOpportunityBalance():newCbcOpportunityBalance() 
	local oSrvBalance  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oSrvProduct  := CbcProductService():newCbcProductService()
	local oProduct	   := oSrvProduct:findByCode(oRequest:productCode)
		
	oCustomer:setCode(oRequest:customerCode)
	oCustomer:setUnit(oRequest:customerUnit) 	
		
	oBalance:setBranch(oBranch)
	oBalance:setProduct(oProduct)
	oBalance:setAddress(oRequest:address)
	oBalance:setIdAddress(oRequest:idAddress)
	oBalance:setQuantity(oRequest:quantity)
	oBalance:setTotal(oRequest:total)
	
	if (cType == "interest")	
		cSuccessMsg := "Manifestação de interesse recebida com sucesso"
		lOk 		:= oSrvBalance:interest(oRequest:userId, oCustomer, oBalance)
	elseIf (cType == "reserve")
		cSuccessMsg := "Reserva processada com sucesso"
		lOk 		:= oSrvBalance:reserve(oRequest:userId, oCustomer, oBalance, @cReserveId)
	endIf	
	
	if lOk
		oStatus:success := .T.
		oStatus:message := cSuccessMsg
	else
		oStatus:success := .F.
		oStatus:message := oSrvBalance:getErrorMessage()		 		
	endIf
	
	oResponse:status 	:= oStatus
	oResponse:reserveId	:= cReserveId

return


/*/{Protheus.doc} findReserveById

Retorna uma Reserva do Estoque de Oportunidades pelo ID
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findReserveById wsReceive requestReserveById wsSend responseReserveById wsService CbcOpportunityBalanceWs
	
	local oWsReserve := nil
	local oStatus    := WsClassNew("WsCbcResponseStatus")
	local oRequest 	 := ::requestReserveById
	local oUtils	 := LibUtilsObj():newLibUtilsObj()
	local oService	 := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oReserve	 := oService:getReserveById(oRequest:branch, oRequest:reserveId)	
	
	if oUtils:isNotNull(oReserve)
		oStatus:success := .T.
		oStatus:message := "Reserva fornecida com sucesso" 
		oWsReserve		:= oReserve:toWsObject()
	else
		oStatus:success := .F.
		oStatus:message := "Reserva não encontrada"   		 
	endIf
	
	::responseReserveById:status  := oStatus
	::responseReserveById:reserve := oWsReserve 
	
return .T.


/*/{Protheus.doc} findReserves

Retorna as Reservas do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findReserves wsReceive requestReserves wsSend responseReserves wsService CbcOpportunityBalanceWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestReserves
	local aReserves	:= {}
	local oService	:= CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oFilter	:= CbcOpportunityBalanceReserveFilter():newCbcOpportunityBalanceReserveFilter()	
	
	oFilter:setStartDate(oRequest:startDate)
	oFilter:setEndDate(oRequest:endDate)
	oFilter:setUserId(oRequest:userId)
	oFilter:setBranch(oRequest:branch)
	oFilter:setStatus(oRequest:status)
	oFilter:setReserveId(oRequest:reserveId)
	oFilter:setCodeCustomer(oRequest:customerCode)
	oFilter:setUnitCustomer(oRequest:customerUnit)
	oFilter:setSeller(oRequest:seller)
	oFilter:setFromUser(oRequest:fromUser)
	
	aReserves := oService:findReserves(oFilter) 	
	
	if (Len(aReserves) > 0)
		oStatus:success := .T.
		oStatus:message := "Reservas fornecidas com sucesso"
		oService:setWsArray(@aReserves)
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum reserva encontrado"   		 
	endIf
	
	::responseReserves:status 	:= oStatus
	::responseReserves:reserves := aReserves 
	
return .T.


/*/{Protheus.doc} cancelReserve

Cancelamento de uma Reserva do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod cancelReserve wsReceive requestCancelReserve wsSend responseCancelReserve wsService CbcOpportunityBalanceWs
	
	local oStatus      := WsClassNew("WsCbcResponseStatus")
	local oRequest	   := ::requestCancelReserve
	local oSrvBalance  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()

	if oSrvBalance:cancelReserve(oRequest:userId, oRequest:branch, oRequest:reserveId)
		oStatus:success := .T.
		oStatus:message := "Reserva cancelada com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := oSrvBalance:getErrorMessage() 
	endIf

	::responseCancelReserve:status := oStatus

return .T.
