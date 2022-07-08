#include 'protheus.ch'

static function qryIniForm(cKey)
    local cQry      := ''
    default cKey    := ''

    cQry += " SELECT SUBSTRING(SM4.M4_DESCR,1,2) AS [FILIAL], "
    cQry += " SUBSTRING(SM4.M4_DESCR,4, LEN(SM4.M4_DESCR)) AS [KEY], "
    cQry += " SM4.M4_FORMULA AS [FORMULA], "
    cQry += " SM4.M4_CODIGO AS [CODIGO], "
    cQry += " SM4.R_E_C_N_O_ AS [REC]"
    cQry += " FROM " + retSqlName('SM4') + " SM4 "
    cQry += " WHERE SM4.M4_FILIAL = '" + xFilial('SM4') + "' "
    if !empty(cKey)
        cQry += " AND ( SM4.M4_DESCR = '00-" + cKey + "' OR SM4.M4_DESCR = '" + FwFilial() + "-" + cKey + "') "
    endif
    cQry += " AND SM4.D_E_L_E_T_ = '' "
return(cQry)