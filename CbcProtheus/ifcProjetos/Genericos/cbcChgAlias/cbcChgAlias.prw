#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Totvs.ch"
#include 'FWMVCDef.ch'

class cbcChgAlias

    data lOk
    data cMsgErr
    data lShowErr
    data aTempObj
    data aSavedArea
    data cProcFun

    method newcbcChgAlias()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method work()
    method save()
    method create()
    method change()
    method destroy()
    method rest()

endclass

method newcbcChgAlias(lShowErr) class cbcChgAlias
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::aTempObj  := {}
    ::aSavedArea:= {}
    ::cProcFun  := ProcName(1)
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcChgAlias
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk
    
    if !(lOk)
        ::cMsgErr   := '[cbcChgAlias] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcChgAlias')
            endif
        endif
    endif
return(self)

method isOk() class cbcChgAlias
return(::lOk)

method getErrMsg() class cbcChgAlias
return(::cMsgErr)

method showErr() class cbcChgAlias
return(::lShowErr)

method work(cJson) class cbcChgAlias
    local oDados        := JsonObject():new()
    local aTables       := {}
    local nX            := 0
    local bErro         := ErrorBlock({|oErr| HandleEr(oErr, @self)})

    oDados:FromJson(cJson)
    aTables := oDados:GetNames()
    
    BEGIN SEQUENCE
        for nX := 1 to len(aTables)
            ::save(aTables[nX])
            ::create(aTables[nX], oDados[aTables[nX]])
            ::change(&(::aTempObj[len(::aTempObj)]):GetAlias(), aTables[nX])
        next nX
        RECOVER
    END SEQUENCE
    ErrorBlock(bErro)
    if!(::isOk())
        ::destroy()
    endif
    FreeObj(oDados)
return(self)

method save(cAls) class cbcChgAlias
    aAdd(::aSavedArea, {cAls, &(cAls)->(GetArea())})
return(self)

method create(cAls, cJson) class cbcChgAlias
    local cObjTbl := mountTable(cAls, cJson, ::cProcFun)
    if (::setStatus(!empty(cObjTbl), 'Erro na Criação da Tabela Temporária!', .T.):isOk())
        aAdd(::aTempObj, cObjTbl)
    endif
return(cObjTbl)

method change(cSource, cDest) class cbcChgAlias
    //if Type(cDest) <> 'U'
        //Fechar o Alias de Destino
        dbSelectArea(cDest)
        &(cDest)->(DBCloseArea())
    //endif
    //Abrir Alias Origem
    dbSelectArea(cSource)
    ChkFile(cSource)

    //Alterar Alias
    if (::setStatus(dbChangeAlias(cSource, cDest), 'Erro na troca de Alias', .T.):isOk())
        //Ativar Alias Destino
        (cDest)->(DBSetOrder(1))
        (cDest)->(dbGoTop())
    endif
return(self)

method destroy() class cbcChgAlias
    local nX := 0

    ::rest()
    for nX := 1 to len(::aTempObj)
        &(::aTempObj[nX]):Delete()
        FreeObj(&(::aTempObj[nX]))
    next nX
    ::aTempObj := {}
return(self)

method rest(cAls) class cbcChgAlias
    local nX    := 0
    default cAls:= ''

    for nX := 1 to len(::aSavedArea)
        if (::aSavedArea[nX, 01] == cAls) .or. empty(cAls)
            &(::aSavedArea[nX, 01])->(DBCloseArea())
            RestArea(::aSavedArea[nX, 02])
        endif
    next nX
return(self)

/*SERVICES ZONE*/
static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)

static function mountTable(cAls, cDados, cProcFun)
    local oDados:= JsonObject():new()
    local aFlds := {}
    local aIdx  := {}
    local cMyAls:= ''
    local nX    := 0

    oDados:FromJson(cDados)
    aFlds := getFields(oDados:GetNames())
    SetPrvt("oTmp" + cAls)
    &("oTmp" + cAls)  := FWTemporaryTable():New(nextAlias())
    &("oTmp" + cAls):SetFields(aFlds)
    if ValType(oDados:GetJsonObject('INDEX')) <> 'U'
        aIdx := oDados['INDEX']
    else
        aIdx := {aFlds[1,1]}
    endif
    &("oTmp" + cAls):AddIndex('Idx',  aIdx)
    &("oTmp" + cAls):Create()
    cMyAls := &("oTmp" + cAls):GetAlias()
    (cMyAls)->(RecLock((cMyAls), .T.))
    for nX := 1 to Len(aFlds)
        (cMyAls)->(&(aFlds[nX, 01])) := oDados[aFlds[nX, 01]]
    next nX
    (cMyAls)->(MsUnLock())
    _SetNamedPrvt( "oTmp" + cAls, &("oTmp" + cAls) , cProcFun/*"simulate"*/ )
    FreeObj(oDados)
return("oTmp" + cAls)

static function getFields(aTarg)
    local aFlds := {}
    local nX    := 0

    for nX := 1 to len(aTarg)
        if aTarg[nX] <> 'INDEX'
            aAdd(aFlds, {aTarg[nX], GetSx3Cache(aTarg[nX],'X3_TIPO'),TamSx3(aTarg[nX])[1],   GetSx3Cache(aTarg[nX],  'X3_DECIMAL')})
        endif
    next nX
return(aFlds)

static function nextAlias()
    local cAls := ''
    while .T.
        cAls := GetNextAlias()
        if (Select(cAls) <= 0)
            exit
        endIf
    endDo
return(cAls)
