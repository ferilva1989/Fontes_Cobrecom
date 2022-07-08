#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

user function cbcManifesto(cMyCarga, aMyVol) //cbcManifesto('00000007')
    local lCloseButt 	:= !(oAPP:lMdi)
    private aMCoors     := FWGetDialogSize( oMainWnd )
    private oModal 		:= nil
    private oFWLayer    := nil
    private oPnlCtrl    := nil
    private oPnlRes     := nil
    private oPnlDet     := nil
    private aVolumes    := {}
    private oFont	    := TFont():New("Arial",,15,,.F.)
    private aRules      := nil
    private aHeader     := {}
    private aColsGrid   := {}
    private oGridDet    := nil
    private oGridRes    := nil
    private oBtnPrint   := nil
    private oBtnExport  := nil
    private oBtnSend    := nil
    private cCarga      := ''
    private cOS         := ''
    default cMyOS       := ''
    default cMyCarga    := ''

    if empty(cMyCarga) .and. empty(aMyVol)
        msgAlert('Dados de Origem não definidos!','Sem Origem')
    else
        cCarga  := cMyCarga
        aVolumes:= getVol(cCarga, aMyVol)
        oModal      := FWDialogModal():New()
        oModal:setSize((aMCoors[3] * 0.5),(aMCoors[4] * 0.5))
        oModal:SetEscClose(.T.)
        oModal:setTitle('Resumo de Carga - CARGA: ' + cCarga)
        oModal:createDialog()
        oModal:addCloseButton(nil, "Fechar")
        oFWLayer := FWLayer():New()
        oFWLayer:Init(oModal:getPanelMain(), lCloseButt)
        cfgLayout()
        mntBrw('DET', @oGridDet, @oPnlDet, aVolumes)
        mntBrw('RES', @oGridRes, @oPnlRes, aVolumes)
        defButtons()
        oModal:Activate()
    endif

    FreeObj(oFont)
    FreeObj(oGridDet)
    FreeObj(oGridRes)
    FreeObj(oBtnPrint)
    FreeObj(oBtnExport)
    FreeObj(oBtnSend)
    FreeObj(oPnlCtrl)
    FreeObj(oPnlDet)
    FreeObj(oPnlRes)
    FreeObj(oFWLayer)
    FreeObj(oModal)
return(nil)

static function cfgLayout()
    oFWLayer:AddCollumn('COL_LEFT', 10, .F.)
    oFWLayer:AddCollumn('COL_RIGHT',90, .F.)

    // Coluna Esquerda (Controles)
    oFWLayer:AddWindow('COL_LEFT', 'WND_CTRL', 'Controles', 100, .T., .F.)
    oPnlCtrl := oFWLayer:GetWinPanel('COL_LEFT', 'WND_CTRL')

    // Coluna Direita (Principal)
    oFWLayer:AddWindow('COL_RIGHT', 'WND_RES', 'Resumo', 20, .T., .F.)
    oPnlRes := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_RES')
    oFWLayer:AddWindow('COL_RIGHT', 'WND_DET', 'Detalhes', 80, .T., .F.)
    oPnlDet := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_DET')
return(nil)

static function defButtons()
    oBtnPrint := TButton():New(05,05,'Imprimir', oPnlCtrl ,;
        {|| FWMsgRun(, { || u_cbcRptManifesto(cCarga, aVolumes)},'Imprimir Volumes','Imprimindo..') }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnExport := TButton():New(40,05,'Exportar', oPnlCtrl ,;
        {|| FWMsgRun(, { || export(cCarga, aVolumes)},'Exportar Volumes','Exportando...') }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnSend := TButton():New(75,05,'Enviar', oPnlCtrl ,;
        {|| Alert('Função Indisponível!') }, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
return(nil)

static function getVol(cCarga, aVol)
    local oVol      := cbcCtrlVolum():newcbcCtrlVolum()
    default aVol    := {}

    if empty(aVol)
        aVol := oVol:loadVolumes(cCarga)
    endif

    FreeObj(oVol)
return(aVol)

static function mntBrw(cOpc, oGrid, oPnl, aVol)
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
    mntDados(cOpc, @oGrid, @aColsGrid, aVol)
    oGrid:Activate()
return(nil)

static function mntHeader(cOpc)
    local aHeaderAux := {}
    local cGrid      := 'oGridRes'
    local nAtual     := 0

    aHeader := {}
    if cOpc == 'DET'
        cGrid := 'oGridDet'
        aAdd(aHeaderAux, {"NF",         GetSx3Cache('ZZ9_DOC','X3_TIPO'),;
            (TamSx3('ZZ9_DOC')[1] + TamSx3('ZZ9_SERIE')[1]),;
            0, PesqPict('ZZ9', 'ZZ9_DOC')})
        aAdd(aHeaderAux, {"OS",         GetSx3Cache('ZZ9_ORDSEP','X3_TIPO'),;
            TamSx3('ZZ9_ORDSEP')[1],;
            0, PesqPict('ZZ9', 'ZZ9_ORDSEP')})
        aAdd(aHeaderAux, {"Cliente",    GetSx3Cache('A1_NOME',  'X3_TIPO'),;
            (TamSx3('A1_COD')[1]+TamSx3('A1_LOJA')[1]+TamSx3('A1_NOME')[1]),;
            0, PesqPict('SA1', 'A1_NOME')})
    endif

    aAdd(aHeaderAux, {"Fardos",     "N", 09, 2, "@E 999,999.99"})
    aAdd(aHeaderAux, {"Carret.",    "N", 09, 2, "@E 999,999.99"})
    aAdd(aHeaderAux, {"Bobinas",    "N", 09, 2, "@E 999,999.99"})
    aAdd(aHeaderAux, {"Paletes",    "N", 09, 2, "@E 999,999.99"})
    aAdd(aHeaderAux, {"Caixas",     "N", 09, 2, "@E 999,999.99"})
    aAdd(aHeaderAux, {"Rolos",      "N", 09, 2, "@E 999,999.99"})
    aAdd(aHeaderAux, {"Peso Total", "N", 09, 2, "@E 999,999.99"})

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

static function mntDados(cOpc, oGrid, aColsGrid, aVolumes, lAllPes)
    local nX    := 0
    local nY    := 0
    local nZ    := 0
    local aTemp := {}
    default lAllPes := .F.

    //Zera a grid
    aColsGrid := {}

    if cOpc == 'RES'
        aAdd(aColsGrid, {0,0,0,0,0,0,0.00})
        for nX := 1 to len(aVolumes)
            if !empty(aVolumes[nX, 02]:GetNames())
                if ValType(aVolumes[nX, 02]:GetJsonObject('PESOBRUTO')) <> 'U'
                    aColsGrid[01,07] += aVolumes[nX, 02]['PESOBRUTO']
                endif
                if ValType(aVolumes[nX, 02]:GetJsonObject('VOLUMES')) <> 'U'
                    for nY := 1 to len(aVolumes[nX, 02]['VOLUMES'])
                        if aVolumes[nX, 02]['VOLUMES'][nY, 01] == 'G'
                            aTemp := aVolumes[nX, 02]['VOLUMES'][nY, 03]
                            for nZ := 1 to len(aTemp)
                                if aTemp[nZ, 01] == 'R'
                                    aColsGrid[01,06] += aTemp[nZ, 04]
                                elseif aTemp[nZ, 01] == 'C' .or. aTemp[nZ, 01] == 'M'
                                    aColsGrid[01,02] += aTemp[nZ, 04]
                                elseif aTemp[nZ, 01] == 'L'
                                    aColsGrid[01,05] += aTemp[nZ, 04]
                                elseif aTemp[nZ, 01] == 'B'
                                    aColsGrid[01,03] += aTemp[nZ, 04]
                                endif
                            next nZ
                        elseif aVolumes[nX, 02]['VOLUMES'][nY, 01] == 'F'
                            aColsGrid[01,01] += aVolumes[nX, 02]['VOLUMES'][nY, 04]
                        elseif aVolumes[nX, 02]['VOLUMES'][nY, 01] == 'P'
                            aColsGrid[01,04] += aVolumes[nX, 02]['VOLUMES'][nY, 04]
                        endif
                    next nY
                endif
            endif
        next nX
    else
        for nX := 1 to len(aVolumes)
            aAdd(aColsGrid, {findOSNF(aVolumes[nX, 01]), aVolumes[nX, 01], findOSCli(aVolumes[nX, 01],aVolumes[nX, 03]), 0,0,0,0,0,0,0.00})
            if !empty(aVolumes[nX, 02]:GetNames())
                if ValType(aVolumes[nX, 02]:GetJsonObject('PESOBRUTO')) <> 'U'
                    aColsGrid[nX,10] += aVolumes[nX, 02]['PESOBRUTO']
                endif
                if lAllPes
                    if ValType(aVolumes[nX, 02]:GetJsonObject('PESOLIQUIDO')) <> 'U'
                        aAdd(aColsGrid[nX], aVolumes[nX, 02]['PESOLIQUIDO'])
                    endif
                    if ValType(aVolumes[nX, 02]:GetJsonObject('PESOTARA')) <> 'U'
                        aAdd(aColsGrid[nX], aVolumes[nX, 02]['PESOTARA'])
                    endif
                endif
                if ValType(aVolumes[nX, 02]:GetJsonObject('VOLUMES')) <> 'U'
                    for nY := 1 to len(aVolumes[nX, 02]['VOLUMES'])
                        if aVolumes[nX, 02]['VOLUMES'][nY, 01] == 'G'
                            aTemp := aVolumes[nX, 02]['VOLUMES'][nY, 03]
                            for nZ := 1 to len(aTemp)
                                if aTemp[nZ, 01] == 'R'
                                    aColsGrid[nX,09] += aTemp[nZ, 04]
                                elseif aTemp[nZ, 01] == 'C' .or. aTemp[nZ, 01] == 'M'
                                    aColsGrid[nX,05] += aTemp[nZ, 04]
                                elseif aTemp[nZ, 01] == 'L'
                                    aColsGrid[nX,08] += aTemp[nZ, 04]
                                elseif aTemp[nZ, 01] == 'B'
                                    aColsGrid[nX,06] += aTemp[nZ, 04]
                                endif
                            next nZ
                        elseif aVolumes[nX, 02]['VOLUMES'][nY, 01] == 'F'
                            aColsGrid[nX,04] += aVolumes[nX, 02]['VOLUMES'][nY, 04]
                        elseif aVolumes[nX, 02]['VOLUMES'][nY, 01] == 'P'
                            aColsGrid[nX,07] += aVolumes[nX, 02]['VOLUMES'][nY, 04]
                        endif
                    next nY
                endif
            endif
        next nX
    endif
    if oGrid <> nil
        oGrid:SetArray(aColsGrid)
        oGrid:Refresh()
    endif
return(nil)

static function findOSCli(cOS, cFili)
    local oSql      := nil
    local cCli      := ""
    Local oStatic   := IfcXFun():newIfcXFun()
    default cFili   := xFilial("ZZR")
    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'qryGetCli', cOS, cFili))
    if oSql:hasRecords()
        oSql:goTop()
        cCli := oSql:getValue('CLI')
    endif
    oSql:close()
    FreeObj(oSql)
return(cCli)

static function findOSNF(cOS)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local oSql      := nil
    local cNF       := ''
    Local oStatic   := IfcXFun():newIfcXFun()
    default cFili   := ''

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'getRegs',,cOS))
    if oSql:hasRecords()
        oSql:goTop()
        DbSelectArea('ZZ9')
        ZZ9->(DbGoTo(oSql:getValue('REC')))
        cNF := AllTrim(ZZ9->ZZ9_DOC)+ iif(!empty(ZZ9->ZZ9_DOC), ' / ', '') + AllTrim(ZZ9->ZZ9_SERIE)
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaZZ9)
    RestArea(aArea)
return(cNF)

static function export(cCarga, aMyVol)
    local oFWMsExcel := nil
    local nX		 := 1
    local oExcel	 := nil
    Local oStatic    := IfcXFun():newIfcXFun()
    local aVol       := oStatic:sP(2):callStatic('cbcManifesto', 'getVol', cCarga, aMyVol)
    local aTotais    := {}
    local aDets      := {}
    local cNomArqv   := GetTempPath() + 'PlanFATUR_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'

    //Carregar Dados
    oStatic:sP(4):callStatic('cbcManifesto', 'mntDados', 'RES', nil, @aTotais,   aVol)
    oStatic:sP(4):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aDets,     aVol)

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Resumo")
    oFWMsExcel:AddTable("Resumo","TOTAIS")
    oFWMsExcel:AddColumn("Resumo","TOTAIS","FAR",1)
    oFWMsExcel:AddColumn("Resumo","TOTAIS","CAR",1)
    oFWMsExcel:AddColumn("Resumo","TOTAIS","BOB",1)
    oFWMsExcel:AddColumn("Resumo","TOTAIS","PAL",1)
    oFWMsExcel:AddColumn("Resumo","TOTAIS","CXS",1)
    oFWMsExcel:AddColumn("Resumo","TOTAIS","ROLOS",1)
    oFWMsExcel:AddColumn("Resumo","TOTAIS","PESO",1)

    for nX := 1 to len(aTotais)
        oFWMsExcel:AddRow("Resumo","TOTAIS", aTotais[nX])
    next nX
    oFWMsExcel:AddworkSheet("Detalhes")
    oFWMsExcel:AddTable("Detalhes","Detalhes")
    oFWMsExcel:AddColumn("Detalhes","Detalhes","NF",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","OS",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","Cliente",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","FAR",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","CAR",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","BOB",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","PAL",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","CXS",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","ROLOS",1)
    oFWMsExcel:AddColumn("Detalhes","Detalhes","PESO",1)
    
    for nX := 1 to len(aDets)
        oFWMsExcel:AddRow("Detalhes","Detalhes", aDets[nX])
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
