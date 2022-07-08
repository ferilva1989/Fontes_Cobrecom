#include 'protheus.ch'

/*/{Protheus.doc} cbcComboItem
Classe que representa um elemento do comboBox.
@author bolognesi
@since 12/09/2016
@version 1.0
/*/
class cbcComboItem 
	data cID
	data cText
	method newcbcComboItem() constructor
	method getID()
	method setID()
	method getText()
	method setText()
endclass

/*/{Protheus.doc} newcbcComboItem
Metodo construtor
@author bolognesi
@since 12/09/2016 
@version 1.0
/*/
method newcbcComboItem() class cbcComboItem
return (self)

method getID() class cbcComboItem
return ::CID

method setID(cId) class cbcComboItem
::cID = cId
return (self)

method getText() class cbcComboItem
return ::cText

method setText(cTxt) class cbcComboItem
::cText = cTxt
return (self)

return