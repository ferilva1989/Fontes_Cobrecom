#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"
#include 'cbcOrdemSep.ch'

static function getQry(cTipo, cOS, cIdCli, nFilter)
    local cQry      := ''
    default cTipo   := 'PRIN'
    default cOS     := ''
    default cIdCli  := ''
    default nFilter := FILTRO_NO

    if cTipo  == 'PRIN'
        cQry += " SELECT "
        cQry += " TEMP.OS			AS [OS],  "
        cQry += " TEMP.SIT			AS [SIT],  "
        cQry += " TEMP.PED			AS [PED],  "
        cQry += " TEMP.SEQ			AS [SEQ],  "
        cQry += " TEMP.TP			AS [TP],  "
        cQry += " TEMP.CLI			AS [CLI], "
        cQry += " TEMP.NOME			AS [NOME], "
        cQry += " SUM(TEMP.PES)		AS [PES], "
        cQry += " TEMP.BLQ			AS [BLQ],  "
        cQry += " TEMP.ENT			AS [ENT],  "
        cQry += " TEMP.FAT			AS [FAT],  "
        cQry += " TEMP.LDO			AS [LDO],  "
        cQry += " TEMP.OBS			AS [OBS] "
        cQry += " FROM ( "
    endif
    cQry += " 		SELECT  "
    if cTipo == 'CLI'
        cQry += " DISTINCT(SA1.A1_COD + SA1.A1_LOJA) AS [CLI] "
    else
        cQry += " 		ZZR.ZZR_OS AS [OS], "
        cQry += " 		CASE "
        cQry += " 			WHEN ZZR.ZZR_DOC <> '' AND ZZR.ZZR_SITUAC = '2' "
        cQry += " 				THEN 'F' "
        cQry += " 			WHEN ZZR.ZZR_DOC <> '' AND ZZR.ZZR_SITUAC = '1' "
        cQry += " 				THEN 'G' "
        cQry += " 		    ELSE ZZR.ZZR_SITUAC "
        cQry += "       END AS [SIT], "
        if cTipo  == 'PRIN'
            cQry += " 		CASE "
            cQry += " 			WHEN ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
            cQry += " 				THEN ZZR.ZZR_PEDIDO "
            cQry += " 			ELSE 'XXXXXX' "
            cQry += " 		END																AS [PED], "
            cQry += " 		CASE "
            cQry += " 			WHEN ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
            cQry += " 				THEN ZZR.ZZR_SEQOS "
            cQry += " 			ELSE 'XX' "
            cQry += " 		END																AS [SEQ], "
        else
            cQry += " 		ZZR.ZZR_PEDIDO AS [PED],"
            cQry += " 		ZZR.ZZR_SEQOS AS [SEQ],"
        endif
        cQry += " 		SC5.C5_TIPO                                                     AS [TP],
        cQry += " 		CASE "
        cQry += " 			WHEN SC5.C5_TIPO IN ('D','B') "
        cQry += " 				THEN SA2.A2_COD + SA2.A2_LOJA"
        cQry += " 		        ELSE SA1.A1_COD + SA1.A1_LOJA"
        cQry += " 		END																AS [CLI], "
        cQry += " 		CASE "
        cQry += " 			WHEN SC5.C5_TIPO IN ('D','B') "
        cQry += " 				THEN RTRIM(LTRIM(SA2.A2_NOME)) "
        cQry += " 		        ELSE RTRIM(LTRIM(SA1.A1_NOME)) "
        cQry += " 		END																AS [NOME], "
        cQry += " 		SUM(ZZR.ZZR_PESPRO)												AS [PES], "
        cQry += " 		CASE "
        cQry += " 			WHEN ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 				THEN SC5.C5_ZZBLVEN "
        cQry += " 			ELSE '' "
        cQry += " 		END																AS [BLQ], "
        cQry += " 		CASE "
        cQry += " 			WHEN ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 				THEN SC5.C5_ENTREG "
        cQry += " 			ELSE '' "
        cQry += " 		END																AS [ENT], "
        cQry += " 		CASE "
        cQry += " 			WHEN ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 				THEN SC5.C5_DTFAT "
        cQry += " 			ELSE '' "
        cQry += " 		END																AS [FAT], "
        cQry += " 		CASE "
        cQry += " 			WHEN ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 				THEN SC5.C5_LAUDO "
        cQry += " 			ELSE '' "
        cQry += " 		END																AS [LDO], "
        cQry += " 		CASE "
        cQry += " 			WHEN ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 				THEN SC5.C5_OBS "
        cQry += " 			ELSE 'AGLUTINADO' "
        cQry += " 		END																AS [OBS] "
    endif
    cQry += " 		FROM " + RetSqlName('ZZR') + " ZZR "
    cQry += " 		INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 								AND ZZR.ZZR_PEDIDO = SC5.C5_NUM "
    cQry += " 								AND ZZR.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
    cQry += " 		LEFT JOIN " + RetSqlName('SA1') + " SA1 ON SC5.C5_CLIENTE = SA1.A1_COD "
    cQry += " 								AND SC5.C5_LOJACLI = SA1.A1_LOJA "
    cQry += " 								AND SC5.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
    cQry += " 		LEFT JOIN " + RetSqlName('SA2') + " SA2 ON SC5.C5_CLIENTE = SA2.A2_COD "
    cQry += " 								AND SC5.C5_LOJACLI = SA2.A2_LOJA "
    cQry += " 								AND SC5.D_E_L_E_T_ = SA2.D_E_L_E_T_ "
    cQry += " 		WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
    cQry += " 		AND ZZR.ZZR_SITUAC NOT IN('" + OS_CANCELADA + "') "
    if cTipo  == 'PRIN'
        if nFilter == FILTRO_PEND
            cQry += " 		AND ZZR.ZZR_SITUAC IN('" + OS_GERADA + "') "
        elseif nFilter == FILTRO_ENV
            cQry += " 		AND ZZR.ZZR_SITUAC IN('" + OS_SEPARANDO + "') "
        endif
        //cQry += " 		AND ZZR.ZZR_SITUAC NOT IN('" + OS_FATURADA + "') "
        //cQry += " 		AND ZZR.ZZR_DOC = '' "
    elseif cTipo  == 'OUT'
        //cQry += " 		AND ZZR.ZZR_SITUAC NOT IN('" + OS_FATURADA + "') "
        //cQry += " 		AND ZZR.ZZR_DOC = '' "
        cQry += " 		AND ZZR.ZZR_SITUAC IN('" + OS_GERADA + "') "
        cQry += " 		AND ZZR.ZZR_OS = ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        if !empty(cIdCli)
            cQry += " 		AND (SA1.A1_COD + SA1.A1_LOJA) = '" + cIdCli + "'"
        endif
    elseif cTipo  == 'IN' .or. cTipo  == 'CLI'
        cQry += " 		AND ZZR.ZZR_OS = '" + AllTrim(cOS) + "' "
    endif
    cQry += " 		AND ZZR.ZZR_SITUAC NOT IN('" + OS_CANCELADA + "') "
    cQry += " 		AND ZZR.D_E_L_E_T_ = '' "
    cQry += " 		AND ZZR.ZZR_OS <> '' "
    cQry += " 		AND ZZR.ZZR_DATA >= '" + DtoS(dDtFrom) + "' "
    if cTipo  <> 'CLI'
        cQry += " 		GROUP BY ZZR.ZZR_OS, ZZR.ZZR_PEDIDO, ZZR.ZZR_SEQOS, SC5.C5_TIPO, SA1.A1_COD, SA2.A2_COD, "
        cQry += "         SA1.A1_LOJA, SA1.A1_NOME, SA2.A2_LOJA, SA2.A2_NOME, SC5.C5_ZZBLVEN, SC5.C5_ENTREG, SC5.C5_DTFAT,  "
        cQry += "         SC5.C5_LAUDO, SC5.C5_OBS, ZZR.ZZR_SITUAC, ZZR.ZZR_DOC "
        if cTipo  == 'PRIN'
            cQry += " ) AS TEMP "
            cQry += " GROUP BY TEMP.OS, TEMP.SIT, TEMP.PED, TEMP.SEQ, TEMP.TP, TEMP.CLI,  "
            cQry += " TEMP.BLQ, TEMP.ENT, TEMP.FAT, TEMP.LDO, TEMP.OBS, TEMP.NOME "
        endif
    endif
return(cQry)

static function qrySelected(cTbl, cFld, cMark)
    local cQry := ''

    cQry += " SELECT TEMP.R_E_C_N_O_ AS [REC], "
    cQry += " TEMP.OS AS [OS], "
    cQry += " TEMP.PED AS [PED], "
    cQry += " TEMP.SEQ AS [SEQ] "
    cQry += " FROM " + cTbl + " TEMP "
    cQry += " WHERE TEMP." + cFld + " = '" + cMark + "' "
    cQry += " AND TEMP.D_E_L_E_T_ = '' "
return(cQry)

static function qryInfoJoin(cOs, cTab)
    local cQry      := ''

    cQry += " SELECT "
    cQry += " COUNT(TEMP.OS) AS [QTD],
    cQry += " SUM(TEMP.PES) AS [PES] "
    cQry += " FROM " + cTab + " TEMP "
    cQry += " WHERE TEMP.OS = '" + cOs + "' "
    cQry += " AND TEMP.D_E_L_E_T_ = '' "
    cQry += " GROUP BY TEMP.OS "
return(cQry)

static function qryJoinSelected(cTab, cFld, cMarca)
    local cQry      := ''

    cQry += " SELECT "
    cQry += " TEMP.OS AS [OS], "
    cQry += " TEMP.PED AS [PED], "
    cQry += " TEMP.SEQ AS [SEQ] "
    cQry += " FROM " + cTab + " TEMP "
    cQry += " WHERE TEMP." + cFld + " = '" + cMarca + "' "
    cQry += " AND TEMP.D_E_L_E_T_ = '' "
return(cQry)

static function qryInUse(cOS, lOnlyPed)
    local cQry      := ''
    default cOS     := ''
    default lOnlyPed:= .F.

    if !empty(cOS)
        cQry += " SELECT ZZR.R_E_C_N_O_ AS [REC] "
        cQry += " FROM " + RetSqlName('ZZR') + " ZZR "
        cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
        if lOnlyPed
            cQry += " AND ZZR.ZZR_PEDIDO = '" + cOS + "' "
        else
            cQry += " AND ZZR.ZZR_OS = '" + cOS + "' "
        endif
        cQry += " AND ZZR.ZZR_SITUAC NOT IN ('"+ OS_GERADA +"','"+ OS_FATURADA +"','"+ OS_CANCELADA +"') "
        cQry += " AND ZZR.ZZR_DOC = '' "
        cQry += " AND ZZR.D_E_L_E_T_ = '' "
    endif
return(cQry)

static function qryGetOSData(cOS, cPedSeq, lNoFat)
    local cQry      := ''
    default cOS     := ''
    default lNoFat  := .T.
    default cPedSeq := ''

    if !empty(cOS)
        cQry += " SELECT ZZR.R_E_C_N_O_ AS [REC], "
        cQry += " ZZR.ZZR_PRODUT AS [COD], "
        cQry += " ZZR.ZZR_DESCRI AS [DESCRI], "
        cQry += " ZZR.ZZR_QUAN AS [QUANT], "
        cQry += " ZZR.ZZR_LOCALI AS [ACONDIC], "
        cQry += " ZZR.ZZR_LOCAL AS [LOCAL], "
        cQry += " ZZR.ZZR_LANCES AS [LANCES], "
        cQry += " ZZR.ZZR_BARINT AS [BARINT], "
        cQry += " ZZR.ZZR_NROBOB AS [NROBOB] "
        cQry += " FROM " + RetSqlName('ZZR') + " ZZR "
        cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
        cQry += " AND ZZR.ZZR_OS = '" + cOS + "' "
        if !empty(cPedSeq)
            cQry += " AND ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS = '" + cPedSeq + "' "
        endif
        if lNoFat
            cQry += " AND ZZR.ZZR_DOC = '' "
        endif
        cQry += " AND ZZR.D_E_L_E_T_ = '' "
    endif
return(cQry)

static function qryIsJoined(cOS)
    local cQry      := ''
    default cOS     := ''

    cQry += " SELECT ZZR.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
    cQry += " AND ZZR.ZZR_OS = '" + cOS + "' "
    cQry += " AND ZZR.ZZR_PEDIDO+ZZR.ZZR_SEQOS <> ZZR.ZZR_OS "
    cQry += " AND ZZR.D_E_L_E_T_ = '' "

return(cQry)
