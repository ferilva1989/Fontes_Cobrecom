#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful apiBolGera DESCRIPTION "API Rest de retorno do Boleto"	
	wsMethod POST description "Rotas POST: /boleto "	
end wsRestful

wsMethod POST wsService apiBolGera
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local lOk		:= .F.
	local cRoute	:= ''
	
	cRoute := oRequest:getRoute()
	
	if(cRoute == "boleto")
		lOk := genBoleto(@self)
	endif
return(lOk)

static function genBoleto(oWs)				
	local cToken 	 	:= ''
	local oRes			:= JsonObject():new()
	local oAuthBol		:= classBolAuth():newclassBolAuth()
	local lRet			:= .F.
	local cMyCnpj 		:= SubStr(FWArrFilAtu( FWGrpCompany(), FWCodEmp() + FWUnitBusiness() + FwFilial() )[18],1,8)
	local oBody			:= JsonObject():new()
	local cMsgErr		:= ''
	local aData			:= {}
	local aBol			:= {}
	
	//Tipo do conteudo para retorno
	oWs:SetContentType("application/json")

	//Obter conteudo da requisição
	cToken := oWs:GetHeader('Authorization')
	
	if !(lRet := (oAuthBol:authToken(cToken):isOk()))
		cMsgErr	:= oAuthBol:getMsgErr()
	else
		oBody:fromJson(oWs:getContent())
		if !empty(oBody["idcli"]) .and. !empty(oBody["idtitulo"])
			aBol := u_zxBolPort(oBody["idcli"], oBody["idtitulo"])
			if (lRet := aBol[1])
				aAdd(aData, aBol[2])
			else
				cMsgErr	:= 'Boleto nao localizado! Redirecionando ao banco!'
			endif
		else
			lRet	:= .F.
			cMsgErr	:= 'Chave de pesquisa vazia!'
		endif		
	endif
	
	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsgErr
	oRes["data"]			:= aData
	oWs:SetStatus(200)
	oWs:SetResponse(oRes:toJson())
	FreeObj(oBody)
	FreeObj(oRes)
	FreeObj(oAuthBol)
return(.T.)