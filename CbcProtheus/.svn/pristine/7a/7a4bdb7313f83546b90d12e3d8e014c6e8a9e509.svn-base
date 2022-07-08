#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYcnpjCli(cOrigem,cEmp, cPedido )
	local cQry	:= ''
	if cOrigem == 'portal'
		cQry += " SELECT " 
		cQry += " SUBSTRING(SA1.A1_CGC,1,8) AS [RAIZ] "
		cQry += " FROM  "
		cQry +=   RetSqlName('ZP5') + " ZP5 WITH (NOLOCK) "
		cQry += " INNER JOIN " +  RetSqlName('SA1') + " SA1 WITH (NOLOCK) "
		cQry += " ON '' = SA1.A1_FILIAL "
		cQry += " AND ZP5.ZP5_CLIENT	= SA1.A1_COD "
		cQry += " AND ZP5.ZP5_LOJA		= SA1.A1_LOJA "
		cQry += " AND SA1.R_E_C_N_O_  	= SA1.R_E_C_N_O_ "
		cQry += " AND ZP5.D_E_L_E_T_  	= SA1.D_E_L_E_T_ "
		cQry += " WHERE ZP5.ZP5_FILIAL 	= '' "
		cQry += " AND ZP5.ZP5_NUM = '" + cPedido + "' "
		cQry += " AND ZP5.D_E_L_E_T_ = '' "
	elseif cOrigem == 'pedido'
		cQry += " SELECT " 
		cQry += " SUBSTRING(SA1.A1_CGC,1,8) AS [RAIZ] "
		cQry += " FROM  "
		cQry +=  RetSqlName('SC5') + " SC5 WITH (NOLOCK) "
		cQry += " INNER JOIN "  + RetSqlName('SA1') + " SA1 WITH (NOLOCK) "
		cQry += " ON '' = SA1.A1_FILIAL "
		cQry += " AND SC5.C5_CLIENTE	= SA1.A1_COD "
		cQry += " AND SC5.C5_LOJACLI	= SA1.A1_LOJA "
		cQry += " AND SA1.R_E_C_N_O_  = SA1.R_E_C_N_O_ "
		cQry += " AND SC5.D_E_L_E_T_  = SA1.D_E_L_E_T_ "
		cQry += " WHERE SC5.C5_FILIAL = '" + cEmp + "' "
		cQry += " AND SC5.C5_NUM = '" + cPedido + "' "
		cQry += " AND SC5.D_E_L_E_T_ = '' "
	endif
return (cQry)