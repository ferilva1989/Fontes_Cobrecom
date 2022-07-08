#Include "PROTHEUS.CH"
#include 'TopConn.ch'
#include 'RWMake.ch'
#include "TOTVS.CH"
 

#define DS_MODALFRAME   128


/*/{Protheus.doc} cbcPortMain
Tela Principal de Digitação do Ticket de Saída
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return nil
@type function
/*/
user function cbcPortMain()                        
	local aCoors 		:= FWGetDialogSize(oMainWnd)
	local cTitulo		:= 'Portaria saída de Notas'
	local oSayData		:= nil
	local oSayHora		:= nil
	local oSayMot		:= nil                                              
	local oSayTra		:= nil
	local oSayCar		:= nil
	local oGroup1		:= nil
	local aButtons 		:= {}
	local oBtnAdd		:= nil
	local oBtnDel		:= nil
	local oFont 		:= TFont():New('Courier new',,-16,.T.)
	local cCompo		:= ""
	local nLarg			:= 0
	static oDlg			:= nil
	static oPanel		:= nil
	static dData
	static cHora 		:= '' 
	static cMot 		:= ''
	static cCarr 		:= ''
	static cTransp 		:= ''
	static oGetData		:= nil
	static oGetHora		:= nil
	static oGetMot		:= nil
	static oGetTra		:= nil	
	static oGetCar		:= nil
	static oMsGet		:= nil
	static cChvEdit		:= Space(TamSX3("F2_CHVNFE")[1])
	static lLiOk		:= .T.
	Static aHeaderEx 	:= nil
	Static aColsEx 		:= nil
	Static aFieldFill 	:= nil
	
	
	// Valores de inicialização
	zeraVar()	
	
	// Definir Janela
	Define MsDialog oDlg Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	// Painel
	oPanel := TPanelCss():New(30,10,nil,oDlg,nil,nil,nil,nil,nil,((oMainWnd:nClientWidth)/2) - 40,((oMainWnd:nClientHeight) /2) - 40,nil,nil)
	styleCss(@oPanel)
	oPanel:align := CONTROL_ALIGN_ALLCLIENT
	
	// Largura da Tela de Trabalho
	nLarg := ((oMainWnd:nClientWidth)/2) - 50
	
	//Configurar Teclas de Atalho
	//F5 Adição
	SetKey(VK_F5, {||editGrid('A')})
	//F6 Remoção
	SetKey(VK_F6, {||editGrid('D')})
	//F8 Finalizar
	SetKey(VK_F8, {||,finaliza()})
		
	// Grupos de divisão de tela
	oGroup1	:= TGroup():New(02, 10, 75, nLarg, 'Dados da Saída',oPanel,,,.T.)
	styleCss(@oGroup1)
	
	// Botões da barra de opção
	aadd( aButtons, {"NOME_OPC", {|| Alert('NOME_OPC')}, "Opção...", "Opção" , {|| .T.}} )     
	EnchoiceBar(oDlg,{|| finaliza()},{|| encerra()},,@aButtons)

	// Carrega a Grid de Dados
	fMSNewGe1({'F2_FILIAL','F2_DOC','F2_SERIE','F2_CHVNFE'})
	
	//Divide tela em 3 partes Horizontais
	nLarg := nLarg / 3
	
	// Botões Avulsos
	oBtnAdd := TButton():New( 45, (nLarg*2), "Adicionar",oGroup1,{||editGrid('A')}, (nLarg/2)-5,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	styleCss(@oBtnAdd)
	oBtnDel := TButton():New( 45, (nLarg*2)+((nLarg/2)-5), "Remover",oGroup1,{||editGrid('D')}, (nLarg/2)-5,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	styleCss(@oBtnDel)
		
	// Says
	oSayData	:= TSay():New(15,15,	{||'Data:'},oPanel,,oFont,,,,.T.,CLR_RED,CLR_WHITE,(nLarg/2)-20,20)
	styleCss(@oSayData)
	oSayHora	:= TSay():New(15,(nLarg),	{||'Hora:'},oPanel,,oFont,,,,.T.,CLR_RED,CLR_WHITE,(nLarg/2)-20,20)
	styleCss(@oSayHora)
	oSayTra		:= TSay():New(15,(nLarg*2)/*220*/,	{||'Transporta:'},oPanel,,oFont,,,,.T.,CLR_RED,CLR_WHITE,(nLarg/2)-20,20)
	styleCss(@oSayTra)
	oSayMot		:= TSay():New(45,15,	{||'Motorista:'},oPanel,,oFont,,,,.T.,CLR_RED,CLR_WHITE,(nLarg/2)-20,20)
	styleCss(@oSayMot)
	oSayCar		:= TSay():New(45,(nLarg),	{||'Carregador:'},oPanel,,oFont,,,,.T.,CLR_RED,CLR_WHITE,(nLarg/2)-20,20)
	styleCss(@oSayCar)
	
	// Gets
	oGetData 	:= TGet():New(15,((nLarg/2)-20)+15,	{ | u | If( PCount() == 0, dData, dData:= u ) },oPanel,(nLarg/2)+5,020,'',,,,,,,.T.,'',,,.F.,.F.,,.F.,.F.,'','',,)
	styleCss(@oGetData)
	oGetHora 	:= TGet():New(15,/*152*/(nLarg)+((nLarg/2)-20),	{ | u | If( PCount() == 0, cHora, cHora:= u ) },oPanel,(nLarg/2)+5,020,X3Picture('F2_HORA'),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cHora,,,, )
	styleCss(@oGetHora)
	oGetTra		:= TGet():New(15,/*252*/(nLarg*2)+((nLarg/2)-20),	{ | u | if(Pcount() == 0, cTransp, cTransp := u ) },oPanel,(nLarg/2)+5,020,"@!",{|| validTran(cTransp) },,,, .T.,, .T.,, .T.,, .F., .F.,, .F., .F. ,"SA4",cTransp,,,,.T.)
	styleCss(@oGetTra)
	oGetMot		:= TGet():New(45,((nLarg/2)-20)+15,	{ | u | If( PCount() == 0, cMot, cMot:= u ) },oPanel,(nLarg/2)+5,020,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cMot,,,,)
	styleCss(@oGetMot)
	oGetCar		:= TGet():New(45,(nLarg)+((nLarg/2)-20),	{ | u | If( PCount() == 0, cCarr, cCarr := u ) },oPanel,(nLarg/2)+5,020,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCarr,,,,)
	styleCss(@oGetCar)
	
	//Ativar Tela					
	ACTIVATE MSDIALOG oDlg CENTERED
	
return(nil)


/*/{Protheus.doc} styleCss
Aplicação do Estilo CSS no Objeto passado.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return nil
@param oObj, object, Objeto para aplicação do CSS
Objetos habilitados:
"TPANELCSS"
"TGROUP"
"TSAY"
"TGET"
"TBUTTON"
@type function
/*/
static function styleCss(oObj)
	local cCss		:= ""
	local cCompo	:= ""
	
	// Identificar o Tipo do Objeto pela sua Classe
	cCompo := GetClassName(oObj)
	
	// Tipo de Obejtos Mapeados
	do case
		case cCompo == "TPANELCSS"
			cCss +=	 "QFrame {";
								+" color: #FFFFFF; /*Cor da fonte*/ ";		  						
		  						+" border-radius: 6px; /*Arrerondamento da borda*/ ";
		                      +" } "
          
		case cCompo == "TGROUP"
			cCss +=	 "QGroupBox {";
						+"  border: 2px solid #00297c; /*cor da borda*/";
						+"  border-radius: 5px;  /*arredondamento da borda*/";
						+"  margin-top: 2px; /*espaco ao topo para o titulo*/";
						+"}";
						+"/* Caracterissticas do titulo */";
						+" QGroupBox::title {";
						+"  color: #0F243E;";
						+"  font-size: 12px; /*Tamanho da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  subcontrol-origin: margin; /*margem*/";
						+"  padding: 0 3px; /*espacamento*/";
						+"  subcontrol-position: top center; /*posiciona texto ao topo+centro*/";
						+"}"
			
		case cCompo == "TSAY"
			cCss +=	"QLabel { ";
						+"  font-size: 24px; /*Tamanho da fonte*/";
						+"  color: #00297c; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
			
		case cCompo == "TGET"
			cCss +=	 "QLineEdit {";
						+"  color: #0F243E; /*Cor da fonte*/";
						+"  font-size: 16px; /*Tamanho da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  min-height: 40px; /*Largura minima*/";
						+"  border: 2px solid #17365D; /*Cor da borda*/";
						+"  border-radius: 10px; /*Arredondamento da borda*/";
						+"  padding: 0 8px; /*Especo (margem)*/";
						+"  background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
						+"                 stop: 0 #B8CCE4, stop: 1 #FFFFFF); /*Cor de fundo*/";
						+"  selection-background-color: #0872E3; /*Cor de fundo quando selecionado*/";
						+"}"
			
		case cCompo == "TBUTTON"
				cCSS +=	"QPushButton {";
						+"  color: #FFFFFF; /*Cor da fonte*/";
						+"  border: 2px solid #00297c; /*Cor da borda*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"  font-size: 24px; /*Tamanho da fonte*/";
						+"  color: #FFFFFF; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
						+"                                    stop: 0 #00297c, stop: 1 #cfddf9); /*Cor de fundo*/";
						+"  min-width: 80px; /*Largura minima*/";
						+"}";
						+"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
						+"QPushButton:pressed {";
						+"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
						+"                                    stop: 0 #cfddf9, stop: 1 #00297c);";
						+"}"								
	endCase		
	
	// Aplica o Css ao Objeto
	if !empty(cCss)
		 oObj:setCSS(cCSS)
	endif	
return(nil)


/*/{Protheus.doc} fMSNewGe1
Criação do Grid com NFs
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return nil
@param aFields, array, Campos irão para aHeader
@type function
/*/
static Function fMSNewGe1(aFields) 
	Local nX			:= 0
	Local aAlterFields 	:= {'F2_CHVNFE'}
	Local nBrwLarg		:= 0
	Local nBrwAlt		:= 0
	
	aHeaderEx 	:= {}
	aColsEx 	:= {}
	aFieldFill 	:= {}
			
	nBrwLarg	:= ((oMainWnd:nClientWidth)/2) - 50
	nBrwAlt		:= ((oMainWnd:nClientHeight) /2) - 50 
	
	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	for nX := 1 to Len(aFields)
		if SX3->(DbSeek(aFields[nX]))
			aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		endif
	next nX
	for nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	next nX
	aadd(aFieldFill, .F.)
	aadd(aColsEx, aFieldFill)
	oMsGet := MsNewGetDados():New( 75, 10, nBrwAlt, nBrwLarg,;
	GD_INSERT+GD_DELETE+GD_UPDATE, {||(thisLiok())}, {||(thisTdOk())}, "+Field1+Field2",;
	aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oPanel,;
	aHeaderEx, aColsEx)
		
	oMsGet:Disable()	
return (nil)


/*/{Protheus.doc} thisLiok
Validação da inserção da linha.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return lRet, Lógico, .T. - OK .F. - Erro
@type function
/*/
static function thisLiok()	
	local nLinha 	:= oMsGet:nAt 
	local lRet		:= .F.	
	local cChave	:= Alltrim(oMsGet:aCols[nLinha][4])
	local nCount	:= 0
	local cDoc		:= ""
	local cSerie	:= ""
	local cxFilial	:= ""
	local oInstSZF  := nil
	
	If !Empty(cChave)
		For nCount := 1 to (nLinha-1)
			If cChave == Alltrim(oMsGet:aCols[nCount][4])
				lLiOk		:= .F.
				Alert('NFe já informada!')
				Return(lRet)
			EndIf
		Next
		oInstSZF  := CbcSZFCtrl():NewCbcSZFCtrl() 			
		lRet := oInstSZF:validSF2(cChave):isOk()
		If !lRet
			lLiOk		:= .F.
			Alert(oInstSZF:getMsgErr())
		Else
			oInstSZF:SetRecnoF2(,cChave)
			cxFilial := oInstSZF:aF2[1]
			cDoc	 := oInstSZF:aF2[3]
			cSerie	 := oInstSZF:aF2[4]
			oMsGet:aCols[nLinha][1] := cxFilial
			oMsGet:aCols[nLinha][2] := cDoc
			oMsGet:aCols[nLinha][3] := cSerie
			lLiOk		:= .T.
		EndIf
		FreeObj(oInstSZF)
	Else
		if nLinha <> len(oMsGet:aCols)
			lLiOk		:= .F.
			Alert('Informe a chave da NFe!')
		endif
	EndIf	 
return(lRet)


/*/{Protheus.doc} thisTdOk
Validação de todas as linha inseridas no Grid.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return lRet, Lógico, .T. - OK .F. - Erro
@type function
/*/
static function thisTdOk()
	local lRet := .T.
return(lRet)


/*/{Protheus.doc} validTran
Validar se Transportadora informada está cadastrada(SA4).
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return lRet, Lógico, .T. - OK .F. - Erro
@param cCod, characters, Código da Transportadora (A4_COD).
@type function
/*/
static function validTran(cCod)
	DbSelectArea("SA4") 
	//A4_FILIAL+A4_COD                                                                                                                                                
	SA4->( DbSetOrder(1) )
	If !SA4->(DbSeek(xFilial("SA4") + cCod ))
		alert("Tranportadora não encontrada, Verifique!")
		return(.F.)
	EndiF
return(.T.)


/*/{Protheus.doc} finaliza
Validar e Enviar as Informações de Cabeçalho e as NFs para classe Controller CbcSZFCtrl
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return lRet, Lógico, .T. - OK .F. - Erro
@type function
/*/
static function finaliza()
	local oInstSZF	:= CbcSZFCtrl():NewCbcSZFCtrl()
	local aDadosZF	:= {}
	local nCount	:= 0
	local lRet		:= .T.
	
	if empty(dData) .Or. empty(cHora) .Or. empty(cTransp) .Or. empty(cCarr) .Or. empty(cMot)
		lRet := .F.
		Alert('Preencha todas as informações!')	
	else	
		if MsgYesNo('Confirma inclusão da Saída?')
			for nCount := 1 to len(oMsGet:aCols)	
				if !oMsGet:aCols[nCount][5] .And. !empty(AllTrim(oMsGet:aCols[nCount][4]))
					aAdd(aDadosZF,{;
									{"FILIAL",	oMsGet:aCols[nCount][1]},;
									{"DATA",	Dtos(dData)},;
									{"HORA",	cHora},;
									{"TRANS",	cTransp},;
									{"CARREG",	cCarr},;
									{"MOTOR",	cMot},;
									{"CHAVE",	oMsGet:aCols[nCount][4]}})
				endif					
			next
			if len(aDadosZF) == 0
				Alert('Informe NFes válidas para realizar a saída!')
				lRet := .F.
			else		
				lRet := oInstSZF:ConfSZF(aDadosZF):isOk()
				if lRet
					if MsgYesNo('Saída Registrada! Continuar incluindo?')
						zeraVar()
						updTela()
					else
						encerra()
					endif
				endif
			endif
		else
			lRet := .F.
		endif		
	endif		
	FreeObj(oInstSZF)
return(lRet)


/*/{Protheus.doc} encerra
Encerrar Tela, liberando as teclas de Atalho.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return .T.
@type function
/*/
static function encerra()
	FreeObj(oGetData)
	FreeObj(oGetHora)
	FreeObj(oGetMot)
	FreeObj(oGetTra)	
	FreeObj(oGetCar)
	FreeObj(oMsGet)
	//Liberar Teclas de Atalho
	//F5 Adição
	SetKey(VK_F5, {||})
	//F6 Remoção
	SetKey(VK_F6, {||})
	//F8 Finalizar
	SetKey(VK_F8, {||})
	oDlg:End()
return(.T.)


/*/{Protheus.doc} zeraVar
Zerrar valores e carregar valores padrões para Header e zerar Grid.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return nil
@type function
/*/
static function zeraVar()
	local nCount	:= 0
	local nToClear	:= 0
	
	//Zerar Header
	dData 	:= Ctod(Space(TamSx3('F2_EMISSAO')[1]))
	cHora 	:= Space(TamSx3('F2_HORA')[1])
	cMot 	:= Space(TamSx3('ZF_MOTOR')[1])
	cCarr 	:= Space(TamSx3('ZF_CARREG')[1])
	cTransp := Space(TamSX3("A4_COD")[1])
	
	//Valores Deafault
	dData 		:= dDataBase
	cHora 		:= SUBSTR(TIME(), 1, 5)
	
	//Zerar Grid se ele já foi montado
	if ValType(oMsGet) <> 'U'
		oMsGet:Enable()
		oMsGet:GoTo(len(oMsGet:aCols))
		//Limpar todas as linhas exceto a última que é sempre uma nova
		nToClear := (len(oMsGet:aCols)-1)
		for nCount := 1 to nToClear
			aDel(oMsGet:aCols, 1)
		next
		aSize(oMsGet:aCols, 1)
		oMsGet:ForceRefresh()
		oMsGet:GoTo(len(oMsGet:aCols))
		oMsGet:Disable()			
	endif
return(nil)


/*/{Protheus.doc} updTela
Refresh dos componentes da Tela.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return nil
@type function
/*/
static function updTela()
	//Update do Grid
	oMsGet:Enable()
		oMsGet:ForceRefresh()
		oMsGet:GoTo(len(oMsGet:aCols))
	oMsGet:Disable()
	//Update do Header
	oGetData:CtrlRefresh()
	oGetHora:CtrlRefresh()
	oGetMot:CtrlRefresh()
	oGetTra:CtrlRefresh()
	oGetCar:CtrlRefresh()
return(nil)


/*/{Protheus.doc} editGrid
Tela para Adição ou Remoção de NFs do Grid.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return .T.
@param cOpc, characters, Ação a ser reliazada: A - Adicionar ou D - Remover
@type function
/*/
static function editGrid(cOpc)
	local lRet
	local cTitle	:= ""
	Local nLinha	:= 2 //Posição inicial dos componentes
	local nPosX		:= 0
	local nPosY		:= 0
	local aButtons	:= {}
	local oBtnFim	:= nil
	local nWidth 	:= CalcFieldSize("C",Len(Space(TamSX3("F2_CHVNFE")[1])),,"@!","") + 10
	local cBlKVld	:= ""
	static oSayChv  := nil
	static oGetChv  := nil
	static oDlgPer 	:= nil
	static oPanelPer := nil
	
	// Libera Grid
	oMsGet:Enable()
	// Posiciona na Última Linha (Registro Novo)
	oMsGet:GoTo(len(oMsGet:aCols))
	
	// Define Bloco de Validação com base no Parâmetro	
	if cOpc == 'A'
		cBlKVld := "{||vldAdd()}" 
		cTitle	:= "Adicionar NFe"
	elseif cOpc == 'D'
		cBlKVld := "{||vldDel()}"
		cTitle	:= "Remover NFe"
	endif
	
	// Definição da Tela de Ação
	DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD
	
	If Type("oMainWnd") == "U"
		DEFINE MSDIALOG oDlgPer TITLE cTitle FROM nPosX,nPosY TO nPosX+100,nPosY+550 Pixel Style DS_MODALFRAME
	Else
		DEFINE MSDIALOG oDlgPer TITLE cTitle FROM nPosX,nPosY TO nPosX+100,nPosY+550 OF oMainWnd Pixel Style DS_MODALFRAME
	EndIF
	
	// Desabilitar ESC
	oDlgPer:lEscClose := .F.
	
	// Painels		
	oPanelPer := TScrollBox():New( oDlgPer, 8,10,nPosX+80,nPosY+520)
	oPanelPer:Align := CONTROL_ALIGN_ALLCLIENT
	styleCss(@oPanelPer)
	
	// Says
	oSayChv		:= TSay():New(nLinha, 05, {||'Chave:'},oPanelPer,,oFntVerdana,,,,.T.,CLR_RED,CLR_WHITE,50,20)
	styleCss(@oSayChv)
	
	// Gets
	oGetChv		:= TGet():New(nLinha,60, { | u | If( PCount() == 0, cChvEdit,cChvEdit:= u ) },oPanelPer,nWidth,020,"@!",&(cBlkVld),0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cChvEdit,,,, )
	styleCss(@oGetChv)
	
	// Liberar Teclas de Atalho da Tela Principal
	// F5 Adição
	SetKey(VK_F5, {||})
	// F6 Remoção
	SetKey(VK_F6, {||})
	// F8 Finalizar
	SetKey(VK_F8, {||})
	
	// Configurar Teclas de Atalho da Tela  de Ação
	// F7 - Finalizar
	SetKey(VK_F7, {||closeAdd()})
	
	// Carregar Botão para Finalizar Tela Ação	
	oBtnFim := TButton():New( 25, 10, "Finalizar",oPanelPer,{||closeAdd()}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	styleCss(@oBtnFim)
	
	// Ativar Tela de Ação		
	ACTIVATE MSDIALOG oDlgPer CENTERED

return(.T.)


/*/{Protheus.doc} vldAdd
Adicionar NFe ao Grid, adicionando a próxima linha em branco.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return lRet, Lógico, .T. - No Encerramento da Tela de Adição || .F. - Continuar Inserindo
@type function
/*/
static function vldAdd()
	local nLinha := oMsGet:nAt //Posição Atual no Grid
	local lRet   := .F.	
	lLiOk		 := .F. // Variável que controla Validação da Linha	
	 
	If !Empty(cChvEdit)
		// Validar se chave tem o tamanho correto
		if len(cChvEdit) == TamSX3("F2_CHVNFE")[1]
			// Atribuir Conteúdo ao Grid
			oMsGet:aCols[nLinha][4] := 	cChvEdit	
			// Adicionar nova linha
			oMsGet:addline()
			// Refresh do Grid
			oMsGet:ForceRefresh()
			// Refresh muda a posição para linha 1, aqui corrijo para atual
			oMsGet:GoTo(nLinha)
			// Ir para Linha nova, nesse momento executa LiOk
			oMsGet:GoBottom()
			// Posiciono na linha nova
			nLinha++
			oMsGet:GoTo(nLinha)
					
			// Falhou a validação do LiOK
			if !lLiOk
				// Voltar e excluir linha com conteúdo não aceito
				nLinha--
				// Deletar linha incorreta
				aDel(oMsGet:aCols, nLinha)
				// Ajustar tamanho do array, pois aDel deixa elemento Nil e reorganiza para o fim do array
				aSize(oMsGet:aCols, nLinha)				
				// Atualizar e Reposicionar
				oMsGet:ForceRefresh()
				oMsGet:GoTo(nLinha)			
				oMsGet:aCols[nLinha][4] := ""
			endif
		else
			Alert('Chave Incorreta!')
		endif
	else
		// Finalizando a Tela
		lRet := .T.
	endif
	//Retornar para próxima inserção
	cChvEdit := Space(TamSX3("F2_CHVNFE")[1])
	oGetChv:CtrlRefresh()
return(lRet)


/*/{Protheus.doc} vldDel
Remover NFe do Grid, reposicionar na linha em branco ao final.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return lRet, Lógico, .T. - No Encerramento da Tela de Adição || .F. - Continuar Deletando
@type function
/*/
static function vldDel()
	local nLinha := oMsGet:nAt
	local nCount := 0
	local lRet   := .F.
	
	If !Empty(cChvEdit)
		// Validar Tamanho da Chave está correto
		if len(cChvEdit) == TamSX3("F2_CHVNFE")[1]
			// Varrer o Grid
			For nCount := 1 to len(oMsGet:aCols)
				If cChvEdit == Alltrim(oMsGet:aCols[nCount][4])
					// Deleta aCols ou Linha do Grid
					aDel(oMsGet:aCols, nCount)
					// Ajustar tamanho do array, pois aDel deixa último elemento Nil
					aSize(oMsGet:aCols, (len(oMsGet:aCols)-1))
					// Já garanto uma chave apenas, assim posso sair do loop se achou
					Exit		
				EndIf
			Next
			// Atualizar o Grid
			oMsGet:ForceRefresh()
			// Posicionar na linha nova			
			oMsGet:GoTo(nLinha)
		else
			Alert('Chave Incorreta!')
		endif
	else
		//Finalizando a Tela
		lRet := .T.
	endif		
	//Retornar para próxima chave
	cChvEdit := Space(TamSX3("F2_CHVNFE")[1])
	oGetChv:CtrlRefresh()	
return(lRet)


/*/{Protheus.doc} closeAdd
Encerrar Tela de ação, liberando a tecla de Atalho e mapeando as da tela principal.
@author alexandre.madeira
@since 03/10/2018
@version 1.0
@return .T.
/*/
static function closeAdd()
	Close(oDlgPer)
	oMsGet:ForceRefresh()
	oMsGet:Disable()
	// Libera Tecla de Atalho da Tela de Ação
	SetKey(VK_F7, {||})	
	
	//Configurar Teclas de Atalho da Tela Principal
	//F5 Adição
	SetKey(VK_F5, {||editGrid('A')})
	//F6 Remoção
	SetKey(VK_F6, {||editGrid('D')})
	//F8 Finalizar
	SetKey(VK_F8, {||,finaliza()})	
return(.T.)
