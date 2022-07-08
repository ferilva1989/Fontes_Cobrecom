#include "Totvs.ch"
#define TAM_V 015
#define TAM_TAB 005
#define OPC_TBL 1
#define OPC_PAR 2
#define OPC_FRM 3

user function cbcBldExp(aMyRegra)
    private aExpress    := {}
    default aMyRegra    := {}

    aExpress := aMyRegra

    /*
    // Chamando CursorArrow() força a CursorWait() mostrar o cursor de ampulheta sempre.
    CursorArrow()
    CursorWait()
    */
    // iniciar View
    FWMsgRun(, { || initView() }, 	"Construtor de Expressões", "Iniciando...")
return(aExpress)

static function initView()
    local lCloseButt 	:= !(oAPP:lMdi)
    local aCoors        := FWGetDialogSize( oMainWnd )
    local nX            := 0
    private oFont	    := TFont():New("Arial",,15,,.F.)
    private oModal      := nil
    private oFWLayer    := nil
    private oPnlCtrl    := nil
    private oPnlExpr    := nil
    private oRadio      := nil
    private oGetDado    := nil
    private oCmbOper    := nil
    private oCmbTab     := nil
    private oGetValue   := nil
    private oGrpExpr    := nil
    private oBtnAdd     := nil
    private oBtnOpen    := nil
    private oBtnClose   := nil
    private oBtnAnd     := nil
    private oBtnOr      := nil
    private oBtnClean   := nil
    private oExpMain    := nil
    private oMenuSub    := nil
    private oMenuAntes  := nil
    private oMenuDepois := nil
    private oMenuExcluir:= nil
    private oScroll     := nil
    private oPnlTst     := nil
    private aOptions    := {}
    private aCmbOper    := {}
    private aCmbTabel   := {}
    private aCmbDados   := {}
    private aTblCtrl    := {}
    private aFreeObj    := {}
    private aExpCtrl    := {}
    private cOper       := ''
    private cTabel      := ''
    private cAlsTabel   := ''
    private xDado       := Space(200)
    private xValue      := Space(200)
    private nColAt      := 0
    private nLinAt      := 1    
    private nMHeight    := 0
    private nWidth      := 0
    private nLimitWidth := 0
    private nLimitHeight:= 0
    private nMngExpr    := 0
    private nOpc        := 1
    private bAddExpr    := {|| }

    oModal  := FWDialogModal():New()
    oModal:setSize((aCoors[3] * 0.4),(aCoors[4] * 0.31))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Construtor de Expressões')
    oModal:createDialog()
    oModal:addCloseButton({||validEnd(.F.)}, "Fechar")
    oModal:addOkButton({|| validEnd(.T.)}, "Concluir",{||.T.} )
    oFWLayer := FWLayer():New()
    oFWLayer:Init(oModal:getPanelMain(), lCloseButt)

    defLayout()
    defPrinCtrls()
    chgOpc(nOpc)
    defExprCtrls()

    applyCss('PRIN',@oModal:oSayTitle)
   	applyCss('PRIN',@oModal:oTop)

    if !empty(aExpress)
       oModal:setInitBlock({|| rebuildExpr()}) 
    endif

    oModal:Activate()

    DBClearAllFilter()

    for nX := 1 to len(aFreeObj)
        FreeObj(&(aFreeObj[nX]))
    next nX

    FreeObj(oFont)
    FreeObj(oRadio)
    FreeObj(oGetDado)
    FreeObj(oCmbOper)
    FreeObj(oCmbTab)
    FreeObj(oGetValue)
    FreeObj(oGrpExpr)
    FreeObj(oBtnAdd)
    FreeObj(oBtnOpen)
    FreeObj(oBtnClose)
    FreeObj(oBtnAnd)
    FreeObj(oBtnOr)
    FreeObj(oBtnClean)
    FreeObj(oExpMain)
    FreeObj(oMenuSub)
    FreeObj(oMenuAntes)
    FreeObj(oMenuDepois)
    FreeObj(oMenuExcluir)
    FreeObj(oScroll)
    FreeObj(oPnlTst)
    FreeObj(oPnlCtrl)
    FreeObj(oPnlExpr)
    FreeObj(oFWLayer)
    FreeObj(oModal)
return(nil)

static function defLayout()
    oFWLayer:AddCollumn('COL', 100, .F.)

    // Coluna Esquerda (Controles)
    oFWLayer:AddWindow('COL', 'WND_CTRL', 'Controles', 35, .T., .F.)
    oPnlCtrl := oFWLayer:GetWinPanel('COL', 'WND_CTRL')
    oFWLayer:AddWindow('COL', 'WND_EXPR', 'Expressão', 65, .T., .F.)
    oPnlExpr := oFWLayer:GetWinPanel('COL', 'WND_EXPR')
return(nil)

static function defPrinCtrls()
    aOptions := {'Dados', 'Parâmetros', 'Funções'}
    oRadio := TRadMenu():New (05, 05, aOptions,,oPnlCtrl,,,,,,,,140,30,,,,.T.)
    oRadio:bSetGet := {|u| iif(PCount()==0,nOpc,nOpc:=u)}
    oRadio:lHoriz := .T.
    oRadio:bChange := {|| FWMsgRun(, { || chgOpc(nOpc) }, 	"Construtor de Expressões", "Alterando Origem...") }
    applyCss('CTRL', @oRadio)
return(nil)

static function defTables()
    local aArea     := GetArea()
	local aAreaX2   := SX2->(GetArea())
    local cParTabel := GetNewPar('ZZ_TESTABS', 'SB1;SF1;SD1;SA2;SF4')
    local aParTabel := {}
    local nX        := 0

    aParTabel := StrTokArr(cParTabel,";" )
    DbSelectArea("SX2")
    SX2->(dbSetOrder(1))
    for nX := 1 to len(aParTabel)
        if SX2->(dbSeek(AllTrim(aParTabel[nX])))
            aAdd(aTblCtrl, {AllTrim(aParTabel[nX]), AllTrim(SX2->X2_NOME)})
            aAdd(aCmbTabel, AllTrim(SX2->X2_NOME))
        endif        
    next nX

    RestArea(aAreaX2)
	RestArea(aArea)
return(nil)

static function chgtable()
    local aArea     := GetArea()
	local aAreaX3   := SX3->(GetArea())
    
    aCmbDados := {}
    setAlsTabel()
    if !empty(cAlsTabel)
        DbSelectArea('SX3')
        SX3->(DbSetFilter({|| X3_ARQUIVO == cAlsTabel }, "X3_ARQUIVO == '"+cAlsTabel+"'"))
        //Percorre o Dicionário enquanto for essa tabela
        SX3->(DbGoTop())
        While ! SX3->(EoF())
            aAdd(aCmbDados, AllTrim(SX3->X3_CAMPO))
            SX3->(DbSkip())
        EndDo
    endif
    FreeObj(oGetDado)
    oGetDado   := TComboBox():New(25,05,{|u|if(PCount()>0, xDado:=u, xDado)},aCmbDados,150,15,oPnlCtrl,,{|| .T.},,,,.T.,,,,,,,,,'xDado')
    applyCss('CTRL', @oGetDado)
    RestArea(aAreaX3)
	RestArea(aArea)
return(.T.)

static function loadParam()
    local aArea     := GetArea()
	local aAreaX6   := SX6->(GetArea())
    
    aCmbDados := {}

    DbSelectArea("SX6")
	SX6->(DbGoTop())
	
	While !SX6->(EoF())
		if (aScan(aCmbDados, AllTrim(SX6->X6_VAR)) == 0)
            aAdd(aCmbDados, AllTrim(SX6->X6_VAR))
		endif
		SX6->(DbSkip())
	EndDo
    FreeObj(oGetDado)
    oGetDado   := TComboBox():New(25,05,{|u|if(PCount()>0, xDado:=u, xDado)},aCmbDados,150,15,oPnlCtrl,,{|| .T.},,,,.T.,,,,,,,,,'xDado')
    applyCss('CTRL', @oGetDado)
    RestArea(aAreaX6)
	RestArea(aArea)
return(.T.)

static function defExprCtrls()
    oBtnOpen    := TButton():New(05,05, '(',oPnlExpr , {|| addExpre('(')},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss('CTRL', @oBtnOpen)
    oBtnClose   := TButton():New(05,50, ')',oPnlExpr , {|| addExpre(')')},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss('CTRL', @oBtnClose)
    oBtnAnd     := TButton():New(05,95, 'E',oPnlExpr , {|| addExpre('.and.')},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss('CTRL', @oBtnAnd)
    oBtnOr      := TButton():New(05,140, 'OU',oPnlExpr ,{|| addExpre('.or.')},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss('CTRL', @oBtnOr)
    oBtnClean   := TButton():New(05,215, 'Limpar',oPnlExpr ,{|| clear()},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss('CTRL', @oBtnClean)
    nMHeight:= oPnlExpr:nHeight/3.5
    nWidth := oPnlExpr:nWidth/2-25
    nLimitWidth := oPnlExpr:nWidth/2-15
    nLimitHeight:= (nMHeight * 3)
    oGrpExpr:= TGroup():New(23, 02, nMHeight + 46, nLimitWidth + 13,'',oPnlExpr,,,.T.)
    applyCss('CTRL', @oGrpExpr)
    oScroll     := TScrollArea():New(oPnlExpr,25,05,nMHeight,nLimitWidth, .T., .F.)
    oScroll:lTracking := .T.
	oPnlTst := TPanel():New( 0, 0, /*cText*/, oScroll, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, nWidth, nMHeight) 
    oScroll:SetFrame(oPnlTst)
return(nil)

static function setAlsTabel()
    local nPosi     := 0

    if ((nPosi := aScan(aTblCtrl, {|x| x[02] == cTabel})) > 0)
        cAlsTabel := aTblCtrl[nPosi, 01]
    else
        cAlsTabel := ""
    endif
return(nil)

static function resetVarOpc()
    xDado       := Space(200)
    xValue      := Space(200)
    cTabel      := ""
    cAlsTabel   := ""
    aCmbDados   := {}
    aTblCtrl    := {}
    aCmbTabel   := {}
    FreeObj(oCmbTab)
    FreeObj(oCmbOper)
    FreeObj(oGetValue)
    FreeObj(oBtnAdd)
    SetKey(VK_F5, {||})
return(nil)

static function chgOpc(nOpc)
    resetVarOpc()
    if nOpc == 1
        bAddExpr := {|| addTblExpre()}
        defTables()
        if empty(cTabel)
            cTabel := aCmbTabel[1]
            setAlsTabel()
        endif
        oCmbTab    := TComboBox():New(02,160,{|u|if(PCount()>0, cTabel:=u, cTabel)},aCmbTabel,105,25,oPnlCtrl,,{|| chgtable()},,,,.T.,,,,,,,,,'cTabel')
        applyCss('CTRL', @oCmbTab)
        chgtable()
        aCmbOper := {'Igual a',;
                    'Diferente de',;
                    'Menor que',;
                    'Menor ou Igual que',;
                    'Maior que',;
                    'Maior ou Igual que',;
                    'Contém a Expressão',;
                    'Não Contém',;
                    'Está contido em',;
                    'Não está Contido em'}
        oCmbOper    := TComboBox():New(25,160,{|u|if(PCount()>0, cOper:=u, cOper)},aCmbOper,105,25,oPnlCtrl,,{|| },,,,.T.,,,,,,,,,'cOper')
        applyCss('CTRL', @oCmbOper)
        oCmbOper:Select(1)
        oGetValue   := TGet():New(25,270, { |u| iif( PCount() == 0, xValue, xValue := u) }, oPnlCtrl, 150, 15,"@!",,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xValue,,,, )
        applyCss('CTRL', @oGetValue)
        SetKey(VK_F5, {||showHelp()})
    elseif nOpc == 2
        bAddExpr := {|| addParExpre()}
        loadParam()
        aCmbOper := {'Igual a',;
                    'Diferente de',;
                    'Menor que',;
                    'Menor ou Igual que',;
                    'Maior que',;
                    'Maior ou Igual que',;
                    'Contém a Expressão',;
                    'Não Contém',;
                    'Está contido em',;
                    'Não está Contido em'}
        oCmbOper    := TComboBox():New(25,160,{|u|if(PCount()>0, cOper:=u, cOper)},aCmbOper,105,25,oPnlCtrl,,{|| },,,,.T.,,,,,,,,,'cOper')
        applyCss('CTRL', @oCmbOper)
        oCmbOper:Select(1)
        oGetValue   := TGet():New(25,270, { |u| iif( PCount() == 0, xValue, xValue := u) }, oPnlCtrl, 150, 15,"@!",,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xValue,,,, )
        applyCss('CTRL', @oGetValue)
    else
        bAddExpr := {|| addExpre({AllTrim(xDado), nOpc})}
        FreeObj(oGetDado)
        oGetDado  := TGet():New(25,05, 	{ |u| iif( PCount() == 0, xDado, xDado := u ) }, oPnlCtrl, 400, 15,"@!",,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,xDado,,,, )
        applyCss('CTRL', @oGetDado)
        oGetDado:Refresh()
        SetKey(VK_F5, {||jsonFuncs()})
    endif
    oBtnAdd     := TButton():New(42,05, 'Adicionar',oPnlCtrl , bAddExpr,50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss('CTRL', @oBtnAdd)
    oRadio:SetOption(nOpc)
    oPnlCtrl:Refresh()
    oPnlExpr:Refresh()
return(.T.)

static function addParExpre()
    local aArea     := GetArea()
	local aAreaX6   := SX6->(GetArea())
    local aFil		:= FWAllFilial()
    local nX        := 0
    local lSeek     :=.F.
    
    if FWSX6Util():ExistsParam(AllTrim(xDado))
        DbSelectArea("SX6")
        SX6->(DbSetOrder(1))
        if !(lSeek := SX6->(DbSeek(Space(Len(SX6->X6_FIL)) + AllTrim(xDado))))
            for nX := 1 to len(aFil)
                if (lSeek := SX6->(DbSeek(aFil[nX] + AllTrim(xDado))))
                    EXIT
                endif
            next nX
        endif
        if lSeek
            if vldXValue(SX6->X6_TIPO, xValue)
                addExpre({AllTrim(xDado), AllTrim(cOper), AllTrim(xValue), SX6->X6_TIPO, nOpc})
                oCmbOper:Select(1)
                oGetValue:Select(1)
            endif
        else
            MsgAlert('Parâmetro selecionado não está disponível!','Code: 2 - Parâmetro não encontrado')
        endif
    else
        MsgAlert('Parâmetro selecionado não está disponível!','Code: 2 - Parâmetro não encontrado')
    endif
    RestArea(aAreaX6)
	RestArea(aArea) 
return(nil)

static function addTblExpre()
    local lAllTrim := MsgYesNo('Deseja Remover os Espaços em Branco da Origem?','Remover Espaços')
    if vldXValue(GetSx3Cache(AllTrim(xDado), 'X3_TIPO'), xValue)
        addExpre({AllTrim(xDado), AllTrim(cOper), AllTrim(xValue), AllTrim(cAlsTabel), lAllTrim, GetSx3Cache(AllTrim(xDado), 'X3_TIPO'),nOpc})
        oCmbOper:Select(1)
        oGetValue:Select(1)
    endif
return(nil)

static function vldXValue(cTp, xValue)
    local lOk       := .T.

    if cTp == 'L'
        if !AllTrim(xValue) $ '.F.//.T.//T//F'
            MsgAlert('Formato de conteúdo inválido para o parâmetro! Aceito: .T. || .F. || T || F','Code: 3 - Conteúdo inválido')
            lOk := .F.
        endif
    elseif cTp == 'N'
        if !IsDigit(AllTrim(xValue))
            MsgAlert('Formato de conteúdo inválido para o parâmetro! Aceito: Números','Code: 3 - Conteúdo inválido')
            lOk := .F.
        endif
    elseif cTp == 'D'
        if DtoC(CtoD(AllTrim(xValue))) == '  /  /  '
            MsgAlert('Formato de conteúdo inválido para o parâmetro! Aceito: dd/MM/aa','Code: 3 - Conteúdo inválido')
            lOk := .F.
        endif
    /*
    elseif cTp == 'C'
        if empty(xValue)
            MsgAlert('Formato de conteúdo inválido para o parâmetro!','Code: 3 - Conteúdo inválido')
            lOk := .F.
        else
            xValue := "'" + AllTrim(xValue) + "'"
        endif
    */
    endif
return(lOk)

static function addExpre(xAdd)
    local cLabel := ''
    local nX     := ''

    if ValType(xAdd) == "A"
        if Val(cValToChar(xAdd[len(xAdd)])) == OPC_TBL .or. Val(cValToChar(xAdd[len(xAdd)])) == OPC_PAR
            if !empty(xAdd[1]) .and. !empty(xAdd[2])
                cLabel := xAdd[1] + " " + xAdd[2] + " " + xAdd[3]
            endif
            xDado  := Space(200)
            xValue := Space(200)
        elseif  Val(cValToChar(xAdd[len(xAdd)])) == OPC_FRM
            cLabel := xAdd[1]
        else
            cLabel := ""
            for nX := 1 to len(xAdd)
                cLabel += " "
                cLabel += xAdd[nX]
            next nX
        endif
    else
        cLabel := xAdd
    endif

    if !empty(cLabel)
        if nMngExpr == 0
            aAdd(aExpress, xAdd)
            addCmbExp(cLabel, Len(aExpress))
        else
            mngExpre(nMngExpr)
            aExpress[nMngExpr] := xAdd
            rebuildExpr()
        endif
    endif
return(nil)

static function addCmbExp(cLabel, nPosi)
    local lOk    := .T.
    local nPosiV := nLinAt
    local nPosiH := 005
    local nTamH  := iif((Len(cLabel) * 04) < 15, 15, (Len(cLabel) * 04))

    if (nColAt + TAM_TAB + nTamH)  <= nLimitWidth
        nPosiH += (nColAt)
    else
        nPosiV += TAM_V
    endif

    if (nPosiV + TAM_V) > nMHeight 
        if ((nPosiV + TAM_V) < nLimitHeight)
            oPnlTst:nHeight += (TAM_V)
        else
            lOk := .F.
            MsgAlert('Excedeu Limite de Condições','Limite de Condições')    
        endif
    endif

    if lOk
        nColAt := (nPosiH + nTamH)
        nLinAt := nPosiV
        SetPrvt("oExp" + StrZero(nPosi,2,0))
        &("oExp" + StrZero(nPosi,2,0))   := TButton():New(nLinAt, nPosiH, cLabel, oPnlTst ,{|| .T.},nTamH,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        defSubMenu(nPosi)
        &("oExp" + StrZero(nPosi,2,0)):SetPopupMenu(oExpMain)
        applyCss('PRIN', @(&("oExp" + StrZero(nPosi,2,0))))
        _SetNamedPrvt( "oExp" + StrZero(nPosi,2,0), &("oExp" + StrZero(nPosi,2,0)) , "initView" )
        aAdd(aFreeObj, "oExp" + StrZero(nPosi,2,0))
        oPnlExpr:Refresh()
        oPnlTst:Refresh()
    endif
return(nil)

static function defSubMenu(nPosi)
    oExpMain    := TMenu():New( 0,0,0,0,.T.)
    aExpCtrl := {'Substituir',;
        'Incluir Antes',;
        'Incluir Depois',;
        'Excluir'}
    // Adiciona sub-Itens
    oMenuSub    := TMenuItem():New(oExpMain,"Substituir",,,,{|| operExp('S',nPosi)},,,,,,,,,.T.)
    oMenuAntes  := TMenuItem():New(oExpMain,"Incluir Antes",,,,{||operExp('A',nPosi)},,,,,,,,,.T.)
    oMenuDepois := TMenuItem():New(oExpMain,"Incluir Depois",,,,{||operExp('D',nPosi)},,,,,,,,,.T.)
    oMenuExcluir:= TMenuItem():New(oExpMain,"Excluir",,,,{||operExp('E',nPosi)},,,,,,,,,.T.)
    oExpMain:Add(oMenuSub)
    oExpMain:Add(oMenuAntes)
    oExpMain:Add(oMenuDepois)
    oExpMain:Add(oMenuExcluir)
return(nil)

static function clear()
    local nX := 0
    for nX := 1 to len(aExpress)
        if Type( "oExp" + StrZero(nX,2,0) ) <> "U"
            &("oExp" + StrZero(nX,2,0)):Destroy()
            FreeObj( &("oExp" + StrZero(nX,2,0)))
        endif
    next nX
    aExpress    := {}
    nColAt      := 00
    nLinAt      := 01
    nMngExpr    := 0
    /*
    oPnlTst:FreeChildren()
    oScroll:FreeChildren()
    oGrpExpr:FreeChildren()
    oPnlExpr:FreeChildren()
    defExprCtrls()
    */
    oPnlExpr:Refresh()
    oGrpExpr:Refresh()
    oScroll:Refresh()
    oPnlTst:Refresh()
return(nil)

static function operExp(cOpc, nPosi)
    local xVal  := aExpress[nPosi]
    local nAt   := 0
    local nX    := 0
    
    if cOpc == 'S' .or. cOpc == 'A' .or. cOpc == 'D'
        lockBtnExp(.T.)
        applyCss('SUB', @(&("oExp" + StrZero(nPosi,2,0))))
        if cOpc == 'S'
            if ValType(xVal) == "A"
                if Val(cValToChar(xVal[len(xVal)])) == OPC_TBL .or. Val(cValToChar(xVal[len(xVal)])) == OPC_PAR
                    chgOpc(xVal[len(xVal)])
                    nAt := aScan(aCmbOper, xVal[2])
                    xDado  := Padr(xVal[1],200)
                    xValue := Padr(xVal[3],200)
                    oCmbOper:Select(iif(nAt > 0, nAt, 1))
                    oCmbOper:Refresh()
                    nAt := aScan(aCmbDados, xVal[1])
                    oGetDado:Select(iif(nAt > 0, nAt, 1))
                    oGetDado:Refresh()
                    oGetValue:Refresh()
                elseif  Val(cValToChar(xVal[len(xVal)])) == OPC_FRM
                    chgOpc(xVal[len(xVal)])
                    xDado  := Padr(xVal[1],200)
                    oGetDado:Refresh()
                else
                    chgOpc(OPC_FRM)
                    xDado := ""
                    for nX := 1 to len(xVal)
                        xDado += " "
                        xDado += xVal[nX]
                    next nX
                    xDado  := Padr(xDado,200)
                    oGetDado:Refresh()
                endif
            endif
            deleteExp(nPosi, .F.)
        endif
        nMngExpr := iif(cOpc == 'D', (nPosi + 1), nPosi)
    elseif cOpc == 'E'
        deleteExp(nPosi)
        rebuildExpr()
    endif
return(nil)

static function rebuildExpr()
    local aBck  := aClone(aExpress)
    local nX    := 0
    clear()
    for nX := 1 to len(aBck)
        addExpre(aBck[nX])
    next nX
    xDado  := Space(200)
    xValue := Space(200)
    if nOpc == 1
        oCmbOper:Select(1)
    endif
    oPnlExpr:Refresh()
    oGrpExpr:Refresh()
    oScroll:Refresh()
    oPnlTst:Refresh()
return(nil)

static function applyCss(cOpc, oObj)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
	
	if cTpObj == "TBUTTON"
        if cOpc == 'SUB'
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #000000; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 10px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #a60f0f, stop: 1 #f23333); /*Cor de fundo*/";
                                +"  min-width: 20px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #f23333 stop: 1 #a60f0f);";
                                +"}"
        elseif cOpc == 'PRIN'
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #000000; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 10px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #012b73, stop: 1 #367cf5); /*Cor de fundo*/";
                                +"  min-width: 20px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #367cf5 stop: 1 #012b73);";
                                +"}"
        else
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #FFFFFF; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 15px; /*Tamanho da fonte*/";
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
        endif            		
	elseif cTpObj == "TSAY"
			cCss +=	"QLabel { ";
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+"  color: #FFFFFF; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
    elseif cTpObj == "TGET"
			cCss +=	"QLineEdit { ";
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+"  color: #000000; /*Cor da fonte*/";
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
		                      +" } "                              
    elseif cTpObj == "TCOMBOBOX"
			cCss +=	"QComboBox { ";
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+"  color: #FFFFFF; /*Cor da fonte*/";
                        +"  background-color: #00297c;";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
                        +"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
    elseif cTpObj == "TRADMENU"
			cCss +=	"QRadioButton { ";
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+"  color: #000000; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"}"
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)


static function lockBtnExp(lDo)
    local nX := 0
    for nX := 1 to len(aExpress)
        if lDo
            &("oExp" + StrZero(nX,2,0)):Disable()
        else
            &("oExp" + StrZero(nX,2,0)):Enable()
        endif
    next nX
return(nil)

static function deleteExp(nPosi, lVisual)
    default lVisual := .T.

    if lVisual .and. Type( "oExp" + StrZero(nPosi,2,0) ) <> "U"
        &("oExp" + StrZero(nPosi,2,0)):Destroy()
        FreeObj( &("oExp" + StrZero(nPosi,2,0)))
    endif
    aDel(aExpress, nPosi)
    aSize(aExpress,(len(aExpress)-1))
return(nil)

static function mngExpre(nPosi)
    if nPosi <> 0
        aAdd(aExpress, NIL)
        Ains(aExpress, nPosi)
    endif
return(nil)

static function validEnd(lOk)
    if !lOk
        aExpress := {}
    endif
    oModal:DeActivate()
return(nil)

static function ExpTranslate(aTarg)
    local nX    := 0
    local xVal  := nil
    local cExpr := ''
    local cSpc  := ' '

    for nX := 1 to len(aTarg)
        xVal := aTarg[nX]
        cExpr += cSpc
        if ValType(xVal) <> "A"
            cExpr += xVal
        else
            cExpr += procExpr(xVal)
        endif
    next nX
return(cExpr)

static function procExpr(xVal)
    local cExpr := ''
    local cTemp := ''
    local cIni  := ''
    local cFim  := ''
    local cSpc  := ' '
    local nX    := 0
    local cVIni := ''

    if(cValToChar(xVal[2]) == 'Contém a Expressão' .or.;
        cValToChar(xVal[2]) == 'Não Contém')
        cTemp   := xVal[1]
        xVal[1] := xVal[3]
        xVal[3] := cTemp
    endif
    
    if(cValToChar(xVal[2]) == 'Não Contém' .or.;
        cValToChar(xVal[2]) == 'Não está Contido em')
        cIni := '!('
        cFim := ')'
    endif

    if Val(cValToChar(xVal[len(xVal)])) == OPC_TBL
        cTemp := xVal[4] + "->"
        cTemp += xVal[1]
        if xVal[5]
            cTemp := "AllTrim(" + cTemp + ")"
        endif
        cTemp += cSpc
        cTemp += convertOper(xVal[2]) + cSpc
        if xVal[6] == 'C'
            if Left(AllTrim(xVal[3]),1) <> "'" .or. Left(AllTrim(xVal[3]),1) <> '"'
                cVIni := "'"
                cTemp +=  cVIni
            else
                cVIni := Left(AllTrim(xVal[3]),1)
            endif
            cTemp += xVal[3]
            if Right(AllTrim(xVal[3]),1) <> cVIni
                cTemp += cVIni
            endif
        elseif xVal[6] == 'N'
            cTemp += cValToChar(Val(AllTrim(xVal[3])))
        else
            cTemp += xVal[3]
        endif
     elseif Val(cValToChar(xVal[len(xVal)])) == OPC_PAR
        cTemp := ""
        if xVal[4] == 'C'
            cTemp += 'AllTrim('
        endif
        cTemp += 'GetMv("'
        cTemp += xVal[1]
        cTemp += '")'
        if xVal[4] == 'C'
            cTemp += ')'
        endif
        cTemp += cSpc
        cTemp += convertOper(xVal[2]) + cSpc
        if xVal[4] == 'D'
            cTemp += 'CtoD("'
            cTemp += xVal[3]
            cTemp += '")'
        elseif xVal[4] == 'C'
            if Left(AllTrim(xVal[3]),1) <> "'" .or. Left(AllTrim(xVal[3]),1) <> '"'
                cVIni := "'"
                cTemp +=  cVIni
            else
                cVIni := Left(AllTrim(xVal[3]),1)
            endif
            cTemp += xVal[3]
            if Right(AllTrim(xVal[3]),1) <> cVIni
                cTemp += cVIni
            endif
        elseif xVal[4] == 'N'
            cTemp += cValToChar(Val(AllTrim(xVal[3])))
        else
            cTemp += xVal[3]
        endif
    elseif  Val(cValToChar(xVal[len(xVal)])) == OPC_FRM
        cTemp := xVal[1]
    else
        cTemp := ""
        for nX := 1 to len(xVal)
            cTemp += " "
            cTemp += xVal[nX]
        next nX
    endif
    cExpr := cIni + iif(!empty(cIni), cSpc, '') + cTemp + iif(!empty(cFim), cSpc, '') + cFim
return(cExpr)

static function convertOper(cOper)
    local cConvert := ''

    if cOper == 'Igual a'
        cConvert := '=='
    elseif cOper == 'Diferente de'
        cConvert := '<>'
    elseif cOper == 'Menor que'
        cConvert := '<'
    elseif cOper == 'Menor ou Igual que'
        cConvert := '<='
    elseif cOper == 'Maior que'
        cConvert := '>'
    elseif cOper == 'Maior ou Igual que'
        cConvert := '>='
    else
        cConvert := '$'
    endif
return(cConvert)

static function showHelp()
    local cMsg := AllTrim(FWX3Titulo(AllTrim(xDado)))
    local xLinha := chr(13)+chr(10)
    if empty(cMsg)
        MsgInfo('Help do campo não localizado!','HELP')
    else
        cMsg+= xLinha
        cMsg+= AllTrim(GetSx3Cache(AllTrim(xDado), 'X3_DESCRIC'))
        MsgInfo(AllTrim(cMsg), 'HELP')
    endif
return(nil)

static function jsonFuncs()
    local oModalFunc:= nil
	local oPnlFunc  := nil
    local oCmbFunc  := nil
    local oFontFunc	:= TFont():New("Arial",,25,,.T.)
    local bConfirm  := nil
    local cFunc     := ""
    local aCmbFunc  := {}
    local aFuncs    := {}

    //bBlkVld	    := { || .T.}
	bConfirm    := { || FWMsgRun(, {|| confirmFunc(@oModalFunc, cFunc, aFuncs)}, 	"Adicionar Função", "Adicionando...")}

    oModalFunc := FWDialogModal():New() 
	oModalFunc:setSize(100,300)
	oModalFunc:SetEscClose(.T.)
	oModalFunc:setTitle('Auxiliar de Funções')
	oModalFunc:createDialog()
	oModalFunc:addCloseButton(nil, "Fechar")
	oModalFunc:addOkButton(bConfirm, "Confirma", {||.T.} )
	oPnlFunc := TPanel():New( ,,, oModalFunc:getPanelMain() ) 
	oPnlFunc:SetCss("")
	oPnlFunc:Align := CONTROL_ALIGN_ALLCLIENT
    
    loadJsFunc(@aCmbFunc, @aFuncs)
    oCmbFunc    := TComboBox():New(05,05,{|u|if(PCount()>0, cFunc:=u, cFunc)},aCmbFunc,295,50,oPnlFunc,,{|| .T.},,,,.T.,,,,,,,,,'cFunc')
    
    applyCss('CTRL', @oCmbFunc)    
    applyCss('CTRL', @oModalFunc:oSayTitle)
   	applyCss('CTRL', @oModalFunc:oTop)
    
    oModalFunc:Activate()
    
    FreeObj(oCmbFunc)
    FreeObj(oFontFunc)
    FreeObj(oPnlFunc)
    FreeObj(oModalFunc)
return(nil)

static function loadJsFunc(aCmbFunc, aFuncs)
    local oCrud       := nil
    local cPath       := GetNewPar('ZZ_JSFUNCS', 'JSFUNCS')
    local aItm        := {}
    local aTemps      := {}
    local isAdm       := FwIsAdmin()
    local nX          := 0
    oCrud := jsonCrud():newjsonCrud(cPath, !isAdm)
    if !(oCrud:itsOk())
		Alert( oCrud:getMsgLog() )
    else
        if isAdm
            oCrud:showDialog()
        endif
        aItm :=  oCrud:getJson('AREGISTROS')
        for nX := 1 to len(aItm)
            //fieldRule(@aCampAlt, upper(aItm[nX]))
            aTemps := StrTokArr(AllTrim(aItm[nX]),";" )
            aAdd(aCmbFunc, aTemps[1])
            aAdd(aFuncs, {aTemps[1], aTemps[2]})
        next nX
    endif
    FreeObj(oCrud)
return(nil)

static function confirmFunc(oModalFunc, cFunc, aFuncs)
    local nPos := aScan(aFuncs, {|x| x[1] == cFunc})
    if ( nPos > 0)
        xDado := aFuncs[nPos, 2] + Space(200 - len(aFuncs[nPos, 2]))
    endif
    oModalFunc:DeActivate()
return(.T.)
