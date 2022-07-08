#include 'protheus.ch'


class cbcBIResp 	
	data sucesso
	data msg
	data xRet
	
	method newcbcBIResp() constructor 
	method toJson()
endclass


method newcbcBIResp() class cbcBIResp
	 ::sucesso 	:= .F.
	 ::msg		:= ""
	 ::xRet		:= ""
return


method toJson()  class cbcBIResp 
return(toJson(self)) 


static function toJson(oObj)
	local oJson	:= nil
	local aProp	:= {}
	local nX	:= 0
	local cJson	:= ''
	local cTipo	:= ''
	
	oJson 	:= JsonObject():new()
	aProp	:= ClassDataArr(oObj,.F.)
    for nX := 1 to len(aProp)
    	cTipo = valtype(aProp[nX,2])
    	if  cTipo == 'O'
    		oJson[aProp[nX,1]] := toJson(aProp[nX,2])
    	else
    		oJson[aProp[nX,1]] := aProp[nX,2]
    	endif
    next nX
    cJson := oJson:toJSON()
    FreeObj(oJson)
return(cJson)
