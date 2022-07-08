#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"

#define SQL_NO_BRANCHES	 "'*'"


/*/{Protheus.doc} CbcOpportunityBalanceService

Serviços referentes aos Estoques de Oportunidades da Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcOpportunityBalanceService from CbcService
	
	method newCbcOpportunityBalanceService() constructor
	
	method findBalances() 
	method interest()
	method reserve()
	method getReserveById()
	method findReserves()
	method cancelReserve()
	method setWaiting()
	method setConfirmed()  
	method setExpired()
	method undoConfirm()
	
endClass


/*/{Protheus.doc} newCbcOpportunityBalanceService

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcOpportunityBalanceService() class CbcOpportunityBalanceService
return self


/*/{Protheus.doc} findBalances

Retorna os Saldos do Estoque de Oportunidades
	
@author victorhugo
@since 29/02/2016

@param cUserId, String, ID do Usuário do Portal
@param cName, String, Código do Nome do Produto
@param cColor, String, Código da Cor do Produto
@param cBitola, String, Código da Bitola do Produto
@param oCustomer, CbcCustomer, Cliente Cobrecom (opcional)

@return Vetor Lista de Objetos CbcOpportunityBalance
/*/
method findBalances(cUserId, cName, cColor, cBitola, oCustomer) class CbcOpportunityBalanceService
	
	local aBalances := {}
	local oSql		:= getSqlBalances(cUserId, cName, cColor, cBitola, oCustomer) 
	
	while oSql:notIsEof()				
		
		aAdd(aBalances, createBalanceFromSql(oSql))
		
		oSql:skip()
	endDo
	
	oSql:close() 
	
return aBalances

/**
 * Cria o SQL de Pesquisa de Saldos
 */
static function getSqlBalances(cUserId, cName, cColor, cBitola, oCustomer)
	
	local cQuery 		:= ""
	local cInBranches	:= getInBranches(cUserId)
	local oSql	 		:= LibSqlObj():newLibSqlObj()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	
	checkCustomerBillBranch(oCustomer, @cInBranches)
	
	if Empty(cInBranches)
		cInBranches := SQL_NO_BRANCHES
	endIf
	
	cQuery := " SELECT BF_FILIAL BRANCH, B1_COD CODE, B1_DESC [DESCRIPTION], B1_NOME CODE_NAME, Z1_DESC NAME, "
	cQuery += " 	   B1_BITOLA CODE_BITOLA, Z2_DESC BITOLA, B1_COR CODE_COLOR, Z3_DESC COLOR, "
	cQuery += " 	   CASE "
	cQuery += " 	   		WHEN BF_LOCALIZ IS NULL "
	cQuery += " 	   			THEN '' "
	cQuery += " 	   ELSE "
	cQuery += " 	   		CASE "
	cQuery += " 	   			WHEN SUBSTRING(BF_LOCALIZ,1,1) = 'R' "
	cQuery += " 	   				THEN 'ROLO ' + RTRIM ( CAST( CAST( SUBSTRING(BF_LOCALIZ,2,5) AS NUMERIC ) AS CHAR ) ) + ' ' + B1_UM "
	cQuery += " 	   			WHEN SUBSTRING(BF_LOCALIZ,1,1) = 'C' "
	cQuery += " 	   				THEN 'CARRETEL PLASTICO ' + RTRIM ( CAST( CAST( SUBSTRING(BF_LOCALIZ,2,5) AS NUMERIC ) AS CHAR ) ) + ' ' + B1_UM "
	cQuery += " 	   			WHEN SUBSTRING(BF_LOCALIZ,1,1) = 'M' "
	cQuery += " 	   				THEN 'CARRETEL MADEIRA ' + RTRIM ( CAST( CAST( SUBSTRING(BF_LOCALIZ,2,5) AS NUMERIC ) AS CHAR ) ) + ' ' + B1_UM "
	cQuery += " 	   			WHEN SUBSTRING(BF_LOCALIZ,1,1) = 'T' "
	cQuery += " 	   				THEN 'RETALHO ' + RTRIM ( CAST( CAST( SUBSTRING(BF_LOCALIZ,2,5) AS NUMERIC ) AS CHAR ) ) + ' ' + B1_UM "
	cQuery += " 	   			WHEN SUBSTRING(BF_LOCALIZ,1,1) = 'L' "
	cQuery += " 	   				THEN 'BLISTER ' + RTRIM ( CAST( CAST( SUBSTRING(BF_LOCALIZ,2,5) AS NUMERIC ) AS CHAR ) ) + ' ' + B1_UM "
	cQuery += " 	   			ELSE '' "
	cQuery += " 	   		END "
	cQuery += " 	 	END [ADDRESS], BF_LOCALIZ [ID_ADDRESS], "
    cQuery += " 		ISNULL( (BF_QUANT-BF_EMPENHO) / CAST( ISNULL(SUBSTRING(BF_LOCALIZ,2,5),'1') AS NUMERIC ), 0 ) QUANTITY, "
    cQuery += " 		ISNULL( BF_QUANT-BF_EMPENHO, 0 ) TOTAL "    
    cQuery += " FROM %SBF.SQLNAME% "
    cQuery += " 	INNER JOIN %SB1.SQLNAME% ON "
	cQuery += " 		%SB1.XFILIAL% AND B1_COD = BF_PRODUTO AND B1_NOME = '"+cName+"' AND "
	cQuery += " 		B1_BITOLA = '"+cBitola+"' AND B1_XOPORT = 'S' AND B1_MSBLQL != '1' AND %SB1.NOTDEL% "
	if !Empty(cColor)
		cQuery += " AND B1_COR = '"+cColor+"' " 
	endIf
	cQuery += " 	INNER JOIN %SZ1.SQLNAME% ON "
	cQuery += " 		%SZ1.XFILIAL% AND Z1_COD = B1_NOME AND %SZ1.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ2.SQLNAME% ON "
	cQuery += " 		%SZ2.XFILIAL% AND Z2_COD = B1_BITOLA AND %SZ2.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ3.SQLNAME% ON "
	cQuery += " 		%SZ3.XFILIAL% AND Z3_COD = B1_COR AND %SZ3.NOTDEL% "	
	cQuery += " WHERE BF_FILIAL IN ("+cInBranches+") AND BF_LOCAL = '01' AND SUBSTRING(BF_LOCALIZ,1,1)	<>	'B' AND " 
	cQuery += " 	  (BF_QUANT - BF_EMPENHO) >	0 AND %SBF.NOTDEL% " 

	cQuery += " UNION ALL "

	cQuery += " SELECT ZE_FILIAL BRANCH, B1_COD CODE, B1_DESC [DESCRIPTION], B1_NOME CODE_NAME, Z1_DESC NAME, "
	cQuery += " 	   B1_BITOLA CODE_BITOLA, Z2_DESC BITOLA, B1_COR CODE_COLOR, Z3_DESC COLOR, "
	cQuery += " 	   ISNULL('BOBINA ' + RTRIM( CAST(ZE_QUANT AS CHAR) ) + ' ' + B1_UM, '') [ADDRESS], "
	cQuery += " 	   'B'+right(replicate('0',5)+ convert(varchar(5),ZE_QUANT),5) [ID_ADDRESS], "	
    cQuery += " 	   COUNT(*) QUANTITY, ISNULL(SUM(ZE_QUANT), 0) TOTAL "
    cQuery += " FROM %SZE.SQLNAME% "
    cQuery += " 	INNER JOIN %SB1.SQLNAME% ON "
	cQuery += " 		%SB1.XFILIAL% AND B1_COD = ZE_PRODUTO AND B1_NOME = '"+cName+"' AND "
	cQuery += " 		B1_BITOLA = '"+cBitola+"' AND B1_XOPORT = 'S' AND B1_MSBLQL != '1' AND %SB1.NOTDEL% "
	if !Empty(cColor)
		cQuery += " AND B1_COR = '"+cColor+"' " 
	endIf
	cQuery += " 	INNER JOIN %SZ1.SQLNAME% ON "
	cQuery += " 		%SZ1.XFILIAL% AND Z1_COD = B1_NOME AND %SZ1.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ2.SQLNAME% ON "
	cQuery += " 		%SZ2.XFILIAL% AND Z2_COD = B1_BITOLA AND %SZ2.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ3.SQLNAME% ON "
	cQuery += " 		%SZ3.XFILIAL% AND Z3_COD = B1_COR AND %SZ3.NOTDEL% "
    cQuery += " WHERE ZE_FILIAL IN ("+cInBranches+") AND ZE_STATUS = 'T' AND ZE_QUANT > 0 AND %SZE.NOTDEL% "
    cQuery += " GROUP BY ZE_FILIAL, B1_COD, B1_DESC, B1_NOME, Z1_DESC, B1_BITOLA, Z2_DESC, B1_COR, Z3_DESC, " 
    cQuery += " 	  ISNULL('BOBINA ' + RTRIM( CAST(ZE_QUANT AS CHAR) ) + ' ' + B1_UM, ''), "
    cQuery += " 	  'B'+right(replicate('0',5)+ convert(varchar(5),ZE_QUANT),5) "	
    cQuery += " ORDER BY 1,2 " 
	
	oSql:newAlias(cQuery) 
	
return oSql

/**
 * Cria um Saldo a partir do objeto SQL
 */
static function createBalanceFromSql(oSql)
	
	local oProduct := nil
	local oBalance := nil
	
	oProduct := CbcProduct():newCbcProduct()
	oProduct:setCode(oSql:getValue("CODE"))
	oProduct:setDescription(oSql:getValue("AllTrim(DESCRIPTION)"))
	oProduct:setName(oSql:getValue("AllTrim(NAME)"))
	oProduct:setCodeName(oSql:getValue("CODE_NAME"))
	oProduct:setBitola(oSql:getValue("AllTrim(BITOLA)"))
	oProduct:setCodeBitola(oSql:getValue("CODE_BITOLA"))
	oProduct:setColor(oSql:getValue("AllTrim(COLOR)"))
	oProduct:setCodeColor(oSql:getValue("CODE_COLOR"))
	
	oBalance := CbcOpportunityBalance():newCbcOpportunityBalance()
	oBalance:setBranch(CbcBranch():newCbcBranch(oSql:getValue("BRANCH")))
	oBalance:setProduct(oProduct)
	oBalance:setAddress(oSql:getValue("AllTrim(ADDRESS)"))
	oBalance:setIdAddress(oSql:getValue("ID_ADDRESS"))
	oBalance:setQuantity(oSql:getValue("QUANTITY"))
	oBalance:setTotal(oSql:getValue("TOTAL"))
	
return oBalance

/**
 * Coleta as Filiais que o usuário pode visualizar
 */
static function getInBranches(cUserId)
	
	local nI			:= 0
	local aBranches		:= {}
	local aAllowBranches:= {}
	local cInBranches	:= "" 
	local cSellerRule	:= ""  
	local cAllowBranches:= GetNewPar("ZZ_FILESPT", BRANCH_ITU)
	local oUtils		:= LibUtilsObj():newLibUtilsObj() 
	local oSql	 		:= LibSqlObj():newLibSqlObj()
	local oService 		:= CbcUserService():newCbcUserService()
	local oUser	   		:= oService:findById(cUserId)
	
	if oUtils:isNull(oUser)
		return ""   
	endIf
	
	if Empty(cAllowBranches)	
		if (oUser:isProspect() .or. oUser:isCustomer())
			aAdd(aBranches, CbcBranch():newCbcBranch(BRANCH_ITU))
		elseIf (oUser:isSeller())
			aBranches := oUser:getSeller():getBranches() 
		endIf
	else
		aAllowBranches := StrTokArr(cAllowBranches, ",")
		for nI := 1 to Len(aAllowBranches)
			aAdd(aBranches, CbcBranch():newCbcBranch(aAllowBranches[nI]))
		next nI 
	endIf	
	
	if (Len(aBranches) == 0)
		aAdd(aBranches, CbcBranch():newCbcBranch(BRANCH_ITU))
		aAdd(aBranches, CbcBranch():newCbcBranch(BRANCH_TRES_LAGOAS))
	endIf	
	
	for nI := 1 to Len(aBranches)
		if !Empty(cInBranches)
			cInBranches += ","
		endIf
		cInBranches += "'"+aBranches[nI]:getId()+"'" 
	next nI
	
	checkCustomerBillBranch(oUser:getCustomer(), @cInBranches)		
	
return cInBranches

/**
 * Trata as Filiais de Faturamento dos Clientes
 */
static function checkCustomerBillBranch(oCustomer, cInBranches)
	
	local nI			:= 0
	local cSalesOrder	:= ""
	local cBillBranch	:= ""
	local aAllowBranches:= {}
	local cAllowBranches:= GetNewPar("ZZ_FILESPT", BRANCH_ITU)
	local oCbcInd 		:= nil 
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	
	if oUtils:isNull(oCustomer) .or. Empty(oCustomer:getCode())
		return
	endIf
	
	cInBranches	:= "" 
	cBillBranch := oCustomer:getBillBranch() 
	
	if oUtils:isNull(cBillBranch)
		oCbcInd 	:= CbcIndRules():newCbcIndRules(oCustomer:getCode(), oCustomer:getUnit(), cSalesOrder, oCustomer:isProspect()) 
		cBillBranch := oCbcInd:billingBranch()
	endIf
	
	if Empty(cBillBranch)
		aAllowBranches := StrTokArr(cAllowBranches, ",") 
		for nI := 1 to Len(aAllowBranches)
			if !Empty(cInBranches)
				cInBranches += ","
			endIf
			cInBranches += "'"+aAllowBranches[nI]+"'" 
		next nI
	elseIf (cBillBranch $ cAllowBranches)
		cInBranches := "'"+cBillBranch+"'"
	endIf
	
return


/*/{Protheus.doc} interest

Manifestação de Interesse por um Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@param cUserId, String, ID do Usuário solicitante
@param oCustomer, CbcCustomer, Cliente Cobrecom
@param oBalance, CbcOpportuniyBalance, Saldo do Estoque de Oportunidades

@return Logico Indica se a manifestação foi processada com sucesso
/*/
method interest(cUserId, oCustomer, oBalance) class CbcOpportunityBalanceService
	
	local oUser	:= nil

	if !validReserve("interest", @self, cUserId, @oCustomer, oBalance, @oUser)
		return .F.
	endIf
	
	createNotifications(EVENT_PRODUCT_BALANCE_INTEREST, oUser, oBalance, oCustomer)

return .T.


/*/{Protheus.doc} reserve

Criação de uma Reserva do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016

@param cUserId, String, ID do Usuário solicitante
@param oCustomer, CbcCustomer, Cliente Cobrecom
@param oBalance, CbcOpportuniyBalance, Saldo do Estoque de Oportunidades
@param cReserveId, String, Variável para atribuição do ID da Reserva

@return Logico Indica se a reserva foi processada com sucesso
/*/
method reserve(cUserId, oCustomer, oBalance, cReserveId) class CbcOpportunityBalanceService
	
	local oUser	:= nil

	if !validReserve("reserve", @self, cUserId, @oCustomer, oBalance, @oUser)
		return .F.
	endIf
	
	cReserveId := createReserve(@self, cUserId, oCustomer, @oBalance)
	
	if Empty(cReserveId)
		return .F.
	endIf
	
	createNotifications(EVENT_PRODUCT_BALANCE_RESERVE, oUser, oBalance, oCustomer, cReserveId)

return .T.

/**
 * Cria as Notificações das Reservas
 */
static function createNotifications(cEvent, oUser, oBalance, oCustomer, cReserveId) 
	
	local cCbcMsg			:= ""
	local cCustomerMsg 		:= ""
	local cOperation		:= "" 
	local oEvent			:= nil
	local oSrvEvent 		:= CbcEventService():newCbcEventService()
	local oSrvNotif			:= CbcNotificationService():newCbcNotificationService()
	local lOwnerWasNotified := .F.
	
	if (cEvent == EVENT_PRODUCT_BALANCE_INTEREST)
		cOperation := "interest"
	elseIf (cEvent == EVENT_PRODUCT_BALANCE_RESERVE)
		cOperation := "reserve"
	endIf
	
	cCbcMsg := getMessage(cOperation, "cobrecom", oUser, oBalance, oCustomer, cReserveId)
	
	if (oUser:isProspect() .or. oUser:isCustomer())
		cCustomerMsg := getMessage(cOperation, "customer", oUser, oBalance, oCustomer, cReserveId)
	endIf	
		
	oEvent := CbcEvent():newCbcEvent(cEvent, oUser:getId(), cCbcMsg)
	
	checkSellersToNotify(@oEvent, oCustomer)
	
	oSrvEvent:check(oEvent)	
	
	if !Empty(cCustomerMsg)
		oEvent:setMessage(cCustomerMsg)
	endIf
			
	lOwnerWasNotified := (aScan(oEvent:getNotifyUsers(), oUser:getId()) > 0)
	
	if !lOwnerWasNotified			
		oEvent:setNotifyUsers({oUser:getId()})
		oEvent:setEmailUsers({oUser:getId()})	
		oSrvNotif:create(oEvent)
	endIf		
	
return

/**
 * Coleta a Mensagem de Reserva de Produtos
 */
static function getMessage(cOperation, cTo, oUser, oBalance, oCustomer, cReserveId)
	
	local cMsg 		:= ""
	local oReserve	:= nil
	local oProduct	:= oBalance:getProduct()
	local oService 	:= CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	
	if !Empty(cReserveId)
		oReserve := oService:getReserveById(oBalance:getBranch():getId(), cReserveId)
	endIf
	
	if (cTo == "customer")
		return getCustomerReserveMessage(cOperation, oUser, oBalance, oCustomer, oReserve)
	endIf
	
	cMsg := "O usuário "+AllTrim(oUser:getName())
	
	if (cOperation == "interest")
		cMsg += " manifestou interesse sobre "
	elseIf (cOperation == "reserve")
		cMsg += " reservou " 
	endIf
	
	cMsg += " o produto "+AllTrim(oProduct:getDescription())+". "
	cMsg += "Segue abaixo maiores informações: "+CRLF+CRLF	
	cMsg += "Data da Reserva: "+DtoC(Date())+" - "+Left(Time(), 5)+CRLF
	if (cOperation == "reserve")
		cMsg += "Código da Reserva: "+cReserveId+CRLF
		cMsg += "Data de Validade: "+DtoC(oReserve:getDateValid())+CRLF
		cMsg += "Hora de Validade: "+oReserve:getTimeValid()+CRLF
	endIf 
	cMsg += "Usuário: "+AllTrim(oUser:getId())+" - "+AllTrim(oUser:getName())+CRLF
	cMsg += "Grupo do Usuário: "+AllTrim(oUser:getGroupName())+CRLF
	cMsg += "Filial: "+AllTrim(oBalance:getBranch():getName())+CRLF
	cMsg += "Cliente: "+AllTrim(oCustomer:getCode())+"-"+AllTrim(oCustomer:getUnit())+" - "+AllTrim(oCustomer:getName())+CRLF
	cMsg += "Produto: "+AllTrim(oProduct:getCode())+" - "+AllTrim(oProduct:getDescription())+CRLF
	cMsg += "Acondicionamento: "+AllTrim(oBalance:getAddress())+CRLF
	cMsg += "Quantidade: "+AllTrim(Str(oBalance:getQuantity()))+CRLF
	cMsg += "Total: "+AllTrim(Str(oBalance:getTotal()))
	
return cMsg

/**
 * Coleta a Mensagem de Reserva de Produtos
 */
static function getCustomerReserveMessage(cOperation, oUser, oBalance, oCustomer, oReserve)
	
	local cMsg 		:= ""
	local oProduct	:= oBalance:getProduct()
	
	cMsg := "Olá, "+AllTrim(oUser:getName())+" !"+CRLF+CRLF
	
	if (cOperation == "interest")
		cMsg += "Recebemos sua manifestação de interesse no produto "+AllTrim(oProduct:getDescription())+". "+CRLF+CRLF
		cMsg += "Em breve entraremos em contato."
	elseIf (cOperation == "reserve")
		cMsg += "Recebemos sua reserva do produto "+AllTrim(oProduct:getDescription())+". " 
	endIf
	
	cMsg += CRLF+CRLF
	cMsg += "Segue abaixo maiores informações "
	
	if (cOperation == "interest")
		cMsg += "sobre seu manifesto: "
	elseIf (cOperation == "reserve")
		cMsg += "sobre a sua reserva: "
	endIf
	
	cMsg += CRLF+CRLF
	 
	cMsg += "Data: "+DtoC(Date())+" - "+Left(Time(), 5)+CRLF
	if (cOperation == "reserve")
		cMsg += "Código da Reserva: "+oReserve:getId()+CRLF
		cMsg += "Data de Validade: "+DtoC(oReserve:getDateValid())+CRLF
		cMsg += "Hora de Validade: "+oReserve:getTimeValid()+CRLF
	endIf
	cMsg += "Produto: "+AllTrim(oProduct:getCode())+" - "+AllTrim(oProduct:getDescription())+CRLF
	cMsg += "Acondicionamento: "+AllTrim(oBalance:getAddress())+CRLF
	cMsg += "Quantidade: "+AllTrim(Str(oBalance:getQuantity()))+CRLF
	cMsg += "Total: "+AllTrim(Str(oBalance:getTotal()))
	
return cMsg

/**
 * Validação dos Dados da Reserva
 */
static function validReserve(cOperation, oSelf, cUserId, oCustomer, oBalance, oUser)
	
	local lOk 			:= .F.
	local cMsg			:= "" 
	local oUtils		:= LibUtilsObj():newLibUtilsObj()	
	local oSrvEvent 	:= CbcEventService():newCbcEventService()
	local oSrvUser		:= CbcUserService():newCbcUserService() 
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()  
	local oUser			:= oSrvUser:findById(cUserId)
	local oProduct		:= oBalance:getProduct()	
	local lProspect		:= (cOperation == "interest")
	
	begin sequence
		
		if oUtils:isNull(oUser)
			cMsg := "Usuário inválido"
			break
		endIf
		
		if oUtils:isNull(oCustomer)
			cMsg := "Cliente não informado"
			break
		endIf
		
		oCustomer := oSrvCustomer:findByCode(oCustomer:getCode(), oCustomer:getUnit(), lProspect)
		if oUtils:isNull(oCustomer)
			cMsg := "Cliente inválido"
			break
		endIf 
		
		if (oCustomer:getCode() == DEFAULT_CUSTOMER_CODE .and. oCustomer:getUnit() == DEFAULT_CUSTOMER_UNIT)
			cMsg := "Não é permitido realizar reservas para o Cliente Padrão"
			break
		endIf
		
		if oCustomer:isBlocked()
			cMsg := "Cliente bloqueado"
			break
		endIf
		
		if oUtils:isNull(oProduct)
			cMsg := "Produto inválido"
			break
		endIf
		
		if oUtils:isNull(oBalance:getBranch()) .or. !(oBalance:getBranch():getId() $ "'"+BRANCH_ITU+"','"+BRANCH_TRES_LAGOAS+"'")
			cMsg := "Filial inválida"
			break
		endIf
		
		if (!Empty(oCustomer:getBillBranch()) .and. oBalance:getBranch():getId() != oCustomer:getBillBranch())
			cMsg := "Filial inválida para o cliente informado"
			break	
		endIf
		
		if Empty(oBalance:getAddress())
			cMsg := "Acondicionamento não informado"
			break
		endIf
		
		if Empty(oBalance:getIdAddress())
			cMsg := "Localização não informada"
			break
		endIf
		
		if (oBalance:getQuantity() <= 0)
			cMsg := "Quantidade inválida"
			break
		endIf
		
		if (oBalance:getTotal() <= 0)
			cMsg := "Total inválido"
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
	if !lOk
		oSelf:cErrorMessage := cMsg
	endIf
	
return lOk

/**
 * Criação da Reserva
 */
static function createReserve(oSelf, cUserId, oCustomer, oBalance)
	
	local dDateValid	:= CtoD("")
	local aData 		:= {}	
	local cTimeValid	:= "" 
	local cId 			:= GetSxeNum("ZP4", "ZP4_CODIGO")
	local oSql			:= LibSqlObj():newLibSqlObj() 
	
	if hasThisReserveId(oBalance:getBranch():getId(), cId)
		RollBackSx8()
		ConOut('[CBC-Portal] - Erro ID Reserva Duplicada! Id:' + cId +; 
				' User:' + cUserId + ' Filial:' + oBalance:getBranch():getId(); 
				+ ' Cli:' + oCustomer:getCode() + '-' + oCustomer:getUnit(); 
				+ ' Prod:' + oBalance:getProduct():getCode() + '(' + oBalance:getIdAddress() + ')')
		return ""
	endif
	
	if !allocBalance(@oSelf, cId, oBalance, @dDateValid, @cTimeValid)
		RollBackSx8()
		return ""
	endIf	
		
	aAdd(aData, {"ZP4_FILIAL", oBalance:getBranch():getId()})
	aAdd(aData, {"ZP4_STATUS", RESERVE_STATUS_WAITING})
	aAdd(aData, {"ZP4_CODIGO", cId})
	aAdd(aData, {"ZP4_DATA", Date()})
	aAdd(aData, {"ZP4_HORA", Left(Time(), 5)})
	aAdd(aData, {"ZP4_DTVAL", dDateValid})
	aAdd(aData, {"ZP4_HRVAL", cTimeValid})
	aAdd(aData, {"ZP4_CODUSR", cUserId})
	aAdd(aData, {"ZP4_CODCLI", oCustomer:getCode()})
	aAdd(aData, {"ZP4_LOJCLI", oCustomer:getUnit()}) 
	aAdd(aData, {"ZP4_CODPRO", oBalance:getProduct():getCode()})
	aAdd(aData, {"ZP4_ACOND", oBalance:getAddress()})
	aAdd(aData, {"ZP4_LOCALI", oBalance:getIdAddress()})
	aAdd(aData, {"ZP4_QUANT", oBalance:getQuantity()})
	aAdd(aData, {"ZP4_TOTAL", oBalance:getTotal()}) 
	
	if oSql:insert("ZP4", aData)
		ConfirmSx8()
	else
		cId := ""
		RollBackSx8()
		oSelf:cErrorMessage := "Falha na gravação da Reserva"
	endIf
return cId

/**
 * Gravação do Empenho da Reserva
 */
static function allocBalance(oSelf, cId, oBalance, dDateValid, cTimeValid)
	
	local lOk 	  		:= .F.
	local cBranch 		:= oBalance:getBranch():getId()
	local cReserveId	:= cId
	local cProduct		:= oBalance:getProduct():getCode()
	local cIdAddress	:= oBalance:getIdAddress()
	local nQuantity		:= oBalance:getQuantity()												   	
	local oResMan 		:= CbcReserveManager():newCbcReserveManager(cBranch, cReserveId, cProduct, cIdAddress, nQuantity) 
	
	if oResMan:ptEmpSdc()	
		lOk 	   := .T.
		dDateValid := oResMan:getExpireDate()
		cTimeValid := Left(oResMan:getExpireHour(), 5)
	else
		oSelf:cErrorMessage := Capital(oResMan:getErrorMsg())
	endIf	 
	
return lOk


/*/{Protheus.doc} getReserveById

Retorna uma Reserva pelo ID
	
@author victorhugo
@since 29/02/2016

@param cBranch, String, Código da Filial
@param cReserveId, String, ID da Reserva

@return CbcOpportunityBalanceReserve Reserva solicitada
/*/
method getReserveById(cBranch, cReserveId) class CbcOpportunityBalanceService
	
	local oReserve	:= nil
	local oSql		:= nil
	local oFilter	:= CbcOpportunityBalanceReserveFilter():newCbcOpportunityBalanceReserveFilter()	 
	
	oFilter:setBranch(cBranch)
	oFilter:setReserveId(cReserveId) 
	
	oSql := getSqlReserves(oFilter)
	
	if oSql:hasRecords()
		oReserve := createSqlReserve(oSql)
	endIf
	
	oSql:close() 
	
return oReserve


/*/{Protheus.doc} findReserves

Retorna os Reservas do Estoque de Oportunidades
	
@author victorhugo
@since 29/02/2016

@param oFilter, CbcOpportunityBalanceReserveFilter, Filtro das Reservas

@return Vetor Lista de Objetos CbcOpportunityBalance
/*/
method findReserves(oFilter) class CbcOpportunityBalanceService
	
	local oReserve	:= nil
	local aReserves := {}
	local oSql		:= getSqlReserves(oFilter) 
	
	while oSql:notIsEof()
						
		aAdd(aReserves, createSqlReserve(oSql))
		
		oSql:skip()
	endDo
	
	oSql:close() 
	
return aReserves

/**
 * Cria uma reserva a partir do Objeto SQL
 */
static function createSqlReserve(oSql)
	
	local oReserve := CbcOpportunityBalanceReserve():newCbcOpportunityBalanceReserve()
	
	oReserve:setStatus(oSql:getValue("STATUS"))
	oReserve:setId(oSql:getValue("ID"))
	oReserve:setDate(oSql:getValue("DATE"))
	oReserve:setTime(oSql:getValue("TIME"))
	oReserve:setDateValid(oSql:getValue("VALID_DATE"))
	oReserve:setTimeValid(oSql:getValue("VALID_TIME"))
	oReserve:setUserId(oSql:getValue("USER_ID"))
	oReserve:setUserName(oSql:getValue("AllTrim(USER_NAME)"))
	oReserve:setCodeCustomer(oSql:getValue("CUSTOMER_CODE"))
	oReserve:setUnitCustomer(oSql:getValue("CUSTOMER_UNIT"))
	oReserve:setNameCustomer(oSql:getValue("AllTrim(CUSTOMER_NAME)"))
	oReserve:setItemQuotation(oSql:getValue("ITEM_QUOTATION"))
	oReserve:setIdQuotation(oSql:getValue("ID_QUOTATION"))
	oReserve:setBalance(createBalanceFromSql(oSql))
	
return oReserve


/**
 * Cria o SQL de Pesquisa de Reservas
 */
static function getSqlReserves(oFilter)
	
	local cQuery 		:= ""
	local cBranch		:= oFilter:getBranch() 
	local cReserveId	:= oFilter:getReserveId()
	local dStartDate	:= oFilter:getStartDate()
	local dEndDate		:= oFilter:getEndDate()
	local cUserId		:= oFilter:getUserId()
	local cStatus		:= oFilter:getStatus()
	local cCodeCustomer	:= oFilter:getCodeCustomer()
	local cUnitCustomer := oFilter:getUnitCustomer()
	local cSeller		:= oFilter:getSeller()
	local cFromUser		:= oFilter:getFromUser()		
	local oSql	 		:= LibSqlObj():newLibSqlObj()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oUser			:= nil
	local lIsSeller		:= .F.
	local lIsCustomer	:= .F. 	
	
	if !Empty(cUserId)
		oUser := oSrvUser:findById(cUserId)
	endIf
	
	lIsSeller 	:= (oUtils:isNotNull(oUser) .and. oUser:isSeller())
	lIsCustomer	:= (oUtils:isNotNull(oUser) .and. (oUser:isProspect() .or. oUser:isCustomer()))
	
	cQuery := " SELECT ZP4_FILIAL BRANCH, ZP4_STATUS STATUS, ZP4_CODIGO ID, ZP4_DATA [DATE], ZP4_HORA [TIME], ZP4_DTVAL VALID_DATE, ZP4_HRVAL VALID_TIME, "
	cQuery += " 	   ZP4_CODUSR USER_ID, ZP1_NOME USER_NAME, ZP4_CODCLI CUSTOMER_CODE, ZP4_LOJCLI CUSTOMER_UNIT, A1_NOME CUSTOMER_NAME, ZP4_CODPRO CODE, "
	cQuery += " 	   ZP4_QUANT QUANTITY, ZP4_TOTAL TOTAL, ZP4_ACOND [ADDRESS], ZP4_LOCALI [ID_ADDRESS], B1_DESC [DESCRIPTION], B1_NOME CODE_NAME, "
	cQuery += " 	   Z1_DESC NAME, B1_BITOLA CODE_BITOLA, Z2_DESC BITOLA, B1_COR CODE_COLOR, Z3_DESC COLOR, "
	cQuery += "  	   CASE WHEN ZP6_ITEM IS NOT NULL THEN ZP6_ITEM ELSE CK_ITEM END ITEM_QUOTATION, "
	cQuery += " 	   CASE WHEN ZP6_NUM IS NOT NULL THEN ZP6_NUM ELSE CK_NUM END ID_QUOTATION " 
	cQuery += " FROM %ZP4.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP4_CODUSR AND %ZP1.NOTDEL% "
	cQuery += " 	INNER JOIN %SB1.SQLNAME% ON "
	cQuery += " 		%SB1.XFILIAL% AND B1_COD = ZP4_CODPRO AND %SB1.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ1.SQLNAME% ON "
	cQuery += " 		%SZ1.XFILIAL% AND Z1_COD = B1_NOME AND %SZ1.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ2.SQLNAME% ON "
	cQuery += " 		%SZ2.XFILIAL% AND Z2_COD = B1_BITOLA AND %SZ2.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ3.SQLNAME% ON "
	cQuery += " 		%SZ3.XFILIAL% AND Z3_COD = B1_COR AND %SZ3.NOTDEL% "
	cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
	cQuery += " 		%SA1.XFILIAL% AND A1_COD = ZP4_CODCLI AND A1_LOJA = ZP4_LOJCLI AND %SA1.NOTDEL% " 
	cQuery += " 	LEFT JOIN %ZP6.SQLNAME% ON "
	cQuery += " 		%ZP6.XFILIAL% AND ZP6_FILRES = ZP4_FILIAL AND ZP6_NUMRES = ZP4_CODIGO AND %ZP6.NOTDEL% "
	cQuery += " 	LEFT JOIN %SCK.SQLNAME% ON "
	cQuery += " 		%SCK.XFILIAL% AND CK_ZZNRRES = ZP4_CODIGO AND %SCK.NOTDEL% "
	
	cQuery += " WHERE "
	
	if !Empty(cBranch)
		cQuery += " ZP4_FILIAL = '"+cBranch+"' AND "
	endIf
	
	if lIsCustomer 
		cQuery += " ZP4_CODUSR = '"+cUserId+"' AND "	
	else
		if lIsSeller
			cQuery += " ( ZP4_CODUSR = '"+cUserId+"' OR A1_VEND = '"+oUser:getSeller():getId()+"' ) AND "
		endIf	
		if !Empty(cCodeCustomer)
			cQuery += " ZP4_CODCLI = '"+cCodeCustomer+"' AND "
		endIf
		if !Empty(cUnitCustomer)
			cQuery += " ZP4_LOJCLI = '"+cUnitCustomer+"' AND "
		endIf
		if !Empty(cSeller)
			cQuery += " A1_VEND = '"+cSeller+"' AND "
		endIf
		if !Empty(cFromUser)
			cQuery += " ZP4_CODUSR = '"+cFromUser+"' AND "
		endIf
	endIf
	
	if Empty(cReserveId)
		if !Empty(cStatus)
			cQuery += " ZP4_STATUS = '"+cStatus+"' AND "
		endIf
		if !Empty(dStartDate) .and. !Empty(dEndDate)	
			cQuery += " ZP4_DATA >= '"+DtoS(dStartDate)+"' AND ZP4_DATA <= '"+DtoS(dEndDate)+"' AND "
		endIf
	else
		cQuery += " ZP4_CODIGO = '"+cReserveId+"' AND "
	endIf
	
	cQuery += " %ZP4.NOTDEL% "	
	cQuery += " ORDER BY ZP4_FILIAL, ZP4_CODIGO "
	
	oSql:newAlias(cQuery)
	oSql:setField("DATE", "D")
	oSql:setField("VALID_DATE", "D")
	
return oSql


/*/{Protheus.doc} cancelReserve

Cancelamento de uma Reserva do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016

@param cUserId, String, ID do Usuário solicitante
@param cBranch, String, Código da Filial
@param cReserveId, String, ID da Reserva

@return Logico Indica se o cancelamento foi processado com sucesso
/*/
method cancelReserve(cUserId, cBranch, cReserveId) class CbcOpportunityBalanceService
	
	local lOk  	 	:= .F.
	local cCustomer	:= ""
	local cUnit		:= ""
	local cName		:= "" 
	local cQuotation:= ""
	local cWhere 	:= "ZP4_FILIAL = '"+cBranch+"' AND ZP4_CODIGO = '"+cReserveId+"'"
	local oEvent	:= nil
	local oResUser	:= nil
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSql 	 	:= LibSqlObj():newLibSqlObj()
	local oSrvEvent := CbcEventService():newCbcEventService()
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser		:= oSrvUser:findById(cUserId)
	
	if oUtils:isNull(oUser)
		::cErrorMessage := "Usuário inválido"
		return .F.
	endIf
	
	if !oSql:exists("ZP4", cWhere)
		::cErrorMessage := "Reserva não encontrada"
		return .F.
	endIf
	
	if !oSql:exists("ZP4", cWhere+" AND ZP4_STATUS = '"+RESERVE_STATUS_WAITING+"' ")
		::cErrorMessage := "Essa reserva não está com status Pendente"
		return .F.
	endIf
	
	cQuotation := oSql:getFieldValue("ZP6", "ZP6_NUM", "ZP6_FILRES = '"+cBranch+"' AND ZP6_NUMRES = '"+cReserveId+"'")
	
	if !Empty(cQuotation)
		::cErrorMessage := "Essa reserva está associada ao Orçamento "+cQuotation
		return .F.
	endIf
	
	if !cancelAlloc(@self, cBranch, cReserveId)
		return .F.
	endIf
	
	setStatus(@self, cBranch, cReserveId, RESERVE_STATUS_CANCELED)
	
	oSql:update("ZP4", "ZP4_USRCAN = '"+cUserId+"', ZP4_DTCAN = '"+DtoS(Date())+"', ZP4_HRCAN = '"+Left(Time(), 5)+"'", cWhere) 
	
return .T.

/**
 * Cancela o Empenho nas Tabelas da Cobrecom
 */
static function cancelAlloc(oSelf, cBranch, cReserveId)
	
	local lOk 	  := .F.
	local oResMan := CbcReserveManager():newCbcReserveManager(cBranch, cReserveId) 
	
	if oResMan:ptCanSdc()	
		lOk 	   := .T.
	else
		oSelf:cErrorMessage := Capital(oResMan:getErrorMsg())
	endIf
	
return lOk


/*/{Protheus.doc} setWaiting

Define uma reserva como Pendente
	
@author victorhugo
@since 08/03/2016

@param cBranch, String, Código da Filial
@param cReserveId, String, ID da Reserva

@return Logico Indica se a reserva foi atualizada
/*/
method setWaiting(cBranch, cReserveId) class CbcOpportunityBalanceService
return setStatus(@self, cBranch, cReserveId, RESERVE_STATUS_WAITING)


/*/{Protheus.doc} setConfirmed

Define uma reserva como Confirmada
	
@author victorhugo
@since 08/03/2016

@param cBranch, String, Código da Filial
@param cReserveId, String, ID da Reserva

@return Logico Indica se a reserva foi atualizada
/*/
method setConfirmed(cBranch, cReserveId) class CbcOpportunityBalanceService
return setStatus(@self, cBranch, cReserveId, RESERVE_STATUS_CONFIRMED)


/*/{Protheus.doc} setExpired

Define uma reserva como Expirada
	
@author victorhugo
@since 08/03/2016

@param cBranch, String, Código da Filial
@param cReserveId, String, ID da Reserva

@return Logico Indica se a reserva foi atualizada
/*/
method setExpired(cBranch, cReserveId) class CbcOpportunityBalanceService
return setStatus(@self, cBranch, cReserveId, RESERVE_STATUS_EXPIRED)


/*/{Protheus.doc} undoConfirm

Estorna a Confirmação de uma Reserva
	
@author victorhugo
@since 08/03/2016

@param cBranch, String, Código da Filial
@param cReserveId, String, ID da Reserva

@return Logico Indica se o Estorno foi realizado
/*/
method undoConfirm(cBranch, cReserveId, lClearQuotations) class CbcOpportunityBalanceService
	
	local oReserve	 		:= nil
	local cVldDateTime		:= ""
	local cDateTime			:= ""
	local oSql				:= LibSqlObj():newLibSqlObj()
	local lOk	   			:= .T.
	default lClearQuotations:= .F.
	
	if setStatus(@self, cBranch, cReserveId, RESERVE_STATUS_WAITING, .T.)
		if lClearQuotations
			oSql:update("ZP6", "ZP6_FILRES = ' ', ZP6_NUMRES = ' '", "ZP6_FILRES = '"+cBranch+"' AND ZP6_NUMRES = '"+cReserveId+"'")
		endIf	
	else
		return .F.
	endIf

	oReserve 	 := ::getReserveById(cBranch, cReserveId)
	cVldDateTime := DtoS(oReserve:getDateValid())+StrTran(oReserve:getTimeValid(), ":", "")
	cDateTime	 := DtoS(dDataBase)+StrTran(Time(), ":", "")
	
	if (cVldDateTime < cDateTime)
		lOk := setStatus(@self, cBranch, cReserveId, RESERVE_STATUS_EXPIRED)
	endIf

return lOk

/**
 * Define os Status das Reservas
 */
static function setStatus(oSelf, cBranch, cReserveId, cStatus, lUndoConfirm)
	
	local cEvent	:= ""
	local cCustomer := ""
	local cUnit		:= "" 
	local cName		:= ""
	local cActionMsg:= ""
	local cCbcMsg	:= ""
	local cCustMsg  := ""
	local cWhere 	:= "ZP4_FILIAL = '"+cBranch+"' AND ZP4_CODIGO = '"+cReserveId+"'"
	local oEvent	:= nil
	local oUser		:= nil
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSql 	 	:= LibSqlObj():newLibSqlObj()
	local oSrvUser  := CbcUserService():newCbcUserService()
	local oSrvEvent := CbcEventService():newCbcEventService()
	local oSrvNotif	:= CbcNotificationService():newCbcNotificationService()
	local lOwnerWasNotified := .F.
	
	oSql:newTable("ZP4", "ZP4_CODUSR USERID, ZP4_CODCLI CUSTOMER, ZP4_LOJCLI UNIT", cWhere)
	
	if oSql:hasRecords()
		oUser	  := oSrvUser:findById(oSql:getValue("USERID"))
		cCustomer := oSql:getValue("CUSTOMER")
		cUnit	  := oSql:getValue("UNIT")
		cName	  := oSql:getFieldValue("SA1", "A1_NOME", "%SA1.XFILIAL% AND A1_COD = '"+cCustomer+"' AND A1_LOJA = '"+cUnit+"'")
	else
		oSelf:cErrorMessage := "Reserva não encontrada"
		oSql:close() 
		return .F.		
	endIf
	
	oSql:update("ZP4", "ZP4_STATUS = '"+cStatus+"'", cWhere)		 
	
	cCbcMsg  := "A reserva "+AllTrim(cReserveId)+" do cliente "+AllTrim(cName)
	cCustMsg := "Sua reserva "+AllTrim(cReserveId) 
	
	if lUndoConfirm
		cEvent 		:= EVENT_PRODUCT_BALANCE_RESERVE_UNDO_CONFIRM
		cActionMsg  := " teve a confirmação estornada"
	elseIf (cStatus == RESERVE_STATUS_WAITING)
		cEvent 		:= EVENT_PRODUCT_BALANCE_RESERVE
		cActionMsg  := " retorno para o status pendente" 
	elseIf (cStatus == RESERVE_STATUS_CONFIRMED)		
		cEvent 		:= EVENT_PRODUCT_BALANCE_RESERVE_CONFIRMED
		cActionMsg  := " foi confirmada!"
	elseIf (cStatus == RESERVE_STATUS_EXPIRED)
		cEvent 		:= EVENT_PRODUCT_BALANCE_RESERVE_EXPIRED
		cActionMsg  := " expirou!"
	elseIf (cStatus == RESERVE_STATUS_CANCELED)
		cEvent 		:= EVENT_CANCEL_PRODUCT_BALANCE_RESERVE
		cActionMsg  := " foi cancelada!"
	endIf
	
	if Empty(cEvent)
		return .F.
	endIf
	
	cCbcMsg  += cActionMsg
	cCustMsg += cActionMsg
	
	oEvent  := CbcEvent():newCbcEvent(cEvent, nil, cCbcMsg)		
	
	checkSellersToNotify(@oEvent, nil, cBranch, cReserveId)
	
	oSrvEvent:check(oEvent)
	
	lOwnerWasNotified := (aScan(oEvent:getNotifyUsers(), oUser:getId()) > 0)
	
	if !lOwnerWasNotified
		oEvent:setMessage(cCustMsg)	
		oEvent:setNotifyUsers({oUser:getId()})
		oEvent:setEmailUsers({oUser:getId()})
		oSrvNotif:create(oEvent)
	endIf		
							  
return .T.


/**
 * Verifica se algum Vendedor deve ser notificado sobre o evento de um cliente
 */
static function checkSellersToNotify(oEvent, oCustomer, cBranch, cReserveId)
	
	local cCode			:= ""
	local cUnit			:= ""
	local cSellerId		:= "" 
	local oSeller	 	:= nil
	local oUser			:= nil
	local lProspect		:= (oEvent:getId() == EVENT_PRODUCT_BALANCE_INTEREST)
	local oSql 			:= LibSqlObj():newLibSqlObj()	
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()
	
	if oUtils:isNotNull(oCustomer)
		cCode := oCustomer:getCode()
		cUnit := oCustomer:getUnit()
	else
		 getReserveCustomer(cBranch, cReserveId, @cCode, @cUnit)		 
	endIf	
	
	oCustomer := oSrvCustomer:findByCode(cCode, cUnit, lProspect)
	oSeller   := oCustomer:getSeller()
	
	if oUtils:isNull(oSeller) .or. Empty(oSeller:getId())
		return
	endIf
	
	cSellerId := oSql:getFieldValue("ZP1", "ZP1_CODIGO", "%ZP1.XFILIAL% AND ZP1_CODVEN = '"+oSeller:getId()+"'")
		
	if !Empty(cSellerId)
		oEvent:addNotifyUser(cSellerId)
		oEvent:addEmailUser(cSellerId)
	endIf	
					
return


/**
 * Coleta o Cliente de uma Reserva
 */
static function getReserveCustomer(cBranch, cReserveId, cCode, cUnit)
	
	local oSql := LibSqlObj():newLibSqlObj()
	
	oSql:newTable("ZP4", "ZP4_CODCLI CODE, ZP4_LOJCLI UNIT", "ZP4_FILIAL = '"+cBranch+"' AND ZP4_CODIGO = '"+cReserveId+"'")
	
	cCode := oSql:getValue("CODE")
	cUnit := oSql:getValue("UNIT")
	
	oSql:close() 
	
return


static function hasThisReserveId(cBranch, cId)
	local lHas := .F.
	local oSql := LibSqlObj():newLibSqlObj()
			
	oSql:newTable("ZP4", "ZP4_CODIGO CODE", "ZP4_FILIAL = '"+cBranch+"' AND ZP4_CODIGO = '"+cId+"'")
		
	lHas := oSql:hasRecords()
	
	oSql:close()
	FreeObj(oSql)
return(lHas)
