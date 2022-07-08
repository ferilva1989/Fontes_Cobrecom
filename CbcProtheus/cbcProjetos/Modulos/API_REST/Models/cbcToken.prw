#include 'protheus.ch'
#INCLUDE "CBCREST.ch"

class cbcToken 
	data cod
	data expira
	data regras
	data assinatura
	
	method newcbcToken() constructor 
	method toJson()
	method gerToken()
	method vldToken()
endclass

method newcbcToken(cCod,cRegra) class cbcToken
Default cCod 		:= ""
Default cRegra		:= ""	 
	 ::cod 			:= cCod
	 ::regras		:= cRegra
	 ::expira		:= ""
	 ::assinatura 	:= ""
return

method gerToken() class cbcToken
	//TODO Talvez parametros, atual validade 1 dia
	Local expirar	:= DtoS(DaySum(Date(), 1))
	//TODO melhorar sistema de criptografia
	::assinatura 	:= SHA1(::cod + expirar)
	::cod 		 	:= Encode64(::cod)
	::expira 		:= Encode64(expirar)
return Encode64(::toJson())

method vldToken(cToken) class cbcToken
Local lRet 		:= {.F.,''}
Local json 		:= jsonTypes():newjsonTypes()
Local oToken	:= json:fromJson(Decode64(cToken))	
	//Vazio
	If Empty(oToken)
		lRet := {.F., E410}
	Else	
		//Validar assinatura (Validade)
		If SHA1(Decode64(oToken:cod) + Decode64(oToken:expira)) != oToken:assinatura 
			lRet := {.F.,E405}
		Else
			//Expirar
			If StoD(Decode64(oToken:expira)) <= Date()   
				lRet := {.F.,E409}
			//Resultado OK
			Else
				lRet := {.T.,Decode64(oToken:cod)}
			Endif
		Endif
	EndIf
return lRet

method toJson()  class cbcToken
Local json := jsonTypes():newjsonTypes()
return json:toJson(self)