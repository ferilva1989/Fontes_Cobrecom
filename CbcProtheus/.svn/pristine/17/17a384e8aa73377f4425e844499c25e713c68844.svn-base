#include 'protheus.ch'
#include 'parmtype.ch'
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

user function cbcFinCarga()
        
    // Chamando CursorArrow() força a CursorWait() mostrar o cursor de ampulheta sempre.
    CursorArrow()
    CursorWait()

    // iniciar View
    FWMsgRun(, { || initView() }, 	"Controle Financeiro de Carga", "Iniciando Cargas...")
return(nil)

static function initView()
    local lCloseButt 	:= !(oAPP:lMdi)
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oDlgPrinc   := nil
    private oTable      := nil
    private oFWLayer    := nil
    private oPanelBrw   := nil
    private oPanelCtrl  := nil
    private oBtnDo		:= nil
    private oBtnUnDo	:= nil
    private oBtnAdd     := nil
    private oBtnEdit	:= nil
    private oBtnFim		:= nil
    private oBtnFat     := nil
    private oBtnMan     := nil
    private oGrpProc    := nil
    private oGrpImp     := nil
    private oGrpMnt     := nil
    private oBrw        := nil
    private oGrpOpc     := nil
    private oBtnTrc     := nil
    private cAls        := ''
    
    // Componentes Visuais
    DEFINE MSDIALOG oDlgPrinc TITLE 'Controle Financeiro de Cargas' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlgPrinc:lMaximized := .T.

    oFWLayer := FWLayer():New()
    oFWLayer:Init(oDlgPrinc, lCloseButt)

    cfgLayout()
    mountCtrl()
    mountTable()
    mountBrw()
    CursorArrow()

    Activate MsDialog oDlgPrinc Center

    oTable:Delete()
    
    FreeObj(oTable)
    FreeObj(oFWLayer)
    FreeObj(oPanelBrw)
    FreeObj(oPanelCtrl)
    FreeObj(oBtnDo)
    FreeObj(oBtnAdd)
    FreeObj(oBtnFim)
    FreeObj(oGrpProc)
    FreeObj(oGrpMnt)
    FreeObj(oBrw)
    FreeObj(oDlgPrinc)
return(nil)

static function cfgLayout()
    oFWLayer:AddCollumn('COL_LEFT', 80, .F.)
    oFWLayer:AddCollumn('COL_RIGHT', 20, .F.)

    // Coluna Direita (Browser)
    oFWLayer:AddWindow('COL_LEFT', 'WND_PRIN', 'Principal', 100, .T., .F.)
    oPanelBrw := oFWLayer:GetWinPanel('COL_LEFT', 'WND_PRIN')

    // Coluna Esquerda (Controles)
    oFWLayer:SetColSplit('COL_RIGHT', CONTROL_ALIGN_LEFT)
    oFWLayer:AddWindow('COL_RIGHT', 'WND_CTRL', 'Controles', 100, .T., .F.)
    oPanelCtrl := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_CTRL')
return(nil)

static function mountCtrl()

    oGrpProc := TGroup():New( 10,02,57,113,'Processamento',oPanelCtrl,,,.T.)
    oBtnDo 	 := TButton():New( 20, 5,  'Processar', oPanelCtrl ,{|| FWMsgRun(, { || process()}, "Liberar", "Liberando Carga...")},;
        105,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oGrpMnt := TGroup():New( 60,02,107,113,'Detalhes',oPanelCtrl,,,.T.)
    oBtnAdd := TButton():New( 70, 5,  'Analisar', 	oPanelCtrl ,{|| FWMsgRun(, { || mngCarga()},  "Gerador de Carga", "Iniciando...")},;
        105,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnFim  := TButton():New( 110, 02, 'Encerrar',  oPanelCtrl ,{||oDlgPrinc:End()},;
        113,47,,,.F.,.T.,.F.,,.F.,,,.F. )

return(nil)

static function mountTable()
    local aFlds     := getFields('TBL_PRIN')
    Local oStatic   := IfcXFun():newIfcXFun()
    local cQry      := oStatic:sP(1):callStatic('cbcQryFCarga', 'qryView')

    oTable := FWTemporaryTable():New(oStatic:sP(1):callStatic('cbcViewCarga', 'nextAlias'))
    oTable:SetFields(aFlds)
    oTable:AddIndex('CARGA', {aFlds[1,1]} )
    oTable:AddIndex('ROTA',  {aFlds[2,1]} )
    oTable:Create()
    cAls := oTable:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAls))
return(nil)

static function mountBrw()
    oBrw := FWMBrowse():New()
    oBrw:SetOwner( oPanelBrw )
    oBrw:SetDescription('Ordens de Carga')
    oBrw:SetAlias(cAls)
    oBrw:SetMenuDef('')
    oBrw:SetFields(getFields('BRW_PRIN'))
    oBrw:SetProfileID('CARGAFPRIN')
    oBrw:ForceQuitButton(.T.)
    oBrw:DisableDetails()
    oBrw:DisableReport()
    oBrw:setIgnoreaRotina(.T.)
    oBrw:SetUseFilter(.T.)
    oBrw:SetChange({ || chgLine()})
    oBrw:SetSeek(.T.,;
        {;
        {"CARGA" ,{{"",GetSx3Cache('ZZ9_ORDCAR', 'X3_TIPO'),;
        TamSx3('ZZ9_ORDCAR')[1],;
        0,"CARGA",,PesqPict('ZZ9', 'ZZ9_ORDCAR')}}},;
        {"ROTA" ,{{"",GetSx3Cache('ZZ9_ROTA', 'X3_TIPO'),;
        TamSx3('ZZ9_ROTA')[1],;
        0,"ROTA",,PesqPict('ZZ9', 'ZZ9_ROTA')}}};
        };
        )
    oBrw:AddLegend("FIN == '" + Padr(' ', TamSX3('ZZ9_FLGFIN')[1]) + "'",  'BR_VERDE',   'Aguardando')
    oBrw:AddLegend("((APR + REJ) < OS) .AND. FIN <> '" + Padr(' ', TamSX3('ZZ9_FLGFIN')[1]) + "'",  'BR_AMARELO', 'Analisando')
    oBrw:AddLegend("((APR + REJ) == OS) .AND. FIN <> '" + Padr(' ', TamSX3('ZZ9_FLGFIN')[1]) + "'",  'BR_VERMELHO', 'Processar')
    oBrw:Activate()
return(nil)

static function chgLine()
    if (cAls)->OS == ((cAls)->APR + (cAls)->REJ)
        oBtnDo:Enable()
    else
        oBtnDo:Disable()
    endif
return(nil)

static function process()
    local oCtrl := cbcCtrlCarga():newcbcCtrlCarga()
    local lDo   := .T.

    if (cAls)->OS <> ((cAls)->APR + (cAls)->REJ)
        MsgAlert('Todas as Ordens devem estar analisadas!','Ordens não Analisadas')
    else
        lDo :=  ((cAls)->REJ == 0)
        oCtrl:define(AllTrim((cAls)->CARGA))
        if lDo    
            oCtrl:changeStatus(CARGA_LIB_LOG)
        else
            oCtrl:changeStatus(CARGA_INICIO)
        endif
        if !(oCtrl:isOk())
            MsgAlert(AllTrim(oCtrl:getErrMsg()), 'Erro no Processamento')
        endif
        FWMsgRun(, { || forcedRefresh() }, 	"Controle Financeiro de Cargas", "Atualizando...")
    endif
    FreeObj(oCtrl)
return(nil)

static function getFields(cOpc, cAls)
    local aRet      := {}
    Local oStatic   := IfcXFun():newIfcXFun()
    default cAls    := ''

    if cOpc == 'BRW_PRIN'
        aAdd(aRet, {'Carga',     {|| (oTable:GetAlias())->(CARGA)}, GetSx3Cache('ZZ9_ORDCAR','X3_TIPO'),PesqPict('ZZ9', 'ZZ9_ORDCAR'),1,TamSx3('ZZ9_ORDCAR')[1],    0})
        aAdd(aRet, {'Qtd OS',    {|| (oTable:GetAlias())->(OS)},    'N','@E 9999',1,4,    0})
        aAdd(aRet, {'Aprovadas', {|| (oTable:GetAlias())->(APR)},   'N','@E 9999',1,4,    0})
        aAdd(aRet, {'Rejeitadas',{|| (oTable:GetAlias())->(REJ)},   'N','@E 9999',1,4,    0})        
        aAdd(aRet, {'Total',     {|| CalcTotal((oTable:GetAlias())->(CARGA))},GetSx3Cache('F2_VALBRUT','X3_TIPO'),PesqPict('SF2', 'F2_VALBRUT'),1,TamSx3('F2_VALBRUT')[1],    2})
        aAdd(aRet, {'Peso',      {|| oStatic:sP(1):callStatic('cbcViewCarga', 'CalcPeso',(oTable:GetAlias())->(CARGA))},GetSx3Cache('ZZR_PESPRO','X3_TIPO'),PesqPict('ZZR', 'ZZR_PESPRO'),1,TamSx3('ZZR_PESPRO')[1],    2})
        aAdd(aRet, {'Emissao',   {|| (oTable:GetAlias())->(EMISS)}, GetSx3Cache('ZZ9_DATA',  'X3_TIPO'),PesqPict('ZZ9', 'ZZ9_DATA'),  1,TamSx3('ZZ9_DATA')[1],      0})
        aAdd(aRet, {'Hora',      {|| (oTable:GetAlias())->(HORA)},  GetSx3Cache('ZZ9_HORA',  'X3_TIPO'),PesqPict('ZZ9', 'ZZ9_HORA'),  1,TamSx3('ZZ9_HORA')[1],      0})
    elseif cOpc == 'TBL_PRIN'
        aAdd(aRet, {'CARGA', GetSx3Cache('ZZ9_ORDCAR','X3_TIPO'),TamSx3('ZZ9_ORDCAR')[1],   0})
        aAdd(aRet, {'EMISS', GetSx3Cache('ZZ9_DATA',  'X3_TIPO'),TamSx3('ZZ9_DATA')[1],     0})
        aAdd(aRet, {'HORA',  GetSx3Cache('ZZ9_HORA',  'X3_TIPO'),TamSx3('ZZ9_HORA')[1],     0})
        aAdd(aRet, {'STATUS',GetSx3Cache('ZZ9_STATUS','X3_TIPO'),TamSx3('ZZ9_STATUS')[1],   0})
        aAdd(aRet, {'FIN',   GetSx3Cache('ZZ9_FLGFIN','X3_TIPO'),TamSx3('ZZ9_FLGFIN')[1],   0})
        aAdd(aRet, {'APR',   'N', 4,   0})
        aAdd(aRet, {'REJ',   'N', 4,   0})
        aAdd(aRet, {'OS',    'N', 4,   0})
    endif
return(aRet)

static function forcedRefresh()
    reboot()
    mountTable()
    mountBrw()
return(nil)

static function reboot()
    oBrw:DeActivate()
    oBrw := nil
    if oTable <> nil
        oTable:Delete()
    endif
    oTable := nil
    oPanelBrw:FreeChildren()
return(nil)

static function mngCarga()
    local cCarga    := (oTable:GetAlias())->(CARGA)
    
    u_cbcMngFCarga(cCarga)
    FWMsgRun(, { || forcedRefresh() }, 	"Controle Financeiro de Cargas", "Atualizando...")
return(nil)

static function CalcTotal(cCarga)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local nTotal     := 0.00
    local oSql	    := LibSqlObj():newLibSqlObj()
    Local oStatic    := IfcXFun():newIfcXFun()
    Default cCarga := ""

    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryFCarga', 'qryGetTotal', cCarga))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            nTotal += oSql:getValue("TOTAL")
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(nTotal)
