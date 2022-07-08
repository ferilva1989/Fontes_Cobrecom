#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful apiBolAuth DESCRIPTION "API Rest de autenticação do Gerador Boletos"	
	wsMethod POST description "Rotas POST: /login /authToken "
end wsRestful

wsMethod POST wsService apiBolAuth
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local lOk		:= .F.
	local cRoute	:= ''
	
	cRoute := oRequest:getRoute()
	
	if(cRoute == "login")
		lOk := login(@self)
	elseif(cRoute == "authtoken")
		lOk := authToken(@self)
	elseif(cRoute == "changepass")
		lOk := changePass(@self)
	elseif(cRoute == "recoverypass")
		lOk := recoveryPass(@self)
	elseif(cRoute == "resetpass")
		lOk := resetPass(@self)
	endif
return(lOk)

static function login(oWs)
	local oData			:= nil
	local oBody		    := JsonObject():new()
	local oRes			:= JsonObject():new()
	local oAuthBol		:= classBolAuth():newclassBolAuth()
	local lRet			:= .F.
	
	//Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
	oBody:fromJson(oWs:getContent())	
	
	if !(lRet := (oAuthBol:setLogin(oBody["login"], oBody["password"]):isOk()))
		oRes["status"] 			:= .F.
		oRes["msg"]				:= oAuthBol:getMsgErr()
		oRes["data"]			:= {}
		oWs:SetStatus(200)
		oWs:SetResponse(oRes:toJson())
	else
		oRes["status"] 			:= .T.
		oRes["msg"]				:= ''
		oRes["data"]			:= {oAuthBol:setAuthToken():getAuthToken(), oAuthBol:getUserUltLog(),; 
													oAuthBol:getUserMail(), oAuthBol:getUserMobile()}
		oWs:SetStatus(200)
		oWs:SetResponse(oRes:toJson())
	endif
	FreeObj(oRes)
return(.T.)

static function authToken(oWs)				
	local oData			:= nil
	local cToken 	 	:= ''
	local oRes			:= JsonObject():new()
	local oAuthBol		:= classBolAuth():newclassBolAuth()
	local lRet			:= .F.
	local oBody		    := JsonObject():new()
	
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
		oRes["status"] 			:= .T.
		oRes["msg"]				:= ''
		oRes["data"]			:= {}
		oWs:SetStatus(200)
		oWs:SetResponse(oRes:toJson())
	endif
	FreeObj(oRes)
return(.T.)

static function changePass(oWs)				
	local oData			:= nil
	local cToken 	 	:= ''
	local oRes			:= JsonObject():new()
	local oAuthBol		:= classBolAuth():newclassBolAuth()
	local lRet			:= .F.
	local cMsgErr		:= ''
	local aData			:= {}
	local oBody		    := JsonObject():new()
	
	//Tipo do conteudo para retorno
	oWs:SetContentType("application/json")

	//Obter conteudo da requisição
	cToken := oWs:GetHeader('Authorization')
	
	if !(lRet := (oAuthBol:authToken(cToken):isOk()))
		cMsgErr	:= oAuthBol:getMsgErr()
	else
		oBody:fromJson(oWs:getContent())
		if !(lRet := !(empty(oBody["pass"])))
			cMsgErr	:= 'Nova senha nao pode estar vazia!'
		else
			if!(lRet := (oAuthBol:changePass(oBody["pass"], oBody["email"], oBody["celSms"]):isOk()))
				cMsgErr	:= oAuthBol:getMsgErr()
			endif
		endif
	endif
	
	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsgErr
	oRes["data"]			:= aData
	oWs:SetStatus(200)
	oWs:SetResponse(oRes:toJson())	
	FreeObj(oRes)
return(.T.)

static function recoveryPass(oWs)				
	local oData			:= nil
	local cToken 	 	:= ''
	local oRes			:= JsonObject():new()
	local oAuthBol		:= classBolAuth():newclassBolAuth()
	local lRet			:= .F.
	local cMsgErr		:= ''
	local aData			:= {}
	local oBody		    := JsonObject():new()
	
	//Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
	oBody:fromJson(oWs:getContent())
	if !(lRet := !(empty(oBody["id"])))
		cMsgErr	:= 'Identificacao nao pode estar vazia!'
	else
		if!(lRet := (oAuthBol:recoveryPass(oBody["id"]):isOk()))
			cMsgErr	:= oAuthBol:getMsgErr()
		endif
	endif
	
	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsgErr
	oRes["data"]			:= aData
	oWs:SetStatus(200)
	oWs:SetResponse(oRes:toJson())	
	FreeObj(oRes)
return(.T.)

static function resetPass(oWs)				
	local oData			:= nil
	local cToken 	 	:= ''
	local oRes			:= JsonObject():new()
	local oAuthBol		:= classBolAuth():newclassBolAuth()
	local lRet			:= .F.
	local cMsgErr		:= ''
	local aData			:= {}
	local oBody		    := JsonObject():new()
	
	//Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
	//Obter conteudo da requisição
	cToken := oWs:GetHeader('Authorization')
	
	oBody:fromJson(oWs:getContent())
	if !(lRet := !(empty(oBody["pass"])))
		cMsgErr	:= 'Nova senha nao pode estar vazia!'
	else
		if!(lRet := (oAuthBol:recoveryPass(cToken, oBody["pass"]):isOk()))
			cMsgErr	:= oAuthBol:getMsgErr()
		endif
	endif
	
	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsgErr
	oRes["data"]			:= aData
	oWs:SetStatus(200)
	oWs:SetResponse(oRes:toJson())	
	FreeObj(oRes)
return(.T.)