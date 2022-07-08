#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TOTVS.ch'

user function cbcAvalEstoque()
    private dDtFim

    if pergs()
        // iniciar View
        FWMsgRun(, { |oSay| initView(oSay) }, 	"Avaliação de Estoque", "Iniciando...")
    endif
return(nil)

static function pergs()
    local aRet      := {}
    local aPerg     := {}
    local lRet      := .F.

    aadd(aPerg,{1,"Entraga Até: ", dDataBase,"",".T.","",".T.",50,.T.})
    if (lRet := ParamBox(aPerg,"Processamento MRP",@aRet))
        dDtFim := aRet[01]
    endif
return(lRet)

static function initView(oSay)
    local lCloseButt 	:= !(oAPP:lMdi)
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oDlgPrinc   := nil
    private oTable      := nil
    private oTablePrinc := nil
    private oTableUni   := nil
    private oTableMRPxUni:= nil
    private oTableEst   := nil
    private oTableRet   := nil
    private oTableCurv  := nil
    private oFWLayer    := nil
    //private oFWSubLayer := nil
    private oPanelBrw   := nil
    private oPanelCtrl  := nil
    private oPanelDet   := nil
    private oPanelDBrw  := nil
    private oTFolder    := nil
    private oBtnDo		:= nil
    private oBtnPlan    := nil
    private oBtnFim		:= nil
    private oBtnESA     := nil
    private oBrw        := nil
    private oBrwDet     := nil
    private cAls        := ''
    private cAlsPrinc   := ''
    private cAlsUni     := ''
    private cAlsMRPxUni := ''
    private cAlsEst     := ''
    private cAlsRet     := ''
    private cAlsCurv    := ''
    private aFil		:= FWAllFilial()
    private oCombo      := nil
    private cCombo      := ""
    private cFili       := FwFilial()
    private oFont     	:= TFont():New("Arial",,15,,.T.)
    private oSayFilial  := nil
    private oSayTipo    := nil
    private oSayNec     := nil
    private oSayEsaIn   := nil
    private oSayEsaOut  := nil

    // Componentes Visuais
    DEFINE MSDIALOG oDlgPrinc TITLE 'Avaliação de Estoque' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlgPrinc:lMaximized := .T.

    oFWLayer := FWLayer():New()
    oFWLayer:Init(oDlgPrinc, lCloseButt)

    cfgLayout()
    mountCtrl()
    if oSay <> nil
        oSay:SetText('Carregando Dados na Tabela...')
        ProcessMessage()
    endif
    mountTable()
    mntBrwPrinc()
    mntBrwDet()
    mntHeader()
    avalEstoque()

    Activate MsDialog oDlgPrinc Center

    oTablePrinc:Delete()
    oTable:Delete()
    oTableUni:Delete()
    oTableMRPxUni:Delete()
    oTableEst:Delete()
    oTableRet:Delete()
    oTableCurv:Delete()

    FreeObj(oSayFilial)
    FreeObj(oSayTipo)
    FreeObj(oSayNec)
    FreeObj(oSayEsaIn)
    FreeObj(oSayEsaOut)
    FreeObj(oFont)
    FreeObj(oBrwDet)
    FreeObj(oTableUni)
    FreeObj(oTableMRPxUni)
    FreeObj(oTable)
    FreeObj(oTablePrinc)
    FreeObj(oTableEst)
    FreeObj(oTableCurv)
    //FreeObj(oFWSubLayer)
    FreeObj(oFWLayer)
    FreeObj(oPanelDBrw)
    FreeObj(oPanelBrw)
    FreeObj(oPanelCtrl)
    FreeObj(oPanelDet)
    FreeObj(oTFolder)
    FreeObj(oBtnDo)
    FreeObj(oBtnPlan)
    FreeObj(oBtnFim)
    FreeObj(oBtnESA)
    FreeObj(oBrw)
    FreeObj(oDlgPrinc)
return(nil)

static function cfgLayout()
    oFWLayer:AddCollumn('COL_LEFT', 28, .F.)
    oFWLayer:AddCollumn('COL_RIGHT',70, .F.)

    // Coluna Esquerda
    oFWLayer:AddWindow('COL_LEFT', 'WND_CTRL', 'Controle', 20, .T., .F.)
    oPanelCtrl := oFWLayer:GetWinPanel('COL_LEFT', 'WND_CTRL')
    
    oFWLayer:AddWindow('COL_LEFT', 'WND_PRIN', 'Produtos', 80, .T., .F.)
    oPanelBrw := oFWLayer:GetWinPanel('COL_LEFT', 'WND_PRIN')

    // Coluna Direita
    oFWLayer:SetColSplit('COL_LEFT', CONTROL_ALIGN_RIGHT)
    oFWLayer:AddWindow('COL_RIGHT', 'WND_DET', 'Detalhes', 20, .T., .F.)
    oPanelDet := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_DET')
    oFWLayer:AddWindow('COL_RIGHT', 'WND_DBRW', 'Detalhes', 80, .T., .F.)
    oPanelDBrw := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_DBRW')
return(nil)

static function mountCtrl()
    /*
    oGrpProc := TGroup():New( 10,02,57,113,'Processamento',oPanelCtrl,,,.T.)
    oBtnDo 	 := TButton():New( 20, 5,  'Processar', oPanelCtrl ,{|| FWMsgRun(, { || process()}, "Liberar", "Liberando Carga...")},;
        105,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oGrpMnt := TGroup():New( 60,02,107,113,'Detalhes',oPanelCtrl,,,.T.)
    oBtnAdd := TButton():New( 70, 5,  'Analisar', 	oPanelCtrl ,{|| FWMsgRun(, { || mngCarga()},  "Gerador de Carga", "Iniciando...")},;
        105,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    */
    oBtnPlan 	 := TButton():New( 05, 05,  'Exportar', oPanelCtrl ,{|| FWMsgRun(, { || export()}, "Exportar", "Exportando Avaliação de estoque...")},;
        30,15,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnESA 	 := TButton():New( 05, 40,  'ESA', oPanelCtrl ,{|| FWMsgRun(, { || viewEsa()}, "ESA", "Avaliação de estoque...")},;
        30,15,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnDo      := TButton():New( 22, 05, 'Processar',  oPanelCtrl ,{|| FWMsgRun(, { |oSay| processa(oSay)}, "Processar", "Processando MRP...")},;
        30,15,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnFim  := TButton():New( 22, 40, 'Encerrar',  oPanelCtrl ,{||oDlgPrinc:End()},;
        30,15,,,.F.,.T.,.F.,,.F.,,,.F. )

return(nil)

static function mountTable()
    local aFlds     := {}
    local cQry      := ""
    Local oStatic   := IfcXFun():newIfcXFun()

    aFlds := getFields('TBL_ESTOQUE')
    cQry  := oStatic:sP(1):callStatic('qryAvalEstoque', 'qryEstoque', dDtFim)
    oTableEst := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcChgAlias', 'nextAlias'))
    oTableEst:SetFields(aFlds)
    oTableEst:AddIndex('FILIAL', {aFlds[1,1]} )
    oTableEst:AddIndex('PRODUTO',{aFlds[2,1]} )
    oTableEst:Create()
    cAlsEst := oTableEst:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAlsEst))

    //TABELA PRINCIPAL
    aFlds := getFields('TBL')
    cQry  := oStatic:sP(2):callStatic('qryAvalEstoque', 'qryTable', dDtFim, oTableEst:GetRealName())
    oTable := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcChgAlias', 'nextAlias'))
    oTable:SetFields(aFlds)
    oTable:AddIndex('FILIAL', {aFlds[1,1]} )
    oTable:AddIndex('PRODUTO',{aFlds[2,1]} )
    oTable:Create()
    cAls := oTable:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAls))

    /*BRW PRINC*/
    aFlds := getFields('TBL_PRINC')
    cQry  := oStatic:sP(1):callStatic('qryAvalEstoque', 'qryPrinc', oTable:GetRealName())
    
    oTablePrinc := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias'))
    oTablePrinc:SetFields(aFlds)
    oTablePrinc:AddIndex('PRODUTO', {aFlds[1,1]} )
    oTablePrinc:Create()
    cAlsPrinc := oTablePrinc:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAlsPrinc))

    /*TBL UNIMOV*/
    aFlds := getFields('TBL_UNIMOV')
    cQry  := oStatic:sP(1):callStatic('qryAvalEstoque', 'qryLoadUnimov')
    oTableUni := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias'))
    oTableUni:SetFields(aFlds)
    oTableUni:AddIndex('FILIAL',  {aFlds[1,1]} )
    oTableUni:AddIndex('PRODUTO', {aFlds[2,1]} )
    oTableUni:AddIndex('UNIMOV',  {aFlds[3,1]} )
    oTableUni:Create()
    cAlsUni := oTableUni:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAlsUni))

    /*TBL MRP X UNIMOV*/
    aFlds := getFields('TBL_MRPXMOV')
    
    oTableMRPxUni := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias'))
    oTableMRPxUni:SetFields(aFlds)
    oTableMRPxUni:AddIndex('FILIAL', {aFlds[1,1]} )
    oTableMRPxUni:AddIndex('RECMRP', {aFlds[2,1]} )
    oTableMRPxUni:AddIndex('RECMOV', {aFlds[3,1]} )
    oTableMRPxUni:Create()
    cAlsMRPxUni := oTableMRPxUni:GetAlias()

    /*TBL RETRABALHO*/
    aFlds := getFields('TBL_RETRAB')
    
    oTableRet := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias'))
    oTableRet:SetFields(aFlds)
    oTableRet:AddIndex('FILIAL', {aFlds[1,1]} )
    oTableRet:AddIndex('PRODUTO',{aFlds[2,1]} )
    oTableRet:Create()
    cAlsRet := oTableRet:GetAlias()


    /*TBL CURVA*/
    aFlds := getFields('TBL_CURVA')
    cQry  := oStatic:sP(1):callStatic('qryAvalEstoque', 'qryTabCurva')
    oTableCurv := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias'))
    oTableCurv:SetFields(aFlds)
    oTableCurv:AddIndex('FILIAL',  {aFlds[1,1]} )
    oTableCurv:AddIndex('PRODUTO', {aFlds[2,1]} )
    oTableCurv:AddIndex('GRUPO',   {aFlds[4,1]} )
    oTableCurv:Create()
    cAlsCurv := oTableCurv:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAlsCurv))
return(nil)

static function mntBrwPrinc()
    oBrw := FWMBrowse():New()
    oBrw:SetOwner( oPanelBrw )
    oBrw:SetDescription('Produtos')
    oBrw:SetAlias(cAlsPrinc)
    oBrw:SetMenuDef('')
    oBrw:SetFields(getFields('BRW_PRIN'))
    oBrw:SetProfileID('AVALESTPRIN')
    oBrw:ForceQuitButton(.T.)
    oBrw:DisableDetails()
    oBrw:DisableReport()
    oBrw:setIgnoreaRotina(.T.)
    oBrw:SetUseFilter(.T.)
    oBrw:SetChange({ || chgLine()})
    oBrw:SetSeek(.T.,;
        {;
        {"PRODUTO" ,{{"",GetSx3Cache('C9_PRODUTO', 'X3_TIPO'),;
        TamSx3('C9_PRODUTO')[1],;
        0,"PRODUTO",,PesqPict('SC9', 'C9_PRODUTO')}}}};
        )
    oBrw:Activate()
return(nil)

static function mntBrwDet()
    oBrwDet := FWMBrowse():New()
    oBrwDet:SetOwner( oPanelDBrw )
    oBrwDet:SetDescription('Detalhes')
    oBrwDet:SetAlias(cAls)
    oBrwDet:SetMenuDef('')
    oBrwDet:SetFields(getFields('BRW_DET'))
    oBrwDet:SetProfileID('AVALDET')
    oBrwDet:ForceQuitButton(.T.)
    oBrwDet:DisableDetails()
    oBrwDet:DisableReport()
    oBrwDet:setIgnoreaRotina(.T.)
    oBrwDet:SetUseFilter(.T.)
    oBrwDet:SetFilterDefault("FILIAL == '" + AllTrim(cFili) + "'")
    //oBrwDet::SetChange({ || chgLine('DET')})
    oBrwDet:SetSeek(.T.,;
        {;
        {"PRODUTO" ,{{"",GetSx3Cache('C9_PRODUTO', 'X3_TIPO'),;
        TamSx3('C9_PRODUTO')[1],;
        0,"PRODUTO",,PesqPict('SC9', 'C9_PRODUTO')}}}};
        )
    oBrwDet:Activate()
return(nil)

static function getFields(cOpc)
    local aRet      := {}

    if cOpc == 'BRW_PRIN'
        aAdd(aRet, {'Produto',     {|| (cAlsPrinc)->(PRODUTO)}, GetSx3Cache('C9_PRODUTO','X3_TIPO'),PesqPict('SC9', 'C9_PRODUTO'),1,TamSx3('C9_PRODUTO')[1], GetSx3Cache('C9_PRODUTO', 'X3_DECIMAL')})
        aAdd(aRet, {'Descrição',   {|| (cAlsPrinc)->(DESCRI)},  GetSx3Cache('B1_DESC','X3_TIPO'),   PesqPict('SB1', 'B1_DESC'),   1,TamSx3('B1_DESC')[1],    GetSx3Cache('B1_DESC', 'X3_DECIMAL')})
    elseif cOpc == 'BRW_DET'
        aAdd(aRet, {'Filial',      {|| (cAls)->(FILIAL)},  GetSx3Cache('C9_FILIAL','X3_TIPO'),  PesqPict('SC9', 'C9_FILIAL'), 1,TamSx3('C9_FILIAL')[1],   GetSx3Cache('C9_FILIAL', 'X3_DECIMAL')})
        aAdd(aRet, {'Produto',     {|| (cAls)->(PRODUTO)}, GetSx3Cache('C9_PRODUTO','X3_TIPO'), PesqPict('SC9', 'C9_PRODUTO'),1,TamSx3('C9_PRODUTO')[1],  GetSx3Cache('C9_PRODUTO', 'X3_DECIMAL')})
        aAdd(aRet, {'Descrição',   {|| (cAls)->(DESCRI)},  GetSx3Cache('B1_DESC','X3_TIPO'),    PesqPict('SB1', 'B1_DESC'),   1,TamSx3('B1_DESC')[1],     GetSx3Cache('B1_DESC', 'X3_DECIMAL')})
        aAdd(aRet, {'Acondic.',    {|| (cAls)->(ACONDIC)}, GetSx3Cache('BF_LOCALIZ','X3_TIPO'), PesqPict('SBF', 'BF_LOCALIZ'),1,TamSx3('BF_LOCALIZ')[1],  GetSx3Cache('BF_LOCALIZ', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.Req.',    {|| (cAls)->(NECESSI)}, GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.Seg.',    {|| (cAls)->(SEGURO)},  GetSx3Cache('ZAI_ESTSEG','X3_TIPO'), PesqPict('ZAI', 'ZAI_ESTSEG'),1,TamSx3('ZAI_ESTSEG')[1],  GetSx3Cache('ZAI_ESTSEG', 'X3_DECIMAL')})
        aAdd(aRet, {'Estoque',     {|| (cAls)->(ESTOQUE)}, GetSx3Cache('B2_QATU','X3_TIPO'),    PesqPict('SB2', 'B2_QATU'),   1,TamSx3('B2_QATU')[1],     GetSx3Cache('B2_QATU', 'X3_DECIMAL')})
        aAdd(aRet, {'Solici.',     {|| (cAls)->(SOLICIT)}, GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Transito',    {|| (cAls)->(TRANSIT)}, GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.MRP',     {|| (cAls)->(MRP)},     GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.Exced.',  {|| (cAls)->(EXCEDE)},  GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.Produz',  {|| (cAls)->(PRODUZ)},  GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.Transf',  {|| (cAls)->(TRANSF)},  GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.ESA',     {|| (cAls)->(ESA)},     GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
        aAdd(aRet, {'Qtd.Retrab',  {|| (cAls)->(RETRAB)},   GetSx3Cache('C2_QUANT','X3_TIPO'),   PesqPict('SC2', 'C2_QUANT'),  1,TamSx3('C2_QUANT')[1],    GetSx3Cache('C2_QUANT', 'X3_DECIMAL')})
    elseif cOpc == 'TBL'
        aAdd(aRet, {'FILIAL',   GetSx3Cache('C9_FILIAL', 'X3_TIPO'),TamSx3('C9_FILIAL')[1],  GetSx3Cache('C9_FILIAL', 'X3_DECIMAL')})
        aAdd(aRet, {'PRODUTO',  GetSx3Cache('C9_PRODUTO','X3_TIPO'),TamSx3('C9_PRODUTO')[1], GetSx3Cache('C9_PRODUTO','X3_DECIMAL')})
        aAdd(aRet, {'DESCRI',   GetSx3Cache('B1_DESC','X3_TIPO'),   TamSx3('B1_DESC')[1],    GetSx3Cache('B1_DESC','X3_DECIMAL')})
        aAdd(aRet, {'ACONDIC',  GetSx3Cache('BF_LOCALIZ','X3_TIPO'),TamSx3('BF_LOCALIZ')[1], GetSx3Cache('BF_LOCALIZ','X3_DECIMAL')})
        aAdd(aRet, {'TIPO',     'C',                                12,                      0})
        aAdd(aRet, {'NECESSI',  GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'SEGURO',   GetSx3Cache('ZAI_ESTSEG','X3_TIPO'),TamSx3('ZAI_ESTSEG')[1], GetSx3Cache('ZAI_ESTSEG','X3_DECIMAL')})
        aAdd(aRet, {'ECONOM',   GetSx3Cache('ZAI_LTECON','X3_TIPO'),TamSx3('ZAI_LTECON')[1], GetSx3Cache('ZAI_LTECON','X3_DECIMAL')})
        aAdd(aRet, {'ESTOQUE',  GetSx3Cache('B2_QATU','X3_TIPO'),   TamSx3('B2_QATU')[1],    GetSx3Cache('B2_QATU',   'X3_DECIMAL')})
        aAdd(aRet, {'SOLICIT',  GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'TRANSIT',  GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'MRP',      GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'EXCEDE',   GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'PRODUZ',   GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'TRANSF',   GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'ESA',      GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'METRAGE',  GetSx3Cache('C6_METRAGE','X3_TIPO'),TamSx3('C6_METRAGE')[1], GetSx3Cache('C6_METRAGE','X3_DECIMAL')})
        aAdd(aRet, {'RETRAB',    GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
    elseif cOpc == 'TBL_PRINC'
        aAdd(aRet, {'PRODUTO',  GetSx3Cache('C9_PRODUTO','X3_TIPO'),TamSx3('C9_PRODUTO')[1], GetSx3Cache('C9_PRODUTO','X3_DECIMAL')})
        aAdd(aRet, {'DESCRI',   GetSx3Cache('B1_DESC','X3_TIPO'),   TamSx3('B1_DESC')[1],    GetSx3Cache('B1_DESC','X3_DECIMAL')})
        //aAdd(aRet, {'TIPO',     'C',                                12,                      0})
    elseif cOpc == 'TBL_UNIMOV'
        aAdd(aRet, {'FILIAL',   GetSx3Cache('C9_FILIAL', 'X3_TIPO'),TamSx3('C9_FILIAL')[1],  GetSx3Cache('C9_FILIAL', 'X3_DECIMAL')})
        aAdd(aRet, {'PRODUTO',  GetSx3Cache('C9_PRODUTO','X3_TIPO'),TamSx3('C9_PRODUTO')[1], GetSx3Cache('C9_PRODUTO','X3_DECIMAL')})
        aAdd(aRet, {'DESCR',    GetSx3Cache('B1_DESC','X3_TIPO'),   TamSx3('B1_DESC')[1],    GetSx3Cache('B1_DESC','X3_DECIMAL')})
        aAdd(aRet, {'UNIMOV',   'N',                                12,                      0})
        aAdd(aRet, {'SALDO',    GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'QTDORIG',    GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
    elseif cOpc == 'TBL_MRPXMOV'
        aAdd(aRet, {'FILIAL',   GetSx3Cache('C9_FILIAL', 'X3_TIPO'),TamSx3('C9_FILIAL')[1],  GetSx3Cache('C9_FILIAL', 'X3_DECIMAL')})
        aAdd(aRet, {'RECMRP',  'N',                                12,                      0})
        aAdd(aRet, {'RECMOV',  'N',                                12,                      0})
        aAdd(aRet, {'QTD',     GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
    elseif cOpc == 'TBL_ESTOQUE'
        aAdd(aRet, {'FILIAL',   GetSx3Cache('C9_FILIAL', 'X3_TIPO'),TamSx3('C9_FILIAL')[1],  GetSx3Cache('C9_FILIAL', 'X3_DECIMAL')})
        aAdd(aRet, {'PRODUTO',  GetSx3Cache('C9_PRODUTO','X3_TIPO'),TamSx3('C9_PRODUTO')[1], GetSx3Cache('C9_PRODUTO','X3_DECIMAL')})
        aAdd(aRet, {'ACONDIC',  GetSx3Cache('BF_LOCALIZ','X3_TIPO'),TamSx3('BF_LOCALIZ')[1], GetSx3Cache('BF_LOCALIZ','X3_DECIMAL')})
        aAdd(aRet, {'METRAGE',  GetSx3Cache('C6_METRAGE','X3_TIPO'),TamSx3('C6_METRAGE')[1], GetSx3Cache('C6_METRAGE','X3_DECIMAL')})
        aAdd(aRet, {'QTDORIG',  GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'QTDMRP',   GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'QTDRETR',   GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
    elseif cOpc == 'TBL_RETRAB'
        aAdd(aRet, {'FILIAL',   GetSx3Cache('C9_FILIAL', 'X3_TIPO'),TamSx3('C9_FILIAL')[1],  GetSx3Cache('C9_FILIAL', 'X3_DECIMAL')})
        aAdd(aRet, {'ID',       GetSx3Cache('C6_NUM','X3_TIPO'),    TamSx3('C6_NUM')[1],     GetSx3Cache('C6_NUM','X3_DECIMAL')})
        aAdd(aRet, {'PRODUTO',  GetSx3Cache('C9_PRODUTO','X3_TIPO'),TamSx3('C9_PRODUTO')[1], GetSx3Cache('C9_PRODUTO','X3_DECIMAL')})
        aAdd(aRet, {'ACONDORI', GetSx3Cache('BF_LOCALIZ','X3_TIPO'),TamSx3('BF_LOCALIZ')[1], GetSx3Cache('BF_LOCALIZ','X3_DECIMAL')})
        aAdd(aRet, {'LANCORI',  GetSx3Cache('C6_LANCES','X3_TIPO'), TamSx3('C6_LANCES')[1],  GetSx3Cache('C6_LANCES','X3_DECIMAL')})
        aAdd(aRet, {'ACONDDEST',GetSx3Cache('BF_LOCALIZ','X3_TIPO'),TamSx3('BF_LOCALIZ')[1], GetSx3Cache('BF_LOCALIZ','X3_DECIMAL')})
        aAdd(aRet, {'LANCDEST', GetSx3Cache('C6_LANCES','X3_TIPO'), TamSx3('C6_LANCES')[1],  GetSx3Cache('C6_LANCES','X3_DECIMAL')})
        aAdd(aRet, {'QTD',      GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL')})
        aAdd(aRet, {'RECEST',   'N',                                11,                      0})
    elseif cOpc == 'TBL_CURVA'
        aAdd(aRet, {'FILIAL',   GetSx3Cache('C9_FILIAL', 'X3_TIPO'),TamSx3('C9_FILIAL')[1],  GetSx3Cache('C9_FILIAL', 'X3_DECIMAL')})
        aAdd(aRet, {'PRODUTO',  GetSx3Cache('C9_PRODUTO','X3_TIPO'),TamSx3('C9_PRODUTO')[1], GetSx3Cache('C9_PRODUTO','X3_DECIMAL')})
        aAdd(aRet, {'ACONDIC',  GetSx3Cache('BF_LOCALIZ','X3_TIPO'),TamSx3('BF_LOCALIZ')[1], GetSx3Cache('BF_LOCALIZ','X3_DECIMAL')})
        aAdd(aRet, {'GRUPO',    'C',                                1,                      0})
        aAdd(aRet, {'METRAGE',  GetSx3Cache('C6_METRAGE','X3_TIPO'),TamSx3('C6_METRAGE')[1], GetSx3Cache('C6_METRAGE','X3_DECIMAL')})
    endif
return(aRet)

static function chgLine(cMyFili)
    default cMyFili := ""
    if !empty(cMyFili)
        cFili := cMyFili
    endif
    if oBrwDet <> nil
        oBrwDet:CleanFilter()
        oBrwDet:SetFilterDefault("FILIAL == '" + AllTrim(cFili) + "' .AND. PRODUTO == '" + (cAlsPrinc)->(PRODUTO) + "'")
		oBrwDet:Refresh(.T.)
        oCombo:Select( Val(cFili) )
        oCombo:Refresh()
        oSayTipo:cCaption := 'Tipo: ' + getTipo(cFili, AllTrim((cAlsPrinc)->(PRODUTO)))
        oSayNec:cCaption := 'Necessidade: ' + cValToChar(somaTotal("NEC",cFili, AllTrim((cAlsPrinc)->(PRODUTO))))
        oSayEsaIn:cCaption := 'ESA(' + AllTrim(FWArrFilAtu(FWGrpCompany(), cFili )[7]) + '): ' + cValToChar(somaESA(.T.,cFili, AllTrim((cAlsPrinc)->(PRODUTO))))
        oSayEsaOut:cCaption := 'ESA(OUTRAS): '   + cValToChar(somaESA(.F.,cFili, AllTrim((cAlsPrinc)->(PRODUTO))))
    endif    
return(.T.)

static function mntHeader()
    local nX        := 0
    local aNameFili := {}
    
    for nX := 1 to len(aFil)
        aAdd(aNameFili, FWArrFilAtu(FWGrpCompany(), aFil[nX] )[7])
    next nX
    oSayFilial	:= TSay():New(05,05,	{||'Filial:'}, oPanelDet,,oFont,,,,.T.,,, 100, 25)
    oCombo := TComboBox():New(15,05,{|u|if(PCount()>0, cCombo:=u, '')},;
        aNameFili,85,20,oPanelDet,,;
        {|| FWMsgRun(, { || chgLine(StrZero(oCombo:nAt,2)) }, 	"Aguarde...", "Alternando Filial...")};
        ,,,,.T.,,,,,,,,,'cCombo')
    oSayTipo	:= TSay():New(10,92,	{||'Tipo: ' + getTipo(cFili, AllTrim((cAlsPrinc)->(PRODUTO)))}, oPanelDet,,oFont,,,,.T.,,, 100, 25) 
    oSayNec	    := TSay():New(30,92,	{||'Necessidade: ' + cValToChar(somaTotal("NEC",cFili, AllTrim((cAlsPrinc)->(PRODUTO))))}, oPanelDet,,oFont,,,,.T.,,, 200, 25)
    oSayEsaIn   := TSay():New(10,165,	{||'ESA(' + AllTrim(FWArrFilAtu(FWGrpCompany(), cFili )[7]) + '): ' + cValToChar(somaESA(.T.,cFili, AllTrim((cAlsPrinc)->(PRODUTO))))}, oPanelDet,,oFont,,,,.T.,,, 200, 25)
    oSayEsaOut  := TSay():New(30,165,	{||'ESA(OUTRAS): '   + cValToChar(somaESA(.F.,cFili, AllTrim((cAlsPrinc)->(PRODUTO))))}, oPanelDet,,oFont,,,,.T.,,, 200, 25)
    oCombo:Select( Val(cFili) )
    oCombo:Refresh()
return(nil)

static function somaTotal(cOpc, cMyFili, cProd)
    local aArea     := GetArea()
    local aAreacAls := (cAls)->(GetArea())
    local aAreacAlsP:= (cAlsPrinc)->(GetArea())
    local nTotal    := 0
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    
    oSql:newAlias(oStatic:sP(4):callStatic('qryAvalEstoque', 'qryTotal', cOpc, cMyFili, cProd, oTable:GetRealName()))
    if oSql:hasRecords()
        oSql:goTop()
        nTotal := oSql:getValue('TOTAL')
    endif
    oSql:Close()
    FreeObj(oSql)
    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nTotal)

static function somaESA(lIn, cMyFili, cProd)
    local aArea     := GetArea()
    local aAreacAls := (cAls)->(GetArea())
    local aAreacAlsP:= (cAlsPrinc)->(GetArea())
    local nTotal    := 0
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(3):callStatic('qryAvalEstoque', 'qryESA', lIn, cMyFili, cProd))
    if oSql:hasRecords()
        oSql:goTop()
        nTotal := oSql:getValue('TOTAL')
    endif
    oSql:Close()
    FreeObj(oSql)
    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nTotal)

static function avalEstoque()
    local aArea     := GetArea()
    local aAreacAls := (cAls)->(GetArea())
    local aAreacAlsP:= (cAlsPrinc)->(GetArea())
    local aAreacAlsE:= (cAlsEst)->(GetArea())
    Local oStatic   := IfcXFun():newIfcXFun()
    
    TcSqlExec(oStatic:sP(2):callStatic('qryAvalEstoque', 'qryDistEst', oTableEst:GetRealName(),oTable:GetRealName()))

    TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'qryMRP', oTable:GetRealName()))
    
    TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'qryExced', oTable:GetRealName()))

    RestArea(aAreacAlsE)
    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nil)

static function export()
    local aArea      := GetArea()
    local aAreacAls  := (cAls)->(GetArea())
    local aAreacAlsP := (cAlsPrinc)->(GetArea())
    local oFWMsExcel := nil
    local nX		 := 0
    local nY         := 0
    local oExcel	 := nil
    local cNomArqv   := GetTempPath() + 'PlanAvalEst_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local aNameFili  := {}
    local aFlds      := getFields("BRW_DET")
    local oSql       := nil
    Local oStatic    := IfcXFun():newIfcXFun()

    for nX := 1 to len(aFil)
        aAdd(aNameFili, AllTrim(FWArrFilAtu(FWGrpCompany(), aFil[nX] )[7]))
    next nX

    oFWMsExcel := FWMSExcel():New()
    
    for nX := 1 to len(aNameFili)
        oFWMsExcel:AddworkSheet(aNameFili[nX])
        oFWMsExcel:AddTable(aNameFili[nX], "MRP")
        for nY := 1 to len(aFlds)
            oFWMsExcel:AddColumn(aNameFili[nX], "MRP",aFlds[nY, 01], 1)
        next nY
        oFWMsExcel:AddColumn(aNameFili[nX], "MRP","Tipo", 1)
    next nX
    oSql       := LibSqlObj():newLibSqlObj() 
    oSql:newAlias(oStatic:sP(1):callStatic('qryAvalEstoque', 'qryExport', oTable:GetRealName()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            oFWMsExcel:AddRow(aNameFili[Val(AllTrim(oSql:getValue('FILIAL')))],"MRP",{;
                AllTrim(oSql:getValue('FILIAL')),;
                AllTrim(oSql:getValue('PRODUTO')),;
                AllTrim(oSql:getValue('DESCRI')),;
                AllTrim(oSql:getValue('ACONDIC')),;
                oSql:getValue('NECESSI'),;
                oSql:getValue('SEGURO'),;
                oSql:getValue('ESTOQUE'),;
                oSql:getValue('SOLICIT'),;
                oSql:getValue('TRANSIT'),;
                oSql:getValue('MRP'),;
                oSql:getValue('EXCEDE'),;
                oSql:getValue('PRODUZ'),;
                oSql:getValue('TRANSF'),;
                oSql:getValue('ESA'),;
                oSql:getValue('RETRAB'),;
                AllTrim(oSql:getValue('TIPO'));
                })
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)

    for nX := 1 to len(aNameFili)
        oFWMsExcel:AddworkSheet("ESA-" + aNameFili[nX])
        oFWMsExcel:AddTable("ESA-" + aNameFili[nX], "ESA")
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","PRODUTO", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","DESCRI", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","ACONDIC", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","UNIMOV", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","MOVCOD", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","MOVDESC", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","QTD", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","QTDORIG", 1)
        oFWMsExcel:AddColumn("ESA-" + aNameFili[nX], "ESA","POSICAO", 1)
    next nX
    oSql       := LibSqlObj():newLibSqlObj() 
    oSql:newAlias(oStatic:sP(3):callStatic('qryAvalEstoque', 'expUnimovs', oTableMRPxUni:GetRealName(), oTable:GetRealName(), oTableUni:GetRealName()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            oFWMsExcel:AddRow("ESA-" + aNameFili[Val(AllTrim(oSql:getValue('FILIAL')))],"ESA",{;
                AllTrim(oSql:getValue('PRODUTO')),;
                AllTrim(oSql:getValue('DESCRI')),;
                AllTrim(oSql:getValue('ACONDIC')),;
                oSql:getValue('UNIMOV'),;
                oSql:getValue('ESACOD'),;
                oSql:getValue('ESADESCR'),;
                oSql:getValue('QTD'),;
                oSql:getValue('QTDORIG'),;
                posicUni(AllTrim(oSql:getValue('UNIMOV')));
                })
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)

    for nX := 1 to len(aNameFili)
        oFWMsExcel:AddworkSheet("Retrab-" + aNameFili[nX])
        oFWMsExcel:AddTable("Retrab-" + aNameFili[nX],  "Retrab")
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","ID", 1)
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","PRODUTO", 1)
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","DESCRI", 1)
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","ORIGEM", 1)
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","LANCORIG", 1)
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","DEST", 1)
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","LANCDEST", 1)
        oFWMsExcel:AddColumn("Retrab-" + aNameFili[nX], "Retrab","QTD", 1)
    next nX
    oSql       := LibSqlObj():newLibSqlObj() 
    oSql:newAlias(oStatic:sP(1):callStatic('qryAvalEstoque', 'expRetrab', oTableRet:GetRealName()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            oFWMsExcel:AddRow("Retrab-" + aNameFili[Val(AllTrim(oSql:getValue('FILIAL')))],"Retrab",{;
                AllTrim(oSql:getValue('ID')),;
                AllTrim(oSql:getValue('PRODUTO')),;
                AllTrim(oSql:getValue('DESCRI')),;
                AllTrim(oSql:getValue('ORIGEM')),;
                oSql:getValue('LANCORI'),;
                AllTrim(oSql:getValue('DESTINO')),;
                oSql:getValue('LANCDEST'),;
                oSql:getValue('QTD');
                })
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)

    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    FreeObj(oFWMsExcel)
    FreeObj(oExcel)

    oBrwDet:SetFilterDefault("FILIAL == '" + AllTrim(cFili) + "' .AND. PRODUTO == '" + (cAlsPrinc)->(PRODUTO) + "'")
    oBrwDet:Refresh(.T.)

    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nil)

static function processa(oSay)
    local aRet      := {}
    local aPergs    := {}
    local aOpera    := {"PRODUCAO", "EXCEDENTE", "ESA","RETRABALHAR"}
    local aOpera2   := {"NADA","PRODUCAO", "EXCEDENTE", "ESA","RETRABALHAR"}
    local lKeep     := .T.
    local nX        := 0
    default oSay    := nil
    
    if oSay <> nil
        oSay:SetText('Verificando Processamentos anterioes')
        ProcessMessage()
    endif
    resetMrp()
    if oSay <> nil
        oSay:SetText('Carregando Parâmetros')
        ProcessMessage()
    endif
    while lKeep
        aAdd( aPergs ,{2, "Operação 01: ", Space(10),      aOpera,  50, ".T.", .T.})
        aAdd( aPergs ,{2, "Operação 02: ", Space(10),      aOpera2, 50, ".T.", .F.})
        aAdd( aPergs ,{2, "Operação 03:",  Space(10),      aOpera2, 50, ".T.", .F.})
        aAdd( aPergs ,{2, "Operação 04:",  Space(10),      aOpera2, 50, ".T.", .F.})

        if !(ParamBox(aPergs ,"Configura Operações", @aRet))
            MsgAlert('Processamento cancelado!','Cancelado')
            lKeep := .F.
        else
            if validBox(aRet, @oSay)
                lKeep := .F.
                for nX := 1 to len(aRet)
                    if oSay <> nil
                        oSay:SetText('Processando Operação: ' + cValtoChar(nX)  + ' de ' + cValToChar(len(aRet)))
                        ProcessMessage()
                    endif
                    if aRet[nX] <> "NADA"
                        execOper(aRet[nX], @oSay)
                    endif
                next nX
            endif
        endif
    endDo
return(nil)

static function validBox(aOpc, oSay)
    local lRet := .T.
    local cMsg := ""

    if oSay <> nil
        oSay:SetText('Validando Operações selecionadas...')
        ProcessMessage()
    endif
    if (lRet := MV_PAR02 == 'NADA' .or. (MV_PAR02 <> MV_PAR01 .and. MV_PAR02 <> MV_PAR03))    
        if !(lRet := MV_PAR03 == 'NADA' .or. (MV_PAR03 <> MV_PAR01 .and. MV_PAR03 <> MV_PAR02))
            cMsg := "Operacao 03 Invalida!"
        endif
    else
        cMsg := "Operacao 02 Invalida!"
    endif
    if !lRet
        alert(cMsg)
    endif
return(lRet)

static function execOper(cOper, oSay)
    if cOper == "PRODUCAO"
        produzir(@oSay)
    elseif cOper == "EXCEDENTE"
        transferir(@oSay)
    elseif cOper == "ESA"
        fracionar(@oSay)
    elseif cOper == "RETRABALHAR"
        retrabalhar(@oSay)
    endif
return(nil)

static function produzir(oSay)
    local aArea     := GetArea()
    local aAreacAls := (cAls)->(GetArea())
    local aAreacAlsP:= (cAlsPrinc)->(GetArea())
    Local oStatic   := IfcXFun():newIfcXFun()
    
    if oSay <> nil
        oSay:SetText('Processando Produções...')
        ProcessMessage()
    endif
    TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'qryProduzir', oTable:GetRealName()))

    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nil)

static function transferir(oSay)
    local aArea     := GetArea()
    local aAreacAls := (cAls)->(GetArea())
    local aAreacAlsP:= (cAlsPrinc)->(GetArea())
    Local oStatic   := IfcXFun():newIfcXFun()
    
    if oSay <> nil
        oSay:SetText('Processando Transferências...')
        ProcessMessage()
    endif
    TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'qryTransferir', oTable:GetRealName()))

    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nil)

static function retrabalhar(oSay)
    local aArea     := GetArea()
    local aAreacAls := (cAls)->(GetArea())
    local aAreacAlsP:= (cAlsPrinc)->(GetArea())
    local aAreacAlsE:= (cAlsEst)->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj() 
    Local oStatic    := IfcXFun():newIfcXFun()
    local oSql2     := nil
    local nX        := 0
    local nID       := 0
    local nLances   := 0
    local nNecess   := 0
    local nTotProd  := 0
    local cUseID    := ""

    if oSay <> nil
        oSay:SetText('Processando Retrabalhos...')
        ProcessMessage()
    endif
    //TcSqlExec(StaticCall(qryAvalEstoque, qryNegociar, oTable:GetRealName()))
    oSql:newAlias(oStatic:sP(1):callStatic('qryAvalEstoque', 'qryLoadRetrab', oTable:GetRealName()))
    if oSql:hasRecords()
        nTotProd := oSql:Count()
        oSql:goTop()
        while oSql:notIsEof()
            nX++
            if oSay <> nil
                oSay:SetText('Processando: ' + cValtoChar(nX)  + ' de ' + cValToChar(nTotProd))
                ProcessMessage()
            endif
            nNecess := oSql:getValue('NECESS')
            oSql2  := LibSqlObj():newLibSqlObj()
            oSql2:newAlias(oStatic:sP(6):callStatic('qryAvalEstoque', 'sldDisponi',; 
                                    oTableEst:GetRealName(),; 
                                    oTableRet:GetRealName(),;
                                    oSql:getValue('FILIAL'),;
                                    oSql:getValue('PRODUTO'),;
                                    oSql:getValue('METRAGE'),;
                                    oSql:getValue('NECESS');
                                    ))
            if oSql2:hasRecords()
                oSql2:goTop()
                while oSql2:notIsEof() .and. nNecess > 0
                    if oSql2:getValue('SALDO') >= nNecess
                        nUsar := nNecess
                    else
                        nUsar := ((INT(oSql2:getValue('SALDO') / oSql:getValue('METRAGE'))) * oSql:getValue('METRAGE'))
                    endif
                    if nUsar > 0
                        if oSql2:getValue('ID') == '000000'
                            nID++
                            cUseID  := StrZero(nID, TamSx3('C6_NUM')[1])
                            nLances := Ceiling((nUsar / oSql2:getValue('METRAGE')))
                        else
                            cUseID  := oSql2:getValue('ID')
                            nLances := 0
                        endif
                        grvRetrab({{oSql:getValue('FILIAL'),;
                                    cUseID,;
                                    oSql:getValue('PRODUTO'),;
                                    oSql2:getValue('ACONDIC'),;
                                    nLances,;
                                    oSql:getValue('ACONDIC'),;
                                    (nUsar / oSql:getValue('METRAGE')),;
                                    nUsar,;
                                    oSql2:getValue('REC')}})
                        nNecess := (nNecess - nUsar)
                    endif
                    oSql2:Skip()
                endDo
            endif
            oSql2:Close()
            FreeObj(oSql2)
            TcSqlExec(oStatic:sP(3):callStatic('qryAvalEstoque', 'grvRetrab',; 
                                                     oTable:GetRealName(),;
                                                     oSql:getValue('REC'),;
                                                     (oSql:getValue('NECESS') - nNecess);
                                                     ))
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)

    avalSobrasRet(@oSay)

    RestArea(aAreacAlsE)
    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nil)

static function avalSobrasRet(oSay)
    local oSql      := nil
    local nTota     := 0
    local nX        := 0
    Local oStatic   := IfcXFun():newIfcXFun()
    
    if oSay <> nil
        oSay:SetText('Avaliando Sobras...')
        ProcessMessage()
    endif

    oSql := LibSqlObj():newLibSqlObj() 
    oSql:newAlias(oStatic:sP(1):callStatic('qryAvalEstoque', 'qrySobras', oTableRet:GetRealName()))
    if oSql:hasRecords()
        nTota := oSql:Count()
        oSql:goTop()
        while oSql:notIsEof()
            nX++
            if oSay <> nil
                oSay:SetText('Processando: ' + cValtoChar(nX)  + ' de ' + cValToChar(nTota))
                ProcessMessage()
            endif
            if oSql:getValue('SOBRA') > 0
                direcionaSobra(oSql:getValue('FILIAL'), oSql:getValue('ID'), oSql:getValue('PRODUTO'), oSql:getValue('ACONDORI'), oSql:getValue('RECEST'),oSql:getValue('SOBRA'))
            endif
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
return(nil)

static function direcionaSobra(cFili, cID, cProd, cAcondOri, nRecEst, nSobra)
    local oSql      := nil
    local nQtd      := nSobra
    local nLances   := 0
    local nUsar     := 0
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql := LibSqlObj():newLibSqlObj() 
    oSql:newAlias(oStatic:sP(4):callStatic('qryAvalEstoque', 'qryAvalSobra', oTableCurv:GetRealName(), cFili, cProd,nQtd))
    if oSql:hasRecords()
        oSql:goTop()
        nLances := INT(nQtd / oSql:getValue('METRAGE'))
        nUsar := (nLances * oSql:getValue('METRAGE'))
        grvRetrab({{cFili,cID,cProd,cAcondOri,0,oSql:getValue('ACONDIC'),nLances,nUsar,nRecEst}})
        nQtd := (nQtd - nUsar)
        if nQtd > 0
            direcionaSobra(cFili, cID, cProd, cAcondOri, nRecEst, nQtd)
        endif
    else
        grvRetrab({{cFili,cID,cProd,cAcondOri,0,'SUCATA',1,nQtd,nRecEst}})
    endif
    oSql:Close()
    FreeObj(oSql)
return(nil)

static function grvRetrab(aRetrab)
    local aArea         := GetArea()
    local aAreacAlsRet  := (cAlsRet)->(GetArea())
    local nX            := 0
    Local oStatic       := IfcXFun():newIfcXFun()

    for nX := 1 to len(aRetrab)
        Reclock(cAlsRet, .T.)
            (cAlsRet)->FILIAL   := aRetrab[nX, 01]
            (cAlsRet)->ID       := aRetrab[nX, 02]
            (cAlsRet)->PRODUTO  := aRetrab[nX, 03]
            (cAlsRet)->ACONDORI := aRetrab[nX, 04]
            (cAlsRet)->LANCORI  := aRetrab[nX, 05]
            (cAlsRet)->ACONDDEST:= aRetrab[nX, 06]
            (cAlsRet)->LANCDEST := aRetrab[nX, 07]
            (cAlsRet)->QTD      := aRetrab[nX, 08]
            (cAlsRet)->RECEST   := aRetrab[nX, 09]
        (cAlsRet)->(MsUnLock())
        TcSqlExec(oStatic:sP(3):callStatic('qryAvalEstoque', 'grvEstRet',; 
                                            oTableEst:GetRealName(),;
                                            aRetrab[nX, 09],;
                                            aRetrab[nX, 08];
                                            ))
    next nX

    RestArea(aAreacAlsRet)
    RestArea(aArea)
return(nil)

static function fracionar(oSay)
    local oSql      := LibSqlObj():newLibSqlObj() 
    Local oStatic   := IfcXFun():newIfcXFun()
    local oSql2     := nil
    local nSaldo    := 0
    local nUsar     := 0
    local nTotProd  := 0
    local nTotUni   := 0
    local nX        := 0
    local nY        := 0

    oSql:newAlias(oStatic:sP(1):callStatic('qryAvalEstoque', 'qryloadEsa', oTable:GetRealName()))
    if oSql:hasRecords()
        nTotProd := oSql:Count()
        oSql:goTop()
        while oSql:notIsEof()
            nX++
            if oSay <> nil
                oSay:SetText('Processando produto: ' + cValtoChar(nX)  + ' de ' + cValToChar(nTotProd))
                ProcessMessage()
            endif
            nY     := 0
            nSaldo := 0
            oSql2  := LibSqlObj():newLibSqlObj()
            oSql2:newAlias(oStatic:sP(4):callStatic('qryAvalEstoque', 'qrygetUnimovs',; 
                                    oTableUni:GetRealName(),; 
                                    oSql:getValue('FILIAL'),;
                                    oSql:getValue('PRODUTO'),;
                                    oSql:getValue('METRAGE');
                                    ))
            if oSql2:hasRecords()
                nTotUni := oSql2:Count()
                nSaldo := oSql:getValue('SALDO')
                oSql2:goTop()
                while oSql2:notIsEof() .and. nSaldo > 0
                    nY++
                    if oSay <> nil
                        oSay:SetText('Produto ' + AllTrim(oSql:getValue('PRODUTO')) + ' - Processando Unimovs: ' + cValtoChar(nY)  + ' de ' + cValToChar(nTotUni))
                        ProcessMessage()
                    endif
                    nUsar := 0
                    if oSql2:getValue('SALDO') >= nSaldo
                        nUsar := nSaldo
                    else
                        nUsar := (Int(oSql2:getValue('SALDO') / oSql:getValue('METRAGE')) * oSql:getValue('METRAGE'))
                    endif
                    if nUsar > 0
                        Reclock(cAlsMRPxUni, .T.)
                            (cAlsMRPxUni)->FILIAL := oSql:getValue('FILIAL')
                            (cAlsMRPxUni)->RECMRP := oSql:getValue('REC')
                            (cAlsMRPxUni)->RECMOV := oSql2:getValue('REC')
                            (cAlsMRPxUni)->QTD    := nUsar
                        (cAlsMRPxUni)->(MsUnLock())
                        TcSqlExec(oStatic:sP(3):callStatic('qryAvalEstoque', 'grvUniSaldo',; 
                                                            oTableUni:GetRealName(),;
                                                            oSql2:getValue('REC'),;
                                                            nUsar;
                                                            ))
                    endif
                    nSaldo -= nUsar
                    oSql2:Skip()
                endDo
                TcSqlExec(oStatic:sP(3):callStatic('qryAvalEstoque', 'grvESASaldo',; 
                                                     oTable:GetRealName(),;
                                                     oSql:getValue('REC'),;
                                                     (oSql:getValue('SALDO') - nSaldo);
                                                     ))
            endif
            oSql2:Close()
            FreeObj(oSql2)
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
return(nil)

static function viewEsa()
    local aArea         := GetArea()
    local aAreacAls     := (cAls)->(GetArea())
    local aAreacAlsP    := (cAlsPrinc)->(GetArea())
    local aAreacUni     := (cAlsUni)->(GetArea())
    local aAreaUnixMrp  := (cAlsMRPxUni)->(GetArea())
    local lCloseButt 	:= !(oAPP:lMdi)
    local oMFWLayer      := FWLayer():New()
    local nAddHeight    := (aCoors[3] * 0.5)
    local nAddWidth     := (aCoors[4] * 0.5)
    private oModal      := nil
    private oBrwMRPXUNI := nil
    private oBrwUni     := nil
    private oBrwMRP     := nil
    private oPanelU     := nil
    private oPanelD     := nil
    private oPanelMRP   := nil

    oModal  := FWDialogModal():New()
    oModal:setSize(nAddHeight, nAddWidth) //Height, Width
    oModal:SetEscClose(.T.)
    oModal:setTitle('Estoque ESA')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")

    oMFWLayer:Init(oModal:getPanelMain(), lCloseButt)
    
    //LINHA CIMA
    oMFWLayer:addLine('UP', 50)
    oMFWLayer:AddCollumn('COL',100, .F.,'UP')
    oMFWLayer:AddWindow('COL', 'WND_UNI', 'Unimovs', 100, .T., .F.,,'UP')
    oPanelU := oMFWLayer:GetWinPanel('COL', 'WND_UNI','UP')

    //LINHA BAIXO
    oMFWLayer:addLine('DW', 50)
    oMFWLayer:AddCollumn('COL_L',50, .F.,'DW')
    oMFWLayer:AddWindow('COL_L', 'WND_MRP', 'MRP', 100, .T., .F.,,'DW')
    oPanelMRP := oMFWLayer:GetWinPanel('COL_L', 'WND_MRP','DW')

    oMFWLayer:AddCollumn('COL_R',50, .F.,'DW')
    oMFWLayer:AddWindow('COL_R', 'WND_FRAC', 'Fracionar', 100, .T., .F.,,'DW')
    oPanelD := oMFWLayer:GetWinPanel('COL_R', 'WND_FRAC','DW')

    mntBrw('UNI',       @oBrwUni,       @oPanelU)
    mntBrw('MRPXUNI',   @oBrwMRPXUNI,   @oPanelD)
    mntBrw('MRP',       @oBrwMRP,       @oPanelMRP)

    oModal:Activate()

    RestArea(aAreacUni)
    RestArea(aAreaUnixMrp)
    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
    chgLine()
    FreeObj(oPanelMRP)
    FreeObj(oPanelD)
    FreeObj(oPanelU)
    FreeObj(oBrwMRPXUNI)
    FreeObj(oBrwUni)
    FreeObj(oBrwMRP)
    FreeObj(oMFWLayer)
    FreeObj(oModal)
return(nil)

static function mntBrw(cOpc, oGrid, oPnl)
    oGrid := FWBrowse():New()
    oGrid:DisableReport()
    //oGrid:DisableFilter()
    //oGrid:DisableConfig()
    oGrid:SetSeek()
    oGrid:SetFontBrowse(oFont)
    oGrid:SetOwner(oPnl)
    oGrid:SetTypeMove(0)
    oGrid:SetDataTable(.T.)
    if cOpc == 'UNI'
        oGrid:SetAlias(cAlsUni)
        oGrid:SetProfileID('BRWUNI')
        oGrid:SetFilterDefault("FILIAL == '" + AllTrim(cFili) + "' .AND. PRODUTO == '" + getEsa(AllTrim((cAlsPrinc)->(PRODUTO))) + "'")
        oGrid:SetChange({ || setRelation(.T.)})
    elseif cOpc == 'MRP'
        oGrid:SetAlias(cAls)
        oGrid:SetProfileID('BRWMRP')
        oGrid:SetFilterDefault("FILIAL == '" + AllTrim(cFili) + "' .AND. PRODUTO == '" + (cAlsPrinc)->(PRODUTO) + "'")
        oGrid:SetChange({ || setRelation(.F.)})
        oGrid:SetDoubleClick({|| FWMsgRun(, {|| addFrac()},'Adiciona Fracionamento','Adicionamento...')})
    else
        oGrid:SetAlias(cAlsMRPxUni)
        oGrid:SetProfileID('BRWMRPXUNI')
        oGrid:SetFilterDefault("FILIAL == '" + AllTrim(cFili) + "' .AND. RECMOV == " + cValToChar((cAlsUni)->(Recno())) + " .AND. RECMRP == " + cValToChar((cAls)->(Recno())) )
        oGrid:SetDoubleClick({|| FWMsgRun(, {|| removeFrac()},'Remover Fracionamento','Removendo...')})
    endif
    oGrid:SetColumns(mntFields(cOpc,'C'))
    oGrid:SetFieldFilter(mntFields(cOpc))
    oGrid:Activate()
return(nil)

static function getEsa(cProd)
    local cEsa      := ""
    local oSql      := LibSqlObj():newLibSqlObj() 
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(1):callStatic('qryAvalEstoque', 'qrygetEsa', cProd))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            cEsa    := AllTrim(oSql:getValue('PROD'))
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
return(cEsa)

static function setRelation(lMrp)
    default lMrp := .T.
    if oBrwMRPXUNI <> nil
        oBrwMRPXUNI:CleanFilter()
        oBrwMRPXUNI:SetFilterDefault("FILIAL == '" + AllTrim(cFili) + "' .AND. RECMOV == " + cValToChar((cAlsUni)->(Recno())) + " .AND. RECMRP == " + cValToChar((cAls)->(Recno())) )
		oBrwMRPXUNI:Refresh(.T.)
    endif
    if lMrp
        if oBrwMRP <> nil
            oBrwMRP:Refresh(.T.)
        endif
    endif
return(nil)

static function mntFields(cOpc, cTp)
    local aHeader    := {}
    local aRet       := {}
    local nX         := 0
    default cTp      := ''

    if cOpc == 'UNI'
        cGrid := 'oBrwUni'
        aAdd(aHeader, {'UNIMOV', 'Unimov', 'N', 12, 0,   '@E 999999999999'})
        aAdd(aHeader, {'QTDORIG', 'Qtd.Orig', GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL'), PesqPict('SC2', 'C2_QUANT')})
        aAdd(aHeader, {'SALDO',   'Saldo',    GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL'), PesqPict('SC2', 'C2_QUANT')})
    elseif cOpc == 'MRP'
        cGrid := 'oBrwMRP'
        aAdd(aHeader, {'StaticCall(cbcAvalEstoque, isUtiliza, (cAls)->(Recno()), (cAlsUni)->(Recno()))', 'Util.', 'C', 01, 0,   '@!'})
        aAdd(aHeader, {'ACONDIC', 'Acondic.', GetSx3Cache('BF_LOCALIZ','X3_TIPO'),TamSx3('BF_LOCALIZ')[1], GetSx3Cache('BF_LOCALIZ','X3_DECIMAL'), PesqPict('SBF', 'BF_LOCALIZ')})
        aAdd(aHeader, {'MRP - (ESA+PRODUZ+TRANSF)',   'Pendente',    GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL'), PesqPict('SC2', 'C2_QUANT')})
        aAdd(aHeader, {'ESA',   'Qtd.ESA',    GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL'), PesqPict('SC2', 'C2_QUANT')})
    else
        cGrid := 'oBrwMRPXUNI'
        aAdd(aHeader, {'StaticCall(cbcAvalEstoque, getAcondic, (cAlsMRPxUni)->(RECMRP))', 'Acondic.', GetSx3Cache('BF_LOCALIZ','X3_TIPO'),TamSx3('BF_LOCALIZ')[1], GetSx3Cache('BF_LOCALIZ','X3_DECIMAL'), PesqPict('SBF', 'BF_LOCALIZ')})
        aAdd(aHeader, {'QTD', 'Qtd.', GetSx3Cache('C2_QUANT','X3_TIPO'),  TamSx3('C2_QUANT')[1],   GetSx3Cache('C2_QUANT',  'X3_DECIMAL'),  PesqPict('SC2', 'C2_QUANT')})
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

static function getAcondic(nRec)
    local cAcond    := ""
    local oSql      := LibSqlObj():newLibSqlObj() 
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(2):callStatic('qryAvalEstoque', 'getAcondic', oTable:GetRealName(), nRec))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            cAcond    := oSql:getValue('ACONDIC')
            oSql:Skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
return(cAcond)

static function removeFrac()
    Local oStatic   := IfcXFun():newIfcXFun()
    local lRet      := MsgYesNo("Deseja remover este Fracionamento da Bobina ESA?","Confirma Remoção")
    if lRet
        TcSqlExec(oStatic:sP(3):callStatic('qryAvalEstoque', 'grvUniSaldo',; 
                                            oTableUni:GetRealName(),;
                                            (cAlsMRPxUni)->(RECMOV),;
                                            (cAlsMRPxUni)->(QTD),;
                                            "+"))
        TcSqlExec(oStatic:sP(3):callStatic('qryAvalEstoque', 'grvESASaldo',; 
                                                     oTable:GetRealName(),;
                                                     (cAlsMRPxUni)->(RECMRP),;
                                                     (getQtdFraciona( (cAlsMRPxUni)->(RECMRP) ) - (cAlsMRPxUni)->(QTD));
                                                     ))
        Reclock(cAlsMRPxUni, .F.)
            (cAlsMRPxUni)->(dbDelete())
        (cAlsMRPxUni)->(MsUnLock())        
        setRelation(.T.)
        oBrwUni:Refresh()
        oBrwMRP:Refresh()
    endif
return(lRet)

static function getQtdFraciona(nRec)
    local aArea         := GetArea()
    local aAreacAls     := (cAls)->(GetArea())
    local aAreacAlsP    := (cAlsPrinc)->(GetArea())
    local aAreacUni     := (cAlsUni)->(GetArea())
    local aAreaUnixMrp  := (cAlsMRPxUni)->(GetArea())
    local nQtd          := 0

    dbSelectArea(cAls)
    (cAls)->(DbGoTo(nRec))
    nQtd := (cAls)->(ESA)

    RestArea(aAreacUni)
    RestArea(aAreaUnixMrp)
    RestArea(aAreacAlsP)
    RestArea(aAreacAls)
    RestArea(aArea)
return(nQtd)

static function resetMrp()
    Local oStatic   := IfcXFun():newIfcXFun()
    local lRet      := MsgYesNo("Deseja Limpar processamentos anteriores que foram realizados?","Limpar processamento")
    if lRet
        TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'clearTable',; 
                                                        oTableMRPxUni:GetRealName();
                                                        ))
        TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'clearTable',; 
                                                        oTableRet:GetRealName();
                                                        ))
        TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'resetUni',; 
                                                oTableUni:GetRealName();
                                                ))
        TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'resetMRP',; 
                                                        oTable:GetRealName();
                                                        ))
        TcSqlExec(oStatic:sP(1):callStatic('qryAvalEstoque', 'resetRet',; 
                                                        oTableEst:GetRealName();
                                                        ))
    endif
return(nil)

static function isUtiliza(nRecMRP, nRecUni)
    local cUtil     := Space(01)
    local oSql      := LibSqlObj():newLibSqlObj() 
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(4):callStatic('qryAvalEstoque', 'isUtiliza', oTableMRPxUni:GetRealName(), cFili, nRecMRP, nRecUni))
    if oSql:hasRecords()
        cUtil := "X"
    endif
    oSql:Close()
    FreeObj(oSql)
return(cUtil)

static function addFrac()
    local aRet      := {}
    local aPergs    := {}
    Local oStatic   := IfcXFun():newIfcXFun()

    if ((cAls)->(MRP) - ((cAls)->(PRODUZ) +  (cAls)->(ESA) +  (cAls)->(TRANSF))) >= 0
        if ( (cAlsUni)->(SALDO) >= (cAls)->(METRAGE) ) 
            aAdd( aPergs ,{1,"Quantidade: ", 0,PesqPict('SC2', 'C2_QUANT'),'StaticCall(cbcAvalEstoque, validFraciona, MV_PAR01)',,'.T.',50,.F.})
            if ParamBox(aPergs,"Parâmetros",aRet)
                if MsgYesNo("Deseja Fracionar bobina?","Adiconar Fracionamento")
                    Reclock(cAlsMRPxUni, .T.)
                        (cAlsMRPxUni)->FILIAL := cFili
                        (cAlsMRPxUni)->RECMRP := (cAls)->(Recno())
                        (cAlsMRPxUni)->RECMOV := (cAlsUni)->(Recno())
                        (cAlsMRPxUni)->QTD    := MV_PAR01
                    (cAlsMRPxUni)->(MsUnLock())                    
                    TcSqlExec(oStatic:sP(4):callStatic('qryAvalEstoque', 'grvUniSaldo',; 
                                            oTableUni:GetRealName(),;
                                            (cAlsUni)->(Recno()),;
                                            MV_PAR01,;
                                            "-"))
                    TcSqlExec(oStatic:sP(3):callStatic('qryAvalEstoque', 'grvESASaldo',; 
                                            oTable:GetRealName(),;
                                            (cAls)->(Recno()),;
                                            (cAls)->(ESA) + MV_PAR01;
                                            ))
                    setRelation(.T.)
                    oBrwUni:Refresh()
                    oBrwMRP:Refresh()
                endif
            endif
        else
            MsgAlert("Não tem saldo suficiente na Unimov pra fracionar!","Sem Saldo Unimov")
        endif
    else
        MsgAlert("Não tem saldo de MRP pendente pra fracionar!","Sem Saldo MRP")
    endif
return(nil)

static function validFraciona(nQtd)
    local lRet := .F.

    if nQtd >= (cAls)->(METRAGE)
        if nQtd <= (cAlsUni)->(SALDO)
            if nQtd <= ((cAls)->(MRP) - ((cAls)->(PRODUZ) +  (cAls)->(ESA) +  (cAls)->(TRANSF)))
                if (MV_PAR01 % (cAls)->(METRAGE)) == 0
                    lRet := .T.
                else
                    MsgAlert("Quantidade menor não multipla da Metragem do Acondicionamento!","Quantidade Inválida")
                endif
            else
                MsgAlert("Quantidade pendente do MRP menor que a indicada!","Quantidade Inválida")
            endif
        else
            MsgAlert("Quantidade insuficiente na Unimov!","Quantidade Inválida")
        endif
    else
        MsgAlert("Quantidade menor que a Metragem do Acondicionamento!","Quantidade Inválida")
    endif
return(lRet)

static function getTipo(cFili, cProd)
    local cTipo     := ""
    local oSql      := LibSqlObj():newLibSqlObj() 
    Local oStatic   := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(3):callStatic('qryAvalEstoque', 'qryTipo', oTable:GetRealName(), cFili, cProd))
    if oSql:hasRecords()
        cTipo := AllTrim(oSql:getValue('TIPO'))
    endif
    oSql:Close()
    FreeObj(oSql)
return(cTipo)

static function posicUni(cMov)
    local oEnder := ctrlEndProd():newctrlEndProd(.F.)
    local oJson  := JsonObject():new()
    local cEnder := ""
    local aWhere := {}

    aAdd(aWhere,{"removeu", nil})
    aAdd(aWhere,{"oque", StrZero(Val(cMov),10)})
    oJson := oEnder:getinEnder(aWhere)
    if (len(oJson) > 0)
        cEnder := cValToChar(oJson[1]['onde'])
    endif
    FreeObj(oJson)
    FreeObj(oEnder)
return(cEnder)
