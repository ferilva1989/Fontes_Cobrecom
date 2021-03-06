#include 'protheus.ch'
#include 'parmtype.ch'
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

user function cbcViewCarga()
    private cFilter := '1'
    private dDtFrom := dDataBase
    
    pergsView(@cFilter, @dDtFrom)
    
    // Chamando CursorArrow() for?a a CursorWait() mostrar o cursor de ampulheta sempre.
    CursorArrow()
    CursorWait()

    // iniciar View
    FWMsgRun(, { || initView() }, 	"Controle de Ordem de Carga", "Iniciando Cargas...")
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
    private oBtnCte     := nil
    private oBtnAge     := nil
    private oBtnVei     := nil
    private cAls        := ''
    
    // Componentes Visuais
    DEFINE MSDIALOG oDlgPrinc TITLE 'Controle de Cargas' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlgPrinc:lMaximized := .T.

    oFWLayer := FWLayer():New()
    oFWLayer:Init(oDlgPrinc, lCloseButt)

    cfgLayout()
    mountCtrl()
    mountTable()
    mountBrw()
    chgLine()
    CursorArrow()

    Activate MsDialog oDlgPrinc Center

    oTable:Delete()
    
    FreeObj(oBtnVei)
    FreeObj(oBtnAge)
    FreeObj(oBtnCte)
    FreeObj(oTable)
    FreeObj(oFWLayer)
    FreeObj(oPanelBrw)
    FreeObj(oPanelCtrl)
    FreeObj(oBtnDo)
    FreeObj(oBtnUnDo)
    FreeObj(oBtnAdd)
    FreeObj(oBtnEdit)
    FreeObj(oBtnFim)
    FreeObj(oBtnFat)
    FreeObj(oBtnMan)
    FreeObj(oGrpProc)
    FreeObj(oGrpImp)
    FreeObj(oGrpMnt)
    FreeObj(oBrw)
    FreeObj(oGrpOpc)
    FreeObj(oBtnTrc)
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

    oGrpMnt := TGroup():New( 60,02,107,113,'Montagem de Carga',oPanelCtrl,,,.T.)
    oBtnAdd := TButton():New( 70, 5,  'Criar', 	oPanelCtrl ,{|| FWMsgRun(, { || buildCarga(.T.)},  "Gerador de Carga", "Iniciando...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnEdit:= TButton():New( 70, 60, 'Editar', 	oPanelCtrl ,{|| FWMsgRun(, {|| buildCarga(.F.)},  "Manuten??o de Carga", "Carregando...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oGrpImp := TGroup():New( 110,02,197,113,'Impress?o',oPanelCtrl,,,.T.)
    oBtnFat := TButton():New( 120, 5,  'Faturamento', 	oPanelCtrl ,{||FWMsgRun(, { || print('FAT')},  "Planilha de Faturamento", 'Gerando planilha para Faturamento...')},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnMan  := TButton():New( 120, 60, 'Manifesto', 	oPanelCtrl ,{||FWMsgRun(, { || print('MAN')},  'Manifesto de Carga', 'Imprimindo Manifesto...')},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnAge := TButton():New( 155, 5,  'Agendamento', 	oPanelCtrl ,{||FWMsgRun(, { || print('AGE')},  "Planilha de Agendamento", 'Gerando planilha para Agendamento...')},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnTrc := TButton():New( 155, 60,  'Trace', 	    oPanelCtrl ,{||FWMsgRun(, { || u_cbcTraceBck()},  "Trace", 'Carregando...')},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oGrpOpc := TGroup():New( 200,02,247,113,'Op??es',oPanelCtrl,,,.T.)
    oBtnVei := TButton():New( 210, 5,  'Ve?culos', 	oPanelCtrl ,{ || u_cbcDefVeic(AllTrim((cAls)->CARGA))},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnCte := TButton():New( 210, 60,  'Frete', 	oPanelCtrl ,{||FWMsgRun(, { || calcCte(AllTrim((cAls)->CARGA))},  "Frete", 'Carregando tabelas...')},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnFim  := TButton():New( 250, 02, 'Encerrar',  oPanelCtrl ,{||oDlgPrinc:End()},;
        113,47,,,.F.,.T.,.F.,,.F.,,,.F. )

return(nil)

static function mountTable()
    local aFlds     := getFields('TBL_PRIN')
    Local oStatic   := IfcXFun():newIfcXFun()
    local cQry      := oStatic:sP(2):callStatic('cbcQryCarga', 'qryCargaView', cFilter, dDtFrom)

    oTable := FWTemporaryTable():New(nextAlias())
    oTable:SetFields(aFlds)
    oTable:AddIndex('CARGA', {aFlds[1,1]} )
    oTable:AddIndex('ROTA',  {aFlds[2,1]} )
    oTable:Create()
    cAls := oTable:GetAlias()

    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAls))
return(nil)

static function mountBrw()
    oBrw := FWMarkBrowse():New()
    oBrw:SetFieldMark('MARK')
    oBrw:SetCustomMarkRec({|| doMark()})
    oBrw:SetSemaphore(.T.)
    oBrw:SetOwner( oPanelBrw )
    oBrw:SetDescription('Ordens de Carga')
    oBrw:SetAlias(cAls)
    oBrw:SetMenuDef('')
    oBrw:SetFields(getFields('BRW_PRIN'))
    oBrw:SetProfileID('CARGAPRIN')
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
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_INICIO,    TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_VERDE',   'Gerada')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_FINANCEIRO,TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_LARANJA', 'Analise Financeiro')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_LIB_LOG,   TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_AMARELO', 'Liberada Financeiro')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_LIB_FATUR, TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_AZUL',    'Liberada Faturamento')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_FATURADA,  TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_PRETO',   'Faturada')
    oBrw:AddLegend("STATUS == '" + Padr(CARGA_CANCELADA, TamSX3('ZZ9_STATUS')[1]) + "'",  'BR_VERMELHO','Cancelada')
    oBrw:Activate()
    //oBrw:AddButton(cBtnLabel, bBtnClick,,,, .F., nTipoBtn)
return(nil)

static function doMark()
    local cMarca	:= oBrw:Mark()
    local cFld 		:= oBrw:cFieldMark

    if !((cAls)->(RecLock(cAls, .F.)))
        MsgAlert('Erro ao selecionar Registro!','Error')
    else
        if (cAls)->(&cFld) <> cMarca
            (cAls)->(&cFld) := cMarca
        else
            (cAls)->(&cFld) := ' '
        endif
        (cAls)->(MSUnlock())
    endif
return(nil)

static function process(lDo)
    local cErr  := ''
    local aErr  := {}
    local nX    := 0
    local lOk   := .F.
    local oCtrl := cbcCtrlCarga():newcbcCtrlCarga()
    local oSql  := LibSqlObj():newLibSqlObj()
    local lFinan:= GetNewPar('ZZ_FICARGA', .F.)
    Local oStatic:= IfcXFun():newIfcXFun()
    local cSts  := ''
    default lDo := .T.

    oSql:newAlias(oStatic:sP(3):callStatic('cbcQryCarga', 'qrySelected', oTable:GetRealName(), oBrw:cFieldMark, oBrw:Mark()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            (cAls)->(DbGoto(oSql:getValue('REC')))
            cSts := ''
            if lDo
                if AllTrim((cAls)->TRANSP) <> 'N?O DEFINIDA'
                    if lFinan .and. AllTrim((cAls)->STATUS) == CARGA_INICIO
                        cSts := avalFinance(AllTrim((cAls)->CARGA))
                    elseif (!lFinan) .and. (AllTrim((cAls)->STATUS) == CARGA_INICIO)
                        cSts := CARGA_LIB_FATUR
                    elseif AllTrim((cAls)->STATUS) == CARGA_LIB_LOG
                        cSts := CARGA_LIB_FATUR
                    endif
                endif
            else
                if ((AllTrim((cAls)->STATUS) == CARGA_LIB_LOG) .or. (AllTrim((cAls)->STATUS) == CARGA_LIB_FATUR))
                    cSts := CARGA_INICIO
                endif
            endif
            lOk   := .F.
            if !empty(cSts)
                oCtrl:define(AllTrim((cAls)->CARGA))
                lOk := oCtrl:changeStatus(cSts, AllTrim((cAls)->STATUS)):isOk()
            endif
            if !lOk
                aAdd(aErr, AllTrim(oSql:getValue('CARGA')))
            endif
            oSql:skip()
        endDo
        if empty(aErr)
            msgInfo('Todos as CARGAS selecionadas foram processadas!','Sucesso')
        else
            for nX := 1 to len(aErr)
                cErr += aErr[nX]
                if nX < len(aErr)
                    cErr += ', '
                endif
            next nX
            msgAlert('CARGAS n?o processadas: ' + cErr + '.','Alerta')
        endif
    else
        MsgAlert('Nenhuma CARGA foi Selecionada!', 'Selecionar')
    endif

    FWMsgRun(, { || forcedRefresh() }, 	"Controle de Cargas", "Atualizando...")

    FreeObj(oCtrl)
    FreeObj(oSql)
return(nil)

static function getFields(cOpc, cAls)
    local aRet      := {}
    default cAls    := ''

    if cOpc == 'BRW_PRIN'
        aAdd(aRet, {'Carga',    {|| (oTable:GetAlias())->(CARGA)},          GetSx3Cache('ZZ9_ORDCAR','X3_TIPO'),PesqPict('ZZ9', 'ZZ9_ORDCAR'),1,TamSx3('ZZ9_ORDCAR')[1],    0})
        aAdd(aRet, {'Transp',   {|| (oTable:GetAlias())->(TRANSP)},         GetSx3Cache('A4_NOME',   'X3_TIPO'),PesqPict('SA4', 'A4_NOME'),   1,TamSx3('A4_NOME')[1],       0})
        aAdd(aRet, {'Prior',    {|| (oTable:GetAlias())->(PRIOR)},          GetSx3Cache('ZZ9_PRIORI', 'X3_TIPO'),PesqPict('ZZ9','ZZ9_PRIORI'),1,TamSx3('ZZ9_PRIORI')[1],    0})
        aAdd(aRet, {'Peso',     {|| CalcPeso((oTable:GetAlias())->(CARGA))},GetSx3Cache('ZZR_PESPRO','X3_TIPO'),PesqPict('ZZR', 'ZZR_PESPRO'),1,TamSx3('ZZR_PESPRO')[1],    2})
        aAdd(aRet, {'Emissao',  {|| (oTable:GetAlias())->(EMISS)},          GetSx3Cache('ZZ9_DATA',  'X3_TIPO'),PesqPict('ZZ9', 'ZZ9_DATA'),  1,TamSx3('ZZ9_DATA')[1],      0})
        aAdd(aRet, {'Hora',     {|| (oTable:GetAlias())->(HORA)},           GetSx3Cache('ZZ9_HORA',  'X3_TIPO'),PesqPict('ZZ9', 'ZZ9_HORA'),  1,TamSx3('ZZ9_HORA')[1],      0})
    elseif cOpc == 'TBL_PRIN'
        aAdd(aRet, {'CARGA', GetSx3Cache('ZZ9_ORDCAR','X3_TIPO'),TamSx3('ZZ9_ORDCAR')[1],   0})
        aAdd(aRet, {'TRANSP',GetSx3Cache('A4_NOME','X3_TIPO'),   TamSx3('A4_NOME')[1],      0})
        aAdd(aRet, {'PRIOR', GetSx3Cache('ZZ9_PRIORI','X3_TIPO'),TamSx3('ZZ9_PRIORI')[1],   0})
        aAdd(aRet, {'EMISS', GetSx3Cache('ZZ9_DATA',  'X3_TIPO'),TamSx3('ZZ9_DATA')[1],     0})
        aAdd(aRet, {'HORA',  GetSx3Cache('ZZ9_HORA',  'X3_TIPO'),TamSx3('ZZ9_HORA')[1],     0})
        aAdd(aRet, {'STATUS',GetSx3Cache('ZZ9_STATUS','X3_TIPO'),TamSx3('ZZ9_STATUS')[1],   0})
        aAdd(aRet, {'MARK',	 GetSx3Cache('C9_OK',     'X3_TIPO'),TamSx3('C9_OK')[1],        0})
    endif
return(aRet)

static function CalcPeso(cCarga)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local nPeso     := 0.00
    local oSql	    := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()

    DbSelectArea('ZZ9')

    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryCarga', 'getRegs', cCarga))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            ZZ9->(DbGoTo(oSql:getValue("REC")))
            oReg := JsonObject():new()
            oReg:FromJSON(ZZ9->ZZ9_JSVOLU)
            if !empty(oReg:GetNames())
                if ValType(oReg:GetJsonObject('PESOBRUTO')) <> 'U'
                    nPeso += oReg['PESOBRUTO']
                endif
            endif
            FreeObj(oReg)
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(nPeso)

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

static function buildCarga(lNew)
    local cCarga    := ''
    local lLiberado := .T.
    local cSts      := ""
    default lNew    := .T.
    if !lNew
        cCarga      := (oTable:GetAlias())->(CARGA)
        cSts        := (oTable:GetAlias())->(STATUS)
        lLiberado   := (AllTrim((oTable:GetAlias())->(STATUS)) == CARGA_INICIO )
    endif
    u_cbcMngCarga(cCarga, lLiberado, cSts)
    FWMsgRun(, { || forcedRefresh() }, 	"Controle de Cargas", "Atualizando...")
return(nil)

static function print(cOpc)
    if cOpc == 'FAT'
        planFatur()
    elseif cOpc == 'MAN'
        prtManifesto()
    elseif cOpc == 'AGE'
        planAgenda()
    endif
return(nil)

static function prtManifesto()
    local aArea    	:= GetArea()
    local aAreaAls 	:= (cAls)->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    local aCargas   := {}
    local nX        := 0

    oSql:newAlias(oStatic:sP(3):callStatic('cbcQryCarga', 'qrySelected', oTable:GetRealName(), oBrw:cFieldMark, oBrw:Mark()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            (cAls)->(DbGoto(oSql:getValue('REC')))
            aAdd(aCargas, (cAls)->(CARGA))
            doMark()
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaAls)
    RestArea(aArea)

    if empty(aCargas)
        aAdd(aCargas, (cAls)->(CARGA))
    endif

    for nX := 1 to len(aCargas)
        u_cbcRptManifesto(aCargas[nX])
    next nX
    oBrw:Refresh()
return(nil)

static function planFatur()
    local aArea    	:= GetArea()
    local aAreaAls 	:= (cAls)->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    local aCargas   := {}

    oSql:newAlias(oStatic:sP(3):callStatic('cbcQryCarga', 'qrySelected', oTable:GetRealName(), oBrw:cFieldMark, oBrw:Mark()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            (cAls)->(DbGoto(oSql:getValue('REC')))
            aAdd(aCargas, (cAls)->(CARGA))
            doMark()
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaAls)
    RestArea(aArea)

    if empty(aCargas)
        aAdd(aCargas, (cAls)->(CARGA))
    endif

    if !empty(aCargas)
        u_cbcPlanFatur(aCargas)
    endif
    oBrw:Refresh()
return(nil)

static function planAgenda()    
    local aArea    	:= GetArea()
    local aAreaAls 	:= (cAls)->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    local aCargas   := {}

    oSql:newAlias(oStatic:sP(3):callStatic('cbcQryCarga', 'qrySelected', oTable:GetRealName(), oBrw:cFieldMark, oBrw:Mark()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            (cAls)->(DbGoto(oSql:getValue('REC')))
            aAdd(aCargas, (cAls)->(CARGA))
            doMark()
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaAls)
    RestArea(aArea)

    if empty(aCargas)
        aAdd(aCargas, (cAls)->(CARGA))
    endif

    if !empty(aCargas)
        u_cbcPlanAgenda(aCargas)
    endif
    oBrw:Refresh()
return(nil)

static function chgLine()
    if AllTrim((cAls)->STATUS) == CARGA_INICIO
        oBtnDo:Enable()
        oBtnUnDo:Disable()
        oBtnFat:Disable()
        oBtnMan:Disable()
        oBtnCte:Enable()
    elseif AllTrim((cAls)->STATUS) == CARGA_LIB_LOG
        oBtnDo:Enable()
        oBtnUnDo:Enable()
        oBtnFat:Disable()
        oBtnMan:Disable()
        oBtnCte:Enable()
    elseif AllTrim((cAls)->STATUS) == CARGA_LIB_FATUR
        oBtnDo:Disable()
        oBtnUnDo:Enable()
        oBtnFat:Enable()
        oBtnMan:Disable()
        oBtnCte:Enable()
    elseif AllTrim((cAls)->STATUS) == CARGA_FATURADA
        oBtnDo:Disable()
        oBtnUnDo:Disable()
        oBtnFat:Enable()
        oBtnMan:Enable()
        oBtnCte:Enable()
    else
        oBtnDo:Disable()
        oBtnUnDo:Disable()
        oBtnFat:Disable()
        oBtnMan:Disable()
        oBtnCte:Disable()
    endif
return(.T.)

static function calcCte(cCarga)
    u_cbcDefTrp(cCarga)
    FWMsgRun(, { || forcedRefresh() }, 	"Controle de Cargas", "Atualizando...")
return(nil)

static function pergsView(cFilter, dDtFrom)
    local aParam  	:= { dDtFrom, cFilter}
    local aRet      := {}
    local aPerg     := {}
    local aFilter   := {'I','D','G','L','F',''}

    aadd(aPerg,{1,"Data Inicial", aParam[01],"",".T.","",".T.",50,.T.})
    aadd(aPerg,{3,"Filtrar",      aParam[02],{"Iniciadas", "Analise Financeiro","Lib.Financeiro","Lib. Fatur", "Faturadas","Todos"},50,"",.F.})

    if !(ParamBox(aPerg,"Filtros de Abertura",@aRet))
        cFilter := ''
        dDtFrom := StoD('20200101')
    else
        cFilter     := aFilter[aRet[2]]
        dDtFrom     := aRet[1]
    endif
return(aRet)

static function avalFinance(cCarga)
    local aArea    	:= GetArea()
    local aAreaAls 	:= (cAls)->(GetArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    local oCtrl     := cbcCtrlCarga():newcbcCtrlCarga()
    Local oStatic   := IfcXFun():newIfcXFun()
    local cSts      := CARGA_FINANCEIRO
    local aFld      := {}
    local nX        := 0
    local nTotal    := 0
    local lRisco    := GetNewPar('ZZ_CGRISCA', .T.)

    if lRisco
        aAdd(aFld, {'ZZ9_FLGFIN', 'S'})
        oSql:newAlias(oStatic:sP(1):callStatic('cbcQryCarga', 'avalFinance', cCarga))
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                if AllTrim(oSql:getValue("RISCO")) == 'A'
                    oCtrl:define(AllTrim(cCarga))
                    if oCtrl:update(aFld, AllTrim(oSql:getValue("SEP"))):isOk()
                        nX++
                    endif
                elseif AllTrim(oSql:getValue("FLGFIN")) == 'S'
                    nX++
                endif
                nTotal++
                oSql:skip()
            endDo
            if nX >= nTotal
                cSts := CARGA_LIB_LOG
            endif
        endif
        oSql:close()
    endif
    FreeObj(oSql)
    FreeObj(oCtrl)
    RestArea(aAreaAls)
    RestArea(aArea)
return(cSts)
