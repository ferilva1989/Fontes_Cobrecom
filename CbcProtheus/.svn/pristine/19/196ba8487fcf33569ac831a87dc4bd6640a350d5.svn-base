#include 'protheus.ch'
#include 'parmtype.ch'
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

user function cbcMngCarga(cCarga, lLiberado, cSts)
    private oModal 		:= nil
    private oContainer  := nil
    private oFWExpLayer := nil
    private oLUPanel    := nil
    private oLDPanel    := nil
    private oRUPanel    := nil
    private oRDPanel    := nil
    private oGrpFilt    := nil
    private aMCoors 	:= FWGetDialogSize( oMainWnd )
    private oTabIn      := nil
    private oTabOut     := nil
    private cAlsIn      := ''
    private cAlsOut     := ''
    private aRota       := {}
    private cIDCli      := ''
    private cInCarga    := ''
    private cTransp     := ''
    private oBrwIn      := nil
    private oBrwOut     := nil
    private oBtnJRem    := nil
    private oBtnTransp  := nil
    private nPesoOut    := 0.00
    private nPesoIn     := 0.00
    private nQtdOut     := 0
    private nQtdIn      := 0
    private nInMarked   := 0
    private nOutMarked  := 0
    private oBtnJAdd    := nil
    private oBtnFilter  := nil
    private oBtnFat     := nil
    private oSayOutQtd	:= nil
    private oSayOutPes	:= nil
    private oSayInQtd	:= nil
    private oSayInPes   := nil
    private aRule       := {}
    private oCtrl       := cbcCtrlCarga():newcbcCtrlCarga()
    private oFontPrt	:= TFont():New("Arial",,15,,.T.)
    private oBtnVolume  := nil
    private oBtnPar     := nil
    private oGrpTransb  := nil
    private oBtnTrbAdd  := nil
    private oBtnTrbRem  := nil
    private oVol        := cbcCtrlVolum():newcbcCtrlVolum()
    private lEdit       := nil
    private lGrava      := .T.
    private lFat        := .T.
    private cStsFilt    := ""
    default cCarga      := ""
    default cSts        := ""
    default lLiberado   := .T.

    lEdit       := lLiberado
    cStsFilt    := cSts
    initRules()

    if empty(cCarga)
        cInCarga  := GetSXENum("ZZ9","ZZ9_ORDCAR")
        lGrava    := .F.
    else
        cInCarga := cCarga
    endif

    oCtrl:define(cInCarga)

    oModal  := FWDialogModal():New()
    oModal:setSize((aMCoors[3] * 0.5),(aMCoors[4] * 0.5))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Manutenção de Carga')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    //oModal:addOkButton({||FWMsgRun(,{|| rfshJoin()},"Aglutinação de OS", "Aglutinando Ordens...")}, "Concluir",{||.T.} )
    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:SetCss("")
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
    oFWExpLayer := FWLayer():New()
    oFWExpLayer:Init( oContainer, .F., .T. )

    //"Controles"
    oFWExpLayer:AddCollumn('COL_CTRL', 10, .F.)
    //"Detalhes"
    oFWExpLayer:AddCollumn('COL_BRW', 88, .F.)
    
    if lEdit //OUT
        //"Controles"
        oFWExpLayer:AddWindow('COL_CTRL', 'WND_CTRL_OUT', 'Ctrl. Selecionadas', 50, .T., .F.)
        oLUPanel := oFWExpLayer:GetWinPanel('COL_CTRL', 'WND_CTRL_OUT')
        //"Detalhes"
        oFWExpLayer:AddWindow('COL_BRW', 'WND_OUT', 'Ordens de Separação - Adicionar', 50, .T., .F.)
        oRUPanel := oFWExpLayer:GetWinPanel('COL_BRW', 'WND_OUT')
        detDefine('OUT', @oLUPanel)
        oGrpFilt := TGroup():New( 25,02,54,60,'Filtros',oLUPanel,,,.T.)
    endif

    //IN
    //"Controles"
    oFWExpLayer:AddWindow('COL_CTRL', 'WND_CTRL_IN', 'Ctrl. Carga', iif(lEdit, 50, 100), .T., .F.)
    oLDPanel := oFWExpLayer:GetWinPanel('COL_CTRL', 'WND_CTRL_IN')
    //"Detalhes"    
    oFWExpLayer:AddWindow('COL_BRW', 'WND_IN', 'Carga - ' + cInCarga, iif(lEdit, 50, 100), .T., .F.)
    oRDPanel := oFWExpLayer:GetWinPanel('COL_BRW', 'WND_IN')
    detDefine('IN',  @oLDPanel)
            
    mntBuild()

    sayTranport()

    SetKey(VK_F5, {|| msgObsFin()})
    
    oModal:Activate()
    
    SetKey(VK_F5, {||})

    if empty(cCarga)
        if nQtdIn > 0
            ConfirmSX8()
        else
            RollBackSx8()
        endif
    endif

    FreeObj(oBtnTrbAdd)
    FreeObj(oBtnTrbRem)
    FreeObj(oGrpTransb)
    FreeObj(oBtnFat)
    FreeObj(oGrpFilt)
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
    FreeObj(oBtnFilter)
    FreeObj(oSayOutQtd)
    FreeObj(oSayOutPes)
    FreeObj(oBtnJRem)
    FreeObj(oSayInQtd)
    FreeObj(oSayInPes)
    FreeObj(oFontPrt)
    FreeObj(oModal)
return(nil)

static function msgObsFin()
    local cMsg := ""

    if oTabIn <> nil
        if !(cAlsIn)->(Eof())
            if !empty((cAlsIn)->(FIN))
                cMsg := getFinObs((cAlsIn)->(OS))
                if !empty(cMsg)
                    MsgInfo(AllTrim(cMsg),'Obs. Financeiro')
                endif
            endif
        endif
    endif
return(nil)

static function initRules()
    if empty(aRule)
        aRule := oVol:loadRules('', '')[01,02]
    else
        aRule := u_cbcRulesVolum('','', aRule)
    endif
return(nil)

static function detDefine(cOpc, oPnlCtrl)

    if cOpc == 'OUT'
        oBtnJAdd    := TButton():New(05,05,'Adicionar', oPnlCtrl , {||FWMsgRun(,{|| makeCarga(.T., oTabOut:GetRealName(), oBrwOut:cFieldMark, oBrwOut:Mark()) },"Montagem de Carga", "Adicionando Ordens Selecionadas...")},50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
        oBtnJAdd:Disable()
        oBtnFilter  := TButton():New(32,04,'Rotas',     oPnlCtrl , {||FWMsgRun(,{|| RouteFilter() },"Filtro de Rota", "Adicionando Rotas...")},25,20,,,.F.,.T.,.F.,,.F.,,,.F. )
        oBtnFat     := TButton():New(32,32,'NFs',       oPnlCtrl , {||FWMsgRun(,{|| filtFat() },"Filtro de Rota", "Adicionando Rotas...")},25,20,,,.F.,.T.,.F.,,.F.,,,.F. )
        oBtnPar     := TButton():New(55,05,'Parâmetros',oPnlCtrl , {||FWMsgRun(,{|| initRules() },"Simulação de Volumes", "Simulando Volumes...")},50,20,,,.F.,.T.,.F.,,.F.,,,.F. )

        oSayOutQtd	:= TSay():New(82,05,	{||'Qtd    : ' + cValToChar(nQtdOut)}, oPnlCtrl,,oFontPrt,,,,.T.,,, 100, 15)
        oSayOutPes	:= TSay():New(100,05,	{||'Peso   : ' + cValToChar(nPesoOut)},oPnlCtrl,,oFontPrt,,,,.T.,,, 100, 15)
    elseif cOpc == 'IN'
        oBtnJRem    := TButton():New(05,05,'Remover',	oPnlCtrl , {||FWMsgRun(,{|| makeCarga(.F., oTabIn:GetRealName(), oBrwIn:cFieldMark, oBrwIn:Mark()) },"Montagem de Carga", "Removendo Ordens Selecionadas...")},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oBtnJRem:Disable()
        oBtnTransp  := TButton():New(22,05,'Transp.',   oPnlCtrl , {||FWMsgRun(,{|| defTransp(@cTransp) },"Transportadora", "Definindo Transportadora...")},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        oBtnVolume  := TButton():New(39,05,'Volumes',   oPnlCtrl , {||FWMsgRun(,{|| u_cbcViewVol(cInCarga) },"Volumes", "Gerar Volumes...")},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        if lEdit
            oBtnTrbAdd  := TButton():New(56,05,'Transbordo',oPnlCtrl , {||FWMsgRun(,{|| transbordo() },"Transbordo", "Adicionando Transbordo...")},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        else
            oBtnTrbAdd  := TButton():New(56,05,'Transferir',oPnlCtrl , {||FWMsgRun(,{|| transferir(cInCarga, (cAlsIn)->(OS)) },"Transferir", "Transferindo...")},50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        endif
        
        oSayInQtd	:= TSay():New(82,05,	{||'Qtd    : ' + cValToChar(nQtdIn)}, oPnlCtrl,,oFontPrt,,,,.T.,,, 100, 15)
        oSayInPes	:= TSay():New(100,05,	{||'Peso   : ' + cValToChar(nPesoIn)},oPnlCtrl,,oFontPrt,,,,.T.,,, 100, 15)
    endif
return(nil)

static function strRoute()
    local cRota := ''
    local nX    := 0

    for nX := 1 to len(aRota)
        if !empty(cRota)
            cRota += ","
        endif
        cRota += "'"
        cRota += aRota[nX]
        cRota += "'"
    next nX
return(cRota)

static function RouteFilter()
    local oModalFil		:= nil
    local oPnlFil		:= nil
    local oFont       	:= TFont():New("Arial",,35,,.T.)
    local cRota         := Space(TamSx3('C5_ROTA')[1])
    local bmntFilter	:= {|| FWMsgRun(,{|| mntFilter(@cRota, @oSayFil, @oGetFil)},'Filtrar Rota','Filtrando...')}
    local bLimpaR       := {|| FWMsgRun(,{|| mntFilter('', @oSayFil, @oGetFil, .T.) },'Filtrar Rota','Limpando Filtros...')}

    oModalFil:= FWDialogModal():New()
    oModalFil:setSize(150,250)
    oModalFil:SetEscClose(.T.)
    oModalFil:setTitle('Filtrar Rotas')
    oModalFil:createDialog()
    oModalFil:addCloseButton(nil, "Fechar")
    oModalFil:addOkButton(bmntFilter, "OK", {||.T.} )
    oModalFil:addButtons({{'', 'Limpar', bLimpaR, '',,.T.,.F.}})

    oPnlFil := TPanel():New( ,,, oModalFil:getPanelMain())
    oPnlFil:SetCss("")
    oPnlFil:Align := CONTROL_ALIGN_ALLCLIENT

    oSayFil		:= TSay():New(05, 05, {||'Filtro: ' + strRoute()},oPnlFil,,oFont,,,,.T.,CLR_RED,CLR_WHITE,230,60)
    oGetFil		:= TGet():New(65,05, { | u | If( PCount() == 0, cRota,cRota:= u ) },oPnlFil,230,30,"@!",/*&(cBlkVld)*/,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cRota,,,, )

    oModalFil:Activate()

    FreeObj(oFont)
    FreeObj(oSayFil)
    FreeObj(oGetFil)
    FreeObj(oPnlFil)
    FreeObj(oModalFil)
return(nil)

static function mntFilter(cRota, oSay, oGet, lAll)
    local nPos := 0
    default cRota:= ''
    default lAll := .F.

    if lAll
        aRota := {}
    else
        if !empty(AllTrim(cRota))
            nPos := aScan(aRota, cRota)
            if nPos > 0
                if MsgYesNo('Rota: ' + cRota + ' já adicionada ao filtro! Deseja remover?', 'Remover Filtro')
                    aDel(aRota, nPos)
                    aSize(aRota,(len(aRota)-1))
                endif
            else
                aAdd(aRota, cRota)
            endif
        endif
    endif
    rfshBuild()
    cRota := Space(TamSx3('C5_ROTA')[1])
    oSay:Refresh()
    oGet:Refresh()
return(nil)

static function makeCarga(lAdd, cTab, cFld, cMarca)
    local oSql      := LibSqlObj():newLibSqlObj()
    local aOS       := {}
    Local oStatic   := IfcXFun():newIfcXFun()
    default lAdd    := .T.

    oSql:newAlias(oStatic:sP(3):callStatic('cbcQryCarga', 'qryOSSelected', cTab, cFld, cMarca))
    if oSql:hasRecords()
        oSql:goTop()
        BEGIN TRANSACTION
            while oSql:notIsEof()
                aAdd(aOS, {AllTrim(oSql:getValue('OS')), AllTrim(oSql:getValue('ROTA')), AllTrim(oSql:getValue('FILORI'))})
                oSql:Skip()
            endDo
        END TRANSACTION
    endif
    oSql:close()

    if empty(aOS)
        msgAlert('Sem OSs selecionadas para adicionar na carga','Erro Processamento')
    else
        if lAdd
            if (oCtrl:add(aOS, '', aRule):isOK())
                oCtrl:update({{'ZZ9_TRANSP',''},{'ZZ9_JSCTE', '{}'}})
                lGrava := .T.
            endif
        else
            oCtrl:remove(aOS)
            /*
            if (oCtrl:remove(aOS):isOK())
                oCtrl:update({{'ZZ9_TRANSP',''},{'ZZ9_JSCTE', '{}'}})
            endif
            */
        endif
        if !(oCtrl:isOk())
            msgAlert(oCtrl:getErrMsg(),'Erro Processamento')
        endif
    endif
    FreeObj(oSql)
    rfshBuild()
return(nil)

static function mntBuild()
    //getIDCli()
    MntBuildTable()
    if lEdit
        MntBuildBrw(@oBrwOut,@cAlsOut, 'Ordens de Separação - Selecionar',;
            @oRUPanel, {|| doBuildMark(cAlsOut, oBrwOut, @nPesoOut, @nQtdOut,;
            @oBtnJAdd, @oSayOutQtd, @oSayOutPes, lEdit, "+", @nOutMarked)}, @nPesoOut, @nQtdOut,;
            @oBtnJAdd, @oSayOutQtd, @oSayOutPes, lEdit, "+", @nOutMarked)
        oBrwOut:Refresh()
    endif
    MntBuildBrw(@oBrwIn, @cAlsIn,  'Carga: ' + cInCarga,;
        @oRDPanel, {|| doBuildMark(cAlsIn,  oBrwIn,  @nPesoIn,  @nQtdIn,;
        @oBtnJRem, @oSayInQtd, @oSayInPes, lEdit, "-", @nInMarked)}, @nPesoIn,  @nQtdIn,;
        @oBtnJRem, @oSayInQtd, @oSayInPes, lEdit, "-", @nInMarked)    
    oBrwIn:Refresh()
    loadInfo()
return(nil)

static function rfshBuild()
    if lEdit
        oBrwOut:DeActivate()
        oBrwOut := nil
        if oTabOut <> nil
            oTabOut:Delete()
        endif
        oTabOut := nil
        oRUPanel:FreeChildren()
    endif

    oBrwIn:DeActivate()
    oBrwIn := nil
    if oTabIn <> nil
        oTabIn:Delete()
    endif
    oTabIn := nil
    oRDPanel:FreeChildren()

    mntBuild()
    nInMarked   := 0
    nOutMarked  := 0
    nQtdOut     := 0
    if oBtnJAdd <> nil
        oBtnJAdd:Disable()
    endif
    if oBtnJRem <> nil
        oBtnJRem:Disable()
    endif
    sayTranport()
return(nil)

static function loadInfo()
    local aInfo := loadVolumes(cInCarga)
    nPesoIn := aInfo[1]
    nQtdIn  := aInfo[2]
    if nQtdIn > 0
        oBtnVolume:Enable()
    else
        oBtnVolume:Disable()
    endif
    oSayInQtd:Refresh()
    oSayInPes:Refresh()
    if lEdit
        nOsOut   := 0
        nPesoOut := 0.00
        oSayOutQtd:Refresh()
        oSayOutPes:Refresh()
    endif
return(nil)

static function loadVolumes(cCarga)
    local aVol      := {}
    local nPes      := 0
    local nQtd      := 0
    local nX        := 0

    aVol := oVol:loadVolumes(cCarga)
    nQtd := len(aVol)
    for nX := 1 to nQtd
        if ValType(aVol[nX, 02]:GetJsonObject('PESOBRUTO')) <> 'U'
            nPes += aVol[nX, 02]['PESOBRUTO']
        endif
    next nX
return({nPes,nQtd})

static function MntBuildTable()
    local aFlds     := getFields('TBL_BUILD')
    Local oStatic   := IfcXFun():newIfcXFun()
    if lEdit
        oTabOut := FWTemporaryTable():New(nextAlias())
        oTabOut:SetFields(aFlds)
        oTabOut:AddIndex('ROTA',{aFlds[1,1]} )
        oTabOut:AddIndex('OS',  {aFlds[2,1]} )
        oTabOut:Create()
        cAlsOut := oTabOut:GetAlias()
        //Carregar a Temp
        SQLToTrb(oStatic:sP(3):callStatic('cbcQryCarga','qryAddView', '', strRoute(), lFat), aFlds, (cAlsOut))
    endif
    oTabIn := FWTemporaryTable():New(nextAlias())
    oTabIn:SetFields(aFlds)
    oTabIn:AddIndex('ROTA',{aFlds[1,1]} )
    oTabIn:AddIndex('OS',  {aFlds[2,1]} )
    oTabIn:Create()
    cAlsIn := oTabIn:GetAlias()
    //Carregar a Temp
    SQLToTrb(oStatic:sP(4):callStatic('cbcQryCarga', 'qryAddView', cInCarga, '',,cStsFilt), aFlds, (cAlsIn))
return(nil)


static function getFields(cOpc, cAls)
    local aRet      := {}
    default cAls    := ''

    if cOpc == 'BRW_BUILD'
        aAdd(aRet, {'Rota',     {|| (cAls)->(ROTA)},    GetSx3Cache('ZZ9_ROTA',  'X3_TIPO'),PesqPict('ZZ9', 'ZZ9_ROTA'),  1,TamSx3('ZZ9_ROTA')[1],      0})
        aAdd(aRet, {'Os',       {|| (cAls)->(OS)},      GetSx3Cache('ZZ9_ORDSEP','X3_TIPO'),PesqPict('ZZ9', 'ZZ9_ROTA'),  1,TamSx3('ZZ9_ORDSEP')[1],    0})
        aAdd(aRet, {'Cli',      {|| '[' + AllTrim((cAls)->(CLI))+ AllTrim((cAls)->(LOJA)) + ']-' + AllTrim((cAls)->(NOME))},;
            GetSx3Cache('A1_NOME',  'X3_TIPO'), PesqPict('SA1', 'A1_NOME'),   1,;
            (TamSx3('A1_COD')[1]+TamSx3('A1_LOJA')[1]+TamSx3('A1_NOME')[1]),      0})
        aAdd(aRet, {'Ender.',   {|| (cAls)->(ENDE)},    GetSx3Cache('A1_END',    'X3_TIPO'),PesqPict('SA1', 'A1_END'),    1,TamSx3('A1_END')[1],        0})
        aAdd(aRet, {'Munic.',   {|| (cAls)->(MUN)},     GetSx3Cache('A1_MUN',    'X3_TIPO'),PesqPict('SA1', 'A1_MUN'),    1,TamSx3('A1_MUN')[1],        0})
        aAdd(aRet, {'UF',       {|| (cAls)->(UF)},      GetSx3Cache('A1_EST',    'X3_TIPO'),PesqPict('SA1', 'A1_EST'),    1,TamSx3('A1_EST')[1],        0})
        aAdd(aRet, {'End.Entr.',{|| (cAls)->(ENT)},     GetSx3Cache('C5_ENDENT2','X3_TIPO'),PesqPict('SC5', 'C5_ENDENT2'),1,TamSx3('C5_ENDENT2')[1],    0})
        aAdd(aRet, {'Cond.Pag.',{|| (cAls)->(PAG)},     GetSx3Cache('E4_DESCRI', 'X3_TIPO'),PesqPict('SE4', 'E4_DESCRI'), 1,TamSx3('E4_DESCRI')[1],     0})
        aAdd(aRet, {'Dt.Fat',   {|| (cAls)->(FAT)},     GetSx3Cache('C5_DTFAT',  'X3_TIPO'),PesqPict('SC5', 'C5_DTFAT'),  1,TamSx3('C5_DTFAT')[1],      0})
        aAdd(aRet, {'Blq.Vend.',{|| (cAls)->(BLQ)},     GetSx3Cache('C5_ZZBLVEN','X3_TIPO'),PesqPict('SC5', 'C5_ZZBLVEN'),1,TamSx3('C5_ZZBLVEN')[1],    0})
        aAdd(aRet, {'Repre.',   {|| (cAls)->(REP)},     GetSx3Cache('A3_NOME',   'X3_TIPO'),PesqPict('SA3', 'A3_NOME'),   1,TamSx3('A3_NOME')[1],       0})
        aAdd(aRet, {'Atend.',   {|| (cAls)->(ATE)},     GetSx3Cache('A3_NOME',   'X3_TIPO'),PesqPict('SA3', 'A3_NOME'),   1,TamSx3('A3_NOME')[1],       0})
        aAdd(aRet, {'Agendar',  {|| (cAls)->(AGE)},     GetSx3Cache('A1_XAGENTR','X3_TIPO'),PesqPict('SA1', 'A1_XAGENTR'),1,TamSx3('A1_XAGENTR')[1],    0})
        aAdd(aRet, {'Obs.',     {|| (cAls)->(OBS)},     GetSx3Cache('C5_OBS',    'X3_TIPO'),PesqPict('SC5', 'C5_OBS'),    1,TamSx3('C5_OBS')[1],        0})
        aAdd(aRet, {'Obs.Fin',  {|| iif(empty((cAls)->(FIN)), '', getFinObs((cAls)->(OS)))}, GetSx3Cache('C5_OBS',    'X3_TIPO'),PesqPict('SC5', 'C5_OBS'),    1,TamSx3('C5_OBS')[1],        0})
        aAdd(aRet, {'Origem',   {|| (cAls)->(FILORI)},  GetSx3Cache('C9_FILIAL', 'X3_TIPO'),PesqPict('SC9', 'C9_FILIAL'), 1,TamSx3('C9_FILIAL')[1],     0})
    elseif cOpc == 'TBL_BUILD'
        aAdd(aRet, {'ROTA',  GetSx3Cache('ZZ9_ROTA',  'X3_TIPO'),TamSx3('ZZ9_ROTA')[1],     0})
        aAdd(aRet, {'OS',    GetSx3Cache('ZZ9_ORDSEP','X3_TIPO'),TamSx3('ZZ9_ORDSEP')[1],   0})
        aAdd(aRet, {'CLI',   GetSx3Cache('A1_COD',    'X3_TIPO'),TamSx3('A1_COD')[1],       0})
        aAdd(aRet, {'LOJA',  GetSx3Cache('A1_LOJA',   'X3_TIPO'),TamSx3('A1_LOJA')[1],      0})
        aAdd(aRet, {'NOME',  GetSx3Cache('A1_NOME',   'X3_TIPO'),TamSx3('A1_NOME')[1],      0})
        aAdd(aRet, {'ENDE',  GetSx3Cache('A1_END',    'X3_TIPO'),TamSx3('A1_END')[1],       0})
        aAdd(aRet, {'UF',    GetSx3Cache('A1_EST',    'X3_TIPO'),TamSx3('A1_EST')[1],       0})
        aAdd(aRet, {'MUN',   GetSx3Cache('A1_MUN',    'X3_TIPO'),TamSx3('A1_MUN')[1],       0})
        aAdd(aRet, {'ENT',   GetSx3Cache('C5_ENDENT2','X3_TIPO'),TamSx3('C5_ENDENT2')[1],   0})
        aAdd(aRet, {'PAG',   GetSx3Cache('E4_DESCRI', 'X3_TIPO'),TamSx3('E4_DESCRI')[1],    0})
        aAdd(aRet, {'FAT',   GetSx3Cache('C5_DTFAT',  'X3_TIPO'),TamSx3('C5_DTFAT')[1],     0})
        aAdd(aRet, {'BLQ',   GetSx3Cache('C5_ZZBLVEN','X3_TIPO'),TamSx3('C5_ZZBLVEN')[1],   0})
        aAdd(aRet, {'REP',   GetSx3Cache('A3_NOME',   'X3_TIPO'),TamSx3('A3_NOME')[1],      0})
        aAdd(aRet, {'ATE',   GetSx3Cache('A3_NOME',   'X3_TIPO'),TamSx3('A3_NOME')[1],      0})
        aAdd(aRet, {'AGE',   GetSx3Cache('A1_XAGENTR','X3_TIPO'),TamSx3('A1_XAGENTR')[1],   0})
        aAdd(aRet, {'OBS',   GetSx3Cache('C5_OBS',    'X3_TIPO'),TamSx3('C5_OBS')[1],       0})
        aAdd(aRet, {'PES',   GetSx3Cache('ZZR_PESPRO','X3_TIPO'),TamSx3('ZZR_PESPRO')[1],   2})
        aAdd(aRet, {'FIN',   GetSx3Cache('ZZ9_FLGFIN','X3_TIPO'),TamSx3('ZZ9_FLGFIN')[1],   0})
        aAdd(aRet, {'MARK',	 GetSx3Cache('C9_OK',     'X3_TIPO'),TamSx3('C9_OK')[1],        0})
        aAdd(aRet, {'FILORI',GetSx3Cache('C9_FILIAL', 'X3_TIPO'),TamSx3('C9_FILIAL')[1],    0})
    endif
return(aRet)

static function MntBuildBrw(oMdlBrw, cMdlAls, cTitle, oMdlPanel, bMdlMark, nPeso,  nQtd, oBtn, oSayQtd, oSayPes, lEdit, cOper, nMarked)
    oMdlBrw := FWMarkBrowse():New()
    oMdlBrw:SetFieldMark('MARK')
    oMdlBrw:SetCustomMarkRec(bMdlMark)
    oMdlBrw:SetSemaphore(.T.)
    oMdlBrw:SetOwner( oMdlPanel )
    oMdlBrw:SetDescription(cTitle)
    oMdlBrw:SetAlias(cMdlAls)
    oMdlBrw:SetMenuDef('')
    oMdlBrw:SetFields(getFields('BRW_BUILD', cMdlAls))
    //oMBrw:SetProfileID('AGLUT_OS')
    oMdlBrw:ForceQuitButton(.T.)
    oMdlBrw:DisableDetails()
    oMdlBrw:DisableReport()
    oMdlBrw:setIgnoreaRotina(.T.)
    oMdlBrw:SetUseFilter(.T.)
    //oMdlBrw:SetUseCaseFilter(.T.)
    oMdlBrw:SetSeek(.T.,;
        {;
        {"ROTA" ,{{"",GetSx3Cache('C5_ROTA', 'X3_TIPO'),;
        TamSx3('C5_ROTA')[1],;
        0,"ROTA",,PesqPict('SC5', 'C5_ROTA')}}},;
        {"OS" ,{{"",GetSx3Cache('ZZ9_ORDSEP', 'X3_TIPO'),;
        TamSx3('ZZ9_ORDSEP')[1],;
        0,"OS",,PesqPict('ZZ9', 'ZZ9_ORDSEP')}}};
        };
        )
    oMdlBrw:AddButton('Inverter Marcações', {|| FWMsgRun(,{|| MarkAll(@oMdlBrw, @nPeso, @nQtd, @oBtn, @oSayQtd, @oSayPes, lEdit, cOper, @nMarked)}, 'Selecionando...', 'Inventendo Marcações...')},,4)
    oMdlBrw:Activate()
return(nil)

static function doBuildMark(cMAls, oMBrw, nPeso, nQtdOs, oBtn, oSay1, oSay2, lEdit, cOper, nMarked)
    local cMarca	:= oMBrw:Mark()
    local cFld 		:= oMBrw:cFieldMark
    local lMarked   := .F.
    default lAdd    := .T.

    if !lEdit
        msgAlert('Carga já Liberada para Faturamento!','Carga Bloqueada')
    else
        if !((cMAls)->(RecLock(cMAls, .F.)))
            MsgAlert('Erro ao selecionar Registro!','Error')
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
            oBtn:Disable()
        else
            if lEdit
                oBtn:Enable()
            endif
        endif
        oSay1:Refresh()
        oSay2:Refresh()
    endif
return(nil)

static function defTransp(cTransp)
    oCtrl:setTransp(@cTransp, lGrava, .T.)
    sayTranport()
return(cTransp)

static function sayTranport()
    local aTransp     := {'', 'NÃO DEFINIDA'}
    Local oStatic       := IfcXFun():newIfcXFun()
    if !empty(cTransp) .and. !lGrava
        aTransp := {cTransp, oStatic:sP(1):callStatic('cbcCtrlCarga', 'transpName', cTransp)}
    else
        aTransp := oCtrl:getTransp()
        cTransp := aTransp[1]
    endif
    oModal:oBottom:cTitle   := 'TRANSPORTADORA: ' + aTransp[2]
    oModal:oBottom:oFont    := oFontPrt
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

static function MarkAll(oBrw, nPeso, nQtd, oBtn, oSayQtd, oSayPes, lEdit, cOper, nMarked)
	local cAls	  	:= oBrw:Alias()
	local nRegAtual := 0
    local nMarks    := 0
	oBrw:GoTop(.T.)
	nRegAtual := oBrw:At()

	//Percorrer os registros do browser
	while .T.		
        //TODO MARKALL
        doBuildMark(cAls, oBrw, @nPeso, @nQtd, @oBtn, @oSayQtd, @oSayPes, lEdit, cOper, @nMarked)
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

static function filtFat()
    local oModalMsg		:= nil	
	local oPnlMsg		:= nil
    local oFont		    := TFont():New("Arial",,12,,.T.)
	local oFontBtn		:= TFont():New("Arial",,20,,.T.)
	local oBtnYes		:= nil
	local oBtnNo		:= nil
    local oSay          := nil
	local cBtnYes		:= 'Ativar'
	local cBtnNo		:= 'Desativar'
	local bBtnYes		:= {|| FWMsgRun(, { || doFilFat(.T., oModalMsg)}, "Adicionando Filtro", "Filtrando Faturadas...")}
	local bBtnNo		:= {|| FWMsgRun(, { || doFilFat(.F., oModalMsg)}, "Removendo Filtro", "Removendo Filtro de Faturadas...")}
			
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

    oSay	:= TSay():New(01,05,	{||'Filtro: ' + iif(lFat, 'Ativado', 'Desativado')}, oPnlMsg,,oFont,,,,.T., CLR_BLUE, /*CLR_WHITE*/, 190, 25)
    oSay:SetTextAlign( 2, 2 )
   	oBtnYes 	:= TButton():New( 20, 05,  cBtnYes, 	oPnlMsg , bBtnYes, 	90,30,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnNo	 	:= TButton():New( 20, 105,  cBtnNo,	oPnlMsg , bBtnNo, 		90,30,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )
	if lFat
        oBtnYes:Disable()
    else
        oBtnNo:Disable()
    endif
    
    oModalMsg:Activate()
	    
    FreeObj(oSay)
    FreeObj(oBtnYes)
	FreeObj(oBtnNo)
    FreeObj(oPnlMsg)
    FreeObj(oModalMsg)
    FWMsgRun(, { || rfshBuild()}, "Analise Carga", "Atualizando...")    
return(nil)

static function doFilFat(lMyFat, oModal)
    lFat := lMyFat
    oModal:DeActivate()
return(nil)

static function getFinObs(cOS)
    local aArea    	:= GetArea()
    local cObs      := ""
    Local oStatic   := IfcXFun():newIfcXFun()

    cObs := oStatic:sP(2):callStatic('cbcMngFCarga', 'getObs', AllTrim(cInCarga), AllTrim(cOS))
    
    RestArea(aArea)
return(cObs)

static function transbordo()
    local bProcess	:= { || FWMsgRun(, {|| procTransbordo()}, 	"Transbordo NFe", "Transbordo de NFe...")}

    u_cbcWMSNFe(bProcess, "SF2")
return(nil)

static function procTransbordo()
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local aFldValue := {}
    local oSql      := LibSqlObj():newLibSqlObj()
    Local oStatic   := IfcXFun():newIfcXFun()
    
    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryCarga', 'qryNotaxCarga'))
    if oSql:hasRecords()
        DbSelectArea("ZZ9")
        oSql:goTop()
        BEGIN TRANSACTION
            while oSql:notIsEof()
                if empty(oSql:getValue('CARGA'))
                    ZZ9->(DbGoTo(oSql:getValue('REC')))
                    aFldValue := {}
                    aAdd(aFldValue, {'ZZ9_FILIAL', FwFilial()})
                    aAdd(aFldValue, {'ZZ9_FILORI', ZZ9->ZZ9_FILIAL})
                    aAdd(aFldValue, {'ZZ9_ORDCAR', oCtrl:getCarga()})
                    aAdd(aFldValue, {'ZZ9_ORDSEP', ZZ9->ZZ9_ORDSEP})
                    aAdd(aFldValue, {'ZZ9_ROTA',   'TRB'})
                    aAdd(aFldValue, {'ZZ9_PRIORI', ZZ9->ZZ9_PRIORI})
                    aAdd(aFldValue, {'ZZ9_FLGFIN', ZZ9->ZZ9_FLGFIN})
                    aAdd(aFldValue, {'ZZ9_USER',   RetCodUsr()})
                    aAdd(aFldValue, {'ZZ9_DATA',   DtoC(Date())})
                    aAdd(aFldValue, {'ZZ9_HORA',   time()})
                    aAdd(aFldValue, {'ZZ9_STATUS', CARGA_FATURADA})
                    aAdd(aFldValue, {'ZZ9_JSVOLU', ZZ9->ZZ9_JSVOLU})
                    aAdd(aFldValue, {'ZZ9_TRANSP', ''})
                    aAdd(aFldValue, {'ZZ9_JSINFO', ZZ9_JSINFO})
                    aAdd(aFldValue, {'ZZ9_JSCTE',  '{}'})
                    aAdd(aFldValue, {'ZZ9_PLCVEI', ''})
                    aAdd(aFldValue, {'ZZ9_DOC', ZZ9->ZZ9_DOC})
                    aAdd(aFldValue, {'ZZ9_SERIE', ZZ9->ZZ9_SERIE})
                    oCtrl:insert(aFldValue)
                    if !(oCtrl:isOk())
                        DisarmTransaction()
                        msgAlert(oCtrl:getErrMsg(),'Erro Processamento')
                        EXIT
                    endif
                else
                    msgAlert('NF já está em transbordo na Carga:' + AllTrim(oSql:getValue('CARGA')),'Erro Processamento')
                endif
                oSql:Skip()
            endDo
        END TRANSACTION
    else
        msgAlert('NF sem Carga na filial de Origem!','Erro Processamento')
    endif
    oSql:close()
    FreeObj(oSql)

    rfshBuild()
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(nil) 

static function transferir(cMyCarga, cMyOs)
    local aArea    	:= GetArea()
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local aPerg     := {}
    local aRet      := {}
    local lOk       := .T.
    local cMsgErr   := ""
    local cTrfCar   := ""
    local aFldValue := {}

    aAdd(aPerg,{3,"Operação: ", 1, {"Nova","Iniciada"},               50,"",.F.})
    aAdd(aPerg,{1,"Carga: ", Space(TamSX3("ZZ9_ORDCAR")[01]), "", "Vazio().Or.ExistCPO('ZZ9')","ZZ9","MV_PAR01 == 2",50,.F.})
    if (ParamBox(aPerg,"Transferir Carga",@aRet))
        if aRet[01] == 2
            if !(lOk := !empty(aRet[02]))
                cMsgErr:= 'Ordem de Carga de Destino não informada!'
            else
                if !(lOk := vldTransf(aRet[02]))
                    cMsgErr:= 'Ordem de Carga de Destino já processada!'
                else
                    cTrfCar := aRet[02]
                endif
            endif
        endif
        if lOk
            if empty(cTrfCar)
                cTrfCar  := GetSXENum("ZZ9","ZZ9_ORDCAR")
            endif
            aAdd(aFldValue, {'ZZ9_ORDCAR', cTrfCar})
            if !(lOk := oCtrl:update(aFldValue, cMyOs):isOk())
                cMsgErr:= oCtrl:getErrMsg()
            endif
        endif
        if !lOk
            if aRet[01] == 1
                RollBackSx8()
            endif
            MsgAlert(cMsgErr, 'Ordem de Carga')
        else
            if aRet[01] == 1
                ConfirmSX8()
            endif
            MsgInfo('Transferencia para carga ' + cTrfCar + ' realizada!', 'Transferência de Carga')
        endif
    endif
    rfshBuild()
    RestArea(aAreaZZ9)
    RestArea(aArea)
return(nil)

static function vldTransf(cMyCarga)
    local lRet      := .T.
    local lVldSts   := GetNewPar("ZZ_VLDTRFS",.F.)
    local oCarga    := cbcCtrlCarga():newcbcCtrlCarga()
    oCarga:define(cMyCarga)
    if lVldSts
        lRet := (oCarga:getStatus() == CARGA_INICIO )
    endif
    FreeObj(oCarga)
return(lRet)

