#include 'protheus.ch'
#include 'parmtype.ch'

user function qryMultiPedidos(cIdVen, nRec)
	local cQry := ''
	
	cQry += " SELECT SC5.C5_FILIAL AS [FILIAL],                          "
	cQry += " SC5.R_E_C_N_O_ AS [REC_SC5],                               "
	cQry += " SA1.R_E_C_N_O_ AS [REC_SA1]                                "
	cQry += " FROM " + RetSqlName('SC5') + " SC5                         "
	cQry += " INNER JOIN SA1010 SA1 ON ''				= SA1.A1_FILIAL  "
	cQry += " 					AND SC5.C5_CLIENTE	= SA1.A1_COD         "
	cQry += " 					AND SC5.C5_LOJACLI	= SA1.A1_LOJA        "
	cQry += " 					AND SC5.D_E_L_E_T_	= SA1.D_E_L_E_T_     "
	cQry += " WHERE SC5.C5_X_IDVEN = '" + cIdVen + "'                    "
	cQry += " AND SC5.R_E_C_N_O_ <> " + cValToChar(nRec)
	cQry += " AND SC5.D_E_L_E_T_ = ''                                    "

return(cQry)

user function qryMainPedido(cIdVen)
	local cQry 		:= ''
	local cPed 		:= ''
	local cFilOrig 	:= ''
	
	default cIdVen := ''
	
	if !empty(cIdVen)
		
		cFilOrig := Substr(cIdVen,1,TamSX3('C5_FILIAL')[1])
		cPed 	 := Substr(cIdVen,TamSX3('C5_FILIAL')[1] + 1, TamSX3('C5_NUM')[1])
				
		cQry += " SELECT SC5.C5_FILIAL AS [FILIAL],                          "
		cQry += " SC5.R_E_C_N_O_ AS [REC_SC5]	                             "
		cQry += " FROM " + RetSqlName('SC5') + " SC5                         "
		cQry += " WHERE SC5.C5_FILIAL = '" + cFilOrig + "'					 " 
		cQry += " AND SC5.C5_NUM = '" + cPed + "'                      		 "
		cQry += " AND SC5.C5_X_IDVEN = '" + cIdVen + "'                      "
		cQry += " AND SC5.D_E_L_E_T_ = ''                                    "
	endif
return(cQry)