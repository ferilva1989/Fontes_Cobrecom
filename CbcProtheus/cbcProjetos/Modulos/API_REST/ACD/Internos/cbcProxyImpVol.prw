#include 'protheus.ch'
#include 'parmtype.ch'
#include 'AutomacaoColetas.ch'

class cbcProxyImpVol 
	data cInVol
	data lOsOk
	data cMsgErro
	data cOperador

	method newcbcProxyImpVol() constructor
	method vldDados()
	method delVolume()
	method impVolInit()
endclass

method newcbcProxyImpVol(cInVol,cOperador) class cbcProxyImpVol
	Local nTamVol 		:= TamSx3("ZZO_NUMVOL")[1]
	Default cInVol 		:= ""	
	Default cOperador	:= ""
	
	::cOperador := cOperador
	
	If Len(cInVol) <> (nTamVol)
		::lOsOk := .F.
		::cInVol := ""
	Else  
		::lOsOk 		:= .T.
		::cInVol 		:= Padr(cInVol, nTamVol) 
	EndIf
return

method vldDados() class cbcProxyImpVol
	//TODO fazer função
return .T.

method delVolume() class cbcProxyImpVol
	Local lRet 	:= .T.
	Local aRet	:= {}
	::cMsgErro	:= ""
	//Chamar a função Interna
	aRet := {.T.,"[OK] - Finalizado com sucesso"} //U_CDRelVol(::cOperador,::cInVol)	
	If Empty(aRet)
		aRet := {.F.,"[ERRO] - CDRelVol devolveu retorno vazio"}
	EndIf
	if !aRet[1]
		::cMsgErro := aRet[2]
	EndIf
return aRet[1]

method impVolInit(apiRes, oRes) class cbcProxyImpVol
	Local nX	 	:=  0
	
	If  Empty(::cInVol) 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E800
		oRes:body		:= ""
	
	ElseIf !::lOsOk 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E804
		oRes:body		:= ""
	
	ElseIf !::vldDados()
		oRes:sucesso 	:= .F.
		oRes:msg		:= E801
		oRes:body		:= ""

	//Chamada para função interna
	ElseIf !::delVolume()	
		oRes:sucesso 	:= .F.
		oRes:msg		:= ::cMsgErro
		oRes:body		:= ""
	Else
		oRes:sucesso 	:= .T.
		oRes:msg		:= 'VOLUME Nro. ' + ::cInVol + ' Impresso com sucesso '
		oRes:body		:= ""
	EndIf
	apiRes:SetResponse(oRes:toJson())
return 