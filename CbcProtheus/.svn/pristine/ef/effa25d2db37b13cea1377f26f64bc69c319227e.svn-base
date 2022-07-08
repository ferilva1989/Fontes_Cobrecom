#include 'protheus.ch'

/*/{Protheus.doc} cbcPackFootage
Classe que representa um elemento do comboBox.
@author bolognesi
@since 12/09/2016
@version 1.0
/*/
class cbcPackFootage 
	data cPackAge //Acondicionamento
	data aFootAge //Metragem
	method newcbcPackFootage() constructor
	method getPackAge()
	method setPackAge()
	method getFootAge()
	method setFootAge()
	method addFootAge()
endclass

/*/{Protheus.doc} newcbcPackFootage
Metodo construtor
@author bolognesi
@since 12/09/2016 
@version 1.0
/*/
method newcbcPackFootage() class cbcPackFootage
	::aFootAge = {}
return (self)

method getPackAge() class cbcPackFootage
return ::cPackAge

method setPackAge(cAcon) class cbcPackFootage
::cPackAge = cAcon
return (self)

method getFootAge() class cbcPackFootage
return ::aFootAge

method addFootAge(cMtr) class cbcPackFootage
	Aadd(::aFootAge, cMtr)
return (self)