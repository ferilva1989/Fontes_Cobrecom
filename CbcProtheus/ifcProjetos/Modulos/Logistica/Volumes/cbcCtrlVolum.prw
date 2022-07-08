#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"
#include 'FWMVCDef.ch'
#include 'cbcOrdemSep.ch'

#define ARR_ACONDIC 01
#define ARR_PESO    02
#define ARR_TIPO    03
#define ARR_QTDE    04
#define ARR_COD     05
#define ARR_METRAG  06

class cbcCtrlVolum

    data lOk
    data cMsgErr
    data lShowErr

    method newcbcCtrlVolum()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method loadRules()
    method genVolumes()
    method loadVolumes()
endClass

method newcbcCtrlVolum(lShowErr) class cbcCtrlVolum
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcCtrlVolum
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[cbcCtrlVolum] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcCtrlVolum')
            endif
        endif
    endif
return(self)

method isOk() class cbcCtrlVolum
return(::lOk)

method getErrMsg() class cbcCtrlVolum
return(::cMsgErr)

method showErr() class cbcCtrlVolum
return(::lShowErr)

method loadRules(cCarga, cOS) class cbcCtrlVolum
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local oReg      := nil
    local oSql      := nil
    local nX        := 0
    local aRules    := {}
    local aRule     := {}
    Local oStatic   := IfcXFun():newIfcXFun()
    default cCarga  := ''
    default cOS     := ''

    if empty(cCarga) .or. (empty(cCarga) .and. empty(cOS))
        initRule(@aRule)
        if !empty(aRule)
            aSort(aRule, , , { | x,y | x[1] < y[1] } )
        endif
        aAdd(aRules, {cOS, AClone(aRule)})
    else
        dbSelectArea('ZZ9')
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'getRegs', cCarga, cOS))
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                aRule := {}
                oReg := JsonObject():new()
                ZZ9->(DbGoTo(oSql:getValue("REC")))
                oReg:FromJSON(ZZ9->ZZ9_JSVOLU)
                if !empty(oReg:GetNames())
                    if ValType(oReg:GetJsonObject('REGRA')) <> 'U'
                        for nX := 1 to len(oReg['REGRA'])
                            aAdd(aRule, (oReg['REGRA'][nX]))
                        next nX
                    endif
                endif
                if !empty(aRule)
                    aSort(aRule, , , { | x,y | x[1] < y[1] } )
                endif
                aAdd(aRules, {AllTrim(ZZ9->ZZ9_ORDSEP), aClone(aRule)})
                FreeObj(oReg)
                oSql:skip()
            endDo
        endif
        oSql:Close()
        FreeObj(oSql)
    endif
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(aRules)

method genVolumes(aTarg) class cbcCtrlVolum
    local aVolumes  := {}
    local nX        := 0
    default aTarg   := {}
    for nX := 1 to len(aTarg)
        aAdd(aVolumes, {aTarg[nX, 01], applyRules(aTarg[nX, 02], aTarg[nX, 01]), FwFilial()})
    next nX
return(aVolumes)

method loadVolumes(cCarga, cOS, aRule) class cbcCtrlVolum
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local aVolumes  := {}
    local oReg      := nil
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    default cOS     := ''

    DbSelectArea('ZZ9')

    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'getRegs', cCarga, cOS))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            oReg := JsonObject():new()
            ZZ9->(DbGoTo(oSql:getValue("REC")))
            oReg:FromJSON(ZZ9->ZZ9_JSVOLU)
            aAdd(aVolumes, {ZZ9->ZZ9_ORDSEP, oReg, ZZ9->ZZ9_FILORI})
            FreeObj(oReg)
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)

    RestArea(aAreaZZ9)
    RestArea(aArea)
return(aVolumes)

/*SERVICES ZONE*/
static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)

static function initRule(aRule)
    local aRet		:= {}
    local oFormulas := ctrlIniFormul():newctrlIniFormul()
    local cKey  	:= AllTrim(GetNewPar('ZZ_DEFVOL', 'DEF_VOLUMES'))
    local nX		:= 0
    default aRule	:= {}

    oFormulas:setKeyForm(cKey)
    aRet := oFormulas:getFormulas()
    for nX := 1 to len(aRet)
        aAdd(aRule, &(aRet[nX,3]))
    next nX
    FreeObj(oFormulas)
return(aRule)

static function applyRules(aRules, cOS)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local aAreaZZR 	:= ZZR->(GetArea())
    local oSql      := nil
    local aWork     := {}
    local aVolumes  := {}
    local aVol      := {}
    local oVolume   := JsonObject():new()
    local nTara     := 0
    local nLiq      := 0
    default aRules  := {}

    if !empty(cOS)
        oVolume['REGRA'] := aRules
        aSort(aRules, , , { | x,y | x[1] < y[1] } )
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(qryOSItems(cOS, aRules))
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                aAdd(aWork, {AllTrim(oSql:getValue("ACONDI")),;
                    oSql:getValue("PESO"),;
                    AllTrim(oSql:getValue("TIPO")),;
                    oSql:getValue("QTDE"),;
                    AllTrim(oSql:getValue("COD")),;
                    oSql:getValue("METRAG");
                    })
                nLiq += oSql:getValue("PESO")
                oSql:skip()
            endDo
            aVolumes := workVol(aRules, @aWork, @nTara)
            if !empty(aVol := workGranel(@aWork))
                aAdd(aVolumes, AClone(aVol))
            endif
        endif
        oSql:Close()
        FreeObj(oSql)
        oVolume['VOLUMES']      := aVolumes
        oVolume['PESOBRUTO']    := nLiq + nTara
        oVolume['PESOTARA']     := nTara
        oVolume['PESOLIQUIDO']  := nLiq
        oVolume['USER']         := {RetCodUsr(), DtoC(Date()), time()}
    endif
    RestArea(aAreaZZR)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(oVolume)

static function workVol(aRule, aWork, nTara)
    local aArea    	:= GetArea()
    local aAreaSB1 	:= SB1->(GetArea())
    local nX        := 0
    local nY        := 0
    local nZ        := 0
    local nPosi     := 0
    local nPosProd  := 0
    local nQtdFard  := 0
    local nRestFard := 0
    local nLances   := 0
    local nPosFard  := 0
    local nPesVol   := 0
    local aMatch    := {}
    local aVol      := {}
    local aDelMatch := {}
    local aFardos   := {}
    default nTara   := 0.00

    DbSelectArea('SB1')
    //Loop nos Tipos de Volumes da Regra
    for nZ := 1 to len(aRule)
        if !empty(aRule[nZ, 07]) .and. ValType(aRule[nZ, 07]) == 'A'
            //Loop nos Acondicionamentos da Regra
            for nY := 1 to len(aRule[nZ, 07])
                //Loop nos Produtos
                for nX := 1 to len(aWork)
                    //Compara acondicionamento do Produto com o da Regra
                    if AllTrim(aWork[nX, ARR_ACONDIC]) == AllTrim(aRule[nZ, 07, nY, 01])
                        //Compara o tipo do Acondicionamento com o da Regra
                        if empty(aRule[nZ, 07, nY, 02]) .or. (AllTrim(aRule[nZ, 07, nY, 02]) == AllTrim(aWork[nX, ARR_TIPO]))
                            //Procura já adicionado
                            nPosi := AScan( aMatch, {|x| x[1] == nX} )
                            if nPosi > 0
                                //Adiciona produto a Regra no Match
                                aAdd(aMatch[nPosi, 02], nZ)
                            else
                                //Adiciona produto e peso a Regra no Match
                                aAdd(aMatch, {nX, {nZ}, aWork[nX, ARR_PESO]})
                            endif
                        endif
                    endif
                next nX
            next nY
        endif
    next nZ
    //Pegar peso Total do que é volume na carga
    for nY := 1 to len(aMatch)
        nPesVol += aMatch[nY, 03]
    next nY
    //Verificar se atende os limites
    for nY := 1 to len(aMatch)
        for nZ := 1 to len(aMatch[nY, 02])
            if nPesVol >= aRule[aMatch[nY,02,nZ], 03] .and. nPesVol <= aRule[aMatch[nY,02,nZ],04]
                //Verifica se Tipo de Volume já foi adicionado
                nPosi := AScan( aVol, {|x| x[1] == aRule[aMatch[nY,02,nZ],02]} )
                if nPosi == 0
                    //Adiciona tipo do volume
                    aAdd(aVol, {aRule[aMatch[nY,02,nZ],02] /*Tipo do Volume*/,0/*Peso Total*/,{}/*Produtos*/,0/*Qtd de Volumes*/,0/*Peso Total da Embalagem*/})
                    nPosi := len(aVol)
                    nPosProd := 0
                else
                    nPosProd := AScan(aVol[nPosi, 03], {|x| x[1] == AllTrim(aWork[(aMatch[nY, 01]), ARR_ACONDIC]) .and. x[2] == AllTrim(aWork[(aMatch[nY, 01]), ARR_TIPO])} )
                endif
                /*Adiciona Produto*/
                if nPosProd == 0
                    aAdd(aVol[nPosi, 03], {AllTrim(aWork[(aMatch[nY, 01]), ARR_ACONDIC]),;
                        AllTrim(aWork[(aMatch[nY, 01]), ARR_TIPO]),;
                        aWork[(aMatch[nY, 01]), ARR_PESO],;
                        aWork[(aMatch[nY, 01]), ARR_QTDE];
                        })
                else
                    aVol[nPosi, 03, nPosProd, 03] += aWork[(aMatch[nY, 01]), ARR_PESO]
                    aVol[nPosi, 03, nPosProd, 04] += aWork[(aMatch[nY, 01]), ARR_QTDE]
                endif
                /*Soma Peso*/
                aVol[nPosi, 02] += Round(aMatch[nY, 03],2)
                
                /*Tratativa para Volumes diferente de FARDOS*/
                if AllTrim(aVol[nPosi, 01]) <> 'F'                    
                    /*Soma Qtd Vol*/
                    aVol[nPosi, 04] := Ceiling((aVol[nPosi, 02] / aRule[aMatch[nY,02,nZ],05]))
                    /*Soma Peso da Embalagem*/
                    aVol[nPosi, 05] := (aVol[nPosi, 04] * aRule[aMatch[nY,02,nZ],06])
                    //nTara += (Ceiling(( Round(aMatch[nY, 03],2) / aRule[aMatch[nY,02,nZ],05])) * aRule[aMatch[nY,02,nZ],06])                    
                else
                    /*Preparo ARRAY para Tratativa de FARDOS posterior*/
                    nPosFard := AScan(aFardos, {|x| x[1] == nPosi})
                    if nPosFard == 0
                        aAdd(aFardos, {nPosi, {}, aRule[aMatch[nY,02,nZ],06]})
                        nPosFard := len(aFardos)
                    endif
                    nQtdFard  := Posicione("SB1",1,xFilial("SB1")+ aWork[(aMatch[nY, 01]), ARR_COD],"B1_QTSCS")
                    //Tratativa para casos de cadastro zerado no SB1 ficará como padrão 1 pra 1
                    if nQtdFard <= 0
                        nQtdFard := 1
                    else
                        if aWork[(aMatch[nY, 01]), ARR_METRAG] <= 50
                            nQtdFard := (nQtdFard * 2)
                        endif
                    endif                    
                    nLances   := aWork[(aMatch[nY, 01]), ARR_QTDE]
                    aAdd(aFardos[nPosFard, 02], {nQtdFard, nLances, aWork[(aMatch[nY, 01]), ARR_METRAG]})
                endif
                aAdd(aDelMatch, aMatch[nY, 01])
                EXIT
            endif
        next nZ
    next nY
    /*Tratamento da composição dos FARDOS*/
    for nY := 1 to len(aFardos)
        nQtdFard    := 0
        nRestFard   := 0
        for nX := 1 to len(aFardos[nY, 02])
            nQtdFard += INT(aFardos[nY, 02, nX, 02] / aFardos[nY, 02, nX, 01])
            /*Calcula a Ocupação do Resto em um fardo a partir do Fator e agrega a variavel de Resto*/
            nRestFard += (Round(((aFardos[nY, 02, nX, 02] % aFardos[nY, 02, nX, 01]) / aFardos[nY, 02, nX, 01]),2))
        next nX
        if nRestFard > 0
            nQtdFard += Ceiling(nRestFard)
        endif
        /*Agregar no aVol na posição salva no aFardos o valor inteiro de Sacos*/ 
        aVol[aFardos[nY, 01], 04] += nQtdFard
        aVol[aFardos[nY, 01], 05] += (nQtdFard * aFardos[nY, 03])
        //nTara += (nQtdFard * aFardos[nY, 03])
    next nY
    for nY := 1 to len(aVol)
        nTara += aVol[nY, 05]
    next nY
    aSort(aDelMatch, , , { | x,y | x > y } )
    for nY := 1 to len(aDelMatch)
        aDel(aWork, aDelMatch[nY])
        aSize(aWork,(len(aWork)-1))
    next nY
    RestArea(aAreaSB1)
    RestArea(aArea)
return(aVol)

static function workGranel(aWork)
    local nX    := 0
    local nPosi := 0
    local aVol  := {}

    if !empty(aWork)
        aVol := {'G', 0, {}, 0, 0}
        for nX := 1 to len(aWork)
            nPosi := AScan( aVol[03], {|x| x[1] == AllTrim(aWork[nX, ARR_ACONDIC]) .and. x[2] == AllTrim(aWork[nX, ARR_TIPO])} )
            if nPosi == 0
                aAdd(aVol[03], {AllTrim(aWork[nX, ARR_ACONDIC]),;
                    AllTrim(aWork[nX, ARR_TIPO]),;
                    aWork[nX, ARR_PESO],;
                    aWork[nX, ARR_QTDE];
                    })
            else
                aVol[03, nPosi, 03] += aWork[nX, ARR_PESO]
                aVol[03, nPosi, 04] += aWork[nX, ARR_QTDE]
            endif
            aVol[02] += aWork[nX, ARR_PESO]
            aVol[04] += aWork[nX, ARR_QTDE]
        next nX
        aWork := {}
    endif
return(aVol)

static function loadTPFilter(aRules, cTp)
    local nX := 0
    local nY := 0

    for nX := 1 to len(aRules)
        for nY := 1 to len(aRules[nX, 07])
            if (AllTrim(aRules[nX, 07, nY, 01]) <> 'B')
                if !empty(aRules[nX, 07, nY, 02])
                    if !empty(cTp)
                        cTp += ","
                    endif
                    cTp += "'" + StrZero(Val(AllTrim(aRules[nX, 07, nY, 02])), 5) + "'"
                endif
            endif
        next nY
    next nX
return(nil)

static function VolCompare(cCarga, aVolO, aVolD)
    local nX    := 0
    local aRet  := {}
    local aDetO := {}
    local aDetD := {}
    local cStrO := ''
    local cStrD := ''
    local oJson := nil
    Local oStatic   := IfcXFun():newIfcXFun()
        
    if !empty(aVolO) .and. !empty(aVolD)
        oStatic:sP(5):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aDetO, aVolO, .T.)
        oStatic:sP(5):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aDetD, aVolD, .T.)
        if len(aDetO) == len(aDetD)
            for nX := 1 to len(aDetD)
                oJson := JsonObject():new()
                cStrO := makeStrVol(aDetO[nX])
                cStrD := makeStrVol(aDetD[nX])
                if cStrO <> cStrD
                    oJson['VOLUMES'] := {cStrO, cStrD}
                endif
                if aDetO[nX, 10] <> aDetD[nX, 10]
                    oJson['PESOBRUTO'] := {aDetO[nX, 10], aDetD[nX, 10]}
                endif                
                if aDetO[nX, 11] <> aDetD[nX, 11]
                    oJson['PESOLIQUIDO'] := {aDetO[nX, 11], aDetD[nX, 11]}
                endif
                if aDetO[nX, 12] <> aDetD[nX, 12]
                    oJson['PESOTARA'] := {aDetO[nX, 12], aDetD[nX, 12]}
                endif
                if !empty(oJson:GetNames())
                    oJson['CARGA']      := cCarga
                    oJson['NF']         := aDetD[nX, 01]
                    oJson['OS']         := aDetD[nX, 02]
                    oJson['CLIENTE']    := aDetD[nX, 03]
                    aAdd(aRet, oJson)
                endif
                FreeObj(oJson)
            next nX
        endif
    endif
return(aRet)

static function makeStrVol(aVol, aEsp)
    local cVol  := ''
    local nX    := 0
    local aPosi := {{'F', 04},{'C', 05},{'B', 06},{'P', 07},{'CX', 08},{'R', 09}}
    default aEsp:= {}
    // 3 primeiros são os informativos
    for nX := 1 to len(aPosi)
        if aVol[aPosi[nX, 02]] > 0
            if !empty(cVol)
                cVol += '|'
            endif
            aAdd(aEsp, {aPosi[nX, 01], aVol[aPosi[nX, 02]]})
            cVol += cValToChar(aVol[aPosi[nX, 02]]) + '-' + aPosi[nX, 01]
        endif
    next nX
return(cVol)

static function reqCCE(aDiverg)
    local aRet      := {}
    local nX        := 0
    local cBody     := ''
    local cSubject  := 'Solicitação de Carta de Correção'
    local cMail     := GetNewPar('ZZ_MREQCCE', 'wfti@cobrecom.com.br')
    local cLinha	:= '<br>'
    default aDiverg := {}

    for nX := 1 to len(aDiverg)
        cBody := ''
        cBody += 'NF: ' + aDiverg[nX]['NF']
        cBody += ' || CARGA: ' + aDiverg[nX]['CARGA']
        cBody += ' || OS: ' + aDiverg[nX]['OS']
        cSubject := '[Carta de Correção]' + ' - ' + cBody
        cBody += cLinha
        cBody += '<table border="1">'
        cBody += '<tr>'
        cBody += '<td>' + 'TIPO' + '</td>'
        cBody += '<td>' + 'ORIGINAL' + '</td>'
        cBody += '<td>' + 'ALTERADO' + '</td>'
        cBody += '</tr>'
        if ValType(aDiverg[nX]:GetJsonObject('VOLUMES')) <> 'U'
            cBody += '<tr>'
            cBody += '<td>' + 'VOLUMES' + '</td>'
            cBody += '<td>' + aDiverg[nX]['VOLUMES'][01] + '</td>'
            cBody += '<td>' + aDiverg[nX]['VOLUMES'][02] + '</td>'
            cBody += '</tr>'
        endif
        if ValType(aDiverg[nX]:GetJsonObject('PESOBRUTO')) <> 'U'
            cBody += '<tr>'
            cBody += '<td>' + 'PESO BRUTO' + '</td>'
            cBody += '<td>' + cValToChar(aDiverg[nX]['PESOBRUTO'][01]) + '</td>'
            cBody += '<td>' + cValToChar(aDiverg[nX]['PESOBRUTO'][02]) + '</td>'
            cBody += '</tr>'
        endif
        if ValType(aDiverg[nX]:GetJsonObject('PESOLIQUIDO')) <> 'U'
            cBody += '<tr>'
            cBody += '<td>' + 'PESO LIQUIDO' + '</td>'
            cBody += '<td>' + cValToChar(aDiverg[nX]['PESOLIQUIDO'][01]) + '</td>'
            cBody += '<td>' + cValToChar(aDiverg[nX]['PESOLIQUIDO'][02]) + '</td>'
            cBody += '</tr>'
        endif
        if ValType(aDiverg[nX]:GetJsonObject('PESOTARA')) <> 'U'
            cBody += '<tr>'
            cBody += '<td>' + 'PESO TARA' + '</td>'
            cBody += '<td>' + cValToChar(aDiverg[nX]['PESOTARA'][01]) + '</td>'
            cBody += '<td>' + cValToChar(aDiverg[nX]['PESOTARA'][02]) + '</td>'
            cBody += '</tr>'
        endif
        cBody += '</table>'
        aAdd(aRet,{aDiverg[nX]['NF'], aDiverg[nX]['CARGA'], aDiverg[nX]['OS']})
        u_SendMail(cMail, cSubject, cBody)
    next nX
return(aRet)

static function qryOSItems(cOS, aRules)
    local cQry      := ''
    local cTp       := ''
    default cOS     := ''

    //loadTPFilter(aRules, @cTp)

    cQry += " SELECT TEMP.COD AS [COD], "
    cQry += " TEMP.ACONDI AS [ACONDI], "
    cQry += " TEMP.TIPO AS [TIPO], "
    cQry += " TEMP.METRAG AS [METRAG], "
    cQry += " SUM(TEMP.PESO) AS [PESO], "
    cQry += " SUM(TEMP.QTDE) AS [QTDE] "
    cQry += " FROM ( "
    cQry += " SELECT  "
    cQry += " ZZR.ZZR_PRODUT AS [COD], "
    cQry += " SUBSTRING(ZZR.ZZR_LOCALI, 1, 1) AS [ACONDI], "
    if !empty(cTp)
        cQry += " CASE "
        cQry += " 	WHEN SUBSTRING(ZZR.ZZR_LOCALI, 2, 5) IN (" + cTp + ")"
        cQry += " 		THEN SUBSTRING(ZZR_LOCALI,2,LEN(ZZR_LOCALI)) "
        cQry += " 	ELSE '' "
        cQry += " END AS [TIPO], "
    else
        cQry += " '' AS [TIPO], "
    endif
    cQry += " SUM(ZZR.ZZR_EMBALA+ZZR.ZZR_PESPRO) AS [PESO], "
    cQry += " CASE "
    cQry += "   WHEN SUBSTRING(ZZR.ZZR_LOCALI, 1, 1) = 'L' "
    cQry += "       THEN SUM(ZZR.ZZR_LANCES / ZZR.ZZR_QTCAIX)"
    cQry += "   ELSE SUM(ZZR.ZZR_LANCES) "
    cQry += " END AS [QTDE], "
    cQry += " CAST(SUBSTRING(ZZR.ZZR_LOCALI,2,LEN(ZZR.ZZR_LOCALI)) AS INT) AS [METRAG] "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR WITH(NOLOCK) "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
    cQry += " AND (ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS = '" + AllTrim(cOS) + "'  "
    cQry += " OR ZZR.ZZR_OS = '" + AllTrim(cOS) + "') "
    cQry += " AND SUBSTRING(ZZR.ZZR_LOCALI, 1, 1) <> 'B' "
    cQry += " AND ZZR.ZZR_SITUAC <> '" + OS_CANCELADA + "' "
    cQry += " AND ZZR.D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZZR.ZZR_PRODUT, SUBSTRING(ZZR.ZZR_LOCALI, 1, 1), "
    cQry += " SUBSTRING(ZZR.ZZR_LOCALI,2,LEN(ZZR.ZZR_LOCALI)) "
    cQry += " UNION "
    cQry += " SELECT "
    cQry += " ZZR.ZZR_PRODUT AS [COD], "
    cQry += " SUBSTRING(ZZR.ZZR_LOCALI, 1, 1) AS [ACONDI], "
    cQry += " CASE "
    cQry += " 	WHEN SZE.ZE_TPBOB IS NULL "
    cQry += " 		THEN '' "
    cQry += " 	ELSE SZE.ZE_TPBOB "
    cQry += " END AS [TIPO], "
    cQry += " SUM(ZZR.ZZR_EMBALA+ZZR.ZZR_PESPRO) AS [PESO], "
    cQry += " SUM(ZZR.ZZR_LANCES) AS [QTDE], "
    cQry += " CAST(SUBSTRING(ZZR.ZZR_LOCALI,2,LEN(ZZR.ZZR_LOCALI)) AS INT) AS [METRAG] "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR WITH(NOLOCK) "
    cQry += " LEFT JOIN " + RetSqlName('SZE') + " SZE WITH(NOLOCK)  "
    cQry += "                     ON ZZR.ZZR_FILIAL  = SZE.ZE_FILIAL "
    cQry += " 					AND ZZR.ZZR_NROBOB = SZE.ZE_NUMBOB "
    cQry += " 					AND ZZR.D_E_L_E_T_ = SZE.D_E_L_E_T_ "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
    cQry += " AND (ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS = '" + AllTrim(cOS) + "'  "
    cQry += " OR ZZR.ZZR_OS = '" + AllTrim(cOS) + "') "
    cQry += " AND SUBSTRING(ZZR.ZZR_LOCALI, 1, 1) = 'B' "
    cQry += " AND ZZR.D_E_L_E_T_ = '' "
    cQry += " AND ZZR.ZZR_SITUAC <> '" + OS_CANCELADA + "' "
    cQry += " GROUP BY ZZR.ZZR_PRODUT, SUBSTRING(ZZR.ZZR_LOCALI, 1, 1), SZE.ZE_TPBOB, SUBSTRING(ZZR.ZZR_LOCALI,2,LEN(ZZR.ZZR_LOCALI)) "
    cQry += " ) AS TEMP "
    cQry += " GROUP BY TEMP.COD, TEMP.METRAG, TEMP.ACONDI, TEMP.TIPO "
    cQry += " ORDER BY TEMP.COD, TEMP.METRAG, TEMP.ACONDI, TEMP.TIPO "
return(cQry)

/* TEST ZONE */
user function ztstVolum(cOS) //ztstVolum('27220801')
    local oCtrl := cbcCtrlVolum():newcbcCtrlVolum()
    local oJson := nil
    local aRules:= {}
    aRules  := u_cbcRulesVolum()
    oJson   := oCtrl:genVolumes(aRules, cOS)
return(oJson)
