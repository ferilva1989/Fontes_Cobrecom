#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQrBobEstoque(cCod)
	local cQry 		:= ''
	default cCod	:= ''
	cCod := StrTran(cCod, 'Q', '')
	cQry += " SELECT "
	cQry += " ZE_FILIAL AS FILIAL, "
	cQry += " ZE_NUMBOB AS NRO_BOBINA, "
	cQry += " ZE_PRODUTO AS PRODUTO, "
	cQry += " ZE_DESCPRO AS DESCRICAO, "
	cQry += " ZE_QUANT AS QUANTIDADE, "
	cQry += " ZE_DATA  AS DATA, "
	cQry += " ZE_PEDIDO AS PEDIDO, "
	cQry += " ZE_NOMCLI AS CLIENTE, "
	cQry += " ZE_BOBORIG AS BOB_ORI, "
	cQry += " ZE_DTINV AS INVENTARIO "
	cQry += " FROM " + RetSqlName('SZE')
	cQry += " WHERE " 
	cQry += " ZE_FILIAL IN ('" + FwFilial() + "')" 
	cQry += " AND ZE_STATUS = 'T' "
	cQry += " AND ZE_QUANT > 0 "
	if !empty(cCod)
		cQry += " AND ZE_PRODUTO = '" + cCod + "' "
	endif
	cQry += " AND D_E_L_E_T_ = '' "
	cQry += " ORDER BY "
	cQry += " ZE_FILIAL, "
	cQry += " ZE_PRODUTO ASC "
return(cQry)