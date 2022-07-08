#include 'protheus.ch'

/*/{Protheus.doc} cbcColorSpecialtys
Classe que representa um elemento do comboBox.
@author bolognesi
@since 12/09/2016
@version 1.0
/*/
class cbcColorSpecialtys 
	data cSpec 		//Especialidade
	data aColor 	//Cor (Padrão {ID TEXT} )
	method newcbcColorSpecialtys() constructor
	method getSpec()
	method setSpec()
	method getColor()
	method setColor()
	method addColor()
endclass

/*/{Protheus.doc} newcbcColorSpecialtys
Metodo construtor
@author bolognesi
@since 12/09/2016 
@version 1.0
/*/
method newcbcColorSpecialtys() class cbcColorSpecialtys
	::aColor = {}
return (self)

method getSpec() class cbcColorSpecialtys
return ::cSpec

method setSpec(cSpecial) class cbcColorSpecialtys
::cSpec = cSpecial
return (self)

method getColor() class cbcColorSpecialtys
return ::aColor[1]

method addColor(aColor) class cbcColorSpecialtys
	Aadd(::aColor, aColor)
return (self)
