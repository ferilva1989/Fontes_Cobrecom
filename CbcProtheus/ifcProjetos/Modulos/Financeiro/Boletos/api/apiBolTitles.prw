#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful apiBolTitles DESCRIPTION "API Rest de retorno dos Títulos para Gerador Boletos"	
	wsMethod POST description "Rotas POST: /titles "	
end wsRestful

wsMethod POST wsService apiBolTitles
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local lOk		:= .F.
	local cRoute	:= ''
	
	cRoute := oRequest:getRoute()
	
	if(cRoute == "titles")
		lOk := getTitles(@self)
	endif
return(lOk)

static function getTitles(oWs)				
	local cToken 	 	:= ''
	local oRes			:= JsonObject():new()
	local oAuthBol		:= classBolAuth():newclassBolAuth()
	local lRet			:= .F.
	local cMyCnpj 		:= SubStr(FWArrFilAtu( FWGrpCompany(), FWCodEmp() + FWUnitBusiness() + FwFilial() )[18],1,8)
	local oBody			:= JsonObject():new()
	Local oStatic    	:= IfcXFun():newIfcXFun()
	
	//Tipo do conteudo para retorno
	oWs:SetContentType("application/json")

	//Obter conteudo da requisição
	cToken := oWs:GetHeader('Authorization')
	
	if !(lRet := (oAuthBol:authToken(cToken):isOk()))
		oRes["status"] 			:= .F.
		oRes["msg"]				:= oAuthBol:getMsgErr()
		oRes["data"]			:= {}
		oWs:SetStatus(200)
		oWs:SetResponse(oRes:toJson())
	else
		if(cMyCnpj == oAuthBol:getUserId())
			oBody:fromJson(oWs:getContent())
			if !empty(oBody["id"])
				oRes["status"] 			:= .T.
				oRes["msg"]				:= ''
				oRes["data"]			:= {oStatic:sP(1):callStatic('srvBolAuth', 'getTitles', oBody["id"])}
			else
				oRes["status"] 			:= .F.
				oRes["msg"]				:= 'Chave de pesquisa vazia!'
				oRes["data"]			:= {}
			endif
		else
			oRes["status"] 			:= .T.
			oRes["msg"]				:= ''		
			oRes["data"]			:= {oStatic:sP(1):callStatic('srvBolAuth', 'getTitles', oAuthBol:getUserId())}
		endif
		oWs:SetStatus(200)
		oWs:SetResponse(oRes:toJson())
	endif
	FreeObj(oBody)
	FreeObj(oRes)
	FreeObj(oAuthBol)
return(.T.)
