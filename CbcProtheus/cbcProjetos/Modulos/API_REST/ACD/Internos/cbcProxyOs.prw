#include 'protheus.ch'
#include 'parmtype.ch'
#include 'AutomacaoColetas.ch'

class cbcProxyOs 
	data aOrdem
	data aResord
	data qtd
	data cInOs
	data cOs
	data cSeq
	data lOsOk
	data cOperador

	method newcbcProxyOs() constructor
	method vldZZRSituac()
	method arrToClass()
	method getOsItens()
	method getOsInit()
	method vldOsWms()
endclass

method newcbcProxyOs(cInOs, cOperador) class cbcProxyOs
	Local nTamOs 		:= TamSx3("ZZR_PEDIDO")[1]
	Local nTamSeq		:= TamSx3("ZZR_SEQOS")[1]
	Default cInOs 		:= ""	
	Default cOperador	:= ""

	::cOperador := cOperador

	If Len(cInOs) <> (nTamOs + nTamSeq)
		::lOsOk := .F.
		::cInOs := ""
	Else  
		::lOsOk 		:= .T.
		::cInOs 		:= Padr(cInOs, nTamOs + nTamSeq  )
		::cSeq 			:= StrZero(Val(Right(::cInOs, nTamSeq)),nTamSeq)
		::cOs 			:= StrZero(Val(Left(::cInOs,nTamOs)),nTamOs) 
		::aResord 		:= {}
		::aOrdem 		:= {}
	EndIf
return

method vldZZRSituac() class cbcProxyOs
	//TODO fazer função
return .T.

method arrToClass() class cbcProxyOs
	Local lRet := .T.

	::aResord := {}

	For nX := 1 To Len(::aOrdem)
		orItem 		:= cbcOs():newcbcOs()
		orItem:tp 	:= ::aOrdem[nX][OSITEM_TIPO]
		orItem:id	:= Alltrim(::aOrdem[nX][OSITEM_ID])
		orItem:qtd  := ::aOrdem[nX][OSITEM_QTD]
		AAdd(::aResord, orItem)
	Next nX


return lRet

method getOsItens(cErrMsg) class cbcProxyOs
	Local lRet := .T.
	local lTemErr := .F.	
	default cErrMsg := ""
	::aOrdem := {}
	::aOrdem := U_CDSendVol(::cOperador,::cOs, ::cSeq, @lTemErr, @cErrMsg)

	If ValType(::aOrdem) != 'A' .or. lTemErr
		lRet := .F.
	EndIf

	/*	
	AAdd(::aOrdem,{'B','96011605832', 20})
	AAdd(::aOrdem,{'B','96011605833', 50})//DUPLICADO COLETOR JUNTA
	AAdd(::aOrdem,{'B','96011605834', 12})
	AAdd(::aOrdem,{'P','92860110100', 18})
	AAdd(::aOrdem,{'B','96011605833', 50})//DUPLICADO COLETOR JUNTA
	*/
return lRet

method getOsInit(apiRes, oRes) class cbcProxyOs
	Local nX	 	:=  0
	local cErrMsg	:= ""

	If  Empty(::cInOs) 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E600
		oRes:body		:= ""

	ElseIf !::lOsOk 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E604
		oRes:body		:= ""
	ElseIf !::vldOsWms()
		oRes:sucesso 	:= .F.
		oRes:msg		:= E617
		oRes:body		:= ""
	ElseIf !::vldZZRSituac()
		oRes:sucesso 	:= .F.
		oRes:msg		:= E601
		oRes:body		:= ""

		//Chamada para função interna
	ElseIf !::getOsItens(@cErrMsg)	
		oRes:sucesso 	:= .F.
		oRes:msg		:= iif(!empty(cErrMsg), cErrMsg, E602)
		oRes:body		:= ""
	Else
		//Preparar para retornar os dados
		If !::arrToClass()
			oRes:sucesso 	:= .F.
			oRes:msg		:= E602
			oRes:body		:= ""
		Else	
			oRes:sucesso 	:= .T.
			oRes:msg		:= 'ORDEM Nro. ' + ::cOs
			oRes:osbase		:= ::aResord
		EndIf
	EndIf
	apiRes:SetResponse(oRes:toJson())
return 


method vldOsWms(cOs, lMsg, lCarga) class cbcProxyOs
	local lOk 		:= .F.
	local oRst 	 	:= nil
	local oJsRes 	:= nil
	local lVld		:= GetNewPar('ZZ_VLDOWMS',.F.)
	default cOs 	:= ::cInOs
	default lMsg    := .F.
	default lCarga  := .F.
	
	if lVld
		oRst 			:= FWRest():New(GetNewPar('WM_URLWMS','http://192.168.1.220:4877'))
		if lCarga
			oRst:setPath('/getcargastatus/'+ Alltrim(cOs) )
		else
			oRst:setPath('/getspstatus/'+ Alltrim(cOs) )
		endif
		if oRst:Get()
			oRst:GetResult()
			oJsRes := JsonObject():New()
			oJsRes:FromJSON(oRst:GetResult())
			lOk := (oJsRes['perc'] == 100)
		else
			lOk  := .F.
			if lMsg
				MsgInfo(oRst:GetLastError(), 'Separação: ' + Alltrim(cOs))
			endif
		endif	
		FreeObj(oRst)
		FreeObj(oJsRes)
	else
		lOk := .T.
	endif
return lOk
