#include "totvs.ch"
#include "restful.ch"
wsRestful cbcAlmoxApi DESCRIPTION "API Rest do Almoxarifado"
	wsMethod POST description "Rotas POST: /smc /cancelsmc /separado "
end wsRestful

wsMethod POST wsService cbcAlmoxApi
    local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oRes		:= JsonObject():new()
    local cRoute	:= ""

	cRoute := oRequest:getRoute()
	if (cRoute == "smc")
		cbcSMC(@self, @oRes)
    elseif (cRoute == "cancelsmc")
		cancelWms(@self, @oRes)
    elseif (cRoute == "separado")
		separado(@self, @oRes)
	else
		oRes["status"] 			:= .F.
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function cbcSMC(oWs, oRes)
    local oBody		    := JsonObject():new()
    local oJson		    := JsonObject():new()
    local oItem			:= nil
	local aRet			:= {.F., 'Sem dados!'}
    local aItems        := {}
    local aServs        := {}
    local aSMC          := {}
    local aSolic        := {}
	local nX			:= 0
    local nSeq          := 0
    local nSaldo        := 0
    local cSMC          := ""
    local cEstoque      := "S"
    local oInt          := cbcAlmoxInteg():newcbcAlmoxInteg(.F.)
    local cServCod      := Alltrim(GetNewPar("ZZ_SMCSERV", "SV04000007"))
    local lFazSolic     := GetNewPar("ZZ_SMCSOLI", .F.)


    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if (ValType(oBody:GetJsonObject('SMC')) <> 'U') .and. (ValType(oBody:GetJsonObject('ITEMS')) <> 'U' .or. ValType(oBody:GetJsonObject('SERVICOS')) <> 'U')
            cSMC := AllTrim(oBody['SMC'])
            if ValType(oBody:GetJsonObject('ITEMS')) <> 'U'
                for nX := 1 to len(oBody['ITEMS'])
                    oItem := JsonObject():new()
                    oItem['Item']       := oBody['ITEMS'][nX]['Item']
                    oItem['Codigo']     := oBody['ITEMS'][nX]['Codigo']
                    nSaldo := oInt:getSaldoProd(AllTrim(oBody['ITEMS'][nX]['Codigo']))
                    if nSaldo >= oBody['ITEMS'][nX]['Quant']
                        oItem['Estoque']    := 'S'
                    else
                        cEstoque := "N"
                        oItem['Estoque']    := 'N'
                        aAdd(aSolic,{AllTrim(oBody['ITEMS'][nX]['Codigo']), (oBody['ITEMS'][nX]['Quant'] - nSaldo)})
                    endif
                    aAdd(aSMC,{AllTrim(oBody['ITEMS'][nX]['Codigo']), oBody['ITEMS'][nX]['Quant']})
                    aAdd(aItems,oItem)
                    FreeObj(oItem)
                next nX
            endif
            if ValType(oBody:GetJsonObject('SERVICOS')) <> 'U'
                for nX := 1 to len(oBody['SERVICOS'])
                    aAdd(aServs,{cServCod, 1, AllTrim(oBody['SERVICOS'][nX]['Descricao'])})
                next nX 
            endif
            if (oInt:addSmc(cSMC, aSMC, @nSeq):isOk())
                aRet := {.T., 'Sucesso'}
                oJson["SEQ"]    := StrZero(nSeq,2)
                oJson["EST"]    := cEstoque
                oJson["ITEMS"]  := aItems
                if !empty(aSolic) .and. lFazSolic
                    u_cbcIncCompras(aSolic, 'SMC_'+cSMC)
                endif
                if !empty(aServs) .and. lFazSolic
                    u_cbcIncCompras(aServs, 'SMC_'+cSMC)
                endif
            else
                aRet := {.F., oInt:getErrMsg()}
            endif
        endif
    endif
    
	oRes["status"] 			:= aRet[1]
	oRes["msg"]				:= aRet[2]
	oRes["data"]			:= oJson:ToJson()
return(.T.)

static function cancelWms(oWs, oRes)
	local oBody		    := JsonObject():new()
    local oJson		    := JsonObject():new()
	local aRet			:= {.F., 'Sem dados!'}
    local cSeq          := ""
    local cSMC          := ""
    local lCanc         := .F.
    local oInt          := cbcAlmoxInteg():newcbcAlmoxInteg(.F.)

    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if (ValType(oBody:GetJsonObject('SMC')) <> 'U') .and. (ValType(oBody:GetJsonObject('SEQ')) <> 'U')
            cSMC := AllTrim(oBody['SMC'])
            cSeq := AllTrim(oBody['SEQ'])
            if (lCanc := oInt:isSMCCanc(cSMC+cSeq))
                aRet := {.T., 'Sucesso!'}
            else
                aRet := {.F., 'Pedido deve ser devolvido via WMS!'}
            endif
        endif
    endif
    
	oRes["status"] 			:= aRet[1]
	oRes["msg"]				:= aRet[2]
	oRes["data"]			:= oJson:ToJson()
return(.T.)

static function separado(oWs, oRes)
	local oBody		    := JsonObject():new()
    local oJson		    := JsonObject():new()
    local oRet		    := nil
    local oPost         := nil
    local aHeader       := {}
	local aRet			:= {.F., 'Sem dados!'}
    local cSMC          := ""
    local cMovSeq       := ""
    local cAssig        := ""
    local cGoAssig      := ""

    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if !empty(oBody:GetNames())
		if (ValType(oBody:GetJsonObject('SMC')) <> 'U')
            cSMC := cValToChar(Val(SubStr(AllTrim(oBody['SMC']), 1, (Len(AllTrim(oBody['SMC']))-2))))
            aadd(aHeader, 'Content-Type: application/json')
            aadd(aHeader, 'Authorization: Bearer eyJraWQiOiI0MTdjMmEyOS01YWMyLTQ4MDItOGYzYi01NjVmZWYxM2JiNzciLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsInJvbGUiOiJ1c2VyLGFkbWluIiwidGVuYW50IjoxLCJ1c2VyVGVuYW50SWQiOjMsInNpdGVDb2RlIjoiRmx1aWciLCJzaXRlSWQiOjEsInVzZXJUeXBlIjowLCJ1c2VyVVVJRCI6ImIzNjNlOWYxLThhNjktNDNkMC05MjhjLTZhMTc5ZjAyYmUwZSIsInRlbmFudFVVSUQiOiI0MTdjMmEyOS01YWMyLTQ4MDItOGYzYi01NjVmZWYxM2JiNzciLCJsYXN0VXBkYXRlRGF0ZSI6MTYwODA1MjMxNTAwMCwidXNlclRpbWVab25lIjoiQW1lcmljYS9TYW9fUGF1bG8iLCJleHAiOjE2NDk5NDM5NDksImlhdCI6MTY0OTk0Mjc0OSwiYXVkIjoiZmx1aWdfYXV0aGVudGljYXRvcl9yZXNvdXJjZSJ9.E95bkmSaxhW1iZALX3FtAxVeQhKVhmjnoqQNPa_B1Pxll3O3Y9NJnlswbBtjq4dcuDPPGuBSHkffbRcqBSNgoe3JHJVkbLKwA9VwG3EwC695UMjEnPOXIGXt_t2MmPR55S4NO1HuM89vOxi-efhy6qhB7CGCHnB3h--ys71mtoFUDyk8eKngRfovjt47kr5n64Zlbbei-gQeyLP49eRE8J8WwR8EkO7CxoZPi35tNk7vaMpVX3DLY278aEM7RIBprtMv-aa9MkuV9HiFFPwKa67c5OL873_wjKZvcncmHi09ac9AHGj43qyXYk_UpbYz23AMU3x9JUiWj1eVhfJn1Q')            
            oRet := JsonObject():new()
            oRest := FWRest():New(AllTrim(GetNewPar("ZZ_ENDFLUI", "http://192.168.1.217:6080")))
            oRest:SetPath('/process-management/api/v2/requests/' + cSMC + '/tasks')
            if !(oRest:Get(aHeader))
                aRet := {.F., oRest:GetLastError()}
            else                
                oRet:fromJSON(oRest:GetResult())
                if (ValType(oRet:GetJsonObject("content")) <> 'U')
                    if (ValType(oRet["content"]:GetJsonObject("movementSequence")) <> 'U')
                        cMovSeq := oRet["content"]["movementSequence"]
                    endif
                    if (ValType(oRet["content"]:GetJsonObject("currentStates")) <> 'U')
                        if (ValType(oRet["content"]["currentStates"][1]:GetJsonObject("colleagueId")) <> 'U')
                            cAssig   := oRet["content"]["currentStates"][1]["colleagueId"]
                            cGoAssig := oRet["content"]["currentStates"][1]["colleagueId"]
                        endif
                    endif
                endif
            endif
            if !empty(oRet:GetNames())
                FreeObj(oRest)
                oRest := FWRest():New(AllTrim(GetNewPar("ZZ_ENDFLUI", "http://192.168.1.217:6080")))
                oPost := JsonObject():new()
                oPost["movementSequence"]       := cMovSeq
                oPost["assignee"]               := cAssig
                oPost["targetState"]            := 0
                oPost["targetAssignee"]         := cGoAssig
                oPost["subProcessTargetState"]  := 0
                oPost["asManager"]              := .F.
                /*
                    {
                        "movementSequence": 2,
                        "assignee": "admin",
                        "targetState": 0,
                        "targetAssignee": "admin",
                        "subProcessTargetState": 0,
                        "comment": null,
                        "asManager": false,
                            "formFields": {
                            "caprovado": "SIM",
                                "tmotivo": "TESTE DE MOTIVO"
                        }
                    }
                */
                oRest:SetPath('/process-management/api/v2/requests/' + cSMC + '/move')
                oRest:SetPostParams(oPost:toJson())
                if !(oRest:Post(aHeader))
                    aRet := {.F., oRest:GetLastError()}
                else
                    oJson:fromJson(oRest:GetResult())
                    aRet := {.T., ''}
                endif
                FreeObj(oPost)
            endif
            FreeObj(oRest)
            FreeObj(oRet)
        else
            aRet[02] := 'SMC não Informada!'
        endif
    endif
    
	oRes["status"] 			:= aRet[1]
	oRes["msg"]				:= aRet[2]
	oRes["data"]			:= oJson:ToJson()
return(.T.)

static function HandleEr(oErr, aRet)
	default aRet := {.F.,'UserException'}
	aRet := {.F., AllTrim(oErr:Description)}
    u_autoAlert('[API Almozarifado] - Erro: ' + AllTrim(oErr:Description))
	if InTransact()
		DisarmTransaction()
	endif
	BREAK
return(nil)

/*TESTE ZONE*/
user function zTstcbcSMC()
    local oBody		    := JsonObject():new()
    local cBody         := '{"ITEMS": [{"Item": "01","Codigo": "MC15001974","Quant": 15},{"Item": "02","Codigo": "MC15002583","Quant": 1}], "SERVICOS": [{"Descricao": "Retificar motor de teste"}]}'
    local oJson		    := JsonObject():new()
    local oItem			:= nil
	local aRet			:= {.F., 'Sem dados!'}
    local aItems        := {}
    local aSMC          := {}
    local aSolic        := {}
    local aServs        := {}
	local nX			:= 0
    local nSeq          := 0
    local nSaldo        := 0
    local cSMC          := ""
    local oInt          := cbcAlmoxInteg():newcbcAlmoxInteg(.F.)
    local cServCod      := Alltrim(GetNewPar("ZZ_SMCSERV", "SV04000007"))

    oBody:FromJson(cBody)

    cSMC := StrZero(Random(1, 999),6)
    for nX := 1 to len(oBody['ITEMS'])
        oItem := JsonObject():new()
        oItem['Item']       := oBody['ITEMS'][nX]['Item']
        oItem['Codigo']     := oBody['ITEMS'][nX]['Codigo']
        nSaldo := oInt:getSaldoProd(AllTrim(oBody['ITEMS'][nX]['Codigo']))
        if nSaldo >= oBody['ITEMS'][nX]['Quant']
            oItem['Estoque']    := 'S'
        else
            oItem['Estoque']    := 'N'
            aAdd(aSolic,{AllTrim(oBody['ITEMS'][nX]['Codigo']), (oBody['ITEMS'][nX]['Quant'] - nSaldo)})
        endif
        aAdd(aSMC,{AllTrim(oBody['ITEMS'][nX]['Codigo']), oBody['ITEMS'][nX]['Quant']})
        aAdd(aItems,oItem)
        FreeObj(oItem)
    next nX
    for nX := 1 to len(oBody['SERVICOS'])
        aAdd(aServs,{cServCod, 1, AllTrim(oBody['SERVICOS'][nX]['Descricao'])})
    next nX 
    if (oInt:addSmc(cSMC, aSMC, @nSeq):isOk())
        aRet := {.T., 'Sucesso'}
        oJson["SEQ"]    := StrZero(nSeq,2)
        oJson["ITEMS"]  := aItems
        if !empty(aSolic)
            u_cbcIncCompras(aSolic,'SMC_'+cSMC)
        endif
        if !empty(aServs)
            u_cbcIncCompras(aServs, 'SMC_'+cSMC)
        endif
    else
        aRet := {.F., oInt:getErrMsg()}
    endif
return(aRet)
