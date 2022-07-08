#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYportal(cNum, cFi, cTipo )
	local cQry		:= ''
	default cTipo	:= 'item'
	default cFi		:= FwFilial()
	default cNum	:= ''

	if !empty(cNum)
		cQry += " SELECT " 
		cQry += getFld(cTipo)
		cQry += " ISNULL( SUM(ZP6.ZP6_PRCMIN / NULLIF(((ZP6.ZP6_RGMIN/100) + 1), 0)) , 0)  AS [CUSTO_HIST_MIN], "
		cQry += " ISNULL( SUM(ZP6.ZP6_PRCSUG / NULLIF(((ZP6.ZP6_RGSUG/100) + 1), 0)) , 0)  AS [CUSTO_HIST_SUG], "
		cQry += " ISNULL( SUM(ZP6.ZP6_PRCAPR / NULLIF(((ZP6.ZP6_RGAPR/100) + 1), 0)) , 0)  AS [CUSTO_HIST_APR], "
		cQry += " ISNULL(((((SUM(ZP6.ZP6_QUANT * ZP6.ZP6_PRCMIN) ) * 100) / NULLIF( SUM(ZP6.ZP6_QUANT * ISNULL( ZP6.ZP6_PRCMIN / NULLIF(((ZP6.ZP6_RGMIN/100) + 1), 0) , 0)),0) )-100), 0) AS [RG_HIST_MIN], "
		cQry += " ISNULL(((((SUM(ZP6.ZP6_QUANT * ZP6.ZP6_PRCSUG) ) * 100) / NULLIF( SUM(ZP6.ZP6_QUANT * ISNULL( ZP6.ZP6_PRCSUG / NULLIF(((ZP6.ZP6_RGSUG/100) + 1), 0) , 0)),0) )-100), 0) AS [RG_HIST_SUG], "
		cQry += " ISNULL(((((SUM(ZP6.ZP6_QUANT * ZP6.ZP6_PRCAPR) ) * 100) / NULLIF( SUM(ZP6.ZP6_QUANT * ISNULL( ZP6.ZP6_PRCAPR / NULLIF(((ZP6.ZP6_RGAPR/100) + 1), 0) , 0)),0) )-100), 0) AS [RG_HIST_APR], "
		cQry += " SUM(ZP6.ZP6_QUANT * ZP6.ZP6_PRCMIN) AS [TOTAL_MIN], "
		cQry += " SUM(ZP6.ZP6_QUANT * ZP6.ZP6_PRCSUG) AS [TOTAL_SUG], "
		cQry += " SUM(ZP6.ZP6_QUANT * ZP6.ZP6_PRCAPR) AS [TOTAL_APR] "
		cQry += " FROM  "
		cQry += RetSqlName('ZP6') + " ZP6 "
		cQry += " INNER JOIN "
		cQry += RetSqlName('ZP5') + " ZP5 WITH (NOLOCK) "
		cQry += " 	ON  ZP6.ZP6_FILIAL		= ZP5.ZP5_FILIAL "
		cQry += " 	AND ZP6.ZP6_NUM			= ZP5.ZP5_NUM "
		cQry += " 	AND ZP5.R_E_C_N_O_		= ZP5.R_E_C_N_O_ "  
		cQry += " 	AND ZP6.D_E_L_E_T_		= ZP5.D_E_L_E_T_ "
		cQry += " INNER JOIN  "
		cQry += RetSqlName('ZP9') + " ZP9 WITH (NOLOCK) "
		cQry += " 	ON  ZP6.ZP6_FILIAL		= ZP9.ZP9_FILIAL "
		cQry += " 	AND ZP6.ZP6_NUM			= ZP9.ZP9_NUM "
		cQry += " 	AND ZP6.ZP6_ITEM		= ZP9.ZP9_ITEM "
		cQry += " 	AND ZP9.ZP9_COR			= ZP9.ZP9_COR "
		cQry += " 	AND ZP9.R_E_C_N_O_		= ZP9.R_E_C_N_O_ "  
		cQry += " 	AND ZP6.D_E_L_E_T_		= ZP9.D_E_L_E_T_ "
		cQry += " INNER JOIN  "
		cQry += RetSqlName('SB1') + " SB1 WITH (NOLOCK) "
		cQry += " 	ON  ' '					= SB1.B1_FILIAL "
		cQry += " 	AND ZP9.ZP9_CODPRO		= SB1.B1_COD "
		cQry += " 	AND SB1.R_E_C_N_O_		= SB1.R_E_C_N_O_ "  
		cQry += " 	AND ZP9.D_E_L_E_T_		= SB1.D_E_L_E_T_ "
		cQry += " WHERE "
		cQry += " 	ZP6.ZP6_FILIAL IN (' " + xFilial("ZP6") + " ') "
		cQry += " 	AND ZP6.ZP6_NUM = '" + cNum + "' " 
		cQry += " 	AND ZP6.D_E_L_E_T_ = ''  "
		cQry += getOrd(cTipo)  
	endif
return(cQry)


static function getFld(cTipo)
	local cFld		:= ''
	default cTipo	:= 'item'
	cFld += " 'PORTAL'					AS [ORIGEM],
	cFld += " ZP6.ZP6_FILIAL			AS [FILIAL],
	if cTipo == 'item'
		cFld += " CONVERT(varchar(20),cast (ZP5.ZP5_DATA as datetime),103) AS [EMISSAO]," 
		cFld += " ZP6.ZP6_NUM			AS [NUMERO], "
		cFld += " ZP6.ZP6_ITEM			AS [ITEM],  "
		cFld += " ZP9.ZP9_CODPRO		AS [COD_PROD], "
		cFld += " ZP9.ZP9_POSHPH		AS [POSHIP], "
		cFld += " SB1.B1_DESC			AS [PRODUTO],
		cFld += " SUM(ZP6.ZP6_PRCMIN)	AS [PRECO_MIN_VENDA], "
		cFld += " SUM(ZP6.ZP6_PRCSUG)	AS [PRECO_SUG_VENDA], "
		cFld += " SUM(ZP6.ZP6_PRCAPR)	AS [PRECO_APR_VENDA], "
		cFld += " SUM(ZP6.ZP6_QUANT)	AS [QTD_VEND], "
	elseif cTipo == 'total'
		cFld += " SUM(ZP6.ZP6_PRCMIN)	AS [PRECO_MIN_VENDA], "
		cFld += " SUM(ZP6.ZP6_PRCSUG)	AS [PRECO_SUG_VENDA], "
		cFld += " SUM(ZP6.ZP6_PRCAPR)	AS [PRECO_APR_VENDA], "
		cFld += " SUM(ZP6.ZP6_QUANT)	AS [QTD_VEND],	"
	endif
return(cFld)


static function getOrd(cTipo)
	local cOrd		:= ''
	default cTipo	:= 'item'
	if cTipo == 'item'
		cOrd += " GROUP BY "
		cOrd += " 	ZP6.ZP6_FILIAL, ZP5.ZP5_DATA, ZP6.ZP6_NUM, ZP6.ZP6_ITEM, ZP9.ZP9_CODPRO,SB1.B1_DESC "
		cOrd += " ORDER BY  "
		cOrd += " 	ZP6.ZP6_FILIAL, ZP5.ZP5_DATA, ZP6.ZP6_NUM, ZP6.ZP6_ITEM "
	elseif cTipo == 'total'
		cOrd += " GROUP BY "
		cOrd += " 	ZP6.ZP6_FILIAL "
		cOrd += " ORDER BY  "
		cOrd += " 	ZP6.ZP6_FILIAL "
	endif
return(cOrd)
