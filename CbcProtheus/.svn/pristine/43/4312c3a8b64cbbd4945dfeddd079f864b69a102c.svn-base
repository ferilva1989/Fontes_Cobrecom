#include 'protheus.ch'

class cbcFiliais
	
	data cBkFil
	
	method newcbcFiliais() constructor
	method setFilial()
	method backFil()
	
endclass

method newcbcFiliais() class cbcFiliais
	
return

method setFilial(cParamFil) class cbcFiliais
	Local lRet := .T.
	cParamFil := Padr(cParamFil, FWSizeFilial())
	If !FWFilExist('01', cParamFil )
		lRet := .F.
	Else
		If cParamFil <> cFilAnt
			::cBkFil := cFilAnt
			cFilAnt := cParamFil
			SM0->(DbSeek(cEmpAnt + cFilAnt))
		EndIf
	EndIf
return lRet

method backFil() class cbcFiliais
	If !Empty(::cBkFil)
		::setFilial(::cBkFil)
	EndIf
return (self)

/* TEST ZONE */
user function zcbcBrnc()
	local oFil	:= cbcFiliais():newcbcFiliais()
	oFil:setFilial('02')
	oFil:setFilial('01')
	oFil:setFilial('02')
	oFil:backFil()
	FreeObj(oFil)
return(nil)
