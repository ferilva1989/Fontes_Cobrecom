#include 'protheus.ch'
#include 'totvs.ch'

user function cbcFluSMC()
    private lKeep := .T.

    while lKeep
        FWMsgRun(, { || viewSMC() }, 	"SMC - Solicitação de Manutenção Corretiva", "Iniciando...")
    endDo
return(nil)

static function viewSMC()
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oDlg        := nil
    private oPnl        := nil
    private oFont	    := TFont():New("Arial",,15,,.F.)
    private oGetCracha  := nil
    private oGetNome    := nil
    private oGetSetor   := nil
    private oGetMaquina := nil
    private oCmbSituac  := nil
    private oCmbPrior   := nil
    private oGetData    := nil
    private oTxtFalha   := nil
    private oSaySituac  := nil
    private oSayPrior   := nil
    private oSayFalha   := nil
    private oSayCracha  := nil
    private oSayNome    := nil
    private oSaySetor   := nil
    private oSayMaquina := nil
    private oSayDtProg  := nil
    private oBtnConfirm := nil
    private oBtnFechar  := nil
    private oBtnLimpar  := nil
    private nLarg       := (aCoors[4] * 0.5)
    private nAlt        := (((aCoors[3] * 0.48)/2) - 40)
    private cCracha     := Space(TamSX3("RA_BITMAP")[1])
    private cNome       := Space(TamSX3("RA_NOME")[1])
    private dDataSol    := dDataBase
    private cFalha      := ""
    private cSetor      := Space(20)
    private cMaquina    := Space(20)
    private aSituac     := {'SIM','NÃO'}
    private aPrior      := {'A - EMERGENTE(IMEDIATO)','B - URGENTE(24 HORAS)','C - PROGRAMADO'}
    private cSituac     := Space(50)
    private cPrior      := Space(50)
    private bConfirm    := {|| FWMsgRun(, { || confirma() }, "SMC - Solicitação de Manutenção Corretiva", "Registrando...")}
    private bEncerra    := {|| FWMsgRun(, { || encerra(.F.) }, "SMC - Solicitação de Manutenção Corretiva", "Encerrando...")}
    private bLimpa      := {|| FWMsgRun(, { || encerra(.T.) }, "SMC - Solicitação de Manutenção Corretiva", "Limpando...")}

    // Componentes Visuais
    DEFINE MSDIALOG oDlg TITLE 'SMC - Solicitação de Manutenção Corretiva' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oPnl := TPanel():New( ,,, oDlg)
    oPnl:Align := CONTROL_ALIGN_ALLCLIENT

    oDlg:lMaximized := .T.
    mntComponents()
    Activate MsDialog oDlg Center
    
    FreeObj(oBtnLimpar)
    FreeObj(oBtnFechar)
    FreeObj(oBtnConfirm)
    FreeObj(oSayDtProg)
    FreeObj(oSayMaquina)
    FreeObj(oSaySetor)
    FreeObj(oSayNome)
    FreeObj(oSayCracha)
    FreeObj(oSayFalha)
    FreeObj(oSayPrior)
    FreeObj(oSaySituac)
    FreeObj(oGetCracha)
    FreeObj(oGetNome)
    FreeObj(oGetSetor)
    FreeObj(oGetMaquina)
    FreeObj(oCmbSituac)
    FreeObj(oCmbPrior)
    FreeObj(oGetData)
    FreeObj(oTxtFalha)
    FreeObj(oFont)
    FreeObj(oPnl)
    FreeObj(oDlg)
return(nil)

static function mntComponents()
    oSayCracha := TSay():New(05,05,	{||'Crachá: *'}, oPnl,,oFont,,,,.T.,,, (nLarg-10)/3, 35)
    applyCss(@oSayCracha)

    oGetCracha  := TGet():New(25,05, 	{ |u| iif( PCount() == 0, cCracha, cCracha := u ) },; 
                oPnl, (nLarg-10)/3, 35,PesqPict('SRA', 'RA_BITMAP'),{|| buscaNome()},0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCracha",,,,.T.,,,,1 )
    applyCss(@oGetCracha)
    
    oSayNome := TSay():New(05,((nLarg-10)/3) + 05,	{||'Nome: *'}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/3)*2, 35)
    applyCss(@oSayNome)
    
    oGetNome    := TGet():New(25,((nLarg-10)/3) + 05, 	{ |u| iif( PCount() == 0, cNome, cNome := u ) },; 
                oPnl, ((nLarg-10)/3)*2, 35,PesqPict('SRA', 'RA_NOME'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNome",,,,.T.,,,,1 )
    applyCss(@oGetNome)
    
    oSaySetor   := TSay():New(75,05,	{||'Setor: *'}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/2), 35)
    applyCss(@oSaySetor)

    oGetSetor   := TGet():New(95,05, 	{ |u| iif( PCount() == 0, cSetor, cSetor := u ) },; 
                oPnl, ((nLarg-10)/2), 35,"@!",,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cSetor",,,,.T.,,,,1 )
    applyCss(@oGetSetor)

    oSayMaquina  := TSay():New(75,((nLarg-10)/2) + 05,	{||"Máquina/Equipamento: *"}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/2), 35)
    applyCss(@oSayMaquina)

    oGetMaquina := TGet():New(95,((nLarg-10)/2) + 05, 	{ |u| iif( PCount() == 0, cMaquina, cMaquina := u ) },; 
                oPnl, ((nLarg-10)/2), 35,"@!",,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cMaquina",,,,.T.,,,,1 )
    applyCss(@oGetMaquina)

    oSaySituac := TSay():New(150,05,	{||'Equip.Parado?:*'}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/3) - 20, 35)
    applyCss(@oSaySituac)
    
    oCmbSituac := TComboBox():New(170,05,{|u|if(PCount()>0, cSituac:=u, cSituac)},;
                aSituac,((nLarg-10)/3)-20,50,oPnl,,{|| },,,,.T.,,,,,,,,,'cSituac')
    oCmbSituac:SetHeight(73)
    applyCss(@oCmbSituac)

    oSayPrior  := TSay():New(150,(((nLarg-10)/3)-20) + 05,	{||'Prioridade: *'}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/3)+45, 35)
    applyCss(@oSayPrior)
    
    oCmbPrior  := TComboBox():New(170,(((nLarg-10)/3)-20) + 05,{|u|if(PCount()>0, cPrior:=u, cPrior)},;
                aPrior,((nLarg-10)/3)+45,50,oPnl,,{|| checkPrior()},,,,.T.,,,,,,,,,'cPrior')
    oCmbPrior:SetHeight(73)
    applyCss(@oCmbPrior)
    
    oSayDtProg  := TSay():New(150,(((nLarg-10)/3)*2) + 35,	{||"Data:"}, oPnl,,oFont,,,,.T.,,, ((nLarg-10)/3) - 20, 35)
    applyCss(@oSayDtProg)
    
    oGetData    := TGet():New(170,(((nLarg-10)/3)*2) + 35, 	{ |u| iif( PCount() == 0, dDataSol, dDataSol := u ) },; 
                oPnl, ((nLarg-10)/3) - 20, 35,PesqPict('SD3', 'D3_EMISSAO'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dDataSol",,,,.T.,,,,1 )
    applyCss(@oGetData)
    
    oSayFalha   := TSay():New(225,05,	{||'Descrição da Falha: *'}, oPnl,,oFont,,,,.T.,,, nLarg-10, 35)
    applyCss(@oSayFalha)
    
    oTxtFalha   := tMultiget():new( 245, 05, {| u | if( pCount() > 0, cFalha := u, cFalha ) }, ;
                oPnl, nLarg-10, 70, , , , , , .T. )
    applyCss(@oTxtFalha)
    
    oBtnConfirm := TButton():New(320,nLarg-80, 'Confirma',oPnl , bConfirm,80,50,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnConfirm, 'CONFIRM')

    oBtnFechar  := TButton():New(320,05, 'Fechar',oPnl , bEncerra,80,50,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnFechar, 'FECHAR')

    oBtnLimpar  := TButton():New(320,(nLarg / 3), 'Limpar',oPnl , bLimpa,80,50,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnLimpar, 'FECHAR')

    oGetData:Disable()

return(nil)

static function checkPrior()
    if cPrior == "C - PROGRAMADO"
        oGetData:Enable()
    else
        oGetData:Disable()
    endif
return(nil)

static function encerra(lMyKeep)
    lKeep := lMyKeep
    oDlg:End()
return(nil)

static function confirma()
    local lRet := .T.
    local aRet := {}
    FWMsgRun(, { || validaCampos(@lRet) }, 	"SMC - Solicitação de Manutenção Corretiva", "Validando...")
    if lRet
        aRet := SendFluig()
        if aRet[1]
            MsgInfo('SMC: ' + cValToChar(aRet[2]) + ' inclusa com sucesso!','Sucesso')
            encerra(.T.)
        endif
    endif
return(lRet)

static function buscaNome()
	local oSql 		:= LibSqlObj():newLibSqlObj()

    oSql:newTable("SRA", "RA_NOME NOME", "RA_FILIAL+RA_MAT = '" + AllTrim(cCracha) + "'")

	if oSql:hasRecords()
        cNome := AllTrim(oSql:getValue("NOME"))
    else
        cNome := Space(TamSX3("RA_NOME")[1])
	endif
    oGetNome:Refresh()
    oSql:close()
    FreeObj(oSql)
return(.T.)

static function validaCampos(lRet)
    default lRet := .T.
    lRet := .T.
    
    if empty(cCracha) .or. empty(cNome) .or. empty(cFalha) .or.;
        empty(cSetor) .or. empty(cMaquina) .or. empty(cSituac) .or. empty(cPrior)
        lRet := .F.
        MsgAlert('Campo(s) Obrigatório(s) não preenchido(s)!','Campo(s) Não Preechido(s)')
    endif 
    if cPrior == "C - PROGRAMADO" .and. (dDataSol < dDataBase) 
        lRet := .F.
        MsgAlert('Data Programada Inválida!','Programação Inválida')
    endif
return(lRet)

static function SendFluig()
    local oClientFluig  := nil
    local cUrl          := AllTrim(GetNewPar("ZZ_ENDFLUI", "http://192.168.1.217:6080"))
    local cRet          := ""
    local lRet          := .T.
    local oRet          := JsonObject():new()
    local nID           := 0

    oClientFluig := FWoAuth1Fluig():New("chave_simples","protheus_fluig",cUrl,"")
    oClientFluig:SetToken("c5872cc3-2aa3-4d3f-89ad-5fda62b3a63f")
    oClientFluig:setSecretToken('11b552ac-552e-47ce-99dd-ce6794e3409d0d5772bd-a412-4310-b485-e169855933b8')
    
    /* Iniciar tarefa de SMC */
    oSMC := getJsonMdl()
    oSMC['taskUserId']           := 'operadores'
    oSMC['selectedColleague'][1] := 'Pool:Role:Aprova_SMC'
    
    putValue('cracha',           AllTrim(cCracha),          @oSMC['formData'])
    putValue('nome',             AllTrim(cNome),            @oSMC['formData'])
    putValue('setor',            AllTrim(cSetor),           @oSMC['formData'])
    putValue('maquina',          AllTrim(cMaquina),         @oSMC['formData'])
    putValue('situacao',         cSituac,                   @oSMC['formData'])  // (Parado YES NO)
    putValue('prioridade',       cPrior,                    @oSMC['formData'])  // A IMEDIATO / B URGENTE / C PROGRMADO
    putValue('txt_programado',   DtoC(dDataSol),            @oSMC['formData'])
    putValue('falha',            AllTrim(cFalha),           @oSMC['formData'])
    cRet := oClientFluig:Post(cUrl + "/ecm/api/rest/ecm/workflowView/send",,oSMC:toJson())
    oRet:FromJson(cRet)
    if (AllTrim(oRet["content"]) == "ERROR")
        lRet := .F.
        MsgAlert(AllTrim(oRet["message"]["message"]), "Erro ao Concluir SMC")
    else
        if ValType(oRet:GetJsonObject('content')) <> 'U'
            if ValType(oRet["content"]:GetJsonObject('processInstanceId')) <> 'U'
                nID := oRet["content"]["processInstanceId"]
            endif
        endif
    endif
    FreeObj(oRet)
    FreeObj(oClientFluig)
return({lRet, nID})

static function putValue(cName, xValue, aJs)
    local nPos := AScan( aJs, {|x| Alltrim(x['name']) == Alltrim(cName)} )
    if nPos > 0
        aJs[nPos]['value'] := xValue
    endif
return nil

static function getJsonMdl()
    local cMdlStr := '{"processInstanceId":0,"processId":"CBC_SMC","version":114,"taskUserId":"admin","completeTask":true,"currentMovto":0,"managerMode":false,"selectedDestinyAfterAutomatic":-1,"conditionAfterAutomatic":-1,"selectedColleague":[],"comments":"","newObservations":[],"appointments":[],"attachments":[],"digitalSignature":false,"formData":[{"name":"caprovado","value":""},{"name":"caprovado","value":""},{"name":"tmotivo","value":""},{"name":"tnumcracha","value":""},{"name":"tnomsolic","value":""},{"name":"tsetorsolic","value":""},{"name":"tmaqequip","value":""},{"name":"requipstop","value":""},{"name":"rprioridade","value":""},{"name":"dateprogram","value":""},{"name":"tfalha","value":""},{"name":"_tmotivo","value":""},{"name":"ccausasprov","value":"   "},{"name":"toutras","value":""},{"name":"tdiagmanut","value":""},{"name":"column_seq","value":""},{"name":"column_item","value":""},{"name":"column_cod","value":""},{"name":"column_desc","value":""},{"name":"column_quant","value":""},{"name":"column_idx","value":""},{"name":"column_SERV_desc","value":""},{"name":"column_SERV_solic","value":""},{"name":"column_SERV_idx","value":""},{"name":"column_OPER_mat","value":""},{"name":"column_OPER_nome","value":""},{"name":"column_OPER_idx","value":""},{"name":"ctrl_Atividade","value":"0"},{"name":"ctrl_Cadastro","value":""},{"name":"ctrl_Separacao","value":""},{"name":"ctrl_Solicita","value":""},{"name":"ctrl_Pendencia","value":""},{"name":"SERV_in_add","value":""},{"name":"comp_in_add","value":""},{"name":"OPER_in_add","value":""},{"name":"NumSMC","value":"0"},{"name":"_caprovado","value":""}],"isDigitalSigned":false,"versionDoc":0,"selectedState":18,"internalFields":[],"transferTaskAfterSelection":false,"currentState":2}'
    local oJs     := nil
    oJs := JsonObject():new()
    oJs:fromJson(cMdlStr)
return oJs

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
			cCss +=	"QLabel { ";
						+"  font-size: 35px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
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
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+"  color: #000000; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"}"
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)

user function cbc01SMCPds()
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
        u_cbcFluSMC(),;
        Final("SMC PDS FINALIZADO")}

    //Seta Atributos
    __lInternet := .F.
    lMsFinalAuto := .F.
    oApp:lMessageBar:= .T.
    oApp:cModDesc:= 'SIGAADV'

    //Inicia a Janela
    oApp:Activate()
return(nil)
