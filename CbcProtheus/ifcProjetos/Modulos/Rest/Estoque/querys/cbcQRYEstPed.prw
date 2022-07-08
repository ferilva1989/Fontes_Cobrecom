#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcQRYEstPed(cFato)
	local cQry		:= ''
	default cFato	:= ''
	cQry  += "SELECT * FROM dbo.BI_VW_ESTEMPFAT "
	if !empty(cFato)
		cQry  += " WHERE FATO = '" + cFato + "' "
	endif
return(cQry)
