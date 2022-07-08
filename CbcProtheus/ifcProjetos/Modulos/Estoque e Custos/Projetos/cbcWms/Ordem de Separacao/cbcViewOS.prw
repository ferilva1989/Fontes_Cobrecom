#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"
#include 'cbcOrdemSep.ch'

user function cbcViewOS(lIsPDS)
    private nFilter     := 0
    private dDtFrom     := CToD("")
    private lPDS        := .F.
    default lIsPDS      := .F.

    if lIsPDS
        lPDS := .T.
        nFilter := FILTRO_PEND
        dDtFrom := StoD('20200101')
    else
        pergsCbcViewOs(@nFilter, @dDtFrom)
    endif

    // Chamando CursorArrow() força a CursorWait() mostrar o cursor de ampulheta sempre.
    CursorArrow()
    CursorWait()

    // iniciar View
    FWMsgRun(, { || initView() }, 	"Controle de Ordem de Separação", "Iniciando OS's...")
return(nil)

static function pergsCbcViewOs(cStsFilter, dDtFrom)
    local aParam  	:= { CToD(""),;
        '1'}
    local aRet      := {}
    local aPerg     := {}

    aadd(aPerg,{1,"Data Inicial", aParam[01],"",".T.","",".T.",50,.T.})
    aadd(aPerg,{3,"Filtrar",      aParam[02],{"Pendentes", "Transmitidos", "Todos"},50,"",.F.})

    if !(ParamBox(aPerg,"Filtros de Abertura",@aRet))
        MsgInfo('Não foi atribuido um filtro, isto pode levar a lentidão no uso da rotina.','Filtros Cancelados')
        nFilter := FILTRO_NO
        dDtFrom := StoD('20200101')
    else
        nFilter := aRet[2]
        dDtFrom := aRet[1]
    endif
return(aRet)


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
    private oBtnWms		:= nil
    private oBtnPrint	:= nil
    private oBtnFim		:= nil
    private oBtnCJoin   := nil
    private oBtneJoin   := nil
    private oGrpAglt    := nil
    private oGrpInt     := nil
    private oGrpOpc     := nil
    private oBrw        := nil
    private oWebChannel := nil
    private nPort 		:= nil
    private oTIBrw      := nil
    private cAls        := ''
    private lWms        := .F.
    // Componentes Visuais
    DEFINE MSDIALOG oDlgPrinc TITLE 'Controle de Status' ;
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

    if oTable <> nil
        oTable:Delete()
    endif

    FreeObj(oTable)
    FreeObj(oFWLayer)
    FreeObj(oPanelBrw)
    FreeObj(oPanelCtrl)
    FreeObj(oGrpOpc)
    FreeObj(oBtnDo)
    FreeObj(oBtnUnDo)
    FreeObj(oBtnWms)
    FreeObj(oBtnPrint)
    FreeObj(oBtnFim)
    FreeObj(oBtnCJoin)
    FreeObj(oBtneJoin)
    FreeObj(oGrpAglt)
    FreeObj(oGrpInt)
    FreeObj(oBrw)
    FreeObj(oWebChannel)
    FreeObj(oTIBrw)
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

    oGrpInt := TGroup():New( 10,02,55,113,'Integração',oPanelCtrl,,,.T.)
    oBtnDo 	 := TButton():New( 20, 5,  'Processar', oPanelCtrl ,{|| FWMsgRun(, { || process(.T.)}, "Ordem de Separação", "Enviando OS's...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnUnDo := TButton():New( 20, 60, 'Produto', 	oPanelCtrl ,{|| FWMsgRun(, { || u_cbcIPrdWms()},  "Integração Manual de Produto", "Integrando manualmente Produto...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    oGrpOpc := TGroup():New( 60,02,135,113,'Opções',oPanelCtrl,,,.T.)
    oBtnWms	 := TButton():New( 70, 5,  'WMS', 	oPanelCtrl ,{||FWMsgRun(, { || cbcWms()},  "CbcWms", iif(lWms, 'Desativando ', 'Ativando ') + "CbcWms...")},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnPrint:= TButton():New( 70, 60, 'Imprimir', 	oPanelCtrl ,{||print()},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnCarga:= TButton():New( 102, 60, 'Imprimir Carga', 	oPanelCtrl ,{||u_cbcVldCarga()},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )

    oGrpAglt := TGroup():New( 140,02,185,113,'Aglutinar',oPanelCtrl,,,.T.)
    oBtnCJoin := TButton():New( 150, 5,  'Criar', 	oGrpAglt ,{||FWMsgRun(, { || joinOS()},  "Aglutinar OSs", 'Aglutinandos OSs selcionadas...')},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnEJoin  := TButton():New( 150, 60, 'Editar', 	oGrpAglt ,{||FWMsgRun(, { || joinOS(.F.)},  'Editar OS Aglutinada', 'Editando OS posicionada...')},;
        50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnFim  := TButton():New( 200, 5, 'Encerrar',  oPanelCtrl ,{||oDlgPrinc:End()},;
        105,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    if lPDS
        oBtnUnDo:Disable()
        oBtnPrint:Disable()
        oBtnCJoin:Disable()
        oBtnEJoin:Disable()
    endif
return(nil)

static function mountTable()
    local aFlds := getFields('T')
    Local oStatic    := IfcXFun():newIfcXFun()
    local cQry  := oStatic:sP(4):callStatic('cbcQryOrdSep', 'getQry', 'PRIN', '', '', nFilter)

    oTable := FWTemporaryTable():New(nextAlias())
    oTable:SetFields(aFlds)
    oTable:AddIndex('OS',  {aFlds[1,1]} )
    oTable:AddIndex('CLI', {aFlds[6,1]} )
    oTable:AddIndex('NOME',{aFlds[7,1]} )
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
    oBrw:SetDescription('Ordens de Separação')
    oBrw:SetAlias(cAls)
    oBrw:SetMenuDef('')
    oBrw:SetFields(getFields('B'))
    oBrw:SetProfileID('VIEWOS')
    oBrw:ForceQuitButton(.T.)
    oBrw:DisableDetails()
    oBrw:DisableReport()
    oBrw:setIgnoreaRotina(.T.)
    oBrw:SetUseFilter(.T.)
    oBrw:SetSeek(.T.,;
        {;
        {"OS" ,{{"",GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'),;
        (TamSx3('ZZR_PEDIDO')[1] + TamSx3('ZZR_SEQOS')[1]),;
        0,"OS",,PesqPict('ZZR', 'ZZR_PEDIDO')}}},;
        {"CLI" ,{{"",GetSx3Cache('A1_COD', 'X3_TIPO'),;
        (TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1]),;
        0,"CLI",,PesqPict('SA1', 'A1_COD')}}},;
        {"NOME" ,{{"",GetSx3Cache('A1_NOME', 'X3_TIPO'),;
        TamSx3('A1_NOME')[1],;
        0,"NOME",,PesqPict('SA1', 'A1_NOME')}}};
        };
        )
    oBrw:AddLegend("SIT == '1'", 'BR_VERDE',    'Pendente WMS')
    oBrw:AddLegend("SIT == '2'", 'BR_AZUL',     'Enviada WMS')
    oBrw:AddLegend("SIT == 'G'", 'BR_AMARELO',  'Faturada e Pendente WMS')
    oBrw:AddLegend("SIT == 'F'", 'BR_LARANJA',  'Faturada e Enviada WMS')
    oBrw:AddLegend("SIT == '9'", 'BR_VERMELHO', 'Cancelada')
    oBrw:AddButton('Inverter', {||FWMsgRun(, {|| allMark()	},  'Invertendo Marcações', 'Marcando...')} ,,7,)
    oBrw:Activate()
    //oBrw:AddButton(cBtnLabel, bBtnClick,,,, .F., nTipoBtn)
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
        if (cAls)->(&cFld) <> cMarca
            (cAls)->(&cFld) := cMarca
        else
            (cAls)->(&cFld) := ' '
        endif
        (cAls)->(MSUnlock())
    endif
return(nil)

static function process(lDo)
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic    := IfcXFun():newIfcXFun()
    local cOSErr    := ''
    local nX        := 0
    local aErr      := {}
    default lDo     := .T.

    oSql:newAlias(oStatic:sP(3):callStatic('cbcQryOrdSep', 'qrySelected', oTable:GetRealName(), oBrw:cFieldMark, oBrw:Mark()))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            (cAls)->(DbGoto(oSql:getValue('REC')))
            if lDo
                if (((cAls)->SIT == '2') .or. ((cAls)->SIT == 'F') .or. ((cAls)->SIT == '9'))
                    aAdd(aErr, AllTrim(oSql:getValue('OS')))
                else
                    if !(integra(AllTrim(oSql:getValue('OS'))))
                        aAdd(aErr, AllTrim(oSql:getValue('OS')))
                    endif
                endif
            else
                if !(estorna(AllTrim(oSql:getValue('OS'))))
                    aAdd(aErr, AllTrim(oSql:getValue('OS')))
                endif
            endif
            oSql:skip()
        endDo
        if empty(aErr)
            msgInfo('Todos as OS selecionadas foram processadas!','Sucesso')
        else
            for nX := 1 to len(aErr)
                cOSErr += aErr[nX]
                if nX < len(aErr)
                    cOSErr += ', '
                endif
            next nX
            msgAlert('OSs não puderam ser processadas: ' + cOSErr + '. Verifique o Status!','Alerta')
        endif
    else
        MsgAlert('Nenhuma OS foi Selecionada!', 'Selecionar')
    endif

    FWMsgRun(, { || forcedRefresh() }, 	"Controle de Ordem de Separação", "Atualizando OS's...")

    oSql:close()
    FreeObj(oSql)
return(nil)

static function integra(cOS)
    local oCtrl     := cbcCtrlOS():newcbcCtrlOS()
    local lRet      := .F.

    oCtrl:define(cOS)
    lRet := oCtrl:export():isOk()
    FreeObj(oCtrl)
return(lRet)

static function estorna(cOS)
    local oCtrl     := cbcCtrlOS():newcbcCtrlOS()
    local oCarga    := cbcCtrlCarga():newcbcCtrlCarga()
    local lRet      := .F.

    oCtrl:define(cOS)
    if oCtrl:inUse()
        MsgAlert("Atenção: " + Chr(13) + Chr(13) +;
            "OS: " + cOS +;
            " em processo na Expedição!",'Bloqueado')
    elseif oCarga:inCarga(cOS, .T.)
        MsgAlert("Atenção: " + Chr(13) + Chr(13) +;
            "OS: " + cOS +;
            " em processo de Carga na Logistica!",'Bloqueado')
    else
        //u_zLimpaOS(AllTrim(oSql:getValue('PED')))
        MsgAlert('Não Configurada!','Alerta')
        lRet := .T.
    endif
    FreeObj(oCarga)
    FreeObj(oCtrl)
return(lRet)

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

static function cbcWms()
    if !(lWms)
        mountWmsView()
        lWms := .T.
    else
        FreeObj(oWebChannel)
        FreeObj(oTIBrw)
        oPanelBrw:FreeChildren()
        mountTable()
        mountBrw()
        lWms := .F.
    endif
return(nil)

static function mountWmsView()
    local cLink := ''

    if lPDS
        cLink := AllTrim(GetNewPar("ZZ_WMSRAPI", "http://cbcwms.cobrecom:3395"))
    else
        cLink := AllTrim(GetNewPar("ZZ_WMSCAPI", "http://cbcwms.cobrecom:3396"))
    endif
    reboot()
    oWebChannel := TWebChannel():New()
    nPort 		:= oWebChannel:connect()
    oTIBrw:= TWebEngine():New(oPanelBrw, 0, 0, (oFWLayer:GetLayerHeight() * 0.4), (oFWLayer:GETLAYERWIDTH()* 0.4),, nPort)
    oTIBrw:navigate(cLink)
    oTIBrw:Align := CONTROL_ALIGN_ALLCLIENT
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

static function joinOS(lAdd)
    local lOk      := .T.
    local cOs      := ''
    local lEdit    := .T.
    default lAdd   := .T.

    if !lAdd
        if !(AllTrim((cAls)->OS) <> (AllTrim((cAls)->PED) + AllTrim((cAls)->SEQ)))
            msgAlert('Não é possível EDITAR OSs não aglutinadas!','Não Aglutinadas')
            lOk := .F.
        endif
        cOs   := AllTrim((cAls)->OS)
        lEdit := (AllTrim((cAls)->SIT) == '1')
    endif
    if lOk
        u_cbcJoinOS(cOs, lEdit)
    endif
    FWMsgRun(, { || forcedRefresh() }, 	"Controle de Ordem de Separação", "Atualizando OS's...")
return(nil)

static function print()
    local aArea := GetArea()
    Local oStatic := IfcXFun():newIfcXFun()
    if lWms
        if Type('oTIBrw') <> "U"
            //cFunc := "mostrar();"
            //oTIBrw:runJavaScript(cFunc)
            oTIBrw:PrintPDF()
        endif
    else
        FWMsgRun(, { || oStatic:sP(2):callStatic('cbcPrtOS', 'cbcPrtOS', AllTrim((cAls)->OS), isJoined()) }, 	"Ordem de Separação", "Imprimindo OS's...")
    endif
    RestArea(aArea)
return(nil)

static function isJoined()
return(AllTrim((cAls)->OS) <> (AllTrim((cAls)->PED) + AllTrim((cAls)->SEQ)))

static function getFields(cOpc, cFldAls)
    local aRet      := {}
    default cFldAls := ''

    if cOpc == 'B'
        aAdd(aRet, {'OS',       {|| (oTable:GetAlias())->(OS)} ,GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PEDIDO'),1,(TamSx3('ZZR_PEDIDO')[1] + TamSx3('ZZR_SEQOS')[1]), 0})
        aAdd(aRet, {'Pedido',   {|| (oTable:GetAlias())->(PED)},GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PEDIDO'),1,TamSx3('ZZR_PEDIDO')[1],   0})
        aAdd(aRet, {'Seq',      {|| (oTable:GetAlias())->(SEQ)},GetSx3Cache('ZZR_SEQOS',  'X3_TIPO'), PesqPict('ZZR', 'ZZR_SEQOS') ,1,TamSx3('ZZR_SEQOS')[1],    0})
        aAdd(aRet, {'Tipo',     {|| (oTable:GetAlias())->(TP)}, GetSx3Cache('C5_TIPO',    'X3_TIPO'), PesqPict('SC5', 'C5_TIPO'),   1,TamSx3('C5_TIPO')[1],      0})
        aAdd(aRet, {'Cliente',  {|| (oTable:GetAlias())->(CLI)},GetSx3Cache('A1_COD',     'X3_TIPO'), PesqPict('SA1', 'A1_COD')  , 1,(TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1]),  0})
        aAdd(aRet, {'Nome',     {||(oTable:GetAlias())->(NOME)},GetSx3Cache('A1_NOME',    'X3_TIPO'), PesqPict('SA1', 'A1_NOME')  , 1,TamSx3('A1_NOME')[1],      0})
        aAdd(aRet, {'Peso',     {|| (oTable:GetAlias())->(PES)},GetSx3Cache('ZZR_PESPRO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PESPRO'),1,TamSx3('ZZR_PESPRO')[1],   2})
        aAdd(aRet, {'N.Fiscal', {|| (oTable:GetAlias())->(NFE)},GetSx3Cache('ZZR_DOC',    'X3_TIPO'), PesqPict('ZZR', 'ZZR_DOC') ,  1,TamSx3('ZZR_DOC')[1],      0})
        aAdd(aRet, {'Blq.Fat',  {|| (oTable:GetAlias())->(BLQ)},GetSx3Cache('C5_ZZBLVEN', 'X3_TIPO'), PesqPict('SC5', 'C5_ZZBLVEN'),1,TamSx3('C5_ZZBLVEN')[1],   0})
        aAdd(aRet, {'Entrega',  {|| (oTable:GetAlias())->(ENT)},GetSx3Cache('C5_ENTREG',  'X3_TIPO'), PesqPict('SC5', 'C5_ENTREG') ,1,TamSx3('C5_ENTREG')[1],    0})
        aAdd(aRet, {'Fatura' ,  {|| (oTable:GetAlias())->(FAT)},GetSx3Cache('C5_DTFAT',   'X3_TIPO'), PesqPict('SC5', 'C5_DTFAT')  ,1,TamSx3('C5_DTFAT')[1],     0})
        aAdd(aRet, {'Laudo',    {|| (oTable:GetAlias())->(LDO)},GetSx3Cache('C5_LAUDO',   'X3_TIPO'), PesqPict('SC5', 'C5_LAUDO')  ,1,TamSx3('C5_LAUDO')[1],     0})
        aAdd(aRet, {'Obs',      {|| (oTable:GetAlias())->(OBS)},GetSx3Cache('C5_OBS',     'X3_TIPO'), PesqPict('SC5', 'C5_OBS') ,   1,TamSx3('C5_OBS')[1],       0})
    elseif cOpc == 'B_JOIN'
        aAdd(aRet, {'OS',      {|| (cFldAls)->(OS)}, GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PEDIDO'),1,(TamSx3('ZZR_PEDIDO')[1] + TamSx3('ZZR_SEQOS')[1]), 0})
        aAdd(aRet, {'Pedido',  {|| (cFldAls)->(PED)},GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PEDIDO'),1,TamSx3('ZZR_PEDIDO')[1],   0})
        aAdd(aRet, {'Seq',     {|| (cFldAls)->(SEQ)},GetSx3Cache('ZZR_SEQOS',  'X3_TIPO'), PesqPict('ZZR', 'ZZR_SEQOS') ,1,TamSx3('ZZR_SEQOS')[1],    0})
        aAdd(aRet, {'Tipo',    {|| (cFldAls)->(TP)}, GetSx3Cache('C5_TIPO',    'X3_TIPO'), PesqPict('SC5', 'C5_TIPO') ,  1,TamSx3('C5_TIPO')[1],      0})
        aAdd(aRet, {'Cliente', {|| (cFldAls)->(CLI)},GetSx3Cache('A1_COD',     'X3_TIPO'), PesqPict('SA1', 'A1_COD')  ,  1,(TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1]),  0})
        aAdd(aRet, {'Nome',    {||(cFldAls)->(NOME)},GetSx3Cache('A1_NOME',    'X3_TIPO'), PesqPict('SA1', 'A1_NOME')  , 1,TamSx3('A1_NOME')[1],      0})
        aAdd(aRet, {'Peso',    {|| (cFldAls)->(PES)},GetSx3Cache('ZZR_PESPRO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PESPRO'),1,TamSx3('ZZR_PESPRO')[1],   2})
        aAdd(aRet, {'N.Fiscal',{|| (cFldAls)->(NFE)},GetSx3Cache('ZZR_DOC',    'X3_TIPO'), PesqPict('ZZR', 'ZZR_DOC') ,  1,TamSx3('ZZR_DOC')[1],      0})
        aAdd(aRet, {'Blq.Fat', {|| (cFldAls)->(BLQ)},GetSx3Cache('C5_ZZBLVEN', 'X3_TIPO'), PesqPict('SC5', 'C5_ZZBLVEN'),1,TamSx3('C5_ZZBLVEN')[1],   0})
        aAdd(aRet, {'Entrega', {|| (cFldAls)->(ENT)},GetSx3Cache('C5_ENTREG',  'X3_TIPO'), PesqPict('SC5', 'C5_ENTREG') ,1,TamSx3('C5_ENTREG')[1],    0})
        aAdd(aRet, {'Fatura' , {|| (cFldAls)->(FAT)},GetSx3Cache('C5_DTFAT',   'X3_TIPO'), PesqPict('SC5', 'C5_DTFAT')  ,1,TamSx3('C5_DTFAT')[1],     0})
        aAdd(aRet, {'Laudo',   {|| (cFldAls)->(LDO)},GetSx3Cache('C5_LAUDO',   'X3_TIPO'), PesqPict('SC5', 'C5_LAUDO') , 1,TamSx3('C5_LAUDO')[1],     0})
        aAdd(aRet, {'Obs',     {|| (cFldAls)->(OBS)},GetSx3Cache('C5_OBS',     'X3_TIPO'), PesqPict('SC5', 'C5_OBS') ,   1,TamSx3('C5_OBS')[1],       0})
    elseif cOpc == 'T'
        aAdd(aRet, {'OS',   GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'),   (TamSx3('ZZR_PEDIDO')[1] + TamSx3('ZZR_SEQOS')[1]), 0})
        aAdd(aRet, {'SIT',  GetSx3Cache('ZZR_SITUAC', 'X3_TIPO'),   TamSx3('ZZR_SITUAC')[1],    0})
        aAdd(aRet, {'PED',  GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'),   TamSx3('ZZR_PEDIDO')[1],    0})
        aAdd(aRet, {'SEQ',  GetSx3Cache('ZZR_SEQOS',  'X3_TIPO'),   TamSx3('ZZR_SEQOS')[1],     0})
        aAdd(aRet, {'TP',   GetSx3Cache('C5_TIPO',    'X3_TIPO'),   TamSx3('C5_TIPO')[1],       0})
        aAdd(aRet, {'CLI',  GetSx3Cache('A1_COD',     'X3_TIPO'),   (TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1]),  0})
        aAdd(aRet, {'NOME', GetSx3Cache('A1_NOME',    'X3_TIPO'),   TamSx3('A1_NOME')[1],       0})
        aAdd(aRet, {'PES',  GetSx3Cache('ZZR_PESPRO', 'X3_TIPO'),   TamSx3('ZZR_PESPRO')[1],    2})
        aAdd(aRet, {'NFE',  GetSx3Cache('ZZR_DOC',    'X3_TIPO'),   TamSx3('ZZR_DOC')[1],       0})
        aAdd(aRet, {'BLQ',  GetSx3Cache('C5_ZZBLVEN', 'X3_TIPO'),   TamSx3('C5_ZZBLVEN')[1],    0})
        aAdd(aRet, {'ENT',  GetSx3Cache('C5_ENTREG',  'X3_TIPO'),   TamSx3('C5_ENTREG')[1],     0})
        aAdd(aRet, {'FAT',  GetSx3Cache('C5_DTFAT',   'X3_TIPO'),   TamSx3('C5_DTFAT')[1],      0})
        aAdd(aRet, {'LDO',  GetSx3Cache('C5_LAUDO',   'X3_TIPO'),   TamSx3('C5_LAUDO')[1],      0})
        aAdd(aRet, {'OBS',  GetSx3Cache('C5_OBS',     'X3_TIPO'),   TamSx3('C5_OBS')[1],        0})
        aAdd(aRet, {'MARK',	GetSx3Cache('C9_OK',      'X3_TIPO'),   TamSx3('C9_OK')[1],         0})
    elseif cOpc = 'T_JOIN'
        aAdd(aRet, {'OS',  GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'),   (TamSx3('ZZR_PEDIDO')[1] + TamSx3('ZZR_SEQOS')[1]), 0})
        aAdd(aRet, {'SIT', GetSx3Cache('ZZR_SITUAC', 'X3_TIPO'),   TamSx3('ZZR_SITUAC')[1],   0})
        aAdd(aRet, {'PED', GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'),   TamSx3('ZZR_PEDIDO')[1],   0})
        aAdd(aRet, {'SEQ', GetSx3Cache('ZZR_SEQOS',  'X3_TIPO'),   TamSx3('ZZR_SEQOS')[1],    0})
        aAdd(aRet, {'TP',  GetSx3Cache('C5_TIPO',    'X3_TIPO'),   TamSx3('C5_TIPO')[1],      0})
        aAdd(aRet, {'CLI', GetSx3Cache('A1_COD',     'X3_TIPO'),   (TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1]),  0})
        aAdd(aRet, {'NOME',GetSx3Cache('A1_NOME',    'X3_TIPO'),   TamSx3('A1_NOME')[1],      0})
        aAdd(aRet, {'PES', GetSx3Cache('ZZR_PESPRO', 'X3_TIPO'),   TamSx3('ZZR_PESPRO')[1],   2})
        aAdd(aRet, {'NFE', GetSx3Cache('ZZR_DOC',    'X3_TIPO'),   TamSx3('ZZR_DOC')[1],      0})
        aAdd(aRet, {'BLQ', GetSx3Cache('C5_ZZBLVEN', 'X3_TIPO'),   TamSx3('C5_ZZBLVEN')[1],   0})
        aAdd(aRet, {'ENT', GetSx3Cache('C5_ENTREG',  'X3_TIPO'),   TamSx3('C5_ENTREG')[1],    0})
        aAdd(aRet, {'FAT', GetSx3Cache('C5_DTFAT',   'X3_TIPO'),   TamSx3('C5_DTFAT')[1],     0})
        aAdd(aRet, {'LDO', GetSx3Cache('C5_LAUDO',   'X3_TIPO'),   TamSx3('C5_LAUDO')[1],     0})
        aAdd(aRet, {'OBS', GetSx3Cache('C5_OBS',     'X3_TIPO'),   TamSx3('C5_OBS')[1],       0})
        aAdd(aRet, {'REC', 'N',                                    11,                        0})
        aAdd(aRet, {'MARK',GetSx3Cache('C9_OK',      'X3_TIPO'),   TamSx3('C9_OK')[1],        0})
    endif
return(aRet)

user function cbc01OSPds()
    local cEmp := '01'
    local cUni := '01'
    
    RPCClearEnv()
    RPCSetType(3)

    //Cria o MsApp
    MsApp():New('SIGAADV')
    oApp:CreateEnv()

    //Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
    PtSetTheme("OCEAN")

    //Define o programa de inicialização
    oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
        {|| RpcSetEnv(cEmp, cUni), }),;
        u_cbcVldCarga(),;
        Final("OSPDS FINALIZADO")}

    //Seta Atributos
    __lInternet := .F.
    lMsFinalAuto := .F.
    oApp:lMessageBar:= .T.
    oApp:cModDesc:= 'SIGAADV'

    //Inicia a Janela
    oApp:Activate()
return(nil)

user function cbc02OSPds()
    local cEmp := '01'
    local cUni := '02'
    
    RPCClearEnv()
    RPCSetType(3)

    //Cria o MsApp
    MsApp():New('SIGAADV')
    oApp:CreateEnv()

    //Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
    PtSetTheme("OCEAN")

    //Define o programa de inicialização
    oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
        {|| RpcSetEnv(cEmp, cUni), }),;
        u_cbcVldCarga(),;
        Final("OSPDS FINALIZADO")}

    //Seta Atributos
    __lInternet := .F.
    lMsFinalAuto := .F.
    oApp:lMessageBar:= .T.
    oApp:cModDesc:= 'SIGAADV'

    //Inicia a Janela
    oApp:Activate()
return(nil)
