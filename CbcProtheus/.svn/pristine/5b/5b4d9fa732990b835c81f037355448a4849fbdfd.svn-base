#include 'Totvs.ch'
#include 'FWMVCDef.ch'

user function cbcSucPesa()
    private lKeep := .T.

    while lKeep
        FWMsgRun(, { || viewSMC() }, 	"Pesagem de Sucata", "Iniciando...")
    endDo
return(nil)

static function viewSMC()
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oDlg        := nil
    private oPnl        := nil
    private oFont	    := TFont():New("Arial",,15,,.F.)
    private oGetCracha  := nil
    private oGetNome    := nil
    private oCmbRecurso := nil
    private oCmbProd    := nil
    private oSayCracha  := nil
    private oSayNome    := nil
    private oSayRecurso := nil
    private oSayPesoBrut:= nil
    private oSayPesoTar := nil
    private oSayPesoLiq := nil
    private oSayProd    := nil
    private oSayRecOri  := nil
    private oBtnConfirm := nil
    private oBtnFechar  := nil
    private oBtnLimpar  := nil
    private oTimer      := nil
    private oGrpBal     := nil
    //private oRadio      := nil
    private oGrpOrig    := nil
    private oSayID      := nil
    private oSayOperador:= nil
    private oSayPesoOri := nil
    private oSayEtiq    := nil
    private oGetEtiq    := nil
    private oBtnGerar   := nil
    private oBtnGuardar := nil
    private oBtnRetirar := nil
    private nLarg       := (aCoors[4] * 0.5)
    private nAlt        := (((aCoors[3] * 0.48)/2) - 40)
    private cCracha     := Space(8)
    private cNome       := Space(TamSX3("RA_NOME")[1])
    private cProd       := Space(TamSX3("B1_COD")[1] + TamSX3("B1_DESC")[1] + 1)
    private cRecurso    := Space(20)
    private cOper       := Space(9) + Space(TamSX3("RA_NOME")[1])
    private cIDOri      := Space(9)
    private cEtiq       := Space(1000)
    private cRecOri     := Space(20)
    private aOperador   := U_srvSucPCF('U')
    private aRecursos   := U_srvSucPCF('R')
    private aProds      := U_srvSucPCF('P')
    private aPesos      := {}
    //private aOptions    := {}
    private nEtapa      := 1
    private nBrut       := 0.00
    private nTar        := 0.00
    private nLiq        := 0.00
    private nBrutOri    := 0.00
    private nLiqOri     := 0.00
    private nTarOri     := 0.00
    private bConfirm    := {|| FWMsgRun(, { || confirma() }, "Pesagem de Sucata", "Registrando...")}
    private bEncerra    := {|| FWMsgRun(, { || encerra(.F.) }, "Pesagem de Sucata", "Encerrando...")}
    private bLimpa      := {|| FWMsgRun(, { || encerra(.T.) }, "Pesagem de Sucata", "Limpando...")}
    private bTimerPes   := {|| atuPeso()}

    //Componentes Visuais
    DEFINE MSDIALOG oDlg TITLE 'Pesagem de Sucata' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oPnl := TPanel():New( ,,, oDlg)
    oPnl:Align := CONTROL_ALIGN_ALLCLIENT

    oDlg:lMaximized := .T.
    oTimer := TTimer():New(5000, bTimerPes, oDlg )
    oTimer:Activate()
    defOpcao()
    mntComponents()
    TrocaOpc(1)
    atuPeso()
    reTela()
    Activate MsDialog oDlg Center
    
    FreeObj(oSayEtiq)
    FreeObj(oGetEtiq)
    FreeObj(oSayRecOri)
    FreeObj(oGrpBal)
    FreeObj(oGrpOrig)
    FreeObj(oGrpOrig)
    FreeObj(oSayID)
    FreeObj(oSayOperador)
    FreeObj(oSayPesoOri)
    FreeObj(oGetCracha)
    FreeObj(oGetNome)
    FreeObj(oCmbRecurso)
    FreeObj(oCmbProd)
    FreeObj(oSayCracha)
    FreeObj(oSayNome)
    FreeObj(oSayProd)
    FreeObj(oSayRecurso)
    FreeObj(oSayPesoBru)
    FreeObj(oSayPesoTar)
    FreeObj(oSayPesoLiq)
    FreeObj(oBtnConfirm)
    FreeObj(oBtnFechar)
    FreeObj(oBtnLimpar)
    //FreeObj(oRadio)
    FreeObj(oBtnGerar)
    FreeObj(oBtnGuardar)
    FreeObj(oBtnRetirar)
    FreeObj(oTimer)
    FreeObj(oFont)
    FreeObj(oPnl)
    FreeObj(oDlg)
return(nil)

static function defOpcao()
    /*
    aOptions := {'Gerar', 'Guardar', 'Retirar'}
    oRadio := TRadMenu():New (02, 02, aOptions,,oPnl,,,,,,,,((nLarg-10)/2),50,,,,.T.,,.F.)
    oRadio:bSetGet := {|u| iif(PCount()==0,nEtapa,nEtapa:=u)}
    oRadio:lHoriz := .T.
    oRadio:bChange := {|| FWMsgRun(, { || TrocaOpc() }, "Pesagem de Sucata", "Alterando Origem...") }
    applyCss(@oRadio)
    */
    oBtnGerar := TButton():New(02,02, 'Gerar',oPnl , {|| TrocaOpc(1)},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnGuardar := TButton():New(02,82, 'Guardar',oPnl , {|| TrocaOpc(2)},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnRetirar := TButton():New(02,162, 'Retirar',oPnl , {|| TrocaOpc(3)},80,25,,,.F.,.T.,.F.,,.F.,,,.F. )
return(nil)

static function TrocaOpc(nOpc)
    zeraVar()
    nEtapa := nOpc
    if nEtapa == 1
        applyCss(@oBtnGerar, 'CONFIRM')
        applyCss(@oBtnGuardar, 'FECHAR')
        applyCss(@oBtnRetirar, 'FECHAR')
        oGrpOrig:Hide()
        oSayID:Hide()
        oSayOperador:Hide()
        oSayPesoOri:Hide()
        oSayRecOri:Hide()
        oSayEtiq:Hide()
        oGetEtiq:Hide()
        oCmbRecurso:Show()
        oSayRecurso:Show()
        oCmbProd:Enable()
    elseif nEtapa == 2
        applyCss(@oBtnGerar, 'FECHAR')
        applyCss(@oBtnGuardar, 'CONFIRM')
        applyCss(@oBtnRetirar, 'FECHAR')
        oGrpOrig:Show()
        oSayID:Show()
        oSayOperador:Show()
        oSayPesoOri:Show()
        oSayRecOri:Show()
        oSayEtiq:Show()
        oGetEtiq:Show()
        oGetEtiq:Enable()
        oCmbRecurso:Hide()
        oSayRecurso:Hide()
        oCmbProd:Disable()
    else
        applyCss(@oBtnGerar, 'FECHAR')
        applyCss(@oBtnGuardar, 'FECHAR')
        applyCss(@oBtnRetirar, 'CONFIRM')
        oGrpOrig:Hide()
        oSayID:Hide()
        oSayOperador:Hide()
        oSayPesoOri:Hide()
        oSayRecOri:Hide()
        oSayEtiq:Hide()
        oGetEtiq:Hide()
        oCmbRecurso:Hide()
        oSayRecurso:Hide()
        oCmbProd:Enable()
    endif
    reTela()
return(.T.)

static function zeraVar()
    cEtiq       := Space(1000)
    aPesos      := {}
    nBrut       := 0.00
    nTar        := 0.00
    nLiq        := 0.00
    nBrutOri    := 0.00
    nLiqOri     := 0.00
    nTarOri     := 0.00
    cCracha     := Space(8)
    cNome       := Space(TamSX3("RA_NOME")[1])
    cProd       := Space(TamSX3("B1_COD")[1] + TamSX3("B1_DESC")[1] + 1)
    cOper       := Space(9) + Space(TamSX3("RA_NOME")[1])
    cIDOri         := Space(9)
    cRecurso    := Space(20)
    oCmbProd:Select(0)
    oCmbRecurso:Select(0)
return(nil)

static function mntComponents()
    oSayCracha := TSay():New(40,05,	{||'Crachá: *'}, oPnl,,oFont,,,,.T.,,, (nLarg-10)/3, 35)
    applyCss(@oSayCracha)

    oGetCracha  := TGet():New(60,05, 	{ |u| iif( PCount() == 0, cCracha, cCracha := u ) },; 
                oPnl, (nLarg-10)/3, 35,PesqPict('SRA', 'RA_BITMAP'),{|| buscaNome()},0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCracha",,,,.T.,,,,1 )
    applyCss(@oGetCracha)
    
    oSayNome := TSay():New(40,((nLarg-10)/3) + 05,	{||'Nome: *'}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/3)*2, 35)
    applyCss(@oSayNome)
    
    oGetNome    := TGet():New(60,((nLarg-10)/3) + 05, 	{ |u| iif( PCount() == 0, cNome, cNome := u ) },; 
                oPnl, ((nLarg-10)/3)*2, 35,PesqPict('SRA', 'RA_NOME'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cNome",,,,.T.,,,,1 )
    applyCss(@oGetNome)
    
    oSayRecurso  := TSay():New(100,05,	{||"Máquina/Recurso: *"}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/2), 35)
    applyCss(@oSayRecurso)

    oCmbRecurso := TComboBox():New(120,05,{|u|if(PCount()>0, cRecurso:=u, cRecurso)},;
                aRecursos,((nLarg-10)),50,oPnl,,{|| },,,,.T.,,,,,,,,,'cRecurso')
    oCmbRecurso:SetHeight(73)
    applyCss(@oCmbRecurso)

    oSayEtiq  := TSay():New(100,05,	{||"Etiqueta: *"}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/2), 35)
    applyCss(@oSayEtiq)

    oGetEtiq    := TGet():New(120,05, 	{ |u| iif( PCount() == 0, cEtiq, cEtiq := u ) },; 
                oPnl, ((nLarg-10)), 35,PesqPict('SRA', 'RA_NOME'),{|| carregaEtiq()},0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cEtiq",,,,.T.,,,,1 )
    applyCss(@oGetEtiq)

    oSayProd  := TSay():New(160,05,	{||"Tipo de Sucata: *"}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/2), 35)
    applyCss(@oSayProd)
    oCmbProd := TComboBox():New(180,05,{|u|if(PCount()>0, cProd:=u, cProd)},;
                aProds,((nLarg-10)),50,oPnl,,{|| },,,,.T.,,,,,,,,,'cProd')
    oCmbProd:SetHeight(73)
    applyCss(@oCmbProd)
    
    /*
    oSayDtProg  := TSay():New(150,(((nLarg-10)/3)*2) + 35,	{||"Data:"}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/3) - 20, 35)
    applyCss(@oSayDtProg)
    
    oGetData    := TGet():New(170,(((nLarg-10)/3)*2) + 35, 	{ |u| iif( PCount() == 0, dDataPesa, dDataPesa := u ) },; 
                oPnl, ((nLarg-10)/3) - 20, 35,PesqPict('SD3', 'D3_EMISSAO'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dDataPesa",,,,.T.,,,,1 )
    applyCss(@oGetData)
    */
    oGrpBal := TGroup():New(225, 05, /*nHeight*/ 325, /*nWidth*/ ((nLarg - 03) / 2),'Balança',oPnl,,,.T.)
    applyCss(@oGrpBal)
    oSayPesoBru   := TSay():New(245,07,	{||'Peso Bruto: '+ cValToChar(nBrut)}, oGrpBal,,oFont,,,,.T.,,, (nLarg-10)/2, 35)
    applyCss(@oSayPesoBru)
    oSayPesoLiq   := TSay():New(275,07,	{||'Peso Liqui: '+ cValToChar(nLiq)}, oGrpBal,,oFont,,,,.T.,,, (nLarg-10)/2, 35)
    applyCss(@oSayPesoLiq)
    oSayPesoTar   := TSay():New(305,07,	{||'Peso Tara: '+ cValToChar(nTar)}, oGrpBal,,oFont,,,,.T.,,, (nLarg-10)/2, 35)
    applyCss(@oSayPesoTar)


    oGrpOrig := TGroup():New(225, ((nLarg - 03) / 2) + 03, /*nHeight*/ 325, /*nWidth*/ (nLarg - 03),'Origem',oPnl,,,.T.)
    applyCss(@oGrpOrig)
    oSayID   := TSay():New(245,((nLarg - 03) / 2) + 05,	{||'ID: '+ cValToChar(cIDOri)}, oGrpOrig,,oFont,,,,.T.,,, (nLarg-10)/2, 35)
    applyCss(@oSayID,'PEQ')
    oSayRecOri   := TSay():New(260,((nLarg - 03) / 2) + 05,	{||'Recurso: '+ cValToChar(cRecOri)}, oGrpOrig,,oFont,,,,.T.,,, (nLarg-10)/2, 35)
    applyCss(@oSayRecOri,'PEQ')
    oSayOperador   := TSay():New(275,((nLarg - 03) / 2) + 05,	{||'Operador: '+ cValToChar(cOper)}, oGrpOrig,,oFont,,,,.T.,,, (nLarg-10)/2, 35)
    applyCss(@oSayOperador,'PEQ')
    oSayPesoOri   := TSay():New(290,((nLarg - 03) / 2) + 05,	{||'Pesos -> B:'+ cValToChar(nBrutOri) + ' L:'+ cValToChar(nLiqOri) + ' T:'+ cValToChar(nTarOri)}, oGrpOrig,,oFont,,,,.T.,,, (nLarg-10)/2, 35)
    applyCss(@oSayPesoOri,'PEQ')

    oBtnConfirm := TButton():New(345,nLarg-80, 'Confirma',oPnl , bConfirm,80,50,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnConfirm, 'CONFIRM')

    oBtnFechar  := TButton():New(345,05, 'Fechar',oPnl , bEncerra,80,50,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnFechar, 'FECHAR')

    oBtnLimpar  := TButton():New(345,(nLarg / 3), 'Limpar',oPnl , bLimpa,80,50,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnLimpar, 'FECHAR')

    oGetNome:Disable()
    oBtnConfirm:Disable()
return(nil)

static function reTela()
    oSayEtiq:Refresh()
    oGetEtiq:Refresh()
    oGrpBal:Refresh()
    oGrpOrig:Refresh()
    oGrpOrig:Refresh()
    oSayID:Refresh()
    oSayOperador:Refresh()
    oSayPesoOri:Refresh()
    oGetCracha:Refresh()
    oGetNome:Refresh()
    oCmbRecurso:Refresh()
    oCmbProd:Refresh()
    oSayCracha:Refresh()
    oSayNome:Refresh()
    oSayProd:Refresh()
    oSayRecurso:Refresh()
    oSayPesoBru:Refresh()
    oSayPesoTar:Refresh()
    oSayPesoLiq:Refresh()
    oBtnConfirm:Refresh()
    oBtnFechar:Refresh()
    oBtnLimpar:Refresh()
    oBtnGerar:Refresh()
    oBtnGuardar:Refresh()
    oBtnRetirar:Refresh()
    oSayRecOri:Refresh()
    oPnl:Refresh()
return(nil)

static function encerra(lMyKeep)
    lKeep := lMyKeep
    oDlg:End()
return(nil)

static function confirma()
    local lRet      := .T.
    local cMsgErr   := "Erro ao registrar Pesagem de Sucata!"
    local cGrvID    := GetSXENum("ZZ8","ZZ8_IDMOV")
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @cMsgErr, @lRet)})

    FWMsgRun(, { || validaCampos(@lRet) }, 	"Pesagem de Sucata", "Validando...")
    BEGIN SEQUENCE
        if lRet
            BEGIN Transaction
                FWMsgRun(, { || lRet := gravaPesagem(cGrvID, @cMsgErr) }, "Pesagem de Sucata", "Gravando Pesagem...")
                if lRet
                    if nEtapa == 1
                        FWMsgRun(, { || lRet := imprimeEtq(cGrvID, @cMsgErr) }, "Pesagem de Sucata", "Gerando Etiqueta...")
                    endif
                endif
                if !lRet
                    DisarmTransaction()
                endif
            END Transaction
        endif
    RECOVER
    END SEQUENCE
    ErrorBlock(bErro)
    if lRet
        ConfirmSX8()
        MsgInfo('Pesagem de Sucata registrada!','Sucesso')
        encerra(.T.)
    else
        RollBackSx8()
        Alert(cMsgErr)
    endif
return(lRet)

static function imprimeEtq(cGrvID, cMsgErr)
    local cEndPrt   := AllTrim(GetNewPar("ZZ_ENDSUCP", "http://192.168.1.17:3001"))
    local oRest		:= FWRest():New(cEndPrt)
    local oRet      := JsonObject():new()
    local oBody     := JsonObject():new()
    local aHeader   := {}
    local lRet      := .T.
    default cMsgErr := ""

    aadd(aHeader, 'Content-Type: application/json')

    oBody["ID"]         := cGrvID
    oBody["Cracha"]     := cCracha
    oBody["Nome"]       := cNome
    oBody["Tara"]       := cValToChar(nTar)
    oBody["Liquido"]    := cValToChar(nLiq)
    oBody["Bruto"]      := cValToChar(nBrut)
    oBody["Produto"]    := cProd
    oBody["Recurso"]    := cRecurso
    oBody["DataPesagem"]       := DtoC(dDataBase)
    oRest:SetPath('/imprimir')
    oRest:SetPostParams(oBody:toJson())
    if !(oRest:Post(aHeader))
        cMsgErr := 'Erro ao gerar impressão Pesagem de Sucata!'
        lRet := .F.
    else
        lRet := modalEtiq(cGrvID, @cMsgErr)
    endif
    FreeObj(oBody)
    FreeObj(oRet)
    FreeObj(oRest)
return(lRet)

static function modalEtiq(cGrvID, cMsgErr)
    local oModal 		:= nil
	local oGetModal	    := nil
    local oPnlModal 	:= nil
	local bValid 		:= { || ValidaEtq(@cCapEtq, cGrvID, @lRet, @oGetModal, @oModal) }
    local cCapEtq       := Space(1000)
    local lRet          := .F.
    default cMsgErr     := ""

	oModal := FWDialogModal():New() 
	oModal:setSize(150,300)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Capture a Etiqueta para validação')
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oModal:addOkButton(bValid, "Confirma", {||.T.} )
	oPnlModal := TPanel():New( ,,, oModal:getPanelMain() ) 
	oPnlModal:SetCss("")
	oPnlModal:Align := CONTROL_ALIGN_ALLCLIENT

    oGetModal := TGet():New(40,05, { | u | If( PCount() == 0, cCapEtq,cCapEtq:= u ) },oPnlModal,290,030,"@!", {||.T.},0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCapEtq,,,, )
    applyCss(@oGetModal)
    applyCss(@oModal:oSayTitle, 'MODAL')
   	applyCss(@oModal:oTop)
    
    oModal:Activate()

    if !lRet
        cMsgErr := "Erro na validação da Etiqueta!"
    endif
    FreeObj(oGetModal)
    FreeObj(oPnlModal)
    FreeObj(oModal)
return(lRet)

static function ValidaEtq(cCapEtq, cGrvID, lRet, oGetModal, oModal)
    local oJson  := JsonObject():new()
    
    oJson:FromJson(cCapEtq)
    if (lRet := !(empty(oJson:GetNames())))
        if (ValType(oJson:GetJsonObject('ID')) <> 'U' .and.;
            ValType(oJson:GetJsonObject('CRACHA')) <> 'U' .and. ValType(oJson:GetJsonObject('NOME')) <> 'U' .and.;
            ValType(oJson:GetJsonObject('RECURSO')) <> 'U' .and. ValType(oJson:GetJsonObject('PRODUTO')) <> 'U' .and.;
            ValType(oJson:GetJsonObject('TARA')) <> 'U' .and. ValType(oJson:GetJsonObject('LIQUIDO')) <> 'U' .and. ValType(oJson:GetJsonObject('BRUTO')) <> 'U' .and.;
            ValType(oJson:GetJsonObject('DATAPESAGEM')) <> 'U')
            /*OUTRA PARTE VALIDAÇÃO*/
            if (AllTrim(oJson['ID']) == Upper(AllTrim(cGrvID)) .and.;
                AllTrim(oJson['RECURSO']) == Upper(AllTrim(cRecurso)) .and.;
                AllTrim(oJson['CRACHA']) == Upper(AllTrim(cCracha)) .and.;
                AllTrim(oJson['NOME']) == Upper(AllTrim(cNome)) .and.;
                Val(cValToChar(oJson['BRUTO'])) == nBrut .and.;
                Val(cValToChar(oJson['LIQUIDO'])) == nLiq .and.;
                Val(cValToChar(oJson['TARA'])) == nTar .and.;
                SubStr(AllTrim(oJson['PRODUTO']),1,10) == Upper(SubStr(AllTrim(cProd),1,10)) .and.;
                oJson['DATAPESAGEM'] == DtoC(dDataBase))
                lRet := .T.
            else
                lRet := .F.
            endif
        else
            lRet := .F.
        endif
    endif
    FreeObj(oJson)
    if lRet
        oModal:DeActivate()
    endif    
return(lRet)

static function buscaNome()
	local nPosi := 0
    oBtnConfirm:Disable()
    if !empty(cCracha)
        nPosi := aScan(aOperador, {|x| AllTrim(x[1]) == AllTrim(cCracha)})
        if nPosi > 0
            cNome := AllTrim(aOperador[nPosi, 2])
            oBtnConfirm:Enable()
        else
            cCracha := Space(8)
            cNome := Space(TamSX3("RA_NOME")[1])            
            Alert('Operador não localizado!')
        endif
    else
        cNome := Space(TamSX3("RA_NOME")[1])
    endif
    oGetNome:Refresh()
    oGetCracha:Refresh()
return(.T.)

static function validaCampos(lRet)
    default lRet := .T.
    lRet := .T.
    
    if empty(cCracha) .or. empty(cNome) .or. (empty(cRecurso) .and. nEtapa == 1) .or. empty(nBrut) .and. empty(nLiq) .and. empty(cProd)
        lRet := .F.
        MsgAlert('Campo(s) Obrigatório(s) não preenchido(s)!','Campo(s) Não Preechido(s)')
    endif
    if lRet .and. nEtapa == 2
        if (nBrut <> nBrutOri) .or. (nLiq <> nLiqOri) .or. (nTar <> nTarOri)
            lRet := .F.
            MsgAlert('Peso guardado divergente do peso de geração!','Peso(s) Divergente(s)')
        endif
    endif
    if lRet .and. nEtapa == 3
        if (u_zArmSucSaldo(SubStr(AllTrim(cProd),1,10)) < nLiq)
            lRet := .F.
            MsgAlert('Retirada não pode ser efetuada!','Sem Saldo')
        endif
    endif
return(lRet)

static function atuPeso()
	local aBalPesos := pegaBalanca()
    if (nBrut <> aBalPesos[1]) .or. (nLiq <> aBalPesos[2]) .or. (nTar <> aBalPesos[3])
        nBrut := aBalPesos[1]
        nLiq  := aBalPesos[2]
        nTar  := aBalPesos[3]
        aPesos := AClone(aBalPesos)
        oSayPesoBru:Refresh()
        oSayPesoTar:Refresh()
        oSayPesoLiq:Refresh()
    endif
return(.T.)

static function carregaEtiq()
    local oJson := JsonObject():new()
    local nPosi := 0
    if !empty(cEtiq)
        oJson:FromJson(AllTrim(cEtiq))
        if ValType(oJson:GetJsonObject('ID')) <> 'U'
            cIDOri := AllTrim(oJson['ID'])
        endif
        if ValType(oJson:GetJsonObject('CRACHA')) <> 'U' .and. ValType(oJson:GetJsonObject('NOME')) <> 'U'
            cOper := AllTrim(oJson['CRACHA']) + '-' + AllTrim(oJson['NOME'])
        endif
        if ValType(oJson:GetJsonObject('TARA')) <> 'U' .and. ValType(oJson:GetJsonObject('LIQUIDO')) <> 'U' .and. ValType(oJson:GetJsonObject('BRUTO')) <> 'U'
            nBrutOri    := Val(cValToChar(oJson['BRUTO']))
            nLiqOri     := Val(cValToChar(oJson['LIQUIDO']))
            nTarOri     := Val(cValToChar(oJson['TARA']))
        endif
        if ValType(oJson:GetJsonObject('PRODUTO')) <> 'U'
            nPosi := aScan(oCmbProd:aItems, {|x| SubStr(AllTrim(x),1,10) == SubStr(AllTrim(oJson['PRODUTO']),1,10)})
            if nPosi > 0
                cProd := AllTrim(oJson['PRODUTO'])
                oCmbProd:Select(nPosi)
            endif
        endif
        if ValType(oJson:GetJsonObject('RECURSO')) <> 'U'
            cRecOri := AllTrim(oJson['RECURSO'])
        endif
        cEtiq := "CARREGADA"
        oGetEtiq:Disable()
        reTela()
    endif
    FreeObj(oJson)
return(.T.)

static function pegaBalanca()
    local aBalPesos := {0.00,0.00,0.00}
    local cEndBal   := AllTrim(GetNewPar("ZZ_ENDSUCP", "http://192.168.1.17:3001"))
    local oRest		:= FWRest():New(cEndBal)
    local oRet      := JsonObject():new()
    local aHeader   := {}

    aadd(aHeader, 'Content-Type: application/json')
    oRest:SetPath('/peso')
    if (oRest:Get(aHeader))
        oRet:fromJSON(oRest:GetResult())
        if !empty(oRet:GetNames())
            if ValType(oRet:GetJsonObject('lider')) <> 'U'
                if ValType(oRet['lider']:GetJsonObject('pesoBruto')) <> 'U'
                    aBalPesos[1] := Val(cValToChar(oRet['lider']['pesoBruto']))
                endif
                if ValType(oRet['lider']:GetJsonObject('peso')) <> 'U'
                    aBalPesos[2] := Val(cValToChar(oRet['lider']['peso']))
                endif
                if ValType(oRet['lider']:GetJsonObject('tara')) <> 'U'
                    aBalPesos[3] := Val(cValToChar(oRet['lider']['tara']))
                endif
            endif
        endif
    endif
    FreeObj(oRet)
    FreeObj(oRest)
return(aBalPesos)

static function gravaPesagem(cGrvID, cMsgErr)
    local aArea    	:= GetArea()
    local aAreaZZ8	:= ZZ8->(getArea())
    local lRet      := .T.
    local oModel    := nil
    local aErro     := {}
    default cMsgErr := ""

    DbSelectArea('ZZ8')
    /*
    RecLock("ZZ8",.T.)
        ZZ8->ZZ8_FILIAL  := FwFilial()
        ZZ8->ZZ8_ETAPA   := cValToChar(nEtapa)
        ZZ8->ZZ8_PESO    := nLiq
        ZZ8->ZZ8_DATA    := dDataBase
        ZZ8->ZZ8_OPER    := AllTrim(cCracha)
        ZZ8->ZZ8_PROD    := AllTrim(cProd)
        ZZ8->ZZ8_IDMOV   := AllTrim(cGrvID)
        if nEtapa == 1
            ZZ8->ZZ8_MAQUIN := AllTrim(cRecurso)
        endif
    ZZ8->(MsUnLock())
    */
    oModel := FWLoadModel('cbcZZ8Model')
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    oModel:LoadValue('ZZ8MASTER', 'ZZ8_FILIAL', FwFilial())
    oModel:LoadValue('ZZ8MASTER', 'ZZ8_ETAPA', cValToChar(nEtapa))
    oModel:LoadValue('ZZ8MASTER', 'ZZ8_PESO', nLiq)
    oModel:LoadValue('ZZ8MASTER', 'ZZ8_DATA', dDataBase/*DtoC(dDataBase)*/)
    oModel:LoadValue('ZZ8MASTER', 'ZZ8_OPER', AllTrim(cCracha))
    oModel:LoadValue('ZZ8MASTER', 'ZZ8_PROD', SubStr(AllTrim(cProd), 1, 10))
    oModel:LoadValue('ZZ8MASTER', 'ZZ8_IDMOV', cGrvID)
    if nEtapa == 1
        oModel:LoadValue('ZZ8MASTER', 'ZZ8_MAQUIN', AllTrim(cRecurso))
    endif
    if !(lRet := FWFormCommit(oModel))
        aErro := oModel:GetErrorMessage()
        if !empty(aErro)
            cMsgErr += aErro[2] + '-'
            cMsgErr += aErro[4] + '-'
            cMsgErr += aErro[5] + '-'
            cMsgErr += aErro[6]
        endif
    endif
    oModel:DeActivate()
    FreeObj(oModel)
    RestArea(aAreaZZ8)
    RestArea(aArea)
return(lRet)

static function applyCss(oObj, cOpc)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
	default cOpc    := ''
	if cTpObj == "TBUTTON"
        if cOpc == 'CONFIRM'
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #FFFFFF; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 25px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #022c73, stop: 1 #2055b0); /*Cor de fundo*/";
                                +"  min-width: 20px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #2055b0 stop: 1 #022c73);";
                                +"}"
        else
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #FFFFFF; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 25px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #525252, stop: 1 #626363); /*Cor de fundo*/";
                                +"  min-width: 20px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #626363 stop: 1 #525252);";
                                +"}"
        endif
	elseif cTpObj == "TSAY"
            if cOpc == 'PEQ'
                cCss +=	"QLabel { ";
                            +"  font-size: 15px; /*Tamanho da fonte*/";
                            +"  color: #00297c; /*Cor da fonte*/";
                            +"  font-weight: bold; /*Negrito*/";
                            +"  text-align: center; /*Alinhamento*/";
                            +"  vertical-align: middle; /*Alinhamento*/";
                            +"  border-radius: 6px; /*Arrerondamento da borda*/";
                            +"}"
            elseif cOpc == 'MODAL'
                cCss +=	"QLabel { ";
                            +"  font-size: 15px; /*Tamanho da fonte*/";
                            +"  color: #FFFFFF; /*Cor da fonte*/";
                            +"  font-weight: bold; /*Negrito*/";
                            +"  text-align: center; /*Alinhamento*/";
                            +"  vertical-align: middle; /*Alinhamento*/";
                            +"  border-radius: 6px; /*Arrerondamento da borda*/";
                            +"}"
            else
                cCss +=	"QLabel { ";
                            +"  font-size: 35px; /*Tamanho da fonte*/";
                            +"  color: #00297c; /*Cor da fonte*/";
                            +"  font-weight: bold; /*Negrito*/";
                            +"  text-align: center; /*Alinhamento*/";
                            +"  vertical-align: middle; /*Alinhamento*/";
                            +"  border-radius: 6px; /*Arrerondamento da borda*/";
                            +"}"
            endif
    elseif cTpObj == "TMULTIGET"
			cCss +=	"QTextEdit { ";
						+"  font-size: 35px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
    elseif cTpObj == "TGET"
			cCss +=	"QLineEdit { ";
						+"  font-size: 25px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
                        +"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
	elseif cTpObj == "TPANEL"
			cCss +=	 "QFrame {";
								+" color: #FFFFFF; /*Cor da fonte*/ ";
								+" background-color: #00297c;";	
								+" border: 2px solid #00297c; /*Cor da borda*/";	  						
		  						+" border-radius: 6px; /*Arrerondamento da borda*/ ";
		                      +" } "
    elseif cTpObj == "TGROUP"
			cCss +=	 "QGroupBox {";
								+" color: #FFFFFF; /*Cor da fonte*/ ";
								+" border: 2px solid #00297c; /*Cor da borda*/";	  						
		  						+" border-radius: 6px; /*Arrerondamento da borda*/ ";
                                +" font-size: 25px; /*Tamanho da fonte*/";
                                +" font-weight: bold; /*Negrito*/";
		                        +" } ";
                                +" QGroupBox::title  { ";
                                +"     subcontrol-origin: margin; ";
                                +"     subcontrol-position: top center; ";
                                +"     padding: 5px 8000px 5px 8000px; ";
                                +"     background-color: #00297c; ";
                                +"     color: rgb(255, 255, 255); ";
                                +" } "
    elseif cTpObj == "TCOMBOBOX"
			cCss +=	"QComboBox { ";
						+"  font-size: 25px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
                        +"  background-color: #FFFFFF;";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
                        +"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
    elseif cTpObj == "TRADMENU"
			cCss +=	"QRadioButton { ";
						+"  font-size: 35px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"}"
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)

static function HandleEr(oErr, cMsgErr, lRet)
    if InTransact()
        DisarmTransaction()
    endif
    lRet := .F.
    cMsgErr := oErr:Description
    //Alert(oErr:Description)
    BREAK
return(nil)

user function cbc01SucPesa()
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
        __cInterNet := nil,;
        u_cbcSucPesa(),;
        Final("PDS Pesa Sucata FINALIZADO")}

    //Seta Atributos
    __lInternet := .F.
    lMsFinalAuto := .F.
    oApp:lMessageBar:= .T.
    oApp:cModDesc:= 'SIGAADV'

    //Inicia a Janela
    oApp:Activate()
return(nil)
