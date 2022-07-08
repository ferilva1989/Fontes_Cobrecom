#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYBob(cEmp, cProduto, cPedido)
	local cQry 		:= ''
	default cEmp		:= '' 
	default cProduto 	:= ''
	default cPedido		:= ''

	cQry += " SELECT 
	cQry += " ZE_NUMBOB AS [NUM_BOB],
	cQry += " ZE_QUANT  AS [ZE_QUANT],
	cQry += " ZE_DESVIO AS [ZE_DESVIO]
	cQry += " FROM 
	cQry +=   RetSqlName('SZE') + " WITH (NOLOCK) "
	cQry += " WHERE

	if empty(cEmp)
		cQry += " ZE_FILIAL IN ('01','02','03')
	else
		cQry += " ZE_FILIAL = '" + cEmp + "' "
	endif
	if empty(cPedido)
		cQry += " AND ZE_STATUS = 'T'
	endif
	if !empty(cProduto)
		cQry += " AND ZE_PRODUTO = '" + cProduto + "' "
	endif
	if !empty(cPedido)
		cQry += " AND ZE_PEDIDO = '" + cPedido + "' "
	endif
	cQry += " AND D_E_L_E_T_ <> '*'
return(cQry)