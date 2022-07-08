#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Totvs.ch'
#include 'cbcOrdemCar.ch'

user function cbcDefTrp(cCarga)//cbcDefTrp('00000036')
    private aTransp := {}
    private aCalc   := {}
    private aTab    := {}
    private aOS     := {}
    private nQtdOS  := 0

    FWMsgRun(, {||loadData(cCarga)},"Calculo de Tabela de Frete", "Calculando...")
    FWMsgRun(, {||viewDefTrp(cCarga)}, 	"Definição de Frete", "Carregando View...")
return(nil)

static function viewDefTrp(cCarga)
    local lCloseButt 	:= !(oAPP:lMdi)
    local bConfirm      := {|| FWMsgRun(, {||grvFrete(cCarga)},"Gravar Frete nas Cargas", "Gravando...") }
    private aMCoors     := FWGetDialogSize( oMainWnd )
    private oModal 		:= nil
    private oFWLayer    := nil
    private oPnlTrans   := nil
    private oPnlOS      := nil
    private oPnlTab     := nil
    private oPnlCalc    := nil
    private oFont	    := TFont():New("Arial",,15,,.T.)
    private aHeader     := {}
    private aColsGrid   := {}
    private lAutoSplit  := .F.
    private oGridTransp := nil
    private oGridOS     := nil
    private oGridTab    := nil
    private oGridCalc   := nil
    private lSplitOS    := .F.
    private lSplitTab   := .F.
    private lSplitCalc  := .F.
    private bRecalc     := {|| FWMsgRun(, {||recalc(cCarga)},"Recalcular Fretes", "Recalculando...")}
        
    oModal      := FWDialogModal():New()
    oModal:setSize((aMCoors[3] * 0.5),(aMCoors[4] * 0.5))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Definição do Frete - Carga: ' + cCarga + ' - Qtd de NF: ' + cValToChar(nQtdOS))
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oModal:addOkButton(bConfirm, "Confirma", {||.T.} )
    oModal:addButtons({{'', 'Recalcular', bRecalc, '',,.T.,.F.}})
    oFWLayer := FWLayer():New()
    oFWLayer:Init(oModal:getPanelMain(), lCloseButt)
    configLayout()
    FWMsgRun(, {|| autoDef()},	"Definição de Tabelas", "Verificando...")
    mntBrw('TRANSP',@oGridTransp,   @oPnlTrans)
    resetSplit()    
    oModal:Activate()
    
    FreeObj(oGridTransp)
    FreeObj(oGridOS)
    FreeObj(oGridTab)
    FreeObj(oGridCalc)
    FreeObj(oPnlTrans)
    FreeObj(oPnlOS)
    FreeObj(oPnlTab)
    FreeObj(oPnlCalc)
    FreeObj(oFont)
    FreeObj(oFWLayer)
    FreeObj(oModal)
return(nil)

static function recalc(cCarga)
    oModal:DeActivate()
    aTransp := {}
    aCalc   := {}
    aTab    := {}
    aOS     := {}
    nQtdOS  := 0

    FWMsgRun(, {||loadData(cCarga, .T.)},"Calculo de Tabela de Frete", "Calculando...")
    FWMsgRun(, {||viewDefTrp(cCarga)}, 	"Definição de Frete", "Carregando View...")
return(nil)

static function configLayout()
    oFWLayer:addLine('UP', 50)
    oFWLayer:addLine('DW', 50)
    oFWLayer:setLinSplit('DW', CONTROL_ALIGN_TOP, {|| validSplit('LINE','DW')}/*BCLOSE*/,	{|| validSplit('LINE','DW')}/*BOPEN*/)//, {|| validSplit(.F.,'UP_RIGHT')}/*BCLOSE*/,	{|| validSplit(.T.,'UP_RIGHT')}/*BOPEN*/)

    oFWLayer:AddCollumn('UP_LEFT', 50, .F., 'UP')    
    oFWLayer:AddCollumn('UP_RIGHT',50, .F., 'UP')
    oFWLayer:setColSplit('UP_RIGHT', CONTROL_ALIGN_LEFT, 'UP', {|| validSplit('COL','UP_RIGHT', 'UP')}/*BCLOSE*/,	{|| validSplit('COL','UP_RIGHT', 'UP')}/*BOPEN*/)

    oFWLayer:AddCollumn('DW_LEFT', 50, .F., 'DW')
    oFWLayer:AddCollumn('DW_RIGHT',50, .F., 'DW')
    oFWLayer:setColSplit('DW_RIGHT', CONTROL_ALIGN_LEFT, 'DW', {|| validSplit('COL','DW_RIGHT', 'DW')}/*BCLOSE*/,	{|| validSplit('COL','DW_RIGHT', 'DW')}/*BOPEN*/)

    // Coluna Esquerda (Controles)
    oFWLayer:AddWindow('UP_LEFT', 'WND_TRANS', 'Transportadoras', 100, .T., .F.,,'UP')
    oPnlTrans := oFWLayer:GetWinPanel('UP_LEFT', 'WND_TRANS', 'UP')

    oFWLayer:AddWindow('DW_LEFT', 'WND_OS', 'Ordens de Separação', 100, .T., .F., ,'DW')
    oPnlOS := oFWLayer:GetWinPanel('DW_LEFT', 'WND_OS', 'DW')
    
    oFWLayer:AddWindow('UP_RIGHT', 'WND_TAB', 'Detalhes Cálculo', 100, .T., .F.,,'UP')
    oPnlCalc := oFWLayer:GetWinPanel('UP_RIGHT', 'WND_TAB','UP')
    
    oFWLayer:AddWindow('DW_RIGHT', 'WND_CALC', 'Tabelas | [F4]-Detalhes do Cálculo', 100, .T., .F.,,'DW')
    oPnlTab := oFWLayer:GetWinPanel('DW_RIGHT', 'WND_CALC','DW')
return(nil)

static function loadData(cCarga, lRecalc)
    local oFrete    := cbcAuditFrete():newcbcAuditFrete()
    local oSql      := LibSqlObj():newLibSqlObj()
    local aRet      := {}
    local nTrans    := 0
    local nOS       := 0
    local nTab      := 0
    local nCalc     := 0
    local nX        := 0
    local nY        := 0
    local nPeso     := 0
    local nValorT   := 0
    local cIbge     := ""
    local oJson     := nil
    default lRecalc := .F.

    DbSelectArea('ZZ9')
    oSql:newAlias(qryCarga(cCarga))
    if oSql:hasRecords()
        nQtdOS := oSql:Count()
        oSql:goTop()
        while oSql:notIsEof()
            nPeso := 0
            if(len(AllTrim(oSql:getValue("IBGE"))) == 7)
                cIbge := AllTrim(oSql:getValue("IBGE"))
            else
                cIbge := UfCodIBGE(AllTrim(oSql:getValue("UF")),.T.) + AllTrim(oSql:getValue("IBGE"))
            endif
            ZZ9->(DbGoTo(oSql:getValue("REC")))
            nPeso   := getPeso(AllTrim(ZZ9->ZZ9_ORDCAR), AllTrim(ZZ9->ZZ9_ORDSEP))
            nValorT := calcValor(AllTrim(ZZ9->ZZ9_ORDCAR), AllTrim(ZZ9->ZZ9_ORDSEP), oSql:getValue("VALOR"))
            oJson := JsonObject():new()
            if !lRecalc
                if !empty(ZZ9->ZZ9_JSCTE)
                    oJson:FromJson(ZZ9->ZZ9_JSCTE)
                endif
            endif
            if !empty(oJson:GetNames())
                aRet := {oJson}
            else
                aRet := oFrete:bestForDest(AllTrim(oSql:getValue("UF")), cIbge, nPeso, nValorT)
                //aRet := mockup()
            endif            
            for nX := 1 to len(aRet)                
                nTrans := aScan(aTransp,{|x| x[01] == aRet[nX]['CNPJ_TRANSP']})
                if nTrans == 0
                    aAdd(aTransp,{aRet[nX]['CNPJ_TRANSP'], aRet[nX]['TRANSP'], 0, 0.00, 0.00, 0.00})
                    nTrans := len(aTransp)
                endif
                nOS := aScan(aOS,{|x| x[01] == aRet[nX]['CNPJ_TRANSP'] .and. x[02] == AllTrim(oSql:getValue("ORDSEP"))})
                if nOS == 0
                    aAdd(aOS,{aRet[nX]['CNPJ_TRANSP'], AllTrim(oSql:getValue("ORDSEP")), 0, nValorT, nPeso, 0.00, oSql:getValue("UF"), oSql:getValue("MUN"), AllTrim(oSql:getValue("CLI"))})
                    //aTransp[nTrans, 03] += 1
                    aTransp[nTrans, 04] += nValorT
                    aTransp[nTrans, 05] += nPeso
                    nOS := len(aOS)
                endif                
                nTab := aScan(aTab,{|x| x[01] == aRet[nX]['CNPJ_TRANSP'] .and. x[02] == AllTrim(oSql:getValue("ORDSEP")) .and. x[03] == aRet[nX]['ROTA'] })
                if nTab == 0
                    aAdd(aTab, {aRet[nX]['CNPJ_TRANSP'], AllTrim(oSql:getValue("ORDSEP")), aRet[nX]['ROTA'], aRet[nX]['TOTAL'], '', aRet[nX]})
                    aOS[nOS, 03] += 1
                    nTab := len(aTab)
                endif
                for nY := 1 to len(aRet[nX]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'])
                    nCalc := aScan(aCalc,{|x| x[01] == aRet[nX]['CNPJ_TRANSP'] .and. x[02] == AllTrim(oSql:getValue("ORDSEP")) .and. x[03] == aRet[nX]['ROTA'] .and. x[04] == aRet[nX]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'][nY][01]})
                    if nCalc == 0
                        aAdd(aCalc,{aRet[nX]['CNPJ_TRANSP'], AllTrim(oSql:getValue("ORDSEP")), aRet[nX]['ROTA'], aRet[nX]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'][nY][01], aRet[nX]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'][nY][02]})
                    endif
                next nY
                nCalc := aScan(aCalc,{|x| x[01] == aRet[nX]['CNPJ_TRANSP'] .and. x[02] == AllTrim(oSql:getValue("ORDSEP")) .and. x[03] == aRet[nX]['ROTA'] .and. x[04] == 'ICMS'})
                if nCalc == 0
                    aAdd(aCalc,{aRet[nX]['CNPJ_TRANSP'], AllTrim(oSql:getValue("ORDSEP")), aRet[nX]['ROTA'], 'ICMS', iif(aRet[nX]['CALCULAR']['AUDIT_CALC'][1]['ICMS'] <> nil, aRet[nX]['CALCULAR']['AUDIT_CALC'][1]['ICMS'][1]['VLR'], 0)})
                endif
            next nX
            FreeObj(oJson)
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    FreeObj(oFrete)
return(nil)

static function mntBrw(cOpc, oGrid, oPnl)
    oGrid := FWBrowse():New()
    aHeader     := {}
    aColsGrid   := {}
    mntHeader(cOpc)
    oGrid:DisableFilter()
    oGrid:DisableConfig()
    oGrid:DisableReport()
    oGrid:DisableSeek()
    oGrid:DisableSaveConfig()
    oGrid:SetFontBrowse(oFont)
    oGrid:SetDataArray()
    oGrid:lHeaderClick := .F.
    oGrid:SetColumns(aHeader)
    oGrid:SetArray(aColsGrid)
    oGrid:SetOwner(oPnl)
    oGrid:SetTypeMove(0)
    if cOpc == 'TRANSP' .or. cOpc == 'OS'
        oGrid:SetDoubleClick({|| FWMsgRun(, {|| loadDets(cOpc)},'Carregando Filtros','carregando...')})
    elseif cOpc == 'TABS'
        //oGrid:setEditCell( .T. , { || .T.} )
        oGrid:SetDoubleClick({|| FWMsgRun(, {|| defineTab()},'Definição de Tabela','Definindo tabela selecionada...')})
    endif
    if cOpc == 'TRANSP'
        oGrid:AddLegend("oGridTransp:oData:aArray[oGridTransp:At(),03] == nQtdOS",  'BR_VERDE',   'Atende Completa')
        oGrid:AddLegend("oGridTransp:oData:aArray[oGridTransp:At(),03] < nQtdOS .and. oGridTransp:oData:aArray[oGridTransp:At(),03] > 0",  'BR_AMARELO',   'Atende Parcial')
        oGrid:AddLegend("oGridTransp:oData:aArray[oGridTransp:At(),03] == 0",  'BR_VERMELHO',   'Não Atende')
    endif
    oGrid:SetChange({ || loadFilter(cOpc)})
    mntDados(cOpc, @oGrid)
    oGrid:Activate()
return(nil)

static function mntHeader(cOpc)
    local aHeaderAux := {}
    local nAtual     := 0
    local cGrid      := ''

    aHeader := {}

    if cOpc == 'TRANSP'
        cGrid := 'oGridTransp'
        aAdd(aHeaderAux, {"CNPJ",       GetSx3Cache('A2_CGC','X3_TIPO'), TamSx3('A2_CGC')[01], 0, PesqPict('SA2', 'A2_CGC')})
        aAdd(aHeaderAux, {"Transp.",    "C", 70, 0, ""})
        aAdd(aHeaderAux, {"Atendidas",  "N", 09, 0, "@E 999,999,999"})
        aAdd(aHeaderAux, {"Frete",      "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Valor NF",   "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Peso NF ",   "N", 09, 2, "@E 999,999.999"})
    elseif cOpc == 'OS'
        cGrid := 'oGridOS'
        aAdd(aHeaderAux, {"Ordem Sep.", GetSx3Cache('ZZ9_ORDSEP','X3_TIPO'),TamSx3('ZZ9_ORDSEP')[01], 0, PesqPict('ZZ9', 'ZZ9_ORDSEP')})
        aAdd(aHeaderAux, {"Cliente",    GetSx3Cache('A1_NOME','X3_TIPO'),   (TamSx3('A1_COD')[01] + TamSx3('A1_LOJA')[01] + TamSx3('A1_NOME')[01]), 0, PesqPict('SA1', 'A1_NOME')})
        aAdd(aHeaderAux, {"Municipio",  GetSx3Cache('A1_MUN','X3_TIPO'),    TamSx3('A1_MUN')[01], 0, PesqPict('SA1', 'A1_MUN')})
        aAdd(aHeaderAux, {"UF",         GetSx3Cache('A1_EST','X3_TIPO'),    TamSx3('A1_EST')[01], 0, PesqPict('SA1', 'A1_EST')})
        aAdd(aHeaderAux, {"Tabs.Disp",  "N", 09, 0, "@E 999,999,999"})
        aAdd(aHeaderAux, {"Valor NF",   "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Peso NF",    "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Frete",      "N", 09, 2, "@E 999,999.999"})
    elseif cOpc == 'TABS'
        cGrid := 'oGridTab'
        aAdd(aHeaderAux, {"Tab.Desc.",  GetSx3Cache('ZF1_ROTA','X3_TIPO'), TamSx3('ZF1_ROTA')[01], 0, PesqPict('ZF1', 'ZF1_ROTA')})
        aAdd(aHeaderAux, {"Valor",      "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Selec.",     "C", 01, 0, ""})
    elseif cOpc == 'CALC'
        cGrid := 'oGridCalc'
        aAdd(aHeaderAux, {"Comp.",      "C", 70, 0, ""})
        aAdd(aHeaderAux, {"Valor",      "N", 09, 2, "@E 999,999.999"})
    endif

    for nAtual := 1 to Len(aHeaderAux)
        aAdd(aHeader, FWBrwColumn():New())
        aHeader[nAtual]:SetData( &("{||" + cGrid + ":oData:aArray[" + cGrid + ":At(),"+Str(nAtual)+"]}") )
        aHeader[nAtual]:SetTitle( aHeaderAux[nAtual][1] )
        aHeader[nAtual]:SetType(aHeaderAux[nAtual][2] )
        aHeader[nAtual]:SetSize( aHeaderAux[nAtual][3] )
        aHeader[nAtual]:SetDecimal( aHeaderAux[nAtual][4] )
        aHeader[nAtual]:SetPicture( aHeaderAux[nAtual][5] )
        /*
        if cOpc == 'TABS' .and. aHeaderAux[nAtual][1] = "Selec."
            aHeader[nAtual]:ledit := .T.
            aHeader[nAtual]:cReadVar:= cGrid + ":oData:aArray[" + cGrid + ":At(),"+cValToChar(nAtual)+"]"
        endif
        */
    next nAtual
return(aHeader)

static function mntDados(cOpc, oGrid)
    local nX    := 0

    //Zera a grid
    aColsGrid := {}

    if cOpc == 'TRANSP'
        for nX := 1 to len(aTransp)
            aAdd(aColsGrid,{aTransp[nX, 01], aTransp[nX, 02],aTransp[nX, 03],aTransp[nX, 06], aTransp[nX, 04],aTransp[nX, 05]})
        next nX
    elseif cOpc == 'OS'
        for nX := 1 to len(aOS)
            if (aOS[nX, 01] == oGridTransp:oData:aArray[oGridTransp:At(),01])
                aAdd(aColsGrid,{aOS[nX, 02], aOS[nX, 09], aOS[nX, 08], aOS[nX, 07], aOS[nX, 03], aOS[nX, 04], aOS[nX, 05], aOS[nX, 06]})
            endif
        next nX
    elseif cOpc == 'TABS'
        for nX := 1 to len(aTab)
            if (aTab[nX, 01] == oGridTransp:oData:aArray[oGridTransp:At(),01]) .and. (aTab[nX, 02] == oGridOS:oData:aArray[oGridOS:At(),01])
                aAdd(aColsGrid,{aTab[nX, 03], aTab[nX, 04], aTab[nX, 05]})
            endif
        next nX
    elseif cOpc == 'CALC'
        for nX := 1 to len(aCalc)
            if (aCalc[nX, 01] == oGridTransp:oData:aArray[oGridTransp:At(),01]) .and. (aCalc[nX, 02] == oGridOS:oData:aArray[oGridOS:At(),01]) .and. (aCalc[nX, 03] == oGridTab:oData:aArray[oGridTab:At(),01])
                aAdd(aColsGrid,{aCalc[nX, 04], aCalc[nX, 05]})
            endif
        next nX
    endif

    oGrid:SetArray(aColsGrid)
    oGrid:Refresh()
return(nil)

static function loadDets(cOpc)
    if cOpc == 'TRANSP'
        if !lSplitOS
            lAutoSplit  := .T.
            oFWLayer:clickLineSplit('DW')
            lAutoSplit  := .F.
            reset('OS',.T.)
            lSplitOS    := .T.
        else
            reset('OS')
            reset('TABS')
            reset('CALC')
            resetSplit(3,.F.)
            lSplitOS     := .F.
            lSplitTab    := .F.
            lSplitCalc   := .F.
        endif
    elseif cOpc == 'OS'
        if !lSplitTab
            lAutoSplit   := .T.
            oFWLayer:clickColSplit('DW_RIGHT', 'DW')
            lAutoSplit   := .F.
            reset('TABS',.T.)
            lSplitTab    := .T.
            SetKey(VK_F4,  {||loadDets('TABS')})
        else
            reset('TABS')
            reset('CALC')
            resetSplit(2,.F.)
            lSplitTab    := .F.
            lSplitCalc   := .F.
            SetKey(VK_F4,   {||})
        endif
    elseif cOpc == 'TABS'
        if !lSplitCalc
            lAutoSplit   := .T.
            oFWLayer:clickColSplit('UP_RIGHT', 'UP')
            lAutoSplit   := .F.
            reset('CALC',.T.)
            lSplitCalc   := .T.
        else
            reset('CALC')
            resetSplit(1,.F.)
            lSplitCalc    := .F.
        endif
    endif
return(nil)

static function loadFilter(cOpc)
    if cOpc == 'TRANSP'
        if lSplitOS
            reset('OS', .T.)
        endif
        if lSplitTab
            reset('TABS',.T.)
        endif
        if lSplitCalc
            reset('CALC',.T.)
        endif
    elseif cOpc == 'OS'
        if lSplitTab
            reset('TABS',.T.)
        endif
        if lSplitCalc
            reset('CALC',.T.)
        endif
    elseif cOpc == 'TABS'
        if lSplitCalc
            reset('CALC',.T.)
        endif
    endif
return(nil)

static function reset(cOpc, lMnt)
    default lMnt := .F.
    if cOpc == 'OS'
        if oGridOS <> nil
            oGridOS:DeActivate()
            FreeObj(oGridOS)
            oPnlOS:FreeChildren()
        endif
        if lMnt
            mntBrw('OS',    @oGridOS,       @oPnlOS)
        endif
    elseif cOpc == 'TABS'
        if oGridTab <> nil
            oGridTab:DeActivate()
            FreeObj(oGridTab)
            oPnlTab:FreeChildren()
        endif
        if lMnt
            mntBrw('TABS',  @oGridTab,      @oPnlTab)
        endif
    elseif cOpc == 'CALC'
        if oGridCalc <> nil
            oGridCalc:DeActivate()
            FreeObj(oGridCalc)
            oPnlCalc:FreeChildren()
        endif
        if lMnt
            mntBrw('CALC',  @oGridCalc,     @oPnlCalc)
        endif
    elseif cOpc == 'TRANSP'
        if oGridTransp <> nil
            oGridTransp:DeActivate()
            FreeObj(oGridTransp)
            oPnlTrans:FreeChildren()
        endif
        if lMnt
            mntBrw('TRANSP',  @oGridTransp,     @oPnlTrans)
        endif
    endif
return(nil)

static function resetSplit(nOpc, lNoVld)
    default nOpc    := 3
    default lNoVld  := .T.
    lAutoSplit := .T.
    if nOpc >= 1
        if lNoVld .or. lSplitCalc
            oFWLayer:clickColSplit('UP_RIGHT', 'UP')
        endif
    endif
    if nOpc >= 2
        if lNoVld .or. lSplitTab
            oFWLayer:clickColSplit('DW_RIGHT', 'DW')
        endif
    endif
    if nOpc >= 3
        if lNoVld .or. lSplitOS
            oFWLayer:clickLineSplit('DW')
        endif
    endif
    lAutoSplit := .F.
return(nil)

static function validSplit(cTipo, cId, cAuxId)
    default cAuxId := ''
	if !lAutoSplit
        if cTipo == 'COL'
		    oFWLayer:clickColSplit(cId, cAuxId)
        else
            oFWLayer:clickLineSplit(cId)
        endif
	endif
return(nil)

static function autoDef()
    local nX    := 0
    local nY    := 0
    local nPos  := 0
    local nQtd  := 0

    for nX := 1 to len(aOS)
        nQtd := 0
        for nY := 1 to len(aTab)
            if (aTab[nY, 01] == aOS[nX, 01]) .and. (aTab[nY, 02] == aOS[nX, 02])
                nQtd++
                nPos := nY
            endif
        next nY
        if nQtd == 1
            aTab[nPos,05] := 'X'
            aOS[nX,06]    := aTab[nPos,04]
            nPos := aScan(aTransp,{|x| x[01] == aOS[nX,01]})
            if nPos <> 0            
                aTransp[nPos,03] += 1
                aTransp[nPos,06] += aOS[nX,06]
            endif
        endif
    next nX
return(nil)

static function defineTab()
    local nX        := 0
    if MsgYesNo('Define a tabela?','Definir Tabela')
        for nX := 1 to len(aTab)
            if aTab[nX, 01] ==  oGridTransp:oData:aArray[oGridTransp:At(),01] .and. aTab[nX, 02] == oGridOS:oData:aArray[oGridOS:At(),01]
                if oGridTab:oData:aArray[oGridTab:At(),01] == aTab[nX, 03]
                    aTab[nX,05] := "X"
                else
                    aTab[nX,05] := ""
                endif
            endif
        next nX
        recalcTotal()
    endif
return(nil)

static function recalcTotal()
    local nX        := 0
    local nY        := 0
    local nZ        := 0
    local nPos      := 0
    local nAtend    := 0
    local nValTot   := 0
    
    for nZ := 1 to len(aTransp)
        nAtend := 0
        nValTot:= 0
        for nY := 1 to len(aOS)
            if aOS[nY, 01] == aTransp[nZ, 01]
                aOS[nY,06]:= 0
                for nX := 1 to len(aTab)
                    if aOS[nY, 01] == aTab[nX, 01] .and. aOS[nY, 02] == aTab[nX, 02] .and. aTab[nX,05] == "X"
                        aOS[nY,06] += aTab[nX,04]
                    endif
                next nX
                if aOS[nY,06] > 0
                    nAtend++
                    nValTot += aOS[nY,06]
                endif
            endif
        next nY
        aTransp[nZ,03] := nAtend
        aTransp[nZ,06] := nValTot
    next nZ
    if oGridTransp <> nil
         for nX := 1 to len(oGridTransp:oData:aArray)
            nPos := aScan(aTransp,{|x| x[01] == oGridTransp:oData:aArray[nX,01]})
            if nPos > 0
                oGridTransp:oData:aArray[nX, 03] := aTransp[nPos,03]
                oGridTransp:oData:aArray[nX, 04] := aTransp[nPos,06]
            endif
        next nX
        oGridTransp:Refresh()
    endif
    if oGridOS <> nil
        nPos := oGridOS:At()
        for nX := 1 to len(aOS)
            if (aOS[nX, 01] == oGridTransp:oData:aArray[oGridTransp:At(),01])
                for nPos := 1 to len(oGridOS:oData:aArray)
                    oGridOS:oData:aArray[nPos, 08] := aOS[nX,06]
                next nPos
            endif
        next nX
        oGridOS:Refresh()
    endif
    if oGridTab <> nil
        nPos := oGridTab:At()
        for nX := 1 to len(aTab)
            if (aTab[nX, 01] == oGridTransp:oData:aArray[oGridTransp:At(),01]) .and. (aTab[nX, 02] == oGridOS:oData:aArray[oGridOS:At(),01])
                for nPos := 1 to len(oGridTab:oData:aArray)
                    oGridTab:oData:aArray[nPos, 03] := aTab[nX,05]
                next nPos
            endif
        next nX
        oGridTab:Refresh()
    endif
return(nil)

static function grvFrete(cCarga)
    local aAtend    := {}
    local aFldValue := {}
    local cTransp   := ''
    local nX        := 0
    local nPos      := 0
    local oCarga    := cbcCtrlCarga():newcbcCtrlCarga()
    for nX := 1 to len(aTransp)
        if aTransp[nX, 03] == nQtdOS
            aAdd(aAtend, nX)
        endif
    next nX
    if empty(aAtend)
        MsgAlert('Não há transportadoras que atendam todas as NFs da Carga!','NFs NÃO Atendidas')
    else
        nPos := modalChoose(aAtend)
        if !empty(nPos)
            oCarga:define(cCarga)
            cTransp := getTransp(aTransp[nPos, 01])
            if empty(cTransp)
                MsgAlert('Cadastro da Transportadora não localizada!','Cadastro não localizado')
            else
                if MsgYesNo('Confirma atualização da Transportadora e do Cálculo?','Confirma')
                    for nX := 1 to len(aTab)
                        if (aTab[nX, 01] == aTransp[nPos, 01]) .and. (AllTrim(aTab[nX, 05]) == 'X')
                            aFldValue := {}
                            aAdd(aFldValue, {'ZZ9_TRANSP',cTransp})
                            aAdd(aFldValue, {'ZZ9_JSCTE', aTab[nX, 06]:ToJson()})
                            oCarga:update(aFldValue, aTab[nX, 02])
                        endif
                    next nX
                    oModal:DeActivate()
                endif
            endif
        endif
    endif
return(nil)

static function modalChoose(aAtend)
    local nX        := 0
    local aDate     := {}
    local aParamBox := {}
    local aRet      := {}
    local nRet      := 0

    for nX := 1 to len(aAtend)
        aAdd(aDate, aTransp[aAtend[nX], 02] + ' - R$' + cValToChar(aTransp[aAtend[nX], 06]))
    next nX
    aadd(aParamBox,{3,'Transportadora:', 1, aDate, 300,"",.T.})
    if ParamBox(aParamBox,"Seleção do Frete",@aRet)
        nRet := aAtend[aRet[1]]
    endif
return(nRet)

static function getTransp(cCgc)
    local oSql      := LibSqlObj():newLibSqlObj()
    local cCod      := ''

    oSql:newAlias(qryTransp(cCgc))
    if oSql:hasRecords()
        oSql:goTop()
        cCod := AllTrim(oSql:getValue("COD"))
    endif
    oSql:close()
    FreeObj(oSql)
return(cCod)

static function getPeso(cCarga, cOS)
    local aArea    	 := GetArea()
    local aAreaZZ9 	 := ZZ9->(GetArea())
    local oVol       := cbcCtrlVolum():newcbcCtrlVolum()
    Local oStatic    := IfcXFun():newIfcXFun()
    local aVol       := {}
    local nY         := 0
    local nPesBruto  := 0

    if !empty(cOS) .and. !empty(cCarga)
        oStatic:sP(5):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aVol, oVol:loadVolumes(cCarga, cOS), .T.)
        for nY := 1 to len(aVol)
            nPesBruto += aVol[nY, 10]
        next nY
    endif

    FreeObj(oVol)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(nPesBruto)

user function cbcDefVeic(cCarga)
	local oModalVei 	:= nil
	local oBtnCad		:= nil
	local oBtnDef		:= nil
    local bDefPlaca     := {|| FWMsgRun(, {||grvPlaca(cCarga)},"Definir Placa", "Definindo...")}
	local bCadVeic      := {|| FWMsgRun(, {||OMSA060()},"Definir Placa", "Definindo...")}
	oModalVei	:= FWDialogModal():New() 
	//Seta a altura e largura da janela em pixel
	oModalVei:setSize(130,130)
	oModalVei:SetEscClose(.T.)
	oModalVei:setTitle('Veículos')
	oModalVei:createDialog()
	
    oBtnCad := TButton():New( 05, 05, 'Cadastro',   oModalVei:getPanelMain(),bCadVeic,  50,30,,,.F.,.T.,.F.,,.F.,,,.F. )    
    oBtnDef := TButton():New( 05, 60, 'Def.Placa',  oModalVei:getPanelMain(),bDefPlaca, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )    
    oModalVei:Activate()
    
	FreeObj(oBtnCad)
	FreeObj(oBtnDef)
	FreeObj(oModalVei)
return(nil)

static function grvPlaca(cCarga)
    local aFldValue := {}
    local cPlaca    := ''
    local oCarga    := cbcCtrlCarga():newcbcCtrlCarga()
   
    oCarga:define(cCarga)
    cPlaca := getPlaca()
    
    if MsgYesNo('Confirma definição da Placa: ' + iif(empty(cPlaca),'SEM PLACA ',AllTrim(cPlaca)) + '?','Confirma')
        aFldValue := {}
        aAdd(aFldValue, {'ZZ9_PLCVEI',cPlaca})
        if oCarga:update(aFldValue):isOk()
            MsgInfo('Placa foi atualizada com sucesso!','Placa Atualizada')
        endif
    endif
return(nil)

static function getPlaca()
    local cPlaca := ""
    local aPerg  := {}
    local aRet   := {}

    aAdd(aPerg,{1,"Placa",Space(TamSX3("C5_VEICULO")[01]),"","Vazio().Or.ExistCPO('DA3')","DA3","",50,.F.})

    if (ParamBox(aPerg,"Informe a Placa",@aRet))
        cPlaca := AllTrim(aRet[01])
    endif
return(cPlaca)

/*QUERY ZONE*/
static function qryCarga(cCarga)
    local cQry := ""

    cQry += " SELECT ZZ9.ZZ9_ORDCAR AS [ORDCAR], "
    cQry += " ZZ9.ZZ9_ORDSEP AS [ORDSEP],  "
    cQry += " SC5.C5_ENDENT1 AS [CEP],  "
    cQry += " SA1.A1_COD + SA1.A1_LOJA + ' - ' + RTRIM(LTRIM(SA1.A1_NOME)) AS [CLI], "
    cQry += " ISNULL(ZZ7.ZZ7_UF,SA1.A1_EST) AS [UF], "
    cQry += " ISNULL(ZZ7.ZZ7_CIDADE, SA1.A1_MUN) AS [MUN],
    cQry += " ISNULL(ZZ7.ZZ7_IBGE, SA1.A1_COD_MUN) AS [IBGE],
    cQry += " ROUND(SUM(ZZR.ZZR_EMBALA + ZZR.ZZR_PESPRO), 2) AS [PESO], "
    cQry += " ROUND(SUM(ZZR.ZZR_QUAN * SC6.C6_PRCVEN), 2) AS [VALOR], "
    cQry += " ZZ9.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL "
    cQry += " 					 AND ZZ9.ZZ9_ORDSEP = ZZR.ZZR_OS "
    cQry += " 					 AND ZZ9.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 					 AND ZZR.ZZR_PEDIDO = SC5.C5_NUM "
    cQry += " 					 AND ZZR.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC6') + " SC6 ON ZZR.ZZR_FILIAL = SC6.C6_FILIAL "
    cQry += " 					 AND ZZR.ZZR_PEDIDO	= SC6.C6_NUM "
    cQry += " 					 AND ZZR.ZZR_ITEMPV	= SC6.C6_ITEM "
    cQry += " 					 AND ZZR.D_E_L_E_T_	= SC6.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 ON ''             = SA1.A1_FILIAL "
    cQry += " 					 AND SC5.C5_CLIENTE = SA1.A1_COD "
    cQry += " 					 AND SC5.C5_LOJACLI = SA1.A1_LOJA "
    cQry += " 					 AND SC5.D_E_L_E_T_ = SA1.D_E_L_E_T_"
    cQry += " LEFT JOIN " + RetSqlName('ZZ7') + " ZZ7 ON '' = ZZ7.ZZ7_FILIAL "
    cQry += " 					 AND SC5.C5_ENDENT1 = ZZ7.ZZ7_CEP "
    cQry += " 					 AND SC5.D_E_L_E_T_ = ZZ7.D_E_L_E_T_ "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '" + cCarga + "'"
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZZ9.ZZ9_ORDCAR, ZZ9.ZZ9_ORDSEP, SC5.C5_ENDENT1, ZZ7.ZZ7_UF, ZZ9.R_E_C_N_O_ , SA1.A1_EST, ZZ7.ZZ7_CIDADE, SA1.A1_MUN, "
    cQry += " SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, ZZ7.ZZ7_IBGE, SA1.A1_COD_MUN "

return(cQry)

static function qryTransp(cCgc)
    local cQry := ""

    cQry += " SELECT SA4.A4_COD AS [COD] "
    cQry += " FROM " + RetSqlName('SA4') + " SA4 "
    cQry += " WHERE SA4.A4_FILIAL = '" + xFilial('SA4') + "' "
    cQry += " AND SA4.A4_CGC = '" + cCgc + "' "
    cQry += " AND SA4.D_E_L_E_T_ = '' "
return(cQry)

static function mockup()
    local aJsOpc    := {}
    local oJson     := nil
    local oTemp     := nil
    local nFrete    := 408.22
    local nIcms     := 83.61
    local nX        := 0
    local aTransp   := {'000002','000401','000130'}

    DbSelectArea('SA4')
    for nX := 1 to 3
        oJson     := JsonObject():new()
        oTemp     := JsonObject():new()
        nFrete  := (nFrete * nX)
        nIcms   := (nIcms * nX)
        oJson['FRETE']  := nFrete
        oJson['ICMS']   := nIcms
        oJson['TOTAL']  := (nFrete + nIcms)
        oJson['TRANSP'] := AllTrim(Posicione("SA4",1,xFilial("SA4")+ aTransp[nX],"A4_NOME"))
        oJson['ROTA']   := 'SP-Capital'
        oJson['CNPJ_TRANSP'] := Posicione("SA4",1,xFilial("SA4")+ aTransp[nX],"A4_CGC")
        oTemp:FromJson('{"FRETE_VALOR": ["FRETE_VALOR", "1", "2", 0.25, 7.29, 0, "Max(((nValor*0.25)/100), 7.29)", ".T."], "GRIS": ["GRIS", "1", "2", 0.23, 7.29, 0, "Max(((nValor*0.23)/100), 7.29)", ".T."], "TAS": ["TAS", "1", "1", 4.14, 0, 0, "4.14", ".T."], "TDE": ["TDE", "2", "5", 0.35722, 136.02, 30, "Max((((nPeso * 0.35722)*30)/100), 136.02)", ".T."], "AUDIT_CALC": [{ "UF_DESTINO": "ES", "PESO_NOTA": 402, "ICMS": [{ "ALIQ": 17, "VLR": 83.61147113253, "BASE": 408.220712, "TOTAL": 491.83218313253 }], "TOTAL_FRETE": 408.220712, "VALOR_NOTA": 20480.89, "UF_ORIGEM": "MT", "FRETE_CALCULO": [ ["FRETE_VALOR", 51.202225], ["GRIS", 47.106047], ["TAS", 4.14], ["TDE", 136.02], ["PEDAGIO", 26.15], ["FRETE_PESO", 143.60244] ] }], "PEDAGIO": ["PEDAGIO", "2", "4", 5.23, 0, 0, "(Ceiling(nPeso/100)* 5.23)", ".T."], "FRETE_PESO": ["FRETE_PESO", "2", "3", 0.35722, 0, 0, "(nPeso * 0.35722)", ".T."]}')
        oJson['CALCULAR'] := oTemp
        aAdd(aJsOpc, oJson)
        FreeObj(oTemp)
        FreeObj(oJson)
        oJson     := JsonObject():new()
        oTemp     := JsonObject():new()
        nFrete  := (nFrete * nX)
        nIcms   := (nIcms * nX)
        oJson['FRETE']  := nFrete
        oJson['ICMS']   := nIcms
        oJson['TOTAL']  := (nFrete + nIcms)
        oJson['TRANSP'] := AllTrim(Posicione("SA4",1,xFilial("SA4")+ aTransp[nX],"A4_NOME"))
        oJson['ROTA']   := 'SP-Interior Leste'
        oJson['CNPJ_TRANSP'] := Posicione("SA4",1,xFilial("SA4")+ aTransp[nX],"A4_CGC")
        oTemp:FromJson('{"FRETE_VALOR": ["FRETE_VALOR", "1", "2", 0.25, 7.29, 0, "Max(((nValor*0.25)/100), 7.29)", ".T."], "GRIS": ["GRIS", "1", "2", 0.23, 7.29, 0, "Max(((nValor*0.23)/100), 7.29)", ".T."], "TAS": ["TAS", "1", "1", 4.14, 0, 0, "4.14", ".T."], "TDE": ["TDE", "2", "5", 0.35722, 136.02, 30, "Max((((nPeso * 0.35722)*30)/100), 136.02)", ".T."], "AUDIT_CALC": [{ "UF_DESTINO": "ES", "PESO_NOTA": 402, "ICMS": [{ "ALIQ": 17, "VLR": 83.61147113253, "BASE": 408.220712, "TOTAL": 491.83218313253 }], "TOTAL_FRETE": 408.220712, "VALOR_NOTA": 20480.89, "UF_ORIGEM": "MT", "FRETE_CALCULO": [ ["FRETE_VALOR", 51.202225], ["GRIS", 47.106047], ["TAS", 4.14], ["TDE", 136.02], ["PEDAGIO", 26.15], ["FRETE_PESO", 143.60244] ] }], "PEDAGIO": ["PEDAGIO", "2", "4", 5.23, 0, 0, "(Ceiling(nPeso/100)* 5.23)", ".T."], "FRETE_PESO": ["FRETE_PESO", "2", "3", 0.35722, 0, 0, "(nPeso * 0.35722)", ".T."]}')
        oJson['CALCULAR'] := oTemp
        aAdd(aJsOpc, oJson)
        FreeObj(oTemp)
        FreeObj(oJson)
        oJson     := JsonObject():new()
        oTemp     := JsonObject():new()
        nFrete  := (nFrete * nX)
        nIcms   := (nIcms * nX)
        oJson['FRETE']  := nFrete
        oJson['ICMS']   := nIcms
        oJson['TOTAL']  := (nFrete + nIcms)
        oJson['TRANSP'] := AllTrim(Posicione("SA4",1,xFilial("SA4")+ aTransp[nX],"A4_NOME"))
        oJson['ROTA']   := 'SP-Interior Oeste'
        oJson['CNPJ_TRANSP'] := Posicione("SA4",1,xFilial("SA4")+ aTransp[nX],"A4_CGC")
        oTemp:FromJson('{"FRETE_VALOR": ["FRETE_VALOR", "1", "2", 0.25, 7.29, 0, "Max(((nValor*0.25)/100), 7.29)", ".T."], "GRIS": ["GRIS", "1", "2", 0.23, 7.29, 0, "Max(((nValor*0.23)/100), 7.29)", ".T."], "TAS": ["TAS", "1", "1", 4.14, 0, 0, "4.14", ".T."], "TDE": ["TDE", "2", "5", 0.35722, 136.02, 30, "Max((((nPeso * 0.35722)*30)/100), 136.02)", ".T."], "AUDIT_CALC": [{ "UF_DESTINO": "ES", "PESO_NOTA": 402, "ICMS": [{ "ALIQ": 17, "VLR": 83.61147113253, "BASE": 408.220712, "TOTAL": 491.83218313253 }], "TOTAL_FRETE": 408.220712, "VALOR_NOTA": 20480.89, "UF_ORIGEM": "MT", "FRETE_CALCULO": [ ["FRETE_VALOR", 51.202225], ["GRIS", 47.106047], ["TAS", 4.14], ["TDE", 136.02], ["PEDAGIO", 26.15], ["FRETE_PESO", 143.60244] ] }], "PEDAGIO": ["PEDAGIO", "2", "4", 5.23, 0, 0, "(Ceiling(nPeso/100)* 5.23)", ".T."], "FRETE_PESO": ["FRETE_PESO", "2", "3", 0.35722, 0, 0, "(nPeso * 0.35722)", ".T."]}')
        oJson['CALCULAR'] := oTemp
        aAdd(aJsOpc, oJson)
        FreeObj(oTemp)
        FreeObj(oJson)
    next nX
return(aJsOpc)

static function calcValor(cCarga, cOS, nMyVal)
    local aArea    	 := GetArea()
    local aAreaSC5 	 := SC5->(GetArea())
    local aAreaSC6 	 := SC6->(GetArea())
    local aAreaSB1 	 := SB1->(GetArea())
    local aAreaSA1   := SA1->(GetArea())
    local oSql       := nil
    local nValor     := 0
    local lFisCalc   := GetNewPar('ZZ_FRETFIS', .F.)
    default nMyVal   := 0

    if lFisCalc
        oSql       := LibSqlObj():newLibSqlObj()
        DbSelectArea("SA1")
        DbSelectArea("SC5")
        oSql:newAlias(qryCliente(cCarga, cOS))
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                SA1->(DbGoTo(oSql:getValue("A1_REC")))
                SC5->(DbGoTo(oSql:getValue("C5_REC")))
                MaFisIni(SA1->A1_COD,;                      // 01 - Codigo Cliente/Fornecedor
                SA1->A1_LOJA,;                              // 02 - Loja do Cliente/Fornecedor
                "C",;                                       // 03 - C:Cliente , F:Fornecedor
                SC5->C5_TIPO,;                              // 04 - Tipo da NF
                SC5->C5_TIPOCLI,;                     	    // 05 - Tipo do Cliente/Fornecedor (F R S)
                MaFisRelImp("MT100", {"SF2", "SD2"}),;      // 06 - Relacao de Impostos que suportados no arquivo
                nil,;                                       // 07 - Tipo de complemento
                nil,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
                "SB1",;                                     // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                "MATA461",;                                 // 10 - Nome da rotina que esta utilizando a funcao
                nil,;                                       // 11 - Tipo documento
                nil,)                                       // 12 - Especie 
                doCalc(cCarga, cOS)
                nValor += MaFisRet(, "NF_TOTAL")
                MaFisEnd()
                oSql:Skip()
            endDo
        endif
        oSql:close()
        FreeObj(oSql)
    endif
    if nValor == 0
        nValor := nMyVal
    endif
    FreeObj(aAreaSC5)
    FreeObj(aAreaSC6)
    FreeObj(aAreaSB1)
    FreeObj(aAreaSA1)
    FreeObj(aArea)
return(nValor)

static function doCalc(cCarga, cOS)
	local aArea   	 := getArea()
	local aAreaSF4 	 := getArea('SF4')
    local aAreaSB1 	 := getArea('SB1')
    local oSql       := LibSqlObj():newLibSqlObj()
    local nItAtu     := 0

    DbSelectArea('SB1')
    DbSelectArea('SF4')
    oSql:newAlias(qryItems(cCarga, cOS))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            nItAtu++
            SB1->(DbGoTo(oSql:getValue("B1_REC")))
            SF4->(DbGoTo(oSql:getValue("F4_REC")))
            MaFisAdd(oSql:getValue("COD"),;         // 01 - Codigo do Produto                    ( Obrigatorio )
            oSql:getValue("TES"),;					// 02 - Codigo do TES                        ( Opcional )
            oSql:getValue("QUANT"),;                // 03 - Quantidade                           ( Obrigatorio )
            oSql:getValue("PRCUNIT"),;              // 04 - Preco Unitario                       ( Obrigatorio )
            0,;                                     // 05 - Desconto
            '',;                                    // 06 - Numero da NF Original                ( Devolucao/Benef )
            '',;                                    // 07 - Serie da NF Original                 ( Devolucao/Benef )
            0,;                                     // 08 - RecNo da NF Original no arq SD1/SD2
            0,;                                     // 09 - Valor do Frete do Item               ( Opcional )
            0,;                                     // 10 - Valor da Despesa do item             ( Opcional )
            0,;                                     // 11 - Valor do Seguro do item              ( Opcional )
            0,;                                     // 12 - Valor do Frete Autonomo              ( Opcional )
            oSql:getValue("TOTAL"),;                // 13 - Valor da Mercadoria                  ( Obrigatorio )
            0,;                                     // 14 - Valor da Embalagem                   ( Opcional )
            SB1->(RecNo()),;                        // 15 - RecNo do SB1
            SF4->(RecNo()))                         // 16 - RecNo do SF4
            
            MaFisLoad("IT_VALMERC", oSql:getValue("TOTAL"), nItAtu)
            MaFisAlt("IT_PESO",     oSql:getValue("PESO"), nItAtu)
	        oSql:Skip()
        endDo
    endif
	oSql:close()
    FreeObj(oSql)
    restArea(aAreaSB1)
    restArea(aAreaSF4)
	restArea(aArea)
return(nil)

static function qryCliente(cCarga, cOS)
    local cQry := ""

    cQry += " SELECT SA1.R_E_C_N_O_ AS [A1_REC], "
    cQry += " SC5.R_E_C_N_O_ AS [C5_REC] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL "
    cQry += " 					 AND ZZ9.ZZ9_ORDSEP = ZZR.ZZR_OS "
    cQry += " 					 AND ZZ9.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 					 AND ZZR.ZZR_PEDIDO = SC5.C5_NUM "
    cQry += " 					 AND ZZR.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 ON ''             = SA1.A1_FILIAL "
    cQry += " 					 AND SC5.C5_CLIENTE = SA1.A1_COD "
    cQry += " 					 AND SC5.C5_LOJACLI = SA1.A1_LOJA "
    cQry += " 					 AND SC5.D_E_L_E_T_ = SA1.D_E_L_E_T_"
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '" + cCarga + "'"
    cQry += " AND ZZ9.ZZ9_ORDSEP = '" + cOS + "'"
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    cQry += " GROUP BY SA1.R_E_C_N_O_, SC5.R_E_C_N_O_ "
return(cQry)

static function qryItems(cCarga, cOS)
    local cQry := ""

    cQry += " SELECT SB1.B1_COD AS [COD],  "
    cQry += " SC6.C6_TES AS [TES],  "
    cQry += " SF4.R_E_C_N_O_ AS [F4_REC], "
    cQry += " ROUND(SUM(ZZR.ZZR_QUAN), 2) AS [QUANT], "
    cQry += " SC6.C6_PRCVEN AS [PRCUNIT], "
    cQry += " ROUND(SUM(ZZR.ZZR_QUAN * SC6.C6_PRCVEN), 2) AS [TOTAL], "
    cQry += " ROUND(SUM(ZZR.ZZR_EMBALA + ZZR.ZZR_PESPRO), 2) AS [PESO], "
    cQry += " SB1.R_E_C_N_O_ AS [B1_REC] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL "
    cQry += " 					 AND ZZ9.ZZ9_ORDSEP = ZZR.ZZR_OS "
    cQry += " 					 AND ZZ9.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 					 AND ZZR.ZZR_PEDIDO = SC5.C5_NUM "
    cQry += " 					 AND ZZR.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC6') + " SC6 ON ZZR.ZZR_FILIAL = SC6.C6_FILIAL "
    cQry += " 					 AND ZZR.ZZR_PEDIDO	= SC6.C6_NUM "
    cQry += " 					 AND ZZR.ZZR_ITEMPV	= SC6.C6_ITEM "
    cQry += " 					 AND ZZR.D_E_L_E_T_	= SC6.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 ON ''             = SA1.A1_FILIAL "
    cQry += " 					 AND SC5.C5_CLIENTE = SA1.A1_COD "
    cQry += " 					 AND SC5.C5_LOJACLI = SA1.A1_LOJA "
    cQry += " 					 AND SC5.D_E_L_E_T_ = SA1.D_E_L_E_T_"
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON ''             = SB1.B1_FILIAL "
    cQry += " 					 AND SC6.C6_PRODUTO = SB1.B1_COD "
    cQry += " 					 AND SC6.D_E_L_E_T_ = SB1.D_E_L_E_T_"
    cQry += " INNER JOIN " + RetSqlName('SF4') + " SF4 ON ''             = SF4.F4_FILIAL "
    cQry += " 					 AND SC6.C6_TES = SF4.F4_CODIGO "
    cQry += " 					 AND SC6.D_E_L_E_T_ = SF4.D_E_L_E_T_"
    cQry += " LEFT JOIN " + RetSqlName('ZZ7') + " ZZ7 ON '' = ZZ7.ZZ7_FILIAL "
    cQry += " 					 AND SC5.C5_ENDENT1 = ZZ7.ZZ7_CEP "
    cQry += " 					 AND SC5.D_E_L_E_T_ = ZZ7.D_E_L_E_T_ "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '" + cCarga + "'"
    cQry += " AND ZZ9.ZZ9_ORDSEP = '" + cOS + "'"
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    cQry += " GROUP BY SB1.B1_COD, "
    cQry += " SF4.R_E_C_N_O_, "
    cQry += " SC6.C6_TES, "
    cQry += " SC6.C6_PRCVEN, "
    cQry += " SB1.R_E_C_N_O_ "
return(cQry)
