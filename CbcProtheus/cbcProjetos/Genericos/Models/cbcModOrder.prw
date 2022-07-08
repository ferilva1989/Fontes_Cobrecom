#include 'protheus.ch'


class cbcModOrder FROM cbcUtilsMeth
	data cBranch
	data cOrderNum		//C5_NUM
	data lScreen
	data oIndOrder
	data lIndRules
	data nTxImposto
	data lLookM2
	
	method newcbcModOrder() constructor
	method setOrderToWork()
	method getField()
	method getItmField()
	method getLiberSituation()
	method getSalesTotal()
	method getCustTotal()
	method getRgTotal()
	method getRgItem()
	method getItens()
	method getOrderStatus()
	method getTotCurva()
	method itemCurva()
	method getTotLib()
	method calcRg()
	
endclass


method newcbcModOrder(cOrderNum, lScreen, lIndRules, cBranch) class cbcModOrder
	default cOrderNum := ''
	default lScreen	:= .F.
	default lIndRules	:= .F.
	default cBranch	:= FwFilial()
	::nTxImposto		:= GetNewPar('ZZ_TXIMRGC', 27.50)
	::lLookM2		:= GetNewPar('ZZ_LOOKM2', .T.)
	::newcbcUtilsMeth()
	if empty(cOrderNum)
		::setStatus(.F., 'Numero Pedido obrigatorio!')
	else
		::setOrderToWork(cOrderNum, lScreen, lIndRules, cBranch)
	endif
return ( self )


method setOrderToWork(cOrderNum, lScreen, lIndRules, cBranch) class cbcModOrder
	default cOrderNum 	:= ''
	default lScreen	:= .F.
	default lIndRules	:= .F.
	default cBranch	:= FwFilial()
	
	if empty(cOrderNum)
		::setStatus(.F., 'Numero Pedido obrigatorio!')
	else
		::setStatus()
		if lScreen
			::cOrderNum := SC5->(C5_NUM)
		else
			::cOrderNum := cOrderNum
		endif
		
		if lIndRules
			::oIndOrder := cbcPedido():newcbcPedido(cOrderNum)
		else
			::oIndOrder := nil
		endif
		
		::cBranch 	:= cBranch
		::defFilial(cBranch)
		::lScreen 	:= lScreen
		::lIndRules	:= lIndRules
	endif
return(self)

method getSalesTotal(cOrderNum) class cbcModOrder
	local oSql 		:= nil
	local cQry		:= ''
	local nTotal	:= 0
	local nX		:= 0
	default cOrderNum	:= ::cOrderNum
	
	if !empty(cOrderNum)
		
		if ::lScreen
			for nX := 1 To Len(aCols)
				if !GDDeleted(nX)
					nTotal += ( GDFieldGet("C6_QTDVEN", nX) * GDFieldGet("C6_PRCVEN", nX) )
				endif
			next nX
		else
			oSql := LibSqlObj():newLibSqlObj()
			cQry += " SELECT "
			cQry += " SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) AS [TOTAL] "
			cQry += " FROM  %SC6.SQLNAME% "
			cQry += " WHERE "
			cQry += " SC6.C6_FILIAL 	= '" + FwFilial() + "' "
			cQry += " AND SC6.C6_NUM 	= '" + cOrderNum + "' "
			cQry += " AND %SC6.NOTDEL% "
			cQry += " GROUP BY SC6.C6_NUM "
			oSql:newAlias(cQry)
			
			oSql:GoTop()
			while oSql:notIsEof()
				nTotal := oSql:getValue('TOTAL')
				oSql:skip()
			endDo
			
			oSql:close()
			FreeObj(oSql)
		endif
	endif
return( nTotal )


method getCustTotal(cOrderNum, cTipoCust) class cbcModOrder
	local oSql 			:= nil
	local cQry			:= ''
	local nTotal			:= 0
	local nMoeda			:= 1
	default cOrderNum		:= ::cOrderNum
	default cTipoCust		:= 'HISTORICO'
	
	if empty(cOrderNum)
		
	else
		nMoeda		:= ::getField('C5_MOEDA')
		oSql := LibSqlObj():newLibSqlObj()
		cQry += " SELECT "
		
		if cTipoCust == 'HISTORICO'
			cQry += whoField( self )
		elseif cTipoCust == 'ATUAL'
			if FwFilial() == '01'
				cQry += " SUM(SC6.C6_QTDVEN * SB1.B1_CUSTD) AS [TOTAL] "
			elseIf FwFilial() == '02'
				cQry += " SUM(SC6.C6_QTDVEN * SB1.B1_CUSTD3L) AS [TOTAL] "
			endif
		endif
		
		cQry += " FROM  %SC6.SQLNAME% "
		
		if cTipoCust == 'ATUAL'
			cQry += " INNER JOIN %SB1.SQLNAME% "
			cQry += " ON %SB1.XFILIAL% "
			cQry += " AND SC6.C6_PRODUTO = SB1.B1_COD "
			cQry += " AND SC6.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
		endif
		
		cQry += " WHERE "
		cQry += " SC6.C6_FILIAL 	= '" + FwFilial() + "' "
		cQry += " AND SC6.C6_NUM 	= '" + cOrderNum + "' "
		cQry += " AND %SC6.NOTDEL% "
		cQry += " GROUP BY SC6.C6_NUM "
		
		oSql:newAlias(cQry)
		
		oSql:GoTop()
		while oSql:notIsEof()
			nTotal := oSql:getValue('TOTAL')
			oSql:skip()
		endDo
		
		oSql:close()
		FreeObj(oSql)
	endif
return ( nTotal)


method getRgTotal(cTipoCust) class cbcModOrder
	local nVlrVenda 		:= 0
	local nTxMoeda		:= 1
	local nMoeda			:= 1
	local nVlrCusto		:= 0
	local nRG			:= 0
	default cTipoCust		:= ''
	
	nMoeda		:= ::getField('C5_MOEDA')
	nTxMoeda		:= ::getField('C5_TXMOEDA')
	nVlrVenda 	:= ::getSalesTotal()
	nVlrCusto 	:= ::getCustTotal()
	nRG := ::calcRg((nVlrVenda),(nVlrCusto),nMoeda,nTxMoeda) 
return(nRG)


method getRgItem(cOrderNum, cItem, cTipoCust) class cbcModOrder
	local nRG 			:= 0
	local nQtd			:= 0
	local nPrc			:= 0
	local nCust			:= 0
	local nMoeda			:= 1
	local nTxMoeda		:= 1
	local cCodProd		:= ''
	local cCampo			:= ''
	local oSql 			:= nil
	default cOrderNum		:= ::cOrderNum
	default cItem			:= 0
	default cTipoCust		:= 'HISTORICO'
	
	if !empty(cOrderNum).AND. !empty(cItem)
		nMoeda		:= ::getField('C5_MOEDA')
		nTxMoeda		:= ::getField('C5_TXMOEDA')
		nQtd 		:= ::getItmField('C6_QTDVEN', cItem, cOrderNum)
		nPrc			:= ::getItmField('C6_PRCVEN', cItem, cOrderNum)
		
		if cTipoCust == 'HISTORICO'
			nCust := ::getItmField(whoField(self, .T.), cItem, cOrderNum)
		elseif cTipoCust == 'ATUAL'
			cCodProd	:= ::getItmField('C6_PRODUTO', cItem, cOrderNum)
			if FwFilial() == '01'
				cCampo	:= "B1_CUSTD"
			elseIf FwFilial() == '02'
				cCampo	:= "B1_CUSTD3L"
			endif
			oSql := LibSqlObj():newLibSqlObj()
			nCust := oSql:getFieldValue("SB1", cCampo,;
				"%SB1.XFILIAL% AND B1_COD ='" + cCodProd + "' ")
			oSql:Close()
			FreeObj(oSql)
		endif
		
		nRG := ::calcRg((nQtd*nPrc),(nQtd*nCust),nMoeda,nTxMoeda) 
		
	endif
return(nRG)


method calcRg(nPrc,nCust,nMoeda,nTaxa) class cbcModOrder
	local nRg	:= 0
	if nMoeda <> 1 .and. ::lLookM2
		nPrc 	:= (nPrc * nTaxa)
		nCust 	:= (nCust - ((nCust/100) * ::nTxImposto) )
	endif
	nRG := (((( nPrc ) * 100)/ nCust) - 100)
return(nRg)


method getField(cCampo, cOrderNum) class cbcModOrder
	local xValor		:= ''
	local oSql 		:= nil
	local cTab		:= 'SC5'
	default cCampo 	:= ''
	default cOrderNum	:= ::cOrderNum
	if !empty(cOrderNum)
		if ::lScreen
			xValor := SC5->((cCampo))
		else
			oSql := LibSqlObj():newLibSqlObj()
			nRec := oSql:getFieldValue("SC5", 'R_E_C_N_O_', "%SC5.XFILIAL% AND C5_NUM ='" + cOrderNum + "' " )
			DbSelectArea(cTab)
			(cTab)->(DbGoto(nRec))
			cCmd := cTab + '->(' + cCampo + ')'
			xValor := &cCmd
			oSql:Close()
			FreeObj(oSql)
		endif
	endif
return(xValor)


method getItens(cOrderNum) class cbcModOrder
	local aItens	:= {}
	local cQry	:= ''
	local nX		:= 0
	local oSql	:= nil
	default cOrderNum	:= ::cOrderNum
	
	if !empty(cOrderNum)
		if ::lScreen
			for nX := 1 To Len(aCols)
				if !GDDeleted(nX)
					aadd( aItens, GDFieldGet("C6_ITEM", nX) )
				endif
			next nX
		else
			oSql := LibSqlObj():newLibSqlObj()
			cQry += " SELECT "
			cQry += " C6_ITEM AS [ITEM] "
			cQry += " FROM  %SC6.SQLNAME% "
			cQry += " WHERE "
			cQry += " SC6.C6_FILIAL 	= '" + FwFilial() + "' "
			cQry += " AND SC6.C6_NUM 	= '" + cOrderNum + "' "
			cQry += " AND %SC6.NOTDEL% "
			cQry += " GROUP BY SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_ITEM "
			
			oSql:newAlias(cQry)
			oSql:GoTop()
			while oSql:notIsEof()
				aadd( aItens, oSql:getValue('ITEM') )
				oSql:skip()
			endDo
			oSql:close()
			FreeObj(oSql)
		endif
	endif
return(aItens)


method getItmField(cCampo, cItem, cOrderNum) class cbcModOrder
	local xValor		:= ''
	local oMemo 		:= nil
	local nRec		:= 0
	local cTab		:= 'SC6'
	local cCmd		:= ''
	default cCampo 	:= ''
	default cOrderNum	:= ::cOrderNum
	if !empty(cOrderNum)
		oSql := LibSqlObj():newLibSqlObj()
		nRec := oSql:getFieldValue("SC6", "R_E_C_N_O_",;
			"%SC6.XFILIAL% AND C6_NUM ='" + cOrderNum +  "' AND  C6_ITEM = '" + cItem + "' ")
		
		DbSelectArea(cTab)
		(cTab)->(DbGoto(nRec))
		cCmd := cTab + '->(' + cCampo + ')'
		xValor := &cCmd
		oSql:Close()
		FreeObj(oSql)
	endif
return(xValor)


method getLiberSituation(cOrderNum) class cbcModOrder
	local aRet		:= {.T., 'REGISTRO LIBERADO'}
	local aQry		:= {}
	default cOrderNum	:= ::cOrderNum
	
	if !empty(cOrderNum)
		aadd(aQry,' SELECT ')
		aadd(aQry,'')
		aadd(aQry,' FROM  %SC9.SQLNAME% ' +;
			' WHERE %SC9.XFILIAL% ' +;
			" AND C9_PEDIDO = '" + cOrderNum + "' ")
		aadd(aQry,'')
		aadd(aQry,' AND %SC9.NOTDEL% ')
		
		aQry[02] := ' SC9.C9_BLCRED AS RETORNO '
		aQry[04] := " AND SC9.C9_BLCRED IN ('09')"
		if haveOne(aQry, Self)
			return {.F.,'REJEITADO CREDITO'}
		endif
		
		aQry[04] := " AND SC9.C9_BLCRED IN ('01')"
		if haveOne(aQry, Self)
			return {.F.,'ANALISE CREDITO'}
		endif
		
		aQry[02] := " SC9.C9_BLEST AS RETORNO "
		aQry[04] := " AND SC9.C9_BLEST IN ('02')"
		if haveOne(aQry, Self)
			return {.F.,'EM PRODUÇÂO'}
		endif
	endif
	
return(aRet)


method getOrderStatus(cBranch, cOrderNum) class cbcModOrder
	local cLiberOK	:= ''
	local aLiber		:= {}
	local cRetStatus	:= ''
	default cBranch 	:= ::cBranch
	default cOrderNum := ::cOrderNum
	
	if ( ! empty(::getField('C5_NOTA') ) )
		cRetStatus := 'ENCERRADO'
	elseif empty( cLiberOK := ::getField('C5_LIBEROK'))
		cRetStatus := 'BLOQUEADO VENDAS
	elseif Alltrim(cLiberOK) == 'S'
		if !(aLiber := ::getLiberSituation())[1]
			cRetStatus := aLiber[2]
		else
			if Alltrim(::getField('C5_ZSTATUS')) == '2'
				cRetStatus := 'EM FATURAMENTO'
			else
				cRetStatus := 'EM SEPARAÇÂO'
			endif
		endif
	else
		cRetStatus := 'N/I'
	endif
return(cRetStatus)


method itemCurva(nItem) class cbcModOrder
	local lRet 		:= .F.
	local oCurve 		:= Nil
	local cProduto	:= ''
	local cLocaliz	:= ''
	default nItem		:= 0
	
	if ! empty(nItem)
		oCurve 	:= cbcJsFld():newcbcJsFld()
		cProduto += ::getItmField('C6_PRODUTO', nItem)
		cLocaliz += ::getItmField('C6_ACONDIC', nItem)
		cLocaliz += StrZero( ::getItmField('C6_METRAGE', nItem), 5 )
		lRet 	:= oCurve:isCurve( cProduto,cLocaliz )
		FreeObj(oCurve)
	endif
return(lRet)


method getTotCurva() class cbcModOrder
	local aItens		:= {}
	local nX			:= 0
	local nValorCurva	:= 0
	
	aItens := ::getItens()
	for nX := 1 to len(aItens)
		if  ::itemCurva(aItens[nX])
			nValorCurva += ( ::getItmField('C6_QTDVEN', aItens[nX]) * ::getItmField('C6_PRCVEN', aItens[nX]) )
		endif
	next nX
return(nValorCurva)


method getTotLib() class cbcModOrder
	local nValorLib	:= 0
	
	
return(nValorLib)



static function haveOne(aQry, oSelf)
	local oSql 		:= nil
	local lRet		:= .F.
	local cQryFinal	:= ''
	default aQry		:= {}
	
	if empty(aQry) .or. (Len(aQry) <> 5)
		oSelf:setStatus(.F., '[ERRO] - cbcModOrder - Query inválida. ')
	else
		oSql := LibSqlObj():newLibSqlObj()
		cQryFinal := aQry[1] + aQry[2] + aQry[3] + aQry[4] + aQry[5]
		oSql:newAlias(cQryFinal)
		lRet := oSql:hasRecords()
		oSql:close()
	endif
	
return(lRet)


static function whoField( oSelf, lOnlyFld )
	local nX 			:= 0
	local cRet			:= ''
	local nItns 		:= {}
	default lOnlyFld	:= .F.
	
	nItns := oSelf:getItens()
	for nX := 1 to Len(nItns)
		if ( oSelf:getItmField('C6_CSTUNRG', nItns[nX]) = 0 )
			
			if lOnlyFld
				cRet := 'C6_LUCROBR'
			else
				if oSelf:getItmField('C6_LUCROBR', nItns[nX]) = 0
					cRet := "SUM(SC6.C6_LUCROBR) AS [TOTAL]"
				else
					cRet := "SUM(SC6.C6_QTDVEN * (SC6.C6_PRCVEN /((SC6.C6_LUCROBR/100)+1))) AS [TOTAL]"
				endif
			endif
		endif
	next nX
	if empty(cRet)
		if lOnlyFld
			cRet := "C6_CSTUNRG"
		else
			cRet := " SUM(SC6.C6_QTDVEN * SC6.C6_CSTUNRG)	 AS [TOTAL]"
		endif
	endif
return(cRet)



/* TEST ZONE */
user function zModOrder(cNum) //U_zModOrder('203381')
	local nX 		:= 0
	local cProd 	:= ''
	local cRgItm	:= ''
	local nRgTotal	:= 0
	local nCusto	:= 0
	
	/* Inicializar a classe */
	local oPed := cbcModOrder():newcbcModOrder(cNum)
	
	// Chamada avulsa (Generica) para calcular RG
	// oPed:calcRg(nPrc,nCust,nMoeda,nTaxa)
	
	/* Obter o status do pedido */
	local cStatus := oPed:getOrderStatus( /*cBranch, cOrderNum*/ )
	
	/* Valor total do pedido */
	local nVlrTotVenda := oPed:getSalesTotal(/*cOrderNum*/)
	
	
	/* Obter o conteudo de qualquer campo */
	local cTipo := oPed:getField('C5_TIPO', /*cOrderNum*/ )
	
	
	/* Obter campo do item 01 */
	local cProdItm := oPed:getItmField('C6_PRODUTO', '01', /*cOrderNum*/)
	
	
	/* Obter um array com os numeros dos itens usado no loop */
	local aArrIt := oPed:getItens(/*cOrderNum*/)
	
	
	/* Obter o conteudo em loop */
	for nX := 1 to len(aArrIt)
		cProd := oPed:getItmField('C6_PRODUTO', aArrIt[nX], /*cOrderNum*/)
	next nX
	
	
	/* Valor total de custo pedido */
	nCusto := oPed:getCustTotal( /*cOrderNum*/, /*'HISTORICO' OU 'ATUAL',DEFAULT HISTORICO*/)
	
	/* Obter o rg total do pedido */
	nRgTotal := oPed:getRgTotal(/*cOrderNum*/, /*'HISTORICO' OU 'ATUAL',DEFAULT HISTORICO*/)
	
	
	/* Obter o rg do item 01, pode ser utilizado no loop*/
	cRgItm := oPed:getRgItem(/*cOrderNum*/, '01',/*'HISTORICO' OU 'ATUAL',DEFAULT HISTORICO*/)
	
	/* Caso Precise trocar a filial */
	oPed:defFilial('01')
	
	
	FreeObj(oPed)
	
	/* FUNCIONALIDADE PARA TRABALHAR COM TELAS ANTES DE GRAVAR */
	
	/* Inicializar a classe sinalizando trabalho com tela */
	oPed := cbcModOrder():newcbcModOrder(cNum, .T. )
	
	/* Obter o valor total do pedido */
	nVlrTotVenda := oPed:getSalesTotal()
	
	/* Obter o conteudo de qualquer campo */
	cTipo := oPed:getField('C5_TIPO')
	
	/* Obter o campo de um item */
	cProdItm := oPed:getItmField('C6_PRODUTO', '01')
	
	/* Obter array com o  numero dos itens */
	aArrIt := oPed:getItens()
	
	
	FreeObj(oPed)
return()


user function zStrsOrd() // U_zStrsOrd()
	
	local oPed 	:= nil
	local cStatus := nil
	local oSql	:= nil
	local cQry	:= ''
	local aStatus	:= {}
	
	Local cDir    := "\saidaSTATUS\"
	Local cArq    := "STATUS_"+DtoS(Date())+"_"+StrTran(Left(Time(),5),":","")+".csv"
	Local nHandle := FCreate(cDir+cArq)
	
	cQry += " SELECT "
	cQry += " SC5.C5_FILIAL AS FILIAL, "
	cQry += " SC5.C5_NUM AS PEDIDO "
	cQry += " FROM  %SC5.SQLNAME% "
	cQry += " WHERE SC5.C5_FILIAL IN ('','01','02') "
	cQry += " AND %SC5.NOTDEL% "
	
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	If nHandle > 0
		if oSql:hasRecords()
			FWrite(nHandle, 'FILIAL;PEDIDO;STATUS' )
			oSql:goTop()
			while oSql:notIsEof()
				oPed := cbcModOrder():newcbcModOrder(  oSql:getValue("PEDIDO"), , ,oSql:getValue("FILIAL"), )
				FWrite(nHandle, oSql:getValue("FILIAL") + ';' + oSql:getValue("PEDIDO") + ';' + oPed:getOrderStatus() +  Chr(13)+Chr(10) )
				FreeObj(oPed)
				oSql:skip()
			endDo
			oSql:close()
			
			FClose(nHandle)
		endif
	endif
	FreeObj(oSql)
	
	Alert('PARADA')
	
return(nil)


user function zRgOrder(cFil,cPedido) // u_zRgOrder(,'203382')
	local oPed	:= nil
	local cMsg	:= ''
	local aArrIt	:= {}
	local nX		:= 0
	local linha	:= chr(13) + chr(10)
	default cFil	:= FwFilial()
	
	oSql := LibSqlObj():newLibSqlObj()
	oPed := cbcModOrder():newcbcModOrder(cPedido, , ,cFil,)
	
	cMsg += 'Status: ' + oPed:getOrderStatus()											+ linha
	cMsg += 'MOEDA: ' 				+ cValToChar(oPed:getField('C5_MOEDA')) 				+ linha
	cMsg += 'TAXA: ' 					+ cValToChar(oPed:getField('C5_TXMOEDA')) 			+ linha
	cMsg += 'Valor Total Curva: ' 		+ cValToChar(oPed:getTotCurva()) 					+ linha
	cMsg += 'Valor Total Pedido: '  	+ cValToChar(Round(oPed:getSalesTotal(),4 )) 		+ linha
	cMsg += 'Custo Total Atual: ' 		+ cValToChar(Round(oPed:getCustTotal(,'ATUAL'),4)) 	+ linha
	cMsg += 'Custo Total Historico: ' 	+ cValToChar(Round(oPed:getCustTotal(,'HISTORICO'),4))+ linha
	cMsg += 'RG Total Atual: ' 		+ cValToChar(Round(oPed:getRgTotal(,'ATUAL'),4))		+ linha
	cMsg += 'RG Total Historico: ' 		+ cValToChar(Round(oPed:getRgTotal(,'HISTORICO'),4))	+ linha
	cMsg += 'RG Por Item: '			+ linha
	
	aArrIt := oPed:getItens()
	for nX := 1 to len(aArrIt)
		cMsg +=  ' Item: ' 			+ cValToChar(aArrIt[nX])
		cMsg +=  ' Produto: ' 			+ cValToChar(oPed:getItmField('C6_PRODUTO', aArrIt[nX]))
		cMsg +=  ' Qtd Vend: ' 		+ cValToChar(oPed:getItmField('C6_QTDVEN', aArrIt[nX]))
		cMsg +=  ' Prc Vend: ' 		+ cValToChar(Round(oPed:getItmField('C6_PRCVEN', aArrIt[nX]),4) )
		cMsg +=  ' Custo: ' 			+ cValToChar(Round(oPed:getItmField('C6_CSTUNRG', aArrIt[nX]),4))
		cMsg +=  ' RG Atual: ' 		+ cValToChar(Round(oPed:getRgItem(, aArrIt[nX],'ATUAL'),4))
		cMsg +=  ' RG Historico ' 		+ cValToChar(Round(oPed:getRgItem(, aArrIt[nX],'HISTORICO'),4))
	next nX
	
	MsgAlert(cMsg)
	FreeObj(oPed)
return(nil)

