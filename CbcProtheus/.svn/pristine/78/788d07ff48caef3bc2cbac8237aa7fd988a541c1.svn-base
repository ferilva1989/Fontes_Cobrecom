#include 'protheus.ch'
#include 'totvs.ch'
#include 'cbcOrdemCar.ch'

user function cbcFatur()   
    private cFatFilter := ""

    pergsView()

    // Chamando CursorArrow() força a CursorWait() mostrar o cursor de ampulheta sempre.
    CursorArrow()
    CursorWait()

    // iniciar View
    FWMsgRun(, { || initView() }, 	"Controle de Faturamento", "Iniciando...")
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
    private oBtnFim		:= nil
    private oBtnFat     := nil
    private oBtnPlan    := nil
    private oGrpProc    := nil
    private oGrpNFe     := nil
    private oBrw        := nil
    private cAls        := ''
    
    // Componentes Visuais
    DEFINE MSDIALOG oDlgPrinc TITLE 'Controle de Faturamento' ;
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

    FreeObj(oBtnPlan)
    FreeObj(oBtnFat)
    FreeObj(oBtnFim)
    FreeObj(oBtnDo)
    FreeObj(oBtnUnDo)
    FreeObj(oBrw)
    FreeObj(oGrpProc)
    FreeObj(oGrpNFe)
    FreeObj(oTable)
    FreeObj(oFWLayer)
    FreeObj(oPanelBrw)
    FreeObj(oPanelCtrl)
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
    oBtnDo 	 := TButton():New( 20, 5,  'Processar', oPanelCtrl ,{|| FWMsgRun(, { || process(.T.)}, "Liberar", "Liberando Carga...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnUnDo := TButton():New( 20, 60, 'Estornar', 	oPanelCtrl ,{|| FWMsgRun(, { || process(.F.)},  "Estornar", "Estornando Carga Liberada...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oGrpNFe := TGroup():New( 60,02,107,113,'Nota Fiscal',oPanelCtrl,,,.T.)
    oBtnFat := TButton():New( 70, 5,  'Transmitir', 	oPanelCtrl ,{|| FWMsgRun(, { || SPEDNFE()},  "Transmissor de NFe", "Iniciando...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnPlan := TButton():New( 70, 60,  'Planilha', 	oPanelCtrl ,{|| FWMsgRun(, { || u_cbcPlanFatur({AllTrim((cAls)->CARGA)})},  "Transmissor de NFe", "Iniciando...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnFim  := TButton():New( 110, 02, 'Encerrar',  oPanelCtrl ,{||oDlgPrinc:End()},;
        113,47,,,.F.,.T.,.F.,,.F.,,,.F. )
return(nil)

static function mountTable()
    local aFlds     := getFields('TBL_PRIN')
    Local oStatic   := IfcXFun():newIfcXFun()
    local cQry      := oStatic:sP(1):callStatic('cbcQryFatur', 'qryView', cFatFilter)

    oTable := FWTemporaryTable():New(nextAlias())
    oTable:SetFields(aFlds)
    oTable:AddIndex('CARGA', {aFlds[1,1]} )
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
    oBrw:SetProfileID('FATPRIN')
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
        0,"CARGA",,PesqPict('ZZ9', 'ZZ9_ORDCAR')}}};
        };
        )
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_INICIO,    TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_VERDE',   'Gerada')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_FINANCEIRO,TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_LARANJA', 'Analise Financeiro')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_LIB_LOG,   TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_AMARELO', 'Liberada Financeiro')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_LIB_FATUR, TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_AZUL',    'Liberada Faturamento')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_FATURADA,  TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_PRETO',   'Faturada')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_CANCELADA, TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_VERMELHO','Cancelada')
    oBrw:Activate()
    //oBrw:AddButton(cBtnLabel, bBtnClick,,,, .F., nTipoBtn)
return(nil)

static function getFields(cOpc, cAls)
    local aRet      := {}
    default cAls    := ''

    if cOpc == 'BRW_PRIN'
        aAdd(aRet, {'Carga',    {|| (oTable:GetAlias())->(CARGA)}, GetSx3Cache('ZZ9_ORDCAR','X3_TIPO'),PesqPict('ZZ9', 'ZZ9_ORDCAR'),1,TamSx3('ZZ9_ORDCAR')[1],    0})
        aAdd(aRet, {'Aglutina', {|| (oTable:GetAlias())->(AGLUT)}, 'C', PesqPict('ZZ9', 'ZZ9_ORDCAR'), 1, 1,    0})
        aAdd(aRet, {'Nr.OSs',   {|| (oTable:GetAlias())->(NROS)},  'N', '@E 999999', 1, 6,    0})
    elseif cOpc == 'TBL_PRIN'
        aAdd(aRet, {'CARGA',    GetSx3Cache('ZZ9_ORDCAR','X3_TIPO'),TamSx3('ZZ9_ORDCAR')[1],   0})
        aAdd(aRet, {'STATUS',   GetSx3Cache('ZZ9_STATUS','X3_TIPO'),TamSx3('ZZ9_STATUS')[1],   0})
        aAdd(aRet, {'AGLUT',    'C', 1,   0})
        aAdd(aRet, {'NROS',     'N', 6,   0})
        //aAdd(aRet, {'MARK',	 GetSx3Cache('C9_OK',     'X3_TIPO'),TamSx3('C9_OK')[1],        0})
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

static function nextAlias()
    local cAls := ''
    while .T.
        cAls := GetNextAlias()
        if (Select(cAls) <= 0)
            exit
        endIf
    endDo
return(cAls)

static function chgLine()
    if AllTrim((cAls)->STATUS) == CARGA_LIB_FATUR
        oBtnFat:Enable()
        oBtnDo:Enable()
        oBtnUnDo:Enable()
    elseif AllTrim((cAls)->STATUS) == CARGA_FATURADA
        oBtnDo:Disable()
        oBtnUnDo:Disable()
        oBtnFat:Enable()
    else
        oBtnDo:Disable()
        oBtnUnDo:Disable()
        oBtnFat:Enable()
    endif
return(.T.)

static function process(lDo)
    local oFat := nil

    if (AllTrim((cAls)->STATUS) == CARGA_LIB_FATUR)
        oFat := cbcCtrlCarga():newcbcCtrlCarga()
        oFat:define(AllTrim((cAls)->CARGA))
        if !lDo
            if (oFat:changeStatus(CARGA_LIB_LOG):isOk())
                FWMsgRun(, { || forcedRefresh() }, 	"Controle de Faturamento", "Atualizando...")
            else
                msgAlert("Erro ao Estornar!","Error")
            endif
        else
            oFat := cbcCtrlFatur():new()
            FWMsgRun(, { |oSay| oFat:fatura(AllTrim((cAls)->CARGA), @oSay) }, 	"Controle de Faturamento", "Faturando...")
            if (oFat:isOk())
                MsgInfo("Carga Faturada!","Sucesso")
                FWMsgRun(, { || forcedRefresh() }, 	"Controle de Faturamento", "Atualizando...")
            endif
        endif
    endif
    FreeObj(oFat)
return(nil)

static function pergsView()
    local aParam  	:= {'01'}
    local aRet      := {}
    local aPerg     := {}
    local aFilter   := {CARGA_LIB_FATUR, CARGA_FATURADA, ""}

    aadd(aPerg,{3,"Filtrar", aParam[01],{"Liberadas", "Faturadas", "Todos"},50,"",.F.})

    if (ParamBox(aPerg,"Filtros de Abertura",@aRet))
        cFatFilter     := aFilter[aRet[01]]
    endif
return(aRet)
