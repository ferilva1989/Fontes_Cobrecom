#include 'protheus.ch'
#include 'Totvs.ch'

user function zgetTESCfop()
    local aArea    	    := GetArea()
    local aAreaSB6 	    := SB6->(GetArea())
    local aAreaSF4 	    := SF4->(GetArea())
    local cCFOP         := ""
    local oSql          := nil

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryTESCfop(B6_TES))
    if oSql:hasRecords()
        oSql:goTop()
        cCFOP := AllTrim(oSql:getValue("CFOP"))
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaSF4)
    RestArea(aAreaSB6)
    RestArea(aArea)
return(cCFOP)

static function qryTESCfop(cTes)
    local cQry := ""
    cQry += " SELECT SF4.F4_CF AS [CFOP] "
    cQry += " FROM " + RetSqlName('SF4') + " SF4 "
    cQry += " WHERE SF4.F4_FILIAL = '' "
    cQry += " AND SF4.F4_CODIGO = '" + cTes + "' "
    cQry += " AND SF4.D_E_L_E_T_ = '' "
return(cQry)
