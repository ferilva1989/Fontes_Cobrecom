#include 'protheus.ch'
#include 'parmtype.ch'

user function MTA500QRY()
	local aArea 	as array 
	local cFiltro 	as character
	aArea 	:= GetArea()
	cFiltro := ''
	if !isInCallStack('U_ZCBVIEWPED')
		cFiltro := " ( SELECT COUNT(*) FROM "+ RetSqlName('SC5') + ;
		" WHERE C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND  C5_X_IDVEN = '' AND D_E_L_E_T_= ''  ) = 1  "
	endif
	Restarea(aArea)
return(cFiltro)
