#INCLUDE "totvs.ch"

user function cbcFluig(cTaskId)
    local oClientFluig  := nil
    local cUrl          := 'http://192.168.1.217:6080'
    local cRet          := ''
    local oMainObj      := nil
    local oJParam       := nil
    local aNames        := {}
    local aInsName      := {}
    local nX            := 0
    local nY            := 0
    default cTaskId     := 60

    oClientFluig := FWoAuth1Fluig():New("chave_simples","protheus_fluig",cUrl,"")
    oClientFluig:SetToken("c5872cc3-2aa3-4d3f-89ad-5fda62b3a63f")
    oClientFluig:setSecretToken('11b552ac-552e-47ce-99dd-ce6794e3409d0d5772bd-a412-4310-b485-e169855933b8')
    
    oMainObj                        := JsonObject():new()
    oJParam		                    := JsonObject():new()
    oJParam['processInstanceId']    := cTaskId
    oJParam['taskUserId']           := 'testeacesso'
    /* Obter html do diagrama e do formulario */
    cRet := oClientFluig:Post('http://192.168.1.217:6080/ecm/api/rest/ecm/workflowView/findDetailsMyRequests',,oJParam:toJson())
    oJRet                    := JsonObject():new()
    oJRet:fromJson(cRet)
    oMainObj['htmlDiagram'] := oJRet['content']['processDiagram']
    oMainObj['htmlForm']    := oJRet['content']['formHtml']
    
    /* Obter lista documentos anexos */
    cRet := oClientFluig:Get("http://192.168.1.217:6080/ecm/api/rest/ecm/workflowView/getAttachments/60/testeacesso/1", "processId=CADCLI")
    oJRet:fromJson(cRet)
    if oJRet['success']
        oMainObj['attachList'] := oJRet['content']['attachments'] 
    else
         MsgInfo(oJRet['message'], 'Erro')
    endif

    /* Obter Historico */
    cRet := oClientFluig:Get("http://192.168.1.217:6080/ecm/api/rest/ecm/workflowView/loadhistory","processInstanceId=60&taskUserId=testeacesso&movementSequence=6&processId=CADCLI")
    oJRet:fromJson(cRet)
    if oJRet['success']
        aNames := oJRet:GetNames()
        aSort(aNames ,,,{ |x,y| (val(x) < val(y))})
        oMainObj['obs'] := ''
        for nX := 1 to len(aNames)
            if oJRet[aNames[nX]]['historyType'] == 'OBSERVATION'
                aInsName := oJRet[aNames[nX]]['mapTasks']:GetNames()
                aSort(aInsName ,,,{ |x,y| (val(x) < val(y))})
                for nY := 1 to len(aInsName)
                oMainObj['obs'] += Alltrim(oJRet[aNames[nX]]['mapTasks'][aInsName[nY]]['completeColleagueName']) + ' '
                oMainObj['obs'] += Alltrim(oJRet[aNames[nX]]['mapTasks'][aInsName[nY]]['observation']) + ' '
                oMainObj['obs'] += oJRet[aNames[nX]]['mapTasks'][aInsName[nY]]['movementDateHour'] + chr(13)+chr(10)
                next nY
            endif
        next nX
    else
         MsgInfo(oJRet['message'], 'Erro')
    endif
   
   /* Iniciar tarefa de SMC */
   oSMC := getJsonMdl()
   oSMC['taskUserId']           := 'testeacesso'
   oSMC['selectedColleague'][1] := 'testeacesso'
  
   putValue('cracha',           '000049',                   @oSMC['formData'])
   putValue('nome',             'Leonardo',                 @oSMC['formData'])
   putValue('setor',            'TI',                       @oSMC['formData'])
   putValue('maquina',          'Extrusora',                @oSMC['formData'])
   putValue('situacao',         'YES',                      @oSMC['formData'])  // (Parado YES NO)
   putValue('prioridade',       'IMEDIATO',                 @oSMC['formData'])  // A IMEDIATO / B URGENTE / C PROGRMADO
   putValue('txt_programado',   '19/02/2021',               @oSMC['formData'])
   putValue('falha',            'Maquina esta esquentando', @oSMC['formData'])
   cRet := oClientFluig:Post('http://192.168.1.217:6080/ecm/api/rest/ecm/workflowView/send',,oSMC:toJson())
   MsgInfo(cRet, 'Criação SMC')
return


static function putValue(cName, xValue, aJs)
    local nPos := AScan( aJs, {|x| Alltrim(x['name']) == Alltrim(cName)} )
    if nPos > 0
        aJs[nPos]['value'] := xValue
    endif
return nil


static function getJsonMdl()
    local cMdlStr := '{"processInstanceId":0,"processId":"SMC","version":4,"taskUserId":"admin","completeTask":true,"currentMovto":0,"managerMode":false,"selectedDestinyAfterAutomatic":-1,"conditionAfterAutomatic":-1,"selectedColleague":["admin"],"comments":"","newObservations":[],"appointments":[],"attachments":[],"digitalSignature":false,"formData":[{"name":"cracha","value":""},{"name":"nome","value":""},{"name":"setor","value":""},{"name":"maquina","value":""},{"name":"situacao","value":"YES"},{"name":"prioridade","value":"IMEDIATO"},{"name":"txt_programado","value":""},{"name":"falha","value":""},{"name":"aprovacao","value":"YES"},{"name":"mtvo_aprovacao","value":""},{"name":"liberado","value":"YES"},{"name":"mtvo_liberado","value":""},{"name":"causas","value":"OPERACIONAL"},{"name":"txt_causa_outra","value":""},{"name":"diagnostico","value":""},{"name":"estoque_tr1","value":"YES"},{"name":"tr1_descricao","value":""},{"name":"tr1_requisicao","value":""},{"name":"estoque_tr2","value":"YES"},{"name":"tr2_descricao","value":""},{"name":"tr2_requisicao","value":""},{"name":"estoque_tr3","value":"YES"},{"name":"tr3_descricao","value":""},{"name":"tr3_requisicao","value":""},{"name":"estoque_tr4","value":"YES"},{"name":"tr4_descricao","value":""},{"name":"tr4_requisicao","value":""},{"name":"estoque_tr5","value":"YES"},{"name":"tr5_descricao","value":""},{"name":"tr5_requisicao","value":""},{"name":"estoque_tr6","value":"YES"},{"name":"tr6_descricao","value":""},{"name":"tr6_requisicao","value":""},{"name":"manu_nome01","value":""},{"name":"manu_nome02","value":""},{"name":"manu_terceiro","value":""}],"isDigitalSigned":false,"isLinkReturn":false,"versionDoc":0,"selectedState":"10","internalFields":[],"subProcessId":"SMC","subProcessSequence":"10","transferTaskAfterSelection":false,"currentState":11}'
    local oJs     := nil
    oJs := JsonObject():new()
    oJs:fromJson(cMdlStr)
return oJs
