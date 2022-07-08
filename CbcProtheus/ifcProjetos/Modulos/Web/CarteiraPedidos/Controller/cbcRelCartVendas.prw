#include 'protheus.ch'


class cbcRelCartVendas 
	data oRefHeader
	data oPedidos
	data totRepre
	method prepData()
	method prepTotal()
	method fimTotal()
	method newcbcRelCartVendas() constructor 
endclass


method newcbcRelCartVendas() class cbcRelCartVendas
return(self)


method prepData() class cbcRelCartVendas
	local oSql			:= nil
	local oJson			:= nil
	local oPed			:= nil
	local aRefHeader	:= {}
	local cPicMoney 	:= PesqPict("SC5", "C5_TOTAL")
	local nSalesTotal	:= 0

	::oPedidos 			:= {}
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cbcQryCartVend())

	if oSql:hasRecords()
		aadd(aRefHeader, {'Representante,','Repres'	,'left'})
		aadd(aRefHeader, {'Filial'		,'Fil'		,'left'})
		aadd(aRefHeader, {'Segmento'	,'Seg'		,'left'})
		aadd(aRefHeader, {'Cliente'		,'Cli'		,'left'})
		aadd(aRefHeader, {'Pedido'		,'Ped'		,'left'})
		aadd(aRefHeader, {'Emissao'		,'Emiss'	,'center'})
		aadd(aRefHeader, {'Entrega'		,'DtProd'	,'center'})
		aadd(aRefHeader, {'Status'		,'Status'	,'left'})
		aadd(aRefHeader, {'Saldo'		,'Saldo'	,'left'})
		aadd(aRefHeader, {'Total'		,'R$'		,'right'})
		aadd(aRefHeader, {'RG'			,'RG'		,'right'})

		::oRefHeader 	:= prepHeader(aRefHeader) 
		::totRepre		:= {}
		oSql:goTop()
		while oSql:notIsEof()
			oPed  		:= cbcModOrder():newcbcModOrder(oSql:getValue('PEDIDO'),,,oSql:getValue('FILIAL'),)
			oJson 		:= JsonObject():new()

			nSalesTotal	:= oPed:getSalesTotal()
			cRepresID 	:= FwNoAccent(oSql:getValue('Alltrim(REPRESENTANTE)'))
			::prepTotal(cRepresID, nSalesTotal, oPed)

			oJson['Filial'] 		:= oSql:getValue('FILIAL')
			oJson['Pedido'] 		:= oSql:getValue('PEDIDO')
			oJson['Emissao'] 		:= DtoC(oPed:getField('C5_EMISSAO'))
			oJson['Representante']  := cRepresID
			oJson['Cliente'] 		:= FwNoAccent(oSql:getValue('Alltrim(CLIENTE)'))
			oJson['Segmento'] 		:= FwNoAccent(oSql:getValue('Alltrim(SEGMENTO)'))
			oJson['Status'] 		:= FwNoAccent(oPed:getOrderStatus())
			oJson['Saldo'] 			:= Alltrim(Transform(oSql:getValue('TOTAL'),cPicMoney))
			oJson['Total'] 			:= Alltrim(Transform(nSalesTotal,cPicMoney))
			oJson['Entrega']		:= DtoC(SToD(oSql:getValue('ENTREGA')))
			oJson['RG'] 			:= Alltrim(Transform(oPed:getRgTotal('HISTORICO'),cPicMoney))	
			aadd(::oPedidos, oJson)
			FreeObj(oPed)
			oSql:skip()
		enddo
	endif
	oSql:close()
	FreeObj(oSql)
	::fimTotal(cPicMoney)
return(self)


method fimTotal(cPicMoney) class cbcRelCartVendas
	local nX	:= 0
	for nX := 1 to len(::totRepre)
		::totRepre[nX]['rg'] := Alltrim(Transform((((( ::totRepre[nX]['total'] ) * 100)/ ::totRepre[nX]['custo']) - 100),cPicMoney))
		::totRepre[nX]['custo'] := 0
		::totRepre[nX]['total'] :=  Alltrim(Transform(::totRepre[nX]['total'],cPicMoney))
	next nX
return(self)


method prepTotal(cRepresID, nSalesTotal, oPed) class cbcRelCartVendas
	local nPos		:= 0
	local oSumaryJS	:= nil
	if ( nPos := AScan(::totRepre,{|oRep| oRep:GetJsonText('cod') == cRepresID })) > 0 
		::totRepre[nPos]['total'] += nSalesTotal
		::totRepre[nPos]['custo'] += oPed:getCustTotal(,'HISTORICO')
	else
		oSumaryJS 			:= JsonObject():new()
		oSumaryJS['cod']	:= cRepresID
		oSumaryJS['total']	:= nSalesTotal
		oSumaryJS['rg']		:= 0
		oSumaryJS['custo']	:= oPed:getCustTotal( ,'HISTORICO')
		aadd(::totRepre, oSumaryJS)
	endif
return(self)


static function cbcQryCartVend()
	local cQry		:= ''
	cQry := " SELECT "  
	cQry += " 	SC5.C5_FILIAL 	AS [FILIAL], " 
	cQry += " 	SC5.C5_NUM		AS [PEDIDO], "
	cQry += " 	SA1.A1_NOME 	AS [CLIENTE], "
	cQry += " 	LTRIM(RTRIM(SA3.A3_COD)) + ' - ' + LTRIM(RTRIM(SA3.A3_NOME)) AS [REPRESENTANTE], "
	cQry += " 	SX5.X5_DESCRI 	AS [SEGMENTO], "
	cQry += " 	SC5.C5_ENTREG 	AS [ENTREGA], "
	cQry += " 	SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) AS [TOTAL] "
	cQry += fetFrmWhr()
	cQry += " GROUP BY  "
	cQry += " 	SC5.C5_FILIAL, SC5.C5_NUM, SA1.A1_NOME, LTRIM(RTRIM(SA3.A3_COD)) + ' - ' + LTRIM(RTRIM(SA3.A3_NOME)), SX5.X5_DESCRI, SC5.C5_ENTREG "
	cQry += " ORDER BY  "
	cQry += " 	SC5.C5_FILIAL, "
	cQry += " 	SC5.C5_NUM "
return(cQry)


static function fetFrmWhr()
	local cQry := ''
	cQry += " FROM " + RetSqlName('SC6') + " SC6 WITH (NOLOCK) "
	cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 WITH (NOLOCK) "
	cQry += " 	ON  SC6.C6_FILIAL		= SC5.C5_FILIAL "
	cQry += " 	AND SC6.C6_NUM			= SC5.C5_NUM "
	cQry += " 	AND SC5.R_E_C_N_O_		= SC5.R_E_C_N_O_ "  
	cQry += " 	AND SC6.D_E_L_E_T_		= SC5.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SF4') + " SF4 WITH (NOLOCK) "
	cQry += " 	ON ''					= SF4.F4_FILIAL "
	cQry += " 	AND SC6.C6_TES			= SF4.F4_CODIGO "
	cQry += " 	AND SF4.R_E_C_N_O_		= SF4.R_E_C_N_O_ "
	cQry += " 	AND SC6.D_E_L_E_T_		= SF4.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH (NOLOCK) "
	cQry += " 	ON  ' '					= SB1.B1_FILIAL "
	cQry += " 	AND SC6.C6_PRODUTO		= SB1.B1_COD "
	cQry += " 	AND SB1.R_E_C_N_O_		= SB1.R_E_C_N_O_ "
	cQry += " 	AND SC6.D_E_L_E_T_		= SB1.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 WITH (NOLOCK) "
	cQry += " 	ON ''					= SA1.A1_FILIAL "
	cQry += " 	AND SC5.C5_CLIENTE		= SA1.A1_COD "
	cQry += " 	AND SC5.C5_LOJACLI		= SA1.A1_LOJA "
	cQry += " 	AND SA1.R_E_C_N_O_		= SA1.R_E_C_N_O_ "
	cQry += " 	AND SC5.D_E_L_E_T_		= SA1.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SA3') + " SA3 WITH (NOLOCK) "
	cQry += " 	ON ''					= SA3.A3_FILIAL "
	cQry += " 	AND SC5.C5_VEND1		= SA3.A3_COD "
	cQry += " 	AND SC5.D_E_L_E_T_		= SA3.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SX5') + " SX5 WITH (NOLOCK)
	cQry += " 	ON  SC5.C5_FILIAL	   	= SX5.X5_FILIAL
	cQry += " 	AND 'ZK'				= SX5.X5_TABELA
	cQry += " 	AND SA1.A1_SEGMENT		= SX5.X5_CHAVE
	cQry += " 	AND SA1.D_E_L_E_T_		= SX5.D_E_L_E_T_
	cQry += " WHERE "
	cQry += " 	SC6.C6_FILIAL			IN ('01','02') "
	cQry += " 	AND SC6.C6_CF			NOT IN ('6151','6152','6901','6124','6902') "
	cQry += " 	AND SC6.C6_NOTA			= '' "
	cQry += " 	AND SC6.D_E_L_E_T_		= '' "
	cQry += " 	AND SC5.C5_TIPO			= 'N' "
	cQry += " 	AND SC5.C5_NOTA			= '' "
	cQry += " 	AND SF4.F4_DUPLIC		= 'S' "
	cQry += " 	AND SB1.B1_TIPO			= 'PA' "
	cQry += " 	AND SA1.A1_VISVEND		<> 'N' "
return(cQry)


static function prepHeader(aRefHeader)
	local aJsHeader		:= {}
	local oJsHeader		:= nil
	local nX			:= 0	
	for nX := 1 to len(aRefHeader)
		oJsHeader := JsonObject():new()
		oJsHeader['text']  := aRefHeader[nX,2] 
		oJsHeader['align'] := aRefHeader[nX,3]
		oJsHeader['value'] := aRefHeader[nX,1]
		aadd(aJsHeader,oJsHeader)
	next nX
return(aJsHeader)


/* TEST ZONE*/
