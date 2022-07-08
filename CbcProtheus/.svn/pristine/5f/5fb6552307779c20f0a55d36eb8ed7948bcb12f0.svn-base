#include 'Totvs.ch'
#include "RPTDef.ch"
#include "FWPrintSetup.ch"

user function cbcNFAlmox() //35210609019651000106550010000174701784680655
    private cChv        := ""
    private cTipo       := "NF"
    private cCodUniq    := ""

    if TelaPerg()
        // Chamando CursorArrow() força a CursorWait() mostrar o cursor de ampulheta sempre.
        CursorArrow()
        CursorWait()

        // iniciar View
        FWMsgRun(, { || initView() }, 	"Integracao Almoxarifado", "Iniciando...")
    endif
return(nil)

static function TelaPerg()
    local oModal 		:= nil
	local oGet		    := nil
    local oPnl	 		:= nil
    local oRadio        := nil
	local oFont			:= TFont():New("Arial",,30,,.T.)
	//local bConfirm 		:= { || oModal:DeActivate() }
    local aButtons      := {}
	local aOptions      := {'N.Fiscal','Ped.Compra'}
    local nOpc          := 1
    local lRet          := .T.

	oModal := FWDialogModal():New() 
	oModal:setSize(150,300)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Informe a Origem da Integração')
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	//oModal:addOkButton(bConfirm, "Confirma", {||.T.} )
    aadd(aButtons, {,'Produtos',{||u_cbcIntManut()}, 'Integração Produtos...',,.T.,.F.})
    oModal:addButtons(aButtons)
	oPnl := TPanel():New( ,,, oModal:getPanelMain() ) 
	oPnl:SetCss("")
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT

    chgOpc(nOpc, @oPnl, @oGet)

    oRadio := TRadMenu():New (05, 05, aOptions,,oPnl,,,,,,,,140,30,,,,.T.)
    oRadio:bSetGet := {|u| iif(PCount()==0,nOpc,nOpc:=u)}
    oRadio:lHoriz := .T.
    oRadio:bChange := {|| FWMsgRun(, { || chgOpc(nOpc, @oPnl, @oGet) }, 	"Origem da Integração", "Alterando Origem...") }
    
    setMsgCss(@oModal:oSayTitle)
   	setMsgCss(@oModal:oTop)
    
    oModal:Activate()
    
    if nOpc == 1
        cTipo   := 'NF'
    else
        cTipo   := 'PED'
    endif

    lRet := validChave()

    FreeObj(oGet)
    FreeObj(oFont)
    FreeObj(oPnl)
    FreeObj(oModal)
return(lRet)

static function chgOpc(nOpc, oPnl, oGet)
    local bBlkVld := { || .T. }
    local oFont   := TFont():New("Arial",,30,,.T.)

    FreeObj(oGet)
    if nOpc == 1
        cChv := Space(TamSX3("F1_CHVNFE")[1])
        oGet := TGet():New(40,05, { | u | If( PCount() == 0, cChv,cChv:= u ) },oPnl,290,030,"@!", bBlkVld,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cChv,,,, )
    else
        cChv := Space(TamSX3("C7_NUM")[1])
        oGet := TGet():New(40,05, { | u | If( PCount() == 0, cChv,cChv:= u ) },oPnl,290,030,"@!", bBlkVld,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SC7",cChv,,,, )
    endif
    oPnl:Refresh()
return(.T.)

static function setMsgCss(oObj, cOpc)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
	default cOpc	:= ''
	
	if cTpObj == "TSAY"
		cCss +=	"QLabel { ";
					+"  font-size: 23px; /*Tamanho da fonte*/";
					+"  color: #006d93; /*Cor da fonte*/";
					+"  font-weight: bold; /*Negrito*/";
					+"  text-align: center; /*Alinhamento*/";
					+"  vertical-align: middle; /*Alinhamento*/";
					+"  border-radius: 6px; /*Arrerondamento da borda*/";
					+"}"
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)

static function validChave()
    local aArea    	:= GetArea()
    local aAreaSF1 	:= SF1->(GetArea())
    local aAreaSC7 	:= SC7->(GetArea())
	local lOk       := .F.
	local oSql 		:= LibSqlObj():newLibSqlObj()

    if !empty(cChv)
        if cTipo == 'NF'
            oSql:newTable("SF1", "F1_CHVNFE CHV", "F1_CHVNFE = '" + cChv + "'")
            lOk := oSql:hasRecords()
            cCodUniq := AllTrim(oSql:getValue("CHV"))
        elseif cTipo == 'PED'
            oSql:newTable("SC7", "C7_NUM CHV", "C7_NUM = '" + cChv + "'")
            lOk := oSql:hasRecords()
            cCodUniq := 'PC' + AllTrim(oSql:getValue("CHV"))
        endif   
    endif
	if !lOk
        cCodUniq := ""
        cChv     := ""
        MsgAlert('Chave não localizada!', 'Não Encontrada')
	endif

    FreeObj(oSql)
    RestArea(aAreaSC7)
    RestArea(aAreaSF1)
    RestArea(aArea)
return(lOk)

static function initView()
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oDlgPrinc   := nil
    private oTable      := nil
    private oPanel      := nil
    private oBrw        := nil
    private cAls        := ''
    private oInt        := cbcAlmoxInteg():newcbcAlmoxInteg()
   
    // Componentes Visuais
    DEFINE MSDIALOG oDlgPrinc TITLE 'Integração Almoxarifado' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlgPrinc:lMaximized := .T.

    oPanel := TPanel():New( ,,, oDlgPrinc ) 
	oPanel:SetCss("")
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    mountTable()
    mountBrw()

    CursorArrow()

    Activate MsDialog oDlgPrinc Center

    if oTable <> nil
        oTable:Delete()
    endif

    FreeObj(oTable)
    FreeObj(oPanel)
    FreeObj(oBrw)
    FreeObj(oDlgPrinc)
return(nil)

static function mountTable()
    local aFlds := getFields('T')
    local cQry  := ""

    if cTipo == 'NF'
        cQry := qryAlmoxNF()
    else
        cQry := qryAlmoxPed()
    endif

    oTable := FWTemporaryTable():New(nextAlias())
    oTable:SetFields(aFlds)
    oTable:AddIndex('Codigo',  {aFlds[1,1]} )
    oTable:Create()
    cAls := oTable:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAls))
return(nil)

static function nextAlias()
    local cAls := ''
    while .T.
        cAls := GetNextAlias()
        if (Select(cAls) <= 0)
            exit
        endIf
    endDo
return(cAls)

static function getFields(cOpc)
    local aRet      := {}

    if cOpc == 'B'
        aAdd(aRet, {'Produto',     {|| (oTable:GetAlias())->(COD)} ,GetSx3Cache('B1_COD',  'X3_TIPO'), PesqPict('SB1', 'B1_COD'),  1,TamSx3('B1_COD')[1],  GetSx3Cache('B1_COD', 'X3_DECIMAL')})
        aAdd(aRet, {'Descricao',   {|| (oTable:GetAlias())->(DESCRI)},GetSx3Cache('B1_DESC', 'X3_TIPO'), PesqPict('SB1', 'B1_DESC'), 1,TamSx3('B1_DESC')[1], GetSx3Cache('B1_DESC', 'X3_DECIMAL')})
        aAdd(aRet, {'Quantidade',  {|| (oTable:GetAlias())->(QTD)}, GetSx3Cache('D1_QUANT','X3_TIPO'), PesqPict('SD1', 'D1_QUANT'),1,TamSx3('D1_QUANT')[1],GetSx3Cache('D1_QUANT', 'X3_DECIMAL')})
        //aAdd(aRet, {'Status',      {|| getStatus() },               'C',                               '@!',                       1,15,                   4})
    elseif cOpc == 'T'
        aAdd(aRet, {'COD',   GetSx3Cache('B1_COD',  'X3_TIPO'),   TamSx3('B1_COD')[1],  GetSx3Cache('B1_COD',  'X3_DECIMAL')})
        aAdd(aRet, {'DESCRI',  GetSx3Cache('B1_DESC', 'X3_TIPO'),   TamSx3('B1_DESC')[1], GetSx3Cache('B1_DESC', 'X3_DECIMAL')})
        aAdd(aRet, {'QTD',   GetSx3Cache('D1_QUANT','X3_TIPO'),   TamSx3('D1_QUANT')[1],GetSx3Cache('D1_QUANT','X3_DECIMAL')})
        aAdd(aRet, {'MARK',	 GetSx3Cache('C9_OK',   'X3_TIPO'),   TamSx3('C9_OK')[1],   GetSx3Cache('C9_OK',  'X3_DECIMAL')})
    endif
return(aRet)

static function mountBrw()
    oBrw := FWMarkBrowse():New()
    oBrw:SetFieldMark('MARK')
    oBrw:SetCustomMarkRec({|| doMark()})
    oBrw:SetSemaphore(.T.)
    oBrw:SetOwner( oPanel )
    oBrw:SetDescription('Produtos Integração')
    oBrw:SetAlias(cAls)
    oBrw:SetMenuDef('')
    oBrw:SetFields(getFields('B'))
    oBrw:SetProfileID('PRODALMOX')
    oBrw:ForceQuitButton(.T.)
    oBrw:DisableDetails()
    oBrw:DisableReport()
    oBrw:setIgnoreaRotina(.T.)
    oBrw:SetUseFilter(.T.)
    oBrw:SetSeek(.T.,;
        {;
        {"COD" ,{{"",GetSx3Cache('B1_COD', 'X3_TIPO'),;
        TamSx3('B1_COD')[1], 0,"COD",,PesqPict('SB1', 'B1_COD')}}};
        };
        )
    oBrw:AddLegend("StaticCall(cbcAlmoxNF, getStatus) == 'Integrado'",'BR_VERMELHO',  'Integrada')
    oBrw:AddLegend("StaticCall(cbcAlmoxNF, getStatus) == 'Pendente'", 'BR_VERDE',     'Pendente')
    oBrw:AddLegend("StaticCall(cbcAlmoxNF, getStatus) == 'Cadastro'", 'BR_AMARELO',   'Cadastro')
    oBrw:AddButton('Integrar',      {||FWMsgRun(, {|| doProcess()	},  'Integrar', 'Integrando...')} ,,7,)
    oBrw:AddButton('Marcar Todos',  {||FWMsgRun(, {|| allMark()	},  'Marcar Todos', 'Marcando...')} ,,7,)
    oBrw:AddButton('Cadastro',      {||FWMsgRun(, {|| u_cbcIntManut() },  'Cadastro', 'Cadastrando...')} ,,7,)
    if cTipo == 'PED'
        oBrw:AddButton('Imprimir',      {||FWMsgRun(, {|| printPed() },  'Imprimir', 'Impressão...')} ,,7,)
    endif
    oBrw:Activate()
return(nil)

static function allMark()
	local nRegAtual := 0
	local nMarks	:= 0
	
	oBrw:GoTop(.T.)
	nRegAtual := oBrw:At()
	//Percorrer os registros do browser 
	while .T.
		doMark()			
		nMarks++		
		oBrw:GoDown(1, .F.)
		//Saida do loop Desceu um registro e continuou no mesmo significa que é o ultimo
		if nRegAtual == oBrw:At()
			EXIT
		endIf
		nRegAtual := oBrw:At()
	endDo
	oBrw:GoTop(.T.)    
return(nMarks)

static function doMark()
    local cMarca	:= oBrw:Mark()
    local cFld 		:= oBrw:cFieldMark

    if !((cAls)->(RecLock(cAls, .F.)))
        MsgAlert('Erro ao selecionar Registro!','Error')
    else
        if getStatus() == "Pendente"
            if (cAls)->(&cFld) <> cMarca
                (cAls)->(&cFld) := cMarca
            else
                (cAls)->(&cFld) := ' '
            endif
            (cAls)->(MSUnlock())
        endif
    endif
return(nil)

static function doProcess()
    local oSql      := LibSqlObj():newLibSqlObj()
    local aItems    := {}
    oSql:newAlias(qrySelected(oTable:GetRealName(), oBrw:cFieldMark, oBrw:Mark()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            (cAls)->(DbGoto(oSql:getValue('REC')))
            aAdd(aItems,{AllTrim((cAls)->COD), AllTrim((cAls)->DESCRI),(cAls)->QTD})
            doMark()
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    if empty(aItems)
        MsgAlert('Sem itens para serem integrados!','No Items')
    else
        oInt:fromNFe(cCodUniq, aItems, .T.)
    endif
    oBrw:Refresh(.T.)
return(nil)

static function getStatus()
    local cStatus       := ""
    local nIdAddress    := 0
    local nIdProd       := 0
    local aWhere        := {}
    local cCodBar       := AllTrim((cAls)->COD)
    Local oStatic       := IfcXFun():newIfcXFun()
    
    oStatic:sP(4):pR({3,4}):callStatic('cbcAlmoxInteg', 'chkProdut', .F., cCodBar, @oInt, @nIdProd)
    if nIdProd > 0
        oStatic:sP(4):pR({4,5}):callStatic('cbcAlmoxInteg', 'chkAddress', .F., 'NFE_' + cCodUniq, @oInt, @nIdAddress)
        if nIdAddress > 0
            aAdd(aWhere,{"tipo", "ENTRADA"})
            aAdd(aWhere,{"produtoId", nIdProd})
            if oStatic:sP(3):pR({2}):callStatic('cbcAlmoxInteg', 'chkMovimento', nIdAddress, @oInt, aWhere)
                cStatus := "Integrado"
            else
                cStatus := "Pendente"
            endif
        else
            cStatus := "Pendente"
        endif
    else
        cStatus := "Cadastro"
    endif
return(cStatus)

static function printPed()
    local cLogo	    := '\logo-cobrecom.png'
    local oPrintPvt
    local dDataGer  := Date()
    local cHoraGer  := Time()
    local cCaminho  := ""
    local cArquivo  := ""

    cCaminho  := GetTempPath()
    cArquivo  := "cbcNFAlmox_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)

    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    //oPrintPvt:SetLandscape()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)
    oPrintPvt:StartPage()
    oPrintPvt:SayBitmap(30, 30, cLogo, 95, 30)
    oPrintPvt:Code128(90, 30, cCodUniq, 50,50/*nHeigth*/,.T./*lSay*/,,110)
    oPrintPvt:EndPage()
    //Mostrando o relatório
    oPrintPvt:Preview()
return(nil)

/*QUERY ZONE*/
static function qryAlmoxNF()
    local cQry := ""

    cQry += "SELECT SD1.D1_COD AS [COD], "
    cQry += "SD1.D1_DESCRI AS [DESCRI], "
    cQry += "SUM(SD1.D1_QUANT) AS [QTD] "
    cQry += "FROM " + RetSqlName('SF1') + " SF1 "
    cQry += "INNER JOIN " + RetSqlName('SD1') + " SD1 ON SF1.F1_FILIAL	= SD1.D1_FILIAL "
					    cQry += "AND SF1.F1_DOC		= SD1.D1_DOC "
					    cQry += "AND SF1.F1_SERIE	= SD1.D1_SERIE "
					    cQry += "AND SF1.F1_FORNECE = SD1.D1_FORNECE "
					    cQry += "AND SF1.F1_LOJA	= SD1.D1_LOJA "
					    cQry += "AND SF1.D_E_L_E_T_ = SD1.D_E_L_E_T_ "
    cQry += "WHERE SF1.F1_FILIAL = '" + xFilial('SF1') + "' "
    cQry += "AND SF1.F1_CHVNFE = '" + cChv + "' "
    cQry += "AND SF1.D_E_L_E_T_ = '' "
    cQry += "GROUP BY SD1.D1_COD, SD1.D1_DESCRI "
    cQry += "ORDER BY SD1.D1_COD "
return(cQry)

static function qryAlmoxPed()
    local cQry := ""

    cQry += " SELECT SC7.C7_PRODUTO AS [COD], "
    cQry += " SC7.C7_DESCRI AS [DESCRI], "
    cQry += " SUM(SC7.C7_QUANT) AS [QTD] "
    cQry += " FROM " + RetSqlName('SC7') + " SC7 "
    cQry += " WHERE SC7.C7_FILIAL = '" + xFilial('SC7') + "' "
    cQry += " AND SC7.C7_NUM = '" + cChv + "' "
    cQry += " AND SC7.D_E_L_E_T_ = '' "
    cQry += " GROUP BY SC7.C7_PRODUTO, SC7.C7_DESCRI "
    cQry += " ORDER BY SC7.C7_PRODUTO "
return(cQry)

static function qrySelected(cTbl, cFld, cMark)
    local cQry := ''

    cQry += " SELECT TEMP.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + cTbl + " TEMP "
    cQry += " WHERE TEMP." + cFld + " = '" + cMark + "' "
    cQry += " AND TEMP.D_E_L_E_T_ = '' "
return(cQry)

/*TEST ZONE*/
user function ztstAlmox()
    private cCodUniq := 'PC000823'
    printPed()
return(nil)
