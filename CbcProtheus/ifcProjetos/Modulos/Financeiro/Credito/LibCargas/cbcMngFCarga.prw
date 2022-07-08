#include 'protheus.ch'
#include 'parmtype.ch'
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

user function cbcMngFCarga(cParCarga)
    local aArea 	  	:= GetArea()
    Local oStatic       := IfcXFun():newIfcXFun()
    private aMCoors     := FWGetDialogSize( oMainWnd )
    private oFont   	:= TFont():New("Arial",,15,,.T.)
    private oModal      := nil
    private oContainer  := nil
    private oFWExpLayer := nil
    private oBrw        := nil
    private oBrwApr     := nil
    private oBrwRej     := nil
    private oUPanel     := nil
    private oLDPanel    := nil
    private oRDPanel    := nil
    private cCarga      := ''
    private cAls        := oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias')
    private cAlsApr     := oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias')
    private cAlsRej     := oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias')
    private cCondEmb    := GetNewPar('ZZ_CPAGEMB', 'EMB')
    cCarga := cParCarga

    oModal  := FWDialogModal():New()
    oModal:setSize((aMCoors[3] * 0.5),(aMCoors[4] * 0.4))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Analise Financeira de Carga')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    
    layout()
    prepAls({cAls, cAlsApr, cAlsRej})
    mntBrw(cAls,    '',  @oBrw,    @oUPanel)
    mntBrw(cAlsApr, 'N', @oBrwApr, @oRDPanel)
    mntBrw(cAlsRej, 'S', @oBrwRej, @oLDPanel)
    
    oModal:Activate()

    closeAls({cAls, cAlsApr, cAlsRej})

    FreeObj(oBrw)
    FreeObj(oBrwApr)
    FreeObj(oBrwRej)
    FreeObj(oLDPanel)
    FreeObj(oUPanel)
    FreeObj(oRDPanel)
    FreeObj(oFWExpLayer)
    FreeObj(oContainer)
    FreeObj(oFont)
    FreeObj(oModal)

    RestArea(aArea)
return(nil)

static function layout()
    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:SetCss("")
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
    oFWExpLayer := FWLayer():New()
    oFWExpLayer:Init( oContainer, .F., .T. )
    
    oFWExpLayer:addLine('UP', 50)
    oFWExpLayer:addLine('DOWN', 50)
    oFWExpLayer:setLinSplit('DOWN', CONTROL_ALIGN_TOP, /*BCLOSE*/,	/*BOPEN*/)
    oFWExpLayer:AddCollumn('COL_U_BRW', 100, .F., 'UP')
    oFWExpLayer:AddWindow('COL_U_BRW', 'WND_U_BRW', 'Analisar', 100, .T., .F.,,'UP')
    oUPanel := oFWExpLayer:GetWinPanel('COL_U_BRW', 'WND_U_BRW','UP')

    oFWExpLayer:AddCollumn('COL_L_BRW', 50, .F.,'DOWN')
    oFWExpLayer:AddWindow('COL_L_BRW', 'WND_L_BRW', 'Aprovadas', 100, .T., .F.,,'DOWN')
    oLDPanel := oFWExpLayer:GetWinPanel('COL_L_BRW', 'WND_L_BRW','DOWN')
    oFWExpLayer:AddCollumn('COL_R_BRW', 50, .F.,'DOWN')
    oFWExpLayer:AddWindow('COL_R_BRW', 'WND_R_BRW', 'Reprovadas', 100, .T., .F.,,'DOWN')
    oRDPanel := oFWExpLayer:GetWinPanel('COL_R_BRW', 'WND_R_BRW','DOWN')

return(nil)

static function mntBrw(cAls, cOpc, oBrw, oPnl)
    oBrw := FWMBrowse():New()
    oBrw:DisableReport()
    oBrw:DisableFilter()
    oBrw:DisableConfig()
    oBrw:SetSeek()
    oBrw:SetFontBrowse(oFont)
    oBrw:SetOwner(oPnl)
    oBrw:SetTypeMove(0)
    oBrw:SetDataTable(.T.)
    oBrw:SetAlias(cAls)
    oBrw:SetProfileID('MNGF' + cOpc)
    oBrw:ForceQuitButton(.T.)
	oBrw:DisableDetails()
	oBrw:setIgnoreaRotina(.T.)
	oBrw:SetUseFilter(.T.)
    if cOpc == 'N'
        oBrw:SetFilterDefault("ZZ9_FILIAL = " + FwFilial() + " .and. ZZ9_ORDCAR == '" + AllTrim(cCarga) + "' .and. ZZ9_FLGFIN = 'N'")
    elseif cOpc == 'S'
        oBrw:SetFilterDefault("ZZ9_FILIAL = " + FwFilial() + " .and. ZZ9_ORDCAR == '" + AllTrim(cCarga) + "' .and. ZZ9_FLGFIN = 'S'")
    else
        oBrw:SetFilterDefault("ZZ9_FILIAL = " + FwFilial() + " .and. ZZ9_ORDCAR == '" + AllTrim(cCarga) + "' .and. ZZ9_FLGFIN = ' '")
        oBrw:AddButton('Apro.Todos', {|| FWMsgRun(, {|| allFlag(.T.)}, "Aprovado", "Aprovando...")},,,, .F., 7 )
        oBrw:AddButton('Reij.Todos', {|| FWMsgRun(, {|| allFlag(.F.)}, "Reprovado", "Reprovando...")},,,, .F., 7 )
    endif
    oBrw:bldblclick := {|| getProcOpc(cAls)}
    oBrw:SetColumns(mntFields('C'))
    oBrw:SetFieldFilter(mntFields())
    oBrw:Activate()
return(nil)

static function mntFields(cTp)
    local aHeader    := {}
    local aRet       := {}
    local nX         := 0
    default cTp      := ''

    aAdd(aHeader, {'ZZ9_ORDSEP',            'Ordem',   GetSx3Cache('ZZ9_ORDSEP','X3_TIPO'), TamSx3('ZZ9_ORDSEP')[1],    GetSx3Cache('ZZ9_ORDSEP',  'X3_DECIMAL'),   PesqPict('ZZ9', 'ZZ9_ORDSEP')})   
    aAdd(aHeader, {'getCli(ZZ9_ORDSEP)',    'Cliente', GetSx3Cache('A1_NOME',  'X3_TIPO'),  (TamSx3('A1_COD')[1]+TamSx3('A1_LOJA')[1]+TamSx3('A1_NOME')[1]), GetSx3Cache('A1_NOME',  'X3_DECIMAL'), PesqPict('SA1', 'A1_NOME')})
    aAdd(aHeader, {'getVal(ZZ9_ORDSEP)',    'Total',   GetSx3Cache('F2_VALBRUT','X3_TIPO'), TamSx3('F2_VALBRUT')[1],    GetSx3Cache('F2_VALBRUT',     'X3_DECIMAL'),PesqPict('SF2', 'F2_VALBRUT')})
    aAdd(aHeader, {'getCondPag(ZZ9_ORDSEP)','Cond.Pag',GetSx3Cache('E4_DESCRI','X3_TIPO'),  TamSx3('E4_DESCRI')[1],     GetSx3Cache('E4_DESCRI',     'X3_DECIMAL'), PesqPict('SE4', 'E4_DESCRI')})
    aAdd(aHeader, {'getObs(ZZ9_ORDCAR, ZZ9_ORDSEP)',    'Obs.',    GetSx3Cache('C5_OBS','X3_TIPO'),     TamSx3('C5_OBS')[1],        GetSx3Cache('C5_OBS',     'X3_DECIMAL'),    PesqPict('SC5', 'C5_OBS')})
    aAdd(aHeader, {'getPedObs(ZZ9_ORDCAR, ZZ9_ORDSEP)',    'Obs. Pedido',    GetSx3Cache('C5_OBS','X3_TIPO'),     TamSx3('C5_OBS')[1],        GetSx3Cache('C5_OBS',     'X3_DECIMAL'),    PesqPict('SC5', 'C5_OBS')})
    
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

static function getObs(cCarga, cOS)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local oObs      := JsonObject():new()
    local cRet      := ''
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryFCarga', 'qryGetRec', cCarga, cOS))
    if oSql:hasRecords()
        oSql:goTop()
        DbSelectArea('ZZ9')
        while oSql:notIsEof()
            ZZ9->(DbGoTo(oSql:getValue('REC')))
            if !empty(ZZ9->ZZ9_JSINFO)
                oObs:FromJson(AllTrim(ZZ9->ZZ9_JSINFO))
                if !empty(oObs:GetNames())
                    if ValType(oObs:GetJsonObject('Financeiro')) <> 'U' 
                        cRet := AllTrim(oObs['Financeiro']['Obs'])
                    endif
                endif
            endif
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    FreeObj(oObs)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(cRet)

static function getPedObs(cCarga, cOS)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local cRet      := ''
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryFCarga', 'qryPedObs', cCarga, cOS))
    if oSql:hasRecords()
        oSql:goTop()
        cRet := oSql:getValue('OBS')
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaZZ9)
    RestArea(aArea)
return(cRet)

static function getCli(cOS, cOpc)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local xRet      := ''
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    default cOpc    := 'CLI'
    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryCarga', 'qryGetCli', cOS))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            xRet := oSql:getValue(cOpc)
            if ValType(xRet) == 'C'
                xRet := AllTrim(xRet)
            endif
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(xRet)

static function getCondPag(cOS, lDesc)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local aAreaSE4 	:= SE4->(GetArea())
    local cCond     := ''
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    default lDesc   := .T.
    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryCarga', 'qryGetCli', cOS))
    if oSql:hasRecords()
        oSql:goTop()
        DbSelectArea('SE4')
        SE4->(DbGoTo(oSql:getValue('COND')))
        if lDesc
            cCond := AllTrim(SE4->E4_CODIGO) + ' - ' + AllTrim(SE4->E4_DESCRI)
        else
            cCond := AllTrim(SE4->E4_CODIGO)
        endif
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaSE4)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(cCond)


static function getVal(cOS)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local nTotal    := 0.00
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryFCarga', 'qryGetTotal', '',cOS))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            nTotal := oSql:getValue('TOTAL')
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(nTotal)

static function getProcOpc(cAls)
	local oModalMsg		:= nil	
	local oPnlMsg		:= nil
    local oFont		    := TFont():New("Arial",,12,,.T.)
	local oFontBtn		:= TFont():New("Arial",,20,,.T.)
	local oBtnYes		:= nil
	local oBtnNo		:= nil
    local oSay          := nil
	local cBtnYes		:= 'Aprovar'
	local cBtnNo		:= 'Reprovar'
	local bBtnYes		:= {|| FWMsgRun(, { || doFlag(.T., cAls, oModalMsg)}, "Aprovado", "Aprovando...")}
	local bBtnNo		:= {|| FWMsgRun(, { || doFlag(.F., cAls, oModalMsg)},"Rejeitado", "Rejeitando...")}
			
    oModalMsg:= FWDialogModal():New() 
	oModalMsg:setSize(75,200)
	oModalMsg:SetEscClose(.F.)
	oModalMsg:setTitle('Selecionar')
   	oModalMsg:nFontTitleSize := 20
	oModalMsg:enableFormBar(.F.)
	oModalMsg:createDialog()
	oPnlMsg := TPanel():New( ,,, oModalMsg:getPanelMain())
	oPnlMsg:SetCss("")
	oPnlMsg:Align := CONTROL_ALIGN_ALLCLIENT

    oSay	:= TSay():New(01,05,	{||'Posição Cliente(F3) | Consulta Cliente(F4) | Observa(F5)'}, oPnlMsg,,oFont,,,,.T., CLR_BLUE, /*CLR_WHITE*/, 190, 25)
    oSay:SetTextAlign( 2, 2 )
   	oBtnYes 	:= TButton():New( 20, 05,  cBtnYes, 	oPnlMsg , bBtnYes, 	90,30,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )
   	setMsgCss(@oBtnYes, 'Y')
    oBtnNo	 	:= TButton():New( 20, 105,  cBtnNo,	oPnlMsg , bBtnNo, 		90,30,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )
    setMsgCss(@oBtnNo, 'N')
   	mngBtn(cAls, @oBtnNo, @oBtnYes)
   	setMsgCss(@oModalMsg:oSayTitle)
   	setMsgCss(@oModalMsg:oTop)
	
    SetKey(VK_F3,  {||verifyCli(cAls, 'P')})
    SetKey(VK_F4,  {||verifyCli(cAls, 'C')})
    SetKey(VK_F5,  {||editObs(cAls)})

    if (getCondPag((cAls)->ZZ9_ORDSEP, .F.) $ cCondEmb)
        MsgAlert('Atenção OS com pagamento no embarque!', 'Pagamento no Embarque')
    endif    
    oModalMsg:Activate()
	
    SetKey(VK_F3,   {||})
    SetKey(VK_F4,   {||})
    SetKey(VK_F5,   {||})

    FreeObj(oSay)
    FreeObj(oBtnYes)
	FreeObj(oBtnNo)
    FreeObj(oPnlMsg)
    FreeObj(oModalMsg)
    FWMsgRun(, { || rfsh()}, "Analise Carga", "Atualizando...")
return(nil)

static function mngBtn(cAls, oBtnY, oBtnN)
    if cAls == cAlsApr
        oBtnN:Enable()
        oBtnY:Disable()
    elseif cAls == cAlsRej
        oBtnY:Enable()
        oBtnN:Disable()
    else
        oBtnN:Enable()
        oBtnY:Enable()
    endif
return(nil)

static function setMsgCss(oObj, cOpc)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
    default cOpc    := ''

	if cTpObj == "TBUTTON"
        if cOpc == 'Y'
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #00297c; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 24px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #00297c, stop: 1 #cfddf9); /*Cor de fundo*/";
                                +"  min-width: 80px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #cfddf9, stop: 1 #00297c);";
                                +"}"
        else
            cCSS :=	"QPushButton {";
								+"  color: #FFFFFF; /*Cor da fonte*/";
								+"  border: 2px solid #870303; /*Cor da borda*/";
								+"  border-radius: 6px; /*Arrerondamento da borda*/";
								+"  font-size: 24px; /*Tamanho da fonte*/";
								+"  color: #FFFFFF; /*Cor da fonte*/";
								+"  font-weight: bold; /*Negrito*/";
								+"  text-align: center; /*Alinhamento*/";
								+"  vertical-align: middle; /*Alinhamento*/";
								+"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
								+"                                    stop: 0 #870303, stop: 1 #d15252); /*Cor de fundo*/";
								+"  min-width: 80px; /*Largura minima*/";
								+"}";
								+"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
								+"QPushButton:pressed {";
								+"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
								+"                                    stop: 0 #d15252, stop: 1 #870303);";
								+"}"
        endif
	elseif cTpObj == "TSAY"
        cCss +=	"QLabel { ";
                    +"  font-size: 20px; /*Tamanho da fonte*/";
                    +"  color: #FFFFFF; /*Cor da fonte*/";
                    +"  font-weight: bold; /*Negrito*/";
                    +"  text-align: center; /*Alinhamento*/";
                    +"  vertical-align: middle; /*Alinhamento*/";
                    +"  border-radius: 6px; /*Arrerondamento da borda*/";
                    +"}"
	elseif cTpObj == "TPANEL"		
        cCss +=	 "QFrame {";
                            +" color: #FFFFFF; /*Cor da fonte*/ ";
                            +" background-color: #00297c;";	
                            +" border: 2px solid #00297c; /*Cor da borda*/";	  						
                            +" border-radius: 6px; /*Arrerondamento da borda*/ ";
                            +" } "
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)

static function doFlag(lDo, cActive, oModal)
    local oCtrl := cbcCtrlCarga():newcbcCtrlCarga()
    local aFld  := {}
    default lDo := .T.

    if !empty(cActive)
        aAdd(aFld, {'ZZ9_FLGFIN',iif(lDo, 'S', 'N')})
        oCtrl:define(AllTrim((cActive)->ZZ9_ORDCAR))
        lOk := oCtrl:update(aFld, (cActive)->ZZ9_ORDSEP):isOk()
        if !lOk
            MsgAlert(AllTrim(oCtrl:getErrMsg()), 'Erro no Processamento')
        endif
    else
        MsgAlert('Selecione uma OS!', 'Selecione OS')
    endif
    FreeObj(oCtrl)
    if oModal <> nil
        oModal:DeActivate()
    endif
return(nil)

static function allFlag(lDo)
    local lEmb  := .F.
    default lDo := .T.

    (cAls)->(DbGoTop())
    while !(cAls)->(EOF())
        if (getCondPag((cAls)->ZZ9_ORDSEP, .F.) $ cCondEmb)
            lEmb := .T.
        else
            doFlag(lDo, cAls, nil)
        endif
        (cAls)->(dbskip())
    endDo
    if lEmb
        MsgAlert('Existem OS(s) com pagamento no embarque que devem ser liberada(s) manualmente!', 'Pagamento no Embarque')
    endif
    rfsh()
return(nil)

static function rfsh()
    /*
    oBrwApr:DeActivate()
    oBrwApr := nil
    oLDPanel:FreeChildren()

    oBrwRej:DeActivate()
    oBrwRej := nil
    oRDPanel:FreeChildren()

    oBrw:DeActivate()
    oBrw := nil
    oUPanel:FreeChildren()

    mntBrw(cAls,    '',  @oBrw,    @oUPanel)
    mntBrw(cAlsApr, 'N', @oBrwApr, @oRDPanel)
    mntBrw(cAlsRej, 'S', @oBrwRej, @oLDPanel)
    */
    oBrwApr:Refresh(.T.)
    oBrwRej:Refresh(.T.)
    oBrw:Refresh(.T.)
    oLDPanel:Refresh()
    oRDPanel:Refresh()
    oUPanel:Refresh()
    Sleep(1500)
return(nil)

static function prepAls(aAls)
    local nX := 0
    for nX := 1 to len(aAls)
        ChkFile("ZZ9")
        dbChangeAlias("ZZ9",aAls[nX])
		(aAls[nX])->(DBSetOrder(1))
		(aAls[nX])->( dbGoTop() )
    next nX
    ChkFile("ZZ9")
return(nil)

static function closeAls(aAls)
	local nX := 0
	for nX := 1 to len(aAls)
		(aAls[nX])->( dbCloseArea() )
	next nX
return(nil)

static function verifyCli(cAls, cOpc)
    local aArea          := GetArea()
    local aAreaSA1       := SA1->(GetArea())
    local nRec           := getCli((cAls)->ZZ9_ORDSEP, 'REC')

    if empty(nRec)
        MsgAlert('Cadastro do Cliente não pode ser Posicionado!','Cadastro não Encontrado')
    else
        DbSelectArea('SA1')
        SA1->(DbGoTo(nRec))
        if cOpc == 'P'
            FWMsgRun(, { || PosiCliente()}, "Posição do Cliente", "Iniciando...")
        else
            FWMsgRun(, { || u_cbcCredView(SA1->A1_COD,SA1->A1_LOJA)}, "Consulta Cliente", "Iniciando...")
        endif
    endif

    RestArea(aAreaSA1)
    RestArea(aArea)
return(nil)

static function PosiCliente()	
    private cFilCorr	 := cFilAnt
	private	aRotina := { {"Pesquisar","PesqBrw"	, 0 , 1,0,.F.},;
						 {"Automatica","A450LibAut", 0 , 2,0,NIL},;
						 {"Manual","A450LibMan", 0 , 4,0,NIL},;
						 {"Legenda","A450Legend", 0 , 3,0,.F.} }
    if ( Pergunte("FIC010",.T.) )
        Fc010Con()
    endif
        
    Pergunte("MTA451",.F.)
return(nil)

static function editObs(cAls)
    local aArea    	    := GetArea()
    local aAreaZZ9 	    := ZZ9->(GetArea())
    local aAreaAls 	    := (cAls)->(GetArea())
    local oModal        := nil
    local oGet          := nil
    local cObs          := getObs((cAls)->ZZ9_ORDCAR, (cAls)->ZZ9_ORDSEP)
    local nAddHeight    := 200
    local nAddWidth     := 300
    local oInfo         := nil
    local oJson         := nil
    local oCtrl         := cbcCtrlCarga():newcbcCtrlCarga()

    oModal  := FWDialogModal():New()
    oModal:setSize(nAddHeight, nAddWidth) //Height, Width
    oModal:SetEscClose(.T.)
    oModal:setTitle('Inserir Obs')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oGet := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cObs := u, cObs ) }, oModal:getPanelMain(), (nAddWidth - 03), (nAddHeight - 70), , , , , , .T. )
    oModal:Activate()
    if !empty(cObs)
        if MsgYesNo('Confirma Observação?','Confirmar')
            oInfo := JsonObject():new()
            oInfo:FromJson((cAls)->ZZ9_JSINFO)
            if ValType(oInfo:GetJsonObject('Financeiro')) <> 'U'
                oInfo['Financeiro']['Obs']  := cObs
                oInfo['Financeiro']['User'] := RetCodUsr()
                oInfo['Financeiro']['Data'] := DtoC(Date())
                oInfo['Financeiro']['Hora'] := time()
            else
                oJson := JsonObject():new()
                oJson['Obs']  := cObs
                oJson['User'] := RetCodUsr()
                oJson['Data'] := DtoC(Date())
                oJson['Hora'] := time()
                oInfo['Financeiro'] := oJson
            endif
            oCtrl:define((cAls)->ZZ9_ORDCAR)
            oCtrl:update({{'ZZ9_JSINFO', oInfo:ToJson()}}, (cAls)->ZZ9_ORDSEP)
        endif
    endif
    FreeObj(oJson)
    FreeObj(oInfo)
    FreeObj(oCtrl)
    FreeObj(oGet)
    FreeObj(oModal)
    RestArea(aAreaZZ9)
    RestArea(aAreaAls)
    RestArea(aArea)
return(nil)
