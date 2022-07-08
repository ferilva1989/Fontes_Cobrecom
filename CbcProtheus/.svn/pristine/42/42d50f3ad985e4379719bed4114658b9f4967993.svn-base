#include 'protheus.ch'
#include 'parmtype.ch'

user function M410FSQL()
	local aArea 	as array 
	local cFiltro 	as character
	aArea 	:= GetArea()
	cFiltro := ''
	if !isInCallStack('U_ZCBVIEWPED')
		cFiltro := 'Empty(C5_X_IDVEN)'
	endif
	Restarea(aArea)
return (cFiltro)
