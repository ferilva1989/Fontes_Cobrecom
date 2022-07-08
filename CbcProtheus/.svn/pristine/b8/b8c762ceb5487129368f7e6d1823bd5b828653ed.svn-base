#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"
#include 'cbcOrdemSep.ch'

user function cbcJoinOS(cOS, lLiberado)
    private oModal 		:= nil
    private oContainer  := nil
    private oFWExpLayer := nil
    private oLUPanel    := nil
    private oLDPanel    := nil
    private oRUPanel    := nil
    private oRDPanel    := nil
    private aMCoors 	:= FWGetDialogSize( oMainWnd )
    private oTabIn      := nil
    private oTabOut     := nil
    private cAlsIn      := ''
    private cAlsOut     := ''
    private cIDCli      := ''
    private cInOs       := ''
    private oBrwIn      := nil
    private oBrwOut     := nil
    private nPesoOut    := 0.00
    private nPesoIn     := 0.00
    private nOsOut      := 0
    private nOsIn       := 0
    private nInMarked   := 0
    private nOutMarked  := 0
    private oBtnJAdd    := nil
    private oSayOutQtd	:= nil
    private oSayOutPes	:= nil
    private oBtnJRem    := nil
    private oSayInQtd	:= nil
    private oSayInPes   := nil
    private oFontPrt	:= TFont():New("Arial",,20,,.T.)
    private lEdit       := lLiberado
    default cOS         := ''

    if empty(cOS)
        cInOs  := GetSXENum("ZZR","ZZR_OS")
    else
        cInOs := cOS
    endif

    getIDCli()

    oModal  := FWDialogModal():New()
    oModal:setSize((aMCoors[3] * 0.5),(aMCoors[4] * 0.5))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Aglutinação de OS')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:SetCss("")
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
    oFWExpLayer := FWLayer():New()
    oFWExpLayer:Init( oContainer, .F., .T. )

    //"Controles"
    oFWExpLayer:AddCollumn('COL_CTRL', 10, .F.)
    oFWExpLayer:AddWindow('COL_CTRL', 'WND_CTRL_OS', 'Ctrl. Selecionadas', 50, .T., .F.)
    oLUPanel := oFWExpLayer:GetWinPanel('COL_CTRL', 'WND_CTRL_OS')
    oFWExpLayer:AddWindow('COL_CTRL', 'WND_CTRL_AGLU', 'Ctrl. Aglutinadas', 50, .T., .F.)
    oLDPanel := oFWExpLayer:GetWinPanel('COL_CTRL', 'WND_CTRL_AGLU')

    oBtnJAdd := TButton():New(05,05, 'Adicionar',oLUPanel , {||FWMsgRun(,{|| makeJoin(.T., oTabOut:GetRealName(), oBrwOut:cFieldMark, oBrwOut:Mark()) },"Aglutinação de OS", "Adicionando Ordens Selecionadas...")},50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnJAdd:Disable()
    oSayOutQtd	:= TSay():New(35,05,	{||'Qtd: ' + cValToChar(nOsOut)}, oLUPanel,,oFontPrt,,,,.T.,,, 100, 25)
    oSayOutPes	:= TSay():New(70,05,	{||'Peso: ' + cValToChar(nPesoOut)}, oLUPanel,,oFontPrt,,,,.T.,,, 100, 25)

    oBtnJRem := TButton():New(05,05, 'Remover',	 oLDPanel , {||FWMsgRun(,{|| makeJoin(.F., oTabIn:GetRealName(), oBrwIn:cFieldMark, oBrwIn:Mark()) },"Aglutinação de OS", "Removendo Ordens Selecionadas...")},50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnJRem:Disable()
    oSayInQtd	:= TSay():New(35,05,	{||'Qtd: ' + cValToChar(nOsIn)}, oLDPanel,,oFontPrt,,,,.T.,,, 100, 25)
    oSayInPes	:= TSay():New(70,05,	{||'Peso: ' + cValToChar(nPesoIn)}, oLDPanel,,oFontPrt,,,,.T.,,, 100, 25)

    //"Detalhes"
    oFWExpLayer:AddCollumn('COL_BRW', 85, .F.)
    oFWExpLayer:AddWindow('COL_BRW', 'WND_OS', 'Ordens de Separação - Adicionar', 50, .T., .F.)
    oRUPanel := oFWExpLayer:GetWinPanel('COL_BRW', 'WND_OS')
    oFWExpLayer:AddWindow('COL_BRW', 'WND_AGLUT', 'Algutinadas - ' + cInOs, 50, .T., .F.)
    oRDPanel := oFWExpLayer:GetWinPanel('COL_BRW', 'WND_AGLUT')
    mntJoin()
    oModal:Activate()
    if empty(cOS)
        if nOsIn > 0
            ConfirmSX8()
        else
            RollBackSx8()
        endif
    endif

    FreeObj(oContainer)
    FreeObj(oFWExpLayer)
    FreeObj(oLUPanel)
    FreeObj(oLDPanel)
    FreeObj(oRUPanel)
    FreeObj(oRDPanel)
    FreeObj(oTabIn)
    FreeObj(oTabOut)
    FreeObj(oBrwIn)
    FreeObj(oBrwOut)
    FreeObj(oBtnJAdd)
    FreeObj(oSayOutQtd)
    FreeObj(oSayOutPes)
    FreeObj(oBtnJRem)
    FreeObj(oSayInQtd)
    FreeObj(oSayInPes)
    FreeObj(oFontPrt)
    FreeObj(oModal)
return(nil)

static function makeJoin(lAdd, cTab, cFld, cMarca)
    local oSql      := LibSqlObj():newLibSqlObj()
    local oCtrl     := cbcCtrlOS():newcbcCtrlOS()
    Local oStatic   := IfcXFun():newIfcXFun()
    default lAdd    := .T.
    oSql:newAlias(oStatic:sP(3):callStatic('cbcQryOrdSep', 'qryJoinSelected', cTab, cFld, cMarca))
    if oSql:hasRecords()
        oSql:goTop()
        BEGIN TRANSACTION
            while oSql:notIsEof()
                oCtrl:define(AllTrim(oSql:getValue('OS')))
                if !(oCtrl:update({{'ZZR_OS', iif(lAdd, cInOs, (AllTrim(oSql:getValue('PED')) + AllTrim(oSql:getValue('SEQ'))))}},; 
                    (AllTrim(oSql:getValue('PED')) + AllTrim(oSql:getValue('SEQ')))):isOk())
                    DisarmTransaction()
                    EXIT
                endif
                oSql:Skip()
            endDo
        END TRANSACTION
        if !oCtrl:isOk()
            msgAlert(oCtrl:getErrMsg(),'Erro Processamento')
        endif
    endif
    oSql:close()
    FreeObj(oSql)
    FreeObj(oCtrl)
    rfshJoin()
return(nil)

static function mntJoin()
    getIDCli()
    MntJoinTable()
    MntJoinBrw(@oBrwOut,@cAlsOut, 'Ordens de Separação - Selecionar',  @oRUPanel, {|| doJoinMark(cAlsOut, oBrwOut, @nPesoOut, @nOsOut, @oBtnJAdd, @oSayOutQtd, @oSayOutPes, lEdit, "+", @nOutMarked)}, {|| allJoinMark(cAlsOut, oBrwOut, @nPesoOut, @nOsOut, @oBtnJAdd, @oSayOutQtd, @oSayOutPes, lEdit, "+", @nOutMarked)})
    MntJoinBrw(@oBrwIn, @cAlsIn,  'Aglutinada: ' + cInOs, @oRDPanel, {|| doJoinMark(cAlsIn,  oBrwIn,  @nPesoIn,  @nOsIn,  @oBtnJRem, @oSayInQtd, @oSayInPes, lEdit, "-", nInMarked)}, {|| allJoinMark(cAlsIn,  oBrwIn,  @nPesoIn,  @nOsIn,  @oBtnJRem, @oSayInQtd, @oSayInPes, lEdit, "-", nInMarked)})
    oBrwOut:Refresh()
    oBrwIn:Refresh()
    getAgltInfo()
return(nil)

static function rfshJoin()
    oBrwOut:DeActivate()
    oBrwOut := nil
    if oTabOut <> nil
        oTabOut:Delete()
    endif
    oTabOut := nil
    oRUPanel:FreeChildren()

    oBrwIn:DeActivate()
    oBrwIn := nil
    if oTabIn <> nil
        oTabIn:Delete()
    endif
    oTabIn := nil
    oRDPanel:FreeChildren()

    mntJoin()
    nInMarked   := 0
    nOutMarked  := 0
    oBtnJAdd:Disable()
    oBtnJRem:Disable()
return(nil)

static function getAgltInfo()
    local oSql := LibSqlObj():newLibSqlObj()
    Local oStatic    := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(2):callStatic('cbcQryOrdSep', 'qryInfoJoin', cInOs, oTabIn:GetRealName()))
    if oSql:hasRecords()
        oSql:goTop()
        nOsIn := oSql:getValue("QTD")
        nPesoIn := oSql:getValue("PES")
    else
        nOsIn := 0
        nPesoIn := 0.00
    endif
    nOsOut := 0
    nPesoOut := 0.00
    oSayInQtd:Refresh()
    oSayInPes:Refresh()
    oSayOutQtd:Refresh()
    oSayOutPes:Refresh()
    oSql:close()
    FreeObj(oSql)
return(nil)

static function getIDCli()
    local oSql := LibSqlObj():newLibSqlObj()
    Local oStatic    := IfcXFun():newIfcXFun()

    oSql:newAlias(oStatic:sP(4):callStatic('cbcQryOrdSep', 'getQry', 'CLI', cInOs, '', nFilter))
    if oSql:hasRecords()
        oSql:goTop()
        cIDCli := oSql:getValue("CLI")
    else
        cIDCli := ''
    endif

    oSql:close()
    FreeObj(oSql)
return(cIDCli)

static function MntJoinTable()
    local aFlds     := getFields('T_JOIN')
    Local oStatic   := IfcXFun():newIfcXFun()

    oTabOut := FWTemporaryTable():New(nextAlias())
    oTabOut:SetFields(aFlds)
    oTabOut:AddIndex('OS',  {aFlds[1,1]} )
    oTabOut:AddIndex('CLI', {aFlds[6,1]} )
    oTabOut:AddIndex('NOME',{aFlds[7,1]} )
    oTabOut:Create()
    cAlsOut := oTabOut:GetAlias()
    //Carregar a Temp
    SQLToTrb(oStatic:sP(4):callStatic('cbcQryOrdSep', 'getQry', 'OUT', cInOs, cIDCli, nFilter), aFlds, (cAlsOut))

    oTabIn := FWTemporaryTable():New(nextAlias())
    oTabIn:SetFields(aFlds)
    oTabIn:AddIndex('OS',  {aFlds[1,1]} )
    oTabIn:AddIndex('CLI', {aFlds[6,1]} )
    oTabIn:AddIndex('NOME',{aFlds[7,1]} )
    oTabIn:Create()
    cAlsIn := oTabIn:GetAlias()
    //Carregar a Temp
    SQLToTrb(oStatic:sP(4):callStatic('cbcQryOrdSep', 'getQry', 'IN', cInOs, cIDCli, nFilter), aFlds, (cAlsIn))
return(nil)

static function MntJoinBrw(oMdlBrw, cMdlAls, cTitle, oMdlPanel, bMdlMark, bAllMark)
    oMdlBrw := FWMarkBrowse():New()
    oMdlBrw:SetFieldMark('MARK')
    oMdlBrw:SetCustomMarkRec(bMdlMark)
    oMdlBrw:SetSemaphore(.T.)
    oMdlBrw:SetOwner( oMdlPanel )
    oMdlBrw:SetDescription(cTitle)
    oMdlBrw:SetAlias(cMdlAls)
    oMdlBrw:SetMenuDef('')
    oMdlBrw:SetFields(getFields('B_JOIN', cMdlAls))
    //oMBrw:SetProfileID('AGLUT_OS')
    oMdlBrw:ForceQuitButton(.T.)
    oMdlBrw:DisableDetails()
    oMdlBrw:DisableReport()
    oMdlBrw:setIgnoreaRotina(.T.)
    oMdlBrw:SetUseFilter(.T.)
    oMdlBrw:SetSeek(.T.,;
        {;
        {"OS" ,{{"",GetSx3Cache('ZZR_OS', 'X3_TIPO'),;
        TamSx3('ZZR_OS')[1],;
        0,"OS",,PesqPict('ZZR', 'ZZR_OS')}}},;
        {"CLI" ,{{"",GetSx3Cache('A1_COD', 'X3_TIPO'),;
        (TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1]),;
        0,"CLI",,PesqPict('SA1', 'A1_COD')}}},;
        {"NOME" ,{{"",GetSx3Cache('A1_NOME', 'X3_TIPO'),;
        TamSx3('A1_NOME')[1],;
        0,"NOME",,PesqPict('SA1', 'A1_NOME')}}};
        };
        )
    oMdlBrw:AddButton('Inverter', {||FWMsgRun(, bAllMark,  'Invertendo Marcações', 'Marcando...')} ,,7,)
    oMdlBrw:Activate()
return(nil)

static function allJoinMark(cMAls, oMBrw, nPeso, nQtdOs, oBtn, oSay1, oSay2, lEdit, cOper, nMarked)
	local nRegAtual := 0
	local nMarks	:= 0
	
	oMBrw:GoTop(.T.)
	nRegAtual := oMBrw:At()
	//Percorrer os registros do browser 
	while .T.
		if !(doJoinMark(cMAls, oMBrw, @nPeso, @nQtdOs, @oBtn, @oSay1, @oSay2, lEdit, cOper, @nMarked))
            EXIT
        else
            nMarks++		
            oMBrw:GoDown(1, .F.)
            //Saida do loop Desceu um registro e continuou no mesmo significa que é o ultimo
            if nRegAtual == oMBrw:At()
                EXIT
            endIf
            nRegAtual := oMBrw:At()
        endif
	endDo
	oMBrw:GoTop(.T.)    
return(nMarks)

static function doJoinMark(cMAls, oMBrw, nPeso, nQtdOs, oBtn, oSay1, oSay2, lEdit, cOper, nMarked)
    local cMarca	:= oMBrw:Mark()
    local cFld 		:= oMBrw:cFieldMark
    local lMarked   := .F.
    local lRet      := .T.
    default lAdd    := .T.

    if !lEdit
        msgAlert('OS Liberada para WMS!','OS Bloqueada')
        lRet := .F.
    else
        if empty(cIDCli)
            cIDCli := (cMAls)->CLI
        endif
        if cIDCli <> (cMAls)->CLI
            msgAlert('Não é possível aglutinar OS de clientes diferentes!','Clientes Diferentes')
            lRet := .F.
        else
            if !((cMAls)->(RecLock(cMAls, .F.)))
                MsgAlert('Erro ao selecionar Registro!','Error')
                lRet := .F.
            else
                if (cMAls)->(&cFld) <> cMarca
                    (cMAls)->(&cFld) := cMarca
                    lMarked := .T.
                    nMarked++
                else
                    (cMAls)->(&cFld) := ' '
                    nMarked--
                endif
                (cMAls)->(MSUnlock())
            endif
            if lMarked

                &('nPeso'+ cOper + '= (cMAls)->PES')
                &('nQtdOs' + cOper + cOper)
            else
                &('nPeso' + cOper + '=((cMAls)->PES * -1)')
                &('nQtdOs'+ cOper + '=(-1)')
            endif
            if nMarked == 0
                getIDCli()
                oBtn:Disable()
            else
                oBtn:Enable()
            endif
            oSay1:Refresh()
            oSay2:Refresh()
        endif
    endif
return(lRet)

static function getFields(cOpc, cFldAls)
    local aRet      := {}
    default cFldAls := ''

    if cOpc == 'B_JOIN'
        aAdd(aRet, {'OS',      {|| (cFldAls)->(OS)}, GetSx3Cache('ZZR_OS', 'X3_TIPO'),     PesqPict('ZZR', 'ZZR_OS'),    1,TamSx3('ZZR_OS')[1],       0})
        aAdd(aRet, {'Pedido',  {|| (cFldAls)->(PED)},GetSx3Cache('ZZR_PEDIDO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PEDIDO'),1,TamSx3('ZZR_PEDIDO')[1],   0})
        aAdd(aRet, {'Seq',     {|| (cFldAls)->(SEQ)},GetSx3Cache('ZZR_SEQOS',  'X3_TIPO'), PesqPict('ZZR', 'ZZR_SEQOS') ,1,TamSx3('ZZR_SEQOS')[1],    0})
        aAdd(aRet, {'Tipo',    {|| (cFldAls)->(TP)}, GetSx3Cache('C5_TIPO',    'X3_TIPO'), PesqPict('SC5', 'C5_TIPO') ,  1,TamSx3('C5_TIPO')[1],      0})
        aAdd(aRet, {'Cliente', {|| (cFldAls)->(CLI)},GetSx3Cache('A1_COD',     'X3_TIPO'), PesqPict('SA1', 'A1_COD')  ,  1,(TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1]),  0})
        aAdd(aRet, {'Nome',    {|| (cFldAls)->(NOME)},GetSx3Cache('A1_NOME',    'X3_TIPO'), PesqPict('SA1', 'A1_NOME')  , 1,TamSx3('A1_NOME')[1],      0})
        aAdd(aRet, {'Peso',    {|| (cFldAls)->(PES)},GetSx3Cache('ZZR_PESPRO', 'X3_TIPO'), PesqPict('ZZR', 'ZZR_PESPRO'),1,TamSx3('ZZR_PESPRO')[1],   2})
        aAdd(aRet, {'N.Fiscal',{|| (cFldAls)->(NFE)},GetSx3Cache('ZZR_DOC',    'X3_TIPO'), PesqPict('ZZR', 'ZZR_DOC') ,  1,TamSx3('ZZR_DOC')[1],      0})
        aAdd(aRet, {'Blq.Fat', {|| (cFldAls)->(BLQ)},GetSx3Cache('C5_ZZBLVEN', 'X3_TIPO'), PesqPict('SC5', 'C5_ZZBLVEN'),1,TamSx3('C5_ZZBLVEN')[1],   0})
        aAdd(aRet, {'Entrega', {|| (cFldAls)->(ENT)},GetSx3Cache('C5_ENTREG',  'X3_TIPO'), PesqPict('SC5', 'C5_ENTREG') ,1,TamSx3('C5_ENTREG')[1],    0})
        aAdd(aRet, {'Fatura' , {|| (cFldAls)->(FAT)},GetSx3Cache('C5_DTFAT',   'X3_TIPO'), PesqPict('SC5', 'C5_DTFAT')  ,1,TamSx3('C5_DTFAT')[1],     0})
        aAdd(aRet, {'Laudo',   {|| (cFldAls)->(LDO)},GetSx3Cache('C5_LAUDO',   'X3_TIPO'), PesqPict('SC5', 'C5_LAUDO') , 1,TamSx3('C5_LAUDO')[1],     0})
        aAdd(aRet, {'Obs',     {|| (cFldAls)->(OBS)},GetSx3Cache('C5_OBS',     'X3_TIPO'), PesqPict('SC5', 'C5_OBS') ,   1,TamSx3('C5_OBS')[1],       0})
    elseif cOpc = 'T_JOIN'
        aAdd(aRet, {'OS',  GetSx3Cache('ZZR_OS', 'X3_TIPO'),       TamSx3('ZZR_OS')[1],       0})
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

static function nextAlias()
    local cAls := ''
    while .T.
        cAls := GetNextAlias()
        if (Select(cAls) <= 0)
            exit
        endIf
    endDo
return(cAls)
