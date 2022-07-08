#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYBFEst()
	local cQry := ''
	cQry += " SELECT " 
	cQry += " SBF.BF_PRODUTO	AS [Produto], "
	cQry += " SBF.BF_LOCALIZ	AS [Acond], "
	cQry += " (SBF.BF_QUANT - SBF.BF_EMPENHO) AS [Disponivel] "
	cQry += " FROM  "
	cQry +=   RetSqlName('SBF') + " SBF WITH (NOLOCK) " 
	cQry += " INNER JOIN " +  RetSqlName('SB1') + " SB1 WITH (NOLOCK) " 
	cQry += " ON ''					= SB1.B1_FILIAL "
	cQry += " AND SBF.BF_PRODUTO	= SB1.B1_COD "
	cQry += " AND SBF.D_E_L_E_T_	= SB1.D_E_L_E_T_ "
	cQry += " WHERE  "
	cQry += " SBF.BF_FILIAL 		= '" + xFilial('SBF') + "' " 
	cQry += " AND SBF.BF_LOCAL 		= '01' "
	cQry += " AND ((SBF.BF_QUANT - SBF.BF_EMPENHO) > 0) "
	cQry += " AND SB1.B1_TIPO 		= 'PA' "
	cQry += " AND SBF.D_E_L_E_T_ 	= '' "
return(cQry)