#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcMovCheck()
    private dDtFecha := DtoC(GetMv("MV_ULMES"))
    private dDtIni   := ""
    private dDtFim   := ""
    private lLoop    := .T.

    while lLoop
        lLoop := .F.
        pergs()
        if !empty(dDtIni) .and. !empty(dDtFim)
            // iniciar View
            FWMsgRun(, { || view() }, 	"Analise de Movimentos", "Iniciando...")
        endif
    endDo
return(nil)

static function view()
    private aCoors      := FWGetDialogSize( oMainWnd )
    private oDlg        := nil
    private oFont	    := TFont():New("Arial",,20,,.T.)
    private oFWLayer    := nil
    private oPnlUP      := nil
    private oPnlDW      := nil
    private oTFolder    := nil
    private oGrpProd    := nil
    private oGrpReq     := nil
    private oGrpDev     := nil
    private oGrpInd     := nil
    private oGrpMov     := nil
    private oGrpMod     := nil
    private oBtnPar     := nil
    private oGetFecha   := nil
    private oGetIni     := nil
    private oGetFim     := nil
    private oSayFecha   := nil
    private oSayIni     := nil
    private oSayFim     := nil
    private oMovCheck   := ctrlMovCheck():newctrlMovCheck()
    private oCtrlCM     := cbcCusCtrl():newcbcCusCtrl()
    private aTFolder    := {'Movimentacoes', 'Custo', 'Fechamento','Inventario'}
    private lCMLoaded   := .F.
    
    DEFINE MSDIALOG oDlg TITLE 'Analise de Movimentos' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlg:lMaximized := .T.
    layout()
    //checkMovtos()
    Activate MsDialog oDlg Center

    oMovCheck:destroyTables()

    FreeObj(oCtrlCM)
    FreeObj(oMovCheck)
    FreeObj(oGetFecha)
    FreeObj(oGetIni)
    FreeObj(oGetFim)
    FreeObj(oSayFecha)
    FreeObj(oSayIni)
    FreeObj(oSayFim)
    FreeObj(oBtnPar)
    FreeObj(oGrpProd)
    FreeObj(oGrpReq)
    FreeObj(oGrpDev)
    FreeObj(oGrpInd)
    FreeObj(oGrpMov)
    FreeObj(oGrpMod)
    FreeObj(oGrpPar)
    FreeObj(oPnlUP)
    FreeObj(oPnlDW)
    FreeObj(oTFolder)
    FreeObj(oFont)
    FreeObj(oFWLayer)
    FreeObj(oDlg)
return(nil)

static function layout()
    local lCloseButt := !(oAPP:lMdi)
    oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, lCloseButt)
    // Coluna Esquerda
	oFWLayer:AddCollumn('PRINC', 100, .F.)		
	
    // Janela Informação
	oFWLayer:AddWindow('PRINC', 'WND_PAR', 'Parâmetro', 15, .T., .F.)
	oPnlUP := oFWLayer:GetWinPanel('PRINC', 'WND_PAR')
	oFWLayer:AddWindow('PRINC', 'WND_DAD', 'Dados', 85, .T., .F.)
	oPnlDW := oFWLayer:GetWinPanel('PRINC', 'WND_DAD')

    oSayFecha	:= TSay():New(07,05,	{||'Dt. Fecha:'}, oPnlUP,,oFont,,,,.T.,,, 050, 25)
    applyCss(@oSayFecha)
    oGetFecha	:= TGet():New(02,45, 	{ | u | If( PCount() == 0, dDtFecha, dDtFecha := u ) }, oPnlUP, 075, 020,"@!",,,CLR_LIGHTGRAY,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,dDtFecha,,,, )
    oGetFecha:lFocSel := .F.
    oGetFecha:SetContentAlign(0)
    applyCss(@oGetFecha)

    oSayIni	    := TSay():New(07,135,	{||'Dt. Inicio:'}, oPnlUP,,oFont,,,,.T.,,, 050, 25)
    applyCss(@oSayIni)
    oGetIni	    := TGet():New(02,175, 	{ | u | If( PCount() == 0, dDtIni, dDtIni := u ) }, oPnlUP, 075, 020,"@!",,,CLR_LIGHTGRAY,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,dDtIni,,,, )
    oGetIni:lFocSel := .F.
    oGetIni:SetContentAlign(0)
    applyCss(@oGetIni)

    oSayFim	    := TSay():New(07,265,	{||'Dt. Fim:'}, oPnlUP,,oFont,,,,.T.,,, 050, 25)
    applyCss(@oSayFim)
    oGetFim	    := TGet():New(02,300, 	{ | u | If( PCount() == 0, dDtFim, dDtFim := u ) }, oPnlUP, 075, 020,"@!",,,CLR_LIGHTGRAY,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,dDtFim,,,, )
    oGetFim:lFocSel := .F.
    oGetFim:SetContentAlign(0)
    applyCss(@oGetFim)

    oBtnPar     := TButton():New(02,395, 'Parâmetros',oPnlUP , {|| changePar()},50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    applyCss(@oBtnPar)

    oTFolder := TFolder():New(05,05,aTFolder,,oPnlDW,,,,.T.,,aCoors[4],aCoors[3])
    oTFolder:Align 	:= CONTROL_ALIGN_ALLCLIENT
    oTFolder:SetOption(1)

    //oBtnCM     := TButton():New(05,05, 'Load',oTFolder:aDialogs[2] , {|| FWMsgRun(, { || cmTab() }, 	"Aguarde...", "Carregando Visão...")},50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    //applyCss(@oBtnCM)
    
    oTMenuBar := TMenuBar():New(oTFolder:aDialogs[1])
 
    oTMenu := TMenu():New(0,0,0,0,.T.,,oTFolder:aDialogs[1])
    oTMenuBar:AddItem('Ações Relacionadas'  , oTMenu, .T.)
    // Cria Itens do Menu   
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[1],'Carregar Dados',,,,{|| FWMsgRun(, { || checkMovtos() }, 	"Aguarde...", "Analisando Movimentos...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu:Add(oTMenuItem)

    //MENU CM
    oTMenuBar2 := TMenuBar():New(oTFolder:aDialogs[2]) 
    oTMenu1 := TMenu():New(0,0,0,0,.T.,,oTFolder:aDialogs[2])
    oTMenuBar2:AddItem('Ações Relacionadas'  , oTMenu1, .T.)    
    // Cria Itens do Menu   
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Carregar Dados',,,,{|| FWMsgRun(, { || cmTab() }, 	"Aguarde...", "Carregando Visão...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu1:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Acertos',,,,{|| FWMsgRun(, { || u_CBCUSR04() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu1:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Ctb. Compras',,,,{|| FWMsgRun(, { || u_CBCUSR01() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu1:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Plan. Resumo',,,,{|| FWMsgRun(, { || planResumo() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu1:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Plan. Detalhes',,,,{|| FWMsgRun(, { || planDetalhes() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu1:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'ETL Custos',,,,{|| FWMsgRun(, { || extractETL() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu1:Add(oTMenuItem)

    oTMenu2 := TMenu():New(0,30,0,0,.T.,,oTFolder:aDialogs[2])
    oTMenuBar2:AddItem('Relatórios'  , oTMenu2, .T.)
     // Cria Itens do Menu   
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Ent./Sai.',,,,{|| FWMsgRun(, { || matr320() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu2:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Mod.1',,,,{|| FWMsgRun(, { || CTBR040() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu2:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Mod.7',,,,{|| FWMsgRun(, { || matr460() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu2:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Ctb.Compras',,,,{|| FWMsgRun(, { || u_CBCUSR01() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu2:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Acerto Val',,,,{|| FWMsgRun(, { || u_CBCUSR04() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu2:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'An.Recursi',,,,{|| FWMsgRun(, { || MATR331() }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu2:Add(oTMenuItem)
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[2],'Bloco H',,,,{|| FWMsgRun(, { || genBlocoH(dDtFim) }, 	"Aguarde...", "Carregando...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu2:Add(oTMenuItem)

    //INVENTÁRIO
    oTMenuBar4 := TMenuBar():New(oTFolder:aDialogs[4])
 
    oTMenu4 := TMenu():New(0,0,0,0,.T.,,oTFolder:aDialogs[4])
    oTMenuBar4:AddItem('Ações Relacionadas'  , oTMenu4, .T.)
    // Cria Itens do Menu   
    oTMenuItem := TMenuItem():New(oTFolder:aDialogs[4],'Verificar Mvtos',,,,{|| FWMsgRun(, { || u_viewMvtoKdx(DtoS(CtoD(dDtIni)), DtoS(CtoD(dDtFim))) }, 	"Aguarde...", "Analisando Movimentos...")},,/*'AVGLBPAR1'*/,,,,,,,.T.)   
    oTMenu4:Add(oTMenuItem)

return(nil)

static function cmTab()
    local aErr      := {}
    Local oStatic   := IfcXFun():newIfcXFun()

    oStatic:sP(2):callStatic('srvMovCheck', 'srvCMLoad', DtoS(CtoD(dDtIni)), DtoS(CtoD(dDtFim)))
    oGrpESxCTB := TGroup():New(025,002,155,130,'ES x CTB',    oTFolder:aDialogs[2],,,.T.)
    oSayESxCTB := TSay():New(025,002,	{||"OK"}, oGrpESxCTB,,oFont,,,,.T.,,, 130, 130)
    oSayESxCTB:SetTextAlign( 2, 2 )
    applyCss(@oSayESxCTB, "OK")
    aErr := oCtrlCM:confx('CONTAB',{'compras'})
    if !empty(aErr)
        oSayESxCTB:SetText("DIVERGÊNCIA")
        oSayESxCTB:BldBlClick := {|| detailCM('ES x CTB', oCtrlCM:confx('CONTAB',{'compras'}))}
        applyCss(@oSayESxCTB, "ERR")
    endif

    oGrpESxBal  := TGroup():New(025,132,155,260,'ES x BAL',  oTFolder:aDialogs[2],,,.T.)
    oSayESxBal := TSay():New(025,132,	{||"OK"}, oGrpESxBal,,oFont,,,,.T.,,, 130, 130)
    oSayESxBal:SetTextAlign( 2, 2 )
    applyCss(@oSayESxBal, "OK")
    aErr := oCtrlCM:confx('BALANCETE',{'compras'})
    if !empty(aErr)
        oSayESxBal:SetText("DIVERGÊNCIA")
        oSayESxBal:BldBlClick := {|| detailCM('ES x BAL', oCtrlCM:confx('BALANCETE',{'compras'}))}
        applyCss(@oSayESxBal, "ERR")
    endif
    
    oGrpESxMod  := TGroup():New(025,262,155,390,'ES x MOD7',  oTFolder:aDialogs[2],,,.T.)
    oSayESxMod := TSay():New(025,262,	{||"OK"}, oGrpESxMod,,oFont,,,,.T.,,, 130, 130)
    oSayESxMod:SetTextAlign( 2, 2 )
    applyCss(@oSayESxMod, "OK")
    aErr := oCtrlCM:confx('MODELO7',{'compras'})
    if !empty(aErr)
        oSayESxMod:SetText("DIVERGÊNCIA")
        oSayESxMod:BldBlClick := {|| detailCM('ES x MOD7', oCtrlCM:confx('MODELO7',{'compras'}))}
        applyCss(@oSayESxMod, "ERR")
    endif

    oTFolder:Refresh()
    lCMLoaded := .T.
return(nil)

static function applyCss(oObj, cOpc)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
    default cOpc    := ""

	if cTpObj == "TBUTTON"
            cCSS :=	"QPushButton {";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  border: 2px solid #00297c; /*Cor da borda*/";
                                +"  border-radius: 6px; /*Arrerondamento da borda*/";
                                +"  font-size: 15px; /*Tamanho da fonte*/";
                                +"  color: #FFFFFF; /*Cor da fonte*/";
                                +"  font-weight: bold; /*Negrito*/";
                                +"  text-align: center; /*Alinhamento*/";
                                +"  vertical-align: middle; /*Alinhamento*/";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #012b73, stop: 1 #367cf5); /*Cor de fundo*/";
                                +"  min-width: 20px; /*Largura minima*/";
                                +"}";
                                +"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
                                +"QPushButton:pressed {";
                                +"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
                                +"                                    stop: 0 #367cf5 stop: 1 #012b73);";
                                +"}"
	elseif cTpObj == "TSAY"
        if cOpc == "OK"
            cCss +=	"QLabel { ";
						+"  font-size: 25px; /*Tamanho da fonte*/";
						+"  color: #007c08; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
        elseif cOpc == "ERR"
            cCss +=	"QLabel { ";
						+"  font-size: 25px; /*Tamanho da fonte*/";
						+"  color: #d11d1d; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
        else
			cCss +=	"QLabel { ";
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
        endif
    elseif cTpObj == "TGET"
			cCss +=	"QLineEdit { ";
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+" color: #FFFFFF; /*Cor da fonte*/ ";
						+" background-color: #00297c;";	
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
						+"  font-size: 15px; /*Tamanho da fonte*/";
						+"  color: #FFFFFF; /*Cor da fonte*/";
                        +"  background-color: #00297c;";
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

static function changePar()
    lLoop    := .T.
    oDlg:End()
return(nil)

static function pergs()
    local aRet      := {}
    local aPerg     := {}

    dDtIni   := ""
    dDtFim   := ""

    aadd(aPerg,{1,"Data Inicial", dDataBase,PesqPict("SF2","F2_EMISSAO"),".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Final",   dDataBase,PesqPict("SF2","F2_EMISSAO"),".T.","",".T.",50,.T.})

    if (ParamBox(aPerg,"Parâmetros",@aRet))
        dDtIni   := DtoC(aRet[01])
        dDtFim   := DtoC(aRet[02])
    endif
return(nil)

static function checkMovtos()
    //aOper         := {"PR0","RE0","PR0IND","RE0IND","DEV","POSPR0","ANTOP","POSOP","MOD"}
    oMovCheck:createTables(DtoS(CtoD(dDtIni)), DtoS(CtoD(dDtFim)))

    oGrpProd := TGroup():New(025,002,130,130,'Produções',    oTFolder:aDialogs[1],,,.T.)
    oSayProd := TSay():New(025,002,	{||"OK"}, oGrpProd,,oFont,,,,.T.,,, 130, 130)
    applyCss(@oSayProd, "OK")
    oSayProd:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("PR0") > 0
        oSayProd:SetText(cValToChar(oMovCheck:hasRecords("PR0")) + " sem REQ")
        oSayProd:BldBlClick := {|| detail("PR0")}
        applyCss(@oSayProd, "ERR")
    endif
    
    oGrpReq  := TGroup():New(025,132,130,260,'Requisições',  oTFolder:aDialogs[1],,,.T.)
    oSayReq  := TSay():New(025,132,	{||"OK"}, oGrpReq,,oFont,,,,.T.,,, 130, 130)
    applyCss(@oSayReq, "OK")
    oSayReq:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("RE0") > 0
        oSayReq:SetText(cValToChar(oMovCheck:hasRecords("RE0")) + " sem PROD")
        oSayReq:BldBlClick := {|| detail("RE0")}
        applyCss(@oSayReq, "ERR")
    endif
    
    oGrpDev  := TGroup():New(025,262,130,390,'Devoluções',   oTFolder:aDialogs[1],,,.T.)
    oSayDev  := TSay():New(025,262,	{||"OK"}, oGrpDev,,oFont,,,,.T.,,, 130, 130)
    applyCss(@oSayDev, "OK")
    oSayDev:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("DEV") > 0
        oSayDev:SetText(cValToChar(oMovCheck:hasRecords("DEV")) + " sem REQ")
        oSayDev:BldBlClick := {|| detail("DEV")}
        applyCss(@oSayDev, "ERR")
    endif
    
    oGrpRec  := TGroup():New(025,392,130,520,'Recursividades',   oTFolder:aDialogs[1],,,.T.)
    oSayRec  := TSay():New(025,392,	{||"OK"}, oGrpRec,,oFont,,,,.T.,,, 130, 130)
    applyCss(@oSayRec, "OK")
    oSayRec:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("REC") > 0
        oSayRec:SetText("Recursividades")
        oSayRec:BldBlClick := {|| detail("REC")}
        applyCss(@oSayRec, "ERR")
    endif

    oGrpIndPr  := TGroup():New(132,002,197,130,'Industrializa - Produções',oTFolder:aDialogs[1],,,.T.)
    oSayIndPr  := TSay():New(132,002,	{||"OK"}, oGrpIndPr,,oFont,,,,.T.,,, 130, 65)
    applyCss(@oSayIndPr, "OK")
    oSayIndPr:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("PR0IND") > 0
        oSayIndPr:SetText(cValToChar(oMovCheck:hasRecords("PR0IND")) + " sem REQ")
        oSayIndPr:BldBlClick := {|| detail("PR0IND")}
        applyCss(@oSayIndPr, "ERR")
    endif
    
    oGrpIndRe  := TGroup():New(198,002,262,130,'Industrializa - Requisições',oTFolder:aDialogs[1],,,.T.)
    oSayIndRe  := TSay():New(198,002,	{||"OK"}, oGrpIndRe,,oFont,,,,.T.,,, 130, 65)
    applyCss(@oSayIndRe, "OK")
    oSayIndRe:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("RE0IND") > 0
        oSayIndRe:SetText(cValToChar(oMovCheck:hasRecords("RE0IND")) + " sem PROD")
        oSayIndRe:BldBlClick := {|| detail("RE0IND")}
        applyCss(@oSayIndRe, "ERR")
    endif
    
    oGrpMovPPR  := TGroup():New(132,132,175,260,'Movimentos - Pós-Prod',   oTFolder:aDialogs[1],,,.T.)
    oSayMovPPR  := TSay():New(132,132,	{||"OK"}, oGrpMovPPR,,oFont,,,,.T.,,, 130, 43)
    applyCss(@oSayMovPPR, "OK")
    oSayMovPPR:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("POSPR0") > 0
        oSayMovPPR:SetText(cValToChar(oMovCheck:hasRecords("POSPR0")) + " Movtos Pós PR")
        oSayMovPPR:BldBlClick := {|| detail("POSPR0")}
        applyCss(@oSayMovPPR, "ERR")
    endif
    oGrpMovPOP  := TGroup():New(176,132,219,260,'Movimentos - Pós OP',   oTFolder:aDialogs[1],,,.T.)
    oSayMovPOP  := TSay():New(176,132,	{||"OK"}, oGrpMovPOP,,oFont,,,,.T.,,, 130, 43)
    applyCss(@oSayMovPOP, "OK")
    oSayMovPOP:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("POSOP") > 0
        oSayMovPOP:SetText(cValToChar(oMovCheck:hasRecords("POSOP")) + " Movtos Pós OP")
        oSayMovPOP:BldBlClick := {|| detail("POSOP")}
        applyCss(@oSayMovPOP, "ERR")
    endif
    oGrpMovPPR  := TGroup():New(220,132,262,260,'Movimentos - Antes OP',   oTFolder:aDialogs[1],,,.T.)
    oSayMovAOP  := TSay():New(220,132,	{||"OK"}, oGrpMovPPR,,oFont,,,,.T.,,, 130, 43)
    applyCss(@oSayMovAOP, "OK")
    oSayMovAOP:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("ANTOP") > 0
        oSayMovAOP:SetText(cValToChar(oMovCheck:hasRecords("ANTOP")) + " Movtos Antes OP")
        oSayMovAOP:BldBlClick := {|| detail("ANTOP")}
        applyCss(@oSayMovAOP, "ERR")
    endif
    oGrpMod  := TGroup():New(132,262,262,390,'MOD',          oTFolder:aDialogs[1],,,.T.)
    oSayMOD  := TSay():New(132,262,	{||"OK"}, oGrpMod,,oFont,,,,.T.,,, 130, 130)
    applyCss(@oSayMOD, "OK")
    oSayMOD:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("MOD") > 0
        oSayMOD:SetText(cValToChar(oMovCheck:hasRecords("MOD")) + " PR sem MOD")
        oSayMOD:BldBlClick := {|| detail("MOD")}
        applyCss(@oSayMOD, "ERR")
    endif
    oGrpPar  := TGroup():New(132,392,262,520,'Parciais', oTFolder:aDialogs[1],,,.T.)
    oSayPar  := TSay():New(132,392,	{||"OK"}, oGrpPar,,oFont,,,,.T.,,, 130, 130)
    applyCss(@oSayPar, "OK")
    oSayPar:SetTextAlign( 2, 2 )
    if oMovCheck:hasRecords("PAR") > 0
        oSayPar:SetText(cValToChar(oMovCheck:hasRecords("PAR")) + " Movtos Parc")
        oSayPar:BldBlClick := {|| detail("PAR")}
        applyCss(@oSayPar, "ERR")
    endif
    oTFolder:Refresh()
return(nil)

static function detail(cOpc)
    local oFWMsExcel := nil
    local oExcel	 := nil
    local cNomArqv   := GetTempPath() + 'Plan_' + cOpc + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local cAls       := &("oTmp" + cOpc):GetAlias()
    Local oStatic    := IfcXFun():newIfcXFun()
    local aFlds      := oStatic:sP(3):callStatic('srvMovCheck', 'getFields', 'B', cOpc, cAls)
    local nX         := 0
    
    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Movimento")
    oFWMsExcel:AddTable("Movimento",cOpc)
    for nX := 1 to len(aFlds)
        oFWMsExcel:AddColumn("Movimento", cOpc, aFlds[nX, 01],1)
    next nX

    DbSelectArea(cAls)
    (cAls)->(DbGoTop())
	while (cAls)->( !Eof())
        aTemp := {}
        for nX := 1 to len(aFlds)
            aAdd(aTemp, Eval(aFlds[nX, 02]))
        next nX
        oFWMsExcel:AddRow("Movimento", cOpc, aTemp)
        (cAls)->(DbSkip())
    endDo
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)

    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    FreeObj(oFWMsExcel)
    FreeObj(oExcel)
return(nil)

static function detailCM(cTitulo, aErr)
	local nX		:= 0
	local cHtml		:= ''
	local cLinha	:= '<br>'
    Local oStatic   := IfcXFun():newIfcXFun()

    cHtml   := "<HTML><BODY><FONT FACE=VERDANA SIZE=2 COLOR=BLACK>"
    cHtml	+= cTitulo
    cHtml   += cLinha
   
    cHtml += '<table class="table" id="table">'
        cHtml += '<col style="width:100%">'
        cHtml += '<thead>'
            cHtml += '<tr>'
                cHtml += '<th>Error</th>'
            cHtml += '</tr>'
        cHtml += '</thead>'
        cHtml += '<tbody>'
            for nX := 1 to len(aErr)
                cHtml += '<tr>'
                    cHtml += '<td>'
                        cHtml += AllTrim(aErr[nX])
                    cHtml += '</td>'
                cHtml += '</tr>'
            next nX
        cHtml += '</tbody>'
    cHtml += '</table>'
	oStatic:sP(1):callStatic('srvMovCheck', 'initVw', cHtml)
return(nil)

static function planResumo()
    local aRet      := {}
    local aPerg     := {}
    local aOpc      := {'ES', 'CONTAB', 'BALANCETE', 'MODELO7'}
    local aTemp     := {}
    local nX        := 0

    if !lCMLoaded
        MsgAlert('Dados não carregados!','Sem Dados')
    else
        for nX := 1 to len(aOpc)
            aAdd(aPerg,{5,aOpc[nX],.F.,50,"",.F.})
        next nX
        if (ParamBox(aPerg,"Selecionar Resumos",@aRet))
            for nX := 1 to len(aRet)
                if aRet[nX]
                    aAdd(aTemp, aOpc[nX])
                endif
            next nX
            if !empty(aTemp)
                oCtrlCM:sndPlan(aTemp)
            endif
        endif
    endif
return(nil)

static function planDetalhes()
    local aRet      := {}
    local aPerg     := {}
    local aOpc      := {'ES', 'CONTAB', 'BALANCETE', 'MODELO7', 'BAL.TERC', 'BAL.COMPRAS'}
    local nOpc      := 0
    local aSubOpc   := {}

    if !lCMLoaded
        MsgAlert('Dados não carregados!','Sem Dados')
    else
        aAdd(aPerg,{3,"Selecione: ",1,aOpc,50,"",.F.})
        if (ParamBox(aPerg,"Selecionar",@aRet))
            nOpc := aRet[01]
            if aOpc[nOpc] == 'CONTAB' .or. aOpc[nOpc] == 'MODELO7'
                oCtrlCM:detPlan(aOpc[nOpc])
            else
                aPerg   := {}
                aRet    := {}
                if aOpc[nOpc] == 'ES'
                    aSubOpc := {'compras','mov.interna','producao', 'vendas', 'dev.venda', 'entr.poder terc', 'saida poder terc','req.p/prod.','all_es'}
                elseif aOpc[nOpc] == 'BALANCETE'
                    aSubOpc := {'ME','MP','OI','PA','PI','SC','SV','MR'}
                elseif aOpc[nOpc] == 'BAL.TERC'
                    aOpc[nOpc] := 'BALAN_3'
                    aSubOpc := {'ME','PA'}
                elseif aOpc[nOpc] == 'BAL.COMPRAS'
                    aOpc[nOpc] := 'BALAN_COMPRAS'
                    aSubOpc := {'MP'}
                endif
                aAdd(aPerg,{3,"Selecione: ",1,aSubOpc,50,"",.F.})
                if (ParamBox(aPerg,"Selecionar",@aRet))
                    oCtrlCM:detPlan(aOpc[nOpc], aSubOpc[aRet[01]])
                endif
            endif
        endif
    endif
return(nil)

static function extractETL()
    local oSrv := cbcCusService():newcbcCusService()
    oSrv:etlData(oCtrlCM)
return(nil)

static function genBlocoH(dDtFim)
    local cDtFim        := DtoS(CtoD(dDtFim))
    local oFWMsExcel    := nil
    local oExcel	    := nil
    local cNomArqv      := GetTempPath() + 'Plan_BlocoH_' + cDtFim + '_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local oSql          := LibSqlObj():newLibSqlObj()    
    local cQry          := u_qryGenBlocoH(cDtFim)

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("DASH")
    oFWMsExcel:AddTable("DASH","BlocoH")
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Situação",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Produto",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "U.M.",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Quantidade",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Val.Unit.",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Total",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Armazem",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Cli|For",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Loja",1)
    oFWMsExcel:AddColumn("DASH", "BlocoH", "Tipo C|F",1)
    
    oSql:newAlias(cQry)
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()

            oFWMsExcel:AddRow("DASH", "BlocoH", {  oSql:getValue('SITUACAO'),;
                                                        oSql:getValue('PRODUTO'),;
                                                        oSql:getValue('UM'),;
                                                        oSql:getValue('QTD'),;
                                                        oSql:getValue('VAL_UNIT'),;
                                                        oSql:getValue('TOTAL'),;
                                                        oSql:getValue('ARMAZEM'),;
                                                        oSql:getValue('CLIFOR'),;
                                                        oSql:getValue('LOJA'),;
                                                        oSql:getValue('TPCF');
                                                     })
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)

    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    FreeObj(oFWMsExcel)
    FreeObj(oExcel)
return(nil)
