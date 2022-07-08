#include 'protheus.ch'
#include 'parmtype.ch'

user function srvTrfFornece(cFilOri, cTpNF)
	local aFornCli	:= {}
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	
	cQry := u_qryTrfFindCF(cFilOri, cTpNF)
	
	if !empty(cQry)		
		oSql:newAlias(cQry)		
		if oSql:hasRecords()
			oSql:goTop()
			aFornCli := {oSql:getValue("COD"), oSql:getValue("LOJA")}
		endif
		oSql:close()
	endif
	FreeObj(oSql)
return(aFornCli)

user function srvTrfCondPag(cTpNF, cFornCli, cLoja)
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cCond		:= ''
	
	if cTpNF == 'N'
		oSql:newTable("SA2", "A2_COND COND", "A2_COD = '" + cFornCli + "' AND A2_LOJA = '" + cLoja + "'")
	elseif cTpNF == 'B'
		oSql:newTable("SA1", "A1_COND COND", "A1_COD = '" + cFornCli + "' AND A1_LOJA = '" + cLoja + "'")
	endif
	
	if oSql:hasRecords()
		oSql:goTop()
		cCond := oSql:getValue("COND")
	endif
	oSql:close()
	FreeObj(oSql)
return(cCond)

user function srvVldFilTrf(nRec)
	local lVld := .F.
	local oSql := LibSqlObj():newLibSqlObj()
	local cCli := ""
	local cLoja:= ""
	local cTpNF:= ""
	
	oSql:newTable("SF2", "F2_CLIENTE CLI, F2_LOJA LOJA, F2_TIPO TIPO", "R_E_C_N_O_ = " + cValtoChar(nRec))
	if oSql:hasRecords()
		cCli := oSql:getValue("CLI")
		cLoja:= oSql:getValue("LOJA")
		cTpNF:= oSql:getValue("TIPO")
		
		oSql:close()
		FreeObj(oSql)
		
		oSql := LibSqlObj():newLibSqlObj()		
		if cTpNF == 'B'
			oSql:newTable("SA2", "A2_CGC CNPJ", "A2_COD = '" + cCli + "' AND A2_LOJA = '" + cLoja + "'")
		elseif cTpNF == 'N'
			oSql:newTable("SA1", "A1_CGC CNPJ", "A1_COD = '" + cCli + "' AND A1_LOJA = '" + cLoja + "'")
		endif
		if oSql:hasRecords()
			lVld := (FWArrFilAtu()[18] == oSql:getValue("CNPJ"))
		endif
	endif	
return(lVld)
