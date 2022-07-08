#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"

#define MONTHS_BACK  ( GetNewPar("ZZ_MESDASH", 3) - 1)


/*/{Protheus.doc} CbcDashboardService

Serviços referentes ao Dashboard do Portal Cobrecom
    
@author victorhugo
@since 11/10/2017
/*/
class CbcDashboardService from CbcService
	
	method newCbcDashboardService() constructor
	
	method getQuotationStatus()
	method getConfirmedQuotations()	
	method getBillingValue()
	
endClass


/*/{Protheus.doc} newCbcDashboardService

Construtor
    
@author victorhugo
@since 11/10/2017
/*/
method newCbcDashboardService() class CbcDashboardService
return self


/*/{Protheus.doc} getQuotationStatus

Retorna os Status dos Orçamentos em Aberto
	
@author victorhugo
@since 11/10/2017
/*/
method getQuotationStatus(cUserId) class CbcDashboardService
	
	local nI		:= 0
	local nY		:= 0	
	local nScan		:= 0
	local oStatus 	:= nil
	local cStatus	:= ""
	local cQuery  	:= ""
	local cInStatus	:= ""
	local aData   	:= {}
	local aSortData	:= {}
	local aStatus	:= {}
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSql	  	:= LibSqlObj():newLibSqlObj()
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser	 	:= oSrvUser:findById(cUserId)	
	
	aAdd(aStatus, { QUOTATION_STATUS_UNDER_MAINTENANCE, "Em manutenção", "default", "#777", "pencil-square-o" })
	aAdd(aStatus, { QUOTATION_STATUS_WAITING_APPROVAL, "Aguardando aprovação", "warning", "#F3CE85", "clock-o" })
	aAdd(aStatus, { QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL, "Aguard. aprov. técnica", "primary", "#424F63", "cogs" })
	aAdd(aStatus, { QUOTATION_STATUS_APPROVINGLY, "Em aprovação", "primary", "#424F63", "users" })
	aAdd(aStatus, { QUOTATION_STATUS_NOT_APPROVED, "Não aprovado", "danger", "#E87B6C", "thumbs-o-down" })
	aAdd(aStatus, { QUOTATION_STATUS_TECNICAL_REJECT, "Rejeição técnica", "danger", "#E87B6C", "thumbs-o-down" })
	aAdd(aStatus, { QUOTATION_STATUS_WAITING_CONFIRM, "Aguardando confirmação", "info", "#6BAFBD", "clock-o" })
	aAdd(aStatus, { QUOTATION_STATUS_WAITING_PROCESSING, "Aguardando processamento", "warning", "#F3CE85", "clock-o" })
	aAdd(aStatus, { QUOTATION_STATUS_PROCESSING, "Em processamento", "primary", "#424F63", "spinner" })
	aAdd(aStatus, { QUOTATION_STATUS_ERROR_PROCESSING, "Erro de processamento", "danger", "#E87B6C", "exclamation-circle" })
	
	for nI := 1 to Len(aStatus)
		if !Empty(cInStatus)
			cInStatus += ","
		endIf
		cInStatus += "'" + aStatus[nI,1] + "'"
	next nI
	
	cQuery := " SELECT ZP5_STATUS [STATUS], SUM(ZP6_TOTSUG) [VALUE] "
	cQuery += " FROM %ZP6.SQLNAME% "	
	cQuery += " 	INNER JOIN %ZP5.SQLNAME% ON "
	cQuery += "  		ZP5_FILIAL = ZP6_FILIAL AND ZP5_NUM = ZP6_NUM AND %ZP5.NOTDEL% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
	cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
	cQuery += " 		%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
	cQuery += " WHERE %ZP6.XFILIAL% AND ZP5_STATUS IN ( " + cInStatus + " ) AND %ZP6.NOTDEL% "
	
	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())	
		cQuery += " AND ZP5_CLIENT = '"+oUser:getCustomer():getCode()+"' AND ZP5_LOJA = '"+oUser:getCustomer():getUnit()+"' "
	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND ZP1_CODVEN = '"+oUser:getSeller():getId()+"' "
	endIf	
	
	cQuery += " GROUP BY ZP5_STATUS "
	cQuery += " ORDER BY 2 "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
	
		oStatus := WsClassNew("WsCbcQuotationStatus")
		
		oStatus:statusId := oSql:getValue("STATUS")
		oStatus:value 	 := oSql:getValue("VALUE")
		
		nScan := aScan(aStatus, { |x| x[1] == oStatus:statusId })		
		 
		oStatus:description := aStatus[nScan,2]
		oStatus:colorClass 	:= aStatus[nScan,3]
		oStatus:color 		:= aStatus[nScan,4]
		oStatus:icon 		:= aStatus[nScan,5]
		
		setStatusQuantity(@oStatus, oUser)
		setStatusFormatValue(@oStatus)
		
		aAdd(aData, oStatus)
		
		oSql:skip()
	endDo	
	
	oSql:close()
	
	for nI := 1 to Len(aStatus)
		
		cStatus := aStatus[nI,1]
		
		for nY := 1 to Len(aData)
			
			if (aData[nY]:statusId == cStatus)
				aAdd(aSortData, aData[nY])
			endIf
		
		next nY	
		
	next nI 

return aSortData

/**
 * Define a quantidade de um status
 */
static function setStatusQuantity(oStatus, oUser)
	
	local cQuery := ""
	local oSql   := LibSqlObj():newLibSqlObj()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	cQuery := " SELECT COUNT(*) QUANTITY "
	cQuery += " FROM %ZP5.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
	cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
	cQuery += " 		%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
	cQuery += " WHERE %ZP5.XFILIAL% AND ZP5_STATUS = '" + oStatus:statusId + "' AND %ZP5.NOTDEL% "
	
	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())	
		cQuery += " AND ZP5_CLIENT = '"+oUser:getCustomer():getCode()+"' AND ZP5_LOJA = '"+oUser:getCustomer():getUnit()+"' "
	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND ZP1_CODVEN = '"+oUser:getSeller():getId()+"' "
	endIf	
	
	oSql:newAlias(cQuery)
	
	oStatus:quantity := oSql:getValue("QUANTITY")
	
	oSql:close()

return

/**
 * Define o valor formatado
 */
static function setStatusFormatValue(oStatus)

	local nValue := oStatus:value
	
	if (nValue < 1000)		
		nValue := 0
	else
		nValue := (nValue / 1000)
		nValue := Round(nValue, 0)
		if (nValue > 1000)
			nValue := (nValue / 1000)
		endIf
	endIf
	
	oStatus:formatValue := AllTrim(Str(nValue)) 
	
return


/*/{Protheus.doc} getConfirmedQuotations

Retorna os Orçamentos Confirmados
	
@author victorhugo
@since 11/10/2017
/*/
method getConfirmedQuotations(cUserId) class CbcDashboardService
	
	local nI				:= 0
	local dStartDate		:= Date()
	local oConfQuotation 	:= nil
	local cMonth			:= ""
	local cExtMonth			:= ""
	local cYear				:= ""
	local cQuery  			:= ""
	local aData   			:= {}	
	local oUtils			:= LibUtilsObj():newLibUtilsObj()
	local oSql	  			:= LibSqlObj():newLibSqlObj()
	local oSrvUser			:= CbcUserService():newCbcUserService()
	local oUser	 			:= oSrvUser:findById(cUserId)	
	
	for nI := 1 to MONTHS_BACK
		dStartDate := FirstDay(dStartDate) - 1
	next nI
	
	dStartDate := FirstDay(dStartDate)
	
	cQuery := " SELECT YEAR_MONTH, SUM(ZP6_TOTAPR) [VALUE] "
	cQuery += " FROM ( "
	cQuery += " 	SELECT LEFT(ZP5_DTPROC, 6) YEAR_MONTH, ZP6_TOTAPR " 
	cQuery += " 		FROM %ZP6.SQLNAME% "
	cQuery += " 			INNER JOIN %ZP5.SQLNAME% ON "
	cQuery += "  				ZP5_FILIAL = ZP6_FILIAL AND ZP5_NUM = ZP6_NUM AND %ZP5.NOTDEL% "
	cQuery += " 			INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 				%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
	cQuery += " 			INNER JOIN %SA1.SQLNAME% ON "
	cQuery += " 				%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
	cQuery += " 		WHERE %ZP6.XFILIAL% AND ZP5_DTPROC >= '" + DtoS(dStartDate) + "' AND ZP5_STATUS = '" + QUOTATION_STATUS_CONFIRMED + "' AND %ZP6.NOTDEL% "
	
	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())	
		cQuery += " AND ZP5_CLIENT = '"+oUser:getCustomer():getCode()+"' AND ZP5_LOJA = '"+oUser:getCustomer():getUnit()+"' "
	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND ZP1_CODVEN = '"+oUser:getSeller():getId()+"' "
	endIf		
	
	cQuery += " ) AS TMP "
	cQuery += " GROUP BY YEAR_MONTH "
	cQuery += " ORDER BY 1 "	
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oConfQuotation := WsClassNew("WsCbcConfirmedQuotation")
		
		cMonth 		:= oSql:getValue("Right(YEAR_MONTH, 2)")
		cExtMonth 	:= Left(Lower(MesExtenso(Val(cMonth))), 3)
		cYear  		:= oSql:getValue("Left(YEAR_MONTH, 4)")		
		
		oConfQuotation:month 	   := cExtMonth + "-" + cYear
		oConfQuotation:value 	   := oSql:getValue("VALUE")
		oConfQuotation:formatValue := "R$ " + AllTrim(Transform(oConfQuotation:value, "@E 999,999,999.99"))
		
		setMonthQuantity(oSql:getValue("YEAR_MONTH"), @oConfQuotation, oUser)
		
		aAdd(aData, oConfQuotation)
		
		oSql:skip()
	endDo	
	
	oSql:close()
	
return aData

/**
 * Define a quantidade de um mes/ano dos orçamentos confirmados
 */
static function setMonthQuantity(cYearMonth, oConfQuotation, oUser)
	
	local cQuery := ""
	local oSql   := LibSqlObj():newLibSqlObj()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	cQuery := " SELECT COUNT(*) QUANTITY "
	cQuery += " FROM %ZP5.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
	cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
	cQuery += " 		%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
	cQuery += " WHERE %ZP5.XFILIAL% AND LEFT(ZP5_DTPROC, 6) = '" + cYearMonth + "' AND ZP5_STATUS = '" + QUOTATION_STATUS_CONFIRMED + "' AND %ZP5.NOTDEL% "
	
	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())	
		cQuery += " AND ZP5_CLIENT = '"+oUser:getCustomer():getCode()+"' AND ZP5_LOJA = '"+oUser:getCustomer():getUnit()+"' "
	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND ZP1_CODVEN = '"+oUser:getSeller():getId()+"' "
	endIf
	
	oSql:newAlias(cQuery)
	
	oConfQuotation:quantity := oSql:getValue("QUANTITY")
	
	oSql:close()

return


/*/{Protheus.doc} getBillingValue

Retorna os Totais de Faturamento por Mês/Ano
	
@author victorhugo
@since 11/10/2017
/*/
method getBillingValue(cUserId) class CbcDashboardService
	
	local nI				:= 0
	local dStartDate		:= Date()
	local oBillingValue 	:= nil
	local cMonth			:= ""
	local cExtMonth			:= ""
	local cYear				:= ""
	local cQuery  			:= ""
	local aData   			:= {}	
	local oUtils			:= LibUtilsObj():newLibUtilsObj()
	local oSql	  			:= LibSqlObj():newLibSqlObj()
	local oSrvUser			:= CbcUserService():newCbcUserService()
	local oUser	 			:= oSrvUser:findById(cUserId)	
	
	for nI := 1 to MONTHS_BACK
		dStartDate := FirstDay(dStartDate) - 1
	next nI
	
	dStartDate := FirstDay(dStartDate)
	
	cQuery := " SELECT YEAR_MONTH, SUM(D2_TOTAL) [VALUE] "
	cQuery += " FROM ( "
	cQuery += " 	SELECT LEFT(D2_EMISSAO, 6) YEAR_MONTH, D2_TOTAL "
	cQuery += " 	FROM %SD2.SQLNAME% "
	cQuery += " 		INNER JOIN %SF2.SQLNAME% ON "
	cQuery += "  			F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND "
	cQuery += " 			F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_TIPO = 'N' AND %SF2.NOTDEL% "	
	cQuery += " 		INNER JOIN %SF4.SQLNAME% ON "
	cQuery += "  			%SF4.XFILIAL% AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND %SF4.NOTDEL% "
	cQuery += " 		INNER JOIN %SA1.SQLNAME% ON "
	cQuery += "  			%SA1.XFILIAL% AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1_VISVEND != 'N' AND %SA1.NOTDEL% "
	cQuery += " 	WHERE D2_FILIAL IN ('01', '02', '03') AND D2_EMISSAO >= '" + DtoS(dStartDate) + "' AND D2_SERIE = '1' AND %SD2.NOTDEL% "	
	
	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())	
		cQuery += " AND F2_CLIENTE = '"+oUser:getCustomer():getCode()+"' AND F2_LOJA = '"+oUser:getCustomer():getUnit()+"' "
	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND F2_VEND1 = '"+oUser:getSeller():getId()+"' "
	endIf		
	
	cQuery += " ) AS TMP "
	cQuery += " GROUP BY YEAR_MONTH "
	cQuery += " ORDER BY 1 "	
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oBillingValue := WsClassNew("WsCbcBillingValue")
		
		cMonth 		:= oSql:getValue("Right(YEAR_MONTH, 2)")
		cExtMonth 	:= Left(Lower(MesExtenso(Val(cMonth))), 3)
		cYear  		:= oSql:getValue("Left(YEAR_MONTH, 4)")		
		
		oBillingValue:month 	   := cExtMonth + "-" + cYear
		oBillingValue:value 	   := oSql:getValue("VALUE")
		oBillingValue:formatValue  := "R$ " + AllTrim(Transform(oBillingValue:value, "@E 999,999,999.99"))
		
		aAdd(aData, oBillingValue)
		
		oSql:skip()
	endDo	
	
	oSql:close()

return aData

