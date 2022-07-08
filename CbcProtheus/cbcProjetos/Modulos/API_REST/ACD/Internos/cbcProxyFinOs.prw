#include 'protheus.ch'
#include 'parmtype.ch'
#include 'AutomacaoColetas.ch'

class cbcProxyFinOs 
	data cInOs
	data cOs
	data cSeq
	data lOsOk
	data cMsgErro
	data cOperador

	method newcbcProxyFinOs() constructor
	method vldZZRSituac()
	method finOrdem()
	method finOsInit()
endclass

method newcbcProxyFinOs(cInOs, cOperador) class cbcProxyFinOs
	Local nTamOs 		:= TamSx3("ZZR_PEDIDO")[1]
	Local nTamSeq		:= TamSx3("ZZR_SEQOS")[1]
	Default cInOs 		:= ""	
	Default cOperador	:= ""
	
	::cOperador 		:= cOperador
	
	
	If Len(cInOs) <> (nTamOs + nTamSeq)
		::lOsOk := .F.
		::cInOs := ""
	Else  
		::lOsOk 		:= .T.
		::cInOs 		:= Padr(cInOs, nTamOs + nTamSeq  )
		::cSeq 			:= StrZero(Val(Right(::cInOs, nTamSeq)),nTamSeq)
		::cOs 			:= StrZero(Val(Left(::cInOs,nTamOs)),nTamOs) 
	EndIf
return

method vldZZRSituac() class cbcProxyFinOs
	//TODO fazer função
return .T.

method finOrdem() class cbcProxyFinOs
	Local lRet 	:= .T.
	Local aRet	:= {}
	::cMsgErro	:= ""
	//Chamar a função Interna
	aRet := {.T.,"[OK] - Finalizado com sucesso"} //U_CDFimOS(::cOperador, ::cOs, ::cSeq)	
	If Empty(aRet)
		aRet := {.F.,"[ERRO] - CDFimOs devolveu retorno vazio"}
	EndIf
	if !aRet[1]
		::cMsgErro := aRet[2]
	EndIf
return aRet[1]

method finOsInit(apiRes, oRes) class cbcProxyFinOs
	Local nX	 	:=  0
	
	If  Empty(::cInOs) 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E600
		oRes:body		:= ""
	
	ElseIf !::lOsOk 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E604
		oRes:body		:= ""
	
	ElseIf !::vldZZRSituac()
		oRes:sucesso 	:= .F.
		oRes:msg		:= E601
		oRes:body		:= ""

	//Chamada para função interna
	ElseIf !::finOrdem()	
		oRes:sucesso 	:= .F.
		oRes:msg		:= ::cMsgErro
		oRes:body		:= ""
	Else
		oRes:sucesso 	:= .T.
		oRes:msg		:= 'ORDEM Nro. ' + ::cOs + ' Seq. ' + ::cSeq + '  Finalizada'
		oRes:body		:= ""
	EndIf
	apiRes:SetResponse(oRes:toJson())
return 