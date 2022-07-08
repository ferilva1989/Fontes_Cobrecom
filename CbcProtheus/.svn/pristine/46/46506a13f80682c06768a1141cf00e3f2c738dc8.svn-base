#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"

user function cbcRulesVolum(cMyCarga, cMyOS, aMyRule) //cbcViewVol('','27187202')
    local lCloseButt 	:= !(oAPP:lMdi)
    private aMCoors     := FWGetDialogSize( oMainWnd )
    private oModal 		:= nil
    private oFWLayer    := nil
    private oPnlCDet    := nil
    private oPnlCVol    := nil
    private oPnlDet     := nil
    private oPnlVol     := nil
    private oFont	    := TFont():New("Arial",,15,,.T.)
    private aRules      := {}
    private aHeader     := {}
    private aHeaderDet  := {}
    private aHeaderVol  := {}
    private aColsGrid   := {}
    private oGridVol    := nil
    private oGridDet    := nil
    private oBtnAddVol  := nil
    private oBtnUp      := nil
    private oBtnDown    := nil
    private oBtnRemVol  := nil
    private oBtnAddDet  := nil
    private oBtnRemDet  := nil
    private oVol        := cbcCtrlVolum():newcbcCtrlVolum()
    private cCarga      := ''
    private cOS         := ''
    default cMyOS       := ''
    default cMyCarga    := ''
    default aMyRule     := {}

    cCarga  := cMyCarga
    cOS     := cMyOS

    if !empty(aMyRule)
        aRules  := aMyRule
    else
        aRules      := oVol:loadRules(iif(empty(cOS), '', cCarga), cOS)[01,02]
    endif

    oModal      := FWDialogModal():New()
    oModal:setSize((aMCoors[3] * 0.5),(aMCoors[4] * 0.5))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Parâmetros de Volumes')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oFWLayer := FWLayer():New()
    oFWLayer:Init(oModal:getPanelMain(), lCloseButt)
    cfgLayout()
    mntBrw('VOL', @oGridVol, @oPnlVol)
    mntBrw('DET', @oGridDet, @oPnlDet)
    defButtons()
    oModal:Activate()

    FreeObj(oBtnAddVol)
    FreeObj(oBtnUp)
    FreeObj(oBtnDown)
    FreeObj(oBtnRemVol)
    FreeObj(oBtnAddDet)
    FreeObj(oBtnRemDet)
    FreeObj(oVol)
    FreeObj(oFont)
    FreeObj(oGridVol)
    FreeObj(oGridDet)
    FreeObj(oPnlCVol)
    FreeObj(oPnlCDet)
    FreeObj(oPnlDet)
    FreeObj(oPnlVol)
    FreeObj(oFWLayer)
    FreeObj(oModal)
return(aRules)

static function cfgLayout()
    oFWLayer:AddCollumn('COL_LEFT', 10, .F.)
    oFWLayer:AddCollumn('COL_RIGHT',89, .F.)

    oFWLayer:AddWindow('COL_LEFT', 'WND_CTRLVOL', 'Controles', 50, .T., .F.)
    oPnlCVol := oFWLayer:GetWinPanel('COL_LEFT', 'WND_CTRLVOL')
    oFWLayer:AddWindow('COL_LEFT', 'WND_CTRLDET', 'Controles', 50, .T., .F.)
    oPnlCDet := oFWLayer:GetWinPanel('COL_LEFT', 'WND_CTRLDET')

    // Coluna Direita (Principal)
    oFWLayer:AddWindow('COL_RIGHT', 'WND_VOL', 'Volumes', 50, .T., .F.)
    oPnlVol := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_VOL')
    oFWLayer:AddWindow('COL_RIGHT', 'WND_DET', 'Detalhes', 50, .T., .F.)
    oPnlDet := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_DET')
return(nil)

static function defButtons()
    oBtnAddVol := TButton():New(05,05,'Adicionar', oPnlCVol ,;
        {|| AddLine('VOL', @oGridVol) }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    //oBtnVol:Align := CONTROL_ALIGN_CENTER
    oBtnUp := TButton():New(40,05,'/\', oPnlCVol ,;
        {|| chgOrder('UP') }, 25,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnDown:= TButton():New(40,30,'\/', oPnlCVol ,;
        {|| chgOrder('DOWN') }, 25,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnRemVol:= TButton():New(75,05,'Remover', oPnlCVol ,;
        {|| delLine('VOL', @oGridVol) }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnAddDet := TButton():New(05,05,'Adicionar.', oPnlCDet ,;
        {|| AddLine('DET', @oGridDet) }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnRemDet := TButton():New(40,05,'Remover', oPnlCDet ,;
        {|| delLine('DET', @oGridDet) }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    if empty(oGridVol:oData:aArray)
        oBtnAddDet:Disable()
        oBtnRemDet:Disable()
    endif
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
        oGrid:SetChange({ || loadDet()})
    endif
    mntDados(cOpc, @oGrid)
    oGrid:Activate()
return(nil)

static function mntHeader(cOpc)
    local aHeaderAux := {}
    local nAtual     := 0
    local cGrid      := ''

    aHeader := {}

    if cOpc == 'VOL'
        cGrid := 'oGridVol'
        aHeaderVol := {}
        aAdd(aHeaderVol, {"Ordem",        "N", 02, 0, "@E 99"})
        aAdd(aHeaderVol, {"Volume",       "C", 01, 0, ""})
        aAdd(aHeaderVol, {"Lim.Min",      "N", 09, 0, "@E 999,999,999"})
        aAdd(aHeaderVol, {"Lim.Max",      "N", 09, 0, "@E 999,999,999"})
        aAdd(aHeaderVol, {"Lim.Unit",     "N", 09, 0, "@E 999,999,999"})
        aAdd(aHeaderVol, {"Peso Unit",    "N", 09, 2, "@E 999,999.999"})
        aHeaderAux := aClone(aHeaderVol)
    else
        cGrid := 'oGridDet'
        aHeaderDet := {}
        aAdd(aHeaderDet, {"Acondic.",     "C", 01, 0, ""})
        aAdd(aHeaderDet, {"Tipo",         "C", 05, 0, ""})
        aHeaderAux := aClone(aHeaderDet)
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
    local nX    := 0

    //Zera a grid
    aColsGrid := {}

    if !empty(aRules)
        if cOpc == 'VOL'
            for nX := 1 to len(aRules)
                aAdd(aColsGrid, {nX,;
                    aRules[nX, 02],;
                    aRules[nX, 03],;
                    aRules[nX, 04],;
                    aRules[nX, 05],;
                    aRules[nX, 06]})
            next nX
        else
            for nX := 1 to len(aRules[oGridVol:At(), 07])
                aAdd(aColsGrid, {aRules[oGridVol:At(), 07, nX, 01],;
                    Padr(aRules[oGridVol:At(), 07, nX, 02], 05)})
            next nX
        endif
        oGrid:SetArray(aColsGrid)
        oGrid:Refresh()
    endif
return(nil)

static function loadDet()
    if oGridDet <> nil
        oGridDet:DeActivate()
        FreeObj(oGridDet)
        oPnlDet:FreeChildren()
        mntBrw('DET', @oGridDet, @oPnlDet)
    endif
    oGridVol:SetFocus()
return(nil)

static function validTipo()
    local lOk := .T.

    if MV_PAR01 == 'B' .and. !empty(MV_PAR02)
        lOk := (AllTrim(MV_PAR02) $ ('1|2|3|4|5|6|7|8|9'))
    endif
    if !lOk
        MsgAlert('Tipo de Bobina Inválido!','Erro de Validação')
    endif
return(lOk)

static function AddLine(cOpc, oGrid)
    local aRet      := {}
    local aPergs    := {}
    local aAcondic  := {'B','R','L','C','M','T'}
    local aVolum    := {'F','P'}
    local nOrdem    := (Len(oGrid:oData:aArray) + 1)

    if cOpc == 'VOL'
        aAdd( aPergs ,{1, aHeaderVol[01, 01], nOrdem,   aHeaderVol[01, 05], ".T.",, ".F.", 50, .T.})
        aAdd( aPergs ,{2, aHeaderVol[02, 01], 'F',        aVolum,    50,  ".T.", .T.})
        aAdd( aPergs ,{1, aHeaderVol[03, 01], 0.00,     aHeaderVol[03, 05], ".T.",, ".T.", 50, .F.})
        aAdd( aPergs ,{1, aHeaderVol[04, 01], 0.00,     aHeaderVol[04, 05], "MV_PAR04 > MV_PAR03",, ".T.", 50, .T.})
        aAdd( aPergs ,{1, aHeaderVol[05, 01], 0.00,     aHeaderVol[05, 05], "MV_PAR05 > 0",, ".T.", 50, .T.})
        aAdd( aPergs ,{1, aHeaderVol[06, 01], 0.00,     aHeaderVol[06, 05], ".T.",, ".T.", 50, .F.})
    else
        aAdd( aPergs ,{2, aHeaderDet[01, 01], 'R',      aAcondic, 50, ".T.", .T.})
        aAdd( aPergs ,{1, aHeaderDet[02, 01], Space(5), aHeaderDet[02, 05], "StaticCall(cbcRulesVolum, validTipo)",, "MV_PAR01 == 'B'", 50, .F.})
    endif
    if !(ParamBox(aPergs ,"Adicionar Regras", @aRet))
        MsgAlert('Adição cancelada','Cancelada')
    else
        preAddLine(cOpc, @oGrid)
        //oGrid:GoBottom()
        if cOpc == 'VOL'
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 1] := aRet[1]
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 2] := aRet[2]
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 3] := aRet[3]
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 4] := aRet[4]
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 5] := aRet[5]
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 6] := aRet[6]
            aAdd(aRet, {})
            aAdd(aRules, AClone(aRet))
            rfshBrw()
        else
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 1] := aRet[1]
            oGrid:oData:aArray[Len(oGrid:oData:aArray), 2] := aRet[2]
            aAdd(aRules[oGridVol:At(), 07], aRet)
        endif
        oGrid:Refresh()
    endif
return(.T.)

static function preAddLine(cOpc, oGrid)
    if cOpc == 'VOL'
        aAdd(oGrid:oData:aArray, {0, Space(1), 0, 0, 0, 0})
    else
        aAdd(oGrid:oData:aArray, {Space(1), Space(5)})
    endif
return(.T.)

static function delLine(cOpc, oGrid)
    if cOpc == 'VOL'
        aDel(aRules, oGridVol:At())
        aSize(aRules,(len(aRules)-1))
    else
        aDel(aRules[oGridVol:At(), 07], oGrid:At())
        aSize(aRules[oGridVol:At(),07],(len(aRules[oGridVol:At(), 07])-1))
    endif
    if !empty(oGrid:oData:aArray)
        aDel(oGrid:oData:aArray, oGrid:At())
        aSize(oGrid:oData:aArray,(len(oGrid:oData:aArray)-1))
    endif
    if empty(oGrid:oData:aArray)
        rfshBrw()
    endif
    chgOrder('DEL')
    oGrid:Refresh()
return(.T.)


static function chgOrder(cOpc)
    local nX    := 0
    local nPos  := oGridVol:At()

    if !empty(oGridVol:oData:aArray)
        if cOpc == 'DEL'
            for nX := 1 to len(oGridVol:oData:aArray)
                aRules[nX, 01] := nX
                oGridVol:oData:aArray[nX, 01] := nX
            next nX
        elseif cOpc == 'UP'
            if nPos > 1
                aRules[nPos, 01]--
                oGridVol:oData:aArray[nPos, 01]--
                aRules[(nPos-1), 01]++
                oGridVol:oData:aArray[(nPos-1), 1]++
                oGridVol:GoUp()
            endif
        elseif cOpc == 'DOWN'
            if nPos < len(oGridVol:oData:aArray)
                aRules[nPos, 01]++
                oGridVol:oData:aArray[nPos, 1]++
                aRules[(nPos+1), 01]--
                oGridVol:oData:aArray[(nPos+1), 1]--
                oGridVol:GoDown()
            endif
        endif
        rfshBrw()
    endif
return(.T.)

static function rfshBrw()
    if !empty(oGridVol:oData:aArray)
        aSort(@aRules, , , { | x,y | x[1] < y[1] } )
        aSort(@oGridVol:oData:aArray, , , { | x,y | x[1] < y[1] } )
    endif
    oGridVol:Refresh()
    loadDet()
    if empty(oGridVol:oData:aArray)
        oBtnAddDet:Disable()
        oBtnRemDet:Disable()
    else
        oBtnAddDet:Enable()
        oBtnRemDet:Enable()
    endif
return(nil)
