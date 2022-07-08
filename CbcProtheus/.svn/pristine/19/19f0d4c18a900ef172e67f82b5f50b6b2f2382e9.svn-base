#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful apiOrdemSep DESCRIPTION "API Rest de Ordem de Separacao"
	wsMethod GET description "Rotas GET: /cancelwms "
end wsRestful

wsMethod GET wsService apiOrdemSep
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local cRoute	:= ""
	local oRes		:= JsonObject():new()

	cRoute := oRequest:getRoute()

	if (cRoute == "cancelwms")
		cancelWms(@self, @oRes)
	else
		oRes["status"] 			:= .F.
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function cancelWms(oWs, oRes)
	local oCtrl         := cbcCtrlOS():newcbcCtrlOS(,.F.)
	local lRet			:= .T.
	local cMsgErr		:= ''
	local cOS			:= ''
	local nId			:= 0
	local lTest			:= GetNewPar('ZZ_TWMSAPI', .F.)

	if (Len(oWs:aURLParms) >= 3)
		cOS := oWs:aURLParms[2]
		nId := oWs:aURLParms[3]
	endif

	if Empty(cOS) .or. Empty(nId)
		cMsgErr := "Forneca a Ordem de Separação!"
		lRet    := .F.
	else
		oCtrl:define(cOS)
		if (lRet := oCtrl:cancelWms(nId, lTest):isOk())
			cMsgErr := 'Ordem ' + cOS + ' com ID ' + cValToChar(nId) + 'cancelada no cbcWMS!'
		else
			cMsgErr := oCtrl:getErrMsg()
		endif
	endIf

	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsgErr
return(nil)
