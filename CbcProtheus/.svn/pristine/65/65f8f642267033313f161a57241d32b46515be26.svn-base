#include 'protheus.ch'
#include 'totvs.ch'
#include 'cbcOrdemCar.ch'

static function qryView(cFilter)
    local cQry      := ""
    default cFilter := ""

    cQry += " SELECT TEMP.CARGA AS [CARGA],  "
    cQry += " TEMP.STATUS AS [STATUS], "
    cQry += " MAX(TEMP.AGLUT) AS [AGLUT], "
    cQry += " COUNT(*) AS [NROS] "
    cQry += " FROM( "
    cQry += " SELECT ZZ9.ZZ9_ORDCAR AS [CARGA],  "
    cQry += " ZZ9.ZZ9_STATUS AS [STATUS], "
    cQry += " ZZ9.ZZ9_ORDSEP AS [SEP], "
    cQry += " CASE "
    cQry += " 	WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
    cQry += " 		THEN 'S' "
    cQry += " 	ELSE '' "
    cQry += " END AS [AGLUT] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9  "
    cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL  "
    cQry += "                                         AND ZZ9.ZZ9_ORDSEP = ZZR.ZZR_OS  "
    cQry += "                                         AND ZZ9.D_E_L_E_T_ = ZZR.D_E_L_E_T_  "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "'  "
    if empty(cFilter)
        cQry += " AND ZZ9.ZZ9_STATUS IN ('" + CARGA_LIB_FATUR + "','" + CARGA_FATURADA + "') "
    else
        cQry += " AND ZZ9.ZZ9_STATUS IN ('" + AllTrim(cFilter) + "') "
    endif
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZZ9.ZZ9_ORDCAR, ZZ9.ZZ9_STATUS, ZZ9.ZZ9_ORDSEP,  "
    cQry += " ZZR.ZZR_OS, ZZR.ZZR_PEDIDO, ZZR.ZZR_SEQOS "
    cQry += " ) AS TEMP "
    cQry += " GROUP BY TEMP.CARGA, TEMP.STATUS "
    cQry += " ORDER BY TEMP.CARGA, TEMP.STATUS "
return(cQry)

static function confLib(cOS)
    local cQry := ""
    
    cQry += " SELECT ZZR.ZZR_ITEMPV AS [ITEM], "
    cQry += " SUM(ZZR.ZZR_QUAN) AS [QTD], "
    cQry += " ( "
    cQry += " 	SELECT SUM(SC9.C9_QTDLIB) "
    cQry += " 	FROM " + RetSqlName('SC9') + " SC9 "
    cQry += " 	WHERE SC9.C9_FILIAL = ZZR.ZZR_FILIAL "
    cQry += " 	AND SC9.C9_PEDIDO = ZZR.ZZR_PEDIDO "
    cQry += " 	AND SC9.C9_SEQOS  = ZZR.ZZR_SEQOS "
    cQry += " 	AND SC9.C9_ITEM	  = ZZR.ZZR_ITEMPV "
    cQry += " 	AND SC9.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " 	AND SC9.C9_BLEST = '' "
    cQry += " 	AND SC9.C9_BLCRED = '' "
    cQry += " ) AS [QTD_SC9] "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR      "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial("ZZR") + "'    "
    cQry += " AND ZZR.ZZR_OS = '" + cOS + "'    "
    cQry += " AND ZZR.D_E_L_E_T_ = ''  "
    cQry += " GROUP BY ZZR.ZZR_FILIAL, "
    cQry += " ZZR.ZZR_PEDIDO, "
    cQry += " ZZR.ZZR_SEQOS, "
    cQry += " ZZR.ZZR_ITEMPV, "
    cQry += " ZZR.D_E_L_E_T_ "
return(cQry)

static function qryPedSeq(cOS)
    local cQry := ""
    
    cQry += " SELECT ZZR.ZZR_PEDIDO AS [PEDIDO],   "
    cQry += " ZZR.ZZR_ITEMPV AS [ITEM],   "
    cQry += " ZZR.ZZR_SEQOS AS [SEQ],   "
    cQry += " ISNULL(SC9.R_E_C_N_O_, 0) AS [SC9_REC],   "
    cQry += " ISNULL(SC9.C9_CLIENTE, '') AS [CLI],   "
    cQry += " ISNULL(SC9.C9_LOJA, '') AS [LOJA]   "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR   "
    cQry += " LEFT JOIN " + RetSqlName('SC9') + " SC9 ON ZZR.ZZR_FILIAL = SC9.C9_FILIAL "
    cQry += " AND ZZR.ZZR_PEDIDO		= SC9.C9_PEDIDO "
    cQry += " AND ZZR.ZZR_SEQOS		= SC9.C9_SEQOS "
    cQry += " AND ZZR.ZZR_ITEMPV		= SC9.C9_ITEM "
    cQry += " AND ZZR.D_E_L_E_T_		= SC9.D_E_L_E_T_  "
    cQry += " AND ''					= SC9.C9_BLEST "
    cQry += " AND ''					= SC9.C9_BLCRED "
    cQry += "   "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial("ZZR") + "'   "
    cQry += " AND ZZR.ZZR_OS = '" + cOS + "'   "
    cQry += " AND ZZR.D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZZR.ZZR_PEDIDO, ZZR.ZZR_ITEMPV, ZZR.ZZR_SEQOS, "
    cQry += " ISNULL(SC9.R_E_C_N_O_, 0), ISNULL(SC9.C9_CLIENTE, ''), ISNULL(SC9.C9_LOJA, '') "
return(cQry)

static function getNFInfo(cNF, cSer)
    local cQry := ""
    cQry += " SELECT  "
    cQry += " ISNULL(ZZ9.ZZ9_ORDSEP, '') AS [SEP], "
    cQry += " SF2.F2_VOLUME1	AS [VOL], "
    cQry += " SF2.F2_ESPECI1	AS [ESP], "
    cQry += " SF2.F2_PBRUTO	AS [BRUT], "
    cQry += " SF2.F2_PLIQUI	AS [LIQ] "
    cQry += " FROM " + RetSqlName('SF2') + " SF2 "
    cQry += " LEFT JOIN " + RetSqlName('ZZ9') + " ZZ9 ON SF2.F2_FILIAL	= ZZ9.ZZ9_FILIAL "
    cQry += " 					AND SF2.F2_DOC		= ZZ9.ZZ9_DOC "
    cQry += " 					AND SF2.F2_SERIE    = ZZ9.ZZ9_SERIE "
    cQry += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
    cQry += " AND SF2.F2_DOC = '" + AllTrim(cNF) + "' "
    cQry += " AND SF2.F2_SERIE = '" + AllTrim(cSer) + "' "
    cQry += " AND SF2.D_E_L_E_T_ = '' "
return(cQry)

static function getF2Rem(aNF)
    local cQry := ""

    cQry += " SELECT DISTINCT(SF2.R_E_C_N_O_) AS [REC] "
    cQry += " FROM " + RetSqlName('SF2') + " SF2 "
    cQry += " INNER JOIN " + RetSqlName('SD2') + " SD2 ON SF2.F2_FILIAL	= SD2.D2_FILIAL "
    cQry += " 					 AND SF2.F2_DOC		= SD2.D2_DOC "
    cQry += " 					 AND SF2.F2_SERIE	= SD2.D2_SERIE "
    cQry += " 					 AND SF2.D_E_L_E_T_	= SD2.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 ON SD2.D2_FILIAL	= SC5.C5_FILIAL "
    cQry += " 					 AND SD2.D2_PEDIDO	= SC5.C5_NUM "
    cQry += " 					 AND SD2.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
    cQry += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
    cQry += " AND SF2.F2_DOC = '" + AllTrim(aNF[01]) + "' "
    cQry += " AND SF2.F2_SERIE = '" + AllTrim(aNF[02]) + "' "
    cQry += " AND SC5.C5_ZZCLIEN <> '' "
    cQry += " AND SC5.C5_ZZLOJEN <> '' "
    cQry += " AND SF2.D_E_L_E_T_ = '' "
return(cQry)

static function getD2Rem(cRec)
    local cQry := ""

    cQry += " SELECT DISTINCT(SD2.R_E_C_N_O_) AS [REC] "
    cQry += " FROM " + RetSqlName('SF2') + " SF2 "
    cQry += " INNER JOIN " + RetSqlName('SD2') + " SD2 ON SF2.F2_FILIAL	= SD2.D2_FILIAL "
    cQry += " 					 AND SF2.F2_DOC		= SD2.D2_DOC "
    cQry += " 					 AND SF2.F2_SERIE	= SD2.D2_SERIE "
    cQry += " 					 AND SF2.D_E_L_E_T_	= SD2.D_E_L_E_T_ "
    cQry += " WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
    cQry += " AND SF2.R_E_C_N_O_ = " + AllTrim(cRec)
    cQry += " AND SF2.D_E_L_E_T_ = '' "
return(cQry)
