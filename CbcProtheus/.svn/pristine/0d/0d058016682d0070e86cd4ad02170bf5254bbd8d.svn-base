#include 'protheus.ch'
//TODO desenvolver doc, classe para avaliar se em uma instancia de um objeto existe uma propriedade 
//especificada evitando error 

class cbcExisteAtt 
	method newcbcExisteAtt() constructor 
	method isAtt()
endclass

method newcbcExisteAtt() class cbcExisteAtt
return self

method isAtt(oObj, aAtt) class cbcExisteAtt 
Local aErro		:= {}
Local nX		:= 0
Default oObj	:= ""
Default aAtt	:= ""
If ValType(oObj) == 'O' && ValType(aAtt) == 'A' 
	For nX := 1 to Len(aAtt)
		If !AttIsMemberOf(oObj,aAtt[nX])
			AAdd(aErro, aAtt[nX])
		EndIf
	Next nX
EndIf
return aErro