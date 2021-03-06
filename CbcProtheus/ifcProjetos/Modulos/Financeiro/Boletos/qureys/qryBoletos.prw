#include 'protheus.ch'
#include 'parmtype.ch'

static function qryGetTitles(cCgc)
	local cQry		:= ''
	Local oStatic	:= IfcXFun():newIfcXFun()
	local aFlds		:= oStatic:sP(1):callStatic('defBoletos', 'fldTitles')
	
	cQry += " SELECT                                                                      "
	cQry += " SA1.A1_NOME				  AS [" + aFlds[01] + "],                         "
	cQry += " SE1.E1_PORTADO			  AS [" + aFlds[02] + "],                         "
	cQry += " CASE                                                                        "
	cQry += " 	WHEN SE1.E1_PORTADO = '341' 											  "
	cQry += " 	THEN '112'+RTRIM(LTRIM(SE1.E1_NUMBCO))                                    "
	cQry += " 	ELSE RTRIM(LTRIM(SE1.E1_NUMBCO))                                          "
	cQry += " END					AS [" + aFlds[03] + "],                               "
	cQry += " SE1.E1_NUM			As [" + aFlds[04] + "],                               "
	cQry += " SE1.E1_PARCELA		AS [" + aFlds[05] + "],                               "
	cQry += " SA1.A1_CGC			AS [" + aFlds[06] + "],                               "
	cQry += " SE1.E1_AGEDEP			AS [" + aFlds[07] + "],                               "
	cQry += " RTRIM(LTRIM(SE1.E1_CONTA)) 												  " 
	cQry += " + RTRIM(LTRIM(SA6.A6_DVCTA))	AS [" + aFlds[08] + "],						  "
	cQry += " SE1.E1_EMISSAO		AS [" + aFlds[09] + "],                               "
	cQry += " SE1.E1_VENCREA		AS [" + aFlds[10] + "],                               "
	//cQry += " '20191010'		AS [" + aFlds[10] + "],                               "
	cQry += " CASE                                                                        "
	cQry += " 	WHEN SE1.E1_VENCREA < '" + DTOS(dDatabase) + "' AND  SE1.E1_BAIXA = ''    "
	cQry += " 	THEN 'ATRASADO'                                                           "
	cQry += " 	ELSE 'A VENCER'                                                           "
	cQry += " END					AS [" + aFlds[11] + "],                               "
	cQry += " SA1.R_E_C_N_O_		AS [" + aFlds[12] + "],			  					  "
	cQry += " SE1.R_E_C_N_O_	 	AS [" + aFlds[13] + "],								  "
	cQry += " SE1.E1_SALDO	 		AS [" + aFlds[14] + "]								  "
	cQry += " FROM %SE1.SQLNAME% WITH(NOLOCK)                                             "
	cQry += " INNER JOIN %SA1.SQLNAME% WITH(NOLOCK)                                       "
	cQry += " 							ON '' 				= SA1.A1_FILIAL               "
	cQry += " 							AND SE1.E1_CLIENTE 	= SA1.A1_COD                  "
	cQry += " 							AND SE1.E1_LOJA 	= SA1.A1_LOJA                 "
	cQry += " 							AND SE1.D_E_L_E_T_ 	= SA1.D_E_L_E_T_              "
	cQry += " INNER JOIN %SA6.SQLNAME% WITH(NOLOCK)                                       "
	cQry += " 							ON '' 				= SA6.A6_FILIAL               "
	cQry += " 							AND SE1.E1_PORTADO	= SA6.A6_COD              	  "
	cQry += " 							AND SE1.E1_AGEDEP	= SA6.A6_AGENCIA		  	  "
	cQry += " 							AND SE1.E1_CONTA	= SA6.A6_NUMCON				  "
	cQry += " 							AND SE1.D_E_L_E_T_	= SA6.D_E_L_E_T_          	  "
	cQry += " WHERE SE1.E1_FILIAL IN ('01', '02', '03')                                         "
	cQry += " AND SA1.A1_CGC LIKE '" + cCgc + "%'                                         "
	cQry += " AND ((SE1.E1_VENCREA <= '" + DTOS(dDatabase) + "' AND SE1.E1_BAIXA = '')    "
	cQry += " OR (SE1.E1_VENCREA > '" + DTOS(dDatabase) + "' AND SE1.E1_BAIXA = ''))      "
	cQry += " AND SE1.E1_PORTADO NOT IN ('000', 'RAF')									  " 
	cQry += " AND SE1.D_E_L_E_T_ = ''                                                     "
	cQry += " AND SE1.E1_NUMBCO <> ''                                                     "
	cQry += " AND SA1.A1_MSBLQL = 2                                                       "
	cQry += " ORDER BY SE1.E1_VENCREA	                                                  "
return(cQry)

static function qryGetTit(nRecCli, nRecTit)
	local cQry		:= ''
	Local oStatic	:= IfcXFun():newIfcXFun()
	local aFlds		:= oStatic:sP(1):callStatic('defBoletos', 'fldTitles')
	
	cQry += " SELECT                                                                      "
	cQry += " SA1.A1_NOME				  AS [" + aFlds[01] + "],                         "
	cQry += " SE1.E1_PORTADO			  AS [" + aFlds[02] + "],                         "
	cQry += " CASE                                                                        "
	cQry += " 	WHEN SE1.E1_PORTADO = '341' 											  "
	cQry += " 	THEN '112'+RTRIM(LTRIM(SE1.E1_NUMBCO))                                    "
	cQry += " 	ELSE RTRIM(LTRIM(SE1.E1_NUMBCO))                                          "
	cQry += " END					AS [" + aFlds[03] + "],                               "
	cQry += " SE1.E1_NUM			As [" + aFlds[04] + "],                               "
	cQry += " SE1.E1_PARCELA		AS [" + aFlds[05] + "],                               "
	cQry += " SA1.A1_CGC			AS [" + aFlds[06] + "],                               "
	cQry += " SE1.E1_AGEDEP			AS [" + aFlds[07] + "],                               "
	cQry += " RTRIM(LTRIM(SE1.E1_CONTA)) 												  " 
	cQry += " + RTRIM(LTRIM(SA6.A6_DVCTA))	AS [" + aFlds[08] + "],						  "
	cQry += " SE1.E1_EMISSAO		AS [" + aFlds[09] + "],                               "
	cQry += " SE1.E1_VENCREA		AS [" + aFlds[10] + "],                               "                             "
	cQry += " CASE                                                                        "
	cQry += " 	WHEN SE1.E1_VENCREA < '" + DTOS(dDatabase) + "' AND  SE1.E1_BAIXA = ''    "
	cQry += " 	THEN 'ATRASADO'                                                           "
	cQry += " 	ELSE 'A VENCER'                                                           "
	cQry += " END					AS [" + aFlds[11] + "],                               "
	cQry += " SA1.R_E_C_N_O_		AS [" + aFlds[12] + "],			  					  "
	cQry += " SE1.R_E_C_N_O_	 	AS [" + aFlds[13] + "],								  "
	cQry += " SE1.E1_SALDO	 		AS [" + aFlds[14] + "]								  "
	cQry += " FROM %SE1.SQLNAME% WITH(NOLOCK)                                             "
	cQry += " INNER JOIN %SA1.SQLNAME% WITH(NOLOCK)                                       "
	cQry += " 							ON '' 				= SA1.A1_FILIAL               "
	cQry += " 							AND SE1.E1_CLIENTE 	= SA1.A1_COD                  "
	cQry += " 							AND SE1.E1_LOJA 	= SA1.A1_LOJA                 "
	cQry += " 							AND SE1.D_E_L_E_T_ 	= SA1.D_E_L_E_T_              "
	cQry += " INNER JOIN %SA6.SQLNAME% WITH(NOLOCK)                                       "
	cQry += " 							ON '' 				= SA6.A6_FILIAL               "
	cQry += " 							AND SE1.E1_PORTADO	= SA6.A6_COD              	  "
	cQry += " 							AND SE1.E1_AGEDEP	= SA6.A6_AGENCIA		  	  "
	cQry += " 							AND SE1.E1_CONTA	= SA6.A6_NUMCON				  "
	cQry += " 							AND SE1.D_E_L_E_T_	= SA6.D_E_L_E_T_          	  "
	cQry += " WHERE SE1.E1_FILIAL IN ('01', '02', '03')									  "
	cQry += " AND SE1.R_E_C_N_O_ = " + cValToChar(nRecTit) + "							  "
	cQry += " AND ((SE1.E1_VENCREA <= '" + DTOS(dDatabase) + "' AND SE1.E1_BAIXA = '')    "
	cQry += " OR (SE1.E1_VENCREA > '" + DTOS(dDatabase) + "' AND SE1.E1_BAIXA = ''))      "
	cQry += " AND SE1.E1_PORTADO NOT IN ('000', 'RAF')									  " 
	cQry += " AND SE1.D_E_L_E_T_ = ''                                                     "
	cQry += " AND SE1.E1_NUMBCO <> ''                                                     "
	cQry += " AND SA1.R_E_C_N_O_ = " + cValToChar(nRecCli) + "							  "
	cQry += " AND SA1.A1_MSBLQL = 2                                                       "
	cQry += " ORDER BY SE1.E1_VENCREA	                                                  "
return(cQry)
