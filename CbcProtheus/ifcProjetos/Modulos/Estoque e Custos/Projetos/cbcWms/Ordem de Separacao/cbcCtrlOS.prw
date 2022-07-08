#include 'protheus.ch'
#include 'parmtype.ch'
#include 'cbcOrdemSep.ch'

class cbcCtrlOS

    data lOk
    data cMsgErr
    data lShowErr
    data cOS

    method newcbcCtrlOS()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getOS()
    method isJoined()
    method define()
    method add()
    method cancel()
    method update()
    method print()
    method inUse()
    method genSequen()
    method cancelWms()
    method export()

endClass

method newcbcCtrlOS(cOS, lShowErr) class cbcCtrlOS
    default lShowErr := .T.
    default cOS      := ''
    ::lShowErr  := lShowErr
    ::define(cOS)
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcCtrlOS
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[cbcCtrlOS] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcCtrlOS')
            endif
        endif
    endif
return(self)

method isOk() class cbcCtrlOS
return(::lOk)

method getErrMsg() class cbcCtrlOS
return(::cMsgErr)

method showErr() class cbcCtrlOS
return(::lShowErr)

method getOS() class cbcCtrlOS
return(::cOS)

method isJoined() class cbcCtrlOS
    local aArea    	:= GetArea()
    local aAreaZZR 	:= ZZR->(GetArea())
    local oSql      := nil
    local lJoined   := .F.
    Local oStatic    := IfcXFun():newIfcXFun()

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryOrdSep', 'qryIsJoined', ::getOS()))
    lJoined := oSql:hasRecords()
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaZZR)
    RestArea(aArea)
return(lJoined)

method define(cOS) class cbcCtrlOS
    default cOS     := ''
    ::cOS           := cOS
return(self)

method update(aFldValue, cPedSeq) class cbcCtrlOS
    local aArea    	    := GetArea()
    local aAreaZZR 	    := ZZR->(GetArea())
    local oSql          := nil
    local aRet          := {}
    local bErro		    := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    Local oStatic       := IfcXFun():newIfcXFun()
    default aFldValue   := {}
    default cPedSeq     := ''

    if !empty(aFldValue)
        if ::setStatus(!empty(::getOS()), 'OS não Definida!'):isOk()
            BEGIN SEQUENCE
                oSql := LibSqlObj():newLibSqlObj()
                oSql:newAlias(oStatic:sP(3):callStatic('cbcQryOrdSep', 'qryGetOSData', ::getOS(), cPedSeq,.F.))
                if oSql:hasRecords()
                    oSql:goTop()
                    BEGIN TRANSACTION
                        while oSql:notIsEof()
                            aRet := updateZZR(oSql:getValue("REC"), aFldValue)
                            ::setStatus(aRet[1], cValToChar(aRet[2]), .T.)
                            oSql:skip()
                        endDo
                    END TRANSACTION
                endif
                RECOVER
            END SEQUENCE
            ErrorBlock(bErro)
            oSql:close()
            FreeObj(oSql)
        endif
    endif

    RestArea(aAreaZZR)
    RestArea(aArea)
return(self)

method inUse(lOnlyPed) class cbcCtrlOS
    local aArea    	:= GetArea()
    local aAreaZZR 	:= ZZR->(GetArea())
    local oSql      := nil
    local lInUse    := .F.
    Local oStatic   := IfcXFun():newIfcXFun()
    default lOnlyPed:= .F.  

    if ::setStatus(!empty(::getOS()), 'OS não Definida!'):isOk()
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(oStatic:sP(2):callStatic('cbcQryOrdSep', 'qryInUse', ::getOS(), lOnlyPed))
        lInUse := oSql:hasRecords()
        oSql:close()
    endif
    FreeObj(oSql)
    RestArea(aAreaZZR)
    RestArea(aArea)
return(lInUse)

method export() class cbcCtrlOS
    local aArea    	:= GetArea()
    local aAreaZZR 	:= ZZR->(GetArea())
    local oInt      := cbcExpIntegra():newcbcExpIntegra(.F.)
    local oJson     := JsonObject():new()
    local aWhere    := {}
    local bErro		:= ErrorBlock({|oErr| HandleEr(oErr, @self)})

    if ::setStatus(!empty(::getOS()), 'OS não Definida!'):isOk()
        aAdd(aWhere,{"mov_tipo", 'SEP'})
        aAdd(aWhere,{"codUnico", ::getOS()})
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                ::setStatus(::update({{'ZZR_SITUAC', OS_SEPARANDO}}):isOk(), 'Erro na alteração STATUS na ZZR!', .T.)
                if empty(Len(oInt:getEnder(aWhere)))
                    oJson['rua']            := 'X'
                    oJson['prateleira']     := 'X'
                    oJson['nivel']          := 'X'
                    oJson['posicao']        := 'X'
                    oJson['cap_max']        := 0
                    oJson['perc_ocupado']   := 0
                    oJson['op_atual']       := ''
                    oJson['ativo']          := .T.
                    oJson['mov_tipo']       := 'SEP'
                    oJson['codUnico']       := ::getOS()
                    oJson['json_regra']     := getOSData(::getOS(), ::isJoined())            
                    ::setStatus(oInt:addOS(oJson):isOk(), 'OS:' + ::getOS() + ' não Integrada!',.T.)
                endif
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    FreeObj(oInt)
    FreeObj(oJson)
    RestArea(aAreaZZR)
    RestArea(aArea)
return(self)

method cancelWms(nId, lTestMode) class cbcCtrlOS
    local aArea    	    := GetArea()
    local aAreaZZR 	    := ZZR->(GetArea())
    local oInt          := cbcExpIntegra():newcbcExpIntegra(.F.)
    local aFldUpd       := {}
    default lTestMode   := .F.
    default nId         := 0

    if lTestMode
        ::setStatus(oInt:removeOS(::getOS(), nId):isOk(), 'OS:' + ::getOS() + ' não Removida!')
    else
        if ::setStatus((!empty(::getOS()) .and. !empty(nId)), 'OS não Definida!'):isOk()
            BEGIN TRANSACTION
                aAdd(aFldUpd, {'ZZR_SITUAC', OS_GERADA})
                ::update(aFldUpd)
                if ::isOk()
                    ::setStatus(oInt:removeOS(::getOS(), nId):isOk(), 'OS:' + ::getOS() + ' não Removida!')
                endif
                if !(::isOk())
                    DisarmTransaction()
                endif
            END TRANSACTION
        endif
    endif
    FreeObj(oInt)
    RestArea(aAreaZZR)
    RestArea(aArea)
return(self)

/*SERVICES ZONE*/
static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)

static function getOSData(cOS, isJoined)
    local aArea    	:= GetArea()
    local aAreaZZR 	:= ZZR->(GetArea())
    local oData     := JsonObject():new()
    local oItem     := nil
    local nX        := 0
    local nPos      := 0
    local aCli      := {}
    local aItems    := {}
    local aJsItems  := {}
    local nPesoBob  := 0.00
    local nPesoSep  := 0.00
    Local oStatic   := IfcXFun():newIfcXFun()

    aItems := oStatic:sP(2):callStatic('cbcPrtOS', 'getOsItems', cOS, isJoined)
    for nX := 1 to len(aItems)
        nPos := 0
        if (aScan(aCli, AllTrim(aItems[nX, 15])) == 0)
            aAdd(aCli, AllTrim(aItems[nX, 15]))
        endif
        if left(AllTrim(aItems[nX, 02]), 1) == 'B'
            nPesoBob += aItems[nX, 10]
        else
            nPesoSep += aItems[nX, 10]
        endif
        if !empty(aJsItems)
            nPos := AScan( aJsItems, {|x| x["barint"] == EncodeUtf8(AllTrim(aItems[nX, 14]))})
        endif
        if nPos > 0
            aJsItems[nPos]["qtdBar"] += aItems[nX, 17]
        else
            oItem           := JsonObject():new()
            oItem["barint"] := EncodeUtf8(AllTrim(aItems[nX, 14]))
            oItem["descr"]  := EncodeUtf8(AllTrim(aItems[nX, 16]) + ' - [' + AllTrim(aItems[nX, 02]) + ']')
            oItem["qtdBar"] := aItems[nX, 17]
            oItem["ender"]  := 0
            oItem["acond"]  := EncodeUtf8(AllTrim(aItems[nX, 02]))
            oItem["itm"]    := EncodeUtf8(AllTrim(aItems[nX, 12]) + AllTrim(aItems[nX, 01] + AllTrim(aItems[nX, 02])))
            aAdd(aJsItems, oItem)
            FreeObj(oItem)
        endif
    next nX

    if !empty(aJsItems)
        oData['cliente']    := aCli
        oData['pesototal']  := nPesoBob + nPesoSep
        oData['pesobob']    := nPesoBob
        oData['pesosep']    := nPesoSep
        oData['data']	    := aJsItems
    endif

    RestArea(aAreaZZR)
    RestArea(aArea)
return(oData:ToJson())

static function updateZZR(nRec, aFldValue)
    local aArea    	:= GetArea()
    local aAreaZZR	:= ZZR->(getArea())
    local lRet 		:= .T.
    local nX		:= 0
    local oModel	:= nil
    local aErro		:= {}
    local cErro		:= ''

    dbselectArea('ZZR')

    oModel := FWLoadModel('cbcZZRModel')
    oModel:SetOperation(4)
    ZZR->(DbGoTo(nRec))
    oModel:Activate()
    for nX := 1 to len(aFldValue)
        oModel:LoadValue('ZZRMASTER',aFldValue[nX, 1], aFldValue[nX, 2])
    next nX
    if !(lRet := FWFormCommit(oModel))
        aErro := oModel:GetErrorMessage()
        if !empty(aErro)
            cErro += aErro[2] + '-'
            cErro += aErro[4] + '-'
            cErro += aErro[5] + '-'
            cErro += aErro[6]
        endif
    endif
    oModel:DeActivate()
    FreeObj(oModel)

    RestArea(aAreaZZR)
    RestArea(aArea)
return({lRet,cErro})

static function canCancelbyPed(cPed)
    local aArea    	:= GetArea()
    local aAreaZZR	:= ZZR->(getArea())
    local aAreaSC9	:= SC9->(getArea())
    local aAreaSDC  := SDC->(getArea())
    local aAreaSC6	:= SC6->(getArea())
    local aAreaZZ9	:= ZZ9->(getArea())
    local aRet      := {.T., 'Ok'}
    local oOrdem    := nil
    local oCarga    := nil

    oOrdem := cbcCtrlOS():newcbcCtrlOS(,.F.)
    oCarga := cbcCtrlCarga():newcbcCtrlCarga(,.F.)

    oOrdem:define(cPed)
    if oOrdem:inUse(.T.)
        aRet := {.F., 'Pedido com Ordem em processo na Expedição!'}
    else
        if oCarga:inCarga(cPed, .T., .T.)
            aRet := {.F., 'Pedido com Carga em processo na Logistica!'}
        endif
    endif

    FreeObj(oOrdem)
    FreeObj(oCarga)
    
    RestArea(aAreaSC6)
    RestArea(aAreaSDC)
    RestArea(aAreaSC9)
    RestArea(aAreaZZ9)
    RestArea(aAreaZZR)
    RestArea(aArea)
return(aRet)

/*TEST ZONE*/
user function tstCtrlOS(cOS, nId) //tstCtrlOS('28190001', 1839)
    local oCtrl := cbcCtrlOS():newcbcCtrlOS()
    local oJson := JsonObject():new()
    oCtrl:define(cOS)
    oJson := getOSData(cOS, oCtrl:isJoined())
    alert('parar')
    //oCtrl:export()
    //oCtrl:cancelWms(nId)
    FreeObj(oCtrl) 
    FreeObj(oJson)
return(nil)
