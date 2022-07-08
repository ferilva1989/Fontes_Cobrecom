#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYcliente(cCnpjRoot)
	local cQry			:= ''
	default cCnpjRoot	:= ''
	if !empty(cCnpjRoot)
		cQry  += " SELECT "  
		cQry  += getFld() 
		cQry  += " FROM "
		cQry  += " ( "
		cQry  += " 	SELECT " 
		cQry  += " 	SA1.A1_COD		AS [COD_CLIENTE], "
		cQry  += "  SA1.A1_LOJA		AS [LOJA_CLIENTE], "
		cQry  += "  SA1.A1_NOME		AS [NOME_CLIENTE], "
		cQry  += "  SA1.A1_CGC		AS [CNPJ],	 "
		cQry  += " CASE  "
		cQry  += "  WHEN  (CAST( SE1.E1_VENCREA AS DATE ) > GETDATE()) AND (SE1.E1_BAIXA = '') "   
		cQry  += "   THEN  "
		cQry  += "    ISNULL(SUM(SE1.E1_SALDO), 0 ) " 
		cQry  += "   ELSE  "
		cQry  += "    0  "
		cQry  += "  END AS [VENCER] , "
		cQry  += " CASE  "
		cQry  += "   WHEN  (CAST( SE1.E1_VENCREA AS DATE ) < GETDATE()) AND (SE1.E1_BAIXA = '') "   
		cQry  += "    THEN  "
		cQry  += "     ISNULL(SUM(SE1.E1_SALDO), 0 ) " 
		cQry  += "   ELSE  "
		cQry  += "     0  "
		cQry  += "   END AS [ATRASADO] , "
		cQry  += "   CASE 
		cQry  += "   	WHEN  (CAST( SE1.E1_VENCREA AS DATE ) < GETDATE()) AND (SE1.E1_BAIXA = '')   
		cQry  += "   		THEN 
		cQry  += "   			DATEDIFF(day,CAST( SE1.E1_VENCREA AS DATE ), GETDATE())
		cQry  += "   		ELSE 
		cQry  += "   		0 
		cQry  += "   END AS [DIAS_ATRASO] ,
		cQry  += " CASE  "
		cQry  += "   WHEN  SE1.E1_BAIXA NOT IN ('') "   
		cQry  += "    THEN  "
		cQry  += "     ISNULL(SUM(SE1.E1_VALOR) - SUM(SE1.E1_SALDO), 0 ) " 
		cQry  += "    ELSE  "
		cQry  += "     0  "
		cQry  += "   END AS [PAGO] "
		cQry  += " FROM  "
		cQry  +=  RetSqlName('SA1') + " SA1 WITH (NOLOCK) "
		cQry  += " INNER JOIN " + RetSqlName('SE1')+ " SE1 WITH (NOLOCK) "
		cQry  += " 		ON  SE1.E1_FILIAL IN ('01','02', '03') "
		cQry  += " 		AND SA1.A1_COD		= SE1.E1_CLIENTE "
		cQry  += " 		AND SA1.A1_LOJA		= SE1.E1_LOJA "
		cQry  += " 		AND SE1.E1_STATUS	= SE1.E1_STATUS "
		cQry  += " 		AND SE1.E1_VENCREA	= SE1.E1_VENCREA "
		cQry  += " 		AND SE1.R_E_C_N_O_	= SE1.R_E_C_N_O_ "
		cQry  += " 		AND SA1.D_E_L_E_T_	= SE1.D_E_L_E_T_ "
		cQry  += " WHERE "
		cQry  += " 		SA1.A1_FILIAL		IN ('') "
		cQry  += " 		AND SA1.A1_CGC		LIKE ('" + cCnpjRoot + "%') 
		cQry  += " 		AND SA1.A1_VISVEND	<> 'N' "
		cQry  += " 		AND SA1.D_E_L_E_T_	= '' "
		cQry  += " GROUP BY "
		cQry  += " SA1.A1_CGC,SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SE1.E1_BAIXA ,SE1.E1_VENCREA "
		cQry  += " ) AS FILTRO "
		cQry  += " GROUP BY FILTRO.CNPJ,FILTRO.COD_CLIENTE, FILTRO.LOJA_CLIENTE, FILTRO.NOME_CLIENTE "
		cQry  += " ORDER BY FILTRO.CNPJ,FILTRO.COD_CLIENTE, FILTRO.LOJA_CLIENTE, FILTRO.NOME_CLIENTE "
	endif
return(cQry)


static function getFld()
	local cFld		:= ''
	cFld += " FILTRO.COD_CLIENTE AS[CLIENTE], "
	cFld += " FILTRO.LOJA_CLIENTE AS [LOJA], "
	cFld += " FILTRO.NOME_CLIENTE	AS [NOME], "
	cFld += " SUM(FILTRO.VENCER) AS [VENCER], "
	cFld += " SUM(FILTRO.ATRASADO) AS [ATRASADO], "
	cFld += " ROUND(AVG(CONVERT(float,DIAS_ATRASO)),2) AS [MEDIA_ATRASO], "
	cFld += " SUM(FILTRO.PAGO) AS [PAGO] "	
return(cFld)

