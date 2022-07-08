#include 'protheus.ch'
#include 'parmtype.ch'

user function qryProcTriangle(nRecC5)
	local cQry		:= ''	
	default nRecC5 	:= 0

	cQry += " SELECT SC5.C5_FILIAL AS [FILORI],                                "
	cQry += " SC5.C5_NUM AS [PEDORI],                                          "
	cQry += " SC6.C6_PRODUTO AS [PRODUTO],                                     "
	cQry += " SC6.C6_ACONDIC AS [ACONDIC],                                     "
	cQry += " SC6.C6_LANCES AS [LANCES],                                       "
	cQry += " SC6.C6_METRAGE AS [METRAGE],                                     "
	cQry += " SUM(SC9.C9_QTDLIB) AS [QTD],                                     "
	cQry += " SC6.R_E_C_N_O_ AS [SC6REC],									   "
	cQry += " SC6.C6_LOCAL AS [LOCAL],                                         "
	cQry += " SC6.C6_TES AS [TES],		                                       "
	cQry += " SB1.B1_PESCOB AS [PESCOB],                                       "
	cQry += " SC6.C6_ITEM AS [ITEM],	                                       "
	cQry += " SC6.C6_PRCVEN AS [PRCVEN]	                                       "
	cQry += " FROM SC5010 SC5                                                  "
	cQry += " INNER JOIN SC6010 SC6 ON SC5.C5_FILIAL		= SC6.C6_FILIAL    "
	cQry += " 						AND SC5.C5_NUM		= SC6.C6_NUM           "
	cQry += " 						AND SC5.D_E_L_E_T_	= SC6.D_E_L_E_T_       "
	cQry += " INNER JOIN SC9010 SC9 ON SC6.C6_FILIAL		= SC9.C9_FILIAL    "
	cQry += " 						AND SC6.C6_NUM		= SC9.C9_PEDIDO        "
	cQry += " 						AND SC6.C6_ITEM		= SC9.C9_ITEM          "
	cQry += " 						AND SC6.D_E_L_E_T_	= SC9.D_E_L_E_T_       "
	cQry += " INNER JOIN SB1010 SB1 ON ''					= SB1.B1_FILIAL    "
	cQry += " 						AND SC6.C6_PRODUTO	= SB1.B1_COD           "
	cQry += " 						AND SC6.D_E_L_E_T_	= SB1.D_E_L_E_T_       "
	cQry += " INNER JOIN SF4010 SF4 ON ''					= SF4.F4_FILIAL    "
	cQry += " 						AND SC6.C6_TES		= SF4.F4_CODIGO        "
	cQry += " 						AND SC6.D_E_L_E_T_	= SF4.D_E_L_E_T_       "
	cQry += " WHERE SC5.R_E_C_N_O_ = " + cValToChar(nRecC5) + "                "
	cQry += " AND SF4.F4_ESTOQUE = 'S'                                         "
	cQry += " AND SB1.B1_TIPO = 'PA'                                           "
	cQry += " AND SC9.C9_BLCRED = ''                                           "
	cQry += " AND SC9.C9_BLEST  = '02'                                         "
	cQry += " AND SC5.D_E_L_E_T_ = ''                                          "
	cQry += " GROUP BY SC5.C5_FILIAL,SC5.C5_NUM,SC6.C6_PRODUTO,SC6.C6_ACONDIC, "
	cQry += " SC6.C6_LANCES, SC6.C6_METRAGE,SC6.R_E_C_N_O_, SC6.C6_LOCAL, 	   "
	cQry += " SC6.C6_TES, SB1.B1_PESCOB, SC6.C6_ITEM, SC6.C6_PRCVEN			   "
return(cQry)

user function qryLockTriangle(cIdVen)
	local cQry		:= ''
	default cIdVen	:= ''

	cQry += " SELECT SC5.R_E_C_N_O_ AS [RECSC5],                           "
	cQry += " ISNULL(SC6.R_E_C_N_O_, 0) AS [RECSC6],                       "
	cQry += " ISNULL(SC9.R_E_C_N_O_, 0) AS [RECSC9],                       "
	cQry += " ISNULL(SDC.R_E_C_N_O_, 0) AS [RECSDC]                        "
	cQry += " FROM SC5010 SC5                                              "
	cQry += " LEFT JOIN SC6010 SC6 ON SC5.C5_FILIAL		= SC6.C6_FILIAL    "
	cQry += " 						AND SC5.C5_NUM		= SC6.C6_NUM       "
	cQry += " 						AND SC5.D_E_L_E_T_	= SC6.D_E_L_E_T_   "
	cQry += " LEFT JOIN SC9010 SC9 ON SC6.C6_FILIAL		= SC9.C9_FILIAL    "
	cQry += " 						AND SC6.C6_NUM		= SC9.C9_PEDIDO    "
	cQry += " 						AND SC6.C6_ITEM		= SC9.C9_ITEM      "
	cQry += " 						AND SC6.D_E_L_E_T_	= SC9.D_E_L_E_T_   "
	cQry += " LEFT JOIN SDC010 SDC ON SC6.C6_FILIAL		= SDC.DC_FILIAL    "
	cQry += " 						AND SC6.C6_NUM		= SDC.DC_PEDIDO    "
	cQry += " 						AND SC6.C6_ITEM		= SDC.DC_ITEM      "
	cQry += " 						AND SC6.D_E_L_E_T_	= SDC.D_E_L_E_T_   "
	cQry += " WHERE SC5.C5_X_IDVEN = '" + cIdVen + "'                      "
	cQry += " AND SC5.D_E_L_E_T_ = ''                                      "
	
return(cQry)

user function qryVldResiTriang(cIdVen)
	local cQry		:= ''
	default cIdVen	:= ''

	cQry += " SELECT SC5.C5_NUM AS [PEDIDO],                                "
	cQry += " SC6.C6_ITEM AS [ITEM]                                         "
	cQry += " FROM SC5010 SC5                                               "
	cQry += " INNER JOIN SC6010 SC6 ON SC5.C5_FILIAL	= SC6.C6_FILIAL   	"
	cQry += " 						AND SC5.C5_NUM		= SC6.C6_NUM        "
	cQry += " 						AND SC5.D_E_L_E_T_	= SC6.D_E_L_E_T_    "
	cQry += " INNER JOIN SC9010 SC9 ON SC6.C6_FILIAL	= SC9.C9_FILIAL   	"
	cQry += " 						AND SC6.C6_NUM		= SC9.C9_PEDIDO     "
	cQry += " 						AND SC6.C6_ITEM		= SC9.C9_ITEM       "
	cQry += " 						AND SC6.D_E_L_E_T_	= SC9.D_E_L_E_T_    "
	cQry += " WHERE SC5.C5_X_IDVEN = '" + cIdVen + "'                       "
	//cQry += " AND SC9.C9_BLEST NOT IN ('01','02','10')                      "
	cQry += " AND SC6.C6_BLQ <> 'R'											"
	cQry += " AND (SC6.C6_QTDVEN-SC6.C6_QTDENT)>0							"
	cQry += " AND SC9.C9_BLEST = '  '										"
	cQry += " AND SC5.D_E_L_E_T_ = ''                                       "
	cQry += " GROUP BY SC5.C5_NUM, SC6.C6_ITEM	                            "

return(cQry)

user function qryResiTriang(cIdVen)
	local cQry		:= ''
	default cIdVen	:= ''

	cQry += " SELECT SC6.R_E_C_N_O_ AS [RECSC6],                            "
	cQry += " SC5.R_E_C_N_O_ AS [RECSC5]		                            "
	cQry += " FROM SC5010 SC5                                               "
	cQry += " INNER JOIN SC6010 SC6 ON SC5.C5_FILIAL	= SC6.C6_FILIAL   	"
	cQry += " 						AND SC5.C5_NUM		= SC6.C6_NUM        "
	cQry += " 						AND SC5.D_E_L_E_T_	= SC6.D_E_L_E_T_    "
	cQry += " INNER JOIN SC9010 SC9 ON SC6.C6_FILIAL	= SC9.C9_FILIAL   	"
	cQry += " 						AND SC6.C6_NUM		= SC9.C9_PEDIDO     "
	cQry += " 						AND SC6.C6_ITEM		= SC9.C9_ITEM       "
	cQry += " 						AND SC6.D_E_L_E_T_	= SC9.D_E_L_E_T_    "
	cQry += " WHERE SC5.C5_X_IDVEN = '" + cIdVen + "'                       "
	cQry += " AND SC6.C6_BLQ <> 'R'											"
	cQry += " AND (SC6.C6_QTDVEN - SC6.C6_QTDENT) > 0						"
	cQry += " AND SC9.C9_BLCRED <> '10' AND SC9.C9_BLEST <> '10'			"
	cQry += " AND (SC9.C9_BLEST <> '  ' OR SC9.C9_BLCRED <> '  ')			"
	cQry += " AND SC5.D_E_L_E_T_ = ''                                       "
	cQry += " GROUP BY SC6.R_E_C_N_O_, SC5.R_E_C_N_O_						"
return(cQry)


user function qryAltertriang(cIdven)
	local cQry		:= ''
	default cIdVen	:= ''

	cQry += " SELECT 	SC6.R_E_C_N_O_ 	AS [RECSC6],                           	"
	cQry += " 			SC5.R_E_C_N_O_ 	AS [RECSC5],                           	"
	cQry += " 			SC9.R_E_C_N_O_ 	AS [RECSC9]                           	"
	cQry += " FROM SC5010 SC5   WITH (NOLOCK)                                  	"
	cQry += " INNER JOIN SC6010 SC6 WITH (NOLOCK)								"
	cQry += " 						ON SC5.C5_FILIAL	= SC6.C6_FILIAL   		"
	cQry += " 						AND SC5.C5_NUM		= SC6.C6_NUM        	"
	cQry += " 						AND SC5.D_E_L_E_T_	= SC6.D_E_L_E_T_    	"
	cQry += " INNER JOIN SC9010 SC9 WITH (NOLOCK)								"
	cQry += " 						ON SC6.C6_FILIAL	= SC9.C9_FILIAL   		"
	cQry += " 						AND SC6.C6_NUM		= SC9.C9_PEDIDO     	"
	cQry += " 						AND SC6.C6_ITEM		= SC9.C9_ITEM       	"
	cQry += " 						AND SC6.D_E_L_E_T_	= SC9.D_E_L_E_T_    	"
	cQry += " WHERE SC5.C5_X_IDVEN = '" + cIdVen + "'                       	"  
	cQry += " AND SC5.D_E_L_E_T_ = ''                                       	"
	cQry += " GROUP BY SC6.R_E_C_N_O_, SC5.R_E_C_N_O_,SC9.R_E_C_N_O_ 			"
return(cQry)

user function qryRetSC5Triang(cIdVen)
	local cQry 		:= ""
	default cIdVen	:= ""
	
	cQry := " SELECT SC5.R_E_C_N_O_ [RECSC5]				"
	cQry += " FROM SC5010 SC5	WITH (NOLOCK)				"
	cQry += " WHERE SC5.C5_X_IDVEN = '" + cIdVen + "'		"
	cQry += " 	AND SC5.D_E_L_E_T_ = ''						"
	cQry += " ORDER BY C5_FILIAL							"	
return(cQry)

static function qryItmRec(nRecC5)
	local cQry 		:= ""
	default nRecC5	:= 0
	
	cQry += " SELECT 	SC6.R_E_C_N_O_ 	AS [RECSC6]                           	"
	cQry += " FROM SC5010 SC5   WITH (NOLOCK)                                  	"
	cQry += " INNER JOIN SC6010 SC6 WITH (NOLOCK)								"
	cQry += " 						ON SC5.C5_FILIAL	= SC6.C6_FILIAL   		"
	cQry += " 						AND SC5.C5_NUM		= SC6.C6_NUM        	"
	cQry += " 						AND SC5.D_E_L_E_T_	= SC6.D_E_L_E_T_    	"
	cQry += " WHERE SC5.R_E_C_N_O_ = " + cValToChar(nRecC5)
	cQry += " AND SC5.D_E_L_E_T_ = ''                                       	"

return(cQry)
