#include 'protheus.ch'

class cbcMethUtils 
	data oSqlTemp
	data cTmpAls
	data lTemTab
	method newcbcMethUtils() constructor 
	method nextAlias()
	method getTmpAls()
	method prepEmp()
	method delTab()
	method tmpFrmArr()

endclass


method newcbcMethUtils() class cbcMethUtils
	::cTmpAls := ''
	::lTemTab := .F.
return(self)


method nextAlias() class cbcMethUtils
	local cAls := ''
	while .T.
		cAls := GetNextAlias()
		if (Select(cAls) <= 0)
			exit
		endIf
	endDo
return(cAls)


/*
	aTmp[NOME_CAMPO]
	aTmp[TIPO_CAMPO]
	aTmp[TAM_CAMPO]
	aTmp[DECIMAL_CAMPO]
	aadd(aFlds, aTmp )
*/

method prepEmp (aIndex, aFlds, cQry) class cbcMethUtils
	local cAls		:= ::nextAlias()
	local nX		:= 0
	default aFlds	:= {}
	if !empty(aFlds)
		::oSqlTemp	:= FWTemporaryTable():New(::nextAlias())
		::lTemTab := .T.
		::oSqlTemp:SetFields( aFlds )
		::oSqlTemp:AddIndex("01", aIndex )
		::oSqlTemp:Create()
		::oSqlTemp:executeQuery(cQry, cAls, aFlds)
		::cTmpAls := ::oSqlTemp:getAlias()
		(cAls)->(DbSelectArea((cAls)))
		(cAls)->(DbGoTop())
		while !((cAls)->(EOF()))
			(::cTmpAls)->(RecLock((::cTmpAls), .T.))
			for nX := 1 to (cAls)->(fcount())
				(::cTmpAls)->(&((cAls)->(fieldname(nX)))) := (cAls)->(fieldget(nX))
			next
			(::cTmpAls)->(MsUnLock())
			(cAls)->(DBSkip())
		enddo
		(cAls)->(DbCloseArea())
	endif
return(self)


method tmpFrmArr() class cbcMethUtils

return(self)


method getTmpAls() class cbcMethUtils
return(::cTmpAls)


method delTab() class cbcMethUtils
	if ::lTemTab
		::oSqlTemp:Delete()
	endif
return(self)
