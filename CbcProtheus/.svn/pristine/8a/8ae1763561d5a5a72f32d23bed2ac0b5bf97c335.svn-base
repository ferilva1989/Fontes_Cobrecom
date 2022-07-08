#include 'protheus.ch'

//xzCalIat
user function mlGetIAP(aParams)
	local oJson   	as object
	local oResp		as object
	local oSql    	as object
	local aHeader 	as array
	local oRest	 	as object
	local lOk		as logical
	local cJs		as character
	local nX		as numeric
	local nPeso		as numeric
	default aParams := {} //[1] Empresa [2] Filial [3] Pedido
	
	lOk := .F.
	oResp := JsonObject():new()	
	if !empty(aParams)
		 
		aHeader := {}
		oJson := JsonObject():new()
		oSql  := LibSqlObj():newLibSqlObj()
		oSql:newAlias(qry(aParams[3], .F.))
		if oSql:hasRecords()
			oSql:goTop()
			oJson['STATUS'] 	 := oSql:getValue("STATUS")
			oJson['PEDIDO'] 	 := oSql:getValue("PEDIDO")
			oJson['CLIENTE'] 	 := oSql:getValue("CLIENTE")
			oJson['FRETE'] 	 	 := oSql:getValue("FRETE")
			oJson['UF_ENTREGA']  := oSql:getValue("UF_ENTREGA")
			oJson['TOTAL'] 	 	 := oSql:getValue("TOTAL")
			oJson['DESCONTO'] 	 := oSql:getValue("DESCONTO")
			oJson['COND_PAGTO']  := oSql:getValue("COND_PAGTO")
			oJson['CALC_RG'] 	 := oSql:getValue("CALC_RG")
			oJson['PERC_FLEX']   := oSql:getValue("PERC_FLEX")
			oJson['APROVADOR']   := Alltrim(oSql:getValue("APROVADOR"))
			oJson['RESPONSAVEL'] := Alltrim(oSql:getValue("RESPONSAVEL"))
			oJson['COD_VEND'] 	 := oSql:getValue("COD_VEND")
			oJson['DATA']        := DtoC(Date())
			oJson['HORA']        := Time()
			oJson['ITENS']		 := u_cbcQRYexec(qryItm(aParams[3])) 

			aadd(aHeader, 'Content-Type: application/json')
			oRest := FWRest():New(GetNewPar('ZZ_MLINFER', 'http://192.168.1.16:5000'))
			oRest:SetPath('/iat')
			oRest:SetPostParams(EncodeUTF8(oJson:toJson(), "cp1252"))
			if !(oRest:Post(aHeader))
				lOk := .F.
			else
                cJs := strtran(oRest:GetResult(),'"',"")
				cJs := strtran(cJs,"'",'"')
				oResp:fromJson(cJs)
				oResp['TOTAL'] 			:= JsonObject():new()
				oResp['TOTAL']['PROBA'] 	:= 0
				nPeso := 0
				for nX := 1 to len(oResp['RESP'])
					oResp['TOTAL']['PROBA'] += (oResp['RESP'][nX]['IAT']['GERAL'] * oResp['RESP'][nX]['TOTAL'])
					nPeso += oResp['RESP'][nX]['TOTAL']
				next nX
				oResp['TOTAL']['PROBA'] := (oResp['TOTAL']['PROBA'] / nPeso)
				
				lOk := .T.
            endif
		endif

		FreeObj(oJson)
		FreeObj(oSql)
		FreeObj(oRest)

	endif
return {lOk, oResp}




user function mlLiberInfo(aParams)
	local oJson   as object
	local oSql    as object
	local oRest	 as object
	local aHeader as array
	default aParams := {} //[1] Empresa [2] Filial [3] Pedido

	if !empty(aParams)
		RPCSetType(3)  //Nao consome licensas
		RpcSetEnv(aParams[1],aParams[2],,,,GetEnvServer(),{ })

		if !empty(aParams[3]) .AND. GetNewPar('ZZ_MLBDON', .T.)
			aHeader := {}
			oJson := JsonObject():new()
			oSql  := LibSqlObj():newLibSqlObj()
			oSql:newAlias(qry(aParams[3]))
			if oSql:hasRecords()
				oSql:goTop()
				oJson['STATUS'] 	 := oSql:getValue("STATUS")
				oJson['PEDIDO'] 	 := oSql:getValue("PEDIDO")
				oJson['CLIENTE'] 	 := oSql:getValue("CLIENTE")
				oJson['FRETE'] 	 	 := oSql:getValue("FRETE")
				oJson['UF_ENTREGA']  := oSql:getValue("UF_ENTREGA")
				oJson['TOTAL'] 	 	 := oSql:getValue("TOTAL")
				oJson['DESCONTO'] 	 := oSql:getValue("DESCONTO")
				oJson['COND_PAGTO']  := oSql:getValue("COND_PAGTO")
				oJson['CALC_RG'] 	 := oSql:getValue("CALC_RG")
				oJson['PERC_FLEX']   := oSql:getValue("PERC_FLEX")
				oJson['APROVADOR']   := Alltrim(oSql:getValue("APROVADOR"))
				oJson['RESPONSAVEL'] := Alltrim(oSql:getValue("RESPONSAVEL"))
				oJson['COD_VEND'] 	 := oSql:getValue("COD_VEND")
				oJson['DATA']        := DtoC(Date())
				oJson['HORA']        := Time()
				oJson['ITENS']		 := u_cbcQRYexec(qryItm(aParams[3])) 

				aadd(aHeader, 'Content-Type: application/json')
				oRest := FWRest():New(GetNewPar('ZZ_MLBDURL', 'http://192.168.1.16:3120'))
				oRest:SetPath('/posts')
				oRest:SetPostParams(oJson:toJson())
				oRest:Post(aHeader)
			endif
			oSql:close()
			FreeObj(oJson)
			FreeObj(oSql)
			FreeObj(oRest)
		endif
		RpcClearEnv() 
	endif
return(nil)


static function qry(cPed, lAprRej)
	local cQry as character
	default lAprRej := .T.
	cQry := ''
	cQry += " SELECT "
	cQry += " ISNULL(ZP1.ZP1_NOME, 'N/D')  AS APROVADOR, "
	cQry += " ISNULL(ZP1_VEND.ZP1_NOME,'') AS RESPONSAVEL, "  
	cQry += " ISNULL(ZP1_VEND.ZP1_CODVEN,'') AS COD_VEND, " 
	cQry += " CASE WHEN ZP5.ZP5_STATUS = '5' THEN 1 ELSE 0 END AS STATUS, "
	cQry += " ZP5.ZP5_NUM AS PEDIDO, "
	cQry += " 'CLI'+ RTRIM(LTRIM(ZP5.ZP5_CLIENT)) + RTRIM(LTRIM(ZP5.ZP5_LOJA)) AS CLIENTE, "
	cQry += " ZP5.ZP5_FRETE AS FRETE, "
	cQry += " ZP5.ZP5_UFENT AS UF_ENTREGA, "
	cQry += " CASE WHEN ZP5.ZP5_STATUS = '5' THEN SUM(ZP6.ZP6_TOTAPR) ELSE SUM(ZP6.ZP6_TOTSUG) END AS TOTAL,  "
	cQry += " CASE WHEN ZP5.ZP5_STATUS = '5' THEN  "
	cQry += " ((SUM(ZP6.ZP6_PRCTAB * ZP6.ZP6_QUANT ) - SUM(ZP6.ZP6_TOTAPR)) * 100 ) /  "
	cQry += " SUM(ZP6.ZP6_PRCTAB * ZP6.ZP6_QUANT ) "
	cQry += " ELSE  "
	cQry += " ((SUM(ZP6.ZP6_PRCTAB * ZP6.ZP6_QUANT ) - SUM(ZP6.ZP6_TOTSUG)) * 100 ) /  "
	cQry += " SUM(ZP6.ZP6_PRCTAB * ZP6.ZP6_QUANT ) "
	cQry += " END AS DESCONTO, "
	cQry += " AVG(CAST(REPLACE(SE4.E4_ZMEDPAG,'*','') AS FLOAT)) AS COND_PAGTO, "
	cQry += " CASE WHEN ZP5.ZP5_STATUS = '5' THEN "
	cQry += " ((SUM(ZP6.ZP6_TOTAPR * 100) /  SUM(((ZP6.ZP6_TOTAPR * 100) / (ZP6.ZP6_RGAPR + 100)))  ) - 100)  "
	cQry += " ELSE "
	cQry += " ((SUM(ZP6.ZP6_TOTSUG * 100) /  SUM(((ZP6.ZP6_TOTSUG * 100) / (ZP6.ZP6_RGSUG + 100)))  ) - 100) "
	cQry += " END		AS CALC_RG, "
	cQry += " ((SUM(CASE "
	cQry += " WHEN (ZP6.ZP6_NOME + ZP6.ZP6_BITOLA = '11505') THEN ZP6.ZP6_QUANT "
	cQry += " ELSE 0 "
	cQry += " END) / SUM(ZP6.ZP6_QUANT)) * 100) AS PERC_FLEX  "
	cQry += " FROM " + RetSqlName('ZP5')   + " ZP5 "
	cQry += " INNER JOIN " + RetSqlName('ZP6') + " ZP6 ON "
	cQry += " ZP5.ZP5_FILIAL		    = ZP6.ZP6_FILIAL "
	cQry += " AND ZP5.ZP5_NUM		    = ZP6.ZP6_NUM "
	cQry += " AND ZP5.D_E_L_E_T_	    = ZP6.D_E_L_E_T_ "
	cQry += " LEFT JOIN " + RetSqlName('ZP1') + " ZP1 ON "
	cQry += " ZP5.ZP5_FILIAL		    = ZP1.ZP1_FILIAL "
	cQry += " AND ZP5.ZP5_APROVA		= ZP1.ZP1_CODIGO "
	cQry += " AND ZP5.D_E_L_E_T_	    = ZP1.D_E_L_E_T_ "
	cQry += " LEFT JOIN " + RetSqlName('ZP1') + " ZP1_VEND ON "
	cQry += " ZP5.ZP5_FILIAL		    = ZP1_VEND.ZP1_FILIAL "
	cQry += " AND ZP5.ZP5_RESPON		= ZP1_VEND.ZP1_CODIGO "
	cQry += " AND ZP5.D_E_L_E_T_	    = ZP1_VEND.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SE4') + " SE4 ON "
	cQry += " ''						= SE4.E4_FILIAL "
	cQry += " AND ZP5.ZP5_CONDPG		= SE4.E4_CODIGO "
	cQry += " AND ZP5.D_E_L_E_T_		= SE4.D_E_L_E_T_ "
	cQry += " WHERE ZP5.ZP5_NUM         = '" +  cPed  + "' "
	if lAprRej
		cQry += " AND ZP5.ZP5_STATUS        IN ('5','6') "
	endif
	cQry += " AND ZP5.ZP5_UFENT         <> '' "
	cQry += " AND ZP5.D_E_L_E_T_        = '' "
	cQry += " GROUP BY ZP5.ZP5_STATUS, ZP1.ZP1_NOME, ZP1_VEND.ZP1_NOME,ZP1_VEND.ZP1_CODVEN, ZP5.ZP5_NUM, ZP5.ZP5_CONDPG, ZP5.ZP5_UFENT, ZP5.ZP5_FRETE, ZP5.ZP5_CLIENT, ZP5.ZP5_LOJA "
	cQry += " ORDER BY ZP5.ZP5_STATUS, ZP1.ZP1_NOME, ZP1_VEND.ZP1_NOME,ZP1_VEND.ZP1_CODVEN, ZP5.ZP5_NUM, ZP5.ZP5_CONDPG, ZP5.ZP5_UFENT, ZP5.ZP5_FRETE, ZP5.ZP5_CLIENT, ZP5.ZP5_LOJA "
return(cQry)


static function qryItm(cPedido)
	local cQry := ''
	cQry += " SELECT "
	cQry += " (ZP6.ZP6_NOME + ZP6.ZP6_BITOLA)		    AS PRODUTO, "
	cQry += " SZ1.Z1_DESC							    AS FAMILIA_PRODUTO, "
	cQry += " SZ2.Z2_DESC							    AS BITOLA_PRODUTO, "
	cQry += " AVG(ZP6.ZP6_PRCTAB)				        AS PRECO_TABELA, "
	cQry += " AVG(ZP6.ZP6_PRCSUG)					    AS PRECO_SUGERIDO, "
	cQry += " AVG(ZP6.ZP6_PRCAPR)					    AS PRECO_APROVADO, "
	cQry += " AVG(ZP6.ZP6_PRCSUG) - AVG(ZP6_PRCAPR) AS DIF_SUG_APROVADO, "
	cQry += " CASE "
	cQry += " WHEN SUM(ZP6.ZP6_TOTSUG) > 0 "
	cQry += " THEN "
	cQry += "  ((SUM(ZP6.ZP6_TOTSUG * 100) /  SUM(((ZP6.ZP6_TOTSUG * 100) / (ZP6.ZP6_RGSUG + 100)))  ) - 100) "
	cQry += "  ELSE 0 "
	cQry += " END AS RG_SUGERIDO, "
    cQry += " 	CASE "
	cQry += " WHEN SUM(ZP6.ZP6_TOTAPR) > 0 "
	cQry += " THEN "
	cQry += " ((SUM(ZP6.ZP6_TOTAPR * 100) /  SUM(((ZP6.ZP6_TOTAPR * 100) / (ZP6.ZP6_RGAPR + 100)))  ) - 100)  "
	cQry += " ELSE 0 "
	cQry += " END AS RG_APROVADO, "
	cQry += " AVG(ZP6.ZP6_TOTSUG)				        AS TOTAL_SUGERIDO, "
	cQry += " AVG(ZP6.ZP6_TOTAPR)					    AS TOTAL_APROVADO, "
	cQry += " AVG(SB1.B1_PESCOB)					    AS PESO_COBRE, "
	cQry += " SUM(ZP9.ZP9_QUANT * ZP6.ZP6_QTACON)		AS QTD_VENDIDA, "
	cQry += " AVG(SB1.B1_PESCOB) * SUM(ZP9.ZP9_QUANT * ZP6.ZP6_QTACON)	AS TOTAL_COBRE "
	cQry += " FROM "       + RetSqlName('ZP6') + " ZP6 "
	cQry += " INNER JOIN " + RetSqlName('SZ1') + " SZ1 ON '' = SZ1.Z1_FILIAL AND ZP6.ZP6_NOME = SZ1.Z1_COD AND ZP6.D_E_L_E_T_ = SZ1.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SZ2') + " SZ2 ON '' = SZ2.Z2_FILIAL AND ZP6.ZP6_BITOLA = SZ2.Z2_COD AND ZP6.D_E_L_E_T_ = SZ2.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('ZP9') + " ZP9 ON	   ZP6.ZP6_FILIAL = ZP9.ZP9_FILIAL AND ZP6.ZP6_NUM = ZP9.ZP9_NUM AND ZP6.ZP6_ITEM = ZP9.ZP9_ITEM AND ZP6.D_E_L_E_T_ = ZP9.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON '' = SB1.B1_FILIAL AND SB1.B1_COD = ZP9.ZP9_CODPRO AND ZP9.D_E_L_E_T_ = SB1.D_E_L_E_T_  "
	cQry += " WHERE ZP6.ZP6_NUM = '" + cPedido + "'"
	cQry += " AND SZ1.D_E_L_E_T_ = ''
	cQry += " GROUP BY (ZP6.ZP6_NOME + ZP6.ZP6_BITOLA), SZ1.Z1_DESC, SZ2.Z2_DESC, SUBSTRING(SB1.B1_COD, 1,5) "
return(cQry)


/* TEST ZONE */
user function xzCalIat(cOrc)//xzCalIat('189322')
	local aParams := {'01', FwFilial(), ''}
	/*
	oSql  := LibSqlObj():newLibSqlObj()
	oSql:newAlias("SELECT ZP5_NUM AS ORC FROM " + RetSqlName('ZP5') + " WHERE ZP5_STATUS >= '20200101' AND ZP5_STATUS IN ('6') AND D_E_L_E_T_ = '' ")
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aParams[3] := oSql:getValue('ORC')
			u_mlLiberInfo(aParams)
			oSql:skip()
		endDo
		oSql:close() 
	endif
	FreeObj(oSql)
	*/
	local aParams := {'01', FwFilial(),cOrc}
	aResp = u_mlGetIAP(aParams)
	cqry := qryItm(aParams[3])
	if aResp[1]
		MsgInfo( 'IA: ' + cValToChar(aResp[2]['TOTAL']['PROBA']),;
					iif(aResp[2]['TOTAL']['PROBA']>0.5,'APROVADO','REJEITADO') )
	endif
	
return nil
