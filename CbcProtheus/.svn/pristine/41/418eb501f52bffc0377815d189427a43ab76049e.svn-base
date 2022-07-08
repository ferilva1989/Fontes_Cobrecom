#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

class cbcRotas
    data lOk
    data cMsgErr
    data lShowErr

    method newcbcRotas()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getRecnos()
    method add()
    method update()
    method remove()
    method download()
    method upload()
endClass

method newcbcRotas(lShowErr) class cbcRotas
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcRotas
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[cbcRotas] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcRotas')
            endif
        endif
    endif
return(self)

method isOk() class cbcRotas
return(::lOk)

method getErrMsg() class cbcRotas
return(::cMsgErr)

method showErr() class cbcRotas
return(::lShowErr)

method getRecnos(cJson, lPosi) class cbcRotas
    local aArea    	    := GetArea()
    local aAreaZZ7 	    := ZZ7->(GetArea())
    local oSql          := nil
    local aRec          := {}
    default lPosi       := .F.

    if(::setStatus(!empty(cJson), 'Conteúdo não informado!'):isOk())
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(getReg(whereJson(cJson)))
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                aAdd(aRec, oSql:getValue("REC"))
                oSql:skip()
            endDo
        endif
        oSql:Close()
        FreeObj(oSql)
    endif
    RestArea(aAreaZZ7)
    RestArea(aArea)        
return(aRec)

method add(aFldValue) class cbcRotas
    local aArea    	    := GetArea()
    local aAreaZZ7 	    := ZZ7->(GetArea())
    local aRet          := {}
    local nX            := 0
    local bErro         := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    default aFldValue   := {}

    if(::setStatus(!empty(aFldValue), 'Conteúdo não informado!'):isOk())
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                DbSelectArea("ZZ7")
                RecLock("ZZ7",.T.)
                    for nX := 1 to len(aFldValue)
                        ZZ7->&(aFldValue[nX, 1]) := Padr(aFldValue[nX, 2], TamSx3(aFldValue[nX, 1])[1])
                    next nX
                ZZ7->(MsUnLock())
                //aRet := updateZZ7(MODEL_OPERATION_INSERT, aFldValue)
                //::setStatus(aRet[1], aRet[2], .T.)
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif

    RestArea(aAreaZZ7)
    RestArea(aArea)
return(self)

method remove(aRec) class cbcRotas
    local aArea    	:= GetArea()
    local aAreaZZ7 	:= ZZ7->(GetArea())
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    local nX        := 0

    if ::setStatus(!empty(aRec), 'Registros não informados!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                DbSelectArea("ZZ7")
                for nX := 1 to len(aRec)
                    ZZ7->(DbGoTo(aRec[nX]))
                    ZZ7->(RecLock("ZZ7",.F.))
                        ZZ7->(DbDelete())
                    ZZ7->(MsUnLock())                    
                    //aRet := updateZZ7(MODEL_OPERATION_DELETE,,aRec[nX])
                    //::setStatus(aRet[1], aRet[2], .T.)
                next nX
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    RestArea(aAreaZZ7)
    RestArea(aArea)
return(self)

method update(aRec, aFldValue) class cbcRotas
    local aArea    	:= GetArea()
    local aAreaZZ7 	:= ZZ7->(GetArea())
    local nX        := 0
    local nY        := 0
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    
    if ::setStatus((!empty(aRec) .and. !empty(aFldValue)), 'Registros não informados!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                DbSelectArea("ZZ7")
                for nX := 1 to len(aRec)
                    ZZ7->(DbGoTo(aRec[nX]))
                    ZZ7->(RecLock("ZZ7",.F.))
                        for nY := 1 to len(aFldValue)
                            ZZ7->(&aFldValue[nY, 1]) := aFldValue[nY, 2]
                        next nY
                    ZZ7->(MsUnLock())   
                    /*
                    aRet := updateZZ7(MODEL_OPERATION_UPDATE, aFldValue,aRec[nX])
                    ::setStatus(aRet[1], aRet[2], .T.)
                    */
                next nX
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    RestArea(aAreaZZ7)
    RestArea(aArea)
return(self)

method download(cJson, oSay) class cbcRotas
    local oSql      := nil
    local aDados    := {}
    default cJson   := ''
    default oSay    := nil

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(loadMun(whereJson(cJson)))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            aAdd(aDados, { oSql:getValue("TRANSP"),;
                           oSql:getValue("IBGE"),;
                           oSql:getValue("ROTA"),;
                           oSql:getValue("MUN"),;
                           oSql:getValue("EST");
            })
            oSql:skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
    if empty(aDados)
        MsgAlert('Dados não encontrados!','Sem dados')
    else
        FWMsgRun(,{|| makePlan(aDados)}, "Gerando Planilha...","Rotas") 
    endif
return(self)

method upload(oSay) class cbcRotas
    local aParamBox := {}
    local aRetPar   := {}
    local aDados    := {}
    local aCeps     := {}
    local aRecs     := {}
    local nX        := 0
    local nY        := 0
    local nTam      := 0
    local cArq      := ''
    local cOrigem   := ''
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    default oSay    := nil

    aAdd(aParamBox,{6,"Informe Planilha com as ROTAS",Space(70),"","","" ,70,.T.,"Arquivo .XLS |*.XLS"})
    if ParamBox(aParamBox, "Parametros", @aRetPar)
        cArq 		:= Alltrim(Substr(aRetPar[1],rat("\",aRetPar[1])+1,len(aRetPar[1])))
        cOrigem	:= Alltrim(Substr(aRetPar[1],1,rat("\",aRetPar[1])))
        Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
		if ::setStatus(!empty(aDados), 'Falhou importação planilha!'):isOk()
        	BEGIN SEQUENCE
                BEGIN TRANSACTION
                    nTam := len(aDados)
                    ProcRegua(nTam)
                    for nX := 3 to nTam
                        if oSay <> nil
                            oSay:SetText("Processando Rota "+cValToChar(nX-1)+" de "+cValToChar(nTam-2))
                            ProcessMessage()
                        endif
                        aRecs := localize('{ "ZZ7_IBGE":"' + (UfCodIBGE(aDados[nX, 05],.T.) + cValToChar(aDados[nX, 02])) + '"}' )
                        if !empty(aRecs)
                            if oSay <> nil
                                oSay:SetText("Limpando Dados Antigos da Rota...")
                                ProcessMessage()
                            endif
                            ::remove(aRecs)
                        endif
                        aFldVld := {}
                        aAdd(aFldVld, {'ZZ7_ROTA',  AllTrim(aDados[nX, 03])})
                        aAdd(aFldVld, {'ZZ7_TRANSP',AllTrim(aDados[nX, 01])})                
                        aAdd(aFldVld, {'ZZ7_IBGE',  (UfCodIBGE(aDados[nX, 05],.T.) + aDados[nX, 02])})
                        aAdd(aFldVld, {'ZZ7_UF',    AllTrim(aDados[nX, 05])})
                        aAdd(aFldVld, {'ZZ7_CIDADE',AllTrim(aDados[nX, 04])})
                        aAdd(aFldVld, {'ZZ7_CEP',   ''})
                        aCeps := loadCeps(AllTrim(aDados[nX, 05]), AllTrim(aDados[nX, 04]))
                        for nY := 1 to len(aCeps)
                            if oSay <> nil
                                oSay:SetText("Processando CEP "+cValToChar(nY)+" de "+cValToChar(len(aCeps)))
                                ProcessMessage()
                            endif
                            if Upper(NoAcento(AllTrim(aCeps[nY, 01]))) == Upper(AllTrim(aDados[nX, 04]))
                                aFldVld[06, 02] := AllTrim(aCeps[nY, 04])
                                ::add(aFldVld)
                            endif
                        next nY
                    next nX	
                END TRANSACTION
                RECOVER
            END SEQUENCE
        ErrorBlock(bErro)
		endif
    endif
return(self)

/*SERVICES ZONE*/
static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)

static function updateZZ7(nOper, aFldValue, nRec)
    local aArea    	    := GetArea()
    local aAreaZZ7	    := ZZ7->(getArea())
    local lRet 		    := .T.
    local nX		    := 0
    local oModel	    := nil
    local aErro		    := {}
    local cErro		    := ''
    default nRec        := 0
    default aFldValue   := {}
    dbselectArea('ZZ7')

    oModel := FWLoadModel('cbcZZ7Model')
    oModel:SetOperation(nOper)
    if !empty(nRec)
        ZZ7->(DbGoTo(nRec))
    endif
    oModel:Activate()
    for nX := 1 to len(aFldValue)
        oModel:LoadValue('ZZ7MASTER',aFldValue[nX, 1], aFldValue[nX, 2])
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

    RestArea(aAreaZZ7)
    RestArea(aArea)
return({lRet,cErro})

static function whereJson(cJson)
    local oJson := JsonObject():new()
    local nX    := 0
    local aNames:= {}
    local cWhere:= ''

    oJson:fromJSON(cJson)
    aNames := oJson:GetNames()
    for nX := 1 to len(aNames)
        if !empty(cWhere)
            cWhere += ' AND'
        endif
        cWhere += ' ' + aNames[nX] + ' = ' + cValToChar(oJson[aNames[nX]])
    next nX
    FreeObj(oJson)
return(cWhere)

static function makePlan(aData)
	local oFWMsExcel := nil
	local nX		 := 1
	local oExcel	 := nil
	local cNomArqv   := GetTempPath() + 'Plan_ROTAS'+ "_" + StrTran(Time(), ':', '-')+ '.xml'
	local cSheet	 := 'Rotas'
	local cTable	 := 'Rotas'
	default aData    := {}

	oFWMsExcel := FWMSExcel():New()
	oFWMsExcel:AddworkSheet(cSheet)
    oFWMsExcel:AddTable(cSheet,cTable)
    oFWMsExcel:AddColumn(cSheet,cTable,"Transp.",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"IBGE",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Rota",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Cidade",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Estado",1)
        
    for nX := 1 to len(aData)
    	oFWMsExcel:AddRow(cSheet,cTable,{;
    										aData[nX, 01],;
    										aData[nX, 02],;
    										aData[nX, 03],;
    										aData[nX, 04],;
    										aData[nX, 05];
    									})
    next nX
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)
         
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()   
	
	FreeObj(oFWMsExcel)
	FreeObj(oExcel)    
return(nil)

static function loadCeps(cEst, cCity)
    local oCep  := cbcCepElsSrc():newcbcCepElsSrc(nil,.F.)
    local aCeps := {}
    local oQry  := JsonObject():new()
    local oTemp := JsonObject():new()
    local oTemp2:= JsonObject():new()
    local aTemp := {}

    oQry['from'] := 0
    oQry['size'] := 1
    oTemp2:FromJSON('{"CIDADE": {"query":"", "operator":"", "fuzziness":""}}')
    oTemp['match'] := oTemp2
    oTemp['match']['CIDADE']['query'] := Upper(AllTrim(cCity))
    oTemp['match']['CIDADE']['operator'] := "and"
    oTemp['match']['CIDADE']['fuzziness']:= "1"
    aAdd(aTemp, oTemp)
    FreeObj(oTemp)
    FreeObj(oTemp2)
    oTemp:= JsonObject():new()
    oTemp2:= JsonObject():new()
    oTemp2:FromJSON('{"UF":{"query":""}}')
    oTemp['match'] := oTemp2
    oTemp['match']['UF']['query'] := Upper(AllTrim(cEst))
    aAdd(aTemp, oTemp)
    FreeObj(oTemp2)
    oTemp2:= JsonObject():new()
    oTemp2:FromJSON('{"bool": {"must":""}}')
    oQry['query'] := oTemp2
    oQry['query']['bool']['must'] := aTemp
    oCep:customSearch(oQry:toJSON())
    aCeps := oCep:aRefResult
    FreeObj(oCep)
    FreeObj(oQry)
    FreeObj(oTemp)
    FreeObj(oTemp2)
return(aCeps)

static function localize(cWhere)
    local oSql      := nil
    local aDados    := {}
    default cWhere  := ''

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(getRegs(whereJson(cWhere)))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            aAdd(aDados, oSql:getValue("REC"))
            oSql:skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
return(aDados)

/*QUERY ZONE*/
static function getRegs(cWhere)
    local cQry      := ''
    default cWhere  := ''

    cQry += " SELECT ZZ7.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('ZZ7') + " ZZ7 "
    cQry += " WHERE " + cWhere
    if !empty(cWhere) 
        cQry += " AND "
    endif
    cQry += " ZZ7.D_E_L_E_T_ = '' "
return(cQry)

static function loadMun(cWhere)
    local cQry      := ''
    default cWhere  := ''

    cQry += " SELECT CC2.CC2_EST AS [EST],  "
    cQry += " CC2.CC2_CODMUN AS [IBGE],  "
    cQry += " CC2.CC2_MUN AS [MUN], "
    cQry += " ISNULL(REPLICATE('0', (2 - LEN(SUB.ROTA))) + SUB.ROTA, '') AS [ROTA], "
    cQry += " ISNULL(REPLICATE('0', (6 - LEN(SUB.TRANSP))) + SUB.TRANSP, '') AS [TRANSP] "
    cQry += " FROM " + RetSqlName('CC2') + " CC2 "
    cQry += " LEFT JOIN ( "
    cQry += " SELECT ZZ7.ZZ7_IBGE AS [IBGE], ZZ7.ZZ7_CIDADE AS [MUN], ZZ7.ZZ7_UF AS [UF], ZZ7.ZZ7_ROTA AS [ROTA], ZZ7.ZZ7_TRANSP AS [TRANSP] "
    cQry += " FROM " + RetSqlName('ZZ7') + " ZZ7 "
    cQry += " WHERE ZZ7.ZZ7_FILIAL = '" + xFilial('ZZ7') + "' "
    cQry += " AND ZZ7.D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZZ7.ZZ7_IBGE, ZZ7.ZZ7_CIDADE, ZZ7.ZZ7_UF, ZZ7.ZZ7_ROTA, ZZ7.ZZ7_TRANSP "
    cQry += " ) SUB ON CC2.CC2_CODMUN = SUBSTRING(SUB.IBGE,3,LEN(SUB.IBGE)) AND CC2.CC2_EST = SUB.UF "
    cQry += " WHERE CC2.CC2_FILIAL = '" + xFilial('CC2') + "' "
    cQry += " AND  "
    if !empty(cWhere)
        cQry += cWhere
        cQry += " AND "
    endif
    cQry += " CC2.D_E_L_E_T_ = '' "
    cQry += " ORDER BY CC2.CC2_EST, CC2.CC2_MUN, CC2.CC2_CODMUN "
return(cQry)

/*USER FUNCTION*/
user function cbcRotas()
    local aParamBox     := {}
    local aRet          := {}
    local cIbgeDe       := Space(TamSx3('ZZ7_IBGE')[1])
    local cIbgeAte      := Replicate('Z', TamSx3('ZZ7_IBGE')[1])
    local cUfDe         := Space(TamSx3('ZZ7_UF')[1])
    local cUfAte        := Replicate('Z', TamSx3('ZZ7_UF')[1])
    local cCityDe       := Space(TamSx3('ZZ7_CIDADE')[1])
    local cCityAte      := Replicate('Z', TamSx3('ZZ7_CIDADE')[1])
    local cRotaDe       := Space(TamSx3('ZZ7_ROTA')[1])
    local cRotaAte      := Replicate('Z', TamSx3('ZZ7_ROTA')[1])

    aAdd(aParamBox,{1,'IBGE de: '   ,cIbgeDe,   PesqPict('ZZ7','ZZ7_IBGE'),  "","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{1,'IBGE até:'   ,cIbgeAte,  PesqPict('ZZ7','ZZ7_IBGE'),  "","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{1,'UF de:'      ,cUfDe,     PesqPict('ZZ7','ZZ7_UF'),    "","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{1,'UF até:'     ,cUfAte,    PesqPict('ZZ7','ZZ7_UF'),    "","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{1,'Cidade de:'  ,cCityDe,   PesqPict('ZZ7','ZZ7_CIDADE'),"","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{1,'Cidade até:' ,cCityAte,  PesqPict('ZZ7','ZZ7_CIDADE'),"","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{1,'Rota de:'    ,cTesAte,   PesqPict('ZZ7','ZZ7_ROTA'),  "","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{1,'Rota até:'   ,cTesAte,   PesqPict('ZZ7','ZZ7_ROTA'),  "","","MV_PAR09 == 1",50,.F.})
    aAdd(aParamBox,{3,"Operação: ", 1,          {"Importar","Exportar"},               50,"",.F.})
    if ParamBox(aParamBox,"Parâmetros - ROTA",@aRet)
        alert(cValToChar(aRet[09]))
    endif
return(nil)

/* TEST ZONE */
user function zTstRotas(nOpc)
    local oRota := nil
    local oWhere:= nil
    oRota := cbcRotas():newcbcRotas()
    //oWhere:= JsonObject():new()
    //oWhere['CC2_MUN'] := "'BOITUVA'"
    //oWhere['CC2_EST'] := "'SP'"
    if nOpc == 1
        FWMsgRun(, { |oSay| oRota:download(nil,oSay)}, 	"Download Rotas", "Processando...")
    else
        FWMsgRun(, { |oSay| oRota:upload(oSay)}, 	"Upload Rotas", "Processando...")
    endif
    FreeObj(oRota)
    FreeObj(oWhere)
return(nil)


