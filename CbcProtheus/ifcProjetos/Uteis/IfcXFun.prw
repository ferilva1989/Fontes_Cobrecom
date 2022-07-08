#INCLUDE "protheus.ch"

Class IfcXFun
    Data nParCount
	Data aParRef
	Method newIfcXFun()
    Method callStatic()
	Method sP()
	Method pR()
	Method isRef()

End Class

Method newIfcXFun(nParCount) Class IfcXFun
	default nParCount := 10
	default aParRef := {}
	::sP(nParCount)
Return (self)


Method sP(nPar) Class IfcXFun
	default nPar := 10
	::aParRef	:= {}
	::nParCount := nPar
return self


Method pR(aPar) Class IfcXFun
	default aPar := {}
	::aParRef := aPar
return self


Method isRef(nPos) Class IfcXFun
	local cRet := ''
	default nPos := 0
	if len(::aParRef) > 0
		if (aScan(::aParRef, {|x| x == nPos}) > 0)
			cRet := '@'
		endif
	endif
return cRet

/*/{Protheus.doc} callStatic
Função que macroexecuta StaticCal(l), visto que a mesma não é compilada na versão 12.1.33
@author clementino 
@since 18/01/2022
@version 1
@param aParams {NomeFonte, NomeFunção, xParams}
@return xVar
@type Method
    /*/

Method callStatic(cFonte,cFunc,xPar1,xPar2,xPar3,xPar4,xPar5,xPar6,xPar7,xPar8,xPar9,xPar10) Class IfcxFun
    Local nX        := 0
    Local xVar      := Nil
    Private cString   := ""
  
	cString := "StaticCall(" + cFonte + ', ' + cFunc
	for nX := 1 to ::nParCount
		if  &('xPar'+cValToChar(nX))  == nil
			cString += ' , '
		else
			cString += ' , ' + ::isRef(nX) + 'xPar'+cValToChar(nX) 
		
		endif
	next
	cString += ')'
	xVar := &(cString)
Return xVar


/* TEST ZONE */
/* 
	Informar no newIfcXFun() a quantidade de parametros utilizados 
	apos o nomde do fonte e nome da função, parametros da função default é 10
*/
user function zxstTzon()
	local oStatic    := IfcXFun():newIfcXFun()
	local aTeste	:= {}
	local aTeste2	:= {}

	oStatic:sP(1):callStatic('ifcXFun', 'refStatic', @aTeste)
	oStatic:sP(2):callStatic('ifcXFun', 'refStatic', @aTeste, @aTeste2)
	alert('oi')
return  nil

static function refStatic(aRef)
	aRef := {'PASSE','AQUI'}
return nil

