#include 'protheus.ch'
#include 'parmtype.ch'
#include 'AutomacaoColetas.ch'

class cbcProxyDelVol 
	data cInVol
	data lVolOk
	data cMsgErro
	data cOperador

	method newcbcProxyDelVol() constructor
	method delVolume()
	method delVolInit()
endclass

method newcbcProxyDelVol(cInVol,cOperador) class cbcProxyDelVol
	Local nTamVol 		:= TamSx3("ZZO_BARINT")[1]
	Local nTamUsr		:= TamSx3("ZZO_OPER")[1]
	Default cInVol 		:= ""	
	Default cOperador	:= ""

	//Retirar a filial do codigo do Operador
	::cOperador := SubStr(cOperador,3,nTamUsr)
	
	//Validar o tamanho do codigo recebido, para nem chamar as
	//funções internas. quando diferente de 11
	If Len(cInVol) != (11)
		::lVolOk := .F.
		::cInVol := ""
	Else  
		::lVolOk 		:= .T.
		::cInVol 		:= Padr(cInVol, nTamVol) 
	EndIf
return

method delVolInit(apiRes, oRes) class cbcProxyDelVol
	Local nX	 	:=  0
	//Codigo do Volume (Codigo de Barras Vazio)
	If  Empty(::cInVol) 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E800
		oRes:body		:= ""
	//Codigo do Volume (Numero de caracteres codigo barras 11)
	ElseIf !::lVolOk 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E804
		oRes:body		:= ""
	//Chamada para função interna
	ElseIf !::delVolume()	
		oRes:sucesso 	:= .F.
		oRes:msg		:= ::cMsgErro
		oRes:body		:= ""
	//Sucesso
	Else
		oRes:sucesso 	:= .T.
		oRes:msg		:= 'VOLUME Nro. ' + ::cInVol + ' Deletado '
		oRes:body		:= ""
	EndIf
	apiRes:SetResponse(oRes:toJson())
return 

method delVolume() class cbcProxyDelVol
	Local lRet 	:= .T.
	Local aRet	:= {}
	::cMsgErro	:= ""
	
	/*UTIL PARA DEBUGAR VER LOG CONSOLE*/
	//conout('DEGUB............>>' + 'OPERADOR: ' + ::cOperador + ' VOLUME: ' + ::cInVol )
	
	//Chamar a função Interna	
	aRet := U_CDDelVol(::cOperador,::cInVol )	
	
	If  Valtype(aRet) != 'A' .Or. Empty(aRet)
		aRet := {.F.,"[ERRO] - CDDelVol não retornou um Array, ou o Array retornou vazio!"}
	EndIf
	if !aRet[1]
		::cMsgErro := EncodeUTF8(aRet[2])
	EndIf
return aRet[1]