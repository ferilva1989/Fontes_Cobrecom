#include 'Totvs.ch'

class cbcTrkSSW
    method newcbcTrkSSW() constructor
    method consulta()
endClass

method newcbcTrkSSW() class cbcTrkSSW
return(self)

method consulta(cChave) class cbcTrkSSW
    local aHeader   as array
    local oRest     as object
    local nStatus   as numeric
    local cError    as character
    local jBody     as object
    local oResp     as object

    aHeader := {}
    oRest := FWRest():New("https://ssw.inf.br")
    oRest:setPath("/api/trackingdanfe")
    
    aAdd(aHeader,"Accept-Encoding: UTF-8")
    aAdd(aHeader,"Content-Type: application/json; charset=utf-8")

    jBody := JsonObject():New()
    oResp := JsonObject():New()
    oResp['STS']    := .T.
    oResp['DATA']   := JsonObject():New()
    oResp['MSG']    := ''

    jBody["chave_nfe"] := cChave

    oRest:SetPostParams(jBody:toJson())
    oRest:SetChkStatus(.F.)
    if oRest:Post(aHeader)
        cError  := ""
        nStatus := HTTPGetStatus(@cError)
        if nStatus >= 200 .And. nStatus <= 299
            if Empty(oRest:GetResult())
                oResp['STS']    := .F.
                oResp['MSG']    := cValToChar(nStatus)
            else
                 oResp['DATA']:fromJson(oRest:GetResult())
            endif
        else
           oResp['STS']     := .F.
           oResp['MSG']     := cError
        endif
    else
       oResp['STS']     := .F.
       oResp['MSG']     := oRest:getLastError() + CRLF + oRest:GetResult()
    endif
    
    FreeObj(jBody)
    FreeObj(oRest)
return(oResp)
