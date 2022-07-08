#Include "Totvs.ch"
user function viewTesIntel()
    /*
    // Chamando CursorArrow() força a CursorWait() mostrar o cursor de ampulheta sempre.
    CursorArrow()
    CursorWait()
    */
    // iniciar View
    FWMsgRun(, { || initView() }, 	"TES Inteligente", "Iniciando...")
return(nil)

static function initView()
    local lCloseButt 	:= !(oAPP:lMdi)
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oTes        := ctrlTesIntel():newctrlTesIntel()
    private oDlg        := nil
    private oFont	    := TFont():New("Arial",,15,,.F.)
    private oFWLayer    := nil
    private oPnlLOper   := nil
    private oPnlLTes    := nil
    private oPnlROper   := nil
    private oPnlRTes    := nil
    private oPnlRules   := nil
    private oBtnOper	:= nil
    private oBtnPar	    := nil
    private oBtnTes     := nil
    private oBtnFim		:= nil
    private oBrwOper    := nil
    private oBrwTes     := nil
    private oBtnAdd     := nil
    private oBtnEdit    := nil
    private oBtnDel     := nil
    private oBtnUp      := nil
    private oBtnDwn     := nil
    
    DbSelectArea('SFM')
    SFM->(DBOrderNickName('ZZFMORDEM'))

    // Componentes Visuais
    DEFINE MSDIALOG oDlg TITLE 'Controle de Cargas' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlg:lMaximized := .T.
    layout(lCloseButt)
    defCtrls()
        
    mntBrw('OPER', @oBrwOper, @oPnlLOper)
    mntBrw('TES', @oBrwTes, @oPnlLTes)

    Activate MsDialog oDlg Center
   
    FreeObj(oTes)
    FreeObj(oBtnOper)
    FreeObj(oBtnPar)
    FreeObj(oBtnTes)
    FreeObj(oBtnFim)
    FreeObj(oBrwOper)
    FreeObj(oBrwTes)
    FreeObj(oBtnAdd)
    FreeObj(oBtnEdit)
    FreeObj(oBtnDel)
    FreeObj(oBtnUp)
    FreeObj(oBtnDwn)
    FreeObj(oPnlLOper)
    FreeObj(oPnlLTes)
    FreeObj(oPnlROper)
    FreeObj(oPnlRTes)
    FreeObj(oPnlRules)
    FreeObj(oFont)
    FreeObj(oFWLayer)
    FreeObj(oDlg)
return(nil)

static function layout(lCloseButt)
    oFWLayer := FWLayer():New()
    oFWLayer:Init(oDlg, lCloseButt)
    //Coluna Ctrl
    oFWLayer:AddCollumn('COL_RIGHT',08, .F.)
    oFWLayer:AddWindow('COL_RIGHT', 'WND_CTRL_OPER', 'Ctrl. Oper', 30, .T., .F.)
    oPnlROper := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_CTRL_OPER')
    oFWLayer:AddWindow('COL_RIGHT', 'WND_CTRL_TES', 'Ctrl. TES', 70, .T., .F.)
    oPnlRTes := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_CTRL_TES')
    //Coluna Brw
    oFWLayer:AddCollumn('COL_LEFT',82, .F.)
    oFWLayer:AddWindow('COL_LEFT', 'WND_OPER', 'Operações', 30, .T., .F.)
    oPnlLOper := oFWLayer:GetWinPanel('COL_LEFT', 'WND_OPER')    
    oFWLayer:AddWindow('COL_LEFT', 'WND_TES', 'Tipo de Entrada e Saída', 70, .T., .F.)
    oPnlLTes := oFWLayer:GetWinPanel('COL_LEFT', 'WND_TES')
return(nil)

static function defCtrls()
    oBtnMng     := TButton():New(00,02, 'Gerenciar',oPnlROper , {|| u_zCadSX5('DJ', 'Tipos de Operação')},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    oBtnAdd     := TButton():New(00,02, 'Adicionar',oPnlRTes , {|| viewAddTes(.F.)},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnEdit    := TButton():New(20,02, 'Editar',oPnlRTes , {|| viewAddTes(.T.)},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnDel     := TButton():New(40,02, 'Excluir',oPnlRTes , {|| delTes()},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnUp      := TButton():New(60,02, 'Subir',oPnlRTes ,{|| chgOrder('S')},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnDwn     := TButton():New(80,02, 'Descer',oPnlRTes ,{|| chgOrder('D')},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
return(nil)

static function mntBrw(cOpc, oGrid, oPnl)
    oGrid := FWBrowse():New()
    oGrid:DisableReport()
    oGrid:DisableFilter()
    oGrid:DisableConfig()
    oGrid:SetSeek()
    oGrid:SetFontBrowse(oFont)
    oGrid:SetOwner(oPnl)
    oGrid:SetTypeMove(0)
    oGrid:SetDataTable(.T.)
    if cOpc == 'TES'
        oGrid:SetAlias('SFM')
        oGrid:SetProfileID('BRWTES')
        oGrid:SetFilterDefault("FM_TIPO == '" + AllTrim(SX5->X5_CHAVE) + "'")
    else
        oGrid:SetAlias('SX5')
        oGrid:SetFilterDefault("X5_FILIAL == '" + xFilial('SX5') + "' .and. X5_TABELA == 'DJ'")
        oGrid:SetProfileID('BRWOPER')
        oGrid:SetChange({ || setRelation()})
    endif
    oGrid:SetColumns(mntFields(cOpc,'C'))
    oGrid:SetFieldFilter(mntFields(cOpc))
    oGrid:Activate()
return(nil)

static function setRelation()
    if oBrwTes <> nil
        oBrwTes:DeActivate()
        oBrwTes := nil
        oPnlLTes:FreeChildren()
        SFM->(DBOrderNickName('ZZFMORDEM'))
        SFM->(DbGoTop())
        mntBrw('TES', @oBrwTes, @oPnlLTes)
        oBrwTes:SetFilterDefault("FM_TIPO == '" + AllTrim(SX5->X5_CHAVE) + "'")
        //oBrwTes:RESET()
        oBrwTes:RESETLEN()
        //oBrwTes:GoBottom()
        //oBrwTes:GOPGDOWN()
        //oBrwTes:GOPGUP()
        //oBrwTes:GoTop()
        //oBrwTes:oData:GoBottom()
        //oBrwTes:oData:GoTop()
        //oBrwTes:oData:UPDATETOPBOT(.T.)
        oBrwTes:oBrowse:Refresh()
        oBrwTes:Refresh()
    endif
    oBrwOper:SetFocus()
return(nil)

static function mntFields(cOpc, cTp)
    local aHeader    := {}
    local aRet       := {}
    local nX         := 0
    default cTp      := ''
    if cOpc == 'OPER'
        cGrid := 'oBrwOper'
        aAdd(aHeader, {'X5_CHAVE', 'Tp.Oper', GetSx3Cache('X5_CHAVE','X3_TIPO'), TamSx3('X5_CHAVE')[1], GetSx3Cache('X5_CHAVE',  'X3_DECIMAL'),    PesqPict('SX5', 'X5_CHAVE')})
        aAdd(aHeader, {'X5_DESCRI', 'Descricao', GetSx3Cache('X5_DESCRI','X3_TIPO'), TamSx3('X5_DESCRI')[1], GetSx3Cache('X5_DESCRI',  'X3_DECIMAL'),    PesqPict('SX5', 'X5_DESCRI')})
    else
        cGrid := 'oBrwTes'
        aAdd(aHeader, {'FM_ZORDEM', 'Ordem', GetSx3Cache('FM_ZORDEM','X3_TIPO'), TamSx3('FM_ZORDEM')[1], GetSx3Cache('FM_ZORDEM',  'X3_DECIMAL'),    PesqPict('SFM', 'FM_ZORDEM')})
        aAdd(aHeader, {'FM_ZREGRA', 'Regra', 'C', 500, 0,   '@!'})
        aAdd(aHeader, {'FM_TE', 'TES Ent.', GetSx3Cache('FM_TE','X3_TIPO'), TamSx3('FM_TE')[1], GetSx3Cache('FM_TE',  'X3_DECIMAL'),    PesqPict('SFM', 'FM_TE')})
        aAdd(aHeader, {'FM_TS', 'TES Sai.', GetSx3Cache('FM_TS','X3_TIPO'), TamSx3('FM_TS')[1], GetSx3Cache('FM_TS',  'X3_DECIMAL'),    PesqPict('SFM', 'FM_TS')})
        aAdd(aHeader, {'FM_DESCRIC', 'Descricao', GetSx3Cache('FM_DESCRIC','X3_TIPO'), TamSx3('FM_DESCRIC')[1], GetSx3Cache('FM_DESCRIC',  'X3_DECIMAL'),    PesqPict('SFM', 'FM_DESCRIC')})
        aAdd(aHeader, {'FM_ZDTINIC', 'Dt.Ini', GetSx3Cache('FM_ZDTINIC','X3_TIPO'), TamSx3('FM_ZDTINIC')[1], GetSx3Cache('FM_ZDTINIC',  'X3_DECIMAL'),    PesqPict('SFM', 'FM_ZDTINIC')})
        aAdd(aHeader, {'FM_ZDTTERM', 'Dt.Fim', GetSx3Cache('FM_ZDTTERM','X3_TIPO'), TamSx3('FM_ZDTTERM')[1], GetSx3Cache('FM_ZDTTERM',  'X3_DECIMAL'),    PesqPict('SFM', 'FM_ZDTTERM')})
    endif
    if cTp == 'C'
        for nX := 1 to len(aHeader)
            //Columns
            AAdd(aRet,FWBrwColumn():New())
            aRet[Len(aRet)]:SetData( &("{||"+ aHeader[nX][1]+"}") )
            aRet[Len(aRet)]:SetTitle(aHeader[nX][2])
            aRet[Len(aRet)]:SetSize(aHeader[nX][4])
            aRet[Len(aRet)]:SetDecimal(aHeader[nX][5])
            aRet[Len(aRet)]:SetPicture(aHeader[nX][6])
        next nX 
    else
        aRet := aHeader       
    endif
return(aRet)

static function viewAddTes(lEdit)
    local aArea    	    := GetArea()
    local aAreaSX5	    := SX5->(getArea())
    private oModalAdd   := nil
    private oRadio      := nil
    private oGrpTes     := nil
    private oGetTes     := nil
    private oSayTesDesc := nil
    private oSayDesc    := nil
    private oGetDesc    := nil
    private oGetIni     := nil
    private oGetFim     := nil
    private oSayReg     := nil
    private oBtnReg     := nil
    private oBtnCod     := nil
    private oGrpDat     := nil
    private oGrpReg     := nil
    private oSayFim     := nil
    private oSayIni     := nil
    private oGrpApl     := nil
    private oRdApli     := nil
    private aOptions    := {'Dados', 'Parâmetros', 'Funções'}
    private nOpc        := 2
    private nAplic      := 3
    private aAplic      := {}
    private cTes        := Space(TamSx3('F4_CODIGO')[1])
    private dDtIni      := dDataBase
    private dDtFim      := Ctod('  /  /  ')
    private cRegra      := Space(500)
    private aRegra      := {}
    private cTesDesc    := Space(TamSx3('F4_TEXTO')[1])
    private cDesc       := Space(TamSx3('FM_DESCRIC')[1])
    private nAddWidth   := (aCoors[4] * 0.20)
    private nAddHeight  := (aCoors[3] * 0.40)
    private cTpOper     := AllTrim(SX5->X5_CHAVE)
    private oLog        := JsonObject():new()
    default lEdit       := .F.

    oModalAdd  := FWDialogModal():New()
    oModalAdd:setSize(nAddHeight, nAddWidth) //Height, Width
    oModalAdd:SetEscClose(.T.)
    oModalAdd:setTitle(iif(lEdit, 'Editar', 'Adicionar') + ' TES - Oper:' + cTpOper + ' - ' + AllTrim(SX5->X5_DESCRI))
    oModalAdd:createDialog()
    oModalAdd:addCloseButton(nil, "Fechar")
    oModalAdd:addOkButton({|| addTes(lEdit)}, "Concluir",{||.T.} )
        
    defAddComp()
        
    if lEdit
        chargeValues()
    endif
    
    oModalAdd:Activate()
    rfshBrw()
    oBrwTes:GoBottom()
    
    FreeObj(oLog)
    FreeObj(oSayFim)
    FreeObj(oSayIni)
    FreeObj(oGetTes)
    FreeObj(oSayDesc)
    FreeObj(oGetIni)
    FreeObj(oGetFim)
    FreeObj(oSayReg)
    FreeObj(oBtnReg)
    FreeObj(oBtnCod)
    FreeObj(oSayTesDesc)
    FreeObj(oGetDesc)
    FreeObj(oRadio)
    FreeObj(oRdApli)
    FreeObj(oGrpReg)
    FreeObj(oGrpTes)
    FreeObj(oGrpApl)
    FreeObj(oGrpDat)
    FreeObj(oModalAdd)

    RestArea(aAreaSX5)
    RestArea(aArea)
return(nil)

static function chargeValues()
    local nMyAplic := 0
    cTes        := iif(empty(AllTrim(SFM->FM_TS)), AllTrim(SFM->FM_TE),AllTrim(SFM->FM_TS))
    nOpc        := iif(empty(AllTrim(SFM->FM_TS)), 1, 2)
    oRadio:SetOption(nOpc)
    if !empty(SFM->FM_ZAPLIC)
        nMyAplic := Val(SFM->FM_ZAPLIC)
    endif
    mntAplica(nMyAplic)
    cTesDesc    := Padr(AllTrim(Posicione("SF4",1,xFilial("SF4")+cTes,"F4_TEXTO")), TamSx3('F4_TEXTO')[1])
    cDesc       := Padr(AllTrim(SFM->FM_DESCRIC), TamSx3('FM_DESCRIC')[1])
    dDtIni      := SFM->FM_ZDTINIC
    dDtFim      := SFM->FM_ZDTTERM
    cRegra      := AllTrim(SFM->FM_ZREGRA)
    if !empty(SFM->FM_JSBUILD)
        oLog:FromJson(SFM->FM_JSBUILD)
        aRegra := oLog['REGRA']
    endif
return(nil)

static function defAddComp()
    //aplicação
    oGrpApl  := TGroup():New(67, 01, /*nHeight*/ 89, /*nWidth*/ nAddWidth - 03,'Aplicação',oModalAdd:getPanelMain(),,,.T.)
    aAplic := {'Ped.Compra', 'NF Entrada', 'Todos'}
    oRdApli := TRadMenu():New (75, 05, aAplic,,oGrpApl,,,,,,,,(nAddWidth - 03) - 8,30,,,,.T.)
    oRdApli:bSetGet := {|u| iif(PCount()==0,nAplic,nAplic:=u)}
    oRdApli:lHoriz := .T.

    //TES
    oGrpTes := TGroup():New(01, 01, /*nHeight*/ 65, /*nWidth*/ nAddWidth - 03,'Tipo de Entrada e Saída',oModalAdd:getPanelMain(),,,.T.)
    aOptions := {'Entrada', 'Saída'}
    oRadio := TRadMenu():New (10, 05, aOptions,,oGrpTes,,,,,,,,140,30,,,,.T.)
    oRadio:bSetGet := {|u| iif(PCount()==0,nOpc,nOpc:=u)}
    oRadio:bChange := { || mntAplica() }
    oRadio:lHoriz := .T.
    oGetTes  := TGet():New(25,05, 	{ |u| iif( PCount() == 0, cTes, cTes := u ) },; 
                oGrpTes, 30, 15,PesqPict('SF4', 'F4_CODIGO'), {|| validTes(@nOpc, @cTes, @cTesDesc) },0,,oFont,;
                .T.,,.T.,,.T.,{|| .T.},.F.,.F.,{|| .T.},.F.,.F.,"SF4","cTes",,,,.T. )
    oSayTesDesc := TSay():New(30,50,	{|| cTesDesc}, oGrpTes,,oFont,,,,.T.,,, 100, 15)
    oSayDesc  := TSay():New(50,05,	{|| 'Desc.:'}, oGrpTes,,oFont,,,,.T.,,, 30, 15)
    oGetDesc  := TGet():New(45,40, 	{ |u| iif( PCount() == 0, cDesc, cDesc := u ) },; 
                oGrpTes, (nAddWidth - 03) - 48, 15,PesqPict('SFM', 'FM_DESCRIC'),,0,,oFont,;
                .T.,,.T.,,.T.,,.F.,.F.,,.F.,.F.,,"cDesc",,,,.T. )
    //Validade
    oGrpDat  := TGroup():New(90, 01, /*nHeight*/ 130, /*nWidth*/ nAddWidth - 03,'Validade',oModalAdd:getPanelMain(),,,.T.)
    oSayIni  := TSay():New(100,05,	{|| 'Inicio'}, oGrpDat,,oFont,,,,.T.,,, ((nAddWidth - 03)/2) - 8, 15)
    oGetIni  := TGet():New(110,05, 	{ |u| iif( PCount() == 0, dDtIni, dDtIni := u ) },; 
        oGrpDat, ((nAddWidth - 03)/2) - 10, 15,PesqPict('SF2', 'F2_EMISSAO'),,0,,oFont,;
        .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dDtIni",,,,.T. )
    oSayFim  := TSay():New(100,((nAddWidth - 03)/2) + 5,	{|| 'Fim'}, oGrpDat,,oFont,,,,.T.,,, ((nAddWidth - 03)/2) - 8, 15)
    oGetFim  := TGet():New(110,((nAddWidth - 03)/2) + 5, 	{ |u| iif( PCount() == 0, dDtFim, dDtFim := u ) },; 
                oGrpDat, ((nAddWidth - 03)/2) - 10, 15,PesqPict('SF2', 'F2_EMISSAO'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dDtFim",,,,.T. )
    //Regra
    oGrpReg  := TGroup():New(130, 01, /*nHeight*/ 238, /*nWidth*/ nAddWidth - 03,'Regra',oModalAdd:getPanelMain(),,,.T.)
    oBtnReg  := TButton():New(140,05, 'Assistente',oGrpReg , {|| mntRegra(.T.)},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnCod  := TButton():New(140,65, 'Código',oGrpReg , {|| mntRegra(.F.)},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oSayReg  := TSay():New(160,05,	{|| cRegra}, oGrpReg,,oFont,,,,.T.,,, (nAddWidth - 03) - 8, 200)
    mntAplica()
return(nil)

static function mntAplica(nMyAplic)
    default nMyAplic := 3
    if nMyAplic < 1 .or. nMyAplic > 3
        nMyAplic := 3
    endif
    oRdApli:SetOption(nMyAplic)
    nAplic := nMyAplic
    if nOpc == 1
        oRdApli:Show()
    else
        oRdApli:Hide()
    endif
    oRdApli:Refresh()
return(nil)

static function mntRegra(lAssist)
    local aTemp     := {}
    local cTemp     := ''
    Local oStatic   := IfcXFun():newIfcXFun()
    default lAssist := .T.

    if lAssist
        aTemp := u_cbcBldExp(aRegra)

        if (!empty(aTemp) .and. !(AllTrim(oStatic:sP(1):callStatic('cbcBldExp', 'ExpTranslate', aTemp)) == AllTrim(cRegra)))
            cTemp := oStatic:sP(1):callStatic('cbcBldExp', 'ExpTranslate', aTemp)
            aRegra := AClone(aTemp)
        endif
    else
        cTemp := ManualEdit()
        aRegra:= {}
    endif
    if !empty(cTemp) 
        cRegra := cTemp
        oLog['USER'] := RetCodUsr()
        oLog['DATA'] := DtoC(Date())
        oLog['HORA'] := time()
        oLog['REGRA']:= aRegra
    endif
return(nil)

static function ManualEdit()
    local oModalEdit    := nil
    local oGetEdit      := nil
    local cEdit         := cRegra
    local nAddHeight    := 200
    local nAddWidth     := 300

    oModalEdit  := FWDialogModal():New()
    oModalEdit:setSize(nAddHeight, nAddWidth) //Height, Width
    oModalEdit:SetEscClose(.T.)
    oModalEdit:setTitle('Edição Manual de Regra')
    oModalEdit:createDialog()
    oModalEdit:addCloseButton(nil, "Fechar")
    oModalEdit:addOkButton({|| finishEdit(@oModalEdit)}, "Concluir",{||.T.} )
    oGetEdit := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cEdit := u, cEdit ) }, ;
    oModalEdit:getPanelMain(), (nAddWidth - 03), (nAddHeight - 70), , , , , , .T. )
    oModalEdit:Activate()

    FreeObj(oGetEdit)
    FreeObj(oModalEdit)
return(cEdit)

static function finishEdit(oModalEdit)
    if MsgYesNo('Confirma edição manual?','Confirma')
        oModalEdit:DeActivate()
    endif
return(.T.)

static function validTes(nOper, cTes, cDesc)
    local aArea     := GetArea()
    local aAreaSF4  := SF4->(GetArea())
    local lRet      := .T.

    if !empty(cTes)
        if (nOper == 1 .and. (Val(cTes) < 500)) .or. (nOper == 2 .and. (Val(cTes) >= 500))
            cDesc := AllTrim(Posicione("SF4",1,xFilial("SF4")+cTes,"F4_TEXTO"))
        else
            lRet := .F.
            cDesc := Space(TamSx3('F4_TEXTO')[1])
            MsgAlert('Tes Incompátivel com Operação!','TES Incompatível')
        endif
    endif
    RestArea(aAreaSF4)
    RestArea(aArea)
return(lRet)

static function addTes(lEdit)
    local aArea    	    := GetArea()
    local aAreaSX5	    := SX5->(getArea())
    local oJson         := JsonObject():new()
    local lRet          := .F.

    if empty(aAplic)
        lRet := .F.
        MsgAlert('Aplicação não selecionada!', 'Sem Aplicação')
    else
        oJson['FM_ZAPLIC']  := cValToChar(nAplic)
        oJson['FM_TIPO']    := AllTrim(cTpOper)
        oJson['FM_DESCRIC'] := AllTrim(cDesc)
        if nOpc == 1
            oJson['FM_TE']  := AllTrim(cTes)
        else
            oJson['FM_TS']  := AllTrim(cTes)
        endif
        oJson['FM_ZDTINIC'] := dDtIni
        oJson['FM_ZDTTERM'] := dDtFim
        oJson['FM_ZORDEM']  := iif(lEdit, AllTrim(SFM->FM_ZORDEM), oTes:nextOrdem(AllTrim(cTpOper)))
        oJson['FM_ZREGRA']  := AllTrim(cRegra)
        oJson['FM_JSBUILD']  := oLog:toJson()
        if lEdit
            if MsgYesNo('Confirma alteração?','Confirmar')
                if !(lRet := (oTes:update(SFM->(Recno()), oJson):isOk()))
                    MsgAlert(oTes:getErrMsg(),'Error')
                endif
            endif
        else
            if MsgYesNo('Confirma inclusão?','Confirmar')
                if !(lRet := (oTes:add('TES', oJson):isOk()))
                    MsgAlert(oTes:getErrMsg(),'Error')
                endif
            endif
        endif
        if lRet
            oModalAdd:DeActivate()
        endif
    endif
    FreeObj(oLog)
    FreeObj(oJson)
    RestArea(aAreaSX5)
    RestArea(aArea)
return(lRet)

static function chgOrder(cOpc)
    local aArea    	    := GetArea()
    local aAreaSX5	    := SX5->(getArea())
    local cTo           := ''
    local nX            := oBrwTes:At()
    local nRecno        := 0
    Local oStatic       := IfcXFun():newIfcXFun()

    if cOpc == 'S'
        if AllTrim(SFM->FM_ZORDEM) <> '01'
            nX--
            nRecno := SFM->(Recno())
            cTo := oStatic:sP(1):callStatic('ctrlTesIntel', 'tira1', AllTrim(SFM->FM_ZORDEM))
        endif
    else
        if AllTrim(SFM->FM_ZORDEM) <> oStatic:sP(1):callStatic('ctrlTesIntel', 'lastOrder', AllTrim(SFM->FM_TIPO))
            nX++
            nRecno := SFM->(Recno())
            cTo := Soma1(AllTrim(SFM->FM_ZORDEM))
        endif
    endif
    if !empty(cTo)
        oTes:chgOrder(AllTrim(SFM->FM_TIPO), AllTrim(SFM->FM_ZORDEM), cTo)
        rfshBrw()
    endif
    RestArea(aAreaSX5)
    RestArea(aArea)
return(nil)

static function rfshBrw()
    setRelation()
    oBrwTes:SetFocus()
return(nil)

static function delTes()
    local aArea    	    := GetArea()
    local aAreaSX5	    := SX5->(getArea())

    if MsgYesNo('Confirma Exclusão do TES/Regra do TES Inteligente?','Confirmar')
        oTes:delete(AllTrim(SFM->FM_TIPO), SFM->(Recno()))
        rfshBrw()
    endif
    RestArea(aAreaSX5)
    RestArea(aArea)
return(nil)
