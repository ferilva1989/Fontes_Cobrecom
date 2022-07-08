#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYped(cNum, cFi, cTipo )
	local cQry		:= ''
	default cTipo	:= 'item'
	default cFi		:= FwFilial()
	default cNum	:= ''

	if !empty(cNum)
		cQry += " SELECT " 
		cQry += getFld(cTipo)
		cQry += " CASE  "
		cQry += " 	WHEN SC6.C6_FILIAL = '01' "   
		cQry += " 		THEN  "
		cQry += " 			ISNULL(SUM(SC6.C6_QTDVEN * SB1.B1_CUSTD), 0) " 
		cQry += " 		ELSE  "
		cQry += " 			ISNULL(SUM(SC6.C6_QTDVEN * SB1.B1_CUSTD3L), 0) " 
		cQry += " 	END 			AS [CUSTO_ATUAL] , "
		cQry += " CASE  "
		cQry += " 	WHEN SC6.C6_FILIAL = '01'  "   
		cQry += " 		THEN  "
		cQry += " 			ISNULL(((((SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) ) * 100) / NULLIF(SUM(SC6.C6_QTDVEN * SB1.B1_CUSTD),0))-100), 0)  " 
		cQry += " 		ELSE  "
		cQry += " 			ISNULL(((((SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) ) * 100) / NULLIF(SUM(SC6.C6_QTDVEN * SB1.B1_CUSTD3L),0))-100), 0) " 
		cQry += " END 				AS [RG_ATUAL] , "
		cQry += " SUM(SC6.C6_CSTUNRG) AS [CUSTO_HIST], "
		cQry += " ISNULL(((((SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) ) * 100) / NULLIF( SUM(SC6.C6_QTDVEN * SC6.C6_CSTUNRG),0) )-100), 0) AS [RG_HIST], "
		cQry += " SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) AS [TOTAL] "
		cQry += " FROM  "
		cQry +=   RetSqlName('SC6') + " SC6 WITH (NOLOCK) "
		cQry += " INNER JOIN  "
		cQry +=   RetSqlName('SC5') + " SC5 WITH (NOLOCK) "
		cQry += " 	ON  SC6.C6_FILIAL		= SC5.C5_FILIAL "
		cQry += " 	AND SC6.C6_NUM			= SC5.C5_NUM "
		cQry += " 	AND SC5.R_E_C_N_O_		= SC5.R_E_C_N_O_ "  
		cQry += " 	AND SC6.D_E_L_E_T_		= SC5.D_E_L_E_T_ "
		cQry += " INNER JOIN  "
		cQry +=   RetSqlName('SB1')+  " SB1 WITH (NOLOCK) "
		cQry += " 	ON  ' '					= SB1.B1_FILIAL "
		cQry += " 	AND SC6.C6_PRODUTO		= SB1.B1_COD "
		cQry += " 	AND SB1.R_E_C_N_O_		= SB1.R_E_C_N_O_ "  
		cQry += " 	AND SC6.D_E_L_E_T_		= SB1.D_E_L_E_T_ "
		cQry += " WHERE "
		cQry += " 	SC6.C6_FILIAL IN ('" + cFi + "') "
		cQry += " 	AND SC6.C6_NUM = '" + cNum + "' "
		cQry += " 	AND SC6.D_E_L_E_T_ = '' "
		cQry += getOrd(cTipo)
	endif
return(cQry)


static function getFld(cTipo)
	local cFld		:= ''
	default cTipo	:= 'item'
	cFld += " SC6.C6_FILIAL		AS [FILIAL], "
	if cTipo == 'item'
		cFld += " CONVERT(varchar(20),cast (SC5.C5_EMISSAO as datetime),103) AS [EMISSAO],"
		cFld += " SC6.C6_NUM		AS [PEDIDO], "
		cFld += " SC6.C6_ITEM		AS [ITEM], "
		cFld += " SC6.C6_PRODUTO	AS [COD_PROD], "
		cFld += " SC6.C6_DESCRI		AS [PRODUTO], "
		cFld += " SC6.C6_PRCVEN		AS [PRECO_VENDA], "
		cFld += " SC6.C6_QTDVEN		AS [QTD_VEND], "
	elseif cTipo == 'total'
		cFld += " SUM(SC6.C6_PRCVEN)	AS [PRECO_VENDA], "
		cFld += " SUM(SC6.C6_QTDVEN)	AS [QTD_VEND], "
	endif
return(cFld)


static function getOrd(cTipo)
	local cOrd		:= ''
	default cTipo	:= 'item'
	if cTipo == 'item'
		cOrd += " GROUP BY "
		cOrd += " 	SC6.C6_FILIAL, SC5.C5_EMISSAO, SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_QTDVEN, SC6.C6_PRCVEN "
		cOrd += " ORDER BY  "
		cOrd += " 	SC6.C6_FILIAL, SC5.C5_EMISSAO, SC6.C6_NUM, SC6.C6_ITEM "
	elseif cTipo == 'total'
		cOrd += " GROUP BY "
		cOrd += " 	SC6.C6_FILIAL  "
		cOrd += " ORDER BY "
		cOrd += " 	SC6.C6_FILIAL "
	endif
return(cOrd)
