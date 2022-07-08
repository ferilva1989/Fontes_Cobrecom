#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDef.ch'
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

class cbcCtrlCarga

    data lOk
    data cMsgErr
    data lShowErr
    data cCarga

    method newcbcCtrlCarga()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getCarga()
    method define()
    method insert()
    method add()
    method remove()
    method load()
    method update()
    method changeStatus()
    method setTransp()
    method getTransp()
    method updVol()
    method getStatus()
    method byOS()
    method byPedido()
    method inCarga()
endClass

method newcbcCtrlCarga(cCarga, lShowErr) class cbcCtrlCarga
    default lShowErr := .T.
    default cCarga      := ''
    ::lShowErr  := lShowErr
    ::define(cCarga)
    ::setStatus()
return(self)


method setStatus(lOk, cMsgErr, lEx, lShow) class cbcCtrlCarga
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[cbcCtrlCarga] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcCtrlCarga')
            endif
        endif
    endif
return(self)

method isOk() class cbcCtrlCarga
return(::lOk)

method getErrMsg() class cbcCtrlCarga
return(::cMsgErr)

method showErr() class cbcCtrlCarga
return(::lShowErr)

method getCarga() class cbcCtrlCarga
return(::cCarga)

method define(cCarga) class cbcCtrlCarga
    default cCarga := ''
    ::cCarga       := cCarga
return(self)

method insert(aFldValue) class cbcCtrlCarga
    local aRet  := {}
    local bErro := ErrorBlock({|oErr| HandleEr(oErr, @self)})

    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                aRet := updateZZ9(MODEL_OPERATION_INSERT, aFldValue)
                ::setStatus(aRet[1], aRet[2], .T.)
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
return(self)

method add(aOS, cTransp, aRule) class cbcCtrlCarga
    local aRet      := {}
    local aFldValue := {}
    local nX        := 0
    local aVol      := {}
    local oVol      := cbcCtrlVolum():newcbcCtrlVolum()
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    default aRule   := {}

    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                for nX := 1 to len(aOS)
                    aFldValue := {}
                    aVol := oVol:genVolumes({{aOS[nX, 1], aRule}})
                    aAdd(aFldValue, {'ZZ9_FILIAL', FwFilial()})
                    aAdd(aFldValue, {'ZZ9_ORDCAR', ::getCarga()})
                    aAdd(aFldValue, {'ZZ9_ORDSEP', aOS[nX, 1]})
                    aAdd(aFldValue, {'ZZ9_ROTA',   aOS[nX, 2]})
                    aAdd(aFldValue, {'ZZ9_USER',   RetCodUsr()})
                    aAdd(aFldValue, {'ZZ9_DATA',   DtoC(Date())})
                    aAdd(aFldValue, {'ZZ9_HORA',   time()})
                    aAdd(aFldValue, {'ZZ9_STATUS', CARGA_INICIO})
                    aAdd(aFldValue, {'ZZ9_JSVOLU', aVol[01,02]:ToJson()})
                    aAdd(aFldValue, {'ZZ9_TRANSP', cTransp})
                    aAdd(aFldValue, {'ZZ9_JSINFO', '{}'})
                    aAdd(aFldValue, {'ZZ9_JSCTE', '{}'})
                    aAdd(aFldValue, {'ZZ9_FILORI', FwFilial()})
                    aRet := updateZZ9(MODEL_OPERATION_INSERT, aFldValue)
                    ::setStatus(aRet[1], aRet[2], .T.)
                next nX
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    FreeObj(oVol)
return(self)

method remove(aOS) class cbcCtrlCarga
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    local nX        := 0
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    Local oStatic   := IfcXFun():newIfcXFun()
    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                for nX := 1 to len(aOS)
                    oSql:newAlias(oStatic:sP(4):callStatic('cbcQryCarga', 'getRegs', ::getCarga(), aOS[nX, 1],,aOS[nX, 3]))
                    if oSql:hasRecords()
                        oSql:goTop()
                        aRet := updateZZ9(MODEL_OPERATION_DELETE, ,oSql:getValue("REC"))
                        ::setStatus(aRet[1], aRet[2], .T.)
                    else
                        ::setStatus(.F., 'OS: ' + aOS[nX, 1] + '-Registro de Carga não localizado!', .T.)
                    endif
                    oSql:Close()
                next nX
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    FreeObj(oSql)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(self)

method byOS(cOS, lDefine) class cbcCtrlCarga
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local aAreaZZR 	:= ZZR->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    local cCarga    := ''
    default lDefine := .F.

    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'getRegs','', AllTrim(cOS)))
    if oSql:hasRecords()
        oSql:goTop()
        dbselectArea('ZZ9')
        ZZ9->(DbGoTo(oSql:getValue("REC")))
        cCarga := AllTrim(ZZ9->ZZ9_ORDCAR)
        if lDefine
            ::define(cCarga)
        endif
    else
        ::setStatus(.F., 'Registro de Carga não localizado!')
    endif
    oSql:Close()
    FreeObj(oSql)

    RestArea(aAreaZZR)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(cCarga)

method byPedido(cPed) class cbcCtrlCarga
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local aAreaZZR 	:= ZZR->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    local aRet      := {}
    default lDefine := .F.

    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryCarga', 'getByPedido', cPed))
    if oSql:hasRecords()
        oSql:goTop()
        aAdd(aRet,{oSql:getValue("CARGA"),; 
                    oSql:getValue("OS"),; 
                    oSql:getValue("STATUS"),; 
                    oSql:getValue("REC")})
    else
        ::setStatus(.F., 'Cargas não localizadas!')
    endif
    oSql:Close()
    FreeObj(oSql)

    RestArea(aAreaZZR)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(aRet)

method changeStatus(cSts, cMySts) class cbcCtrlCarga
    local aFldValue := {}
    default cMySts  := ""

    aAdd(aFldValue, {'ZZ9_STATUS', AllTrim(cSts)})
    ::update(aFldValue,,AllTrim(cMySts))
return(self)

method setTransp(cTransp, lGrava, lPergunte) class cbcCtrlCarga
    local aPergs	 := {}
    local aRet		 := {}
    local aFldValue  := {}
    default cTransp  := ''
    default lGrava   := .T.
    default lPergunte:= .F.

    if empty(cTransp)
        cTransp := Space(TamSX3("A4_COD")[1])
    endif

    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        if lPergunte
            aAdd( aPergs ,{1, "Selecionar Transportadora: ", cTransp, PesqPict('SA4', 'A4_COD'), ".T.", "SA4", ".T.", 50, .T.})
            ::setStatus(ParamBox(aPergs ,"Definir Transportadora", @aRet),;
                "Definição de Transportadora Cancelada!")
        endif
        if ::isOk()
            if lPergunte
                cTransp := AllTrim(aRet[1])
            endif
            if lGrava
                aAdd(aFldValue, {'ZZ9_TRANSP', AllTrim(cTransp)})
                ::update(aFldValue)
            endif
        endif
    endif
return(self)

method getTransp() class cbcCtrlCarga
    local aArea		:= getArea()
    local aAreaZZ9	:= ZZ9->(getArea())
    local oSql		:= nil
    local aTransp   := {'','NÃO DEFINIDA',''}

    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(qryTransp(::getCarga()))
        if oSql:hasRecords()
            oSql:goTop()
            if oSql:count() == 1
                aTransp := {AllTrim(oSql:getValue("TRANSP")),;
                    transpName(AllTrim(oSql:getValue("TRANSP"))),;
                    AllTrim(oSql:getValue("VEIC"))}
            endif
        endif
        oSql:close()
        FreeObj(oSql)
    endif
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(aTransp)

method update(aFld, cOS, cSts) class cbcCtrlCarga
    local oSql      := nil
    local aRet      := {}
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    Local oStatic   := IfcXFun():newIfcXFun()
    default cOS     := ''
    default cSts    := ""

    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        if ::setStatus(!empty(aFld), 'Sem alterações Definidas!'):isOk()
            BEGIN SEQUENCE
                oSql := LibSqlObj():newLibSqlObj()
                oSql:newAlias(oStatic:sP(3):callStatic('cbcQryCarga', 'getRegs', ::getCarga(), cOS, cSts))
                if oSql:hasRecords()
                    oSql:goTop()
                    BEGIN TRANSACTION
                        while oSql:notIsEof()
                            aRet := updateZZ9(MODEL_OPERATION_UPDATE, aFld, oSql:getValue("REC"))
                            ::setStatus(aRet[1], aRet[2], .T.)
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
return(self)

method updVol(aVolu) class cbcCtrlCarga
    local aFldValue := {}
    local nX        := 0
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})

    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                for nX := 1 to len(aVolu)
                    aFldValue := {}
                    aAdd(aFldValue, {'ZZ9_JSVOLU', aVolu[nX, 02]:toJson()})
                    if !(::update(aFldValue, aVolu[nX, 01]):isOk())
                        DisarmTransaction()
                        EXIT
                    endif
                next nX
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
return(self)

method getStatus(cOs) class cbcCtrlCarga
    local oSql      := nil
    local cStatus   := ''
    Local oStatic   := IfcXFun():newIfcXFun()
    default cOs     := ''

    if ::setStatus(!empty(::getCarga()), 'CARGA não Definida!'):isOk()
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'qryStatusCarga', ::getCarga(), cOs))
        if oSql:hasRecords()
            oSql:goTop()
            if oSql:count() == 1
                cStatus := AllTrim(oSql:getValue("STATUS"))
            endif
        endif
        oSql:close()
        FreeObj(oSql)
    endif
return(cStatus)

method inCarga(cOS, lActive, lOnlyPed) class cbcCtrlCarga
    local aArea    	:= GetArea()
    local aAreaZZR 	:= ZZR->(GetArea())
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local lInCarga  := .F.
    local xRet      := nil
    local nX        := 0
    local lInAct    := .T.
    default lActive := .F.
    default lOnlyPed:= .F.


    if lOnlyPed
        xRet := ::byPedido(cOS)
        if lActive
            lInAct    := .F.
            for nX := 1 to len(xRet)
                if (AllTrim(xRet[nX, 03]) <> CARGA_FATURADA) .and. (AllTrim(xRet[nX, 03]) <> CARGA_CANCELADA)
                    lInAct := .T.
                    EXIT
                endif
            next nX
        endif
    else
        xRet := ::byOS(cOS, .T.)
        if lActive
            lInAct := (::getStatus(cOS) <> CARGA_FATURADA) .and. (::getStatus(cOS) <> CARGA_CANCELADA)
        endif
    endif
    
    lInCarga := (!empty(xRet)) .and. lInAct
   
    RestArea(aAreaZZ9)
    RestArea(aAreaZZR)
    RestArea(aArea)
return(lInCarga)

/*SERVICES ZONE*/
static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)

static function updateZZ9(nOper, aFldValue, nRec)
    local aArea    	:= GetArea()
    local aAreaZZ9	:= ZZ9->(getArea())
    local lRet 		:= .T.
    local nX		:= 0
    local oModel	:= nil
    local aErro		:= {}
    local cErro		:= ''
    default nRec    := 0
    default aFldValue := {}
    dbselectArea('ZZ9')

    oModel := FWLoadModel('cbcZZ9Model')
    oModel:SetOperation(nOper)
    if !empty(nRec)
        ZZ9->(DbGoTo(nRec))
    endif
    oModel:Activate()
    for nX := 1 to len(aFldValue)
        oModel:LoadValue('ZZ9MASTER',aFldValue[nX, 1], aFldValue[nX, 2])
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

    RestArea(aAreaZZ9)
    RestArea(aArea)
return({lRet,cErro})

static function transpName(cTransp)
    local oSql 		:= nil
    local aArea		:= getArea()
    local aAreaZZ9	:= ZZ9->(getArea())

    default cTransp := ''

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryNameTransp(cTransp))
    if oSql:hasRecords()
        oSql:goTop()
        cTransp += " - " + oSql:getValue('NOME')
    else
        cTransp := 'NÃO ENCONTRADA'
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(cTransp)

/*QUERY ZONE*/
static function qryTransp(cCarga)
    local cQry := ''
    cQry += " SELECT ZZ9.ZZ9_TRANSP AS [TRANSP],                             "
    cQry += " ZZ9.ZZ9_PLCVEI AS [VEIC]                                       "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9                             "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "'          	     "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '"+ cCarga +"'                            "
    cQry += " AND ZZ9.D_E_L_E_T_ = ''                                        "
    cQry += " GROUP BY ZZ9.ZZ9_TRANSP, ZZ9.ZZ9_PLCVEI                        "
return(cQry)

static function qryNameTransp(cTransp)
    local cQry := ''
    cQry += " SELECT SA4.A4_NOME AS [NOME]  		        "
    cQry += " FROM " + RetSqlName('SA4') + " SA4            "
    cQry += " WHERE SA4.A4_FILIAL = '" + xFilial('SA4') + "'"
    cQry += " AND SA4.A4_COD = '" + cTransp + "'            "
    cQry += " AND SA4.D_E_L_E_T_ = ''	      		        "
return(cQry)


/*
    if cOp == 'INSERT'
        cOp := MODEL_OPERATION_INSERT
    elseif cOp == 'VIEW'
        cOp := MODEL_OPERATION_VIEW
    elseif cOp == 'UPDATE'
        cOp := MODEL_OPERATION_UPDATE
    elseif cOp == 'DELETE'
        cOp := MODEL_OPERATION_DELETE
*/
