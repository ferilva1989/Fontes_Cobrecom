#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function cbcVldCarga()
    FWMsgRun(,{|| viewVldCarga()},'Valida Carga','Carregando...')
return(nil)

static function viewVldCarga()
    local oPnl	 		:= nil
	local oFont			:= TFont():New("Arial",,30,,.T.)
	local bConfirm 		:= { || FWMsgRun(, {|| processa()}, 	"Validando WMS", "Comunicando com WMS...")}
	local bBlkVld		:= { || valida()}
    local aButtons      := {}
	private oModal 		:= nil
	private cCarga		:= Space(TamSX3("ZZ9_ORDCAR")[1])
	private oGet		:= nil
	
    __cInterNet := nil 
    
	oModal := FWDialogModal():New() 
	oModal:setSize(100,300)
	oModal:SetEscClose(.T.)
    oModal:setBackground(.T.)
	oModal:setTitle('Informe a CARGA')
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oModal:addOkButton(bConfirm, "Confirma", {||.T.} )
    aadd(aButtons, {,'Confere Peso',{||FWMsgRun(,{|| zvldPeso()},'Obtendos dados','Aguarde...')}, 'imprimir',,.T.,.F.})
    aadd(aButtons, {,'Imprimir OS',{||FWMsgRun(,{|| zprintOsCar()},'Imprimindo OS','Aguarde...')}, 'imprimir',,.T.,.F.})
	oModal:addButtons(aButtons)
    oPnl := TPanel():New( ,,, oModal:getPanelMain() ) 
	oPnl:SetCss("")
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
    
    oGet := TGet():New(05,05, { | u | If( PCount() == 0, cCarga,cCarga:= u ) },oPnl,290,030,"@!", bBlkVld,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCarga,,,, )
    
    setMsgCss(@oModal:oSayTitle)
   	setMsgCss(@oModal:oTop)
    
    oModal:Activate()
    
    FreeObj(oGet)
    FreeObj(oFont)
    FreeObj(oPnl)
    FreeObj(oModal)
return(nil)


static function zvldPeso()
    local oRest         := nil
    local aHeader       := {}
    local oApiJs        := nil
    local cTexto        := ''
    local linha	        := chr(13) + chr(10)
    local oModal        := nil
    local nX            := 0
    local nY            := 0
    local nZ            := 0
    local aNota         := {}
    local aPesagem      := {}
    local aBobina       := {}
    local oListNota     := nil
    local oListPesagem  := nil
    local oListBobina   := nil
    local nPalCarga     := 0
    local nPos          := 0


    if empty(cCarga) .Or. Len(cCarga) != TamSx3('ZZ9_ORDCAR')[1]
        MsgAlert('Carga Inválida!', 'Validação de Carga')
    else
        oApiJs  := JsonObject():new()
        aadd(aHeader, 'Content-Type: application/json')
        oRest := FWRest():New(GetNewPar('AP_IZWMS','http://192.168.1.220:7873/ws'))
        oRest:SetPath("/CBCWMS/DETCARGA?numero="+Alltrim(cCarga))
        if !(oRest:Get(aHeader))
            MsgInfo('Dados não obtidos', 'Aviso')
        else
            oApiJs:fromJson( oRest:GetResult())
            cTexto +=  '<h2>'
            cTexto += 'Peso Interno:  ' 
            cTexto +=  '<b>'
            cTexto +=  cValToChar( (oApiJs['PB_BOB'] + oApiJs['PB_EXP']) )
            cTexto +=  '</b>' 
            cTexto +=  '</h2>'
            cTexto += linha
            cTexto +=  '<h2>'
            cTexto += 'Peso Nota:  ' 
            cTexto +=  '<b>'
            cTexto +=  cValToChar( cValToChar(oApiJs['PB_NOTA']) )
            cTexto +=  '</b>'
            cTexto +=  '</h2>'
            cTexto += linha
            cTexto +=  '<h2>'
            cTexto += 'Peso Bobina:  ' 
            cTexto +=  '<b>'
            cTexto +=  cValToChar( cValToChar(oApiJs['PB_BOB']) )
            cTexto +=  '</b>'
            cTexto +=  '</h2>'
           
            for nX := 1 to len(oApiJs['DATA'])
                aadd(aNota,{;
                oApiJs['DATA'][nX]['Nota']['NF'],;
                oApiJs['DATA'][nX]['Nota']['CLI'],;
                oApiJs['DATA'][nX]['Nota']['VOL'],;
                cValToChar(oApiJs['DATA'][nX]['Nota']['P_BRU']),;
                cValToChar(oApiJs['DATA'][nX]['Nota']['P_LIQ']),;
                oApiJs['DATA'][nX]['NroOs']} )

                if oApiJs['DATA'][nX]['Interno']['STS']
                    for nY := 1 to len(oApiJs['DATA'][nX]['Interno']['P'])
                        if oApiJs['DATA'][nX]['Interno']['P'][nY]['paletizar']
                            nPalCarga++
                        endif
                        
                        aadd(aPesagem, {;
                        oApiJs['DATA'][nX]['Interno']['P'][nY]['ordemSeparacao'],;
                        cValToChar(oApiJs['DATA'][nX]['Interno']['P'][nY]['tara']),;
                        oApiJs['DATA'][nX]['Interno']['P'][nY]['operador'],;
                        iif(oApiJs['DATA'][nX]['Interno']['P'][nY]['paletizar'],'SIM','NAO'),;
                        cValToChar(oApiJs['DATA'][nX]['Interno']['P'][nY]['data']),;
                        cValToChar(oApiJs['DATA'][nX]['Interno']['P'][nY]['nPesoBruto']),;
                        cValToChar(oApiJs['DATA'][nX]['Interno']['P'][nY]['peso']),;
                        iif(oApiJs['DATA'][nX]['Interno']['P'][nY]['manual'],'SIM','NÃO'),;
                        iif(oApiJs['DATA'][nX]['Interno']['P'][nY]['estorno'],'SIM','NÃO') })
                    next nY
                endif
                for nZ := 1 to len(oApiJs['DATA'][nX]['Bobinas'])
                    if (nPos := Ascan(aBobina, {|el| el[1]  ==  oApiJs['DATA'][nX]['Bobinas'][nZ]['TP_BOB'] }) ) > 0
                        aBobina[nPos][2] += 1
                        aBobina[nPos][3] += oApiJs['DATA'][nX]['Bobinas'][nZ]['P_BOB']
                    else
                        aadd(aBobina,{oApiJs['DATA'][nX]['Bobinas'][nZ]['TP_BOB'],1, oApiJs['DATA'][nX]['Bobinas'][nZ]['P_BOB']})
                    endif
                next nZ
            next nX
            for nX :=  1 to len(aBobina)
                aBobina[nX][2] := cValToChar(aBobina[nX][2])
                aBobina[nX][3] := cValToChar(aBobina[nX][3])
            next nX
            cTexto += linha
            cTexto +=  '<h2>'
            cTexto += 'Pallets:  ' 
            cTexto +=  '<b>'
            cTexto +=  cValToChar(nPalCarga)
            cTexto +=  '</b>'
            cTexto +=  '</h2>'
            cTexto += linha
            cTexto +=  '<h2>'
            cTexto += 'Desvio:  ' 
            cTexto +=  '<b>'
            cTexto +=  cValToChar(oApiJs['PB_NOTA'] - (oApiJs['PB_BOB'] + oApiJs['PB_EXP']))
            cTexto +=  '</b>'
            cTexto +=  '</h2>'

           


            oModal  := FWDialogModal():New()       
            oModal:SetEscClose(.T.)
            oModal:setTitle("Conferencia Carga ")
            oModal:setSubTitle(Alltrim(cCarga))
            oModal:setSize(240, 400)
            oModal:createDialog()
            oModal:addCloseButton(nil, "Fechar")
            oContainer := TPanel():New( ,,, oModal:getPanelMain() )
            oContainer:Align := CONTROL_ALIGN_ALLCLIENT
            TSay():New(1,1,{|| cTexto },oContainer,,,,,,.T.,,,190,80,,,,,,.T.)
            

            oListBobina := TCBrowse():New(1,200,190,60,,,,oContainer,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    
            oListBobina:AddColumn(TCColumn():New("Bobina"         , {|| aBobina[oListBobina:nAt,01]},"@!",,,"CENTER", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListBobina:AddColumn(TCColumn():New("Quantidade"     , {|| aBobina[oListBobina:nAt,02]},"@!",,,"RIGHT", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListBobina:AddColumn(TCColumn():New("Peso"           , {|| aBobina[oListBobina:nAt,03]},"@!",,,"RIGHT", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListBobina:SetArray(aBobina)

            oListNota := TCBrowse():New(85,05,190,90,,,,oContainer,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    
            oListNota:AddColumn(TCColumn():New("Nota Fiscal"    , {|| aNota[oListNota:nAt,01]},"@!",,,"CENTER", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListNota:AddColumn(TCColumn():New("Cliente"        , {|| aNota[oListNota:nAt,02]},"@!",,,"LEFT", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListNota:AddColumn(TCColumn():New("Volumes"        , {|| aNota[oListNota:nAt,03]},"@!",,,"RIGHT", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListNota:AddColumn(TCColumn():New("Peso Bruto"     , {|| aNota[oListNota:nAt,04]},"@!",,,"RIGHT", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListNota:AddColumn(TCColumn():New("Peso Liquido"   , {|| aNota[oListNota:nAt,05]},"@!",,,"RIGHT", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListNota:AddColumn(TCColumn():New("OS"             , {|| aNota[oListNota:nAt,06]},"@!",,,"RIGHT", 030,.F.,.F.,,{|| .F. },,.F., ) )
            oListNota:SetArray(aNota)

            oListPesagem := TCBrowse():New(85,200,190,90,,,,oContainer,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    
            oListPesagem:AddColumn(TCColumn():New("OS"          , {|| aPesagem[oListPesagem:nAt,01]},"@!",,,"CENTER", 020,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Operador"    , {|| aPesagem[oListPesagem:nAt,03]},"@!",,,"RIGHT", 020,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Data"        , {|| aPesagem[oListPesagem:nAt,05]},"@!",,,"RIGHT", 020,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Paletizar"   , {|| aPesagem[oListPesagem:nAt,04]},"@!",,,"RIGHT", 03,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Tara"        , {|| aPesagem[oListPesagem:nAt,02]},"@!",,,"RIGHT", 020,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Peso Bruto"  , {|| aPesagem[oListPesagem:nAt,06]},"@!",,,"RIGHT", 020,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Peso"        , {|| aPesagem[oListPesagem:nAt,07]},"@!",,,"RIGHT", 020,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Manual"      , {|| aPesagem[oListPesagem:nAt,08]},"@!",,,"RIGHT", 03,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:AddColumn(TCColumn():New("Estorno"     , {|| aPesagem[oListPesagem:nAt,09]},"@!",,,"RIGHT", 03,.F.,.F.,,{|| .F. },,.F., ) )
            oListPesagem:SetArray(aPesagem)

            oModal:Activate()
         
        endif
    endif
    FreeObj(oRest)
    FreeObj(oApiJs)
    FreeObj(oModal)
    FreeObj(oListNota)
return nil



static function zprintOsCar()
    local cFileName     := "CBCOrdSep_"+ 'Lote' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')
    local nX            := 0
    local oCtrl         := nil 
    local oSql          := nil
    Local oStatic       := IfcXFun():newIfcXFun()
    private oPrn        := nil
    private lValorFat	:= .F.
    private lImpCb		:= .F.
    private nLin 		:= 0
    private oFont10N	:= TFont():New( "Arial",,10,,.T.,,,,.T.,.F.)
	private oFont11N	:= TFont():New( "Arial",,11,,.T.,,,,.T.,.F.)
	private oFont12 	:= TFont():New( "Arial",,12,,.T.,,,,   ,.F.)
	private oFont12N	:= TFont():New( "Arial",,12,,.T.,,,,.T.,.F.)
	private oFont14N	:= TFont():New( "Arial",,14,,.T.,,,,.T.,.F.)
	private oFont16N	:= TFont():New( "Arial",,16,,.T.,,,,.T.,.F.)
	private oFont18N	:= TFont():New( "Arial",,18,,.T.,,,,.T.,.F.)	
	private Cabec1      := ""
	private Cabec2     	:= ""
    default aOS         := {}
    if empty(cCarga) .Or. Len(cCarga) != TamSx3('ZZ9_ORDCAR')[1]
        MsgAlert('Carga Inválida!', 'Validação de Carga')
    else
        oSql := LibSqlObj():newLibSqlObj()        
        oSql:newAlias(qryVldCarga())
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
            aAdd(aOS, AllTrim(oSql:getValue("OS")))
            oSql:skip()
            endDo
        endif
        oSql:Close()
        FreeObj(oSql)
        if !empty(aOS)
            oPrn := FWMsPrinter():New(cFileName, IMP_PDF, .T., "\OrdSep\", .T.,,,, .T.)
            oPrn:SetLandscape()// Formato pagina Paisagem
            oPrn:SetPaperSize(9)//Papel A4
            oPrn:SetMargin(((05 / 25.4) * 300),((05 / 25.4) * 300),((05 / 25.4) * 300),((05 / 25.4) * 300))
            oPrn:SetViewPDF(.T.)
            for nX := 1 to len(aOS)
                oCtrl := cbcCtrlOS():newcbcCtrlOS()
                MV_PAR01 := Substr(aOS[nX],1,6)
                MV_PAR10 := Substr(aOS[nX],7,2)
                oCtrl:define(aOS[nX])
                if oCtrl:isJoined()
                    oStatic:sP(1):callStatic('cbcPrtOS', 'printJoined', aOS[nX])
                else
                    oStatic:sP(1):callStatic('cbcPrtOS', 'printLegacy', aOS[nX])
                endif
                FreeObj(oCtrl)
            next nX
            oPrn:EndPage()
            oPrn:Preview()
            cCarga := Space(TamSx3('ZZ9_ORDCAR')[1])
            FreeObj(oPrn)
        endif
    endif
return nil


static function valida()
    local lOk       := .F.
	local oSql 		:= LibSqlObj():newLibSqlObj()

    oSql:newTable("ZZ9", "R_E_C_N_O_ REC", "ZZ9_ORDCAR = '" + cCarga + "'")

	if !(lOk := oSql:hasRecords())
        MsgAlert('Carga não localizada!', 'Não Localizada')
		reset()
	endif

    FreeObj(oSql)
return(lOk)

static function reset()
	cCarga := Space(TamSX3("ZZ9_ORDCAR")[1])
	oGet:CtrlRefresh()
return(nil)

static function processa()
    local oSql  := nil
    local oProc := nil
    local aList := {}
    local cMsg  := ''
    local nX    := 0

    if empty(cCarga)
        MsgAlert('Carga não Informada!','Sem Carga')
    else
        oSql := LibSqlObj():newLibSqlObj()        
        oSql:newAlias(qryVldCarga())
        if oSql:hasRecords()
            oSql:goTop()
            oProc := cbcProxyOs():newcbcProxyOs()
            while oSql:notIsEof()
                if !(oProc:vldOsWms(AllTrim(oSql:getValue("OS")), .T., .T.))
                    aAdd(aList, AllTrim(oSql:getValue("OS")))
                endif
                oSql:skip()
            endDo
            FreeObj(oProc)
        endif
        oSql:Close()
        FreeObj(oSql)
        if empty(aList)
            cMsg := 'Carga Completa!'
            MsgInfo(cMsg,'Carga OK')
            reset()
        else
            cMsg := 'Carga incompleta, verificar as OS:' + Chr(13) + Chr(10)
            for nX := 1 to len(aList)
                cMsg += aList[nX] + Chr(13) + Chr(10)  
            next nX
            MsgInfo(cMsg,'Carga Incompleta')
            reset()
        endif
    endif
return(nil)

static function qryVldCarga()
    local cQry := ''
    cQry += " SELECT ZZ9.ZZ9_ORDSEP AS [OS] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '" + AllTrim(cCarga) + "' "
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
return(cQry)

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
