#include 'totvs.ch'

#define TABELA 1
#define VALOR 2

class cbcGenModel from cbcLockCtrl
	data aRec
	data lOk
	data cMsgErro
	
	method newcbcGenModel() CONSTRUCTOR
	method getRecno()
	method addRecno()
	method prepTab()
	method getValue()
	method lockAll()
	method lockOne()

endclass


method newcbcGenModel() class cbcGenModel
	/*
		HERANÇA cbcLockCtrl
		::setResult()
		::okLock()
		::getErr()
		::prepLock()
		::libLock()
		::qryToRec()
		::lockFrmQry()
	*/
	::addRecno()
	::newcbcLockCtrl()
return(nil)


method addRecno(aTabVlr) class cbcGenModel
	local nPos 		:= 0
	default aTabVlr 	:= ''
	
	if empty(aTabVlr)
		::aRec := {}
	else
		if len(aTabVlr) <>  2
			::setResult(.F., '[cbcGenModel] - Parametro deve contem apenas duas posições!')
		elseif (nPos := aScan(::aRec, {|rec| rec[TABELA] == aTabVlr[TABELA]  })) > 0
			::aRec[nPos,VALOR] := aTabVlr[VALOR]
		else
			aadd(aTabVlr, .T.)
			aadd(::aRec, aTabVlr)
		endif
	endif
return(self)


method getRecno(cTab) class cbcGenModel
	local nRec := 0
	local nPos := 0
	if (nPos := aScan(::aRec, {|rec| rec[TABELA] == cTab }) ) > 0
		nRec := ::aRec[nPos,VALOR]
	endif
return(nRec)


method prepTab()   class cbcGenModel
	local nX	:= 0

	if !empty(::aRec)
		for nX := 1 to len(::aRec)
			DbSelectArea( (::aRec[nX,1]) )
			(::aRec[nX,1])->(DbGoTo(::aRec[nX,2]))
		next nX
	endif
return(self)


method getValue(cTabela, cCampo)  class cbcGenModel
	local xValue 		:= ''
	local nRec		:= 0
	default cTabela	:= ''
	default cCampo	:= ''

	if ! empty(nRec := ::getRecno(cTabela))
		(cTabela)->(DbGoto(nRec))
		xValue := (cTabela)->(&(cCampo))
	endif
return (xValue)


method lockAll() class cbcGenModel
	local lOk	:= .F.
	lOk := ::prepLock(::aRec):okLock()
	// ::getErr()
return(lOk)


method lockOne(cTab) class cbcGenModel
	local lOk	:= .F.
	local nPos	:= 0
	default cTab 	:= ''
	if ! empty(cTab)
		
		if (nPos := aScan(::aRec, {|rec| rec[TABELA] == cTab } ) ) > 0
			lOk := ::prepLock( { ::aRec[nPos] }  ):okLock()
		endif
	
	endif
return(lOk)