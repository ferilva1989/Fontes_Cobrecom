#include 'protheus.ch'
class jsonTypes 
	method newjsonTypes() constructor 
	method toJson()
	method fromJson()
endclass

method newjsonTypes() class jsonTypes

return

//JSON => OBJETO
method fromJson(cString) class jsonTypes
Local oRet := ""
Default cString := "{}"
FWJsonDeserialize(cString, @oRet)
return oRet

//OBJETO => JSON
method toJson(cObjeto, lClassName, lUTC) class jsonTypes
local cRet := "{}"

default lClassName	:= .T. 
default lUTC		:= .T.
default cObjeto 	:= ""

If Empty(cObjeto)
	cRet := FWJsonSerialize(self,lClassName,lUTC)
Else
	cRet := FWJsonSerialize(cObjeto,lClassName,lUTC)
EndIf
return cRet 