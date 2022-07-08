#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYCarteira()
	local cQry	:= ''
	cQry += " SELECT"  
	cQry += " SC9.C9_FILIAL  AS [FILIAL], "
	cQry += " SC9.C9_PRODUTO AS [PRODUTO], "
	cQry += " SC5.C5_ENTREG	AS [ENTREGA], "
	cQry += " SC5.C5_PARCIAL	AS [PARCIAL], "
	cQry += " SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)) AS [ACONDICIONAMENTO], "
	cQry += " SC9.C9_QTDLIB AS [QTD_LIB], "
	cQry += " SC5.C5_NUM	AS [PEDIDO] "
	cQry += " FROM  "
	cQry +=   RetSqlName('SC9') + " SC9  WITH (NOLOCK) " 
	cQry += " INNER JOIN  "+ RetSqlName('SC6') + " SC6  WITH (NOLOCK) " 
	cQry += " ON SC9.C9_FILIAL		= SC6.C6_FILIAL  "
	cQry += " AND SC9.C9_PEDIDO		= SC6.C6_NUM  "
	cQry += " AND SC9.C9_ITEM		= SC6.C6_ITEM " 
	cQry += " AND SC9.C9_PRODUTO	= SC6.C6_PRODUTO " 
	cQry += " AND SC6.R_E_C_N_O_	= SC6.R_E_C_N_O_  "
	cQry += " AND SC9.D_E_L_E_T_	= SC6.D_E_L_E_T_  "
	cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 WITH (NOLOCK)  "
	cQry += " ON  SC6.C6_FILIAL		= SC5.C5_FILIAL  "
	cQry += " AND SC6.C6_NUM		= SC5.C5_NUM  "
	cQry += " AND SC5.R_E_C_N_O_	= SC5.R_E_C_N_O_ " 
	cQry += " AND SC6.D_E_L_E_T_	= SC5.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH (NOLOCK)  "
	cQry += " ON ''					= SB1.B1_FILIAL "
	cQry += " AND SC9.C9_PRODUTO	= SB1.B1_COD "
	cQry += " AND SC9.D_E_L_E_T_	= SB1.D_E_L_E_T_ "
	cQry += " WHERE  "
	cQry += " SC9.C9_FILIAL = '" + xFilial('SC9') + "' " 
	cQry += " AND SC9.C9_PEDIDO NOT IN('') "
	cQry += " AND SC9.C9_BLCRED IN (' ')  "
	cQry += " AND SC9.C9_BLEST  IN ('02')  "
	cQry += " AND SC9.C9_SERIENF NOT IN ('U') " 
	cQry += " AND SC9.D_E_L_E_T_ = ''  "
	cQry += " ORDER BY "
	cQry += " SC9.C9_FILIAL, SC9.C9_PRODUTO "
return(cQry)