#include 'protheus.ch'
#include 'parmtype.ch'

user function viewMvtoKdx(cPar01, cPar02)
    local bDblClik      := {|| }
    local oDlg          := nil
    local oBrw          := nil
    local oPanel        := nil
    local oTableP       := nil
    local cDtIni        := ""
    local cDtFim        := ""
    private cAlsP       := ""
    private aCoors      := FWGetDialogSize(oMainWnd)
    private oFont	    := TFont():New("Arial",,20,,.T.)
    default cPar01      := ""
    default cPar02      := ""

    if empty(cPar01) .or. empty(cPar02)
        pergParam(@cPar01, @cPar02)
    endif

    cDtIni  := cPar01
    cDtFim  := cPar02
    
    bDblClik := {|| FWMsgRun(, {|| detalhar('O', {cDtIni, cDtFim, (cAlsP)->PRODUTO}, 'Analise Mvto Produto: ' + AllTrim((cAlsP)->PRODUTO))},"Aguarde...", "Detalhando Mvto do Produto...")}

    DEFINE MSDIALOG oDlg TITLE 'Analise de Movimentos' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlg:lMaximized := .T.
    oPanel := TPanel():New( ,,, oDlg)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    FWMsgRun(, { || mntTable('P', {cDtIni, cDtFim}) }, 	"Aguarde...", "Montando Tabela...")
    FWMsgRun(, { || mntBrw(@oBrw,@oPanel, 'Mvtos Produtos', 'P', bDblClik)}, 	"Aguarde...", "Montando Browser...")

    Activate MsDialog oDlg Center

    //oTableP:Delete()

    FreeObj(oPanel)
    FreeObj(oBrw)
    FreeObj(oTableP)
    FreeObj(oFont)
    FreeObj(oDlg)
return(nil)

static function pergParam(cPar01, cPar02)
    local aRet      := {}
    local aPerg     := {}

    cPar01   := ""
    cPar02   := ""

    aadd(aPerg,{1,"Data Inicial", dDataBase,PesqPict("SF2","F2_EMISSAO"),".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Final",   dDataBase,PesqPict("SF2","F2_EMISSAO"),".T.","",".T.",50,.T.})

    if (ParamBox(aPerg,"Parâmetros",@aRet))
        cPar01   := DtoS(aRet[01])
        cPar02   := DtoS(aRet[02])
    endif
return(nil)

static function mntTable(cOpc, aParam)
    local aFlds     := getFields('T_' + cOpc)
    local aIdx      := getFields('I_' + cOpc)
    local cQry      := u_qryMovtoKdx(cOpc, aParam)
    local nX        := 0
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()

    &("oTable" + cOpc) := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcChgAlias', 'nextAlias'))
    &("oTable" + cOpc):SetFields(aFlds)
    for nX := 1 to len(aIdx)
        &("oTable" + cOpc):AddIndex(aIdx[nX,01], aIdx[nX,02])
    next nX
    &("oTable" + cOpc):Create()
    &("@cAls" + cOpc) := &("oTable" + cOpc):GetAlias()

    oSql:newAlias(cQry)
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            (&("@cAls" + cOpc))->(RecLock((&("@cAls" + cOpc)), .T.))
            for nX := 1 to Len(aFlds)
                (&("@cAls" + cOpc))->(&(aFlds[nX, 01])) := iif(aFlds[nX, 01] <> 'EMISS', oSql:getValue(aFlds[nX, 01]),StoD(oSql:getValue(aFlds[nX, 01])))
            next nX
            (&("@cAls" + cOpc))->(MsUnLock())
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    //Carregar a Temp
    //SQLToTrb(cQry, aFlds, (cAls))
return(nil)

static function mntBrw(oBrw, oPnl, cTitle, cOpc, bDblClik)
    local aSeek := getFields('S_' + cOpc)
    oBrw := FWMBrowse():New()
    oBrw:SetOwner(oPnl)
    oBrw:SetDescription(cTitle)
    oBrw:SetAlias(&("@cAls" + cOpc))
    oBrw:SetMenuDef('')
    oBrw:SetFields(getFields('B_' + cOpc, {&("@cAls" + cOpc)}))
    oBrw:SetProfileID('MVTOKDX' + cOpc)
    oBrw:ForceQuitButton(.T.)
    oBrw:DisableDetails()
    //oBrw:DisableReport()
    oBrw:OptionReport(.T.)
    oBrw:setIgnoreaRotina(.T.)
    oBrw:SetUseFilter(.T.)
    oBrw:SetSeek(.T.,aSeek)
    oBrw:bldblclick := bDblClik
    oBrw:Activate()
return(nil)

static function getFields(cOpc, aParam)
    local aFields   := {}
    default aParam  := {}

    if cOpc == 'B_P'
        //aAdd(aFields, {'Filial',     {|| (aParam[01])->(FILIAL)},       GetSx3Cache('C9_FILIAL', 'X3_TIPO'),PesqPict('SC9', 'C9_FILIAL'), 1, TamSx3('C9_FILIAL')[1],  GetSx3Cache('C9_FILIAL',    'X3_DECIMAL')})
        aAdd(aFields, {'Produto',    {|| (&("cAls" + Right(cOpc,1)))->(PRODUTO)},      GetSx3Cache('B1_COD',    'X3_TIPO'),PesqPict('SB1', 'B1_COD'),    1, TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'Producao',   {|| (&("cAls" + Right(cOpc,1)))->(PROD)},         GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Requisicao', {|| (&("cAls" + Right(cOpc,1)))->(REQ)},          GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Prod.Plan',  {|| (&("cAls" + Right(cOpc,1)))->(PROD_EST)},     GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Req.Plan',   {|| (&("cAls" + Right(cOpc,1)))->(REQ_EST)},      GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Fator Plan', {|| (&("cAls" + Right(cOpc,1)))->(FATOR_PLAN)},   GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Prod.Manu',  {|| (&("cAls" + Right(cOpc,1)))->(PROD_MAN)},     GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Req.Manu',   {|| (&("cAls" + Right(cOpc,1)))->(REQ_MAN)},      GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Prod.Canc',  {|| (&("cAls" + Right(cOpc,1)))->(PROD_UNDO)},    GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Req.Canc',   {|| (&("cAls" + Right(cOpc,1)))->(REQ_UNDO)},     GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Execução',   {|| (&("cAls" + Right(cOpc,1)))->(FATOR_EXEC)},   'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Min',  {|| (&("cAls" + Right(cOpc,1)))->(EST_MIN)},      'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Med',  {|| (&("cAls" + Right(cOpc,1)))->(EST_MED)},      'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Max',  {|| (&("cAls" + Right(cOpc,1)))->(EST_MAX)},      'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Cad.', {|| (&("cAls" + Right(cOpc,1)))->(CAD_FAT)},      'N','@E 999.99999999',  1, 12,   8})
    elseif cOpc == 'T_P'
        //aAdd(aFields, {'FILIAL',    GetSx3Cache('D3_FILIAL', 'X3_TIPO'),TamSx3('D3_FILIAL')[1],  GetSx3Cache('D3_FILIAL',    'X3_DECIMAL')})
        aAdd(aFields, {'PRODUTO',   GetSx3Cache('B1_COD',    'X3_TIPO'),TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'PROD',      GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ',       GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'PROD_EST',  GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ_EST',   GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'FATOR_PLAN',GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'PROD_MAN',  GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ_MAN',   GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'PROD_UNDO', GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ_UNDO',  GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'FATOR_EXEC','N',12,   8})
        aAdd(aFields, {'EST_MIN',   'N',12,   8})
        aAdd(aFields, {'EST_MED',   'N',12,   8})
        aAdd(aFields, {'EST_MAX',   'N',12,   8})
        aAdd(aFields, {'CAD_FAT',   'N',12,   8})
    elseif cOpc == 'I_P'
        aAdd(aFields, {'PRODUTO', {'PRODUTO'}})
    elseif cOpc == 'S_P'
        aAdd(aFields, {"PRODUTO" ,{{"",GetSx3Cache('B1_COD', 'X3_TIPO'),TamSx3('B1_COD')[1],0,"PRODUTO",,PesqPict('SB1', 'B1_COD')}}})
    elseif cOpc == 'B_O'
        aAdd(aFields, {'OP',         {|| (&("cAls" + Right(cOpc,1)))->(OP)},           GetSx3Cache('D3_OP',     'X3_TIPO'),PesqPict('SD3', 'D3_OP'),     1, TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP',        'X3_DECIMAL')})
        aAdd(aFields, {'Produto',    {|| (&("cAls" + Right(cOpc,1)))->(PRODUTO)},      GetSx3Cache('B1_COD',    'X3_TIPO'),PesqPict('SB1', 'B1_COD'),    1, TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'Producao',   {|| (&("cAls" + Right(cOpc,1)))->(PROD)},         GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Requisicao', {|| (&("cAls" + Right(cOpc,1)))->(REQ)},          GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Prod.Plan',  {|| (&("cAls" + Right(cOpc,1)))->(PROD_EST)},     GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Req.Plan',   {|| (&("cAls" + Right(cOpc,1)))->(REQ_EST)},      GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Fator Plan', {|| (&("cAls" + Right(cOpc,1)))->(FATOR_PLAN)},   GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Prod.Manu',  {|| (&("cAls" + Right(cOpc,1)))->(PROD_MAN)},     GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Req.Manu',   {|| (&("cAls" + Right(cOpc,1)))->(REQ_MAN)},      GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Prod.Canc',  {|| (&("cAls" + Right(cOpc,1)))->(PROD_UNDO)},    GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],  GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Req.Canc',   {|| (&("cAls" + Right(cOpc,1)))->(REQ_UNDO)},     GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],  GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Fator Exec', {|| (&("cAls" + Right(cOpc,1)))->(FATOR_EXEC)},   'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Min',  {|| (&("cAls" + Right(cOpc,1)))->(EST_MIN)},      'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Med',  {|| (&("cAls" + Right(cOpc,1)))->(EST_MED)},      'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Max',  {|| (&("cAls" + Right(cOpc,1)))->(EST_MAX)},      'N','@E 999.99999999',  1, 12,   8})
        aAdd(aFields, {'Fator Cad.', {|| (&("cAls" + Right(cOpc,1)))->(CAD_FAT)},      'N','@E 999.99999999',  1, 12,   8})
    elseif cOpc == 'T_O'
        aAdd(aFields, {'OP',        GetSx3Cache('D3_OP',     'X3_TIPO'),TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP',        'X3_DECIMAL')})
        aAdd(aFields, {'PRODUTO',   GetSx3Cache('B1_COD',    'X3_TIPO'),TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'PROD',      GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ',       GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'PROD_EST',  GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ_EST',   GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'FATOR_PLAN',GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'PROD_MAN',  GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ_MAN',   GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'PROD_UNDO', GetSx3Cache('D3_QUANT', 'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'REQ_UNDO',  GetSx3Cache('D3_QUANT', 'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'FATOR_EXEC','N',12,   8})
        aAdd(aFields, {'EST_MIN',   'N',12,   8})
        aAdd(aFields, {'EST_MED',   'N',12,   8})
        aAdd(aFields, {'EST_MAX',   'N',12,   8})
        aAdd(aFields, {'CAD_FAT',   'N',12,   8})
    elseif cOpc == 'I_O'
        aAdd(aFields, {'OP', {'OP'}})
    elseif cOpc == 'S_O'
        aAdd(aFields, {"OP" ,{{"",GetSx3Cache('D3_OP', 'X3_TIPO'),TamSx3('D3_OP')[1],0,"OP",,PesqPict('SD3', 'D3_OP')}}})
    elseif cOpc == 'B_D'
        aAdd(aFields, {'OP',         {|| (&("cAls" + Right(cOpc,1)))->(OP)},           GetSx3Cache('D3_OP',     'X3_TIPO'),PesqPict('SD3', 'D3_OP'),     1, TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP',        'X3_DECIMAL')})
        aAdd(aFields, {'Prod.OP',    {|| (&("cAls" + Right(cOpc,1)))->(PRODOP)},       GetSx3Cache('B1_COD',    'X3_TIPO'),PesqPict('SB1', 'B1_COD'),    1, TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'Unimov',     {|| (&("cAls" + Right(cOpc,1)))->(UNIMOV)},       GetSx3Cache('D3_ZZUNMOV','X3_TIPO'),PesqPict('SD3', 'D3_ZZUNMOV'),1, TamSx3('D3_ZZUNMOV')[1], GetSx3Cache('D3_ZZUNMOV',   'X3_DECIMAL')})
        aAdd(aFields, {'Produto',    {|| (&("cAls" + Right(cOpc,1)))->(PRODUTO)},      GetSx3Cache('B1_COD',    'X3_TIPO'),PesqPict('SB1', 'B1_COD'),    1, TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'Movto',      {|| (&("cAls" + Right(cOpc,1)))->(MVTO)},         GetSx3Cache('D3_CF',     'X3_TIPO'),PesqPict('SD3', 'D3_CF'),     1, TamSx3('D3_CF')[1],      GetSx3Cache('D3_CF',        'X3_DECIMAL')})
        aAdd(aFields, {'Quant.',     {|| (&("cAls" + Right(cOpc,1)))->(QTD)},          GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Cobre',      {|| (&("cAls" + Right(cOpc,1)))->(COBRE)},        GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Pvc',        {|| (&("cAls" + Right(cOpc,1)))->(PVC)},          GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Estorno',    {|| (&("cAls" + Right(cOpc,1)))->(UNDO)},         GetSx3Cache('D3_QUANT',  'X3_TIPO'),PesqPict('SD3', 'D3_QUANT'),  1, TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'Usuario',    {|| (&("cAls" + Right(cOpc,1)))->(USUAR)},        GetSx3Cache('D3_USUARIO','X3_TIPO'),PesqPict('SD3', 'D3_USUARIO'),1, TamSx3('D3_USUARIO')[1], GetSx3Cache('D3_USUARIO',   'X3_DECIMAL')})
        aAdd(aFields, {'Data',       {|| (&("cAls" + Right(cOpc,1)))->(EMISS)},        GetSx3Cache('D3_EMISSAO','X3_TIPO'),PesqPict('SD3', 'D3_EMISSAO'),1, TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO',   'X3_DECIMAL')})
        aAdd(aFields, {'Hora',       {|| (&("cAls" + Right(cOpc,1)))->(HREMISS)},      'C',                                '@!',                         1, 8,                       0})
    elseif cOpc == 'T_D'
        aAdd(aFields, {'OP',        GetSx3Cache('D3_OP',     'X3_TIPO'),TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP',        'X3_DECIMAL')})
        aAdd(aFields, {'PRODOP',    GetSx3Cache('B1_COD',    'X3_TIPO'),TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'UNIMOV',    GetSx3Cache('D3_ZZUNMOV','X3_TIPO'),TamSx3('D3_ZZUNMOV')[1], GetSx3Cache('D3_ZZUNMOV',   'X3_DECIMAL')})
        aAdd(aFields, {'PRODUTO',   GetSx3Cache('B1_COD',    'X3_TIPO'),TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',       'X3_DECIMAL')})
        aAdd(aFields, {'MVTO',      GetSx3Cache('D3_CF',     'X3_TIPO'),TamSx3('D3_CF')[1],      GetSx3Cache('D3_CF',        'X3_DECIMAL')})
        aAdd(aFields, {'QTD',       GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'COBRE',     GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'PVC',       GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'UNDO',      GetSx3Cache('D3_QUANT',  'X3_TIPO'),TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT',     'X3_DECIMAL')})
        aAdd(aFields, {'USUAR',     GetSx3Cache('D3_USUARIO','X3_TIPO'),TamSx3('D3_USUARIO')[1], GetSx3Cache('D3_USUARIO',   'X3_DECIMAL')})
        aAdd(aFields, {'HREMISS',   'C',                                8,                       0})
        aAdd(aFields, {'EMISS',     GetSx3Cache('D3_EMISSAO','X3_TIPO'),TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO',   'X3_DECIMAL')})
    elseif cOpc == 'I_D'
        aAdd(aFields, {'OP', {'OP'}})
        aAdd(aFields, {'MVTO', {'MVTO'}})
        aAdd(aFields, {'PRODUTO', {'PRODUTO'}})
        aAdd(aFields, {'UNIMOV', {'UNIMOV'}})
    elseif cOpc == 'S_D'
        aAdd(aFields, {"PRODUTO" ,{{"",GetSx3Cache('D3_COD', 'X3_TIPO'),TamSx3('D3_COD')[1],0,"PRODUTO",,PesqPict('SD3', 'D3_COD')}}})
        aAdd(aFields, {"OP" ,{{"",GetSx3Cache('D3_OP', 'X3_TIPO'),TamSx3('D3_OP')[1],0,"OP",,PesqPict('SD3', 'D3_OP')}}})
        aAdd(aFields, {"UNIMOV" ,{{"",GetSx3Cache('D3_ZZUNMOV', 'X3_TIPO'),TamSx3('D3_ZZUNMOV')[1],0,"UNIMOV",,PesqPict('SD3', 'D3_ZZUNMOV')}}})
    endif
return(aFields)

static function detalhar(cOpc, aFiltro, cTitle)
    local oDlg          := nil
    local oBrw           := nil
    local oPanel         := nil
    local bDblClik       := {|| .T.}

    SetPrvt("oTable" + cOpc)
    SetPrvt("cAls" + cOpc)

    if cOpc == 'O'
        bDblClik := {|| FWMsgRun(, {|| detalhar('D', {aFiltro[1], aFiltro[2],(&("cAls" + Right(cOpc,1)))->OP}, 'Analise Mvto OP: ' + AllTrim((&("cAls" + Right(cOpc,1)))->OP))},'Aguarde...','Detalhando Movto da OP...')}
    endif

    DEFINE MSDIALOG oDlg TITLE cTitle ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    //oDlg:lMaximized := .T.
    oPanel := TPanel():New( ,,, oDlg)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    mntTable(cOpc, aFiltro)
    mntBrw(@oBrw, @oPanel, cTitle, cOpc, bDblClik)

    Activate MsDialog oDlg Center

    &("oTable" + cOpc):Delete()

    FreeObj(oPanel)
    FreeObj(oBrw)
    FreeObj(&("oTable" + cOpc))
    FreeObj(oDlg)
return(nil)
