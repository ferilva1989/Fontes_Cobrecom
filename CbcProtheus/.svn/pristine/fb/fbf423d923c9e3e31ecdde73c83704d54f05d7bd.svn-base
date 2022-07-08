#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"

user function cbcTraceBck(cParPed, cParOs, cParCar,cParFil)
    local cFilCbc 	:= ''
    local aArea 	:= GetArea()
    private cPedido := ''
    private cOrdCar := ''
    private cOrdSep := ''
    default cParPed := ''
    default cParOs  := ''
    default cParCar := ''
    default cParFil := ''

    if !empty(cParFil)
        cFilCbc 	:= cFilAnt
        cFilAnt     := cParFil
    endif

    if empty(cParPed) .and. empty(cParOs) .and. empty(cParCar)
        pergsTrace()
    else
        cPedido := cParPed
        cOrdCar := cParCar
        cOrdSep := cParOs
    endif
    FWMsgRun(,{|| viewTraceBck()},'TraceBack','Carregando...')

    if !empty(cFilCbc)
        cFilAnt	:= cFilCbc
    endif
    RestArea(aArea)
return(nil)

static function viewTraceBck()
    local bExportar     := {|| }
    private oModal      := nil
    private aCoors 	    := FWGetDialogSize( oMainWnd )
    private aHeader     := {}
    private aColsGrid   := {}
    private oFont	    := TFont():New("Arial",,12,,.T.)
    private oGridP      := nil
    private aHeaderAux  := {}

    bExportar     := {|| FWMsgRun(,{|| doPlan(oGridP) },'Gerando Planilha','Exportando...')}

    oModal  := FWDialogModal():New()
    oModal:setSize((aCoors[3] * 0.45),(aCoors[4] * 0.45))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Trace Back')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oModal:addButtons({{'', 'Exportar', bExportar, '',,.T.,.F.}})
    mntBrw('PRIN', @oGridP, oModal:getPanelMain())

    oModal:Activate()
    
    FreeObj(oFont)
    FreeObj(oGridP)
    FreeObj(oModal)
return(nil)

static function mntBrw(cOpc, oGrid, oPnl)
    oGrid := FWBrowse():New()
    aHeader     := {}
    aColsGrid   := {}
    mntHeader(cOpc)
    oGrid:DisableFilter()
    //oGrid:DisableConfig()
    oGrid:DisableReport()
    oGrid:DisableSeek()
    //oGrid:DisableSaveConfig()
    oGrid:SetFontBrowse(oFont)
    oGrid:SetDataArray()
    oGrid:lHeaderClick := .F.
    oGrid:SetColumns(aHeader)
    oGrid:SetArray(aColsGrid)
    oGrid:SetOwner(oPnl)
    if cOpc <> 'DET'
        oGrid:SetChange({ || .T.})
    endif
    mntDados(cOpc, @oGrid)
    oGrid:Activate()
return(nil)

static function mntHeader(cOpc)
    local nAtual     := 0
    local cGrid      := ''
    default cOpc     :=  'PRIN'
    
    aHeaderAux  := {}
    aHeader     := {}
    
    if cOpc == 'PRIN'
        cGrid := 'oGridP'    
        aAdd(aHeaderAux, {'Pedido',      GetSx3Cache('C5_NUM','X3_TIPO'),    TamSx3('C5_NUM')[1],     0, PesqPict('SC5', 'C5_NUM')})
        aAdd(aHeaderAux, {"Cliente",     GetSx3Cache('A1_NOME',   'X3_TIPO'), (TamSx3('A1_COD')[1]+TamSx3('A1_LOJA')[1]+TamSx3('A1_NOME')[1]), 0, PesqPict('SA1', 'A1_NOME')})
        aAdd(aHeaderAux, {'End.Cli',     GetSx3Cache('A1_END',    'X3_TIPO'),TamSx3('A1_END')[1],     0, PesqPict('SA1', 'A1_END')})
        aAdd(aHeaderAux, {'UF',          GetSx3Cache('A1_EST',    'X3_TIPO'),TamSx3('A1_EST')[1],     0, PesqPict('SA1', 'A1_EST')})
        aAdd(aHeaderAux, {'Municipio',   GetSx3Cache('A1_MUN',    'X3_TIPO'),TamSx3('A1_MUN')[1],     0, PesqPict('SA1', 'A1_MUN')})
        aAdd(aHeaderAux, {'End. Entreg.',GetSx3Cache('C5_ENDENT2','X3_TIPO'),TamSx3('C5_ENDENT2')[1], 0, PesqPict('SC5', 'C5_ENDENT2')})
        aAdd(aHeaderAux, {'Dt.Fat',      GetSx3Cache('C5_DTFAT',  'X3_TIPO'),TamSx3('C5_DTFAT')[1],   0, PesqPict('SC5', 'C5_DTFAT')})
        aAdd(aHeaderAux, {'Blq.Venda',   GetSx3Cache('C5_ZZBLVEN','X3_TIPO'),TamSx3('C5_ZZBLVEN')[1], 0, PesqPict('SC5', 'C5_ZZBLVEN')})
        aAdd(aHeaderAux, {'Agendar',     GetSx3Cache('A1_XAGENTR','X3_TIPO'),TamSx3('A1_XAGENTR')[1], 0, PesqPict('SA1', 'A1_XAGENTR')})
        aAdd(aHeaderAux, {'Observa.',    GetSx3Cache('C5_OBS',    'X3_TIPO'),TamSx3('C5_OBS')[1],     0, PesqPict('SC5', 'C5_OBS')}) 
        aAdd(aHeaderAux, {'Repres.',     GetSx3Cache('A3_NOME',   'X3_TIPO'),TamSx3('A3_NOME')[1],    0, PesqPict('SA3', 'A3_NOME')})
        aAdd(aHeaderAux, {'Atend.',      GetSx3Cache('A3_NOME',   'X3_TIPO'),TamSx3('A3_NOME')[1],    0, PesqPict('SA3', 'A3_NOME')})
        aAdd(aHeaderAux, {"Ordem Sep.",  GetSx3Cache('ZZ9_ORDSEP','X3_TIPO'),TamSx3('ZZ9_ORDSEP')[1], 0, PesqPict('ZZ9', 'ZZ9_ORDSEP')})
        aAdd(aHeaderAux, {'Dt.Sep.',     GetSx3Cache('ZZR_DATA','X3_TIPO'),  TamSx3('ZZR_DATA')[1],   0, PesqPict('ZZR', 'ZZR_DATA')}) 
        aAdd(aHeaderAux, {'Status OS',   GetSx3Cache('ZZR_SITUAC','X3_TIPO'),TamSx3('ZZR_SITUAC')[1], 0, PesqPict('ZZR', 'ZZR_SITUAC')})  
        aAdd(aHeaderAux, {'Perc.Exped.', 'C',    4,     0, "@!"})  
        aAdd(aHeaderAux, {'Carga',       GetSx3Cache('ZZ9_ORDCAR','X3_TIPO'),TamSx3('ZZ9_ORDCAR')[1], 0, PesqPict('ZZ9', 'ZZ9_ORDCAR')}) 
        aAdd(aHeaderAux, {'Dt.Carga',    GetSx3Cache('ZZ9_DATA','X3_TIPO'),  TamSx3('ZZ9_DATA')[1],   0, PesqPict('ZZ9', 'ZZ9_DATA')}) 
        aAdd(aHeaderAux, {'Status Carga',GetSx3Cache('ZZ9_STATUS','X3_TIPO'),TamSx3('ZZ9_STATUS')[1], 0, PesqPict('ZZ9', 'ZZ9_STATUS')}) 
        aAdd(aHeaderAux, {'Obs.Finance', GetSx3Cache('C5_OBS','X3_TIPO'),    TamSx3('C5_OBS')[1],     0, PesqPict('SC5', 'C5_OBS')}) 
        aAdd(aHeaderAux, {'N.Fiscal',    GetSx3Cache('D2_DOC',    'X3_TIPO'),(TamSx3('D2_DOC')[1]+TamSx3('D2_SERIE')[1]),     0, PesqPict('SD2', 'D2_DOC')})
        aAdd(aHeaderAux, {'Dt.NF',       GetSx3Cache('F2_EMISSAO','X3_TIPO'),TamSx3('F2_EMISSAO')[1], 0, PesqPict('SF2', 'F2_EMISSAO')}) 
        aAdd(aHeaderAux, {'Dt.Porta',    GetSx3Cache('F2_DTENTR','X3_TIPO'), TamSx3('F2_DTENTR')[1],  0, PesqPict('SF2', 'F2_DTENTR')}) 
        aAdd(aHeaderAux, {'Hr.Porta',    GetSx3Cache('F2_HRENTR','X3_TIPO'), TamSx3('F2_HRENTR')[1],  0, PesqPict('SF2', 'F2_HRENTR')}) 
    endif

    for nAtual := 1 to Len(aHeaderAux)
        aAdd(aHeader, FWBrwColumn():New())
        aHeader[nAtual]:SetData(&("{||" + cGrid + ":oData:aArray[" + cGrid + ":At(),"+Str(nAtual)+"]}"))
        aHeader[nAtual]:SetTitle( aHeaderAux[nAtual][1] )
        aHeader[nAtual]:SetType(aHeaderAux[nAtual][2] )
        aHeader[nAtual]:SetSize( aHeaderAux[nAtual][3] )
        aHeader[nAtual]:SetDecimal( aHeaderAux[nAtual][4] )
        aHeader[nAtual]:SetPicture( aHeaderAux[nAtual][5] )
    next nAtual
return(aHeader)

static function mntDados(cOpc, oGrid)
    local oSql       := nil
    Local oStatic    := IfcXFun():newIfcXFun()
    default cOpc     :=  'PRIN'
    //Zera a grid
    aColsGrid := {}

    if cOpc == 'PRIN'
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(qryTrace())
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                aAdd(aColsGrid, {oSql:getValue("PEDIDO"),; 
                                    oSql:getValue("NOME"),; 
                                    oSql:getValue("ENDCLI"),; 
                                    oSql:getValue("UF"),; 
                                    oSql:getValue("MUN"),; 
                                    oSql:getValue("ENTREGA"),; 
                                    StoD(oSql:getValue("DT_FAT")),; 
                                    oSql:getValue("BLQ_VEN"),; 
                                    oSql:getValue("AGENDA"),; 
                                    oSql:getValue("OBS"),; 
                                    oSql:getValue("REPRE"),;
                                    oSql:getValue("ATEND"),;
                                    oSql:getValue("ORDSEP"),; 
                                    StoD(oSql:getValue("DT_SEP")),; 
                                    statusDescri('WMS', AllTrim(oSql:getValue("STATUS_SEP"))),;
                                    statusWms(AllTrim(oSql:getValue("ORDSEP"))),;
                                    oSql:getValue("ORDCAR"),; 
                                    StoD(oSql:getValue("DT_CAR")),;
                                    statusDescri('CARGA', AllTrim(oSql:getValue("STATUS_CAR"))),; 
                                    AllTrim(oStatic:sP(2):callStatic('cbcMngFCarga', 'getObs', AllTrim(oSql:getValue("ORDCAR")), AllTrim(oSql:getValue("ORDSEP")))),;
                                    oSql:getValue("NF"),;
                                    StoD(oSql:getValue("NF_EMISSAO")),;
                                    StoD(oSql:getValue("DT_SAIDA")),;
                                    oSql:getValue("HR_SAIDA");
                                    })
                oSql:skip()
            endDo
        endif
        oSql:Close()
        FreeObj(oSql)
    endif
    oGrid:SetArray(aColsGrid)
    oGrid:Refresh()
return(nil)

static function doPlan(oGrid)
    local oFWMsExcel := nil
    local nX		 := 0
    local oExcel	 := nil
    local cNomArqv   := GetTempPath() + 'PlanTRACE_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Trace")
    oFWMsExcel:AddTable("Trace","TraceBack")
    
    for nX := 1 to len(aHeaderAux)
        oFWMsExcel:AddColumn("Trace","TraceBack",aHeaderAux[nX, 01],1)
    next nX
    
    for nX := 1 to len(oGrid:oData:aArray)
        oFWMsExcel:AddRow("Trace","TraceBack", AClone(oGrid:oData:aArray[nX]))
    next nX

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)

    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    FreeObj(oFWMsExcel)
    FreeObj(oExcel)
return(nil)

static function statusWms(cOS)
    local cStatus   := "0%"
    local aWhere    := {}
    local oInt      := cbcExpIntegra():newcbcExpIntegra(.F.)
    local oEnder    := JsonObject():new()
    local cTipo     := 'SEP'
    
    if !empty(cOS)
        aAdd(aWhere,{"mov_tipo", cTipo})
        aAdd(aWhere,{"codUnico", AllTrim(cOS)})

        oEnder := oInt:getEnder(aWhere)
        if len(oEnder) >= 1
            if ValType(oEnder[01]:GetJsonObject('perc_ocupado')) <> 'U'
                cStatus := cValToChar(oEnder[01]["perc_ocupado"]) + "%"
            endif
        endif
    endif
    FreeObj(oEnder)
    FreeObj(oInt)
return(cStatus)

static function qryTrace()
    local cQry := ''

    cQry += " SELECT SC6.C6_NUM AS [PEDIDO], "
    cQry += " SA1.A1_COD + '/' + SA1.A1_LOJA +'-'+ SA1.A1_NOME AS [NOME], "
    cQry += " SA1.A1_END AS [ENDCLI], "
    cQry += " SA1.A1_EST AS [UF], "
    cQry += " SA1.A1_MUN AS [MUN], "    
    cQry += " SC5.C5_ENDENT2 AS [ENTREGA], "
    cQry += " SC5.C5_DTFAT AS [DT_FAT], "
    cQry += " SC5.C5_ZZBLVEN AS [BLQ_VEN], "
    cQry += " SA1.A1_XAGENTR AS [AGENDA], " 
    cQry += " SC5.C5_OBS AS [OBS], "       
    cQry += " ISNULL(SA3REP.A3_NOME,'') AS [REPRE], "
    cQry += " ISNULL(SA3ATE.A3_NOME,'') AS [ATEND], "
    cQry += " ISNULL(ZZR.ZZR_OS, '') AS [ORDSEP], "
    cQry += " ISNULL(ZZR.ZZR_DATA, '') AS [DT_SEP], "
    cQry += " ISNULL(ZZR.ZZR_SITUAC, '') AS [STATUS_SEP],   "
    cQry += " ISNULL(ZZ9.ZZ9_ORDCAR,'') AS [ORDCAR], "
    cQry += " ISNULL(ZZ9.ZZ9_DATA, '') AS [DT_CAR], "
    cQry += " ISNULL(ZZ9.ZZ9_STATUS,'') AS [STATUS_CAR],   "
    cQry += " CASE "
    cQry += " 	WHEN SD2.D2_DOC IS NULL "
    cQry += " 		THEN '' "
    cQry += " 	ELSE SD2.D2_DOC + '/' + SD2.D2_SERIE "
    cQry += " END AS [NF], "
    cQry += " ISNULL(SF2.F2_EMISSAO, '') AS [NF_EMISSAO], "
    cQry += " ISNULL(SF2.F2_DTENTR, '') AS [DT_SAIDA], "
    cQry += " ISNULL(SF2.F2_HRENTR, '') AS [HR_SAIDA] "
    cQry += " FROM " + RetSqlName('SC5') + " SC5 WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('SC6') + " SC6 WITH(NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL "
    cQry += " 						AND SC5.C5_NUM = SC6.C6_NUM "
    cQry += " 						AND SC5.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 WITH(NOLOCK) ON SC5.C5_CLIENTE = SA1.A1_COD "
    cQry += " 						AND SC5.C5_LOJACLI = SA1.A1_LOJA "
    cQry += " 						AND SC5.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
    cQry += " LEFT JOIN " + RetSqlName('ZZR') + " ZZR WITH(NOLOCK) ON SC6.C6_FILIAL = ZZR.ZZR_FILIAL "
    cQry += " 						AND SC6.C6_NUM = ZZR.ZZR_PEDIDO "
    cQry += " 						AND SC6.C6_ITEM = SC6.C6_ITEM "
    cQry += " 						AND SC5.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " LEFT JOIN " + RetSqlName('ZZ9') + " ZZ9 WITH(NOLOCK) ON ZZR.ZZR_FILIAL = ZZ9.ZZ9_FILIAL "
    cQry += " 						AND ZZR.ZZR_OS = ZZ9.ZZ9_ORDSEP "
    cQry += " 						AND ZZR.D_E_L_E_T_ = ZZ9.D_E_L_E_T_ "
    cQry += " LEFT JOIN " + RetSqlName('SD2') + " SD2 WITH(NOLOCK) ON ZZR.ZZR_FILIAL = SD2.D2_FILIAL "
    cQry += " 						AND ZZR.ZZR_PEDIDO = SD2.D2_PEDIDO "
    cQry += " 						AND ZZR.ZZR_ITEMPV = SD2.D2_ITEMPV "
    cQry += " 						AND ZZR.ZZR_SEQOS  = SD2.D2_SEQOS "
    cQry += " 						AND ZZR.D_E_L_E_T_ = SD2.D_E_L_E_T_ "
    cQry += " LEFT JOIN " + RetSqlName('SF2') + " SF2 WITH(NOLOCK) ON SD2.D2_FILIAL = SF2.F2_FILIAL "
    cQry += " 									AND SD2.D2_DOC = SF2.F2_DOC "
    cQry += " 									AND SD2.D2_SERIE = SF2.F2_SERIE "
    cQry += " 									AND SD2.D_E_L_E_T_ = SF2.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SE4') + " SE4 WITH(NOLOCK) ON SC5.C5_CONDPAG  = SE4.E4_CODIGO "
    cQry += " 									AND SC5.D_E_L_E_T_	    = SE4.D_E_L_E_T_  "
    cQry += " LEFT JOIN " + RetSqlName('SA3') + " SA3REP WITH(NOLOCK) ON SC5.C5_VEND1  = SA3REP.A3_COD "
    cQry += " 									AND SC5.D_E_L_E_T_		= SA3REP.D_E_L_E_T_ "
    cQry += " LEFT JOIN " + RetSqlName('SA3') + " SA3ATE WITH(NOLOCK) ON SA3REP.A3_SUPER = SA3ATE.A3_COD "
    cQry += " 									AND SA3REP.D_E_L_E_T_   = SA3ATE.D_E_L_E_T_ "
    cQry += " WHERE SC5.C5_FILIAL = '" + xFilial('SC5') + "' "
    if !empty(cPedido)
        cQry += " AND SC5.C5_NUM = '" + cPedido + "'"
    endif
    if !empty(cOrdCar)
        cQry += " AND ZZ9.ZZ9_ORDCAR = '" + cOrdCar + "'"
    endif
    if !empty(cOrdSep)
        cQry += " AND ZZR.ZZR_OS = '" + cOrdSep + "'"
    endif
    cQry += " GROUP BY SC6.C6_NUM, ISNULL(ZZR.ZZR_OS, ''),   ISNULL(ZZ9.ZZ9_ORDCAR,''),  "
    cQry += " SD2.D2_DOC, SD2.D2_SERIE,   ISNULL(ZZR.ZZR_SITUAC, ''), ISNULL(ZZ9.ZZ9_STATUS,''),   "
    cQry += " SA1.A1_NOME, SC5.C5_DTFAT, SC5.C5_ZZBLVEN,  "
    cQry += " SC5.C5_OBS, SA1.A1_XAGENTR,  SC5.C5_ENDENT2,  "
    cQry += " SA1.A1_COD, SA1.A1_LOJA, ISNULL(SF2.F2_DTENTR, ''), ISNULL(SF2.F2_HRENTR, ''),  "
    cQry += " ISNULL(SA3REP.A3_NOME,''), ISNULL(SA3ATE.A3_NOME,''), ISNULL(SF2.F2_EMISSAO, ''), "
    cQry += " ISNULL(ZZR.ZZR_DATA, ''), ISNULL(ZZ9.ZZ9_DATA, ''), SA1.A1_EST, SA1.A1_MUN, SA1.A1_END "
    cQry += " ORDER BY SC6.C6_NUM "
return(cQry)

static function pergsTrace()
    local aRet      := {}
    local aParamBox := {}

    aAdd(aParamBox,{1,'Pesquisar: ', Space(TamSx3('ZZ9_ORDCAR')[1]), PesqPict('ZZ9','ZZ9_ORDCAR'),  "","","",50,.T.})
    aAdd(aParamBox,{3,"Tipo: ",      1, {"Pedido","Ord.Separação","Ord.Carga"}, 50,"",.F.})
    if ParamBox(aParamBox,"Parâmetros",@aRet)
        if aRet[02] == 1
            cPedido := AllTrim(aRet[01])
        elseif aRet[02] == 2
            cOrdSep := AllTrim(aRet[01])
        elseif aRet[02] == 3
            cOrdCar := AllTrim(aRet[01])
        endif
    endif
return(nil)

static function statusDescri(cOpc, cSts)
    local cDescri := ""

    if cOpc == 'WMS'
        if cSts == '1'
            cDescri := "Aguardando"
        elseif cSts == '2'
            cDescri := "Lib.Expedição"
        endif
    else
        if cSts == 'I' .or. cSts == 'G'
            cDescri := "em Logística"
        elseif cSts == 'D'
            cDescri := "em Financeiro"
        elseif cSts == 'L'
            cDescri := "em Faturamento"
        elseif cSts == 'F'
            cDescri := "Faturado"
        elseif cSts == 'C'
            cDescri := "Cancelado"
        endif
    endif
return(cDescri)
