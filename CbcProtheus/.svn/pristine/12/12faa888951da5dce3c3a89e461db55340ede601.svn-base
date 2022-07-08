#include 'totvs.ch'

class cbcPedModel from cbcGenModel
	
	data aItem
	data lAll
	data nTotGeral
	data nTotCurvaGeral
	data nTotLibC9
	data nLibTotRotina
	data nCurvaTotRotina
	data lSortedItem
	data cOrderSort
	
	method newcbcPedModel() constructor
	method getNroPedido()
	method isParcial()
	method getDtFat()
	method getDtEntr()
	method setSortOrder()
	method getSortOrder()
	method sortItem()
	method setAll()
	method isAll()
	method totalLib()
	method estatistica()
endclass


method newcbcPedModel() class cbcPedModel
	::newcbcGenModel()
	::aItem 			:= {}
	::setAll()
	::nTotGeral		:= 0
	::nTotCurvaGeral	:= 0
	::nTotLibC9		:= 0
	::nLibTotRotina	:= 0
	::nCurvaTotRotina	:= 0
	::lSortedItem		:= .F.
	::cOrderSort		:= ''
return(self)


method getNroPedido() class cbcPedModel
	local xRet	:=  ::getValue('SC5', 'C5_NUM')
return(xRet)


method isParcial() class cbcPedModel
	local lRet := .T.
	lRet :=  Alltrim(::getValue('SC5', 'C5_PARCIAL')) == 'S'
return(lRet)


method getDtFat() class cbcPedModel
	local lRet := .T.
	lRet := ::getValue('SC5', 'C5_DTFAT')
return(lRet)


method getDtEntr() class cbcPedModel
	local lRet := .T.
	lRet := ::getValue('SC5', 'C5_ENTREG')
return(lRet)


method setSortOrder() class cbcPedModel
	::cOrderSort	:= ''
	::cOrderSort 	+= if (::isParcial(), 'SIM', 'NAO')
	::cOrderSort	+= (Dtos(::getDtFat()) + cValToChar(::getRecno('SC5')) )
return(self)


method getSortOrder() class cbcPedModel
return(::cOrderSort)


method sortItem() class cbcPedModel
	if ! ::isParcial()
		ASort(::AITEM, , ,{ |a,b| (a:prodCurva() < b:prodCurva()) } )
	endif
	::lSortedItem := .T.
return(self)


method setAll(lVlr) class cbcPedModel
	default lVlr := .F.
	::lAll := lVlr
return(self)


method isAll() class cbcPedModel
return(::lAll)


method totalLib() class cbcPedModel
	local nX			:= 0
	local oPed		:= nil
	local nTotalLib	:= 0
	local nVlr		:= 0
	
	::nLibTotRotina	:= 0
	::nCurvaTotRotina	:= 0
	
	for nX := 1 to Len(::AITEM)
		oPed := ::AITEM[nX]
		nVlr := (oPed:getQtdOk() * oPed:getPrcVend())
		if oPed:prodCurva()
			::nCurvaTotRotina += nVlr
		endif
		::nLibTotRotina += nVlr
	next nX
	
return(self)


method estatistica() class cbcPedModel
	local oPed	:= nil
	
	
	// Obtem totais partindo numero do pedido
	oPed := cbcModOrder():newcbcModOrder( ::getNroPedido() )
	::nTotGeral		:= oPed:getSalesTotal()
	::nTotCurvaGeral	:= oPed:getTotCurva()
	::nTotLibC9		:= oPed:getTotLib()
	FreeObj(oPed)
	
	// Totais produzidos nesta rotina (::nLibTotRotina  e ::nCurvaTotRotina)
	::totalLib()
	
return(self)
