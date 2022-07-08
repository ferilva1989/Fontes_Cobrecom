#include 'Totvs.ch'

user function srvSucPCF(cOpc)
    local aResults  := {}
    local oSql		:= LibSqlObj():newLibSqlObj()
    local cQry      := ''
    default cOpc    := 'R'

    if cOpc == 'R'
        cQry := qryRecursos()
    elseif cOpc == 'U'
        cQry := qryUsers()
    elseif cOpc == 'P'
        cQry := qryProds()
    endif
    oSql:newAlias(cQry)
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            if cOpc == 'R'
                aAdd(aResults, AllTrim(oSql:getValue("RECURSO")))
            elseif cOpc == 'U'
                aAdd(aResults, {AllTrim(oSql:getValue("CODE")),AllTrim(oSql:getValue("NOME"))})
            elseif cOpc == 'P'
                aAdd(aResults,  AllTrim(oSql:getValue("COD")) + " -> " + AllTrim(oSql:getValue("DESC")))
            endif
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
return(aResults)

user function zArmSucSaldo(cProd)
    local nSaldo    := 0
    local oSql	    := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qrySaldo(cProd))
    if oSql:hasRecords()
        oSql:goTop()
        nSaldo := oSql:getValue("SALDO")
    endif
    oSql:close()
    FreeObj(oSql)
return(nSaldo)

static function qryRecursos()
    local cQry := ""

    cQry += " SELECT rec.Nickname as [RECURSO] "
    cQry += " FROM [PCF_PROD].PCFactory.dbo.TBLResource rec "
    cQry += " WHERE rec.Code NOT IN ('99') "
    cQry += " AND rec.IDCostCenter = " + cValToChar(Val(FwFilial()))
    cQry += " AND rec.FlgEnable IN (1) "
return(cQry)

static function qryUsers()
    local cQry := ""
    cQry += " SELECT usr.Code AS [CODE], "
    cQry += " usr.Name AS [NOME] "
    cQry += " FROM [PCF_PROD].PCFactory.dbo.TBLUser usr "
    cQry += " WHERE usr.IDCostCenter = " + cValToChar(Val(FwFilial()))
    cQry += " AND usr.FlgEnable = 1 "
return(cQry)

static function qryProds()
    local cQry := ""
    cQry += " SELECT SB1.B1_COD AS [COD], "
    cQry += " SB1.B1_DESC AS [DESC] "
    cQry += " FROM " +RetSqlname("SB1")+ " SB1 "
    cQry += " WHERE SB1.B1_TIPO = 'SC' "
    cQry += " AND SB1.B1_MSBLQL = 2 "
    cQry += " AND SB1.D_E_L_E_T_ = '' "
return(cQry)

static function qrySaldo(cProd)
    local cQry := ""
    cQry += " SELECT  "
    cQry += " SUM( "
    cQry += " 	CASE "
    cQry += " 		WHEN ZZ8.ZZ8_ETAPA = '2' "
    cQry += " 			THEN ZZ8.ZZ8_PESO "
    cQry += " 		WHEN ZZ8.ZZ8_ETAPA = '3' "
	cQry += "		    THEN (ZZ8.ZZ8_PESO * -1) " 
    cQry += " 		ELSE 0 "
    cQry += " 	END "
    cQry += " ) AS [SALDO] "
    cQry += " FROM " +RetSqlname("ZZ8")+ " ZZ8 "
    cQry += " WHERE ZZ8.ZZ8_FILIAL = '" + xFilial('ZZ8') + "' "
    cQry += " AND ZZ8.ZZ8_PROD = '" + AllTrim(cProd) + "' "
    cQry += " AND ZZ8.D_E_L_E_T_ = '' "
return(cQry)
