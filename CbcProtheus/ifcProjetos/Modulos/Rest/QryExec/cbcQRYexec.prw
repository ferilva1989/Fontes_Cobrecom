#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYexec(cQry)
	local oSql 		:= nil
	local cAls		:= ''
	local nFld		:= 0
	local nX		:= 0
	local aFlds		:= {}
	local oJsnItm 	:= nil
	local oJsnMain 	:= JsonObject():new()
	local cTipo		:= ''
	local aJson		:= {}
	default cQry	:= ''
	if !empty(cQry)
		oSql := LibSqlObj():newLibSqlObj()
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			cAls := oSql:getAlias()
			nFld := (cAls)->(FCount())
			for nX := 1 to nFld
				aadd(aFlds,(cAls)->(FieldName(nX)))
			next nX
			oSql:goTop()
			while oSql:notIsEof()
				oJsnItm := JsonObject():new()
				for nX := 1 to len(aFlds)
				 	cTipo 	:= ValType(oSql:getValue(aFlds[nX])) 
				 	oJsnItm[aFlds[nX]] := formatValue(oSql:getValue(aFlds[nX]), cTipo)
				next nX
				aadd(aJson, oJsnItm) 
				oSql:skip()
			endDo
			if !empty(aJson)
				oJsnMain['data' ] := aJson
			endif
		endif	
		oSql:close()
		FreeObj(oSql)
	endif
return(oJsnMain)


static function formatValue(xFrmVal, cTipo)
local xValue := ''
	if cTipo == 'C'
		xValue := Alltrim(xFrmVal)
	else
		xValue := xFrmVal
	endif
return(xValue)
