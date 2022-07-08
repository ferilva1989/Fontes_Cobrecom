#include 'protheus.ch'

class cbcParam 
	
	data Conteudo
    data Tipo

	method newcbcParam() constructor 
	
endclass

method newcbcParam() class cbcParam
	 ::Conteudo := ""
	 ::Tipo		:= ""
return