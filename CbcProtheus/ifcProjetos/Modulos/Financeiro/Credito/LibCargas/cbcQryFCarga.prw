#include 'protheus.ch'
#include 'parmtype.ch'
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

static function qryView()
    local cQry := ''
    
    cQry += " SELECT TEMP.CARGA AS [CARGA], "
    cQry += " MAX(TEMP.EMISS) AS [EMISS], "
    cQry += " MAX(TEMP.HORA) AS [HORA], "
    cQry += " MAX(TEMP.FIN) AS [FIN], "
    cQry += " SUM(TEMP.APR) AS [APR], "
    cQry += " SUM(TEMP.REJ) AS [REJ], "
    cQry += " SUM(TEMP.OS) AS [OS], "
    cQry += " TEMP.STATUS AS [STATUS] "
    cQry += " FROM ( "
    cQry += " SELECT ZZ9.ZZ9_ORDCAR AS [CARGA], "
    cQry += " ZZ9.ZZ9_DATA AS [EMISS], "
    cQry += " ZZ9.ZZ9_HORA AS [HORA], "
    cQry += " ZZ9.ZZ9_FLGFIN AS [FIN], "
    cQry += " CASE "
    cQry += " WHEN ZZ9.ZZ9_FLGFIN = 'S' "
    cQry += " THEN 1 "
    cQry += " ELSE 0 "
    cQry += " END AS [APR], "
    cQry += " CASE "
    cQry += " WHEN ZZ9.ZZ9_FLGFIN = 'N' "
    cQry += " THEN 1 "
    cQry += " ELSE 0 "
    cQry += " END AS [REJ], "
    cQry += " 1 AS [OS], "
    cQry += " ZZ9.ZZ9_STATUS AS [STATUS] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_STATUS IN ('" + CARGA_FINANCEIRO + "') "
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    cQry += " ) AS TEMP "
    cQry += " GROUP BY TEMP.CARGA, TEMP.STATUS "
return(cQry)

static function qryFlag(cOrdCar, cOper)
    local cQry      := ''
    default cOper   := '='
    
    cQry += " SELECT ZZ9.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '" + cOrdCar + "' "
    cQry += " AND ZZ9.ZZ9_STATUS IN ('" + CARGA_FINANCEIRO + "') "
    cQry += " AND ZZ9.ZZ9_FLGFIN " + cOper + " 'S'"
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
return(cQry)

static function qryGetRec(cCarga, cOS)
    local cQry      := ''
    default cCarga  := ''
    default cOS     := ''

    if !empty(cCarga) .or. !empty(cOS)
        cQry += " SELECT ZZ9.R_E_C_N_O_ AS [REC] "
        cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
        cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
        if !empty(cCarga)
            cQry += " AND ZZ9.ZZ9_ORDCAR = '" + AllTrim(cCarga) + "' "
        endif
        if !empty(cOS)
            cQry += " AND ZZ9.ZZ9_ORDSEP = '" + AllTrim(cOS) + "' "
        endif
        cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    endif
return(cQry)

static function qryGetTotal(cCarga, cOS)
    local cQry      := ''
    default cCarga  := ''
    default cOS     := ''

    if !empty(cCarga) .or. !empty(cOS)
        cQry += " SELECT SUM(ZZR.ZZR_QUAN * SC6.C6_PRCVEN) AS [TOTAL] "
        cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 WITH(NOLOCK) "
        cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR WITH(NOLOCK) ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL "
        cQry += " 					AND ZZ9.ZZ9_ORDSEP	= ZZR.ZZR_OS "
        cQry += " 					AND ZZ9.D_E_L_E_T_	= ZZR.D_E_L_E_T_ "
        cQry += " INNER JOIN " + RetSqlName('SC6') + " SC6 WITH(NOLOCK) ON ZZR.ZZR_FILIAL = SC6.C6_FILIAL "
        cQry += " 					AND ZZR.ZZR_PEDIDO	= SC6.C6_NUM "
        cQry += " 					AND ZZR.ZZR_ITEMPV	= SC6.C6_ITEM "
        cQry += " 					AND ZZR.D_E_L_E_T_	= SC6.D_E_L_E_T_ "
        cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
        if !empty(cCarga)
            cQry += " AND ZZ9.ZZ9_ORDCAR = '" + AllTrim(cCarga) + "' "
        endif
        if !empty(cOS)
            cQry += " AND ZZ9.ZZ9_ORDSEP = '" + AllTrim(cOS) + "' "
        endif
        cQry += " AND ZZR.ZZR_SITUAC <> '" + OS_CANCELADA + "' "
        cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    endif
return(cQry)

static function qryPedObs(cCarga, cOS)
    local cQry := ''
    
    cQry += " SELECT SC5.C5_OBS AS [OBS] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL "
    cQry += "                                           AND ZZ9.ZZ9_ORDSEP = ZZR.ZZR_OS "
    cQry += "                                           AND ZZ9.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 WITH(NOLOCK) ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 					AND ZZR.ZZR_PEDIDO	= SC5.C5_NUM "
    cQry += " 					AND ZZR.D_E_L_E_T_	= SC5.D_E_L_E_T_ "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '" + AllTrim(cCarga) + "'"
    cQry += " AND ZZ9.ZZ9_ORDSEP = '" + AllTrim(cOS) + "'"
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
return(cQry)
