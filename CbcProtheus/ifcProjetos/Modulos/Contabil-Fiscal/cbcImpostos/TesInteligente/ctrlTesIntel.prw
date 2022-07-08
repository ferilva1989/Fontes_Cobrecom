#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Totvs.ch"
#include 'FWMVCDef.ch'

class ctrlTesIntel

    data lOk
    data cMsgErr
    data lShowErr

    method newctrlTesIntel()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method add()
    method nextOrdem()
    method findTes()
    method chgOrder()
    method simulate()
    method delete()
    method reOrder()
    method update()
    
endclass

method newctrlTesIntel(lShowErr) class ctrlTesIntel
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class ctrlTesIntel
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[ctrlTesIntel] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - ctrlTesIntel')
            endif
        endif
    endif
return(self)

method isOk() class ctrlTesIntel
return(::lOk)

method getErrMsg() class ctrlTesIntel
return(::cMsgErr)

method showErr() class ctrlTesIntel
return(::lShowErr)

method add(cTipo, oDados) class ctrlTesIntel
    local aArea		    := GetArea()
    local aAreaSFM	    := SFM->(GetArea())
    local aAreaSX5	    := SX5->(getArea())
    local bErro         := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    default oDados      := JsonObject():new()
    
    if ::setStatus(!empty(oDados:GetNames()), 'Dados Inválidos!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                if cTipo == 'TES'
                    addTes(@Self, oDados)
                elseif cTipo == 'OPER'
                    addOperacao()
                else
                    ::setStatus(.F., 'Tipo Inválido!', .T.)
                endif
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    RestArea(aAreaSFM)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(self)

method nextOrdem(cTpOper) class ctrlTesIntel
    local aArea		    := GetArea()
    local aAreaSFM	    := SFM->(GetArea())
    local aAreaSX5	    := SX5->(getArea())
    local cOrdem        := '01'
    local cLast         := ''
    
    cLast := lastOrder(cTpOper)
    if !empty(cLast)
        cOrdem := Soma1(cLast)
    endif   
    RestArea(aAreaSFM)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(cOrdem)

method findTes(nEntSai, cFilter, cTpOper, cClieFor, cLoja, cTipoCF, cProduto) class ctrlTesIntel
    local aArea		    := GetArea()
    local aAreaSA1	    := SA1->(GetArea())
    local aAreaSA2	    := SA2->(GetArea())
    local aAreaSB1	    := SB1->(GetArea())
    local aAreaSC5	    := SC5->(GetArea())
    local aAreaSC6	    := SC6->(GetArea())
    local aAreaSX3	    := SX3->(GetArea())
    local aAreaSX5	    := SX5->(getArea())
    local cAlsCliFor    := ''
    default nEntSai     := 2 //Saída
    default cTipoCF     := 'C'
    default ClieFor     := ''
    default cLoja       := ''
    default cFilter     := '3'

    cAlsCliFor := iif(cTipoCF == "C","SA1","SA2")

    if !empty(cClieFor) .and. !empty(cLoja)
        dbSelectArea(cAlsCliFor)
        (cAlsCliFor)->(dbSetOrder(1))    
        (cAlsCliFor)->(DbSeek(xFilial(cAlsCliFor)+cClieFor+cLoja, .F.))
    endif

    if !empty(cProduto)
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))    
        SB1->(DbSeek(xFilial("SB1") + cProduto, .F.))
    endif

    cTes := seekTes(nEntSai, cFilter, cTpOper)
    
    RestArea(aAreaSA1)
    RestArea(aAreaSA2)
    RestArea(aAreaSB1)
    RestArea(aAreaSC5)
    RestArea(aAreaSC6)
    RestArea(aAreaSX3)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(cTes)

method chgOrder(cTpOper, cFrom, cTo) class ctrlTesIntel
    local aArea		    := GetArea()
    local aAreaSFM	    := SFM->(GetArea())
    local aAreaSX5	    := SX5->(getArea())
    local aTarg         := {}
    local nX            := 0
    local oSql 	        := LibSqlObj():newLibSqlObj()
    local bErro         := ErrorBlock({|oErr| HandleEr(oErr, @self)})

    oSql:newAlias(qryRecno(cTpOper, cFrom))
    if oSql:hasRecords()
        oSql:goTop()
        aAdd(aTarg, {oSql:getValue("REC"), {{'FM_ZORDEM', cTo}}})
    endif
    oSql:close()

    oSql:newAlias(qryRecno(cTpOper, cTo))
    if oSql:hasRecords()
        oSql:goTop()
        aAdd(aTarg, {oSql:getValue("REC"), {{'FM_ZORDEM', cFrom}}})
    endif
    oSql:close()
    FreeObj(oSql)
    BEGIN SEQUENCE
        BEGIN TRANSACTION
            for nX := 1 to len(aTarg)
                aRet := updateSFM(MODEL_OPERATION_UPDATE, aTarg[nX, 2], aTarg[nX, 1])
                ::SetStatus(aRet[1],aRet[2], .T.)
            next nX
        END TRANSACTION
        RECOVER
    END SEQUENCE
    ErrorBlock(bErro)

    RestArea(aAreaSFM)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(self)

method simulate(nEntSai, cTpOper, cClieFor, cLoja, cTipoCF, cProduto, cJson) class ctrlTesIntel
    local aArea		    := GetArea()
    local aAreaSA1	    := SA1->(GetArea())
    local aAreaSA2	    := SA2->(GetArea())
    local aAreaSB1	    := SB1->(GetArea())
    local aAreaSC5	    := SC5->(GetArea())
    local aAreaSC6	    := SC6->(GetArea())
    local aAreaSX3	    := SX3->(GetArea())
    local aAreaSFM	    := SFM->(GetArea())
    local aAreaSX5	    := SX5->(getArea())
    local oChange       := nil
    default nEntSai     := 2 //Saída
    default cTipoCF     := 'C'
    default ClieFor     := ''
    default cLoja       := ''

    oChange := cbcChgAlias():newcbcChgAlias()
    if(::setStatus(oChange:work(cJson):isOk(), oChange:getErrMsg()):isOk())
        cTes := ::findTes(nEntSai, ,cTpOper, cClieFor, cLoja, cTipoCF, cProduto)
        oChange:destroy()
    endif
    FreeObj(oChange)

    RestArea(aAreaSA1)
    RestArea(aAreaSA2)
    RestArea(aAreaSB1)
    RestArea(aAreaSC5)
    RestArea(aAreaSC6)
    RestArea(aAreaSX3)
    RestArea(aAreaSFM)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(cTes)

method delete(cTpOper, nRec) class ctrlTesIntel
    local aArea		    := GetArea()
    local aAreaSFM	    := SFM->(GetArea())
    local aAreaSX5	    := SX5->(getArea())
    local aRet          := {}
    local bErro         := ErrorBlock({|oErr| HandleEr(oErr, @self)})

    BEGIN SEQUENCE
        BEGIN TRANSACTION
            aRet := updateSFM(MODEL_OPERATION_DELETE,, nRec)
            if(::SetStatus(aRet[1],aRet[2], .T.):isOk())
                ::reOrder(cTpOper)
            endif
        END TRANSACTION
        RECOVER
    END SEQUENCE
    ErrorBlock(bErro)
    RestArea(aAreaSFM)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(self)

method reOrder(cTpOper) class ctrlTesIntel
    local aArea		    := GetArea()
    local aAreaSFM	    := SFM->(GetArea())
    local aAreaSX5	    := SX5->(getArea())
    local cOrdem    := '00'
    local oSql 	    := LibSqlObj():newLibSqlObj()
    local aRet      := {}
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})

    oSql:newAlias(qryRecno(cTpOper))
    If oSql:hasRecords()
		oSql:goTop()
		BEGIN SEQUENCE
            BEGIN TRANSACTION
            while oSql:notIsEof()
                cOrdem := Soma1(cOrdem)
                aRet := updateSFM(MODEL_OPERATION_UPDATE, {{'FM_ZORDEM', cOrdem}}, oSql:getValue("REC"))
                ::SetStatus(aRet[1],aRet[2], .T.)
                oSql:skip()
            endDo
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaSFM)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(self)

method update(nRec, oDados) class ctrlTesIntel
    local nX        := 0
    local aNames    := oDados:GetNames()
    local aFldVld   := {}
    local aRet      := {}

    for nX := 1 to len(aNames)
        aAdd(aFldVld, {aNames[nX], oDados[aNames[nX]]})
    next nX
    if (::SetStatus(!empty(aFldVld),'Dados não encontrados!'):isOk())
        aRet := updateSFM(MODEL_OPERATION_UPDATE, aFldVld, nRec)
        ::SetStatus(aRet[1],aRet[2])
    endif
return(self)

/*services*/
static function addTes(oSelf, oDados)
    local nX        := 0
    local aNames    := oDados:GetNames()
    local aFldVld   := {}
    local aRet      := {}

    for nX := 1 to len(aNames)
        aAdd(aFldVld, {aNames[nX], oDados[aNames[nX]]})
    next nX
    if (oSelf:SetStatus(!empty(aFldVld),'Dados não encontrados!'):isOk())
        aRet := updateSFM(MODEL_OPERATION_INSERT, aFldVld)
        oSelf:SetStatus(aRet[1],aRet[2])
    endif
return(oSelf)

static function lastOrder(cTpOper)
    local oSql 	:= LibSqlObj():newLibSqlObj()
    local cOrdem:= ''

	oSql:newAlias(qryLastOrdem(cTpOper))
    If oSql:hasRecords()
		oSql:goTop()
        cOrdem := oSql:getValue("ORDEM")
    endif
    oSql:close()
    FreeObj(oSql)    
return(cOrdem)

static function updateSFM(nOper, aFldValue, nRec)
    local aArea    	:= GetArea()
    local aAreaSFM	:= SFM->(getArea())
    local lRet 		:= .T.
    local nX		:= 0
    local oModel	:= nil
    local aErro		:= {}
    local cErro		:= ''
    default nRec    := 0
    default aFldValue := {}
    
    dbselectArea('SFM')

    oModel := FWLoadModel('cbcSFMModel')
    oModel:SetOperation(nOper)
    if !empty(nRec)
        SFM->(DbGoTo(nRec))
    endif
    oModel:Activate()
    for nX := 1 to len(aFldValue)
        oModel:LoadValue('SFMMASTER',aFldValue[nX, 1], aFldValue[nX, 2])
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

    RestArea(aAreaSFM)
    RestArea(aArea)
return({lRet,cErro})

static function seekTes(nEntSai, cFilter, cTpOper)
    local aArea    	:= GetArea()
    local aAreaSFM	:= SFM->(getArea())
    local cTes      := ''
    local cRegra    := ''
    local oSql 	    := LibSqlObj():newLibSqlObj()
    default cFilter := '3'

	oSql:newAlias(qrySeekTes(cTpOper, cFilter))
    If oSql:hasRecords()
        DbSelectArea('SFM')
		oSql:goTop()
		while oSql:notIsEof()
            SFM->(DbGoTo(oSql:getValue("REC")))
            cRegra := AllTrim(SFM->FM_ZREGRA)
            if !empty(cRegra) .and. nEntSai == 1
                cRegra := StrTran(cRegra, 'SD1->', 'M->')
            endif
            if &(cRegra)
                cTes := iif(nEntSai == 1, AllTrim(SFM->FM_TE), AllTrim(SFM->FM_Ts))
                EXIT
            endif
            oSql:skip()
		endDo
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaSFM)
    RestArea(aArea)
return(cTes)

static function qrySeekTes(cTpOper, cFilter)
    local cQry      := ''
    default cFilter := '3'

    cQry+= " SELECT SFM.R_E_C_N_O_ AS [REC] "
    cQry+= " FROM " + retSqlName('SFM') + " SFM "
    cQry+= " WHERE SFM.FM_FILIAL = '" + xFilial('SFM') + "' "
    cQry+= " AND SFM.FM_TIPO = '" + cTpOper + "' "
    cQry+= " AND SFM.FM_ZREGRA <> '' "
    cQry+= " AND (SFM.FM_ZDTTERM >= '" + DtoS(dDataBase) + "'  OR SFM.FM_ZDTTERM = '')"
    cQry+= " AND SFM.FM_ZDTINIC <= '" + DtoS(dDataBase) + "'"
    if cFilter <> '3'
        cQry+= " AND (SFM.FM_ZAPLIC = '" + cFilter + "' OR SFM.FM_ZAPLIC = '' OR SFM.FM_ZAPLIC = '3')"
    endif
    cQry+= " AND SFM.D_E_L_E_T_ = '' "
    cQry+= " ORDER BY SFM.FM_ZORDEM "
return(cQry)

static function qryLastOrdem(cTpOper)
    local cQry := ''

    cQry+= " SELECT "
    cQry+= " MAX(SFM.FM_ZORDEM) AS [ORDEM] "
    cQry+= " FROM " + retSqlName('SFM') + " SFM "
    cQry+= " WHERE SFM.FM_FILIAL = '" + xFilial('SFM') + "' "
    cQry+= " AND SFM.FM_TIPO = '" + cTpOper + "' "
    cQry+= " AND SFM.D_E_L_E_T_ = '' "

return(cQry)

static function qryRecno(cTpOper, cOrdem)
    local cQry          := ''
    default cOrdem      := ''

    cQry+= " SELECT "
    cQry+= " SFM.R_E_C_N_O_ AS [REC] "
    cQry+= " FROM " + retSqlName('SFM') + " SFM "
    cQry+= " WHERE SFM.FM_FILIAL = '" + xFilial('SFM') + "' "
    cQry+= " AND SFM.FM_TIPO = '" + AllTrim(cTpOper) + "' "
    if !empty(cOrdem)
        cQry+= " AND SFM.FM_ZORDEM IN ('" + AllTrim(cOrdem) + "')"
    endif
    cQry+= " AND SFM.D_E_L_E_T_ = '' "
    cQry+= " ORDER BY SFM.FM_ZORDEM "

return(cQry)

static function tira1(cTarg)
    local cTemp := '00'
    local cRet  := ''

    while cTemp <> cTarg
        cRet  := cTemp
        cTemp := Soma1(cTemp)
    endDo
return(cRet)

/*SERVICES ZONE*/
static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)

/*TEST ZONE*/
user function tstTesIntel()
    local cTes := ''
    local oTes := ctrlTesIntel():newctrlTesIntel()
    local oJson:= JsonObject():new()
    local oTemp:= JsonObject():new()
    
    oTemp['A1_COD'] := '008918'
    oTemp['A1_LOJA'] := '01'
    oTemp['A1_NOME'] := 'I.G. TRANSMISSAO E DISTRIBUICAO DE ENERGIA S/A'
    oTemp['A1_PESSOA'] := 'J'
    oTemp['A1_TIPO'] := 'F'
    oTemp['A1_EST'] := 'PR'
    oTemp['A1_CGC'] := '04636029000115'
    oTemp['A1_INSCR'] := '9024293286'
    oTemp['A1_VEND'] := '159279'
    oTemp['A1_GRPTRIB'] := '001'
    oTemp['A1_TIPCLI'] := '1'
    oTemp['A1_CONTRIB'] := '1'
    oTemp['A1_SIMPNAC'] := '2'
    oTemp['A1_CODSIAF'] := '7691'
    oTemp['A1_CALCSUF'] := ''
    oTemp['A1_TES'] := '921'
    oTemp['A1_XREIDI'] := 'S'
    oJson['SA1'] := oTemp:ToJson()
    
    cTes := oTes:simulate(2, '01', , , 'C', '1190504401', oJson:ToJson())
    MsgInfo('TES: ' + cTes,'Retorno')

    FreeObj(oTemp)
    FreeObj(oJson)
return(nil)


