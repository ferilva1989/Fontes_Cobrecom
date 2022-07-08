#include 'Totvs.ch'

user function cbcEndProd()
    private lReload := .T.

    while lReload
        //iniciar View
        FWMsgRun(, { || initView() }, 	"Verticalização Produção", "Iniciando...")
    endDo
return(nil)

static function initView()
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oDlg        := nil
    private oPnl        := nil
    private oFont	    := TFont():New("Arial",,15,,.F.)
    private oCtrl       := ctrlEndProd():newctrlEndProd()
    private aRefList    := {}
    private oTreePad    := nil
    private oGrid       := nil
    private oGrpGrid    := nil
    private oGrpCtrl    := nil
    private oGrpDet     := nil
    private oBtnAdicio  := nil
    private oBtnExclui  := nil
    private oBtnLimpa   := nil
    private oBtnImpri   := nil
    private oBtnFecha   := nil
    private oSayUniMov  := nil
    private oSayProd    := nil
    private oSayQtd     := nil
    private oSayData    := nil
    private oSayHora    := nil
    private oSayLote    := nil
    private aHeader     := {}
    private aColsGrid   := {}
    private aListEnd    := {}
    private aListEst    := {}

    //Componentes Visuais
    DEFINE MSDIALOG oDlg TITLE 'Verticalização de Produção' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oPnl := TPanel():New( ,,, oDlg)
    oPnl:Align := CONTROL_ALIGN_ALLCLIENT
    oGrpGrid:= TGroup():New(003, (aCoors[4]/4)+2, (aCoors[3]*0.33) - 2, /*(aCoors[4]/4)-4*/(((aCoors[4]/4)-4) * 2),'',oPnl,,,.T.)
    oGrpCtrl:= TGroup():New((aCoors[3]*0.328), 003, (aCoors[3]*0.475), /*(aCoors[4]/4)-4*/((aCoors[4]/4)-4),'Controles',oPnl,,,.T.)
    oGrpDet:= TGroup():New((aCoors[3]*0.328), (aCoors[4]/4)+2, (aCoors[3]*0.475), /*(aCoors[4]/4)-4*/(((aCoors[4]/4)-4) * 2),'Detalhes Unimov',oPnl,,,.T.)
    oDlg:lMaximized := .T.
    
    FWMsgRun(, { || controles() }, 	    "Controles", "Carregando...")
    FWMsgRun(, { || mntEnderecos() },   "Enderecos", "Carregando...")
    FWMsgRun(, { || mntTree() }, 	    "Tree",      "Carregando...")
    FWMsgRun(, { || mntBrw() }, 	    "Grid",      "Carregando...")

    Activate MsDialog oDlg Center

    FreeObj(oSayUniMov)
    FreeObj(oSayProd)
    FreeObj(oSayQtd)
    FreeObj(oSayData)
    FreeObj(oSayHora)
    FreeObj(oSayLote)
    FreeObj(oBtnAdicio)
    FreeObj(oBtnExclui)
    FreeObj(oBtnLimpa)
    FreeObj(oBtnImpri)
    FreeObj(oBtnFecha)
    FreeObj(oCtrl)
    FreeObj(oTreePad)
    FreeObj(oGrid)
    FreeObj(oFont)
    FreeObj(oPnl)
    FreeObj(oDlg)
return(nil)

static function controles()
    oBtnAdicio  := TButton():New((aCoors[3]*0.328) + 10,05, 'Adiconar', oGrpCtrl , {|| adicionaEnder()},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnAdicio, 'CONFIRM')
    oBtnExclui  := TButton():New((aCoors[3]*0.328) + 10,90, 'Deletar',  oGrpCtrl , {|| deletaEnder()},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnExclui, 'CONFIRM')
    oBtnLimpa   := TButton():New((aCoors[3]*0.328) + 40,05, 'Limpar',   oGrpCtrl , {|| FWMsgRun(, { || limpaFiltro()}, "Filtro", "Limpando...")},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnLimpa, 'CONFIRM')
    oBtnImpri   := TButton():New((aCoors[3]*0.328) + 40,90, 'Exportar', oGrpCtrl , {|| FWMsgRun(, { || exportar()}, "Exporta Planilha", "Exportando...")},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnImpri, 'CONFIRM')
    oBtnFecha   := TButton():New((aCoors[3]*0.328) + 70,05, 'Fechar',   oGrpCtrl , {|| lReload := .F., oDlg:End()},160,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnFecha, 'FECHAR')
return(nil)

static function mntEnderecos()
    local nPos,nRua, nPrat, nNivel, nX  := 0

    //Criando o DbTree
    aListEnd := oCtrl:listaEnder()
    aListEst := oCtrl:listaInEnder()

    for nX := 1 to len(aListEnd)
        if (aListEnd[nX, 02] == .T.)
            nRua := aScan(aRefList, {|x| x[1] == SubStr(AllTrim(aListEnd[nX,01]),1,1)})
            if empty(nRua)
                aAdd(aRefList, {SubStr(AllTrim(aListEnd[nX,01]),1,1),; //Rua
                                {{SubStr(AllTrim(aListEnd[nX,01]),2,3),; //Prateleira
                                {{SubStr(AllTrim(aListEnd[nX,01]),5,1),; //Nivel
                                {{SubStr(AllTrim(aListEnd[nX,01]),6,2),aListEnd[nX,01]}},; //Posicao
                                }}}}})//Endereco
            else
                nPrat := aScan(aRefList[nRua,02], {|x| x[1] == SubStr(AllTrim(aListEnd[nX,01]),2,3)})
                if empty(nPrat)
                    aAdd(aRefList[nRua,02], {SubStr(AllTrim(aListEnd[nX,01]),2,3),; //Prateleira
                                {{SubStr(AllTrim(aListEnd[nX,01]),5,1),; //Nivel
                                {{SubStr(AllTrim(aListEnd[nX,01]),6,2),aListEnd[nX,01]; //Posicao
                                }}}}})//Endereco
                else
                    nNivel := aScan(aRefList[nRua,02,nPrat,02], {|x| x[1] == SubStr(AllTrim(aListEnd[nX,01]),5,1)})
                    if empty(nNivel)
                        aAdd(aRefList[nRua,02,nPrat,02], {SubStr(AllTrim(aListEnd[nX,01]),5,1),; //Nivel
                                    {{SubStr(AllTrim(aListEnd[nX,01]),6,2),aListEnd[nX,01]; //Posicao
                                    }}})//Endereco
                    else
                        nPos := aScan(aRefList[nRua,02,nPrat,02,nNivel, 02], {|x| x[1] == SubStr(AllTrim(aListEnd[nX,01]),6,2)})
                        if empty(nPos)
                            aAdd(aRefList[nRua,02,nPrat,02,nNivel,02],{SubStr(AllTrim(aListEnd[nX,01]),6,2),aListEnd[nX,01]; //Posicao
                                        })//Endereco
                        endif
                    endif
                endif
            endif
        else
            aAdd(aRefList, {"",; //Rua
                            {{"",; //Prateleira
                            {{"",; //Nivel
                            {{"",aListEnd[nX,01]; //Posicao
                            }}}}}}})//Endereco
        endif
    next nX
return(nil)

static function mntTree()
    local nX,nZ,nY,nT  := 0
    local aCollapse    := {{},{},{},{},{}}

    oTreePad := dbTree():New(003,003,(aCoors[3]/2)-150,(aCoors[4]/4)-1,oPnl,{|| .T.},,.T.)
    oTreePad:Reset()
    oTreePad:SetScroll(1,.T.) //Habilita barra de rolagem horizontal
    oTreePad:SetScroll(2,.T.) //Habilita barra de rolagem vertical
    oTreePad:BldBlClick := { || filterGrid()}
    for nX := 1 to len(aRefList)
        if aRefList[nX, 01] == ""
            oTreePad:AddTree("Avulso: " + aRefList[nX,02,01,02,01,02,01,02]+Space(50),.F., "DESTINOS", "DESTINOS",,,(aRefList[nX,02,01,02,01,02,01,02]+Space(10-Len(aRefList[nX,02,01,02,01,02,01,02]))))
            estoque((aRefList[nX,02,01,02,01,02,01,02]+Space(10-Len(aRefList[nX,02,01,02,01,02,01,02]))))
            oTreePad:EndTree()
            oTreePad:TreeSeek((aRefList[nX,02,01,02,01,02,01,02]+Space(10-Len(aRefList[nX,02,01,02,01,02,01,02]))))
            //oTreePad:PtCollapse()
            aAdd(aCollapse[04],(aRefList[nX,02,01,02,01,02,01,02]+Space(10-Len(aRefList[nX,02,01,02,01,02,01,02]))))
        else
            //oTreePad:AddItem("Rua: " + aRefList[nX, 01]+Space(50),aRefList[nX, 01], "DESTINOS", "DESTINOS",,,1)
            oTreePad:AddTree("Rua: " + aRefList[nX, 01]+Space(50),.F., "DESTINOS", "DESTINOS",,,(aRefList[nX, 01]+Space(10-Len(aRefList[nX, 01]))))
            if oTreePad:TreeSeek((aRefList[nX, 01]+Space(10-Len(aRefList[nX, 01]))))
                for nY := 1 to len(aRefList[nX, 02])
                    //oTreePad:AddItem("Prateleira: " + aRefList[nX, 02, nY, 01]+Space(50), aRefList[nX, 01] + aRefList[nX, 02, nY, 01], "RPMCPO_MDI", "RPMCPO_MDI",,,2)
                    oTreePad:AddTree("Prateleira: " + aRefList[nX, 02, nY, 01]+Space(50),.F., "RPMCPO_MDI", "RPMCPO_MDI",,,aRefList[nX, 01] + aRefList[nX, 02, nY, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01])))
                    if oTreePad:TreeSeek(aRefList[nX, 01] + aRefList[nX, 02, nY, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01])))
                        for nZ := 1 to len(aRefList[nX, 02, nY, 02])
                            //oTreePad:AddItem("Nivel: " + aRefList[nX, 02, nY, 02, nZ, 01]+Space(50),aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01], "PMSUPDOWN_MDI","PMSUPDOWN_MDI",,,3)
                            oTreePad:AddTree("Nivel: " + aRefList[nX, 02, nY, 02, nZ, 01]+Space(50),.F., "PMSUPDOWN_MDI", "PMSUPDOWN_MDI",,,aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01])))
                            if oTreePad:TreeSeek(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01])))
                                for nT := 1 to len(aRefList[nX, 02, nY, 02, nZ, 02])
                                    //oTreePad:AddItem("Pos: " + aRefList[nX, 02, nY, 02, nZ, 02, nT, 01],aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01], "FOLDER5","FOLDER6",,,2)
                                    oTreePad:AddTree("Posicao: " + aRefList[nX, 02, nY, 02, nZ, 02, nT, 01]+Space(50),.F., "QIPIMG32_MDI", "QIPIMG32_MDI",,,aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01])))
                                    estoque(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01])))
                                    oTreePad:EndTree()
                                    oTreePad:TreeSeek(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01])))
                                    aAdd(aCollapse[01], aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+aRefList[nX, 02, nY, 02, nZ, 02, nT, 01])))
                                    //oTreePad:PtCollapse()
                                    oTreePad:TreeSeek(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01])))
                                next nT
                            endif
                            aAdd(aCollapse[02], aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01] + aRefList[nX, 02, nY, 02, nZ, 01])))
                            //oTreePad:PtCollapse()
                            oTreePad:EndTree()
                            oTreePad:TreeSeek(aRefList[nX, 01] + aRefList[nX, 02, nY, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01])))
                        next nX
                    endif
                    aAdd(aCollapse[03], aRefList[nX, 01] + aRefList[nX, 02, nY, 01]+Space(10-Len(aRefList[nX, 01] + aRefList[nX, 02, nY, 01])))
                    //oTreePad:PtCollapse()
                    oTreePad:EndTree()
                    oTreePad:TreeSeek((aRefList[nX, 01]+Space(10-Len(aRefList[nX, 01]))))
                next nY
            endif
            //oTreePad:PtCollapse()
            aAdd(aCollapse[04], (aRefList[nX, 01]+Space(10-Len(aRefList[nX, 01]))))
            oTreePad:EndTree()
            oTreePad:TreeSeek((aRefList[nX, 01]+Space(10-Len(aRefList[nX, 01]))))
            //oTreePad:PtCollapse()
        endif        
    next nX
    for nX := 1 to len(aCollapse)
        for nY := 1 to len(aCollapse[nX])
            oTreePad:TreeSeek(aCollapse[nX,nY])
            oTreePad:PtCollapse()
        next nY
    next nX
    //oTreePad:EndTree()
    oTreePad:Refresh()
return(nil)

static function estoque(cChv)
    local nX, nY := 0

    nX := aScan(aListEst, {|x| AllTrim(x[1]) == AllTrim(cChv)})
    if (nX > 0)
        for nY := 1 to len(aListEst[nX,02])
            oTreePad:AddTreeItem("UniMov: " + aListEst[nX,02,nY,01]+Space(50),  "CONTAINR",,aListEst[nX,02,nY,01]+Space(10-Len(aListEst[nX,02,nY,01])))
            oTreePad:TreeSeek(aListEst[nX,02,nY,01]+Space(10-Len(aListEst[nX,02,nY,01])))
            oTreePad:PtCollapse()
            oTreePad:TreeSeek(cChv)
        next nY
    endif
    oTreePad:TreeSeek(cChv)
return(nil)

static function mntBrw(cFilter)
    default cFilter := ""
    oGrid := FWBrowse():New()
    aHeader     := {}
    aColsGrid   := {}
    mntHeader()
    oGrid:SetSeek()
    oGrid:SetFontBrowse(oFont)
    oGrid:SetDataArray()
    oGrid:SetTypeMove(0)
    oGrid:lHeaderClick := .F.
    oGrid:SetColumns(aHeader)
    oGrid:SetArray(aColsGrid)
    oGrid:SetOwner(oGrpGrid)
    oGrid:SetChange({ || detMovUn('UNDO')})
    oGrid:SetDoubleClick({|| FWMsgRun(, {|| detMovUn('DO', oGrid:oData:aArray[oGrid:At(), 6])},'Detalhes Unimov','carregando...')})
    oGrid:SetSeek(, {{"Endereco" ,{{"","C",;
        50, 0,"Endereco", "", "Endereco"}}, 1},;
        {"Unimov" ,{{"",GetSx3Cache('D3_ZZUNMOV', 'X3_TIPO'),;
        50, 0,"Unimov", PesqPict('SD3', 'D3_ZZUNMOV'), "Unimov"}},2},;
        {"Produto" ,{{"",GetSx3Cache('B1_DESC', 'X3_TIPO'),;
        50, 0,"Produto", PesqPict('SB1', 'B1_DESC'), "Produto"}},2}})
    mntDados(cFilter)
    oGrid:Activate()
return(nil)

static function mntHeader()
    local aHeaderAux := {}
    local nAtual     := 0
    local cGrid      := 'oGrid'
    
    aHeader := {}
    aAdd(aHeaderAux, {"Rua",       "C", 01, 0, ""})
    aAdd(aHeaderAux, {"Prateleira","C", 03, 0, ""})
    aAdd(aHeaderAux, {"Nivel",     "C", 01, 0, ""})
    aAdd(aHeaderAux, {"Posicao",   "C", 02, 0, ""})
    aAdd(aHeaderAux, {"Endereco",  "C", 10, 0, ""})
    aAdd(aHeaderAux, {"Unimov",    "C", 10, 0, ""})
    aAdd(aHeaderAux, {"Produto",  GetSx3Cache('B1_DESC','X3_TIPO'),TamSx3('B1_DESC')[1], 0, PesqPict('SB1', 'B1_DESC')})
    aAdd(aHeaderAux, {"Quant",    "N", 20, 4, ""})
    aAdd(aHeaderAux, {"Operador",  GetSx3Cache('RA_CRACHA','X3_TIPO'),TamSx3('RA_CRACHA')[1], 0, PesqPict('SRA', 'RA_CRACHA')})
    aAdd(aHeaderAux, {"Inventario","C", 10, 0, ""})
    
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

static function mntDados(cFilter)
    local nX, nY    := 0
    local aDet      := {}
    default cFilter := ""
    //Zera a grid
    aColsGrid := {}
    for nX := 1 to len(aListEst)
        if empty(cFilter) .or. len(cFilter) > 7 .or. (len(cFilter) <= 7 .and. cFilter $ AllTrim(aListEst[nX,01]))
            for nY := 1 to len(aListEst[nX, 02])
                nPos := aScan(aListEnd, {|x| AllTrim(x[1]) == AllTrim(aListEst[nX, 01])})
                if nPos > 0
                    if empty(cFilter) .or. len(cFilter) <= 7 .or. (len(cFilter) > 7 .and. cFilter $ AllTrim(aListEst[nX, 02, nY,01]))
                        aDet := detMovUn('PROD', aListEst[nX, 02, nY,01])
                        aAdd(aColsGrid,{iif(aListEnd[nPos, 02], SubStr(AllTrim(aListEst[nX,01]),1,1), ""),; //Rua
                                        iif(aListEnd[nPos, 02], SubStr(AllTrim(aListEst[nX,01]),2,3),""),; //Prateleira
                                        iif(aListEnd[nPos, 02], SubStr(AllTrim(aListEst[nX,01]),5,1),""),; //Nivel
                                        iif(aListEnd[nPos, 02], SubStr(AllTrim(aListEst[nX,01]),6,2),""),; //Posicao
                                        AllTrim(aListEst[nX,01]),;//Endereco
                                        tiraZeros(aListEst[nX, 02, nY,01]),; //Unimov
                                        aDet[1],;//Produto
                                        aDet[2],;//Quantidade
                                        aListEst[nX, 02, nY,02],; //Operador
                                        iif(aListEst[nX, 02, nY,03]==nil,"",Substr(aListEst[nX, 02, nY,03],9,2)+"/"+Substr(aListEst[nX, 02, nY,03],6,2)+"/"+Substr(aListEst[nX, 02, nY,03],1,4)); //Inventario
                                        })
                    endif
                endif
            next nY
        endif
    next nX
    oGrid:SetArray(aColsGrid)
    oGrid:Refresh()
return(nil)

static function filterGrid(cCargo)
    default cCargo := AllTrim(oTreePad:GetCargo())
    
    if oGrid <> nil
        oGrid:DeActivate()
        FreeObj(oGrid)
        oGrpGrid:FreeChildren()
        mntBrw(AllTrim(cCargo))
        oGrid:SetFocus()
    endif
return(nil)

static function limpaFiltro()
    filterGrid("")
    detMovUn('UNDO')
return(nil)

static function detMovUn(cOpc, cUniMov)
    local oJson     := JsonObject():new()
    local xRet      := ""
    default lMostra := .T.
    default cUniMov := ""

    if cOpc == 'DO'
        oJson := oCtrl:detUnMov(cUniMov)
        if !empty(oJson:GetNames())
            if oSayUniMov <> nil
                detMovUn('UNDO')
            endif
            oSayUniMov  := TSay():New((aCoors[3]*0.328) + 010,(aCoors[4]/4)+ 10,{||'Unimov: '+ cValToChar(oJson['Unimov'])}, oGrpDet,,oFont,,,,.T.,,, (((aCoors[4]/4)-4) * 2), 35)
            applyCss(@oSayUniMov,'PEQ')
            oSayProd  := TSay():New((aCoors[3]*0.328) + 030,(aCoors[4]/4)+ 10,	{||'Produto: '+ cValToChar(oJson['Produto']) + ' - ' + cValToChar(oJson['Descricao'])}, oGrpDet,,oFont,,,,.T.,,, (((aCoors[4]/4)-4) * 2), 35)
            applyCss(@oSayProd,'PEQ')
            oSayQtd  := TSay():New((aCoors[3]*0.328) + 050,(aCoors[4]/4)+ 10,	{||'Quantidade: '+ cValToChar(oJson['Quant'])}, oGrpDet,,oFont,,,,.T.,,, (((aCoors[4]/4)-4) * 2), 35)
            applyCss(@oSayQtd,'PEQ')
            oSayData  := TSay():New((aCoors[3]*0.328) + 070,(aCoors[4]/4)+ 10,	{||'Data: '+ DtoC(StoD(cValToChar(oJson['Data'])))}, oGrpDet,,oFont,,,,.T.,,, (((aCoors[4]/4)-4) * 2), 35)
            applyCss(@oSayData,'PEQ')
            oSayHora  := TSay():New((aCoors[3]*0.328) + 090,(aCoors[4]/4)+ 10,	{||'Hora: '+ cValToChar(oJson['Hora'])}, oGrpDet,,oFont,,,,.T.,,, (((aCoors[4]/4)-4) * 2), 35)
            applyCss(@oSayHora,'PEQ')
            oSayLote  := TSay():New((aCoors[3]*0.328) + 110,(aCoors[4]/4)+ 10,	{||'Lote: '+ cValToChar(oJson['Lote'])}, oGrpDet,,oFont,,,,.T.,,, (((aCoors[4]/4)-4) * 2), 35)
            applyCss(@oSayLote,'PEQ')
        else
            MsgAlert('Unimov não localizada para carregar detalhes!', 'Sem Detalhes')
        endif
    elseif cOpc == 'PROD'
        xRet := {}
        oJson := oCtrl:detUnMov(cUniMov)
        if !empty(oJson:GetNames())
           xRet := {AllTrim(cValToChar(oJson['Produto']))+ ' - ' + AllTrim(cValToChar(oJson['Descricao'])), oJson['Quant']}
        endif
    else
        FreeObj(oSayUniMov)
        FreeObj(oSayProd)
        FreeObj(oSayQtd)
        FreeObj(oSayData)
        FreeObj(oSayHora)
        FreeObj(oSayLote)
    endif
return(xRet)

static function deletaEnder()
    local oModal 		:= nil
	local oGetModal	    := nil
    local oPnlModal 	:= nil
    local cEnder        := Space(7)
    local lRet          := .F.

	oModal := FWDialogModal():New() 
	oModal:setSize(150,300)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Excluir Endereço')
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oModal:addOkButton({|| lRet:=.T., oModal:DeActivate()}, "Confirma", {||.T.} )
	oPnlModal := TPanel():New( ,,, oModal:getPanelMain() ) 
	oPnlModal:SetCss("")
	oPnlModal:Align := CONTROL_ALIGN_ALLCLIENT

    oGetModal := TGet():New(40,05, { | u | If( PCount() == 0, cEnder,cEnder:= u ) },oPnlModal,290,030,"@!", {||.T.},0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cEnder,,,, )
    applyCss(@oGetModal)
    applyCss(@oModal:oSayTitle, 'MODAL')
   	applyCss(@oModal:oTop)

    oModal:Activate()

    if lRet
        if (lRet := MsgYesNo('Confirma a exclusão do endereço?','Confirmar'))
            lRet := oCtrl:bloqEnder(Upper(AllTrim(cEnder))):isOk()
            if (lRet)
                MsgInfo('Endereço excluido com sucesso','Sucesso')
            endif
        endif
    endif
    FreeObj(oGetModal)
    FreeObj(oPnlModal)
    FreeObj(oModal)
    if lRet
        lReload := .T.
        oDlg:End()
    endif
return(nil)

static function adicionaEnder()
    local lRet          := .F.
    private nOpc        := 1 
    private oModal 		:= nil
	private oGetModal	:= nil
    private oGetRua	    := nil
    private oGetPrat	:= nil
    private oGetNivel	:= nil
    private oGetPosi	:= nil
    private oPnlModal 	:= nil
    private oBtnNivel   := nil
    private oBtnAvul    := nil
    private oSayMRua    := nil
    private oSayMPrat   := nil
    private oSayMNive   := nil
    private oSayMPosi   := nil
    private oSayModal   := nil
    private cMEnder      := Space(7)
    private cMRua       := Space(1)
    private cMPRat      := Space(3)
    private cMNivel     := Space(1)
    private cMPosi      := Space(2)

	oModal := FWDialogModal():New() 
	oModal:setSize(150,300)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Adicionar Endereço')
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oModal:addOkButton({|| lRet:=.T., oModal:DeActivate()}, "Confirma", {||.T.} )
	oPnlModal := TPanel():New( ,,, oModal:getPanelMain() ) 
	oPnlModal:SetCss("")
	oPnlModal:Align := CONTROL_ALIGN_ALLCLIENT

    oBtnNivel := TButton():New(02,02, 'Nivel',oPnlModal , {|| TrocaOpc(1)},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnAvul  := TButton():New(02,82, 'Avulso',oPnlModal , {|| TrocaOpc(2)},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oModal:oSayTitle, 'MODAL')
   	applyCss(@oModal:oTop)
    TrocaOpc(1)    
    oModal:Activate()

    if lRet
        if nOpc == 1
            cMEnder := Upper(AllTrim(cMRua) + AllTrim(cMPRat) + AllTrim(cMNivel) + AllTrim(cMPosi))
        endif
        if (lRet :=(len(AllTrim(cMEnder)) == 7))
            if (lRet :=MsgYesNo('Confirma a inclusao do endereço?','Confirmar'))
                cMEnder := Upper(cMEnder)
                lRet    := oCtrl:addEnder(AllTrim(cMEnder), (nOpc == 1)):isOk()
                if (lRet)
                    MsgInfo('Endereço adicionado com sucesso','Sucesso')
                endif
            endif
        else
            Alert('Endereço Inválida! [Tamanho = 7]')
        endif
    endif

    FreeObj(oSayModal)
    FreeObj(oSayMRua)
    FreeObj(oSayMPrat)
    FreeObj(oSayMNive)
    FreeObj(oSayMPosi)
    FreeObj(oGetRua)
    FreeObj(oGetPrat)
    FreeObj(oGetNivel)
    FreeObj(oGetPosi)
    FreeObj(oBtnNivel)
    FreeObj(oBtnAvul)
    FreeObj(oGetModal)
    FreeObj(oPnlModal)
    FreeObj(oModal)
    if lRet
        lReload := .T.
        oDlg:End()
    endif
return(nil)

static function TrocaOpc(nPar)
    nOpc := nPar
    resetOpc()
    if nOpc == 1
        oSayMRua := TSay():New(44,05,	{||'Rua:'}, oPnlModal,,oFont,,,,.T.,,,050,030)
        applyCss(@oSayMRua,'PEQ')
        oSayMPrat := TSay():New(44,155,	{||'Prateleira:'}, oPnlModal,,oFont,,,,.T.,,,050,030)
        applyCss(@oSayMPrat,'PEQ')
        oSayMNive := TSay():New(84,05,	{||'Nível:'}, oPnlModal,,oFont,,,,.T.,,,050,030)
        applyCss(@oSayMNive,'PEQ')
        oSayMPosi := TSay():New(84,155,	{||'Posição:'}, oPnlModal,,oFont,,,,.T.,,,050,030)
        applyCss(@oSayMPosi,'PEQ')
        oGetRua     := TGet():New(32,55, { | u | If( PCount() == 0, cMRua,cMRua:= u ) },oPnlModal,90,030,"@!", {||.T.},0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMRua/*,,,,,,,'Rua' */)
        oGetPrat    := TGet():New(32,205, { | u | If( PCount() == 0, cMPRat,cMPRat:= u ) },oPnlModal,90,030,"@!", {||.T.},0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMPRat/*,,,,,,,'Prateleira' */)
        oGetNivel   := TGet():New(72,55, { | u | If( PCount() == 0, cMNivel,cMNivel:= u ) },oPnlModal,90,030,"@!", {||.T.},0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMNivel/*,,,,,,,'Nível' */)
        oGetPosi    := TGet():New(72,205, { | u | If( PCount() == 0, cMPosi,cMPosi:= u ) },oPnlModal,90,030,"@!", {||.T.},0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMPosi/*,,,,,,,'Posição' */)
        applyCss(@oGetRua)
        applyCss(@oGetPrat)
        applyCss(@oGetNivel)
        applyCss(@oGetPosi)
        applyCss(@oBtnNivel, 'CONFIRM')
        applyCss(@oBtnAvul, 'FECHAR')
    else
        oSayModal   := TSay():New(44,05,	{||'Endereço:'}, oPnlModal,,oFont,,,,.T.,,,050,030)
        applyCss(@oSayModal,'PEQ')
        oGetModal   := TGet():New(32,055, { | u | If( PCount() == 0, cMEnder,cMEnder:= u ) },oPnlModal,240,030,"@!", {||.T.},0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMEnder/*,,,,,,,'Endereço' */)
        applyCss(@oGetModal)
        applyCss(@oBtnNivel, 'FECHAR')
        applyCss(@oBtnAvul, 'CONFIRM')
    endif
return(nil)

static function resetOpc()
    FreeObj(oSayModal)
    FreeObj(oSayMRua)
    FreeObj(oSayMPrat)
    FreeObj(oSayMNive)
    FreeObj(oSayMPosi)
    FreeObj(oGetRua)
    FreeObj(oGetPrat)
    FreeObj(oGetNivel)
    FreeObj(oGetPosi)
    FreeObj(oGetModal)
    cMEnder     := Space(7)
    cMRua       := Space(1)
    cMPRat      := Space(3)
    cMNivel     := Space(1)
    cMPosi      := Space(2)
return(nil)

static function exportar()
    local oFWMsExcel := nil
    local oExcel	 := nil
    local cNomArqv   := GetTempPath() + 'PlanEndProd_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local nX         := 0

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Producao")
    oFWMsExcel:AddTable("Producao","Enderecos")
    oFWMsExcel:AddColumn("Producao","Enderecos","Rua",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Prateleira",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Nivel",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Posicao",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Endereco",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Unimov",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Produto",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Quantidade",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Operador",1)
    oFWMsExcel:AddColumn("Producao","Enderecos","Inventario",1)

    for nX := 1 to len(oGrid:oData:aArray)
        oFWMsExcel:AddRow("Producao","Enderecos", AClone(oGrid:oData:aArray[nX]))
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

static function tiraZeros(cTexto)
    local cRet      := ""
    local lContinua := .T.
    default cTexto  := ""

    cRet := Alltrim(cTexto)
    while lContinua
        if SubStr(cRet, 1, 1) <> "0" .Or. Len(cRet) ==0
            lContinua := .F.
        endif
        if lContinua
            cRet := Substr(cRet, 2, Len(cRet))
        endif
    endDo
return(cRet)

static function applyCss(oObj, cOpc)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
	default cOpc    := ''
	if cTpObj == "TBUTTON"
        if cOpc == 'CONFIRM'
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #FFFFFF; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 25px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #022c73, stop: 1 #2055b0); /*Cor de fundo*/";
                                +"  min-width: 20px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #2055b0 stop: 1 #022c73);";
                                +"}"
        else
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #FFFFFF; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 25px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #525252, stop: 1 #626363); /*Cor de fundo*/";
                                +"  min-width: 20px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #626363 stop: 1 #525252);";
                                +"}"
        endif
	elseif cTpObj == "TSAY"
            if cOpc == 'PEQ'
                cCss +=	"QLabel { ";
                            +"  font-size: 15px; /*Tamanho da fonte*/";
                            +"  color: #00297c; /*Cor da fonte*/";
                            +"  font-weight: bold; /*Negrito*/";
                            +"  text-align: center; /*Alinhamento*/";
                            +"  vertical-align: middle; /*Alinhamento*/";
                            +"  border-radius: 6px; /*Arrerondamento da borda*/";
                            +"}"
            elseif cOpc == 'MODAL'
                cCss +=	"QLabel { ";
                            +"  font-size: 15px; /*Tamanho da fonte*/";
                            +"  color: #FFFFFF; /*Cor da fonte*/";
                            +"  font-weight: bold; /*Negrito*/";
                            +"  text-align: center; /*Alinhamento*/";
                            +"  vertical-align: middle; /*Alinhamento*/";
                            +"  border-radius: 6px; /*Arrerondamento da borda*/";
                            +"}"
            else
                cCss +=	"QLabel { ";
                            +"  font-size: 35px; /*Tamanho da fonte*/";
                            +"  color: #00297c; /*Cor da fonte*/";
                            +"  font-weight: bold; /*Negrito*/";
                            +"  text-align: center; /*Alinhamento*/";
                            +"  vertical-align: middle; /*Alinhamento*/";
                            +"  border-radius: 6px; /*Arrerondamento da borda*/";
                            +"}"
            endif
    elseif cTpObj == "TMULTIGET"
			cCss +=	"QTextEdit { ";
						+"  font-size: 35px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
    elseif cTpObj == "TGET"
			cCss +=	"QLineEdit { ";
						+"  font-size: 25px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
                        +"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
	elseif cTpObj == "TPANEL"
			cCss +=	 "QFrame {";
								+" color: #FFFFFF; /*Cor da fonte*/ ";
								+" background-color: #00297c;";	
								+" border: 2px solid #00297c; /*Cor da borda*/";	  						
		  						+" border-radius: 6px; /*Arrerondamento da borda*/ ";
		                      +" } "
    elseif cTpObj == "TGROUP"
			cCss +=	 "QGroupBox {";
								+" color: #FFFFFF; /*Cor da fonte*/ ";
								+" border: 2px solid #00297c; /*Cor da borda*/";	  						
		  						+" border-radius: 6px; /*Arrerondamento da borda*/ ";
                                +" font-size: 25px; /*Tamanho da fonte*/";
                                +" font-weight: bold; /*Negrito*/";
		                        +" } ";
                                +" QGroupBox::title  { ";
                                +"     subcontrol-origin: margin; ";
                                +"     subcontrol-position: top center; ";
                                +"     padding: 5px 8000px 5px 8000px; ";
                                +"     background-color: #00297c; ";
                                +"     color: rgb(255, 255, 255); ";
                                +" } "
    elseif cTpObj == "TCOMBOBOX"
			cCss +=	"QComboBox { ";
						+"  font-size: 25px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
                        +"  background-color: #FFFFFF;";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
                        +"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
    elseif cTpObj == "TRADMENU"
			cCss +=	"QRadioButton { ";
						+"  font-size: 35px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"}"
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)

