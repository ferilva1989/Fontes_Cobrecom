#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"

#define MAX_SEARCH_RECORDS 300


/*/{Protheus.doc} CbcQuotationService

Serviços referentes aos Orçamentos do Portal Cobrecom
    
@author victorhugo
@since 02/06/2016
/*/
class CbcQuotationService from CbcService	 
	
	method newCbcQuotationService() constructor
	
	method search()
	method getById()
	method create()
	method update()
	method activatecanceled()
	method finishMaintenance()
	method takeApproval()
	method giveUpApproval()
	method approve()
	method disapprove()
	method tecnicalReject()
	method undoApproval()
	method cancel()
	method delete()
	method lockUpdate()
	method unlockUpdate()	
	method requestTecnicalApproval()
	method tecnicalApproval()
	method confirm()
	method addDocument()
	method setDocumentDeleted()
	method getItemDescription() 
	method checkRules()
	method canTakeApproval()
	method canRequestTecnicalApproval()	
	method getShowQuotationLink()
	method isTecnicalApprover()
	method getProductCode()
	method getDescStatus()
	method getColorStatus()
	method updateAppPrice()
	method setTotals()
	method calcTaxInfo()
	method updateCustomer()
	method setProcessing()
	method setConfirmed()
	method setErrorProcessing()
	method batchApproval()
	method batchPriceUpdate()
	method canPrint()
	method getWaitingQuotations()
	
endClass


/*/{Protheus.doc} newCbcQuotationService

Construtor
    
@author victorhugo
@since 01/06/2016
/*/
method newCbcQuotationService() class CbcQuotationService
return self


/*/{Protheus.doc} search

Pesquisa Orçamentos
	
@author victorhugo
@since 01/06/2016

@param oFilter, CbcQuotationFilter, Filtro dos Orçamentos
@param lDetails, Logico, Indica se deve carregar os detalhes dos Orçamentos

@return Array Lista de Orçamentos encontrados
/*/
method search(oFilter, lDetails, lImpostos) class CbcQuotationService
	
	local aQuotations 	:= {}
	local cUserId		:= oFilter:getUserId()
	local cApproval		:= oFilter:getApproval()
	local oSql 		 	:= nil
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oUser	 		:= oSrvUser:findById(cUserId)
	default lDetails	:= .F.		
	default lImpostos	:= .F.
	
	if !Empty(cUserId) .and. oUtils:isNull(oUser)
		::cErrorMessage := "Usuário inválido"
		return {}
	endIf
	
	oSql := getFindSql(oUser, oFilter)
	
	while oSql:notIsEof()
		
		aAdd(aQuotations, createFromSql(self, oSql, oUser, lDetails, lImpostos))
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	filterByApprovalStatus(self, @aQuotations, oUser, cApproval)
	
	if (Len(aQuotations) == 0)
		::cErrorMessage := "Nenhum registro encontrado"
	endIf
	
return aQuotations

/**
 * Cria a Query de Pesquisa de Orçamentos
 */
static function getFindSql(oUser, oFilter)
	
	local cQuery 	 		:= ""	
	local cDocType	 		:= ""
	local cDocId	 		:= ""	
	local cCustomerKeyWord 	:= oFilter:getCustomerKeyWord()
	local cCodeCustomer		:= oFilter:getCodeCustomer()
	local cUnitCustomer		:= oFilter:getUnitCustomer()
	local oSql	 	 		:= LibSqlObj():newLibSqlObj()
	local oUtils			:= LibUtilsObj():newLibUtilsObj()	
	
	if !Empty(cCustomerKeyWord)
		cCustomerKeyWord := AllTrim(Lower(cCustomerKeyWord))	
		cCustomerKeyWord := StrTran(cCustomerKeyWord, ",", "")
		cCustomerKeyWord := StrTran(cCustomerKeyWord, ".", "")
		cCustomerKeyWord := StrTran(cCustomerKeyWord, "-", "")
	endIf
	
	if !Empty(oFilter:getSalesOrderId())
		cDocType := QUOTATION_DOC_SALES_ORDER
		cDocId	 := oFilter:getSalesOrderId()
	elseIf !Empty(oFilter:getInvoiceId())
		cDocType := QUOTATION_DOC_INVOICE
		cDocId	 := oFilter:getInvoiceId()
	endIf		
	
	cQuery := " SELECT TOP " + AllTrim(Str(MAX_SEARCH_RECORDS)) 
	cQuery += "		   ZP5_STATUS [STATUS], ZP5_NUM [ID], ZP5_REVATU [LAST_REVISION], ZP5_DATA [DATE], ZP5_HORA [TIME], ZP5_RESPON ID_USER, USR.ZP1_NOME NAME_USER, "
	cQuery += "      ZP5_TIPO [TYPE], ZP5_DTVAL VALID_DATE, ZP5_CLIENT CODE_CUSTOMER, ZP5_LOJA UNIT_CUSTOMER, CUSTOMER.A1_NREDUZ NAME_CUSTOMER, "
	cQuery += " 	   ZP5_CLENTR DEL_CODE_CUSTOMER, ZP5_LJENTR DEL_UNIT_CUSTOMER, DEL_CUSTOMER.A1_NOME DEL_NAME_CUSTOMER, "
	cQuery += " 	   ZP5_CEPENT DEL_ZIP_CODE, ZP5_ENDENT DEL_ADDRESS, ZP5_NUMENT DEL_NUMBER, ZP5_COMENT DEL_COMPLEMENT, ZP5_MUNENT DEL_CITY, ZP5_UFENT DEL_STATE, "
	cQuery += " 	   ZP5_VAREJO RETAIL, ZP5_FRETE FREIGHT, ZP5_CONDPG PAYMENT_CONDITION, E4_DESCRI DESC_PAYMENT, ZP5_APROVA ID_APPROVER,  "
	cQuery += " 	   APPROVER.ZP1_NOME NAME_APPROVER, ZP5_ALTERA CAN_EDIT, CAST(CAST(ZP5_OBS AS VARBINARY(8000)) AS VARCHAR(8000)) COMMENTS, "
	cQuery += " 	   X5_DESCRI REASON_CANCEL, ZP5_OBSCAN CANCEL_COMMENTS, ZP5_ENTPAD STANDARD_DELIVERY, ZP5_TPENT DELIVERY_TYPE, ZP5_DTFAT BILLING_DATE, "
	cQuery += " 	   ZP5_COMFIX FIXED_COMMISSION, ZP5_LAUDO ISSUE_REPORT, ZP5_PALLET PALLETS, ZP5_FATPAR PARTIAL_BILLING, ZP5_PEDCLI CUSTOMER_SALES_ORDER, "
	cQuery += " 	   ZP5_OBSTRA SHIPPING_MESSAGE, CAST(CAST(ZP5_OBSNF AS VARBINARY(8000)) AS VARCHAR(8000)) INVOICE_MESSAGE, ZP5_DTPROC PROC_DATE, "
	cQuery += " 	   ZP5_HRPROC PROC_TIME, CAST(CAST(ZP5_OBPROC AS VARBINARY(8000)) AS VARCHAR(8000)) PROC_COMMENTS, " 		
	cQuery += " 	   ZP5_CNPJ AS CNPJ_CUSTOMER "
	cQuery += " FROM %ZP5.SQLNAME% "
	cQuery += " 	INNER JOIN "+RetSqlName("ZP1")+" USR ON "
	cQuery += " 		USR.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND USR.ZP1_CODIGO = ZP5_RESPON AND USR.D_E_L_E_T_ = ' ' "
	cQuery += " 	INNER JOIN %SE4.SQLNAME% ON "
	cQuery += " 		%SE4.XFILIAL% AND E4_CODIGO = ZP5_CONDPG AND %SE4.NOTDEL% "
	cQuery += " 	LEFT JOIN "+RetSqlName("ZP1")+" APPROVER ON "
	cQuery += " 		APPROVER.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND APPROVER.ZP1_CODIGO = ZP5_APROVA AND APPROVER.D_E_L_E_T_ = ' ' "
	cQuery += " 	INNER JOIN "+RetSqlName("SA1")+" CUSTOMER ON "
	cQuery += " 		CUSTOMER.A1_FILIAL = '"+xFilial("SA1")+"' AND CUSTOMER.A1_COD = ZP5_CLIENT AND "
	cQuery += "			CUSTOMER.A1_LOJA = ZP5_LOJA AND CUSTOMER.D_E_L_E_T_ = ' ' "  
	cQuery += " 	LEFT JOIN "+RetSqlName("SA1")+" DEL_CUSTOMER ON "
	cQuery += " 		DEL_CUSTOMER.A1_FILIAL = '"+xFilial("SA1")+"' AND DEL_CUSTOMER.A1_COD = ZP5_CLENTR AND "
	cQuery += "			DEL_CUSTOMER.A1_LOJA = ZP5_LJENTR AND DEL_CUSTOMER.D_E_L_E_T_ = ' ' "
	cQuery += " 	LEFT JOIN %SX5.SQLNAME% ON "
	cQuery += " 		%SX5.XFILIAL% AND X5_TABELA = '_3' AND X5_CHAVE = ZP5_MOTCAN AND %SX5.NOTDEL% "
	cQuery += " 	LEFT JOIN "+RetSqlName("SA3")+" OWNER_SELLER ON "
	cQuery += " 		OWNER_SELLER.A3_FILIAL = '"+xFilial("SA3")+"' AND OWNER_SELLER.A3_COD = USR.ZP1_CODVEN AND OWNER_SELLER.D_E_L_E_T_ = ' ' "
	cQuery += " 	LEFT JOIN "+RetSqlName("SA3")+" CUSTOMER_SELLER ON "
	cQuery += " 		CUSTOMER_SELLER.A3_FILIAL = '"+xFilial("SA3")+"' AND CUSTOMER_SELLER.A3_COD = CUSTOMER.A1_VEND AND CUSTOMER_SELLER.D_E_L_E_T_ = ' ' "
	cQuery += " 	LEFT JOIN "+RetSqlName("SA3")+" OWNER_MANAGER ON "
	cQuery += " 		OWNER_MANAGER.A3_FILIAL = '"+xFilial("SA3")+"' AND OWNER_MANAGER.A3_COD = OWNER_SELLER.A3_GEREN AND OWNER_MANAGER.D_E_L_E_T_ = ' ' "
	cQuery += " 	LEFT JOIN "+RetSqlName("SA3")+" CUSTOMER_MANAGER ON "
	cQuery += " 		CUSTOMER_MANAGER.A3_FILIAL = '"+xFilial("SA3")+"' AND CUSTOMER_MANAGER.A3_COD = CUSTOMER_SELLER.A3_GEREN AND CUSTOMER_MANAGER.D_E_L_E_T_ = ' ' "	
	cQuery += " WHERE %ZP5.XFILIAL% "
		
	if !Empty(oFilter:getQuotationId())
		cQuery += " AND ZP5_NUM = '"+oFilter:getQuotationId()+"' "
	elseIf !Empty(cDocType)
		cQuery += " AND EXISTS(SELECT 1 FROM %ZPA.SQLNAME% "
		cQuery += "		   	   WHERE %ZPA.XFILIAL% AND ZPA_NUM = ZP5_NUM AND ZPA_TIPO = '"+cDocType+"' AND "
		cQuery += "				     ZPA_NUMDOC = '"+cDocId+"' AND %ZPA.NOTDEL%) "
	else
		if (!Empty(cCodeCustomer) .and. !Empty(cUnitCustomer))
			cQuery += " AND ZP5_CLIENT = '"+cCodeCustomer+"' AND ZP5_LOJA = '"+cUnitCustomer+"' "
		endIf	
		if !Empty(oFilter:getStartDate())
			cQuery += " AND ZP5_DATA >= '"+DtoS(oFilter:getStartDate())+"' "
		endIf
		if !Empty(oFilter:getEndDate())
			cQuery += " AND ZP5_DATA <= '"+DtoS(oFilter:getEndDate())+"' "
		endIf	 
		if !Empty(cCustomerKeyWord)
			cQuery += " AND (CUSTOMER.A1_COD LIKE '%"+cCustomerKeyWord+"%' OR Lower(CUSTOMER.A1_NOME) LIKE '%"+cCustomerKeyWord+"%' OR "
			cQuery += " CUSTOMER.A1_CGC LIKE '%"+cCustomerKeyWord+"%' )"
		endIf 	
		if !Empty(oFilter:getStatus())
			cQuery += " AND ZP5_STATUS = '"+oFilter:getStatus()+"' "
		endIf
	endIf
	 
	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())
		cQuery += " AND ZP5_CLIENT = '"+oUser:getCustomer():getCode()+"' AND ZP5_LOJA = '"+oUser:getCustomer():getUnit()+"' "
	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND USR.ZP1_CODVEN = '"+oUser:getSeller():getId()+"' "
	else
		if !Empty(oFilter:getOwnerId())
			cQuery += " AND ZP5_RESPON = '"+oFilter:getOwnerId()+"' "
		endIf
		if !Empty(oFilter:getSellerId())
			cQuery += " AND (USR.ZP1_CODVEN = '"+oFilter:getSellerId()+"' OR CUSTOMER.A1_VEND = '"+oFilter:getSellerId()+"') "
		endIf
		if !Empty(oFilter:getManagerId())
			cQuery += " AND (OWNER_MANAGER.A3_COD = '"+oFilter:getManagerId()+"' OR CUSTOMER_MANAGER.A3_COD = '"+oFilter:getManagerId()+"') "
		endIf
		if GetNewPar('ZZ_ALMBRGU', .F.)
			if ( oUtils:isNotNull(oUser) .and. oUser:isManager() )
				cQuery += " AND (OWNER_MANAGER.A3_COD = '" + oUser:getSalesId() + ;
				"' OR CUSTOMER_MANAGER.A3_COD = '" + oUser:getSalesId() + ;
				"' OR  ZP5_RESPON = '" +  oUser:getId() + "'  ) "
			endif
		endif
	endIf
	
	cQuery += " AND %ZP5.NOTDEL% "
	cQuery += " ORDER BY ZP5_NUM DESC " 
	
	oSql:newAlias(cQuery)	
	oSql:setField("DATE", "D")
	oSql:setField("VALID_DATE", "D")
	oSql:setField("STANDARD_DELIVERY", "D")
	oSql:setField("BILLING_DATE", "D")
	oSql:setField("PROC_DATE", "D")	
	
return oSql

/**
 * Cria um Orçamento a partir da consulta SQL
 */
static function createFromSql(oSelf, oSql, oUser, lDetails, lImpostos)
	
	local lCheckMinValues	:= .T.
	local lCheckOnlySugTotal:= .T.
	local oQuotation 		:= CbcQuotation():newCbcQuotation()
	default lImpostos		:= .F.
	
	oQuotation:setStatus(oSql:getValue("STATUS")) 
	oQuotation:setId(oSql:getValue("ID"))
	oQuotation:setLastRevision(oSql:getValue("LAST_REVISION"))
	oQuotation:setDate(oSql:getValue("DATE"))
	oQuotation:setTime(oSql:getValue("AllTrim(TIME)"))
	oQuotation:setIdUser(oSql:getValue("ID_USER"))
	oQuotation:setNameUser(oSql:getValue("AllTrim(NAME_USER)"))
	oQuotation:setType(oSql:getValue("TYPE"))
	oQuotation:setValidDate(oSql:getValue("VALID_DATE"))
	oQuotation:setCodeCustomer(oSql:getValue("CODE_CUSTOMER"))
	oQuotation:setUnitCustomer(oSql:getValue("UNIT_CUSTOMER"))
	oQuotation:setCnpjPadrao(oSql:getValue("CNPJ_CUSTOMER"))
	oQuotation:setNameCustomer(oSql:getValue("AllTrim(NAME_CUSTOMER)"))
	oQuotation:setDelCodeCustomer(oSql:getValue("DEL_CODE_CUSTOMER"))
	oQuotation:setDelUnitCustomer(oSql:getValue("DEL_UNIT_CUSTOMER"))
	oQuotation:setDelNameCustomer(oSql:getValue("AllTrim(DEL_NAME_CUSTOMER)"))
  oQuotation:setDelZipCode(oSql:getValue("AllTrim(DEL_ZIP_CODE)"))
	oQuotation:setDelAddress(oSql:getValue("AllTrim(DEL_ADDRESS)"))
  oQuotation:setDelNumber(oSql:getValue("AllTrim(DEL_NUMBER)"))
  oQuotation:setDelComplement(oSql:getValue("AllTrim(DEL_COMPLEMENT)"))
	oQuotation:setDelCity(oSql:getValue("AllTrim(DEL_CITY)"))
	oQuotation:setDelState(oSql:getValue("DEL_STATE"))
	oQuotation:setFreight(oSql:getValue("FREIGHT"))
	oQuotation:setPaymentCondition(oSql:getValue("PAYMENT_CONDITION"))
	oQuotation:setDescPayment(oSql:getValue("AllTrim(DESC_PAYMENT)"))
	oQuotation:setIdApprover(oSql:getValue("ID_APPROVER"))
	oQuotation:setNameApprover(oSql:getValue("AllTrim(NAME_APPROVER)"))
	oQuotation:setCanEdit(oSql:getValue("(CAN_EDIT == 'S')"))
	oQuotation:setCanTakeApproval(.F.)
	oQuotation:setCanRequestTecnicalApproval(.F.)
	oQuotation:setCanPrint(.F.)
	oQuotation:setComments(oSql:getValue("AllTrim(COMMENTS)"))
	oQuotation:setReasonCancel(oSql:getValue("AllTrim(REASON_CANCEL)"))
	oQuotation:setCancelComments(oSql:getValue("AllTrim(CANCEL_COMMENTS)"))
	oQuotation:setStoredStandardDelivery(oSql:getValue("STANDARD_DELIVERY"))
	oQuotation:setDeliveryType(oSql:getValue("DELIVERY_TYPE"))
	oQuotation:setBillingDate(oSql:getValue("BILLING_DATE"))
	oQuotation:setIssueReport(oSql:getValue("(ISSUE_REPORT == 'S')"))
	oQuotation:setPallets(oSql:getValue("(PALLETS == 'S')"))
	oQuotation:setPartialBilling(oSql:getValue("(PARTIAL_BILLING == 'S')"))
	oQuotation:setCustomerSalesOrder(oSql:getValue("AllTrim(CUSTOMER_SALES_ORDER)"))
	oQuotation:setShippingMessage(oSql:getValue("AllTrim(SHIPPING_MESSAGE)"))
	oQuotation:setInvoiceMessage(oSql:getValue("AllTrim(INVOICE_MESSAGE)"))
	oQuotation:setFixedCommission(oSql:getValue("FIXED_COMMISSION"))
	oQuotation:setProcDate(oSql:getValue("PROC_DATE"))
	oQuotation:setProcTime(oSql:getValue("PROC_TIME"))
	oQuotation:setProcComments(oSql:getValue("AllTrim(PROC_COMMENTS)"))
	oQuotation:setRetail(oSql:getValue("(RETAIL == 'S')"))
	oQuotation:setDocuments(getDocuments(oQuotation, oUser))
	
	setSugAppTotal(@oQuotation)
	
	oQuotation:setMinRgTotal(0)
	oQuotation:setSugRgTotal(0)
	oQuotation:setAppRgTotal(0)
	oQuotation:setCopperTotal(0)	
	oQuotation:setSugDiscountAvg(0)
	oQuotation:setAppDiscountAvg(0)
	oQuotation:setSugCommissionAvg(0)
	oQuotation:setAppCommissionAvg(0)		
	oQuotation:setSugImp(0)
	oQuotation:setAppImp(0)
	oQuotation:setItems({})
	
	if lDetails	
	
		oQuotation:setItems(getItems(oQuotation))
		oQuotation:setMessages(getMessages(oQuotation))
		oQuotation:setRevisions(getRevisions(oQuotation))
		oQuotation:setCompetitors(getCompetitors(oQuotation))
		oSelf:checkRules(@oQuotation)		
		oSelf:canRequestTecnicalApproval(oUser, @oQuotation)		
		oSelf:setTotals(oUser, @oQuotation)
		if lImpostos
			oSelf:calcTaxInfo(oUser, @oQuotation)				
		endif
		oSelf:canTakeApproval(oUser, @oQuotation, nil, lCheckMinValues, lCheckOnlySugTotal)
		oSelf:canPrint(oUser, @oQuotation)	
			
	endIf					
	oQuotation:setNameCustomer(DecodeUTF8(oQuotation:getCnpjNameApi(), "cp1252"))
return oQuotation

/**
 * Define os Totais Sugerido e Aprovado de um Orçamento
 */
static function setSugAppTotal(oQuotation)
	
	local cQuery := ""
	local oSql   := LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT SUM(ZP6_TOTSUG) TOTSUG, SUM(ZP6_TOTAPR) TOTAPR "
	cQuery += " FROM %ZP6.SQLNAME% "
	cQuery += " WHERE %ZP6.XFILIAL% AND ZP6_NUM = '" + oQuotation:getId() + "' AND %ZP6.NOTDEL% "
	
	oSql:newAlias(cQuery)
	
	oQuotation:setSugTotal(oSql:getValue("TOTSUG"))
	oQuotation:setAppTotal(oSql:getValue("TOTAPR"))
	
	oSql:close()
	
return

/**
 * Coleta os Itens de um Orçamento
 */
static function getItems(oQuotation)
	
	local oItem   := nil
	local aItems  := {}
	local cQuery  := ""
	local oSql	  := LibSqlObj():newLibSqlObj()
	local oSrvBal := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	
	cQuery := " SELECT ZP6_ITEM ITEM, ZP6_NOME CODE_NAME, Z1_DESC NAME, ZP6_BITOLA CODE_BITOLA, Z2_DESC BITOLA,"
	cQuery += " 	   ZP6_ACOND ID_PACKAGE, ZP6_QTACON AMOUNT_PACKAGE, ZP6_QTDESP SPECIFIC_PACKAGE_AMOUNT, "
	cQuery += " 	   ZP6_ESPECI SPECIALTY, ZP6_DESCRI DESCRIPTION, ZP6_QUANT QUANTITY, ZP6_TABPRC ID_LIST_PRICE, "
	cQuery += "  	   ZP6_PRCTAB LIST_PRICE, ZP6_DESCAV CASH_PAYMENT_DISCOUNT, ZP6_DESCFR FREIGHT_DISCOUNT, "
	cQuery += "  	   ZP6_PRCMIN MIN_PRICE, ZP6_TOTMIN MIN_TOTAL, ZP6_RGMIN MIN_RG, ZP6_PRCSUG SUG_PRICE, "
	cQuery += "  	   ZP6_TOTSUG SUG_TOTAL, ZP6_COMSUG SUG_COMMISSION, ZP6_RGSUG SUG_RG, ZP6_PRCAPR APP_PRICE, ZP6_TOTAPR APP_TOTAL, "
	cQuery += "  	   ZP6_COMAPR APP_COMMISSION, ZP6_RGAPR APP_RG, ZP6_APAUTO APP_AUTO, ZP6_DIFPRC PRICE_DIFF, ZP6_FILRES BRANCH_RESERVE, "
	cQuery += "  	   ZP6_NUMRES ID_RESERVE, ZP6_PEDCLI CUSTOMER_SALES_ORDER, ZP6_ITPEDC ITEM_CUSTOMER_SALES_ORDER, ZP6_DESPAD DEF_DISCOUNT, "
	cQuery += "  	   ZP6_DESSUG SUG_DISCOUNT, ZP6_DESAPR APP_DISCOUNT, ZP6_COMFIX FIXED_COMMISSION, Z4_DETALHE DESC_SPECIALTY " 
	cQuery += " FROM %ZP6.SQLNAME% "
	cQuery += " 	INNER JOIN %SZ1.SQLNAME% ON "
	cQuery += " 		%SZ1.XFILIAL% AND Z1_COD = ZP6_NOME AND %SZ1.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ2.SQLNAME% ON "
	cQuery += " 		%SZ2.XFILIAL% AND Z2_COD = ZP6_BITOLA AND %SZ2.NOTDEL% "
	cQuery += " 	LEFT JOIN %SZ4.SQLNAME% ON "
	cQuery += " 		%SZ4.XFILIAL% AND Z4_COD = ZP6_ESPECI AND %SZ4.NOTDEL% "
	cQuery += " WHERE %ZP6.XFILIAL% AND ZP6_NUM = '"+oQuotation:getId()+"' AND %ZP6.NOTDEL% "
	cQuery += " ORDER BY 1 "

	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oItem := CbcQuotationItem():newCbcQuotationItem()
		oItem:setItem(oSql:getValue("ITEM"))
		oItem:setName(oSql:getValue("NAME"))
		oItem:setCodeName(oSql:getValue("CODE_NAME"))
		oItem:setBitola(oSql:getValue("BITOLA"))
		oItem:setCodeBitola(oSql:getValue("CODE_BITOLA"))
		oItem:setIdPackage(oSql:getValue("ID_PACKAGE"))
		oItem:setAmountPackage(oSql:getValue("AMOUNT_PACKAGE"))
		oItem:setSpecificPackageAmount(oSql:getValue("(SPECIFIC_PACKAGE_AMOUNT == 'S')"))
		oItem:setSpecialty(oSql:getValue("SPECIALTY"))
		oItem:setDescription(oSql:getValue("DESCRIPTION"))
		oItem:setQuantity(oSql:getValue("QUANTITY"))
		oItem:setIdListPrice(oSql:getValue("ID_LIST_PRICE"))
		oItem:setListPrice(oSql:getValue("LIST_PRICE"))
		oItem:setCashPaymentDiscount(oSql:getValue("CASH_PAYMENT_DISCOUNT"))
		oItem:setFreightDiscount(oSql:getValue("FREIGHT_DISCOUNT"))
		oItem:setMinPrice(oSql:getValue("MIN_PRICE"))
		oItem:setMinTotal(oSql:getValue("MIN_TOTAL"))
		oItem:setMinRg(oSql:getValue("MIN_RG"))
		oItem:setSugPrice(oSql:getValue("SUG_PRICE"))
		oItem:setSugTotal(oSql:getValue("SUG_TOTAL"))
		oItem:setSugCommission(oSql:getValue("SUG_COMMISSION"))
		oItem:setSugRg(oSql:getValue("SUG_RG"))
		oItem:setAppPrice(oSql:getValue("APP_PRICE"))
		oItem:setAppTotal(oSql:getValue("APP_TOTAL"))
		oItem:setAppCommission(oSql:getValue("APP_COMMISSION"))
		oItem:setAppRg(oSql:getValue("APP_RG"))
		oItem:setAppAuto(oSql:getValue("(APP_AUTO == 'S')"))
		oItem:setFixedCommission(oSql:getValue("(FIXED_COMMISSION == 'S')"))
		oItem:setPriceDiff(oSql:getValue("PRICE_DIFF"))		
		oItem:setBranchReserve(oSql:getValue("BRANCH_RESERVE"))
		oItem:setIdReserve(oSql:getValue("ID_RESERVE"))
		oItem:setCustomerSalesOrder(oSql:getValue("CUSTOMER_SALES_ORDER"))
		oItem:setItemCustomerSalesOrder(oSql:getValue("ITEM_CUSTOMER_SALES_ORDER"))
		oItem:setColors(getColors(oQuotation, oItem))		
		oItem:setDefDiscount(oSql:getValue("DEF_DISCOUNT"))
		oItem:setSugDiscount(oSql:getValue("SUG_DISCOUNT"))
		oItem:setAppDiscount(oSql:getValue("APP_DISCOUNT"))	
		oItem:setFlex25(oSql:getValue("(CODE_NAME == '115' .AND. CODE_BITOLA == '05')"))
		oItem:setDescSpecialty(oSql:getValue("AllTrim(DESC_SPECIALTY)"))	
		
		aAdd(aItems, oItem)
		
		oSql:skip()
	endDo
	
	oSql:close()	
	
return aItems

/**
 * Coleta as Cores de um Item
 */
static function getColors(oQuotation, oItem)
	
	local oColor  := nil
	local aColors := {} 
	local cQuery := ""
	local oSql	 := LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT ZP9_COR [ID], ZP9_DESCOR NAME, ZP9_QUANT QUANTITY, ZP9_TOTAL TOTAL, ZP9_REQAPR REQUIRE_APPROVAL, ZP9_POSHPH POSHIP "
	cQuery += " FROM %ZP9.SQLNAME% "
	cQuery += " WHERE %ZP9.XFILIAL% AND ZP9_NUM = '"+oQuotation:getId()+"' AND ZP9_ITEM = '"+oItem:getItem()+"' AND %ZP9.NOTDEL% "
	cQuery += " ORDER BY 2 "

	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oColor := CbcQuotationItemColor():newCbcQuotationItemColor()
		oColor:setColorId(oSql:getValue("ID"))
		oColor:setColorName(oSql:getValue("NAME"))
		oColor:setQuantity(oSql:getValue("QUANTITY"))
		oColor:setTotal(oSql:getValue("TOTAL"))
		oColor:setRequireApproval(oSql:getValue("REQUIRE_APPROVAL == 'S'"))			
		oColor:setPoShip(oSql:getValue("POSHIP"))
		
		aAdd(aColors, oColor)
		
		oSql:skip()
	endDo
	
	oSql:close()	
	
return aColors

/**
 * Coleta os Documentos de um Orçamento
 */
static function getDocuments(oQuotation, oUser)
	
	local oDoc	 		:= nil
	local aDocs  		:= {}
	local cQuery 		:= ""
	local lShowUSeries	:= .T. 
	local oSql	 		:= LibSqlObj():newLibSqlObj()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	
	if oUtils:isNotNull(oUser)
		lShowUSeries := (oUser:getGroup() $ GetNewPar("ZZ_GRPNFU", "01,05,06,07,08"))
	endIf
	
	cQuery := " SELECT ZPA_CODFIL BRANCH_ID, ZPA_TIPO [TYPE], ZPA_NUMDOC [ID], ZPA_SERIE SERIES, "
	cQuery += " 	   ZPA_DATA [DATE], ZPA_HORA [TIME], ZPA_EXCL DELETED, ZPA_OBS COMMENTS " 
	cQuery += " FROM %ZPA.SQLNAME% "
	cQuery += " WHERE %ZPA.XFILIAL% AND ZPA_NUM = '"+oQuotation:getId()+"' AND %ZPA.NOTDEL% "
	cQuery += " ORDER BY ZPA_DATA, ZPA_HORA "

	oSql:newAlias(cQuery)
	
	oSql:setField("DATE", "D") 
	
	while oSql:notIsEof()
	
		if (oSql:getValue("AllTrim(SERIES) == 'U'") .and. !lShowUSeries)
			oSql:skip()
			loop
		endIf
		
		oDoc := CbcQuotationDocument():newCbcQuotationDocument()		
		oDoc:setBranchId(oSql:getValue("BRANCH_ID"))
		oDoc:setType(oSql:getValue("TYPE"))
		oDoc:setId(oSql:getValue("ID"))
		oDoc:setSeries(oSql:getValue("SERIES"))
		oDoc:setDate(oSql:getValue("DATE"))
		oDoc:setTime(oSql:getValue("TIME"))
		oDoc:setDeleted(oSql:getValue("(DELETED == 'S')"))	
		oDoc:setComments(oSql:getValue("AllTrim(COMMENTS)"))	
		
		aAdd(aDocs, oDoc)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aDocs

/**
 * Coleta as Mensagens de um Orçamento
 */
static function getMessages(oQuotation)
	
	local oSrvMsg   := CbcMessageService():newCbcMessageService()
	local aMessages := oSrvMsg:findByQuotation(oQuotation:getId())
	
return aMessages

/**
 * Coleta as Revisões de um Orçamento
 */
static function getRevisions(oQuotation)
	
	local oRevision	 := nil
	local aRevisions := {}
	local cQuery	 := ""
	local oSql		 := LibSqlObj():newLibSqlObj()

	cQuery := " SELECT ZPE_REVISA REVISION, ZPE_EVENTO [EVENT], ZPE_CODUSR USER_ID, ZP1_NOME USER_NAME, "
	cQuery += "  	   ZPE_DATA [DATE], ZPE_HORA [TIME], CAST(CAST(ZPE_JSON AS VARBINARY(8000)) AS VARCHAR(8000)) JSON "
	cQuery += " FROM %ZPE.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += "  		%ZP1.XFILIAL% AND ZP1_CODIGO = ZPE_CODUSR AND %ZP1.NOTDEL%  "
	cQuery += " WHERE %ZPE.XFILIAL% AND ZPE_NUM = '"+oQuotation:getId()+"' AND %ZPE.NOTDEL% "
	cQuery += " ORDER BY 1 "
	
	oSql:newAlias(cQuery)
	oSql:setField("DATE", "D")
	
	while oSql:notIsEof()
		
		oRevision := CbcQuotationRevision():newCbcQuotationRevision()
		oRevision:setRevision(oSql:getValue("REVISION"))
		oRevision:setEvent(oSql:getValue("EVENT"))
		oRevision:setIdUser(oSql:getValue("USER_ID"))
		oRevision:setNameUser(oSql:getValue("AllTrim(Capital(USER_NAME))"))
		oRevision:setDate(oSql:getValue("DATE"))
		oRevision:setTime(oSql:getValue("TIME"))
		oRevision:setJson(oSql:getValue("AllTrim(JSON)"))
		
		aAdd(aRevisions, oRevision)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aRevisions

/**
 * Coleta os Concorrentes de um Orçamento
 */
static function getCompetitors(oQuotation)
	
	local oCompetitor  := nil
	local aCompetitors := {}
	local cQuery	   := ""
	local oSql		   := LibSqlObj():newLibSqlObj()

	cQuery := " SELECT ZPG_CODCON [ID], ZPF_NOME [VALUE] "
	cQuery += " FROM %ZPG.SQLNAME% "
	cQuery += " 	INNER JOIN %ZPF.SQLNAME% ON "
	cQuery += "  		%ZPF.XFILIAL% AND ZPF_CODIGO = ZPG_CODCON AND %ZPF.NOTDEL%  "
	cQuery += " WHERE %ZPG.XFILIAL% AND ZPG_NUM = '"+oQuotation:getId()+"' AND %ZPG.NOTDEL% "
	cQuery += " ORDER BY 2 "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oCompetitor := CbcGeneric():newCbcGeneric()
		oCompetitor:setId(oSql:getValue("ID"))
		oCompetitor:setValue(oSql:getValue("AllTrim(VALUE)"))
		
		aAdd(aCompetitors, oCompetitor)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aCompetitors

/**
 * Filtra os Orçamentos da Pesquisa de acordo com a opção de Aprovação selecionada
 */
static function filterByApprovalStatus(oSelf, aQuotations, oUser, cApproval)
	
	local nI					:= 0
	local lAdd					:= .F.
	local lCheckMinValues 		:= .T.
	local lCheckOnlySugTotal	:= .T.						
	local aFiltered 			:= {}
	local oQuotation			:= nil
	local lApprovingly			:= (cApproval == "1")
	local lCompetence			:= (cApproval == "2")
	
	if Empty(cApproval) .or. !oUser:isApprover()
		return
	endIf	
	
	for nI := 1 to Len(aQuotations)
		
		lAdd	   := .F.
		oQuotation := aQuotations[nI]
		
		if lApprovingly .and. (oQuotation:getStatus() == QUOTATION_STATUS_APPROVINGLY .and. oQuotation:getIdApprover() == oUser:getId())
			lAdd := .T.
		elseIf lCompetence .and. (oQuotation:getStatus() == QUOTATION_STATUS_WAITING_APPROVAL)
			lAdd := oSelf:canTakeApproval(oUser, oQuotation, nil, lCheckMinValues, lCheckOnlySugTotal)
		endIf
		
		if lAdd
			aAdd(aFiltered, oQuotation)
		endIf
		
	next nI
	
	aQuotations := aFiltered
	
return


/*/{Protheus.doc} getById

Coleta um Orçamento pelo ID
	
@author victorhugo
@since 01/06/2016

@param cQuotationId, String, ID do Orçamento
@param cUserId, String, ID do Usuário do Portal (opcional)
@param cRevision, String, Revisão do Orçamento (opcional)

@return CbcQuotation Orçamento solicitado
/*/
method getById(cQuotationId, cUserId, cRevision, lImpostos) class CbcQuotationService
	
	local oQuotation  := nil
	local aQuotations := {}
	local lDetails	  := .T.
	local oFilter     := CbcQuotationFilter():newCbcQuotationFilter()
	default lImpostos := .F.

	if !Empty(cRevision)
		return getByRevision(@self, cQuotationId, cRevision)
	endIf
	
	oFilter:setUserId(cUserId)
	oFilter:setQuotationId(cQuotationId)
	
	aQuotations := ::search(oFilter, lDetails, lImpostos)
	
	if (Len(aQuotations) > 0)
		oQuotation := aQuotations[1] 
	endIf
	
return oQuotation

/**
 * Retorna um Orçamento a partir da Revisão
 */
static function getByRevision(oSelf, cQuotationId, cRevision)
	
	local nRecno	 := 0	
	local cQuery	 := ""			
	local cMemo		 := ""
	local oQuotation := nil
	local oRevision	 := nil
	local oMemo		 := nil
	local oSql		 := LibSqlObj():newLibSqlObj()
	local oUtils	 := LibUtilsObj():newLibUtilsObj()

	cQuery := "SELECT R_E_C_N_O_ AS RECNO "  
	cQuery += " FROM %ZPE.SQLNAME% "
	cQuery += " WHERE %ZPE.XFILIAL% AND ZPE_NUM = '"+cQuotationId+"' AND "
	cQuery += "  	  ZPE_REVISA = '"+cRevision+"' AND %ZPE.NOTDEL% " 
	
	oSql:newAlias(cQuery)
	
	if oSql:hasRecords()
	
		oMemo 	:= ManBaseDados():newManBaseDados()
		nRecno 	:= oSql:getValue("RECNO")
		cMemo	:= oMemo:getMemo('ZPE', 'ZPE_JSON', nRecno, .T. )
		
		if !oMemo:lOk
			oSelf:cErrorMessage := oMemo:cMsgErro
		else
			oQuotation := CbcQuotation():newCbcQuotation()			
			oQuotation:fromJsonObject(cMemo)			
			oQuotation:setStatus(QUOTATION_STATUS_REVISION)
			oQuotation:setLastRevision(cRevision)
			oQuotation:setRevisions(getRevisions(oQuotation))
		endif
		
	else
		oSelf:cErrorMessage := "Nenhum registro encontrado"
	endIf
	
	oSql:close()
	
	FreeObj(oMemo)
	
	if oUtils:isNotNull(oQuotation)
		oQuotation:setCanPrint(.T.)
	endIf	
	
return oQuotation


/*/{Protheus.doc} create

Criação de Orçamentos
	
@author victorhugo
@since 01/06/2016

@param oQuotation, CbcQuotation, Orçamento Cobrecom

@return String ID gerado para o Orçamento
/*/
method create(oQuotation) class CbcQuotationService
	
	local cId := ""
	
	if validQuotation("create", @self, oQuotation)
		saveQuotation("create", @self, oQuotation, @cId)
	else
		return ""
	endIf	
	
return cId


/*/{Protheus.doc} update

Atualização de Orçamentos
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param oQuotation, CbcQuotation, Orçamento Cobrecom
@param lItemsChanged, Logico, Indica se algum item foi alterado

@return Logico Indica se o Orçamento foi alterado
/*/
method update(cUserId, oQuotation, lItemsChanged) class CbcQuotationService
	
	local lOk 			:= .F.
	local cQuotationId	:= oQuotation:getId()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if validAction(@self, "update", cUserId, cQuotationId, nil, nil, lItemsChanged) .and. validQuotation("update", @self, oQuotation)
		lOk := saveQuotation("update", @self, oQuotation, nil, cUserId, lItemsChanged)
	endIf
	
	unlockStatus(cQuotationId)

return lOk


/*/{Protheus.doc} update
Reativar orçamento cancelado
@author LeonardoBolognesi
@since 10/08/2021
@param cUserId, String, ID do Usuário
@param oQuotation, CbcQuotation, Orçamento Cobrecom
@param lItemsChanged, Logico, Indica se algum item foi alterado

@return Logico Indica se o Orçamento foi alterado
/*/
method activatecanceled(cUserId, cQuotationId, lItemsChanged) class CbcQuotationService
	local lOk 			:= .F.
	local oQuotation	:= nil
	local lActivate		:= .T.
	static lDoActive	:=  GetNewPar('ZZ_OFFCANC', .T.)
	static nDias		:=  GetNewPar('ZZ_OFFDIA', 120)

	if !lDoActive
		::cErrorMessage := "Ativação de orçamento desabilitada!"
		return .F.
	else
		if !lockStatus(@self, cQuotationId, cUserId)
			return .F.
		endIf
		oQuotation := ::getById(cQuotationId, cUserId)
		if  oQuotation:getStatus() != QUOTATION_STATUS_CANCELED
			::cErrorMessage := "Orçamento não esta cancelado!"
			return .F.
		elseif  DateDiffDay(oQuotation:getDate(), Date()) > nDias
			::cErrorMessage := "Permitido ativar orçamentos apenas com emissão am até " + cValToChar(nDias) + " dia(s) retroativo(s)!"
			return .F.
		endif
		if validAction(@self, "activate_canceled", cUserId, cQuotationId, nil, nil, lItemsChanged) .and. validQuotation("update", @self, oQuotation)
			begin transaction	
				updateStatus(@self, cQuotationId, QUOTATION_STATUS_UNDER_MAINTENANCE)
				updateValidDate(cQuotationId)
				oQuotation := ::getById(cQuotationId, cUserId)
				oQuotation:setStatus(QUOTATION_STATUS_UNDER_MAINTENANCE)
				oQuotation:setBillingDate(date())
				oQuotation:setStandardDelivery(date())
				lOk := saveQuotation("update", @self, oQuotation, nil, cUserId, lItemsChanged, lActivate)
			end transaction
		endIf
		unlockStatus(cQuotationId)
	endif
return lOk


/**
 * Valida um Orçamento para Inclusão ou Alteração
 */
static function validQuotation(cOperation, oSelf, oQuotation)
	
	local lOk 	  		:= .F.
	local cError  		:= ""
	local cUserGroup	:= ""
	local lCreate 		:= (cOperation ==  "create")
	local lUpdate 		:= (cOperation ==  "update")
	local oCustomer	    := nil
	local oDelCustomer  := nil
	local oSql	  		:= LibSqlObj():newLibSqlObj()
	local oUtils		:= LibUtilsObj():newLibUtilsObj() 
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService() 
	
	begin sequence
		
		if lUpdate .and. Empty(oQuotation:getId())  
			cError := "Número do Orçamento não informado"
			break
		endIf
		
		if lUpdate .and. !oSql:exists("ZP5", "%ZP5.XFILIAL% AND ZP5_NUM = '"+oQuotation:getId()+"'")  
			cError := "Orçamento não encontrado"
			break
		endIf
		
		if lCreate .and. !oSql:exists("ZP1", "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+oQuotation:getIdUser()+"'")
			cError := "Usuário inválido"
			break
		endIf
		
		if !(oQuotation:getType() $ QUOTATION_TYPE_NORMAL+","+QUOTATION_TYPE_SALES_ORDER+","+QUOTATION_TYPE_BONUS)
			cError := "Tipo do Orçamento inválido"
			break
		endIf
		
		if Empty(oQuotation:getCodeCustomer()) .or. Empty(oQuotation:getUnitCustomer())
			cError := "Cliente não informado"
			break	
		endIf
		
		oCustomer := oSrvCustomer:findByCode(oQuotation:getCodeCustomer(), oQuotation:getUnitCustomer())
		if oUtils:isNull(oCustomer)
			cError := "Cliente inválido"
			break
		elseIf oCustomer:isBlocked()
			cError := "Cliente bloqueado"
			break
		endIf
		
		cUserGroup := oSql:getFieldValue("ZP1", "ZP1_GRUPO", "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+oQuotation:getIdUser()+"'")
		
		if (oCustomer:getCode() == DEFAULT_CUSTOMER_CODE .and. oCustomer:getUnit() == DEFAULT_CUSTOMER_UNIT) .and. (cUserGroup != USER_SELLER) 
			cError := "O cliente padrão só pode ser usado por usuários do Grupo Representantes"
			break
		endIf
		
		if (oCustomer:getCode() == DEFAULT_CUSTOMER_CODE .and. oCustomer:getUnit() == DEFAULT_CUSTOMER_UNIT) .and. Empty(oQuotation:getCnpjPadrao()) 
			cError := "Orçamento padrão, obrigatório informar CNPJ"
			break
		endIf


		if !Empty(oQuotation:getDelCodeCustomer())
			
			if Empty(oQuotation:getDelUnitCustomer())
				cError := "Loja de Entrega não informada"
				break	
			endIf
		
			oDelCustomer := oSrvCustomer:findByCode(oQuotation:getDelCodeCustomer(), oQuotation:getDelUnitCustomer())
			if oUtils:isNull(oDelCustomer)
				cError := "Cliente de Entrega inválido"
				break
			elseIf oDelCustomer:isBlocked()
				cError := "Cliente de Entrega bloqueado"
				break
			endIf
		
		endIf
		
		if Empty(oQuotation:getDeliveryType())
			cError := "Tipo de Entrega não informado"
			break
		endIf
		
		if !Empty(oQuotation:getFreight()) .and. !(oQuotation:getFreight() $ "C,F")
			cError := "Tipo de Frete inválido"
			break
		endIf
		
		if Empty(oQuotation:getPaymentCondition()) .or. !oSql:exists("SE4", "%SE4.XFILIAL% AND E4_CODIGO = '"+oQuotation:getPaymentCondition()+"'")
			cError := "Condição de Pagamento inválida"
			break
		endIf
		
		if (!oSql:exists("SE4", "%SE4.XFILIAL% AND E4_CODIGO = '"+oQuotation:getPaymentCondition()+"' AND E4_XPORTAL = 'S' AND E4_MSBLQL != '1'") .and. ;
			oQuotation:getPaymentCondition() != oCustomer:getPaymentCondition() .and. oQuotation:getPaymentCondition() != BONUS_PAYMENT_CONDITION)
			cError := "Condição de Pagamento inválida para o cliente informado"
			break
		endIf	
		
		if !checkReserves(oQuotation, @cError)
			break
		endIf
		
		if !validItemsQuotation(cOperation, oQuotation, @cError)
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
	oSelf:cErrorMessage := cError	
	
return lOk

/**
 * Não permite misturar itens com e sem reservas
 */
static function checkReserves(oQuotation, cError)
	
	local nI	 			:= 0
	local nX				:= 0
	local nInvalidReserves	:= 0
	local lOk				:= .T.
	local lHasReserves		:= .F.
	local cStatus			:= ""
	local aInvalidReserves	:= {}
	local oItem				:= nil
	local oSql				:= LibSqlObj():newLibSqlObj()
	local aItems 			:= oQuotation:getItems()
	
	for nI := 1 to Len(aItems)		
		if !Empty(aItems[nI]:getIdReserve())
			lHasReserves := .T.
			exit
		endIf
	next nI
	
	if !lHasReserves
		return .T.
	endIf
	
	for nI := 1 to Len(aItems)
		
		oItem := aItems[nI]
	
		if !Empty(oItem:getIdReserve())
			/* cError := "Não é permitido misturar itens com reserva e itens sem reserva"
			lOk    := .F.
			exit */
			cStatus := oSql:getFieldValue("ZP4", "ZP4_STATUS", "ZP4_FILIAL = '"+oItem:getBranchReserve()+"' AND ZP4_CODIGO = '"+oItem:getIdReserve()+"'")
			
			if (cStatus == RESERVE_STATUS_EXPIRED .or. cStatus == RESERVE_STATUS_CANCELED)
				aAdd(aInvalidReserves, oItem:getIdReserve())
			endIf
		endIf
				
	next nI
	
	nInvalidReserves := Len(aInvalidReserves)
	if lOk .and. (nInvalidReserves > 0)
		lOk 	:= .F.
		cError  := "As seguintes reservas estão expiradas ou foram canceladas: "
		for nX := 1 to nInvalidReserves
			cError += aInvalidReserves[nX]
			if nX < nInvalidReserves
				cError += ',  '
			endif
		next nX
	endIf
		
return lOk

/**
 * Validação dos Itens do Orçamento
 */
static function validItemsQuotation(cOperation, oQuotation, cError)
	
	local nI		:= 0
	local lOk 		:= .F.
	local cItem		:= ""
	local oItem		:= nil
	local aItems	:= oQuotation:getItems()
	local oSql	  	:= LibSqlObj():newLibSqlObj()
	
	begin sequence
		
		if Empty(aItems)
			cError := "Nenhum item informado"
			break
		endIf
		
		for nI := 1 to Len(aItems)
			
			oItem := aItems[nI]
			cItem := StrZero(nI, 2)
			
			oItem:setItem(cItem)
			
			if Empty(oItem:getCodeName()) .or. !oSql:exists("SZ1", "%SZ1.XFILIAL% AND Z1_COD = '"+oItem:getCodeName()+"' AND Z1_XPORTAL IN ('S','E')")
				cError := "Produto inválido para o item "+cItem
				break
			endIf
			
			if Empty(oItem:getCodeBitola()) .or. !oSql:exists("SZ2", "%SZ2.XFILIAL% AND Z2_COD = '"+oItem:getCodeBitola()+"' AND Z2_XPORTAL IN ('S','E')")
				cError := "Bitola inválida para o item "+cItem
				break
			endIf
			
			if Empty(oItem:getIdPackage()) .or. !(oItem:getIdPackage() $ "R,B,C,M,T,L")
				cError := "Acondicionamento inválido para o item "+cItem
				break
			endIf
			
			if !validColorsItem(oItem, @cError)
				break
			endIf
			
			if !validReserveItem(cOperation, oQuotation, oItem, @cError)
				break
			endIf
			
		next nI
		
		lOk := .T.
		
	end sequence
	
return lOk

/**
 * Valida as Cores de um Item
 */
static function validColorsItem(oItem, cError)
			
	local nI		:= 0
	local lOk 		:= .F.
	local cItem		:= oItem:getItem()
	local oColor	:= nil
	local aColors	:= oItem:getColors()
	local oSql	  	:= LibSqlObj():newLibSqlObj()
	
	begin sequence
		
		if Empty(aColors)
			cError := "Cores não informadas para o item "+cItem
			break
		endIf
		
		for nI := 1 to Len(aColors)
		
			oColor := aColors[nI]
		
			if Empty(oColor:getColorId()) .or. !oSql:exists("SZ3", "%SZ3.XFILIAL% AND Z3_COD = '"+oColor:getColorId()+"' AND Z3_XPORTAL IN ('S', 'E')")
				cError := "Cor "+AllTrim(Str(nI))+" inválida para o item "+cItem
				break
			endIf
			
			if Empty(oColor:getQuantity()) .or. oColor:getQuantity() < 0
				cError := "Quantidade inválida para a Cor "+AllTrim(Str(nI))+" do item "+cItem
				break
			endIf
			
			if Empty(oColor:getTotal()) .or. oColor:getTotal() < 0
				cError := "Total inválido para a Cor "+AllTrim(Str(nI))+" do item "+cItem
				break
			endIf
		
		next nI
		
		lOk := .T.
		
	end sequence
	
return lOk

/**
 * Valida a Reserva de um Item
 */
static function validReserveItem(cOperation, oQuotation, oItem, cError)	
	
	local lOk			 := .F.
	local cWhere		 := ""
	local cBranchReserve := oItem:getBranchReserve()
	local cIdReserve	 := oItem:getIdReserve()
	local oSql			 := LibSqlObj():newLibSqlObj()
	
	if Empty(cIdReserve)
		return .T.
	endIf
	
	begin sequence
		
		cWhere := "%ZP6.XFILIAL% AND ZP6_FILRES = '"+cBranchReserve+"' AND ZP6_NUMRES = '"+cIdReserve+"'"
		
		if (cOperation == "update")
			cWhere += " AND ZP6_NUM != '"+oQuotation:getId()+"' "
		endIf
		
		oSql:newTable("ZP6", "ZP6_NUM [ID]", cWhere)
	
		if oSql:hasRecords()
			cError := "A reserva "+cIdReserve+" já está vinculada a outro Orçamento"
			break
		endIf
	
		lOk := .T.
		
	end sequence
	
	oSql:close()
	
return lOk

/**
 * Inclui ou Altera um Orçamento
 */
static function saveQuotation(cOperation, oSelf, oQuotation, cId, cUserId, lItemsChanged, lActivate)
	
	local lOk   		  := .F.
	local lCreateRevision := .F.
	local aData 		  := {}
	local cStatus		  := ""
	local cEvent		  := if(cOperation == "create", EVENT_QUOTATION_CREATE, EVENT_QUOTATION_UPDATE)
	local oSql	    	  := LibSqlObj():newLibSqlObj()
	default lItemsChanged := .T.
	default lActivate	  := .F.
	
	if (cOperation ==  "create")
		cId 	 := GetSxeNum("ZP5", "ZP5_NUM")
		cUserId  := oQuotation:getIdUser()
		aAdd(aData, {"ZP5_FILIAL", xFilial("ZP5")})
		aAdd(aData, {"ZP5_STATUS", QUOTATION_STATUS_UNDER_MAINTENANCE})
		aAdd(aData, {"ZP5_NUM", cId})
		aAdd(aData, {"ZP5_DATA", Date()})
		aAdd(aData, {"ZP5_HORA", Left(Time(), 5)})
		aAdd(aData, {"ZP5_RESPON", cUserId})
		aAdd(aData, {"ZP5_ALTERA", "S"})		
	else
		if lActivate
			aAdd(aData, {"ZP5_DATA", Date()})
			aAdd(aData, {"ZP5_HORA", Left(Time(), 5)})
		endif
		cId := oQuotation:getId()
		oSql:newTable("ZP5", "ZP5_STATUS [STATUS], ZP5_RESPON [OWNER], ZP5_APROVA [APPROVER]", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cId+"'")
		if (cUserId == oSql:getValue("OWNER") .and. lItemsChanged .and. cUserId != oSql:getValue("APPROVER") )	
			cStatus := QUOTATION_STATUS_UNDER_MAINTENANCE
		else
			cStatus := oSql:getValue("STATUS")
			lCreateRevision := .T.
		endIf
		oSql:close()
		aAdd(aData, {"ZP5_STATUS", cStatus})
	endIf	
	
	aAdd(aData, {"ZP5_TIPO", oQuotation:getType()})
	aAdd(aData, {"ZP5_DTVAL", if (Empty(oQuotation:getValidDate()), CtoD(""), oQuotation:getValidDate())})
	aAdd(aData, {"ZP5_CLIENT", oQuotation:getCodeCustomer()})
	aAdd(aData, {"ZP5_LOJA", oQuotation:getUnitCustomer()})
	aAdd(aData, {"ZP5_CNPJ", oQuotation:getCnpjPadrao()})
	aAdd(aData, {"ZP5_NOMCLI", oSql:getFieldValue("SA1", "A1_NOME", "%SA1.XFILIAL% AND A1_COD = '"+oQuotation:getCodeCustomer()+"' AND A1_LOJA = '"+oQuotation:getUnitCustomer()+"'")})
	aAdd(aData, {"ZP5_CLENTR", oQuotation:getDelCodeCustomer()})
	aAdd(aData, {"ZP5_LJENTR", oQuotation:getDelUnitCustomer()})
  	aAdd(aData, {"ZP5_CEPENT", oQuotation:getDelZipCode()})
	aAdd(aData, {"ZP5_ENDENT", oQuotation:getDelAddress()})
  	aAdd(aData, {"ZP5_NUMENT", oQuotation:getDelNumber()})
  	aAdd(aData, {"ZP5_COMENT", oQuotation:getDelComplement()})
	aAdd(aData, {"ZP5_MUNENT", oQuotation:getDelCity()})
	aAdd(aData, {"ZP5_UFENT", oQuotation:getDelState()})
	aAdd(aData, {"ZP5_FRETE", oQuotation:getFreight()})
	aAdd(aData, {"ZP5_CONDPG", oQuotation:getPaymentCondition()})
	aAdd(aData, {"ZP5_OBS", FwNoAccent(oQuotation:getComments())})
	aAdd(aData, {"ZP5_TPENT", oQuotation:getDeliveryType()})
	aAdd(aData, {"ZP5_COMFIX", oQuotation:getFixedCommission()})
	aAdd(aData, {"ZP5_DTFAT", if (Empty(oQuotation:getBillingDate()), CtoD(""), oQuotation:getBillingDate())})
	aAdd(aData, {"ZP5_LAUDO", if (oQuotation:isIssueReport(), "S", "N")})
	aAdd(aData, {"ZP5_PALLET", if (oQuotation:isPallets(), "S", "N")})
	aAdd(aData, {"ZP5_FATPAR", if (oQuotation:isPartialBilling(), "S", "N")})
	aAdd(aData, {"ZP5_PEDCLI", oQuotation:getCustomerSalesOrder()})
	aAdd(aData, {"ZP5_OBSTRA", oQuotation:getShippingMessage()})
	aAdd(aData, {"ZP5_OBSNF", FwNoAccent(oQuotation:getInvoiceMessage())})
	aAdd(aData, {"ZP5_VAREJO", if (oQuotation:isRetail(), "S", "N")})
	
	begin transaction
		
		if (cOperation == "update")
			undoReservesConfirm(cOperation, oQuotation)
			if (cStatus == QUOTATION_STATUS_UNDER_MAINTENANCE)
				clearTecnicalApproval(oQuotation,cUserId)
				oSql:update("ZP5", "ZP5_ENTPAD = ' '", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cId+"'")
			endIf
		endIf	
		
		if saveHeader(cOperation, cId, @oSelf, aData) .and. saveItems(cOperation, cId, @oSelf, oQuotation)
			lOk := .T.
			saveCompetitors(cOperation, cId, oQuotation)				 
		endIf
		
		if lOk
			oQuotation := oSelf:getById(cId, cUserId)
			createNotifications(cEvent, cUserId, oQuotation)
			if lCreateRevision
				createRevision(cUserId, oQuotation, QUOTATION_REVISION_UPDATE)
			elseif (cOperation ==  "create")
				createRevision(cUserId, oQuotation, cEvent)
			endIf	
		endIf
		
		if !lOk .and. (cOperation == "create")
			RollBackSx8()
		endIf
		
	end transaction
	
return lOk

/**
 * Trata o Estorno da Confirmação das Reservas
 */
static function undoReservesConfirm(cOperation, oQuotation)
	
	local nScan		:= 0
	local cQuery	:= ""
	local cBranch	:= ""
	local cId		:= ""
	local lUndo		:= .F.
	local aItems	:= oQuotation:getItems()
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local oSrvRes	:= CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	
	cQuery := " SELECT ZP6_FILRES BRANCH, ZP6_NUMRES [ID] "
	cQuery += " FROM %ZP6.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP4.SQLNAME% ON "
	cQuery += " 		ZP4_FILIAL = ZP6_FILRES AND ZP4_CODIGO = ZP6_NUMRES AND  "
	cQuery += "			ZP4_STATUS = '"+RESERVE_STATUS_CONFIRMED+"' AND %ZP4.NOTDEL% "
	cQuery += " WHERE %ZP6.XFILIAL% AND ZP6_NUM = '"+oQuotation:getId()+"' AND %ZP6.NOTDEL% "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		lUndo	:= .T.
		cBranch := oSql:getValue("BRANCH")
		cId 	:= oSql:getValue("ID")
		
		if (cOperation == "update")
			nScan := aScan(aItems, {|oItem| oItem:getBranchReserve() == cBranch .and. oItem:getIdReserve() == cId })
			lUndo := (nScan == 0)
		endIf	
		
		if lUndo
			oSrvRes:undoConfirm(cBranch, cId)
		endIf
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	if (cOperation == "cancel")
		oSql:update("ZP6", "ZP6_FILRES = '', ZP6_NUMRES = ''", "%ZP6.XFILIAL% AND ZP6_NUM = '"+oQuotation:getId()+"'")
	endIf
	
return

/**
 * Limpa as informação da Aprovação Técnica do Orçamento
 */
static function clearTecnicalApproval(oQuotation, cUserId)
	local oSql 				:= nil
	local oSrvQuotation		:= nil
	local cQuotationId		:= nil
	local oQuotSaved 		:= nil
	local aItToUpd 			:= {}
	local aItmSaved 		:= {}
	local nX				:= 0
	local nY				:= 0
	local cCodUpd			:= ''
	local cCodSvd			:= ''
	local lNeedAprov		:= .F.
	local aStrUpd			:= {}
	local aStrSvd			:= {}
	Local lRet				:= .F.

	oSql 				:= LibSqlObj():newLibSqlObj()
	cQuotationId		:= oQuotation:getId()
	
	oSql:newTable("ZP5", "ZP5_STAPTE [STATUS]", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	if oSql:getValue("STATUS") == "1"	
		oSrvQuotation			:= CbcQuotationService():newCbcQuotationService()
		oQuotSaved 				:= oSrvQuotation:getById(cQuotationId, cUserId)
		aItToUpd 				:= oQuotation:getItems() 
		aItmSaved 				:= oQuotSaved:getItems()
		
		// Itens que precisam de aprovação tecnica
		for nX := 1 to len(aItToUpd)
			if aItToUpd[nX]:isSpecificPackageAmount()
				cCodUpd := oSrvQuotation:getProductCode(oQuotation:getCodeCustomer(),;
											oQuotation:getUnitCustomer(),;
											aItToUpd[nX], nil, nil, oQuotation:isRetail())	
				aadd(aStrUpd, {cCodUpd, aItToUpd[nX]:getPackage(),;
										aItToUpd[nX]:getQuantity(),;
										aItToUpd[nX]:getAmountPackage(),;
										.F.})
			endif
		next nX
		// Itens que ja tenho aprovação tecnica
		for nX := 1 to len(aItmSaved)
			if aItmSaved[nX]:isSpecificPackageAmount()
				cCodSvd := oSrvQuotation:getProductCode(oQuotSaved:getCodeCustomer(),;
											oQuotSaved:getUnitCustomer(),;
											aItmSaved[nX], nil, nil, oQuotSaved:isRetail())		
				aadd(aStrSvd, {cCodSvd, aItmSaved[nX]:getPackage(),;
										aItmSaved[nX]:getQuantity(),;
										aItmSaved[nX]:getAmountPackage()})
			endif
		next nX
		// Ordenar pelo produto + acondicionamento
		aSort(aStrUpd ,,,{ |x,y| 	x[1] + x[2] < y[1] + y[2] })
		aSort(aStrSvd ,,,{ |x,y| 	x[1] + x[2] < y[1] + y[2] })
		
		// Validar as aprovações
		for nX := 1 to len(aStrUpd)
			for nY := 1 to len(aStrSvd)
				// Mesmo produto e acondicionamento
				if (aStrSvd[nY][1] == aStrUpd[nX][1]) .And. (aStrSvd[nY][2] == aStrUpd[nX][2])  
					aStrUpd[nX][5] := (aStrSvd[nY][4] == aStrUpd[nX][4])
				endif
			next nY
			if !aStrUpd[nX][5]
				lNeedAprov := .T.
			endif
		next nX
		if lNeedAprov
			oSql:update("ZP5", "ZP5_STAPTE = '', ZP5_USAPTE = '', ZP5_DTAPTE = '', ZP5_HRAPTE = '', ZP5_OBAPTE = '', ZP5_MOTAPT = ''", ; 
				"%ZP5.XFILIAL% AND ZP5_NUM = '" + cQuotationId + "'")
			lRet := .T.
		endif
		FreeObj(oSrvQuotation)
	elseif oSql:getValue("STATUS") == "2"
		oSql:update("ZP5", "ZP5_STAPTE = '', ZP5_USAPTE = '', ZP5_DTAPTE = '', ZP5_HRAPTE = '', ZP5_OBAPTE = '', ZP5_MOTAPT = ''", ; 
				"%ZP5.XFILIAL% AND ZP5_NUM = '" + cQuotationId + "'")
		lRet := .T.
	endif
	FreeObj(oQuotSaved)
	FreeObj(oSql)
return lRet

/**
 * Grava os dados do Cabeçalho do Orçamento
 */
static function saveHeader(cOperation, cId, oSelf, aData)
	
	local nI     := 0
	local lOk    := .F.
	local cField := ""
	local xValue := nil
	local oSql   := LibSqlObj():newLibSqlObj()
	
	if (cOperation ==  "create")
		if oSql:insert("ZP5", aData)
			lOk := .T.
			ConfirmSx8() 
		endIf	
	else
		ZP5->(dbSetOrder(1))
		ZP5->(dbSeek(xFilial("ZP5")+cId))
		if ZP5->(RecLock("ZP5", .F.))
			for nI := 1 to Len(aData)
				cField := aData[nI,1]
				xValue := aData[nI,2]
				if ZP5->(FieldPos(cField) > 0) .and. (ValType(xValue) != "U")
					ZP5->&cField := xValue
				endIf	
			next nI
			ZP5->(MsUnLock())
			lOk := .T.
		endIf	
	endIf
	
	if !lOk
		oSelf:cErrorMessage := "Falha ao gravar cabeçalho do Orçamento"
		DisarmTransaction()
	endIf
	
return lOk

/**
 * Grava os Itens do Orçamento
 */
static function saveItems(cOperation, cId, oSelf, oQuotation)
	
	local lOk    := .T.
	local lClear := .T.
	local nI	 := 0
	local cItem	 := "00"
	local aItems := oQuotation:getItems() 
	local oSql   := LibSqlObj():newLibSqlObj()
	
	if (cOperation ==  "update")
		oSql:delete("ZP6", "%ZP6.XFILIAL% AND ZP6_NUM = '"+cId+"'", lClear)
		oSql:delete("ZP9", "%ZP9.XFILIAL% AND ZP9_NUM = '"+cId+"'", lClear)
	endIf	
	
	for nI := 1 to Len(aItems)
	
		if (nI == 100)
			cItem := "A0"
		else
			cItem := Soma1(cItem)
		endIf		
		
		if !saveItem(oSelf, cId, cItem, aItems[nI], oQuotation)
			lOk := .F.
			exit
		endIf
		
	next nI
	
	if !lOk
		oSelf:cErrorMessage := "Falha ao gravar itens do Orçamento"
		DisarmTransaction()
	endIf
	
return lOk

/**
 * Grava um item do Orçamento
 */
static function saveItem(oSelf, cId, cItem, oItem, oQuotation)
	
	local lOk   := .F.
	local aData := {}
	local oSql  := LibSqlObj():newLibSqlObj()
	
	aAdd(aData, {"ZP6_FILIAL", xFilial("ZP6")})
	aAdd(aData, {"ZP6_NUM", cId})
	aAdd(aData, {"ZP6_ITEM", cItem})
	aAdd(aData, {"ZP6_NOME", oItem:getCodeName()})
	aAdd(aData, {"ZP6_BITOLA", oItem:getCodeBitola()})
	aAdd(aData, {"ZP6_ACOND", oItem:getIdPackage()})
	aAdd(aData, {"ZP6_QTACON", oItem:getAmountPackage()})
	aAdd(aData, {"ZP6_QTDESP", if (oItem:isSpecificPackageAmount(), "S", "N")})
	aAdd(aData, {"ZP6_ESPECI", oItem:getSpecialty()})
	aAdd(aData, {"ZP6_DESCRI", oSelf:getItemDescription(oItem)})
	aAdd(aData, {"ZP6_QUANT", oItem:getQuantity()})
	aAdd(aData, {"ZP6_TABPRC", oItem:getIdListPrice()})
	aAdd(aData, {"ZP6_PRCTAB", oItem:getListPrice()})
	aAdd(aData, {"ZP6_DESCAV", oItem:getCashPaymentDiscount()})
	aAdd(aData, {"ZP6_DESCFR", oItem:getFreightDiscount()})
	aAdd(aData, {"ZP6_PRCMIN", oItem:getMinPrice()})
	aAdd(aData, {"ZP6_TOTMIN", (oItem:getQuantity() * oItem:getMinPrice())})
	aAdd(aData, {"ZP6_RGMIN", oItem:getMinRg()})
	aAdd(aData, {"ZP6_PRCSUG", oItem:getSugPrice()})
	aAdd(aData, {"ZP6_TOTSUG", oItem:getSugTotal()})
	aAdd(aData, {"ZP6_COMSUG", oItem:getSugCommission()})
	aAdd(aData, {"ZP6_RGSUG", oItem:getSugRg()})
	aAdd(aData, {"ZP6_PRCAPR", oItem:getAppPrice()})
	aAdd(aData, {"ZP6_TOTAPR", oItem:getAppTotal()})
	aAdd(aData, {"ZP6_COMAPR", oItem:getAppCommission()})
	aAdd(aData, {"ZP6_RGAPR", oItem:getAppRg()})
	aAdd(aData, {"ZP6_APAUTO", if (oItem:isAppAuto(), "S", "N")})
	aAdd(aData, {"ZP6_DIFPRC", oItem:getPriceDiff()})	
	aAdd(aData, {"ZP6_FILRES", oItem:getBranchReserve()})
	aAdd(aData, {"ZP6_NUMRES", oItem:getIdReserve()})
	aAdd(aData, {"ZP6_PEDCLI", AllTrim(oItem:getCustomerSalesOrder())})
	aAdd(aData, {"ZP6_ITPEDC", AllTrim(oItem:getItemCustomerSalesOrder())})	
	aAdd(aData, {"ZP6_DESPAD", oItem:getDefDiscount()})
	aAdd(aData, {"ZP6_DESSUG", oItem:getSugDiscount()})
	aAdd(aData, {"ZP6_DESAPR", oItem:getAppDiscount()})
	
	if oSql:insert("ZP6", aData)
		lOk := saveColors(oSelf, cId, cItem, oItem, oQuotation)
	endIf
	
return lOk

/**
 * Grava as Cores de um Item
 */
static function saveColors(oSelf, cId, cItem, oItem, oQuotation)
	
	local lOk     		:= .T.
	local nI			:= 0
	local aData   		:= {}
	local oColor  		:= nil
	local cProductCode	:= ""
	local cCustomer		:= oQuotation:getCodeCustomer()
	local cUnit			:= oQuotation:getUnitCustomer()
	local aColors 		:= oItem:getColors()
	local oSql   	 	:= LibSqlObj():newLibSqlObj()	
	
	for nI := 1 to Len(aColors)
		
		aData  		 := {}
		oColor 		 := aColors[nI]
		cProductCode := oSelf:getProductCode(cCustomer, cUnit, oItem, oColor:getColorId(), nil, oQuotation:isRetail())
		
		aAdd(aData, {"ZP9_FILIAL", xFilial("ZP9")})
		aAdd(aData, {"ZP9_NUM", cId})
		aAdd(aData, {"ZP9_ITEM", cItem})
		aAdd(aData, {"ZP9_COR", oColor:getColorId()})
		aAdd(aData, {"ZP9_DESCOR", oSql:getFieldValue("SZ3", "Z3_DESC", "%SZ3.XFILIAL% AND Z3_COD = '"+oColor:getColorId()+"'")})
		aAdd(aData, {"ZP9_QUANT", oColor:getQuantity()})
		aAdd(aData, {"ZP9_TOTAL", oColor:getTotal()})
		aAdd(aData, {"ZP9_CODPRO", cProductCode})
		aAdd(aData, {"ZP9_REQAPR", if (oColor:requireApproval(), "S", "N")})
		aAdd(aData, {"ZP9_POSHPH", oColor:getPoShip()})
		
		if !oSql:insert("ZP9", aData)
			lOk := .F.
			exit
		endIf
		
	next nI	
	
return lOk

/**
 * Salva uma Revisão do Orçamento
 */
static function createRevision(cUserId, oQuotation, cEvent)
	
	local aData  	 	:= {}
	local lClassName 	:= .T.
	local lUtc		 	:= .F.
	local oSql   	 	:= LibSqlObj():newLibSqlObj()
	local cNextRevision	:= oSql:getNextTableCode("ZPE", "ZPE_REVISA", "%ZPE.XFILIAL% AND ZPE_NUM = '"+oQuotation:getId()+"'")
	
	if (cNextRevision == "01")
		cEvent := QUOTATION_REVISION_CREATE
	endIf
	
	oQuotation:setRevisions({})
	oQuotation:setLastRevision(cNextRevision)
	
	aAdd(aData, {"ZPE_FILIAL", xFilial("ZPE")})
	aAdd(aData, {"ZPE_NUM", oQuotation:getId()})
	aAdd(aData, {"ZPE_EVENTO", cEvent})
	aAdd(aData, {"ZPE_REVISA", cNextRevision})
	aAdd(aData, {"ZPE_CODUSR", cUserId})
	aAdd(aData, {"ZPE_DATA", Date()})
	aAdd(aData, {"ZPE_HORA", Left(Time(), 5)})
	aAdd(aData, {"ZPE_JSON", oQuotation:toJsonString()})
		
	oSql:insert("ZPE", aData)
	
	oSql:update("ZP5", "ZP5_REVATU = '"+cNextRevision+"'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+oQuotation:getId()+"'")
	
return

/**
 * Salva os Concorrentes do Orçamento
 */
static function saveCompetitors(cOperation, cId, oQuotation)
	
	local nI			:= 0
	local lClear		:= .T.
	local aData 		:= {}
	local aCompetitors	:= oQuotation:getCompetitors()
	local oSql			:= LibSqlObj():newLibSqlObj()
	
	if (cOperation == "update")
		oSql:delete("ZPG", "%ZPG.XFILIAL% AND ZPG_NUM = '"+cId+"'", lClear)
	endIf	
	
	for nI := 1 to Len(aCompetitors)
		
		aData := {}
		
		aAdd(aData, {"ZPG_FILIAL", xFilial("ZPG")})
		aAdd(aData, {"ZPG_NUM", cId})
		aAdd(aData, {"ZPG_CODCON", aCompetitors[nI]:getId()})
		
		oSql:insert("ZPG", aData)
		
	next nI
	
return


/*/{Protheus.doc} finishMaintenance

Finaliza a Manutenção de um Orçamento
	
@author victorhugo
@since 02/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a operação foi realizada
/*/
method finishMaintenance(cUserId, cQuotationId) class CbcQuotationService
	local oQuotation := nil
	local cStatus	 := "" 
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "finishMaintenance", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf

	if ::checkRules(@oQuotation)
		cStatus := QUOTATION_STATUS_WAITING_CONFIRM
	else
		if aScan(oQuotation:getRules(), { |x| x:getType() == QUOTATION_PACKAGING_RULES .AND.  !x:isOk() } )  > 0
			updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
			notifyTechnicians(cUserId, oQuotation)
			confirmReserves(oQuotation)
			unlockStatus(cQuotationId)
			return .T.
		endif
		if Empty(oQuotation:getIdApprover())
			cStatus	 := QUOTATION_STATUS_WAITING_APPROVAL
		else
			cStatus := QUOTATION_STATUS_APPROVINGLY
		endIf
	endIf
	oQuotation:setStatus(cStatus)
	
	begin transaction
	
		if (cStatus == QUOTATION_STATUS_WAITING_CONFIRM)
			updateValidDate(cQuotationId)
		endIf
		updateStatus(@self, cQuotationId, cStatus)
		createRevision(cUserId, oQuotation, QUOTATION_REVISION_UPDATE)
		confirmReserves(oQuotation)
		createNotifications(EVENT_FINISH_QUOTATION_MAINTENANCE, cUserId, oQuotation)
		if (cStatus	 != QUOTATION_STATUS_WAITING_CONFIRM)
			createNotifications(EVENT_SEND_QUOTATION_FOR_APPROVAL, cUserId, oQuotation)
		endIf
		
	end transaction
	
	unlockStatus(cQuotationId)	
return .T.

/**
 * Verifica se é necessário Confirmar alguma Reserva
 */
static function confirmReserves(oQuotation)
	
	local nI 	  := 0
	local cStatus := ""
	local cBranch := ""
	local cId	  := ""
	local aItems  := oQuotation:getItems()
	local oSql	  := LibSqlObj():newLibSqlObj()
	local oSrvRes := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	
	for nI := 1 to Len(aItems)
		
		cBranch := aItems[nI]:getBranchReserve()
		cId	    := aItems[nI]:getIdReserve()
		
		if Empty(cId)
			loop
		endIf
		
		cStatus := oSql:getFieldValue("ZP4", "ZP4_STATUS", "ZP4_FILIAL = '"+cBranch+"' AND ZP4_CODIGO = '"+cId+"'")
		
		if (cStatus == RESERVE_STATUS_WAITING)
			oSrvRes:setConfirmed(cBranch, cId)
		endIf
		
	next nI
	
return


/*/{Protheus.doc} takeApproval

Assume a Aprovação de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a operação foi realizada
/*/
method takeApproval(cUserId, cQuotationId) class CbcQuotationService
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "takeApproval", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf

	begin transaction

		oSql:update("ZP5", "ZP5_APROVA = '"+cUserId+"', ZP5_ULTSUG = 0, ZP5_ULTAPR = 0", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_APPROVINGLY)
		
		createNotifications(EVENT_ASSUME_QUOTATION_APPROVAL, cUserId, oQuotation)
		
	end transaction	
	
	unlockStatus(cQuotationId)

return .T.


/*/{Protheus.doc} giveUpApproval

Desiste de Aprovar um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a operação foi realizada
/*/
method giveUpApproval(cUserId, cQuotationId) class CbcQuotationService	
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "giveUpApproval", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf
	
	begin transaction
		
		oSql:update("ZP5", "ZP5_APROVA = ' ', ZP5_ALTERA = 'S'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		
		resetPricesApproval(cQuotationId)
		
		if aScan(oQuotation:getRules(), { |x| x:getType() == QUOTATION_PACKAGING_RULES } )  > 0
			if clearTecnicalApproval(oQuotation,cUserId)
				updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
				notifyTechnicians(cUserId, oQuotation)
			else
				updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_APPROVAL)
				oQuotation:setStatus(QUOTATION_STATUS_WAITING_APPROVAL)
			endIf
		else
			updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_APPROVAL)
			oQuotation:setStatus(QUOTATION_STATUS_WAITING_APPROVAL)
		endif

		createRevision(cUserId, oQuotation, QUOTATION_REVISION_GIVE_UP_APPROVAL)
		createNotifications(EVENT_GIVE_UP_QUOTATION_APPROVAL, cUserId, oQuotation)
		
	end transaction
	
	unlockStatus(cQuotationId)

return .T.


/*/{Protheus.doc} approve

Aprova um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento
@param dValidDate, Data, Data de Validade do Orçamento 
@param nFixedCommission, Numerico, Comissão Fixa

@return Logico Indica se a operação foi realizada
/*/
method approve(cUserId, cQuotationId) class CbcQuotationService
	
	local lOk			:= .F.
	local oQuotation 	:= nil
	local oSql 		 	:= LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "approve", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf
	
	begin transaction			 
		
		oSql:update("ZP6", "ZP6_PRCAPR = ZP6_PRCSUG, ZP6_TOTAPR = ZP6_TOTSUG, ZP6_DESAPR = ZP6_DESSUG, " + ;
		 				   "ZP6_RGAPR = ZP6_RGSUG, ZP6_DIFPRC = 0, ZP6_APAUTO = 'N'", ; 
					"%ZP6.XFILIAL% AND ZP6_NUM = '"+cQuotationId+"' AND ZP6_PRCAPR = 0")
		
		oSql:update("ZP6", "ZP6_COMAPR = ZP6_COMSUG", "%ZP6.XFILIAL% AND ZP6_NUM = '"+cQuotationId+"' AND ZP6_COMFIX != 'S'")
		
		oQuotation := ::getById(cQuotationId, cUserId)
		
		if !checkAppProfile(self, cUserId, oQuotation, @self:cErrorMessage)
			DisarmTransaction()
			break
		endIf			
		
		oSql:update("ZP5", "ZP5_ULTSUG = " + AllTrim(Str(oQuotation:getSugTotal())) + ", ZP5_ULTAPR = " + AllTrim(Str(oQuotation:getAppTotal())), ; 
					"%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")											
		
		updateValidDate(cQuotationId)
		
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_CONFIRM)
		
		oQuotation:setStatus(QUOTATION_STATUS_WAITING_CONFIRM)
		
		createRevision(cUserId, oQuotation, QUOTATION_REVISION_APPROVE)
		
		createNotifications(EVENT_QUOTATION_APPROVAL, cUserId, oQuotation)
		
		lOk := .T.
		
	end transaction
	
	unlockStatus(cQuotationId)

return lOk

/**
 * Atualiza a Data de Validade do Orçamento
 */
static function updateValidDate(cQuotationId)
	
	local oSql 		 := LibSqlObj():newLibSqlObj()
	local nDiaPar	 := GetNewPar("ZZ_VLORCPT", 7)
	local dValidDate := (Date() + nDiaPar )
	
	oSql:newTable("ZP5", "ZP5_CLIENT, ZP5_LOJA", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	
	if (oSql:getValue("ZP5_CLIENT") == DEFAULT_CUSTOMER_CODE .and. oSql:getValue("ZP5_LOJA") == DEFAULT_CUSTOMER_UNIT)
		nDiaPar	 := GetNewPar("ZZ_VLPADPT", 7)
	endIf
	
	oSql:close()
	
	while  u_DiffDay(Date(), dValidDate) != nDiaPar
	 	dValidDate := DaySum(dValidDate, 1)
	enddo
	
	oSql:update("ZP5", "ZP5_DTVAL = '"+DtoS(dValidDate)+"'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	
return


/*/{Protheus.doc} tecnicalReject
Rejeição tecnica de um Orçamento
@author leonardo.bolognesi
@since 13/08/2021
@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento
@return Logico Indica se a operação foi realizada
/*/
method tecnicalReject(cUserId, cQuotationId, cComments, cRejectReason) class CbcQuotationService
	
	local oQuotation 	:= nil
	local oSql 		 	:= LibSqlObj():newLibSqlObj()
	local oService		:= CbcMessageService():newCbcMessageService()
	local cText			:= ""
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	validAction(@self, "disapprove", cUserId, cQuotationId, @oQuotation)
	
	begin transaction		
		
		resetPricesApproval(cQuotationId)
		oSql:update("ZP5", "ZP5_ULTSUG = 0, ZP5_ULTAPR = 0", "%ZP5.XFILIAL% AND ZP5_NUM = '" + cQuotationId + "'")
		updateStatus(@self, cQuotationId,QUOTATION_STATUS_TECNICAL_REJECT)
		oQuotation:setStatus(QUOTATION_STATUS_TECNICAL_REJECT)
		createRevision(cUserId, oQuotation, QUOTATION_REVISION_TECNICAL_REJECT)
		createNotifications(EVENT_QUOTATION_REJECTION, cUserId, oQuotation)

		if !Empty(cRejectReason)
			cRejectReason   := oSql:getFieldValue("SX5", "X5_DESCRI", "%SX5.XFILIAL% AND X5_TABELA = '_4' AND X5_CHAVE = '"+cRejectReason+"'")
			cText := " Orçamento: " + cQuotationId + " foi rejeitado pela aprovação técnica! "
			cText += " Motivo: " + AllTrim(Capital(cRejectReason))
			if !Empty(cComments)
				cText += " Observações: " + AllTrim(cComments)
			endIf	
		endIf
		oService:create(cUserId, {oQuotation:getIdApprover(),oQuotation:getIdUser()}, {}, 'Rejeição Técnica' + 'Orçamento ' + cQuotationId , cText, cQuotationId)
		
	end transaction
	
	unlockStatus(cQuotationId)
	FreeObj(oService)
	FreeObj(oSql)
return .T.

/*/{Protheus.doc} disapprove

Rejeita a Aprovação de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a operação foi realizada
/*/
method disapprove(cUserId, cQuotationId) class CbcQuotationService
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "disapprove", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf
	
	begin transaction		
		
		resetPricesApproval(cQuotationId)
		
		oSql:update("ZP5", "ZP5_ULTSUG = 0, ZP5_ULTAPR = 0", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_NOT_APPROVED)
		
		oQuotation:setStatus(QUOTATION_STATUS_NOT_APPROVED)
		
		createRevision(cUserId, oQuotation, QUOTATION_REVISION_REJECTION)
		
		createNotifications(EVENT_QUOTATION_REJECTION, cUserId, oQuotation)
		
	end transaction
	
	unlockStatus(cQuotationId)

return .T.


/*/{Protheus.doc} undoApproval

Desfaz a Aprovação/Rejeição de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a operação foi realizada
/*/
method undoApproval(cUserId, cQuotationId) class CbcQuotationService	
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "undoApproval", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf
		
	begin transaction			
	
		resetPricesApproval(cQuotationId)
		
		oSql:update("ZP5", "ZP5_ULTSUG = 0, ZP5_ULTAPR = 0", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_APPROVINGLY)
		
		createNotifications(EVENT_UNDO_QUOTATION_APPROVAL, cUserId, oQuotation)
		
	end transaction	
	
	unlockStatus(cQuotationId)

return .T.

/**
 * Reinicia a aprovação dos preços
 */
static function resetPricesApproval(cQuotationId)
	
	local oSql := LibSqlObj():newLibSqlObj()
	
	oSql:update("ZP6", "ZP6_PRCAPR = 0, ZP6_TOTAPR = 0, ZP6_DESAPR = '', ZP6_COMAPR = 0, " + ;
		 			   "ZP6_RGAPR = 0, ZP6_DIFPRC = 0, ZP6_APAUTO = 'N', ZP6_COMFIX = 'N'", ;
					"%ZP6.XFILIAL% AND ZP6_NUM = '"+cQuotationId+"'")
		
	oSql:update("ZP6", "ZP6_PRCAPR = ZP6_PRCSUG, ZP6_TOTAPR = ZP6_TOTSUG, ZP6_DESAPR = ZP6_DESSUG, " + ; 
					   "ZP6_COMAPR = ZP6_COMSUG, ZP6_RGAPR = ZP6_RGSUG, ZP6_DIFPRC = 0, ZP6_APAUTO = 'S'", ;
				"%ZP6.XFILIAL% AND ZP6_NUM = '"+cQuotationId+"' AND ZP6_PRCSUG >= ZP6_PRCMIN")
	
return


/*/{Protheus.doc} cancel

Cancela um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento
@param cReason, String, Motivo do Cancelamento
@param cComments, String, Observações sobre o Cancelamento

@return Logico Indica se a operação foi realizada
/*/
method cancel(cUserId, cQuotationId, cReason, cComments) class CbcQuotationService
	
	local oQuotation  := nil
	local oSql		  := LibSqlObj():newLibSqlObj()
	default cComments := ""
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "cancel", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf	
		
	begin transaction	
		
		oSql:update("ZP5", "ZP5_MOTCAN = '"+cReason+"', ZP5_OBSCAN = '"+cComments+"'", ; 
					"%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_CANCELED)					
		
		undoReservesConfirm("cancel", oQuotation)
		
		createNotifications(EVENT_QUOTATION_CANCEL, cUserId, oQuotation)
		
	end transaction
	
	unlockStatus(cQuotationId)
	
return .T.


/*/{Protheus.doc} delete

Exclui um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se o Orçamento foi excluido
/*/
method delete(cUserId, cQuotationId) class CbcQuotationService
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "delete", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf
	
	begin transaction
		
		undoReservesConfirm("delete", oQuotation)
		
		createNotifications(EVENT_QUOTATION_DELETE, cUserId, oQuotation)
		
		oSql:delete("ZP3", "%ZP3.XFILIAL% AND ZP3_NUMORC = '"+cQuotationId+"'")
		oSql:delete("ZP5", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		oSql:delete("ZP6", "%ZP6.XFILIAL% AND ZP6_NUM = '"+cQuotationId+"'")	
		oSql:delete("ZP9", "%ZP9.XFILIAL% AND ZP9_NUM = '"+cQuotationId+"'")
		oSql:delete("ZPA", "%ZPA.XFILIAL% AND ZPA_NUM = '"+cQuotationId+"'")
		oSql:delete("ZPE", "%ZPE.XFILIAL% AND ZPE_NUM = '"+cQuotationId+"'")
		oSql:delete("ZPG", "%ZPG.XFILIAL% AND ZPG_NUM = '"+cQuotationId+"'")			  
		
	end transaction
	
	unlockStatus(cQuotationId)
	
return .T.


/*/{Protheus.doc} lockUpdate

Bloqueia a Alteração de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a alteração foi bloqueada
/*/
method lockUpdate(cUserId, cQuotationId) class CbcQuotationService
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "lockUpdate", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf
	
	begin transaction	
		
		oSql:update("ZP5", "ZP5_ALTERA = 'N'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		
		createNotifications(EVENT_LOCK_QUOTATION_UPDATE, cUserId, oQuotation)
		
	end transaction
	
	unlockStatus(cQuotationId)
			
return .T.


/*/{Protheus.doc} unlockUpdate

Desbloqueia a Alteração de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a alteração foi desbloqueada
/*/
method unlockUpdate(cUserId, cQuotationId) class CbcQuotationService
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "unlockUpdate", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf		
		
	begin transaction	
		
		oSql:update("ZP5", "ZP5_ALTERA = 'S'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		
		createNotifications(EVENT_UNLOCK_QUOTATION_UPDATE, cUserId, oQuotation)
		
	end transaction	
	
	unlockStatus(cQuotationId)
			
return .T.


/*/{Protheus.doc} requestTecnicalApproval

Requisição de Aprovação Técnica de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param cQuotationId, String, ID do Orçamento

@return Logico Indica se a operação foi realizada
/*/
method requestTecnicalApproval(cUserId, cQuotationId) class CbcQuotationService
	
	local oQuotation := nil
	local oSql 		 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if !validAction(@self, "requestTecnicalApproval", cUserId, cQuotationId, @oQuotation)
		return .F.
	endIf		
		
	updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
	
	notifyTechnicians(cUserId, oQuotation)
	
	unlockStatus(cQuotationId)
				
return .T.

/**
 * Envia e-mail de Notificação para os Técnicos sobre o Orçamento aguardando aprovação
 */
static function notifyTechnicians(cUserId, oQuotation)
	
	local cHtmlText	 	:= ""	
	local cTo	   		:= GetNewPar("ZZ_EMAPRTE", "victor.hugo@b2finance.com")
	local cSubject		:= "Portal Cobrecom - Orçamento " + oQuotation:getId() + " aguardando Aprovação Técnica"
	local oMail 		:= LibMailObj():newLibMailObj()	
	
	if !oMail:setHtmlLayout(GENERIC_NOTIFICATION_EMAIL_HTML)
		ConOut("Layout HTML não encontrado: " + GENERIC_NOTIFICATION_EMAIL_HTML)
		return
	endIf
	
	cHtmlText := "<p><b>" + oQuotation:getNameApprover() + "</b> está solicitando Aprovação Técnica "
	cHtmlText += "para o Orçamento  <b>" + oQuotation:getId() + "</b>."
	cHtmlText += "<p>Seguem maiores informações sobre o Orçamento:</p>"	
	cHtmlText += "<ul>"
	cHtmlText += "	<li><b>Número: </b> " + oQuotation:getId() + "</li>"
	cHtmlText += "	<li><b>Data: </b> " + DtoC(oQuotation:getDate()) + "</li>"
	cHtmlText += "	<li><b>Responsável: </b> " + oQuotation:getNameUser()+ "</li>"
	cHtmlText += "	<li><b>Cliente: </b> " + oQuotation:getNameCustomer() + "</li>"
	cHtmlText += "</ul>"
	
	oMail:setHtmlValue("text", cHtmlText)
	
	if !oMail:send(cTo, cSubject)
		ConOut("Falha ao enviar e-mail de Notificação sobre Aprovação Técnica: " + oMail:getError())
	endIf
	
return


/*/{Protheus.doc} tecnicalApproval

Aprovação Técnica de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cErpUser, String, ID do Técnico
@param cQuotationId, String, ID do Orçamento
@param lApproved, Logico, Indica se o Técnico Aprovou o Orçamento
@param cComments, String, Observações
@param cReason, String, Motivo em caso de Rejeição

@return Logico Indica se a operação foi realizada
/*/
method tecnicalApproval(cErpUser, cQuotationId, lApproved, cComments, cRejectReason) class CbcQuotationService
	
	local lOk 	 	  		:= .F.
	local oQuotation  		:= nil
	local oSql		  		:= LibSqlObj():newLibSqlObj()
	local oUtils	  		:= LibUtilsObj():newLibUtilsObj()
	local cEvent			:= if (lApproved, EVENT_QUOTATION_TEC_APPROVAL, EVENT_QUOTATION_TEC_REJECTION)
	local cUserId			:= ""
	default cComments 		:= ""
	default cRejectReason	:= ""
	
	::cErrorMessage := ""
	
	begin sequence
		
		if !::isTecnicalApprover(cErpUser)
			::cErrorMessage := "O usuário informado não está cadastrado como Aprovador Técnico"
			break
		endIf
		
		oQuotation := ::getById(cQuotationId)
		
		if oUtils:isNull(oQuotation)
			::cErrorMessage := "Orçamento não encontrado"
			break
		endIf
		
		if (oQuotation:getStatus() != QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
			::cErrorMessage := "O orçamento não está aguardando Aprovação Técnica"
			break
		endIf
		
		lOk := .T.
		
	end sequence		
	
	if !lOk
		return .F.
	endIf
	
	begin transaction
				
		oSql:update("ZP5", "ZP5_STAPTE = '"+if(lApproved, "1", "2")+"', ZP5_USAPTE = '"+cErpUser+"', " + ;
					"ZP5_DTAPTE = '"+DtoS(Date())+"', ZP5_HRAPTE = '"+Left(Time(), 5)+"', " + ;
					"ZP5_OBAPTE = '"+Alltrim(cComments)+"', ZP5_MOTAPT = '"+cRejectReason+"'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
					
		createNotifications(cEvent, nil, oQuotation, cErpUser)			
		
		oSql:newTable("ZP1", "ZP1_CODIGO", "%ZP1.XFILIAL% AND ZP1_CODERP = '"+ cErpUser +"'") 
		cUserId := iif(oSql:hasRecords(), oSql:getValue("ZP1_CODIGO"), GetNewPar('ZX_DEFAPRO', '000363'))
		oSql:close() 
		FreeObj(oSql)		
	
		if lApproved
			if !::checkRules(@oQuotation)
				if Empty(oQuotation:getIdApprover())
					updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_APPROVAL)
				else
					updateStatus(@self, cQuotationId, QUOTATION_STATUS_APPROVINGLY)
				endif
			else
				updateValidDate(cQuotationId)
				updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_CONFIRM)  
			endIf
			createRevision(cUserId, oQuotation, QUOTATION_REVISION_TECNICAL_APPROVAL)
		else
			::tecnicalReject(cUserId, cQuotationId, cComments, cRejectReason)
		endif

	end transaction	
				
return lOk


/*/{Protheus.doc} confirm

Confirmação de um Orçamento
	
@author victorhugo
@since 01/06/2016

@param cUserId, String, ID do Usuário
@param xQuotation, String ou Objeto, ID ou Instancia do Orçamento
@param oSalesOrderData, CbcSalesOrderData, Dados para Geração do Pedido

@return String Número do Pedido de Vendas gerado
/*/
method confirm(cUserId, xQuotation, oSalesOrderData) class CbcQuotationService
	
	local oQuotation 	 := nil
	local cQuotationId	 := ""
	local oSql 		 	 := LibSqlObj():newLibSqlObj()
	
	if !lockStatus(@self, cQuotationId, cUserId)
		return .F.
	endIf
	
	if (Type(xQuotation) == "O")
		oQuotation := xQuotation
	else
		cQuotationId := xQuotation
	endIf
	
	if !validAction(@self, "confirm", cUserId, cQuotationId, @oQuotation, oSalesOrderData)
		return .F.
	endIf	
		
	begin transaction	
		
		updateSalesOrderData(cQuotationId, oSalesOrderData, oQuotation)
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_WAITING_PROCESSING)				
		
	end transaction	
	
	unlockStatus(cQuotationId)
			
return .T.

/**
 * Atualiza os Dados adicionais do Orçamento informados no momento da Confirmação
 */
static function updateSalesOrderData(cQuotationId, oSalesOrderData, oQuotation)
	
	local oSql 				  := LibSqlObj():newLibSqlObj()
	local cUpdate			  := ""
	local cDeliveryType		  := oSalesOrderData:getDeliveryType()
	local dBillingDate  	  := oSalesOrderData:getBillingDate()
	local dStandardDelivery	  := oQuotation:getStandardDelivery()
	
	if Empty(dBillingDate)
		dBillingDate := CtoD("")
	endIf
	
	cUpdate := " ZP5_ENTPAD = '"+DtoS(dStandardDelivery)+"', ZP5_TPENT = '"+cDeliveryType+"', ZP5_DTFAT = '"+DtoS(dBillingDate)+"' "
	
	oSql:update("ZP5", cUpdate, "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")	
	
return

/**
 * Valida as ações relacionadas a um Orçamento
 */
static function validAction(oSelf, cAction, cUserId, cQuotationId, oQuotation, oSalesOrderData, lItemsChanged)
	
	local lOk 	  	  		:= .F.
	local lIsOwner	  		:= .F.
	local lIsApprover 		:= .F.	
	local lCheckMinValues 	:= .T.
	local lCheckOnlySugTotal:= .F.
	local nMaxBillDays		:= 0
	local dMaxBillDate		:= nil
	local cError  	  		:= ""
	local cStatus	  		:= ""
	local oUtils	  		:= LibUtilsObj():newLibUtilsObj()
	local oCbcManager 		:= CbcBudgetManager():newCbcBudgetManager()
	local oSrvUser			:= CbcUserService():newCbcUserService()
	local oUser	 			:= oSrvUser:findById(cUserId)		
	
	begin sequence		
		
		if oUtils:isNull(oUser)
			cError := "Usuário inválido"
			break
		endIf
		
		if (ValType(oQuotation) == "U")
			oQuotation := oSelf:getById(cQuotationId, cUserId)
		endIf		
		
		if oUtils:isNull(oQuotation)
			cError := "Orçamento não encontrado"
			break
		endIf
		
		cStatus		:= oQuotation:getStatus()						
		lIsOwner    := (cUserId == oQuotation:getIdUser())
		lIsApprover := (cUserId == oQuotation:getIdApprover())				
		
		if (cAction == "activate_canceled")
			
			if !(lIsOwner .or. lIsApprover)
				cError := "O usuário não pode alterar esse Orçamento"
				break
			endIf
			
			if (lIsOwner .and. !cStatus $ QUOTATION_STATUS_UNDER_MAINTENANCE+","+QUOTATION_STATUS_WAITING_APPROVAL+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_WAITING_PROCESSING+","+QUOTATION_STATUS_ERROR_PROCESSING+","+QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_TECNICAL_REJECT+","+QUOTATION_STATUS_CANCELED .or. ;										  
			   (lIsApprover .and. !lIsOwner .and. !cStatus $ QUOTATION_STATUS_APPROVINGLY+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_ERROR_PROCESSING+","+QUOTATION_STATUS_TECNICAL_REJECT))
			   
			   if !(lIsApprover .and. lIsOwner .and. cStatus == QUOTATION_STATUS_APPROVINGLY)			   
			   		cError := "Esse Orçamento não pode ser alterado porque está " + Lower(oSelf:getDescStatus(cStatus))
			   		break
			   	endIf
			   				
			endIf
			
			if lIsOwner .and. !lIsApprover .and. !oQuotation:canEdit() .and. lItemsChanged
				cError := "O Orçamento está bloqueado para alterações que demandam nova aprovação"
				break
			endIf
									
		endIf
		
		if (cAction == "update")
			
			if !(lIsOwner .or. lIsApprover)
				cError := "O usuário não pode alterar esse Orçamento"
				break
			endIf
			
			if (lIsOwner .and. !cStatus $ QUOTATION_STATUS_UNDER_MAINTENANCE+","+QUOTATION_STATUS_WAITING_APPROVAL+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_WAITING_PROCESSING+","+QUOTATION_STATUS_ERROR_PROCESSING+","+QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_TECNICAL_REJECT .or. ;										  
			   (lIsApprover .and. !lIsOwner .and. !cStatus $ QUOTATION_STATUS_APPROVINGLY+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_ERROR_PROCESSING+","+QUOTATION_STATUS_TECNICAL_REJECT))
			   
			   if !(lIsApprover .and. lIsOwner .and. cStatus == QUOTATION_STATUS_APPROVINGLY)			   
			   		cError := "Esse Orçamento não pode ser alterado porque está " + Lower(oSelf:getDescStatus(cStatus))
			   		break
			   	endIf
			   				
			endIf
			
			if lIsOwner .and. !lIsApprover .and. !oQuotation:canEdit() .and. lItemsChanged
				cError := "O Orçamento está bloqueado para alterações que demandam nova aprovação"
				break
			endIf
									
		endIf
		
		if (cAction $ "delete,finishMaintenance")
			
			if !lIsOwner
				cError := "O usuário não é o responsável pelo Orçamento"
				break
			endIf
			
			if (cStatus != QUOTATION_STATUS_UNDER_MAINTENANCE)
				cError := "O orçamento não está em manutenção"
				break
			endIf
			
		endIf
		
		if (cAction == "finishMaintenance")
		
			if !oCbcManager:vldQuotation(cQuotationId, @cError)
				break
			endIf
		
		endIf
		
		if (cAction $ "finishMaintenance,confirm")
			
			if !checkReserves(oQuotation, @cError)
				break
			endIf
			
		endIf								
		
		if (cAction == "cancel")
			
			if (cStatus == QUOTATION_STATUS_UNDER_MAINTENANCE)
				cError := "O orçamento está em manutenção. Em vez de cancelado ele deve ser excluído."
				break
			endIf
			
			if (cStatus == QUOTATION_STATUS_CANCELED)
				cError := "O orçamento já está cancelado"
				break
			endIf
			
			if !(cStatus == QUOTATION_STATUS_APPROVINGLY .and. lIsApprover) .and. (!cStatus $ QUOTATION_STATUS_WAITING_APPROVAL+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_TECNICAL_REJECT+","+QUOTATION_STATUS_WAITING_PROCESSING+","+QUOTATION_STATUS_ERROR_PROCESSING)
				cError := "Esse orçamento não pode ser cancelado porque está " + Lower(oSelf:getDescStatus(cStatus))
				break
			endIf			
			
		endIf
		
		if (cAction == "takeApproval")
		
			lCheckMinValues 	:= .T.
			lCheckOnlySugTotal	:= .T.
			
			if !oSelf:canTakeApproval(oUser, oQuotation, @cError, lCheckMinValues, lCheckOnlySugTotal)
				break
			endIf
				
		endIf
		
		if (cAction == "requestTecnicalApproval")
			
			if !oSelf:canRequestTecnicalApproval(oUser, oQuotation, @cError)
				break
			endIf
			
		endIf
		
		if (cAction == "giveUpApproval") 
		
			if (!cStatus $ QUOTATION_STATUS_APPROVINGLY+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
				cError := "O orçamento não está em aprovação ou aguardando confirmação"
				break
			endIf
			
			if !lIsApprover 
				cError := "O usuário informado não é o aprovador do orçamento"
				break
			endIf	
				
		endIf
		
		if (cAction == "approve")
			
			if !lIsApprover 
				cError := "O usuário informado não é o aprovador do orçamento"
				break
			endIf
			
			if !(cStatus $ QUOTATION_STATUS_APPROVINGLY+","+QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL+","+QUOTATION_STATUS_TECNICAL_REJECT)
				cError := "O orçamento não está em aprovação"
				break
			endIf
			
		endIf
		
		if (cAction == "disapprove")
			
			if !lIsApprover 
				cError := "O usuário informado não é o aprovador do orçamento"
				break
			endIf
			
			if (!cStatus $ QUOTATION_STATUS_APPROVINGLY+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
				cError := "O orçamento não está em aprovação ou aguardando confirmação"
				break
			endIf
			
		endIf
		
		if (cAction == "undoApproval")
			
			if !lIsApprover 
				cError := "O usuário informado não é o aprovador do orçamento"
				break
			endIf
			
			if (!cStatus $ QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_TECNICAL_REJECT)
				cError := "O orçamento não foi aprovado ou rejeitado"
				break
			endIf
			
		endIf
		
		if (cAction $ "lockUpdate,unlockUpdate") 
			
			if !lIsApprover 
				cError := "O usuário informado não é o aprovador do orçamento"
				break
			endIf
			
			if !(cStatus $ QUOTATION_STATUS_APPROVINGLY+","+QUOTATION_STATUS_WAITING_CONFIRM+","+QUOTATION_STATUS_NOT_APPROVED+","+QUOTATION_STATUS_TECNICAL_REJECT+","+QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
				cError := "O orçamento não está em aprovação"
				break
			endIf
			
		endIf
		
		if (cAction == "confirm") 
			
			if (cStatus != QUOTATION_STATUS_WAITING_CONFIRM)
				cError := "O orçamento não está em aguardando confirmação"
				break
			endIf
			
			if (!Empty(oQuotation:getValidDate()) .and. oQuotation:getValidDate() < Date())
				cError := "O prazo de validade desse Orçamento expirou"
				break
			endIf
			
			if (Empty(oQuotation:getDeliveryType()))
				cError := "Tipo de Entrega não definido"
				break
			endIf
			
			if (oSalesOrderData:getDeliveryType() == "1")
			
				if (Empty(oSalesOrderData:getBillingDate()) .or. oSalesOrderData:getBillingDate() != Date())
					cError := "Para entrega imediata a Data de Faturamento deve ser igual a Data Atual"
					break
				endIf
			
			elseIf (oSalesOrderData:getDeliveryType() == "2")
			
				if (Empty(oSalesOrderData:getBillingDate()) .or. oSalesOrderData:getBillingDate() < oQuotation:getStandardDate())
					cError := "Para entrega programada a Data de Faturamento deve ser maior ou igual a Data de Entrega Padrão"
					break
				endIf
				
				nMaxBillDays := GetNewPar("ZZ_DIASFAT", 0)
				
				if (nMaxBillDays > 0)
					dMaxBillDate := (oQuotation:getStandardDate() + nMaxBillDays)
				endIf
				
				if !Empty(dMaxBillDate) .and. (oSalesOrderData:getBillingDate() > dMaxBillDate)
					cError := "Para entrega programada a Data de Faturamento desse orçamento não pode ser maior que " + DtoC(dMaxBillDate)
					break
				endIf
			
			else
			
				cError := "Tipo de Entrega inválido"
				break
				
			endIf
				
		endIf

		
		lOk := .T.
		
	end sequence
	
	if !Empty(cError)
		oSelf:cErrorMessage := cError
	endIf
	
	if !lOk
		unlockStatus(cQuotationId)
	endIf
	
return lOk

/**
 * Reserva a alteração de Status para um Usuário
 */
static function lockStatus(oSelf, cQuotationId, cUserId)
	
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local cLockedUserId := lockedUserId(cQuotationId)
	
	if !Empty(cLockedUserId) .and. (cLockedUserId != cUserId)
		oSelf:cErrorMessage := "O status desse Orçamento está sendo alterado por outro usuário"
		return .F.
	endIf
	
	oSql:update("ZP5", "ZP5_LOCKED = '" + cUserId + "'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	
return .T.

/**
 * Libera a alteração de Status
 */
static function unlockStatus(cQuotationId)
	
	local oSql 	:= LibSqlObj():newLibSqlObj()
	
	oSql:update("ZP5", "ZP5_LOCKED = ' '", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	
return

/**
 * Retorna o ID do Usuário que está com o Orçamento reservado para troca de status
 */
static function lockedUserId(cQuotationId)
	
	local oSql 	:= LibSqlObj():newLibSqlObj()
	
return oSql:getFieldValue("ZP5", "ZP5_LOCKED", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")

/**
 * Atualiza o Status de um Orçamento
 */
static function updateStatus(oSelf, cQuotationId, cStatus)
	
	local lOk  	:= .F.
	local oSql 	:= LibSqlObj():newLibSqlObj()
	
	if oSql:update("ZP5", "ZP5_STATUS = '"+cStatus+"'", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
		if cStatus == '5' .or. cStatus == '6' // 5 = cONFIRMADO // 6 = NAO APROVADO
			startjob("u_mlLiberInfo",getenvserver(),.F.,{'01',FwFilial(),cQuotationId})
		endif
		lOk := .T.
	else
		oSelf:cErrorMessage := "Falha interna ao atualizar o status do Orçamento "+cQuotationId
	endIf
	
return lOk


/*/{Protheus.doc} addDocument

Adiciona documentos a um Orçamento
	
@author victorhugo
@since 02/06/2016

@param oDocument, CbcQuotationDocument, Documento gerado

@return Logico Indica se o registro foi gravado
/*/
method addDocument(cQuotationId, oDocument) class CbcQuotationService
	
	local cUserId	 := ""
	local cInvoice	 := ""
	local aData 	 := {}
	local oQuotation := nil
	local oSql 	 	 := LibSqlObj():newLibSqlObj()
	
	if !validAddDocument(@self, cQuotationId, oDocument, @oQuotation)
		return .F.
	endIf
	
	aAdd(aData, {"ZPA_NUM", cQuotationId})
	aAdd(aData, {"ZPA_TIPO", oDocument:getType()})
	aAdd(aData, {"ZPA_CODFIL", oDocument:getBranchId()})
	aAdd(aData, {"ZPA_NUMDOC", oDocument:getId()})
	aAdd(aData, {"ZPA_SERIE", oDocument:getSeries()})
	aAdd(aData, {"ZPA_DATA", if (Empty(oDocument:getDate()), Date(), oDocument:getDate())})
	aAdd(aData, {"ZPA_HORA", if (Empty(oDocument:getTime()), Left(Time(), 5), oDocument:getTime())})
	aAdd(aData, {"ZPA_OBS", oDocument:getComments()})
	
	begin transaction
	
		oSql:insert("ZPA", aData)
			
		if (oDocument:getType() == QUOTATION_DOC_INVOICE)			
			cInvoice := AllTrim(oDocument:getId())			
			if !Empty(oDocument:getSeries())
				cInvoice += "-" + oDocument:getSeries()
			endIf			
			createNotifications(EVENT_CREATE_QUOTATION_INVOICE, cUserId, oQuotation, __cUserId, cInvoice)		
		endIf
	
	end transaction

return .T.

/**
 * Validação da criação de Documentos para um Orçamento
 */
static function validAddDocument(oSelf, cQuotationId, oDocument, oQuotation)
	
	local lOk        := .F.
	local oUtils	 := LibUtilsObj():newLibUtilsObj()
	
	oQuotation := oSelf:getById(cQuotationId)
	
	begin sequence
		
		if oUtils:isNull(oQuotation)
			oSelf:cErrorMessage := "Orçamento não encontrado"
			break
		endIf
		
		if Empty(oDocument:getBranchId())
			oSelf:cErrorMessage := "Filial do Documento não informada"
			break
		endIf
		
		if Empty(oDocument:getType())
			oSelf:cErrorMessage := "Tipo do Documento não informado"
			break
		endIf
		
		if !(oDocument:getType() $ QUOTATION_DOC_SALES_ORDER + "," + QUOTATION_DOC_INVOICE)
			oSelf:cErrorMessage := "Tipo do Documento inválido"
			break
		endIf
		
		if Empty(oDocument:getId())
			oSelf:cErrorMessage := "Número do Documento não informado"
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
return lOk


/*/{Protheus.doc} setDocumentDeleted

Define um documento de um Orçamento com excluido
	
@author victorhugo
@since 02/06/2016
/*/
method setDocumentDeleted(cQuotationId, cType, cBranchId, cDocumentId, cSeries, cComments) class CbcQuotationService
	
	local cUpdate := ""
	local cWhere  := ""
	local oSql    := LibSqlObj():newLibSqlObj()
	
	cWhere := " ZPA_NUM = '"+cQuotationId+"' AND ZPA_TIPO = '"+cType+"' AND ZPA_CODFIL = '"+cBranchId+"' AND "
	cWhere += " ZPA_NUMDOC = '"+cDocumentId+"' AND ZPA_EXCL != 'S' "
	
	if (cType == QUOTATION_DOC_INVOICE) .and. !Empty(cSeries)
		cWhere += " AND ZPA_SERIE = '"+cSeries+"' "
	endIf	
	
	if !oSql:exists("ZPA", cWhere)
		::cErrorMessage := "Documento não encontrado"
		return .F.
	endIf
	
	cUpdate := " ZPA_EXCL = 'S' "
	
	if !Empty(cComments)
		cUpdate += ", ZPA_OBS = '"+cComments+"'"
	endIf
	
	oSql:update("ZPA", cUpdate, cWhere)
	
return .T.

 
/*/{Protheus.doc} getItemDescription

Coleta a Descrição de um Item de Orçamento
	
@author victorhugo
@since 06/06/2016

@param oItem, CbcQuotationItem, Item de Orçamento

@return String Descrição do Item
/*/
method getItemDescription(oItem) class CbcQuotationService
	
	local cDescription := ""
	local cName		   := ""
	local cBitola	   := ""
	local cUM		   := "MT"
	local cCodeName	   := oItem:getCodeName()
	local cCodeBitola  := oItem:getCodeBitola()
	local cPackage   := oItem:getPackage()
	local nAmount	   := oItem:getAmountPackage()
	local oSql		   := LibSqlObj():newLibSqlObj()
	
	if Empty(cCodeName) .or. Empty(cCodeBitola) .or. Empty(cPackage) .or. Empty(nAmount)
		return ""
	endIf
	
	cName   	 := oSql:getFieldValue("SZ1", "Z1_DESC", "%SZ1.XFILIAL% AND Z1_COD = '"+cCodeName+"'")
	cBitola 	 := oSql:getFieldValue("SZ2", "Z2_DESC", "%SZ2.XFILIAL% AND Z2_COD = '"+cCodeBitola+"'")
	cDescription := Upper(AllTrim(cName))+" "+Upper(AllTrim(cBitola))+" "+Upper(AllTrim(cPackage))+" "+AllTrim(Str(nAmount))+" "+cUM

return cDescription


/*/{Protheus.doc} checkRules

Verifica e Define as Regras de Negócios de um Orçamento
	
@author victorhugo
@since 26/07/2016

@param oQuotation, CbcQuotation, Orçamento Cobrecom

@return Logico Indica se todas as Regras estão Ok
/*/
method checkRules(oQuotation) class CbcQuotationService
	
	local lOk	 := .T.
	local nI	 := 0
	local aRules := {}
	
	oQuotation:setRules({})
	
	checkPackagingRules(@oQuotation)
	checkColorsRules(@oQuotation)
	checkPricesRules(@oQuotation)
	checkMinimumValueRules(@oQuotation)
	checkOtherRules(@oQuotation)
	
	aRules := oQuotation:getRules()
	
	for nI := 1 to Len(aRules)
		if !aRules[nI]:isOk()
			lOk := .F.
			exit
		endIf
	next nI
	
return lOk

/**
 * Verifica as Regras relacionadas ao Acondicionamento dos Produtos
 */
static function checkPackagingRules(oQuotation)
		
	local oRule  	 	:= CbcQuotationRule():newCbcQuotationRule()
	local oSql   	 	:= LibSqlObj():newLibSqlObj()
	local lOk			:= .T.	
	local dDate	  		:= CtoD("")
	local cStatus		:= ""
	local cIdUser 		:= ""
	local cTime	  		:= ""
	local cReason 		:= ""	
	local cApComments	:= ""
	local cComments		:= ""
	local aItems		:= oQuotation:getItems()	
	local nI			:= 0
	
	if !checkColorsRules(oQuotation)
		lOk 	  := .F.
		cComments := "Uma ou mais cores precisam de aprovação"
	endIf
	
	oSql:newTable("ZP5", "ZP5_STAPTE [STATUS], ZP5_USAPTE [ID_USER], ZP5_DTAPTE [DATE], ZP5_HRAPTE [TIME], "+;
				  "ZP5_MOTAPT [REASON], ZP5_OBAPTE [COMMENTS]", "%ZP5.XFILIAL% AND ZP5_NUM = '"+oQuotation:getId()+"'")
	
	oSql:setField("DATE", "D")
	
	cStatus     := oSql:getValue("STATUS")
	cIdUser     := oSql:getValue("ID_USER")
	dDate	    := oSql:getValue("DATE")
	cTime	    := oSql:getValue("TIME")
	cReason	    := oSql:getValue("REASON")
	cApComments := oSql:getValue("COMMENTS")
	
	for nI := 1 to Len(aItems)		
		if hasAppPackaging(aItems[nI])
			lOk := .F.		
			cComments += "Um ou mais itens violam as Regras de Acondicionamento"
			exit
		endIf
				
	next nI
	oSql:close()
	
	if !Empty(cStatus)
		lOk		  := (cStatus == "1")
		/*
		cComments += if(lOk, "  Aprovado", "  Rejeitado")
		cComments += " por [" + getErpUserName(cIdUser) + "] "
		cComments += " em "+DtoC(dDate)+" às "+cTime
		if !lOk .and. !Empty(cReason)
			cReason   := oSql:getFieldValue("SX5", "X5_DESCRI", "%SX5.XFILIAL% AND X5_TABELA = '_4' AND X5_CHAVE = '"+cReason+"'")
			cComments += " Motivo:  [" + AllTrim(Capital(cReason)) + "]"
			if !Empty(cApComments)
				cComments += " Observações:  [" + AllTrim(cApComments) + ']'
			endIf	
		endIf
		*/
	endIf
	
	if lOk
		cComments := "Nenhum item viola as Regras de Acondicionamento"
	endIf
	
	oRule:setType(QUOTATION_PACKAGING_RULES)
	oRule:setDescription("Acondicionamentos/Cores")
	oRule:setOk(lOk)
	oRule:setComments(cComments)
	
	aAdd(oQuotation:aRules, oRule)
	
return

/**
 * Retorna o Nome de um Usuário do Protheus
 */
static function getErpUserName(cIdUser)
	
	local nI     := 0
	local cName	 := ""
	local aIds	 := {cIdUser}
	local aUsers := FwSfAllUsers(aIds)
	
	if (Len(aUsers) > 0)
		cName := AllTrim(Capital(aUsers[1,4]))
	endIf
	
return cName

/**
 * Verifica as Regras relacionadas as Cores dos Produtos
 */
static function checkColorsRules(oQuotation)
	
	local nI	 := 0
	local lOk	 := .T.
	local aItems := oQuotation:getItems()
	
	for nI := 1 to Len(aItems)		
		if (hasAppColors(aItems[nI]))
			lOk := .F.
			exit
		endIf		
	next nI
	
return lOk

/**
 * Verifica se um item possui alguma cor que precisa de aprovação
 */
static function hasAppColors(oItem)
	
	local nI	  		:= 0
	local hasAppColors	:= .F.
	local aColors 		:= oItem:getColors()
	
	for nI := 1 to Len(aColors)		
		if (aColors[nI]:requireApproval())
			hasAppColors := .T.
		endIf		
	next nI
	
return hasAppColors

/**
 * Verifica se um item possui viola alguma regra de acondicionamento
 */
static function hasAppPackaging(oItem)
	
return (oItem:isSpecificPackageAmount() .or. oItem:getSpecialty() != "01")

/**
 * Verifica as Regras relacionadas ao Preços dos Produtos
 */
static function checkPricesRules(oQuotation)
	
	local nI	 	:= 0
	local lOk	 	:= .T.
	local oItem  	:= nil
	local oRule  	:= CbcQuotationRule():newCbcQuotationRule()
	local aItems 	:= oQuotation:getItems()
	
	for nI := 1 to Len(aItems)
		
		oItem := aItems[nI]
		
		if (oItem:getSugPrice() < oItem:getMinPrice() .or. oItem:getAppPrice() < oItem:getMinPrice())
			lOk := .F.
			exit
		endIf		
		
	next nI
	
	oRule:setOk(lOk) 
	oRule:setType(QUOTATION_PRICES_RULES)
	oRule:setDescription("Preços")	
	
	if lOk
		oRule:setComments("Nenhum Preço abaixo do Preço Mínimo")
	else
		oRule:setComments("Um ou mais itens possuem Preço abaixo do Preço Mínimo")
	endIf 				
	
	aAdd(oQuotation:aRules, oRule)
	
return

/**
 * Verifica as Regras relacionadas ao Valores Mínimos
 */
static function checkMinimumValueRules(oQuotation)
	
	local lOk		:= .F.
	local cComments := ""
	local oRule 	:= CbcQuotationRule():newCbcQuotationRule()
	
	begin sequence
		
		if !checkBndesRules(oQuotation, @cComments)
			break
		endIf
		
		if !checkFreightRules(oQuotation, @cComments)
			break
		endIf
		
		if !checkPaymentRules(oQuotation, @cComments)
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
	if lOk
		cComments := "O Valor Total Sugerido e a Condição de Pagamento estão de acordo com a Política Comercial"
	endIf
	
	oRule:setType(QUOTATION_MINIMUM_VALUES_RULES)
	oRule:setDescription("Valor Mínimo / Cond. Pagamento")
	oRule:setOk(lOk)
	oRule:setComments(cComments)
	
	aAdd(oQuotation:aRules, oRule)
	
return

/**
 * Verifica as Regras de Valor Mínimo relacionadas ao BNDES
 */
static function checkBndesRules(oQuotation, cComments)
	
	local lOk 		 	:= .T.
	local nSugTotal	 	:= 0
	local nMinVlBndes	:= 0
	local cPayCond	 	:= oQuotation:getPaymentCondition()
	local cBndesCond 	:= GetMv("ZZ_BNDECON")
	local lIsBndes	 	:= (AllTrim(cPayCond) == AllTrim(cBndesCond)) 
	
	if !lIsBndes
		return .T.
	endIf
	
	nSugTotal   := getSugTotal(oQuotation)
	nMinVlBndes := GetMv("ZZ_BNDEVLR")
	
	if (nSugTotal < nMinVlBndes)
		lOk 		:= .F.
		cComments	:= "O Valor Mínimo para Condição de Pagamento BNDES é R$ "+AllTrim(Transform(nMinVlBndes, PesqPict("ZP6", "ZP6_TOTSUG")))
	endIf
	
return lOk

/**
 * Verifica as Regras de Valor Mínimo relacionadas ao Frete/Estado 
 */
static function checkFreightRules(oQuotation, cComments)
	
	local lOk 			:= .T.
	local nMinValue		:= 0
	local nSugTotal     := getSugTotal(oQuotation)
	local oCustomer		:= nil
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()	
	local cState		:= oQuotation:getDelState()
	local cFreight		:= oQuotation:getFreight()
	local cWhere		:= "%ZPC.XFILIAL% AND ZPC_FRETE = '"+cFreight+"'"
	
	if Empty(cState)
		oCustomer := oSrvCustomer:findByCode(oQuotation:getCodeCustomer(), oQuotation:getUnitCustomer())
		cState 	  := oCustomer:getState()
	endIf
	
	oSql:newTable("ZPC", "ZPC_VLRMIN MIN_VALUE", cWhere+" AND ZPC_UF LIKE '%"+cState+"%' ")
	
	if !oSql:hasRecords()
		oSql:newTable("ZPC", "ZPC_VLRMIN MIN_VALUE", cWhere+" AND ZPC_UF = '*' ")
	endIf
	
	if oSql:hasRecords()
		nMinValue := oSql:getValue("MIN_VALUE")
	endIf
	
	oSql:close()
	
	if (nMinValue > 0 .and. nMinValue > nSugTotal)
		lOk 	  := .F.
		cFreight  := if((cFreight == "C"), "CIF", "FOB")
		cComments := "Para Frete "+cFreight+" com entrega em "+cState+" o Valor Mínimo é R$ "+AllTrim(Transform(nMinValue, PesqPict("ZP6", "ZP6_TOTSUG"))) 
	endIf
	
return lOk

/**
 * Verifica as Regras de Valor Mínimo relacionadas a Condição de Pagamento
 */
static function checkPaymentRules(oQuotation, cComments)
	
	local lOk 			:= .T.	
	local aCondition	:= {}
	local cQuery		:= ""
	local nSugTotal 	:= 0
	local nPlots		:= 0
	local nMaxPlots		:= 0
	local nMaxTerms		:= 0
	local nAvgTerms		:= 0
	local nMinValue 	:= getPaymentMinValue()
	local cPayCond		:= oQuotation:getPaymentCondition()	
	local oSql			:= LibSqlObj():newLibSqlObj()
	
	if (nMinValue == 0)
		return .T.
	endIf
	
	nSugTotal := getSugTotal(oQuotation)
	
	if (nSugTotal < nMinValue)
		cComments := "O Valor Total Sugerido é menor que o mínimo permitido para Faturamento"
		return .F.
	endIf
	
	cQuery := " SELECT * FROM %ZPD.SQLNAME% " 
	cQuery += " WHERE %ZPD.XFILIAL% AND %ZPD.NOTDEL% AND "
	cQuery += " 	  ZPD_VLRMIN <= "+AllTrim(Str(nSugTotal))+" AND ZPD_VLRMAX >= "+AllTrim(Str(nSugTotal))+" "
	
	oSql:newAlias(cQuery)
	
	if !oSql:hasRecords()
		oSql:close()
		return .T.
	endIf
	
	aCondition	:= Condicao(nSugTotal, cPayCond)
	nPlots		:= Len(aCondition)
	nAvgTerms	:= Round(getAveragePaymentTerms(cPayCond), 0)
	nMaxPlots	:= oSql:getValue("ZPD_MAXPAR")
	nMaxTerms	:= oSql:getValue("ZPD_MAXPRZ")
	
	if (nPlots > nMaxPlots .or. nAvgTerms > nMaxTerms)
		lOk 	  := .F.
		cComments := "O Orçamento requer uma Condição de Pagamento com no máximo "+AllTrim(Str(nMaxPlots))+" parcelas e "
		cComments += "com Prazo Médio Máximo de "+AllTrim(Str(nMaxTerms))+" dias"
	endIf
	
	oSql:close()
	
return lOk

/**
 * Retorna o Valor Mínimo das Regras de Valores Minimos x Condição de Pagamento
 */
static function getPaymentMinValue()
	
	local cQuery    := ""
	local nMinValue := 0
	local oSql	    := LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT MIN(ZPD_VLRMIN) MIN_VALUE " 
	cQuery += " FROM %ZPD.SQLNAME% "
	cQuery += " WHERE %ZPD.XFILIAL% AND %ZPD.NOTDEL% " 
	
	oSql:newAlias(cQuery)
		
	nMinValue := oSql:getValue("MIN_VALUE")
	
	oSql:close()
	
return nMinValue

/**
 * Coleta o Prazo Médio de um Condição de Pagamento
 */
static function getAveragePaymentTerms(cPayCond)
	
	local oSql	    := LibSqlObj():newLibSqlObj()
	local cAvgTerms := oSql:getFieldValue("SE4", "E4_ZMEDPAG", "%SE4.XFILIAL% AND E4_CODIGO = '"+cPayCond+"'")
	
return Val(cAvgTerms)

/**
 * Verifica as Demais regras de Aprovação
 */
static function checkOtherRules(oQuotation)
	
	local lOk				:= .T.
	local lFlexOk			:= .T.
	local lVarejoOk			:= .T.
	local lBonificacao		:= (oQuotation:getType() == QUOTATION_TYPE_BONUS)
	local nI				:= 0
	local nTotalMeters		:= 0
	local nTotalFlex		:= 0
	local nFlexPerc			:= 0
	local nMaxFlex			:= GetNewPar("ZZ_MAXFLEX", 0)
	local nMinVarejo		:= GetNewPar("ZZ_MINVARE", 0)
	local nMaxVarejo		:= GetNewPar("ZZ_MAXVARE", 99999999999)
	local cComments 		:= ""
	local aItems			:= oQuotation:getItems()
	local oItem				:= nil	
	local oRule 			:= CbcQuotationRule():newCbcQuotationRule()
	local oSql				:= LibSqlObj():newLibSqlObj()
	
	for nI := 1 to Len(aItems)
			
		oItem := aItems[nI]
		
		nTotalMeters += oItem:getQuantity()
		
		if oItem:isFlex25()
			nTotalFlex += oItem:getQuantity()
		endIf	
		
	next nI

	if (nTotalFlex > 0)
		nFlexPerc := ((nTotalFlex / nTotalMeters) * 100)
	endIf
	
	if (nMaxFlex > 0 .and. nFlexPerc > nMaxFlex)
		lFlexOk := .F.
	endIf
	
	if (oQuotation:isRetail() .and. ( (oQuotation:getSugTotal() < nMinVarejo) .or. (oQuotation:getSugTotal() > nMaxVarejo) ))
		lVarejoOk := .F.
	endIf
	
	setSugAppTotal(@oQuotation)
		
	oSql:newTable("ZP5", "ZP5_ULTSUG, ZP5_ULTAPR", "%ZP5.XFILIAL% AND ZP5_NUM = '" + oQuotation:getId() + "'")
	
	nUltSug := oSql:getValue("ZP5_ULTSUG")
	nUltApp := oSql:getValue("ZP5_ULTAPR")
	
	oSql:close()
	
	if (lFlexOk .and. lVarejoOk .and. !lBonificacao)
		cComments := "Nenhuma outra regra foi violada"
	else
		lOk := .F.
		if !lFlexOk
			cComments := "O porcentual de Flex 2,5 mm2 não pode exceder " + AllTrim(Transform(nMaxFlex, "@E 999,999,999.99")) + "%"
		endIf
		if !lVarejoOk
			if !Empty(cComments)
				cComments += "<br/><br/>"
			endIf
			cComments += "A faixa de valores para vendas à varejo é de R$ " + AllTrim(Transform(nMinVarejo, "@E 999,999,999.99")) + " a " + AllTrim(Transform(nMaxVarejo, "@E 999,999,999.99"))
		endIf
		if lBonificacao
			if !Empty(cComments)
				cComments += "<br/><br/>"
			endIf
			cComments += "Orçamento tipo bonificação"
		endIf 	
	endIf
	
	oRule:setType(QUOTATION_OTHER_RULES)
	oRule:setDescription("Outras")
	oRule:setOk(lOk)
	oRule:setComments(cComments)
	
	aAdd(oQuotation:aRules, oRule)
	
return

/**
 * Coleta o Total Sugerido do Orçamento
 */
static function getSugTotal(oQuotation)
	
	local nI	  	:= 0
	local nSugTotal	:= 0
	local aItems 	:= oQuotation:getItems()
	
	if Empty(aItems)
		aItems := getItems(oQuotation)
	endIf
	
	for nI := 1 to Len(aItems)
		nSugTotal += aItems[nI]:getSugTotal()
	next nI
	
return nSugTotal


/*/{Protheus.doc} canTakeApproval

Verifica se um Usuário pode assumir a Aprovação de um Orçamento
	
@author victorhugo
@since 26/07/2016

@param xUser, String/CbcUser, ID ou Objeto do Usuário
@param oQuotation, CbcQuotation, Orçamento Cobrecom
@param cMsg, String, Variavel para atribuição das mensagens referentes as validações (opcional)
@param lCheckMinValues, Logico, Indica se deve verificar os valores minimos (por padrão assume .T.)
@param lCheckOnlySugTotal, Logico, Indica se deve verificar apenas o Valor Sugerido (por padrão assume .F.)

@return Logico Indica se o Usuário pode assumir a Aprovação do Orçamento
/*/
method canTakeApproval(xUser, oQuotation, cMsg, lCheckMinValues, lCheckOnlySugTotal) class CbcQuotationService	  
	
	local lOk 	   	:= .F.
	local oUser	   	:= nil
	local oUtils   	:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser 	:= CbcUserService():newCbcUserService()
	local cStatus  	:= oQuotation:getStatus()
	local cType		:= oQuotation:getType()
	
	if (ValType(xUser) == "O")
		oUser := xUser
	else
		oUser := oSrvUser:findById(xUser)
	endIf
	
	cMsg := ""
			
	if oUtils:isNull(oUser)
		
		cMsg := "Usuário inválido"	
		
	elseIf ( cStatus != QUOTATION_STATUS_WAITING_APPROVAL .and. cStatus != QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL .and. cStatus != QUOTATION_STATUS_APPROVINGLY)
		
		cMsg := "O orçamento não está aguardando aprovação"	
	
	elseIf !oUser:isApprover()
		
		cMsg := "O usuário informado não é aprovador"
		
	elseif (cStatus == QUOTATION_STATUS_APPROVINGLY .and. oUser:getId() == oQuotation:getIdApprover())	
		
		cMsg := "O usuário informado já está aprovando esse orçamento"
		
	elseif (cStatus == QUOTATION_STATUS_APPROVINGLY .and. !oUser:getAppProfile():canStealApproval())	
		
		cMsg := "O aprovador não possui permissão para assumir a aprovação de outro aprovador"
		
	elseif (cType == QUOTATION_TYPE_BONUS .and. !oUser:getAppProfile():canApproveBonus())	
		
		cMsg := "O aprovador não possui permissão para aprovar bonificações"	
		
	endIf	
	
	if Empty(cMsg)
		checkAppProfile(self, oUser, oQuotation, @cMsg, lCheckMinValues, lCheckOnlySugTotal)
	endIf
		
	lOk := Empty(cMsg)
	
	oQuotation:setCanTakeApproval(lOk)
	
return lOk

/**
 * Verifica se um Aprovador tem alçada para assumir um Orçamento
 */
static function checkAppProfile(oSelf, xUser, oQuotation, cMsg, lCheckMinValues, lCheckOnlySugTotal)
	
	local lOk 	    	 		:= .T.
	local cInvalidField  		:= ""	
	local oUser	 				:= nil
	local oProfile 				:= nil	
	local oSrvUser				:= CbcUserService():newCbcUserService()
	local aItems   		 		:= oQuotation:getItems()	
	default lCheckMinValues		:= .T.
	default lCheckOnlySugTotal	:= .F.
	
	if (ValType(xUser) == "O")
		oUser := xUser
	else
		oUser := oSrvUser:findById(xUser)
	endIf
	
	oProfile := oUser:getAppProfile()
	
	cMsg := ""	
	
	if Empty(aItems)
		setSugAppTotal(@oQuotation)
		oQuotation:setItems(getItems(oQuotation))
		oSelf:setTotals(oUser, @oQuotation)
		//oSelf:calcTaxInfo(oUser, @oQuotation)
	endIf
	
	if lCheckOnlySugTotal
		lOk := !invalidAppField(oQuotation:getSugTotal(), oProfile:getMinValue(), oProfile:getMaxValue(), lCheckMinValues)
		if !lOk				
			cMsg := "Total Sugerido fora da alçada do aprovador"
		endIf
		return lOk
	endIf
	
	if invalidAppField(oQuotation:getSugTotal(), oProfile:getMinValue(), oProfile:getMaxValue(), lCheckMinValues)	    
	    
	    cInvalidField := "Total Sugerido" 	  
	
	elseIf invalidAppField(oQuotation:getAppTotal(), oProfile:getMinValue(), oProfile:getMaxValue(), lCheckMinValues)	
		
		cInvalidField := "Total Aprovado" 
	
	elseIf invalidAppField(oQuotation:getAppRgTotal(), oProfile:getMinRg(), oProfile:getMaxRg(), lCheckMinValues)	
		
		cInvalidField := "RG Aprovado" 
	
	//elseIf invalidAppField(oQuotation:getAppDiscountAvg(), oProfile:getMinDiscount(), oProfile:getMaxDiscount(), lCheckMinValues)
	
	elseIf !checkDiscounts(oUser, oQuotation, lCheckMinValues)	
		
		cInvalidField := "Média de Desconto Aprovado"
		 
	endIf
	
	if Empty(cInvalidField)
		vldAppCommission(oQuotation, oProfile, lCheckMinValues, @cInvalidField)
	endIf	
	
	if !Empty(cInvalidField)		
		lOk  := .F.		
		cMsg := cInvalidField + " fora da alçada do aprovador"
	endIf
	
return lOk

/**
 * Verifica se um valor é invalido de acordo com a alça de aprovação
 */
static function invalidAppField(nValue, nMin, nMax, lCheckMin)

	local lInvalid := .F.

	if (nValue != 0)
		lInvalid := ( nValue > nMax .or. (lCheckMin .and. nValue < nMin) )
	endIf
	
return lInvalid

/**
 * Verifica as faixas de descontos do aprovador
 */
static function checkDiscounts(oUser, oQuotation, lCheckMin)

	local lOk       	:= .F.
	local lFound		:= .F.
	local xResult		:= nil		
	local cQuery		:= ""
	local cFormula		:= ""
	local nMinDiscount	:= 0
	local nMaxDiscount	:= 0
	local nAppDiscount	:= oQuotation:getAppDiscountAvg()
	local oSql			:= LibSqlObj():newLibSqlObj()
	local aAreaSA1  	:= SA1->(GetArea())
	local aAreaSE4  	:= SE4->(GetArea())
	local aAreaZP5  	:= ZP5->(GetArea())
	
	if (nAppDiscount == 0)		
		return .T.
	endIf
	
	cQuery := " SELECT ZPI_DESMIN, ZPI_DESMAX, ZPI_FORMUL "
	cQuery += " FROM %ZPI.SQLNAME% "
	cQuery += " WHERE %ZPI.XFILIAL% AND ZPI_CODUSR = '" + oUser:getId() + "' AND %ZPI.NOTDEL% "
	cQuery += " ORDER BY 1,2,3 "
	
	oSql:newAlias(cQuery)
	
	if !oSql:hasRecords()		
		oSql:close()
		return .F.
	endIf
	
	ZP5->(dbSetOrder(1))
	ZP5->(dbSeek(xFilial("ZP5") + oQuotation:getId()))
	
	SE4->(dbSetOrder(1))
	SE4->(dbSeek(xFilial("SE4") + ZP5->ZP5_CONDPG))
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + ZP5->(ZP5_CLIENT + ZP5_LOJA)))
	
	while oSql:notIsEof()
		
		nMinDiscount := oSql:getValue("ZPI_DESMIN")
		nMaxDiscount := oSql:getValue("ZPI_DESMAX")
		cFormula	 := oSql:getValue("ZPI_FORMUL")
		xResult		 := Formula(cFormula)
		
		if (ValType(xResult) == "L" .and. xResult)
			lFound := .T.
			exit
		endIf						
		
		oSql:skip()
	endDo
	
	oSql:close()		
	
	if lFound
		if lCheckMin
			lOk := ( nAppDiscount >= nMinDiscount .and. nAppDiscount <= nMaxDiscount )
		else
			lOk := ( nAppDiscount <= nMaxDiscount )
		endIf		
	endIf	
	
	RestArea(aAreaSA1)
	RestArea(aAreaSE4)
	RestArea(aAreaZP5)

return lOk

/**
 * Valida Comissão Fixa de um Orçamento
 */
static function vldAppCommission(oQuotation, oProfile, lCheckMin, cInvalidField)
	
	local lIsInvalid		:= .F.
	local lIsFixedCommission:= .F.
	local cItem				:= ""
	local nI	 			:= 0
	local nAppComission		:= 0
	local nMaxCommission 	:= oProfile:getMaxCommission()
	local nMinCommission 	:= oProfile:getMinCommission()
	local aItems 			:= oQuotation:getItems()
	
	cInvalidField := ""
	
	for nI := 1 to Len(aItems)
		
		lIsInvalid	   		:= .F.
		cItem		   		:= aItems[nI]:getItem()
		nAppCommission 		:= aItems[nI]:getAppCommission()
		lIsFixedCommission	:= aItems[nI]:isFixedCommission()
		
		if (nAppCommission != 0 .and. lIsFixedCommission)
			lIsInvalid := ( nAppCommission > nMaxCommission .or. (lCheckMin .and. nAppCommission < nMinCommission) )
		endIf
		
		if lIsInvalid
			cInvalidField := "Comissão Aprovada do item " + aItems[nI]:getItem()
			return .F.
		endIf
		
	next nI
	
return .T.

/**
 * Cria as Notificações relacionadas aos Orçamentos
 */
static function createNotifications(cEvent, cUserId, oQuotation, cErpUser, cInvoice)
	
	local lNotifyOwner		:= .F.
	local lNotifyApprover	:= .F.
	local aNotifyUsers		:= {}
	local aEmailUsers		:= {}		
	local oEvent			:= nil
	local oSrvQuotation		:= CbcQuotationService():newCbcQuotationService()
	local oSrvEvent 		:= CbcEventService():newCbcEventService()
	local oSrvUser			:= CbcUserService():newCbcUserService()	
	local lIsOwner			:= (cUserId == oQuotation:getIdUser())
	local lIsApprover		:= (cUserId == oQuotation:getIdApprover())
	local lHasApprover		:= !Empty(oQuotation:getIdApprover())
	local cMessage			:= ""
	local cAppId			:= oQuotation:getIdApprover()
	local cOwnerName		:= oSrvUser:getFullName(oQuotation:getIdUser())
	local cUserName			:= oSrvUser:getFullName(cUserId)
	local cQuotationLink	:= oSrvQuotation:getShowQuotationLink(oQuotation:getId())		
	
	if (cEvent == EVENT_QUOTATION_CREATE)
		
		cMessage := cUserName+" criou o "+cQuotationLink
		
	elseIf (cEvent == EVENT_QUOTATION_UPDATE)
		
		cMessage := cUserName+" alterou o "+cQuotationLink
		
		if lIsApprover
			lNotifyOwner := .T.
		endIf
		
	elseIf (cEvent == EVENT_QUOTATION_DELETE)
		
		cMessage 		:= cUserName+" excluiu o Orçamento "+oQuotation:getId()
		lNotifyApprover := .T.
		
	elseIf (cEvent == EVENT_QUOTATION_CANCEL)
		
		cMessage 		:= cUserName+" cancelou o "+cQuotationLink
		lNotifyApprover := .T.
		
	elseIf (cEvent == EVENT_FINISH_QUOTATION_MAINTENANCE)
		
		cMessage 		:= cUserName+" finalizou a manutenção do "+cQuotationLink
		lNotifyApprover := .T.				
		
	elseIf (cEvent == EVENT_SEND_QUOTATION_FOR_APPROVAL)
		
		cMessage 		:= "O "+cQuotationLink+" de "+cOwnerName+" está aguardando aprovação"
		lNotifyApprover := .T.
		
	elseIf (cEvent == EVENT_ASSUME_QUOTATION_APPROVAL)
				
		cAppId		 := cUserId
		cMessage 	 := cUserName+" assumiu a aprovação do "+cQuotationLink
		lNotifyOwner := .T.
		lIsApprover  := .T.
		lHasApprover := .T.
		
	elseIf (cEvent == EVENT_QUOTATION_APPROVAL)
	
		cMessage 	 := cUserName+" aprovou o "+cQuotationLink
		lNotifyOwner := .T.
	
	elseIf (cEvent == EVENT_QUOTATION_REJECTION)
		
		cMessage 	 := cUserName+" não aprovou o "+cQuotationLink
		lNotifyOwner := .T.
		
	elseIf (cEvent == EVENT_UNDO_QUOTATION_APPROVAL)
		
		cMessage 	 := cUserName+" desfez a decisão de aprovação do "+cQuotationLink
		lNotifyOwner := .T.
		
	elseIf (cEvent == EVENT_LOCK_QUOTATION_UPDATE)
		
		cMessage 	 := cUserName+" bloqueou a edição do "+cQuotationLink
		lNotifyOwner := .T.
		
	elseIf (cEvent == EVENT_UNLOCK_QUOTATION_UPDATE)
		
		cMessage 	 := cUserName+" desbloqueou a edição do "+cQuotationLink
		lNotifyOwner := .T.
		
	elseIf (cEvent == EVENT_GIVE_UP_QUOTATION_APPROVAL)
				
		cMessage 	 := cUserName+" desistiu de aprovar o "+cQuotationLink
		lNotifyOwner := .T.
		
	elseIf (cEvent == EVENT_QUOTATION_TEC_APPROVAL)	
		
		cMessage 		:= getErpUserName(cErpUser)+" aprovou o "+cQuotationLink 
		lNotifyApprover := .T.
	
	elseIf (cEvent == EVENT_QUOTATION_TEC_REJECTION)	
		
		cMessage 		:= getErpUserName(cErpUser)+" não aprovou o "+cQuotationLink 
		lNotifyApprover := .T.
		
	elseIf (cEvent == EVENT_CONFIRM_QUOTATION)		
		
		cMessage 	 := "O "+cQuotationLink+" foi processado com sucesso"
		lNotifyOwner := .T.
			
	elseIf (cEvent == EVENT_CREATE_QUOTATION_INVOICE)		
		
		cMessage 	 := "Foi emitida a Nota Fiscal "+cInvoice+" referente ao "+cQuotationLink
		lNotifyOwner := .T.
			
	elseIf (cEvent == EVENT_ERROR_PROCESSING_QUOTATION)		
		
		cMessage 	 := "Falha ao processar o "+cQuotationLink
		lNotifyOwner := .T.
			
	endIf
	
	if lNotifyOwner .and. !lIsOwner
		aAdd(aNotifyUsers, oQuotation:getIdUser())
		aAdd(aEmailUsers, oQuotation:getIdUser())
	endIf
	
	if lHasApprover .and. lNotifyApprover .and. !lIsApprover
		aAdd(aNotifyUsers, cAppId)
		aAdd(aEmailUsers, cAppId)
	endIf
	
	oEvent := CbcEvent():newCbcEvent(cEvent, cUserId, cMessage, aNotifyUsers, aEmailUsers)
	
	oSrvEvent:check(oEvent)
	
return


/*/{Protheus.doc} canRequestTecnicalApproval

Verifica se um Usuário pode solicitar Aprovação Técnica de um Orçamento
	
@author victorhugo
@since 26/07/2016

@param xUser, String/CbcUser, ID ou Objeto do Usuário
@param oQuotation, CbcQuotation, Orçamento Cobrecom
@param cMsg, String, Variavel para atribuição das mensagens referentes as validações (opcional)

@return Logico Indica se o Usuário pode assumir a Aprovação do Orçamento
/*/
method canRequestTecnicalApproval(xUser, oQuotation, cMsg) class CbcQuotationService
	
	local nI				:= 0
	local lOk 	   			:= .F.
	local lInvalidPackRules := .F.
	local aRules   			:= {}
	local oUser	   			:= nil
	local oSql				:= LibSqlObj():newLibSqlObj()
	local oUtils   			:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser 			:= CbcUserService():newCbcUserService()
	local cStatus  			:= oQuotation:getStatus()	
	
	if (ValType(xUser) == "O")
		oUser := xUser
	else
		oUser := oSrvUser:findById(xUser)
	endIf
	
	cMsg := ""	
			
	if oUtils:isNull(oUser)
		
		cMsg := "Usuário inválido"
				
	elseIf (cStatus != QUOTATION_STATUS_APPROVINGLY)
		
		cMsg := "O orçamento não está em aprovação"
	
	elseIf (oUser:getId() != oQuotation:getIdApprover())
		
		cMsg := "O usuário informado não é o aprovador do orçamento"
				
	else
	
		::checkRules(@oQuotation)
		
		aRules := oQuotation:getRules()
	
		for nI := 1 to Len(aRules)
			if (aRules[nI]:getType() == QUOTATION_PACKAGING_RULES)
				lInvalidPackRules := .T.
				exit
			endIf
		next nI
		
		if !lInvalidPackRules
			cMsg := "O orçamento não possui restrições relacionadas ao acondicionamento dos produtos"
		endIf	
	
	endIf
	
	lOk := Empty(cMsg)		
	
	oQuotation:setCanRequestTecnicalApproval(lOk)
	
return lOk


/*/{Protheus.doc} getShowQuotationLink

Retorna o Link para Visualização de um Orçamento no Portal
	
@author victorhugo
@since 16/08/2016

@param cId, String, ID do Orçamento

@return String URL para Visualização
/*/
method getShowQuotationLink(cId) class CbcQuotationService
	
	local cLink  := ""
	local cMvPar := if ( PORTAL_REST_API, "ZZ_PTURL", "ZZ_URLPORT" )
	local cUrl   := GetNewPar(cMvPar, "")	
	
	if (Right(cUrl, 1) != "/")
		cUrl += "/" 
	endIf
	
	if PORTAL_REST_API
		cUrl += "quotations/show/" + cId
	else
		cUrl += "quotation/show?id=" + cId
	endIf	
		
	cLink := 'Orçamento <a class="text-info" href="' + cUrl + '">' + cId + '</a>'
	
return cLink


/*/{Protheus.doc} isTecnicalApprover

Indica se o Usuário do Protheus é um Aprovador Técnico
	
@author victorhugo
@since 23/08/2016

@param cErpUser, String, ID do Usuário do Protheus (se não informado assume o usuário logado)

@return Logico Indica se é um Aprovador Técnico
/*/
method isTecnicalApprover(cErpUser) class CbcQuotationService
	
	default cErpUser  := __cUserId

return (cErpUser $ GetMv("ZZ_USAPRTE"))


/*/{Protheus.doc} getProductCode

Retorna o Código do Produto de um Item
	
@author victorhugo
@since 19/09/2016

@param cCustomer, String, Codigo do Cliente
@param cUnit, String, Loja do Cliente
@param oItem, CbcQuotationItem, Item do Orçamento
@param cColor, String, Código da Cor (se não informado assume a primeira cor do item)
@param cQuotationId, String, Número do Orçamento
@param lRetail, Logico, Indica se é uma venda para Varejo

@return String Codigo do Produto
/*/
method getProductCode(cCustomer, cUnit, oItem, cColor, cQuotationId, lRetail) class CbcQuotationService
	
	local nScan				:= 0
	local cCode 			:= ""
	local cStrClass			:= ""
	local cName				:= oItem:getCodeName()
	local cBitola			:= oItem:getCodeBitola()
	local cSpecialty		:= oItem:getSpecialty()
	local aColors			:= oItem:getColors()
	local oCbcProd			:= nil
	local oCbcRet		 	:= nil
	local oSql			 	:= LibSqlObj():newLibSqlObj()
	local cCodZP9			:= ""
	default cQuotationId 	:= ""
	default lRetail			:= .F.
	
	oCbcProd := CbcProductDetails():newCbcProductDetails(cCustomer, cUnit, lRetail)
	
	if !Empty(oItem:getIdReserve() )
		return oSql:getFieldValue("ZP4", "ZP4_CODPRO", "ZP4_FILIAL = '"+oItem:getBranchReserve()+"' AND ZP4_CODIGO = '"+oItem:getIdReserve()+"'") 
	endIf
	
	if Empty(cColor) .and. (Len(aColors) > 0)
		cColor := aColors[1]:getColorId()
	endIf
	
	if !Empty(cQuotationId)
		cCodZP9 := oSql:getFieldValue("ZP9", "ZP9_CODPRO", "%ZP9.XFILIAL% AND ZP9_NUM = '"+cQuotationId+"' AND ZP9_ITEM = '"+oItem:getItem()+"' AND ZP9_COR = '"+cColor+"'")
		if !Empty(cCodZP9)
			return cCodZP9
		endif
	endIf
	
	if Empty(cSpecialty)
		cSpecialty := "01"
	endIf
	
	oCbcProd:getClsStrings(cName, cBitola, cColor, AllTrim(cSpecialty))
	
	oCbcRet := oCbcProd:oCmbResp 
	
	if oCbcRet:lOk
		cStrClass := oCbcRet:cClasse
		cCode	  := AllTrim(cName) + AllTrim(cBitola) + AllTrim(cColor) + AllTrim(cStrClass) + AllTrim(cSpecialty)
	else
		::cErrorMessage := oCbcRet:cMsg
	endIf

return cCode


/*/{Protheus.doc} getDescStatus

Retorna a Descrição do Status dos Orçamentos
	
@author victorhugo
@since 26/09/2016

@param cStatus, String, Status do Orçamento

@return String Descrição do Status
/*/
method getDescStatus(cStatus) class CbcQuotationService    
    
    local cDescription := ""    
    
    if (cStatus == QUOTATION_STATUS_REVISION)
    	cDescription := "Revisão"
    elseIf (cStatus == QUOTATION_STATUS_UNDER_MAINTENANCE)
    	cDescription := "Em manutenção"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_APPROVAL)
    	cDescription := "Aguardando aprovação"
    elseIf (cStatus == QUOTATION_STATUS_APPROVINGLY)
    	cDescription := "Em aprovação"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_CONFIRM)
    	cDescription := "Aguandando confirmação"
    elseIf (cStatus == QUOTATION_STATUS_CONFIRMED)
    	cDescription := "Confirmado"
    elseIf (cStatus == QUOTATION_STATUS_NOT_APPROVED)
    	cDescription := "Não aprovado"
	 elseIf (cStatus == QUOTATION_STATUS_TECNICAL_REJECT)
    	cDescription := "Rejeição técnica"
    elseIf (cStatus == QUOTATION_STATUS_CANCELED)
    	cDescription := "Cancelado"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
    	cDescription := "Aguardando aprovação técnica"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_PROCESSING)
    	cDescription := "Aguardando processamento"
    elseIf (cStatus == QUOTATION_STATUS_PROCESSING)
    	cDescription := "Em processamento"
    elseIf (cStatus == QUOTATION_STATUS_ERROR_PROCESSING)
    	cDescription := "Erro de processamento"
	elseIf (cStatus == QUOTATION_STATUS_TECNICAL_REJECT)
    	cDescription := "Rejeição técnica"		
    endIf

return cDescription


/*/{Protheus.doc} getColorStatus

Retorna a Cor do Status dos Orçamentos
	
@author victorhugo
@since 26/09/2016

@param cStatus, String, Status do Orçamento

@return String Cor do Status
/*/
method getColorStatus(cStatus) class CbcQuotationService    
    
    local cColor := ""    
    
    if (cStatus == QUOTATION_STATUS_UNDER_MAINTENANCE)
    	cColor := "BR_BRANCO"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_APPROVAL)
    	cColor := "BR_AMARELO"
    elseIf (cStatus == QUOTATION_STATUS_APPROVINGLY)
    	cColor := "BR_PRETO"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_CONFIRM)
    	cColor := "BR_AZUL"
    elseIf (cStatus == QUOTATION_STATUS_CONFIRMED)
    	cColor := "BR_VERDE"
    elseIf (cStatus == QUOTATION_STATUS_NOT_APPROVED)
    	cColor := "BR_VERMELHO"
	elseIf (cStatus == QUOTATION_STATUS_TECNICAL_REJECT)
    	cColor := "BR_VERMELHO"
    elseIf (cStatus == QUOTATION_STATUS_CANCELED)
    	cColor := "BR_CANCEL"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)
    	cColor := "BR_MARROM"
    elseIf (cStatus == QUOTATION_STATUS_WAITING_PROCESSING)
    	cColor := "BR_CINZA"
    elseIf (cStatus == QUOTATION_STATUS_PROCESSING)
    	cColor := "BR_VIOLETA"
    elseIf (cStatus == QUOTATION_STATUS_ERROR_PROCESSING)
    	cColor := "BR_LARANJA"			
    endIf

return cColor


/*/{Protheus.doc} updateAppPrice

Atualização da Aprovação dos Preços dos Itens dos Orçamentos
	
@author victorhugo
@since 30/11/2016

@param cUserId, String, ID do Aprovador
@param cQuotationId, String, Número do Orçamento
@param oItem, CbcQuotationItem, Item do Orçamento

@return Logico Indica se a aprovação foi bem sucedida
/*/
method updateAppPrice(cUserId, cQuotationId, oItem) class CbcQuotationService
		
	local cUpdate	 := ""
	local oSql		 := LibSqlObj():newLibSqlObj()
	local oUtils 	 := LibUtilsObj():newLibUtilsObj()
	local oQuotation := ::getById(cQuotationId)

	if oUtils:isNull(oQuotation)
		::cErrorMessage := "Orçamento não encontrado"
		return .F.
	endIf
	
	if (oQuotation:getStatus() != QUOTATION_STATUS_APPROVINGLY)
		::cErrorMessage := "O orçamento " + oQuotation:getId() + " não está em aprovação"
		return .F.
	endIf
	
	if (cUserId != oQuotation:getIdApprover())
		::cErrorMessage := "O usuário informado não é o Aprovador do Orçamento"
		return .F.
	endIf
			
	cUpdate := " ZP6_PRCAPR = "+AllTrim(Str(oItem:getAppPrice()))+", "
	cUpdate += " ZP6_TOTAPR = "+AllTrim(Str(oItem:getAppTotal()))+", " 
	cUpdate += " ZP6_DESAPR = '"+AllTrim(oItem:getAppDiscount())+"', "
	cUpdate += " ZP6_COMAPR = "+AllTrim(Str(oItem:getAppCommission()))+", " 
	cUpdate += " ZP6_RGAPR = "+AllTrim(Str(oItem:getAppRg()))+", "
	cUpdate += " ZP6_DIFPRC = "+AllTrim(Str(oItem:getPriceDiff()))+", "
	cUpdate += " ZP6_APAUTO = 'N', "
	cUpdate += " ZP6_COMFIX = "+if(oItem:isFixedCommission(), "'S'", "'N'")+" "
	
	oSql:update("ZP6", cUpdate, "%ZP6.XFILIAL% AND ZP6_NUM = '"+cQuotationId+"' AND ZP6_ITEM = '"+oItem:getItem()+"'")
	
return .T.


/*/{Protheus.doc} setTotals

Define os Totais de um Orçamento
	
@author victorhugo
@since 26/07/2016

@param xUser, String/CbcUser, ID ou Objeto do Usuário
@param oQuotation, CbcQuotation, Orçamento Cobrecom
@param cMsg, String, Variavel para atribuição das mensagens referentes as validações (opcional)
/*/
method setTotals(xUser, oQuotation, cMsg) class CbcQuotationService
	
	local lOk 	   := .F.
	local oUser	   := nil
	local oUtils   := LibUtilsObj():newLibUtilsObj()
	local oSrvUser := CbcUserService():newCbcUserService()
	local oCbcProd := CbcProductValues():newCbcProductValues()
	
	default cMsg   := ""
	
	oQuotation:setMinRgTotal(0)
	oQuotation:setSugRgTotal(0)
	oQuotation:setAppRgTotal(0)
	oQuotation:setCopperTotal(0)
	oQuotation:setSugDiscountAvg(0)
	oQuotation:setAppDiscountAvg(0)
	oQuotation:setSugCommissionAvg(0)
	oQuotation:setAppCommissionAvg(0)
	oQuotation:setSugImp(0)
	oQuotation:setAppImp(0)
	
	if (ValType(xUser) == "O")
		oUser := xUser
	else
		oUser := oSrvUser:findById(xUser)
	endIf
	
	begin sequence
			
		if oUtils:isNull(oUser)
			cMsg := "Usuário inválido"
			break
		endIf	
		
		oCbcProd:getCalcFrmQuot(oQuotation, {"TOTAL_RG","DATA_ENTREGA","TOTAIS","IMP"})	
		
		lOk  := oCbcProd:lOk
		cMsg := oCbcProd:cMsg 
		
		if !lOk		
			break
		endIf
		
		if oUser:isApprover()
			oQuotation:setMinRgTotal(oCbcProd:oQuotRg:getFromMinTotal())
			oQuotation:setSugRgTotal(oCbcProd:oQuotRg:getFromSugTotal())
			oQuotation:setAppRgTotal(oCbcProd:oQuotRg:getFromAppTotal())			
		endIf
				
		oQuotation:setCopperTotal(oCbcProd:getTotalWeight())
		oQuotation:setSugDiscountAvg(oCbcProd:getAvgSugDisc())
		oQuotation:setAppDiscountAvg(oCbcProd:getAvgDiscApp())
		oQuotation:setSugCommissionAvg(oCbcProd:getAvgSugComm())
		oQuotation:setAppCommissionAvg(oCbcProd:getAvgCommApp())
		oQuotation:setSugImp(oCbcProd:getImpSug())
		oQuotation:setAppImp(oCbcProd:getImpApp())
		oQuotation:setStandardDelivery(oCbcProd:getDlvDate())	
		
	end sequence
	
return lOk


/*/{Protheus.doc} calcTaxInfo
Define os impostos de um orçamento
@author leonardo
@since 06/08/2021
@param xUser, String/CbcUser, ID ou Objeto do Usuário
@param oQuotation, CbcQuotation, Orçamento Cobrecom
@param cMsg, String, Variavel para atribuição das mensagens referentes as validações (opcional)
/*/
method calcTaxInfo(xUser, oQuotation, cMsg) class CbcQuotationService 
	local lOk 	   		:= .T.
	local oUser	   		:= nil
	local oCustomer		:= nil
	local oJsonItm  	:= nil
	local aTax			:= {}
	local oJsonCli  	:= JsonObject():new()
	local oJsonReq  	:= JsonObject():new()
	local oJsonRes  	:= JsonObject():new()
	local oSrvUser 		:= CbcUserService():newCbcUserService()
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local aItms			:= {}
	local aImpostos		:= {}
	local nX			:= 0
	default cMsg   		:= ''
	if (ValType(xUser) == "O")
		oUser := xUser
	else
		oUser := oSrvUser:findById(xUser)
	endIf
	begin sequence
		if oUtils:isNotNull(oUser)
			if oUser:isApprover()
				if Empty(oQuotation:getCodeCustomer()) .or. Empty(oQuotation:getUnitCustomer())
					lOk  := .F.
					cMsg := "Cliente não informado"
					break 
				endif
				oCustomer := oSrvCustomer:findByCode(oQuotation:getCodeCustomer(), oQuotation:getUnitCustomer())
				if oUtils:isNull(oCustomer)
					lOk  := .F.
					cMsg := "Cliente inválido"
					break
				endif
				// oQuotation:getCnpjPadrao()
				if (oCustomer:getCode() == DEFAULT_CUSTOMER_CODE .and. oCustomer:getUnit() == DEFAULT_CUSTOMER_UNIT)
					lOk  := .F.
					cMsg := "Apenas clientes cadastrados!"
					break
				else
					oJsonCli['A1_COD']	:= oCustomer:getCode()
					oJsonCli['A1_LOJA'] := oCustomer:getUnit()
					oJsonReq['CLI'] 	:= oJsonCli
					oJsonReq['ITEMS']	:= {}
					aItms := oQuotation:getItems()
					for nX := 1 to len(aItms)
						oJsonItm			:= JsonObject():new()
						oJsonItm['COD'] 	:= ::getProductCode(oCustomer:getCode(), oCustomer:getUnit(), aItms[nX], ,oQuotation:getId())
						oJsonItm['QTD']		:= aItms[nX]:getQuantity()
						oJsonItm['PRCUNIT']	:= aItms[nX]:getSugPrice()
						oJsonItm['TOTAL']	:= (oJsonItm['PRCUNIT'] * oJsonItm['QTD'])
						aadd(oJsonReq['ITEMS'], oJsonItm)
					next nX
					oJsonRes:fromJson(u_cbcTaxPortal(oJsonReq:toJson())) 
					for nX := 1 to len(oJsonRes['aImpostos'])
						if oJsonRes['aImpostos'][nX][4] > 0
							aadd(aImpostos,oJsonRes['aImpostos'][nX])
						endif
					next nX
					aTax := aClone({ aImpostos, oJsonRes['TotalMerc'], oJsonRes['Total'],oJsonRes['Filial']})
				endif
			endIf
		endif
	end sequence
	oQuotation:setTaxinfo({lOk, cMsg, aTax})
	FreeObj(oSrvUser)
	FreeObj(oJsonRes)
	FreeObj(oJsonReq)
	FreeObj(oSrvCustomer)
	FreeObj(oJsonCli)
	FreeObj(oUtils)
return lOk


/*/{Protheus.doc} updateCustomer

Atualiza o cliente de um Orçamento
	
@author victorhugo
@since 23/01/2017

@param cQuotationId, String, Numero do Orçamento
@param cCodeCustomer, String, Codigo do Cliente
@param cUnitCustomer, String, Loja do Cliente
@param cUserId, String, Codigo do Usuario (opcional)

@return Logico Indica se o cliente foi atualizado
/*/
method updateCustomer(cQuotationId, cCodeCustomer, cUnitCustomer, cUserId) class CbcQuotationService
	
	local lOK   		:= .F.
	local cNameCustomer := ""
	local oQuotation	:= ::getById(cQuotationId, cUserId)
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSql  		:= LibSqlObj():newLibSqlObj()
	
	begin sequence
		
		if oUtils:isNull(oQuotation)
			::cErrorMessage := "Orçamento não encontrado"
			break
		endIf
		
		if (oQuotation:getStatus() != QUOTATION_STATUS_WAITING_CONFIRM)
			::cErrorMessage := "Esse orçamento não está aguardando confirmação"
			break	
		endIf
		
		cNameCustomer := oSql:getFieldValue("SA1", "A1_NOME", "%SA1.XFILIAL% AND A1_COD = '"+cCodeCustomer+"' AND A1_LOJA = '"+cUnitCustomer + "' AND A1_MSBLQL != '1'  AND A1_REVIS = '1' ")
		
		if Empty(cNameCustomer)
			::cErrorMessage := "Cliente inválido"
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
	if lOk
		oSql:update("ZP5", "ZP5_CLIENT = '"+cCodeCustomer+"', ZP5_LOJA = '"+cUnitCustomer+"', ZP5_NOMCLI = '"+cNameCustomer+"'", ;
					"%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	endIf

return lOk
	
	
/*/{Protheus.doc} setProcessing

Define um Orçamento com o Status em Processamento
	
@author victorhugo
@since 19/05/2017
/*/
method setProcessing(cQuotationId) class CbcQuotationService
				
	local oSql    := LibSqlObj():newLibSqlObj()
	local cStatus := oSql:getFieldValue("ZP5", "ZP5_STATUS", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	
	if Empty(cStatus)
		::cErrorMessage := "Orçamento não encontrado"
		return .F.
	endIf
	
	if (!cStatus $ QUOTATION_STATUS_WAITING_PROCESSING + "," + QUOTATION_STATUS_ERROR_PROCESSING)
		::cErrorMessage := "Esse Orçamento não está aguardando processamento"
		return .F.
	endIf
	
	updateStatus(@self, cQuotationId, QUOTATION_STATUS_PROCESSING)	

return .T.


/*/{Protheus.doc} setConfirmed

Define um Orçamento com o Status Confirmado
	
@author victorhugo
@since 19/05/2017
/*/
method setConfirmed(xQuotation, aDocuments) class CbcQuotationService
	
	local nI	     	:= 0
	local cUserId	 	:= ""
	local oQuotation	:= nil
	local cQuotationId	:= ''
	local oUtils	 	:= LibUtilsObj():newLibUtilsObj()
	local cType			:= ValType(xQuotation)
	default aDocuments	:= {}  
	
	if (cType == "O")
		oQuotation := xQuotation
	elseIf (cType == 'C')
		oQuotation 	:= ::getById(xQuotation)
	else
		::cErrorMessage := "Tipo parametro inválido"
		return .F.
	endIf
	
	if oUtils:isNull(oQuotation)
		::cErrorMessage := "Orçamento não encontrado"
		return .F.
	endIf
	
	cQuotationId := oQuotation:getId()
	
	if (oQuotation:getStatus() != QUOTATION_STATUS_PROCESSING)
		::cErrorMessage := "Esse Orçamento não está em processamento"
		return .F.
	endIf
	
	begin transaction
	
		for nI := 1 to Len(aDocuments)
			if !::addDocument(cQuotationId, aDocuments[nI])
				DisarmTransaction()
				return .F.
			endIf
		next nI
		
		ZP5->(dbSetOrder(1))
		ZP5->(dbSeek(xFilial("ZP5")+cQuotationId))
		
		if ZP5->(RecLock("ZP5", .F.))
			ZP5->ZP5_DTPROC  := Date()
			ZP5->ZP5_HRPROC  := Left(Time(), 5)
			ZP5->ZP5_OBPROC := "Orçamento confirmado com sucesso"
		endIf
	
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_CONFIRMED)	
		createNotifications(EVENT_CONFIRM_QUOTATION, cUserId, oQuotation)		
			
	end transaction

return .T.


/*/{Protheus.doc} setErrorProcessing

Define um Orçamento com o Status Erro de Processamento
	
@author victorhugo
@since 19/05/2017
/*/
method setErrorProcessing(xQuotation, cErrorMessage) class CbcQuotationService

	local cUserId	 		:= ""
	local oQuotation		:= nil
	local cQuotationId		:= ''
	local oUtils	 		:= LibUtilsObj():newLibUtilsObj()
	local cType				:= ValType(xQuotation) 
	default cErrorMessage	:= ''
	
	if (cType == "O")
		oQuotation := xQuotation
	elseIf (cType == 'C')
		oQuotation 	:= ::getById(xQuotation)
	else
		::cErrorMessage := "Tipo parametro inválido"
		return .F.
	endIf
	
	if oUtils:isNull(oQuotation)
		::cErrorMessage := "Orçamento não encontrado"
		return .F.
	endIf
	
	cQuotationId := oQuotation:getId()
	
	if (oQuotation:getStatus() != QUOTATION_STATUS_PROCESSING)
		::cErrorMessage := "Esse Orçamento não está em processamento"
		return .F.
	endIf
	
	begin transaction
		
		ZP5->(dbSetOrder(1))
		ZP5->(dbSeek(xFilial("ZP5")+cQuotationId))
		
		if ZP5->(RecLock("ZP5", .F.))
			ZP5->ZP5_DTPROC  := Date()
			ZP5->ZP5_HRPROC  := Left(Time(), 5)
			ZP5->ZP5_OBPROC := cErrorMessage
		endIf
	
		updateStatus(@self, cQuotationId, QUOTATION_STATUS_ERROR_PROCESSING)
		createNotifications(EVENT_ERROR_PROCESSING_QUOTATION, cUserId, oQuotation)			
			
	end transaction

return .T.


/*/{Protheus.doc} batchApproval

Aprovação em Lote dos Orçamentos
	
@author victorhugo
@since 01/06/2017
/*/
method batchApproval(cUserId, cQuotationId, cOption, nValue, cProduct, cBitola, cPack, lOnlyNotApproved) class CbcQuotationService
	
	local nI		  := 0
	local lOk		  := .F.
	local cMsg		  := ""
	local aItems	  := {}
	local oItem		  := nil
	local oQuotation  := nil		
	local oSql	 	  := LibSqlObj():newLibSqlObj()	
	
	if !validBatchApproval(@self, cUserId, cQuotationId, cOption)
		return .F.
	endIf	
	
	oQuotation := ::getById(cQuotationId, cUserId)	
	aItems	   := oQuotation:getItems()
	
	begin transaction
	
		for nI := 1 to Len(aItems)
		
			oItem := aItems[nI]
			
			if (!Empty(cProduct) .and. oItem:getCodeName() != cProduct) .or. (!Empty(cBitola) .and. oItem:getCodeBitola() != cBitola) .or. ;
			   (!Empty(cPack) .and. oItem:getIdPackage() != cPack)				   
			   loop
			endIf			
			
			if lOnlyNotApproved .and. (oItem:getAppPrice() > 0)
				loop
			endIf
			
			if (cOption == "commission")
				lOk := oSql:update("ZP6", "ZP6_COMFIX = 'S', ZP6_COMAPR = " + AllTrim(Str(nValue)), ; 
								   "%ZP6.XFILIAL% AND ZP6_NUM = '" + cQuotationId + "' AND ZP6_ITEM = '" + oItem:getItem() + "'")
			else
				lOk := updBatchAppPrice(@self, oQuotation, oItem, cOption, nValue)
			endIf			
			
			if !lOk
				DisarmTransaction()
				return .F.
			endIf
		
		next nI		
	
	end transaction		

return .T.

/**
 * Valida a Aprovação em Lote
 */
static function validBatchApproval(oSelf, cUserId, cQuotationId, cOption)
	
	local lOk	 := .T.
	local cQuery := ""
	local cError := ""	
	local oSql	 := LibSqlObj():newLibSqlObj()
	
	begin sequence
	
		if !oSql:exists("ZP1", "%ZP1.XFILIAL% AND ZP1_CODIGO = '" + cUserId + "' AND ZP1_MSBLQL != '1'")
			cError := "Usuário inválido"
			break
		endIf
		
		oSql:newTable("ZP5", "ZP5_APROVA APPROVER, ZP5_STATUS [STATUS]", "%ZP5.XFILIAL% AND ZP5_NUM = '" + cQuotationId + "'")
		
		if !oSql:hasRecords()
			cError := "Orçamento não encontrado"
			break
		endIf
		
		if (oSql:getValue("APPROVER") != cUserId)
			cError := "Esse usuário não está aprovando o Orçamento " + cQuotationId
			break
		endIf  
		
		if (oSql:getValue("STATUS") != QUOTATION_STATUS_APPROVINGLY)
			cError := "O orçamento " + cQuotationId + " não está em aprovação"
			break
		endIf
		
		if !(cOption $ "diff,discount,commission,rg")
			cError := "Opção inválida"
			break
		endIf		
	
	end sequence
	
	if !Empty(cError)
		oSelf:cErrorMessage := cError
		lOk := .F.
	endIf	
	
	oSql:close()
	
return lOk

/**
 * Atualiza o Preço Aprovado de um item na Aprovação em Lote
 */
static function updBatchAppPrice(oSelf, oQuotation, oItem, cOption, nValue)
	
	local lOk			:= .F.
	local oCbcProdVal	:= nil
	local nAppPrice		:= 0
	local nAppTotal		:= 0
	local nAppRg		:= 0
	local nAppCommission:= 0
	local nDiffValue	:= 0
	local nPriceDiff	:= 0
	local cAppDiscount	:= ""	
	local oCbcProdVal 	:= nil
	local oUser			:= nil
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oUtils	  	:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()
	local oCustomer 	:= oSrvCustomer:findByCode(oQuotation:getCodeCustomer(), oQuotation:getUnitCustomer())	
	local oSeller	  	:= oCustomer:getSeller()
	local cPackage	  	:= oItem:getIdPackage() + StrZero(oItem:getAmountPackage(), 5)
	local cProductCode  := oSelf:getProductCode(oCustomer:getCode(), oCustomer:getUnit(), oItem, nil, nil, oQuotation:isRetail())
	
	if (cOption == "diff")
		nAppPrice := oItem:getSugPrice() + ((oItem:getSugPrice() * nValue) / 100)
	elseIf (cOption == "discount")
		nAppPrice := oItem:getMinPrice() - ((oItem:getMinPrice() * nValue) / 100)
	elseIf (cOption == "rg")
		oCbcProdVal	:= CbcProductValues():newCbcProductValues()
		oCbcProdVal:setRetail(oQuotation:isRetail())
		nAppPrice 	:= oCbcProdVal:getPrcFrmRG(nValue, oItem:getQuantity(), cProductCode)
	endIf		
	
	oCbcProdVal	:= CbcProductValues():newCbcProductValues(oCustomer:getCode(), oCustomer:getUnit(), cProductCode, cPackage, oItem:getQuantity(), nAppPrice)
	
	oCbcProdVal:setPayTerm(oQuotation:getPaymentCondition())
	oCbcProdVal:setTpFreight(oQuotation:getFreight())
	oCbcProdVal:setRetail(oQuotation:isRetail())
	
	if oUtils:isNotNull(oSeller) .and. !Empty(oSeller:getId())
		oCbcProdVal:setSalesMan(oSeller:getId())
	else
		oUser   := oSrvUser:findById(oQuotation:getIdUser())
		oSeller := oUser:getSeller()
		if oUtils:isNotNull(oSeller)
			oCbcProdVal:setSalesMan(oSeller:getId())
		endIf
	endIf
	
	oCbcProdVal:initCalc()
	
	if oCbcProdVal:lOk
		
		lOk 		   := .T.
		nAppTotal	   := (oItem:getQuantity() * nAppPrice)
		cAppDiscount   := oCbcProdVal:cCalcDiscRange
		nAppRg		   := if(Empty(oCbcProdVal:nCalcRg), 0, oCbcProdVal:nCalcRg)
		nAppCommission := if(Empty(oCbcProdVal:nCommission), 0, oCbcProdVal:nCommission)
		nDiffValue	   := (nAppPrice - oItem:getSugPrice())
		nPriceDiff	   := ((nDiffValue / oItem:getSugPrice()) * 100)
		
		cUpdate := " ZP6_PRCAPR = " + AllTrim(Str(nAppPrice)) + ", "
		cUpdate += " ZP6_TOTAPR = " + AllTrim(Str(nAppTotal)) + ", "
		cUpdate += " ZP6_RGAPR = " + AllTrim(Str(nAppRg)) + ", "
		cUpdate += " ZP6_DIFPRC = " + AllTrim(Str(nPriceDiff)) + ", "
		cUpdate	+= " ZP6_DESAPR = '" + cAppDiscount + "', "
		cUpdate	+= " ZP6_APAUTO = 'N' "	
		
		if (!oItem:isFixedCommission())
			cUpdate += ", ZP6_COMAPR = " + AllTrim(Str(nAppCommission))
		endIf	
		
		oSql:update("ZP6", cUpdate, "%ZP6.XFILIAL% AND ZP6_NUM = '" + oQuotation:getId() + "' AND ZP6_ITEM = '" + oItem:getItem() + "'")		
		
	else
	
		oSelf:cErrorMessage := oCbcProdVal:cMsg
		
	endIf
	
return lOk


/*/{Protheus.doc} canPrint

Verifica se um Orçamento pode ser impresso
	
@author victorhugo
@since 17/08/2017
/*/
method canPrint(oUser, oQuotation) class CbcQuotationService
	
	local lCanPrint 	:= .F.
	local aValidStatus	:= {}
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local lCheck		:= (GetNewPar("ZZ_VLIMPOR", "S") == "S")
	
	if oUtils:isNull(oUser)
		oQuotation:setCanPrint(.T.)
		return .T.
	endIf	
	
	aAdd(aValidStatus, QUOTATION_STATUS_WAITING_CONFIRM)
	aAdd(aValidStatus, QUOTATION_STATUS_CONFIRMED)
	aAdd(aValidStatus, QUOTATION_STATUS_WAITING_PROCESSING)
	aAdd(aValidStatus, QUOTATION_STATUS_PROCESSING)
	aAdd(aValidStatus, QUOTATION_STATUS_ERROR_PROCESSING)
		
	if !lCheck .or. (oUser:getGroup() != USER_SELLER) 
		lCanPrint := .T.
	else
		lCanPrint := (aScan(aValidStatus, oQuotation:getStatus()) > 0)
	endIf	
	
	oQuotation:setCanPrint(lCanPrint)

return lCanPrint


/*/{Protheus.doc} getWaitingQuotations

Retorna os Orçamentos aguardando confirmação
	
@author victorhugo
@since 13/10/2017
/*/
method getWaitingQuotations(cUserId) class CbcQuotationService
	
	local nI   			 := 0
	local lAdd			 := .F.
	local aQuotations	 := {}
	local oQuotation	 := nil
	local oUtils		 := LibUtilsObj():newLibUtilsObj()
	local oCbcCheckOrder := CbcCheckOrder():newCbcCheckOrder()
	local oSrvUser		 := CbcUserService():newCbcUserService()
	local oUser	 		 := oSrvUser:findById(cUserId)
	local aIds 			 := oCbcCheckOrder:getWarningCancel()
	
	for nI := 1 to Len(aIds)
		
		oQuotation := createWaitingQuotation(oUser, aIds[nI])			
		
		if oUtils:isNotNull(oQuotation)
			aAdd(aQuotations, oQuotation)
		endIf	
	
	next nI
	
return aQuotations

/**
 * Cria um Orçamento que está aguardando confirmação
 */
static function createWaitingQuotation(oUser, cId)
	
	local cQuery 		:= ""
	local oQuotation	:= CbcQuotation():newCbcQuotation()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSql			:= LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT ZP5_STATUS [STATUS], ZP5_DATA [DATE], ZP5_HORA [TIME], ZP5_RESPON ID_USER, ZP1_NOME NAME_USER, "
	cQuery += "        ZP5_CLIENT CODE_CUSTOMER, ZP5_LOJA UNIT_CUSTOMER, A1_NOME NAME_CUSTOMER "
	cQuery += " FROM %ZP5.SQLNAME% "	
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
	cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
	cQuery += " 		%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
	cQuery += " WHERE %ZP5.XFILIAL% AND ZP5_NUM = '" + cId + "' AND %ZP5.NOTDEL% "
	
	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())	
		cQuery += " AND ZP5_CLIENT = '"+oUser:getCustomer():getCode()+"' AND ZP5_LOJA = '"+oUser:getCustomer():getUnit()+"' "
	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND ZP1_CODVEN = '"+oUser:getSeller():getId()+"' "
	endIf
	
	oSql:newAlias(cQuery)	
	oSql:setField("DATE", "D")
	
	if !oSql:hasRecords()
		oSql:close()
		return nil
	endIf
	 
	oQuotation:setId(cId)
	oQuotation:setStatus(oSql:getValue("STATUS"))
	oQuotation:setDate(oSql:getValue("DATE"))
	oQuotation:setTime(oSql:getValue("AllTrim(TIME)"))
	oQuotation:setIdUser(oSql:getValue("ID_USER"))
	oQuotation:setNameUser(oSql:getValue("AllTrim(NAME_USER)"))
	oQuotation:setCodeCustomer(oSql:getValue("CODE_CUSTOMER"))
	oQuotation:setUnitCustomer(oSql:getValue("UNIT_CUSTOMER"))
	oQuotation:setNameCustomer(oSql:getValue("AllTrim(NAME_CUSTOMER)"))
	
	setSugAppTotal(@oQuotation)
	
	oSql:close()
	
return oQuotation


/*/{Protheus.doc} batchPriceUpdate

Alteração em Lote dos Preços
	
@author victorhugo
@since 14/01/2019
/*/
method batchPriceUpdate(cUserId, cQuotationId, cOption, nValue, cProduct, cBitola, cPack) class CbcQuotationService
	
	local nI		  		:= 0
	local lOk		  		:= .F.
	local cMsg		  		:= ""
	local cStatus	  		:= ""
	local aItems	  		:= {}
	local oItem		  		:= nil
	local oQuotation  		:= nil		
	local oSql	 	  		:= LibSqlObj():newLibSqlObj()	
	
	if !vldBatchPriceUpdate(@self, cUserId, cQuotationId, cOption)
		return .F.
	endIf	
	
	oQuotation := ::getById(cQuotationId, cUserId)	
	cStatus	   := oQuotation:getStatus()
	aItems	   := oQuotation:getItems()
	
	begin transaction
	
		for nI := 1 to Len(aItems)
		
			oItem := aItems[nI]
			
			if (!Empty(cProduct) .and. oItem:getCodeName() != cProduct) .or. (!Empty(cBitola) .and. oItem:getCodeBitola() != cBitola) .or. ;
			   (!Empty(cPack) .and. oItem:getIdPackage() != cPack)				   
			   loop
			endIf			
			
			lOk := updBatchSugPrice(@self, cUserId, oQuotation, oItem, cOption, nValue)
			
			if !lOk
				DisarmTransaction()
				return .F.
			endIf
		
		next nI		
		
		if (cStatus != QUOTATION_STATUS_UNDER_MAINTENANCE)
			oSql:update("ZP5", "ZP5_STATUS = '" + QUOTATION_STATUS_UNDER_MAINTENANCE + "'", "%ZP5.XFILIAL% AND ZP5_NUM = '" + oQuotation:getId() + "'") 
		endIf
	
	end transaction		

return .T.

/**
 * Valida a Alteração de Preços Sugeridos em Lote
 */
static function vldBatchPriceUpdate(oSelf, cUserId, cQuotationId, cOption)
	
	local lOk	 := .T.
	local cQuery := ""
	local cError := ""	
	local oSql	 := LibSqlObj():newLibSqlObj()
	
	begin sequence
	
		if !oSql:exists("ZP1", "%ZP1.XFILIAL% AND ZP1_CODIGO = '" + cUserId + "' AND ZP1_MSBLQL != '1'")
			cError := "Usuário inválido"
			break
		endIf
		
		oSql:newTable("ZP5", "ZP5_RESPON [OWNER], ZP5_STATUS [STATUS]", "%ZP5.XFILIAL% AND ZP5_NUM = '" + cQuotationId + "'")
		
		if !oSql:hasRecords()
			cError := "Orçamento não encontrado"
			break
		endIf
		
		if (oSql:getValue("OWNER") != cUserId)
			cError := "Esse usuário não é o responsável pelo Orçamento " + cQuotationId
			break
		endIf  
		
		if !oSql:getValue("STATUS") $ QUOTATION_STATUS_UNDER_MAINTENANCE + "," + QUOTATION_STATUS_WAITING_APPROVAL + "," + ; 
									  QUOTATION_STATUS_WAITING_CONFIRM + "," + QUOTATION_STATUS_WAITING_PROCESSING + "," + ;
									  QUOTATION_STATUS_ERROR_PROCESSING + "," + QUOTATION_STATUS_NOT_APPROVED+ "," +QUOTATION_STATUS_TECNICAL_REJECT
			cError := "Status inválido"
			break
		endIf
		
		if !(cOption $ "diff,fixed_price")
			cError := "Opção inválida"
			break
		endIf		
	
	end sequence
	
	if !Empty(cError)
		oSelf:cErrorMessage := cError
		lOk := .F.
	endIf	
	
	oSql:close()
	
return lOk

/**
 * Atualiza o Preço Sugerido de um item na Alteração em Lote
 */
static function updBatchSugPrice(oSelf, cUserId, oQuotation, oItem, cOption, nValue)
	
	local lOk			:= .F.
	local oCbcProdVal	:= nil
	local nSugPrice		:= 0
	local nSugTotal		:= 0
	local nSugRg		:= 0
	local nSugCommission:= 0
	local nAppPrice		:= 0
	local nAppTotal		:= 0
	local nAppRg		:= 0
	local nAppCommission:= 0
	local cSugDiscount	:= ""
	local cAppDiscount	:= ""
	local cAppAuto		:= ""	
	local oCbcProdVal 	:= nil
	local oUser			:= nil
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oUtils	  	:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()
	local oCustomer 	:= oSrvCustomer:findByCode(oQuotation:getCodeCustomer(), oQuotation:getUnitCustomer())	
	local oSeller	  	:= oCustomer:getSeller()
	local cPackage	  	:= oItem:getIdPackage() + StrZero(oItem:getAmountPackage(), 5)
	local cProductCode  := oSelf:getProductCode(oCustomer:getCode(), oCustomer:getUnit(), oItem, nil, nil, oQuotation:isRetail())
	
	if (cOption == "diff")
		nSugPrice := oItem:getSugPrice() + ((oItem:getSugPrice() * nValue) / 100)
	elseIf (cOption == "fixed_price")
		nSugPrice := nValue	
	endIf		
	
	oCbcProdVal	:= CbcProductValues():newCbcProductValues(oCustomer:getCode(), oCustomer:getUnit(), cProductCode, cPackage, oItem:getQuantity(), nSugPrice)
	
	oCbcProdVal:setPayTerm(oQuotation:getPaymentCondition())
	oCbcProdVal:setTpFreight(oQuotation:getFreight())
	oCbcProdVal:setRetail(oQuotation:isRetail())
	
	if oUtils:isNotNull(oSeller) .and. !Empty(oSeller:getId())
		oCbcProdVal:setSalesMan(oSeller:getId())
	else
		oUser   := oSrvUser:findById(oQuotation:getIdUser())
		oSeller := oUser:getSeller()
		if oUtils:isNotNull(oSeller)
			oCbcProdVal:setSalesMan(oSeller:getId())
		endIf
	endIf
	
	oCbcProdVal:initCalc()
	
	if oCbcProdVal:lOk
		
		lOk 		   := .T.		
		nSugTotal	   := (oItem:getQuantity() * nSugPrice)
		cSugDiscount   := oCbcProdVal:cCalcDiscRange
		nSugRg		   := if(Empty(oCbcProdVal:nCalcRg), 0, oCbcProdVal:nCalcRg)
		nSugCommission := if(Empty(oCbcProdVal:nCommission), 0, oCbcProdVal:nCommission)	
		
		if (nSugPrice < oItem:getMinPrice())
			nAppPrice		:= 0
			nAppTotal		:= 0
			nAppRg			:= 0
			nAppCommission	:= 0			
			cAppDiscount	:= ""
			cAppAuto		:= "N"
		else
			nAppPrice		:= nSugPrice
			nAppTotal		:= nSugTotal
			nAppRg			:= nSugRg
			nAppCommission	:= nSugCommission		
			cAppDiscount	:= cSugDiscount
			cAppAuto		:= "S"
		endIf	
		
		cUpdate := " ZP6_DIFPRC = 0, "
		cUpdate += " ZP6_PRCSUG = " + AllTrim(Str(nSugPrice)) + ", "
		cUpdate += " ZP6_TOTSUG = " + AllTrim(Str(nSugTotal)) + ", "
		cUpdate += " ZP6_DESSUG = '" + cSugDiscount + "', "
		cUpdate += " ZP6_RGSUG = " + AllTrim(Str(nSugRg)) + ", "
		cUpdate += " ZP6_COMSUG = " + AllTrim(Str(nSugCommission)) + ","
		cUpdate += " ZP6_PRCAPR = " + AllTrim(Str(nAppPrice)) + ", "
		cUpdate += " ZP6_TOTAPR = " + AllTrim(Str(nAppTotal)) + ", "
		cUpdate += " ZP6_DESAPR = '" + cAppDiscount + "', "
		cUpdate += " ZP6_RGAPR = " + AllTrim(Str(nAppRg)) + ", "
		cUpdate += " ZP6_COMAPR = " + AllTrim(Str(nAppCommission)) + ","
		cUpdate += " ZP6_APAUTO = '" + cAppAuto + "' "
		
		oSql:update("ZP6", cUpdate, "%ZP6.XFILIAL% AND ZP6_NUM = '" + oQuotation:getId() + "' AND ZP6_ITEM = '" + oItem:getItem() + "'")					
		
	else
	
		oSelf:cErrorMessage := oCbcProdVal:cMsg
		
	endIf
	
return lOk
