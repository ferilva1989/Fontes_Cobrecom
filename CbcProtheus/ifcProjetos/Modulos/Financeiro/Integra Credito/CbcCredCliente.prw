#INCLUDE "TOTVS.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'
#include "TOPCONN.ch"
#include "tbiconn.ch"   
#Define linha chr(13)+chr(10)

#define 	ARRAY_OPC {'SER','CCB','MON','INF'}
#define 	LOK 1
#define		CERRMSG 2
#define		ORESP 3
#define		CRESP 4
#define 	HEADER 'Content-Type: application/json' 

class CbcCredCliente

	data oArea
	data cEndUrl
	data lOk
	data cMsg
	data cCliente
	data cLoja
	data cCNPJ
	data nRecCli
	data cOpc
	data cLogon
	data cPass

	method newCbcCredCliente() constructor

	method getCliente()
	method setCliente()
	method getLoja()
	method setLoja()
	method getCNPJ()
	method setCNPJ()
	method getRecCli()
	method setRecCli()
	method getLogon()	
	method setLogon()
	method getPass()
	method setPass()
	method getOpc()
	method setOpc()
		
	method isOK()
	method initView()
	method getCliInfo()
	method setAuth()
	method getRota()	
	method consultaCred()  
	method refreshSer()
	
endclass

method newCbcCredCliente(cCli, cLoja, nRecno) class CbcCredCliente
	default cCli 	:= ''
	default cLoja 	:= ''
	default nRecno	:= 0

	::lOk 		:= .T.
	::oArea 	:= SigaArea():newSigaArea()
	::cOpc		:= ''
	::setCliente(cCli)
	::setLoja(cLoja)
	::setRecCli(nRecno)
	::getCliInfo()
	::setLogon()
	::setPass()
return(self)

method getCliente() class CbcCredCliente
return(::cCliente)

method setCliente(cCli) class CbcCredCliente
	::cCliente := Padr(cCli,TamSx3("A1_COD") [1])
return(self)

method getLoja() 	class CbcCredCliente
return(::cLoja)

method setLoja(cLoja) 	class CbcCredCliente
	::cLoja := Padr(cLoja, 	TamSx3("A1_LOJA")[1])
return(self)

method getCNPJ()	class CbcCredCliente
return(SubStr(::cCNPJ, 1,8))

method setCNPJ(cCnpj)	class CbcCredCliente
	::cCNPJ := Padr(cCnpj, TamSx3("A1_CGC")[1])
return(self)

method getRecCli() 	class CbcCredCliente
return(::nRecCli)

method setRecCli(nRec) 	class CbcCredCliente
	::nRecCli := nRec
return(self)
         
method getLogon() class CbcCredCliente
return(::cLogon)

method setLogon(logon) class CbcCredCliente
 ::cLogon := logon	
return(self)

method getPass() class CbcCredCliente
return(::cPass)

method setPass(pass) class CbcCredCliente
	::cPass := pass
return(self)

method setOpc(cOpc) class CbcCredCliente
	::cOpc := cOpc
return(self)

method getOpc() class CbcCredCliente
return(::cOpc)

method initView() class CbcCredCliente
	local cHome := ''
	
	FWMsgRun(, { |oSay| montaTela(cHome, @self) }, 	"Consulta Crédito", "Carregando...")
return(self)

method getCliInfo() class CbcCredCliente
	local cCli 	:= ::getCliente()
	local cLoja := ::getLoja()

	if !empty(cCli) .And. !empty(cLoja)
		::oArea:saveArea( {'SA1'} )
		DbSelectarea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		if SA1->(DbSeek(xFilial("SA1") + cCli + cLoja, .F.) )
			::setCNPJ(SA1->(A1_CGC))
		else
			::lOk := .F.
			::cMsg := "[ERRO] - Chave cliente: " + cCli + " / Loja: " + cLoja + " não encontrado"
		endif
		::oArea:backArea()
	else
		::lOk := .F.
		::cMsg := "[ERRO] - Cliente: " + cCli + " / Loja: " + cLoja + " não informado"
	endif
return(self)
                 
method setAuth() class CbcCredCliente
	local lRet		:= .F.	
	local aPergs	:= {}
	local aRet		:= {}
	local aPergRet	:= {}
	local cUsrInfo	:= ''
	local nOpc		:= 0
	
	::setPass("")
	::setLogon("")	
	
	cUsrInfo := Posicione("SX5",1,xFilial("SX5")+"Z8"+Alltrim(__CUSERID),"X5_DESCRI" )
		
	if !empty(cUsrInfo)
		aRet := StrTokArr(cUsrInfo, ";")
		nOpc := aScan(ARRAY_OPC,::getOpc())
		if len(aRet) >= nOpc .and. nOpc > 0
			::setLogon(AllTrim(aRet[nOpc])) 
			aAdd(aPergs,{8,"Digite a senha: ",Space(20),"","","","",80,.F.})
			if !ParamBox(aPergs ,"Insira a Senha de Acesso - Usuário: " + AllTrim(aRet[nOpc]),aPergRet)
				Alert("Login Cancelado!")
				::setPass("")
				::setLogon("")
			else
				if !empty(MV_PAR01)
					::setPass(AllTrim(MV_PAR01))
					lRet := .T.
				endif
			endIf			
		endIf 
	endif
	::lOk := lRet
return(self)

method getRota() class CbcCredCliente
	local cUrl 		:= ''
	local cParam	:= ''
	local oRst
	local aHeadOut	:= {}
	
	::cEndUrl 		:= ''
			
	if empty(::getCNPJ()) .or. empty(::getOpc()) .or. !::lOk
		::lOk 			:= .F.
		::cMsg 			:= "[ERRO-Cred] - Informações Inválidas!"
	else
		if ::getOpc() == 'SER'
			if ::refreshSer():lOk
				cUrl	:= AllTrim(GetNewPar('MV_APISERA', 'http://192.168.1.16:6235'))
				cParam	:= '/api/serasa/' + ::getCNPJ() + '/html'
			endif
		elseif ::getOpc() == 'CCB'
			if ::setAuth():lOk
				cUrl		:= GetNewPar('ZZ_CCBLINK', "http://www.ccb.inf.br/Conveniado/Consulta/ConsFicha.asp?")
				cParam		:= "Email=" + ::getLogon() + "&Senha=" + ::getPass() + "&CNPJ=" + ::getCNPJ() + "&Mercado=N"
			else
				::lOk 	:= .F.
				::cMsg 	:= "[ERRO-Cred] - Usuário inválido ou  não encontrado para utilizar o CCB"
			endif
		elseif ::getOpc() == 'MON'
			cUrl		:= AllTrim(GetNewPar('MV_APISERA', 'http://192.168.1.16:6235'))
			cParam		:= '/api/serasa/' + ::getCNPJ() + '/html'
		elseif ::getOpc() == 'INF'
			cUrl		:= AllTrim(GetNewPar('MV_APIHTML', 'http://192.168.1.16:7000'))
			cParam		:= '/infocnpj/' + ::getCNPJ()
		else
			::lOk 		:= .F.
			::cMsg 		:= "[ERRO-Cred] - Endereço de Consulta não disponível"
		endif
	endif
	if !empty(cUrl)
		oRst  := FWRest():New(cUrl)
		oRst:setPath(cParam)
		oRst:Get(aHeadOut)
		if oRst:oResponseH:cStatusCode == '200'
			::cEndUrl 			:= cUrl + cParam
		else	
			::lOk   := .F.
			::cMsg 	:= "Sem Retorno da Consulta! Atualize ou tente novamente!"
		endif
		freeObj(oRst)
	endif
return(self)

method consultaCred(cOpc) class CbcCredCliente
	::lOk   := .T.
	::cMsg 	:= ''
	
	if !empty(cOpc)
		if ::setOpc(cOpc):lOk
			if ::getRota():lOk
				OpenLink(::cEndUrl)
			endif			
		endif		
	else		
		::lOk 	:= .F.
		::cMsg 	:= "[ERRO-Cred] - Opção de Consulta não definida!"
	endif
	if !::lOk
		MsgInfo('Aviso',::cMsg)
		OpenLink('')
	endif
return(self)

method refreshSer()	class CbcCredCliente	
	local oRst
	local aHeadOut	:= {}
	local cBody 	:= ''	 
	local cUrl		:= AllTrim(GetNewPar('MV_APISERA', 'http://192.168.1.16:6235'))
	local lRet 		:= .F.
	local oJson		
	
	if msgYesNo('Deseja atualizar a consulta no SERASA?','Atualizar Consulta SERASA')
		if ::setAuth():lOk
			if msgYesNo('Será Cobrada Taxa referente a nova consulta no SERASA. Deseja continuar?','Atualizar SERASA - TAXA DE CONSULTA')	
				oJson := JsonObject():new()
			    oJson['logon']	:= ::getLogon()
			    oJson['senha']	:= ::getPass()
				oJson['cnpj']	:= ::getCNPJ()
			    oJson['ret']	:= 'relato'
					
				cBody := oJson:toJSON("" ,.F., .T.)
				
				oRst  := cbcRestAPI():newcbcRestAPI()
				oRst:setHeader(HEADER, .T.)
				oRst:setURL(cUrl)
				oRst:setURLPath('/api/consultanext')
				oRst:sendPost(cBody)	
				
				if ! oRst:getResp( LOK )
					::cMsg 	:= oRst:getResp( CERRMSG )
				else
					lRet := .T.
				endif
				FreeObj(oRst)
				FreeObj(oJson)
			else
				::cMsg 	:= 'Atualização da Consulta SERASA Cancelada!!!'
			endif
		else
			::lOk 	:= .F.
			::cMsg 	:= "[ERRO-Cred] - Usuário inválido ou  não encontrado para utilizar SERASA"
		endif
	else
		lRet := .T.
	endif
	::lOk := lRet
return(self)

static function montaTela(cLink, oSelf)
	local lCloseButt 		:= !(oAPP:lMdi)	
	local aCredCoors 		:= FWGetDialogSize( oMainWnd )
	private oScroll
	private oBrw
	private oTIBrw
	private oDlgCred
	private oFWCredLayer 	:= FWLayer():New()
	private oLPanel
	private oRPanel
	private oBtnClose
    private oBtnSerasa
    private oBtnMonitore
    private oBtnCcb
    private oBtnPrint
    private oBtnInfo
    private oBtnPosi
    private oBtnLog    
    private oWebChannel := TWebChannel():New()
    private nPort 		:= oWebChannel:connect()
    
    
	DEFINE MSDIALOG oDlgCred TITLE 'Controle de Status' ;
	    FROM aCredCoors[1],aCredCoors[2] TO aCredCoors[3],aCredCoors[4] ;
      OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
    
    oDlgCred:lMaximized := .T.
		
	oFWCredLayer:Init(oDlgCred, lCloseButt)
    
     //"Controles"
    oFWCredLayer:AddCollumn('COL_LEFT', 10, .F.)
	oFWCredLayer:AddWindow('COL_LEFT', 'WND_CTRL', 'Controles', 100, .T., .F.)
	oLPanel := oFWCredLayer:GetWinPanel('COL_LEFT', 'WND_CTRL')
	oFWCredLayer:SetColSplit('COL_LEFT', CONTROL_ALIGN_RIGHT)
	
	//"Navegação"
	oFWCredLayer:AddCollumn('COL_RIGHT', 90, .F.)
	oFWCredLayer:AddWindow('COL_RIGHT', 'WND_NAV', 'Navegação', 100, .T., .F.) 
	oRPanel := oFWCredLayer:GetWinPanel('COL_RIGHT', 'WND_NAV')
	oScroll := TScrollBox():New(oRPanel,01,01,oFWCredLayer:GETLAYERHEIGHT(),oFWCredLayer:GETLAYERWIDTH(),.T.,.T.,.T.)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	
	//"Botões"
    oBtnClose 	 := TButton():New( 005, 005, 'Fechar', 		oLPanel ,{|| oDlgCred:End()}, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnPrint 	 := TButton():New( 030, 005, 'Imprimir', 	oLPanel ,{|| oTIBrw:Print()}, 50,30,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnSerasa 	 := TButton():New( 065, 005, 'Serasa', 		oLPanel ,{|| FWMsgRun(, { |oSay| oSelf:consultaCred('SER') }, 		"Consulta SERASA RELATO", "Carregando Consulta...")}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnMonitore := TButton():New( 100, 005, 'Monitore', 	oLPanel ,{|| FWMsgRun(, { |oSay| oSelf:consultaCred('MON') }, 		"Consulta SERASA MONITORE", "Carregando Consulta...")}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnCcb 	 := TButton():New( 135, 005, 'CCB', 		oLPanel ,{|| FWMsgRun(, { |oSay| oSelf:consultaCred('CCB') }, 		"Consulta CCB", "Carregando Consulta...")}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnInfo 	 := TButton():New( 170, 005, 'Info', 		oLPanel ,{|| FWMsgRun(, { |oSay| oSelf:consultaCred('INF') }, 		"Consulta Informações", "Carregando Consulta...")}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnPosi 	 := TButton():New( 205, 005, 'Posição', 	oLPanel ,{|| FWMsgRun(, { |oSay| posiCli() }, 					   	"Consulta Posição Cliente", "Carregando Posição Cliente...")}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnLog 	 := TButton():New( 240, 005, 'Log Pedidos', oLPanel ,{|| FWMsgRun(, { |oSay| logPeds(@oBrw, @oRPanel, @oSelf)},	"Consulta Logs Pedidos", "Carregando Logs de Pedidos...")}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//"Browser"	 
	oTIBrw:= TWebEngine():New(oScroll, 0, 0, oFWCredLayer:GetLayerHeight(), oFWCredLayer:GetLayerWidth(),, nPort) 
    oTIBrw:navigate(cLink)
    oTIBrw:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE DIALOG oDlgCred CENTERED
	
	freeObj(oBtnClose)
    freeObj(oBtnSerasa)
    freeObj(oBtnMonitore)
    freeObj(oBtnCcb)
    freeObj(oBtnPrint)
    freeObj(oBtnInfo)
    freeObj(oBtnPosi)
    freeObj(oBtnLog)
    freeObj(oScroll)
	freeObj(oTIBrw)
	freeObj(oFWCredLayer)
	freeObj(oLPanel)
	freeObj(oRPanel)
	freeObj(oBrw)
    freeObj(oDlgCred)    
return(nil)

static function OpenLink(cLink)
	oTIBrw:navigate(cLink)
return(nil)

static function posiCli()
	private cFilCorr	 := cFilAnt
	private	aRotina := { {"Pesquisar","PesqBrw"	, 0 , 1,0,.F.},;
						 {"Automatica","A450LibAut", 0 , 2,0,NIL},;
						 {"Manual","A450LibMan", 0 , 4,0,NIL},;
						 {"Legenda","A450Legend", 0 , 3,0,.F.} }
	
	if ( Pergunte("FIC010",.T.) )
		Fc010Con()
	endif
		
	Pergunte("MTA451",.F.)
return(nil)

static function logPeds(oBrw, oPanel, oSelf)
	local cFiltro 	:= ''
	local cAls		:= 'ZZI'
	local cTitle	:= 'Log de Pedidos'
	
	getFilter(cAls, @cFiltro, oSelf)
	montaBrw(@oBrw, @oPanel, cAls,@cFiltro, cTitle)
	//freeObj(oBrw)		
return(nil)

static function getFilter(cAls, cFiltro, oSelf)
	default cFiltro := ''
	
	if cAls == 'ZZI'
		cFiltro += "@ZZI_CODCLI = '" + oSelf:getCliente() + "' "
		cFiltro += " AND ZZI_LOJCLI = '" + oSelf:getLoja() + "' "
		cFiltro += " AND ZZI_FILIAL+ZZI_PEDIDO IN ("
		cFiltro += " SELECT DISTINCT(SC9.C9_FILIAL+SC9.C9_PEDIDO) "
		cFiltro += " FROM " + RetSqlName('SC9') + " SC9 "
		cFiltro += " WHERE SC9.C9_FILIAL = ZZI_FILIAL "
		cFiltro += " AND SC9.C9_PEDIDO = ZZI_PEDIDO "
		cFiltro += " AND SC9.C9_BLCRED IN ('01','02','09') "
		cFiltro += " AND SC9.D_E_L_E_T_ <> '*' "
		cFiltro += " ) "
		cFiltro += " AND ZZI_CODEVE IN ('04','05','10') "
	endif
return(cFiltro)

static function montaBrw(oBrw, oPanel, cAls, cFiltro, cTitle)
	default cFiltro := ''
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias(cAls)
	oBrw:SetOwner(oPanel)
	oBrw:SetDescription(cTitle)
	oBrw:ForceQuitButton(.T.)
	oBrw:DisableDetails()
	oBrw:DisableReport()
	oBrw:setIgnoreaRotina(.T.)
	oBrw:SetMenuDef('')
	oBrw:SetUseFilter(.T.)
	if !empty(cFiltro)
		oBrw:SetFilterDefault(cFiltro)
	endif
	oBrw:Activate()
return(nil)

/* PE_MATA450A   FUNÇÂO M450AROT() */
user function cbcCredView(cCli, cLoja)
	local oCredito := nil	
	if empty(cCli) .Or. empty(cLoja)
		MessageBox("Selecione ao menos um cliente para consulta", "AVISO", 48)     
	else
		oCredito := CbcCredCliente():newCbcCredCliente(cCli, cLoja, 0)
		oCredito:initView()
	endif
return(nil)