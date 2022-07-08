#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful cbcApiCompras DESCRIPTION "API Rest de Compras"
	wsMethod POST description "Rotas POST: /lista /rejeita /aprova / inclui "
end wsRestful

wsMethod POST wsService cbcApiCompras
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oRes		:= JsonObject():new()
    local cRoute	:= ""
	local aVld		:= {.F.,''}

	cRoute := oRequest:getRoute()
	if (cRoute == "login")
		login(@self, @oRes)
	elseif !(aVld := validTkn(@self) )[1]
		oRes["status"] 	:= aVld[1]
		oRes["msg"]	    := aVld[2]
	elseif (cRoute == "lista")
		lista(@self, @oRes)
    elseif (cRoute == "rejeita")
		rejeita(@self, @oRes)
    elseif (cRoute == "aprova")
		aprova(@self, @oRes)
	elseif (cRoute == "inclui")
		insere(@self, @oRes)
	else
		oRes["status"] 			:= .F.
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function lista(oWs, oRes)
	local oBody		    := JsonObject():new()
    local oJson         := JsonObject():new()
	local lRet			:= .F.
	local cMsg			:= 'Sem dados!'
	local cJson			:= '{}'

    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if ValType(oBody:GetJsonObject('user')) <> 'U' .and.;
			ValType(oBody:GetJsonObject('status')) <> 'U'
            oJson := u_cbcGetPC(oBody['user'], oBody['status'])
		    lRet := !empty((oJson:GetNames()))
            if lRet
                cMsg  := ''
                cJson := oJson:ToJson()
            endif
        endif
    endif

	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsg
	oRes["data"]			:= cJson
return(.T.)

static function rejeita(oWs, oRes)
	local oBody		    := JsonObject():new()
	local aRet			:= {.F., 'Sem dados!'}
	local cJson			:= '{}'
	local nX			:= 0
	local bErro			:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})

    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if ValType(oBody:GetJsonObject('rec')) == 'A';
		 .and. ValType(oBody:GetJsonObject('motivo')) <> 'U';
		 .and. ValType(oBody:GetJsonObject('user')) <> 'U'
            BEGIN SEQUENCE
				BEGIN Transaction
					for nX := 1 to len(oBody['rec'])
						aRet := u_cbcRejPC(oBody['rec'][nX], oBody['motivo'], oBody['user'] )
						if !(aRet[1])
							UserException(aRet[2])
						endif
					next nX
				END Transaction
				RECOVER
    		END SEQUENCE
			ErrorBlock(bErro)
        endif
    endif
    
	oRes["status"] 			:= aRet[1]
	oRes["msg"]				:= aRet[2]
	oRes["data"]			:= cJson
return(.T.)

static function aprova(oWs, oRes)
	local oBody		    := JsonObject():new()
	local aRet			:= {.F., 'Sem dados!'}
	local cJson			:= '{}'
	local nX			:= 0
	local bErro			:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})

    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if ValType(oBody:GetJsonObject('rec')) == 'A' .and. ValType(oBody:GetJsonObject('user')) <> 'U'
            BEGIN SEQUENCE
				BEGIN Transaction
					for nX := 1 to len(oBody['rec'])
						aRet := u_cbcLibPC(oBody['rec'][nX], oBody['user'])
						if !(aRet[1])
							UserException(aRet[2])
						endif
					next nX
				END Transaction
				RECOVER
    		END SEQUENCE
			ErrorBlock(bErro)
        endif
    endif
    
	oRes["status"] 			:= aRet[1]
	oRes["msg"]				:= aRet[2]
	oRes["data"]			:= cJson
return(.T.)

static function login(oWs, oRes)
	local oBody		    := JsonObject():new()
	local aRet			:= {.F., 'Sem dados!'}
	local oRetObj		:= JsonObject():new()
	local cJson			:= '{}'
	local bErro			:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
	local oJwt			:= cbcJwtAuth():newcbcJwtAuth()

    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if  ValType(oBody:GetJsonObject('user')) <> 'U' .and.  ValType(oBody:GetJsonObject('senha')) <> 'U'
            BEGIN SEQUENCE
				if (vldLogin(oBody['user'],oBody['senha'], @oBody))
					aRet[1] 			:= .T.
					aRet[2]				:= ''
					oRetObj['usr']		:= oBody['cod']
					oRetObj['tkn']		:= oJwt:gerToken(oBody['cod'], 1)
					cJson 				:= oRetObj:toJSon()
				else
					aRet[1] 			:= .F.
					aRet[2]				:= 'Usuario ou senha invÃ¡lido'
				endif
				RECOVER
    		END SEQUENCE
			ErrorBlock(bErro)
        endif
    endif
	oRes["status"] 			:= aRet[1]
	oRes["msg"]				:= aRet[2]
	oRes["data"]			:= cJson
	
	FreeObj(oJwt)
return .T.

static function vldLogin(cUsr, cPass, oBody)
	local lOk 		:= .F.
	local oLogin	:= nil
	oLogin :=  cbcLogClass():newcbcLogClass()
	if oLogin:doLogin(cUsr, cPass):isOk()
		 if oLogin:isLogged
		 	if oLogin:haveGroup('000132') .OR. oLogin:haveGroup('000000')
				lOk := .T.
				oBody["cod"] := oLogin:getUsrInfo()['Codigo']
			endif
		 endif
	endif	
	FreeObj(oLogin:free())
return lOk

static function validTkn(oWs)
	local aRet   := {.F., ''}
	local oJwt	 := cbcJwtAuth():newcbcJwtAuth()
	oJwt:vldToken(oWs:GetHeader('Authorization'))
	aRet := aClone(oJwt:aResult)
	FreeObj(oJwt)
return aRet

static function insere(oWs, oRes)
	local oBody		    := JsonObject():new()
	local aRet			:= {.F., 'Verificar dados obrigatórios!'}
	local cJson			:= '{}'
	local oExec			:= nil
	local bkUsr       	:= RetCodUsr()
    local bkUNm       	:= cUserName
	local cUsr			:= ''
	local bErro			:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
	
    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if ValType(oBody:GetJsonObject('user')) <> 'U' .and. ValType(oBody:GetJsonObject('HEADER')) <> 'U' .and. ValType(oBody:GetJsonObject('ITEMS')) <> 'U'
			cUsr := oBody['user']
			if !empty(cUsr)
				if Empty(aAllusers  := FWSFALLUSERS({cUsr}))
						aRet[1] := .F.
						aRet[2] := 'Usuario invalido'
				else
					BEGIN SEQUENCE
						BEGIN Transaction
							oBody['HEADER']['C7_NUM'] 		:= GetNumSC7()
							oBody['HEADER']['C7_EMISSAO'] 	:= dDataBase
							if ValType(oBody['HEADER']:GetJsonObject('C7_COND')) == 'U'
								oBody['HEADER']['C7_COND'] 		:= getCondPagto(AllTrim(oBody['HEADER']['C7_FORNECE']), AllTrim(oBody['HEADER']['C7_LOJA']))
							endif
							oBody['HEADER']['C7_FILENT']	:= FwFilial()
							cUserName  := aAllusers[1][3]
							__cUserId  := cUsr
							oExec := cbcExecAuto():newcbcExecAuto()
							oExec:setFilial(FwFilial())
							oExec:fromJson(oBody)
							oExec:exAuto('MATA120',3,,"COM")
							aRet := oExec:getRet()
							FreeObj(oExec)
							if !empty(cUsr)
								__cUserId := bkUsr
								cUserName := bkUNm
							endif
							//cJson  :=  aAllusers[1][3]
						END Transaction
						RECOVER
					END SEQUENCE
					ErrorBlock(bErro)
				endif
			endif
		endif
    endif   
	oRes["status"] 			:= aRet[1]
	oRes["msg"]				:= aRet[2]
	oRes["data"]			:= cJson
return(.T.)

static function getCondPagto(cForn, cLoja)
    local aArea    	:= GetArea()
    local aAreaSA2 	:= SA2->(GetArea())
	local cCond     := ''
	local oSql 		:= LibSqlObj():newLibSqlObj()

    oSql:newTable("SA2", "A2_COND COND", "A2_COD = '" + cForn + "' AND A2_LOJA = '" + cLoja + "'")

	if (oSql:hasRecords())
        cCond := oSql:getValue("COND")
	endif

    FreeObj(oSql)
    RestArea(aAreaSA2)
    RestArea(aArea)
return(cCond)

static function HandleEr(oErr, aRet)
	default aRet := {.F.,'UserException'}
	aRet := {.F., AllTrim(oErr:Description)}
    u_autoAlert('[API COMPRAS] - Erro: ' + AllTrim(oErr:Description))
	if InTransact()
		DisarmTransaction()
	endif
	BREAK
return(nil)
