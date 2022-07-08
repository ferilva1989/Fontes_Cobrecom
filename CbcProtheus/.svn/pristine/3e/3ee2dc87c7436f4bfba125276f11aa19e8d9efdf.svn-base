#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"
#include 'cbcOrdemCar.ch'

user function cbcViewVol(cMyCarga, cMyOS) //cbcViewVol('00000007','27187202')
    local lCloseButt 	:= !(oAPP:lMdi)
    private aMCoors     := FWGetDialogSize( oMainWnd )
    private oModal 		:= nil
    private oFWLayer    := nil
    private oPnlCtrl    := nil
    private oPnlChart   := nil
    private oPnlDet     := nil
    private oPnlVol     := nil
    private oPnlOS      := nil
    private oChart      := nil
    private aRand       := {}
    private oVol        := cbcCtrlVolum():newcbcCtrlVolum()
    private aVolumes    := {}
    private aVolInit    := {}
    private oFont	    := TFont():New("Arial",,15,,.T.)
    private aRules      := nil
    private aHeader     := {}
    private aColsGrid   := {}
    private oGridVol    := nil
    private oGridDet    := nil
    private oGridOS     := nil
    private oBtnRules   := nil
    private oBtnSave    := nil
    private oBtnResume  := nil
    private lSave       := .F.
    private cCarga      := ''
    private cOS         := ''
    default cMyOS       := ''
    default cMyCarga    := ''

    cCarga  := cMyCarga
    cOS     := cMyOS

    if empty(cOS) .and. empty(cCarga)
        msgAlert('Ordem de Carga ou Separação não definidas!','Sem Ordem')
    else
        aVolumes := oVol:loadVolumes(cCarga, cOS, @aRules)
        if empty(aVolumes)
            aRules      := oVol:loadRules(cCarga, cOS)
            aVolumes    := oVol:genVolumes(aRules)
        else
            aVolInit := AClone(aVolumes)
        endif
        oModal      := FWDialogModal():New()
        oModal:setSize((aMCoors[3] * 0.5),(aMCoors[4] * 0.5))
        oModal:SetEscClose(.T.)
        oModal:setTitle('Volumes - ' + iif(!empty(cOS), 'OS: ' + cOS, 'CARGA: ' + cCarga) + iif(!empty(cCarga), ' - Alteração', ' - Simulação'))
        oModal:createDialog()
        oModal:addCloseButton({|| finish()}, "Fechar")
        oFWLayer := FWLayer():New()
        oFWLayer:Init(oModal:getPanelMain(), lCloseButt)
        cfgLayout()
        mntChart()
        mntBrw('OS',  @oGridOS,  @oPnlOS)
        mntBrw('VOL', @oGridVol, @oPnlVol)
        mntBrw('DET', @oGridDet, @oPnlDet)
        defButtons()
        oModal:Activate()
    endif

    FreeObj(oChart)
    FreeObj(oVol)
    FreeObj(oFont)
    FreeObj(oGridVol)
    FreeObj(oGridDet)
    FreeObj(oGridOS)
    FreeObj(oBtnRules)
    FreeObj(oBtnSave)
    FreeObj(oBtnResume)
    FreeObj(oPnlOS)
    FreeObj(oPnlCtrl)
    FreeObj(oPnlChart)
    FreeObj(oPnlDet)
    FreeObj(oPnlVol)
    FreeObj(oFWLayer)
    FreeObj(oModal)
return(nil)

static function cfgLayout()
    oFWLayer:AddCollumn('COL_LEFT', 30, .F.)
    oFWLayer:AddCollumn('COL_RIGHT',70, .F.)

    // Coluna Esquerda (Controles)
    oFWLayer:AddWindow('COL_LEFT', 'WND_OS', 'Ordens Separação', 30, .T., .F.)
    oPnlOS := oFWLayer:GetWinPanel('COL_LEFT', 'WND_OS')
    oFWLayer:AddWindow('COL_LEFT', 'WND_CHRT', 'Gráfico da Carga', 47, .T., .F.)
    oPnlChart := oFWLayer:GetWinPanel('COL_LEFT', 'WND_CHRT')
    oFWLayer:AddWindow('COL_LEFT', 'WND_CTRL', 'Controles', 23, .T., .F.)
    oPnlCtrl := oFWLayer:GetWinPanel('COL_LEFT', 'WND_CTRL')

    // Coluna Direita (Principal)
    oFWLayer:AddWindow('COL_RIGHT', 'WND_VOL', 'Volumes', 50, .T., .F.)
    oPnlVol := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_VOL')
    oFWLayer:AddWindow('COL_RIGHT', 'WND_DET', 'Detalhes', 50, .T., .F.)
    oPnlDet := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_DET')
return(nil)

static function defButtons()
    oBtnRules := TButton():New(01,00,'Regras', oPnlCtrl ,;
        {|| FWMsgRun(, { || chgRules() },'Alterando Regras','Alterando...')}, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnSave := TButton():New(01,55,'Salvar', oPnlCtrl ,;
        {|| FWMsgRun(, { || saveVol()},'Salvando Volumes','Salvando...') }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnSave:Disable()
    oBtnResume := TButton():New(01,110,'Resumo', oPnlCtrl ,;
        {|| FWMsgRun(, { || resume() },'Resumo de Volumes','Carregando...')}, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
return(nil)

static function mntChart()
    oChart := FwChartFactory():New()
    oChart:SetOwner(oPnlChart)
    oChart:SetChartDefault(NEWPIECHART)
    chartSeries()
    oChart:EnableMenu(.T.)
    oChart:setLegend( CONTROL_ALIGN_BOTTOM )
    oChart:setPicture("@E 999,999.999")
    oChart:Activate(  )
return(nil)

static function chartSeries()
    local aTemp := {}
    local aVol  := {}
    local nY    := 0
    local nX    := 0
    local nPos  := 0

    for nX := 1 to len(aVolumes)
        aTemp := aVolumes[nX, 02]['VOLUMES']
        for nY := 1 to len(aTemp)
            nPos := aScan(aVol,{|x|x[1] == aTemp[nY, 01]})
            if nPos == 0
                aAdd(aVol, {aTemp[nY, 01], (aTemp[nY, 02] + aTemp[nY, 05])})
            else
                aVol[nPos, 02] += (aTemp[nY, 02] + aTemp[nY, 05])
            endif
        next nY
    next nX
    for nX := 1 to len(aVol)
        oChart:addSerie(aVol[nX, 01], aVol[nX, 02])
    next nX
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
    if cOpc <> 'DET'
        oGrid:SetChange({ || loadDet(cOpc)})
    endif
    mntDados(cOpc, @oGrid)
    oGrid:Activate()
return(nil)

static function mntHeader(cOpc)
    local aHeaderAux := {}
    local nAtual     := 0
    local cGrid      := ''
    aHeader := {}
    if cOpc == 'OS'
        cGrid := 'oGridOS'
        aAdd(aHeaderAux, {"Ordem Sep.",  GetSx3Cache('ZZ9_ORDSEP','X3_TIPO'),TamSx3('ZZ9_ORDSEP')[1], 0, PesqPict('ZZ9', 'ZZ9_ROTA')})
        aAdd(aHeaderAux, {"Cliente",     GetSx3Cache('A1_NOME',   'X3_TIPO'), (TamSx3('A1_COD')[1]+TamSx3('A1_LOJA')[1]+TamSx3('A1_NOME')[1]), 0, PesqPict('SA1', 'A1_NOME')})
    elseif cOpc == 'VOL'
        cGrid := 'oGridVol'
        aAdd(aHeaderAux, {"Volume",       "C", 01, 0, ""})
        aAdd(aHeaderAux, {"Quant.",       "N", 09, 0, "@E 999,999,999"})
        aAdd(aHeaderAux, {"Peso Liq.",    "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Tara",         "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Peso Bruto",   "N", 09, 2, "@E 999,999.999"})
    else
        cGrid := 'oGridDet'
        aAdd(aHeaderAux, {"Acondic.",     "C", 01, 0, ""})
        aAdd(aHeaderAux, {"Tipo",         "C", 05, 0, ""})
        aAdd(aHeaderAux, {"Peso Liq.",    "N", 09, 2, "@E 999,999.999"})
        aAdd(aHeaderAux, {"Quant.",       "N", 09, 0, "@E 999,999,999"})
    endif

    for nAtual := 1 to Len(aHeaderAux)
        aAdd(aHeader, FWBrwColumn():New())
        aHeader[nAtual]:SetData(&("{||" + cGrid + ":oData:aArray[" + cGrid + ":At(),"+Str(nAtual)+"]}"))
        aHeader[nAtual]:SetTitle( aHeaderAux[nAtual][1] )
        aHeader[nAtual]:SetType(aHeaderAux[nAtual][2] )
        aHeader[nAtual]:SetSize( aHeaderAux[nAtual][3] )
        aHeader[nAtual]:SetDecimal( aHeaderAux[nAtual][4] )
        aHeader[nAtual]:SetPicture( aHeaderAux[nAtual][5] )
    next nAtual
return(aHeader)

static function mntDados(cOpc, oGrid)
    local nPos  := 0
    local nX    := 0
    local nY    := 0
    local aVol  := {}
    Local oStatic   := IfcXFun():newIfcXFun()

    //Zera a grid
    aColsGrid := {}

    //aVol := oVolumes['VOLUMES']

    if cOpc == 'OS'
        for nX := 1 to len(aVolumes)
            aAdd(aColsGrid, {aVolumes[nX, 01], oStatic:sP(1):callStatic('cbcManifesto', 'findOSCli', aVolumes[nX, 01])})
        next nX
    elseif cOpc == 'VOL'
        nPos := aScan(aVolumes,{|x|x[1] == oGridOS:oData:aArray[oGridOS:At(), 1]})
        if nPos >0
            aVol := aVolumes[nPos, 02]['VOLUMES']
            for nX := 1 to len(aVol)
                aAdd(aColsGrid, {aVol[nX, 01],;
                    aVol[nX, 04],;
                    aVol[nX, 02],;
                    aVol[nX, 05],;
                    (aVol[nX, 05] + aVol[nX, 02])})
            next nX
        endif
    else
        nPos := aScan(aVolumes,{|x|x[1] == oGridOS:oData:aArray[oGridOS:At(), 1]})
        if nPos >0
            aVol := aVolumes[nPos, 02]['VOLUMES']
            nPos := aScan(aVol,{|x|x[1] == oGridVol:oData:aArray[oGridVol:At(), 1]})
            if nPos > 0
                for nY := 1 to len(aVol[nPos, 03])
                    aAdd(aColsGrid, {aVol[nPos, 03, nY, 01],;
                        aVol[nPos, 03, nY, 02],;
                        aVol[nPos, 03, nY, 03],;
                        aVol[nPos, 03, nY, 04]})
                next nY
            endif
        endif
    endif
    oGrid:SetArray(aColsGrid)
    oGrid:Refresh()
return(nil)

static function loadDet(cOpc)
    if cOpc == 'OS'
        if oGridVol <> nil
            oGridVol:DeActivate()
            FreeObj(oGridVol)
            oPnlVol:FreeChildren()
            mntBrw('VOL', @oGridVol, @oPnlVol)
        endif
        if oGridDet <> nil
            oGridDet:DeActivate()
            FreeObj(oGridDet)
            oPnlDet:FreeChildren()
            mntBrw('DET', @oGridDet, @oPnlDet)
        endif
        oGridOS:SetFocus()
    else
        if oGridDet <> nil
            oGridDet:DeActivate()
            FreeObj(oGridDet)
            oPnlDet:FreeChildren()
            mntBrw('DET', @oGridDet, @oPnlDet)
        endif
        oGridVol:SetFocus()
    endif
return(nil)

static function chgRules()
    local aRule := {}
    local aVol  := {}
    local nX    := 0
    local lCarga:= .F.

    if !empty(cCarga)
        lCarga := msgYesNo('Modificar todas as OSs da CARGA?','Modificar CARGA')
    endif

    if lCarga .or. empty(cCarga)
        aRule      := u_cbcRulesVolum('','')
        for nX := 1 to len(oGridOS:oData:aArray)
            aAdd(aVol, {oGridOS:oData:aArray[nX, 01], aRule})
        next nX
        aVolumes := oVol:genVolumes(aVol)
    else
        aRule       := u_cbcRulesVolum(cCarga, oGridOS:oData:aArray[oGridOS:At(), 1])
        aVol        := oVol:genVolumes({{oGridOS:oData:aArray[oGridOS:At(), 1], aRule}})
        nX          := aScan(aVolumes,{|x|x[1] == aVol[01, 01]})
        if nX > 0
            aVolumes[nX, 02] := aVol[01, 02]
        else
            msgAlert('Erro ao Processar Alteração das Regras!','Erro Alteração')
        endif
    endif
    lSave := .T.
    oBtnSave:Enable()
    reboot()
return(nil)

static function reboot()
    if oChart <> nil
        oChart:DeActivate()
        FreeObj(oChart)
    endif
    oPnlChart:FreeChildren()
    if oGridOS <> nil
        oGridOS:DeActivate()
        FreeObj(oGridOS)
    endif
    oPnlOS:FreeChildren()
    aHeader     := {}
    aColsGrid   := {}
    mntChart()
    mntBrw('OS', @oGridOS, @oPnlOS)
    loadDet('OS')
return(nil)

static function saveVol()
    local oCarga    := nil
    local aDiverg   := {}
    Local oStatic   := IfcXFun():newIfcXFun()

    if MsgYesNo('Confirma alteração dos volumes!','Confirma')
        oCarga := cbcCtrlCarga():newcbcCtrlCarga()
        oCarga:define(cCarga)
        oCarga:updVol(aVolumes)
        if (oCarga:getStatus() == CARGA_FATURADA)
            aDiverg := oStatic:sP(3):callStatic('cbcCtrlVolum', 'VolCompare', cCarga, aVolInit, aVolumes)
            oStatic:sP(1):callStatic('cbcCtrlVolum', 'ReqCCE', aDiverg)
        endif
        aVolInit := AClone(aVolumes)
        FreeObj(oCarga)
        lSave := .F.
        oBtnSave:Disable()
    endif
return(.T.)

static function finish()
    if lSave
        if MsgYesNo('Existem alterações não salvas! Deseja salvar?','Salvar Alterações')
            FWMsgRun(, { || saveVol()}, 	"Salvar Volumes", "Salvando...")
        endif
    endif
    oModal:DeActivate()
return(.T.)

static function resume()
    FWMsgRun(, { || u_cbcManifesto(cCarga, aVolumes)}, 	"Resumo de Carga", "Gerando...")
return(nil)
