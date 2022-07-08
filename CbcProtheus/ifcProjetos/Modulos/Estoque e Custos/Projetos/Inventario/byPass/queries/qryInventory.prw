#include 'protheus.ch'
#include 'parmtype.ch'

static function qryBrw(cDtIni, cDtFim)
	local cQry	:= ''
	
	// NÃO USAR WITH(NOLOCK), SQLTOTRB NÃO ACEITA A TAG	
	cQry += " SELECT SF2.F2_FILIAL		AS [FILIAL],                              "
	cQry += " SF2.F2_DOC				AS [DOC],                                 "
	cQry += " SF2.F2_SERIE				AS [SERIE],                               "
	cQry += " SF2.F2_CLIENTE			AS [CLI],                                 "
	cQry += " SF2.F2_LOJA				AS [LOJA],                                "
	cQry += " SA1.A1_NOME				AS [NOME],                                "
	cQry += " SF2.F2_EMISSAO			AS [EMISSAO]                              "
	cQry += " FROM " + RetSqlName('SF2') + " SF2                                  "
	cQry += " INNER JOIN " + RetSqlName('SD2') + " SD2                            "
	cQry += " 						ON SF2.F2_FILIAL	= SD2.D2_FILIAL           "
	cQry += " 						AND SF2.F2_DOC		= SD2.D2_DOC              "
	cQry += " 						AND SF2.F2_SERIE	= SD2.D2_SERIE            "
	cQry += " 						AND SF2.D_E_L_E_T_	= SD2.D_E_L_E_T_          "
	cQry += " INNER JOIN " + RetSqlName('SF4') + " SF4                            "
	cQry += " 						ON ''				= SF4.F4_FILIAL           "
	cQry += " 						AND SD2.D2_TES		= SF4.F4_CODIGO           "
	cQry += " 						AND SD2.D_E_L_E_T_	= SF4.D_E_L_E_T_          "
	cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1                            "
	cQry += " 						ON ''				= SA1.A1_FILIAL           "
	cQry += " 						AND SF2.F2_CLIENTE	= SA1.A1_COD              "
	cQry += " 						AND SF2.F2_LOJA		= SA1.A1_LOJA             "
	cQry += " 						AND SF2.D_E_L_E_T_	= SA1.D_E_L_E_T_          "
	cQry += " WHERE SF2.F2_FILIAL = '" + xFilial('SF2') + "'                      "
	cQry += " AND SF2.F2_EMISSAO >= '" + cDtIni + "'                              "
	cQry += " AND SF2.F2_EMISSAO <= '" + cDtFim + "'                              "
	cQry += " AND SF4.F4_ESTOQUE = 'S'                                            "
	cQry += " AND SF2.D_E_L_E_T_ = ''                                             "
	cQry += " GROUP BY SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE,   "
	cQry += " SF2.F2_LOJA, SA1.A1_NOME, SF2.F2_EMISSAO                            "
	cQry += " ORDER BY SF2.F2_DOC, SF2.F2_SERIE                                   "
return(cQry)

static function qryDeduct(oSqlTemp, cMark)
	local cQry	:= ''

	cQry += " SELECT SD2.D2_FILIAL			AS [FILIAL],                                                  "
	cQry += " SUBSTRING(SD2.D2_COD,1,10)	AS [COD],                                                     "
	cQry += " SD2.D2_LOCAL					AS [LOCAL],                                                   "
	cQry += " SDB.DB_LOCALIZ				AS [ACOND],                                                   "
	cQry += " SUM(SDB.DB_QUANT)				AS [QTDE]                                                     "
	cQry += " FROM %SD2.SQLNAME% WITH (NOLOCK)                                                            "
	cQry += " INNER JOIN %SDB.SQLNAME% WITH (NOLOCK)                                                      "
	cQry += " 						ON SD2.D2_FILIAL	= SDB.DB_FILIAL                                   "
	cQry += " 						AND SD2.D2_DOC		= SDB.DB_DOC                                      "
	cQry += " 						AND SD2.D2_SERIE	= SDB.DB_SERIE                                    "
	cQry += " 						AND SD2.D2_NUMSEQ	= SDB.DB_NUMSEQ                                   "
	cQry += " 						AND SD2.D_E_L_E_T_	= SDB.D_E_L_E_T_                                  "
	cQry += " INNER JOIN %SF4.SQLNAME% WITH (NOLOCK)                                                      "
	cQry += " 						ON ''					= SF4.F4_FILIAL                               "
	cQry += " 						AND SD2.D2_TES		= SF4.F4_CODIGO                                   "
	cQry += " 						AND SD2.D_E_L_E_T_	= SF4.D_E_L_E_T_                                  "
	cQry += " WHERE %SD2.XFILIAL%                                                                         "
	cQry += " AND SD2.D2_DOC + SD2.D2_SERIE IN (                                                          "
	cQry += " 									SELECT TEMP.DOC + TEMP.SERIE                              "
	cQry += " 									FROM " + oSqlTemp:GetRealName() + " TEMP WITH (NOLOCK)    "
	cQry += " 									WHERE TEMP.OK = '" + cMark + "'                        	  "
	cQry += " 									AND TEMP.D_E_L_E_T_ = ''                                  "
	cQry += " )                                                                                           "
	cQry += " AND SDB.DB_LOCALIZ NOT LIKE 'B%'                                                            "
	cQry += " AND SF4.F4_ESTOQUE = 'S'                                                                    "
	cQry += " AND SD2.D_E_L_E_T_ = ''                                                                     "
	cQry += " GROUP BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_LOCAL, SDB.DB_LOCALIZ	                          "
return(cQry)

static function qryRecTab(cDtInve, cCod, cLocal, cAcond)
	local cQry	:= ''

	cQry += " SELECT SB7.R_E_C_N_O_  AS [REC]           "
	cQry += " FROM %SB7.SQLNAME% WITH (NOLOCK)          "
	cQry += " WHERE %SB7.XFILIAL%                       "
	cQry += " AND SB7.B7_DATA = '" + cDtInve + "'		"
	cQry += " AND SB7.B7_COD = '" + cCod + "'           "
	cQry += " AND SB7.B7_LOCAL = '" + cLocal + "'       "
	cQry += " AND SB7.B7_LOCALIZ = '" + cAcond  + "'    "
	cQry += " AND SB7.D_E_L_E_T_ = ''                   "
return(cQry)

static function qryFallBack(cDtInve)
	local cQry	:= ''

	cQry += " SELECT SB7.R_E_C_N_O_ AS [REC],           "
	cQry += " SB7.B7_QUANT  		AS [QTD],		    "
	cQry += " SB7.B7_ZDEBITA  		AS [DEBITA]       	"
	cQry += " FROM %SB7.SQLNAME% WITH (NOLOCK)          "
	cQry += " WHERE %SB7.XFILIAL%                       "
	cQry += " AND SB7.B7_DATA = '" + cDtInve + "'		"
	cQry += " AND SB7.B7_ZDEBITA <> 0    				"
	cQry += " AND SB7.D_E_L_E_T_ = ''                   "
return(cQry)

static function qryDivergence(cDtInve, lExp)
	local cQry	:= ''	
	default lExp := .T.
	
	cQry += " SELECT SB7.B7_FILIAL 					AS [FILIAL],                               "
	cQry += " 		SB7.B7_COD 						AS [PRODUTO],                              "
	cQry += " 		SB1.B1_DESC 					AS [DESCRICAO],                            "
	cQry += " 		SB7.B7_LOCAL 					AS [ARMAZ],                                "
	cQry += " 		SB7.B7_LOCALIZ 					AS [ACONDIC],                              "
	cQry += " 		SB7.B7_QUANT 					AS [QUANT],                                "
	cQry += " 		SB7.B7_SLDANT 					AS [SALDANT],                              "
	cQry += " 		(SB7.B7_SLDANT - SB7.B7_QUANT) 	AS [DIFER],                                "
	cQry += " 		SB1.B1_PESCOB 					AS [KG_COBRE],                             "
	cQry += " 		SB7.B7_ZDEBITA 					AS [DEBITA]                                "
	cQry += " FROM %SB7.SQLNAME% WITH (NOLOCK)                                                 "
	cQry += " INNER JOIN %SB1.SQLNAME% WITH (NOLOCK) ON '  ' 			= SB1.B1_FILIAL        "
	cQry += " 										AND SB7.B7_COD		= SB1.B1_COD           "
	cQry += " 										AND SB7.D_E_L_E_T_ 	= SB1.D_E_L_E_T_       "
	cQry += " WHERE %SB7.XFILIAL%                                                              "
	cQry += " AND SB7.B7_DATA = '" + cDtInve + "'                                              "
	cQry += " AND SB7.B7_QUANT <> SB7.B7_SLDANT                                                "
	if lExp
		cQry += " AND (SB1.B1_TIPO = 'PA' AND SB7.B7_LOCAL = '01')                             "
	else
		cQry += " AND NOT (SB1.B1_TIPO = 'PA' AND SB7.B7_LOCAL = '01')                         "
	endif
	cQry += " AND SB1.B1_TIPO NOT IN ('AI','SV','MC')                                          "
	cQry += " AND SB7.B7_LOCAL NOT IN ('03','04','95','90','98','91')                          "
	cQry += " AND SB7.D_E_L_E_T_ = ''                                                          "
	cQry += " ORDER BY SB7.B7_LOCAL, SB7.B7_COD, SB7.B7_LOCALIZ                                "
return(cQry)