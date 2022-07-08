#include 'protheus.ch'
#include 'parmtype.ch'

user function zVlValPr(_dDtEntr)
	local nX	:= 0
	local aArea	:= getArea()
	if IsInCallStack('A440Libera') .and. IsInCallStack('u_AvalPrz')
		for nX:= 1 to Len(aCols)		
			if !GDDeleted(nX)
				GDFieldPut("C6_ENTREG",_dDtEntr,nX)
			endif
		next nX
	endif
	restArea(aArea)
return (nil)