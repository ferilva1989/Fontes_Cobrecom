#include 'protheus.ch'


class cbcCtrCartEstoque 
	data aRefHeader
	data oColumnDef
	data oTotais
	data cTitulo
	data oMainData
	method prepData()
	method prepDetalhe()
	method newcbcCtrCartEstoque() constructor 
endclass


method newcbcCtrCartEstoque() class cbcCtrCartEstoque
return(self)


method prepData(cTpData) class cbcCtrCartEstoque
	local oSql			:= nil
	local oJson			:= nil
	local oPed			:= nil
	::oMainData 			:= {}
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(defQry(cTpData))
	if oSql:hasRecords()
		::oColumnDef := prepColumn(defColumn(cTpData)) 
		::aRefHeader := prepHeader(cTpData)
		::oTotais	 := totalizadores(cTpData)
		oSql:goTop()
		while oSql:notIsEof()
			aadd(::oMainData, prepReg(oSql,cTpData))
			oSql:skip()
		enddo
	endif
	oSql:close()
	FreeObj(oSql)
return(self)


method prepDetalhe(oJsData) class cbcCtrCartEstoque
	local oSql			:= nil
	local oSqlReg		:= nil
	local oJsHead		:= nil
	local aHdr			:= {}
	local cPicValue 	:= PesqPict("SD3", "D3_QUANT")
	local nX			:= ''
	
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(defQry(oJsData['tipo'], oJsData['codigo'] ))
	if oSql:hasRecords()
		oSql:goTop()
		::oMainData 	:= {}
		::aRefHeader 	:= {}
		
		if oJsData['tipo'] == 'EPA'
		    ::cTitulo := oSql:getValue('Alltrim(CODIGO)') + '-' + oSql:getValue('Alltrim(DESCRICAO)') + '- ( ' + oJsData['tipo'] + ' )'
		    aHdr := {'Filial', 'Acond', 'Disponivel' }
		elseif oJsData['tipo'] == 'BOB'
			 ::cTitulo := oSql:getValue('Alltrim(PRODUTO)') + '-' + oSql:getValue('Alltrim(DESCRICAO)') + '- ( ' + oJsData['tipo'] + ' )'
			 aHdr := {'Filial', 'NrBob', 'Disponivel', 'DtInvent' }
		elseif oJsData['tipo'] == 'ESA'
			::cTitulo := StrTran(oSql:getValue('Alltrim(PRODUTO)'),'Q','') + '-' + oSql:getValue('Alltrim(DESCRICAO)') + '- ( ' + oJsData['tipo'] + ' )'
			 aHdr := {'Filial', 'Disponivel' }
		endif
		for nX := 1 to len(aHdr)
			oJsHead := JsonObject():new()
			oJsHead['name'] := aHdr[nX]
			aadd(::aRefHeader, oJsHead)
		next nX
		
		while oSql:notIsEof()
			oJsReg := JsonObject():new()
			if oJsData['tipo'] == 'EPA'
				oJsReg['Filial']	:=  oSql:getValue('FILIAL')	
				oJsReg['Acond']		:=	oSql:getValue('Alltrim(ACONDICIONAMENTO)')
				oJsReg['Disponivel']:=	Transform(oSql:getValue('SALDO_DISPONIVEL'), cPicValue)
			elseif oJsData['tipo'] == 'BOB'
				oJsReg['Filial']		:= oSql:getValue('FILIAL')	
				oJsReg['NrBob']			:= oSql:getValue('Alltrim(NRO_BOBINA)')
				oJsReg['Disponivel']	:= Transform(oSql:getValue('QUANTIDADE'), cPicValue)
				oJsReg['DtInvent']		:= DtoC(SToD(oSql:getValue('INVENTARIO')))
			elseif oJsData['tipo'] == 'ESA'
				oJsReg['Filial']		:= oSql:getValue('FILIAL')
				oJsReg['Disponivel']	:= Transform(oSql:getValue('ESA_DISPONIVEL'), cPicValue)	
			endif
			aadd(::oMainData, oJsReg)
			oSql:skip()
		enddo
	endif
	oSql:close()
	FreeObj(oSql)
return(self)


static function defQry(cTpData, cParam)
	local cQry		:= ''
	default cParam	:= ''
	if cTpData == 'EPA'
		cQry := u_cbcQrEpaEstoque(cParam)
	elseif cTpData == 'BOB'
		cQry := u_cbcQrBobEstoque(cParam)
	elseif cTpData == 'ESA'
		cQry := u_cbcQrEsaEstoque(cParam)
	elseif cTpData == 'CART'
		cQry := u_cbcQrCartPedido(cParam)
	endif
return(cQry)


static function prepReg(oSql, cTpData)
	local cPicValue 	:= PesqPict("SD3", "D3_QUANT")
	local oJson := JsonObject():new()
	if cTpData == 'EPA'
		oJson['Filial']  	:= oSql:getValue('FILIAL')
		oJson['Codigo']  	:= oSql:getValue('Alltrim(CODIGO)')
		oJson['Descricao']  := FwNoAccent(oSql:getValue('Alltrim(DESCRICAO)'))
		oJson['Acond']  	:= oSql:getValue('Alltrim(ACONDICIONAMENTO)')
		oJson['Estoque']  	:= Transform(oSql:getValue('ESTOQUE'), cPicValue)
		oJson['Carteira']  	:= Transform(oSql:getValue('CARTEIRA'), cPicValue)
		oJson['Disponivel'] := Transform(oSql:getValue('SALDO_DISPONIVEL'), cPicValue)
	elseif cTpData == 'BOB'
		oJson['Filial']  	:= oSql:getValue('FILIAL')
		oJson['NroBobina']  := oSql:getValue('NRO_BOBINA')
		oJson['Codigo']  	:= oSql:getValue('Alltrim(PRODUTO)')
		oJson['Descricao']  := oSql:getValue('Alltrim(DESCRICAO)')
		oJson['Disponivel'] := Transform(oSql:getValue('QUANTIDADE'), cPicValue)
		oJson['DtBob']  	:= DtoC(SToD(oSql:getValue('DATA')))
		oJson['Pedido']  	:= oSql:getValue('PEDIDO')
		oJson['Cliente']  	:= oSql:getValue('Alltrim(CLIENTE)')
		oJson['BobOrig']  	:= oSql:getValue('BOB_ORI')
		oJson['DtInvent']  	:= DtoC(SToD(oSql:getValue('INVENTARIO')))
	elseif cTpData == 'ESA'
		oJson['Filial']		:= oSql:getValue('FILIAL')
		oJson['Codigo']		:= oSql:getValue('Alltrim(PRODUTO)')	
		oJson['Descricao']	:= oSql:getValue('Alltrim(DESCRICAO)')	
		oJson['Disponivel']	:= Transform(oSql:getValue('ESA_DISPONIVEL'), cPicValue)	
		oJson['Total']		:= Transform(oSql:getValue('ESA_TOTAL'), cPicValue)	
		oJson['CartSemEpa']	:= Transform(oSql:getValue('NECESSARIO_CARTEIRA_SEM_EPA'), cPicValue)	
		oJson['BobPed'] 	:= Transform(oSql:getValue('BOB_ESTOQUE'), cPicValue)	
		oJson['BobCart']	:= Transform(oSql:getValue('BOB_CARTEIRA'), cPicValue)	
		oJson['BobSemEpa']	:= Transform(oSql:getValue('BOB_SEM_EPA'), cPicValue)
	elseif cTpData == 'CART'
		oJson['Filial'] 	:= oSql:getValue('FILIAL')
		oJson['DtFat']		:= DtoC(SToD(oSql:getValue('DTFAT')))
		oJson['Pedido']		:= oSql:getValue('Alltrim(PEDIDO)')
		oJson['Emissao']    := DtoC(SToD(oSql:getValue('EMISSAO')))
		oJson['Codigo'] 	:= oSql:getValue('Alltrim(CODIGO)')
		oJson['Descricao']  := oSql:getValue('Alltrim(DESCRICAO)')
		oJson['Acond'] 		:= oSql:getValue('Alltrim(ACONDICIONAMENTO)')
		oJson['Necessario'] := Transform(oSql:getValue('NECESSIDADE'), cPicValue)
	endif
return(oJson)


static function prepHeader(cTpData)
	local aHeader := {}
	if cTpData == 'EPA'
		aadd(aHeader, 'Filial')
		aadd(aHeader, 'Codigo')
		aadd(aHeader, 'Descricao')
		aadd(aHeader, 'Acond')
		aadd(aHeader, 'Estoque')
		aadd(aHeader, 'Carteira')
		aadd(aHeader, 'Disponivel')
	elseif cTpData == 'BOB'
		aadd(aHeader, 'Filial')
		aadd(aHeader, 'Codigo')
		aadd(aHeader, 'Descricao')
		aadd(aHeader, 'Disponivel')
		aadd(aHeader, 'NroBobina')
		aadd(aHeader, 'DtBob')
		aadd(aHeader, 'Pedido')
		aadd(aHeader, 'Cliente')
		aadd(aHeader, 'BobOrig')
		aadd(aHeader, 'DtInvent')
	elseif cTpData == 'ESA'
		aadd(aHeader, 'Filial')
		aadd(aHeader, 'Codigo')	
		aadd(aHeader, 'Descricao')	
		aadd(aHeader, 'Disponivel')	
		aadd(aHeader, 'Total')	
		aadd(aHeader, 'CartSemEpa')	
		aadd(aHeader, 'BobPed')	
		aadd(aHeader, 'BobCart')	
		aadd(aHeader, 'BobSemEpa')
	elseif cTpData == 'CART'
		aadd(aHeader,'Filial')
		aadd(aHeader,'DtFat')
		aadd(aHeader,'Pedido')
		aadd(aHeader,'Emissao')	
		aadd(aHeader,'Codigo')
		aadd(aHeader,'Necessario')
		aadd(aHeader,'Acond')
		aadd(aHeader,'Descricao')
	endif
return (aHeader)


static function totalizadores(cTpData)
	local aTot := {}
	if cTpData == 'EPA'
		aadd(aTot, 'Estoque')
		aadd(aTot, 'Carteira')
		aadd(aTot, 'Disponivel')
	elseif cTpData == 'BOB'
		aadd(aTot, 'Disponivel')
	elseif cTpData == 'ESA'
		aadd(aTot, 'Total')
		aadd(aTot, 'CartSemEpa')
		aadd(aTot, 'Disponivel')
		aadd(aTot, 'BobPed')
		aadd(aTot, 'BobCart')
		aadd(aTot, 'BobSemEpa')
	elseif cTpData == 'CART'
		aadd(aTot,'Necessario')
	endif
return(aTot)


//Horizontal: htLeft, htCenter, htRight, htJustify
static function defColumn(cTpData)
	local aRefColumn	:= {}
	if cTpData == 'EPA'
		aadd(aRefColumn, {'Filial'		, .T.	, 'htLeft'	 , 'text'})
		aadd(aRefColumn, {'Codigo'		, .T.	, 'htLeft'	 , 'text'})
		aadd(aRefColumn, {'Descricao'	, .T.	, 'htJustify', 'text'})
		aadd(aRefColumn, {'Acond'		, .T.	, 'htRight'	 , 'text'})
		aadd(aRefColumn, {'Estoque'		, .T.	, 'htRight'	 ,'numeric'})
		aadd(aRefColumn, {'Carteira'	, .T.	, 'htRight'	 ,'numeric'})
		aadd(aRefColumn, {'Disponivel'	, .T.	, 'htRight'	 ,'numeric'})
	elseif cTpData == 'BOB'
		aadd(aRefColumn, {'Filial'		, .T. , 'htLeft'	, 'text'})
		aadd(aRefColumn, {'Codigo'		, .T. , 'htLeft'	, 'text'})
		aadd(aRefColumn, {'Descricao'	, .T. , 'htJustify'	, 'text'})
		aadd(aRefColumn, {'Disponivel'	, .T. , 'htRight'	, 'numeric'})
		aadd(aRefColumn, {'NroBobina'	, .T. , 'htRight'	, 'text'})
		aadd(aRefColumn, {'DtBob'		, .T. , 'htRight'	, 'date'})
		aadd(aRefColumn, {'Pedido'		, .T. , 'htRight'	, 'text'})
		aadd(aRefColumn, {'Cliente'		, .T. , 'htRight'	, 'text'})
		aadd(aRefColumn, {'BobOrig'		, .T. , 'htRight'	, 'text'})
		aadd(aRefColumn, {'DtInvent'	, .T. , 'htRight'	, 'date'})
	elseif cTpData == 'ESA'	
		aadd(aRefColumn, {'Filial'		, .T. , 'htLeft'	, 'text'})
		aadd(aRefColumn, {'Codigo'		, .T. , 'htLeft'	, 'text'})	
		aadd(aRefColumn, {'Descricao'	, .T. , 'htLeft'	, 'text'})	
		aadd(aRefColumn, {'Disponivel'	, .T. , 'htRight'	, 'numeric'})	
		aadd(aRefColumn, {'Total'		, .T. , 'htRight'	, 'numeric'})	
		aadd(aRefColumn, {'CartSemEpa'	, .T. , 'htRight'	, 'numeric'})	
		aadd(aRefColumn, {'BobPed'		, .T. , 'htRight'	, 'numeric'})	
		aadd(aRefColumn, {'BobCart'		, .T. , 'htRight'	, 'numeric'})	
		aadd(aRefColumn, {'BobSemEpa'	, .T. , 'htRight'	, 'numeric'})
	elseif cTpData == 'CART'
		aadd(aRefColumn, {'Filial'		, .T. , 'htLeft'	, 'text'})
		aadd(aRefColumn, {'DtFat'		, .T. , 'htCenter'	, 'date'})
		aadd(aRefColumn, {'Pedido'		, .T. , 'htCenter'	, 'text'})
		aadd(aRefColumn, {'Emissao'		, .T. , 'htCenter'	, 'date'})	
		aadd(aRefColumn, {'Codigo'		, .T. , 'htLeft'	, 'text'})
		aadd(aRefColumn, {'Necessario'	, .T. , 'htRight'	, 'numeric'})
		aadd(aRefColumn, {'Acond'		, .T. , 'htRight'	, 'text'})
		aadd(aRefColumn, {'Descricao'	, .T. , 'htJustify'	, 'text'})
	endif
return(aRefColumn)


static function prepColumn(aRefHeader)
	local aJsHeader		:= {}
	local oJsHeader		:= nil
	local nX			:= 0	
	for nX := 1 to len(aRefHeader)
		oJsHeader := JsonObject():new()
		oJsHeader['data']  		:= aRefHeader[nX,1] 
		oJsHeader['readOnly'] 	:= aRefHeader[nX,2]
		oJsHeader['className'] 	:= aRefHeader[nX,3]
		oJsHeader['type']		:= aRefHeader[nX,4]
		
		aadd(aJsHeader,oJsHeader)
	next nX
return(aJsHeader)

