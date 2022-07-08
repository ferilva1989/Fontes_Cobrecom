#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQrEsaEstoque(cProd)
	local cQry := 'SELECT * FROM [dbo].[ESA_DISPONIVEL]'
	default cProd := ''
	cProd := StrTran(cProd, 'Q', '')
	if !empty(cProd)
		cQry += " WHERE " 
		cQry += " FILIAL = '" + fwFilial() + "' "
		cQry += " AND PRODUTO = 'Q' + '" + cProd + "' "
		cQry += " AND ESA_DISPONIVEL > 0 "
	endif	
return(cQry)