#include 'protheus.ch'

user function cbcDataDiff(dMyData, nDay, lSum)
	local nX		:= 0
	default lSum	:= .T.
	default nDay	:= 1

	for nX := 1 to nDay
		if lSum
			dMyData := DaySum(dMyData, 1)
		else
			dMyData := DaySub(dMyData, 1)
		endif
		dMyData := u_cbcDataVld(dMyData, lSum)
	next nX
return(dMyData)

user function cbcDataVld(dMyData, lNextDay)
	default dMyData	:= Date()
    default lNextDay:= .T.
	
	dMyData := Datavalida(dMyData, lNextDay)

	while !empty(cbcDayOff(dMyData))
		if lNextDay
			dMyData := DaySum(dMyData, 1)
		else
			dMyData := DaySub(dMyData, 1)
		endif
		dMyData := Datavalida(dMyData, lNextDay)		
	endDo
return(dMyData)

static function cbcDayOff(dDayIni, dDayFim)
	local aArea		:= GetArea()
	local aDayOff 	:= {}
	local oSql 		:= nil
	default dDayFim	:= dDayIni
	
	oSql 	 := LibSqlObj():newLibSqlObj()
	oSql:newAlias(qryDayOff(DtoS(dDayIni), DtoS(dDayFim)))
	If oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aAdd(aDayOff, StoD(oSql:getValue("DAY_OFF")))
			oSql:skip()
		endDo
	endif
	
	oSql:close()
	FreeObj(oSql)
	RestArea(aArea)
return(aDayOff)

static function qryDayOff(cDayIni, cDayFim)
	local cQry := ''
	cQry += " SELECT SUBSTRING(SX5.X5_DESCRI,1,8) AS [DAY_OFF] "
	cQry += " FROM " + retSqlName('SX5') + " SX5 "
	cQry += " WHERE SX5.X5_FILIAL = '" + xFilial('SX5') + "' "
	cQry += " AND SX5.X5_TABELA = 'ZV' "
	cQry += " AND SUBSTRING(SX5.X5_DESCRI,1,8) >= '" + cDayIni + "'"
	cQry += " AND SUBSTRING(SX5.X5_DESCRI,1,8) <= '" + cDayFim + "'"
	cQry += " AND SX5.D_E_L_E_T_ = '' "
return(cQry)
