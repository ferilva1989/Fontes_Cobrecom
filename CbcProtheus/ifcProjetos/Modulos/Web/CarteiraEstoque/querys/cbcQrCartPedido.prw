#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQrCartPedido()
	local cQry := ''
	cQry += " SELECT "
	cQry += " SC6.C6_FILIAL AS FILIAL, "
	cQry += " SC5.C5_DTFAT 	 AS DTFAT, "
	cQry += " SC5.C5_NUM 	 AS PEDIDO, "
	cQry += " SC5.C5_EMISSAO AS EMISSAO, "
	cQry += " SC6.C6_PRODUTO AS CODIGO, "
	cQry += " SB1.B1_DESC AS DESCRICAO, "
	cQry += " SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)) AS ACONDICIONAMENTO, "
	cQry += " SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT) AS NECESSIDADE "
	cQry += " FROM "
	cQry +=   RetSqlName('SC6') + " SC6 "
	cQry += " INNER JOIN " +  RetSqlName('SC5') + " SC5 WITH (NOLOCK) " 
	cQry += " ON  SC6.C6_FILIAL		= SC5.C5_FILIAL "
	cQry += " AND SC6.C6_NUM			= SC5.C5_NUM "
	cQry += " AND SC5.R_E_C_N_O_		= SC5.R_E_C_N_O_ "  
	cQry += " AND SC6.D_E_L_E_T_		= SC5.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SF4') + " SF4 WITH (NOLOCK) "
	cQry += " ON ''					= SF4.F4_FILIAL "
	cQry += " AND SC6.C6_TES			= SF4.F4_CODIGO "
	cQry += " AND SF4.R_E_C_N_O_		= SF4.R_E_C_N_O_ "
	cQry += " AND SC6.D_E_L_E_T_		= SF4.D_E_L_E_T_ "
	cQry += " INNER JOIN " +  RetSqlName('SB1') + " SB1 WITH (NOLOCK) "
	cQry += " ON  ' '					= SB1.B1_FILIAL "
	cQry += " AND SC6.C6_PRODUTO		= SB1.B1_COD "
	cQry += " AND SB1.R_E_C_N_O_		= SB1.R_E_C_N_O_ "
	cQry += " AND SC6.D_E_L_E_T_		= SB1.D_E_L_E_T_ "
	cQry += " WHERE  "
	cQry += " SC6.C6_FILIAL			IN ('" + FwFilial() + "')"
	cQry += " AND SC6.C6_CF			NOT IN ('6151','6152','6901','6124','6902') "
	cQry += " AND SC6.C6_NOTA			= '' "
	cQry += " AND SC6.D_E_L_E_T_		= '' "
	cQry += " AND SC5.C5_TIPO			= 'N' "
	cQry += " AND SC5.C5_NOTA			= '' "
	cQry += " AND  DATEDIFF ( day , getdate() , convert(date,  SC5.C5_DTFAT) ) <= " + cValToChar(GetNewPar('ZZ_MESDTFA',30))
	cQry += " AND SF4.F4_DUPLIC		= 'S' "
	cQry += " AND SB1.B1_TIPO			= 'PA' "
	cQry += " GROUP BY "
	cQry += " SC6.C6_FILIAL,SC5.C5_DTFAT, SC5.C5_NUM, SC5.C5_EMISSAO, SC6.C6_PRODUTO, SC6.C6_ACONDIC, SC6.C6_METRAGE, SB1.B1_DESC "
	cQry += " ORDER BY "
	cQry += " SC6.C6_FILIAL, SC5.C5_DTFAT, SC5.C5_NUM, SC5.C5_EMISSAO, SC6.C6_PRODUTO, SC6.C6_ACONDIC, SC6.C6_METRAGE, SB1.B1_DESC "
return(cQry)