#include 'Totvs.ch'

class ctrlMovCheck
    data lOk
    data cMsgErr
    data lShowErr
    data aOper
    data cProcFun
    data aTmpTables

    method newctrlMovCheck()
    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method addTmpTables()
    method delTmpTables()
    method createTables()
    method destroyTables()
    method hasRecords()
endClass

method newctrlMovCheck(lShowErr) class ctrlMovCheck
    default lShowErr := .T.
    ::lShowErr      := lShowErr
    ::cProcFun      := ProcName(1)
    ::aOper         := {"PR0","RE0","PR0IND","RE0IND","DEV","POSPR0","ANTOP","POSOP","MOD", "REC","PAR"}
    ::aTmpTables    := {}
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class ctrlMovCheck
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[ctrlMovCheck] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - ctrlMovCheck')
            endif
        endif
    endif
return(self)

method isOk() class ctrlMovCheck
return(::lOk)

method getErrMsg() class ctrlMovCheck
return(::cMsgErr)

method showErr() class ctrlMovCheck
return(::lShowErr)

method addTmpTables(cTable) class ctrlMovCheck
    aAdd(::aTmpTables,cTable)
return(self)

method delTmpTables(cTable) class ctrlMovCheck
    local nPosi := AScan( ::aTmpTables, cTable)
    if nPosi > 0
        aDel(::aTmpTables, nPosi)
        aSize(::aTmpTables,(len(::aTmpTables)-1))
    endif
return(self)

method createTables(cDtIni, cDtFim) class ctrlMovCheck
    local nX      := 0
    local cTbl    := ""
    Local oStatic := IfcXFun():newIfcXFun()

    for nX := 1 to len(::aOper)
        cTbl  :=  oStatic:sP(4):callStatic('srvMovCheck', 'mountTable', ::aOper[nX], cDtIni, cDtFim, ::cProcFun)
        ::addTmpTables(cTbl)
    next nX
return(self)

method destroyTables() class ctrlMovCheck
    while !empty(::aTmpTables)
        &(::aTmpTables[01]):Delete()
        FreeObj(&(::aTmpTables[01]))
        ::delTmpTables(::aTmpTables[01])
    endDo
return(self)

method hasRecords(cOpc) class ctrlMovCheck
    local oSql      := LibSqlObj():newLibSqlObj()
    local nRecs     := 0
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(1):callStatic('qryMovCheck', 'qryHasRec', &("oTmp" + cOpc):GetRealName()))
    if oSql:hasRecords()
        nRecs := oSql:Count()
    endif
    oSql:close()
    FreeObj(oSql)
return(nRecs)

static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)
