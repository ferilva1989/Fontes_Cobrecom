#include 'protheus.ch'
#include 'parmtype.ch'


user function cbcQRYfaixaRg(aFaixa, cMes, cAno)
	local cQry		:= ''
	default cMes	:= ' DATEPART( month, GETDATE()) '
	default cAno	:= ' DATEPART( year, GETDATE())  '
	cQry += " SELECT "
	cQry += " 	ORIGEM.FAIXA, "
	cQry += " 	SUM(ORIGEM.TOTAL) AS TOTAL "
	cQry += " 	FROM  "
	cQry += " (  "
	cQry += " SELECT  " 
	cQry += " SC6.C6_NUM							AS [PEDIDO],  "
	cQry += " SUM(SC6.C6_PRCVEN * SC6.C6_QTDVEN)	AS [TOTAL],  "
	cQry += " ISNULL(round(((((SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) ) * 100) / NULLIF( SUM(SC6.C6_QTDVEN * SC6.C6_CSTUNRG),0) )-100),2), 0) AS [RG], "
	cQry += getCase( formatFaixa(aFaixa) )
	cQry += " FROM  "
	cQry += RetSqlName('SC6') + " SC6 WITH (NOLOCK)  "
	cQry += " INNER JOIN  " 
	cQry += RetSqlName('SC5') + " SC5 WITH (NOLOCK)  "
	cQry += " ON  SC6.C6_FILIAL		= SC5.C5_FILIAL  "
	cQry += " AND SC6.C6_NUM		= SC5.C5_NUM  "
	cQry += " AND SC5.R_E_C_N_O_	= SC5.R_E_C_N_O_  "  
	cQry += " AND SC6.D_E_L_E_T_	= SC5.D_E_L_E_T_  "
	cQry += " INNER JOIN  "
	cQry +=  RetSqlName('SA1') + " SA1 WITH (NOLOCK)  "
	cQry += " ON '" + xFilial('SA1') + "' = SA1.A1_FILIAL "
	cQry += " AND SC5.C5_CLIENTE	= SA1.A1_COD "
	cQry += " AND SC5.C5_LOJACLI	= SA1.A1_LOJA "
	cQry += " AND SA1.R_E_C_N_O_	= SA1.R_E_C_N_O_ "
	cQry += " AND SC5.D_E_L_E_T_	= SA1.D_E_L_E_T_ "
	cQry += " INNER JOIN  "
	cQry +=  RetSqlName('SF4') + " SF4 WITH (NOLOCK)  "
	cQry +=  " ON '" + xFilial('SF4') + "' = SF4.F4_FILIAL "
	cQry +=  " AND SC6.C6_TES		= SF4.F4_CODIGO "
	cQry +=  " AND SF4.R_E_C_N_O_	= SF4.R_E_C_N_O_ "
	cQry +=  " AND SC6.D_E_L_E_T_	= SF4.D_E_L_E_T_ "
	cQry += " INNER JOIN  "
	cQry +=  RetSqlName('SB1') + " SB1 WITH (NOLOCK)  "
	cQry += " ON  '" + xFilial('SB1') + " '	= SB1.B1_FILIAL  "
	cQry += " AND SC6.C6_PRODUTO		= SB1.B1_COD  "
	cQry += " AND SB1.R_E_C_N_O_		= SB1.R_E_C_N_O_  "  
	cQry += " AND SC6.D_E_L_E_T_		= SB1.D_E_L_E_T_  "
	cQry += " WHERE  "
	cQry += " SC6.C6_FILIAL IN ('01','02','03')  "
	cQry += " AND SC6.C6_CF		NOT IN ('6151','6152','6901','6124','6902') "
	cQry += " AND SC5.C5_TIPO	= 	'N' "
	cQry += " AND  DATEPART(month,CONVERT(DATETIME,SC5.C5_EMISSAO)) = " + cMes
	cQry += " AND  DATEPART(year,CONVERT(DATETIME,SC5.C5_EMISSAO)) = "  + cAno
	cQry += " AND SA1.A1_VISVEND <> 'N' "
	cQry += " AND SF4.F4_DUPLIC	=	'S' "
	cQry += " AND SC6.D_E_L_E_T_ = ''  "
	cQry += " GROUP BY  "
	cQry += " SC6.C6_FILIAL, SC6.C6_NUM  "
	cQry += " ) AS ORIGEM  "
	cQry += " GROUP BY  " 
	cQry += " ORIGEM.FAIXA  "
	cQry += " ORDER BY  " 
	cQry += " ORIGEM.FAIXA  "
return(cQry)


static function formatFaixa(aFaixa) // { {'-5', '0'}, {'0', '2'}, {'2', '3'} }
local aRet		:= {}
local nX		:= 0
default aFaixa	:= {}
	for nX := 1 to len(aFaixa)
		aadd(aRet, {"[" + aFaixa[nX,1] + " ate " + aFaixa[nX,2] + "]", aFaixa[nX,1], aFaixa[nX,2]} )
	next nX
return(aRet)


static function getCase(aFaixa)
	local cCase		:= ''
	local nX		:= 0
	local nTam		:= 0
	local nCase		:= 0
	default aFaixa	:= {}
	nTam	:= len(aFaixa)
	if !empty(aFaixa)
		cCase += " CASE "
		for nX := 1 to nTam
			cCase += " WHEN " 
			cCase += " ISNULL(round(((((SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) ) * 100) / NULLIF( SUM(SC6.C6_QTDVEN * SC6.C6_CSTUNRG),0) )-100),2), 0) "   
			cCase += " BETWEEN " + aFaixa[nX,2] + " AND " + aFaixa[nX,3]
			cCase += " 	THEN 
			cCase += "' " + aFaixa[nX,1] + "' "
			if nX < nTam
				cCase += " 	ELSE " 	
				cCase += " 		CASE "
				nCase ++	
			endif
			if nX == nTam
				cCase += " 	ELSE "
				cCase += " '[OUTRAS]' "
			endif
		next nX
		
		for nX := 1 to nCase 
			cCase += " END "
		next nX
		
		cCase += " END AS [FAIXA] "
	endif
return(cCase)

