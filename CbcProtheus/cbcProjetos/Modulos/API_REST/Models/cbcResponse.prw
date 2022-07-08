#include 'protheus.ch'

class cbcResponse 
	
	data sucesso
	data msg
	data body
	data mvParam
	data osbase
	
	method newcbcResponse() constructor 
	method toJson()
endclass

method newcbcResponse() class cbcResponse
	 ::sucesso 	:= .F.
	 ::msg		:= ""
	 ::body 	:= ""
	 ::mvParam	:= cbcParam():newcbcParam()
	 ::osbase	:= {cbcOs():newcbcOs()}
return

method toJson()  class cbcResponse
Local json := jsonTypes():newjsonTypes()
return json:toJson(self) 