#include 'protheus.ch'


/*/{Protheus.doc} cbcMdlLabel
//TODO Criação da Classe com o formato do objeto Label.
@author bolognesi
@since 07/01/2019
@version 1.0
@type class
/*/
class cbcMdlLabel 

	data cTipo
	data cCampo
	data aConteudo
	data cConteudo
	method newcbcMdlLabel() constructor 

endclass


/*/{Protheus.doc} newcbcMdlLabel
//TODO Construtor da classe.
@author bolognesi
@since 07/01/2019
@version 1.0

@type function
/*/
method newcbcMdlLabel() class cbcMdlLabel
	::cTipo := ''
	::cCampo := ''
	::aConteudo := {}
	::cConteudo := ''
return(self)