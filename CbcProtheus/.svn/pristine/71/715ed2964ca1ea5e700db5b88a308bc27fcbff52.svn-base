#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcWmsDuplic()
    local aRet      := {}
    local aPerg     := {}

    //aadd(aPerg,{1,"Tipo Mov.: ", Space(3), "",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Endereco:  ", Space(10),"",".T.","",".T.",50,.F.})

    if (ParamBox(aPerg,"Parâmetros",@aRet))
        FWMsgRun(, { || process('SEP', AllTrim(aRet[01]))}, 	"Consultando cbcWMS", "Filtrando movimentos duplicados...")
    endif
return(nil)

static function process(cTipo, cCodUnico)
    local oInt          := cbcExpIntegra():newcbcExpIntegra(.F.)
    local oEnder        := JsonObject():new()
    local oRegra        := nil
    local oRest         := nil
    local cUrlApi       := AllTrim(GetNewPar("ZZ_NODEWMS", "http://192.168.1.220:4877"))
    local aLista        := {}
    local aWhere        := {}
    local nX            := 0
    local nY            := 0
    local aHeader       := {'Content-Type: application/json'}
    default cTipo       := 'SEP'
    default cCodUnico   := ''
    
    if !empty(cTipo)
        aAdd(aWhere,{"mov_tipo", cTipo})
    endif
    if !empty(cCodUnico)
        aAdd(aWhere,{"codUnico", cCodUnico})
    endif
    
    oRest := FWRest():New(cUrlApi)
    
    oEnder := oInt:getEnder(aWhere)
    for nX := 1 to len(oEnder)
        oRest:SetPath('/sp/' + oEnder[nX]['codUnico'])
        if (oRest:Get(aHeader))
            oRegra := JsonObject():new()
            oRegra:FromJson(oRest:GetResult())
            for nY := 1 to len(oRegra)
                doMovs(oEnder[nX]['id'], oRegra[nY]['moviInfo'], oRegra[nY]['dife'], @oInt, @aLista)
            next nY
            FreeObj(oRegra)
        endif
    next nX
    if !empty(aLista)
        u_zArrToTxt(aLista, .T., GetTempPath()+'Separa_Negativa_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + '.txt')
    endif
    
    FreeObj(oRest)
    FreeObj(oEnder)
    FreeObj(oInt)    
return(nil)

static function doMovs(nEndOri, aEndMov, nDifer, oInt, aLista)
    local oMovs   := nil
    local aMovs   := {}
    local nX      := 0
    local nSldMov := 0
    Local oStatic := IfcXFun():newIfcXFun()

    nDifer := ABS(nDifer)

    while nDifer > 0
        nX++
        if nX > len(aEndMov)
            aMovs := {}
        else
            if aEndMov[nX]['quantidade'] >= nDifer
                nSldMov := nDifer
            else
                nSldMov := aEndMov[nX]['quantidade']
            endif
            aAdd(aMovs, {aEndMov[nX]['produtoId'], aEndMov[nX]['endMovId'], nSldMov})       
            nDifer -= nSldMov
        endif
    endDo
    if !empty(aMovs)
        oMovs := JsonObject():new()
        oStatic:sP(3):callStatic('cbcExpIntegra', 'mntMovimento', aMovs, @oMovs, nEndOri)
        oInt:doMovimento(oMovs)
        for nX := 1 to len(aMovs)
            aAdd(aLista, {aMovs[nX,01], aMovs[nX,02], nEndOri,aMovs[nX,03], iif(oInt:isOk(), 'OK', oInt:getErrMsg())})
        next nX
        FreeObj(oMovs)
    endif    
return(nil)
