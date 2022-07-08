#include 'totvs.ch'

// C6_ACONDIC + StrZero(C6_METRAGE, cLocaliza)
static cLocaliza := '5'


class cbcC9Model from cbcGenModel
	data nQtdOk
	data dEntItem
	data lHaveCurve
	data lCurve
	data cObsEmp
	method newcbcC9Model() constructor
	
	method getCodProd()
	method getNroPedido()
	method getItemPedido()
	method getQtdLiberada()
	method getLance()
	method getMetragem()
	method getAcond()
	method setAcond()
	method getArmazem()
	method getDtFat()
	method getEntrItem()
	method getCliLoja()
	method getNrResItem()
	method getSeqC9()
	method getQtdVend()
	method getPrcVend()
	method getTipoLib()
	method isParcial()
	method setParcial()
	method prodCurva()
	method getLocaliz()
	method getDisponivel()
	method getQtdEmp()
	method calcMult()
	method liberItem()
	
	method getEntItem()
	method setEntItem()
	
	method getQtdOk()
	method setQtdOk()
	
	method getObsEmp()
	method setObsEmp()
	
endclass


method newcbcC9Model() class cbcC9Model
	::newcbcGenModel()
	::setQtdOk()
	::lHaveCurve := .F.
	::setObsEmp()
return(self)

method getCodProd() class cbcC9Model
	local xRet := ::getValue('SC9', 'C9_PRODUTO')
return(xRet)

method getNroPedido() class cbcC9Model
	local xRet	:=  ::getValue('SC9', 'C9_PEDIDO')
return(xRet)

method getItemPedido() class cbcC9Model
	local xRet	:= ::getValue('SC9', 'C9_ITEM')
return(xRet)

method getQtdLiberada() class cbcC9Model
	local xRet	:= ::getValue('SC9', 'C9_QTDLIB')
return(xRet)

method isParcial() class cbcC9Model
	local lRet := .T.
	lRet :=  Alltrim(::getValue('SC5', 'C5_PARCIAL')) == 'S'
return(lRet)

method getLance() class cbcC9Model
	local xRet := ::getValue('SC6', 'C6_LANCES')
return(xRet)

method getMetragem() class cbcC9Model
	local xRet := ::getValue('SC6', 'C6_METRAGE')
return(xRet)

method getAcond() class cbcC9Model
	local xRet	:= ::getValue('SC6', 'C6_ACONDIC')
return(xRet)

method getArmazem() class cbcC9Model
	local xRet := ::getValue('SC9', 'C9_LOCAL')
return(xRet)

method getDtFat() class cbcC9Model
	local xRet := ::getValue('SC5', 'C5_DTFAT')
return(xRet)

method getEntrItem() class cbcC9Model
	local xRet	:= ::getValue('SC6', 'C6_ENTREG')
return(xRet)

method getCliLoja() class cbcC9Model
	local xRet := ::getValue('SC9', 'C9_CLIENTE + C9_LOJA')
return(xRet)

method getNrResItem() class cbcC9Model
	local xRet := ::getValue('SC6', 'C6_RES_SZZ + C6_ITE_SZZ')
return(xRet)

method getSeqC9() class cbcC9Model
	local xRet := ::getValue('SC9', 'C9_SEQUEN')
return(xRet)

method getQtdVend() class cbcC9Model
	local xRet := ::getValue('SC6', 'C6_QTDVEN')
return(xRet)

method getPrcVend() class cbcC9Model
	local xRet := ::getValue('SC6', 'C6_PRCVEN')
return(xRet)

method getTipoLib() class cbcC9Model
	local xRet := ::getValue('SC5', 'C5_TIPOLIB')
return(xRet)

method getLocaliz() class cbcC9Model
	local xRet := ::getValue('SC6', 'C6_ACONDIC + StrZero(C6_METRAGE,'+ cLocaliza +')')
return(xRet)


method getDisponivel() class cbcC9Model
	local xRet := ::getValue('SBF', ' SBF->BF_QUANT - SBF->BF_EMPENHO ')
return(xRet)


method getEntItem() class cbcC9Model
return(::dEntItem)


method setEntItem(dData) class cbcC9Model
	default dData := ::getDtFat()
	::dEntItem := dData
return(self)


method prodCurva(lForceUpd) class cbcC9Model
	local oCurve 		:= Nil
	local lCurva		:= .F.
	local nRecZZZ		:= 0
	default lForceUpd	:= .F.
	
	if  !(::lHaveCurve) .or. lForceUpd
		if ( lCurva := ( (nRecZZZ := ::getRecno('ZZZ') ) > 0 ) )
			oCurve 	:= cbcJsFld():newcbcJsFld()
			lCurva 	:= oCurve:isCurve(,::getLocaliz(),nRecZZZ)
			FreeObj(oCurve)
		endif
		::lCurve		:= lCurva
		::lHaveCurve 	:= .T.
	else
		lCurva := ::lCurve
	endif
	
return(lCurva)


method getQtdEmp() class cbcC9Model
	local nQtd	:= 0
	nQtd := ::calcMult(::getQtdLiberada())
return(nQtd)


method calcMult(nValor) class cbcC9Model
	local nQtd		:= 0
	default 	nValor := 0
	if nValor > 0
		nQtd := ( nValor / ::getLance() ) * ::getLance()
	endif
return(nQtd)


method getQtdOk() class cbcC9Model
return(::nQtdOk)

method setQtdOk(nQtd) class cbcC9Model
	default nQtd := 0
	::nQtdOk := nQtd
return(self)


method getObsEmp() class cbcC9Model
return(::cObsEmp)


method setObsEmp(cTxt) class cbcC9Model
	default cTxt := ''
	::cObsEmp := cTxt
return(self)


method liberItem() class cbcC9Model
	/*
	_nTmLce := Val(Substr(_cLocz2,2,5))
	// Pega o menor dos dois
	_nQtdALib := Min(SC9->C9_QTDLIB,(SBF->BF_QUANT - SBF->BF_EMPENHO))
	
	// Libertar somente o múltiplo do acondicionamento
	_nQtdALib := Int((_nQtdALib / _nTmLce))
	_nQtdALib := (_nQtdALib * _nTmLce)
	
	If _nQtdALib > 0
		U_CDLibEst("L",SC9->C9_PRODUTO,_nQtdALib,;
			SC9->C9_LOCAL,_cLocz2,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"C")
	EndIf
	*/
	
return (self)

