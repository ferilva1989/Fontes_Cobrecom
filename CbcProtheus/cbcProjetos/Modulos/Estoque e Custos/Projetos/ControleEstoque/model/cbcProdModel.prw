#include 'totvs.ch'

class cbcProdModel

	data nRecBF
	data cCodProd
	data lAtendido
	data nNecessario
	data nSldOrig
	data nsaldo
	data nSimulSaldo
	data nQtdVend
 
	method newcbcProdModel() constructor
	
	method getRecBF()
	method checkAtend()
	
	method empSaldo()
	method resetSaldo()

endclass


method newcbcProdModel() class cbcProdModel
	::lAtendido 		:= .F.
	::nNecessario		:= 0
	::nSldOrig		:= 0
	::nsaldo			:= 0
	::nSimulSaldo		:= 0
	::nQtdVend		:= 0
return(self)


method checkAtend() class cbcProdModel
	// TODO Lock do SBF
	DbSelectArea('SBF')
	SBF->(DbGoTo(::nRecBF))
	::nSldOrig		:= SBF->(SBF->BF_QUANT - SBF->BF_EMPENHO) 
	::nsaldo 		:= if(::nSldOrig <= ::nNecessario,::nSldOrig,::nNecessario )
	// TODO Retirar saldo do SBF ( mesma logica ::nsaldo ) 
	::nSimulSaldo 	:= ::nsaldo 
	::lAtendido 		:= ( ::nsaldo >= ::nNecessario )
return(::lAtendido)


method empSaldo(oPed,oItem,lSimulado) class cbcProdModel
	local nVlrCons	:= 0
	local cTxtLib		:= 'SEM SALDO PARA LIBERAR'
	local lRet		:= .F.
	default lSimulado	:= .F.
	nValor 			:= oItem:getQtdEmp()
	
	if nValor > 0 .and. ::nSimulSaldo > 0  
		if nValor > ::nSimulSaldo
			if oPed:isParcial()
				nVlrCons := oItem:calcMult(::nSimulSaldo)
				if !lSimulado
					cTxtLib := 'ITEM LIBERADO PARCIAL' 
					cTxtLib += ' NECESSARIO: ' + cValToChar(nValor)
					cTxtLib += ' LIBERADO: ' + cValToChar(nVlrCons)
				endif
			else
				if !lSimulado
					cTxtLib := 'DISPONIVEL SALDO PARCIAL, MAS CLIENTE NÂO ACEITA'
					cTxtLib += ' NECESSARIO: ' + cValToChar(nValor)
					cTxtLib += ' LIBERADO: ' + cValToChar(nVlrCons)
				endif
			endif
		else
			
			nVlrCons := nValor
		
			if !lSimulado
				cTxtLib := 'LIBERADO'
			endif
		
		endif
	endif
	::nSimulSaldo -= nVlrCons
	
	if lSimulado
		lRet := ( nVlrCons > 0 )
	else
		oItem:setQtdOk(nVlrCons)
		oItem:setObsEmp(cTxtLib)
	endif
	
return(lRet)


method resetSaldo() class cbcProdModel
	::nSimulSaldo := ::nsaldo
return(self)


method getRecBF() class cbcProdModel
return(::nRecBF)
