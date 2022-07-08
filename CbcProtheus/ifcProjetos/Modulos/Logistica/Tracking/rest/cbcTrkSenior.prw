#include 'Totvs.ch'

class cbcTrkSenior
    data cTenant
    method newcbcTrkSenior() constructor
    method consulta()
endClass

method newcbcTrkSenior(cTenant) class cbcTrkSenior
    /*
    "trdtransportes"
    "rissotransportes"
    "rocell"
    */
    ::cTenant := cTenant
return(self)

method consulta(cChave) class cbcTrkSenior
    local aHeader   as array
    local oRest     as object
    local nStatus   as numeric
    local cError    as character
    local jBody     as object
    local oResp     as object

    aHeader := {}
    oRest := FWRest():New("https://platform.senior.com.br")
    oRest:setPath("/t/senior.com.br/bridge/1.0/anonymous/rest/tms/tck/actions/externalTenantConsultaTracking")
    
    aAdd(aHeader,"Accept-Encoding: UTF-8")
    aAdd(aHeader,"Content-Type: application/json; charset=utf-8")
    aAdd(aHeader,"externaluser: true")
    aAdd(aHeader,"x-tenant: " + Alltrim(::cTenant))

    jBody := JsonObject():New()
    oResp := JsonObject():New()
    oResp['STS']    := .T.
    oResp['DATA']   := JsonObject():New()
    oResp['MSG']    := ''

    jBody["documento"]          := getNota(cChave)
    jBody["inscricaoFiscal"]    := getCnpjByCh(cChave)

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

//TODO: Obter CNPJ filial pela chave
static function getCnpjByCh(cChave)
//return '02544042000119'
return '02544042000119'

//TODO: Obter NOTA pela chave
static function getNota(cChave)
return '48944'
