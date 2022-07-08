#include 'protheus.ch'

/*/{Protheus.doc} cbcRegERS
Modelo dados representando registro CBCERS
@type class
@author bolognesi
@since 15/01/2018
@version 1.0
@description Classe modelo dados Registro CBCERS
/*/
class cbcRegERS FROM jsonTypes

	data cChaveUnq
	data cCodFil
	data dDtEmissao
	data cNomeCliente
	data cRepresentante
	data cNumero
	data nSaldo
	data nValorTotal

	data aFinanceiro
	data aConsumo
	data aPagamentos

	method newcbcRegERS() constructor

	method getChaveUnq()
	method setChaveUnq()
	method getCodFil()
	method setCodFil()
	method getDtEmissao()
	method setDtEmissao()
	method getNomeCliente()
	method setNomeCliente()
	method getNumero()
	method setNumero()
	method getSaldo()
	method setSaldo()
	method getValorTotal()
	method setValorTotal()
	method getRepresentante()
	method setRepresentante()
	method addParcela()
	method addConsumo()
	
	method sumParcela()
	method vldTotal()
	
endclass


/*/{Protheus.doc} newcbcRegERS
Construtor da classe
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Contrutor
/*/
method newcbcRegERS() class cbcRegERS
	::newjsonTypes()
	::aFinanceiro 	:= {}
	::aConsumo		:= {}
	::aPagamentos		:= {}
return ( self )


/*DEFINIÇÔES DO GETTERS E SETTERS DAS PROPRIEDADES*/
method getChaveUnq() class cbcRegERS
return ( ::cChaveUnq )


method setChaveUnq() class cbcRegERS
	local cBranch	:= ::getCodFil()
	local cNumber	:= ::getNumero()
	local cNewValue	:= ''
	if !empty(cBranch) .and. !empty(cNumber)
		cNewValue := (cBranch +  cNumber)
	endif
	::cChaveUnq := cNewValue
return( nil )


method getCodFil() class cbcRegERS
return ( ::cCodFil )


method setCodFil(CodFil) class cbcRegERS
	default CodFil := ''
	::cCodFil := CodFil
return ( self )


method getDtEmissao() class cbcRegERS
return ( ::dDtEmissao )


method setDtEmissao(dData) class cbcRegERS
	default dData := ' '
	::dDtEmissao := dData
return ( self )


method getNomeCliente() class cbcRegERS
return ( ::cNomeCliente )


method setNomeCliente(cNomeCli) class cbcRegERS
	default cNomeCli := ''
	::cNomeCliente := cNomeCli
return ( self )


method getNumero() class cbcRegERS
return ( ::cNumero )


method setNumero(cNum) class cbcRegERS
	default cNum := ''
	::cNumero := cNum
return ( self )


method getSaldo() class cbcRegERS
return ( ::nSaldo )


method setSaldo(nSaldo)class cbcRegERS
	default nSaldo := 0
	::nSaldo := nSaldo
return ( self )


method getValorTotal() class cbcRegERS
return ( ::nValorTotal )


method setValorTotal(nValor)class cbcRegERS
	default nValor := 0
	::nValorTotal := nValor
return ( self )


method getRepresentante() class cbcRegERS
return ( ::cRepresentante )


method setRepresentante(cRepres) class cbcRegERS
	default cRepres := ''
	::cRepresentante := cRepres
return ( self )


/*/{Protheus.doc} addParcela
Adiciona parcela do modelo cbcFinanceiro
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Adiciona parcela do modelo cbcFinanceiro
/*/
method addParcela(aParc) class cbcRegERS
	default aParc := {}
	if !empty(aParc)
		aadd( ::aFinanceiro, aParc )
	endif
return ( self )


/*/{Protheus.doc} addConsumo
Adiciona um modelo cbcConsumoERS
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Adicionar o um modelo cbcConsumoERS
/*/
method addConsumo(aConsumo) class cbcRegERS
	default aConsumo := {}
	if !empty(aConsumo)
		aadd( ::aConsumo, aConsumo )
	endif
return ( self )


/*/{Protheus.doc} sumParcela
Soma parcela modelo cbcFinanceiroERS
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Realiza a soma de todas as parcelas
de uma modelo cbcFinanceiroERS
/*/
method sumParcela() class cbcRegERS
	local nTotal := 0
	local nX	 := 0

	if !empty( ::aFinanceiro )
		for nX := 1 to len( ::aFinanceiro )
			nTotal += ::aFinanceiro[nX]:getValor()
		next nX
	endif

return( nTotal )


/*/{Protheus.doc} vldTotal
Validações gerais do modelo
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Realiza as validações
1-) Soma das parcelas cbcFinanceiroERS, igual total cbcRegERS
/*/
method vldTotal() class cbcRegERS
	local lOk := .T.
	lOk  := ( ::sumParcela() == ::getValorTotal() )
return ( lOk )
